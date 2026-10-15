unit GR_Sound;

{$I GameOptions.inc}

interface

uses
  GameEvents,
  EC_Struct,
  DirectSound,
  SyncObjs,
  VorbisFile;

const

  SoundStreamPrimeAll = -1;

type

  PSoundWaveFormat = ^TSoundWaveFormat;

  TSoundBuffer = class;

  TSoundBufferControl = class;

  TSoundControl = class;

  TSoundBufferControl = class(TObjectEx)
    SoundPath: WideString;
    SoundGroup: Integer;
    Looping: Boolean;
    Buffer: TSoundBuffer;
    Volume: Single;
    Pan: Single;
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure Configure(const Path: WideString; Group: Integer; ALooping: Boolean);
    procedure SetVolume(Value: Single);
    procedure SetPan(Value: Single);
    procedure Play;
    function IsPlaying: Boolean;
  end;

  TSoundBuffer = class(TObjectEx)
    Prev: TSoundBuffer;
    Next: TSoundBuffer;
    AutoRelease: Boolean;
    Streaming: Boolean;
    Started: Boolean;
    DirectBuffer: IDirectSoundBuffer;
    Notify: IDirectSoundNotify;
    // WaitForChunk reads these consecutive native-width handles as one wait set.
    StopEvent: TGameEventHandle;
    ChunkEvents: array[0..2] of TGameEventHandle;
    VolumeEvent: TGameEventHandle;
    BufferBytes: Integer;
    WaveFormat: TSoundWaveFormat;
    VolumeTimer: TGameEventTimer;
    Volume: Single;
    VolumeScale: Single;
    VolumeStep: Single;
    FadingOut: Boolean;
    SoundGroup: Integer;
    Controller: TSoundBufferControl;
    WriteOffset: Integer;
    LastPlayCursor: Cardinal;
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure Init(ByteCount: Integer; Format: PSoundWaveFormat);
    procedure InitStream(ChunkBytes: Integer; Format: PSoundWaveFormat);
    procedure ClearBuf;
    procedure Write(Data: Pointer; ByteCount: Cardinal; Format: PSoundWaveFormat);
    function WriteStream(Chunk: Integer; var Decoder: TOggWorker): Boolean;
    procedure Play(Looping: Boolean);
    function WaitForChunk: Integer;
    function IsPlaying: Boolean;
    procedure SignalStop;
    procedure SetVolume(Value: Single);
    procedure SetVolumeScale(Value: Single);
    procedure StartVolumeRamp(Interval: Cardinal; Step: Single);
    procedure SetPan(Value: Single);
  end;

  TSoundControl = class(TObjectEx)
    FirstBuffer: TSoundBuffer;
    LastBuffer: TSoundBuffer;
    DirectSound: IDirectSound;
    PrimaryBuffer: IDirectSoundBuffer;
    WaveFormat: TSoundWaveFormat;
    Lock: TCriticalSection;
    LastFadeTick: Cardinal;
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure StopUncontrolledSounds;
    function AddBuffer: TSoundBuffer;
    procedure RemoveBuffer(Buffer: TSoundBuffer);
    function SuppressGroup(Group: Integer; Volume: Single): Boolean;
    procedure RemoveFinishedBuffers;
    procedure UpdateFades;
    procedure PlaySound(const Path: WideString);
    function PlayEffect(const Path: WideString; Group: Integer; Volume: Single; Pan: Single): TSoundBuffer;
    function PlayLoop(const Path: WideString; Group: Integer; Volume: Single; Pan: Single): TSoundBuffer;
    procedure SignalStop;
  end;

function SoundErrorText(Code: Integer): AnsiString;

function EnumerateSoundDevice(Guid: Pointer; Description: PAnsiChar; Module: PAnsiChar; Context: Pointer): LongBool; stdcall;

implementation

uses
  GlobalsV,
  Types,
  SysUtils,
  GR_Main,
  GameSystem,
  GameDiagnostics,
  EC_Cache,
  EC_CacheSound,
  EC_Str,
  EC_Mem,
  Math;

const
  UnsignedPcmSilence = $80;
  SoundEventPollMs = 1000;

