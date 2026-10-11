unit EC_OKGF;

{$I GameOptions.inc}

interface

uses
  Types;

type

  // Native ARM FPC must pass narrow C arguments as initialized ABI words.
  {$IFDEF CPUARM}
  TOkgfByteArgument = Cardinal;
  TOkgfWordArgument = Cardinal;
  {$ELSE}
  TOkgfByteArgument = Byte;
  TOkgfWordArgument = Word;
  {$ENDIF}

  PointerToTOkgfReadContext = ^TOkgfReadContext;

  {$Z4}
  TOkgfImageKind = (
      oikUnknown = 0,
      oikBmp = 1,
      oikIndexedBmp = 2,
      oikJpeg = 3,
      oikPng = 4,
      oikIndexedPsd = 5,
      oikGrayscalePsd = 6,
      oikRgbPsd = 7,
      oikCmykPsd = 8
  );

  TOkgfReadContext = packed record
    CodecContext: Pointer;
    ImageKind: TOkgfImageKind;
    Width: Integer;
    Height: Integer;
    PaletteCount: Integer;
    SourceData: Pointer;
    SourceSize: Integer;
    OwnsSource: Integer;
  end;

  POkgfReadContext = PointerToTOkgfReadContext;

function OKGF_ZLib_Compress(
    Dest: Pointer;
    Source: Pointer;
    SourceSize: Integer;
    Mode: Integer
): Integer; stdcall;

function OKGF_ZLib_UnCompress(
    Dest: Pointer;
    DestCapacity: Integer;
    Source: Pointer;
    SourceSize: Integer
): Integer; stdcall;

function OKGF_ZLib_UnCompress2(
    Dest: Pointer;
    DestCapacity: Integer;
    Source: Pointer;
    SourceSize: Integer
): Integer; stdcall;

implementation

uses
  ZBase,
  ZDeflate,
  ZInflate;

function OKGF_ZLib_Compress(
    Dest: Pointer;
    Source: Pointer;
    SourceSize: Integer;
    Mode: Integer
): Integer; stdcall;
var
  Stream: z_stream;
  Level: Integer;
  Header: array[0..1] of Cardinal;
begin
  Result := 0;
  // ZLib.dll $1000B7C0 requires at least 16 input bytes and allows only
  // SourceSize - 8 bytes for the stream: a larger result is left uncompressed.
  if SourceSize < 16 then
    Exit;
  if Mode = 0 then
    Level := Z_BEST_COMPRESSION
  else
    Level := Z_BEST_SPEED;
  FillChar(Stream, SizeOf(Stream), 0);
  Stream.next_in := Source;
  Stream.avail_in := SourceSize;
  Stream.next_out := PByte(Dest) + 8;
  Stream.avail_out := SourceSize - 8;
  if deflateInit(Stream, Level) <> Z_OK then
    Exit;
  try
    if deflate(Stream, Z_FINISH) <> Z_STREAM_END then
      Exit;
    Header[0] := NtoLE(Cardinal($31304C5A));
    Header[1] := NtoLE(Cardinal(SourceSize));
    Move(Header, Dest^, SizeOf(Header));
    Result := Stream.total_out + SizeOf(Header);
  finally
    deflateEnd(Stream);
  end;
end;

function ExpandZlibBlock(
    Dest: Pointer;
    DestCapacity: Integer;
    Source: Pointer;
    SourceSize: Integer;
    RequiredMagic: Cardinal
): Integer;
var
  Magic, ExpectedSize: Cardinal;
  Stream: z_stream;
begin
  Result := 0;
  if SourceSize < 8 then
    Exit;
  Move(Source^, Magic, SizeOf(Magic));
  if LEtoN(Magic) <> RequiredMagic then
    Exit;
  Move((PByte(Source) + 4)^, ExpectedSize, SizeOf(ExpectedSize));
  ExpectedSize := LEtoN(ExpectedSize);
  // ZLib.dll $1000B830 has a header-only size query for ZL01. The ZL02
  // export at $1000B920 has no such query. Neither rejects trailing input.
  if (RequiredMagic = $31304C5A) and (Dest = nil) then
  begin
    Result := Integer(ExpectedSize);
    Exit;
  end;
  if ExpectedSize > Cardinal(DestCapacity) then
    Exit;
  FillChar(Stream, SizeOf(Stream), 0);
  Stream.next_in := PByte(Source) + 8;
  Stream.avail_in := SourceSize - 8;
  Stream.next_out := Dest;
  Stream.avail_out := Cardinal(DestCapacity);
  if inflateInit(Stream) <> Z_OK then
    Exit;
  try
    if (inflate(Stream, Z_FINISH) = Z_STREAM_END) and (Stream.total_out = ExpectedSize) then
      Result := Stream.total_out;
  finally
    inflateEnd(Stream);
  end;
end;

function OKGF_ZLib_UnCompress(
    Dest: Pointer;
    DestCapacity: Integer;
    Source: Pointer;
    SourceSize: Integer
): Integer; stdcall;
begin
  Result := ExpandZlibBlock(Dest, DestCapacity, Source, SourceSize, $31304C5A);
end;

function OKGF_ZLib_UnCompress2(
    Dest: Pointer;
    DestCapacity: Integer;
    Source: Pointer;
    SourceSize: Integer
): Integer; stdcall;
begin
  Result := ExpandZlibBlock(Dest, DestCapacity, Source, SourceSize, $32304C5A);
end;

end.
