unit UtilityFunctionsPack;

{$I GameOptions.inc}
// This DLL was compiled with C++ binary64 intermediates, unlike the Delphi game.
{$LEGACYPC24 OFF}
// Keep declared Single/Double operations off Win32's PC24 x87 intermediates.
{$EXCESSPRECISION OFF}
{$DELPHIORDER OFF}

// Native implementation of UtilityFunctions.dll 2.2.1. All mod-specific state
// and behavior live here; the host only registers the library and forwards
// galaxy teardown/capital recalculation. No Win32 object layouts or DLL ABI.
interface

{$IFDEF NATIVE_UTILITY_FUNCTIONS_PACK}
procedure RegisterUtilityFunctionsPack;
procedure ResetUtilityFunctionsPack;
procedure ApplyUtilityFunctionsCapitalOverride(var Capital: Integer);
{$ENDIF}

implementation

{$IFDEF NATIVE_UTILITY_FUNCTIONS_PACK}
uses
  Classes,
  SysUtils,
  Math,
  StrUtils,
  DateUtils,
  SDL2,
  EC_Expression,
  NativeScriptLibrary,
  GameObjectRegistry,
  aGalaxy,
  aGalaxyStruct,
  aPlanet,
  aShip,
  aItem,
  aPlayer,
  aScript,
  aTransport,
  aWarrior,
  aKling,
  aRuins,
  aPath,
  GR_Main,
  GameInput,
  GameWindow;

// CHANGE: PORTABILITY - Native implementation of UtilityFunctions.dll 2.2.1
// (KIaxons/Utility-Functions-Pack b24d0fd). Keep script-visible behavior here;
// typed fields replace the DLL's x86 offsets, Delphi VMT calls and raw pointers.
type
  TUtilityNearbyShip = record
    Ship: TShip;
    ShipId: Integer;
    Distance: Integer;
  end;
var
  UtilityNearbyShips: array of TUtilityNearbyShip;
  UtilityCapitalTarget: Integer = 0;
  UtilityCapitalOverrideEnabled: Boolean = False;
  UtilityRandomState: Cardinal;
  UtilityRegistered: Boolean = False;

procedure UtilityError(const Text: string);
begin
  raise ExceptionExpressionEC.Create('UtilityFunctions: ' + Text);
end;

procedure UtilityRequireGalaxy;
begin
  if (Galaxy = nil) or not IsLiveGameObject(Galaxy) or Galaxy.Destroying then
    UtilityError('No active galaxy');
end;

function UtilityPlayer: TPlayer;
begin
  UtilityRequireGalaxy;
  Result := GetPlayer;
  if not IsLiveGameObject(Result) or not (Result is TPlayer) then
    UtilityError('No active player');
end;

function UtilityObject(Value: PtrUInt): TObject;
begin
  UtilityRequireGalaxy;
  // Never inspect a script-supplied VMT before proving that the address is an
  // allocated game object. TStar predates TObjectEx and belongs to Stars.
  if (Value = 0)
      or (not IsLiveGameObject(Pointer(Value))
          and ((Galaxy.Stars = nil) or (Galaxy.Stars.IndexOf(Pointer(Value)) < 0))) then
    UtilityError('Invalid or expired object');
  Result := TObject(Value);
end;

function UtilityShip(Value: TVarEC): TShip;
var
  Obj: TObject;
begin
  Obj := UtilityObject(Value.GetDword);
  if not (Obj is TShip) then
    UtilityError('Expected ship or station');
  Result := TShip(Obj);
end;

function UtilityPlanet(Value: TVarEC): TPlanet;
var
  Obj: TObject;
begin
  Obj := UtilityObject(Value.GetDword);
  if not (Obj is TPlanet) then
    UtilityError('Expected planet');
  Result := TPlanet(Obj);
end;

function UtilityBinding(Ship: TShip): TScriptShip;
begin
  Result := TScriptShip(Ship.ScriptShip);
  if Result = nil then
    Exit;
  if not IsLiveGameObject(Result)
      or not (Result is TScriptShip)
      or not IsLiveGameObject(Result.Script)
      or not (Result.Script is TScript)
      or (Result.GroupIndex < 0)
      or (Result.GroupIndex >= Result.Script.Groups.Count) then
    UtilityError('Invalid ship script binding');
end;

function UtilitySeed(Obj: TObject; Generation: Boolean): PCardinal;
begin
  Obj := UtilityObject(PtrUInt(Obj));
  if Obj is TGalaxy then
  begin
    if Generation then
      Result := @TGalaxy(Obj).GenerationSeed
    else
      Result := @TGalaxy(Obj).RandomState;
  end
  else if Obj is TShip then
  begin
    if Generation then
      Result := @TShip(Obj).Seed
    else
      Result := @TShip(Obj).RandomState;
  end
  else if Obj is TPlanet then
  begin
    if Generation then
      Result := @TPlanet(Obj).GenerationSeed
    else
      Result := @TPlanet(Obj).RandomState;
  end
  else if Obj is TStar then
  begin
    if Generation then
      Result := @TStar(Obj).GenerationSeed
    else
      Result := @TStar(Obj).RandomState;
  end
  else
  begin
    UtilityError('Object has no random seed');
    Result := nil;
  end;
end;

function UtilityTruncFloat(Value: Double): Double;
var
  Bits: QWord;
begin
  if IsNan(Value) or IsInfinite(Value) then
    UtilityError('Non-finite numeric value');
  // Every representable binary64 value at this magnitude is integral. Avoid
  // FPC's Int64-returning Floor/Ceil/Trunc for otherwise valid large floats.
  if Abs(Value) < 1 then
  begin
    // C floor/ceil preserve negative zero, including ceil(-tiny).
    Move(Value, Bits, SizeOf(Bits));
    Bits := Bits and QWord($8000000000000000);
    Move(Bits, Result, SizeOf(Result));
  end
  else if Abs(Value) >= 4503599627370496.0 then
    Result := Value
  else
    Result := Trunc(Value);
end;

function UtilityFloor(Value: Double): Double;
begin
  Result := UtilityTruncFloat(Value);
  if Result > Value then
    Result := Result - 1;
end;

function UtilityCeil(Value: Double): Double;
begin
  Result := UtilityTruncFloat(Value);
  if Result < Value then
    Result := Result + 1;
end;

function UtilityRoundEven(Value: Double): Double;
var
  Whole, Fraction: Double;
begin
  Whole := UtilityTruncFloat(Value);
  Fraction := Abs(Value - Whole);
  if Abs(Fraction - 0.5) < 2.2204460492503131e-16 then
    Result := UtilityFloor(Value * 0.5 + 0.5) * 2
  else if Value >= 0 then
    Result := UtilityTruncFloat(Value + 0.5)
  else
    Result := UtilityTruncFloat(Value - 0.5);
end;

function UtilityInt(Value: Double): Integer;
begin
  if IsNan(Value) or IsInfinite(Value) or (Value < Low(Integer)) or (Value > High(Integer)) then
    UtilityError('Numeric result is outside the 32-bit integer range');
  Result := Trunc(Value);
end;

function UtilityBankRound(Value: Double): Integer;
begin
  Result := UtilityInt(UtilityRoundEven(Value));
end;

function UtilityRandom(Minimum, Maximum: Integer; Obj: TObject): Integer;
var
  State: PCardinal;
  Seed, Previous, Width: Cardinal;
  LowValue: Integer;
begin
  State := UtilitySeed(Obj, False);
  if Galaxy.CustomRules.Enabled and Galaxy.CustomRules.ChaoticRandom then
  begin
    // Compatibility: the DLL uses its own MSVC rand(), with only 15 random
    // bits, and does not advance the object's saved seed in chaotic mode.
    UtilityRandomState := UtilityRandomState * 214013 + 2531011;
    Seed := (UtilityRandomState shr 16) and $7FFF;
  end
  else
  begin
    Previous := State^;
    Seed := Previous * 7981 + 567 + Previous div 7981;
    if Seed = Previous then
      Seed := Seed * 7281 + 517 + Seed div 7181;
    State^ := Seed;
  end;
  LowValue := Min(Minimum, Maximum);
  Width := Cardinal(Max(Minimum, Maximum) - LowValue + 1);
  if Width = 0 then
    UtilityError('Random range overflows 32 bits');
  Result := LowValue + Integer(Seed mod Width);
end;

function UtilityPart(const Text, Separator: WideString; Index, ClearSpaces: Integer): WideString;
var
  Start, Finish, I: Integer;
