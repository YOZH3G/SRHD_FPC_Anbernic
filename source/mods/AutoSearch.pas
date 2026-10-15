unit AutoSearch;

{$I GameOptions.inc}
{$LEGACYPC24 OFF}
{$DELPHIORDER OFF}
// Keep DLL binary64 operations out of x87, whose game precision is PC24.
{$EXCESSPRECISION OFF}

// Native implementation of the ExpAutoSearch script library. Request state,
// filtering and result ownership stay here; the host only resets on teardown.
interface

{$IFDEF NATIVE_AUTOSEARCH}
procedure RegisterAutoSearch;
procedure ResetAutoSearch;
{$ENDIF}

implementation

{$IFDEF NATIVE_AUTOSEARCH}
uses
  SysUtils,
  Math,
  EC_Expression,
  aMyFunction,
  NativeScriptLibrary,
  GameObjectRegistry,
  aConst,
  aGalaxy,
  aGalaxyStruct,
  aPlanet,
  aShip,
  aRuins,
  aItem;

type
  TSearchBonus = record
    HullMask, ItemType, Level, Kind: Integer;
    CustomWeapon, Group: WideString;
    Armor, Speed, JumpRange, Radar, Scanner, Repair, Gripper, Shield: Integer;
    NoDelta: Boolean;
  end;
  PSearchBonus = ^TSearchBonus;

  TSearchRequest = record
    ItemType: Integer;
    Owners: array[0..7] of Integer;
    Hulls: array[0..10] of Integer;
    DamageClasses: array[0..2] of Integer;
    CustomWeapon: WideString;
    Minimum, MaximumDamage, Range: Integer;
    Bonus, BonusLevel, Weight, Price, ExcludeConstellation20: Integer;
  end;

  TSearchResult = record
    Item: TEquipment;
    Owner: TObject;
    ItemId, OwnerId: Integer;
  end;

var
  Initialized: Boolean;
  Bonuses: array of TSearchBonus;
  DamageSets: array[50..67] of Integer;
  Request: TSearchRequest;
  Results: array of TSearchResult;
  ResultCount: Integer;

procedure SearchError(const Text: string);
begin
  raise ExceptionExpressionEC.Create('AutoSearch: ' + Text);
end;

procedure RequireInitialized;
begin
  if not Initialized then
    SearchError('Library is not initialized');
end;

function DllText(const Value: WideString): WideString;
var
  N: Integer;
