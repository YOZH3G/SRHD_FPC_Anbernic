unit aRuins;

{$I GameOptions.inc}

interface

uses
  Types,
  aConst,
  EC_BlockPar,
  EC_Buf,
  EC_Struct,
  aGalaxy,
  aGalaxyStruct,
  aItem,
  aMyFunction,
  aPlanet,
  aShip;

type

  TRuins = class;

  TStationHullTypes = set of THullType;

  TStationHullGeneration = packed record
    MinSize: Integer;
    MaxSize: Integer;
    TechSizeBonus: Integer;
    MinLevel: Integer;
    MaxLevel: Integer;
  end;

  TStationLevelRange = packed record
    Minimum: Integer;
    Maximum: Integer;
  end;

  TStationWeaponGeneration = packed record
    BasicLevel: Integer;
    IntermediateLevel: Integer;
    AdvancedLevel: Integer;
    MinimumRange: Integer;
  end;

  TRuins = class(TShip)
    EquipmentShop: TObjectList;
    ShopGoods: array[TGoodsIndex] of TGoodsTradePriceEntry;
    RelocationAge: Integer;
    FlyToStar: TStar;
    FlyDate: Integer;
    SatelliteOffer: TSatellite;
    SpecialServiceActive: Boolean;
    ModernizationSponsor: Boolean;
    NoLanding: Boolean;
    ShopUpdateMode: TShopUpdateMode;
    procedure SaveToBuffer(Buffer: TBufEC); override;
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy); override;
    procedure ResolveLoadedReferences(Galaxy: TGalaxy); override;
    procedure ClearObjectReferences; override;
    procedure SaveToBlock(Block: TBlockParEC); override;
    procedure LoadFromBlock(Block: TBlockParEC); override;
    procedure NextDay; override;
    procedure NextDayLogic; override;
    procedure AssignWeaponTargetsInStar; override;
    function GetName: WideString; override;
    function GetFullName(const Separator: WideString): WideString; override;
    function GetGreetingShipCategory: TGreetingShipCategory; override;
    function GetHomeStar: TStar; override;
    function GetDominantCareer: TRangerCareer; override;
    function GetStrengthScaledPirateStatus: TPercent; override;
    function GetDesiredCargoFreeSpace: Integer; override;
    procedure RefuelAtLocation; override;
    function AdjustItemEvaluation(
        Item: TItem;
        PriceMode: Byte;
        Effectiveness: Single
    ): Single; override;
    function EvaluateStatBonus(BonusKind: TEquipmentBonusKind; Value: Integer): Single; override;
    function EvaluateWeaponDamage(
        Weapon: TWeapon;
        IncludeAdditiveBonuses: Boolean;
        BaseDamage: Single
    ): Single; override;
    procedure RepairBrokenEquipmentAtLocation; override;
    procedure BuildReachablePlanetQueue; override;
    function CanQueueReachablePlanet(Planet: TPlanet): Boolean; override;
    procedure SelectEnemyShipInStar; override;
    procedure EngageEnemyShip; override;
    function RelationToRanger(Ranger: Pointer): Byte; override;
    procedure ChangeRelationToRanger(Ranger: Pointer; Amount: Integer); override;
    procedure ReactToAttack(Attacker: TShip); override;
    function RelationToNonRanger(Ship: TShip): Byte; override;
    function RecomputeFearState: Boolean; override;
    function AcceptsRansomDemandFrom(Ship: TShip): Boolean; override;
    function TrustsAttackRequester(Ship: TShip): Boolean; override;
    function AcceptsAppealFrom(Ship: TShip): Boolean; override;
    function AcceptPickupItem(Item: TItem): Boolean; override;
    procedure ProcessCombatDialogue; override;
    procedure ReactToExtortionDemand(Ranger: Pointer); override;
    function BuildMoneyExtortionResponse(
        OtherShip: TShip;
        var Response: WideString;
        DemandedAmount: Integer
    ): Boolean; override;
    function BuildCargoExtortionResponse(
        OtherShip: TShip;
        var Response: WideString
    ): Boolean; override;
    function BuildTrucePaymentResponse(
        OtherShip: TShip;
        var Response: WideString;
        OfferedAmount: Integer
    ): Boolean; override;
    function BuildAttackRequestResponse(
        Requester: TShip;
        var Response: WideString;
        Target: TShip
    ): Boolean; override;
    function AcceptPartnershipOffer(
        OtherShip: TShip;
        var Response: WideString;
        PaymentAmount: Integer
    ): Boolean; override;
    function BuildPartnershipOfferResponse(
        OtherShip: TShip;
        var Response: WideString;
        PaymentAmount: Integer
    ): Boolean; override;
    procedure RefreshCurrentStanding; override;
    function CanDock(Ship: TShip): Boolean; override;
    function CheckDockingPermission(Ship: TShip; var Response: WideString): Boolean; override;
    constructor Create;
    destructor Destroy; override;
    procedure Init(StationType: TStationType; Star: TStar; TypeNameOverride: WideString);
    function GetColoredFullName(const ColorTag: WideString): WideString;
    procedure RegenerateSatelliteOffer;
    procedure ReloadWeapons;
    procedure RefreshShopInventory;
    function CalculateEquipmentShopTargetCount: Integer;
    function CountEquipmentShopItems(ItemType: TItemType): Integer;
    function FindMostExpensiveShopItem(MinCost: Integer; MaxCost: Integer): TItem;
    function RemoveSimilarShopItem(Item: TEquipment): Boolean;
    function SelectEquipmentOfferSpecialMicroModule(Item: TEquipment; Planet: TPlanet): Integer;
    function SelectHullOfferSpecialMicroModule(Hull: THull; Planet: TPlanet): Integer;
    function SelectWeaponOfferSpecialMicroModule(Weapon: TWeapon; Planet: TPlanet): Integer;
    function TryStartAbductionCycle: Boolean;
    procedure TryAbductDepartingShip(Ship: TShip);
    procedure ReportAbductionOutcome;
    function EvaluateLocalForceBalance(Point: TPointF): Single;
    function EvaluateRelocationPosition(Point: TPointF): Single;
    function TryRepositionInStar: Boolean;
    function TryRelocateToPirateStar: Boolean;
    procedure ApplyInventoryMicroModulesToShopItems;
    procedure ForceGoodsForSale(GoodsMask: TItemTypeMask);
    procedure GenerateCombatSkills;
    procedure RandomizePosition;
    function SelectTeleportArrivalPoint(Star: TStar): TPointF;
    function GeneratePlanetHullOffer(Ship: TObject; Planet: TPlanet): THull;
    function GenerateHullOffer(Ship: TObject; Planet: TPlanet): THull;
    function GenerateWeaponOffer(Ship: TObject; Planet: TPlanet): TWeapon;
    function GenerateEquipmentOffer(
        Ship: TObject;
        Planet: TPlanet;
        ItemType: TItemType
    ): TEquipment;
    function GenerateEquipmentOfferBatch(
        Ship: TShip;
        UnusedForceGeneratedOffers: Boolean
    ): TObjectList;
    procedure UpdateGoodsMarketState;
    function CalculateRepairCost(Ship: TShip; out EquipmentCost: Integer): Integer;
    function GetRepairCost(Ship: TShip): Integer;
    procedure RepairShipEquipment(Ship: TShip);
    function GetNodeSaleBatchSize: Integer;
    function FindPirateBaseWithNodes: TRuins;
    function SelectServiceMicroModule(
        Kind: Integer;
        Index: Integer;
        InvertRarity: Boolean
    ): Integer;
  end;

const

  StationPilotRaces: array[rstRangerCenter..rstDominion] of array[0..1] of TOwnerId = (
      (oiFeyan, oiGaal),
      (oiHuman, oiPeleng),
      (oiMaloc, oiPeleng),
      (oiFeyan, oiGaal),
      (oiHuman, oiHuman),
      (oiGaal, oiGaal),
      (oiFeyan, oiFeyan)
  );

  StationHullGeneration: array[rstRangerCenter..rstDominion] of TStationHullGeneration = (
      (MinSize: 900; MaxSize: 1600; TechSizeBonus: 1500; MinLevel: 2; MaxLevel: 6),
      (MinSize: 900; MaxSize: 1000; TechSizeBonus: 1500; MinLevel: 2; MaxLevel: 5),
      (MinSize: 1200; MaxSize: 1500; TechSizeBonus: 1700; MinLevel: 2; MaxLevel: 7),
      (MinSize: 800; MaxSize: 1200; TechSizeBonus: 1100; MinLevel: 2; MaxLevel: 7),
      (MinSize: 800; MaxSize: 1000; TechSizeBonus: 1100; MinLevel: 2; MaxLevel: 5),
      (MinSize: 800; MaxSize: 1000; TechSizeBonus: 1200; MinLevel: 2; MaxLevel: 5),
      (MinSize: 900; MaxSize: 1000; TechSizeBonus: 1500; MinLevel: 2; MaxLevel: 5)
  );

  StationDefenseLevels: array[rstRangerCenter..rstDominion] of TStationLevelRange = (
      (Minimum: 2; Maximum: 6),
      (Minimum: 2; Maximum: 5),
      (Minimum: 2; Maximum: 7),
      (Minimum: 2; Maximum: 8),
      (Minimum: 2; Maximum: 5),
      (Minimum: 2; Maximum: 4),
      (Minimum: 2; Maximum: 5)
  );

  StationRepairLevels: array[rstRangerCenter..rstDominion] of TStationLevelRange = (
      (Minimum: 2; Maximum: 5),
      (Minimum: 1; Maximum: 4),
      (Minimum: 2; Maximum: 5),
      (Minimum: 2; Maximum: 6),
      (Minimum: 2; Maximum: 4),
      (Minimum: 2; Maximum: 3),
      (Minimum: 1; Maximum: 4)
  );

  StationWeaponGeneration: array[rstRangerCenter..rstDominion] of TStationWeaponGeneration = (
      (BasicLevel: 4; IntermediateLevel: 2; AdvancedLevel: 2; MinimumRange: 450),
      (BasicLevel: 4; IntermediateLevel: 2; AdvancedLevel: 2; MinimumRange: 400),
      (BasicLevel: 4; IntermediateLevel: 4; AdvancedLevel: 4; MinimumRange: 470),
      (BasicLevel: 4; IntermediateLevel: 4; AdvancedLevel: 4; MinimumRange: 500),
      (BasicLevel: 4; IntermediateLevel: 2; AdvancedLevel: 2; MinimumRange: 300),
      (BasicLevel: 4; IntermediateLevel: 2; AdvancedLevel: 2; MinimumRange: 350),
      (BasicLevel: 4; IntermediateLevel: 2; AdvancedLevel: 2; MinimumRange: 400)
  );

  StationWeaponTypes: array[rstRangerCenter..rstDominion] of array[0..2] of TItemType = (
      (t_Flux, t_FlowBlaster, t_AtomicVision),
      (t_Flux, t_WavePhaser, t_Disintegrator),
      (t_Flux, t_Multiresonator, t_FlowBlaster),
      (t_Flux, t_Treton, t_Turbogravitron),
      (t_FragmentationCannon, t_ElectronicCutter, t_WavePhaser),
      (t_IndustrialLaser, t_Treton, t_WavePhaser),
      (t_Flux, t_WavePhaser, t_Disintegrator)
  );

  StationSkillBonusWeights: array[bonSkill1..bonSkill6] of Integer = (100, 100, 80, 0, 0, 0);

  StationOfferHullLevelBonus: array[rstRangerCenter..rstDominion] of Integer =
      (0, 0, 1, 0, 0, 0, 0);

  StationOfferHullTypes: array[rstRangerCenter..rstDominion] of TStationHullTypes = (
      [htRanger],
      [htPirate, htTransport],
      [htRanger, htWarrior],
      [htRanger..htDiplomat],
      [htTransport, htLiner],
      [htTransport..htDiplomat],
      [htPirate]
  );

  StationOfferRareHullTypes: array[rstRangerCenter..rstDominion] of TStationHullTypes = (
      [htRanger],
      [htPirate],
      [htWarrior],
      [htRanger, htTransport..htDiplomat],
      [htTransport, htLiner],
      [htTransport..htDiplomat],
      [htPirate]
  );

  StationOfferWeaponLevelBonus: array[TStationType] of Integer = (1, 1, 2, 1, 1, 1, 2, 1);

  StationOfferEquipmentLevelBonus:
          array[TStationType] of array[t_FuelTanks..t_DefGenerator] of Integer =
      (
          (1, 0, 1, 0, 0, 0, 0),
          (0, 0, 0, 0, 0, 1, 0),
          (0, 0, 0, 0, 0, 0, 0),
          (0, 0, 0, 1, 0, 1, 0),
          (0, 0, 0, 0, 0, 1, 0),
          (0, 0, 0, 0, 0, 1, 0),
          (0, 0, 0, 0, 0, 1, 0),
          (0, 0, 0, 0, 0, 0, 0)
      );

implementation

uses
  Classes,
  aWarrior,
  aPlayer,
  aNormalShip,
  aPirate,
  aRanger,
  Math,
  GR_Main,
  aGalaxyEvent,
  SysUtils,
  Globals,
  aScript,
  fEquipmentShop,
  EC_Str,
  aAsteroid,
  aMissile,
  aTranclucator,
  GlobalsV;

constructor TRuins.Create;
begin
  inherited Create;
  EquipmentShop := TObjectList.Create;
  RelocationAge := 0;
  FlyToStar := nil;
  FlyDate := 0;
  ModernizationSponsor := False;
  SpecialServiceActive := False;
  if Galaxy <> nil then
    RegenerateSatelliteOffer;
end;

destructor TRuins.Destroy;
var
  I: Integer;
  Ranger: TRanger;
  Event: TGalaxyEvent;
  Star: TStar;
begin
  for I := 0 to Galaxy.Rangers.Count - 1 do
  begin
    Ranger := TRanger(Galaxy.Rangers[I]);
    if Ranger.LastDockedNonPlanetLocation = Self then
      Ranger.LastDockedNonPlanetLocation := nil;
  end;
  EquipmentShop.Free;
  EquipmentShop := nil;
  if SatelliteOffer <> nil then
  begin
    SatelliteOffer.Free;
    SatelliteOffer := nil;
  end;
  if not Galaxy.Destroying and (GetPlayer <> nil) and (GetPlayer.RuinsProxy <> Self) then
  begin
    Event := AddGalaxyEvent('RuinsDestroyed');
    Event.AddData(Ord(TypeId));
    Event.AddData(Id);
    Event.AddData(CurrentStar.Id);
    Event.AddTextData(Name);
    Event.AddTextData(TypeNameOverrideKey);
  end;
  for I := 0 to Galaxy.Stars.Count - 1 do
  begin
    Star := TStar(Galaxy.Stars[I]);
    if Star.Dominion = Self then
      Star.Dominion := nil;
  end;
  inherited Destroy;
end;

