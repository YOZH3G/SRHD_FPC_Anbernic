unit GR_Music;

{$I GameOptions.inc}

interface

uses
  GameEvents,
  EC_Thread,
  EC_FileStream,
  VorbisFile,
  GR_Sound,
  SyncObjs;

type

  TMusicControl = class;

  TMusicUnit = class;

  TMusicUnit = class(TThreadEC)
    Decoder: TOggWorker;
    DeferredPlayback: Boolean;
    RequestedFileName: WideString;
    ImmediateStop: Boolean;
    Buffer: TSoundBuffer;
    DecodeLock: TCriticalSection;
    Stream: TFileStreamEC;
    StartPlaybackEvent: TGameEventHandle;
    CompletionEvent: TGameEventHandle;
    procedure Execute; override;
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure LoadFile(const FileName: WideString; Deferred: Boolean);
    function GetFileName: WideString;
    function IsIntroTrack: Boolean;
  end;

  TMusicControl = class(TThreadEC)
    CompletionEvent: TGameEventHandle;
    ControlLock: TCriticalSection;
    Current: TMusicUnit;
    Queued: TMusicUnit;
    Gap3C: array[0..3] of Byte;
    CurrentFileName: WideString;
    CategoryOverride: WideString;
    procedure Execute; override;
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure PlayFile(const FileName: WideString);
    procedure PlayCategory(const Category: WideString);
    procedure RequestFadeOut;
    procedure StopImmediately;
    function HasSelectedMusic: Boolean;
    function IsPlaying: Boolean;
  end;

function ChooseMusicFile(const Category: WideString; const CurrentFile: WideString): WideString;

implementation

uses
  GlobalsV,
  Types,
  SysUtils,
  DirectSound,
  EC_Str,
  EC_BlockPar,
  GR_Main;

const
  MusicChunkBytes = 2 * VorbisOutputBytesPerSecond;
  MusicEndFadeThresholdBytes = $C800;

constructor TMusicUnit.Create;
begin
  inherited Create;
  Buffer := nil;
  DecodeLock := nil;
  // The controller can signal this while the worker clears a finished track.
  // Keep its address stable until destruction, after playback has completed.
  StartPlaybackEvent := CreateGameEvent(False, False);
  DecodeLock := TCriticalSection.Create;
  Decoder := TOggWorker.Create(@DecodeLock);
  Buffer := SoundManager.AddBuffer;
end;

destructor TMusicUnit.Destroy;
begin
  RequestStop;
  SetGameEvent(StartPlaybackEvent);
  // Destruction waits for completion without re-raising a pending worker error.
  WaitGameEvent(IdleEvent, INFINITE);
  Clear;
  CloseGameEvent(StartPlaybackEvent);
  StartPlaybackEvent := 0;
  if Buffer <> nil then
  begin
    SoundManager.RemoveBuffer(Buffer);
    Buffer := nil;
  end;
  FreeAndNil(Decoder);
  if DecodeLock <> nil then
  begin
    DecodeLock.Free;
    DecodeLock := nil;
  end;
  inherited Destroy;
end;

procedure TMusicUnit.Clear;
begin
  ImmediateStop := False;
  if Decoder <> nil then
    Decoder.CloseStream;
  if Buffer <> nil then
    Buffer.Clear;
  if DecodeLock = nil then
    Exit;
  DecodeLock.Enter;
  try
    FreeAndNil(Stream);
  finally
    DecodeLock.Leave;
  end;
end;

procedure TMusicUnit.LoadFile(const FileName: WideString; Deferred: Boolean);
begin
  if GetFileName <> FileName then
  begin
    RequestedFileName := FileName;
    if IsRunning then
    begin
      RequestStop;
      SetGameEvent(StartPlaybackEvent);
      WaitForIdle(INFINITE);
    end;
    Clear;
    Stream := TFileStreamEC.Create($400FF, FileName);
    // No playback is active here; discard signals belonging to the previous track.
    ResetGameEvent(StartPlaybackEvent);
    DeferredPlayback := Deferred;
    if Deferred then
      SetPriority(ThreadPriorityLowest)
    else
      SetPriority(ThreadPriorityAboveNormal);
    Start;
  end;
end;

function TMusicUnit.GetFileName: WideString;
begin
  if not IsRunning then
    Result := '';
  DecodeLock.Enter;
  if Stream = nil then
    Result := ''
  else
    Result := Stream.SourceFile.GetFileName;
  DecodeLock.Leave;