function SoundErrorText(Code: Integer): AnsiString;
begin
  Result := '';
  case Code of
    DS_OK: Result := 'DS_OK';
    DS_NO_VIRTUALIZATION: Result := 'DS_NO_VIRTUALIZATION';
    DS_INCOMPLETE: Result := 'DS_INCOMPLETE';
    DSERR_ALLOCATED: Result := 'DSERR_ALLOCATED';
    DSERR_CONTROLUNAVAIL: Result := 'DSERR_CONTROLUNAVAIL';
    DSERR_INVALIDPARAM: Result := 'DSERR_INVALIDPARAM';
    DSERR_INVALIDCALL: Result := 'DSERR_INVALIDCALL';
    DSERR_GENERIC: Result := 'DSERR_GENERIC';
    DSERR_PRIOLEVELNEEDED: Result := 'DSERR_PRIOLEVELNEEDED';
    DSERR_OUTOFMEMORY: Result := 'DSERR_OUTOFMEMORY';
    DSERR_BADFORMAT: Result := 'DSERR_BADFORMAT';
    DSERR_UNSUPPORTED: Result := 'DSERR_UNSUPPORTED';
    DSERR_NODRIVER: Result := 'DSERR_NODRIVER';
    DSERR_ALREADYINITIALIZED: Result := 'DSERR_ALREADYINITIALIZED';
    DSERR_NOAGGREGATION: Result := 'DSERR_NOAGGREGATION';
    DSERR_BUFFERLOST: Result := 'DSERR_BUFFERLOST';
    DSERR_OTHERAPPHASPRIO: Result := 'DSERR_OTHERAPPHASPRIO';
    DSERR_UNINITIALIZED: Result := 'DSERR_UNINITIALIZED';
    DSERR_NOINTERFACE: Result := 'DSERR_NOINTERFACE';
    DSERR_ACCESSDENIED: Result := 'DSERR_ACCESSDENIED';
    DSERR_BUFFERTOOSMALL: Result := 'DSERR_BUFFERTOOSMALL';
    DSERR_DS8_REQUIRED: Result := 'DSERR_DS8_REQUIRED';
    DSERR_SENDLOOP: Result := 'DSERR_SENDLOOP';
    DSERR_BADSENDBUFFERGUID: Result := 'DSERR_BADSENDBUFFERGUID';
    DSERR_OBJECTNOTFOUND: Result := 'DSERR_OBJECTNOTFOUND';
    DSERR_FXUNAVAILABLE: Result := 'DSERR_FXUNAVAILABLE';
  else
    Result := 'unknown audio status $' + IntToHex(Cardinal(Code), 8);
  end;
end;

procedure CheckSoundStatus(Status: Integer; const Operation: UnicodeString);
begin
  if (Status <> DS_OK) and (Status <> DS_INCOMPLETE) then
    raise EGameDiagnosticException.Create(
        'Audio ' + Operation + ': ' + SoundErrorText(Status) + ' (status=$' + IntToHex(Cardinal(Status), 8) + ')');
end;

constructor TSoundBufferControl.Create;
begin
  inherited Create;
end;

destructor TSoundBufferControl.Destroy;
begin
  Clear;
  inherited Destroy;
end;

procedure TSoundBufferControl.Clear;
begin
  if Buffer <> nil then
  begin
    Buffer.Controller := nil;
    Buffer.Clear;
    Buffer := nil;
    Volume := 0;
    Pan := 0;
  end;
end;

procedure TSoundBufferControl.Configure(const Path: WideString; Group: Integer; ALooping: Boolean);
begin
  if SoundPath <> Path then
  begin
    Clear;
    SoundGroup := Group;
    SoundPath := Path;
    Looping := ALooping;
  end;
end;

procedure TSoundBufferControl.SetVolume(Value: Single);
begin
  if Volume = Value then
    Exit;
  if Looping then
  begin
    if Value = 0 then
    begin
      if Buffer <> nil then
        Clear;
    end
    else
    begin
      Volume := Value;
      if Buffer = nil then
      begin
        Buffer := SoundManager.PlayLoop(SoundPath, SoundGroup, Volume, Pan);
        if Buffer <> nil then
          Buffer.Controller := Self;
      end
      else
        Buffer.SetVolumeScale(Volume);
    end;
  end
  else
  begin
    Volume := Value;
    if Buffer <> nil then
      Buffer.SetVolumeScale(Volume);
  end;
end;

procedure TSoundBufferControl.SetPan(Value: Single);
begin
  if Pan = Value then
    Exit;
  Pan := Value;
  if Looping then
  begin
    if Buffer = nil then
    begin
      Buffer := SoundManager.PlayLoop(SoundPath, SoundGroup, Volume, Pan);
      if Buffer <> nil then
        Buffer.Controller := Self;
    end
    else
      Buffer.SetPan(Pan);
  end
  else if Buffer <> nil then
    Buffer.SetPan(Pan);
end;

procedure TSoundBufferControl.Play;
begin
  if Looping then
    Exit;
  if Buffer <> nil then
    Clear;
  Buffer := SoundManager.PlayEffect(SoundPath, SoundGroup, Volume, Pan);
  if Buffer <> nil then
    Buffer.Controller := Self;
end;

function TSoundBufferControl.IsPlaying: Boolean;
begin
  Result := False;
  if Buffer <> nil then
    Result := Buffer.IsPlaying;