begin
  Result := '';
  if Separator = '' then
  begin
    // Unlike separated fields, character indexing does not apply abs().
    if (Index < 0) or (Index > Length(Text)) then
      UtilityError('Character index out of range');
    Exit(Copy(Text, Index + 1, 1));
  end;
  if Index = Low(Integer) then
    Exit;
  Index := Abs(Index);
  Start := 1;
  while True do
  begin
    Finish := PosEx(Separator, Text, Start);
    if Finish = 0 then
      Finish := Length(Text) + 1;
    if Index = 0 then
    begin
      Result := Copy(Text, Start, Finish - Start);
      Break;
    end;
    if Finish > Length(Text) then
      Exit;
    Start := Finish + Length(Separator);
    Dec(Index);
  end;
  if ClearSpaces = 1 then
  begin
    while (Result <> '') and (Result[1] in [#9..#13, ' ']) do
      Delete(Result, 1, 1);
    while (Result <> '') and (Result[Length(Result)] in [#9..#13, ' ']) do
      Delete(Result, Length(Result), 1);
  end
  else if ClearSpaces <> 0 then
    for I := Length(Result) downto 1 do
      if Result[I] in [#9, ' '] then
        Delete(Result, I, 1);
end;

function UtilityPortion(Cur, A, B, FromA, ToB: Double): Double;
begin
  if A < B then
  begin
    if Cur <= A then
      Exit(FromA);
    if Cur >= B then
      Exit(ToB);
    Result := (Cur - A) / (B - A) * (ToB - FromA) + FromA;
  end
  else
  begin
    if Cur >= A then
      Exit(FromA);
    if Cur <= B then
      Exit(ToB);
    Result := (A - Cur) / (A - B) * (ToB - FromA) + FromA;
  end;
end;

procedure SF_UFP_UtilityFunctionsLibInit(av: array of TVarEC; code: TCodeEC);
begin
  UtilityRequireGalaxy;
  // The port already owns typed Galaxy/Player references; no VMT harvesting.
  if TObject(av[1].GetDword) <> Galaxy then
    UtilityError('Unexpected galaxy');
end;

procedure SF_UFP_GetObjectGenerationSeed(av: array of TVarEC; code: TCodeEC);
begin
  av[0].SetInt(Integer(UtilitySeed(TObject(av[1].GetDword), True)^));
end;

procedure SF_UFP_GetObjectSeed(av: array of TVarEC; code: TCodeEC);
begin
  av[0].SetInt(Integer(UtilitySeed(TObject(av[1].GetDword), False)^));
end;

procedure SF_UFP_GetSectorAdjacentToDicea(av: array of TVarEC; code: TCodeEC);
var
  I: Integer;
  Sector: TConstellation;
begin
  UtilityRequireGalaxy;
  av[0].SetDword(0);
  for I := 0 to Galaxy.Constellations.Count - 1 do
  begin
    Sector := Galaxy.Constellations[I];
    if (Sector.Id <> 20) and (Sector.HiddenOutlineSegmentsBackup.Count <> 0) then
    begin
      av[0].SetDword(PtrUInt(Sector));
      Exit;
    end;
  end;
end;

procedure SF_UFP_AdvancedAdjustmentSet(av: array of TVarEC; code: TCodeEC);
var
  Option, Value, Maximum, Minimum, OldValue: Integer;
  Field: PByte;
  Scaled: Boolean;
begin
  UtilityRequireGalaxy;
  Option := av[1].GetInt;
  Value := av[2].GetInt;
  Field := nil;
  case Option of
    -2: Field := @Galaxy.StasisModEnabled;
    -1: Field := PByte(@Galaxy.IronWill);
    0: Field := PByte(@Galaxy.CustomRules.Enabled);
    1: Field := PByte(@Galaxy.CustomRules.DominatorStrength);
    2: Field := PByte(@Galaxy.CustomRules.DominatorAggression);
    3: Field := PByte(@Galaxy.CustomRules.DominatorSpawn);
    4: Field := PByte(@Galaxy.CustomRules.PirateAggression);
    5: Field := PByte(@Galaxy.CustomRules.CoalitionAggression);
    6: Field := PByte(@Galaxy.CustomRules.AsteroidModifier);
    7: Field := PByte(@Galaxy.CustomRules.SunDamageModifier);
    8: Field := PByte(@Galaxy.CustomRules.ExtraInventions);
    9: Field := PByte(@Galaxy.CustomRules.AcrynModifier);
    10: Field := PByte(@Galaxy.CustomRules.NodeDropModifier);
    11: Field := PByte(@Galaxy.CustomRules.ArcadeDropValueModifier);
    12: Field := PByte(@Galaxy.CustomRules.DropValueModifier);
    13: Field := PByte(@Galaxy.CustomRules.AgriculturalPlanetWeight);
    14: Field := PByte(@Galaxy.CustomRules.MixedPlanetWeight);
    15: Field := PByte(@Galaxy.CustomRules.IndustrialPlanetWeight);
    16: Field := PByte(@Galaxy.CustomRules.ExtraRangers);
    17: Field := PByte(@Galaxy.CustomRules.ArcadeHitpointsModifier);
    18: Field := PByte(@Galaxy.CustomRules.ArcadeDamageModifier);
    19: Field := PByte(@Galaxy.CustomRules.AIJunkTolerance);
    20: Field := PByte(@Galaxy.CustomRules.ChaoticRandom);
    21: Field := PByte(@Galaxy.CustomRules.UnrestrictedEquipmentKnowledge);
    22: Field := PByte(@Galaxy.CustomRules.StationsNearStars);
    23: Field := PByte(@Galaxy.CustomRules.FullStationTargeting);
    24: Field := PByte(@Galaxy.CustomRules.SpecialShips);
    25: Field := PByte(@Galaxy.CustomRules.ZeroStartingExperience);
    26: Field := PByte(@Galaxy.CustomRules.ArcadeBattleRoyale);
    27: Field := PByte(@Galaxy.CustomRules.DominatorRacialWeapons);
    28: Field := PByte(@Galaxy.CustomRules.StartInCenter);
    29: Field := PByte(@Galaxy.CustomRules.MaxRangeMissiles);
    30: Field := PByte(@Galaxy.CustomRules.OldHyperspace);
    31: Field := PByte(@Galaxy.CustomRules.PirateNodes);
    32: Field := PByte(@Galaxy.CustomRules.AIUseShops);
    33: Field := PByte(@Galaxy.CustomRules.StationsUseShop);
    34: Field := PByte(@Galaxy.CustomRules.DuplicateArtefacts);
    35: Field := PByte(@Galaxy.CustomRules.HullGrowth);
    36: Field := PByte(@Galaxy.CustomRules.ArcadeEquipmentChange);
    37: Field := PByte(@Galaxy.CustomRules.OldSpeedCalculation);
    38: Field := PByte(@Galaxy.CustomRules.OldMissileBonuses);
  end;
  if Field = nil then
  begin
    av[0].SetInt(-1);
    Exit;
  end;
  Scaled := Option in [1..7, 10..12, 17, 18];
  Minimum := 0;
  Maximum := 1;
  if Scaled then
  begin
    Minimum := 50;
    Maximum := 200;
    // Compatibility: pirate aggression accepts up to 500, despite the DLL
    // header documenting 200. Validate the implementation's actual range.
    if Option in [1..4] then
      Maximum := 500;
  end
  else
    case Option of
      8: Maximum := 255;
      9: Maximum := 100;
      13..15: Maximum := 10;
      16, 19: Maximum := 50;
      35: Maximum := 2;
    end;
  OldValue := Field^;
  if Value <> -1 then
  begin
    if (Value < Minimum) or (Value > Maximum) then
      UtilityError('Advanced adjustment out of range');
    if Scaled then
      Field^ := UtilityBankRound(Double(0.16) * Value) - 8
    else
      Field^ := Value;
  end;
  if Scaled then
    OldValue := 50 + UtilityBankRound(OldValue * 6.25);
  av[0].SetInt(OldValue);
end;

procedure SF_UFP_HullExtraSettings(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Hull: THull;
  Setting: Integer;
  Value, Previous: PtrUInt;
  Query: Boolean;
begin
  Obj := UtilityObject(av[1].GetDword);
  if (Obj is TShip) and (Ord(TShip(Obj).TypeId) < 6) then
  begin
    if (TShip(Obj).Inventory = nil) or (TShip(Obj).Inventory.Count = 0) then
      UtilityError('Ship has no hull inventory entry');
    // DLL uses item zero, not the equipped Hull field.
    Obj := UtilityObject(PtrUInt(TShip(Obj).Inventory[0]));
  end;
  if not (Obj is THull) then
    UtilityError('Expected a hull or a non-station ship');
  Hull := THull(Obj);
  Setting := av[2].GetInt;
  Value := av[3].GetDword;
  Query := Cardinal(Value) = $FFFFFFFF;
  Previous := 0;
  case Setting of
    0: Previous := Cardinal(Hull.Energy);
    1: Previous := Cardinal(Hull.EnergyMax);
    2: Previous := Ord(Hull.ImpulseShieldsEnabled);
    3: Previous := Ord(Hull.InterceptorsEnabled);
    4: Previous := Ord(Hull.InterceptorTargetingStrategy);
    5: Previous := Hull.InterceptorPassCountOverride;
    6: Previous := PtrUInt(Hull.InterceptorTarget);
  else
    UtilityError('Unknown hull setting');
  end;
  av[0].SetDword(Previous);
  if Query then
    Exit;
  case Setting of
    0: Hull.Energy := Integer(Value);
    1: Hull.EnergyMax := Integer(Value);
    2, 3:
    begin
      if Value > 1 then
        UtilityError('Hull boolean out of range');
      if Setting = 2 then
        Hull.ImpulseShieldsEnabled := Value <> 0
      else
        Hull.InterceptorsEnabled := Value <> 0;
    end;
    4:
    begin
      if Value > 6 then
        UtilityError('Interceptor tactic out of range');
      Hull.InterceptorTargetingStrategy := TInterceptorTargetingStrategy(Value);
    end;
    5:
    begin
      if Value > 255 then
        UtilityError('Interceptor flight time out of range');
      Hull.InterceptorPassCountOverride := Value;
    end;
    6:
    begin
      if Value <> 0 then
        if not (UtilityObject(Value) is TShip) or (Ord(TShip(Value).TypeId) >= 6) then
          UtilityError('Interceptor target must be a non-station ship');
      Hull.InterceptorTarget := Pointer(Value);
    end;
  end;
end;

procedure SF_UFP_SetRangersCapital(av: array of TVarEC; code: TCodeEC);
var
  Value, Mode: Integer;
begin
  UtilityRequireGalaxy;
  Value := av[1].GetInt;
  Mode := av[2].GetInt;
  av[0].SetInt(Galaxy.AverageRangerCapital);
  if Value >= 0 then
  begin
    UtilityCapitalTarget := Value;
    Galaxy.AverageRangerCapital := Value;
  end;
  // Compatibility: worker-status query (-2) first applies a nonnegative value.
  // A negative value with mode 1 reuses the remembered target (initially zero).
  case Mode of
    -2: av[0].SetInt(Ord(UtilityCapitalOverrideEnabled));
    -1: UtilityCapitalOverrideEnabled := False;
    1:
    begin
      UtilityCapitalOverrideEnabled := True;
      Galaxy.AverageRangerCapital := UtilityCapitalTarget;
    end;
  end;
end;

function UtilityDllText(const Text: WideString): WideString;
var
  Terminator: Integer;
begin
  // DLL strings are wchar_t pointers. Callers that distinguish a null pointer
  // from a non-null empty C string must inspect the original WideString first.
  Terminator := Pos(#0, Text);
  if Terminator = 0 then
    Result := Text
  else
    Result := Copy(Text, 1, Terminator - 1);
end;

procedure SF_UFP_ParsCountFromString(av: array of TVarEC; code: TCodeEC);
var
  Text, Separator: WideString;
  Start, Found, Count: Integer;
begin
  Text := av[1].GetString;
  if Text = '' then
  begin
    av[0].SetInt(0);
    Exit;
  end;
  Text := UtilityDllText(Text);
  Separator := UtilityDllText(av[2].GetString);
  // The DLL loops forever for an empty separator; expose an error instead.
  if Separator = '' then
    UtilityError('Empty separator in ParsCountFromString');
  Count := 1;
  Start := 1;
  repeat
    Found := PosEx(Separator, Text, Start);
    if Found = 0 then
      Break;
    Inc(Count);
    Start := Found + Length(Separator);
  until False;
  av[0].SetInt(Count);
end;

procedure SF_UFP_GetParFromString(av: array of TVarEC; code: TCodeEC);
begin
  if av[1].GetString = '' then
    av[0].SetString('')
  else
    av[0]
        .SetString(
            UtilityPart(
                UtilityDllText(av[1].GetString),
                UtilityDllText(av[2].GetString),
                av[3].GetInt,
                av[4].GetInt
            ));
end;

procedure SF_UFP_SetParFromString(av: array of TVarEC; code: TCodeEC);
var
  Text, Separator, Value: WideString;
  Index, Count, Start, Finish: Integer;
  NullSource: Boolean;
begin
  Text := av[1].GetString;
  NullSource := Text = '';
  Text := UtilityDllText(Text);
  Separator := UtilityDllText(av[2].GetString);
  Index := av[3].GetInt;
  Value := UtilityDllText(av[4].GetString);
  // Compatibility: DLL 1000A204 rejects abs(INT_MIN), which stays negative.
  // Its next guard compares the field index to character length and appends
  // without a separator. Missing fields otherwise replace the last field.
  if NullSource then
    Text := Value
  else if Index = Low(Integer) then
    Text := ''
  else if (Text <> '') and ((Index < 0) or (Index > Length(Text) - 1)) then
    Text := Text + Value
  else if Separator = '' then
  begin
    // Non-null empty input differs from a null Delphi string: substr(1)
    // throws, while index -1 wraps its second substring position back to zero.
    if (Text = '') and (Index <> -1) then
      UtilityError('Character index out of range');
    Text := Copy(Text, 1, Index) + Value + Copy(Text, Index + 2, MaxInt)
  end
  else
  begin
    Count := Abs(Index);
    Start := 1;
    Finish := Pos(Separator, Text);
    if Finish = 0 then
    begin
      // Compatibility: one-field input is prepended/appended, not replaced.
      if Count = 0 then
        Text := Value + Separator + Text
      else
        Text := Text + Separator + Value;
    end
    else
    begin
      while Count <> 0 do
      begin
        Start := Finish + Length(Separator);
        Finish := PosEx(Separator, Text, Start);
        if Finish = 0 then
          Break;
        Dec(Count);
      end;
      if Finish = 0 then
        Finish := Length(Text) + 1;
      Text := Copy(Text, 1, Start - 1) + Value + Copy(Text, Finish, MaxInt);
    end;
  end;
  av[0].SetString(Text);
end;

procedure SF_UFP_TrimNumbers(av: array of TVarEC; code: TCodeEC);
var
  Text: WideString;
  I: Integer;
begin
  Text := UtilityDllText(av[1].GetString);
  for I := Length(Text) downto 1 do
    if Text[I] in ['0'..'9'] then
      Delete(Text, I, 1);
  av[0].SetString(Text);
end;

procedure SF_UFP_PortionInDiapason(av: array of TVarEC; code: TCodeEC);
begin
  av[0]
      .SetFloat(
          UtilityPortion(
              av[1].GetFloat,
              av[2].GetFloat,
              av[3].GetFloat,
              av[4].GetFloat,
              av[5].GetFloat
          ));
end;

procedure SF_UFP_RoundTo(av: array of TVarEC; code: TCodeEC);
var
  A, Step, Quotient, Shift: Double;
  Mode: Integer;
begin
  A := av[1].GetFloat;
  Step := av[2].GetFloat;
  Mode := av[3].GetInt;
  if IsNan(A) or IsInfinite(A) or IsNan(Step) or IsInfinite(Step) or (Step = 0) then
    UtilityError('RoundTo requires finite arguments and a nonzero step');
  Quotient := A / Step;
  if Mode = 0 then
    A := UtilityFloor(Quotient + 0.5)
  else if Mode < 0 then
    A := UtilityFloor(Quotient)
  else if Mode = 1 then
    A := UtilityCeil(Quotient)
  else if Mode = 2 then
    A := UtilityBankRound(Quotient)
  else
  begin
    if Quotient >= 0 then
      Shift := 0.5
    else
      Shift := -0.5;
    if Abs(Abs(Quotient) - Abs(UtilityTruncFloat(Quotient)) - 0.5) < 2.2204460492503131e-16 then
      A := 2 * UtilityFloor(Quotient * 0.5) + 1
    else
      A := UtilityTruncFloat(Quotient + Shift);
    // Both DLL tie-breaking helpers return int32; only floor/ceil modes
    // operate across the entire floating-point range.
    A := UtilityInt(A);
  end;
  av[0].SetFloat(Step * A);
end;

procedure SF_UFP_Power(av: array of TVarEC; code: TCodeEC);
var
  Base, Exponent, Value: Double;
  Bits: QWord;
begin
  Base := av[1].GetFloat;
  Exponent := av[2].GetFloat;
  // The shared Pascal Math unit retains PC24; SDL uses C double-precision pow.
  Value := SDL_pow(Base, Exponent);
  if IsNan(Value) then
  begin
    // MSVC prefers the base NaN, then the exponent, and creates a negative
    // quiet NaN for domain errors. FloatToString exposes these signs, which
    // differ between C libraries. Keep pow's non-NaN identities such as NaN^0.
    if IsNan(Base) then
      Value := Base
    else if IsNan(Exponent) then
      Value := Exponent
    else
    begin
      Bits := QWord($FFF8000000000000);
      Move(Bits, Value, SizeOf(Value));
    end;
  end;
  av[0].SetFloat(Value);
end;

function UtilityDistance(X1, Y1, X2, Y2: Integer): Integer;
var
  DX, DY, SquareDistance: Integer;
begin
  DX := X1 - X2;
  DY := Y1 - Y2;
  // Preserve the DLL's 32-bit intermediate arithmetic before sqrt/round.
  SquareDistance := DX * DX + DY * DY;
  if SquareDistance < 0 then
    UtilityError('Squared distance overflows a signed 32-bit integer');
  Result := UtilityBankRound(Sqrt(Double(SquareDistance)));
end;

procedure SF_UFP_DistCoords(av: array of TVarEC; code: TCodeEC);
begin
  av[0].SetInt(UtilityDistance(av[1].GetInt, av[2].GetInt, av[3].GetInt, av[4].GetInt));
end;

procedure SF_UFP_CustomArtCostCalc(av: array of TVarEC; code: TCodeEC);
var
  Cost: Integer;
  Tech, Difficulty: Double;
begin
  UtilityRequireGalaxy;
  Cost := av[1].GetInt;
  Cost := UtilityRandom(Cost - 500, Cost + 500, Galaxy);
  Tech := 0.5 * Max(0, Integer(Galaxy.TechLevel) - 4) + 1;
  Difficulty := Double(0.85) + Double(0.15) * Galaxy.DifficultyLevels[1];
  Cost := UtilityBankRound(Tech * Difficulty * Cost);
  av[0].SetInt(Max(1, Cost + UtilityRandom(-50, 100, Galaxy)));
end;

procedure SF_UFP_CustomArtSizeCalc(av: array of TVarEC; code: TCodeEC);
var
  Size: Integer;
begin
  UtilityRequireGalaxy;
  Size := UtilityBankRound(Double(0.01) * ((Galaxy.DifficultyLevels[4] + 1) * 50) * av[1].GetInt);
  av[0].SetInt(Max(1, Size + UtilityRandom(0, 7, Galaxy)));
end;

procedure SF_UFP_RndObject(av: array of TVarEC; code: TCodeEC);
begin
  av[0].SetInt(UtilityRandom(av[1].GetInt, av[2].GetInt, TObject(av[3].GetDword)));
end;

procedure SF_UFP_RndFloat(av: array of TVarEC; code: TCodeEC);
var
  Draw, Scale: Single;
begin
  // Compatibility: this is a scaled integer draw, not the game's float RNG.
  Draw :=
      UtilityRandom(
          UtilityInt(10000000.0 * av[1].GetFloat),
          UtilityInt(10000000.0 * av[2].GetFloat),
          TObject(av[3].GetDword)
      );
  Scale := 0.0000001;
  Draw := Scale * Draw;
  av[0].SetFloat(Draw);
end;

procedure SF_UFP_GetPlanetOrbitProbe(av: array of TVarEC; code: TCodeEC);
var
  Player: TPlayer;
  Planet: TPlanet;
  Probe: TSatellite;
  Orbit, OrbitCount, I: Integer;
begin
  Planet := UtilityPlanet(av[1]);
  Orbit := av[2].GetInt;
  // Compatibility: DLL 1000BB1D sign-extends its plain-char field at +$138.
  // Keep that behavior even though the game's actual orbit count is a Byte.
  OrbitCount := ShortInt(Planet.ProbeOrbitCount);
  av[0].SetDword(0);
  if Orbit < 0 then
  begin
    av[0].SetDword(Cardinal(OrbitCount));
    Exit;
  end;
  if Orbit >= OrbitCount then
    Exit;
  Player := UtilityPlayer;
  for I := 0 to Player.Satellites.Count - 1 do
  begin
    Probe := Player.Satellites[I];
    if (Probe.TargetPlanet = Planet) and (Probe.TrajectoryIndex = Orbit) then
    begin
      if av[3].GetInt <> 0 then
      begin
        // Compatibility: detach without freeing, moving into cargo, or
        // refreshing the player's property notification. The caller owns it.
        Probe.TargetPlanet := nil;
        Player.Satellites.Delete(I);
      end;
      av[0].SetDword(PtrUInt(Probe));
      Exit;
    end;
  end;
end;

function UtilityListContains(List: TList; Obj: Pointer): Boolean;
begin
  Result := (List <> nil) and (List.IndexOf(Obj) >= 0);
end;

function UtilityShipOwnsItem(Ship: TShip; Item: TItem): Boolean;
begin
  Result :=
      UtilityListContains(Ship.Inventory, Item)
          or UtilityListContains(Ship.Artefacts, Item)
          or UtilityListContains(Ship.GuaranteedDeathDropItems, Item);
  if not Result and (Ship is TRuins) then
    Result := UtilityListContains(TRuins(Ship).EquipmentShop, Item);
end;

function UtilityItemHasOwner(Item: TItem): Boolean;
var
  Player: TPlayer;
  Star: TStar;
  Planet: TPlanet;
  I, J: Integer;
begin
  Player := UtilityPlayer;
  Result := True;
  if UtilityShipOwnsItem(Player, Item) or UtilityListContains(Player.Satellites, Item) then
    Exit;
  // The vault owns wrappers, not item pointers. A non-removing vault lookup
  // exposes the item while the wrapper still owns and will free it.
  if Galaxy.StoredItems <> nil then
    for I := 0 to Galaxy.StoredItems.Count - 1 do
      if TStoredItem(Galaxy.StoredItems[I]).Item = Item then
        Exit;
  for I := 0 to Player.StorageEntries.Count - 1 do
    if PStorageEntry(Player.StorageEntries[I]).Item = Item then
      Exit;
  for I := 0 to Galaxy.Stars.Count - 1 do
  begin
    Star := Galaxy.Stars[I];
    if UtilityListContains(Star.Items, Item) then
      Exit;
    for J := 0 to Star.Ships.Count - 1 do
      if UtilityShipOwnsItem(TShip(Star.Ships[J]), Item) then
        Exit;
  end;
  for I := 0 to Galaxy.ShipsInTransit.Count - 1 do
    if UtilityShipOwnsItem(TShip(Galaxy.ShipsInTransit[I]), Item) then
      Exit;
  if Galaxy.LoadedShips <> nil then
    for I := 0 to Galaxy.LoadedShips.Count - 1 do
      if UtilityShipOwnsItem(TShip(Galaxy.LoadedShips[I]), Item) then
        Exit;
  for I := 0 to Galaxy.Planets.Count - 1 do
  begin
    Planet := Galaxy.Planets[I];
    if UtilityListContains(Planet.EquipmentShop, Item) then
      Exit;
    // Parked defense ships can belong only to the planet's warrior list.
    if Planet.Warriors <> nil then
      for J := 0 to Planet.Warriors.Count - 1 do
        if UtilityShipOwnsItem(TShip(Planet.Warriors[J]), Item) then
          Exit;
    if Planet.SurfaceLootEntries <> nil then
      for J := 0 to Planet.SurfaceLootEntries.Count - 1 do
        if PPlanetSurfaceLootEntry(Planet.SurfaceLootEntries[J]).Item = Item then
          Exit;
  end;
  Result := False;
end;

procedure SF_UFP_SetPlanetOrbitProbe(av: array of TVarEC; code: TCodeEC);
var
  Player: TPlayer;
  Planet: TPlanet;
  Probe, Existing: TSatellite;
  Orbit, I: Integer;
begin
  Planet := UtilityPlanet(av[1]);
  Orbit := av[2].GetInt;
  Probe := TSatellite(UtilityObject(av[3].GetDword));
  if not (Probe is TSatellite) then
    UtilityError('Expected orbit probe');
  // The DLL accepts negatives, but the planet UI indexes its trajectory array
  // with this field. Reject them before they can corrupt game state.
  if Orbit < 0 then
    UtilityError('Negative probe orbit');
  // Same signed-char upper bound as GetPlanetOrbitProbe (DLL 1000BBB8).
  if Orbit >= ShortInt(Planet.ProbeOrbitCount) then
    Exit;
  Player := UtilityPlayer;
  for I := 0 to Player.Satellites.Count - 1 do
  begin
    Existing := Player.Satellites[I];
    if (Existing.TargetPlanet = Planet) and (Existing.TrajectoryIndex = Orbit) then
      UtilityError('Another probe occupies this planet orbit');
  end;
  // Respect the DLL's detached-probe precondition. Adding the same object to
  // two owning lists would otherwise double-free it on sale or game teardown.
  if (Probe.TargetPlanet <> nil) or UtilityItemHasOwner(Probe) then
    UtilityError('Detach the probe from its owner before assigning an orbit');
  Probe.TrajectoryIndex := Orbit;
  Probe.TargetPlanet := Planet;
  Player.Satellites.Add(Probe);
end;

function UtilityLootHidden(Planet: TPlanet; Entry: PPlanetSurfaceLootEntry): Boolean;
begin
  case Ord(Entry.TerrainKind) of
    0: Result := Entry.SurfaceTileIndex > Planet.WaterExplored;
    1: Result := Entry.SurfaceTileIndex > Planet.LandExplored;
  else
    Result := Entry.SurfaceTileIndex > Planet.HillExplored;
  end;
end;

procedure SF_UFP_PlanetItemsHiddency(av: array of TVarEC; code: TCodeEC);
var
  Planet: TPlanet;
  Entry: PPlanetSurfaceLootEntry;
  Index, Value, I, Count, Limit: Integer;
  Request: WideString;
begin
  Planet := UtilityPlanet(av[1]);
  av[0].SetInt(0);
  if Planet.SurfaceLootEntries = nil then
    Exit;
  Index := av[2].GetInt;
  if Index < 0 then
  begin
    Count := 0;
    for I := 0 to Planet.SurfaceLootEntries.Count - 1 do
      if UtilityLootHidden(Planet, Planet.SurfaceLootEntries[I]) then
        Inc(Count);
    av[0].SetInt(Count);
    Exit;
  end;
  if Index >= Planet.SurfaceLootEntries.Count then
    UtilityError('Planet item index out of range');
  Entry := Planet.SurfaceLootEntries[Index];
  Request := UtilityDllText(av[3].GetString);
  Value := av[4].GetInt;
  // Compatibility: hiddenness depends on the exploration threshold only;
  // the separate Unavailable flag is deliberately neither checked nor updated.
  if Request = 'IsHidden' then
    av[0].SetInt(Ord(UtilityLootHidden(Planet, Entry)))
  else if Request = 'TerrainType' then
  begin
    av[0].SetInt(Ord(Entry.TerrainKind));
    if Value >= 0 then
      Entry.TerrainKind := TPlanetTerrainKind(Min(Value, 2));
  end
  else if Request = 'TerrainNeeded' then
  begin
    av[0].SetInt(Entry.SurfaceTileIndex);
    case Ord(Entry.TerrainKind) of
      0: Limit := Planet.WaterTiles;
      1: Limit := Planet.LandTiles;
    else
      Limit := Planet.HillTiles;
    end;
    if Value >= 0 then
      Entry.SurfaceTileIndex := Min(Value, Limit);
  end
  else if Request = 'GridPosX' then
  begin
    av[0].SetInt(Entry.GridX);
    if Value >= 0 then
      Entry.GridX := Min(Value, 13);
  end
  else if Request = 'GridPosY' then
  begin
    av[0].SetInt(Entry.GridY);
    if Value >= 0 then
      Entry.GridY := Min(Value, 6);
  end
  else
    UtilityError('Unknown planet item request');
end;

function UtilityShipType(Ship: TShip): WideString;
const
  Names: array[0..12] of WideString = (
      'Kling',
      'Ranger',
      'Transport',
      'Pirate',
      'Warrior',
      'Tranclucator',
      'RC',
      'PB',
      'WB',
      'SB',
      'BK',
      'MC',
      'CB'
  );
var
  Binding: TScriptShip;
begin
  if Ship.TypeNameOverrideKey <> '' then
    Exit(Ship.TypeNameOverrideKey);
  Result := '';
  if Ord(Ship.TypeId) <= High(Names) then
    Result := Names[Ord(Ship.TypeId)];
  case Ord(Ship.TypeId) of
    1:
      if Ship <> UtilityPlayer then
      begin
        Binding := UtilityBinding(Ship);
        if (Binding <> nil)
            and (Binding.Script.ScriptFileName = 'Script.PC_fem_rangers')
            and (Binding.GetGroup.Name = 'GroupFem') then
          Result := 'FemRanger';
      end;
    2:
      case Ord(TTransport(Ship).TransportType) of
        0: Result := 'Transport';
        1: Result := 'Liner';
        2: Result := 'Diplomat';
      else
        // DLL 1000B48F falls through to the next outer switch arm.
        Result := 'Pirate';
      end;
    4:
      case Ord(TWarrior(Ship).WarriorType) of
        0: Result := 'Warrior';
        1: Result := 'WarriorBig';
      else
        // The corresponding warrior fallthrough is at DLL 1000B4D0.
        Result := 'Tranclucator';
      end;
    8:
      if Ship = UtilityPlayer.RuinsProxy then
        Result := 'PlayerBridge';
    13: UtilityError('Unspecified custom station type');
  end;
end;

function UtilityInNormalSpace(Ship: TShip): Boolean;
var
  Player: TPlayer;
begin
  Player := UtilityPlayer;
  if (Ship = Player) and (Player.RuinsMode <> 0) then
    Result :=
        (Player.RuinsSavedPlanet = nil)
            and (Player.RuinsSavedDockedTo = nil)
            and not Ship.InHyperspace
  else
    Result := (Ship.CurrentPlanet = nil) and (Ship.DockedTo = nil) and not Ship.InHyperspace;
end;

procedure UtilitySortNearby(Lo, Hi: Integer);
var
  I, J: Integer;
  Temp: TUtilityNearbyShip;
begin
  if Hi <= Lo then
    Exit;
  I := Lo;
  J := Hi + 1;
  repeat
    Inc(I);
    while UtilityNearbyShips[I].Distance < UtilityNearbyShips[Lo].Distance do
    begin
      if I = Hi then
        Break;
      Inc(I);
    end;
    Dec(J);
    while UtilityNearbyShips[J].Distance > UtilityNearbyShips[Lo].Distance do
    begin
      if J = Lo then
        Break;
      Dec(J);
    end;
    if I >= J then
      Break;
    Temp := UtilityNearbyShips[I];
    UtilityNearbyShips[I] := UtilityNearbyShips[J];
    UtilityNearbyShips[J] := Temp;
  until False;
  Temp := UtilityNearbyShips[Lo];
  UtilityNearbyShips[Lo] := UtilityNearbyShips[J];
  UtilityNearbyShips[J] := Temp;
  UtilitySortNearby(Lo, J - 1);
  UtilitySortNearby(J + 1, Hi);
end;

procedure SF_UFP_ShipNearbyShips(av: array of TVarEC; code: TCodeEC);
var
  Ship, Candidate: TShip;
  I, N, Index, Types: Integer;
  TypeFilter, FactionFilter, Faction: WideString;
begin
  av[0].SetDword(0);
  Index := av[2].GetInt;
  if Index < -1 then
    Exit;
  Ship := UtilityShip(av[1]);
  if Ship.InHyperspace or (Ship.CurrentStar = nil) then
    Exit;
  if av[3].GetInt = 0 then
  begin
    Types := av[4].GetInt;
    case Types of
      0: Types := 16383;
      -1: Types := 63;
      -2: Types := 16320;
    end;
    TypeFilter := UtilityDllText(av[5].GetString);
    FactionFilter := UtilityDllText(av[6].GetString);
    SetLength(UtilityNearbyShips, 1);
    UtilityNearbyShips[0].Ship := Ship;
    UtilityNearbyShips[0].ShipId := Ship.Id;
    UtilityNearbyShips[0].Distance := 0;
    for I := 0 to Ship.CurrentStar.Ships.Count - 1 do
    begin
      Candidate := Ship.CurrentStar.Ships[I];
      if (Candidate = Ship) or not UtilityInNormalSpace(Candidate) then
        Continue;
      if (Types and (1 shl Ord(Candidate.TypeId))) = 0 then
        Continue;
      if (TypeFilter <> '')
          and (Pos(',' + UtilityShipType(Candidate) + ',', ',' + TypeFilter + ',') = 0) then
        Continue;
      if FactionFilter <> '' then
      begin
        Faction := '';
        if Candidate.ScriptShip <> nil then
          Faction := UtilityDllText(TScriptShip(Candidate.ScriptShip).StateText);
        if (Faction = '') or (Faction = 'SubFactionFixedStanding') then
          Faction := '!';
        if Pos(',' + Faction + ',', ',' + FactionFilter + ',') = 0 then
          Continue;
      end;
      N := Length(UtilityNearbyShips);
      SetLength(UtilityNearbyShips, N + 1);
      UtilityNearbyShips[N].Ship := Candidate;
      UtilityNearbyShips[N].ShipId := Candidate.Id;
      // The DLL truncates each coordinate before computing rounded distance.
      UtilityNearbyShips[N].Distance :=
          UtilityDistance(
              UtilityInt(Ship.Position.X),
              UtilityInt(Ship.Position.Y),
              UtilityInt(Candidate.Position.X),
              UtilityInt(Candidate.Position.Y)
          );
    end;
    // Compatibility: retain its unstable partition sort, including moving the
    // source away from index zero when another ship has rounded distance zero.
    UtilitySortNearby(0, High(UtilityNearbyShips));
  end;
  // Compatibility: a cached request ignores the new filters/source and retains
  // object references until the next fresh query. Empty-cache count is -1.
  if Index = -1 then
    av[0].SetDword(Cardinal(Length(UtilityNearbyShips) - 1))
  else if Index < Length(UtilityNearbyShips) then
  begin
    Candidate := UtilityNearbyShips[Index].Ship;
    // Retain cache positions/count, but never hand out a freed/reused address.
    if IsLiveGameObject(Candidate)
        and (Candidate is TShip)
        and (Candidate.Id = UtilityNearbyShips[Index].ShipId) then
      av[0].SetDword(PtrUInt(Candidate));
  end;
end;

procedure SF_UFP_ShipPrevStar(av: array of TVarEC; code: TCodeEC);
begin
  av[0].SetDword(PtrUInt(UtilityShip(av[1]).TransitOriginStar));
end;

procedure SF_UFP_SetShipExpByType(av: array of TVarEC; code: TCodeEC);
var
  Player: TPlayer;
  Ship: TShip;
  Value: Integer;
begin
  Ship := UtilityShip(av[1]);
  Value := av[2].GetInt;
  Player := UtilityPlayer;
  if Ship = Player then
    case av[3].GetInt of
      1: Player.ExperienceByDominators := Value;
      2: Player.ExperienceByPirates := Value;
      3: Player.ExperienceByNormals := Value;
      4: Player.ExperienceByTraderCareer := Value;
    else
      Ship.TotalExperience := Value;
    end
  else
    Ship.TotalExperience := Value;
end;

procedure SF_UFP_ShipExchangeToShip(av: array of TVarEC; code: TCodeEC);
var
  A, B: TShip;
  Mode, I: Integer;
  Text: WideString;
  Flag: Boolean;
  procedure SwapPointer(var First; var Second);
  var
    Temp: Pointer;
  begin
    Temp := PPointer(@First)^;
    PPointer(@First)^ := PPointer(@Second)^;
    PPointer(@Second)^ := Temp;
  end;
begin
  A := UtilityShip(av[1]);
  B := UtilityShip(av[2]);
  Mode := av[3].GetInt;
  // Compatibility: the original switch lacks breaks: 0 swaps all three sets,
  // 1 swaps bonuses AND graphics, and 2 swaps graphics only. OwnerShip links,
  // WeaponCount and derived stats remain untouched, just as in the DLL.
  if Mode = 0 then
  begin
    SwapPointer(A.Inventory, B.Inventory);
    SwapPointer(A.EquipmentCache.Hull, B.EquipmentCache.Hull);
    SwapPointer(A.EquipmentCache.FuelTanks, B.EquipmentCache.FuelTanks);
    SwapPointer(A.EquipmentCache.Engine, B.EquipmentCache.Engine);
    SwapPointer(A.EquipmentCache.Radar, B.EquipmentCache.Radar);
    SwapPointer(A.EquipmentCache.Scanner, B.EquipmentCache.Scanner);
    SwapPointer(A.EquipmentCache.RepairRobot, B.EquipmentCache.RepairRobot);
    SwapPointer(A.EquipmentCache.CargoHook, B.EquipmentCache.CargoHook);
    SwapPointer(A.EquipmentCache.DefGenerator, B.EquipmentCache.DefGenerator);
    for I := Low(A.Weapons) to High(A.Weapons) do
      SwapPointer(A.Weapons[I], B.Weapons[I]);
    SwapPointer(A.Artefacts, B.Artefacts);
  end;
  if Mode in [0, 1] then
    SwapPointer(A.StatBonuses, B.StatBonuses);
  if Mode in [0..2] then
  begin
    SwapPointer(A.Graphic, B.Graphic);
    Text := A.GraphName;
    A.GraphName := B.GraphName;
    B.GraphName := Text;
    // DLL 1000CF91..1000CFA9 swaps +$49C (script appearance), not the
    // Dominator camouflage flag at +$461 despite both being called chameleon.
    Flag := A.ScriptChameleon;
    A.ScriptChameleon := B.ScriptChameleon;
    B.ScriptChameleon := Flag;
  end;
end;

procedure SF_UFP_GetShipScriptName(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  Binding: TScriptShip;
  Text: WideString;
begin
  av[0].SetString('');
  Ship := UtilityShip(av[1]);
  if Ship = UtilityPlayer then
    Exit;
  Binding := UtilityBinding(Ship);
  if Binding = nil then
    Exit;
  if (av[2].GetInt in [2, 4])
      and (not IsLiveGameObject(Binding.State) or not (Binding.State is TScriptState)) then
    UtilityError('Ship script binding has no valid state');
  Text := UtilityDllText(Copy(Binding.Script.ScriptFileName, 8, MaxInt));
  case av[2].GetInt of
    1: Text := UtilityDllText(Binding.GetGroup.Name);
    2: Text := UtilityDllText(Binding.State.Name);
    3: Text := Text + '.' + UtilityDllText(Binding.GetGroup.Name);
    4:
      Text :=
          Text
              + '.'
              + UtilityDllText(Binding.GetGroup.Name)
              + '.'
              + UtilityDllText(Binding.State.Name);
  end;
  av[0].SetString(Text);
end;

procedure SF_UFP_ShipJoinToScript(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  Script, OldScript, Candidate: TScript;
  Group: TScriptGroup;
  State: TScriptState;
  Binding: TScriptShip;
  Path, Name: WideString;
  I, GroupIndex, OldIndex: Integer;
begin
  Ship := UtilityShip(av[1]);
  if Ship = UtilityPlayer then
    Exit;
  Path := UtilityDllText(av[2].GetString);
  Name := 'Script.' + UtilityPart(Path, '.', 0, 0);
  Script := nil;
  for I := 0 to Galaxy.Scripts.Count - 1 do
  begin
    Candidate := Galaxy.Scripts[I];
    if UtilityDllText(Candidate.ScriptFileName) = Name then
    begin
      Script := Candidate;
      Break;
    end;
  end;
  if Script = nil then
  begin
    AppendDebugLogLine('UtilityFunctions: ShipJoinToScript missing script: ' + UTF8Encode(Path));
    Exit;
  end;
  Name := UtilityPart(Path, '.', 1, 0);
  GroupIndex := -1;
  for I := 0 to Script.Groups.Count - 1 do
    if UtilityDllText(TScriptGroup(Script.Groups[I]).Name) = Name then
    begin
      GroupIndex := I;
      Break;
    end;
  if GroupIndex < 0 then
  begin
    AppendDebugLogLine('UtilityFunctions: ShipJoinToScript missing group: ' + UTF8Encode(Path));
    Exit;
  end;
  Group := Script.Groups[GroupIndex];
  Name := UtilityPart(Path, '.', 2, 0);
  State := nil;
  if Name <> '' then
    for I := 0 to Script.States.Count - 1 do
      if UtilityDllText(TScriptState(Script.States[I]).Name) = Name then
      begin
        State := Script.States[I];
        Break;
      end;
  if State = nil then
  begin
    if (Group.InitialStateIndex < 0) or (Group.InitialStateIndex >= Script.States.Count) then
      UtilityError('Script group has no valid initial state');
    State := Script.States[Group.InitialStateIndex];
    if Name <> '' then
      AppendDebugLogLine(
          'UtilityFunctions: ShipJoinToScript using default state: ' + UTF8Encode(Path)
      );
  end;
  Binding := UtilityBinding(Ship);
  OldScript := nil;
  if Binding <> nil then
  begin
    OldScript := Binding.Script;
    if OldScript <> Script then
    begin
      OldIndex := OldScript.Ships.IndexOf(Binding);
      if OldIndex >= 0 then
        OldScript.Ships.Delete(OldIndex)
      else if OldScript.Ships.Count <> 0 then
      begin
        AppendDebugLogLine(
            'UtilityFunctions: ShipJoinToScript missing old binding: ' + UTF8Encode(Path)
        );
        Exit;
      end;
    end
    else if (Binding.GroupIndex = GroupIndex) and (Binding.State = State) then
      Exit;
    // Compatibility bug: the DLL looks up the old index in the NEW script's
    // groups. Equal numeric indices across different scripts keep data/faction.
    // Comparing indices reproduces that behavior without an out-of-bounds read.
    if GroupIndex <> Binding.GroupIndex then
    begin
      FillChar(Binding.Data, SizeOf(Binding.Data), 0);
      Binding.StateText := '';
      Binding.EndState := False;
      Binding.Hit := False;
      Binding.HitPlayer := False;
    end;
  end
  else
  begin
    Binding := TScriptShip.Create;
    Binding.Ship := Ship;
  end;
  if OldScript <> Script then
    Script.Ships.Add(Binding);
  Binding.Script := Script;
  Binding.GroupIndex := GroupIndex;
  // Compatibility: do not call BindShip/ChangeState here. They run entry code,
  // reset orders and update other lists which the DLL deliberately leaves alone.
  Binding.State := State;
  Ship.ScriptShip := Binding;
end;

procedure SF_UFP_GetScriptNoKlingMarksFromStar(av: array of TVarEC; code: TCodeEC);
var
  Star: TStar;
  Script: TScript;
  Binding: TScriptStar;
  I, J, Marks: Integer;
  Text: WideString;
begin
  Star := TStar(UtilityObject(av[1].GetDword));
  if not (Star is TStar) then
    UtilityError('Expected star');
  Text := '';
  for I := 0 to Galaxy.Scripts.Count - 1 do
  begin
    Script := Galaxy.Scripts[I];
    for J := 0 to Script.Stars.Count - 1 do
    begin
      Binding := Script.Stars[J];
      if Binding.Star <> Star then
        Continue;
      Marks := Ord(Binding.RejectHostilePresence) + 2 * Ord(Binding.ProtectStar);
      if Marks = 0 then
        Continue;
      if Text <> '' then
        Text := Text + ',';
      Text := Text + UtilityDllText(Copy(Script.ScriptFileName, 8, MaxInt)) + '.' + IntToStr(Marks);
    end;
  end;
  av[0].SetString(Text);
end;

procedure SF_UFP_GetShipPath(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  Last: PSPathNode;
  Request: WideString;
  Value: Double;
begin
  Ship := UtilityShip(av[1]);
  Last := Ship.MovementPath.ActiveTail;
  Request := UtilityDllText(av[2].GetString);
  if Last <> nil then
  begin
    if Request = 'EndCoordX' then
      Value := Last.Position.X
    else if Request = 'EndCoordY' then
      Value := Last.Position.Y
    else
      Value := Last.Heading;
  end
  else
  begin
    if Request = 'EndCoordX' then
      Value := Ship.Position.X
    else if Request = 'EndCoordY' then
      Value := Ship.Position.Y
    else
      Value := Ship.MovementDirection;
  end;
  // DLL 1000E182 reads +$420, which the game stores in degrees despite the
  // upstream header's radians comment. Unknown requests also select the angle.
  av[0].SetFloat(Value);
end;

procedure SF_UFP_SetShipPath(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  Node: PSPathNode;
  Count: Integer;
  OffsetX, OffsetY, DeltaX, DeltaY, DX, DY, Angle: Single;
begin
  Ship := UtilityShip(av[1]);
  Count := Ship.MovementPath.NodeCount;
  if Count = 0 then
    Exit;
  Node := Ship.MovementPath.ActiveTail;
  if Node = nil then
    UtilityError('Ship movement path has no tail');
  OffsetX := av[2].GetInt - Node.Position.X;
  OffsetY := av[3].GetInt - Node.Position.Y;
  DeltaX := 0;
  DeltaY := 0;
  // The DLL divides by zero with one node, but the infinities only affect
  // offsets after the final write. Skip that unused division, retaining the
  // actual result: relocate the sole node and leave its heading unchanged.
  if Count > 1 then
  begin
    DeltaX := OffsetX / (Count - 1);
    DeltaY := OffsetY / (Count - 1);
  end;
  while Node <> nil do
  begin
    Node.Position.X := Node.Position.X + OffsetX;
    Node.Position.Y := Node.Position.Y + OffsetY;
    OffsetX := OffsetX - DeltaX;
    OffsetY := OffsetY - DeltaY;
    if Node.Next <> nil then
    begin
      DX := Node.Position.X - Node.Next.Position.X;
      DY := Node.Position.Y - Node.Next.Position.Y;
      if (DX = 0) and (DY = 0) then
        Angle := 0
      else
        // C atan2 preserves the signed-zero quadrants on every target.
        Angle := SDL_atan2(-DX, DY);
      Angle := Angle * 180.0;
      Node.Heading := Angle / Double(Pi);
    end;
    Node := Node.Prev;
  end;
  if (Count > 1) and (Ship.MovementPath.ActiveTail.Prev <> nil) then
    Ship.MovementPath.ActiveTail.Heading := Ship.MovementPath.ActiveTail.Prev.Heading;
end;

procedure SF_UFP_ShipVisibility(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  Ship := UtilityShip(av[1]);
  av[0].SetFloat(0);
  case av[2].GetInt of
    1: av[0].SetFloat(Ship.FilmAlphaStep);
    -2:
    begin
      Ship.FilmAlpha := av[3].GetFloat;
      // The renderer needs a nonzero delta to apply alpha during a film.
      Ship.FilmAlphaStep := 0.00001;
    end;
    -1: Ship.FilmAlphaStep := av[3].GetFloat;
  else
    av[0].SetFloat(Ship.FilmAlpha);
  end;
end;

procedure SF_UFP_ShipSubrace(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  Value: Integer;
begin
  Ship := UtilityShip(av[1]);
  if Ord(Ship.TypeId) <> 0 then
  begin
    av[0].SetInt(-1);
    Exit;
  end;
  av[0].SetInt(Ord(TKling(Ship).DominatorSeries));
  Value := av[2].GetInt;
  if Value >= 0 then
  begin
    // The DLL narrows to a byte. Preserve that narrowing for valid series, but
    // reject values that would index outside the game's three series tables.
    if Byte(Value) > Ord(High(TDominatorSeries)) then
      UtilityError('Unknown Dominator series');
    TKling(Ship).DominatorSeries := TDominatorSeries(Byte(Value));
  end;
end;

procedure SF_UFP_IdToHole(av: array of TVarEC; code: TCodeEC);
var
  Id, I: Integer;
  Hole: THole;
begin
  UtilityRequireGalaxy;
  Id := av[1].GetInt;
  if Id <= 0 then
    UtilityError('Invalid black hole ID');
  av[0].SetDword(0);
  for I := 0 to Galaxy.Holes.Count - 1 do
  begin
    Hole := Galaxy.Holes[I];
    if Hole.Id = Cardinal(Id) then
    begin
      av[0].SetDword(PtrUInt(Hole));
      Exit;
    end;
  end;
end;

procedure SF_UFP_HoleStatus(av: array of TVarEC; code: TCodeEC);
var
  Hole: THole;
  Value: Integer;
begin
  Hole := THole(UtilityObject(av[1].GetDword));
  if not (Hole is THole) then
    UtilityError('Expected black hole');
  Value := av[2].GetInt;
  if Value = -1 then
    av[0].SetInt(Hole.HoleType)
  else
  begin
    Hole.HoleType := Value;
    // Compatibility: upstream C++ has no return here, but the shipped DLL at
    // 1000E623 stores ECX through EAX and returns with the hole pointer in EAX.
    // Preserve that 32-bit int result instead of inventing a success boolean.
    av[0].SetInt(Integer(PtrUInt(Hole)));
  end;
end;

function UtilityPortionSingle(Cur, A, B, FromA, ToB: Single): Single;
var
  Fraction, Span: Single;
begin
  if A < B then
  begin
    if Cur <= A then
      Exit(FromA);
    if Cur >= B then
      Exit(ToB);
    Fraction := Cur - A;
    Span := B - A;
  end
  else
  begin
    if Cur >= A then
      Exit(FromA);
    if Cur <= B then
      Exit(ToB);
    Fraction := A - Cur;
    Span := A - B;
  end;
  Fraction := Fraction / Span;
  Span := ToB - FromA;
  Fraction := Fraction * Span;
  Result := Fraction + FromA;
end;

procedure SF_UFP_AdjustRuinsGoodsPricesToStorage(av: array of TVarEC; code: TCodeEC);
var
  Player: TPlayer;
  I, Kind, TargetPrice: Integer;
  Entry: PStorageEntry;
  Item: TItem;
  Station: TRuins;
  Factor, UnitCost, Product: Single;
begin
  Player := UtilityPlayer;
  for I := 0 to Player.StorageEntries.Count - 1 do
  begin
    Entry := Player.StorageEntries[I];
    Item := Entry.Item;
    Kind := Ord(Item.ItemType);
    if (Kind > 7) or (Item.Weight <= 0) then
      Continue;
    if not (Entry.LocationOwner is TRuins) then
      Continue;
    Station := TRuins(Entry.LocationOwner);
    Factor :=
        UtilityPortionSingle(
            Item.Weight,
            av[1].GetInt,
            av[2].GetInt,
            av[3].GetFloat,
            av[4].GetFloat
        );
    UnitCost := Item.Cost;
    UnitCost := UnitCost / Single(Item.Weight);
    Product := Factor * UtilityBankRound(UnitCost);
    TargetPrice := UtilityInt(Product);
    // C++ buy_price is offset +12: the station buys FROM the player. This is
    // BaseSalePrice, not the similarly named script GoodsBuyPrice (+8).
    if Station.ShopGoods[Kind].BaseSalePrice > TargetPrice then
      Station.ShopGoods[Kind].BaseSalePrice := TargetPrice;
  end;
end;

function UtilityTextPath(const LegacyPath: WideString): string;
var
  Relative: WideString;
  I: Integer;
begin
  Relative := UtilityDllText(LegacyPath);
  for I := 1 to Length(Relative) do
    if Relative[I] = '\' then
      Relative[I] := '/';
  // Mods pass Documents/SpaceRangersHD paths, including newgame.txt used by
  // the game itself. Honor --user-dir and the Android profile directory.
  if LowerCase(Copy(Relative, 1, 15)) = 'spacerangershd/' then
    Delete(Relative, 1, 15);
  Result := UTF8Encode(GetGameUserDirectory + Relative);
end;

function UtilityReadText(const Path: string; out Text: WideString): Boolean;
var
  Stream: TFileStream;
  Bytes: UTF8String;
begin
  Text := '';
  Result := False;
  try
    Stream := TFileStream.Create(Path, fmOpenRead or fmShareDenyNone);
    try
      SetLength(Bytes, Stream.Size);
      if Bytes <> '' then
        Stream.ReadBuffer(Bytes[1], Length(Bytes));
      // CHANGE: PORTABILITY - UTF-8 replaces the DLL's Windows C-locale text
      // streams. Keep its line/key behavior while allowing Unicode mod values.
      Text := UTF8Decode(Bytes);
      Text := WideStringReplace(Text, #13#10, #10, [rfReplaceAll]);
      Result := True;
    finally
      Stream.Free;
    end;
  except
    on E: EFOpenError do
      ; // Like wifstream: an absent/unreadable file is empty.
  end;
end;

function UtilityNextLine(
    const Text: WideString;
    var Position: Integer;
    out Line: WideString
): Boolean;
var
  Finish: Integer;
begin
  Result := Position <= Length(Text);
  if not Result then
    Exit;
  Finish := PosEx(#10, Text, Position);
  if Finish = 0 then
    Finish := Length(Text) + 1;
  Line := Copy(Text, Position, Finish - Position);
  Position := Finish + 1;
end;

procedure UtilityKeyValue(const Line: WideString; out Key, Value: WideString);
var
  Separator: Integer;
begin
  Separator := Pos('=', Line);
  if Separator = 0 then
  begin
    // Compatibility: C++ converts npos to -1, so a line without '=' has both
    // its key and value equal to the entire line. Whitespace is not trimmed.
    Key := Line;
    Value := Line;
  end
  else
  begin
    Key := Copy(Line, 1, Separator - 1);
    Value := Copy(Line, Separator + 1, MaxInt);
  end;
end;

procedure SF_UFP_GetParFromTxt(av: array of TVarEC; code: TCodeEC);
var
  Text, Line, Key, Value, Name: WideString;
  Position: Integer;
begin
  av[0].SetString('');
  Name := UtilityDllText(av[2].GetString);
  if not UtilityReadText(UtilityTextPath(av[1].GetString), Text) then
    Exit;
  Position := 1;
  while UtilityNextLine(Text, Position, Line) do
  begin
    UtilityKeyValue(Line, Key, Value);
    if Key = Name then
    begin
      av[0].SetString(UtilityDllText(Value));
      Exit;
    end;
  end;
end;

procedure SF_UFP_SetParFromTxt(av: array of TVarEC; code: TCodeEC);
var
  Text, OutputText, Line, Key, Value, Name, NewValue, OldValue: WideString;
  Path: string;
  Position: Integer;
  Found: Boolean;
  Stream: TFileStream;
  Bytes: UTF8String;
begin
  Path := UtilityTextPath(av[1].GetString);
  Name := UtilityDllText(av[2].GetString);
  NewValue := UtilityDllText(av[3].GetString);
  OldValue := '';
  OutputText := '';
  Found := False;
  UtilityReadText(Path, Text);
  Position := 1;
  while UtilityNextLine(Text, Position, Line) do
  begin
    UtilityKeyValue(Line, Key, Value);
    if Key = Name then
    begin
      OldValue := Value;
      Line := Name + '=' + NewValue;
      Found := True;
    end;
    // Compatibility: all duplicate keys are replaced, the LAST old value is
    // returned, leading empty lines vanish, and no final newline is appended.
    if OutputText <> '' then
      OutputText := OutputText + #10;
    OutputText := OutputText + Line;
  end;
  if not Found then
  begin
    if OutputText <> '' then
      OutputText := OutputText + #10;
    OutputText := OutputText + Name + '=' + NewValue;
  end;
  av[0].SetString(UtilityDllText(OldValue));
  try
    Stream := TFileStream.Create(Path, fmCreate);
    try
      Bytes := UTF8Encode(OutputText);
      if Bytes <> '' then
        Stream.WriteBuffer(Bytes[1], Length(Bytes));
    finally
      Stream.Free;
    end;
  except
    on E: EFCreateError do
      ; // The original silently leaves unwritable files alone.
  end;
end;

procedure SF_UFP_IsShiftCtrlPressed(av: array of TVarEC; code: TCodeEC);
begin
  av[0].SetInt(Ord((GameKeyState(VK_SHIFT) < 0) and (GameKeyState(VK_CONTROL) < 0)));
end;

procedure UtilityMultiplyDecimal(var Digits: AnsiString; Multiplier: Integer);
var
  I, Carry, Product: Integer;
begin
  Carry := 0;
  for I := Length(Digits) downto 1 do
  begin
    Product := (Ord(Digits[I]) - Ord('0')) * Multiplier + Carry;
    Digits[I] := AnsiChar(Ord('0') + Product mod 10);
    Carry := Product div 10;
  end;
  if Carry <> 0 then
    Digits := AnsiChar(Ord('0') + Carry) + Digits;
end;

function UtilityFixedFloat(Value: Double; Decimals: Integer): WideString;
var
  Bits, Mantissa: QWord;
  Exponent, FractionDigits, I, Keep: Integer;
  Negative, RoundUp: Boolean;
  Digits: AnsiString;
begin
  // std::format uses exact fixed decimal conversion and ties-to-even, with a
  // literal decimal point. FPC FloatToStrF caps its decimals at 18 and libc's
  // formatter/locale differs across targets. Convert the finite IEEE mantissa
  // as an integer instead; at most 1074 small decimal multiplications suffice.
  if Decimals > 10000 then
    UtilityError('FloatToString precision exceeds 10000');
  Decimals := Max(1, Decimals);
  Move(Value, Bits, SizeOf(Bits));
  Negative := (Bits shr 63) <> 0;
  Mantissa := Bits and QWord($000FFFFFFFFFFFFF);
  Exponent := (Bits shr 52) and $7FF;
  if Exponent = $7FF then
  begin
    if Mantissa = 0 then
      Result := 'inf'
    else
      Result := 'nan';
    if Negative then
      Result := '-' + Result;
    Exit;
  end;
  if Exponent = 0 then
    Exponent := -1074
  else
  begin
    Mantissa := Mantissa or QWord($0010000000000000);
    Exponent := Exponent - 1023 - 52;
  end;
  Digits := UIntToStr(Mantissa);
  FractionDigits := 0;
  if Mantissa <> 0 then
  begin
    if Exponent >= 0 then
      for I := 1 to Exponent do
        UtilityMultiplyDecimal(Digits, 2)
    else
    begin
      FractionDigits := -Exponent;
      for I := 1 to FractionDigits do
        UtilityMultiplyDecimal(Digits, 5);
    end;
  end;
  if Length(Digits) <= FractionDigits then
    Digits := StringOfChar('0', FractionDigits + 1 - Length(Digits)) + Digits;
  if Decimals < FractionDigits then
  begin
    Keep := Length(Digits) - (FractionDigits - Decimals);
    RoundUp := Digits[Keep + 1] > '5';
    if Digits[Keep + 1] = '5' then
    begin
      RoundUp := Odd(Ord(Digits[Keep]) - Ord('0'));
      for I := Keep + 2 to Length(Digits) do
        if Digits[I] <> '0' then
          RoundUp := True;
    end;
    SetLength(Digits, Keep);
    if RoundUp then
    begin
      I := Keep;
      while (I > 0) and (Digits[I] = '9') do
      begin
        Digits[I] := '0';
        Dec(I);
      end;
      if I = 0 then
        Digits := '1' + Digits
      else
        Digits[I] := AnsiChar(Ord(Digits[I]) + 1);
    end;
  end
  else
    Digits := Digits + StringOfChar('0', Decimals - FractionDigits);
  Insert('.', Digits, Length(Digits) - Decimals + 1);
  if Negative then
    Digits := '-' + Digits;
  Result := WideString(Digits);
end;

procedure SF_UFP_FloatToString(av: array of TVarEC; code: TCodeEC);
begin
  av[0].SetString(UtilityFixedFloat(av[1].GetFloat, av[2].GetInt));
end;

procedure SF_UFP_SendStringToClipboard(av: array of TVarEC; code: TCodeEC);
begin
  // Unsupported/headless clipboard services must not terminate a script.
  try
    SetGameClipboard(UtilityDllText(av[1].GetString));
  except
    on E: Exception do
      AppendDebugLogLine('UtilityFunctions: clipboard unavailable: ' + E.Message);
  end;
end;

procedure SF_UFP_GetStringFromClipboard(av: array of TVarEC; code: TCodeEC);
begin
  av[0].SetString(GetGameClipboard);
end;

procedure SF_UFP_OpenExternalLink(av: array of TVarEC; code: TCodeEC);
begin
  av[0].SetInt(Ord(OpenGameURL(UtilityDllText(av[1].GetString))));
end;

procedure ResetUtilityFunctionsPack;
begin
  SetLength(UtilityNearbyShips, 0);
  UtilityCapitalTarget := 0;
  UtilityCapitalOverrideEnabled := False;
end;

procedure ApplyUtilityFunctionsCapitalOverride(var Capital: Integer);
begin
  if UtilityCapitalOverrideEnabled then
    Capital := UtilityCapitalTarget;
end;

procedure RegisterUtilityFunctionsPack;
  procedure RegisterExport(const Signature: WideString; Callback: TExpressionCallback);
  begin
    RegisterNativeScriptFunction('UtilityFunctions', Signature, Callback);
  end;
begin
  if UtilityRegistered then
    Exit;
  UtilityRegistered := True;
  RegisterExport(
      'void,AdjustRuinsGoodsPricesToStorage,int,int,float,float',
      @SF_UFP_AdjustRuinsGoodsPricesToStorage
  );
  RegisterExport('int,AdvancedAdjustmentSet,int,int', @SF_UFP_AdvancedAdjustmentSet);
  RegisterExport('int,CustomArtCostCalc,int', @SF_UFP_CustomArtCostCalc);
  RegisterExport('int,CustomArtSizeCalc,int', @SF_UFP_CustomArtSizeCalc);
  RegisterExport('int,DistCoords,int,int,int,int', @SF_UFP_DistCoords);
  RegisterExport('str,FloatToString,float,int', @SF_UFP_FloatToString);
  RegisterExport('int,GetObjectGenerationSeed,dword', @SF_UFP_GetObjectGenerationSeed);
  RegisterExport('str,GetParFromString,str,str,int,int', @SF_UFP_GetParFromString);
  RegisterExport('str,GetParFromTxt,str,str', @SF_UFP_GetParFromTxt);
  RegisterExport('dword,GetPlanetOrbitProbe,dword,int,int', @SF_UFP_GetPlanetOrbitProbe);
  RegisterExport('str,GetScriptNoKlingMarksFromStar,dword', @SF_UFP_GetScriptNoKlingMarksFromStar);
  RegisterExport('dword,GetSectorAdjacentToDicea', @SF_UFP_GetSectorAdjacentToDicea);
  RegisterExport('float,GetShipPath,dword,str', @SF_UFP_GetShipPath);
  RegisterExport('str,GetShipScriptName,dword,int', @SF_UFP_GetShipScriptName);
  RegisterExport('str,GetStringFromClipboard', @SF_UFP_GetStringFromClipboard);
  RegisterExport('int,HoleStatus,dword,int', @SF_UFP_HoleStatus);
  RegisterExport('dword,HullExtraSettings,dword,int,dword', @SF_UFP_HullExtraSettings);
  RegisterExport('dword,IdToHole,int', @SF_UFP_IdToHole);
  RegisterExport('int,IsShiftCtrlPressed', @SF_UFP_IsShiftCtrlPressed);
  RegisterExport('int,OpenExternalLink,str', @SF_UFP_OpenExternalLink);
  RegisterExport('int,ParsCountFromString,str,str', @SF_UFP_ParsCountFromString);
  RegisterExport('int,PlanetItemsHiddency,dword,int,str,int', @SF_UFP_PlanetItemsHiddency);
  RegisterExport(
      'float,PortionInDiapason,float,float,float,float,float',
      @SF_UFP_PortionInDiapason
  );
  RegisterExport('float,Power,float,float', @SF_UFP_Power);
  RegisterExport('float,RndFloat,float,float,dword', @SF_UFP_RndFloat);
  RegisterExport('int,RndObject,int,int,dword', @SF_UFP_RndObject);
  RegisterExport('float,RoundTo,float,float,int', @SF_UFP_RoundTo);
  RegisterExport('void,SendStringToClipboard,str', @SF_UFP_SendStringToClipboard);
  RegisterExport('str,SetParFromString,str,str,int,str', @SF_UFP_SetParFromString);
  RegisterExport('str,SetParFromTxt,str,str,str', @SF_UFP_SetParFromTxt);
  RegisterExport('void,SetPlanetOrbitProbe,dword,int,dword', @SF_UFP_SetPlanetOrbitProbe);
  RegisterExport('int,SetRangersCapital,int,int', @SF_UFP_SetRangersCapital);
  RegisterExport('void,SetShipExpByType,dword,int,int', @SF_UFP_SetShipExpByType);
  RegisterExport('void,SetShipPath,dword,int,int', @SF_UFP_SetShipPath);
  RegisterExport('void,ShipExchangeToShip,dword,dword,int', @SF_UFP_ShipExchangeToShip);
  RegisterExport('void,ShipJoinToScript,dword,str', @SF_UFP_ShipJoinToScript);
  RegisterExport('dword,ShipNearbyShips,dword,int,int,int,str,str', @SF_UFP_ShipNearbyShips);
  RegisterExport('dword,ShipPrevStar,dword', @SF_UFP_ShipPrevStar);
  RegisterExport('int,ShipSubrace,dword,int', @SF_UFP_ShipSubrace);
  RegisterExport('float,ShipVisibility,dword,int,float', @SF_UFP_ShipVisibility);
  RegisterExport('str,TrimNumbers,str', @SF_UFP_TrimNumbers);
  RegisterExport('void,UtilityFunctionsLibInit,dword', @SF_UFP_UtilityFunctionsLibInit);
  RegisterExport('int,GetObjectSeed,dword', @SF_UFP_GetObjectSeed);
end;

initialization
  UtilityRandomState := Cardinal(DateTimeToUnix(Now, False));
  RegisterUtilityFunctionsPack;
{$ENDIF}
end.
