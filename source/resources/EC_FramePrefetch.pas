unit EC_FramePrefetch;

{$I GameOptions.inc}

// Decodes animation frames on a worker thread before they are drawn.
//
// A large animation frame decoded on its first draw stalls the frame that
// shows it; the hangar's 624x323 holograms cost 10-15 ms per frame on a
// handheld. Owners queue the frames they will draw next; the worker decodes
// them into pixel buffers, and the render thread only copies a finished
// buffer into a new texture. Jobs point into the owner's immutable source
// data, so an owner must call CancelFramePrefetch before freeing it.

interface

uses
  Types;

type
  PPrefetchedFrame = ^TPrefetchedFrame;

  TPrefetchedFrame = record
    Owner: Pointer;
    FrameIndex: Integer;
    Source: Pointer;
    SourceSize: Integer;
    Compressed: Boolean;
    Running, Done: Boolean;
    // Results, valid once Done. Pixels has the texture's format and pitch;
    // an empty frame has no content, and a failed one is decoded again by
    // the owner so the error surfaces where it always did.
    Empty, Failed: Boolean;
    Pixels: Pointer;
    Width, Height, Pitch: Integer;
    Format: Cardinal;
    TopLeft: TPoint;
    QueuedTick: QWord;
  end;

// Queues a frame unless it is already queued or the queue is full. Source is
// the frame's gi data inside the owner's buffer.
procedure RequestFramePrefetch(Owner: Pointer; FrameIndex: Integer; Source: Pointer; SourceSize: Integer; Compressed: Boolean);
// Returns the decoded frame and removes it from the queue, waiting if the
// worker is decoding it now; nil if the frame is not queued or not started.
// The caller frees the result with FreePrefetchedFrame.
function TakePrefetchedFrame(Owner: Pointer; FrameIndex: Integer): PPrefetchedFrame;
procedure FreePrefetchedFrame(Frame: PPrefetchedFrame);
// Drops every frame of the owner, waiting for one being decoded.
procedure CancelFramePrefetch(Owner: Pointer);
function FramePrefetchAvailable: Boolean;

implementation

uses
{$IFNDEF FPC_WASM_EMSCRIPTEN}
  Classes,
{$ENDIF}
  SysUtils,
  Direct3D9,
  EC_OKGF,
  GameDiagnostics,
  GameWindow,
  GR_gi;

const
  MaxQueuedFrames = 16;
  // Decoded frames waiting to be drawn; about 20 frames of 624x323.
  MaxResultBytes = 16 * 1024 * 1024;
  // An animation that stopped never takes its frames.
  ResultLifetimeMs = 10000;

{$IFNDEF FPC_WASM_EMSCRIPTEN}

type
  TFramePrefetchWorker = class(TThread)
  protected
    procedure Execute; override;
  end;

var
  Lock: TRTLCriticalSection;
  WorkEvent, DoneEvent: PRTLEvent;
  Frames: TList;
  Worker: TFramePrefetchWorker;
  ResultBytes: SizeUInt;
  Disabled: Boolean;

procedure DecodeFrame(Frame: PPrefetchedFrame);
var
  Image: TgiGR;
  Unpacked: Pointer;
  UnpackedSize, Bpp: Integer;
begin
  Unpacked := nil;
  Image := TgiGR.Create;
  try
    // TgiGR.LoadCompressedGiBytes allocates through AllocEC, which evicts
    // textures when memory runs out; only the render thread may do that.
    if Frame.Compressed then
    begin
      if Frame.SourceSize >= 8 then
      begin
        UnpackedSize := OKGF_ZLib_UnCompress(nil, 0, Frame.Source, Frame.SourceSize);
        if UnpackedSize > 0 then
        begin
          GetMem(Unpacked, UnpackedSize);
          UnpackedSize := OKGF_ZLib_UnCompress(Unpacked, UnpackedSize, Frame.Source, Frame.SourceSize);
          if UnpackedSize > 0 then
            Image.LoadRawGiBytes(Unpacked, UnpackedSize);
        end;
      end;
    end
    else
      Image.LoadRawGiBytes(Frame.Source, Frame.SourceSize);
    if Image.IsEmpty or (Image.GetContentSize.X = 0) or (Image.GetContentSize.Y = 0) then
    begin
      Frame.Empty := True;
      Exit;
    end;
    Frame.Width := Image.GetContentSize.X;
    Frame.Height := Image.GetContentSize.Y;
    Frame.TopLeft := Image.GetTopLeft;
    // Same choice and pitch as TCGaiEC.GetOrCreateFrameSurface and the
    // texture storage, so the render thread copies the buffer as a whole.
    if (Image.Header.Format = 0) and (Image.Header.AlphaMask = 0) then
    begin
      Frame.Format := D3DFMT_R5G6B5;
      Bpp := 2;
    end
    else
    begin
      Frame.Format := D3DFMT_A8R8G8B8;
      Bpp := 4;
    end;
    Frame.Pitch := (Frame.Width * Bpp + 3) and not 3;
    Frame.Pixels := AllocMem(SizeUInt(Frame.Pitch) * Frame.Height);
    Image.DecodeToPixels(Frame.Pixels, Frame.Pitch, Frame.Width, Frame.Height, True);
  finally
    Image.Free;
    if Unpacked <> nil then
      FreeMem(Unpacked);
  end;