end;

constructor TSoundBuffer.Create;
var
  i: Integer;
begin
  inherited Create;
  Streaming := False;
  DirectBuffer := nil;
  Notify := nil;
  for i := Low(ChunkEvents) to High(ChunkEvents) do
    ChunkEvents[i] := 0;
  StopEvent := CreateGameEvent(True, False);
  for i := Low(ChunkEvents) to High(ChunkEvents) do
    ChunkEvents[i] := CreateGameEvent(False, False);
  VolumeEvent := CreateGameEvent(False, False);
  BufferBytes := 0;
  Volume := 1;
  VolumeScale := 1;
  FillChar(WaveFormat, SizeOf(WaveFormat), 0);
  if PAnsiChar(@VolumeEvent) - PAnsiChar(@StopEvent) <> SizeOf(StopEvent) + SizeOf(ChunkEvents) then
    RaiseWideMessage('TSoundBuffer.Create 2');
end;

destructor TSoundBuffer.Destroy;
var
  i: Integer;
begin
  Clear;
  if StopEvent <> 0 then
  begin
    CloseGameEvent(StopEvent);
    StopEvent := 0;
  end;
  for i := Low(ChunkEvents) to High(ChunkEvents) do
    if ChunkEvents[i] <> 0 then
    begin
      CloseGameEvent(ChunkEvents[i]);
      ChunkEvents[i] := 0;
    end;
  if VolumeEvent <> 0 then
  begin
    CloseGameEvent(VolumeEvent);
    VolumeEvent := 0;
  end;
  inherited Destroy;
end;

procedure TSoundBuffer.Clear;
begin
  SoundManager.Lock.Enter;
  try
    if Controller <> nil then
    begin
      Controller.Buffer := nil;
      Controller.Volume := 0;
      Controller := nil;
    end;
    if VolumeTimer <> nil then
    begin
      FreeAndNil(VolumeTimer);
    end;
    if DirectBuffer <> nil then
      DirectBuffer.Stop;
    Notify := nil;
    DirectBuffer := nil;
    BufferBytes := 0;
    Streaming := False;
    Started := False;
    FillChar(WaveFormat, SizeOf(WaveFormat), 0);
  finally
    SoundManager.Lock.Leave;
  end;
end;

procedure TSoundBuffer.Init(ByteCount: Integer; Format: PSoundWaveFormat);
var
  Status: Integer;
  Desc: TDSBufferDesc;
begin
  SoundManager.Lock.Enter;
  try
    Clear;
    BufferBytes := ByteCount;
    System.Move(Pointer(Format)^, Pointer(@WaveFormat)^, SizeOf(WaveFormat));
    FillChar(Desc, SizeOf(Desc), 0);
    Desc.Size := SizeOf(Desc);
    Desc.Flags := DSBCAPS_STATIC or DSBCAPS_LOCSOFTWARE or DSBCAPS_CTRLPAN or DSBCAPS_CTRLVOLUME;
    Desc.BufferBytes := ByteCount;
    Desc.WaveFormat := @WaveFormat;
    SoundManager.Lock.Enter;
    try
      Status := SoundManager.DirectSound.CreateSoundBuffer(Desc, DirectBuffer, nil);
    finally
      SoundManager.Lock.Leave;
    end;
    CheckSoundStatus(Status, 'CreateSoundBuffer(effect)');
  finally
    SoundManager.Lock.Leave;
  end;
end;

procedure TSoundBuffer.InitStream(ChunkBytes: Integer; Format: PSoundWaveFormat);
var
  Status: Integer;
  Positions, Position: PDSPositionNotify;
  i: Integer;
  Desc: TDSBufferDesc;