procedure TRuins.Init(StationType: TStationType; Star: TStar; TypeNameOverride: WideString);
var
  I: Integer;
  Ranger: TRanger;
  Event: TGalaxyEvent;
  Good: Byte;
  Weapon: TWeapon;
  Hook: TCargoHook;
  EquipmentOwner: TOwnerId;

  procedure SelectStationName(Config: TBlockParEC);
  var
    Index, I, J, K, LastName: Integer;
    Used: Boolean;
    Ship: TShip;
    OtherStar: TStar;
  begin
    if Config = nil then
      Exit;
    if Config.CountBlocks(ShipTypeNames[TypeId].Name) = 0 then
      Exit;
    LastName := Config.GetBlock(ShipTypeNames[TypeId].Name).GetParamCount - 1;
    Index := NextRandomIntRange(0, LastName, RandomState);
    for I := 0 to LastName do
    begin
      Name := Config.GetBlock(ShipTypeNames[TypeId].Name).GetParamValue(Index);
      Used := False;
      for J := 0 to Galaxy.Stars.Count - 1 do
      begin
        OtherStar := TStar(Galaxy.Stars[J]);
        for K := 0 to OtherStar.Ships.Count - 1 do
        begin
          Ship := TShip(OtherStar.Ships[K]);
          if (Ship.TypeId = TypeId) and (Ship.Name = Name) and (Ship <> Self) then
          begin
            Used := True;
            Break;
          end;
        end;
        if Used then
          Break;
      end;
      if not Used then
        Break;
      IncrementWrapped(Index, 0, LastName);
      if I = LastName then
        Name := Name + ' ' + '-' + IntToStr(NextRandomIntRange(10, 99, RandomState)) + '-';
    end;
  end;

  function RandomStationEquipmentSize(BaseSize: Integer): Integer;
  begin
    Result :=
        NextRandomIntRange(
            Round(BaseSize * EquipmentSizeFactors[2] * 2),
            Round(BaseSize * EquipmentSizeFactors[1] * 2),
            RandomState
        );
  end;
begin
  if StationType = rstCustomStation then
    TypeId := rstRangerCenter
  else
    TypeId := StationType;
  TypeNameOverrideKey := TypeNameOverride;
  CurrentStar := Star;
  CurrentStar.Ships.Add(Self);
  HomePlanet := nil;
  CurrentPlanet := nil;
  if (Galaxy.CurrentTurn < GalaxyWarmupTurns)
      and (GetPlayer.CurrentStar.Constellation = Star.Constellation) then
    PilotRace := StationPilotRaces[TypeId, 0]
  else if NextRandomUnitFloat(RandomState) < 0.5 then
    PilotRace := StationPilotRaces[TypeId, 0]
  else
    PilotRace := StationPilotRaces[TypeId, 1];
  OwnerId := RaceToOwner(PilotRace);
  RandomizePosition;
  Name := '';
  SelectStationName(ModRuinNameConfig);
  if Length(GetName) = 0 then
    SelectStationName(LanguageDataConfig.GetBlock('RuinName'));
  for I := 0 to Galaxy.Rangers.Count - 1 do
  begin
    Ranger := TRanger(Galaxy.Rangers[I]);
    RangerRelations
        .Add(Pointer(OwnerRelations[RaceToOwner(PilotRace), RaceToOwner(Ranger.PilotRace)]));
  end;
  GenerateCombatSkills;
  RefreshCurrentStanding;
  if (GetPlayer <> nil) and (GetPlayer.RuinsProxy <> Self) then
  begin
    Event := AddGalaxyEvent('RuinsCreated');
    Event.AddData(Ord(StationType));
    Event.AddData(Id);
    Event.AddData(Star.Id);
    Event.AddTextData(Name);
    Event.AddTextData(TypeNameOverride);
  end;
  ChameleonActive := False;
  GraphDominator := Galaxy.GraphDominatorSurfacesEnabled;
  RefreshShopInventory;
  for Good := Low(TGoodsIndex) to High(TGoodsIndex) do
  begin
    ShopGoods[Good].Count :=
        Round(GoodsMarket[Good].BaseStock * StationGoodsFactors[TypeId, Good].StockFactor);
    ShopGoods[Good].PriceState := GoodsMarket[Good].AveragePrice;
    ShopGoods[Good].PurchasePrice := Round(ShopGoods[Good].PriceState);
    ShopGoods[Good].BaseSalePrice := Round(ShopGoods[Good].PriceState * 0.98 - 1);
  end;
  if CurrentStar.ControlFaction = sfPirates then
    EquipmentOwner := oiPirate
  else
    EquipmentOwner := OwnerId;
  CreateAndEquipHull(
      RoundAndTruncateToTens(
          (NextRandomIntRange(
                      StationHullGeneration[TypeId].MinSize,
                      StationHullGeneration[TypeId].MaxSize,
                      RandomState)
                  + Galaxy.ScaleIntByTechLevel(0, StationHullGeneration[TypeId].TechSizeBonus))
              * HullCapacityScale
      ),
      Galaxy.ScaleIntByTechLevel(
          1,
          NextRandomIntRange(
              StationHullGeneration[TypeId].MinLevel,
              StationHullGeneration[TypeId].MaxLevel,
              RandomState
          )
      ),
      OwnerId,
      -1,
      CurrentStar.ControlFaction = sfPirates
  );
  CreateAndEquipFuelTanks(RandomStationEquipmentSize(FuelTanksBaseSize), 1, EquipmentOwner);
  CreateAndEquipEngine(RandomStationEquipmentSize(EngineBaseSize), 1, EquipmentOwner);
  CreateAndEquipDefGenerator(
      RandomStationEquipmentSize(DefGeneratorBaseSize),
      Galaxy.ScaleIntByTechLevel(
          1,
          NextRandomIntRange(
              StationDefenseLevels[TypeId].Minimum,
              StationDefenseLevels[TypeId].Maximum,
              RandomState
          )
      ),
      EquipmentOwner
  );
  CreateAndEquipRepairRobot(
      RandomStationEquipmentSize(RepairRobotBaseSize),
      Galaxy.ScaleIntByTechLevel(
          1,
          NextRandomIntRange(
              StationRepairLevels[TypeId].Minimum,
              StationRepairLevels[TypeId].Maximum,
              RandomState
          )
      ),
      EquipmentOwner
  );
  if (WeaponInfos[StationWeaponTypes[TypeId, 2]].TechLevel <= Galaxy.TechLevel)
      and (NextRandomUnitFloat(RandomState) > 0.6) then
    Weapon :=
        CreateAndEquipWeapon(
            StationWeaponTypes[TypeId, 2],
            RandomStationEquipmentSize(WeaponInfos[StationWeaponTypes[TypeId, 2]].AverageSize),
            Galaxy.ScaleIntByTechLevel(
                StationWeaponGeneration[TypeId].AdvancedLevel,
                NextRandomIntRange(
                    StationWeaponGeneration[TypeId].AdvancedLevel + 1,
                    8,
                    RandomState
                )
            ),
            EquipmentOwner
        )
  else if (WeaponInfos[StationWeaponTypes[TypeId, 1]].TechLevel <= Galaxy.TechLevel)
      and (NextRandomUnitFloat(RandomState) > 0.6) then
    Weapon :=
        CreateAndEquipWeapon(
            StationWeaponTypes[TypeId, 1],
            RandomStationEquipmentSize(WeaponInfos[StationWeaponTypes[TypeId, 1]].AverageSize),
            Galaxy.ScaleIntByTechLevel(
                StationWeaponGeneration[TypeId].IntermediateLevel,
                NextRandomIntRange(
                    StationWeaponGeneration[TypeId].IntermediateLevel + 1,
                    8,
                    RandomState
                )
            ),
            EquipmentOwner
        )
  else
    Weapon :=
        CreateAndEquipWeapon(
            StationWeaponTypes[TypeId, 0],
            RandomStationEquipmentSize(WeaponInfos[StationWeaponTypes[TypeId, 0]].AverageSize),
            Galaxy.ScaleIntByTechLevel(
                StationWeaponGeneration[TypeId].BasicLevel,
                NextRandomIntRange(StationWeaponGeneration[TypeId].BasicLevel + 1, 8, RandomState)
            ),
            EquipmentOwner
        );
  Weapon.Range := Max(Weapon.Range, StationWeaponGeneration[TypeId].MinimumRange);
  if TypeId = rstDominion then
  begin
    CurrentStar.Dominion := Self;
    Hook :=
        CreateAndEquipCargoHook(
            RandomStationEquipmentSize(CargoHookBaseSize),
            Galaxy.ScaleIntByTechLevel(2, NextRandomIntRange(5, 8, RandomState)),
            EquipmentOwner
        );
    Hook.Range := Max(Hook.Range, 200);
  end;
  if GetCargoFreeSpace < 0 then
    Inc(GetHull.Weight, Abs(GetCargoFreeSpace));
  RefreshDerivedStats(True);
  NodeReserve := 0;
  TypeId := StationType;
end;

procedure TRuins.SaveToBuffer(Buffer: TBufEC);
var
  Count, I: Integer;
  Item: TItem;
  Good: Byte;
begin
  inherited SaveToBuffer(Buffer);
  Count := EquipmentShop.Count;
  Buffer.AddWideChar(WideChar(Count));
  for I := 0 to Count - 1 do
  begin
    Item := TItem(EquipmentShop[I]);
    Buffer.AddAnsiChar(AnsiChar(Item.ItemType));
    Item.SaveToBuffer(Buffer);
  end;
  for Good := Low(TGoodsIndex) to High(TGoodsIndex) do
  begin
    Buffer.AddIntegerValue(ShopGoods[Good].Count);
    Buffer.AddSingle(ShopGoods[Good].PriceState);
    Buffer.AddIntegerValue(ShopGoods[Good].PurchasePrice);
    Buffer.AddIntegerValue(ShopGoods[Good].BaseSalePrice);
  end;
  Buffer.AddIntegerValue(RelocationAge);
  if FlyToStar = nil then
    Buffer.AddDWord(0)
  else
    Buffer.AddDWord(FlyToStar.Id);
  Buffer.AddIntegerValue(FlyDate);
  SatelliteOffer.SaveToBuffer(Buffer);
  Buffer.AddBoolean(ModernizationSponsor);
  Buffer.AddBoolean(SpecialServiceActive);
  Buffer.AddBoolean(NoLanding);
  Buffer.AddAnsiChar(AnsiChar(ShopUpdateMode));
end;

procedure TRuins.LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy);
var
  Count, I: Integer;
  Item: TItem;
  Good: Byte;
begin
  inherited LoadFromBuffer(Buffer, Galaxy);
  if LoadedSaveVersion < 102 then
    Buffer.GetByte;
  Count := Buffer.GetWord;
  if (Count < 0) or (Count > MaxSavedListCount) then
    raise EAbort.Create('Err');
  for I := 0 to Count - 1 do
  begin
    Item := CreateItemByType(MigrateSavedItemType(Buffer.GetByte));
    EquipmentShop.Add(Item);
    Item.LoadFromBuffer(Buffer, Galaxy);
  end;
  for Good := Low(TGoodsIndex) to High(TGoodsIndex) do
  begin
    ShopGoods[Good].Count := Buffer.GetInt32;
    ShopGoods[Good].PriceState := Buffer.GetSingle;
    ShopGoods[Good].PurchasePrice := Buffer.GetInt32;
    ShopGoods[Good].BaseSalePrice := Buffer.GetInt32;
  end;
  if LoadedSaveVersion >= 107 then
    RelocationAge := Buffer.GetInt32;
  FlyToStar := TStar(Buffer.GetUInt32);
  FlyDate := Buffer.GetInt32;
  if SatelliteOffer <> nil then
  begin
    SatelliteOffer.Free;
    SatelliteOffer := nil;
  end;
  SatelliteOffer := TSatellite.Create;
  SatelliteOffer.LoadFromBuffer(Buffer, Galaxy);
  SatelliteOffer.TargetPlanet := nil;
  ModernizationSponsor := Buffer.GetBoolean;
  SpecialServiceActive := Buffer.GetBoolean;
  NoLanding := Buffer.GetBoolean;
  if LoadedSaveVersion >= 83 then
    ShopUpdateMode := TShopUpdateMode(Buffer.GetByte)
  else
    ShopUpdateMode := sumNormal;
end;

procedure TRuins.SaveToBlock(Block: TBlockParEC);
var
  I: Integer;
  Text: WideString;
  Item: TItem;
  Slot: TShopSlot;
  ShopBlock: TBlockParEC;
begin
  inherited SaveToBlock(Block);
  Text := IntToStr(ShopGoods[GoodsTextOrder[0]].Count);
  for I := 1 to 7 do
    Text := Text + ',' + IntToStr(ShopGoods[GoodsTextOrder[Byte(I)]].Count);
  Block.AddParam(DecodeTextW('SihrolpaGloiordesa'), Text); // 'ShopGoods'
  Text := IntToStr(ShopGoods[GoodsTextOrder[0]].PurchasePrice);
  for I := 1 to 7 do
    Text := Text + ',' + IntToStr(ShopGoods[GoodsTextOrder[Byte(I)]].PurchasePrice);
  Block.AddParam(DecodeTextW('SihrolpaGloiordesaSrakloe'), Text); // 'ShopGoodsSale'
  Text := IntToStr(ShopGoods[GoodsTextOrder[0]].BaseSalePrice);
  for I := 1 to 7 do
    Text := Text + ',' + IntToStr(ShopGoods[GoodsTextOrder[Byte(I)]].BaseSalePrice);
  Block.AddParam(DecodeTextW('SihrolpaGloiordesaBruhy'), Text); // 'ShopGoodsBuy'
  ShopBlock := Block.AddBlockByPath(DecodeTextW('EdqeSahloEp')); // 'EqShop'
  if (EquipmentShop <> nil) and (EquipmentShop.Count > 0) then
  begin
    for I := 0 to EquipmentShop.Count - 1 do
    begin
      Item := TItem(EquipmentShop[I]);
      Text := DecodeTextW('ImtreamrIodo') + IntToStr(Int64(Cardinal(Item.Id))); // 'ItemId'
      Item.SaveToBlock(ShopBlock.AddBlockByPath(Text));
    end;
  end
  else if (GetPlayer.DockedTo = Self) and (TemporaryShopSlots <> nil) then
    for I := 0 to TemporaryShopSlots.Count - 1 do
    begin
      Slot := TShopSlot(TemporaryShopSlots[I]);
      Item := Slot.Item;
      if Item <> nil then
      begin
        Text := DecodeTextW('ImtreamrIodo') + IntToStr(Int64(Cardinal(Item.Id))); // 'ItemId'
        Item.SaveToBlock(ShopBlock.AddBlockByPath(Text));
      end;
    end;
  ShopBlock.AddParam(DecodeTextW('AodEdrIstaelma'), ''); // 'AddItem'
  with Block.AddBlockByPath(DecodeTextW('Sataokrgalgae')) do // 'Storage'
  begin
    for I := 0 to GetPlayer.StorageEntries.Count - 1 do
      if PStorageEntry(GetPlayer.StorageEntries[I]).LocationOwner = Self then
      begin
        Item := PStorageEntry(GetPlayer.StorageEntries[I]).Item;
        Text := DecodeTextW('ImtreamrIodo') + IntToStr(Int64(Cardinal(Item.Id))); // 'ItemId'
        Item.SaveToBlock(AddBlockByPath(Text));
      end;
    AddParam(DecodeTextW('AodEdrIstaelma'), ''); // 'AddItem'
  end;
