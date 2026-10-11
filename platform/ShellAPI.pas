unit ShellAPI;
{$MODE delphi}
{$EXCESSPRECISION OFF}
interface
uses
  Windows;
function ShellExecuteA(
    Window: Windows.THandle;
    Operation, FileName, Parameters, Directory: PAnsiChar;
    ShowCommand: Integer
): Windows.THandle;
implementation
uses
  SysUtils;
{$IFNDEF DARWIN}
function SDL_OpenURL(URL: PAnsiChar): Integer; cdecl; external 'SDL2';
{$ENDIF}
function ShellExecuteA(
    Window: Windows.THandle;
    Operation, FileName, Parameters, Directory: PAnsiChar;
    ShowCommand: Integer
): Windows.THandle;
begin
{$IFDEF DARWIN}
  if ExecuteProcess('/usr/bin/open', [AnsiString(FileName)]) = 0 then
{$ELSE}
  if SDL_OpenURL(FileName) = 0 then
{$ENDIF}
    Result := 33
  else
    Result := 2;
end;
end.
