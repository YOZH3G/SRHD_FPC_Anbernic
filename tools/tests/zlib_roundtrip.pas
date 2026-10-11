program ZlibRoundtrip;
{$MODE delphi}
uses
  SysUtils,
  EC_OKGF;
var
  Source, PackedData, Restored: array[0..4095] of Byte;
  I, Mode, PackedSize, RestoredSize: Integer;
begin
  for I := 0 to High(Source) do
    Source[I] := I mod 17;
  for Mode := 0 to 1 do
  begin
    PackedSize := OKGF_ZLib_Compress(@PackedData[0], @Source[0], SizeOf(Source), Mode);
    if (PackedSize <= 8) or (PackedSize >= SizeOf(Source)) then
      raise Exception.Create('Compression failed');
    if OKGF_ZLib_UnCompress(nil, 0, @PackedData[0], PackedSize) <> SizeOf(Source) then
      raise Exception.Create('Wrong envelope size');
    RestoredSize := OKGF_ZLib_UnCompress(@Restored[0], SizeOf(Restored), @PackedData[0], PackedSize);
    if RestoredSize <> SizeOf(Source) then
      raise Exception.Create('Decompression failed');
    for I := 0 to High(Source) do
      if Restored[I] <> Source[I] then
        raise Exception.CreateFmt('Byte mismatch at %d', [I]);
    PackedData[8] := PackedData[8] xor $FF;
    if OKGF_ZLib_UnCompress(@Restored[0], SizeOf(Restored), @PackedData[0], PackedSize) <> 0 then
      raise Exception.Create('Corrupt stream accepted');
  end;
  Writeln('PASS: zlib roundtrip, envelope size and corrupt-stream rejection');
end.
