unit GameSDLDiagnostics;

{$MODE DELPHI}

interface

uses
  SysUtils,
  GameDiagnostics;

type
  EGameSDLError = class(EGameDiagnosticException);

// Read SDL's thread-local error before any cleanup or further SDL operation.
function GameSDLErrorMessage: UnicodeString;
procedure RaiseGameSDLError(const Operation: UnicodeString);
procedure CheckGameSDL(Value: Integer; const Operation: UnicodeString);
procedure InstallGameSDLDiagnostics;
procedure RemoveGameSDLDiagnostics;

implementation

uses
  SDL2;

var
  Installed: Boolean;
  PreviousOutput: TSDL_LogOutputFunction;
  PreviousUserData: Pointer;
  PreviousPriorities: array[0..8] of Integer;

function GameSDLErrorMessage: UnicodeString;
begin
  Result := UTF8Decode(UTF8String(SDL_GetError));
  if Result = '' then
    Result := 'SDL did not provide an error message';
end;

procedure RaiseGameSDLError(const Operation: UnicodeString);
begin
  raise EGameSDLError.Create(Operation + ': ' + GameSDLErrorMessage);
end;

procedure CheckGameSDL(Value: Integer; const Operation: UnicodeString);
begin
  if Value < 0 then
    RaiseGameSDLError(Operation);
end;

function SDLLogCategory(Category: Integer): UnicodeString;
begin
  case Category of
    0: Result := 'application';
    1: Result := 'error';
    2: Result := 'assert';
    3: Result := 'system';
    4: Result := 'audio';
    5: Result := 'video';
    6: Result := 'render';
    7: Result := 'input';
    8: Result := 'test';
  else
    Result := IntToStr(Category);
  end;
end;

procedure GameSDLLogOutput(UserData: Pointer; Category, Priority: Integer; Message: PAnsiChar); cdecl;
var
  Level: TGameLogLevel;
begin
  // SDL invokes this from native threads and while holding internal locks.
  // Never let Pascal exceptions unwind through its C callback boundary.
  try
    case Priority of
      1, 2: Level := gllDebug;
      3: Level := gllInfo;
      4: Level := gllWarning;
    else
      Level := gllError;
    end;
    LogGameMessage(Level, 'sdl.' + SDLLogCategory(Category), UTF8Decode(UTF8String(Message)));
  except
  end;
end;

procedure InstallGameSDLDiagnostics;
var
  Category: Integer;
begin
  if Installed then
    Exit;
  SDL_LogGetOutputFunction(PreviousOutput, PreviousUserData);
  SDL_LogSetOutputFunction(@GameSDLLogOutput, nil);
  for Category := Low(PreviousPriorities) to High(PreviousPriorities) do
  begin
    PreviousPriorities[Category] := SDL_LogGetPriority(Category);
    // SDL defaults suppress warnings in some categories.
    if PreviousPriorities[Category] > 4 then
      SDL_LogSetPriority(Category, 4);
  end;
  Installed := True;
end;

procedure RemoveGameSDLDiagnostics;
var
  Category: Integer;
begin
  if not Installed then
    Exit;
  SDL_LogSetOutputFunction(PreviousOutput, PreviousUserData);
  for Category := Low(PreviousPriorities) to High(PreviousPriorities) do
    SDL_LogSetPriority(Category, PreviousPriorities[Category]);
  Installed := False;
end;

finalization
  // This unit finalizes before the logger on which it depends.
  RemoveGameSDLDiagnostics;
end.