end;

procedure TRuins.LoadFromBlock(Block: TBlockParEC);
var
  I: Integer;
  Text, Name: WideString;
  Item: TItem;
  Kind: Byte;
  Entry: PStorageEntry;
  Slot: TShopSlot;
  ShopBlock: TBlockParEC;
begin
  inherited LoadFromBlock(Block);
  Text := Block.GetParam(DecodeTextW('SihrolpaGloiordes')); // 'ShopGoods'
  for I := 0 to 7 do
    ShopGoods[GoodsTextOrder[Byte(I)]].Count := StrToInt(ExtractDelimitedPartW(Text, I, ','));
  Text := Block.GetParam(DecodeTextW('SihrolpaGloiordesaSrakloe')); // 'ShopGoodsSale'
  for I := 0 to 7 do
    ShopGoods[GoodsTextOrder[Byte(I)]].PurchasePrice :=
        StrToInt(ExtractDelimitedPartW(Text, I, ','));
  Text := Block.GetParam(DecodeTextW('SihrolpaGloiordesaBruhy')); // 'ShopGoodsBuy'
  for I := 0 to 7 do
    ShopGoods[GoodsTextOrder[Byte(I)]].BaseSalePrice :=
        StrToInt(ExtractDelimitedPartW(Text, I, ','));
  ShopBlock := Block.GetBlockByPath(DecodeTextW('EdqeSahloEp')); // 'EqShop'
  if (EquipmentShop <> nil) and (EquipmentShop.Count > 0) then
  begin
    for I := 0 to EquipmentShop.Count - 1 do
    begin
      Item := TItem(EquipmentShop[I]);
      Text := DecodeTextW('ImtreamrIodo') + IntToStr(Int64(Cardinal(Item.Id))); // 'ItemId'
      Item.LoadFromBlock(ShopBlock.GetBlockByPath(Text));
    end;
  end
  else if (GetPlayer.DockedTo = Self) and (TemporaryShopSlots <> nil) then
    for I := 0 to TemporaryShopSlots.Count - 1 do
    begin
      Slot := TShopSlot(TemporaryShopSlots[I]);
      Item := Slot.Item;
      if Item <> nil then
      begin
        Text := DecodeTextW('ImtreamrIodo') + IntToStr(Int64(Cardinal(Item.Id))); // 'ItemId'
        Item.LoadFromBlock(ShopBlock.GetBlockByPath(Text));
      end;
    end;
  Text := ShopBlock.GetParam(DecodeTextW('AodEdrIstaelma')); // 'AddItem'
  for I := 0 to CountDelimitedPartsW(Text, ',') - 1 do
  begin
    Name := ExtractDelimitedPartW(Text, I, ',');
    for Kind := 0 to 75 do
      if ItemTypeNames[TItemType(Kind)] = Name then
      begin
        if Kind in [42..68] then
        begin
          Item := CreateDefaultItemByType(TItemType(Kind));
          if Item <> nil then
          begin
            if (TemporaryShopSlots <> nil) and (TemporaryShopStation = Self) then
            begin
              RestoreTemporaryShopStock;
              EquipmentShop.Add(Item);
              BuildTemporaryShopSlotGrid;
            end
            else
              EquipmentShop.Add(Item);
          end;
        end;
        Break;
      end;
  end;
  with Block.GetBlockByPath(DecodeTextW('Sataokrgalgae')) do // 'Storage'
  begin
    for I := 0 to GetPlayer.StorageEntries.Count - 1 do
      if PStorageEntry(GetPlayer.StorageEntries[I]).LocationOwner = Self then
      begin
        Item := PStorageEntry(GetPlayer.StorageEntries[I]).Item;
        Text := DecodeTextW('ImtreamrIodo') + IntToStr(Int64(Cardinal(Item.Id))); // 'ItemId'
        Item.LoadFromBlock(GetBlockByPath(Text));
      end;
    Text := GetParam(DecodeTextW('AodEdrIstaelma')); // 'AddItem'
    for I := 0 to CountDelimitedPartsW(Text, ',') - 1 do
    begin
      Name := ExtractDelimitedPartW(Text, I, ',');
      for Kind := 0 to 75 do
        if ItemTypeNames[TItemType(Kind)] = Name then
        begin
          if (Kind in [0..7]) or (Kind in [42..68]) or (Kind in [10..41]) or (Kind in [69..73]) then
          begin
            Item := CreateDefaultItemByType(TItemType(Kind));
            if Item <> nil then
            begin
              New(Entry);
              Entry.LocationOwner := Self;
              Entry.SlotIndex := GetPlayer.FindNextStorageSlot(Self);
              Entry.Item := Item;
              GetPlayer.StorageEntries.Add(Entry);
              GetPlayer.RefreshStorageBubbles;
            end;
          end;
          Break;
        end;
    end;
  end;
end;

procedure TRuins.ResolveLoadedReferences(Galaxy: TGalaxy);
var
  Count: Integer;
  I: Integer;
  Item: TItem;
begin
  inherited ResolveLoadedReferences(Galaxy);
  Count := EquipmentShop.Count;
  for I := 0 to Count - 1 do
  begin
    Item := TItem(EquipmentShop[I]);
    Item.ResolveLoadedReferences(Galaxy);
  end;
  FlyToStar := TObject(Galaxy.IdToStar(Cardinal(FlyToStar))) as TStar;
end;

procedure TRuins.ClearObjectReferences;
var
  Count: Integer;
  I: Integer;
  Item: TItem;
begin
  inherited ClearObjectReferences;
  Count := EquipmentShop.Count;
  for I := 0 to Count - 1 do
  begin
    Item := TItem(EquipmentShop[I]);
    Item.ClearReferences;
  end;
  FlyToStar := nil;
end;

procedure TRuins.NextDay;
begin
  inherited NextDay;
  if (ScriptShip <> nil) and HasScriptControl then
  begin
    ScriptNextDay;
    if ScriptShip <> nil then
      Exit;
  end;
  NextDayLogic;
  if (ScriptShip <> nil) and not HasScriptControl then
    ScriptNextDay;
end;

procedure TRuins.NextDayLogic;
var
  Stage: Integer;
  Imbalance, LocalBalance: Single;
  // Four native frame bytes precede compiler temporaries; no access identifies their type.
  UnresolvedFrameBytes: array[0..3] of Byte;

  function FindDominionHomeStar: TStar;
  var
    I: Integer;
    Star: TStar;
  begin
    Result := nil;
    if (TransitOriginStar <> nil) and (TransitOriginStar.Dominion = Self) then
    begin
      Result := TransitOriginStar;
      Exit;
    end;
    for I := 0 to Galaxy.Stars.Count - 1 do
    begin
      Star := TStar(Galaxy.Stars[I]);
      if Star.Dominion = Self then
      begin
        Result := Star;
        Exit;
      end;
    end;
  end;
begin
  Stage := 0;
  try
    if IsDocked then
      OrderTakeoff;
    if not InNormalSpace then
      Exit;
    begin
      Stage := 1;
      if (EnemyShip <> nil) and (EnemyShip.CurrentStar <> CurrentStar) then
        EnemyShip := nil;
      Stage := 2;
      if NextRandomIntRange(1, 60, RandomState) = 1 then
      begin
        RepairBrokenEquipmentAtLocation;
        ReloadWeapons;
        if Galaxy.IsStationShopUpdateEnabled and not ModernizationSponsor then
        begin
          BuyEquipmentAtLocation(False);
          RepairBrokenEquipmentAtLocation;
        end;
      end;
      Stage := 3;
      AssignWeaponTargetsInStar;
      Stage := 4;
      QueueItemsWithinPickupRange;
      Stage := 5;
      if TypeId = rstPirateBase then
      begin
        Stage := 6;
        if Galaxy.HasUnresolvedDominatorSeries([dsBlazer, dsKeller, dsTerron])
            and (Galaxy.CurrentTurn mod 60 = 0)
            and (DaysSincePlayerSeen > 30)
            and (NodeReserve < Max(500, GetPlayer.TotalExperience div 10))
            and (NodeReserve
                < 200
                    / GalaxyDifficultyTuning[Galaxy.DifficultyLevels[7]]
                        .GoodsEventDurationFactor) then
          Inc(
              NodeReserve,
              NextRandomIntRange(
                  0,
                  Round(
                      250
                          / GalaxyDifficultyTuning[Galaxy.DifficultyLevels[7]]
                              .GoodsEventDurationFactor
                  ),
                  RandomState
              )
          );
      end
      else if TypeId = rstDominion then
      begin
        Stage := 7;
        AutoApplyMicroModules;
        ApplyInventoryMicroModulesToShopItems;
        Inc(RelocationAge);
        if CurrentStar.Dominion = Self then
        begin
          if (FlyToStar <> nil) and (CurrentStar.Battle <> 0) then
          begin
            FlyToStar := nil;
            FlyDate := 0;
            OrderNone(False);
          end;
          if (FlyToStar = nil) and (Order = soNone) then
          begin
            Stage := 8;
            if not TryRelocateToPirateStar and not TryStartAbductionCycle then
              TryRepositionInStar;
          end;
        end
        else
        begin
          if CurrentStar = FlyToStar then
          begin
            FlyToStar := nil;
            FlyDate := Galaxy.CurrentTurn + 30;
          end;
          Imbalance :=
              Abs(
                      CurrentStar.GetCachedFactionStrength(sfCoalition)
                          - CurrentStar.GetCachedFactionStrength(sfDominators) * 2.5)
                  / Max(0.001, CurrentStar.GetCachedFactionStrength(sfPirates));
          LocalBalance := EvaluateLocalForceBalance(Position);
          if ((LocalBalance < -150) or (Imbalance > 30))
              and (FlyDate < Galaxy.CurrentTurn + 25)
              and (FlyDate > Galaxy.CurrentTurn) then
          begin
            FlyToStar := FindDominionHomeStar;
            if FlyToStar <> nil then
              FlyDate := Galaxy.CurrentTurn + 1
            else
              FlyDate := 0;
          end
          else if (Imbalance > 1.5) or (LocalBalance < -8) then
            FlyDate := Min(FlyDate, Max(FlyDate - 15, Galaxy.CurrentTurn + 4))
          else if (Imbalance > 1.37) or (LocalBalance < -4) then
            FlyDate := Min(FlyDate, Max(FlyDate - 7, Galaxy.CurrentTurn + 4))
          else if (Imbalance > 1.25) or (LocalBalance < -2) then
            FlyDate := Min(FlyDate, Max(FlyDate - 3, Galaxy.CurrentTurn + 4))
          else if (Imbalance > 1.12) or (LocalBalance < -1) then
            FlyDate := Min(FlyDate, Max(FlyDate - 1, Galaxy.CurrentTurn + 4));
          if FlyDate < Galaxy.CurrentTurn + 3 then
            FlyToStar := FindDominionHomeStar;
        end;
      end;
      Stage := 9;
      if CargoFreeSpace < 0 then
        DropCargoUntilNotOverloaded;
      Stage := 10;
      if NextRandomIntRange(1, 17, RandomState) = 1 then
        RegenerateSatelliteOffer;
      Stage := 11;
      RefreshShopInventory;
      Stage := 12;
      UpdateGoodsMarketState;
      Stage := 13;
      if FlyToStar <> nil then
      begin
        if CurrentStar = FlyToStar then
        begin
          FlyToStar := nil;
          FlyDate := 0;
        end
        else if FlyDate <= Galaxy.CurrentTurn then
          OrderTeleport(FlyToStar, SelectTeleportArrivalPoint(FlyToStar), 10, True);
      end;
    end;
  except
    on E: Exception do
    begin
      AppendLogLineThreadSafe(E.ClassName + ' ' + E.Message);
      raise Exception.Create(
          'Error in procedure TRuins.NextDayLogic '
              + GetFullName(' ')
              + ' label = '
              + IntToStr(Stage));
    end;
  end;
end;

function TRuins.GetName: WideString;
begin
  Result := Name;
end;

function TRuins.GetFullName(const Separator: WideString): WideString;
var
  Caption: WideString;
begin
  if TypeNameOverrideKey = '' then
    Result := LocalizedText('ShipType.TypeName.' + GetTypeNameKey) + Separator + Name
  else
  begin
    Caption := LocalizedText('ShipType.TypeName.' + TypeNameOverrideKey);
    if Caption <> '' then
      Result := Caption + Separator + Name
    else
      Result := Name;
  end;
end;

function TRuins.GetColoredFullName(const ColorTag: WideString): WideString;
begin
  if TypeNameOverrideKey = '' then
    Result :=
        LocalizedText('ShipType.TypeName.' + GetTypeNameKey + 'Small')
            + ' '
            + WrapTextInColor(Name, ColorTag)
  else
    Result :=
        LocalizedText('ShipType.TypeName.' + TypeNameOverrideKey + 'Small')
            + ' '
            + WrapTextInColor(Name, ColorTag);
end;

function TRuins.GetGreetingShipCategory: TGreetingShipCategory;
begin
  Result := gscTransport; // Native default category, also used for transports.
end;

function TRuins.GetDominantCareer: TRangerCareer;
begin
  Result := rcTrader;
end;

function TRuins.GetHomeStar: TStar;
begin
  Result := nil;
end;

function TRuins.GetStrengthScaledPirateStatus: TPercent;
begin
  Result := 0;
end;

function TRuins.GetDesiredCargoFreeSpace: Integer;
begin
  Result := 0;
end;

procedure TRuins.RegenerateSatelliteOffer;
var
  Level: Integer;
begin
  if SatelliteOffer = nil then
    SatelliteOffer := TSatellite.Create;
  Level := NextRandomIntRange(0, Round(Galaxy.ScaleIntByTechLevel(1, 5)), RandomState);
  SatelliteOffer.InitGenerated(Level, PickRandomEquipmentOwner(RandomState), RandomState);
  SatelliteOffer.TargetPlanet := nil;
end;

procedure TRuins.RefuelAtLocation;
begin
  if GetFuelTanks <> nil then
    GetFuelTanks.Fuel := GetFuelTanks.Capacity;
end;

procedure TRuins.RepairBrokenEquipmentAtLocation;
var
  I: Integer;
  Item, Artefact: TEquipment;
begin
  for I := 1 to Inventory.Count - 1 do
  begin
    Item := TEquipment(Inventory[I]);
    if (not (Item is TWeapon)
            or (TWeapon(Item).GetWeaponInfo.Availability <> waNotSoldAndNodeRepair))
        and CanRepairEquipmentTech(Item)
        and ((Item.BrokenFlag <> 0) or (Item.ConditionPercent < 1)) then
    begin
      Item.BrokenFlag := 0;
      if ModernizationSponsor then
        Item.ConditionPercent := 1
      else
        Item.Repair;
    end;
  end;
  for I := 0 to Artefacts.Count - 1 do
  begin
    Artefact := TEquipment(Artefacts[I]);
    if (Artefact.BrokenFlag <> 0) or (Artefact.ConditionPercent < 1) then
    begin
      Artefact.BrokenFlag := 0;
      if ModernizationSponsor then
        Artefact.ConditionPercent := 1
      else
        Artefact.Repair;
    end;
  end;