begin
  SoundManager.Lock.Enter;
  try
    Clear;
    WriteOffset := 0;
    LastPlayCursor := 0;
    BufferBytes := ChunkBytes;
    System.Move(Pointer(Format)^, Pointer(@WaveFormat)^, SizeOf(WaveFormat));
    FillChar(Desc, SizeOf(Desc), 0);
    Desc.Size := SizeOf(Desc);
    Desc.Flags := DSBCAPS_LOCSOFTWARE or DSBCAPS_CTRLPAN or DSBCAPS_CTRLVOLUME or DSBCAPS_CTRLPOSITIONNOTIFY or DSBCAPS_GETCURRENTPOSITION2;
    Desc.BufferBytes := ChunkBytes * Length(ChunkEvents);
    Desc.WaveFormat := @WaveFormat;
    SoundManager.Lock.Enter;
    try
      Status := SoundManager.DirectSound.CreateSoundBuffer(Desc, DirectBuffer, nil);
    finally
      SoundManager.Lock.Leave;
    end;
    CheckSoundStatus(Status, 'CreateSoundBuffer(stream)');
    Status := DirectBuffer.QueryInterface(IDirectSoundNotify, Notify);
    CheckSoundStatus(Status, 'QueryInterface(stream notifications)');
    Positions := AllocClearEC(Length(ChunkEvents) * SizeOf(TDSPositionNotify));
    Position := Positions;
    for i := Low(ChunkEvents) to High(ChunkEvents) do
    begin
      Position.EventHandle := ChunkEvents[i];
      if i = 0 then
        Position.Offset := ChunkBytes * Length(ChunkEvents) - 1
      else
        Position.Offset := i * ChunkBytes - 1;
      Position := AddPointerOffset(Position, SizeOf(TDSPositionNotify));
    end;
    try
      Status := Notify.SetNotificationPositions(Length(ChunkEvents), Positions);
      CheckSoundStatus(Status, 'SetNotificationPositions(stream)');
    finally
      FreeEC(Positions);
    end;
    Status := DirectBuffer.GetFormat(@WaveFormat, SizeOf(WaveFormat), nil);
    CheckSoundStatus(Status, 'GetFormat(stream)');
    ClearBuf;
    SetVolume(MusicVolume * MusicVolumeScale);
    SetVolumeScale(1);
    Streaming := True;
  finally
    SoundManager.Lock.Leave;
  end;
end;

procedure TSoundBuffer.ClearBuf;
var
  Data: Pointer;
  Bytes: Cardinal;
  Status: Integer;
begin
  SoundManager.Lock.Enter;
  try
    Data := nil;
    Bytes := 0;
    if DirectBuffer = nil then
      Exit;
    Status := DirectBuffer.Lock(0, 0, @Data, @Bytes, nil, nil, DSBLOCK_ENTIREBUFFER);
    CheckSoundStatus(Status, 'Lock(clear buffer)');
    if WaveFormat.BitsPerSample = 8 then
      System.FillChar(Pointer(Data)^, Bytes, UnsignedPcmSilence)
    else
      FillChar(Data^, Bytes, 0);
    Status := DirectBuffer.Unlock(Data, Bytes, nil, 0);
    CheckSoundStatus(Status, 'Unlock(clear buffer)');
  finally
    SoundManager.Lock.Leave;
  end;
end;

procedure TSoundBuffer.Write(Data: Pointer; ByteCount: Cardinal; Format: PSoundWaveFormat);
var
  Dest: Pointer;
  Bytes: Cardinal;
  Status: Integer;
begin
  SoundManager.Lock.Enter;
  try
    if (Cardinal(BufferBytes) < ByteCount) or not CompareMem(@WaveFormat, Format, SizeOf(WaveFormat)) or Streaming then
      Init(ByteCount, Format);
    if DirectBuffer = nil then
      Exit;
    Dest := nil;
    Bytes := 0;
    Status := DirectBuffer.Lock(0, ByteCount, @Dest, @Bytes, nil, nil, DSBLOCK_ENTIREBUFFER);
    CheckSoundStatus(Status, 'Lock(write effect)');
    System.Move(Pointer(Data)^, Pointer(Dest)^, ByteCount);
    Status := DirectBuffer.Unlock(Dest, Bytes, nil, 0);
    CheckSoundStatus(Status, 'Unlock(write effect)');
  finally
    SoundManager.Lock.Leave;
  end;
end;

function TSoundBuffer.WriteStream(Chunk: Integer; var Decoder: TOggWorker): Boolean;
var
  Offset: Integer;
  Dest: Pointer;
  LockedBytes: Cardinal;
  Status, ReadBytes, WantedBytes: Integer;
  Temp: Pointer;
  PlayCursor, WriteCursor, PlayedChunkStart: Cardinal;
