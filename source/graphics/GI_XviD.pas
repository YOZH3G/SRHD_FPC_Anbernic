unit GI_XviD;

{$I GameOptions.inc}

interface

uses
  EC_File,
  EC_Buf,
  EC_BlockPar,
  GI_MessageLoop,
  GameAVI,
  Dynlibs;

type

  TxvidGI = class;

  TXvidFunction =
      function(Handle: Pointer; Option: Integer; Param1: Pointer; Param2: Pointer): Integer; cdecl;

  {$PUSH}
  {$PACKRECORDS C}
  TXvidGlobalInit = record
    Version: Integer;
    CpuFlags: Cardinal;
    Debug: Integer;
  end;

  TXvidDecoderCreate = record
    Version: Integer;
    Width: Integer;
    Height: Integer;
    Handle: Pointer;
  end;

  TXvidImage = record
    ColorSpace: Integer;
    Planes: array[0..3] of Pointer;
    Strides: array[0..3] of Integer;
  end;

  TXvidDecoderFrame = record
    Version: Integer;
    General: Integer;
    Bitstream: Pointer;
    Length: Integer;
    Output: TXvidImage;
    Brightness: Integer;
  end;

  {$POP}

  TxvidGI = class(TObjectGI)
    SourceFile: TFileEC;
    CompressedFrame: TBufEC;
    Gap128: array[0..7] of Byte;
    DecoderHandle: Pointer;
    DecodedFrameCount: Integer;
    TargetFrame: Integer;
    VideoWidth: Integer;
    VideoHeight: Integer;
    PlaybackFinished: TObjectNotifyEventGI;
    ColorSpace: Integer;
    FillViewport: Boolean;
    AviFile: TGameAVI;
    FrameCount: Integer;
    FramesPerSecond: Double;
    procedure Clear; override;
    procedure LoadFromConfigPath(const Path: WideString); override;
    procedure LoadFromBlock(Block: TBlockParEC); override;
    constructor Create(Owner: TObjectGI);
    destructor Destroy; override;
    function ImageOpen(const FileName: WideString; FillViewport: Boolean): Boolean;
    procedure XvidClose;
    procedure ImageClose;
    procedure ReadVideoConfig(Block: TBlockParEC);
    function DecodeNextFrame: Boolean;
    function SetPlaybackTime(TimeMs: Double): Boolean;
    procedure SetFramePosition(Frame: Integer);
  end;

const
{$IFDEF MSWINDOWS}
  XvidLibraryName = 'xvidcore.dll';
{$ELSE}
  {$IFDEF DARWIN}
  XvidLibraryName = 'libxvidcore.dylib';
  {$ELSE}
  XvidLibraryName = 'libxvidcore.so.4';
  {$ENDIF}
{$ENDIF}

var
  XvidLibrary: TLibHandle = 0;

  XvidGlobal: TXvidFunction = nil;

  XvidDecore: TXvidFunction = nil;

implementation

uses
  Types,
  SysUtils,
  Direct3D9,
  GR_DX,
  GR_Main,
  EC_Str,
  EC_Struct;

constructor TxvidGI.Create(Owner: TObjectGI);
begin
  inherited Create(Owner);
end;

destructor TxvidGI.Destroy;
begin
  ImageClose;
  inherited Destroy;
end;

procedure TxvidGI.Clear;
begin
  ImageClose;
  inherited Clear;
end;

function TxvidGI.ImageOpen(const FileName: WideString; FillViewport: Boolean): Boolean;
var
  ErrorCode, Status: Integer;
  GlobalInit: TXvidGlobalInit;
  DecoderCreate: TXvidDecoderCreate;
begin
  Result := True;
  Self.FillViewport := FillViewport;
  ImageClose;
  try
    if XvidLibrary = 0 then
    begin
      XvidLibrary := LoadLibrary(XvidLibraryName);
      if XvidLibrary = 0 then
        RaiseWideMessage('Error loading ' + XvidLibraryName + ': ' + GetLoadErrorStr);
      XvidGlobal := GetProcAddress(XvidLibrary, 'xvid_global');
      if not Assigned(XvidGlobal) then
        RaiseWideMessage('Error xvid_global');
      XvidDecore := GetProcAddress(XvidLibrary, 'xvid_decore');
      if not Assigned(XvidDecore) then
        RaiseWideMessage('Error xvid_decore');
    end;
    FillChar(GlobalInit, SizeOf(GlobalInit), 0);
    GlobalInit.Version := $10100;
    GlobalInit.CpuFlags := 0;
    XvidGlobal(nil, 0, @GlobalInit, nil);
    SourceFile := TFileEC.Create;
    CompressedFrame := TBufEC.Create;
    CompressedFrame.SetSize($180000);
    AviFile := TGameAVI.Create(FileName);
    FramesPerSecond := AviFile.FramesPerSecond;
    FrameCount := AviFile.FrameCount;
    FillChar(DecoderCreate, SizeOf(DecoderCreate), 0);
    DecoderCreate.Version := $10100;
    DecoderCreate.Width := AviFile.Width;
    DecoderCreate.Height := AviFile.Height;
    Status := XvidDecore(nil, 0, @DecoderCreate, nil);
    if Status <> 0 then
      RaiseWideMessage('Error xvid_decore_func = ' + IntToStr(Status));
    DecoderHandle := DecoderCreate.Handle;
    DecodedFrameCount := 0;
    ColorSpace := $40;
    VideoWidth := AviFile.Width;
    VideoHeight := AviFile.Height;
    if Direct3DDevice = nil then
      raise Exception.Create('TxvidGI.ImageOpen(..)::GR_D3DDevice = nil');
    ErrorCode :=
        Direct3DDevice.CreateTexture(
            VideoWidth,
            VideoHeight,
            1,
            0,
            D3DFMT_X8R8G8B8,
            D3DPOOL_MANAGED,
            OffscreenTexture,
            nil
        );
    if ErrorCode <> 0 then
      raise Exception.Create(Direct3DErrorText(ErrorCode));
    SetFramePosition(1);
    OffscreenFillViewport := Self.FillViewport;
  except
    on E: Exception do
    begin
      AppendLogLineThreadSafe(E.ClassName + ' ' + E.Message);
      Result := False;
      ImageClose;
    end;
  end;