end;

procedure TRuins.ReloadWeapons;
var
  I: Integer;
  Weapon: TWeapon;
begin
  for I := 1 to WeaponCount do
  begin
    Weapon := Weapons[I];
    if (Weapon.GetWeaponInfo.ShotType in [wstTorpedo..wstRocket])
        and (Weapon.Ammo < Weapon.AmmoCapacity) then
    begin
      if ModernizationSponsor then
        Inc(Weapon.Ammo)
      else
        Weapon.Ammo := Weapon.AmmoCapacity;
    end;
  end;
end;

procedure TRuins.RefreshShopInventory;
type
  TQuotas = array[t_Hull..WeaponCategoryItemType] of Integer;
var
  I, Attempts, Added: Integer;
  Item: TEquipment;
  Kind: TItemType;
  Planet: TPlanet;
begin
  if ShopUpdateMode in [sumDisabled, sumGoodsOnly] then
    Exit;
  if (Galaxy.CurrentTurn > CreationTurn + 1)
      and (Integer(Seed + Cardinal(Galaxy.CurrentTurn)) mod 7 <> 0) then
    Exit;
  Planet :=
      TPlanet(
          CurrentStar.Planets[NextRandomIntRange(0, CurrentStar.Planets.Count - 1, RandomState)]
      );
  if Planet.OwnerId = oiUninhabited then
    Planet := nil;
  if EquipmentShop.Count >= CalculateEquipmentShopTargetCount then
    if Planet <> nil then
    begin
      I := SeededRandomIntRange(0, EquipmentShop.Count - 1, Seed * Cardinal(Galaxy.CurrentTurn));
      Item := TEquipment(EquipmentShop[I]);
      if (Item.ScriptItem = nil) or (TScriptItem(Item.ScriptItem).Name = '') then
      begin
        EquipmentShop.Delete(I);
        Item.Free;
      end;
    end;
  Added := 0;
  while (EquipmentShop.Count <= CalculateEquipmentShopTargetCount * 0.7)
      or ((EquipmentShop.Count <= CalculateEquipmentShopTargetCount) and (Planet <> nil)) do
  begin
    if Planet = nil then
      Planet := FindFirstInhabitedPlanetInStar;
    Inc(Added);
    if Added > 10 then
      Break;
    Attempts := 0;
    repeat
      Inc(Attempts);
      Kind :=
          TItemType(
              SeededRandomIntRange(
                  Ord(t_Hull),
                  Ord(WeaponCategoryItemType),
                  (Seed * Cardinal(Galaxy.CurrentTurn)) * 175 + Cardinal(Attempts)
              )
          );
    until (Attempts > 20)
        or (CountEquipmentShopItems(Kind) < TQuotas(StationEquipmentOfferQuotas[TypeId])[Kind]);
    Item := GenerateEquipmentOffer(GetPlayer, Planet, Kind);
    if Item <> nil then
    begin
      EquipmentShop.Add(Item);
      RemoveSimilarShopItem(Item);
    end;
  end;
end;

function TRuins.CalculateEquipmentShopTargetCount: Integer;
type
  TQuotas = array[t_Hull..WeaponCategoryItemType] of Integer;
var
  Count: Integer;
  Kind: TItemType;
begin
  Count := 0;
  for Kind := t_Hull to WeaponCategoryItemType do
    Inc(Count, TQuotas(StationEquipmentOfferQuotas[TypeId])[Kind]);
  Result := Round(Count + NextRandomIntRange(-2, 2, RandomState));
  Result := Max(10, Min(Result, 18));
end;

function TRuins.CountEquipmentShopItems(ItemType: TItemType): Integer;
var
  I, Count: Integer;
  Item: TItem;
begin
  Count := 0;
  for I := 0 to EquipmentShop.Count - 1 do
  begin
    Item := TItem(EquipmentShop[I]);
    // The WeaponCategoryItemType shop bucket counts every weapon subtype.
    if (Item.ItemType = ItemType)
        or ((Item.ItemType in [t_IndustrialLaser..t_CustomWeapon])
            and (ItemType = WeaponCategoryItemType)) then
      Inc(Count);
  end;
  Result := Count;
end;

function TRuins.FindMostExpensiveShopItem(MinCost, MaxCost: Integer): TItem;
var
  I: Integer;
  Item, Best: TItem;
begin
  Best := nil;
  for I := 0 to EquipmentShop.Count - 1 do
  begin
    Item := TItem(EquipmentShop[I]);
    if (Item.ItemType <> t_Hull) and (Item.Cost <= MaxCost) and (Item.Cost >= MinCost) then
    begin
      if Best = nil then
        Best := Item
      else if TEquipment(Item).Cost > Best.Cost then
        Best := Item;
    end;
  end;
  Result := Best;
end;

function TRuins.RemoveSimilarShopItem(Item: TEquipment): Boolean;
var
  I: Integer;
  Existing: TEquipment;
begin
  Result := False;
  for I := 0 to EquipmentShop.Count - 1 do
  begin
    Existing := TEquipment(EquipmentShop[I]);
    if (Existing.ItemType = Item.ItemType)
        and (Existing <> Item)
        and ((Existing.ScriptItem = nil) or (TScriptItem(Existing.ScriptItem).Name = '')) then
    begin
      case Existing.ItemType of
        t_Hull:
          if (Existing as THull).TechLevel = (Item as THull).TechLevel then
            Result := True;
        t_FuelTanks:
          if (Existing as TFuelTanks).TechLevel = (Item as TFuelTanks).TechLevel then
            Result := True;
        t_Engine:
          if (Existing as TEngine).TechLevel = (Item as TEngine).TechLevel then
            Result := True;
        t_Radar:
          if (Existing as TRadar).TechLevel = (Item as TRadar).TechLevel then
            Result := True;
        t_Scaner:
          if (Existing as TScaner).TechLevel = (Item as TScaner).TechLevel then
            Result := True;
        t_RepairRobot:
          if (Existing as TRepairRobot).TechLevel = (Item as TRepairRobot).TechLevel then
            Result := True;
        t_CargoHook:
          if (Existing as TCargoHook).TechLevel = (Item as TCargoHook).TechLevel then
            Result := True;
        t_DefGenerator:
          if (Existing as TDefGenerator).TechLevel = (Item as TDefGenerator).TechLevel then
            Result := True;
      else
        if Existing.ItemType in [t_IndustrialLaser..t_CustomWeapon] then
          if (Existing as TWeapon).TechLevel = (Item as TWeapon).TechLevel then
            Result := True;
      end;
      if Result then
      begin
        if EquipmentShop.Count < CalculateEquipmentShopTargetCount then
          Result := Abs(Existing.Weight - Item.Weight) < Existing.Weight div 5;
        if Result then
        begin
          EquipmentShop.Delete(I);
          Existing.Free;
          Break;
        end;
      end;
    end;
  end;
end;

function TRuins.SelectEquipmentOfferSpecialMicroModule(Item: TEquipment; Planet: TPlanet): Integer;
var
  I, Candidate, Count: Integer;
  Template: PMicroModuleTemplate;
  Ceiling, Minimum, Maximum: Integer;
begin
  Result := -1;
  if NextRandomIntRange(1, 100, RandomState) > Galaxy.GetMicroModuleOfferRollThresholdPercent then
    Exit;
  Ceiling := Round(Planet.InventionLevels[piMainTech] * 100 / 8);
  Minimum := 0;
  Maximum := 0;
  Count := 0;
  Template := Pointer(MicroModuleTemplates);
  for I := 0 to MicroModuleTemplateCount - 1 do
  begin
    repeat
      if not Template.SpecialOnly then
        Break;
      if TypeNameOverrideKey <> '' then
      begin
        if (Template.OfferStationNames <> '<Any>')
            and (Pos('<' + TypeNameOverrideKey + '>', Template.OfferStationNames) <= 0) then
          Break;
      end
      else if not (TypeId in Template.OfferStationTypes) then
        Break;
      if not IsBonusCompatibleWithEquipment(I, Item) then
        Break;
      if Template.Priority > Ceiling then
        Break;
      if Count = 0 then
      begin
        Minimum := Template.Priority;
        Maximum := Template.Priority;
      end
      else
      begin
        Minimum := Min(Minimum, Template.Priority);
        Maximum := Max(Maximum, Template.Priority);
      end;
      MicroModuleCandidateIndices[Count] := I;
      Inc(Count);
    until True;
    Template := Pointer(PAnsiChar(Template) + SizeOf(TMicroModuleInfo));
  end;
  if Count > 0 then
  begin
    Minimum := Max(0, Maximum - 40);
    for I := 0 to 10 do
    begin
      Candidate := NextRandomIntRange(0, Count - 1, RandomState);
      if MicroModuleTemplates[MicroModuleCandidateIndices[Candidate]].Priority >= Minimum then
      begin
        Result := MicroModuleCandidateIndices[Candidate];
        Break;
      end;
    end;
  end;
end;

function TRuins.SelectHullOfferSpecialMicroModule(Hull: THull; Planet: TPlanet): Integer;
var
  I, Candidate, Count: Integer;
  Template: PMicroModuleTemplate;
  Ceiling, Minimum, Maximum: Integer;
begin
  Result := -1;
  if NextRandomIntRange(1, 100, RandomState) > Galaxy.GetMicroModuleOfferRollThresholdPercent then
    Exit;
  Ceiling := Round(Planet.InventionLevels[piMainTech] * 100 / 8);
  Minimum := 0;
  Maximum := 0;
  Count := 0;
  Template := Pointer(MicroModuleTemplates);
  for I := 0 to MicroModuleTemplateCount - 1 do
  begin
    repeat
      if not Template.SpecialOnly then
        Break;
      if TypeNameOverrideKey <> '' then
      begin
        if (Template.OfferStationNames <> '<Any>')
            and (Pos('<' + TypeNameOverrideKey + '>', Template.OfferStationNames) <= 0) then
          Break;
      end
      else if not (TypeId in Template.OfferStationTypes) then
        Break;
      if not IsBonusCompatibleWithHull(I, Hull) then
        Break;
      if Template.Priority > Ceiling then
        Break;
      if Count = 0 then
      begin
        Minimum := Template.Priority;
        Maximum := Template.Priority;
      end
      else
      begin
        Minimum := Min(Minimum, Template.Priority);
        Maximum := Max(Maximum, Template.Priority);
      end;
      MicroModuleCandidateIndices[Count] := I;
      Inc(Count);
    until True;
    Template := Pointer(PAnsiChar(Template) + SizeOf(TMicroModuleInfo));
  end;
  if Count > 0 then
  begin
    Minimum := Max(0, Maximum - 40);
    for I := 0 to 10 do
    begin
      Candidate := NextRandomIntRange(0, Count - 1, RandomState);
      if MicroModuleTemplates[MicroModuleCandidateIndices[Candidate]].Priority >= Minimum then
      begin
        Result := MicroModuleCandidateIndices[Candidate];
        Break;
      end;
    end;
  end;
end;

function TRuins.SelectWeaponOfferSpecialMicroModule(Weapon: TWeapon; Planet: TPlanet): Integer;
var
  I, Candidate, Count: Integer;
  Template: PMicroModuleTemplate;
  Ceiling, Minimum, Maximum: Integer;
begin
  Result := -1;
  if NextRandomIntRange(1, 100, RandomState) > Galaxy.GetMicroModuleOfferRollThresholdPercent then
    Exit;
  Ceiling := Round(Planet.InventionLevels[piMainTech] * 100 / 8);
  Minimum := 0;
  Maximum := 0;
  Count := 0;
  Template := Pointer(MicroModuleTemplates);
  for I := 0 to MicroModuleTemplateCount - 1 do
  begin
    repeat
      if not Template.SpecialOnly then
        Break;
      if TypeNameOverrideKey <> '' then
      begin
        if (Template.OfferStationNames <> '<Any>')
            and (Pos('<' + TypeNameOverrideKey + '>', Template.OfferStationNames) <= 0) then
          Break;
      end
      else if not (TypeId in Template.OfferStationTypes) then
        Break;
      if not IsBonusCompatibleWithWeapon(I, Weapon) then
        Break;
      if Template.Priority > Ceiling then
        Break;
      if Count = 0 then
      begin
        Minimum := Template.Priority;
        Maximum := Template.Priority;
      end
      else
      begin
        Minimum := Min(Minimum, Template.Priority);
        Maximum := Max(Maximum, Template.Priority);
      end;
      MicroModuleCandidateIndices[Count] := I;
      Inc(Count);
    until True;
    Template := Pointer(PAnsiChar(Template) + SizeOf(TMicroModuleInfo));
  end;
  if Count > 0 then
  begin
    Minimum := Max(0, Maximum - 40);
    for I := 0 to 10 do
    begin
      Candidate := NextRandomIntRange(0, Count - 1, RandomState);
      if MicroModuleTemplates[MicroModuleCandidateIndices[Candidate]].Priority >= Minimum then
      begin
        Result := MicroModuleCandidateIndices[Candidate];
        Break;
      end;
    end;
  end;
end;

procedure TRuins.BuildReachablePlanetQueue;
begin
end;

function TRuins.CanQueueReachablePlanet(Planet: TPlanet): Boolean;
begin
  Result := False;
end;

procedure TRuins.SelectEnemyShipInStar;
begin
  EnemyShip := nil;
end;

procedure TRuins.EngageEnemyShip;
begin
end;

procedure TRuins.AssignWeaponTargetsInStar;
var
  I, J, Assigned: Integer;
  Ship: TShip;
  Weapon: TWeapon;
  Asteroid: TAsteroid;
  DistanceSquared: Single;
  Missile: TMissile;