begin
  N := Pos(#0, Value);
  if N = 0 then
    Result := Value
  else
    Result := Copy(Value, 1, N - 1);
end;

procedure ResetAutoSearch;
begin
  Initialized := False;
  Bonuses := nil;
  Results := nil;
  ResultCount := 0;
  FillChar(DamageSets, SizeOf(DamageSets), 0);
  Request := Default(TSearchRequest);
end;

function BonusAt(Index: Integer): PSearchBonus;
begin
  if (Index < 0) or (Index >= Length(Bonuses)) then
    SearchError('Bonus index out of range');
  Result := @Bonuses[Index];
end;

function ItemBonus(IndexPlusOne: Integer): PSearchBonus;
begin
  Result := nil;
  if IndexPlusOne > 0 then
    Result := BonusAt(IndexPlusOne - 1)
  else if IndexPlusOne < 0 then
    SearchError('Invalid equipment bonus index');
end;

procedure SF_Init(av: array of TVarEC; Code: TCodeEC);
var
  Count: Integer;
begin
  Count := av[1].GetInt;
  if (Count < 0) or (Count > 65536) then
    SearchError('Bonus count out of range');
  // The DLL's player pointer only distinguishes a military-base name that is
  // never excluded by the search. No borrowed player pointer is needed here.
  ResetAutoSearch;
  SetLength(Bonuses, Count);
  Initialized := True;
end;

procedure SF_IsInitialized(av: array of TVarEC; Code: TCodeEC);
begin
  av[0].SetInt(Ord(Initialized));
end;

procedure SF_FillBonus(av: array of TVarEC; Code: TCodeEC);
const
  HullNames: array[0..6] of WideString = ('Ranger', 'Warrior', 'Pirate', 'Transport', 'Liner', 'Diplomat', 'Flagman');
  HullBits: array[0..6] of Integer = (1, 2, 4, 8, 16, 32, 2048);
var
  Bonus: PSearchBonus;
  Text: WideString;
  I: Integer;
begin
  RequireInitialized;
  Bonus := BonusAt(av[1].GetInt);
  Text := DllText(av[5].GetString);
  for I := 0 to High(HullNames) do
    if Pos(HullNames[I], Text) > 0 then
      Inc(Bonus.HullMask, HullBits[I]);
  Bonus.ItemType := av[6].GetInt;
  Text := av[7].GetString;
  if Text <> '' then
    Bonus.CustomWeapon := DllText(Text);
  Text := av[8].GetString;
  if Text <> '' then
    Bonus.Group := DllText(Text);
  Bonus.Level := av[9].GetInt;
  Bonus.Armor := av[19].GetInt;
  Bonus.Speed := av[20].GetInt;
  Bonus.JumpRange := av[21].GetInt;
  Bonus.Radar := av[22].GetInt;
  Bonus.Scanner := av[23].GetInt;
  Bonus.Repair := av[24].GetInt;
  Bonus.Gripper := av[25].GetInt;
  Bonus.Shield := av[26].GetInt;
  // Both the mask and NoDelta accumulate if a bonus slot is filled again.
  if Pos('NoDelta', DllText(av[27].GetString)) > 0 then
    Bonus.NoDelta := True;
  Bonus.Kind := av[28].GetInt;
end;

procedure SF_FillDamageSet(av: array of TVarEC; Code: TCodeEC);
var
  Kind: Integer;
begin
  RequireInitialized;
  Kind := av[1].GetInt;
  if (Kind < Low(DamageSets)) or (Kind > High(DamageSets)) then
    SearchError('Weapon type out of range');
  DamageSets[Kind] := av[2].GetInt;
end;

procedure SF_FillRequest(av: array of TVarEC; Code: TCodeEC);
const
  EquipmentNames: array[42..49] of WideString =
      ('Hulls', 'FuelTanks', 'Engines', 'Radars', 'Scanners', 'Droids', 'Grippers', 'ShieldGenerators');
var
  Name, Text: WideString;
  Kind, I: Integer;
begin
  RequireInitialized;
  Name := DllText(av[1].GetString);
  Request.ExcludeConstellation20 := av[24].GetInt;
  if Name = 'Weapons' then
    Kind := av[18].GetInt
  else
  begin
    Kind := Low(EquipmentNames);
    while (Kind <= High(EquipmentNames)) and (EquipmentNames[Kind] <> Name) do
      Inc(Kind);
    // Unknown names only update the constellation exclusion in the DLL.
    if Kind > High(EquipmentNames) then
      Exit;
  end;
  Request.ItemType := Kind;
  for I := 0 to 7 do
    Request.Owners[I] := av[I + 2].GetInt;
  if Name = 'Weapons' then
  begin
    for I := 0 to 2 do
      Request.DamageClasses[I] := av[I + 10].GetInt;
    Request.Minimum := av[13].GetInt;
    Request.MaximumDamage := av[14].GetInt;
    Request.Range := av[15].GetInt;
    Text := av[19].GetString;
    if Text <> '' then
      Request.CustomWeapon := DllText(Text);
  end
  else if Name = 'Hulls' then
  begin
    for I := 0 to 5 do
      Request.Hulls[I] := av[I + 10].GetInt;
    Request.Hulls[10] := av[16].GetInt;
    Request.Minimum := av[17].GetInt;
  end
  else
  begin
    Request.Minimum := av[10].GetInt;
    if Name = 'Engines' then
      Request.MaximumDamage := av[11].GetInt;
  end;
  Request.Bonus := av[20].GetInt;
  Request.BonusLevel := av[21].GetInt;
  Request.Weight := av[22].GetInt;
  Request.Price := av[23].GetInt;
end;

function MatchesBonus(Bonus: PSearchBonus): Boolean;
var
  Selected: PSearchBonus;
begin
  Result := False;
  if Request.Bonus < 0 then
  begin
    if Request.Bonus = -1 then
    begin
      if Request.BonusLevel <> 0 then
        if (Bonus = nil) or (Bonus.Kind = 2) or ((Request.BonusLevel > 1) and (Bonus.Level < Request.BonusLevel)) then
          Exit;
    end
    else if (Request.Bonus = -2) and (Bonus <> nil) and (Bonus.Kind <> 2) then
      Exit;
    Exit(True);
  end;
  Selected := BonusAt(Request.Bonus);
  if (Bonus = nil) or (Bonus.Kind = 2) then
    Exit;
  if Request.BonusLevel <> 0 then
    Result := (Bonus.Group = Selected.Group) and ((Request.BonusLevel <= 1) or (Bonus.Level >= Request.BonusLevel))
  else
    Result := (Bonus = Selected) or ((Selected.Group <> '') and (Bonus.Group = Selected.Group));
end;

function HasNoDelta(IndexPlusOne: Integer): Boolean;
var
  Bonus: PSearchBonus;
begin
  Bonus := ItemBonus(IndexPlusOne);
  Result := (Bonus <> nil) and Bonus.NoDelta;
end;

function WeaponNoDelta(Item: TWeapon; EffectiveKind: Integer): Boolean;
var
  I: Integer;
  Entry: PExtraSpecial;
begin
  if EffectiveKind >= 68 then
    Exit(
        (Item is TCustomWeapon)
            and (TCustomWeapon(Item).CustomInfo <> nil)
            and ((Cardinal(TCustomWeapon(Item).CustomInfo.DamageFlags) and $100000) <> 0)
    );
  Result := HasNoDelta(Item.SpecialModuleIndex) or HasNoDelta(Item.MicroModuleIndex);
  if Result or (Item.ExtraSpecials = nil) then
    Exit;
  for I := 0 to Item.ExtraSpecials.Count - 1 do
  begin
    Entry := Item.ExtraSpecials[I];
    if (Entry <> nil) and HasNoDelta(Entry.ModuleIndexPlusOne) then
      Exit(True);
  end;
end;

function TruncateInt32(Value: Double): Integer;
begin
  // SSE cvttsd2si returns INT_MIN for NaN, infinity and out-of-range results.
  if IsNan(Value) or (Value < -2147483648.0) or (Value >= 2147483648.0) then
    Result := Low(Integer)
  else
    Result := Trunc(Value);
end;

function MatchesItem(Item: TEquipment): Boolean;
var
  Bonus: PSearchBonus;
  Kind, OriginalKind, Flags, DamageClass, I, Value: Integer;
  SkipStats, ConvertedWeapon: Boolean;
  Weapon: TWeapon;
  CustomInfo: PWeaponInfo;
  ShieldValue: Double;
begin
  Result := False;
  OriginalKind := Ord(Item.ItemType);
  Kind := OriginalKind;
  CustomInfo := nil;
  if Item is TCustomWeapon then
    CustomInfo := TCustomWeapon(Item).CustomInfo;
  Bonus := ItemBonus(Item.SpecialModuleIndex);
  SkipStats := False;
  ConvertedWeapon := False;
  if (Bonus <> nil) and (Bonus.ItemType <> 0) then
  begin
    if OriginalKind < 50 then
      SkipStats := Bonus.ItemType <> OriginalKind
    else
    begin
      ConvertedWeapon := Bonus.ItemType >= 50;
      SkipStats := not ConvertedWeapon;
    end;
    Kind := Bonus.ItemType;
  end;
  if Request.ItemType = -1 then
  begin
    if (Kind < 50) or (Kind > 68) then
      Exit;
    if Kind = 68 then
    begin
      if CustomInfo = nil then
        Exit;
      Flags := Cardinal(CustomInfo.DamageFlags);
    end
    else
      Flags := DamageSets[Kind];
    DamageClass := 0;
    if (Flags and 1) <> 0 then
      DamageClass := 0
    else if (Flags and 2) <> 0 then
      DamageClass := 1
    else if (Flags and 4) <> 0 then
      DamageClass := 2;
    if Request.DamageClasses[DamageClass] = 0 then
      Exit;
    Kind := -1;
  end
  else if (Kind <> Request.ItemType) and (Kind <> -1) then
    Exit;
  if Request.Weight <> 0 then
    if ((Kind = 42) and (Item.Weight < Request.Weight)) or ((Kind <> 42) and (Item.Weight > Request.Weight)) then
      Exit;
  if (Request.Price <> 0) and (Item.Cost > Request.Price) then
    Exit;
  I := Ord(Item.OwnerId);
  if (I > High(Request.Owners)) or (Request.Owners[I] <> 1) then
    Exit;
  if (DllText(Item.CustomFaction) <> '') and (Copy(Item.CustomFaction, 1, 10) <> 'SubFaction') then
    Exit;
  if not MatchesBonus(Bonus) then
    Exit;
  if SkipStats then
    Exit(True);

  if (Kind = -1) or ((Kind >= 50) and (Kind <= 68)) then
  begin
    if not (Item is TWeapon) then
      Exit;
    Weapon := TWeapon(Item);
    if Kind = 68 then
    begin
      if CustomInfo = nil then
        Exit;
      if DllText(CustomInfo.ConfigName) <> Request.CustomWeapon then
        if not ConvertedWeapon or (Bonus.CustomWeapon <> Request.CustomWeapon) then
          Exit;
    end;
    if ((Request.MaximumDamage <> 0) and (Weapon.MaxDamage < Request.MaximumDamage))
        or ((Request.Range <> 0) and (Weapon.Range < Request.Range)) then
      Exit;
    if Request.Minimum <> 0 then
    begin
      Value := Weapon.MinDamage;
      if WeaponNoDelta(Weapon, Kind) then
        Value := Weapon.MaxDamage;
      if Value < Request.Minimum then
        Exit;
    end;
    Exit(True);
  end;

  Value := 0;
  case Kind of
    42:
    begin
      if not (Item is THull) then
        Exit;
      Value := Byte(THull(Item).Armor);
      if Bonus <> nil then
        Inc(Value, Bonus.Armor);
      if (Request.Minimum <> 0) and (Value < Request.Minimum) then
        Exit;
      // Preserve the DLL's ItemType-vs-HullType read: unbonused hulls fail.
      if Bonus = nil then
        Exit((OriginalKind <= 5) and (Request.Hulls[OriginalKind] <> 0));
      if Bonus.HullMask = 0 then
        Exit(True);
      // Flagman is stored as bit 11, but the original tests only bits 0..10.
      for I := 0 to High(Request.Hulls) do
        if (Request.Hulls[I] <> 0) and ((Bonus.HullMask and (1 shl I)) <> 0) then
          Exit(True);
      Exit;
    end;
    43:
    begin
      if not (Item is TFuelTanks) then
        Exit;
      Value := TFuelTanks(Item).Capacity;
    end;
    44:
    begin
      if not (Item is TEngine) then
        Exit;
      Value := TEngine(Item).Speed;
      if Bonus <> nil then
        Inc(Value, Bonus.Speed);
      if (Request.Minimum <> 0) and (Value < Request.Minimum) then
        Exit;
      Value := Byte(TEngine(Item).JumpRange);
      if Bonus <> nil then
        Inc(Value, Bonus.JumpRange);
      Exit((Request.MaximumDamage = 0) or (Value >= Request.MaximumDamage));
    end;
    45:
    begin
      if not (Item is TRadar) then
        Exit;
      Value := TRadar(Item).Range;
      if Bonus <> nil then
        Inc(Value, Bonus.Radar);
    end;
    46:
    begin
      if not (Item is TScaner) then
        Exit;
      Value := Byte(TScaner(Item).ScanPower);
      if Bonus <> nil then
        Inc(Value, Bonus.Scanner);
    end;
    47:
    begin
      if not (Item is TRepairRobot) then
        Exit;
      Value := TRepairRobot(Item).RepairPoints;
      if Bonus <> nil then
        Inc(Value, Bonus.Repair);
    end;
    48:
    begin
      if not (Item is TCargoHook) then
        Exit;
      Value := TCargoHook(Item).PickupPower;
      if Bonus <> nil then
        Inc(Value, Bonus.Gripper);
    end;
    49:
    begin
      if not (Item is TDefGenerator) then
        Exit;
      ShieldValue := 1.0 - Double(TDefGenerator(Item).DamageFactor);
      if Bonus = nil then
        Value := TruncateInt32(ShieldValue * 100.0)
      else
        Value := Bonus.Shield - TruncateInt32(ShieldValue * -100.0);
    end;
  else
    Exit; // Invalid type/layout combinations must not become arbitrary reads.
  end;
  Result := (Request.Minimum = 0) or (Value >= Request.Minimum);
end;

procedure SearchShop(Shop: TObjectList; Owner: TObject; OwnerId: Integer);
var
  I: Integer;
  Item: TEquipment;
begin
  if Shop = nil then
    Exit;
  for I := 0 to Shop.Count - 1 do
  begin
    Item := TEquipment(Shop[I]);
    if not IsLiveGameObject(Item) or not (Item is TEquipment) then
      Continue;
    if not MatchesItem(Item) then
      Continue;
    if ResultCount = Length(Results) then
      SetLength(Results, ResultCount * 2 + 64);
    Results[ResultCount].Item := Item;
    Results[ResultCount].Owner := Owner;
    Results[ResultCount].ItemId := Item.Id;
    Results[ResultCount].OwnerId := OwnerId;
    Inc(ResultCount);
  end;
end;

procedure SF_Launch(av: array of TVarEC; Code: TCodeEC);
var
  Origin, Star: TStar;
  Planet: TPlanet;
  Station: TRuins;
  Obj: TObject;
  I, J: Integer;
begin
  RequireInitialized;
  ResultCount := 0;
  if (Galaxy = nil) or not IsLiveGameObject(Galaxy) or Galaxy.Destroying or (av[1].GetDword <> PtrUInt(Galaxy)) or (Galaxy.Stars = nil) then
    SearchError('Invalid or inactive galaxy');
  Origin := TStar(av[2].GetDword);
  if (Origin = nil) or (Galaxy.Stars.IndexOf(Origin) < 0) then
    SearchError('Invalid or expired origin star');
  if Length(Origin.StarDistances) < Galaxy.Stars.Count then
    SearchError('Incomplete star distance cache');
  // Planet shops precede station shops; retain the game's existing distance
  // cache and tie order rather than recalculating/sorting coordinates.
  try
    for I := 0 to Galaxy.Stars.Count - 1 do
    begin
      Star := Origin.StarDistances[I].Star;
      if (Star = nil) or (Galaxy.Stars.IndexOf(Star) < 0) then
        SearchError('Invalid cached star');
      if (Request.ExcludeConstellation20 <> 0) and (Star.Constellation <> nil) and (Star.Constellation.Id = 20) then
        Continue;
      if (DllText(Star.Status.CustomFaction) = '') and (Star.Planets <> nil) then
        for J := 0 to Star.Planets.Count - 1 do
        begin
          Obj := Star.Planets[J];
          if not IsLiveGameObject(Obj) or not (Obj is TPlanet) then
            Continue;
          Planet := TPlanet(Obj);
          if not (Ord(Planet.OwnerId) in [5, 6]) then
            SearchShop(Planet.EquipmentShop, Planet, Integer(Planet.Id));
        end;
      if Star.Ships <> nil then
        for J := 0 to Star.Ships.Count - 1 do
        begin
          Obj := Star.Ships[J];
          if not IsLiveGameObject(Obj) or not (Obj is TRuins) then
            Continue;
          Station := TRuins(Obj);
          if (Ord(Station.TypeId) in [6..13]) and (DllText(Station.TypeNameOverrideKey) <> 'SSB') then
            SearchShop(Station.EquipmentShop, Station, Station.Id);
        end;
    end;
  except
    ResultCount := 0;
    raise;
  end;
  av[0].SetInt(ResultCount);
end;

procedure SF_GetResult(av: array of TVarEC; Code: TCodeEC);
var
  Index: Integer;
  Entry: TSearchResult;
  Shop: TObjectList;
begin
  RequireInitialized;
  Index := av[1].GetInt;
  if (Index < 0) or (Index >= ResultCount) then
    SearchError('Result index out of range');
  Entry := Results[Index];
  av[0].SetDword(0);
  if not IsLiveGameObject(Entry.Item)
      or not IsLiveGameObject(Entry.Owner)
      or not (Entry.Item is TEquipment)
      or (Entry.Item.Id <> Entry.ItemId) then
    Exit;
  if Entry.Owner is TPlanet then
  begin
    if Integer(TPlanet(Entry.Owner).Id) <> Entry.OwnerId then
      Exit;
    Shop := TPlanet(Entry.Owner).EquipmentShop;
  end
  else if Entry.Owner is TRuins then
  begin
    if TRuins(Entry.Owner).Id <> Entry.OwnerId then
      Exit;
    Shop := TRuins(Entry.Owner).EquipmentShop;
  end
  else
    Exit;
  if (Shop = nil) or (Shop.IndexOf(Entry.Item) < 0) then
    Exit;
  if av[2].GetInt = 0 then
    av[0].SetDword(PtrUInt(Entry.Item))
  else
    av[0].SetDword(PtrUInt(Entry.Owner));
end;

procedure RegisterAutoSearch;
begin
  RegisterNativeScriptFunction('AutoSearch', 'int,IsAutoSearchDLLInit', @SF_IsInitialized);
  RegisterNativeScriptFunction('AutoSearch', 'void,InitAutoSearchDLL,int,dword', @SF_Init);
  RegisterNativeScriptFunction(
      'AutoSearch',
      'void,FillAutoSearchBonusArray,int,str,str,str,str,int,str,str,int,str,str,str,str,str,str,str,str,int,int,int,int,int,int,int,int,int,str,int',
      @SF_FillBonus
  );
  RegisterNativeScriptFunction('AutoSearch', 'void,FillAutoSearchDamageSetArray,int,int', @SF_FillDamageSet);
  RegisterNativeScriptFunction(
      'AutoSearch',
      'void,FillAutoSearchRequestList,str,int,int,int,int,int,int,int,int,int,int,int,int,int,int,int,int,int,str,int,int,int,int,int',
      @SF_FillRequest
  );
  RegisterNativeScriptFunction('AutoSearch', 'int,AutoSearchLaunch,dword,dword', @SF_Launch);
  RegisterNativeScriptFunction('AutoSearch', 'dword,GetAutoSearchResult,int,int', @SF_GetResult);
end;

initialization
  RegisterAutoSearch;
{$ENDIF}
end.
