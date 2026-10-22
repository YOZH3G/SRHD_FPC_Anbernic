unit GameSystemKeys;

{$MODE DELPHI}

interface

uses
  GameInput;

// Anbernic's stock firmware handles its volume and power buttons only in its
// own menu, and SDL does not report them: they sit on input devices without
// ordinary keys. The game reads those devices itself. Volume presses become
// VK_VOLUME_UP/VK_VOLUME_DOWN messages; a power press suspends the handheld.
procedure InitializeSystemKeys;
function PollSystemKeys(var Message: TGameMessage): Boolean;

implementation

uses
  SysUtils,
  BaseUnix,
  GameDiagnostics;

const
  EV_KEY = 1;
  KEY_VOLUMEDOWN = 114;
  KEY_VOLUMEUP = 115;
  KEY_POWER = 116;

type
  TInputEvent = record
    Seconds, Microseconds: PtrInt;
    EventType, Code: Word;
    Value: Integer;
  end;

var
  Devices: array of cint;
  // The press that wakes the handheld arrives after the resume; ignore it.
  IgnoreUntil: QWord;

function InputIoctl(Number, Size: Cardinal): TIOCtlRequest;
begin
  // _IOC(_IOC_READ, 'E', Number, Size)
  Result := TIOCtlRequest((Cardinal(2) shl 30) or (Size shl 16) or (Ord('E') shl 8) or Number);
end;

procedure InitializeSystemKeys;
var
  Index, Handle: cint;
  Bits: array[0..95] of Byte;
  Name: array[0..63] of AnsiChar;
  Volume, Power: Boolean;
  Found: UnicodeString;

  function HasKey(Code: Integer): Boolean;
  begin
    Result := Bits[Code div 8] and (1 shl (Code mod 8)) <> 0;
  end;

begin
  Found := '';
  for Index := 0 to 31 do
  begin
    Handle := FpOpen('/dev/input/event' + IntToStr(Index), O_RDONLY or O_NONBLOCK);
    if Handle < 0 then
      Continue;
    FillChar(Bits, SizeOf(Bits), 0);
    if FpIOCtl(Handle, InputIoctl($20 + EV_KEY, SizeOf(Bits)), @Bits) < 0 then
    begin
      FpClose(Handle);
      Continue;
    end;
    Volume := HasKey(KEY_VOLUMEUP) or HasKey(KEY_VOLUMEDOWN);
    Power := HasKey(KEY_POWER);
    if not Volume and not Power then
    begin
      FpClose(Handle);
      Continue;
    end;
    FillChar(Name, SizeOf(Name), 0);
    FpIOCtl(Handle, InputIoctl($06, SizeOf(Name) - 1), @Name);
    SetLength(Devices, Length(Devices) + 1);
    Devices[High(Devices)] := Handle;
    if Found <> '' then
      Found := Found + '; ';
    Found := Found + 'event' + IntToStr(Index) + ' (' + UnicodeString(AnsiString(PAnsiChar(@Name))) + ')';
    if Volume then
      Found := Found + ' volume';
    if Power then
      Found := Found + ' power';
  end;
  if Found = '' then
    Found := 'none';
  LogGameMessage(gllInfo, 'input', 'System keys: ' + Found);
end;

procedure DrainSystemKeys;
var
  Index: Integer;
  Event: TInputEvent;
begin
  for Index := 0 to High(Devices) do
    while FpRead(Devices[Index], Event, SizeOf(Event)) = SizeOf(Event) do
      ;
end;

procedure Suspend;
var
  Handle: cint;
  State: AnsiString;
begin
  LogGameMessage(gllInfo, 'input', 'Power button: suspending');
  State := 'mem';
  Handle := FpOpen('/sys/power/state', O_WRONLY);
  // The write returns once the handheld has woken up again.
  if (Handle < 0) or (FpWrite(Handle, State[1], Length(State)) <> Length(State)) then
    LogGameMessage(gllWarning, 'input', 'Power button: suspend failed, errno=' + IntToStr(FpGetErrno))
  else
    LogGameMessage(gllInfo, 'input', 'Power button: resumed');
  if Handle >= 0 then
    FpClose(Handle);
  DrainSystemKeys;
  IgnoreUntil := GetTickCount64 + 1000;
end;

function PollSystemKeys(var Message: TGameMessage): Boolean;
var
  Index: Integer;
  Event: TInputEvent;
begin
  Result := False;
  for Index := 0 to High(Devices) do
    while FpRead(Devices[Index], Event, SizeOf(Event)) = SizeOf(Event) do
    begin
      if (Event.EventType <> EV_KEY) or (Event.Value <> 1) or (GetTickCount64 < IgnoreUntil) then
        Continue;
      if Event.Code = KEY_POWER then
      begin
        Suspend;
        Exit;
      end;
      if (Event.Code <> KEY_VOLUMEUP) and (Event.Code <> KEY_VOLUMEDOWN) then
        Continue;
      Message := Default(TGameMessage);
      Message.Message := WM_KEYDOWN;
      if Event.Code = KEY_VOLUMEUP then
        Message.WParam := VK_VOLUME_UP
      else
        Message.WParam := VK_VOLUME_DOWN;
      Message.LParam := 1;
      Exit(True);
    end;
end;

end.