begin
  Assigned := 0;
  for I := 1 to WeaponCount do
  begin
    Weapon := Weapons[I];
    Weapon.Target := nil;
  end;
  if (GetPlayer.CurrentStar = CurrentStar)
      or (NextRandomUnitFloat(RandomState) > 0.7)
      or Galaxy.IsFullStationTargetingEnabled
      or (CurrentStar.ControlFaction = sfDominators)
      or (CurrentStar.Status.CustomFaction <> '') then
    for I := 0 to CurrentStar.Ships.Count - 1 do
    begin
      Ship := TShip(CurrentStar.Ships[I]);
      if ((Ship.OwnerId = oiDominator) or (Ship.RelationToShip(Self) < RelationBadMin))
          and Ship.InNormalSpace
          and (not HasIndependentScriptFaction
              or not Ship.HasIndependentScriptFaction
              or (TScriptShip(ScriptShip).StateText <> TScriptShip(Ship.ScriptShip).StateText)) then
        for J := 1 to WeaponCount do
        begin
          Weapon := Weapons[J];
          if (Weapon.Target = nil)
              and IsEquipmentUsable(Weapon)
              and (PointDistanceSquared(Position, Ship.Position)
                  <= Sqr(GetWeaponRange(Weapon))) then
          begin
            Weapon.Target := Ship;
            Inc(Assigned);
            if Assigned = WeaponCount then
              Exit;
          end;
        end;
    end;
  for I := 0 to CurrentStar.Missiles.Count - 1 do
  begin
    Missile := TMissile(CurrentStar.Missiles[I]);
    if (Missile.OwnerShip <> Self) and (Missile.Target = Self) then
      for J := 1 to WeaponCount do
      begin
        Weapon := Weapons[J];
        if not (Weapon.GetWeaponInfo.ShotType in [wstTorpedo..wstRocket])
            and (Weapon.Target = nil)
            and IsEquipmentUsable(Weapon)
            and (PointDistanceSquared(Position, Missile.Position)
                <= Sqr(GetWeaponRange(Weapon))) then
        begin
          Weapon.Target := Missile;
          Inc(Assigned);
          if Assigned = WeaponCount then
            Exit;
          Break;
        end;
      end;
  end;
  if (CurrentStar.Items.Count < 10)
      and (GetPlayer.CurrentStar = CurrentStar)
      and GetPlayer.InNormalSpace then
    for I := 0 to CurrentStar.Asteroids.Count - 1 do
    begin
      Asteroid := TAsteroid(CurrentStar.Asteroids[I]);
      DistanceSquared := PointDistanceSquared(Position, Asteroid.Position);
      if DistanceSquared <= AsteroidTargetRangeSquared then
        for J := 1 to WeaponCount do
        begin
          Weapon := Weapons[J];
          if ((NextRandomUnitFloat(RandomState) <= 0.9) or (GetHullIntegrityPercent <= 90))
              and not (Weapon.GetWeaponInfo.ShotType in [wstAreaDamage..wstRocket])
              and IsEquipmentUsable(Weapon)
              and (Sqr(GetWeaponRange(Weapon)) >= DistanceSquared) then
          begin
            Weapon.Target := Asteroid;
            Inc(Assigned);
            if Assigned = WeaponCount then
              Exit;
            Break;
          end;
        end;
    end;
end;

function TRuins.TryStartAbductionCycle: Boolean;
var
  I, J, Count: Integer;
  Ship: TShip;
  Star: TStar;
begin
  Result := False;
  if CurrentStar.Dominion <> Self then
    Exit;
  if (PickupTargets <> nil) and (PickupTargets.Count > 0) then
    Exit;
  if CurrentStar.Dominion <> Self then
    Exit;
  if CurrentStar.Battle <> 0 then
    Exit;
  if RelocationAge < 135.0 then
    Exit;
  if NextRandomIntRange(1, 100, RandomState)
      <= Round(RemapClamped(RelocationAge, 135, 675, 100, 95)) then
    Exit;
  Count := 0;
  for I := 0 to CurrentStar.Ships.Count - 1 do
  begin
    Ship := TShip(CurrentStar.Ships[I]);
    if Ship.AbductedByPirateClan then
      Exit;
    if Ship.InNormalSpace
        and (Ship is TPirate)
        and (Ship.ScriptShip = nil)
        and (Ship.AbsoluteScriptOrder <= 0)
        and (Ship.Order in [soNone, soMove]) then
      Inc(Count);
  end;
  if Count < 5 then
    Exit;
  Count := 0;
  for I := 1 to Galaxy.Stars.Count - 1 do
  begin
    if CurrentStar.StarDistances[I].Distance > 40 then
      Break;
    Star := CurrentStar.StarDistances[I].Star;
    if (Star.ControlFaction = sfCoalition) and (Star.Status.CustomFaction = '') then
      for J := 0 to Star.Ships.Count - 1 do
      begin
        Ship := TShip(Star.Ships[J]);
        if Ship.InNormalSpace
            and (Ship.Order = soJump)
            and (TStar(Ship.OrderTarget).ControlFaction = sfCoalition)
            and (TStar(Ship.OrderTarget).Status.CustomFaction = '')
            and (Ship.EstimateOrderTravelTurns >= 2)
            and (Ship is TNormalShip)
            and (Ship.OwnerId <> oiPirate)
            and (Ship.TypeId in [stRanger..stTransport])
            and (Ship.ScriptShip = nil)
            and (Ship.AbsoluteScriptOrder <= 0) then
          Inc(Count);
      end;
  end;
  if Count > 0 then
  begin
    RelocationAge := (RelocationAge - 90) div 2;
    OrderTeleport(CurrentStar, Position, 10, True);
    Result := True;
  end;
end;

procedure TRuins.TryAbductDepartingShip(Ship: TShip);
var
  Candidate: TNormalShip;
begin
  if CurrentStar.Dominion <> Self then
    Exit;
  if not InHyperspace then
    Exit;
  if Order <> soTeleport then
    Exit;
  if OrderTarget <> CurrentStar then
    Exit;
  if Cardinal(OrderStateData) <= 1 then
    Exit;
  if Ship.ScriptShip <> nil then
    Exit;
  if Ship.HasScriptControl then
    Exit;
  if Ship.CountActiveArtefacts(t_ArtGiperJump) > 0 then
    Exit;
  if not (Ship is TNormalShip) then
    Exit;
  Candidate := TNormalShip(Ship);
  if Candidate.AbductedByPirateClan then
    Exit;
  if Candidate is TPirate then
    Exit;
  if Candidate.CurrentStanding in [ssPiratePassive..ssPirateMilitary] then
    Exit;
  if (GetPlayer <> nil)
      and (GetPlayer.QuestTargetDefendShip = Candidate)
      and (NextRandomIntRange(1, 100, RandomState) > 70) then
    Exit;
  if GetPlayer = Candidate then
  begin
    if Galaxy.CurrentTurn
        < 200 / GalaxyDifficultyTuning[Galaxy.DifficultyLevels[7]].GoodsEventDurationFactor
            + GalaxyWarmupTurns then
      Exit;
    if NextRandomIntRange(0, 100, RandomState)
            * GalaxyDifficultyTuning[Galaxy.DifficultyLevels[7]].GoodsEventDurationFactor
        < 40 then
      Exit;
  end;
  if Candidate.TypeId = stTransport then
    Candidate.AbductedByPirateClan := True
  else if Candidate.TypeId = stRanger then
    case (Candidate as TRanger).GetDominantCareer of
      rcTrader: Candidate.AbductedByPirateClan := NextRandomIntRange(1, 100, RandomState) > 30;
      rcWarrior: Candidate.AbductedByPirateClan := NextRandomIntRange(1, 100, RandomState) > 70;
      rcPirate: Candidate.AbductedByPirateClan := NextRandomIntRange(1, 100, RandomState) > 50;
    end;
  if Candidate.AbductedByPirateClan then
  begin
    Candidate.OrderTarget := CurrentStar;
    Candidate.OrderStateData := OrderStateData + NextRandomIntRange(1, 10, RandomState);
  end;
end;

procedure TRuins.ReportAbductionOutcome;
var
  Text: WideString;
  I, Abducted, Pirates: Integer;
  Ship: TShip;
begin
  Abducted := 0;
  Pirates := 0;
  for I := 0 to CurrentStar.Ships.Count - 1 do
  begin
    Ship := TShip(CurrentStar.Ships[I]);
    if Ship.AbductedByPirateClan then
      Inc(Abducted);
    if Ship.InNormalSpace
        and (Ship is TPirate)
        and (Ship.ScriptShip = nil)
        and (Ship.Order in [soNone, soMove]) then
      Inc(Pirates);
  end;
  Text := TextHighlightColorTag + GetFullName(' ') + EndColorTag + #13#10;
  if Abducted = 0 then
    Text := Text + LookupTalkText('Talk.PirateClan.RuinTalkAfterAbduct.Failure')
  else if Pirates = 0 then
    Text := Text + LookupTalkText('Talk.PirateClan.RuinTalkAfterAbduct.SuccessNoPirate')
  else
    Text := Text + LookupTalkText('Talk.PirateClan.RuinTalkAfterAbduct.Success');
  AddOrUpdatePlayerBubble(pmRadio, Galaxy.CurrentTurn, Text, '').Targets[0].ShipId := Id;
end;

function TRuins.EvaluateLocalForceBalance(Point: TPointF): Single;
var
  I: Integer;
  Ship: TShip;
  ReferenceStrength, RelationFactor, HullFraction: Single;
begin
  Result := 0;
  RefreshDerivedStats(True);
  HullFraction := Max(0.01, GetHull.HullPoints / GetHull.Weight);
  ReferenceStrength :=
      Max(
          1.0,
          Strength / (UsableWeaponCount + 7) + Galaxy.AverageRangerStrength * 0.1 * HullFraction
      );
  for I := 0 to CurrentStar.Ships.Count - 1 do
  begin
    Ship := TShip(CurrentStar.Ships[I]);
    RelationFactor := 1;
    if (Ship.DockedTo = Self) and ((FlyToStar = nil) or (FlyToStar = CurrentStar)) then
      RelationFactor := 0.75
    else if not Ship.InNormalSpace then
      Continue;
    if GetRelationLevelToShip(Ship) = rlHostile then
      RelationFactor := -1 * RelationFactor
    else if GetRelationLevelToShip(Ship) = rlExcellent then
      RelationFactor := 1 * RelationFactor
    else if GetRelationLevelToShip(Ship) = rlGood then
      RelationFactor := 0.5 * RelationFactor
    else
      Continue;
    if RelationFactor > 0 then
      RelationFactor := RelationFactor * HullFraction;
    Result :=
        Result
            + Ship.Strength
                / (Ship.UsableWeaponCount + 7)
                / ReferenceStrength
                * RelationFactor
                * Min(1.0, Ship.Speed / Max(100, PointDistance(Point, Ship.Position)));
  end;
end;

function TRuins.EvaluateRelocationPosition(Point: TPointF): Single;
var
  I, RangeSquared: Integer;
  Item: TItem;
begin
  Result := 0;
  if IsEquipmentUsable(GetCargoHook) then
  begin
    RangeSquared := GetCargoHookRangeSquared;
    for I := 0 to CurrentStar.Items.Count - 1 do
    begin
      Item := TItem(CurrentStar.Items[I]);
      if CanCargoHookHandleItem(Item, Self)
          and (PointDistanceSquared(Point, Item.Position) <= RangeSquared)
          and AcceptPickupItem(Item) then
        Result := Result + Item.Cost;
    end;
  end;
  Result := Result / Max(10, Galaxy.ComputeScaledMiniMoney(oiHuman));
  Result := Result * RemapClamped(RelocationAge, 30, 90, 0.3, 1);
  if CurrentStar.Battle <> 0 then
    Result := Result + EvaluateLocalForceBalance(Point);
end;

function TRuins.TryRepositionInStar: Boolean;
const
  StationTypes = [rstRangerCenter..rstCustomStation];
var
  SavedPoint, BestPoint: TPointF;
  InitialScore, BestScore, Score, Radius: Single;
  I: Integer;
begin
  Result := False;
  if (PickupTargets <> nil) and (PickupTargets.Count > 0) then
    Exit;
  if RelocationAge < 30 then
    Exit;
  for I := 0 to CurrentStar.Ships.Count - 1 do
    if TShip(CurrentStar.Ships[I]).AbductedByPirateClan
        and TShip(CurrentStar.Ships[I]).InHyperspace then
      Exit;
  SavedPoint := Position;
  InitialScore := EvaluateRelocationPosition(Position);
  BestScore := InitialScore;
  for I := 0 to 100 do
  begin
    RandomizePosition;
    Score := EvaluateRelocationPosition(Position);
    if (Score >= BestScore) and (DistanceToNearestShipByTypeMask(StationTypes) > 700) then
    begin
      BestScore := Score;
      BestPoint := Position;
    end;
  end;
  if ((InitialScore > 0) and (BestScore < InitialScore + 10)) or (BestScore < InitialScore + 5) then
  begin
    Position := SavedPoint;
    Exit;
  end;
  Radius := 100;
  for I := 0 to 100 do
  begin
    Position.X := BestPoint.X + NextRandomIntRange(-100, 100, RandomState) * 0.01 * Radius;
    Position.Y := BestPoint.Y + NextRandomIntRange(-100, 100, RandomState) * 0.01 * Radius;
    if (DistanceToNearestShipByTypeMask(StationTypes) > 700)
        and (Sqr(Position.X) + Sqr(Position.Y) >= Sqr(CurrentStar.SafeRadius) * 1.1) then
    begin
      Score := EvaluateRelocationPosition(Position);
      if Score >= BestScore then
      begin
        BestScore := Score;
        BestPoint := Position;
        Radius := Radius * 0.75;
      end;
    end;
  end;
  Position := SavedPoint;
  RelocationAge := (RelocationAge - 30) div 2;
  OrderTeleport(CurrentStar, BestPoint, 0, True);
  Result := True;
end;

function TRuins.TryRelocateToPirateStar: Boolean;
var
  I: Integer;
  Star: TStar;
  Candidates: TList;
  Constellation: TConstellation;
begin
  Result := False;
  if CurrentStar.Battle = 0 then
    Exit;
  if RelocationAge < 45 then
    Exit;
  if CurrentStar.Dominion <> Self then
    Exit;
  if EvaluateLocalForceBalance(Position) > -10 then
    Exit;
  Candidates := TList.Create;
  Constellation := CurrentStar.Constellation;
  for I := 0 to Constellation.Stars.Count - 1 do
  begin
    Star := TStar(Constellation.Stars[I]);
    if (Star <> CurrentStar)
        and (Star.ControlFaction = sfPirates)
        and (Star.Battle = 0)
        and not IsStarProtectedByScript(Star)
        and (Star.Dominion = nil)
        and (Star.Status.CustomFaction = '') then
      Candidates.Add(Star);
  end;
  if Candidates.Count = 0 then
    Candidates.Free
  else
  begin
    Star := TStar(Candidates[NextRandomIntRange(0, Candidates.Count - 1, RandomState)]);
    Candidates.Free;
    CurrentStar.Dominion := nil;
    Star.Dominion := Self;
    FlyToStar := Star;
    FlyDate := Galaxy.CurrentTurn + 1;
    RelocationAge := (RelocationAge - 150) div 2;
    Result := True;
  end;
end;

function TRuins.AcceptPickupItem(Item: TItem): Boolean;
begin
  Result := False;
  if TypeId = rstDominion then
  begin
    if not (Item.ItemType
        in [
            t_Food..t_ArtefactAntigrav,
            t_ArtDefToEnergy..t_ArtGiperJump,
            t_ArtDefToArms1..t_CustomWeapon,
            t_MicroModule]) then
      Exit;
  end
  else if not ((Item.ItemType in [t_Food..t_Narcotics, t_Hull..t_CustomWeapon])
      and (Item.OwnerId <> oiDominator)) then
    Exit;
  Result := True;
end;

procedure TRuins.ApplyInventoryMicroModulesToShopItems;
var
  I, J: Integer;
  Module: TItem;
  Item: TEquipment;
  Applied: Boolean;
