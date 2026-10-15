unit GameScriptLibrary;

{$MODE DELPHI}
{$I mods/NativeMods.inc}

interface

uses
  GameDiagnostics;

type
  EScriptImportError = class(EGameDiagnosticException);

function LoadScriptLibrary(const FileName: UnicodeString): Cardinal;
function FreeScriptLibrary(Handle: Cardinal): Boolean;

implementation

uses
{$IFDEF NATIVE_SCRIPT_MODS}
  NativeScriptLibrary,
{$ENDIF}
  SysUtils;

function LoadScriptLibrary(const FileName: UnicodeString): Cardinal;
begin
{$IFDEF NATIVE_SCRIPT_MODS}
  Result := LoadNativeScriptLibrary(FileName);
  if Result <> 0 then
    Exit;
{$ENDIF}
  // Even Win32 FPC objects do not have the original Delphi layout/VMT ABI.
  // Never substitute the original DLL when its portable implementation is off.
  raise EScriptImportError.Create('Native script library is disabled or unavailable: ' + FileName);
end;

function FreeScriptLibrary(Handle: Cardinal): Boolean;
begin
{$IFDEF NATIVE_SCRIPT_MODS}
  if FreeNativeScriptLibrary(Handle) then
    Exit(True);
{$ENDIF}
  Result := Handle = 0;
end;

end.