begin
  SoundManager.Lock.Enter;
  Result := False;
  try
    if not Streaming then
      Exit;
    if DirectBuffer = nil then
      Exit;
    if Chunk = SoundStreamPrimeAll then
    begin
      Offset := 0;
      WantedBytes := BufferBytes * Length(ChunkEvents);
    end
    else
    begin
      DirectBuffer.GetCurrentPosition(@PlayCursor, @WriteCursor);
      PlayedChunkStart := PlayCursor div Cardinal(BufferBytes) * Cardinal(BufferBytes);
      if LastPlayCursor = PlayedChunkStart then
      begin
        Result := True;
        Exit;
      end;
      LastPlayCursor := PlayedChunkStart;
      if Cardinal(WriteOffset) >= PlayedChunkStart then
      begin
        if Cardinal(WriteOffset) >= WriteCursor then
        begin
          WantedBytes := BufferBytes * Length(ChunkEvents) - WriteOffset;
          Offset := WriteOffset;
          WriteOffset := 0;
        end
        else
        begin
          Offset := (Cardinal(BufferBytes) + WriteCursor - 1) div Cardinal(BufferBytes) * Cardinal(BufferBytes);
          if BufferBytes * Length(ChunkEvents) <= Offset then
          begin
            Offset := 0;
            WantedBytes := PlayedChunkStart;
            WriteOffset := PlayedChunkStart;
          end
          else
          begin
            WriteOffset := 0;
            WantedBytes := BufferBytes * Length(ChunkEvents) - Offset;
          end;
        end;
      end
      else
      begin
        Offset := WriteOffset;
        WantedBytes := PlayedChunkStart - Cardinal(Offset);
        if WantedBytes <= 0 then
        begin
          Result := True;
          Exit;
        end;
        Inc(WriteOffset, WantedBytes);
      end;
    end;
    ReadBytes := WantedBytes;
    Temp := AllocEC(ReadBytes);
    try
      if ReadVorbisSamples(Decoder, Temp, ReadBytes) = 0 then
        ReadBytes := 0;
      if ReadBytes > 0 then
      begin
        Dest := nil;
        LockedBytes := 0;
        Status := DirectBuffer.Lock(Offset, ReadBytes, @Dest, @LockedBytes, nil, nil, 0);
        CheckSoundStatus(Status, 'Lock(write stream)');
        System.Move(Pointer(Temp)^, Pointer(Dest)^, ReadBytes);
        if BufferBytes > ReadBytes then
        begin
          if WaveFormat.BitsPerSample = 8 then
            System.FillChar(Pointer(PAnsiChar(Dest) + ReadBytes)^, BufferBytes - ReadBytes, UnsignedPcmSilence)
          else
            FillChar(Pointer(PAnsiChar(Dest) + ReadBytes)^, BufferBytes - ReadBytes, 0);
        end;
        Status := DirectBuffer.Unlock(Dest, LockedBytes, nil, 0);
        CheckSoundStatus(Status, 'Unlock(write stream)');
      end;
    finally
      FreeEC(Temp);
    end;
  finally
    SoundManager.Lock.Leave;
  end;
  Result := ReadBytes >= WantedBytes;
end;

procedure TSoundBuffer.Play(Looping: Boolean);
var
  Status, i: Integer;
begin
  SoundManager.Lock.Enter;
  try
    for i := Low(ChunkEvents) to High(ChunkEvents) do
      ResetGameEvent(ChunkEvents[i]);
    ResetGameEvent(VolumeEvent);
    if DirectBuffer = nil then
      Exit;
    if not Streaming then
    begin
      if Looping then
        Status := DirectBuffer.Play(0, 0, DSBPLAY_LOOPING)
      else
        Status := DirectBuffer.Play(0, 0, 0);
      CheckSoundStatus(Status, 'Play(effect)');
    end
    else
    begin
      Status := DirectBuffer.Play(0, 0, DSBPLAY_LOOPING);
      CheckSoundStatus(Status, 'Play(stream)');
    end;
    Started := True;
  finally
    SoundManager.Lock.Leave;
  end;
end;

function TSoundBuffer.WaitForChunk: Integer;
var
  WaitResult: Cardinal;
begin
  Result := -1;
  if not Streaming then
  begin
    WaitGameEvent(ChunkEvents[0], INFINITE);
    Result := 0;
  end
  else if VolumeTimer = nil then
  begin
    WaitResult := WaitGameEvents(Length(ChunkEvents) + 1, @StopEvent, False, SoundEventPollMs);
    if WaitResult = WAIT_TIMEOUT then
      Result := 0
    else
      Result := WaitResult - WAIT_OBJECT_0 - 1;
  end
  else
  begin
    while True do
    begin
      WaitResult := WaitGameEvents(Length(ChunkEvents) + 2, @StopEvent, False, SoundEventPollMs);
      if WaitResult = WAIT_TIMEOUT then
      begin
        Result := 0;
        Break
      end;
      if WaitResult = WAIT_OBJECT_0 then
      begin
        Result := -1;
        Break
      end;
      if WaitResult <> WAIT_OBJECT_0 + Length(ChunkEvents) + 1 then
      begin
        Result := WaitResult - WAIT_OBJECT_0 - 1;
        Break;
      end;
      SetVolumeScale(VolumeScale + VolumeStep);
      if VolumeScale = 0 then
      begin
        Result := -1;
        Break
      end;
    end;
  end;
end;

function TSoundBuffer.IsPlaying: Boolean;
var
  Flags: Cardinal;
  Status: Integer;