end;

procedure TFramePrefetchWorker.Execute;
var
  Index: Integer;
  Frame: PPrefetchedFrame;
begin
  while not Terminated do
  begin
    Frame := nil;
    EnterCriticalSection(Lock);
    for Index := 0 to Frames.Count - 1 do
      if not PPrefetchedFrame(Frames[Index]).Running and not PPrefetchedFrame(Frames[Index]).Done then
      begin
        Frame := Frames[Index];
        Frame.Running := True;
        Break;
      end;
    LeaveCriticalSection(Lock);
    if Frame = nil then
    begin
      RTLEventWaitFor(WorkEvent);
      Continue;
    end;
    try
      DecodeFrame(Frame);
    except
      if Frame.Pixels <> nil then
        FreeMem(Frame.Pixels);
      Frame.Pixels := nil;
      Frame.Failed := True;
    end;
    EnterCriticalSection(Lock);
    Frame.Running := False;
    Frame.Done := True;
    if Frame.Pixels <> nil then
      Inc(ResultBytes, SizeUInt(Frame.Pitch) * Frame.Height);
    LeaveCriticalSection(Lock);
    RTLEventSetEvent(DoneEvent);
  end;
end;

function StartWorker: Boolean;
begin
  if Worker = nil then
  begin
    if Disabled or (TThread.ProcessorCount < 2) then
    begin
      Disabled := True;
      Exit(False);
    end;
    try
      Worker := TFramePrefetchWorker.Create(False);
    except
      LogCurrentGameException('graphics', 'starting the frame prefetch thread; frames decode on first draw', gllWarning);
      Worker := nil;
      Disabled := True;
      Exit(False);
    end;
  end;
  Result := True;
end;

function FramePrefetchAvailable: Boolean;
begin
  Result := not Disabled;
end;

// Under Lock: the frame leaves the queue and its result no longer counts.
procedure RemoveFrame(Index: Integer);
var
  Frame: PPrefetchedFrame;
begin
  Frame := Frames[Index];
  Frames.Delete(Index);
  if Frame.Pixels <> nil then
    Dec(ResultBytes, SizeUInt(Frame.Pitch) * Frame.Height);
end;

function FindFrame(Owner: Pointer; FrameIndex: Integer): Integer;
var
  Index: Integer;
begin
  for Index := 0 to Frames.Count - 1 do
    if (PPrefetchedFrame(Frames[Index]).Owner = Owner) and (PPrefetchedFrame(Frames[Index]).FrameIndex = FrameIndex) then
      Exit(Index);
  Result := -1;
end;

procedure RequestFramePrefetch(Owner: Pointer; FrameIndex: Integer; Source: Pointer; SourceSize: Integer; Compressed: Boolean);
var
  Index: Integer;
  Frame: PPrefetchedFrame;
  Now: QWord;