end;

function TMusicUnit.IsIntroTrack: Boolean;
begin
  Result :=
      (GetFileName = 'music\1c.dat')
          or (GetFileName = 'music\logo.dat')
          or (GetFileName = 'music\intro.dat');
end;

procedure TMusicUnit.Execute;
var
  Ended: Boolean;
  Format: TSoundWaveFormat;
  Chunk: Integer;
begin
  // Always wake the controller, including when opening the decoder fails or
  // releasing the failed stream raises during cleanup.
  try
    if OpenVorbisStream(Decoder, Format, Stream) = 0 then
      Exit;
    try
      Buffer.InitStream(MusicChunkBytes, @Format);
      if not Buffer.WriteStream(SoundStreamPrimeAll, Decoder) then
        Exit;
      if DeferredPlayback then
      begin
        WaitGameEvent(StartPlaybackEvent, INFINITE);
        if IsStopRequested then
          Exit;
        SetPriority(ThreadPriorityAboveNormal);
        SysUtils.Sleep(100);
        SysUtils.Sleep(100);
      end;
      Ended := False;
      if IsIntroTrack then
        Buffer.SetVolumeScale(1)
      else
        Buffer.SetVolumeScale(0);
      if not IsIntroTrack then
        Buffer.StartVolumeRamp(100, 0.1);
      Buffer.Play(False);
      repeat
        Chunk := Buffer.WaitForChunk;
      until Chunk <> 0;
      while not Ended do
      begin
        if ImmediateStop then
          Break;
        if IsStopRequested then
        begin
          SetStopRequested(False);
          if not IsIntroTrack then
            Buffer.StartVolumeRamp(100, -0.1);
        end;
        Ended := not Buffer.WriteStream(Chunk, Decoder);
        if Stream.EndOfFile then
          if Stream.FillAvailable + Stream.ReadAvailable <= MusicEndFadeThresholdBytes then
            RequestStop;
        Chunk := Buffer.WaitForChunk;
        if Chunk < 0 then
          Break;
      end;
    except
    end;
  finally
    try
      Clear;
    finally
      SetGameEvent(CompletionEvent);
    end;
  end;
end;

constructor TMusicControl.Create;
begin
  inherited Create;
  Current := nil;
  Queued := nil;
  ControlLock := TCriticalSection.Create;
  if MusicEnabled then
  begin
    if MusicEnabled then
    begin
      Current := TMusicUnit.Create;
      Queued := TMusicUnit.Create;
      // Native order: Current receives the still-zero handle before creation.
      Current.CompletionEvent := CompletionEvent;
      Queued.CompletionEvent := 0;
    end;
    SetPriority(ThreadPriorityAboveNormal);
    CompletionEvent := CreateGameEvent(False, False);
    if CompletionEvent = 0 then
      raise Exception.Create('CreateEvent');
    if MusicEnabled then
      Start;
    AppendLogLineThreadSafe('Pre-fetching music.... ok!');
  end;
end;

destructor TMusicControl.Destroy;
begin
  RequestStop;
  if CompletionEvent <> 0 then
    SetGameEvent(CompletionEvent);
  WaitGameEvent(IdleEvent, INFINITE);
  Clear;
  if CompletionEvent <> 0 then
  begin
    CloseGameEvent(CompletionEvent);
    CompletionEvent := 0;
  end;
  if ControlLock <> nil then
  begin
    ControlLock.Free;
    ControlLock := nil;
  end;
  inherited Destroy;
end;

procedure TMusicControl.Clear;
begin
  if Current <> nil then
  begin
    Current.RequestStop;
    SetGameEvent(Current.StartPlaybackEvent);
  end;
  if Queued <> nil then
  begin
    Queued.RequestStop;
    SetGameEvent(Queued.StartPlaybackEvent);
  end;
  if Current <> nil then
    WaitGameEvent(Current.IdleEvent, INFINITE);
  if Queued <> nil then
    WaitGameEvent(Queued.IdleEvent, INFINITE);
  if Current <> nil then
  begin
    Current.Free;
    Current := nil;
  end;
  if Queued <> nil then
  begin
    Queued.Free;
    Queued := nil;
  end;
end;

procedure TMusicControl.Execute;
var
  Previous: TMusicUnit;