begin
  SoundManager.Lock.Enter;
  Result := False;
  try
    if DirectBuffer = nil then
      Exit;
    Status := DirectBuffer.GetStatus(Flags);
    CheckSoundStatus(Status, 'GetStatus(buffer)');
  finally
    SoundManager.Lock.Leave;
  end;
  Result := (Flags and DSBSTATUS_PLAYING) = DSBSTATUS_PLAYING;
end;

procedure TSoundBuffer.SignalStop;
begin
  SetGameEvent(StopEvent);
end;

procedure TSoundBuffer.SetVolume(Value: Single);
var
  Status: Integer;
  Minimum: Single;
  Operation: UnicodeString;
begin
  SoundManager.Lock.Enter;
  try
    Volume := Value;
    if DirectBuffer = nil then
      Exit;
    Minimum := -3000;
    if Value = 0 then
      Status := DirectBuffer.SetVolume(DSBVOLUME_MIN)
    else
      Status := DirectBuffer.SetVolume(Round((0 - Minimum) * (Volume * VolumeScale) + Minimum));
    if (Status <> DS_OK) and (Status <> DS_INCOMPLETE) then
    begin
      Operation := 'SetVolume(value=' + FloatToStr(Value) + ', scale=' + FloatToStr(VolumeScale) + ')';
      if Controller <> nil then
        Operation := Operation + ' for ' + Controller.SoundPath;
      CheckSoundStatus(Status, Operation);
    end;
  finally
    SoundManager.Lock.Leave;
  end;
end;

procedure TSoundBuffer.SetVolumeScale(Value: Single);
begin
  VolumeScale := Value;
  if VolumeScale < 0 then
    VolumeScale := 0
  else if VolumeScale > 1 then
    VolumeScale := 1;
  SetVolume(Volume);
end;

procedure TSoundBuffer.StartVolumeRamp(Interval: Cardinal; Step: Single);
begin
  ResetGameEvent(VolumeEvent);
  VolumeStep := Step;
  if VolumeTimer <> nil then
  begin
    FreeAndNil(VolumeTimer);
  end;
  VolumeTimer := TGameEventTimer.Create(VolumeEvent, Interval);
end;

procedure TSoundBuffer.SetPan(Value: Single);
var
  Status, Pan: Integer;
begin
  SoundManager.Lock.Enter;
  try
    if DirectBuffer = nil then
      Exit;
    Pan := Round(10000 * Value);
    if Pan < DSBPAN_LEFT then
      Pan := DSBPAN_LEFT
    else if Pan > DSBPAN_RIGHT then
      Pan := DSBPAN_RIGHT;
    Status := DirectBuffer.SetPan(Pan);
    CheckSoundStatus(Status, 'SetPan(buffer)');
  finally
    SoundManager.Lock.Leave;
  end;
end;

function EnumerateSoundDevice(Guid: Pointer; Description, Module: PAnsiChar; Context: Pointer): LongBool; stdcall;
var
  Text: WideString;
begin
  Text := SysUtils.Format('- %s', [Description]);
  LogGameMessage(gllInfo, 'audio', 'Available device: ' + AnsiString(Description));
  if FindTextOffsetW(Text, 'Xonar') >= 0 then
    XonarSoundDevice := True;
  Result := True;
end;

constructor TSoundControl.Create;
var
  Status: Integer;
  Desc: TDSBufferDesc;