begin
  if (Source = nil) or (SourceSize <= 0) or not StartWorker then
    Exit;
  Now := GetTickCount64;
  EnterCriticalSection(Lock);
  try
    Index := 0;
    while Index < Frames.Count do
    begin
      Frame := Frames[Index];
      if Frame.Done and (Now - Frame.QueuedTick > ResultLifetimeMs) then
      begin
        RemoveFrame(Index);
        FreePrefetchedFrame(Frame);
        Inc(GamePrefetchedFramesDropped);
      end
      else
        Inc(Index);
    end;
    if (Frames.Count >= MaxQueuedFrames) or (ResultBytes >= MaxResultBytes) or (FindFrame(Owner, FrameIndex) >= 0) then
      Exit;
    New(Frame);
    FillChar(Frame^, SizeOf(Frame^), 0);
    Frame.Owner := Owner;
    Frame.FrameIndex := FrameIndex;
    Frame.Source := Source;
    Frame.SourceSize := SourceSize;
    Frame.Compressed := Compressed;
    Frame.QueuedTick := Now;
    Frames.Add(Frame);
  finally
    LeaveCriticalSection(Lock);
  end;
  RTLEventSetEvent(WorkEvent);
end;

function TakePrefetchedFrame(Owner: Pointer; FrameIndex: Integer): PPrefetchedFrame;
var
  Index: Integer;
begin
  Result := nil;
  if Worker = nil then
    Exit;
  EnterCriticalSection(Lock);
  try
    while True do
    begin
      Index := FindFrame(Owner, FrameIndex);
      if Index < 0 then
        Exit;
      Result := Frames[Index];
      if not Result.Running then
        Break;
      // The worker is decoding this frame: finishing it is faster than
      // decoding it again here.
      LeaveCriticalSection(Lock);
      RTLEventWaitFor(DoneEvent, 5);
      EnterCriticalSection(Lock);
    end;
    RemoveFrame(Index);
  finally
    LeaveCriticalSection(Lock);
  end;
  if not Result.Done then
  begin
    // Still queued: decoding it here costs the same as waiting for it.
    FreePrefetchedFrame(Result);
    Result := nil;
  end
  else
    Inc(GamePrefetchedFramesUsed);
end;

procedure FreePrefetchedFrame(Frame: PPrefetchedFrame);
begin
  if Frame = nil then
    Exit;
  if Frame.Pixels <> nil then
    FreeMem(Frame.Pixels);
  Dispose(Frame);
end;

procedure CancelFramePrefetch(Owner: Pointer);
var
  Index: Integer;
  Frame: PPrefetchedFrame;
  Busy: Boolean;
begin
  if Worker = nil then
    Exit;
  EnterCriticalSection(Lock);
  try
    repeat
      Busy := False;
      Index := 0;
      while Index < Frames.Count do
      begin
        Frame := Frames[Index];
        if Frame.Owner <> Owner then
          Inc(Index)
        else if Frame.Running then
        begin
          Busy := True;
          Inc(Index);
        end
        else
        begin
          RemoveFrame(Index);
          if Frame.Done then
            Inc(GamePrefetchedFramesDropped);
          FreePrefetchedFrame(Frame);
        end;
      end;
      if Busy then
      begin
        LeaveCriticalSection(Lock);
        RTLEventWaitFor(DoneEvent, 5);
        EnterCriticalSection(Lock);
      end;
    until not Busy;
  finally
    LeaveCriticalSection(Lock);
  end;
end;

initialization
  InitCriticalSection(Lock);
  WorkEvent := RTLEventCreate;
  DoneEvent := RTLEventCreate;
  Frames := TList.Create;

finalization
  if Worker <> nil then
  begin
    Worker.Terminate;
    RTLEventSetEvent(WorkEvent);
    Worker.WaitFor;
    Worker.Free;
    Worker := nil;
  end;
  // Caches freed by later finalizations find nothing left to cancel.
  Disabled := True;
  while Frames.Count > 0 do
  begin
    FreePrefetchedFrame(Frames[Frames.Count - 1]);
    Frames.Delete(Frames.Count - 1);
  end;
  Frames.Free;
  RTLEventDestroy(WorkEvent);
  RTLEventDestroy(DoneEvent);
  DoneCriticalSection(Lock);

{$ELSE}

// The browser build has no threads; frames decode on their first draw.

procedure RequestFramePrefetch(Owner: Pointer; FrameIndex: Integer; Source: Pointer; SourceSize: Integer; Compressed: Boolean);
begin
end;

function TakePrefetchedFrame(Owner: Pointer; FrameIndex: Integer): PPrefetchedFrame;
begin
  Result := nil;
end;

procedure FreePrefetchedFrame(Frame: PPrefetchedFrame);
begin
end;

procedure CancelFramePrefetch(Owner: Pointer);
begin
end;

function FramePrefetchAvailable: Boolean;
begin
  Result := False;
end;

{$ENDIF}

end.
