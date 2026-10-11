program OkgfNarrowArguments;
{$MODE delphi}
uses
  SysUtils, EC_OKGF;
var
  Pixels: array[0..31] of Byte;
  Factors: array[0..4] of Byte = (0, 17, 128, 254, 255);
  Factor, Index, Expected: Integer;
begin
  // Alpha is the sixth C argument, passed on the stack on ARM32. Check both
  // its zero-extension and pixel stride across two rows, including guard bytes.
  for Factor := Low(Factors) to High(Factors) do
  begin
    FillChar(Pixels, SizeOf(Pixels), $5A);
    for Index := 0 to 7 do
      Pixels[3 + Index * 4] := 200 + (Index mod 4) * 3;
    OKGR_Light_BYTE(@Pixels[3], 4, 0, 4, 2, Factors[Factor]);
    for Index := 0 to High(Pixels) do
    begin
      Expected := $5A;
      if Index mod 4 = 3 then
        Expected := ((200 + ((Index div 4) mod 4) * 3) * Factors[Factor] + 127) div 255;
      if Pixels[Index] <> Expected then
        raise Exception.CreateFmt('Lighting factor %d, byte %d: got %d, expected %d',
            [Factors[Factor], Index, Pixels[Index], Expected]);
    end;
  end;
  WriteLn('PASS: narrow C stack argument, alpha boundaries, pixel stride and guard bytes');
end.