begin
  inherited Create;
  Lock := TCriticalSection.Create;
  FirstBuffer := nil;
  LastBuffer := nil;
  DirectSound := nil;
  PrimaryBuffer := nil;
  if SoundEnabled or MusicEnabled then
  begin
    try
      DirectSoundEnumerateA(EnumerateSoundDevice, nil);
      Status := DirectSoundCreate(nil, DirectSound, nil);
      CheckSoundStatus(Status, 'CreateDevice');
      Status := DirectSound.SetCooperativeLevel(MainWindowHandle, DSSCL_PRIORITY);
      CheckSoundStatus(Status, 'SetCooperativeLevel');
      FillChar(Desc, SizeOf(Desc), 0);
      Desc.Size := SizeOf(Desc);
      Desc.Flags := DSBCAPS_PRIMARYBUFFER or DSBCAPS_LOCSOFTWARE;
      Status := DirectSound.CreateSoundBuffer(Desc, PrimaryBuffer, nil);
      CheckSoundStatus(Status, 'CreateSoundBuffer(primary)');
      FillChar(WaveFormat, SizeOf(WaveFormat), 0);
      WaveFormat.FormatTag := 1;
      WaveFormat.Channels := 2;
      WaveFormat.SamplesPerSecond := 44100;
      WaveFormat.BitsPerSample := 16;
      WaveFormat.BlockAlign := (WaveFormat.BitsPerSample shr 3) * WaveFormat.Channels;
      WaveFormat.AverageBytesPerSecond := WaveFormat.SamplesPerSecond * WaveFormat.BlockAlign;
      Status := PrimaryBuffer.SetFormat(@WaveFormat);
      CheckSoundStatus(Status, 'SetFormat(primary)');
      Status := PrimaryBuffer.GetFormat(@WaveFormat, SizeOf(WaveFormat), nil);
      CheckSoundStatus(Status, 'GetFormat(primary)');
      if WaveFormat.FormatTag <> 1 then
        LogGameMessage(gllWarning, 'audio', 'Requested PCM format replaced with tag ' + IntToStr(WaveFormat.FormatTag));
      LogGameMessage(
          gllInfo,
          'audio',
          'Output format: '
              + IntToWideString(WaveFormat.Channels)
              + ' channels at '
              + IntToWideString(WaveFormat.SamplesPerSecond)
              + ' Hz, '
              + IntToWideString(WaveFormat.BitsPerSample)
              + ' bit '
      );
      if (WaveFormat.BitsPerSample shr 3) * WaveFormat.Channels <> WaveFormat.BlockAlign then
        LogGameMessage(gllWarning, 'audio', 'Unexpected block alignment: ' + IntToStr(WaveFormat.BlockAlign));
      if WaveFormat.SamplesPerSecond * WaveFormat.BlockAlign <> WaveFormat.AverageBytesPerSecond then
        LogGameMessage(gllWarning, 'audio', 'Unexpected bytes per second: ' + IntToStr(WaveFormat.AverageBytesPerSecond));
    except
      LogCurrentGameException('audio', 'Initialization failed; continuing without sound or music', gllWarning);
      PrimaryBuffer := nil;
      DirectSound := nil;
      SoundEnabled := False;
      MusicEnabled := False;
    end;
  end;
end;

destructor TSoundControl.Destroy;
begin
  Clear;
  PrimaryBuffer := nil;
  DirectSound := nil;
  Lock.Free;
  inherited Destroy;
end;

procedure TSoundControl.Clear;
begin
  while FirstBuffer <> nil do
    RemoveBuffer(FirstBuffer);
end;

procedure TSoundControl.StopUncontrolledSounds;
var
  NextBuffer, Buffer: TSoundBuffer;
begin
  Lock.Enter;
  NextBuffer := FirstBuffer;
  while NextBuffer <> nil do
  begin
    Buffer := NextBuffer;
    NextBuffer := NextBuffer.Next;
    if (Buffer.Controller = nil) and not Buffer.Streaming and Buffer.IsPlaying then
      RemoveBuffer(Buffer);
  end;
  Lock.Leave;
end;

function TSoundControl.AddBuffer: TSoundBuffer;
var
  Buffer: TSoundBuffer;
begin
  Lock.Enter;
  try
    Buffer := TSoundBuffer.Create;
    if LastBuffer <> nil then
      LastBuffer.Next := Buffer;
    Buffer.Prev := LastBuffer;
    Buffer.Next := nil;
    LastBuffer := Buffer;
    if FirstBuffer = nil then
      FirstBuffer := Buffer;
  finally
    Lock.Leave;
  end;
  Result := Buffer;
end;

procedure TSoundControl.RemoveBuffer(Buffer: TSoundBuffer);
begin
  Lock.Enter;
  try
    if Buffer.Prev <> nil then
      Buffer.Prev.Next := Buffer.Next;
    if Buffer.Next <> nil then
      Buffer.Next.Prev := Buffer.Prev;
    if LastBuffer = Buffer then
      LastBuffer := Buffer.Prev;
    if FirstBuffer = Buffer then
      FirstBuffer := Buffer.Next;
    Buffer.Free;
  finally
    Lock.Leave;
  end;
end;

function TSoundControl.SuppressGroup(Group: Integer; Volume: Single): Boolean;
var
  Buffer: TSoundBuffer;
begin
  Result := False;
  Lock.Enter;
  try
    Buffer := FirstBuffer;
    while Buffer <> nil do
    begin
      if Buffer.SoundGroup = Group then
      begin
        if Buffer.VolumeScale >= Volume then
        begin
          Result := True;
          Exit;
        end;
        Buffer.FadingOut := True;
        if Buffer.Controller <> nil then
        begin
          Buffer.Controller.Buffer := nil;
          Buffer.Controller.Volume := 0;
          Buffer.Controller := nil;
        end;
      end;
      Buffer := Buffer.Next;
    end;
  finally
    Lock.Leave;
  end;
end;

procedure TSoundControl.RemoveFinishedBuffers;
var
  NextBuffer, Buffer: TSoundBuffer;