begin
  while not IsStopRequested do
  begin
    WaitGameEvent(CompletionEvent, INFINITE);
    if IsStopRequested then
      Break;
    SysUtils.Sleep(10);
    ControlLock.Enter;
    try
      if Queued.IsRunning then
      begin
        Previous := Current;
        Current := Queued;
        Queued := Previous;
        CurrentFileName := Current.GetFileName;
        Current.CompletionEvent := CompletionEvent;
        Queued.CompletionEvent := 0;
        SetGameEvent(Current.StartPlaybackEvent);
      end;
    finally
      // IsRunning can raise a stored worker failure. Release before this worker
      // exits so later music requests and destruction can still acquire the lock.
      ControlLock.Leave;
    end;
  end;
end;

procedure TMusicControl.PlayFile(const FileName: WideString);
begin
  if not MusicEnabled then
    Exit;
  if FileName = '' then
    Exit;
  ControlLock.Enter;
  try
    if Queued.IsRunning then
    begin
      Queued.RequestStop;
      SetGameEvent(Queued.StartPlaybackEvent);
      Queued.WaitForIdle(INFINITE);
    end;
    Queued.LoadFile(FileName, True);
    if Current.IsRunning then
      Current.RequestStop
    else
      SetGameEvent(CompletionEvent);
  finally
    ControlLock.Leave;
  end;
end;

procedure TMusicControl.PlayCategory(const Category: WideString);
var
  Attempts: Integer;
  Chosen: WideString;
begin
  if MusicEnabled then
  begin
    ControlLock.Enter;
    try
      if CategoryOverride = '' then
      begin
        Chosen := ChooseMusicFile(Category, Current.GetFileName);
        if (Chosen <> '') and (Chosen = CurrentFileName) then
          Chosen := ChooseMusicFile('All', Current.GetFileName);
      end
      else
      begin
        Attempts := 0;
        repeat
          Chosen := ChooseMusicFile(CategoryOverride, Current.GetFileName);
          Inc(Attempts);
          if Attempts > 20 then
            Break;
        until (Chosen = '') or (Chosen <> CurrentFileName);
      end;
      if Chosen <> '' then
        PlayFile(Chosen);
    finally
      ControlLock.Leave;
    end;
  end;
end;

procedure TMusicControl.RequestFadeOut;
begin
  if MusicEnabled and Current.IsRunning then
    Current.RequestStop;
end;

procedure TMusicControl.StopImmediately;
begin
  if MusicEnabled and Current.IsRunning then
  begin
    Current.RequestStop;
    Current.ImmediateStop := True;
  end;
end;

function TMusicControl.HasSelectedMusic: Boolean;
begin
  ControlLock.Enter;
  try
    Result := (Current.GetFileName <> '') or (Queued.GetFileName <> '');
  finally
    ControlLock.Leave;
  end;
end;

function TMusicControl.IsPlaying: Boolean;
begin
  ControlLock.Enter;
  try
    Result :=
        ((Current <> nil) and (Current.Buffer <> nil) and Current.Buffer.IsPlaying)
            or ((Queued <> nil) and (Queued.Buffer <> nil) and Queued.Buffer.IsPlaying);
  finally
    ControlLock.Leave;
  end;
end;

function ChooseMusicFile(const Category, CurrentFile: WideString): WideString;
var
  Block: TBlockParEC;
  Count, Index, Weight: Integer;
begin
  try
    Block := MainDataConfig.GetBlockByPath('Music.' + Category);
    Count := Block.GetParamCount;
    for Index := 0 to Count - 1 do
      if (Block.GetParamValue(Index) <> '')
          and (TrimWideString(LowerCaseWideString(Block.GetParamValue(Index))) = CurrentFile) then
      begin
        Result := '';
        Exit;
      end;
    Weight := 0;
    for Index := 0 to Count - 1 do
      if Block.GetParamValue(Index) <> '' then
        Inc(Weight, ExtractDigitsToIntW(Block.GetParamName(Index)));
    Weight := Random(Weight);
    for Index := 0 to Count - 1 do
      if Block.GetParamValue(Index) <> '' then
      begin
        Dec(Weight, ExtractDigitsToIntW(Block.GetParamName(Index)));
        if Weight < 0 then
        begin
          Result := TrimWideString(LowerCaseWideString(Block.GetParamValue(Index)));
          AppendLogLineThreadSafe(AnsiString(Result));
          Exit;
        end;
      end;
  except
    Result := '';
  end;
end;

end.
