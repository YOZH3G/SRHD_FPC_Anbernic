unit NativeScriptLibrary;

{$I GameOptions.inc}

// Portable implementations retain the original import signatures and save names.
// The existing import metadata holds registry IDs instead of function pointers.
interface

uses
  EC_Expression;

procedure RegisterNativeScriptFunction(
    const LibraryName, Signature: WideString;
    Callback: TExpressionCallback
);
function LoadNativeScriptLibrary(const Path: WideString): Cardinal;
function FreeNativeScriptLibrary(Handle: Cardinal): Boolean;
function NativeScriptLibraryName(Handle: Cardinal): WideString;
function InitNativeScriptFunction(
    Cell: TVarEC;
    Handle: Cardinal;
    const ExportName: WideString;
    const Signature: WideString = ''
): Boolean;
procedure InitAllNativeScriptFunctions(Scope: TVarArrayEC; Handle: Cardinal);
procedure InvokeNativeScriptFunction(Cell: TVarEC; av: array of TVarEC; Code: TCodeEC);

implementation

uses
  SysUtils,
  EC_Str;

type
  TNativeExport = record
    LibraryHandle: Cardinal;
    Name, Signature: WideString;
    Callback: TExpressionCallback;
  end;
var
  Libraries: array of WideString;
  NativeExports: array of TNativeExport;

function LibraryKey(const Path: WideString): WideString;
var
  S: WideString;
  I: Integer;
begin
  S := Path;
  for I := 1 to Length(S) do
    if S[I] = '\' then
      S[I] := '/';
  I := Length(S);
  while (I > 0) and (S[I] <> '/') do
    Dec(I);
  Result := LowerCase(Copy(S, I + 1, MaxInt));
  if Copy(Result, Length(Result) - 3, 4) = '.dll' then
    Delete(Result, Length(Result) - 3, 4);
end;

function LoadNativeScriptLibrary(const Path: WideString): Cardinal;
var
  I: Integer;
  Key: WideString;
begin
  Key := LibraryKey(Path);
  for I := 0 to High(Libraries) do
    if Libraries[I] = Key then
      Exit(I + 1);
  Result := 0;
end;

function FreeNativeScriptLibrary(Handle: Cardinal): Boolean;
begin
  // Native code is part of the executable; freeing an import does not unload it.
  Result := (Handle > 0) and (Handle <= Cardinal(Length(Libraries)));
end;

function NativeScriptLibraryName(Handle: Cardinal): WideString;
begin
  if not FreeNativeScriptLibrary(Handle) then
    raise ExceptionExpressionEC.Create('Unknown native script library');
  Result := Libraries[Handle - 1];
end;

procedure RegisterNativeScriptFunction(
    const LibraryName, Signature: WideString;
    Callback: TExpressionCallback
);
var
  Handle: Cardinal;
  N, I: Integer;
  ExportName: WideString;
begin
  ExportName := ExtractDelimitedPartW(Signature, 1, ',');
  Handle := LoadNativeScriptLibrary(LibraryName);
  if Handle = 0 then
  begin
    if Length(Libraries) >= $FFFF then
      raise ExceptionExpressionEC.Create('Too many native script libraries');
    SetLength(Libraries, Length(Libraries) + 1);
    Handle := Length(Libraries);
    Libraries[Handle - 1] := LibraryKey(LibraryName);
  end;
  // Registration can be repeated while rebuilding the script scope.
  for I := 0 to High(NativeExports) do
    if (NativeExports[I].LibraryHandle = Handle) and (NativeExports[I].Name = ExportName) then
    begin
      NativeExports[I].Signature := Signature;
      NativeExports[I].Callback := Callback;
      Exit;
    end;
  N := Length(NativeExports);
  if N >= $FFFF then
    raise ExceptionExpressionEC.Create('Too many native script exports');
  SetLength(NativeExports, N + 1);
  NativeExports[N].LibraryHandle := Handle;
  NativeExports[N].Name := ExportName;
  NativeExports[N].Signature := Signature;
  NativeExports[N].Callback := Callback;
end;

function InitNativeScriptFunction(
    Cell: TVarEC;
    Handle: Cardinal;
    const ExportName, Signature: WideString
): Boolean;
var
  I, J, Count: Integer;
  Text, Kind: WideString;
  Data: array of Dword;