begin
  Lock.Enter;
  try
    NextBuffer := FirstBuffer;
    while NextBuffer <> nil do
    begin
      Buffer := NextBuffer;
      NextBuffer := NextBuffer.Next;
      if Buffer.AutoRelease and not Buffer.IsPlaying then
        RemoveBuffer(Buffer);
    end;
  finally
    Lock.Leave;
  end;
end;

procedure TSoundControl.UpdateFades;
var
  NextBuffer, Buffer: TSoundBuffer;
  NewVolume: Single;
  Tick: Cardinal;
begin
  Tick := GameTickCount;
  if Tick - LastFadeTick < 10 then
    Exit;
  LastFadeTick := Tick;
  Lock.Enter;
  try
    NextBuffer := FirstBuffer;
    while NextBuffer <> nil do
    begin
      Buffer := NextBuffer;
      NextBuffer := NextBuffer.Next;
      if Buffer.FadingOut then
      begin
        NewVolume := Max(0, Buffer.VolumeScale - 0.05);
        if NewVolume > 0.05 then
          Buffer.SetVolumeScale(NewVolume)
        else
          RemoveBuffer(Buffer);
      end;
    end;
  finally
    Lock.Leave;
  end;
end;

procedure TSoundControl.PlaySound(const Path: WideString);
var
  Control: TCSoundControlEC;
  Sound: TCSoundEC;
  Buffer: TSoundBuffer;
begin
  if Path = '' then
    Exit;
  if not SoundEnabled then
    Exit;
  Control := nil;
  RemoveFinishedBuffers;
  try
    Control := TCSoundControlEC.Create;
    GlobalCache.ResetControl(Control);
    Control.SetCacheKey(Path);
    Sound := AcquireCachedSound(Control);
    Buffer := AddBuffer;
    Buffer.AutoRelease := True;
    Buffer.Write(Sound.SampleData, Sound.SampleDataSize, @Sound.Format);
    Buffer.SetVolume(SoundVolume);
    Buffer.SetVolumeScale(1);
    Buffer.Play(False);
  finally
    if Control <> nil then
    begin
      Control.Release;
      Control.Free;
    end;
  end;
end;

function TSoundControl.PlayEffect(const Path: WideString; Group: Integer; Volume, Pan: Single): TSoundBuffer;
var
  Control: TCSoundControlEC;
  Sound: TCSoundEC;
  Buffer: TSoundBuffer;
begin
  Result := nil;
  if Path = '' then
    Exit;
  if not SoundEnabled then
    Exit;
  Control := nil;
  RemoveFinishedBuffers;
  if (Group <> 0) and SuppressGroup(Group, Volume) then
    Exit;
  try
    Control := TCSoundControlEC.Create;
    GlobalCache.ResetControl(Control);
    Control.SetCacheKey(Path);
    Sound := AcquireCachedSound(Control);
    Buffer := AddBuffer;
    Buffer.SoundGroup := Group;
    Buffer.AutoRelease := True;
    Buffer.Write(Sound.SampleData, Sound.SampleDataSize, @Sound.Format);
    Buffer.SetVolume(SoundVolume);
    Buffer.SetVolumeScale(Volume);
    Buffer.SetPan(Pan);
    Buffer.Play(False);
    Result := Buffer;
  finally
    if Control <> nil then
    begin
      Control.Release;
      Control.Free;
    end;
  end;
end;

function TSoundControl.PlayLoop(const Path: WideString; Group: Integer; Volume, Pan: Single): TSoundBuffer;
var
  Control: TCSoundControlEC;
  Sound: TCSoundEC;
  Buffer: TSoundBuffer;
begin
  Result := nil;
  if Path = '' then
    Exit;
  if not SoundEnabled then
    Exit;
  Control := nil;
  RemoveFinishedBuffers;
  if (Group <> 0) and SuppressGroup(Group, Volume) then
    Exit;
  try
    Control := TCSoundControlEC.Create;
    GlobalCache.ResetControl(Control);
    Control.SetCacheKey(Path);
    Sound := AcquireCachedSound(Control);
    Buffer := AddBuffer;
    Buffer.SoundGroup := Group;
    Buffer.AutoRelease := True;
    Buffer.Write(Sound.SampleData, Sound.SampleDataSize, @Sound.Format);
    Buffer.SetVolume(SoundVolume);
    Buffer.SetVolumeScale(Volume);
    Buffer.SetPan(Pan);
    Buffer.Play(True);
    Result := Buffer;
  finally
    if Control <> nil then
    begin
      Control.Release;
      Control.Free;
    end;
  end;
end;

procedure TSoundControl.SignalStop;
var
  Buffer: TSoundBuffer;
begin
  Lock.Enter;
  Buffer := FirstBuffer;
  while Buffer <> nil do
  begin
    Buffer.SignalStop;
    Buffer := Buffer.Next;
  end;
  Lock.Leave;
end;

end.