end;

procedure TxvidGI.XvidClose;
var
  Status: Integer;
begin
  if DecoderHandle <> nil then
  begin
    Status := XvidDecore(DecoderHandle, 1, nil, nil);
    DecoderHandle := nil;
    if Status <> 0 then
      AppendLogLineThreadSafe(
          'Error XvidClose: xvid_decore_func - XVID_DEC_DESTROY = ' + IntToStr(Status)
      );
  end;
  FreeAndNil(AviFile);
end;

procedure TxvidGI.ImageClose;
begin
  XvidClose;
  if SourceFile <> nil then
  begin
    SourceFile.Free;
    SourceFile := nil;
  end;
  if CompressedFrame <> nil then
  begin
    CompressedFrame.Free;
    CompressedFrame := nil;
  end;
  if OffscreenTexture <> nil then
    OffscreenTexture := nil;
end;

procedure TxvidGI.LoadFromConfigPath(const Path: WideString);
begin
  inherited LoadFromConfigPath(Path);
  ReadVideoConfig(UiStyleConfig.GetBlockByPath(Path));
end;

procedure TxvidGI.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  ReadVideoConfig(Block);
end;

procedure TxvidGI.ReadVideoConfig(Block: TBlockParEC);
begin
end;

function TxvidGI.DecodeNextFrame: Boolean;
var
  BytesUsed, ErrorCode: Integer;
  BytesRead: Cardinal;
  Data: Pointer;
  LockedRect: TD3DLockedRect;
  Frame: TXvidDecoderFrame;
begin
  if DecodedFrameCount >= FrameCount then
  begin
    Result := False;
    Exit;
  end;
  BytesRead := AviFile.ReadFrame(DecodedFrameCount, CompressedFrame.Data, CompressedFrame.DataSize);
  Data := CompressedFrame.Data;
  ErrorCode := OffscreenTexture.LockRect(0, LockedRect, nil, 0);
  if ErrorCode <> 0 then
    raise Exception.Create('GR_lpTexAVI.LockRect error');
  while BytesRead > 1 do
  begin
    FillChar(Frame, SizeOf(Frame), 0);
    Frame.Version := $10100;
    Frame.General := 1;
    Frame.Bitstream := Data;
    Frame.Length := BytesRead;
    Frame.Output.ColorSpace := ColorSpace;
    Frame.Output.Planes[0] := LockedRect.Bits;
    Frame.Output.Strides[0] := LockedRect.Pitch;
    // Statistics are optional and unused; avoid allocating a versioned C union.
    BytesUsed := XvidDecore(DecoderHandle, 2, @Frame, nil);
    if (BytesUsed <= 0) or (Cardinal(BytesUsed) > BytesRead) then
      RaiseWideMessage('AVI decode');
    Data := Pointer(PAnsiChar(Data) + BytesUsed);
    Dec(BytesRead, BytesUsed);
  end;
  OffscreenTexture.UnlockRect(0);
  Inc(DecodedFrameCount);
  OffscreenFillViewport := FillViewport;
  OffscreenFrameUpdated := True;
  Result := DecodedFrameCount < FrameCount;
end;

function TxvidGI.SetPlaybackTime(TimeMs: Double): Boolean;
var
  Frame: Integer;
begin
  Result := False;
  Frame := Round(0.001 * TimeMs * FramesPerSecond);
  if Frame >= FrameCount then
  begin
    Frame := FrameCount - 1;
    Result := True;
  end;
  SetFramePosition(Frame);
end;

procedure TxvidGI.SetFramePosition(Frame: Integer);
begin
  if DecoderHandle <> nil then
  begin
    TargetFrame := Frame;
    while TargetFrame > DecodedFrameCount do
      if not DecodeNextFrame then
      begin
        XvidClose;
        if Assigned(PlaybackFinished) then
          PlaybackFinished(Self);
        Break;
      end;
  end;
end;

finalization
  if XvidLibrary <> 0 then
    UnloadLibrary(XvidLibrary);
end.