begin
  Applied := True;
  while Applied do
  begin
    Applied := False;
    for I := 1 to Inventory.Count - 1 do
    begin
      Module := TItem(Inventory[I]);
      if Module is TMicroModule then
        for J := 0 to EquipmentShop.Count - 1 do
        begin
          Item := TEquipment(EquipmentShop[J]);
          if (Module as TMicroModule).CanInstallOn(Item) then
          begin
            Applied := True;
            ApplyMicroModule((Module as TMicroModule).MicroModuleIndex - 1, Item);
            Inventory.Delete(Inventory.IndexOf(Module));
            Module.Free;
            RefreshDerivedStats(True);
            Break;
          end;
        end;
      if Applied then
        Break;
    end;
  end;
end;

function TRuins.RelationToNonRanger(Ship: TShip): Byte;
begin
  if Ship.TypeId in [stKling, stTranclucator] then
    Result := 50
  else
    Result := 100;
end;

function TRuins.RelationToRanger(Ranger: Pointer): Byte;
begin
  Result := Byte(RangerRelations[Galaxy.Rangers.IndexOf(TObject(Ranger) as TRanger)]);
  if not NoLanding or (GetPlayer <> Ranger) then
    Result := Max(50, Result);
end;

procedure TRuins.ChangeRelationToRanger(Ranger: Pointer; Amount: Integer);
var
  Relation: Byte;
  NewRelation, Index: Integer;
begin
  Index := Galaxy.Rangers.IndexOf(TObject(Ranger) as TRanger);
  Relation := Byte(RangerRelations[Index]);
  if (Amount > 0) and (TShip(Ranger).GetEffectiveSkillLevel(psCharisma) > 0) then
    Inc(Amount, Round((TShip(Ranger).GetEffectiveSkillLevel(psCharisma)) * Amount * 0.2));
  NewRelation := Relation + Amount;
  if NewRelation < 0 then
    Relation := 0
  else if NewRelation > 100 then
    Relation := 100
  else
    Relation := NewRelation;
  RangerRelations[Index] := Pointer(Relation);
  if (Relation < RelationBadMin)
      and ((EnemyShip = nil) or (EnemyShip.CurrentStar <> CurrentStar)) then
    EnemyShip := TShip(Ranger);
  if GetPlayer = Ranger then
  begin
    if RandomIntRange(0, 100) = 0 then
      SysUtils.Sleep(1);
    if (Byte(RangerRelations[Index]) <> Relation) and not GR_Main.CCInterface.GetTamperDetected then
      GR_Main.CCInterface.SetTamperDetected(True);
  end;
end;

procedure TRuins.ReactToAttack(Attacker: TShip);
var
  I: Integer;
  Planet: TPlanet;
  Independent: Boolean;
begin
  EnemyShip := Attacker;
  if CurrentStanding = ssCustom then
    Exit;
  Independent :=
      not (CurrentStanding in FactionStandingMasks[CurrentStar.ControlFaction])
          or (CurrentStar.Status.CustomFaction <> '');
  if Attacker.TypeId = stRanger then
  begin
    ChangeRelationToRanger(Attacker, -10);
    if Independent then
      Exit;
    if (CurrentStar.ControlFaction = sfPirates) and (MainPiratePlanet <> nil) then
      MainPiratePlanet.ChangeRelationToRanger(Attacker, -10)
    else if CurrentStar.ControlFaction <> sfDominators then
      for I := 0 to CurrentStar.Planets.Count - 1 do
      begin
        Planet := TPlanet(CurrentStar.Planets[I]);
        if Planet.OwnerId <> oiUninhabited then
          Planet.ChangeRelationToRanger(Attacker, -10);
      end;
  end;
  if (Attacker.PartnerShip <> nil) and (Attacker.PartnerShip.TypeId = stRanger) then
  begin
    ChangeRelationToRanger(Attacker.PartnerShip, -5);
    if Independent then
      Exit;
    if (CurrentStar.ControlFaction = sfPirates) and (MainPiratePlanet <> nil) then
      MainPiratePlanet.ChangeRelationToRanger(Attacker.PartnerShip, -5)
    else if CurrentStar.ControlFaction <> sfDominators then
      for I := 0 to CurrentStar.Planets.Count - 1 do
      begin
        Planet := TPlanet(CurrentStar.Planets[I]);
        if Planet.OwnerId <> oiUninhabited then
          Planet.ChangeRelationToRanger(Attacker.PartnerShip, -5);
      end;
  end;
  if (Attacker is TTranclucator)
      and (TTranclucator(Attacker).OwnerShip <> nil)
      and (TTranclucator(Attacker).OwnerShip.TypeId = stRanger) then
  begin
    ChangeRelationToRanger(TTranclucator(Attacker).OwnerShip, -10);
    if Independent then
      Exit;
    if (CurrentStar.ControlFaction = sfPirates) and (MainPiratePlanet <> nil) then
      MainPiratePlanet.ChangeRelationToRanger(TTranclucator(Attacker).OwnerShip, -10)
    else if CurrentStar.ControlFaction <> sfDominators then
      for I := 0 to CurrentStar.Planets.Count - 1 do
      begin
        Planet := TPlanet(CurrentStar.Planets[I]);
        if Planet.OwnerId <> oiUninhabited then
          Planet.ChangeRelationToRanger(TTranclucator(Attacker).OwnerShip, -10);
      end;
  end;
  if not Independent
      and (Attacker is TNormalShip)
      and (TSystemKillCountArray((Attacker as TNormalShip).CurrentSystemKills)[
              Ord(CurrentStar.ControlFaction)]
          = 0) then
    TSystemKillCountArray((Attacker as TNormalShip).CurrentSystemKills)
        [Ord(CurrentStar.ControlFaction)] :=
        1;
end;

function TRuins.RecomputeFearState: Boolean;
begin
  Result := False;
end;

function TRuins.AcceptsRansomDemandFrom(Ship: TShip): Boolean;
begin
  Result := False;
end;

function TRuins.TrustsAttackRequester(Ship: TShip): Boolean;
begin
  Result := True;
end;

function TRuins.AcceptsAppealFrom(Ship: TShip): Boolean;
begin
  Result := False;
end;

procedure TRuins.ProcessCombatDialogue;
begin
end;

procedure TRuins.ReactToExtortionDemand(Ranger: Pointer);
begin
end;

function TRuins.BuildMoneyExtortionResponse(
    OtherShip: TShip;
    var Response: WideString;
    DemandedAmount: Integer
): Boolean;
begin
  Result := False;
  Response := 'Talk not supporting';
end;

function TRuins.BuildCargoExtortionResponse(OtherShip: TShip; var Response: WideString): Boolean;
begin
  Result := False;
  Response := 'Talk not supporting';
end;

function TRuins.BuildTrucePaymentResponse(
    OtherShip: TShip;
    var Response: WideString;
    OfferedAmount: Integer
): Boolean;
begin
  Result := False;
  Response := 'Talk not supporting';
end;

function TRuins.BuildAttackRequestResponse(
    Requester: TShip;
    var Response: WideString;
    Target: TShip
): Boolean;
begin
  Result := False;
  Response := 'Talk not supporting';
end;

function TRuins.AcceptPartnershipOffer(
    OtherShip: TShip;
    var Response: WideString;
    PaymentAmount: Integer
): Boolean;
begin
  Result := False;
  Response := 'Not supporting';
end;

function TRuins.BuildPartnershipOfferResponse(
    OtherShip: TShip;
    var Response: WideString;
    PaymentAmount: Integer
): Boolean;
begin
  Result := False;
  Response := 'Not supporting';
end;

procedure TRuins.ForceGoodsForSale(GoodsMask: TItemTypeMask);
var
  Good: Byte;
begin
  for Good := Low(TGoodsIndex) to High(TGoodsIndex) do
    if Good in GoodsMask then
    begin
      ShopGoods[Good].PriceState :=
          GoodsMarket[Good].MinPrice * NextRandomFloatRange(0.9, 1.1, RandomState);
      ShopGoods[Good].Count :=
          Max(
              ShopGoods[Good].Count
                  + NextRandomIntRange(1, GoodsMarket[Good].BaseStock div 10 + 1, RandomState),
              GoodsMarket[Good].BaseStock div 10 + 1
          );
      ShopGoods[Good].PurchasePrice := Round(ShopGoods[Good].PriceState);
      ShopGoods[Good].BaseSalePrice := Max(1, Round(ShopGoods[Good].PriceState * 0.98 - 1));
    end;
end;

procedure TRuins.GenerateCombatSkills;
var
  Level, Accuracy, Maneuverability: Integer;
begin
  Level := Round(RemapClamped(Galaxy.TechLevel, 3, 8, 0, 4));
  if Galaxy.GetFactionControlPercent(sfDominators) < 40 then
    Dec(Level, 2);
  if Galaxy.GetFactionControlPercent(sfDominators) > 80 then
    Inc(Level);
  if Galaxy.WarDeltaWin[1] > -3 then
    Inc(Level);
  if Galaxy.WarDeltaWin[1] < 3 then
    Dec(Level, 2);
  Accuracy := NextRandomIntRange(Level - 1, Level + 1, RandomState);
  Maneuverability := NextRandomIntRange(Level - 1, Level + 1, RandomState);
  Accuracy := Min(5, Max(0, Accuracy));
  Maneuverability := Min(5, Max(0, Maneuverability));
  BaseSkills[psAccuracy] := Accuracy;
  BaseSkills[psManeuverability] := Maneuverability;
end;

procedure TRuins.RandomizePosition;
var
  Point: TPointF;
begin
  Point := SelectTeleportArrivalPoint(CurrentStar);
  Position := Point;
end;

function TRuins.SelectTeleportArrivalPoint(Star: TStar): TPointF;
var
  Attempts: Integer;
  Planet: TPlanet;
  LastPlanet: Integer;
  Polar: TPolarPoint;

  function IsStationArrivalPointClear(Point: TPointF): Boolean;
  var
    I: Integer;
    Ship: TShip;
    DistanceSquared: Single;
  begin
    Result := False;
    for I := 0 to Star.Ships.Count - 1 do
    begin
      Ship := TShip(Star.Ships[I]);
      if (Ship is TRuins) and (Ship <> Self) then
      begin
        DistanceSquared := PointDistanceSquared(Point, Ship.Position);
        if DistanceSquared <= 490000 then
          Exit;
      end;
    end;
    Result := True;
  end;
begin
  Attempts := 0;
  LastPlanet := Star.Planets.Count - 1;
  if Galaxy.AreStationsNearStarsEnabled then
    LastPlanet := LastPlanet div 2;
  repeat
    Planet := TPlanet(Star.Planets[NextRandomIntRange(0, LastPlanet, RandomState)]);
    Polar.Radius :=
        Planet.Radius + Planet.Orbit.Radius + 100 + NextRandomIntRange(0, 50, RandomState);
    Polar.AngleDegrees := NextRandomIntRange(0, 359, RandomState);
    Result := PolarToPoint(Polar);
    Inc(Attempts);
  until IsStationArrivalPointClear(Result) or (Attempts > 1000);
end;

function TRuins.AdjustItemEvaluation(Item: TItem; PriceMode: Byte; Effectiveness: Single): Single;
begin
  Result := Effectiveness;
end;

function TRuins.EvaluateStatBonus(BonusKind: TEquipmentBonusKind; Value: Integer): Single;
const
  ScannerFlags = [dkScanBonus..dkDroidBlock];
  NoFlags = [];
begin
  Result := 0;
  if Value = 0 then
    Exit;
  case BonusKind of
    bonHull: Result := Value * 300;
    bonRadar: Result := ShortInt(GetRadar = nil);
    bonScan: Result := Value * 20 * CountWeaponsByDamageFlags(ScannerFlags);
    bonDroid: Result := Value * 20 / Max(0.1, GetHull.GetFragilityFactor(NoFlags));
    bonDef: Result := Value * 8 * 100 / Max(5, 100 - Value) * 45 / Max(5, 45 - Value);
    bonWEnergy: Result := Value * 10;
    bonWSplinter: Result := Value * 10;
    bonWMissile: Result := Value * 10 * (0.1 + ShortInt(GetRadarRange > 0) * 0.9);
    bonWRadius: Result := Value;
    bonSkill1..bonSkill6:
    begin
      if Value > 0 then
        Result :=
            Min(
                    6
                        - GetEffectiveSkillLevel(
                            EquipmentBonusSkills[Ord(BonusKind) - Ord(bonSkill1)]),
                    Value)
                * StationSkillBonusWeights[BonusKind];
      if (Value > 0)
          and (Value + GetEffectiveSkillLevel(EquipmentBonusSkills[Ord(BonusKind) - Ord(bonSkill1)])
              > 6) then
        Result :=
            Result
                + (StationSkillBonusWeights[BonusKind] * 0.05)
                    * (Value
                        + GetEffectiveSkillLevel(
                            EquipmentBonusSkills[Ord(BonusKind) - Ord(bonSkill1)])
                        - 6);
      if Value < 0 then
        Result :=
            Min(
                    GetEffectiveSkillLevel(EquipmentBonusSkills[Ord(BonusKind) - Ord(bonSkill1)]),
                    -Value)
                * -StationSkillBonusWeights[BonusKind];
      if (Value < 0)
          and (Value + GetEffectiveSkillLevel(EquipmentBonusSkills[Ord(BonusKind) - Ord(bonSkill1)])
              < 0) then
        Result :=
            Result
                + (StationSkillBonusWeights[BonusKind] * 0.03)
                    * (Value
                        + GetEffectiveSkillLevel(
                            EquipmentBonusSkills[Ord(BonusKind) - Ord(bonSkill1)]));
    end;
  end;
  if TypeId = rstDominion then
    case BonusKind of
      bonHook: Result := (Min(Value, HullBaseSize * EquipmentSizeFactors[5]) + Value * 0.1) * 1.0;
      bonHookRadius: Result := Value * 1.5;
    end;
end;

function TRuins.EvaluateWeaponDamage(
    Weapon: TWeapon;
    IncludeAdditiveBonuses: Boolean;
    BaseDamage: Single
): Single;
const
  ScannerFlags = [dkScanBonus..dkDroidBlock];
  ShockFlags = [dkShock];
  AcidFlags = [dkAcid];
var
  ScannerFactor, StatusFactor: Single;
  Flags: TDamageFlagSet;
  HasOtherWeapon: Boolean;
  I, ShotTotal: Integer;
