unit GameEvents;

{$MODE DELPHI}
{$POINTERMATH ON}

interface

uses
  Classes;

type
  TGameEventHandle = PtrUInt;
  PGameEventHandle = ^TGameEventHandle;
  TGameEventTimer = class(TThread)
  private
    Target, Shutdown: TGameEventHandle;
    Interval: Cardinal;
    procedure Execute; override;
  public
    constructor Create(Event: TGameEventHandle; Period: Cardinal);
    destructor Destroy; override;
  end;

const
  WAIT_OBJECT_0 = 0;
  WAIT_ABANDONED_0 = $80; // Script-visible result code; plain events cannot be abandoned.
  WAIT_TIMEOUT = 258;
  WAIT_FAILED = Cardinal($FFFFFFFF);
  INFINITE = Cardinal($FFFFFFFF);

function CreateGameEvent(ManualReset, InitialState: Boolean): TGameEventHandle;
// Owners must stop signal/reset callers before closing; handles are object addresses.
// An entered wait retains the object, but a copied handle alone does not retain it.
procedure CloseGameEvent(Handle: TGameEventHandle);
procedure SetGameEvent(Handle: TGameEventHandle);
procedure ResetGameEvent(Handle: TGameEventHandle);
function WaitGameEvent(Handle: TGameEventHandle; Timeout: Cardinal): Cardinal;
function WaitGameEvents(
    Count: Cardinal;
    Handles: Pointer;
    WaitAll: Boolean;
    Timeout: Cardinal
): Cardinal;

implementation

uses
  SysUtils,
  SDL2;

type
  TGameEvent = class
    ManualReset, Signalled, Closed: Boolean;
    References: Integer;
  end;
var
  EventMutex: PSDL_Mutex;
  EventChanged: PSDL_Cond;

procedure ReleaseEvent(Event: TGameEvent);
begin
  Dec(Event.References);
  if Event.References = 0 then
    Event.Free;
end;

function CreateGameEvent(ManualReset, InitialState: Boolean): TGameEventHandle;
var
  Event: TGameEvent;
begin
  Event := TGameEvent.Create;
  Event.ManualReset := ManualReset;
  Event.Signalled := InitialState;
  Event.References := 1;
  Result := TGameEventHandle(Event);
end;

procedure CloseGameEvent(Handle: TGameEventHandle);
var
  Event: TGameEvent;
begin
  if Handle = 0 then
    Exit;
  SDL_LockMutex(EventMutex);
  try
    Event := TGameEvent(Handle);
    Event.Closed := True;
    // A waiter retains its event until it has observed the final state.
    SDL_CondBroadcast(EventChanged);
    ReleaseEvent(Event);
  finally
    SDL_UnlockMutex(EventMutex);
  end;
end;

procedure SetGameEvent(Handle: TGameEventHandle);
begin
  if Handle = 0 then
    Exit;
  SDL_LockMutex(EventMutex);
  try
    TGameEvent(Handle).Signalled := True;
    SDL_CondBroadcast(EventChanged);
  finally
    SDL_UnlockMutex(EventMutex);
  end;
end;

procedure ResetGameEvent(Handle: TGameEventHandle);
begin
  if Handle = 0 then
    Exit;
  SDL_LockMutex(EventMutex);
  try
    TGameEvent(Handle).Signalled := False;
  finally
    SDL_UnlockMutex(EventMutex);
  end;
end;

function WaitGameEvents(
    Count: Cardinal;
    Handles: Pointer;
    WaitAll: Boolean;
    Timeout: Cardinal
): Cardinal;
var
  Events: array of TGameEvent;
  Index, Selected, Held: Integer;
  Ready, Closed: Boolean;
  Deadline, NowTick: QWord;
  Remaining: Cardinal;
begin
  Result := WAIT_FAILED;
  if (Count = 0) or (Handles = nil) then
    Exit;
  SetLength(Events, Count);
  Deadline := GetTickCount64 + Timeout;
  Held := 0;
  SDL_LockMutex(EventMutex);
  try
    for Index := 0 to Integer(Count) - 1 do
    begin
      if PGameEventHandle(Handles)[Index] = 0 then
        Exit;
      Events[Index] := TGameEvent(PGameEventHandle(Handles)[Index]);
      Inc(Events[Index].References);
      Inc(Held);
    end;
    repeat
      Ready := WaitAll;
      Closed := False;
      Selected := -1;
      for Index := 0 to High(Events) do
      begin
        Closed := Closed or Events[Index].Closed;
        if Events[Index].Signalled then
        begin
          if Selected < 0 then
            Selected := Index;
          if not WaitAll then
            Ready := True;
        end
        else if WaitAll then
          Ready := False;
      end;
      if Ready then
      begin
        // Consume auto-reset events only after the entire wait is satisfied.
        if WaitAll then
        begin
          for Index := 0 to High(Events) do
            if not Events[Index].ManualReset then
              Events[Index].Signalled := False;
          Exit(WAIT_OBJECT_0);
        end;
        if not Events[Selected].ManualReset then
          Events[Selected].Signalled := False;
        Exit(WAIT_OBJECT_0 + Cardinal(Selected));
      end;
      if Closed then
        Exit(WAIT_FAILED);
      Remaining := INFINITE;
      if Timeout <> INFINITE then
      begin
        NowTick := GetTickCount64;
        if NowTick >= Deadline then
          Exit(WAIT_TIMEOUT);
        Remaining := Deadline - NowTick;
      end;
      // Checking state and releasing the mutex to sleep are atomic. A signal
      // cannot be lost between scanning several events and entering the wait.
      if SDL_CondWaitTimeout(EventChanged, EventMutex, Remaining) < 0 then
        Exit(WAIT_FAILED);
    until False;
  finally
    for Index := 0 to Held - 1 do
      ReleaseEvent(Events[Index]);
    SDL_UnlockMutex(EventMutex);
  end;
end;

function WaitGameEvent(Handle: TGameEventHandle; Timeout: Cardinal): Cardinal;
begin
  Result := WaitGameEvents(1, @Handle, False, Timeout);
end;

constructor TGameEventTimer.Create(Event: TGameEventHandle; Period: Cardinal);
begin
  inherited Create(True);
  Target := Event;
  Interval := Period;
  if Interval = 0 then
    Interval := 1;
  Shutdown := CreateGameEvent(True, False);
  Start;
end;

procedure TGameEventTimer.Execute;
begin
  while WaitGameEvent(Shutdown, Interval) = WAIT_TIMEOUT do
    SetGameEvent(Target);
end;

destructor TGameEventTimer.Destroy;
begin
  // Joining makes it safe for the owner to destroy the target event immediately.
  SetGameEvent(Shutdown);
  WaitFor;
  CloseGameEvent(Shutdown);
  inherited Destroy;
end;

initialization
  EventMutex := SDL_CreateMutex;
  EventChanged := SDL_CreateCond;
  if (EventMutex = nil) or (EventChanged = nil) then
    raise Exception.Create('Creating game events: ' + string(SDL_GetError));
finalization
  SDL_DestroyCond(EventChanged);
  SDL_DestroyMutex(EventMutex);
end.
