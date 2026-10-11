unit GameScriptLibrary;

{$MODE DELPHI}

interface

function LoadScriptLibrary(const FileName: UnicodeString): Cardinal;
function FreeScriptLibrary(Handle: Cardinal): Boolean;
function ScriptLibraryProc(Handle: Cardinal; const Name: AnsiString): Pointer;

implementation

uses
  SysUtils
{$IF Defined(MSWINDOWS) and Defined(CPU386)}
  ,
  Windows
{$ENDIF}
      ;

function LoadScriptLibrary(const FileName: UnicodeString): Cardinal;
begin
{$IF Defined(MSWINDOWS) and Defined(CPU386)}
  Result := Windows.LoadLibraryW(PWideChar(FileName));
{$ELSE}
  // Script imports describe Win32 stdcall words, including addresses and float
  // bit patterns. Loading a native library would not make that ABI portable.
  raise Exception.Create('Script DLL imports require 32-bit Windows: ' + FileName);
{$ENDIF}
end;

function FreeScriptLibrary(Handle: Cardinal): Boolean;
begin
{$IF Defined(MSWINDOWS) and Defined(CPU386)}
  Result := Windows.FreeLibrary(Handle);
{$ELSE}
  Result := Handle = 0;
{$ENDIF}
end;

function ScriptLibraryProc(Handle: Cardinal; const Name: AnsiString): Pointer;
begin
{$IF Defined(MSWINDOWS) and Defined(CPU386)}
  Result := Windows.GetProcAddress(Handle, PAnsiChar(Name));
{$ELSE}
  Result := nil;
{$ENDIF}
end;

end.