begin
  Result := False;
  for I := 0 to High(NativeExports) do
    if (NativeExports[I].LibraryHandle = Handle) and (NativeExports[I].Name = ExportName) then
    begin
      Text := Signature;
      if Text = '' then
        Text := NativeExports[I].Signature;
      Count := CountDelimitedPartsW(Text, ',');
      if Count <> CountDelimitedPartsW(NativeExports[I].Signature, ',') then
        raise ExceptionExpressionEC.Create(
            'Native library signature argument count: ' + ExportName);
      SetLength(Data, Count);
      Data[1] := I + 1;
      for J := 0 to Count - 1 do
      begin
        if J = 1 then
          Continue;
        Kind := ExtractDelimitedPartW(Text, J, ',');
        if Kind <> ExtractDelimitedPartW(NativeExports[I].Signature, J, ',') then
          raise ExceptionExpressionEC.Create('Native library signature type: ' + ExportName);
        if Kind = 'void' then
          Data[J] := Ord(lvVoid)
        else if Kind = 'int' then
          Data[J] := Ord(lvInt)
        else if Kind = 'dword' then
          Data[J] := Ord(lvDword)
        else if Kind = 'float' then
          Data[J] := Ord(lvFloat)
        else if Kind = 'str' then
          Data[J] := Ord(lvString)
        else
          raise ExceptionExpressionEC.Create('Unsupported native library type: ' + Kind);
      end;
      // Rebinding must retain the saved library/alias identity: ConvertToKind
      // clears StringValue even when the cell is already a library function.
      Cell := Cell.Resolve;
      if Cell.Kind <> vkLibraryFun then
        Cell.ConvertToKind(vkLibraryFun);
      Cell.SetLibrarySignature(Data);
      Exit(True);
    end;
end;

procedure InitAllNativeScriptFunctions(Scope: TVarArrayEC; Handle: Cardinal);
var
  I: Integer;
  Cell: TVarEC;
begin
  for I := 0 to High(NativeExports) do
    if NativeExports[I].LibraryHandle = Handle then
    begin
      Cell := Scope.GetVarNE(NativeExports[I].Name);
      if Cell = nil then
        Cell := Scope.Add(NativeExports[I].Name, vkLibraryFun);
      if Cell.RealVType <> vkLibraryFun then
        Continue;
      Cell.SetString(NativeScriptLibraryName(Handle) + ',' + NativeExports[I].Name);
      InitNativeScriptFunction(Cell, Handle, NativeExports[I].Name);
    end;
end;

procedure InvokeNativeScriptFunction(Cell: TVarEC; av: array of TVarEC; Code: TCodeEC);
var
  I, Slot: Integer;
  Args: array of TVarEC;
  SingleValue: Single;
  ReturnKind: TLibraryValueKind;
begin
  if Length(Cell.LibraryFunData) < 2 then
    raise ExceptionExpressionEC.Create('Unresolved native library function: ' + Cell.GetString);
  Slot := Cell.LibraryFunData[1];
  if (Slot < 1) or (Slot > Length(NativeExports)) then
    raise ExceptionExpressionEC.Create('Unresolved native library function: ' + Cell.GetString);
  if Length(Cell.LibraryFunData) <> Length(av) + 1 then
    raise ExceptionExpressionEC.Create('Count variable: ' + Cell.Name);
  // A script may assign the result back into the variable holding the callee.
  ReturnKind := TLibraryValueKind(Cell.LibraryFunData[0]);
  SetLength(Args, Length(av));
  try
    // DLL arguments were converted according to the import declaration. In
    // particular float is Single, while dword can also carry a native object.
    for I := 0 to High(Args) do
    begin
      Args[I] := TVarEC.Create(vkEmpty);
      if I = 0 then
        Continue;
      case TLibraryValueKind(Cell.LibraryFunData[I + 1]) of
        lvInt: Args[I].SetInt(av[I].GetInt);
        lvDword: Args[I].SetDword(av[I].GetDword);
        lvFloat:
        begin
          SingleValue := av[I].GetFloat;
          Args[I].SetFloat(SingleValue);
        end;
        lvString:
        begin
          if av[I].RealVType <> vkString then
            raise ExceptionExpressionEC.Create('Variable not string');
          Args[I].SetString(av[I].GetString);
        end;
      end;
    end;
    NativeExports[Slot - 1].Callback(Args, Code);
    av[0].ResetKind(vkEmpty);
    case ReturnKind of
      lvInt: av[0].SetInt(Args[0].GetInt);
      lvDword: av[0].SetDword(Args[0].GetDword);
      lvFloat:
      begin
        SingleValue := Args[0].GetFloat;
        av[0].SetFloat(SingleValue);
      end;
      lvString: av[0].SetString(Args[0].GetString);
    end;
  finally
    for I := 0 to High(Args) do
      Args[I].Free;
  end;
end;

end.