begin
  Flags := Weapon.GetDamageFlags;
  if (Flags * ScannerFlags <> []) and (GetScanner <> nil) and (GetRadar <> nil) then
    ScannerFactor :=
        RemapClamped(
            GetScannerPower
                - DefenseDamageFactorToPercent(GetGeneratedDefenseDamageFactor(Galaxy.TechLevel))
                + 1,
            -5,
            10,
            0.1,
            2
        )
  else
    ScannerFactor := 0;
  Result := BaseDamage * GetWeaponArtefactDamageFactor(Weapon);
  if dkDrain in Flags then
    Result := Result * 1.5;
  if dkShock in Flags then
    Result := Result * (1.05 + CountWeaponsByDamageFlags(ShockFlags) * 0.05);
  if dkAcid in Flags then
    Result := Result * 1.05;
  StatusFactor := 1;
  if dkScanBonus in Flags then
    StatusFactor := StatusFactor * (1 + ScannerFactor * 0.1);
  if dkBonusToDamaged in Flags then
    StatusFactor := StatusFactor * (1 + ScannerFactor * 0.1);
  StatusFactor := StatusFactor - 1;
  if IncludeAdditiveBonuses then
  begin
    if dkBlockWeapon in Flags then
      Result := Result + ScannerFactor * 5;
    if dkDroidBlock in Flags then
      Result := Result + ScannerFactor * 5;
    Result := Result + Integer(CountWeaponsByDamageFlags(AcidFlags)) * Weapon.GetShotCount;
    if dkAcid in Flags then
    begin
      ShotTotal := 1;
      for I := 1 to CountEquippedWeapons do
        Inc(ShotTotal, Weapons[I].GetShotCount);
      Result := Result + ShotTotal * 2;
    end;
  end;
  case Weapon.GetWeaponInfo.ShotType of
    wstRocket: Result := Result * 1.1 * Weapon.GetShotCount * (1 + StatusFactor);
    wstMissile:
      Result :=
          Result
              * (1.1 + Weapon.GetWeaponInfo.SecondaryDamageRadius * 0.5 * 0.01 + StatusFactor)
              * Weapon.GetShotCount;
    wstTorpedo:
      Result :=
          Result * (1 + Weapon.GetWeaponInfo.SecondaryDamageRadius * 0.5 * 0.01 + StatusFactor);
    wstChain: Result := Result * (1.1 + (Weapon.GetShotCount - 1) * 0.2) * (1 + StatusFactor);
    wstSplash:
      Result :=
          Result * (1 + Weapon.GetWeaponInfo.SecondaryDamageRadius * 1.0 * 0.01 + StatusFactor);
    wstAreaDamage: Result := Result * (1 + Weapon.Range * 1.3 * 0.01 + StatusFactor);
  else
    Result := Result * (1 + StatusFactor);
  end;
  Result := Result * Weapon.GetAttackCount;
  HasOtherWeapon := False;
  for I := 1 to CountEquippedWeapons do
    if not (Weapons[I].GetWeaponInfo.ShotType in [wstAreaDamage..wstRocket]) then
      HasOtherWeapon := True;
  if not HasOtherWeapon and (Weapon.GetWeaponInfo.ShotType in [wstAreaDamage..wstRocket]) then
    Result := Result * 0.5;
end;

procedure TRuins.RefreshCurrentStanding;
var
  StandingMode: TScriptStandingOverrideMode;
begin
  StandingMode := GetScriptStandingOverrideMode;
  if StandingMode = ssmCustomFaction then
    CurrentStanding := ssCustom
  else if StandingMode <> ssmFixed then
    if TypeId <> rstCustomStation then
      CurrentStanding := StationDefaultStandings[TypeId];
end;

function TRuins.GeneratePlanetHullOffer(Ship: TObject; Planet: TPlanet): THull;
var
  Buyer: TShip;
  ModuleIndex: Integer;
begin
  Result := nil;
  if (Planet <> nil) and (Ship <> nil) and (Ship is TShip) then
  begin
    Buyer := TShip(Ship);
    Result := Planet.GenerateHullOffer(TShip(Ship));
    if Result <> nil then
    begin
      ModuleIndex := Result.SpecialModuleIndex - 1;
      if ModuleIndex < 0 then
      begin
        if Buyer.CanGenerateSpecialHullModule then
          ModuleIndex := SelectHullOfferSpecialMicroModule(Result, Planet);
        if (Buyer.GetHull.SpecialModuleIndex > 0)
            and (GetPlayer <> Buyer)
            and (ModuleIndex < 0) then
          ModuleIndex := Buyer.GetHull.SpecialModuleIndex - 1;
        if ModuleIndex >= 0 then
          ApplySpecialMicroModule(ModuleIndex, Result);
      end;
    end;
  end;
end;

function TRuins.GenerateHullOffer(Ship: TObject; Planet: TPlanet): THull;
var
  Buyer: TShip;
  Count, MinLevel, MaxLevel, MinSize, MaxSize, Size: Integer;
  HullType: THullType;
  Owner: TOwnerId;
  Series, ModuleIndex: Integer;
  Flagship: Boolean;
begin
  Result := nil;
  if TypeId = rstCustomStation then
  begin
    Result := GeneratePlanetHullOffer(Ship, Planet);
    Exit;
  end;
  if (Ship <> nil) and (Ship is TShip) then
  begin
    Buyer := TShip(Ship);
    Count := 0;
    for HullType := htRanger to htFlagship do
      if HullType in StationOfferHullTypes[TypeId] then
        Inc(Count);
    if Count = 0 then
      Exit;
    Count := NextRandomIntRange(1, Count, RandomState);
    for HullType := htRanger to htFlagship do
    begin
      if HullType in StationOfferHullTypes[TypeId] then
        Dec(Count);
      if Count = 0 then
        Break;
    end;
    Flagship := (Buyer is TWarrior) and ((Buyer as TWarrior).WarriorType = wtFlagship);
    if Flagship then
      HullType := htFlagship;
    if (GetPlayer = Buyer)
        or (Buyer.GetHull.HullType = htSpecial)
        or (Buyer.GetHull.HullType = HullType) then
    begin
      MaxLevel := Planet.InventionLevels[EquipmentInventionIndices[t_Hull]];
      MinLevel := Max(1, MaxLevel div 2 - 1);
      MaxLevel := Min(8, MaxLevel + StationOfferHullLevelBonus[TypeId]);
      case Galaxy.GetHullGrowthMod of
        1:
        begin
          Size := Buyer.GetHull.EstimateCapacityWithoutBonuses;
          if Flagship then
            Size := Size div 2;
          MinSize := Size div 2;
          if HullType in [htTransport, htLiner] then
            MaxSize := Size + (40 + 10 * Ord(TypeId = rstBusinessCenter)) * Galaxy.TechLevel
          else
            case HullType of
              htDiplomat: MaxSize := Size + 10 * Galaxy.TechLevel;
            else
              MaxSize := Size + 25 * Galaxy.TechLevel;
            end;
          MinSize :=
              Max(
                  MinSize,
                  Round(HullBaseSize * EquipmentSizeFactors[5 - Ord(TypeId = rstBusinessCenter)])
              );
          MaxSize :=
              Galaxy.ScaleIntByTechLevel(Round(HullBaseSize * EquipmentSizeFactors[4]), MaxSize);
        end;
        2:
        begin
          Size := Buyer.GetHull.Weight;
          if Flagship then
            Size := Size div 2;
          MinSize :=
              Round(HullBaseSize * EquipmentSizeFactors[5 - Ord(TypeId = rstBusinessCenter)]);
          MaxSize :=
              Min(
                  Size,
                  Round(HullBaseSize * EquipmentSizeFactors[Galaxy.ScaleIntByTechLevel(5, 1)])
              );
        end;
      else
        begin
          Size := Buyer.GetHull.Weight;
          if Flagship then
            Size := Size div 2;
          MinSize := Size div 2;
          if HullType in [htTransport, htLiner] then
            MaxSize := Size + 300 + 100 * Ord(TypeId = rstBusinessCenter)
          else
            case HullType of
              htDiplomat: MaxSize := Size + 50;
            else
              MaxSize := Size + 200;
            end;
          MinSize :=
              Max(
                  MinSize,
                  Round(HullBaseSize * EquipmentSizeFactors[5 - Ord(TypeId = rstBusinessCenter)])
              );
          MaxSize :=
              Min(
                  MaxSize,
                  Round(HullBaseSize * EquipmentSizeFactors[Galaxy.ScaleIntByTechLevel(3, 1)])
              );
        end;
      end;
      Owner := PickRandomEquipmentOwner(RandomState);
      if (Buyer.GetHull.OwnerId = Owner) or (GetPlayer = Buyer) then
      begin
        Result := THull.Create;
        Series := -1;
        ModuleIndex := -1;
        Result.OwnerId := Owner;
        Result.PirateBuilt :=
            (CurrentStar.ControlFaction = sfPirates) and (CurrentStar.Status.CustomFaction = '');
        if Buyer.CanGenerateSpecialHullModule then
          ModuleIndex := SelectHullOfferSpecialMicroModule(Result, Planet);
        if ModuleIndex < 0 then
        begin
          if Buyer.CanGenerateSpecialHullModule then
            ModuleIndex := SelectHullOfferSpecialMicroModule(Result, Planet);
          if HullType in StationOfferRareHullTypes[TypeId] then
            Series := Galaxy.SelectHullSeries(Owner, HullType, 1, 100)
          else
            Series := Galaxy.SelectHullSeries(Owner, HullType, 1, 30);
        end;
        if Flagship then
          Result.Init(
              NextRandomIntRange(MinSize * 2, MaxSize * 2, RandomState),
              NextRandomIntRange(MinLevel, MaxLevel, RandomState),
              Owner,
              htFlagship,
              Series,
              Result.PirateBuilt
          )
        else
          Result.Init(
              NextRandomIntRange(MinSize, MaxSize, RandomState),
              NextRandomIntRange(MinLevel, MaxLevel, RandomState),
              Owner,
              HullType,
              Series,
              Result.PirateBuilt
          );
        if (Buyer.GetHull.SpecialModuleIndex > 0)
            and (GetPlayer <> Buyer)
            and (ModuleIndex < 0) then
          ModuleIndex := Buyer.GetHull.SpecialModuleIndex - 1;
        if ModuleIndex >= 0 then
          ApplySpecialMicroModule(ModuleIndex, Result);
      end;
    end;
  end;
end;

function TRuins.GenerateWeaponOffer(Ship: TObject; Planet: TPlanet): TWeapon;
var
  Buyer: TShip;
  Attempts, MinLevel, MaxLevel, MinSize, MaxSize: Integer;
  Availability: TWeaponAvailabilityMask;
  Info: PWeaponInfo;
  Owner, CandidateOwner: TOwnerId;
  ModuleIndex: Integer;
begin
  Result := nil;
  if (Ship <> nil) and (Ship is TShip) then
  begin
    Buyer := TShip(Ship);
    Availability := [waFree];
    if (Buyer.TypeId = stKling) and (OwnerId in PlanetOwnerMasks.Dominators) then
      Availability := Availability + [waNotSoldAndNodeRepair];
    if (Buyer.TypeId in [stRanger, stPirate])
        and (CurrentStanding in FactionStandingMasks[sfPirates])
        and ((CurrentStar.ControlFaction = sfPirates)
            or not (CurrentStanding in FactionStandingMasks[sfCoalition])) then
      Availability := Availability + [waPirateOnly];
    if (Buyer.TypeId in [stRanger..stWarrior])
        and (CurrentStanding in FactionStandingMasks[sfCoalition])
        and ((CurrentStar.ControlFaction = sfCoalition)
            or not (CurrentStanding in FactionStandingMasks[sfPirates])) then
      Availability := Availability + [waCoalitionOnly, waMalocOnly..waGaalOnly];
    // The native counter guard has no back edge: only one offer is generated.
    Attempts := 0;
    if Attempts <= 100 then
    begin
      Inc(Attempts);
      Info :=
          Galaxy.SelectWeaponInfo(RandomState, Availability, Planet.InventionLevels[piMainTech], 1);
      AdvanceRandomSeed(RandomState);
      if not (Buyer.TypeId in [stRanger, stPirate])
          and (Info.ShotType in [wstTorpedo..wstRocket]) then
      begin
        if Buyer.CountDirectFireWeapons > Buyer.CountMissileWeapons then
          ;
      end;
      MinSize := Round(Info.AverageSize * EquipmentSizeFactors[5]);
      MaxSize := Round(Info.AverageSize * EquipmentSizeFactors[1]);
      if (Buyer is TWarrior) and ((Buyer as TWarrior).WarriorType = wtFlagship) then
      begin
        MinSize := MinSize * 2;
        MaxSize := MaxSize * 2;
      end;
      MinLevel := 1;
      MaxLevel :=
          Min(Planet.InventionLevels[piMainTech], Planet.InventionLevels[Info.InventionIndex]);
      MinLevel := Max(MinLevel, MaxLevel div 2 - 1);
      MaxLevel := Min(8, MaxLevel + StationOfferWeaponLevelBonus[TypeId]);
      Owner := PickRandomEquipmentOwner(RandomState);
      if (CurrentStar.ControlFaction = sfPirates)
          and (CurrentStanding in FactionStandingMasks[sfPirates])
          and ((NextRandomIntRange(1, 100, RandomState) < 70)
              or (Galaxy.CoalitionDefeatedTurn <> 0)) then
        Owner := oiPirate;
      for CandidateOwner := oiMaloc to oiPirate do
        if OwnerWeaponAvailability[CandidateOwner] = Info.Availability then
        begin
          Owner := CandidateOwner;
          Break;
        end;
      Result :=
          CreateGeneratedWeapon(
              Info,
              NextRandomIntRange(MinSize, MaxSize, RandomState),
              NextRandomIntRange(MinLevel, MaxLevel, RandomState),
              Owner
          );
      if (Buyer is TWarrior) and ((Buyer as TWarrior).WarriorType = wtFlagship) then
      begin
        Result.DetailImprovement := 3;
        Result.Improve(ikAny);
      end
      else if Buyer.CanGenerateMicroModuleForLoadout then
      begin
        ModuleIndex := SelectWeaponOfferSpecialMicroModule(Result, Planet);
        if ModuleIndex >= 0 then
          ApplySpecialMicroModule(ModuleIndex, Result);
      end;
    end;
  end;
end;

function TRuins.GenerateEquipmentOffer(
    Ship: TObject;
    Planet: TPlanet;
    ItemType: TItemType
): TEquipment;
var
  Buyer: TShip;
  Attempts, Priority, ModuleIndex, MinLevel, MaxLevel, MinSize, MaxSize, SpecialModule: Integer;
  Owner: TOwnerId;
