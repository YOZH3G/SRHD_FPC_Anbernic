unit EC_Thread;

{$I GameOptions.inc}

interface

uses
  EC_Struct,
  Classes,
  GameEvents,
  GameDiagnostics,
  SysUtils,
  SyncObjs;

type

  TThreadPriorityEC = (
      ThreadPriorityIdle,
      ThreadPriorityLowest,
      ThreadPriorityBelowNormal,
      ThreadPriorityNormal,
      ThreadPriorityAboveNormal,
      ThreadPriorityHighest,
      ThreadPriorityTimeCritical
  );

  EWorkerFailure = class(EGameDiagnosticException);

  TThreadEC = class;

  TThreadEC = class(TObjectEx)
  private
    Worker: TThread;
    Failure: TGameExceptionReport;
  public
    Lock: TCriticalSection;
    ThreadHandle: TThreadID;
    ThreadId: TThreadID;
    Priority: TThreadPriorityEC;
    StopRequested: Boolean;
    StopEvent: TGameEventHandle;
    Flag18: Boolean;
    ShutdownEvent: TGameEventHandle;
    StartEvent: TGameEventHandle;
    RunningEvent: TGameEventHandle;
    IdleEvent: TGameEventHandle;
    procedure Execute; virtual;
    constructor Create(const LogName: ShortString = '');
    destructor Destroy; override;
    procedure ProcessRequests;
    procedure SetPriority(Value: TThreadPriorityEC);
    procedure SetFlag18;
    procedure ClearFlag18;
    procedure RequestStop;
    function IsStopRequested: Boolean;
    procedure SetStopRequested(Value: Boolean);
    procedure Start;
    function IsRunning: Boolean;
    function WaitForIdle(TimeoutMs: Cardinal): Boolean;
    procedure CheckFailure;
  end;

implementation

type
  TGameWorker = class(TThread)
    Owner: TThreadEC;
    LogName: ShortString;
    procedure Execute; override;
  end;

procedure TGameWorker.Execute;
begin
  SetGameLogThreadName(LogName);
  Owner.ProcessRequests;
end;

constructor TThreadEC.Create(const LogName: ShortString);
var
  NewWorker: TGameWorker;
begin
  inherited Create;
  Lock := TCriticalSection.Create;
  StopEvent := CreateGameEvent(True, False);
  ShutdownEvent := CreateGameEvent(False, False);
  StartEvent := CreateGameEvent(False, False);
  RunningEvent := CreateGameEvent(True, False);
  IdleEvent := CreateGameEvent(True, True);
  NewWorker := TGameWorker.Create(True);
  Worker := NewWorker;
  NewWorker.Owner := Self;
  if LogName = '' then
    NewWorker.LogName := ClassName
  else
    NewWorker.LogName := LogName;
  ThreadHandle := Worker.Handle;
  ThreadId := Worker.ThreadID;
  Worker.Start;
end;

destructor TThreadEC.Destroy;
begin
  if Worker <> nil then
  begin
    RequestStop;
    SetGameEvent(ShutdownEvent);
    Worker.WaitFor;
    FreeAndNil(Worker);
  end;
  CloseGameEvent(IdleEvent);
  CloseGameEvent(StartEvent);
  CloseGameEvent(RunningEvent);
  CloseGameEvent(ShutdownEvent);
  CloseGameEvent(StopEvent);
  Failure.Free;
  Lock.Free;
  inherited Destroy;
end;

procedure TThreadEC.CheckFailure;
var
  Report: TGameExceptionReport;
begin
  Report := nil;
  Lock.Enter;
  try
    if Failure <> nil then
      Report := Failure.Clone;
  finally
    Lock.Leave;
  end;
  if Report <> nil then
    raise EWorkerFailure.Create(Report);
end;

procedure TThreadEC.ProcessRequests;
var
  Events: array[0..1] of TGameEventHandle;
  Failed: Boolean;
  Report: TGameExceptionReport;
begin
  Events[0] := ShutdownEvent;
  Events[1] := StartEvent;
  while WaitGameEvents(Length(Events), @Events, False, INFINITE) = WAIT_OBJECT_0 + 1 do
  begin
    Failed := False;
    try
      Execute;
    except
      // Log on the worker thread before handing the report to observers.
      Report := CaptureGameException('Worker ' + ClassName);
      LogGameException(Report, 'worker');
      Lock.Enter;
      try
        Failure := Report;
      finally
        Lock.Leave;
      end;
      Failed := True;
    end;
    Lock.Enter;
    try
      ResetGameEvent(RunningEvent);
      SetGameEvent(IdleEvent);
    finally
      Lock.Leave;
    end;
    // Publish completion even after failure so a waiting UI can report it.
    if Failed then
      Exit;
  end;
end;

procedure TThreadEC.Execute;
begin
  while not IsStopRequested do
    SysUtils.Sleep(100);
end;

procedure TThreadEC.SetPriority(Value: TThreadPriorityEC);
begin
  Priority := Value;
  if Worker <> nil then
    Worker.Priority := TThreadPriority(Value);
end;

procedure TThreadEC.SetFlag18;
begin
  Flag18 := True;
end;

procedure TThreadEC.ClearFlag18;
begin
  Flag18 := False;
end;

procedure TThreadEC.RequestStop;
begin
  Lock.Enter;
  StopRequested := True;
  SetGameEvent(StopEvent);
  Lock.Leave;
end;

function TThreadEC.IsStopRequested: Boolean;
begin
  Lock.Enter;
  Result := StopRequested;
  Lock.Leave;
end;

procedure TThreadEC.SetStopRequested(Value: Boolean);
begin
  if Value then
    RequestStop
  else
  begin
    Lock.Enter;
    StopRequested := False;
    ResetGameEvent(StopEvent);
    Lock.Leave;
  end;
end;

procedure TThreadEC.Start;
begin
  CheckFailure;
  Lock.Enter;
  try
    if IsRunning then
      Exit;
    ResetGameEvent(StopEvent);
    StopRequested := False;
    ResetGameEvent(IdleEvent);
    SetGameEvent(RunningEvent);
    SetGameEvent(StartEvent);
  finally
    Lock.Leave;
  end;
end;

function TThreadEC.IsRunning: Boolean;
begin
  CheckFailure;
  Result := WaitGameEvent(IdleEvent, 0) = WAIT_TIMEOUT;
end;

function TThreadEC.WaitForIdle(TimeoutMs: Cardinal): Boolean;
begin
  Result := WaitGameEvent(IdleEvent, TimeoutMs) = WAIT_OBJECT_0;
  CheckFailure;
end;

end.
