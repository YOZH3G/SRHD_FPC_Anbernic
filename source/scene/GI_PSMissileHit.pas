unit GI_PSMissileHit;

{$I GameOptions.inc}

interface

type

  TGAISet = array[0..0] of WideString;

var

  MissileHitAnimationPaths: array of TGAISet;

procedure LoadMissileHitAnimationPaths;

implementation

uses
  GR_Main,
  SysUtils,
  Math,
  EC_BlockPar,
  EC_Str,
  Globals;

procedure LoadMissileHitAnimationPaths;
var
  Block, PaletteBlock: TBlockParEC;
  Index, BlockCount, Count: Integer;
  Text: WideString;
begin
  Block := GameDataConfig.GetBlockByPath('SE.Weapon.MissileHit.Palettes');
  BlockCount := Block.GetBlockCount;
  Count := 0;
  for Index := 0 to BlockCount - 1 do
    Count := Math.Max(Count, ExtractDigitsToIntW(Block.GetBlockNameByIndex(Index)) + 1);
  SetLength(MissileHitAnimationPaths, Count);
  for Index := 0 to Count - 1 do
  begin
    Text := IntToStr(Index);
    if Block.CountBlocks(Text) <> 0 then
    begin
      PaletteBlock := Block.GetBlockByPath(Text);
      if PaletteBlock.CountParams('GAI') > 0 then
        MissileHitAnimationPaths[Index][0] := PaletteBlock.GetParam('GAI');
    end;
  end;
end;

end.