begin
  Result := nil;
  if (Ship = nil) or not (Ship is TShip) then
    Exit;
  Buyer := TShip(Ship);
  if ItemType in [t_FuelTanks..t_DefGenerator] then
  begin
    if not (ItemType in [t_FuelTanks, t_Engine])
        and (Buyer.GetSlotCountForItemType(ItemType) = 0)
        and (GetPlayer <> Buyer) then
      Exit;
    MinLevel := 1;
    MaxLevel := Planet.InventionLevels[EquipmentInventionIndices[ItemType]];
    MinLevel := Max(MinLevel, MaxLevel div 2 - 1);
    MaxLevel := Min(8, MaxLevel + StationOfferEquipmentLevelBonus[TypeId, ItemType]);
    MinSize := Round(GetAverageItemSize(ItemType) * EquipmentSizeFactors[5]);
    MaxSize := Round(GetAverageItemSize(ItemType) * EquipmentSizeFactors[1]);
    if (Buyer is TWarrior) and ((Buyer as TWarrior).WarriorType = wtFlagship) then
    begin
      MinSize := MinSize * 2;
      MaxSize := MaxSize * 2;
    end;
    Owner := PickRandomEquipmentOwner(RandomState);
    if (CurrentStar.ControlFaction = sfPirates)
        and (CurrentStanding in FactionStandingMasks[sfPirates])
        and ((NextRandomIntRange(1, 100, RandomState) < 70)
            or (Galaxy.CoalitionDefeatedTurn <> 0)) then
      Owner := oiPirate;
    Result :=
        CreateGeneratedEquipment(
            ItemType,
            NextRandomIntRange(MinSize, MaxSize, RandomState),
            NextRandomIntRange(MinLevel, MaxLevel, RandomState),
            Owner
        );
    if Buyer.CanGenerateMicroModuleForLoadout then
    begin
      SpecialModule := SelectEquipmentOfferSpecialMicroModule(Result, Planet);
      if SpecialModule >= 0 then
        ApplySpecialMicroModule(SpecialModule, Result);
    end;
  end
  else if ItemType in [t_IndustrialLaser..t_CustomWeapon] then
    Result := GenerateWeaponOffer(Ship, Planet)
  else if ItemType = t_Hull then
    Result := GenerateHullOffer(Ship, Planet);
  if Result = nil then
    Exit;
  case TypeId of
    rstBusinessCenter:
    begin
      Result.Cost := Min(Int64(MaxMonetaryValue), Round(Result.Cost * 1.2));
      Result.ConditionPercent := NextRandomIntRange(70, 100, RandomState);
    end;
    rstMedicalBase: Result.ConditionPercent := NextRandomIntRange(1, 100, RandomState);
    rstPirateBase: Result.ConditionPercent := NextRandomIntRange(0, 60, RandomState);
    rstMilitaryBase: Result.ConditionPercent := NextRandomIntRange(60, 100, RandomState);
    rstDominion: Result.ConditionPercent := NextRandomIntRange(0, 60, RandomState);
  end;
  if Result.CanImprove then
    if TypeId = rstScienceBase then
      case NextRandomIntRange(0, 100, RandomState) of
        0..70: Result.Improve(ikMinor);
        71..90: Result.Improve(ikMedium);
        91..100: Result.Improve(ikMajor);
      end
    else if TypeId = rstRangerCenter then
      case NextRandomIntRange(0, 100, RandomState) of
        0..10: Result.Improve(ikMinor);
        11..20: Result.Improve(ikMedium);
        21..22: Result.Improve(ikMajor);
      end
    else
      case NextRandomIntRange(0, 100, RandomState) of
        0..10: Result.Improve(ikMinor);
        11..20: Result.Improve(ikMedium);
        21..23: Result.Improve(ikMajor);
      end;
  Attempts := 0;
  if (TypeId = rstDominion) and (NextRandomIntRange(0, 100, RandomState) > 50) then
    repeat
      Priority := Round(RemapClamped(Galaxy.TechLevel, 3, 7, 70, 0));
      ModuleIndex :=
          Galaxy.SelectMicroModule(
              Priority + Attempts div 5,
              Min(100, Priority + 20 + Attempts * 4),
              AdvanceRandomSeed(RandomState),
              Self
          );
      if CanInstallMicroModule(ModuleIndex, Result) then
      begin
        ApplyMicroModule(ModuleIndex, Result);
        Break;
      end;
      Inc(Attempts);
    until Attempts > 50;
end;

function TRuins.GenerateEquipmentOfferBatch(
    Ship: TShip;
    UnusedForceGeneratedOffers: Boolean
): TObjectList;
type
  TQuotasByItemType = array[t_Hull..WeaponCategoryItemType] of Integer;
var
  Item: TEquipment;
  I, J: Integer;
  Kind: TItemType;
  Planet: TPlanet;
begin
  Result := TObjectList.Create;
  for J := 1 to StationEquipmentOfferQuotas[TypeId].Hulls do
  begin
    Planet := TPlanet(CurrentStar.SelectRandomInhabitedPlanet);
    Item := GenerateEquipmentOffer(Ship, Planet, t_Hull);
    if Item <> nil then
      Result.Add(Item);
  end;
  for I := 1 to CountItemTypesInMask([Ord(t_FuelTanks)..Ord(t_DefGenerator)]) do
  begin
    Kind := TItemType(GetItemTypeFromMask([Ord(t_FuelTanks)..Ord(t_DefGenerator)], I));
    for J := 1 to TQuotasByItemType(StationEquipmentOfferQuotas[TypeId])[Kind] do
    begin
      Planet := TPlanet(CurrentStar.SelectRandomInhabitedPlanet);
      Item := GenerateEquipmentOffer(Ship, Planet, Kind);
      if Item <> nil then
        Result.Add(Item);
    end;
  end;
  for I := 1 to StationEquipmentOfferQuotas[TypeId].Weapons do
  begin
    Planet := TPlanet(CurrentStar.SelectRandomInhabitedPlanet);
    Item := GenerateEquipmentOffer(Ship, Planet, WeaponCategoryItemType);
    if Item <> nil then
      Result.Add(Item);
  end;
end;

procedure TRuins.UpdateGoodsMarketState;
var
  Good: Byte;
  TargetPrice, PriceStep: Single;
  TargetCount, CountStep: Integer;
  Race: TOwnerId;
begin
  if ShopUpdateMode in [sumDisabled, sumEquipmentOnly] then
    Exit;
  Race := PilotRace;
  for Good := Low(TGoodsIndex) to High(TGoodsIndex) do
  begin
    TargetCount :=
        Round(
            GoodsMarket[Good].BaseStock
                * PlanetRaceMarket[Race].GoodsFactors[Good].StockFactor
                * StationGoodsFactors[TypeId, Good].StockFactor
        );
    TargetPrice :=
        GoodsMarket[Good].AveragePrice
            * PlanetRaceMarket[Race].GoodsFactors[Good].PriceFactor
            * StationGoodsFactors[TypeId, Good].PriceFactor
            / RemapClamped(ShopGoods[Good].Count, TargetCount * 0.3, TargetCount * 2, 0.8, 1.2);
    if TargetPrice > GoodsMarket[Good].MinPrice then
      TargetPrice := Min(TargetPrice, GoodsMarket[Good].MaxPrice + 1)
    else
      TargetPrice := Max(TargetPrice, GoodsMarket[Good].MinPrice - 1);
    if ShopGoods[Good].PriceState - TargetPrice >= 0 then
      PriceStep := TargetPrice * NextRandomFloatRange(0.0035, 0.006, RandomState)
    else
      PriceStep := -TargetPrice * NextRandomFloatRange(0.0035, 0.006, RandomState);
    case NextRandomIntRange(1, 100, RandomState) of
      1..70: ShopGoods[Good].PriceState := ShopGoods[Good].PriceState - PriceStep;
      71..90:;
    else
      ShopGoods[Good].PriceState := ShopGoods[Good].PriceState + PriceStep;
    end;
    if ShopGoods[Good].PriceState < GoodsMarket[Good].MinPrice div 2 then
      ShopGoods[Good].PriceState := GoodsMarket[Good].MinPrice div 2
    else if ShopGoods[Good].PriceState > GoodsMarket[Good].MaxPrice * 2 then
      ShopGoods[Good].PriceState := GoodsMarket[Good].MaxPrice * 2;
    ShopGoods[Good].PurchasePrice := Max(2, Round(ShopGoods[Good].PriceState));
    ShopGoods[Good].BaseSalePrice :=
        Max(
            ShopGoods[Good].PurchasePrice div 2 + 1,
            Round(
                ShopGoods[Good].PriceState
                        * RemapClamped(
                            ShopGoods[Good].Count,
                            TargetCount,
                            TargetCount * 2,
                            0.9,
                            0.7)
                    - 1
            )
        );
    if ShopGoods[Good].Count - TargetCount >= 0 then
      CountStep :=
          Round(
              TargetCount * NextRandomFloatRange(0.0025, 0.005, RandomState)
                  + NextRandomUnitFloat(RandomState)
          )
    else
      CountStep :=
          Round(
              -TargetCount * NextRandomFloatRange(0.0025, 0.005, RandomState)
                  - NextRandomUnitFloat(RandomState)
          );
    case NextRandomIntRange(1, 100, RandomState) of
      1..20: Dec(ShopGoods[Good].Count, CountStep);
      21..95:;
    else
      Inc(ShopGoods[Good].Count, CountStep);
    end;
    if ShopGoods[Good].Count < 0 then
      ShopGoods[Good].Count := 0;
  end;
end;

function TRuins.CalculateRepairCost(Ship: TShip; out EquipmentCost: Integer): Integer;
var
  I: Integer;
  Item: TEquipment;
  EquipmentFactor, ArtefactFactor: Single;
begin
  Result := 0;
  EquipmentFactor := 1;
  // Keep the native byte load followed by signed extension under DCC32 O-.
  if TypeId = rstMilitaryBase then
    EquipmentFactor := RemapClamped(Ord(GetPlayer.Rank), 0, 7, 0.9, 0.2);
  if TypeId = rstPirateBase then
    EquipmentFactor := 0.84;
  for I := 0 to Ship.Inventory.Count - 1 do
  begin
    Item := TEquipment(Ship.Inventory[I]);
    if (not (Item is TWeapon)
            or (TWeapon(Item).GetWeaponInfo.Availability <> waNotSoldAndNodeRepair)
            or CanRepairArtefactsAtLocation)
        and CanRepairEquipmentTech(Item)
        and ((Item.ItemType = t_Hull)
            or ((Item.EquippedFlag <> 0) and (Item.ConditionPercent < 90))) then
      Inc(Result, Round(Item.CalculateRepairCost * EquipmentFactor));
  end;
  EquipmentCost := Result;
  if CanRepairArtefactsAtLocation then
  begin
    ArtefactFactor := 1;
    if TypeId = rstScienceBase then
      ArtefactFactor := 0.84;
    if TypeId = rstPirateBase then
      ArtefactFactor := 0.84;
    for I := 0 to Ship.Artefacts.Count - 1 do
    begin
      Item := TEquipment(Ship.Artefacts[I]);
      if (Item.EquippedFlag <> 0) and (Item.ConditionPercent < 90) then
        Inc(Result, Round(Item.CalculateRepairCost * ArtefactFactor));
    end;
  end;
end;

function TRuins.GetRepairCost(Ship: TShip): Integer;
var
  EquipmentCost: Integer;
begin
  Result := CalculateRepairCost(Ship, EquipmentCost);
end;

procedure TRuins.RepairShipEquipment(Ship: TShip);
var
  I: Integer;
  Item: TEquipment;
begin
  if GetRepairCost(Ship) > Ship.Money then
    Exit;
  Ship.SetMoney(Ship.Money - GetRepairCost(Ship));
  for I := 0 to Ship.Inventory.Count - 1 do
  begin
    Item := TEquipment(Ship.Inventory[I]);
    if (not (Item is TWeapon)
            or (TWeapon(Item).GetWeaponInfo.Availability <> waNotSoldAndNodeRepair)
            or CanRepairArtefactsAtLocation)
        and CanRepairEquipmentTech(Item)
        and ((Item.ItemType = t_Hull)
            or ((Item.EquippedFlag <> 0) and (Item.ConditionPercent < 90))) then
      Item.Repair;
  end;
  if CanRepairArtefactsAtLocation then
    for I := 0 to Ship.Artefacts.Count - 1 do
    begin
      Item := TEquipment(Ship.Artefacts[I]);
      if (Item.EquippedFlag <> 0) and (Item.ConditionPercent < 90) then
        Item.Repair;
    end;
end;

function TRuins.GetNodeSaleBatchSize: Integer;
begin
  Result := Min(NodeReserve, 250);
end;

function TRuins.FindPirateBaseWithNodes: TRuins;
var
  I, J, Index: Integer;
  Star: TStar;
  Ship: TShip;
begin
  Index := Galaxy.Stars.IndexOf(CurrentStar);
  for I := 0 to Galaxy.Stars.Count - 1 do
  begin
    IncrementWrapped(Index, 0, Galaxy.Stars.Count - 1);
    Star := TStar(Galaxy.Stars[Index]);
    if (Star.Battle = 0)
        and (Star.ControlFaction <> sfDominators)
        and (Star.Status.CustomFaction = '')
        and (Star.ShipTypeCounts[rstPirateBase] <> 0) then
      for J := 0 to Star.Ships.Count - 1 do
      begin
        Ship := TShip(Star.Ships[J]);
        if (Ship.TypeId = rstPirateBase)
            and (Ship.TypeNameOverrideKey = '')
            and (Ship.NodeReserve > 0) then
        begin
          Result := Ship as TRuins;
          Exit;
        end;
      end;
  end;
  Result := nil;
end;

function TRuins.SelectServiceMicroModule(Kind, Index: Integer; InvertRarity: Boolean): Integer;
var
  ChainIndex: Integer;
  Rare: Boolean;
begin
  ChainIndex := Index + 2;
  Rare := ((Cardinal(Galaxy.CurrentTurn) + GetPlayer.RandomState) mod 33 = 0) <> InvertRarity;
  case Kind of
    2:
      if Rare then
        Result :=
            Galaxy.SelectMicroModule(
                0,
                20,
                Galaxy.CurrentTurn div 57 + 2938629 + 17 * ChainIndex + Id,
                Self
            )
      else
        Result :=
            Galaxy.SelectMicroModule(
                10,
                30,
                Galaxy.CurrentTurn div 57 + 32465621 + 17 * ChainIndex + Id,
                Self
            );
    1:
      Result :=
          Galaxy.SelectMicroModule(
              31,
              69,
              Galaxy.CurrentTurn div 57 + 2351417 + 17 * ChainIndex + Id,
              Self
          );
  else
    Result :=
        Galaxy.SelectMicroModule(70, 100, Galaxy.CurrentTurn div 57 + 17 * ChainIndex + Id, Self);
  end;
end;

function TRuins.CanDock(Ship: TShip): Boolean;
begin
  Result := False;
  if InNormalSpace
      and (Ship.EnemyShip <> Self)
      and (GetRelationLevelToShip(Ship) > rlHostile)
      and not NoLanding
      and (not (CurrentStanding in [ssPirateActive..ssPirateMilitary])
          or (Ship.CurrentStanding in [ssPiratePassive..ssPirateMilitary])) then
    Result := True;
end;

function TRuins.CheckDockingPermission(Ship: TShip; var Response: WideString): Boolean;
begin
  Result := False;
  if NoLanding or not InNormalSpace then
    Response := LookupLocalizedTextByKey('Help.LandingCancelScript')
  else if (CurrentStanding in [ssPirateActive..ssPirateMilitary])
      and not (Ship.CurrentStanding in [ssPiratePassive..ssPirateMilitary]) then
    Response := LookupLocalizedTextByKey('Help.LandingCancelPirate')
  else if (Ship.EnemyShip = Self) or (GetRelationLevelToShip(Ship) <= rlHostile) then
    Response := LookupLocalizedTextByKey('Help.LandingCancelWar')
  else
  begin
    Response := '';
    Result := True;
  end;
end;

end.
