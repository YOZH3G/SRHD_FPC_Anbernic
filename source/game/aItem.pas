unit aItem;

{$I GameOptions.inc}

interface

uses
  Types,
  aConst,
  Classes,
  EC_BlockPar,
  EC_Buf,
  EC_Struct,
  SE_Space,
  aEFilm,
  aGalaxy,
  aGalaxyStruct;

const

  EquipmentSlotIndexMask = $7F;

  EquipmentSecondaryFireFlag = $80;

type

  TArtefact = class;

  TArtefactCustom = class;

  TArtefactTranclucator = class;

  TArtefactTransmitter = class;

  TCargoHook = class;

  TCistern = class;

  TCountableItem = class;

  TCustomWeapon = class;

  TDefGenerator = class;

  TEngine = class;

  TEquipment = class;

  TEquipmentWithActCode = class;

  TFuelTanks = class;

  TGoods = class;

  THull = class;

  TItem = class;

  TMicroModule = class;

  TProtoplasm = class;

  TRadar = class;

  TRepairRobot = class;

  TSatellite = class;

  TScaner = class;

  TTreasureMap = class;

  TUselessItem = class;

  TWeapon = class;

  PointerToTExtraSpecial = ^TExtraSpecial;

  {$Z1}
  TItemLootPool = (ilpArcadeBattle = 0, ilpTreasure = 1, ilpReward = 2, ilpAnyAvailable = 3);

  {$Z1}
  TInterceptorTargetingStrategy = (
      itsManual = 0,
      itsMostHullPoints = 1,
      itsFewestHullPoints = 2,
      itsGreatestStrength = 3,
      itsStrongestDefense = 4,
      itsNearest = 5,
      itsFarthest = 6
  );

  {$Z1}
  TImprovementKind = (ikMinor = 0, ikMedium = 1, ikMajor = 2, ikAny = 3);

  {$Z1}
  TWeaponTargetKind = (wtkNone = 0, wtkShip = 1, wtkItem = 2, wtkAsteroid = 3, wtkMissile = 4);

  TExtraSpecial = packed record
    ModuleIndexPlusOne: Integer;
    Count: Integer;
  end;

  PExtraSpecial = PointerToTExtraSpecial;

  TItem = class(TObjectEx)
    GraphObject: TObjectSE;
    Id: Integer;
    ItemType: TItemType;
    Position: TPointF;
    Weight: Integer;
    OwnerId: TOwnerId;
    Cost: Integer;
    NameOverride: WideString;
    FilmObject: TEFilmObj;
    ScriptItem: TObject;
    DestroyFlag: Integer;
    NoDropFlag: Byte;
    procedure SaveToBuffer(Buffer: TBufEC); virtual;
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy); virtual;
    procedure ResolveLoadedReferences(Galaxy: TGalaxy); virtual;
    procedure ClearReferences; virtual;
    procedure SaveToBlock(Block: TBlockParEC); virtual;
    procedure LoadFromBlock(Block: TBlockParEC); virtual;
    function GetDisplayName: WideString; virtual; abstract;
    function GetShortName: WideString; virtual;
    function GetInfoText(ColorTag: WideString; Ship: Pointer): WideString; virtual;
    function GetDescriptionText: WideString; virtual; abstract;
    function GetBitmapResourceName: WideString; virtual; abstract;
    constructor Create;
    destructor Destroy; override;
    function GetSmallInfoText: WideString;
    function CalculateResaleValue(TradingSkill: Byte): Integer;
    function GetConditionAdjustedCost: Integer;
    function GetCategoryConfigName: WideString;
    function GetGraphObject: TObjectSE;
    procedure ReleaseGraphObject;
    function GetOwnerConfigName: WideString;
  end;

  TEquipment = class(TItem)
    ConfigBlockName: WideString;
    CustomFaction: WideString;
    ConditionPercent: Double;
    BrokenFlag: Byte;
    EquippedFlag: Byte;
    AssignedSlotData: Dword;
    MicroModuleIndex: Integer;
    SpecialModuleIndex: Integer;
    ExtraSpecials: TList;
    DominatorSeries: TDominatorSeries;
    DetailImprovement: Byte;
    procedure SaveToBuffer(Buffer: TBufEC); override;
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy); override;
    procedure SaveToBlock(Block: TBlockParEC); override;
    procedure LoadFromBlock(Block: TBlockParEC); override;
    function GetDisplayName: WideString; override;
    function GetShortName: WideString; override;
    function GetDescriptionText: WideString; override;
    function GetBitmapResourceName: WideString; override;
    procedure Unequip; virtual;
    procedure Repair; virtual;
    procedure Improve(Kind: TImprovementKind); virtual;
    function CalculateImprovementCost(Kind: TImprovementKind): Integer; virtual;
    function HasStandardStats: Boolean; virtual;
    function GetFragilityFactor(DamageFlags: TDamageFlagSet): Single; virtual;
    procedure ReplaceInfoTokens(var Text: WideString; ColorTag: WideString; Ship: Pointer); virtual;
    function Clone: TItem; virtual;
    constructor Create;
    destructor Destroy; override;
    procedure Equip;
    function NeedsRepair: Boolean;
    function CalculateRepairCost: Integer;
    function GetConditionText(PrefixNewLine: Boolean): WideString;
    function GetBrokenInBattleText: WideString;
    function GetBrokenInUseText: WideString;
    function GetBrokenByForceText: WideString;
    function GetLevel: Integer;
    function GetLevelLetter: WideString;
    procedure ImproveAtScientificBase;
    function HasMicroModule: Boolean;
    function GetMicroModuleQuotedName: WideString;
    function GetSpecialModuleName: WideString;
    function GetStatBonus(BonusKind: TEquipmentBonusKind): Integer;
    function GetDescriptionStatBonus(BonusKind: TEquipmentBonusKind): Integer;
    function GetBonusDescription(ColorTag: WideString): WideString;
    function CanImprove: Boolean;
  end;

  THull = class(TEquipment)
    HullPoints: Integer;
    TechLevel: Byte;
    Armor: ShortInt;
    HullType: THullType;
    HullSeries: Integer;
    OwnerShip: Pointer;
    CapitalShip: Byte;
    PirateBuilt: Boolean;
    ImpulseShieldsEnabled: Boolean;
    InterceptorsEnabled: Boolean;
    Energy: Integer;
    EnergyMax: Integer;
    InterceptorTarget: Pointer;
    InterceptorTargetingStrategy: TInterceptorTargetingStrategy;
    InterceptorPassCountOverride: Byte;
    procedure SaveToBuffer(Buffer: TBufEC); override;
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy); override;
    procedure ResolveLoadedReferences(Galaxy: TGalaxy); override;
    procedure ClearReferences; override;
    procedure SaveToBlock(Block: TBlockParEC); override;
    procedure LoadFromBlock(Block: TBlockParEC); override;
    function GetDisplayName: WideString; override;
    function GetShortName: WideString; override;
    function GetInfoText(ColorTag: WideString; Ship: Pointer): WideString; override;
    function GetBitmapResourceName: WideString; override;
    procedure Repair; override;
    procedure Improve(Kind: TImprovementKind); override;
    function HasStandardStats: Boolean; override;
    function GetFragilityFactor(DamageFlags: TDamageFlagSet): Single; override;
    procedure ReplaceInfoTokens(
        var Text: WideString;
        ColorTag: WideString;
        Ship: Pointer
    ); override;
    procedure Init(
        Capacity: Integer;
        Level: Byte;
        Owner: TOwnerId;
        HullType: THullType;
        Series: Integer;
        PirateBuilt: Boolean
    );
    procedure ApplySeriesSizeAndCost;
    function CalculateGeneratedArmor: ShortInt;
    function CalculateGeneratedCost: Integer;
    function GetSeriesName: WideString;
    function GetSpecialKindGraph: WideString;
    function GetSlotCount(Kind: TShipSlotKind): Integer;
    function CalculateMass: Integer;
    function EstimateCapacityWithoutBonuses: Integer;
  end;

  TFuelTanks = class(TEquipment)
    TechLevel: Byte;
    Fuel: Integer;
    Capacity: Byte;
    procedure SaveToBuffer(Buffer: TBufEC); override;
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy); override;
    procedure SaveToBlock(Block: TBlockParEC); override;
    procedure LoadFromBlock(Block: TBlockParEC); override;
    function GetInfoText(ColorTag: WideString; Ship: Pointer): WideString; override;
    procedure Improve(Kind: TImprovementKind); override;
    function HasStandardStats: Boolean; override;
    procedure ReplaceInfoTokens(
        var Text: WideString;
        ColorTag: WideString;
        Ship: Pointer
    ); override;
    procedure Init(Weight: Integer; Level: Byte; Owner: TOwnerId);
    function CalculateGeneratedCapacity: Byte;
    function CalculateGeneratedCost: Integer;
  end;

  TEngine = class(TEquipment)
    TechLevel: Byte;
    Speed: Integer;
    JumpRange: ShortInt;
    OutputPercent: Byte;
    procedure SaveToBuffer(Buffer: TBufEC); override;
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy); override;
    procedure SaveToBlock(Block: TBlockParEC); override;
    procedure LoadFromBlock(Block: TBlockParEC); override;
    function GetInfoText(ColorTag: WideString; Ship: Pointer): WideString; override;
    procedure Improve(Kind: TImprovementKind); override;
    function HasStandardStats: Boolean; override;
    procedure ReplaceInfoTokens(
        var Text: WideString;
        ColorTag: WideString;
        Ship: Pointer
    ); override;
    procedure Init(Weight: Integer; Level: Byte; Owner: TOwnerId);
    function CalculateGeneratedSpeed: Integer;
    function CalculateGeneratedJumpRange: ShortInt;
    function CalculateGeneratedCost: Integer;
  end;

  TRadar = class(TEquipment)
    TechLevel: Byte;
    Range: Integer;
    procedure SaveToBuffer(Buffer: TBufEC); override;
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy); override;
    procedure SaveToBlock(Block: TBlockParEC); override;
    procedure LoadFromBlock(Block: TBlockParEC); override;
    function GetInfoText(ColorTag: WideString; Ship: Pointer): WideString; override;
    procedure Improve(Kind: TImprovementKind); override;
    function HasStandardStats: Boolean; override;
    procedure ReplaceInfoTokens(
        var Text: WideString;
        ColorTag: WideString;
        Ship: Pointer
    ); override;
    procedure Init(Weight: Integer; Level: Byte; Owner: TOwnerId);
    function CalculateGeneratedRange: Integer;
    function CalculateGeneratedCost: Integer;
  end;

  TScaner = class(TEquipment)
    TechLevel: Byte;
    ScanPower: ShortInt;
    procedure SaveToBuffer(Buffer: TBufEC); override;
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy); override;
    procedure SaveToBlock(Block: TBlockParEC); override;
    procedure LoadFromBlock(Block: TBlockParEC); override;
    function GetInfoText(ColorTag: WideString; Ship: Pointer): WideString; override;
    procedure Improve(Kind: TImprovementKind); override;
    function HasStandardStats: Boolean; override;
    procedure ReplaceInfoTokens(
        var Text: WideString;
        ColorTag: WideString;
        Ship: Pointer
    ); override;
    procedure Init(Weight: Integer; Level: Byte; Owner: TOwnerId);
    function CalculateGeneratedScanPower: Integer;
    function CalculateGeneratedCost: Integer;
  end;

  TRepairRobot = class(TEquipment)
    TechLevel: Byte;
    RepairPoints: Byte;
    procedure SaveToBuffer(Buffer: TBufEC); override;
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy); override;
    procedure SaveToBlock(Block: TBlockParEC); override;
    procedure LoadFromBlock(Block: TBlockParEC); override;
    function GetInfoText(ColorTag: WideString; Ship: Pointer): WideString; override;
    procedure Improve(Kind: TImprovementKind); override;
    function HasStandardStats: Boolean; override;
    procedure ReplaceInfoTokens(
        var Text: WideString;
        ColorTag: WideString;
        Ship: Pointer
    ); override;
    procedure Init(Weight: Integer; Level: Byte; Owner: TOwnerId);
    function CalculateGeneratedRepairPoints: Byte;
    function CalculateGeneratedCost: Integer;
  end;

  TCargoHook = class(TEquipment)
    TechLevel: Byte;
    PickupPower: Integer;
    Range: Integer;
    MinPullSpeed: Single;
    MaxPullSpeed: Single;
    procedure SaveToBuffer(Buffer: TBufEC); override;
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy); override;
    procedure SaveToBlock(Block: TBlockParEC); override;
    procedure LoadFromBlock(Block: TBlockParEC); override;
    function GetInfoText(ColorTag: WideString; Ship: Pointer): WideString; override;
    procedure Improve(Kind: TImprovementKind); override;
    function HasStandardStats: Boolean; override;
    procedure ReplaceInfoTokens(
        var Text: WideString;
        ColorTag: WideString;
        Ship: Pointer
    ); override;
    constructor Create;
    procedure Init(Weight: Integer; Level: Byte; Owner: TOwnerId);
    function CalculateGeneratedPickupPower: Integer;
    function CalculateGeneratedRange: Integer;
    function CalculateGeneratedMinPullSpeed: Single;
    function CalculateGeneratedMaxPullSpeed: Single;
    function CalculateGeneratedCost: Integer;
  end;

  TDefGenerator = class(TEquipment)
    TechLevel: Byte;
    DamageFactor: Single;
    procedure SaveToBuffer(Buffer: TBufEC); override;
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy); override;
    procedure SaveToBlock(Block: TBlockParEC); override;
    procedure LoadFromBlock(Block: TBlockParEC); override;
    function GetInfoText(ColorTag: WideString; Ship: Pointer): WideString; override;
    procedure Improve(Kind: TImprovementKind); override;
    function HasStandardStats: Boolean; override;
    procedure ReplaceInfoTokens(
        var Text: WideString;
        ColorTag: WideString;
        Ship: Pointer
    ); override;
    procedure Init(Weight: Integer; Level: Byte; Owner: TOwnerId);
    function CalculateGeneratedDamageFactor: Single;
  end;

  TWeapon = class(TEquipment)
    TechLevel: Byte;
    Range: Integer;
    MinDamage: Integer;
    MaxDamage: Integer;
    Target: TObject;
    LoadedTargetKind: TWeaponTargetKind;
    Ammo: Integer;
    AmmoCapacity: Integer;
    procedure SaveToBuffer(Buffer: TBufEC); override;
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy); override;
    procedure ResolveLoadedReferences(Galaxy: TGalaxy); override;
    procedure ClearReferences; override;
    procedure SaveToBlock(Block: TBlockParEC); override;
    procedure LoadFromBlock(Block: TBlockParEC); override;
    function GetDisplayName: WideString; override;
    function GetShortName: WideString; override;
    function GetInfoText(ColorTag: WideString; Ship: Pointer): WideString; override;
    function GetDescriptionText: WideString; override;
    function GetBitmapResourceName: WideString; override;
    procedure Unequip; override;
    procedure Improve(Kind: TImprovementKind); override;
    function HasStandardStats: Boolean; override;
    procedure ReplaceInfoTokens(
        var Text: WideString;
        ColorTag: WideString;
        Ship: Pointer
    ); override;
    function GetConfigName: WideString; virtual;
    function GetWeaponInfo: PWeaponInfo; virtual;
    destructor Destroy; override;
    procedure Init(ItemType: TItemType; Weight: Integer; Level: Byte; Owner: TOwnerId);
    function CalculateGeneratedAmmoCapacity: Integer;
    function CalculateGeneratedMinDamage: Integer;
    function CalculateGeneratedMaxDamage: Integer;
    function CalculateGeneratedRange: Integer;
    function CalculateStandardMaxDamage: Integer;
    function CalculateStandardRange: Integer;
    function GetShotDelayFactor: Double;
    function NeedsAmmo: Boolean;
    function CalculateAmmoRefillCost: Integer;
    function GetShotPalette: Integer;
    function GetDamageFlags: TDamageFlagSet;
    function GetShotCount: Integer;
    function GetAttackCount: Integer;
  end;

  TCustomWeapon = class(TWeapon)
    CustomInfo: PWeaponInfo;
    procedure SaveToBuffer(Buffer: TBufEC); override;
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy); override;
    procedure SaveToBlock(Block: TBlockParEC); override;
    procedure LoadFromBlock(Block: TBlockParEC); override;
    function GetBitmapResourceName: WideString; override;
    function GetConfigName: WideString; override;
    function GetWeaponInfo: PWeaponInfo; override;
    procedure InitCustom(
        Info: PWeaponInfo;
        Equipped: Boolean;
        Weight: Integer;
        Level: Byte;
        Owner: TOwnerId
    );
  end;

  TGoods = class(TItem)
    Quantity: Integer;
    NaturalFlag: Boolean;
    procedure SaveToBuffer(Buffer: TBufEC); override;
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy); override;
    function GetDisplayName: WideString; override;
    function GetInfoText(ColorTag: WideString; Ship: Pointer): WideString; override;
    function GetDescriptionText: WideString; override;
    function GetBitmapResourceName: WideString; override;
    procedure Init(ItemType: TItemType; Quantity: Integer);
  end;

  TCountableItem = class(TEquipment)
    StackCount: Integer;
    DropFlag: Byte;
    procedure SaveToBuffer(Buffer: TBufEC); override;
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy); override;
    function GetDisplayName: WideString; override;
    function GetInfoText(ColorTag: WideString; Ship: Pointer): WideString; override;
    function GetDescriptionText: WideString; override;
    function GetBitmapResourceName: WideString; override;
    procedure Init(ConfigName: WideString; Count: Integer; DropFlag: Byte);
    function GetUnitSize: Integer;
    function Split(Count: Integer): TCountableItem;
    function CanMerge(Other: TObject): Boolean;
    function Merge(Other: TObject): Boolean;
  end;

  TProtoplasm = class(TCountableItem)
    function GetDisplayName: WideString; override;
    function GetInfoText(ColorTag: WideString; Ship: Pointer): WideString; override;
    function GetDescriptionText: WideString; override;
    function GetBitmapResourceName: WideString; override;
    procedure Init(Count: Integer; DropFlag: Byte);
  end;

  TEquipmentWithActCode = class(TEquipment)
    ActionCode: Pointer;
    ActCodeInitialized: Boolean;
    DisplayAsArtefact: Boolean;
    constructor Create;
    destructor Destroy; override;
  end;

  TUselessItem = class(TEquipmentWithActCode)
    CustomText: WideString;
    Data: array[0..2] of Integer;
    procedure SaveToBuffer(Buffer: TBufEC); override;
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy); override;
    procedure SaveToBlock(Block: TBlockParEC); override;
    procedure LoadFromBlock(Block: TBlockParEC); override;
    function GetDisplayName: WideString; override;
    function GetInfoText(ColorTag: WideString; Ship: Pointer): WideString; override;
    function GetDescriptionText: WideString; override;
    function GetBitmapResourceName: WideString; override;
    constructor Create;
    destructor Destroy; override;
    procedure Init(
        ConfigName: WideString;
        Series: TDominatorSeries;
        Seed: Cardinal;
        ForceArtefactDisplay: Boolean
    );
    function IsDominatorRemains: Boolean;
    procedure CheckIfWeDisplayAsArtefact;
    function GetOnUseCodeText: WideString;
    function GetActionCode: Pointer;
  end;

  TCistern = class(TEquipment)
    Fuel: Integer;
    Capacity: Byte;
    procedure SaveToBuffer(Buffer: TBufEC); override;
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy); override;
    procedure SaveToBlock(Block: TBlockParEC); override;
    procedure LoadFromBlock(Block: TBlockParEC); override;
    function GetDisplayName: WideString; override;
    function GetInfoText(ColorTag: WideString; Ship: Pointer): WideString; override;
    function GetDescriptionText: WideString; override;
    function GetBitmapResourceName: WideString; override;
    procedure Init(Fuel: Integer; Capacity: Byte; Owner: TOwnerId);
  end;

  TSatellite = class(TEquipment)
    SatelliteTypeId: Byte;
    TargetPlanet: Pointer;
    TrajectoryIndex: Integer;
    WearPerTurn: Single;
    WaterExplorationRate: Byte;
    LandExplorationRate: Byte;
    HillExplorationRate: Byte;
    procedure SaveToBuffer(Buffer: TBufEC); override;
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy); override;
    procedure ResolveLoadedReferences(Galaxy: TGalaxy); override;
    procedure ClearReferences; override;
    procedure SaveToBlock(Block: TBlockParEC); override;
    procedure LoadFromBlock(Block: TBlockParEC); override;
    function GetDisplayName: WideString; override;
    function GetInfoText(ColorTag: WideString; Ship: Pointer): WideString; override;
    function GetDescriptionText: WideString; override;
    function GetBitmapResourceName: WideString; override;
    procedure InitGenerated(TypeId: Byte; Owner: TOwnerId; Seed: Cardinal);
    function GetBrokenInUseText: WideString;
    function GetIdleInfoText: WideString;
  end;

  TTreasureMap = class(TEquipment)
    TargetPlanet: Pointer;
    SourceShipName: WideString;
    PreviewTablePage1: WideString;
    PreviewTablePage2: WideString;
    procedure SaveToBuffer(Buffer: TBufEC); override;
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy); override;
    procedure ResolveLoadedReferences(Galaxy: TGalaxy); override;
    procedure ClearReferences; override;
    function GetDisplayName: WideString; override;
    function GetInfoText(ColorTag: WideString; Ship: Pointer): WideString; override;
    function GetDescriptionText: WideString; override;
    function GetBitmapResourceName: WideString; override;
    procedure Init(Planet: Pointer; Victim: Pointer);
    function GetTargetPlanetName: WideString;
    function BuildPreviewTable(PageIndex: Integer; Planet: Pointer): WideString;
  end;

  TMicroModule = class(TEquipment)
    procedure SaveToBuffer(Buffer: TBufEC); override;
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy); override;
    function GetDisplayName: WideString; override;
    function GetInfoText(ColorTag: WideString; Ship: Pointer): WideString; override;
    function GetDescriptionText: WideString; override;
    function GetBitmapResourceName: WideString; override;
    procedure Init(ModuleIndex: Integer);
    function GetPlainName: WideString;
    function CalculateNodeExchangeValue(
        LowPriorityOfferCost: Integer;
        MediumPriorityOfferCost: Integer
    ): Integer;
    function GetHighlightedName: WideString;
    function CanInstallOn(Item: TEquipment): Boolean;
  end;

  TArtefact = class(TEquipmentWithActCode)
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy); override;
    function GetDisplayName: WideString; override;
    function GetInfoText(ColorTag: WideString; Ship: Pointer): WideString; override;
    function GetDescriptionText: WideString; override;
    function GetBitmapResourceName: WideString; override;
    procedure Init(Owner: TOwnerId; ItemType: TItemType); virtual;
    constructor Create;
    destructor Destroy; override;
    function GetOnUseCodeText: WideString;
    function GetActionCode: Pointer;
    function GetEffectiveType: TItemType;
    function GetBoostStatusText: WideString;
  end;

  TArtefactTransmitter = class(TArtefact)
    Power: Integer;
    procedure SaveToBuffer(Buffer: TBufEC); override;
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy); override;
    procedure SaveToBlock(Block: TBlockParEC); override;
    procedure LoadFromBlock(Block: TBlockParEC); override;
    function GetInfoText(ColorTag: WideString; Ship: Pointer): WideString; override;
    procedure InitTransmitter(Owner: TOwnerId);
  end;

  TArtefactTranclucator = class(TArtefact)
    Ship: Pointer;
    procedure SaveToBuffer(Buffer: TBufEC); override;
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy); override;
    procedure ResolveLoadedReferences(Galaxy: TGalaxy); override;
    procedure ClearReferences; override;
    procedure SaveToBlock(Block: TBlockParEC); override;
    procedure LoadFromBlock(Block: TBlockParEC); override;
    function GetDisplayName: WideString; override;
    function Clone: TItem; override;
    destructor Destroy; override;
    procedure InitTranclucator(Owner: TOwnerId; OwnerShip: Pointer; ExistingShip: Pointer);
  end;

  TArtefactCustom = class(TArtefact)
    CountsAsItemType: TItemType;
    SharedUse: Boolean;
    SharedEffect: Boolean;
    Data: array[1..3] of Integer;
    TextData1: WideString;
    TextData2: WideString;
    TextData3: WideString;
    procedure SaveToBuffer(Buffer: TBufEC); override;
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy); override;
    procedure SaveToBlock(Block: TBlockParEC); override;
    procedure LoadFromBlock(Block: TBlockParEC); override;
    function GetDisplayName: WideString; override;
    function GetInfoText(ColorTag: WideString; Ship: Pointer): WideString; override;
    function GetDescriptionText: WideString; override;
    procedure LoadConfig(ApplyConfiguredWeight: Boolean);
  end;

function CanCargoHookHandleItem(Item: TItem; Ship: Pointer): Boolean;

function ReadSavedMicroModuleIndex(Buffer: TBufEC): Integer;

function CalculateGeneratedHullCost(
    Capacity: Cardinal;
    Level: Cardinal;
    Owner: TOwnerId;
    HullType: THullType
): Integer;

function GetBaseHullSlotCount(
    Kind: TShipSlotKind;
    HullType: THullType;
    Owner: TOwnerId;
    Ship: Pointer
): Integer;

function CalculateGeneratedFuelCapacity(Weight: Cardinal; Level: Integer): Integer;

function CalculateGeneratedFuelTanksCost(
    Weight: Cardinal;
    Level: Integer;
    Owner: TOwnerId
): Integer;

function CalculateGeneratedEngineCost(Weight: Cardinal; Level: Byte; Owner: TOwnerId): Integer;

function CalculateGeneratedRadarCost(Weight: Cardinal; Level: Byte; Owner: TOwnerId): Integer;

function CalculateGeneratedScanerCost(Weight: Cardinal; Level: Byte; Owner: TOwnerId): Integer;

function CalculateGeneratedRepairRobotCost(Weight: Cardinal; Level: Byte; Owner: TOwnerId): Integer;

function CalculateGeneratedCargoHookCost(Weight: Cardinal; Level: Byte; Owner: TOwnerId): Integer;

function GetGeneratedDefenseDamageFactor(Level: Byte): Double;

function DefenseDamageFactorToPercent(Factor: Double): TPercent;

function DefensePercentToDamageFactor(Percent: Integer): Double;

function CalculateGeneratedDefGeneratorCost(
    Weight: Cardinal;
    Level: Byte;
    Owner: TOwnerId
): Integer;

function CalculateGeneratedWeaponCost(
    Info: PWeaponInfo;
    Weight: Cardinal;
    Level: Byte;
    Owner: TOwnerId
): Integer;

function GetMicroModuleInfoText(ModuleIndex: Integer; ColorTag: WideString): WideString;

function GetMicroModulePriorityColorTier(ModuleIndex: Integer): Byte;

function GetMicroModuleNameColorTag(ModuleIndex: Integer): WideString;

function GetMicroModuleTextColorTag(ModuleIndex: Integer): WideString;

function GetMicroModuleBitmapResourceName(ModuleIndex: Integer): WideString;

function ApplyMicroModule(ModuleIndex: Integer; Item: TEquipment): Boolean;

procedure RemoveMicroModule(Item: TEquipment);

procedure ApplySpecialMicroModule(ModuleIndex: Integer; Item: TEquipment);

procedure RemoveSpecialMicroModule(Item: TEquipment);

function CanInstallMicroModule(ModuleIndex: Integer; Item: TEquipment): Boolean;

function IsBonusCompatibleWithEquipment(ModuleIndex: Integer; Item: TEquipment): Boolean;

function IsBonusCompatibleWithHull(ModuleIndex: Integer; Hull: THull): Boolean;

function IsBonusCompatibleWithWeapon(ModuleIndex: Integer; Weapon: TWeapon): Boolean;

function CreateConfiguredArtefactByItemType(ItemType: TItemType; Owner: TOwnerId): TArtefact;

function CreateRandomLootItem(
    Pool: TItemLootPool;
    Owner: TOwnerId;
    Seed: Cardinal
): TEquipmentWithActCode;

function CreateItemByType(ItemType: TItemType): TItem;

function CreateDefaultItemByType(ItemType: TItemType): TItem;

function CreateGeneratedEquipment(
    ItemType: TItemType;
    Weight: Integer;
    Level: Integer;
    Owner: TOwnerId
): TEquipment;

function CreateGeneratedWeapon(
    Info: PWeaponInfo;
    Weight: Integer;
    Level: Integer;
    Owner: TOwnerId
): TWeapon;

function GetItemTypeBitmapPath(ItemType: TItemType): WideString;

function GetStackableItemTypeName(ItemType: TItemType): WideString;

function GetStackableItemName(Item: TItem): WideString;

function MigrateSavedItemType(ItemType: Byte): TItemType;

implementation

uses
  GlobalsV,
  aPlanet,
  aTranclucator,
  aPirate,
  SysUtils,
  SE_Process,
  GR_Main,
  aPlayer,
  aScript,
  aMyFunction,
  Math,
  aShip,
  aKling,
  EC_Str,
  aAsteroid,
  aMissile,
  Globals,
  fShip2;

constructor TItem.Create;
begin
  inherited Create;
  if Galaxy <> nil then
  begin
    Id := Galaxy.NextItemId;
    Inc(Galaxy.NextItemId);
  end;
  NameOverride := '';
end;

destructor TItem.Destroy;
begin
  if (Galaxy <> nil) and not Galaxy.Destroying and (GetPlayer <> nil) and (ScriptItem <> nil) then
    TScriptItem(ScriptItem).RunActionCode(satOnItemDestroy, nil, nil, nil, 0);
  Id := 0;
  if ScriptItem <> nil then
  begin
    (ScriptItem as TScriptItem).Item := nil;
    ScriptItem := nil;
  end;
  if GraphObject <> nil then
    ReleaseSpaceObject(GraphObject);
  inherited Destroy;
end;

procedure TItem.SaveToBuffer(Buffer: TBufEC);
begin
  Buffer.AddDWord(Id);
  Buffer.AddAnsiChar(AnsiChar(ItemType));
  Buffer.AddSingle(Position.X);
  Buffer.AddSingle(Position.Y);
  Buffer.AddIntegerValue(Weight);
  Buffer.AddAnsiChar(AnsiChar(OwnerId));
  Buffer.AddDWord(Cost);
  Buffer.AddIntegerValue(DestroyFlag);
  if NameOverride = '' then
    Buffer.AddBoolean(False)
  else
  begin
    Buffer.AddBoolean(True);
    Buffer.AddWideStringZ(NameOverride);
  end;
  Buffer.AddAnsiChar(AnsiChar(NoDropFlag));
end;

procedure TItem.LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy);
begin
  Id := Buffer.GetUInt32;
  if Galaxy.NextItemId <= Cardinal(Id) then
    Galaxy.NextItemId := Id + 1;
  ItemType := MigrateSavedItemType(Buffer.GetByte);
  Position.X := Buffer.GetSingle;
  Position.Y := Buffer.GetSingle;
  Weight := Buffer.GetInt32;
  OwnerId := TOwnerId(Buffer.GetByte);
  Cost := Buffer.GetUInt32;
  DestroyFlag := Buffer.GetInt32;
  if Buffer.GetBoolean then
    NameOverride := Buffer.ReadWideString;
  NoDropFlag := Buffer.GetByte;
end;

procedure TItem.SaveToBlock(Block: TBlockParEC);
begin
  Block.AddParam(DecodeTextW('IQNaaWmee'), GetDisplayName); // 'IName'
  Block.AddParam(DecodeTextW('InToyAple'), ItemTypeNames[ItemType]); // 'IType'
  Block.AddParam(DecodeTextW('OpwRn3ewr'), OwnerInfo[OwnerId].InternalName); // 'Owner'
  Block.AddParam(DecodeTextW('SaiRzoe'), IntToStr(Weight)); // 'Size'
  Block.AddParam(DecodeTextW('CfoTsat'), IntToStr(Cost)); // 'Cost'
  Block.AddParam(DecodeTextW('NeonDarlokpl'), IntToStr(NoDropFlag)); // 'NoDrop'
  if ScriptItem <> nil then
    Block.AddParam(
        DecodeTextW('IsSacaraiOpit'),
        TScriptItem(ScriptItem).Script.ScriptFileName
    ); // 'IScript'
end;

procedure TItem.LoadFromBlock(Block: TBlockParEC);
var
  I: Integer;
  Text: WideString;
begin
  Text := Block.GetParam(DecodeTextW('OpwRn3ewr')); // 'Owner'
  for I := 0 to 7 do
    if Text = OwnerInfo[TOwnerId(I)].InternalName then
      OwnerId := TOwnerId(I);
  Weight := StrToInt(Block.GetParam(DecodeTextW('SaiRzoe'))); // 'Size'
  Cost := StrToInt(Block.GetParam(DecodeTextW('CfoTsat'))); // 'Cost'
  Text := LowerCase(Block.GetParam(DecodeTextW('NeonDarlokpl'))); // 'NoDrop'
  if Text = 'false' then
    NoDropFlag := 0
  else if Text = 'true' then
    NoDropFlag := 1
  else
    NoDropFlag := StrToInt(Text);
  if Self is TGoods then
    (Self as TGoods).Quantity := Weight;
  if Self is TCountableItem then
    (Self as TCountableItem).StackCount := Weight div (Self as TCountableItem).GetUnitSize;
  if (ItemType = t_ArtefactTranclucator) and ((Self as TArtefactTranclucator).Ship <> nil) then
    TTranclucator((Self as TArtefactTranclucator).Ship).ArtefactSize := Weight;
end;

procedure TItem.ResolveLoadedReferences(Galaxy: TGalaxy);
begin

end;

procedure TItem.ClearReferences;
begin

end;

function TItem.GetSmallInfoText: WideString;
begin
  Result := LookupLocalizedTextByKey('Items.SmallInfo');
end;

function TItem.CalculateResaleValue(TradingSkill: Byte): Integer;
begin
  if Self is TEquipment then
    Result :=
        Max(
            1,
            Round(
                (Cost - (Self as TEquipment).CalculateRepairCost)
                    * 0.01
                    * PilotSkillEffects[TradingSkill, psTrading]
            )
        )
  else
    Result := Round(Cost * 0.01 * PilotSkillEffects[TradingSkill, psTrading]);
end;

function TItem.GetConditionAdjustedCost: Integer;
begin
  if Self is TEquipment then
    Result := Max(1, Cost - (Self as TEquipment).CalculateRepairCost)
  else
    Result := Cost;
end;

function TItem.GetCategoryConfigName: WideString;
begin
  if ItemType in [t_IndustrialLaser..t_CustomWeapon] then
    Result := 'Weapon'
  else if ItemType in [t_ArtefactHull..t_ArtFastRacks] then
    Result := 'Artefact'
  else
    Result := ItemTypeNames[ItemType];
end;

function TItem.GetShortName: WideString;
begin
  Result := '';
end;

function TItem.GetInfoText(ColorTag: WideString; Ship: Pointer): WideString;
begin
  Result := '';
end;

function TItem.GetGraphObject: TObjectSE;

  procedure CreateContainer(
      GraphKey: WideString
  ); { Captures the item at ParentFrame-4; caller removes ParentFrame. }
  begin
    RetainSpaceObject(
        GraphObject,
        CreateSpaceObjectByName('Container', 'Item.' + GraphKey, Classes.Point(0, 0))
    );
  end;

begin
  if GraphObject = nil then
  begin
    if Self is TMicroModule then
    begin
      if (MicroModuleTemplates[(Self as TMicroModule).MicroModuleIndex - 1].KindGraph <> '')
          and (GameDataConfig
                  .GetBlock('SE')
                  .GetBlock('Item')
                  .FindBlock(
                      'mm_'
                          + MicroModuleTemplates[(Self as TMicroModule).MicroModuleIndex - 1]
                              .KindGraph)
              <> nil) then
        CreateContainer(
            'mm_' + MicroModuleTemplates[(Self as TMicroModule).MicroModuleIndex - 1].KindGraph
        )
      else
        CreateContainer(
            'mm_'
                + IntToStr(
                    GetMicroModulePriorityColorTier((Self as TMicroModule).MicroModuleIndex - 1))
        );
    end
    else if ItemType = t_ArtefactBomb then
      CreateContainer('Bomb')
    else if (Self is TUselessItem)
        and (GameDataConfig
                .GetBlockByPath('SE.Item')
                .CountBlocks(TUselessItem(Self).ConfigBlockName)
            > 0) then
      CreateContainer(TUselessItem(Self).ConfigBlockName)
    else if Self is TCistern then
      CreateContainer('Cistern')
    else if (Self is TGoods) and (Self as TGoods).NaturalFlag then
    begin
      if Weight <= 29 then
        CreateContainer('m0_' + IntToStr(SeededRandomIntRange(0, 2, Id * 25457)))
      else if Weight <= 59 then
        CreateContainer('m1_' + IntToStr(SeededRandomIntRange(0, 2, Id * 25457)))
      else
        CreateContainer('m2_' + IntToStr(SeededRandomIntRange(0, 2, Id * 25457)));
    end
    else if (Self is TProtoplasm) and ((Self as TProtoplasm).DropFlag <> 0) then
    begin
      if Weight <= 29 then
        CreateContainer('n0_' + IntToStr(Cardinal(Id) mod 5))
      else if Weight <= 59 then
        CreateContainer('n1_' + IntToStr(Cardinal(Id) mod 5))
      else if Weight <= 99 then
        CreateContainer('n2_' + IntToStr(Cardinal(Id) mod 5))
      else
        CreateContainer('n3_' + IntToStr(Cardinal(Id) mod 5));
    end
    else if (Self is TCountableItem) and ((Self as TCountableItem).DropFlag <> 0) then
    begin
      if Weight <= 29 then
        CreateContainer(
            (Self as TCountableItem).ConfigBlockName
                + '0_'
                + WideString(IntToStr(Cardinal(Id) mod 5))
        )
      else if Weight <= 59 then
        CreateContainer(
            (Self as TCountableItem).ConfigBlockName
                + '1_'
                + WideString(IntToStr(Cardinal(Id) mod 5))
        )
      else if Weight <= 99 then
        CreateContainer(
            (Self as TCountableItem).ConfigBlockName
                + '2_'
                + WideString(IntToStr(Cardinal(Id) mod 5))
        )
      else
        CreateContainer(
            (Self as TCountableItem).ConfigBlockName
                + '3_'
                + WideString(IntToStr(Cardinal(Id) mod 5))
        );
    end
    else if (Self is TEquipment) and ((Self as TEquipment).CustomFaction <> '') then
    begin
      if Weight <= 29 then
        CreateContainer((Self as TEquipment).CustomFaction + '0')
      else if Weight <= 59 then
        CreateContainer((Self as TEquipment).CustomFaction + '1')
      else if Weight <= 99 then
        CreateContainer((Self as TEquipment).CustomFaction + '2')
      else
        CreateContainer((Self as TEquipment).CustomFaction + '3');
    end
    else if (Self is TEquipment) and (OwnerId = oiDominator) then
    begin
      if (Self as TEquipment).DominatorSeries = dsBlazer then
      begin
        if Weight <= 29 then
          CreateContainer('db0')
        else if Weight <= 59 then
          CreateContainer('db1')
        else if Weight <= 99 then
          CreateContainer('db2')
        else
          CreateContainer('db3');
      end
      else if (Self as TEquipment).DominatorSeries = dsKeller then
      begin
        if Weight <= 29 then
          CreateContainer('dk0')
        else if Weight <= 59 then
          CreateContainer('dk1')
        else if Weight <= 99 then
          CreateContainer('dk2')
        else
          CreateContainer('dk3');
      end
      else if (Self as TEquipment).DominatorSeries = dsTerron then
      begin
        if Weight <= 29 then
          CreateContainer('dt0')
        else if Weight <= 59 then
          CreateContainer('dt1')
        else if Weight <= 99 then
          CreateContainer('dt2')
        else
          CreateContainer('dt3');
      end
      else
        RaiseWideMessage('Item graph');
    end
    else
    begin
      if Weight <= 29 then
        CreateContainer('c0_' + IntToStr(SeededRandomIntRange(0, 7, Id * 25457)))
      else if Weight <= 59 then
        CreateContainer('c1_' + IntToStr(SeededRandomIntRange(0, 7, Id * 25457)))
      else if Weight <= 99 then
        CreateContainer('c2_' + IntToStr(SeededRandomIntRange(0, 7, Id * 25457)))
      else
        CreateContainer('c3_' + IntToStr(SeededRandomIntRange(0, 7, Id * 25457)));
    end;
    GraphObject.SetPosition(Position);
  end;
  Result := GraphObject;
end;

procedure TItem.ReleaseGraphObject;
begin
  if GraphObject <> nil then
    ReleaseSpaceObject(GraphObject);
end;

function CanCargoHookHandleItem(Item: TItem; Ship: Pointer): Boolean;
var
  Owner: TShip;
begin
  Owner := TShip(Ship);
  Result := False;
  if not Owner.IsEquipmentUsable(Owner.GetCargoHook) then
    Exit;
  if Owner.CalculateCargoHookPower(Owner.GetCargoHook) < Item.Weight then
    Exit;
  if (Item is TUselessItem) and (TUselessItem(Item).ConfigBlockName = 'ExampleAsteroid') then
    Exit;
  if GetPlayer <> Owner then
  begin
    if (Item.ScriptItem <> nil) and (TScriptItem(Item.ScriptItem).Name <> '') then
      Exit;
    if (Item is TSatellite) or (Item.DestroyFlag > 0) then
      Exit;
  end;
  Result := True;
end;

function TItem.GetOwnerConfigName: WideString;
begin
  if Self is TGoods then
    Result := OwnerInfo[oiUninhabited].InternalName
  else if TEquipment(Self).CustomFaction <> '' then
    Result := TEquipment(Self).CustomFaction
  else if (OwnerId = oiDominator) and (Self is TEquipment) then
    Result := DominatorSeriesNames[TEquipment(Self).DominatorSeries]
  else if (Self is THull) and (Self as THull).PirateBuilt then
    Result := OwnerInfo[oiPirate].InternalName + OwnerToSys(OwnerId)
  else
    Result := OwnerInfo[OwnerId].InternalName;
end;

constructor TEquipment.Create;
begin
  inherited Create;
  ExtraSpecials := nil;
  EquippedFlag := 0;
end;

destructor TEquipment.Destroy;
var
  I: Integer;
  Entry: PExtraSpecial;
begin
  if ExtraSpecials <> nil then
  begin
    for I := 0 to ExtraSpecials.Count - 1 do
    begin
      Entry := ExtraSpecials[I];
      Dispose(Entry);
    end;
    ExtraSpecials.Free;
  end;
  ExtraSpecials := nil;
  inherited Destroy;
end;

procedure TEquipment.SaveToBuffer(Buffer: TBufEC);
var
  Index, ModuleIndex: Integer;
  Entry: PExtraSpecial;
begin
  inherited SaveToBuffer(Buffer);
  if CustomFaction = '' then
    Buffer.AddBoolean(False)
  else
  begin
    Buffer.AddBoolean(True);
    Buffer.AddWideStringZ(CustomFaction);
  end;
  if ConfigBlockName = '' then
    Buffer.AddBoolean(False)
  else
  begin
    Buffer.AddBoolean(True);
    Buffer.AddWideStringZ(ConfigBlockName);
  end;
  Buffer.AddBoolean(Boolean(EquippedFlag));
  Buffer.AddSingle(ConditionPercent);
  Buffer.AddBoolean(Boolean(BrokenFlag));
  Buffer.AddAnsiChar(AnsiChar(AssignedSlotData));
  Buffer.AddIntegerValue(MicroModuleIndex);
  if MicroModuleIndex > 0 then
    Buffer.AddDWord(MicroModuleTemplates[MicroModuleIndex - 1].ConfigNameHash);
  Buffer.AddIntegerValue(SpecialModuleIndex);
  if SpecialModuleIndex > 0 then
    Buffer.AddDWord(MicroModuleTemplates[SpecialModuleIndex - 1].ConfigNameHash);
  if ExtraSpecials = nil then
    Buffer.AddIntegerValue(0)
  else
  begin
    Buffer.AddIntegerValue(ExtraSpecials.Count);
    for Index := 0 to ExtraSpecials.Count - 1 do
    begin
      Entry := ExtraSpecials[Index];
      ModuleIndex := Entry.ModuleIndexPlusOne;
      Buffer.AddIntegerValue(ModuleIndex);
      if ModuleIndex > 0 then
        Buffer.AddDWord(MicroModuleTemplates[ModuleIndex - 1].ConfigNameHash);
      Buffer.AddIntegerValue(Entry.Count);
    end;
  end;
  Buffer.AddAnsiChar(AnsiChar(DominatorSeries));
end;

function ReadSavedMicroModuleIndex(Buffer: TBufEC): Integer;
var
  I: Integer;
  NameHash: Cardinal;
begin
  Result := Buffer.GetInt32;
  if Result > 0 then
  begin
    NameHash := Buffer.GetUInt32;
    if (High(MicroModuleTemplates) + 1 < Result)
        or (MicroModuleTemplates[Result - 1].ConfigNameHash <> NameHash) then
    begin
      Result := 0;
      for I := 0 to High(MicroModuleTemplates) do
        if MicroModuleTemplates[I].ConfigNameHash = NameHash then
        begin
          Result := I + 1;
          Break;
        end;
    end;
  end;
end;

procedure TEquipment.LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy);
var
  ConfigNumber, Count, Index, ExistingIndex, ModuleIndex: Integer;
  Entry: PExtraSpecial;

  function FindLegacyMicroModuleIndex(
      ConfigNumber: Integer
  ): Integer; { Returns a one-based template index, or 0 if absent. }
  var
    I: Integer;
  begin
    Result := 0;
    for I := 0 to High(MicroModuleTemplates) do
      if MicroModuleTemplates[I].ConfigNumber = ConfigNumber then
      begin
        Result := I + 1;
        Break;
      end;
  end;

begin
  inherited LoadFromBuffer(Buffer, Galaxy);
  if LoadedSaveVersion >= 152 then
    if Buffer.GetBoolean then
      CustomFaction := Buffer.ReadWideString;
  if LoadedSaveVersion >= 86 then
    if Buffer.GetBoolean then
      ConfigBlockName := Buffer.ReadWideString;
  EquippedFlag := Byte(Buffer.GetBoolean);
  ConditionPercent := Buffer.GetSingle;
  BrokenFlag := Byte(Buffer.GetBoolean);
  AssignedSlotData := Buffer.GetByte;
  if LoadedSaveVersion >= 157 then
  begin
    MicroModuleIndex := ReadSavedMicroModuleIndex(Buffer);
    SpecialModuleIndex := ReadSavedMicroModuleIndex(Buffer);
  end
  else if LoadedSaveVersion >= 67 then
  begin
    MicroModuleIndex := Buffer.GetInt32;
    SpecialModuleIndex := Buffer.GetInt32;
    if LoadedSaveVersion >= 98 then
    begin
      if MicroModuleIndex > 0 then
      begin
        ConfigNumber := Buffer.GetInt32;
        if (High(MicroModuleTemplates) + 1 < MicroModuleIndex)
            or (MicroModuleTemplates[MicroModuleIndex - 1].ConfigNumber <> ConfigNumber) then
          MicroModuleIndex := FindLegacyMicroModuleIndex(ConfigNumber);
      end;
      if SpecialModuleIndex > 0 then
      begin
        ConfigNumber := Buffer.GetInt32;
        if (High(MicroModuleTemplates) + 1 < SpecialModuleIndex)
            or (MicroModuleTemplates[SpecialModuleIndex - 1].ConfigNumber <> ConfigNumber) then
          SpecialModuleIndex := FindLegacyMicroModuleIndex(ConfigNumber);
      end;
    end;
  end
  else
  begin
    MicroModuleIndex := Buffer.GetByte;
    SpecialModuleIndex := Buffer.GetByte;
  end;
  if LoadedSaveVersion < 98 then
  begin
    if MicroModuleIndex <> 0 then
    begin
      if MicroModuleTemplates[MicroModuleIndex - 1].ConfigNumber > 24 then
        Inc(MicroModuleIndex);
      if MicroModuleTemplates[MicroModuleIndex - 1].ConfigNumber > 124 then
        Inc(MicroModuleIndex);
      if MicroModuleTemplates[MicroModuleIndex - 1].ConfigNumber > 219 then
        Inc(MicroModuleIndex);
    end;
    if SpecialModuleIndex <> 0 then
    begin
      if MicroModuleTemplates[SpecialModuleIndex - 1].ConfigNumber > 24 then
        Inc(SpecialModuleIndex);
      if MicroModuleTemplates[SpecialModuleIndex - 1].ConfigNumber > 124 then
        Inc(SpecialModuleIndex);
      if MicroModuleTemplates[SpecialModuleIndex - 1].ConfigNumber > 219 then
        Inc(SpecialModuleIndex);
    end;
  end;
  if LoadedSaveVersion >= 116 then
  begin
    Count := Buffer.GetInt32;
    if Count > 0 then
    begin
      ExtraSpecials := TList.Create;
      for Index := 0 to Count - 1 do
      begin
        if LoadedSaveVersion >= 157 then
          ModuleIndex := ReadSavedMicroModuleIndex(Buffer)
        else
        begin
          ModuleIndex := Buffer.GetInt32;
          ConfigNumber := Buffer.GetInt32;
          if (High(MicroModuleTemplates) + 1 < ModuleIndex)
              or (MicroModuleTemplates[ModuleIndex - 1].ConfigNumber <> ConfigNumber) then
            ModuleIndex := FindLegacyMicroModuleIndex(ConfigNumber);
        end;
        if ModuleIndex = 0 then
          ModuleIndex := 1;
        if LoadedSaveVersion >= 140 then
        begin
          New(Entry);
          Entry.ModuleIndexPlusOne := ModuleIndex;
          Entry.Count := Buffer.GetInt32;
          ExtraSpecials.Add(Entry);
        end
        else
        begin
          Entry := nil;
          for ExistingIndex := 0 to ExtraSpecials.Count - 1 do
            if PExtraSpecial(ExtraSpecials[ExistingIndex]).ModuleIndexPlusOne = ModuleIndex then
            begin
              Entry := ExtraSpecials[ExistingIndex];
              Inc(Entry.Count);
              Break;
            end;
          if Entry = nil then
          begin
            New(Entry);
            Entry.ModuleIndexPlusOne := ModuleIndex;
            Entry.Count := 1;
            ExtraSpecials.Add(Entry);
          end;
        end;
      end;
    end;
  end;
  DominatorSeries := TDominatorSeries(Buffer.GetByte);
end;

function TEquipment.Clone: TItem;
var
  Buffer: TBufEC;
  NewId: Cardinal;
begin
  NewId := Galaxy.NextItemId;
  Result := CreateItemByType(ItemType);
  Buffer := TBufEC.Create;
  SaveToBuffer(Buffer);
  Buffer.SetPosition(0);
  LoadedSaveVersion := CurrentSaveVersion;
  Result.LoadFromBuffer(Buffer, Galaxy);
  Result.ResolveLoadedReferences(Galaxy);
  Result.Id := NewId;
  Galaxy.NextItemId := NewId + 1;
  Buffer.Free;
end;

procedure TEquipment.SaveToBlock(Block: TBlockParEC);
var
  I: Integer;
  Entry: PExtraSpecial;
  Text, ModuleName: WideString;
begin
  inherited SaveToBlock(Block);
  Block.AddParam(DecodeTextW('DyuRrdawbRiblNijtSyp'), FloatToStr(ConditionPercent)); // 'Durability'
  Block.AddParam(DecodeTextW('BorYorkNeln'), BoolToWideString(Boolean(BrokenFlag))); // 'Broken'
  Block.AddParam(DecodeTextW('BrognWulso'), IntToStr(MicroModuleIndex)); // 'Bonus'
  if MicroModuleIndex <> 0 then
    Block.AddParam(
        DecodeTextW('IQBaodn4ursTNgatm2e'),
        MicroModuleTemplates[MicroModuleIndex - 1].Name
    ); // 'IBonusName'
  Block.AddParam(DecodeTextW('SrpeeIcjigaEl4'), IntToStr(SpecialModuleIndex)); // 'Special'
  if SpecialModuleIndex <> 0 then
    Block.AddParam(
        DecodeTextW('IaSopRefcGihajl6NtaEm3ew'),
        MicroModuleTemplates[SpecialModuleIndex - 1].Name
    ); // 'ISpecialName'
  if ExtraSpecials <> nil then
  begin
    Text := '';
    for I := 0 to ExtraSpecials.Count - 1 do
    begin
      Entry := ExtraSpecials[I];
      if Text <> '' then
        Text := Text + ', ';
      if (Entry.ModuleIndexPlusOne <= 0)
          or (Entry.ModuleIndexPlusOne > MicroModuleTemplateCount) then
        ModuleName := '<' + IntToWideString(Entry.ModuleIndexPlusOne - 1) + '>'
      else
      begin
        ModuleName := MicroModuleTemplates[Entry.ModuleIndexPlusOne - 1].Name;
        if ModuleName = '' then
          ModuleName := '[' + MicroModuleTemplates[Entry.ModuleIndexPlusOne - 1].ConfigName + ']';
      end;
      if Entry.Count <> 1 then
        Text := Text + IntToWideString(Entry.Count) + 'x' + ModuleName
      else
        Text := Text + ModuleName;
    end;
    if Text <> '' then
      Block.AddParam(DecodeTextW('IaEoxRtfrGahSjp6etcEi3awlhs4'), Text); // 'IExtraSpecials'
  end;
  Block.AddParam(
      DecodeTextW('D9o5meScewr3iwegs4'),
      DominatorSeriesNames[DominatorSeries]
  ); // 'DomSeries'
end;

procedure TEquipment.LoadFromBlock(Block: TBlockParEC);
var
  SeriesIndex: Integer;
  Text: WideString;
begin
  inherited LoadFromBlock(Block);
  ConditionPercent :=
      ExtractDecimalToSingleW(Block.GetParam(DecodeTextW('DyuRrdawbRiblNijtSyp'))); // 'Durability'
  BrokenFlag := Byte(LowerCase(Block.GetParam(DecodeTextW('BorYorkNeln'))) = 'true'); // 'Broken'
  MicroModuleIndex := StrToInt(Block.GetParam(DecodeTextW('BrognWulso'))); // 'Bonus'
  SpecialModuleIndex := StrToInt(Block.GetParam(DecodeTextW('SrpeeIcjigaEl4'))); // 'Special'
  Text := Block.GetParam(DecodeTextW('D9o5meScewr3iwegs4')); // 'DomSeries'
  for SeriesIndex := Ord(Low(TDominatorSeries)) to Ord(High(TDominatorSeries)) do
    if Text = DominatorSeriesNames[TDominatorSeries(SeriesIndex)] then
      DominatorSeries := TDominatorSeries(SeriesIndex);
end;

procedure TEquipment.Equip;
begin
  EquippedFlag := 1;
  if (Galaxy = nil) or Galaxy.Destroying or (GetPlayer = nil) then
    Exit;
  if ScriptItem <> nil then
    TScriptItem(ScriptItem).RunActionCode(satOnItemEquip, nil, nil, nil, 0);
  if Self is TEquipmentWithActCode then
    RunItemConfigActionCode(Self, satOnItemEquip, nil, nil, nil, 0);
end;

procedure TEquipment.Unequip;
begin
  EquippedFlag := 0;
  if (Galaxy = nil) or Galaxy.Destroying or (GetPlayer = nil) then
    Exit;
  if ScriptItem <> nil then
    TScriptItem(ScriptItem).RunActionCode(satOnItemDeEquip, nil, nil, nil, 0);
  if Self is TEquipmentWithActCode then
    RunItemConfigActionCode(Self, satOnItemDeEquip, nil, nil, nil, 0);
end;

procedure TEquipment.Repair;
begin
  ConditionPercent := 100;
  BrokenFlag := 0;
end;

function TEquipment.NeedsRepair: Boolean;
const
  RepairableTypes = [0..79] - [0..7, 9, 23..25, 35..38, 42, 69..72, 74..79];
begin
  if ItemType = t_Hull then
    Result := (Self as THull).HullPoints < (Self as THull).Weight
  else
    Result := (Byte(ItemType) in RepairableTypes) and (ConditionPercent < 90);
end;

function TEquipment.CalculateRepairCost: Integer;
var
  DamagePercent: Double;
begin
  if Self is TCountableItem then
  begin
    Result := 0;
    Exit;
  end;
  if ItemType = t_Hull then
  begin
    Result := 0;
    if (Self as THull).Weight - (Self as THull).HullPoints <> 0 then
    begin
      DamagePercent :=
          100 / (Self as THull).Weight * ((Self as THull).Weight - (Self as THull).HullPoints);
      Result := RoundAndTruncateToTens((Cost div 40) / 100 * DamagePercent + 10);
    end;
  end
  else if ItemType in [t_FuelTanks..t_CustomWeapon, t_Satellite] then
  begin
    if ConditionPercent = 100 then
      Result := 0
    else
      Result :=
          RoundAndTruncateToTens(
              (100 - Round(ConditionPercent)) * ((Cost div 7) / 100) + Cost div 20 + 10
          );
    if BrokenFlag <> 0 then
      Result := Round(Result * 1.3);
  end
  else if ItemType
      in [
          t_Artefact,
          t_ArtefactHull..t_ArtefactAntigrav,
          t_ArtDefToEnergy..t_ArtGiperJump,
          t_ArtBio..t_ArtFastRacks] then
  begin
    if ConditionPercent = 100 then
      Result := 0
    else
      Result :=
          RoundAndTruncateToTens(
              (100 - Round(ConditionPercent)) * ((Cost div 5) / 100) + Cost div 10 + 10
          );
    if BrokenFlag <> 0 then
      Result := Round(Result * 1.3);
    Result := Result * 2;
  end
  else
    Result := 0;
end;

function TEquipment.GetConditionText(PrefixNewLine: Boolean): WideString;
const
  SupportedTypes = [0..79] - [0..7, 9, 23..25, 35..38, 42, 69..72, 74..79];
var
  Prefix: WideString;
begin
  if not (Byte(ItemType) in SupportedTypes) then
  begin
    Result := '';
    Exit;
  end;
  if PrefixNewLine then
    Prefix := #13#10
  else
    Prefix := '';
  if (GetPlayer <> nil) and not GetPlayer.CanUseEquipmentTech(Self) then
  begin
    Result := WrapTextInColor(Prefix + LocalizedText('Items.Equpments.CanNotBeUsed'), RedColorTag);
    Exit;
  end;
  if (GetPlayer <> nil)
      and not GetPlayer.CanRepairEquipmentTech(Self)
      and (BrokenFlag <> 0)
      and not (ItemType in [t_FuelTanks..t_Engine]) then
  begin
    Result := WrapTextInColor(Prefix + LocalizedText('Items.Equpments.CanNotBeUsed'), RedColorTag);
    Exit;
  end;
  if BrokenFlag <> 0 then
  begin
    if ItemType in [t_FuelTanks..t_DefGenerator] then
      Result :=
          WrapTextInColor(
              Prefix + LocalizedText('Items.' + ItemTypeNames[ItemType] + '.Broken'),
              RedColorTag
          )
    else if ItemType in [t_IndustrialLaser..t_CustomWeapon] then
      Result := WrapTextInColor(Prefix + LocalizedText('Items.Weapon.Broken'), RedColorTag)
    else if ItemType in [t_Artefact..t_Artefact2] then
      Result :=
          WrapTextInColor(
              Prefix + LocalizedText('Artefacts.CustomArtefacts.' + ConfigBlockName + '.Broken'),
              RedColorTag
          )
    else if ItemType
        in [
            t_Artefact,
            t_ArtefactHull..t_ArtefactAntigrav,
            t_ArtDefToEnergy..t_ArtGiperJump,
            t_ArtBio..t_ArtFastRacks] then
      Result :=
          WrapTextInColor(
              Prefix + LocalizedText('Artefacts.' + ItemTypeNames[ItemType] + '.Broken'),
              RedColorTag
          )
    else if ItemType = t_Satellite then
      Result := WrapTextInColor(Prefix + LocalizedText('Items.Satellite.Broken'), RedColorTag)
    else
      Result := '';
  end
  else if Self is TArtefact then
  begin
    // Native retains this transmitter branch despite the initial supported-type set.
    if (ItemType = t_ArtefactTransmitter)
        and ((Self as TArtefactTransmitter).Power < MinTransmitterPower) then
      Result :=
          WrapTextInColor(Prefix + LocalizedText('Artefacts.ArtTransmitter.Broken'), GoldColorTag)
    else
      Result := '';
  end
  else if ConditionPercent < 20 then
    Result := WrapTextInColor(Prefix + LocalizedText('Items.Equpments.SmallDuration'), GoldColorTag)
  else if ConditionPercent < 50 then
    Result :=
        WrapTextInColor(Prefix + LocalizedText('Items.Equpments.AverageDuration'), GrayColorTag)
  else
    Result := '';
  if (GetPlayer <> nil) and not GetPlayer.CanRepairEquipmentTech(Self) then
  begin
    if not PrefixNewLine then
      Result := '';
    Result :=
        WrapTextInColor(Prefix + LocalizedText('Items.Equpments.CanNotBeRepaired'), GrayColorTag)
            + Result;
  end;
end;

function TEquipment.GetBrokenInBattleText: WideString;
begin
  if ItemType in [t_FuelTanks..t_DefGenerator] then
    Result := LocalizedText('Items.' + ItemTypeNames[ItemType] + '.BrokenInBattle')
  else if ItemType in [t_IndustrialLaser..t_CustomWeapon] then
    Result :=
        FormatText1(
            LocalizedText('Items.Weapon.BrokenInBattle'),
            TextHighlightColorTag,
            '<Name>',
            GetDisplayName
        )
  else if ItemType in [t_Artefact..t_Artefact2] then
    Result := LocalizedText('Artefacts.CustomArtefacts.' + ConfigBlockName + '.BrokenInBattle')
  else if ItemType
      in [
          t_Artefact,
          t_ArtefactHull..t_ArtefactAntigrav,
          t_ArtDefToEnergy..t_ArtGiperJump,
          t_ArtBio..t_ArtFastRacks] then
    Result := LocalizedText('Artefacts.' + ItemTypeNames[ItemType] + '.BrokenInBattle')
  else
    Result := '';
end;

function TEquipment.GetBrokenInUseText: WideString;
begin
  if ItemType in [t_FuelTanks..t_DefGenerator] then
    Result := LocalizedText('Items.' + ItemTypeNames[ItemType] + '.BrokenInUse')
  else if ItemType in [t_IndustrialLaser..t_CustomWeapon] then
    Result :=
        FormatText1(
            LocalizedText('Items.Weapon.BrokenInUse'),
            TextHighlightColorTag,
            '<Name>',
            GetDisplayName
        )
  else if ItemType in [t_Artefact..t_Artefact2] then
    Result := LocalizedText('Artefacts.CustomArtefacts.' + ConfigBlockName + '.BrokenInUse')
  else if ItemType
      in [
          t_Artefact,
          t_ArtefactHull..t_ArtefactAntigrav,
          t_ArtDefToEnergy..t_ArtGiperJump,
          t_ArtBio..t_ArtFastRacks] then
    Result := LocalizedText('Artefacts.' + ItemTypeNames[ItemType] + '.BrokenInUse')
  else
    Result := '';
end;

function TEquipment.GetBrokenByForceText: WideString;
begin
  Result := '';
  if ItemType in [t_FuelTanks..t_DefGenerator] then
    Result := LocalizedText('Items.' + ItemTypeNames[ItemType] + '.BrokenByForce')
  else if ItemType in [t_IndustrialLaser..t_CustomWeapon] then
    Result :=
        FormatText1(
            LocalizedText('Items.Weapon.BrokenByForce'),
            TextHighlightColorTag,
            '<Name>',
            GetDisplayName
        )
  else if ItemType in [t_Artefact..t_Artefact2] then
    Result := LocalizedText('Artefacts.CustomArtefacts.' + ConfigBlockName + '.BrokenByForce')
  else if ItemType
      in [
          t_Artefact,
          t_ArtefactHull..t_ArtefactAntigrav,
          t_ArtDefToEnergy..t_ArtGiperJump,
          t_ArtBio..t_ArtFastRacks] then
    Result := LocalizedText('Artefacts.' + ItemTypeNames[ItemType] + '.BrokenByForce')
  else
    Exit;
  if Result = '' then
    Result := GetBrokenInUseText;
end;

function TEquipment.GetLevel: Integer;
begin
  case ItemType of
    t_Hull: Result := (Self as THull).TechLevel;
    t_FuelTanks: Result := (Self as TFuelTanks).TechLevel;
    t_Engine: Result := (Self as TEngine).TechLevel;
    t_Radar: Result := (Self as TRadar).TechLevel;
    t_Scaner: Result := (Self as TScaner).TechLevel;
    t_RepairRobot: Result := (Self as TRepairRobot).TechLevel;
    t_CargoHook: Result := (Self as TCargoHook).TechLevel;
    t_DefGenerator: Result := (Self as TDefGenerator).TechLevel;
  else
    if ItemType in [t_IndustrialLaser..t_CustomWeapon] then
      Result := (Self as TWeapon).TechLevel
    else
      Result := 0;
  end;
end;

var
  EquipmentLevelLetters: array[1..8] of WideString = ('A', 'B', 'C', 'D', 'E', 'F', 'G', 'H');
var
  TreasureMapColumnPositions: array[1..2, 0..3] of Integer =
      ((20, 40, 280, 380), (20, 40, 380, 490));
  TreasureMapRuleLengths: array[1..2] of Integer = (76, 98);

function TEquipment.GetLevelLetter: WideString;
var
  Level: Integer;
begin
  Level := GetLevel;
  Result := '';
  if (Level >= 1) and (Level <= 8) then
    Result := EquipmentLevelLetters[Level];
end;

function TEquipment.GetDescriptionText: WideString;
begin
  if (ItemType in [t_FuelTanks..t_DefGenerator]) and (OwnerId = oiDominator) then
    Result :=
        LocalizedText(
            'Items.' + ItemTypeNames[ItemType] + '.KlingDescription.' + IntToStr(GetLevel)
        )
  else
    Result :=
        LocalizedText('Items.' + ItemTypeNames[ItemType] + '.Description.' + IntToStr(GetLevel));
end;

function TEquipment.GetDisplayName: WideString;
var
  TypeName: WideString;
begin
  Result := '';
  if NameOverride <> '' then
    Result := NameOverride
  else if SpecialModuleIndex <> 0 then
    Result :=
        WrapTextInColor(GetSpecialModuleName, GetMicroModuleTextColorTag(SpecialModuleIndex - 1))
  else if CustomFaction <> '' then
    Result := LocalizedText('Items.' + ItemTypeNames[ItemType] + '.' + CustomFaction + 'Name');
  if Result = '' then
  begin
    if OwnerId <> oiDominator then
    begin
      TypeName := LocalizedText('Items.' + ItemTypeNames[ItemType] + '.Type.' + IntToStr(GetLevel));
      Result :=
          ReplaceColoredToken(
              LocalizedText('Items.' + ItemTypeNames[ItemType] + '.Name'),
              '<Type>',
              TypeName,
              ''
          );
    end
    else
      Result := LocalizedText('Items.' + ItemTypeNames[ItemType] + '.KlingName');
  end;
  if HasMicroModule then
    Result :=
        Result
            + ' '
            + WrapTextInColor(
                GetMicroModuleQuotedName,
                GetMicroModuleNameColorTag(MicroModuleIndex - 1));
end;

function TEquipment.GetShortName: WideString;
begin
  if NameOverride <> '' then
    Result := NameOverride
  else if OwnerId <> oiDominator then
    Result := LocalizedText('Items.' + ItemTypeNames[ItemType] + '.ShortName')
  else
    Result := LocalizedText('Items.' + ItemTypeNames[ItemType] + '.KlingName');
end;

procedure TEquipment.ImproveAtScientificBase;
begin
  DetailImprovement := (Cardinal(Id) mod 2) + 1;
  case (Cardinal(Id) div 3) mod 6 of
    0: Improve(ikMajor);
    1..2: Improve(ikMedium);
  else
    Improve(ikMinor);
  end;
end;

function TEquipment.HasMicroModule: Boolean;
begin
  Result := MicroModuleIndex <> 0;
end;

function TEquipment.GetMicroModuleQuotedName: WideString;
begin
  if HasMicroModule then
  begin
    if FindTextOffsetW(MicroModuleTemplates[MicroModuleIndex - 1].Name, '"') >= 0 then
      Result := MicroModuleTemplates[MicroModuleIndex - 1].Name
    else
      Result := '"' + MicroModuleTemplates[MicroModuleIndex - 1].Name + '"';
  end
  else
    Result := '';
end;

function TEquipment.GetSpecialModuleName: WideString;
begin
  if SpecialModuleIndex <> 0 then
    Result := MicroModuleTemplates[SpecialModuleIndex - 1].Name
  else
    Result := '';
end;

procedure TEquipment.Improve(Kind: TImprovementKind);
begin
end;

function TEquipment.CalculateImprovementCost(Kind: TImprovementKind): Integer;
begin
  case Kind of
    ikMinor: Result := RoundAndTruncateToTens(Cost * 0.3);
    ikMedium: Result := RoundAndTruncateToTens(Cost * 0.6);
    ikMajor: Result := RoundAndTruncateToTens(Cost * 1.2);
  else
    RaiseWideMessage('Косяк в улучшении');
    Result := 0;
  end;
end;

function TEquipment.HasStandardStats: Boolean;
begin
  Result := True;
end;

function TEquipment.GetBitmapResourceName: WideString;
var
  Path: WideString;
begin
  Result := '';
  if ConfigBlockName <> '' then
    Result := 'Bm.Items.' + GiResourceSuffix + ConfigBlockName
  else if (SpecialModuleIndex > 0)
      and (MicroModuleTemplates[SpecialModuleIndex - 1].KindGraph <> '') then
    Result :=
        'Bm.Items.'
            + GiResourceSuffix
            + ItemTypeNames[ItemType]
            + MicroModuleTemplates[SpecialModuleIndex - 1].KindGraph
  else if CustomFaction <> '' then
  begin
    Path := 'Bm.Items.' + GiResourceSuffix + ItemTypeNames[ItemType] + CustomFaction;
    if CacheDataRoot.FileExistsByPath(Path + 'a')
        and CacheDataRoot.FileExistsByPath(Path + 'i')
        and CacheDataRoot.FileExistsByPath(Path + 's') then
      Result := Path;
  end;
  if Result = '' then
    if OwnerId = oiDominator then
      Result := 'Bm.Items.' + GiResourceSuffix + ItemTypeNames[ItemType] + 'Kling0'
    else
      Result := 'Bm.Items.' + GiResourceSuffix + ItemTypeNames[ItemType] + IntToStr(GetLevel - 1);
end;

function TEquipment.GetFragilityFactor(DamageFlags: TDamageFlagSet): Single;
var
  I: Integer;
  Entry: PExtraSpecial;
  Factor: Single;
begin
  Result := 1 / Max(0.001, OwnerInfo[OwnerId].EquipmentDurabilityFactor);
  if MicroModuleIndex <> 0 then
    Result := Result * MicroModuleTemplates[MicroModuleIndex - 1].FragilityFactor;
  if SpecialModuleIndex <> 0 then
    Result := Result * MicroModuleTemplates[SpecialModuleIndex - 1].FragilityFactor;
  if ExtraSpecials <> nil then
    for I := 0 to ExtraSpecials.Count - 1 do
    begin
      Entry := ExtraSpecials[I];
      Factor := MicroModuleTemplates[Entry.ModuleIndexPlusOne - 1].FragilityFactor;
      if Abs(Factor - 1) > 0.000001 then
      begin
        if Entry.Count = 1 then
          Result := Result * Factor
        else
          Result := Power(Factor, Entry.Count) * Result;
      end;
    end;
end;

procedure TEquipment.ReplaceInfoTokens(var Text: WideString; ColorTag: WideString; Ship: Pointer);
begin
end;

function TEquipment.GetStatBonus(BonusKind: TEquipmentBonusKind): Integer;
var
  I, SpecialBonus: Integer;
  Entry: PExtraSpecial;
begin
  if (BonusKind in [bonSkill1..bonSkill6, bonStimCapacity]) and (MicroModuleIndex <> 0) then
    Result := MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[BonusKind]
  else
    Result := 0;
  if (ItemType in [t_IndustrialLaser..t_CustomWeapon])
      and (BonusKind in [bonWEnergy..bonWRadius, bonMissileSpeed]) then
    Exit;
  if SpecialModuleIndex <> 0 then
    SpecialBonus := MicroModuleTemplates[SpecialModuleIndex - 1].StatBonuses[BonusKind]
  else
    SpecialBonus := 0;
  if ExtraSpecials <> nil then
    for I := 0 to ExtraSpecials.Count - 1 do
    begin
      Entry := ExtraSpecials[I];
      Inc(
          SpecialBonus,
          MicroModuleTemplates[Entry.ModuleIndexPlusOne - 1].StatBonuses[BonusKind] * Entry.Count
      );
    end;
  if (SpecialBonus <> 0)
      and (MicroModuleIndex <> 0)
      and not (BonusKind in [bonExtraAkrinEff, bonExtraAkrinPenalty]) then
  begin
    if (BonusKind in [bonMass]) = (SpecialBonus > 0) then
      Inc(
          SpecialBonus,
          Round(
              MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonExtraAkrinPenalty]
                  * SpecialBonus
                  * 0.0001
          )
      )
    else
      Inc(
          SpecialBonus,
          Round(
              MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonExtraAkrinEff]
                  * SpecialBonus
                  * 0.0001
          )
      );
  end;
  Inc(Result, SpecialBonus);
end;

function TEquipment.GetDescriptionStatBonus(BonusKind: TEquipmentBonusKind): Integer;
var
  Index, CombinedBonus, SeparatedBonus, ExtraSeparatedBonus, EffectPercent, PenaltyPercent: Integer;
  Entry: PExtraSpecial;
begin
  if (BonusKind in [bonSkill1..bonSkill6, bonStimCapacity])
      and (MicroModuleIndex <> 0)
      and not MicroModuleTemplates[MicroModuleIndex - 1].SeparatedNumbers then
    Result := MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[BonusKind]
  else
    Result := 0;
  if (ItemType in [t_IndustrialLaser..t_CustomWeapon])
      and (BonusKind in [bonWEnergy..bonWRadius, bonMissileSpeed]) then
    Exit;
  CombinedBonus := 0;
  SeparatedBonus := 0;
  ExtraSeparatedBonus := 0;
  if SpecialModuleIndex <> 0 then
    if MicroModuleTemplates[SpecialModuleIndex - 1].SeparatedNumbers then
      SeparatedBonus := MicroModuleTemplates[SpecialModuleIndex - 1].StatBonuses[BonusKind]
    else
      CombinedBonus := MicroModuleTemplates[SpecialModuleIndex - 1].StatBonuses[BonusKind];
  if ExtraSpecials <> nil then
    for Index := 0 to ExtraSpecials.Count - 1 do
    begin
      Entry := ExtraSpecials[Index];
      if MicroModuleTemplates[Entry.ModuleIndexPlusOne - 1].SeparatedNumbers then
        ExtraSeparatedBonus :=
            CombinedBonus
                + MicroModuleTemplates[Entry.ModuleIndexPlusOne - 1].StatBonuses[BonusKind]
                    * Entry.Count
      else
        CombinedBonus :=
            CombinedBonus
                + MicroModuleTemplates[Entry.ModuleIndexPlusOne - 1].StatBonuses[BonusKind]
                    * Entry.Count;
    end;
  if MicroModuleIndex <> 0 then
  begin
    EffectPercent := MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonExtraAkrinEff];
    PenaltyPercent := MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonExtraAkrinPenalty];
  end
  else
  begin
    EffectPercent := 0;
    PenaltyPercent := 0;
  end;
  if ((EffectPercent <> 0) or (PenaltyPercent <> 0))
      and ((CombinedBonus <> 0) or (SeparatedBonus <> 0) or (ExtraSeparatedBonus <> 0))
      and not (BonusKind in [bonExtraAkrinEff..bonExtraAkrinPenalty]) then
  begin
    CombinedBonus := CombinedBonus + SeparatedBonus + ExtraSeparatedBonus;
    if (BonusKind in [bonMass]) = (CombinedBonus > 0) then
      CombinedBonus := CombinedBonus + Round(CombinedBonus * PenaltyPercent * 0.0001)
    else
      CombinedBonus := CombinedBonus + Round(CombinedBonus * EffectPercent * 0.0001);
    if (BonusKind in [bonMass]) = (SeparatedBonus > 0) then
      SeparatedBonus := SeparatedBonus + Round(SeparatedBonus * PenaltyPercent * 0.0001)
    else
      SeparatedBonus := SeparatedBonus + Round(SeparatedBonus * EffectPercent * 0.0001);
    if (BonusKind in [bonMass]) = (ExtraSeparatedBonus > 0) then
      ExtraSeparatedBonus :=
          ExtraSeparatedBonus + Round(ExtraSeparatedBonus * PenaltyPercent * 0.0001)
    else
      ExtraSeparatedBonus :=
          ExtraSeparatedBonus + Round(ExtraSeparatedBonus * EffectPercent * 0.0001);
    CombinedBonus := CombinedBonus - SeparatedBonus - ExtraSeparatedBonus;
  end;
  Result := Result + CombinedBonus;
end;

function TEquipment.GetBonusDescription(ColorTag: WideString): WideString;
var
  Description: WideString;
  EffectPercent, PenaltyPercent, StatBonus: Integer;
  BonusKind: TEquipmentBonusKind;
  Index, ModuleIndexPlusOne: Integer;

  function ExpandModuleTokens(
      Text: WideString;
      ModuleIndexPlusOne, Count: Integer
  ): WideString; { Uses the parent description, bonus multipliers and color. RET 4 removes Result; the caller removes ParentFrame. Count 0 suppresses numeric bonuses. }
  var
    BonusIndex: TEquipmentBonusKind;
    Value: Integer;
  begin
    // The native helper reads the captured description; Text remains an unused managed parameter.
    Result := Description;
    for BonusIndex := Low(TEquipmentBonusKind) to High(TEquipmentBonusKind) do
    begin
      Value := MicroModuleTemplates[ModuleIndexPlusOne - 1].StatBonuses[BonusIndex];
      Value := Value * Count;
      if (Count <> 0)
          and (EffectPercent <> 0)
          and not (BonusIndex in [bonExtraAkrinEff..bonExtraAkrinPenalty]) then
        if (BonusIndex in [bonMass]) = (Value > 0) then
          Value := Value + Round(Value * PenaltyPercent * 0.0001)
        else
          Value := Value + Round(Value * EffectPercent * 0.0001);
      if Value > 0 then
        ReplaceTextToken(
            Result,
            '<' + EquipmentBonusNames[BonusIndex] + '>',
            '+' + IntToStr(Value),
            ColorTag
        )
      else if Value < 0 then
        ReplaceTextToken(
            Result,
            '<' + EquipmentBonusNames[BonusIndex] + '>',
            IntToStr(Value),
            ColorTag
        )
      else
        ReplaceTextToken(Result, '<' + EquipmentBonusNames[BonusIndex] + '>', '--', ColorTag);
    end;
  end;

begin
  Result := '';
  if MicroModuleIndex <> 0 then
  begin
    EffectPercent := MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonExtraAkrinEff];
    PenaltyPercent := MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonExtraAkrinPenalty];
  end
  else
  begin
    EffectPercent := 0;
    PenaltyPercent := 0;
  end;
  if SpecialModuleIndex <> 0 then
  begin
    Description :=
        LocalizedColorText(
            'MicroModuls.' + MicroModuleTemplates[SpecialModuleIndex - 1].ConfigName + '.Text'
        );
    if MicroModuleTemplates[SpecialModuleIndex - 1].SeparatedNumbers then
      Description := ExpandModuleTokens(Description, SpecialModuleIndex, 1);
    if (Self is TWeapon)
        and (MicroModuleTemplates[SpecialModuleIndex - 1].TextReplace = '')
        and (GetSpecialModuleName <> '') then
    begin
      Result :=
          #13#10' '#13#10
              + LocalizedText('Items.Weapon.WSpecial')
              + ' '
              + WrapTextInColor(GetSpecialModuleName, TextHighlightColorTag);
      if Description <> '' then
        Result :=
            Result
                + #13#10
                + WrapTextInColor(Description, GetMicroModuleTextColorTag(SpecialModuleIndex - 1));
    end
    else if Description <> '' then
      Result :=
          #13#10' '#13#10
              + WrapTextInColor(Description, GetMicroModuleTextColorTag(SpecialModuleIndex - 1));
  end;
  if MicroModuleIndex <> 0 then
  begin
    Description :=
        LocalizedColorText(
            'MicroModuls.' + MicroModuleTemplates[MicroModuleIndex - 1].ConfigName + '.ExText'
        );
    if Description <> '' then
    begin
      if MicroModuleTemplates[MicroModuleIndex - 1].SeparatedNumbers then
        Description := ExpandModuleTokens(Description, MicroModuleIndex, 0);
      Result :=
          Result
              + #13#10
              + WrapTextInColor(Description, GetMicroModuleTextColorTag(MicroModuleIndex - 1));
    end;
  end;
  if ExtraSpecials <> nil then
    for Index := 0 to ExtraSpecials.Count - 1 do
    begin
      ModuleIndexPlusOne := PExtraSpecial(ExtraSpecials[Index]).ModuleIndexPlusOne;
      if (ModuleIndexPlusOne <> MicroModuleIndex)
          or MicroModuleTemplates[ModuleIndexPlusOne - 1].SeparatedNumbers then
      begin
        Description :=
            LocalizedColorText(
                'MicroModuls.' + MicroModuleTemplates[ModuleIndexPlusOne - 1].ConfigName + '.ExText'
            );
        if Description <> '' then
        begin
          ReplaceTextToken(
              Description,
              '<ExCount>',
              IntToStr(PExtraSpecial(ExtraSpecials[Index]).Count),
              ColorTag
          );
          if MicroModuleTemplates[ModuleIndexPlusOne - 1].SeparatedNumbers then
            Description :=
                ExpandModuleTokens(
                    Description,
                    ModuleIndexPlusOne,
                    PExtraSpecial(ExtraSpecials[Index]).Count
                );
          Result :=
              Result
                  + #13#10
                  + WrapTextInColor(
                      Description,
                      GetMicroModuleTextColorTag(ModuleIndexPlusOne - 1));
        end;
      end;
    end;
  if Result <> '' then
    for BonusKind := bonHull to bonNull do
    begin
      StatBonus := GetDescriptionStatBonus(BonusKind);
      if StatBonus > 0 then
        ReplaceTextToken(
            Result,
            '<' + EquipmentBonusNames[BonusKind] + '>',
            '+' + IntToStr(StatBonus),
            ColorTag
        )
      else if StatBonus < 0 then
        ReplaceTextToken(
            Result,
            '<' + EquipmentBonusNames[BonusKind] + '>',
            IntToStr(StatBonus),
            ColorTag
        )
      else
        ReplaceTextToken(Result, '<' + EquipmentBonusNames[BonusKind] + '>', '--', ColorTag);
    end;
end;

function TEquipment.CanImprove: Boolean;
begin
  Result :=
      HasStandardStats
          and ((SpecialModuleIndex = 0)
              or not MicroModuleTemplates[SpecialModuleIndex - 1].BlocksSpecialSlot);
end;

procedure THull.Init(
    Capacity: Integer;
    Level: Byte;
    Owner: TOwnerId;
    HullType: THullType;
    Series: Integer;
    PirateBuilt: Boolean
);
begin
  ItemType := t_Hull;
  OwnerShip := nil;
  Weight := Capacity;
  HullPoints := Weight;
  Self.HullType := HullType;
  TechLevel := Level;
  OwnerId := Owner;
  Armor := CalculateGeneratedArmor;
  Repair;
  Cost := CalculateGeneratedCost;
  MicroModuleIndex := 0;
  HullSeries := Series;
  Self.PirateBuilt := PirateBuilt;
  ApplySeriesSizeAndCost;
  CapitalShip := 0;
  ImpulseShieldsEnabled := False;
  InterceptorsEnabled := False;
  Energy := 0;
  EnergyMax := 0;
  InterceptorTarget := nil;
end;

procedure THull.ApplySeriesSizeAndCost;
var
  NewWeight: Integer;
begin
  if HullSeries <> -1 then
  begin
    NewWeight := Round(Weight / 100 * HullSeriesDefinitions[HullSeries].SizePercent);
    if NewWeight < Weight then
      NewWeight := Min(Weight, Max(250, NewWeight));
    Weight := NewWeight;
    HullPoints := Weight;
    Cost := RoundAndTruncateToTens(Cost / 100 * HullSeriesDefinitions[HullSeries].CostPercent);
    if (Cost < 0) or (Cost > MaxMonetaryValue) then
      Cost := MaxMonetaryValue;
  end;
end;

procedure THull.SaveToBuffer(Buffer: TBufEC);
begin
  inherited SaveToBuffer(Buffer);
  Buffer.AddIntegerValue(HullPoints);
  Buffer.AddAnsiChar(AnsiChar(TechLevel));
  Buffer.AddAnsiChar(AnsiChar(Armor));
  Buffer.AddAnsiChar(AnsiChar(HullType));
  Buffer.AddIntegerValue(HullSeries);
  if HullSeries <> -1 then
    Buffer.AddDWord(HullSeriesDefinitions[HullSeries].SystemNameCRC);
  Buffer.AddBoolean(PirateBuilt);
  Buffer.AddAnsiChar(AnsiChar(CapitalShip));
  Buffer.AddBoolean(ImpulseShieldsEnabled);
  Buffer.AddBoolean(InterceptorsEnabled);
  Buffer.AddIntegerValue(Energy);
  Buffer.AddIntegerValue(EnergyMax);
  if InterceptorsEnabled then
  begin
    if InterceptorTarget <> nil then
      Buffer.AddDWord((TObject(InterceptorTarget) as TShip).Id)
    else
      Buffer.AddDWord(0);
    Buffer.AddAnsiChar(AnsiChar(InterceptorTargetingStrategy));
    Buffer.AddAnsiChar(AnsiChar(InterceptorPassCountOverride));
  end;
end;

procedure THull.LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy);
var
  SavedHullType: Integer;

  function ReadSavedHullSeriesIndex(
      Buffer: TBufEC
  ): Integer; { Returns a zero-based series index, or -1 if absent or unresolved. }
  var
    I: Integer;
    CRC: Cardinal;
  begin
    Result := Buffer.GetInt32;
    if Result <> -1 then
    begin
      CRC := Buffer.GetUInt32;
      if (Result > High(HullSeriesDefinitions))
          or (HullSeriesDefinitions[Result].SystemNameCRC <> CRC) then
      begin
        Result := -1;
        for I := 0 to High(HullSeriesDefinitions) do
          if HullSeriesDefinitions[I].SystemNameCRC = CRC then
          begin
            Result := I;
            Break;
          end;
      end;
    end;
  end;

begin
  inherited LoadFromBuffer(Buffer, Galaxy);
  if LoadedSaveVersion >= 51 then
    HullPoints := Buffer.GetInt32
  else
    HullPoints := Buffer.GetWord;
  TechLevel := Buffer.GetByte;
  Armor := ShortInt(Buffer.GetByte);
  SavedHullType := Buffer.GetByte;
  if LoadedSaveVersion >= 88 then
    HullType := THullType(SavedHullType)
  else if LoadedSaveVersion >= 67 then
  begin
    if (SavedHullType > 6) and (SavedHullType < 24) then
      SavedHullType := 6;
    if SavedHullType >= 24 then
      Dec(SavedHullType, 17);
    HullType := THullType(SavedHullType);
  end
  else if SavedHullType > 26 then
    HullType := htSpecial
  else
  begin
    if (SavedHullType > 6) and (SavedHullType < 24) then
      SavedHullType := 6;
    if SavedHullType >= 24 then
      Dec(SavedHullType, 17);
    HullType := THullType(SavedHullType);
  end;
  if (HullType = htSpecial) and (SpecialModuleIndex = 0) then
    HullType := htRanger;
  if LoadedSaveVersion >= 163 then
    HullSeries := ReadSavedHullSeriesIndex(Buffer)
  else
  begin
    HullSeries := Buffer.GetByte;
    if (HullSeries = 255) or (High(HullSeriesDefinitions) < HullSeries) then
      HullSeries := -1;
  end;
  if LoadedSaveVersion >= 50 then
    PirateBuilt := Buffer.GetBoolean
  else
    PirateBuilt := False;
  if LoadedSaveVersion >= 51 then
  begin
    CapitalShip := Buffer.GetByte;
    ImpulseShieldsEnabled := Buffer.GetBoolean;
    InterceptorsEnabled := Buffer.GetBoolean;
    Energy := Buffer.GetInt32;
    EnergyMax := Buffer.GetInt32;
  end
  else
  begin
    CapitalShip := 0;
    ImpulseShieldsEnabled := False;
    InterceptorsEnabled := False;
    Energy := 0;
    EnergyMax := 0;
  end;
  if LoadedSaveVersion >= 52 then
    if InterceptorsEnabled then
    begin
      InterceptorTarget := Pointer(Buffer.GetUInt32);
      InterceptorTargetingStrategy := TInterceptorTargetingStrategy(Buffer.GetByte);
      InterceptorPassCountOverride := Buffer.GetByte;
    end
    else
    begin
      InterceptorTarget := nil;
      InterceptorTargetingStrategy := itsManual;
      InterceptorPassCountOverride := 0;
    end
  else if LoadedSaveVersion = 51 then
  begin
    InterceptorTarget := Pointer(Buffer.GetUInt32);
    InterceptorTargetingStrategy := itsManual;
    InterceptorPassCountOverride := 0;
  end
  else
  begin
    InterceptorTarget := nil;
    InterceptorTargetingStrategy := itsManual;
    InterceptorPassCountOverride := 0;
  end;
end;

procedure THull.ResolveLoadedReferences(Galaxy: TGalaxy);
begin
  if InterceptorTarget <> nil then
    InterceptorTarget := TObject(Galaxy.IdToShip(Integer(InterceptorTarget), False)) as TShip;
end;

procedure THull.ClearReferences;
begin
  inherited ClearReferences;
  InterceptorTarget := nil;
end;

procedure THull.SaveToBlock(Block: TBlockParEC);
begin
  inherited SaveToBlock(Block);
  Block.AddParam(DecodeTextW('Hristophorisnotuse'), IntToStr(HullPoints)); // 'Hitpoints'
  Block.AddParam(DecodeTextW('Tre4cwh0L6eHv3ealf'), IntToStr(TechLevel)); // 'TechLevel'
  Block.AddParam(DecodeTextW('Alrumuotr'), IntToStr(Armor)); // 'Armor'
  Block.AddParam(DecodeTextW('SohtiEprTtyopwec'), IntToStr(Ord(HullType))); // 'ShipType'
  Block.AddParam(DecodeTextW('Stearoidess'), IntToStr(HullSeries)); // 'Series'
  if HullSeries <> -1 then
    Block.AddParam(DecodeTextW('IfSoenrOilets2Noarmye'), GetSeriesName); // 'ISeriesName'
  Block.AddParam(
      DecodeTextW('BlueivlitoBuyAPIinroaLtte'),
      BoolToWideString(PirateBuilt)
  ); // 'BuiltByPirate'
end;

procedure THull.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  HullPoints := StrToInt(Block.GetParam(DecodeTextW('Hristophorisnotuse'))); // 'Hitpoints'
  TechLevel := StrToInt(Block.GetParam(DecodeTextW('Tre4cwh0L6eHv3ealf'))); // 'TechLevel'
  Armor := StrToInt(Block.GetParam(DecodeTextW('Alrumuotr'))); // 'Armor'
  HullType := THullType(StrToInt(Block.GetParam(DecodeTextW('SohtiEprTtyopwec')))); // 'ShipType'
  HullSeries := StrToInt(Block.GetParam(DecodeTextW('Stearoidess'))); // 'Series'
  PirateBuilt :=
      LowerCase(Block.GetParam(DecodeTextW('BlueivlitoBuyAPIinroaLtte')))
          = 'true'; // 'BuiltByPirate'
end;

function THull.CalculateGeneratedArmor: ShortInt;
begin
  Result := HullLevelStats[TechLevel].Armor;
end;

function CalculateGeneratedHullCost(
    Capacity, Level: Cardinal;
    Owner: TOwnerId;
    HullType: THullType
): Integer;
var
  Kind: TShipSlotKind;
  Factor: Double;
begin
  Factor := 1;
  if HullType in [htRanger..htDiplomat] then
  begin
    for Kind := sskRadar to sskAfterburner do
      case Kind of
        sskRadar:
          if GetBaseHullSlotCount(Kind, HullType, Owner, nil) = 0 then
            Factor := 0.7 * Factor;
        sskScanner:
          if GetBaseHullSlotCount(Kind, HullType, Owner, nil) = 0 then
            Factor := 0.9 * Factor;
        sskRepairRobot:
          if GetBaseHullSlotCount(Kind, HullType, Owner, nil) = 0 then
            Factor := 0.7 * Factor;
        sskCargoHook:
          if GetBaseHullSlotCount(Kind, HullType, Owner, nil) = 0 then
            Factor := 0.6 * Factor;
        sskDefGenerator:
          if GetBaseHullSlotCount(Kind, HullType, Owner, nil) = 0 then
            Factor := 0.7 * Factor;
        sskWeapon:
          Factor :=
              RemapClamped(GetBaseHullSlotCount(Kind, HullType, Owner, nil), 2, 5, 0.5, 1) * Factor;
        sskArtefact:
          Factor :=
              RemapClamped(GetBaseHullSlotCount(Kind, HullType, Owner, nil), 0, 4, 0.7, 1) * Factor;
        sskAfterburner:
          if GetBaseHullSlotCount(Kind, HullType, Owner, nil) = 0 then
            Factor := 0.85 * Factor;
      end;
    if Factor < 0.2 then
      Factor := 0.2;
  end
  else if HullType = htFlagship then
    Factor := 0.05;
  Result :=
      RoundAndTruncateToTens(
          RemapClamped(Level, 1, 8, 1, 8)
              * 2000
              * Factor
              * (Max(Capacity, 250) * 0.01 - 0.006)
              * (Max(Capacity, 1000) * 0.002 - 0.001)
              * (Max(Capacity, 2000) * 0.0005)
      );
end;

function THull.CalculateGeneratedCost: Integer;
var
  Value: Integer;
begin
  Value := CalculateGeneratedHullCost(Weight, TechLevel, OwnerId, HullType);
  while Value < 0 do
  begin
    Weight := Abs(Round(Weight / 2));
    HullPoints := Weight;
    Value := CalculateGeneratedHullCost(Weight, TechLevel, OwnerId, HullType);
  end;
  Result := Value;
end;

procedure THull.Repair;
begin
  inherited Repair;
  HullPoints := Weight;
end;

procedure THull.Improve(Kind: TImprovementKind);
var
  ExtraCapacity: Integer;

begin
  if Kind = ikAny then
    Kind := TImprovementKind(SeededRandomIntRange(0, 2, Galaxy.CurrentTurn * Id));
  case Kind of
    ikMinor: Inc(Armor, SeededRandomIntRange(1, 2, Id * 254571));
    ikMedium: Inc(Armor, SeededRandomIntRange(2, 3, Id * 254571));
    ikMajor: Inc(Armor, SeededRandomIntRange(3, 4, Id * 254571));
  end;
  if HullType = htTranclucator then
  begin
    ExtraCapacity := 0;
    case Kind of
      ikMinor:
        ExtraCapacity := Round(SeededRandomIntRange(3, 7, Id * 214571) * Max(Weight, 500) * 0.01);
      ikMedium:
        ExtraCapacity := Round(SeededRandomIntRange(8, 12, Id * 214571) * Max(Weight, 500) * 0.01);
      ikMajor:
        ExtraCapacity := Round(SeededRandomIntRange(13, 17, Id * 214571) * Max(Weight, 500) * 0.01);
    end;
    Inc(Weight, ExtraCapacity);
    Inc(HullPoints, ExtraCapacity);
  end;
  Inc(Cost, CalculateImprovementCost(Kind) div 2);
end;

function THull.HasStandardStats: Boolean;
begin
  if (MicroModuleIndex = 0)
      or (MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonHull] = 0) then
    Result := CalculateGeneratedArmor = Armor
  else
    Result :=
        CalculateGeneratedArmor
            = Armor - MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonHull];
end;

function THull.GetDisplayName: WideString;
var
  TypeName, ShipTypeName: WideString;
begin
  if NameOverride <> '' then
    Result := NameOverride
  else if SpecialModuleIndex <> 0 then
  begin
    Result :=
        WrapTextInColor(GetSpecialModuleName, GetMicroModuleTextColorTag(SpecialModuleIndex - 1));
    ReplaceTextToken(Result, '<Type>', LocalizedText('Items.Hull.Type.' + IntToStr(TechLevel)), '');
  end
  else
  begin
    TypeName := LocalizedText('Items.Hull.Type.' + IntToStr(TechLevel));
    case HullType of
      htRanger: ShipTypeName := LocalizedText('Items.Hull.ShipType.Ranger');
      htTransport: ShipTypeName := LocalizedText('Items.Hull.ShipType.Transport');
      htLiner: ShipTypeName := LocalizedText('Items.Hull.ShipType.Liner');
      htDiplomat: ShipTypeName := LocalizedText('Items.Hull.ShipType.Diplomat');
      htPirate: ShipTypeName := LocalizedText('Items.Hull.ShipType.Pirate');
      htWarrior: ShipTypeName := LocalizedText('Items.Hull.ShipType.Warrior');
      htKling: ShipTypeName := LocalizedText('Items.Hull.ShipType.Kling');
    else
      ShipTypeName := '';
    end;
    Result :=
        FormatText2(
            LocalizedText('Items.Hull.Name'),
            '',
            '<Type>',
            TypeName,
            '<ShipType>',
            ShipTypeName
        );
  end;
  if HasMicroModule then
    Result :=
        Result
            + ' '
            + WrapTextInColor(
                GetMicroModuleQuotedName,
                GetMicroModuleNameColorTag(MicroModuleIndex - 1));
end;

function THull.GetSeriesName: WideString;
begin
  if (OwnerShip <> nil) and TShip(OwnerShip).UsesVeteranHumanRangerAppearance then
    Result :=
        FormatText1(
            LocalizedText('HullType.SeriesName'),
            '',
            '<Name>',
            LocalizedText('HullType.HullOldfag.Name')
        )
  else if HullSeries = -1 then
    Result := ''
  else
    Result :=
        FormatText1(
            LocalizedText('HullType.SeriesName'),
            '',
            '<Name>',
            HullSeriesDefinitions[HullSeries].Name
        );
end;

function THull.GetShortName: WideString;
begin
  if NameOverride <> '' then
    Result := NameOverride
  else
    Result := LocalizedText('Items.Hull.ShortName');
end;

function THull.GetInfoText(ColorTag: WideString; Ship: Pointer): WideString;
var
  Text, SizeColor: WideString;
begin
  Text := '';
  if SpecialModuleIndex <> 0 then
    Text := MicroModuleTemplates[SpecialModuleIndex - 1].TextReplace;
  if Text = '' then
    Text := LocalizedText('Items.Hull.Text');
  if (OwnerShip <> nil) and TShip(OwnerShip).UsesVeteranHumanRangerAppearance then
    Text := LocalizedText('HullType.HullOldfag.Text') + ' ' + Text
  else if HullSeries <> -1 then
    Text := HullSeriesDefinitions[HullSeries].Text + ' ' + Text;
  if HullPoints <= Weight / 2 then
    SizeColor := GoldColorTag
  else
    SizeColor := ColorTag;
  ReplaceTextToken(Text, '<Size>', IntToStr(HullPoints), SizeColor);
  ReplaceTextToken(Text, '<MaxSize>', IntToStr(Weight), ColorTag);
  ReplaceInfoTokens(Text, ColorTag, Ship);
  Text := Text + GetBonusDescription(ColorTag);
  if ScriptItem <> nil then
    Text := TScriptItem(ScriptItem).FormatDataText(Text, ColorTag);
  Result := Text;
end;

procedure THull.ReplaceInfoTokens(var Text: WideString; ColorTag: WideString; Ship: Pointer);
var
  BonusText: WideString;
  BaseArmor, StatBonus: Integer;
begin
  ReplaceTextToken(
      Text,
      '<FragilityE>',
      IntToStr(Round(GetFragilityFactor([dkEnergy]) * 100)),
      ColorTag
  );
  ReplaceTextToken(
      Text,
      '<FragilityS>',
      IntToStr(Round(GetFragilityFactor([dkSplinter]) * 100)),
      ColorTag
  );
  ReplaceTextToken(
      Text,
      '<FragilityM>',
      IntToStr(Round(GetFragilityFactor([dkMissile]) * 100)),
      ColorTag
  );
  if (MicroModuleIndex = 0)
      or (MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonHull] = 0) then
    BonusText := ''
  else
  begin
    if MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonHull] > 0 then
      BonusText :=
          WrapTextInColor(
              '+' + IntToStr(MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonHull]),
              GreenColorTag
          )
    else
      BonusText :=
          WrapTextInColor(
              IntToStr(MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonHull]),
              RedColorTag
          );
  end;
  StatBonus := GetStatBonus(bonHull);
  if StatBonus <> 0 then
    if StatBonus > 0 then
      BonusText := BonusText + WrapTextInColor('+' + IntToStr(StatBonus), EquipmentBonusColorTag)
    else
      BonusText := BonusText + WrapTextInColor(IntToStr(StatBonus), EquipmentBonusColorTag);
  if OwnerShip <> nil then
    StatBonus := TShip(OwnerShip).GetTotalStatBonus(bonHull) - StatBonus
  else
    StatBonus := 0;
  if StatBonus <> 0 then
    if StatBonus > 0 then
      BonusText :=
          BonusText + WrapTextInColor('(+' + IntToStr(StatBonus) + ')', EquipmentBonusColorTag)
    else
      BonusText :=
          BonusText + WrapTextInColor('(' + IntToStr(StatBonus) + ')', EquipmentBonusColorTag);
  if MicroModuleIndex = 0 then
    BaseArmor := Armor
  else
    BaseArmor := Armor - MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonHull];
  if CalculateGeneratedArmor = BaseArmor then
    ReplaceTextToken(Text, '<HitProtect>', WideString(IntToStr(BaseArmor)) + BonusText, ColorTag)
  else if CalculateGeneratedArmor < BaseArmor then
    ReplaceTextToken(
        Text,
        '<HitProtect>',
        WrapTextInColor(IntToStr(BaseArmor), GreenColorTag) + BonusText,
        ColorTag
    )
  else
    ReplaceTextToken(
        Text,
        '<HitProtect>',
        WrapTextInColor(IntToStr(BaseArmor), RedColorTag) + BonusText,
        ColorTag
    );
end;

function THull.GetBitmapResourceName: WideString;
var
  Ship: TShip;
begin
  if ConfigBlockName <> '' then
    Result := 'Bm.Items.' + GiResourceSuffix + ConfigBlockName
  else if HullType = htRanger then
    Result := 'Bm.Items.' + GiResourceSuffix + 'Hull_' + OwnerInfo[OwnerId].InternalName + '_R_'
  else if HullType = htWarrior then
    Result := 'Bm.Items.' + GiResourceSuffix + 'Hull_' + OwnerInfo[OwnerId].InternalName + '_W_'
  else if HullType = htPirate then
    Result := 'Bm.Items.' + GiResourceSuffix + 'Hull_' + OwnerInfo[OwnerId].InternalName + '_P_'
  else if HullType = htTransport then
    Result := 'Bm.Items.' + GiResourceSuffix + 'Hull_' + OwnerInfo[OwnerId].InternalName + '_T_'
  else if HullType = htLiner then
    Result := 'Bm.Items.' + GiResourceSuffix + 'Hull_' + OwnerInfo[OwnerId].InternalName + '_L_'
  else if HullType = htDiplomat then
    Result := 'Bm.Items.' + GiResourceSuffix + 'Hull_' + OwnerInfo[OwnerId].InternalName + '_D_'
  else if (HullType = htSpecial) and (SpecialModuleIndex <> 0) then
    Result := 'Bm.Items.' + GiResourceSuffix + 'Hull_' + GetSpecialKindGraph + '_'
  else
    RaiseWideMessage('THull.Image');
  Ship := OwnerShip;
  if Ship <> nil then
  begin
    if (HullType = htSpecial)
        and (SpecialModuleIndex <> 0)
        and (GetSpecialKindGraph = 'J')
        and Ship.IsFemaleHumanPilot
        and (Ship.TypeId = stRanger) then
      Result := 'Bm.Items.' + GiResourceSuffix + 'Hull_J_alt_'
    else if (HullType = htRanger)
        and (SpecialModuleIndex = 0)
        and Ship.UsesVeteranHumanRangerAppearance then
      Result := 'Bm.Items.' + GiResourceSuffix + 'Hull_People_ROld_'
    else if (Ship.TypeId = stPirate)
        and (Ship.OwnerId = oiPirate)
        and ((Ship as TPirate).PirateType <> 0) then
      Result := 'Bm.Items.' + GiResourceSuffix + 'Hull_' + OwnerInfo[OwnerId].InternalName + '_PC_';
  end;
end;

function THull.GetSpecialKindGraph: WideString;
begin
  Result := '1';
  if SpecialModuleIndex = 0 then
    Exit;
  if MicroModuleTemplates[SpecialModuleIndex - 1].KindGraph <> '' then
    Result := MicroModuleTemplates[SpecialModuleIndex - 1].KindGraph;
end;

function THull.GetSlotCount(Kind: TShipSlotKind): Integer;
var
  BonusKind: TEquipmentBonusKind;
  I, Maximum, Minimum: Integer;
  Entry: PExtraSpecial;
begin
  Result := GetBaseHullSlotCount(Kind, HullType, OwnerId, OwnerShip);
  BonusKind := HullSlotBonusKinds[Kind];
  Maximum := DefaultHullSlotCounts[Kind];
  Minimum := MinimumHullSlotCounts[Kind];
  if SpecialModuleIndex <> 0 then
    Result :=
        Min(
            Maximum,
            Max(
                Minimum,
                Result + MicroModuleTemplates[SpecialModuleIndex - 1].StatBonuses[BonusKind]
            )
        );
  if ExtraSpecials <> nil then
  begin
    for I := 0 to ExtraSpecials.Count - 1 do
    begin
      Entry := ExtraSpecials[I];
      Inc(
          Result,
          MicroModuleTemplates[Entry.ModuleIndexPlusOne - 1].StatBonuses[BonusKind] * Entry.Count
      );
    end;
    Result := Min(Maximum, Max(Minimum, Result));
  end;
  if HullSeries <> -1 then
    Result :=
        Min(Maximum, Max(Minimum, Result + HullSeriesDefinitions[HullSeries].SlotBonuses[Kind]));
  if MicroModuleIndex <> 0 then
    Result :=
        Min(
            Maximum,
            Max(Minimum, Result + MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[BonusKind])
        );
end;

function GetBaseHullSlotCount(
    Kind: TShipSlotKind;
    HullType: THullType;
    Owner: TOwnerId;
    Ship: Pointer
): Integer;
begin
  Result := 0;
  case HullType of
    htRanger: Result := RangerHullSlots[Owner, Kind];
    htWarrior: Result := WarriorHullSlots[Owner, Kind];
    htPirate: Result := PirateHullSlots[Owner, Kind];
    htTransport: Result := TransportHullSlots[Owner, Kind];
    htLiner: Result := LinerHullSlots[Owner, Kind];
    htDiplomat: Result := DiplomatHullSlots[Owner, Kind];
    htTranclucator: Result := TranclucatorHullSlots[Kind];
    htKling:
      if (Ship = nil) or not (TObject(Ship) is TKling) then
        Result := DominatorHullSlots[ktBoss, Kind]
      else
        Result := DominatorHullSlots[(TObject(Ship) as TKling).KlingType, Kind];
    htStation:
      if Ship = nil then
        Result := StationHullSlots[rstRangerCenter, Kind]
      else if not (TShip(Ship).TypeId in [rstRangerCenter..rstCustomStation]) then
        Result := StationHullSlots[rstRangerCenter, Kind]
      else
        Result := StationHullSlots[TShip(Ship).TypeId, Kind];
    htSpecial: Result := SpecialHullSlots[Kind];
    htFlagship: Result := FlagshipHullSlots[Kind];
  else
    RaiseWideMessage('SlotCount error');
  end;
end;

function THull.CalculateMass: Integer;
begin
  Result := Round(RemapClamped(TechLevel, 1, 8, Weight * 0.6, Weight * 0.8));
end;

function THull.GetFragilityFactor(DamageFlags: TDamageFlagSet): Single;
var
  DamageClass: TWeaponDamageClass;
  Entry: PExtraSpecial;
  I: Integer;
  Factor: Single;
begin
  if DamageFlags = [] then
  begin
    Result := 0;
    for DamageClass := wdcEnergy to wdcMissile do
      Result := GetFragilityFactor([TDamageKind(WeaponDamageClasses[DamageClass].Kind)]) + Result;
    Result := Result / 3;
    Exit;
  end;
  DamageClass := ClassifyWeaponDamageFlags(DamageFlags);
  Result :=
      HullFragilityByType[HullType]
          * HullLevelStats[TechLevel].Fragility[DamageClass]
          * HullFragilityByOwner[DamageClass, OwnerId];
  if PirateBuilt then
    Result := Result * HullFragilityByOwner[DamageClass, oiPirate];
  if MicroModuleIndex <> 0 then
    Result :=
        Result
            * MicroModuleTemplates[MicroModuleIndex - 1].FragilityFactorByDamageClass[DamageClass];
  if SpecialModuleIndex <> 0 then
    Result :=
        Result
            * MicroModuleTemplates[SpecialModuleIndex - 1]
                .FragilityFactorByDamageClass[DamageClass];
  if ExtraSpecials <> nil then
    for I := 0 to ExtraSpecials.Count - 1 do
    begin
      Entry := ExtraSpecials[I];
      Factor :=
          MicroModuleTemplates[Entry.ModuleIndexPlusOne - 1]
              .FragilityFactorByDamageClass[DamageClass];
      if Abs(Factor - 1) > 0.000001 then
      begin
        if Entry.Count = 1 then
          Result := Result * Factor
        else
          Result := Power(Factor, Entry.Count) * Result;
      end;
    end;
  if HullSeries <> -1 then
    Result := Result * HullSeriesDefinitions[HullSeries].FragilityByDamageClass[DamageClass];
end;

function THull.EstimateCapacityWithoutBonuses: Integer;
var
  I: Integer;

  procedure UndoSizePercent(
      Percent: Integer
  ); { Updates the parent's capacity accumulator; caller removes ParentFrame. Nonpositive Percent leaves it unchanged. }
  var
    Factor: Single;
  begin
    if Percent <= 0 then
      Factor := 1
    else
      Factor := 100 / Percent;
    Result := Round(Result * Factor);
  end;

begin
  Result := Weight;
  if ExtraSpecials <> nil then
    for I := 0 to ExtraSpecials.Count - 1 do
      UndoSizePercent(
          MicroModuleTemplates[PExtraSpecial(ExtraSpecials[I]).ModuleIndexPlusOne - 1].SizePercent
      );
  if MicroModuleIndex <> 0 then
    UndoSizePercent(MicroModuleTemplates[MicroModuleIndex - 1].SizePercent);
  if SpecialModuleIndex <> 0 then
    UndoSizePercent(MicroModuleTemplates[SpecialModuleIndex - 1].SizePercent);
  if HullSeries <> -1 then
    UndoSizePercent(HullSeriesDefinitions[HullSeries].SizePercent);
end;

procedure TFuelTanks.Init(Weight: Integer; Level: Byte; Owner: TOwnerId);
begin
  ItemType := t_FuelTanks;
  Self.Weight := Weight;
  TechLevel := Level;
  Capacity := CalculateGeneratedCapacity;
  Fuel := Capacity;
  OwnerId := Owner;
  Repair;
  Cost := CalculateGeneratedCost;
  MicroModuleIndex := 0;
end;

procedure TFuelTanks.SaveToBuffer(Buffer: TBufEC);
begin
  inherited SaveToBuffer(Buffer);
  Buffer.AddAnsiChar(AnsiChar(TechLevel));
  Buffer.AddWideChar(WideChar(Fuel));
  Buffer.AddAnsiChar(AnsiChar(Capacity));
end;

procedure TFuelTanks.LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy);
begin
  inherited LoadFromBuffer(Buffer, Galaxy);
  TechLevel := Buffer.GetByte;
  Fuel := Buffer.GetWord;
  Capacity := Buffer.GetByte;
end;

procedure TFuelTanks.SaveToBlock(Block: TBlockParEC);
begin
  inherited SaveToBlock(Block);
  Block.AddParam(DecodeTextW('Tre4cwh0L6eHv3ealf'), IntToStr(TechLevel)); // 'TechLevel'
  Block.AddParam(DecodeTextW('FiuNeol'), IntToStr(Fuel)); // 'Fuel'
  Block.AddParam(DecodeTextW('CraspiaNcliotay'), IntToStr(Capacity)); // 'Capacity'
end;

procedure TFuelTanks.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  TechLevel := StrToInt(Block.GetParam(DecodeTextW('Tre4cwh0L6eHv3ealf'))); // 'TechLevel'
  Fuel := Word(StrToInt(Block.GetParam(DecodeTextW('FiuNeol')))); // 'Fuel'
  Capacity := StrToInt(Block.GetParam(DecodeTextW('CraspiaNcliotay'))); // 'Capacity'
end;

function TFuelTanks.CalculateGeneratedCapacity: Byte;
begin
  Result := CalculateGeneratedFuelCapacity(Weight, TechLevel);
end;

function CalculateGeneratedFuelCapacity(Weight: Cardinal; Level: Integer): Integer;
begin
  Result := Round(Weight / FuelTanksBaseSize * 20 + FuelCapacityByLevel[Level]);
end;

function CalculateGeneratedFuelTanksCost(
    Weight: Cardinal;
    Level: Integer;
    Owner: TOwnerId
): Integer;
begin
  Result :=
      RoundAndTruncateToTens(
          Weight
              / FuelTanksBaseSize
              * Cardinal(Level * Level)
              * 500
              * OwnerInfo[Owner].FuelPriceFactor
      );
end;

function TFuelTanks.CalculateGeneratedCost: Integer;
begin
  Result := CalculateGeneratedFuelTanksCost(Weight, TechLevel, OwnerId);
end;

procedure TFuelTanks.Improve(Kind: TImprovementKind);
begin
  if Kind = ikAny then
    Kind := TImprovementKind(SeededRandomIntRange(0, 2, Galaxy.CurrentTurn * Id));
  case Kind of
    ikMinor:
      Capacity := Round(Capacity * SeededRandomFloatRange(Id * 254571, 0.05, 0.1)) + Capacity + 1;
    ikMedium:
      Capacity := Round(Capacity * SeededRandomFloatRange(Id * 254571, 0.1, 0.15)) + Capacity + 3;
    ikMajor:
      Capacity := Round(Capacity * SeededRandomFloatRange(Id * 254571, 0.15, 0.2)) + Capacity + 5;
  end;
  Inc(Cost, CalculateImprovementCost(Kind) div 2);
end;

function TFuelTanks.HasStandardStats: Boolean;
var
  BaseCapacity, ExpectedWeight, SizePercent: Integer;
begin
  if (MicroModuleIndex = 0)
      or (MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonFuel] = 0) then
    BaseCapacity := Capacity
  else
    BaseCapacity := Capacity - MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonFuel];
  ExpectedWeight := Round((BaseCapacity - FuelCapacityByLevel[TechLevel]) * FuelTanksBaseSize / 20);
  if MicroModuleIndex <> 0 then
    SizePercent := MicroModuleTemplates[MicroModuleIndex - 1].SizePercent
  else
    SizePercent := 0;
  if SizePercent > 0 then
    ExpectedWeight := Round(ExpectedWeight * SizePercent / 100);
  if SpecialModuleIndex <> 0 then
    SizePercent := MicroModuleTemplates[SpecialModuleIndex - 1].SizePercent
  else
    SizePercent := 0;
  if SizePercent > 0 then
    ExpectedWeight := Round(ExpectedWeight * SizePercent / 100);
  Result := Abs(ExpectedWeight - Weight) <= 1;
end;

function TFuelTanks.GetInfoText(ColorTag: WideString; Ship: Pointer): WideString;
var
  Text: WideString;
begin
  Text := '';
  if SpecialModuleIndex <> 0 then
    Text := MicroModuleTemplates[SpecialModuleIndex - 1].TextReplace;
  if (Text = '') and (CustomFaction <> '') then
    Text := LocalizedText('Items.FuelTanks.' + CustomFaction + 'Text');
  if Text = '' then
    if OwnerId <> oiDominator then
      Text := LocalizedText('Items.FuelTanks.Text')
    else
      Text := LocalizedText('Items.FuelTanks.KlingText');
  ReplaceTextToken(Text, '<Fuel>', IntToStr(Fuel), ColorTag);
  ReplaceInfoTokens(Text, ColorTag, Ship);
  Text := Text + GetBonusDescription(ColorTag);
  if ScriptItem <> nil then
    Text := TScriptItem(ScriptItem).FormatDataText(Text, ColorTag);
  Result := Text + GetConditionText(True);
end;

procedure TFuelTanks.ReplaceInfoTokens(var Text: WideString; ColorTag: WideString; Ship: Pointer);
var
  BonusText: WideString;
  BaseValue, SizePercent, ExpectedWeight: Integer;
begin
  if (MicroModuleIndex = 0)
      or (MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonFuel] = 0) then
    BonusText := ''
  else if MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonFuel] > 0 then
    BonusText :=
        WrapTextInColor(
            '+' + IntToStr(MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonFuel]),
            GreenColorTag
        )
  else
    BonusText :=
        WrapTextInColor(
            IntToStr(MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonFuel]),
            RedColorTag
        );
  if MicroModuleIndex = 0 then
    BaseValue := Capacity
  else
    BaseValue := Capacity - MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonFuel];
  ExpectedWeight := Round((BaseValue - FuelCapacityByLevel[TechLevel]) * FuelTanksBaseSize / 20);
  if MicroModuleIndex <> 0 then
    SizePercent := MicroModuleTemplates[MicroModuleIndex - 1].SizePercent
  else
    SizePercent := 0;
  if SizePercent > 0 then
    ExpectedWeight := Round(ExpectedWeight * SizePercent / 100);
  if SpecialModuleIndex <> 0 then
    SizePercent := MicroModuleTemplates[SpecialModuleIndex - 1].SizePercent
  else
    SizePercent := 0;
  if SizePercent > 0 then
    ExpectedWeight := Round(ExpectedWeight * SizePercent / 100);
  if Abs(ExpectedWeight - Weight) <= 1 then
    ReplaceTextToken(Text, '<Capacity>', WideString(IntToStr(BaseValue)) + BonusText, ColorTag)
  else if ExpectedWeight > Weight then
    ReplaceTextToken(
        Text,
        '<Capacity>',
        WrapTextInColor(IntToStr(BaseValue), GreenColorTag) + BonusText,
        ColorTag
    )
  else
    ReplaceTextToken(
        Text,
        '<Capacity>',
        WrapTextInColor(IntToStr(BaseValue), RedColorTag) + BonusText,
        ColorTag
    );
end;

procedure TEngine.Init(Weight: Integer; Level: Byte; Owner: TOwnerId);
begin
  ItemType := t_Engine;
  MicroModuleIndex := 0;
  Self.Weight := Weight;
  TechLevel := Level;
  Speed := CalculateGeneratedSpeed;
  JumpRange := CalculateGeneratedJumpRange;
  OutputPercent := 100;
  OwnerId := Owner;
  Repair;
  Cost := CalculateGeneratedCost;
end;

procedure TEngine.SaveToBuffer(Buffer: TBufEC);
begin
  inherited SaveToBuffer(Buffer);
  Buffer.AddAnsiChar(AnsiChar(TechLevel));
  Buffer.AddIntegerValue(Speed);
  Buffer.AddAnsiChar(AnsiChar(JumpRange));
  Buffer.AddAnsiChar(AnsiChar(OutputPercent));
end;

procedure TEngine.LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy);
begin
  inherited LoadFromBuffer(Buffer, Galaxy);
  TechLevel := Buffer.GetByte;
  if LoadedSaveVersion >= 161 then
    Speed := Buffer.GetInt32
  else
    Speed := Buffer.GetWord;
  JumpRange := ShortInt(Buffer.GetByte);
  OutputPercent := Buffer.GetByte;
  ItemType := t_Engine;
end;

procedure TEngine.SaveToBlock(Block: TBlockParEC);
begin
  inherited SaveToBlock(Block);
  Block.AddParam(DecodeTextW('Tre4cwh0L6eHv3ealf'), IntToStr(TechLevel)); // 'TechLevel'
  Block.AddParam(DecodeTextW('Sapreneld'), IntToStr(Speed)); // 'Speed'
  Block.AddParam(DecodeTextW('JiuOmipa'), IntToStr(JumpRange)); // 'Jump'
end;

procedure TEngine.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  TechLevel := StrToInt(Block.GetParam(DecodeTextW('Tre4cwh0L6eHv3ealf'))); // 'TechLevel'
  Speed := Word(StrToInt(Block.GetParam(DecodeTextW('Sapreneld')))); // 'Speed'
  JumpRange := StrToInt(Block.GetParam(DecodeTextW('JiuOmipa'))); // 'Jump'
end;

function TEngine.CalculateGeneratedSpeed: Integer;
begin
  Result := EngineLevelStats[TechLevel].Speed;
end;

function TEngine.CalculateGeneratedJumpRange: ShortInt;
begin
  Result := EngineLevelStats[TechLevel].JumpRange;
end;

function CalculateGeneratedEngineCost(Weight: Cardinal; Level: Byte; Owner: TOwnerId): Integer;
begin
  Result :=
      RoundAndTruncateToTens(
          RemapClamped(EngineBaseSize / Weight, 0.5, 2, 1, 2)
              * (Level * Level)
              * 500
              * OwnerInfo[Owner].FuelPriceFactor
      );
end;

function TEngine.CalculateGeneratedCost: Integer;
begin
  Result := CalculateGeneratedEngineCost(Weight, TechLevel, OwnerId);
end;

procedure TEngine.Improve(Kind: TImprovementKind);
begin
  if Kind = ikAny then
    Kind := TImprovementKind(SeededRandomIntRange(0, 2, Galaxy.CurrentTurn * Id));
  if DetailImprovement = 0 then
    if SeededRandomUnitFloat(Galaxy.CurrentTurn * (Ord(Kind) + 1) * Id) < 0.5 then
      DetailImprovement := 1
    else
      DetailImprovement := 2;
  if DetailImprovement = 1 then
    case Kind of
      ikMinor:
      begin
        Inc(
            Speed,
            RoundAndTruncateToTens(
                Speed * SeededRandomFloatRange(Id * 374571, 0.01, 0.05)
                    + SeededRandomIntRange(10, 30, Id * 254571)
            )
        );
        Inc(JumpRange, SeededRandomIntRange(1, 2, Id * 354571));
      end;
      ikMedium:
      begin
        Inc(
            Speed,
            RoundAndTruncateToTens(
                Speed * SeededRandomFloatRange(Id * 374571, 0.02, 0.06)
                    + SeededRandomIntRange(30, 60, Id * 254571)
            )
        );
        Inc(JumpRange, SeededRandomIntRange(2, 4, Id * 354571));
      end;
      ikMajor:
      begin
        Inc(
            Speed,
            RoundAndTruncateToTens(
                Speed * SeededRandomFloatRange(Id * 374571, 0.03, 0.07)
                    + SeededRandomIntRange(50, 80, Id * 254571)
            )
        );
        Inc(JumpRange, SeededRandomIntRange(3, 7, Id * 354571));
      end;
    end
  else if DetailImprovement = 2 then
    case Kind of
      ikMinor:
      begin
        Inc(JumpRange, SeededRandomIntRange(2, 5, Id * 354571));
        Inc(
            Speed,
            RoundAndTruncateToTens(
                Speed * SeededRandomFloatRange(Id * 374571, 0.01, 0.03)
                    + SeededRandomIntRange(10, 20, Id * 254571)
            )
        );
      end;
      ikMedium:
      begin
        Inc(JumpRange, SeededRandomIntRange(5, 7, Id * 354571));
        Inc(
            Speed,
            RoundAndTruncateToTens(
                Speed * SeededRandomFloatRange(Id * 374571, 0.01, 0.04)
                    + SeededRandomIntRange(20, 40, Id * 254571)
            )
        );
      end;
      ikMajor:
      begin
        Inc(JumpRange, SeededRandomIntRange(7, 12, Id * 354571));
        Inc(
            Speed,
            RoundAndTruncateToTens(
                Speed * SeededRandomFloatRange(Id * 374571, 0.01, 0.05)
                    + SeededRandomIntRange(30, 50, Id * 254571)
            )
        );
      end;
    end;
  Inc(Cost, CalculateImprovementCost(Kind) div 2);
  DetailImprovement := 0;
end;

function TEngine.HasStandardStats: Boolean;
var
  StandardSpeed, StandardJump: Boolean;
begin
  if (MicroModuleIndex = 0)
      or (MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonSpeed] = 0) then
    StandardSpeed := CalculateGeneratedSpeed = Speed
  else
    StandardSpeed :=
        CalculateGeneratedSpeed
            = Speed - MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonSpeed];
  if (MicroModuleIndex = 0)
      or (MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonJump] = 0) then
    StandardJump := CalculateGeneratedJumpRange = JumpRange
  else
    StandardJump :=
        CalculateGeneratedJumpRange
            = JumpRange - MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonJump];
  Result := StandardSpeed and StandardJump;
end;

function TEngine.GetInfoText(ColorTag: WideString; Ship: Pointer): WideString;
var
  Text: WideString;
begin
  Text := '';
  if SpecialModuleIndex <> 0 then
    Text := MicroModuleTemplates[SpecialModuleIndex - 1].TextReplace;
  if (Text = '') and (CustomFaction <> '') then
    Text := LocalizedText('Items.Engine.' + CustomFaction + 'Text');
  if Text = '' then
    if OwnerId <> oiDominator then
      Text := LocalizedText('Items.Engine.Text')
    else
      Text := LocalizedText('Items.Engine.KlingText');
  ReplaceInfoTokens(Text, ColorTag, Ship);
  Text := Text + GetBonusDescription(ColorTag);
  if ScriptItem <> nil then
    Text := TScriptItem(ScriptItem).FormatDataText(Text, ColorTag);
  Result := Text + GetConditionText(True);
end;

procedure TEngine.ReplaceInfoTokens(var Text: WideString; ColorTag: WideString; Ship: Pointer);
var
  BonusText: WideString;
  BaseValue, StatBonus: Integer;
begin
  if MicroModuleIndex = 0 then
    StatBonus := 0
  else
    StatBonus := MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonSpeed];
  BaseValue := Max(0, Speed - StatBonus);
  StatBonus := Max(0, Speed) - BaseValue;
  if StatBonus = 0 then
    BonusText := ''
  else if StatBonus > 0 then
    BonusText := WrapTextInColor('+' + IntToStr(StatBonus), GreenColorTag)
  else
    BonusText := WrapTextInColor(IntToStr(StatBonus), RedColorTag);
  StatBonus := Max(-Max(0, Speed), GetStatBonus(bonSpeed));
  if StatBonus <> 0 then
    if StatBonus > 0 then
      BonusText := BonusText + WrapTextInColor('+' + IntToStr(StatBonus), EquipmentBonusColorTag)
    else
      BonusText := BonusText + WrapTextInColor(IntToStr(StatBonus), EquipmentBonusColorTag);
  if (Ship <> nil) and (EquippedFlag <> 0) then
    StatBonus := Max(TShip(Ship).GetTotalStatBonus(bonSpeed) - StatBonus, -(Speed + StatBonus))
  else
    StatBonus := 0;
  if StatBonus <> 0 then
    if StatBonus > 0 then
      BonusText :=
          BonusText + WrapTextInColor('(+' + IntToStr(StatBonus) + ')', EquipmentBonusColorTag)
    else
      BonusText :=
          BonusText + WrapTextInColor('(' + IntToStr(StatBonus) + ')', EquipmentBonusColorTag);
  if CalculateGeneratedSpeed = BaseValue then
    ReplaceTextToken(Text, '<Speed>', WideString(IntToStr(BaseValue)) + BonusText, ColorTag)
  else if CalculateGeneratedSpeed < BaseValue then
    ReplaceTextToken(
        Text,
        '<Speed>',
        WrapTextInColor(IntToStr(BaseValue), GreenColorTag) + BonusText,
        ColorTag
    )
  else
    ReplaceTextToken(
        Text,
        '<Speed>',
        WrapTextInColor(IntToStr(BaseValue), RedColorTag) + BonusText,
        ColorTag
    );
  if MicroModuleIndex = 0 then
    StatBonus := 0
  else
    StatBonus := MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonJump];
  BaseValue := Max(0, JumpRange - StatBonus);
  StatBonus := Max(0, JumpRange) - BaseValue;
  if StatBonus = 0 then
    BonusText := ''
  else if StatBonus > 0 then
    BonusText := WrapTextInColor('+' + IntToStr(StatBonus), GreenColorTag)
  else
    BonusText := WrapTextInColor(IntToStr(StatBonus), RedColorTag);
  StatBonus := Max(-Max(0, JumpRange), GetStatBonus(bonJump));
  if StatBonus <> 0 then
    if StatBonus > 0 then
      BonusText := BonusText + WrapTextInColor('+' + IntToStr(StatBonus), EquipmentBonusColorTag)
    else
      BonusText := BonusText + WrapTextInColor(IntToStr(StatBonus), EquipmentBonusColorTag);
  if (Ship <> nil) and (EquippedFlag <> 0) then
    StatBonus := Max(TShip(Ship).GetTotalStatBonus(bonJump) - StatBonus, -(JumpRange + StatBonus))
  else
    StatBonus := 0;
  if StatBonus <> 0 then
    if StatBonus > 0 then
      BonusText :=
          BonusText + WrapTextInColor('(+' + IntToStr(StatBonus) + ')', EquipmentBonusColorTag)
    else
      BonusText :=
          BonusText + WrapTextInColor('(' + IntToStr(StatBonus) + ')', EquipmentBonusColorTag);
  if CalculateGeneratedJumpRange = BaseValue then
    ReplaceTextToken(Text, '<Parsec>', WideString(IntToStr(BaseValue)) + BonusText, ColorTag)
  else if CalculateGeneratedJumpRange < BaseValue then
    ReplaceTextToken(
        Text,
        '<Parsec>',
        WrapTextInColor(IntToStr(BaseValue), GreenColorTag) + BonusText,
        ColorTag
    )
  else
    ReplaceTextToken(
        Text,
        '<Parsec>',
        WrapTextInColor(IntToStr(BaseValue), RedColorTag) + BonusText,
        ColorTag
    );
end;

procedure TRadar.Init(Weight: Integer; Level: Byte; Owner: TOwnerId);
begin
  ItemType := t_Radar;
  Self.Weight := Weight;
  TechLevel := Level;
  Range := CalculateGeneratedRange;
  OwnerId := Owner;
  Repair;
  Cost := CalculateGeneratedCost;
  MicroModuleIndex := 0;
end;

procedure TRadar.SaveToBuffer(Buffer: TBufEC);
begin
  inherited SaveToBuffer(Buffer);
  Buffer.AddAnsiChar(AnsiChar(TechLevel));
  Buffer.AddWideChar(WideChar(Range));
end;

procedure TRadar.LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy);
begin
  inherited LoadFromBuffer(Buffer, Galaxy);
  TechLevel := Buffer.GetByte;
  Range := Buffer.GetWord;
end;

procedure TRadar.SaveToBlock(Block: TBlockParEC);
begin
  inherited SaveToBlock(Block);
  Block.AddParam(DecodeTextW('Tre4cwh0L6eHv3ealf'), IntToStr(TechLevel)); // 'TechLevel'
  Block.AddParam(DecodeTextW('Rialdoinurs'), IntToStr(Range)); // 'Radius'
end;

procedure TRadar.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  TechLevel := StrToInt(Block.GetParam(DecodeTextW('Tre4cwh0L6eHv3ealf'))); // 'TechLevel'
  Range := Word(StrToInt(Block.GetParam(DecodeTextW('Rialdoinurs')))); // 'Radius'
end;

function TRadar.CalculateGeneratedRange: Integer;
begin
  Result := RadarLevelRanges[TechLevel];
end;

function CalculateGeneratedRadarCost(Weight: Cardinal; Level: Byte; Owner: TOwnerId): Integer;
begin
  Result :=
      RoundAndTruncateToTens(
          RemapClamped(RadarBaseSize / Weight, 0.5, 2, 1, 2)
              * (Level * Level)
              * 500
              * OwnerInfo[Owner].FuelPriceFactor
      );
end;

function TRadar.CalculateGeneratedCost: Integer;
begin
  Result := CalculateGeneratedRadarCost(Weight, TechLevel, OwnerId);
end;

procedure TRadar.Improve(Kind: TImprovementKind);
begin
  if Kind = ikAny then
    Kind := TImprovementKind(SeededRandomIntRange(0, 2, Galaxy.CurrentTurn * Id));
  case Kind of
    ikMinor:
      Inc(
          Range,
          RoundAndTruncateToTens(
              Range * SeededRandomFloatRange(Id * 354571, 0.05, 0.1)
                  + SeededRandomIntRange(100, 200, Id * 254571)
          )
      );
    ikMedium:
      Inc(
          Range,
          RoundAndTruncateToTens(
              Range * SeededRandomFloatRange(Id * 354571, 0.05, 0.1)
                  + SeededRandomIntRange(300, 400, Id * 254571)
          )
      );
    ikMajor:
      Inc(
          Range,
          RoundAndTruncateToTens(
              Range * SeededRandomFloatRange(Id * 354571, 0.05, 0.1)
                  + SeededRandomIntRange(400, 500, Id * 254571)
          )
      );
  end;
  Inc(Cost, CalculateImprovementCost(Kind) div 2);
end;

function TRadar.HasStandardStats: Boolean;
begin
  if (MicroModuleIndex = 0)
      or (MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonRadar] = 0) then
    Result := CalculateGeneratedRange = Range
  else
    Result :=
        CalculateGeneratedRange
            = Range - MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonRadar];
end;

function TRadar.GetInfoText(ColorTag: WideString; Ship: Pointer): WideString;
var
  Text: WideString;
begin
  Text := '';
  if SpecialModuleIndex <> 0 then
    Text := MicroModuleTemplates[SpecialModuleIndex - 1].TextReplace;
  if (Text = '') and (CustomFaction <> '') then
    Text := LocalizedText('Items.Radar.' + CustomFaction + 'Text');
  if Text = '' then
    if OwnerId <> oiDominator then
      Text := LocalizedText('Items.Radar.Text')
    else
      Text := LocalizedText('Items.Radar.KlingText');
  ReplaceInfoTokens(Text, ColorTag, Ship);
  Text := Text + GetBonusDescription(ColorTag);
  if ScriptItem <> nil then
    Text := TScriptItem(ScriptItem).FormatDataText(Text, ColorTag);
  Result := Text + GetConditionText(True);
end;

procedure TRadar.ReplaceInfoTokens(var Text: WideString; ColorTag: WideString; Ship: Pointer);
var
  BonusText: WideString;
  BaseValue, StatBonus: Integer;
begin
  if (MicroModuleIndex = 0)
      or (MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonRadar] = 0) then
    BonusText := ''
  else if MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonRadar] > 0 then
    BonusText :=
        WrapTextInColor(
            '+' + IntToStr(MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonRadar]),
            GreenColorTag
        )
  else
    BonusText :=
        WrapTextInColor(
            IntToStr(MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonRadar]),
            RedColorTag
        );
  StatBonus := Max(-Max(0, Range), GetStatBonus(bonRadar));
  if StatBonus <> 0 then
    if StatBonus > 0 then
      BonusText := BonusText + WrapTextInColor('+' + IntToStr(StatBonus), EquipmentBonusColorTag)
    else
      BonusText := BonusText + WrapTextInColor(IntToStr(StatBonus), EquipmentBonusColorTag);
  if (Ship <> nil) and (EquippedFlag <> 0) then
    StatBonus := Max(TShip(Ship).GetTotalStatBonus(bonRadar) - StatBonus, -(Range + StatBonus))
  else
    StatBonus := 0;
  if StatBonus <> 0 then
    if StatBonus > 0 then
      BonusText :=
          BonusText + WrapTextInColor('(+' + IntToStr(StatBonus) + ')', EquipmentBonusColorTag)
    else
      BonusText :=
          BonusText + WrapTextInColor('(' + IntToStr(StatBonus) + ')', EquipmentBonusColorTag);
  if MicroModuleIndex = 0 then
    BaseValue := Range
  else
    BaseValue := Range - MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonRadar];
  if HasStandardStats then
    ReplaceTextToken(Text, '<Radius>', WideString(IntToStr(BaseValue)) + BonusText, ColorTag)
  else if CalculateGeneratedRange < BaseValue then
    ReplaceTextToken(
        Text,
        '<Radius>',
        WrapTextInColor(IntToStr(BaseValue), GreenColorTag) + BonusText,
        ColorTag
    )
  else
    ReplaceTextToken(
        Text,
        '<Radius>',
        WrapTextInColor(IntToStr(BaseValue), RedColorTag) + BonusText,
        ColorTag
    );
end;

procedure TScaner.Init(Weight: Integer; Level: Byte; Owner: TOwnerId);
begin
  ItemType := t_Scaner;
  Self.Weight := Weight;
  TechLevel := Level;
  ScanPower := CalculateGeneratedScanPower;
  OwnerId := Owner;
  Repair;
  Cost := CalculateGeneratedCost;
  MicroModuleIndex := 0;
end;

procedure TScaner.SaveToBuffer(Buffer: TBufEC);
begin
  inherited SaveToBuffer(Buffer);
  Buffer.AddAnsiChar(AnsiChar(TechLevel));
  Buffer.AddAnsiChar(AnsiChar(ScanPower));
end;

procedure TScaner.LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy);
begin
  inherited LoadFromBuffer(Buffer, Galaxy);
  TechLevel := Buffer.GetByte;
  ScanPower := ShortInt(Buffer.GetByte);
  if (LoadedSaveVersion < 118)
      and (MicroModuleIndex <> 0)
      and (MicroModuleTemplates[MicroModuleIndex - 1].ConfigNumber = 122) then
    Inc(ScanPower);
end;

procedure TScaner.SaveToBlock(Block: TBlockParEC);
begin
  inherited SaveToBlock(Block);
  Block.AddParam(DecodeTextW('Tre4cwh0L6eHv3ealf'), IntToStr(TechLevel)); // 'TechLevel'
  Block.AddParam(DecodeTextW('Prouwseor'), IntToStr(ScanPower)); // 'Power'
end;

procedure TScaner.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  TechLevel := StrToInt(Block.GetParam(DecodeTextW('Tre4cwh0L6eHv3ealf'))); // 'TechLevel'
  ScanPower := StrToInt(Block.GetParam(DecodeTextW('Prouwseor'))); // 'Power'
end;

function TScaner.CalculateGeneratedScanPower: Integer;
begin
  Result := DefenseDamageFactorToPercent(GetGeneratedDefenseDamageFactor(TechLevel)) + 1;
end;

function CalculateGeneratedScanerCost(Weight: Cardinal; Level: Byte; Owner: TOwnerId): Integer;
begin
  Result :=
      RoundAndTruncateToTens(
          RemapClamped(ScannerBaseSize / Weight, 0.5, 2, 1, 2)
              * (Level * Level)
              * 500
              * OwnerInfo[Owner].FuelPriceFactor
      );
end;

function TScaner.CalculateGeneratedCost: Integer;
begin
  Result := CalculateGeneratedScanerCost(Weight, TechLevel, OwnerId);
end;

procedure TScaner.Improve(Kind: TImprovementKind);
begin
  if Kind = ikAny then
    Kind := TImprovementKind(SeededRandomIntRange(0, 2, Galaxy.CurrentTurn * Id));
  case Kind of
    ikMinor:
      ScanPower :=
          ScanPower
              + Round(ScanPower * SeededRandomFloatRange(Id * 254571, 0.05, 0.1))
              + SeededRandomIntRange(1, 3, Id * 354571);
    ikMedium:
      ScanPower :=
          ScanPower
              + Round(ScanPower * SeededRandomFloatRange(Id * 254571, 0.05, 0.1))
              + SeededRandomIntRange(3, 5, Id * 354571);
    ikMajor:
      ScanPower :=
          ScanPower
              + Round(ScanPower * SeededRandomFloatRange(Id * 254571, 0.05, 0.1))
              + SeededRandomIntRange(5, 7, Id * 354571);
  end;
  Inc(Cost, CalculateImprovementCost(Kind) div 2);
end;

function TScaner.HasStandardStats: Boolean;
begin
  if (MicroModuleIndex = 0)
      or (MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonScan] = 0) then
    Result := CalculateGeneratedScanPower = ScanPower
  else
    Result :=
        CalculateGeneratedScanPower
            = ScanPower - MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonScan];
end;

function TScaner.GetInfoText(ColorTag: WideString; Ship: Pointer): WideString;
var
  Text: WideString;
begin
  Text := '';
  if SpecialModuleIndex <> 0 then
    Text := MicroModuleTemplates[SpecialModuleIndex - 1].TextReplace;
  if (Text = '') and (CustomFaction <> '') then
    Text := LocalizedText('Items.Scaner.' + CustomFaction + 'Text');
  if Text = '' then
    if OwnerId <> oiDominator then
      Text := LocalizedText('Items.Scaner.Text')
    else
      Text := LocalizedText('Items.Scaner.KlingText');
  ReplaceInfoTokens(Text, ColorTag, Ship);
  Text := Text + GetBonusDescription(ColorTag);
  if ScriptItem <> nil then
    Text := TScriptItem(ScriptItem).FormatDataText(Text, ColorTag);
  Result := Text + GetConditionText(True);
end;

procedure TScaner.ReplaceInfoTokens(var Text: WideString; ColorTag: WideString; Ship: Pointer);
var
  BonusText: WideString;
  BaseValue, StatBonus: Integer;
begin
  if MicroModuleIndex = 0 then
    StatBonus := 0
  else
    StatBonus := MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonScan];
  BaseValue := Max(0, ScanPower - StatBonus);
  StatBonus := Max(0, ScanPower) - BaseValue;
  if StatBonus = 0 then
    BonusText := ''
  else if StatBonus > 0 then
    BonusText := WrapTextInColor('+' + IntToStr(StatBonus), GreenColorTag)
  else
    BonusText := WrapTextInColor(IntToStr(StatBonus), RedColorTag);
  StatBonus := Max(-Max(0, ScanPower), GetStatBonus(bonScan));
  if StatBonus <> 0 then
    if StatBonus > 0 then
      BonusText := BonusText + WrapTextInColor('+' + IntToStr(StatBonus), EquipmentBonusColorTag)
    else
      BonusText := BonusText + WrapTextInColor(IntToStr(StatBonus), EquipmentBonusColorTag);
  if (Ship <> nil) and (EquippedFlag <> 0) then
    StatBonus := Max(TShip(Ship).GetTotalStatBonus(bonScan) - StatBonus, -(ScanPower + StatBonus))
  else
    StatBonus := 0;
  if StatBonus <> 0 then
    if StatBonus > 0 then
      BonusText :=
          BonusText + WrapTextInColor('(+' + IntToStr(StatBonus) + ')', EquipmentBonusColorTag)
    else
      BonusText :=
          BonusText + WrapTextInColor('(' + IntToStr(StatBonus) + ')', EquipmentBonusColorTag);
  if CalculateGeneratedScanPower = BaseValue then
    ReplaceTextToken(Text, '<Percent>', WideString(IntToStr(BaseValue)) + BonusText, ColorTag)
  else if CalculateGeneratedScanPower < BaseValue then
    ReplaceTextToken(
        Text,
        '<Percent>',
        WrapTextInColor(IntToStr(BaseValue), GreenColorTag) + BonusText,
        ColorTag
    )
  else
    ReplaceTextToken(
        Text,
        '<Percent>',
        WrapTextInColor(IntToStr(BaseValue), RedColorTag) + BonusText,
        ColorTag
    );
end;

procedure TRepairRobot.Init(Weight: Integer; Level: Byte; Owner: TOwnerId);
begin
  ItemType := t_RepairRobot;
  Self.Weight := Weight;
  TechLevel := Level;
  RepairPoints := CalculateGeneratedRepairPoints;
  OwnerId := Owner;
  Repair;
  Cost := CalculateGeneratedCost;
  MicroModuleIndex := 0;
end;

procedure TRepairRobot.SaveToBuffer(Buffer: TBufEC);
begin
  inherited SaveToBuffer(Buffer);
  Buffer.AddAnsiChar(AnsiChar(TechLevel));
  Buffer.AddAnsiChar(AnsiChar(RepairPoints));
end;

procedure TRepairRobot.LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy);
begin
  inherited LoadFromBuffer(Buffer, Galaxy);
  TechLevel := Buffer.GetByte;
  RepairPoints := Buffer.GetByte;
  if LoadedSaveVersion < 118 then
  begin
    if TechLevel < 5 then
      Inc(RepairPoints, 5);
    if (MicroModuleIndex <> 0)
        and (MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonDroid] <> 0) then
      case MicroModuleTemplates[MicroModuleIndex - 1].ConfigNumber of
        122: Inc(RepairPoints, 7);
        21: Inc(RepairPoints, 4);
        7: Inc(RepairPoints, 3);
        204: Dec(RepairPoints, 5);
        14: Dec(RepairPoints, 5);
        110: Dec(RepairPoints, 5);
        16: Dec(RepairPoints, 3);
      end;
  end;
end;

procedure TRepairRobot.SaveToBlock(Block: TBlockParEC);
begin
  inherited SaveToBlock(Block);
  Block.AddParam(DecodeTextW('Tre4cwh0L6eHv3ealf'), IntToStr(TechLevel)); // 'TechLevel'
  Block.AddParam(DecodeTextW('Raenplavikr'), IntToStr(RepairPoints)); // 'Repair'
end;

procedure TRepairRobot.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  TechLevel := StrToInt(Block.GetParam(DecodeTextW('Tre4cwh0L6eHv3ealf'))); // 'TechLevel'
  RepairPoints := StrToInt(Block.GetParam(DecodeTextW('Raenplavikr'))); // 'Repair'
end;

function TRepairRobot.CalculateGeneratedRepairPoints: Byte;
begin
  Result := RepairRobotLevelPoints[TechLevel];
end;

function CalculateGeneratedRepairRobotCost(Weight: Cardinal; Level: Byte; Owner: TOwnerId): Integer;
begin
  Result :=
      RoundAndTruncateToTens(
          RemapClamped(RepairRobotBaseSize / Weight, 0.5, 2, 1, 2)
              * (Level * Level)
              * 500
              * OwnerInfo[Owner].FuelPriceFactor
      );
end;

function TRepairRobot.CalculateGeneratedCost: Integer;
begin
  Result := CalculateGeneratedRepairRobotCost(Weight, TechLevel, OwnerId);
end;

procedure TRepairRobot.Improve(Kind: TImprovementKind);
begin
  if Kind = ikAny then
    Kind := TImprovementKind(SeededRandomIntRange(0, 2, Galaxy.CurrentTurn * Id));
  case Kind of
    ikMinor:
      RepairPoints :=
          RepairPoints
              + Round(RepairPoints * SeededRandomFloatRange(Id * 254571, 0.07, 0.12))
              + SeededRandomIntRange(1, 4, Id * 354571);
    ikMedium:
      RepairPoints :=
          RepairPoints
              + Round(RepairPoints * SeededRandomFloatRange(Id * 254571, 0.07, 0.12))
              + SeededRandomIntRange(4, 7, Id * 354571);
    ikMajor:
      RepairPoints :=
          RepairPoints
              + Round(RepairPoints * SeededRandomFloatRange(Id * 254571, 0.07, 0.12))
              + SeededRandomIntRange(7, 10, Id * 354571);
  end;
  Inc(Cost, CalculateImprovementCost(Kind) div 2);
end;

function TRepairRobot.HasStandardStats: Boolean;
begin
  if (MicroModuleIndex = 0)
      or (MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonDroid] = 0) then
    Result := CalculateGeneratedRepairPoints = RepairPoints
  else
    Result :=
        CalculateGeneratedRepairPoints
            = RepairPoints - MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonDroid];
end;

function TRepairRobot.GetInfoText(ColorTag: WideString; Ship: Pointer): WideString;
var
  Text: WideString;
begin
  Text := '';
  if SpecialModuleIndex <> 0 then
    Text := MicroModuleTemplates[SpecialModuleIndex - 1].TextReplace;
  if (Text = '') and (CustomFaction <> '') then
    Text := LocalizedText('Items.RepairRobot.' + CustomFaction + 'Text');
  if Text = '' then
    if OwnerId <> oiDominator then
      Text := LocalizedText('Items.RepairRobot.Text')
    else
      Text := LocalizedText('Items.RepairRobot.KlingText');
  ReplaceInfoTokens(Text, ColorTag, Ship);
  Text := Text + GetBonusDescription(ColorTag);
  if ScriptItem <> nil then
    Text := TScriptItem(ScriptItem).FormatDataText(Text, ColorTag);
  Result := Text + GetConditionText(True);
end;

procedure TRepairRobot.ReplaceInfoTokens(var Text: WideString; ColorTag: WideString; Ship: Pointer);
var
  BonusText: WideString;
  BaseValue, StatBonus: Integer;
begin
  if (MicroModuleIndex = 0)
      or (MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonDroid] = 0) then
    BonusText := ''
  else if MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonDroid] > 0 then
    BonusText :=
        WrapTextInColor(
            '+' + IntToStr(MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonDroid]),
            GreenColorTag
        )
  else
    BonusText :=
        WrapTextInColor(
            IntToStr(MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonDroid]),
            RedColorTag
        );
  StatBonus := Max(-Max(0, RepairPoints), GetStatBonus(bonDroid));
  if StatBonus <> 0 then
    if StatBonus > 0 then
      BonusText := BonusText + WrapTextInColor('+' + IntToStr(StatBonus), EquipmentBonusColorTag)
    else
      BonusText := BonusText + WrapTextInColor(IntToStr(StatBonus), EquipmentBonusColorTag);
  if (Ship <> nil) and (EquippedFlag <> 0) then
    StatBonus :=
        Max(TShip(Ship).GetTotalStatBonus(bonDroid) - StatBonus, -(RepairPoints + StatBonus))
  else
    StatBonus := 0;
  if StatBonus <> 0 then
    if StatBonus > 0 then
      BonusText :=
          BonusText + WrapTextInColor('(+' + IntToStr(StatBonus) + ')', EquipmentBonusColorTag)
    else
      BonusText :=
          BonusText + WrapTextInColor('(' + IntToStr(StatBonus) + ')', EquipmentBonusColorTag);
  if MicroModuleIndex = 0 then
    BaseValue := RepairPoints
  else
    BaseValue := RepairPoints - MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonDroid];
  if HasStandardStats then
    ReplaceTextToken(
        Text,
        '<RecoverHitPoints>',
        WideString(IntToStr(BaseValue)) + BonusText,
        ColorTag
    )
  else if CalculateGeneratedRepairPoints < BaseValue then
    ReplaceTextToken(
        Text,
        '<RecoverHitPoints>',
        WrapTextInColor(IntToStr(BaseValue), GreenColorTag) + BonusText,
        ColorTag
    )
  else
    ReplaceTextToken(
        Text,
        '<RecoverHitPoints>',
        WrapTextInColor(IntToStr(BaseValue), RedColorTag) + BonusText,
        ColorTag
    );
end;

constructor TCargoHook.Create;
begin
  inherited Create;
end;

procedure TCargoHook.Init(Weight: Integer; Level: Byte; Owner: TOwnerId);
begin
  ItemType := t_CargoHook;
  Self.Weight := Weight;
  TechLevel := Level;
  PickupPower := CalculateGeneratedPickupPower;
  Range := CalculateGeneratedRange;
  MinPullSpeed := CalculateGeneratedMinPullSpeed;
  MaxPullSpeed := CalculateGeneratedMaxPullSpeed;
  OwnerId := Owner;
  Repair;
  Cost := CalculateGeneratedCost;
  MicroModuleIndex := 0;
end;

procedure TCargoHook.SaveToBuffer(Buffer: TBufEC);
begin
  inherited SaveToBuffer(Buffer);
  Buffer.AddAnsiChar(AnsiChar(TechLevel));
  Buffer.AddWideChar(WideChar(PickupPower));
  Buffer.AddWideChar(WideChar(Range));
  Buffer.AddSingle(MinPullSpeed);
  Buffer.AddSingle(MaxPullSpeed);
end;

procedure TCargoHook.LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy);
begin
  inherited LoadFromBuffer(Buffer, Galaxy);
  TechLevel := Buffer.GetByte;
  PickupPower := Buffer.GetWord;
  Range := Buffer.GetWord;
  MinPullSpeed := Buffer.GetSingle;
  MaxPullSpeed := Buffer.GetSingle;
end;

procedure TCargoHook.SaveToBlock(Block: TBlockParEC);
begin
  inherited SaveToBlock(Block);
  Block.AddParam(DecodeTextW('Tre4cwh0L6eHv3ealf'), IntToStr(TechLevel)); // 'TechLevel'
  Block.AddParam(DecodeTextW('Prouwseor'), IntToStr(PickupPower)); // 'Power'
  Block.AddParam(DecodeTextW('Rialdoinurs'), IntToStr(Range)); // 'Radius'
  Block.AddParam(DecodeTextW('SapperenduMaidno'), FloatToStr(MinPullSpeed)); // 'SpeedMin'
  Block.AddParam(DecodeTextW('Suplexe2d3Moarxi'), FloatToStr(MaxPullSpeed)); // 'SpeedMax'
end;

procedure TCargoHook.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  TechLevel := StrToInt(Block.GetParam(DecodeTextW('Tre4cwh0L6eHv3ealf'))); // 'TechLevel'
  PickupPower := Word(StrToInt(Block.GetParam(DecodeTextW('Prouwseor')))); // 'Power'
  Range := Word(StrToInt(Block.GetParam(DecodeTextW('Rialdoinurs')))); // 'Radius'
  MinPullSpeed :=
      ExtractDecimalToSingleW(Block.GetParam(DecodeTextW('SapperenduMaidno'))); // 'SpeedMin'
  MaxPullSpeed :=
      ExtractDecimalToSingleW(Block.GetParam(DecodeTextW('Suplexe2d3Moarxi'))); // 'SpeedMax'
end;

function TCargoHook.CalculateGeneratedPickupPower: Integer;
begin
  Result := CargoHookLevelStats[TechLevel].PickupPower;
end;

function TCargoHook.CalculateGeneratedRange: Integer;
begin
  Result := CargoHookLevelStats[TechLevel].Range;
end;

function TCargoHook.CalculateGeneratedMinPullSpeed: Single;
begin
  Result := CargoHookLevelStats[TechLevel].MinPullSpeed;
end;

function TCargoHook.CalculateGeneratedMaxPullSpeed: Single;
begin
  Result := CargoHookLevelStats[TechLevel].MaxPullSpeed;
end;

function CalculateGeneratedCargoHookCost(Weight: Cardinal; Level: Byte; Owner: TOwnerId): Integer;
begin
  Result :=
      RoundAndTruncateToTens(
          RemapClamped(CargoHookBaseSize / Weight, 0.5, 2, 1, 2)
              * (Level * Level)
              * 500
              * OwnerInfo[Owner].FuelPriceFactor
      );
end;

function TCargoHook.CalculateGeneratedCost: Integer;
begin
  Result := CalculateGeneratedCargoHookCost(Weight, TechLevel, OwnerId);
end;

procedure TCargoHook.Improve(Kind: TImprovementKind);
begin
  if Kind = ikAny then
    Kind := TImprovementKind(SeededRandomIntRange(0, 2, Galaxy.CurrentTurn * Id));
  if DetailImprovement = 0 then
    if SeededRandomUnitFloat(Galaxy.CurrentTurn * (Ord(Kind) + 1) * Id) < 0.5 then
      DetailImprovement := 1
    else
      DetailImprovement := 2;
  if DetailImprovement = 1 then
    case Kind of
      ikMinor:
      begin
        PickupPower :=
            PickupPower
                + Round(PickupPower * SeededRandomFloatRange(Id * 374571, 0.07, 0.12))
                + SeededRandomIntRange(5, 10, Id * 254571);
        Inc(Range, SeededRandomIntRange(2, 4, Id * 354571));
      end;
      ikMedium:
      begin
        PickupPower :=
            PickupPower
                + Round(PickupPower * SeededRandomFloatRange(Id * 374571, 0.07, 0.12))
                + SeededRandomIntRange(10, 15, Id * 254571);
        Inc(Range, SeededRandomIntRange(5, 7, Id * 354571));
      end;
      ikMajor:
      begin
        PickupPower :=
            PickupPower
                + Round(PickupPower * SeededRandomFloatRange(Id * 374571, 0.07, 0.12))
                + SeededRandomIntRange(15, 20, Id * 254571);
        Inc(Range, SeededRandomIntRange(8, 10, Id * 354571));
      end;
    end
  else if DetailImprovement = 2 then
    case Kind of
      ikMinor:
      begin
        Inc(Range, SeededRandomIntRange(10, 15, Id * 354571));
        PickupPower :=
            PickupPower
                + Round(PickupPower * SeededRandomFloatRange(Id * 374571, 0.01, 0.05))
                + SeededRandomIntRange(2, 3, Id * 254571);
      end;
      ikMedium:
      begin
        Inc(Range, SeededRandomIntRange(15, 20, Id * 354571));
        PickupPower :=
            PickupPower
                + Round(PickupPower * SeededRandomFloatRange(Id * 374571, 0.01, 0.05))
                + SeededRandomIntRange(3, 4, Id * 254571);
      end;
      ikMajor:
      begin
        Inc(Range, SeededRandomIntRange(20, 25, Id * 354571));
        PickupPower :=
            PickupPower
                + Round(PickupPower * SeededRandomFloatRange(Id * 374571, 0.01, 0.05))
                + SeededRandomIntRange(4, 5, Id * 254571);
      end;
    end;
  Inc(Cost, CalculateImprovementCost(Kind) div 2);
  DetailImprovement := 0;
end;

function TCargoHook.HasStandardStats: Boolean;
var
  StandardPower, StandardRange: Boolean;
begin
  if (MicroModuleIndex = 0)
      or (MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonHook] = 0) then
    StandardPower := CalculateGeneratedPickupPower = PickupPower
  else
    StandardPower :=
        CalculateGeneratedPickupPower
            = PickupPower - MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonHook];
  if (MicroModuleIndex = 0)
      or (MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonHookRadius] = 0) then
    StandardRange := CalculateGeneratedRange = Range
  else
    StandardRange :=
        CalculateGeneratedRange
            = Range - MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonHookRadius];
  Result := StandardPower and StandardRange;
end;

function TCargoHook.GetInfoText(ColorTag: WideString; Ship: Pointer): WideString;
var
  Text: WideString;
begin
  Text := '';
  if SpecialModuleIndex <> 0 then
    Text := MicroModuleTemplates[SpecialModuleIndex - 1].TextReplace;
  if (Text = '') and (CustomFaction <> '') then
    Text := LocalizedText('Items.CargoHook.' + CustomFaction + 'Text');
  if Text = '' then
    if OwnerId <> oiDominator then
      Text := LocalizedText('Items.CargoHook.Text')
    else
      Text := LocalizedText('Items.CargoHook.KlingText');
  ReplaceInfoTokens(Text, ColorTag, Ship);
  Text := Text + GetBonusDescription(ColorTag);
  if ScriptItem <> nil then
    Text := TScriptItem(ScriptItem).FormatDataText(Text, ColorTag);
  Result := Text + GetConditionText(True);
end;

procedure TCargoHook.ReplaceInfoTokens(var Text: WideString; ColorTag: WideString; Ship: Pointer);
var
  BonusText: WideString;
  BaseValue, StatBonus: Integer;
begin
  if (MicroModuleIndex = 0)
      or (MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonHook] = 0) then
    BonusText := ''
  else if MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonHook] > 0 then
    BonusText :=
        WrapTextInColor(
            '+' + IntToStr(MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonHook]),
            GreenColorTag
        )
  else
    BonusText :=
        WrapTextInColor(
            IntToStr(MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonHook]),
            RedColorTag
        );
  StatBonus := Max(-Max(0, PickupPower), GetStatBonus(bonHook));
  if StatBonus <> 0 then
    if StatBonus > 0 then
      BonusText := BonusText + WrapTextInColor('+' + IntToStr(StatBonus), EquipmentBonusColorTag)
    else
      BonusText := BonusText + WrapTextInColor(IntToStr(StatBonus), EquipmentBonusColorTag);
  if (Ship <> nil) and (EquippedFlag <> 0) then
    StatBonus := Max(TShip(Ship).GetTotalStatBonus(bonHook) - StatBonus, -(PickupPower + StatBonus))
  else
    StatBonus := 0;
  if StatBonus <> 0 then
    if StatBonus > 0 then
      BonusText :=
          BonusText + WrapTextInColor('(+' + IntToStr(StatBonus) + ')', EquipmentBonusColorTag)
    else
      BonusText :=
          BonusText + WrapTextInColor('(' + IntToStr(StatBonus) + ')', EquipmentBonusColorTag);
  if MicroModuleIndex = 0 then
    BaseValue := PickupPower
  else
    BaseValue := PickupPower - MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonHook];
  if CalculateGeneratedPickupPower = BaseValue then
    ReplaceTextToken(Text, '<PickUpSize>', WideString(IntToStr(BaseValue)) + BonusText, ColorTag)
  else if CalculateGeneratedPickupPower < BaseValue then
    ReplaceTextToken(
        Text,
        '<PickUpSize>',
        WrapTextInColor(IntToStr(BaseValue), GreenColorTag) + BonusText,
        ColorTag
    )
  else
    ReplaceTextToken(
        Text,
        '<PickUpSize>',
        WrapTextInColor(IntToStr(BaseValue), RedColorTag) + BonusText,
        ColorTag
    );
  if (MicroModuleIndex = 0)
      or (MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonHookRadius] = 0) then
    BonusText := ''
  else if MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonHookRadius] > 0 then
    BonusText :=
        WrapTextInColor(
            '+' + IntToStr(MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonHookRadius]),
            GreenColorTag
        )
  else
    BonusText :=
        WrapTextInColor(
            IntToStr(MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonHookRadius]),
            RedColorTag
        );
  StatBonus := Max(-Max(0, Range), GetStatBonus(bonHookRadius));
  if StatBonus <> 0 then
    if StatBonus > 0 then
      BonusText := BonusText + WrapTextInColor('+' + IntToStr(StatBonus), EquipmentBonusColorTag)
    else
      BonusText := BonusText + WrapTextInColor(IntToStr(StatBonus), EquipmentBonusColorTag);
  if (Ship <> nil) and (EquippedFlag <> 0) then
    StatBonus := Max(TShip(Ship).GetTotalStatBonus(bonHookRadius) - StatBonus, -(Range + StatBonus))
  else
    StatBonus := 0;
  if StatBonus <> 0 then
    if StatBonus > 0 then
      BonusText :=
          BonusText + WrapTextInColor('(+' + IntToStr(StatBonus) + ')', EquipmentBonusColorTag)
    else
      BonusText :=
          BonusText + WrapTextInColor('(' + IntToStr(StatBonus) + ')', EquipmentBonusColorTag);
  if MicroModuleIndex = 0 then
    BaseValue := Range
  else
    BaseValue := Range - MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonHookRadius];
  if CalculateGeneratedRange = BaseValue then
    ReplaceTextToken(
        Text,
        '<Radius>',
        WideString(IntToStr(BaseValue)) + BonusText,
        TextHighlightColorTag
    )
  else if CalculateGeneratedRange < BaseValue then
    ReplaceTextToken(
        Text,
        '<Radius>',
        WrapTextInColor(IntToStr(BaseValue), GreenColorTag) + BonusText,
        ColorTag
    )
  else
    ReplaceTextToken(
        Text,
        '<Radius>',
        WrapTextInColor(IntToStr(BaseValue), RedColorTag) + BonusText,
        ColorTag
    );
  ReplaceTextToken(
      Text,
      '<SpeedMin>',
      IntToStr(Round(CargoHookLevelStats[TechLevel].MinPullSpeed)),
      TextHighlightColorTag
  );
  ReplaceTextToken(
      Text,
      '<SpeedMax>',
      IntToStr(Round(CargoHookLevelStats[TechLevel].MaxPullSpeed)),
      TextHighlightColorTag
  );
end;

procedure TDefGenerator.Init(Weight: Integer; Level: Byte; Owner: TOwnerId);
begin
  ItemType := t_DefGenerator;
  Self.Weight := Weight;
  TechLevel := Level;
  DamageFactor := CalculateGeneratedDamageFactor;
  OwnerId := Owner;
  Repair;
  Cost := CalculateGeneratedDefGeneratorCost(Weight, Level, Owner);
  MicroModuleIndex := 0;
end;

procedure TDefGenerator.SaveToBuffer(Buffer: TBufEC);
begin
  inherited SaveToBuffer(Buffer);
  Buffer.AddAnsiChar(AnsiChar(TechLevel));
  Buffer.AddSingle(DamageFactor);
end;

procedure TDefGenerator.LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy);
begin
  inherited LoadFromBuffer(Buffer, Galaxy);
  TechLevel := Buffer.GetByte;
  DamageFactor := Buffer.GetSingle;
end;

procedure TDefGenerator.SaveToBlock(Block: TBlockParEC);
begin
  inherited SaveToBlock(Block);
  Block.AddParam(DecodeTextW('Tre4cwh0L6eHv3ealf'), IntToStr(TechLevel)); // 'TechLevel'
  Block.AddParam(DecodeTextW('Prouwseor'), FloatToStr(1 - DamageFactor)); // 'Power'
end;

procedure TDefGenerator.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  TechLevel := StrToInt(Block.GetParam(DecodeTextW('Tre4cwh0L6eHv3ealf'))); // 'TechLevel'
  DamageFactor := 1 - ExtractDecimalToSingleW(Block.GetParam(DecodeTextW('Prouwseor'))); // 'Power'
end;

function TDefGenerator.CalculateGeneratedDamageFactor: Single;
begin
  Result := DefGeneratorLevelFactors[TechLevel];
end;

function GetGeneratedDefenseDamageFactor(Level: Byte): Double;
begin
  Result := DefGeneratorLevelFactors[Level];
end;

function DefenseDamageFactorToPercent(Factor: Double): TPercent;
begin
  Result := Round((1 - Factor) * 100);
end;

function DefensePercentToDamageFactor(Percent: Integer): Double;
begin
  Result := 1 - Percent * 0.01;
end;

function CalculateGeneratedDefGeneratorCost(
    Weight: Cardinal;
    Level: Byte;
    Owner: TOwnerId
): Integer;
begin
  Result :=
      RoundAndTruncateToTens(
          RemapClamped(DefGeneratorBaseSize / Weight, 0.5, 2, 1, 2)
              * (Level * Level)
              * 500
              * OwnerInfo[Owner].FuelPriceFactor
      );
end;

procedure TDefGenerator.Improve(Kind: TImprovementKind);
begin
  if Kind = ikAny then
    Kind := TImprovementKind(SeededRandomIntRange(0, 2, Galaxy.CurrentTurn * Id));
  case Kind of
    ikMinor: DamageFactor := DamageFactor - SeededRandomFloatRange(Id * 254573, 0.01, 0.03);
    ikMedium: DamageFactor := DamageFactor - SeededRandomFloatRange(Id * 254572, 0.02, 0.04);
    ikMajor: DamageFactor := DamageFactor - SeededRandomFloatRange(Id * 254571, 0.03, 0.05);
  end;
  Inc(Cost, CalculateImprovementCost(Kind) div 2);
end;

function TDefGenerator.HasStandardStats: Boolean;
var
  ActualPercent, BonusPercent, GeneratedPercent: Integer;
begin
  ActualPercent := Round(DamageFactor * 100);
  GeneratedPercent := Round(CalculateGeneratedDamageFactor * 100);
  if (MicroModuleIndex = 0)
      or (MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonDef] = 0) then
    Result := ActualPercent = GeneratedPercent
  else
  begin
    BonusPercent := Round(MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonDef]);
    Result := ActualPercent + BonusPercent = GeneratedPercent;
  end;
end;

function TDefGenerator.GetInfoText(ColorTag: WideString; Ship: Pointer): WideString;
var
  Text: WideString;
begin
  Text := '';
  if SpecialModuleIndex <> 0 then
    Text := MicroModuleTemplates[SpecialModuleIndex - 1].TextReplace;
  if (Text = '') and (CustomFaction <> '') then
    Text := LocalizedText('Items.DefGenerator.' + CustomFaction + 'Text');
  if Text = '' then
    if OwnerId <> oiDominator then
      Text := LocalizedText('Items.DefGenerator.Text')
    else
      Text := LocalizedText('Items.DefGenerator.KlingText');
  ReplaceInfoTokens(Text, ColorTag, Ship);
  Text := Text + GetBonusDescription(ColorTag);
  if ScriptItem <> nil then
    Text := TScriptItem(ScriptItem).FormatDataText(Text, ColorTag);
  Result := Text + GetConditionText(True);
end;

procedure TDefGenerator.ReplaceInfoTokens(
    var Text: WideString;
    ColorTag: WideString;
    Ship: Pointer
);
var
  BonusText: WideString;
  ModuleBonus, ActualFactorPercent, GeneratedFactorPercent, StatBonus: Integer;
  DisplayPercent: Byte;
begin
  ModuleBonus := 0;
  if MicroModuleIndex <> 0 then
    ModuleBonus := MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonDef];
  DisplayPercent := DefenseDamageFactorToPercent(DamageFactor);
  if ModuleBonus = 0 then
    BonusText := ''
  else if ModuleBonus > 0 then
    BonusText := WrapTextInColor('+' + IntToStr(ModuleBonus), GreenColorTag)
  else
    BonusText := WrapTextInColor(IntToStr(ModuleBonus), RedColorTag);
  StatBonus := Max(-Max(0, DisplayPercent), GetStatBonus(bonDef));
  if StatBonus <> 0 then
    if StatBonus > 0 then
      BonusText := BonusText + WrapTextInColor('+' + IntToStr(StatBonus), EquipmentBonusColorTag)
    else
      BonusText := BonusText + WrapTextInColor(IntToStr(StatBonus), EquipmentBonusColorTag);
  if (Ship <> nil) and (EquippedFlag <> 0) then
    StatBonus :=
        Max(TShip(Ship).GetTotalStatBonus(bonDef) - StatBonus, -(DisplayPercent + StatBonus))
  else
    StatBonus := 0;
  if StatBonus <> 0 then
    if StatBonus > 0 then
      BonusText :=
          BonusText + WrapTextInColor('(+' + IntToStr(StatBonus) + ')', EquipmentBonusColorTag)
    else
      BonusText :=
          BonusText + WrapTextInColor('(' + IntToStr(StatBonus) + ')', EquipmentBonusColorTag);

  ActualFactorPercent := Round(DamageFactor * 100);
  GeneratedFactorPercent := Round(CalculateGeneratedDamageFactor * 100);
  if (MicroModuleIndex <> 0)
      and (MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonDef] <> 0) then
    Inc(ActualFactorPercent, Round(MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonDef]));
  if HasStandardStats then
    ReplaceTextToken(
        Text,
        '<Percent>',
        WideString(IntToStr(DisplayPercent - ModuleBonus)) + BonusText,
        ColorTag
    )
  else if ActualFactorPercent < GeneratedFactorPercent then
    ReplaceTextToken(
        Text,
        '<Percent>',
        WrapTextInColor(IntToStr(DisplayPercent - ModuleBonus), GreenColorTag) + BonusText,
        ColorTag
    )
  else
    ReplaceTextToken(
        Text,
        '<Percent>',
        WrapTextInColor(IntToStr(DisplayPercent - ModuleBonus), RedColorTag) + BonusText,
        ColorTag
    );
end;

destructor TWeapon.Destroy;
begin
  inherited Destroy;
end;

procedure TWeapon.Init(ItemType: TItemType; Weight: Integer; Level: Byte; Owner: TOwnerId);
begin
  Target := nil;
  Self.ItemType := ItemType;
  Self.Weight := Weight;
  TechLevel := Level;
  Range := CalculateGeneratedRange;
  MinDamage := CalculateGeneratedMinDamage;
  MaxDamage := CalculateGeneratedMaxDamage;
  OwnerId := Owner;
  Repair;
  Cost := CalculateGeneratedWeaponCost(GetWeaponInfo, Weight, Level, Owner);
  if GetWeaponInfo.ShotType in [wstTorpedo..wstRocket] then
  begin
    AmmoCapacity := CalculateGeneratedAmmoCapacity;
    Ammo := AmmoCapacity;
  end;
  MicroModuleIndex := 0;
end;

procedure TCustomWeapon.InitCustom(
    Info: PWeaponInfo;
    Equipped: Boolean;
    Weight: Integer;
    Level: Byte;
    Owner: TOwnerId
);
begin
  Target := nil;
  ItemType := t_CustomWeapon;
  CustomInfo := Info;
  if Equipped then
    Equip
  else
    Unequip;
  Self.Weight := Weight;
  TechLevel := Level;
  Range := CalculateGeneratedRange;
  MinDamage := CalculateGeneratedMinDamage;
  MaxDamage := CalculateGeneratedMaxDamage;
  OwnerId := Owner;
  Repair;
  Cost := CalculateGeneratedWeaponCost(Info, Weight, Level, Owner);
  if GetWeaponInfo.ShotType in [wstTorpedo..wstRocket] then
  begin
    AmmoCapacity := CalculateGeneratedAmmoCapacity;
    Ammo := AmmoCapacity;
  end;
  MicroModuleIndex := 0;
end;

procedure TWeapon.SaveToBuffer(Buffer: TBufEC);
begin
  inherited SaveToBuffer(Buffer);
  Buffer.AddAnsiChar(AnsiChar(TechLevel));
  Buffer.AddWideChar(WideChar(Range));
  Buffer.AddIntegerValue(MinDamage);
  Buffer.AddIntegerValue(MaxDamage);
  if Target = nil then
    Buffer.AddAnsiChar(#0)
  else if Target is TShip then
  begin
    Buffer.AddAnsiChar(#1);
    Buffer.AddDWord((Target as TShip).Id);
  end
  else if Target is TItem then
  begin
    Buffer.AddAnsiChar(#2);
    Buffer.AddDWord((Target as TItem).Id);
  end
  else if Target is TAsteroid then
  begin
    Buffer.AddAnsiChar(#3);
    Buffer.AddDWord((Target as TAsteroid).Id);
  end
  else if Target is TMissile then
  begin
    Buffer.AddAnsiChar(#4);
    Buffer.AddDWord((Target as TMissile).Id);
  end
  else
    Buffer.AddAnsiChar(#0);
  if GetWeaponInfo.ShotType in [wstTorpedo..wstRocket] then
  begin
    Buffer.AddDWord(Ammo);
    Buffer.AddDWord(AmmoCapacity);
  end;
end;

procedure TCustomWeapon.SaveToBuffer(Buffer: TBufEC);
begin
  Buffer.AddWideStringZ(CustomInfo.ConfigName);
  inherited SaveToBuffer(Buffer);
end;

procedure TWeapon.LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy);
begin
  inherited LoadFromBuffer(Buffer, Galaxy);
  TechLevel := Buffer.GetByte;
  Range := Buffer.GetWord;
  if LoadedSaveVersion >= 115 then
  begin
    MinDamage := Buffer.GetInt32;
    MaxDamage := Buffer.GetInt32;
  end
  else
  begin
    MinDamage := Buffer.GetByte;
    MaxDamage := Buffer.GetByte;
  end;
  LoadedTargetKind := TWeaponTargetKind(Buffer.GetByte);
  if LoadedTargetKind = wtkNone then
    Target := nil
  else
    Target := TObject(Buffer.GetUInt32);
  if GetWeaponInfo.ShotType in [wstTorpedo..wstRocket] then
  begin
    Ammo := Buffer.GetUInt32;
    AmmoCapacity := Buffer.GetUInt32;
    if (LoadedSaveVersion < 118)
        and (MicroModuleIndex <> 0)
        and (MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonWMissile] <> 0) then
      case MicroModuleTemplates[MicroModuleIndex - 1].ConfigNumber of
        204: Inc(MaxDamage, 10);
        210: Inc(MaxDamage, 15);
        216: Inc(MaxDamage, 15);
        2: Inc(MaxDamage, 4);
        18: Inc(MaxDamage, 4);
        119: Dec(MaxDamage, 2);
      else
        Inc(MaxDamage, MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonWMissile] div 2);
      end;
  end;
end;

procedure TCustomWeapon.LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy);
begin
  CustomInfo := Galaxy.RequireCustomWeaponInfo(Buffer.ReadWideString);
  inherited LoadFromBuffer(Buffer, Galaxy);
end;

procedure TWeapon.SaveToBlock(Block: TBlockParEC);
begin
  inherited SaveToBlock(Block);
  Block.AddParam(DecodeTextW('Tre4cwh0L6eHv3ealf'), IntToStr(TechLevel)); // 'TechLevel'
  Block.AddParam(DecodeTextW('Rialdoinurs'), IntToStr(Range)); // 'Radius'
  Block.AddParam(DecodeTextW('MailnoDrakmoarglen'), IntToStr(MinDamage)); // 'MinDamage'
  Block.AddParam(DecodeTextW('MianxaDoarmuavgre'), IntToStr(MaxDamage)); // 'MaxDamage'
  Block.AddParam(DecodeTextW('Almamuo'), IntToStr(Ammo)); // 'Ammo'
  Block.AddParam(DecodeTextW('MraixoAsmImGod'), IntToStr(AmmoCapacity)); // 'MaxAmmo'
end;

procedure TCustomWeapon.SaveToBlock(Block: TBlockParEC);
begin
  Block.AddParam(DecodeTextW('CrulsitroimaTryspie'), CustomInfo.ConfigName); // 'CustomType'
  inherited SaveToBlock(Block);
end;

procedure TWeapon.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  TechLevel := StrToInt(Block.GetParam(DecodeTextW('Tre4cwh0L6eHv3ealf'))); // 'TechLevel'
  Range := Word(StrToInt(Block.GetParam(DecodeTextW('Rialdoinurs')))); // 'Radius'
  MinDamage := StrToInt(Block.GetParam(DecodeTextW('MailnoDrakmoarglen'))); // 'MinDamage'
  MaxDamage := StrToInt(Block.GetParam(DecodeTextW('MianxaDoarmuavgre'))); // 'MaxDamage'
  Ammo := StrToInt(Block.GetParam(DecodeTextW('Almamuo'))); // 'Ammo'
  AmmoCapacity := StrToInt(Block.GetParam(DecodeTextW('MraixoAsmImGod'))); // 'MaxAmmo'
end;

procedure TCustomWeapon.LoadFromBlock(Block: TBlockParEC);
begin
  CustomInfo :=
      Galaxy.RequireCustomWeaponInfo(
          Block.GetParam(DecodeTextW('CrulsitroimaTryspie'))
      ); // 'CustomType'
  inherited LoadFromBlock(Block);
end;

procedure TWeapon.ResolveLoadedReferences(Galaxy: TGalaxy);
begin
  inherited ResolveLoadedReferences(Galaxy);
  if LoadedTargetKind = wtkShip then
    Target := TObject(Galaxy.IdToShip(Integer(Target), True)) as TShip
  else if LoadedTargetKind = wtkItem then
    Target := TObject(Galaxy.IdToItem(Integer(Target), True)) as TItem
  else if LoadedTargetKind = wtkAsteroid then
    Target := TObject(Galaxy.IdToAsteroid(Integer(Target))) as TAsteroid
  else if LoadedTargetKind = wtkMissile then
    Target := TObject(Galaxy.IdToMissile(Integer(Target))) as TMissile;
end;

procedure TWeapon.ClearReferences;
begin
  inherited ClearReferences;
  LoadedTargetKind := wtkNone;
  Target := nil;
end;

procedure TWeapon.Unequip;
begin
  inherited Unequip;
  Target := nil;
end;

function TWeapon.CalculateGeneratedAmmoCapacity: Integer;
begin
  Result := TechLevel * 5 + 25;
end;

function TWeapon.CalculateGeneratedMinDamage: Integer;
begin
  Result := Round(GetWeaponInfo.MinDamage * GetWeaponInfo.DamageScaleByLevel[TechLevel]);
end;

function TWeapon.CalculateGeneratedMaxDamage: Integer;
begin
  Result := Round(GetWeaponInfo.MaxDamage * GetWeaponInfo.DamageScaleByLevel[TechLevel]);
end;

function TWeapon.CalculateGeneratedRange: Integer;
begin
  Result := Round(GetWeaponInfo.AverageRange * WeaponRangeLevelFactors[TechLevel]);
end;

function TWeapon.CalculateStandardMaxDamage: Integer;
var
  BonusKind: TEquipmentBonusKind;
begin
  Result := CalculateGeneratedMaxDamage;
  BonusKind := WeaponDamageClasses[ClassifyWeaponDamageFlags(GetWeaponInfo.DamageFlags)].BonusKind;
  if MicroModuleIndex <> 0 then
    Inc(Result, MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[BonusKind]);
  if SpecialModuleIndex <> 0 then
    Inc(Result, MicroModuleTemplates[SpecialModuleIndex - 1].StatBonuses[BonusKind]);
end;

function TWeapon.CalculateStandardRange: Integer;
begin
  Result := CalculateGeneratedRange;
  if MicroModuleIndex <> 0 then
    Inc(Result, MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonWRadius]);
  if SpecialModuleIndex <> 0 then
    Inc(Result, MicroModuleTemplates[SpecialModuleIndex - 1].StatBonuses[bonWRadius]);
end;

function CalculateGeneratedWeaponCost(
    Info: PWeaponInfo;
    Weight: Cardinal;
    Level: Byte;
    Owner: TOwnerId
): Integer;
var
  LevelCost: Single;
begin
  LevelCost := RemapClamped(Level, 1, 8, 1, 4) * Info.CostFactor;
  Result :=
      RoundAndTruncateToTens(
          RemapClamped(Info.AverageSize / Weight, 0.5, 2, 1, 2)
              * LevelCost
              * 250
              * OwnerInfo[Owner].FuelPriceFactor
      );
end;

procedure TWeapon.Improve(Kind: TImprovementKind);
var
  CurrentDamage, BaseDamage, ModuleDamage: Integer;
  Info: PWeaponInfo;
begin
  if Kind = ikAny then
    Kind := TImprovementKind(SeededRandomIntRange(0, 2, Galaxy.CurrentTurn * Id));
  Info := GetWeaponInfo;
  if DetailImprovement = 0 then
    if Info.ShotType in [wstTorpedo..wstRocket] then
      DetailImprovement := 1
    else if SeededRandomUnitFloat(Galaxy.CurrentTurn * (Ord(Kind) + 1) * Id) < 0.5 then
      DetailImprovement := 1
    else
      DetailImprovement := 2;
  CurrentDamage := MaxDamage;
  BaseDamage := Info.MaxDamage;
  if (Info.ShotType in [wstMissile..wstRocket])
      and (MicroModuleIndex > 0)
      and not Galaxy.AreOldMissileBonusesEnabled then
  begin
    ModuleDamage :=
        MicroModuleTemplates[MicroModuleIndex - 1]
            .StatBonuses[
                WeaponDamageClasses[ClassifyWeaponDamageFlags(Info.DamageFlags)].BonusKind];
    CurrentDamage := Ceil(CurrentDamage - (1 - 1 / GetShotCount) * ModuleDamage);
  end;
  if DetailImprovement = 1 then
    case Kind of
      ikMinor:
      begin
        MaxDamage :=
            MaxDamage
                + Round(
                    CurrentDamage * SeededRandomFloatRange(Id * 276247, 0.07, 0.12)
                        + BaseDamage * SeededRandomFloatRange(Id * 976247, 0.1, 0.2))
                + 1;
        Inc(
            Range,
            RoundAndTruncateToTens(
                Range * SeededRandomFloatRange(Id * 354571, 0.02, 0.05)
                    + Info.AverageRange * SeededRandomFloatRange(Id * 976247, 0.02, 0.04)
            )
        );
      end;
      ikMedium:
      begin
        MaxDamage :=
            MaxDamage
                + Round(
                    CurrentDamage * SeededRandomFloatRange(Id * 276247, 0.07, 0.12)
                        + BaseDamage * SeededRandomFloatRange(Id * 976247, 0.2, 0.3))
                + 2;
        Inc(
            Range,
            RoundAndTruncateToTens(
                Range * SeededRandomFloatRange(Id * 354571, 0.02, 0.05)
                    + Info.AverageRange * SeededRandomFloatRange(Id * 976247, 0.03, 0.04)
            )
        );
      end;
      ikMajor:
      begin
        MaxDamage :=
            MaxDamage
                + Round(
                    CurrentDamage * SeededRandomFloatRange(Id * 276247, 0.07, 0.12)
                        + BaseDamage * SeededRandomFloatRange(Id * 976247, 0.3, 0.4))
                + 3;
        Inc(
            Range,
            RoundAndTruncateToTens(
                Range * SeededRandomFloatRange(Id * 354571, 0.02, 0.05)
                    + Info.AverageRange * SeededRandomFloatRange(Id * 976247, 0.04, 0.06)
            )
        );
      end;
    end
  else if DetailImprovement = 2 then
    case Kind of
      ikMinor:
      begin
        Inc(
            Range,
            RoundAndTruncateToTens(
                Range * SeededRandomFloatRange(Id * 354571, 0.04, 0.07)
                    + Info.AverageRange * SeededRandomFloatRange(Id * 976247, 0.03, 0.06)
            )
        );
        MaxDamage :=
            MaxDamage
                + Round(
                    CurrentDamage * SeededRandomFloatRange(Id * 276247, 0.03, 0.06)
                        + BaseDamage * SeededRandomFloatRange(Id * 976247, 0.05, 0.1))
                + 1;
      end;
      ikMedium:
      begin
        Inc(
            Range,
            RoundAndTruncateToTens(
                Range * SeededRandomFloatRange(Id * 354571, 0.04, 0.07)
                    + Info.AverageRange * SeededRandomFloatRange(Id * 976247, 0.06, 0.08)
            )
        );
        MaxDamage :=
            MaxDamage
                + Round(
                    CurrentDamage * SeededRandomFloatRange(Id * 276247, 0.03, 0.06)
                        + BaseDamage * SeededRandomFloatRange(Id * 976247, 0.1, 0.15))
                + 2;
      end;
      ikMajor:
      begin
        Inc(
            Range,
            RoundAndTruncateToTens(
                Range * SeededRandomFloatRange(Id * 354571, 0.04, 0.07)
                    + Info.AverageRange * SeededRandomFloatRange(Id * 976247, 0.08, 0.11)
            )
        );
        MaxDamage :=
            MaxDamage
                + Round(
                    CurrentDamage * SeededRandomFloatRange(Id * 276247, 0.03, 0.06)
                        + BaseDamage * SeededRandomFloatRange(Id * 976247, 0.15, 0.2))
                + 3;
      end;
    end
  else if DetailImprovement = 3 then
    Inc(
        Range,
        RoundAndTruncateToTens(
            Range * SeededRandomFloatRange(Id * 976247, 0.12, 0.18)
                + (Sqrt(Sqr(Info.AverageRange) + 90000) - Info.AverageRange)
        )
    );
  Inc(Cost, CalculateImprovementCost(Kind) div 2);
  DetailImprovement := 0;
end;

function TWeapon.HasStandardStats: Boolean;
begin
  Result := (CalculateStandardMaxDamage = MaxDamage) and (CalculateStandardRange = Range);
end;

function TWeapon.GetDisplayName: WideString;
begin
  if NameOverride <> '' then
    Result := NameOverride
  else if (SpecialModuleIndex <> 0)
      and (MicroModuleTemplates[SpecialModuleIndex - 1].TextReplace <> '') then
    Result := MicroModuleTemplates[SpecialModuleIndex - 1].Name
  else
    Result := GetShortName;
  if HasMicroModule then
    Result :=
        Result
            + ' '
            + WrapTextInColor(
                GetMicroModuleQuotedName,
                GetMicroModuleNameColorTag(MicroModuleIndex - 1));
end;

function TWeapon.GetShortName: WideString;
begin
  if NameOverride <> '' then
    Result := NameOverride
  else
    Result := LocalizedText('Items.Weapon.Name.' + GetConfigName);
end;

function TWeapon.GetInfoText(ColorTag: WideString; Ship: Pointer): WideString;
var
  Text, LevelText: WideString;
  DamageClass: TWeaponDamageClass;
begin
  Text := '';
  if SpecialModuleIndex <> 0 then
    Text := MicroModuleTemplates[SpecialModuleIndex - 1].TextReplace;
  if Text = '' then
    Text := LocalizedText('Items.Weapon.Text.' + GetConfigName);
  DamageClass := ClassifyWeaponDamageFlags(GetWeaponInfo.DamageFlags);
  ReplaceInfoTokens(Text, ColorTag, Ship);
  LevelText := ' (' + GetLevelLetter + ')';
  Text :=
      Text
          + #13#10
          + FormatText1(
              LocalizedText('Items.Weapon.AddText'),
              ColorTag,
              '<WeaponType>',
              LocalizedText('Items.Weapon.Type' + WeaponDamageClasses[DamageClass].Name)
                  + LevelText);
  Text := Text + GetBonusDescription(ColorTag);
  if ScriptItem <> nil then
    Text := TScriptItem(ScriptItem).FormatDataText(Text, ColorTag);
  Result := Text + GetConditionText(True);
end;

procedure TWeapon.ReplaceInfoTokens(var Text: WideString; ColorTag: WideString; Ship: Pointer);
var
  BonusText: WideString;
  UnusedNativeText:
      WideString; // Native initializes/finalizes this extra string slot without reading it.
  ModuleBonus, EffectiveBonus, BaseDamage, I: Integer;
  DamageClass: TWeaponDamageClass;
  ExpectedRange, CurrentRange, BaseRange, ExpectedDamage: Integer;
  Entry: PExtraSpecial;
  ShipBonus: Integer;
begin
  if Cardinal(GetDamageFlags) and DamageNoDeltaMask
      <> 0 then // Native flag displays the maximum as the minimum too.
    ReplaceTextToken(Text, '<MinDamage>', IntToStr(Max(MaxDamage, MinDamage)), ColorTag)
  else
    ReplaceTextToken(Text, '<MinDamage>', IntToStr(MinDamage), ColorTag);
  ModuleBonus := 0;
  DamageClass := ClassifyWeaponDamageFlags(GetWeaponInfo.DamageFlags);
  if MicroModuleIndex <> 0 then
    Inc(
        ModuleBonus,
        MicroModuleTemplates[MicroModuleIndex - 1]
            .StatBonuses[WeaponDamageClasses[DamageClass].BonusKind]
    );
  BonusText := '';
  BaseDamage := Max(MaxDamage, MinDamage) - ModuleBonus;
  ExpectedDamage := CalculateGeneratedMaxDamage;
  if ExtraSpecials <> nil then
    for I := 0 to ExtraSpecials.Count - 1 do
    begin
      Entry := ExtraSpecials[I];
      Inc(
          BaseDamage,
          MicroModuleTemplates[Entry.ModuleIndexPlusOne - 1]
                  .StatBonuses[WeaponDamageClasses[DamageClass].BonusKind]
              * Entry.Count
      );
    end;
  if ModuleBonus > 0 then
    BonusText := WrapTextInColor('+' + IntToStr(ModuleBonus), GreenColorTag);
  if ModuleBonus < 0 then
    BonusText := WrapTextInColor(IntToStr(ModuleBonus), RedColorTag);
  if (Ship <> nil) and (EquippedFlag <> 0) then
    ShipBonus := TShip(Ship).GetTotalStatBonus(WeaponDamageClasses[DamageClass].BonusKind)
  else
    ShipBonus := 0;
  if ShipBonus <> 0 then
    if ShipBonus > 0 then
      BonusText :=
          BonusText + WrapTextInColor('(+' + IntToStr(ShipBonus) + ')', EquipmentBonusColorTag)
    else
      BonusText :=
          BonusText + WrapTextInColor('(' + IntToStr(ShipBonus) + ')', EquipmentBonusColorTag);
  if BaseDamage = ExpectedDamage then
    ReplaceTextToken(Text, '<MaxDamage>', IntToStr(BaseDamage), ColorTag)
  else if BaseDamage > ExpectedDamage then
    ReplaceTextToken(
        Text,
        '<MaxDamage>',
        WrapTextInColor(IntToStr(BaseDamage), GreenColorTag),
        ColorTag
    )
  else
    ReplaceTextToken(
        Text,
        '<MaxDamage>',
        WrapTextInColor(IntToStr(BaseDamage), RedColorTag),
        ColorTag
    );
  ReplaceTextToken(Text, '<Bonus>', BonusText, ColorTag);
  if GetWeaponInfo.ShotType in [wstTorpedo..wstRocket] then
  begin
    ModuleBonus := 0;
    if ExtraSpecials <> nil then
      for I := 0 to ExtraSpecials.Count - 1 do
      begin
        Entry := ExtraSpecials[I];
        Inc(
            ModuleBonus,
            MicroModuleTemplates[Entry.ModuleIndexPlusOne - 1].StatBonuses[bonWRadius] * Entry.Count
        );
      end;
    ExpectedRange := CalculateGeneratedRange + ModuleBonus;
    CurrentRange := Range + ModuleBonus;
    if MicroModuleIndex <> 0 then
      Inc(ModuleBonus, MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonWRadius])
    else
      ModuleBonus := 0;
    BaseRange := CurrentRange - ModuleBonus;
    EffectiveBonus :=
        Max(CurrentRange, GetWeaponInfo.MissileRange) - Max(BaseRange, GetWeaponInfo.MissileRange);
    if ModuleBonus > 0 then
      BonusText := WrapTextInColor('+' + IntToStr(EffectiveBonus), GreenColorTag)
    else if ModuleBonus < 0 then
      if EffectiveBonus < 0 then
        BonusText := WrapTextInColor(IntToStr(EffectiveBonus), RedColorTag)
      else
        BonusText := WrapTextInColor('-0', RedColorTag)
    else
      BonusText := '';
    if (Ship <> nil) and (EquippedFlag <> 0) then
      ShipBonus := TShip(Ship).GetTotalStatBonus(bonWRadius)
    else
      ShipBonus := 0;
    EffectiveBonus :=
        Max(CurrentRange + ShipBonus, GetWeaponInfo.MissileRange)
            - Max(CurrentRange, GetWeaponInfo.MissileRange);
    if ShipBonus > 0 then
      BonusText :=
          BonusText + WrapTextInColor('(+' + IntToStr(EffectiveBonus) + ')', EquipmentBonusColorTag)
    else if ShipBonus < 0 then
      if EffectiveBonus < 0 then
        BonusText :=
            BonusText
                + WrapTextInColor(
                    IntToStr(EffectiveBonus) + ')',
                    EquipmentBonusColorTag) // Native negative branch omits the opening parenthesis.
      else
        BonusText := BonusText + WrapTextInColor('(-0)', EquipmentBonusColorTag);
    if BaseRange = ExpectedRange then
      ReplaceTextToken(
          Text,
          '<Radius>',
          WideString(IntToStr(Max(BaseRange, GetWeaponInfo.MissileRange))) + BonusText,
          ColorTag
      )
    else if BaseRange > ExpectedRange then
      ReplaceTextToken(
          Text,
          '<Radius>',
          WrapTextInColor(IntToStr(Max(BaseRange, GetWeaponInfo.MissileRange)), GreenColorTag)
              + BonusText,
          ColorTag
      )
    else
      ReplaceTextToken(
          Text,
          '<Radius>',
          WrapTextInColor(IntToStr(Max(BaseRange, GetWeaponInfo.MissileRange)), RedColorTag)
              + BonusText,
          ColorTag
      );
    ReplaceTextToken(Text, '<Count>', IntToStr(Ammo), ColorTag);
    ReplaceTextToken(Text, '<MaxCount>', IntToStr(AmmoCapacity), ColorTag);
    ReplaceTextToken(Text, '<CntShots>', IntToStr(GetShotCount), ColorTag);
  end
  else
  begin
    ModuleBonus := 0;
    if ExtraSpecials <> nil then
      for I := 0 to ExtraSpecials.Count - 1 do
      begin
        Entry := ExtraSpecials[I];
        Inc(
            ModuleBonus,
            MicroModuleTemplates[Entry.ModuleIndexPlusOne - 1].StatBonuses[bonWRadius] * Entry.Count
        );
      end;
    ExpectedRange := CalculateGeneratedRange + ModuleBonus;
    CurrentRange := Range + ModuleBonus;
    if MicroModuleIndex <> 0 then
      Inc(ModuleBonus, MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonWRadius])
    else
      ModuleBonus := 0;
    BaseRange := CurrentRange - ModuleBonus;
    if ModuleBonus > 0 then
      BonusText := WrapTextInColor('+' + IntToStr(ModuleBonus), GreenColorTag)
    else if ModuleBonus < 0 then
      BonusText := WrapTextInColor(IntToStr(ModuleBonus), RedColorTag)
    else
      BonusText := '';
    if (Ship <> nil) and (EquippedFlag <> 0) then
      ShipBonus := TShip(Ship).GetTotalStatBonus(bonWRadius)
    else
      ShipBonus := 0;
    if ShipBonus <> 0 then
      if ShipBonus > 0 then
        BonusText := BonusText + WrapTextInColor('+' + IntToStr(ShipBonus), EquipmentBonusColorTag)
      else
        BonusText := BonusText + WrapTextInColor(IntToStr(ShipBonus), EquipmentBonusColorTag);
    if BaseRange = ExpectedRange then
      ReplaceTextToken(Text, '<Radius>', WideString(IntToStr(BaseRange)) + BonusText, ColorTag)
    else if BaseRange > ExpectedRange then
      ReplaceTextToken(
          Text,
          '<Radius>',
          WrapTextInColor(IntToStr(BaseRange), GreenColorTag) + BonusText,
          ColorTag
      )
    else
      ReplaceTextToken(
          Text,
          '<Radius>',
          WrapTextInColor(IntToStr(BaseRange), RedColorTag) + BonusText,
          ColorTag
      );
  end;
  ReplaceTextToken(Text, '<CntAttacks>', IntToStr(GetAttackCount), ColorTag);
end;

function TWeapon.GetDescriptionText: WideString;
begin
  Result := LocalizedText('Items.TWeapon.Description.' + GetConfigName);
end;

function TWeapon.GetShotDelayFactor: Double;
var
  SpeedPercent, I: Integer;
  Entry: PExtraSpecial;
begin
  SpeedPercent := GetWeaponInfo.ShotSpeedPercent;
  if MicroModuleIndex <> 0 then
    Inc(SpeedPercent, MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonShotSpeed]);
  if SpecialModuleIndex <> 0 then
    Inc(SpeedPercent, MicroModuleTemplates[SpecialModuleIndex - 1].StatBonuses[bonShotSpeed]);
  if ExtraSpecials <> nil then
    for I := 0 to ExtraSpecials.Count - 1 do
    begin
      Entry := ExtraSpecials[I];
      Inc(
          SpeedPercent,
          MicroModuleTemplates[Entry.ModuleIndexPlusOne - 1].StatBonuses[bonShotSpeed] * Entry.Count
      );
    end;
  SpeedPercent := Max(0, Min(100, SpeedPercent));
  Result := 1 - SpeedPercent * 0.01;
end;

function TWeapon.GetBitmapResourceName: WideString;
begin
  if ConfigBlockName <> '' then
    Result := 'Bm.Items.' + GiResourceSuffix + ConfigBlockName
  else if (SpecialModuleIndex > 0)
      and (MicroModuleTemplates[SpecialModuleIndex - 1].KindGraph <> '') then
    Result :=
        'Bm.Items.'
            + GiResourceSuffix
            + ItemTypeNames[ItemType]
            + MicroModuleTemplates[SpecialModuleIndex - 1].KindGraph
  else
    Result := 'Bm.Items.' + GiResourceSuffix + ItemTypeNames[ItemType];
end;

function TCustomWeapon.GetBitmapResourceName: WideString;
begin
  if ConfigBlockName <> '' then
    Result := 'Bm.Items.' + GiResourceSuffix + ConfigBlockName
  else if (SpecialModuleIndex > 0)
      and (MicroModuleTemplates[SpecialModuleIndex - 1].KindGraph <> '') then
    Result :=
        'Bm.Items.'
            + GiResourceSuffix
            + 'W'
            + GetConfigName
            + MicroModuleTemplates[SpecialModuleIndex - 1].KindGraph
  else
    Result := 'Bm.Items.' + GiResourceSuffix + 'W' + GetConfigName;
end;

function TWeapon.NeedsAmmo: Boolean;
begin
  Result := False;
  if GetWeaponInfo.ShotType in [wstTorpedo..wstRocket] then
    if Ammo < AmmoCapacity then
      Result := True;
end;

function TWeapon.CalculateAmmoRefillCost: Integer;
var
  MissingAmmo: Integer;
  UnitCost: Single;
begin
  Result := 0;
  if not (GetWeaponInfo.ShotType in [wstTorpedo..wstRocket]) then
    Exit;
  if Ammo < AmmoCapacity then
  begin
    MissingAmmo := AmmoCapacity - Ammo;
    UnitCost := Galaxy.ScaleIntByTechLevel(10, 100);
    Result := Round(MissingAmmo * UnitCost);
  end;
end;

function TWeapon.GetShotPalette: Integer;
begin
  if (SpecialModuleIndex = 0) or (MicroModuleTemplates[SpecialModuleIndex - 1].ShotVisual = -1) then
    Result := GetWeaponInfo.DefaultPalette
  else
    Result := MicroModuleTemplates[SpecialModuleIndex - 1].ShotVisual;
end;

function TWeapon.GetDamageFlags: TDamageFlagSet;
var
  I: Integer;
  Entry: PExtraSpecial;
begin
  Result := GetWeaponInfo.DamageFlags;
  if SpecialModuleIndex <> 0 then
    Result := Result + MicroModuleTemplates[SpecialModuleIndex - 1].WeaponDamageFlags;
  if MicroModuleIndex <> 0 then
    Result := Result + MicroModuleTemplates[MicroModuleIndex - 1].WeaponDamageFlags;
  if ExtraSpecials <> nil then
    for I := 0 to ExtraSpecials.Count - 1 do
    begin
      Entry := ExtraSpecials[I];
      Result := Result + MicroModuleTemplates[Entry.ModuleIndexPlusOne - 1].WeaponDamageFlags;
    end;
end;

function TWeapon.GetShotCount: Integer;
var
  I: Integer;
  Entry: PExtraSpecial;
begin
  Result := GetWeaponInfo.ShotCount;
  if not (GetWeaponInfo.ShotType in [wstChain, wstMissile, wstRocket]) then
    Exit;
  if SpecialModuleIndex <> 0 then
    Inc(Result, MicroModuleTemplates[SpecialModuleIndex - 1].StatBonuses[bonShots]);
  if MicroModuleIndex <> 0 then
    Inc(Result, MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonShots]);
  if ExtraSpecials <> nil then
    for I := 0 to ExtraSpecials.Count - 1 do
    begin
      Entry := ExtraSpecials[I];
      Inc(
          Result,
          MicroModuleTemplates[Entry.ModuleIndexPlusOne - 1].StatBonuses[bonShots] * Entry.Count
      );
    end;
  Result := Max(Result, 1);
end;

function TWeapon.GetAttackCount: Integer;
var
  I: Integer;
  Entry: PExtraSpecial;
begin
  Result := GetWeaponInfo.AttackCount;
  if SpecialModuleIndex <> 0 then
    Inc(Result, MicroModuleTemplates[SpecialModuleIndex - 1].StatBonuses[bonAttacks]);
  if MicroModuleIndex <> 0 then
    Inc(Result, MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonAttacks]);
  if ExtraSpecials <> nil then
    for I := 0 to ExtraSpecials.Count - 1 do
    begin
      Entry := ExtraSpecials[I];
      Inc(
          Result,
          MicroModuleTemplates[Entry.ModuleIndexPlusOne - 1].StatBonuses[bonAttacks] * Entry.Count
      );
    end;
  Result := Max(Result, 1);
end;

function TWeapon.GetWeaponInfo: PWeaponInfo;
begin
  Result := @WeaponInfos[ItemType];
end;

function TCustomWeapon.GetWeaponInfo: PWeaponInfo;
begin
  Result := CustomInfo;
end;

function TWeapon.GetConfigName: WideString;
begin
  Result := IntToStr(Ord(ItemType) - Ord(t_IndustrialLaser) + 1);
end;

function TCustomWeapon.GetConfigName: WideString;
begin
  Result := CustomInfo.ConfigName;
end;

procedure TGoods.Init(ItemType: TItemType; Quantity: Integer);
begin
  Self.ItemType := ItemType;
  Self.Quantity := Quantity;
  Weight := Quantity;
  Cost := GoodsMarket[Ord(Self.ItemType)].AveragePrice * Self.Quantity;
  NaturalFlag := False;
end;

procedure TGoods.SaveToBuffer(Buffer: TBufEC);
begin
  inherited SaveToBuffer(Buffer);
  Buffer.AddIntegerValue(Quantity);
  Buffer.AddBoolean(NaturalFlag);
end;

procedure TGoods.LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy);
begin
  inherited LoadFromBuffer(Buffer, Galaxy);
  Quantity := Buffer.GetInt32;
  NaturalFlag := Buffer.GetBoolean;
end;

function TGoods.GetDisplayName: WideString;
begin
  if NameOverride <> '' then
    Result := NameOverride
  else
    Result := GoodsMarket[Ord(ItemType)].DisplayName;
end;

function TGoods.GetInfoText(ColorTag: WideString; Ship: Pointer): WideString;
var
  Text: WideString;
begin
  Text := LocalizedText('Items.Goods.Text' + IntToStr(Ord(ItemType) + 1));
  Result := WrapTextInColor(GetDisplayName, ColorTag) + Text;
end;

function TGoods.GetDescriptionText: WideString;
begin
  Result := LocalizedText('Items.Goods.Description.' + IntToStr(Ord(ItemType) + 1));
end;

function TGoods.GetBitmapResourceName: WideString;
begin
  Result := 'Bm.Items.' + GiResourceSuffix + ItemTypeNames[ItemType];
end;

procedure TCountableItem.SaveToBuffer(Buffer: TBufEC);
begin
  inherited SaveToBuffer(Buffer);
  Buffer.AddIntegerValue(StackCount);
  Buffer.AddBoolean(Boolean(DropFlag));
end;

procedure TCountableItem.LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy);
begin
  inherited LoadFromBuffer(Buffer, Galaxy);
  StackCount := Buffer.GetInt32;
  DropFlag := Byte(Buffer.GetBoolean);
end;

procedure TCountableItem.Init(ConfigName: WideString; Count: Integer; DropFlag: Byte);
begin
  ItemType := t_UselessCountableItem;
  ConfigBlockName := ConfigName;
  Self.DropFlag := DropFlag;
  StackCount := Count;
  Weight := GetUnitSize * Count;
  Cost := Count;
  OwnerId := oiUninhabited;
  EquippedFlag := 0;
  ConditionPercent := 0;
  BrokenFlag := 1;
end;

function TCountableItem.GetDisplayName: WideString;
begin
  if NameOverride <> '' then
    Result := NameOverride
  else
    Result := LocalizedText('Items.CustomCountables.' + ConfigBlockName + '.Name');
end;

function TCountableItem.GetInfoText(ColorTag: WideString; Ship: Pointer): WideString;
begin
  Result := LocalizedText('Items.CustomCountables.' + ConfigBlockName + '.Text');
  ReplaceTextToken(Result, '<N>', IntToStr(StackCount), ColorTag);
  if ScriptItem <> nil then
    Result := TScriptItem(ScriptItem).FormatDataText(Result, ColorTag);
end;

function TCountableItem.GetDescriptionText: WideString;
begin
  Result := LocalizedText('Items.CustomCountables.' + ConfigBlockName + '.Description');
end;

function TCountableItem.GetBitmapResourceName: WideString;
begin
  if StackCount <= 19 then
    Result := 'Bm.Items.' + GiResourceSuffix + ConfigBlockName + '0_'
  else if StackCount <= 39 then
    Result := 'Bm.Items.' + GiResourceSuffix + ConfigBlockName + '1_'
  else if StackCount <= 59 then
    Result := 'Bm.Items.' + GiResourceSuffix + ConfigBlockName + '2_'
  else if StackCount <= 79 then
    Result := 'Bm.Items.' + GiResourceSuffix + ConfigBlockName + '3_'
  else
    Result := 'Bm.Items.' + GiResourceSuffix + ConfigBlockName + '4_';
end;

function TCountableItem.GetUnitSize: Integer;
var
  Block: TBlockParEC;
begin
  Result := 1;
  if ItemType <> t_Protoplasm then
  begin
    Block := LanguageDataConfig.GetBlockByPath('Items.CustomCountables.' + ConfigBlockName);
    if Block.CountParams('UnitSize') > 0 then
      Result := ExtractDigitsToIntW(Block.GetParam('UnitSize'));
  end;
end;

function TCountableItem.Split(Count: Integer): TCountableItem;
var
  SplitCount, I: Integer;
  NewScriptItem, OriginalScriptItem: TScriptItem;
begin
  SplitCount := Min(StackCount, Count);
  if ItemType = t_Protoplasm then
  begin
    Result := TProtoplasm.Create;
    (Result as TProtoplasm).Init(SplitCount, 0);
  end
  else
  begin
    Result := TCountableItem.Create;
    Result.Init(ConfigBlockName, SplitCount, 0);
  end;
  Result.Cost := Max(1, Round(Cost / StackCount * SplitCount));
  Cost := Max(1, Cost - Result.Cost);
  Dec(StackCount, SplitCount);
  Weight := GetUnitSize * StackCount;
  Result.OwnerId := OwnerId;
  Result.DominatorSeries := DominatorSeries;
  Result.CustomFaction := CustomFaction;
  if (ScriptItem <> nil) and (TScriptItem(ScriptItem).Name = '') then
  begin
    OriginalScriptItem := TScriptItem(ScriptItem);
    NewScriptItem := nil;
    for I := 0 to OriginalScriptItem.Script.Items.Count - 1 do
    begin
      NewScriptItem := OriginalScriptItem.Script.Items[I];
      if (NewScriptItem.Name = '') and (NewScriptItem.Item = nil) then
        Break;
      NewScriptItem := nil;
    end;
    if NewScriptItem = nil then
    begin
      NewScriptItem := TScriptItem.Create;
      NewScriptItem.Script := OriginalScriptItem.Script;
      OriginalScriptItem.Script.Items.Add(NewScriptItem);
    end;
    NewScriptItem.Item := Result;
    Result.ScriptItem := NewScriptItem;
    if NewScriptItem.ActionCode <> nil then
      NewScriptItem.ActionCode.Free;
    NewScriptItem.ActionCode := nil;
    NewScriptItem.ActionCodeInitialized := False;
    NewScriptItem.OnActionText := OriginalScriptItem.OnActionText;
    NewScriptItem.OnUseText := OriginalScriptItem.OnUseText;
    NewScriptItem.CanSell := OriginalScriptItem.CanSell;
    NewScriptItem.Data[1] := OriginalScriptItem.Data[1];
    NewScriptItem.Data[2] := OriginalScriptItem.Data[2];
    NewScriptItem.Data[3] := OriginalScriptItem.Data[3];
    NewScriptItem.TextData1 := OriginalScriptItem.TextData1;
    NewScriptItem.TextData2 := OriginalScriptItem.TextData2;
    NewScriptItem.TextData3 := OriginalScriptItem.TextData3;
  end;
end;

function TCountableItem.CanMerge(Other: TObject): Boolean;
var
  OtherStack: TCountableItem;
begin
  Result := False;
  if not (Other is TCountableItem) then
    Exit;
  if Self = Other then
    Exit;
  if TItem(Other).ItemType <> ItemType then
    Exit;
  OtherStack := TCountableItem(Other);
  if Self is TProtoplasm then
    if OtherStack.DominatorSeries <> DominatorSeries then
      Exit;
  if ConfigBlockName = OtherStack.ConfigBlockName then
    Result := True;
end;

function TCountableItem.Merge(Other: TObject): Boolean;
var
  OtherStack: TCountableItem;
begin
  Result := False;
  if CanMerge(Other) then
  begin
    OtherStack := TCountableItem(Other);
    Inc(StackCount, OtherStack.StackCount);
    Weight := GetUnitSize * StackCount;
    Inc(Cost, OtherStack.Cost);
    Result := True;
  end;
end;

procedure TProtoplasm.Init(Count: Integer; DropFlag: Byte);
begin
  ItemType := t_Protoplasm;
  StackCount := Count;
  Weight := Count;
  Cost := Count * 10;
  OwnerId := oiDominator;
  Self.DropFlag := DropFlag;
  EquippedFlag := 0;
  ConditionPercent := 0;
  BrokenFlag := 1;
end;

function TProtoplasm.GetDisplayName: WideString;
begin
  if NameOverride <> '' then
    Result := NameOverride
  else
    Result :=
        LocalizedText('Items.Nod.Name')
            + ' '
            + LocalizedText('Items.Nod.S' + IntToStr(Ord(DominatorSeries)));
end;

function TProtoplasm.GetInfoText(ColorTag: WideString; Ship: Pointer): WideString;
begin
  Result := LocalizedText('Items.Nod.Text');
  ReplaceTextToken(Result, '<N>', IntToStr(StackCount), ColorTag);
end;

function TProtoplasm.GetDescriptionText: WideString;
begin
  Result := LocalizedText('Items.Nod.Description');
end;

function TProtoplasm.GetBitmapResourceName: WideString;
begin
  if StackCount <= 19 then
    Result := 'Bm.Items.' + GiResourceSuffix + 'Nod0_'
  else if StackCount <= 39 then
    Result := 'Bm.Items.' + GiResourceSuffix + 'Nod1_'
  else if StackCount <= 59 then
    Result := 'Bm.Items.' + GiResourceSuffix + 'Nod2_'
  else if StackCount <= 79 then
    Result := 'Bm.Items.' + GiResourceSuffix + 'Nod3_'
  else
    Result := 'Bm.Items.' + GiResourceSuffix + 'Nod4_';
end;

constructor TEquipmentWithActCode.Create;
begin
  inherited Create;
  ActionCode := nil;
  ActCodeInitialized := False;
end;

destructor TEquipmentWithActCode.Destroy;
begin
  ActionCode := nil;
  inherited Destroy;
end;

constructor TUselessItem.Create;
begin
  inherited Create;
  DisplayAsArtefact := False;
end;

destructor TUselessItem.Destroy;
begin
  if (Galaxy <> nil) and not Galaxy.Destroying and (GetPlayer <> nil) then
    RunItemConfigActionCode(Self, satOnItemDestroy, nil, nil, nil, 0);
  inherited Destroy;
end;

procedure TUselessItem.Init(
    ConfigName: WideString;
    Series: TDominatorSeries;
    Seed: Cardinal;
    ForceArtefactDisplay: Boolean
);
begin
  ItemType := t_UselessItem;
  DominatorSeries := Series;
  if ConfigName = 'Remains' then
  begin
    repeat
      ConfigBlockName :=
          'Remains_' + IntToStr(SeededRandomIntRange(0, UselessItemRemainsCount - 1, Seed));
      if Pos(
              DominatorSeriesNames[Series],
              LookupLocalizedTextByKey('UselessItems.' + ConfigBlockName + '.Owner'))
          > 0 then
        Break;
      Inc(Seed);
    until False;
  end
  else
    ConfigBlockName := ConfigName;
  if ForceArtefactDisplay then
    DisplayAsArtefact := True
  else
    CheckIfWeDisplayAsArtefact;
  if ConfigName = 'Remains' then
    OwnerId := oiDominator
  else
    OwnerId :=
        OwnerFromInternalName(
            LookupLocalizedTextByKey('UselessItems.' + ConfigBlockName + '.Owner')
        );
  Weight :=
      StrToInt(AnsiString(LookupLocalizedTextByKey('UselessItems.' + ConfigBlockName + '.Size')));
  Weight :=
      Max(
          1,
          Round(
              SeededRandomIntRange(0, Weight, Id * 71621723)
                      * RemapClamped(Galaxy.TechLevel, 4, 8, 0.5, 3)
                  + Weight
          )
      );
  Cost :=
      Round(
          Galaxy.ResolveMoneySizeTag(
                  LookupLocalizedTextByKey('UselessItems.' + ConfigBlockName + '.Cost'),
                  oiHuman)
              * SeededRandomFloatRange(Id * 13567157, 0.5, 1.2)
      );
  Cost :=
      RoundAndTruncateToTens(
          SeededRandomIntRange(150, 200, Id * 13567157)
                  * RemapClamped(Galaxy.TechLevel, 4, 8, 1, 3)
                  * RemapClamped(Weight, 10, 100, 1, 6)
                  * GalaxyDifficultyTuning[Galaxy.DifficultyLevels[7]].ArcadeRewardScale
              + Cost
      );
  Repair;
  CustomText := '';
  Data[0] := 0;
  Data[1] := 0;
  Data[2] := 0;
end;

procedure TUselessItem.SaveToBuffer(Buffer: TBufEC);
begin
  inherited SaveToBuffer(Buffer);
  Buffer.AddWideStringZ(CustomText);
  Buffer.AddIntegerValue(Data[0]);
  Buffer.AddIntegerValue(Data[1]);
  Buffer.AddIntegerValue(Data[2]);
end;

procedure TUselessItem.LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy);
begin
  inherited LoadFromBuffer(Buffer, Galaxy);
  if LoadedSaveVersion < 86 then
    ConfigBlockName := Buffer.ReadWideString;
  if LoadedSaveVersion >= 76 then
  begin
    CustomText := Buffer.ReadWideString;
    Data[0] := Buffer.GetInt32;
    Data[1] := Buffer.GetInt32;
    Data[2] := Buffer.GetInt32;
  end
  else
  begin
    CustomText := '';
    Data[0] := 0;
    Data[1] := 0;
    Data[2] := 0;
  end;
  CheckIfWeDisplayAsArtefact;
end;

procedure TUselessItem.SaveToBlock(Block: TBlockParEC);
begin
  inherited SaveToBlock(Block);
  Block.AddParam(DecodeTextW('SoyIsaNoarmoed'), ConfigBlockName); // 'SysName'
end;

procedure TUselessItem.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  ConfigBlockName := Block.GetParam(DecodeTextW('SoyIsaNoarmoed')); // 'SysName'
  CheckIfWeDisplayAsArtefact;
end;

function TUselessItem.GetDisplayName: WideString;
begin
  if NameOverride <> '' then
    Result := NameOverride
  else if LanguageDataConfig.GetBlock('UselessItems').CountBlocks(ConfigBlockName) <= 0 then
    Result := ''
  else
    Result := LocalizedText('UselessItems.' + ConfigBlockName + '.Name');
end;

function TUselessItem.GetInfoText(ColorTag: WideString; Ship: Pointer): WideString;
begin
  Result := CustomText;
  if Result = '' then
    if LanguageDataConfig.GetBlock('UselessItems').CountBlocks(ConfigBlockName) > 0 then
      Result := LocalizedText('UselessItems.' + ConfigBlockName + '.Text');
  ReplaceTextToken(Result, '<Data1>', IntToStr(Data[0]), ColorTag);
  ReplaceTextToken(Result, '<Data2>', IntToStr(Data[1]), ColorTag);
  ReplaceTextToken(Result, '<Data3>', IntToStr(Data[2]), ColorTag);
end;

function TUselessItem.GetDescriptionText: WideString;
begin
  if LanguageDataConfig.GetBlock('UselessItems').CountBlocks(ConfigBlockName) <= 0 then
    Result := ''
  else
    Result := LocalizedText('UselessItems.' + ConfigBlockName + '.Description');
end;

function TUselessItem.GetBitmapResourceName: WideString;
begin
  if Pos('Remains', ConfigBlockName) > 0 then
    Result :=
        'Bm.ItemsUseless.'
            + GiResourceSuffix
            + ConfigBlockName
            + '_'
            + IntToStr(Ord(DominatorSeries))
            + '_'
  else if Pos('Mimic', ConfigBlockName) > 0 then
    Result :=
        'Bm.Items.'
            + GiResourceSuffix
            + CopyWideStringUnchecked(ConfigBlockName, 6, Length(ConfigBlockName) - 5)
            + '_'
  else
    Result := 'Bm.ItemsUseless.' + GiResourceSuffix + ConfigBlockName + '_';
  if not CacheDataRoot.FileExistsByPath(Result + 's') then
  begin
    AppendLogLineThreadSafe(
        AnsiString(
            'Can not find image for useless item ' + ConfigBlockName + ' changing to Usl_FishCont'
        )
    );
    Result := 'Bm.ItemsUseless.' + GiResourceSuffix + 'Usl_FishCont_';
  end;
end;

function TUselessItem.IsDominatorRemains: Boolean;
begin
  Result := (OwnerId = oiDominator) and (Pos('Remains_', ConfigBlockName) = 1);
end;

procedure TUselessItem.CheckIfWeDisplayAsArtefact;
var
  I: Integer;
begin
  DisplayAsArtefact := False;
  for I := 0 to Length(UselessItemLootPools[3]) - 1 do
    if UselessItemLootPools[3][I] = ConfigBlockName then
    begin
      DisplayAsArtefact := True;
      Break;
    end;
end;

function TUselessItem.GetOnUseCodeText: WideString;
var
  Block: TBlockParEC;
begin
  Result := '';
  Block := LanguageDataConfig.GetBlock('UselessItems').FindBlock(ConfigBlockName);
  if Block <> nil then
  begin
    Block := Block.FindBlock('OnUseCode');
    if Block <> nil then
      Result := Block.ConcatenateValues;
  end;
end;

function TUselessItem.GetActionCode: Pointer;
var
  Config: TBlockParEC;
begin
  if ActCodeInitialized then
  begin
    Result := ActionCode;
    Exit;
  end;
  ActCodeInitialized := True;
  Result := nil;
  Config := LanguageDataConfig.GetBlock('UselessItems').FindBlock(ConfigBlockName);
  if Config <> nil then
  begin
    ActionCode := GetCachedActionCode(UselessItemScriptCache, ConfigBlockName, Config);
    Result := ActionCode;
  end;
end;

procedure TCistern.Init(Fuel: Integer; Capacity: Byte; Owner: TOwnerId);
begin
  ItemType := t_Cistern;
  Self.Capacity := Capacity;
  Weight := Capacity;
  Self.Fuel := Min(Self.Capacity, Fuel);
  Cost := 10 * Capacity;
  OwnerId := Owner;
  EquippedFlag := 0;
  Repair;
end;

procedure TCistern.SaveToBuffer(Buffer: TBufEC);
begin
  inherited SaveToBuffer(Buffer);
  Buffer.AddAnsiChar(AnsiChar(Capacity));
  Buffer.AddIntegerValue(Fuel);
end;

procedure TCistern.LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy);
begin
  inherited LoadFromBuffer(Buffer, Galaxy);
  Capacity := Buffer.GetByte;
  Fuel := Buffer.GetInt32;
end;

procedure TCistern.SaveToBlock(Block: TBlockParEC);
begin
  inherited SaveToBlock(Block);
  Block.AddParam(DecodeTextW('FiuNeol'), IntToStr(Fuel)); // 'Fuel'
  Block.AddParam(DecodeTextW('CraspiaNcliotay'), IntToStr(Capacity)); // 'Capacity'
end;

procedure TCistern.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  Fuel := StrToInt(Block.GetParam(DecodeTextW('FiuNeol'))); // 'Fuel'
  Capacity := StrToInt(Block.GetParam(DecodeTextW('CraspiaNcliotay'))); // 'Capacity'
end;

function TCistern.GetDisplayName: WideString;
begin
  if NameOverride <> '' then
    Result := NameOverride
  else
    Result := LocalizedText('Items.Cistern.Name');
end;

function TCistern.GetInfoText(ColorTag: WideString; Ship: Pointer): WideString;
begin
  Result := LocalizedText('Items.Cistern.Text');
  ReplaceTextToken(Result, '<Fuel>', IntToStr(Fuel), ColorTag);
  ReplaceTextToken(Result, '<Capacity>', IntToStr(Capacity), ColorTag);
end;

function TCistern.GetDescriptionText: WideString;
begin
  Result := LocalizedText('Items.Cistern.Description');
end;

function TCistern.GetBitmapResourceName: WideString;
begin
  if ConfigBlockName <> '' then
    Result := 'Bm.Items.' + GiResourceSuffix + ConfigBlockName
  else
    Result := 'Bm.Items.' + GiResourceSuffix + 'Cistern_';
end;

procedure TSatellite.InitGenerated(TypeId: Byte; Owner: TOwnerId; Seed: Cardinal);
var
  Roll: Single;
  SpeedText: WideString;
  WearLevel: Byte;
begin
  ItemType := t_Satellite;
  SatelliteTypeId := TypeId;
  OwnerId := Owner;
  TargetPlanet := nil;
  TrajectoryIndex := 0;
  SpeedText := LocalizedText('Items.Satellite.' + IntToStr(SatelliteTypeId) + '.Speed');
  WaterExplorationRate := StrToInt(ExtractDelimitedPartW(SpeedText, 0, ','));
  LandExplorationRate := StrToInt(ExtractDelimitedPartW(SpeedText, 1, ','));
  HillExplorationRate := StrToInt(ExtractDelimitedPartW(SpeedText, 2, ','));
  Roll := NextRandomUnitFloat(Seed);
  if Roll < 0.2 then
    Inc(WaterExplorationRate)
  else if Roll < 0.4 then
    Inc(LandExplorationRate)
  else if Roll < 0.6 then
    Inc(HillExplorationRate);
  EquippedFlag := 0;
  Weight :=
      StrToInt(LookupLocalizedTextByKey('Items.Satellite.' + IntToStr(SatelliteTypeId) + '.Size'));
  Weight :=
      Round(
          NextRandomIntRange(0, Weight, Seed) * RemapClamped(aGalaxy.Galaxy.TechLevel, 4, 8, 1, 1.5)
              + Weight div 2
      );
  Cost :=
      Round(
          aGalaxy.Galaxy.ResolveMoneySizeTag(
                  LookupLocalizedTextByKey(
                      'Items.Satellite.' + IntToStr(SatelliteTypeId) + '.Cost'
                  ),
                  oiHuman)
              * NextRandomFloatRange(1, 2, Seed)
      );
  Cost :=
      RoundAndTruncateToTens(
          NextRandomIntRange(150, 200, Seed)
                  * RemapClamped(aGalaxy.Galaxy.TechLevel, 4, 8, 1, 3)
                  * RemapClamped(Weight, 10, 50, 2, 1)
                  / GalaxyDifficultyTuning[aGalaxy.Galaxy.DifficultyLevels[7]].QuestMoneyFactor
              + Cost
      );
  WearLevel :=
      SizeTagToLevel(
          LookupLocalizedTextByKey('Items.Satellite.' + IntToStr(SatelliteTypeId) + '.Wear')
      );
  WearPerTurn := GenerateValueForSizeLevel(WearLevel, 1, 10, 30, Seed * $E73FE205) * 0.1;
  Repair;
end;

procedure TSatellite.SaveToBuffer(Buffer: TBufEC);
begin
  inherited SaveToBuffer(Buffer);
  Buffer.AddAnsiChar(AnsiChar(SatelliteTypeId));
  Buffer.AddIntegerValue(TrajectoryIndex);
  if TargetPlanet = nil then
    Buffer.AddDWord(0)
  else
    Buffer.AddDWord((TObject(TargetPlanet) as TPlanet).Id);
  Buffer.AddAnsiChar(AnsiChar(WaterExplorationRate));
  Buffer.AddAnsiChar(AnsiChar(LandExplorationRate));
  Buffer.AddAnsiChar(AnsiChar(HillExplorationRate));
  Buffer.AddSingle(WearPerTurn);
end;

procedure TSatellite.LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy);
begin
  inherited LoadFromBuffer(Buffer, Galaxy);
  SatelliteTypeId := Buffer.GetByte;
  TrajectoryIndex := Buffer.GetInt32;
  TargetPlanet := Pointer(Buffer.GetUInt32);
  WaterExplorationRate := Buffer.GetByte;
  LandExplorationRate := Buffer.GetByte;
  HillExplorationRate := Buffer.GetByte;
  WearPerTurn := Buffer.GetSingle;
end;

procedure TSatellite.SaveToBlock(Block: TBlockParEC);
begin
  inherited SaveToBlock(Block);
  Block.AddParam(DecodeTextW('ToyIprey'), IntToStr(SatelliteTypeId)); // 'Type'
  Block.AddParam(DecodeTextW('WuartTewrf'), IntToStr(WaterExplorationRate)); // 'Water'
  Block.AddParam(DecodeTextW('LLagnsd3'), IntToStr(LandExplorationRate)); // 'Land'
  Block.AddParam(DecodeTextW('HbiFldle'), IntToStr(HillExplorationRate)); // 'Hill'
  Block.AddParam(DecodeTextW('WoeIamrr'), FloatToStr(WearPerTurn)); // 'Wear'
end;

procedure TSatellite.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  SatelliteTypeId := StrToInt(Block.GetParam(DecodeTextW('ToyIprey'))); // 'Type'
  WaterExplorationRate := StrToInt(Block.GetParam(DecodeTextW('WuartTewrf'))); // 'Water'
  LandExplorationRate := StrToInt(Block.GetParam(DecodeTextW('LLagnsd3'))); // 'Land'
  HillExplorationRate := StrToInt(Block.GetParam(DecodeTextW('HbiFldle'))); // 'Hill'
  WearPerTurn := ExtractDecimalToSingleW(Block.GetParam(DecodeTextW('WoeIamrr'))); // 'Wear'
end;

procedure TSatellite.ResolveLoadedReferences(Galaxy: TGalaxy);
begin
  inherited ResolveLoadedReferences(Galaxy);
  TargetPlanet := TObject(Galaxy.IdToPlanet(Cardinal(TargetPlanet))) as TPlanet;
end;

procedure TSatellite.ClearReferences;
begin
  inherited ClearReferences;
  TargetPlanet := nil;
end;

function TSatellite.GetDisplayName: WideString;
begin
  if NameOverride <> '' then
    Result := NameOverride
  else
    Result :=
        LookupLocalizedTextByKey('Items.Satellite.Name')
            + ' '
            + LocalizedText('Items.Satellite.' + IntToStr(SatelliteTypeId) + '.Name')
            + '-'
            + IntToStr(Cardinal(Id) mod 100 + 1);
end;

function TSatellite.GetInfoText(ColorTag: WideString; Ship: Pointer): WideString;
begin
  Result := LocalizedText('Items.Satellite.' + IntToStr(SatelliteTypeId) + '.Text');
  if WaterExplorationRate > 0 then
    ReplaceTextToken(Result, '<Water>', IntToStr(WaterExplorationRate), ColorTag)
  else
    ReplaceTextToken(Result, '<Water>', '-', '');
  if LandExplorationRate > 0 then
    ReplaceTextToken(Result, '<Land>', IntToStr(LandExplorationRate), ColorTag)
  else
    ReplaceTextToken(Result, '<Land>', '-', '');
  if HillExplorationRate > 0 then
    ReplaceTextToken(Result, '<Hill>', IntToStr(HillExplorationRate), ColorTag)
  else
    ReplaceTextToken(Result, '<Hill>', '-', '');
  Result := Result + GetConditionText(True);
end;

function TSatellite.GetBrokenInUseText: WideString;
var
  PlanetName: WideString;
begin
  Result := LocalizedText('Items.' + ItemTypeNames[ItemType] + '.BrokenInUse');
  if TargetPlanet <> nil then
    PlanetName := (TObject(TargetPlanet) as TPlanet).Name
  else
    PlanetName := '';
  ReplaceTextToken(Result, '<Name>', GetDisplayName, TextHighlightColorTag);
  ReplaceTextToken(Result, '<Planet>', PlanetName, TextHighlightColorTag);
end;

function TSatellite.GetIdleInfoText: WideString;
var
  PlanetName: WideString;
begin
  Result := LocalizedText('Items.' + ItemTypeNames[ItemType] + '.IdleInfo');
  if TargetPlanet <> nil then
    PlanetName := (TObject(TargetPlanet) as TPlanet).Name
  else
    PlanetName := '';
  ReplaceTextToken(Result, '<Name>', GetDisplayName, TextHighlightColorTag);
  ReplaceTextToken(Result, '<Size>', IntToStr(Weight), TextHighlightColorTag);
  ReplaceTextToken(Result, '<Planet>', PlanetName, TextHighlightColorTag);
end;

function TSatellite.GetDescriptionText: WideString;
begin
  Result := LocalizedText('Items.Satellite.' + IntToStr(SatelliteTypeId) + '.Description');
end;

function TSatellite.GetBitmapResourceName: WideString;
begin
  if ConfigBlockName <> '' then
    Result := 'Bm.Items.' + GiResourceSuffix + ConfigBlockName
  else
    Result := 'Bm.Items.' + GiResourceSuffix + 'Satellite' + IntToStr(SatelliteTypeId) + '_';
end;

procedure TTreasureMap.Init(Planet: Pointer; Victim: Pointer);
begin
  ItemType := t_TreasureMap;
  Weight := 1;
  Cost := 1;
  OwnerId := (TObject(Victim) as TShip).OwnerId;
  if TObject(Victim) is TPirate then
    SourceShipName := (TObject(Victim) as TPirate).GetFullName(' ')
  else
    SourceShipName := (TObject(Victim) as TShip).GetFullName(' ');
  TargetPlanet := Planet;
  PreviewTablePage1 := BuildPreviewTable(1, Planet);
  PreviewTablePage2 := BuildPreviewTable(2, Planet);
  EquippedFlag := 0;
  Repair;
end;

procedure TTreasureMap.SaveToBuffer(Buffer: TBufEC);
begin
  inherited SaveToBuffer(Buffer);
  if TargetPlanet = nil then
    Buffer.AddDWord(0)
  else
    Buffer.AddDWord((TObject(TargetPlanet) as TPlanet).Id);
  Buffer.AddWideStringZ(SourceShipName);
  Buffer.AddWideStringZ(PreviewTablePage1);
  Buffer.AddWideStringZ(PreviewTablePage2);
end;

procedure TTreasureMap.LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy);
begin
  inherited LoadFromBuffer(Buffer, Galaxy);
  TargetPlanet := Pointer(Buffer.GetUInt32);
  SourceShipName := Buffer.ReadWideString;
  PreviewTablePage1 := Buffer.ReadWideString;
  PreviewTablePage2 := Buffer.ReadWideString;
end;

procedure TTreasureMap.ResolveLoadedReferences(Galaxy: TGalaxy);
begin
  inherited ResolveLoadedReferences(Galaxy);
  TargetPlanet := TObject(Galaxy.IdToPlanet(Cardinal(TargetPlanet))) as TPlanet;
end;

procedure TTreasureMap.ClearReferences;
begin
  inherited ClearReferences;
  TargetPlanet := nil;
end;

function TTreasureMap.GetDisplayName: WideString;
begin
  if NameOverride <> '' then
    Result := NameOverride
  else
    Result := LocalizedText('Items.TreasureMap.Name');
end;

function TTreasureMap.GetInfoText(ColorTag: WideString; Ship: Pointer): WideString;
begin
  Result := LocalizedText('Items.TreasureMap.Text') + ' ' + LocalizedText('Items.TreasureMap.Hint');
  ReplaceTextToken(Result, '<Planet>', GetTargetPlanetName, TextHighlightColorTag);
  ReplaceTextToken(Result, '<Ship>', SourceShipName, TextHighlightColorTag);
end;

function TTreasureMap.GetDescriptionText: WideString;
begin
  Result := LocalizedText('Items.TreasureMap.Description');
end;

function TTreasureMap.GetBitmapResourceName: WideString;
var
  Kind: Integer;
begin
  if OwnerId in [oiMaloc..oiHuman] then
    Kind := 1
  else
    Kind := 2;
  Result := 'Bm.ItemsUseless.' + GiResourceSuffix + 'TreasureMap' + IntToStr(Kind) + '_';
end;

function TTreasureMap.GetTargetPlanetName: WideString;
begin
  Result := (TObject(TargetPlanet) as TPlanet).Name;
end;

function TTreasureMap.BuildPreviewTable(PageIndex: Integer; Planet: Pointer): WideString;
var
  I, Number: Integer;
  Entry: PPlanetSurfaceLootEntry;
  Rows, Header, Caption, Rule: WideString;
  World: TPlanet;

  function ItemColorTag(
      Item: TItem
  ): WideString; { Nested helper of BuildPreviewTable; caller removes the unused static link. }
  begin
    if Item is TGoods then
      Result := GrayColorTag
    else if Item is TArtefact then
      Result := RedColorTag
    else if Item is TCistern then
      Result := GrayColorTag
    else if Item is TMicroModule then
      Result := MagentaColorTag
    else if Item is TEquipment then
      Result := GoldColorTag
    else
      Result := '';
  end;

begin
  Rule := WrapTextInColor(StringOfChar('-', TreasureMapRuleLengths[PageIndex]), GrayColorTag);
  Caption :=
      FormatText1(
          LocalizedColorText('FormGS.PlanetInfo'),
          TextHighlightColorTag,
          '<Planet>',
          (TObject(Planet) as TPlanet).Name
      );
  Header := Header + #13#10 + '<td=' + IntToStr(0) + '>' + '<align=left>' + Caption + '</align>';
  Header :=
      Header
          + '<td='
          + IntToStr(TreasureMapColumnPositions[PageIndex, 3] div 2)
          + '>'
          + '<align=center>'
          + WrapTextInColor(LocalizedText('Items.TreasureMap.Name'), GreenColorTag)
          + '</align>';
  Caption :=
      FormatText1(
          LocalizedColorText('FormGS.StarInfo'),
          TextHighlightColorTag,
          '<Star>',
          (TObject(Planet) as TPlanet).CurrentStar.Name
      );
  Header :=
      Header
          + '<td='
          + IntToStr(TreasureMapColumnPositions[PageIndex, 3])
          + '>'
          + '<align=right>'
          + WrapTextInColor(Caption, '')
          + '</align>';
  Header := Header + #13#10 + Rule + #13#10;
  Header :=
      Header
          + '<td='
          + IntToStr(TreasureMapColumnPositions[PageIndex, 0])
          + '>'
          + '<align=right>'
          + WrapTextInColor(LocalizedColorText('FormGS.ColumnNumber'), TextHighlightColorTag)
          + '</align>';
  Header :=
      Header
          + '<td='
          + IntToStr(TreasureMapColumnPositions[PageIndex, 1])
          + '>'
          + WrapTextInColor(LocalizedColorText('FormGS.ColumnName'), TextHighlightColorTag);
  Header :=
      Header
          + '<td='
          + IntToStr(TreasureMapColumnPositions[PageIndex, 2])
          + '>'
          + '<align=right>'
          + WrapTextInColor(LocalizedColorText('FormShip.StorageInfo.Size'), TextHighlightColorTag)
          + '</align>';
  Header :=
      Header
          + '<td='
          + IntToStr(TreasureMapColumnPositions[PageIndex, 3])
          + '>'
          + '<align=right>'
          + WrapTextInColor(LocalizedColorText('FormShip.StorageInfo.Cost'), TextHighlightColorTag)
          + '</align>';
  Header := Header + #13#10 + Rule;
  if Planet <> nil then
    if TObject(Planet) is TPlanet then
    begin
      Rows := '';
      Number := 1;
      World := TObject(Planet) as TPlanet;
      if World.SurfaceLootEntries <> nil then
      begin
        for I := 0 to World.SurfaceLootEntries.Count - 1 do
        begin
          Entry := World.SurfaceLootEntries[I];
          if Entry.Item <> nil then
            if GetPlayer.CanAccessSurfaceLootItem(Entry.Item)
                and not (Entry.Item is TGoods)
                and not (Entry.Item is TCistern) then
            begin
              Rows := Rows + #13#10;
              Rows :=
                  Rows
                      + '<td='
                      + IntToStr(TreasureMapColumnPositions[PageIndex, 0])
                      + '>'
                      + '<align=right>'
                      + WrapTextInColor(IntToStr(Number), '')
                      + '</align>';
              Rows :=
                  Rows
                      + '<td='
                      + IntToStr(TreasureMapColumnPositions[PageIndex, 1])
                      + '>'
                      + ''
                      + WrapTextInColor(Entry.Item.GetDisplayName, ItemColorTag(Entry.Item))
                      + '';
              Rows :=
                  Rows
                      + '<td='
                      + IntToStr(TreasureMapColumnPositions[PageIndex, 2])
                      + '>'
                      + '<align=right>'
                      + WrapTextInColor(IntToStr(Entry.Item.Weight), GreenColorTag)
                      + '</align>';
              Rows :=
                  Rows
                      + '<td='
                      + IntToStr(TreasureMapColumnPositions[PageIndex, 3])
                      + '>'
                      + '<align=right>'
                      + WrapTextInColor(IntToStr(Entry.Item.Cost), CyanColorTag)
                      + '</align>';
              Inc(Number);
            end;
        end;
        Result := Header + Rows;
      end;
    end;
end;

procedure TMicroModule.Init(ModuleIndex: Integer);
begin
  ItemType := t_MicroModule;
  OwnerId := oiUninhabited;
  MicroModuleIndex := ModuleIndex + 1;
  Repair;
  Weight := 1;
  Cost :=
      RoundAndTruncateToTens(
          100
              * Galaxy.ComputeScaledSmallMoney(oiHuman)
              / (MicroModuleTemplates[MicroModuleIndex - 1].Priority + 20)
              * SeededRandomFloatRange(Id * 1367, 0.5, 1.2)
      );
  Cost :=
      RoundAndTruncateToTens(
          SeededRandomIntRange(150, 200, Id * 13567157)
                  * RemapClamped(Galaxy.TechLevel, 4, 8, 1, 3)
                  * GalaxyDifficultyTuning[Galaxy.DifficultyLevels[7]].QuestMoneyFactor
              + Cost
      );
end;

procedure TMicroModule.SaveToBuffer(Buffer: TBufEC);
begin
  inherited SaveToBuffer(Buffer);
end;

procedure TMicroModule.LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy);
begin
  inherited LoadFromBuffer(Buffer, Galaxy);
  if LoadedSaveVersion < 113 then
    Buffer.GetInt32;
  if MicroModuleIndex = 0 then
    MicroModuleIndex := 1;
end;

function TMicroModule.GetDisplayName: WideString;
var
  Text: WideString;
begin
  if NameOverride <> '' then
    Result := NameOverride
  else
  begin
    Result := MicroModuleTemplates[MicroModuleIndex - 1].NamePrefix;
    if Result = '' then
      Result := WrapTextInColor(LookupLocalizedTextOrEmpty('MicroModuls.Name'), '');
    Text := MicroModuleTemplates[MicroModuleIndex - 1].Name;
    if FindTextOffsetW(Text, '"') < 0 then
      Text := '"' + Text + '"';
    Result :=
        Result + ' ' + WrapTextInColor(Text, GetMicroModuleNameColorTag(MicroModuleIndex - 1));
  end;
end;

function TMicroModule.GetPlainName: WideString;
var
  Text: WideString;
begin
  if NameOverride <> '' then
    Result := NameOverride
  else
  begin
    Result := MicroModuleTemplates[MicroModuleIndex - 1].NamePrefix;
    if Result = '' then
      Result := WrapTextInColor(LookupLocalizedTextOrEmpty('MicroModuls.Name'), '');
    Text := MicroModuleTemplates[MicroModuleIndex - 1].Name;
    if FindTextOffsetW(Text, '"') < 0 then
      Text := '"' + Text + '"';
    Result := Result + ' ' + Text;
  end;
end;

function TMicroModule.GetInfoText(ColorTag: WideString; Ship: Pointer): WideString;
begin
  Result := GetMicroModuleInfoText(MicroModuleIndex - 1, ColorTag);
end;

function GetMicroModuleInfoText(ModuleIndex: Integer; ColorTag: WideString): WideString;
var
  Index, Value, Fraction: Integer;
  Text: WideString;
  Kind: TEquipmentBonusKind;
begin
  Index := ModuleIndex + 1;
  Result :=
      LocalizedColorText('MicroModuls.' + MicroModuleTemplates[ModuleIndex].ConfigName + '.Text');
  for Kind := Low(TEquipmentBonusKind) to High(TEquipmentBonusKind) do
    if Kind in [bonExtraAkrinEff..bonExtraAkrinPenalty] then
    begin
      Value := MicroModuleTemplates[Index - 1].StatBonuses[Kind];
      if Value = 0 then
        ReplaceTextToken(Result, '<' + EquipmentBonusNames[Kind] + '>', '--', ColorTag)
      else
      begin
        if Value > 0 then
          Text := '+'
        else
          Text := '-';
        Value := Abs(Value);
        Fraction := Value mod 100;
        Value := Value div 100;
        if Fraction <> 0 then
          Text := Text + IntToStr(Value) + '.' + IntToStr(Fraction)
        else
          Text := Text + IntToStr(Value);
        ReplaceTextToken(Result, '<' + EquipmentBonusNames[Kind] + '>', Text, ColorTag);
      end;
    end
    else
    begin
      Value := MicroModuleTemplates[Index - 1].StatBonuses[Kind];
      if Value > 0 then
        ReplaceTextToken(
            Result,
            '<' + EquipmentBonusNames[Kind] + '>',
            '+' + IntToStr(Value),
            ColorTag
        )
      else if Value < 0 then
        ReplaceTextToken(Result, '<' + EquipmentBonusNames[Kind] + '>', IntToStr(Value), ColorTag)
      else
        ReplaceTextToken(Result, '<' + EquipmentBonusNames[Kind] + '>', '--', ColorTag);
    end;
end;

function TMicroModule.GetDescriptionText: WideString;
begin
  Result := '';
end;

function TMicroModule.GetBitmapResourceName: WideString;
begin
  if ConfigBlockName <> '' then
    Result := 'Bm.Items.' + GiResourceSuffix + ConfigBlockName
  else
    Result := GetMicroModuleBitmapResourceName(MicroModuleIndex - 1);
end;

function GetMicroModulePriorityColorTier(ModuleIndex: Integer): Byte;
begin
  case MicroModuleTemplates[ModuleIndex].Priority of
    0..30: Result := 3;
    31..69: Result := 2;
    70..100: Result := 1;
  else
    Result := 3;
  end;
end;

function GetMicroModuleNameColorTag(ModuleIndex: Integer): WideString;
begin
  if MicroModuleTemplates[ModuleIndex].Color <> '' then
    Result := '<color=' + MicroModuleTemplates[ModuleIndex].Color + '>'
  else
    case GetMicroModulePriorityColorTier(ModuleIndex) of
      2: Result := TextHighlightColorTag;
      3: Result := RedColorTag;
    else
      Result := MicroModuleHighPriorityColorTag;
    end;
end;

function GetMicroModuleTextColorTag(ModuleIndex: Integer): WideString;
begin
  if MicroModuleTemplates[ModuleIndex].Color <> '' then
    Result := '<color=' + MicroModuleTemplates[ModuleIndex].Color + '>'
  else
    Result := EquipmentBonusColorTag;
end;

function GetMicroModuleBitmapResourceName(ModuleIndex: Integer): WideString;
begin
  if (ModuleIndex >= 0) and (MicroModuleTemplates[ModuleIndex].KindGraph <> '') then
    Result :=
        'Bm.Micromoduls.'
            + GiResourceSuffix
            + 'MM'
            + MicroModuleTemplates[ModuleIndex].KindGraph
            + '_'
  else
    Result :=
        'Bm.Micromoduls.'
            + GiResourceSuffix
            + 'MM'
            + IntToStr(GetMicroModulePriorityColorTier(ModuleIndex))
            + '_';
end;

function ApplyMicroModule(ModuleIndex: Integer; Item: TEquipment): Boolean;
var
  BonusKind: TEquipmentBonusKind;
begin
  if (ModuleIndex = -1) or (Item = nil) then
  begin
    Result := False;
    Exit;
  end;
  Result := True;
  Item.MicroModuleIndex := ModuleIndex + 1;
  Item.Weight :=
      Round(
          Max(1, Item.Weight / 100 * MicroModuleTemplates[Item.MicroModuleIndex - 1].SizePercent)
      );
  Item.Cost :=
      Min(
          MaxMonetaryValue,
          Round(
              Max(1, Item.Cost / 100 * MicroModuleTemplates[Item.MicroModuleIndex - 1].CostPercent)
          )
      );
  case Item.ItemType of
    t_Hull:
    begin
      Inc(
          (Item as THull).Armor,
          MicroModuleTemplates[Item.MicroModuleIndex - 1].StatBonuses[bonHull]
      );
      (Item as THull).HullPoints := Min(Item.Weight, (Item as THull).HullPoints);
    end;
    t_FuelTanks:
      Inc(
          (Item as TFuelTanks).Capacity,
          MicroModuleTemplates[Item.MicroModuleIndex - 1].StatBonuses[bonFuel]
      );
    t_Engine:
    begin
      Inc(
          (Item as TEngine).Speed,
          MicroModuleTemplates[Item.MicroModuleIndex - 1].StatBonuses[bonSpeed]
      );
      Inc(
          (Item as TEngine).JumpRange,
          MicroModuleTemplates[Item.MicroModuleIndex - 1].StatBonuses[bonJump]
      );
    end;
    t_Radar:
      Inc(
          (Item as TRadar).Range,
          MicroModuleTemplates[Item.MicroModuleIndex - 1].StatBonuses[bonRadar]
      );
    t_Scaner:
      Inc(
          (Item as TScaner).ScanPower,
          MicroModuleTemplates[Item.MicroModuleIndex - 1].StatBonuses[bonScan]
      );
    t_RepairRobot:
      Inc(
          (Item as TRepairRobot).RepairPoints,
          MicroModuleTemplates[Item.MicroModuleIndex - 1].StatBonuses[bonDroid]
      );
    t_CargoHook:
    begin
      Inc(
          (Item as TCargoHook).PickupPower,
          MicroModuleTemplates[Item.MicroModuleIndex - 1].StatBonuses[bonHook]
      );
      Inc(
          (Item as TCargoHook).Range,
          MicroModuleTemplates[Item.MicroModuleIndex - 1].StatBonuses[bonHookRadius]
      );
      (Item as TCargoHook).MinPullSpeed :=
          (Item as TCargoHook).MinPullSpeed
              + MicroModuleTemplates[Item.MicroModuleIndex - 1].StatBonuses[bonHookMinSpeed];
      (Item as TCargoHook).MaxPullSpeed :=
          (Item as TCargoHook).MaxPullSpeed
              + MicroModuleTemplates[Item.MicroModuleIndex - 1].StatBonuses[bonHookMaxSpeed];
    end;
    t_DefGenerator:
      if MicroModuleTemplates[Item.MicroModuleIndex - 1].StatBonuses[bonDef] <> 0 then
        (Item as TDefGenerator).DamageFactor :=
            (Item as TDefGenerator).DamageFactor
                - (1
                    - DefensePercentToDamageFactor(
                        MicroModuleTemplates[Item.MicroModuleIndex - 1].StatBonuses[bonDef]));
  else
    if Item.ItemType in [t_IndustrialLaser..t_CustomWeapon] then
    begin
      BonusKind :=
          WeaponDamageClasses[ClassifyWeaponDamageFlags(TWeapon(Item).GetWeaponInfo.DamageFlags)]
              .BonusKind;
      Inc(
          (Item as TWeapon).MaxDamage,
          MicroModuleTemplates[Item.MicroModuleIndex - 1].StatBonuses[BonusKind]
      );
      Inc(
          (Item as TWeapon).Range,
          MicroModuleTemplates[Item.MicroModuleIndex - 1].StatBonuses[bonWRadius]
      );
      if TWeapon(Item).GetWeaponInfo.ShotType in [wstTorpedo..wstRocket] then
        Inc(
            (Item as TWeapon).AmmoCapacity,
            MicroModuleTemplates[Item.MicroModuleIndex - 1].StatBonuses[bonAmmo]
        );
    end
    else
      Exception.Create(
          'Микромодуль в оборудование хотели вставить, в которое вставить микромодуль нельзя!'
      ); // Native allocates without raising.
  end;
end;

procedure RemoveMicroModule(Item: TEquipment);
var
  BonusKind: TEquipmentBonusKind;
begin
  if (Item = nil) or (Item.MicroModuleIndex = 0) then
    Exit;
  Item.Weight :=
      Round(
          Max(1, Item.Weight / MicroModuleTemplates[Item.MicroModuleIndex - 1].SizePercent * 100)
      );
  Item.Cost :=
      Round(Max(1, Item.Cost / MicroModuleTemplates[Item.MicroModuleIndex - 1].CostPercent * 100));
  case Item.ItemType of
    t_Hull:
    begin
      Dec(
          (Item as THull).Armor,
          MicroModuleTemplates[Item.MicroModuleIndex - 1].StatBonuses[bonHull]
      );
      (Item as THull).HullPoints := Min(Item.Weight, (Item as THull).HullPoints);
    end;
    t_FuelTanks:
      Dec(
          (Item as TFuelTanks).Capacity,
          MicroModuleTemplates[Item.MicroModuleIndex - 1].StatBonuses[bonFuel]
      );
    t_Engine:
    begin
      Dec(
          (Item as TEngine).Speed,
          MicroModuleTemplates[Item.MicroModuleIndex - 1].StatBonuses[bonSpeed]
      );
      Dec(
          (Item as TEngine).JumpRange,
          MicroModuleTemplates[Item.MicroModuleIndex - 1].StatBonuses[bonJump]
      );
    end;
    t_Radar:
      Dec(
          (Item as TRadar).Range,
          MicroModuleTemplates[Item.MicroModuleIndex - 1].StatBonuses[bonRadar]
      );
    t_Scaner:
      Dec(
          (Item as TScaner).ScanPower,
          MicroModuleTemplates[Item.MicroModuleIndex - 1].StatBonuses[bonScan]
      );
    t_RepairRobot:
      Dec(
          (Item as TRepairRobot).RepairPoints,
          MicroModuleTemplates[Item.MicroModuleIndex - 1].StatBonuses[bonDroid]
      );
    t_CargoHook:
    begin
      Dec(
          (Item as TCargoHook).PickupPower,
          MicroModuleTemplates[Item.MicroModuleIndex - 1].StatBonuses[bonHook]
      );
      Dec(
          (Item as TCargoHook).Range,
          MicroModuleTemplates[Item.MicroModuleIndex - 1].StatBonuses[bonHookRadius]
      );
      (Item as TCargoHook).MinPullSpeed :=
          (Item as TCargoHook).MinPullSpeed
              - MicroModuleTemplates[Item.MicroModuleIndex - 1].StatBonuses[bonHookMinSpeed];
      (Item as TCargoHook).MaxPullSpeed :=
          (Item as TCargoHook).MaxPullSpeed
              - MicroModuleTemplates[Item.MicroModuleIndex - 1].StatBonuses[bonHookMaxSpeed];
    end;
    t_DefGenerator:
      if MicroModuleTemplates[Item.MicroModuleIndex - 1].StatBonuses[bonDef] <> 0 then
        (Item as TDefGenerator).DamageFactor :=
            (Item as TDefGenerator).DamageFactor
                + (1
                    - DefensePercentToDamageFactor(
                        MicroModuleTemplates[Item.MicroModuleIndex - 1].StatBonuses[bonDef]));
  else
    if Item.ItemType in [t_IndustrialLaser..t_CustomWeapon] then
    begin
      BonusKind :=
          WeaponDamageClasses[ClassifyWeaponDamageFlags(TWeapon(Item).GetWeaponInfo.DamageFlags)]
              .BonusKind;
      Dec(
          (Item as TWeapon).MaxDamage,
          MicroModuleTemplates[Item.MicroModuleIndex - 1].StatBonuses[BonusKind]
      );
      Dec(
          (Item as TWeapon).Range,
          MicroModuleTemplates[Item.MicroModuleIndex - 1].StatBonuses[bonWRadius]
      );
      if TWeapon(Item).GetWeaponInfo.ShotType in [wstTorpedo..wstRocket] then
        Dec(
            (Item as TWeapon).AmmoCapacity,
            MicroModuleTemplates[Item.MicroModuleIndex - 1].StatBonuses[bonAmmo]
        );
    end;
  end;
  Item.MicroModuleIndex := 0;
end;

procedure ApplySpecialMicroModule(ModuleIndex: Integer; Item: TEquipment);
var
  BonusKind: TEquipmentBonusKind;
begin
  if (ModuleIndex = -1) or (Item = nil) or (Item.SpecialModuleIndex <> 0) then
  begin
    RaiseWideMessage('SpecialToEquipment');
    Exit;
  end;
  Item.SpecialModuleIndex := ModuleIndex + 1;
  Item.Weight := Round(Max(1, Item.Weight / 100 * MicroModuleTemplates[ModuleIndex].SizePercent));
  Item.Cost :=
      Min(
          MaxMonetaryValue,
          RoundAndTruncateToTens(
              Max(10, Item.Cost / 100 * MicroModuleTemplates[ModuleIndex].CostPercent)
          )
      );
  if Item.ItemType = t_Hull then
  begin
    (Item as THull).HullType := htSpecial;
    (Item as THull).HullPoints := Item.Weight;
    if (Item.Cost < 0) or (Item.Cost > MaxMonetaryValue) then
      Item.Cost := MaxMonetaryValue;
  end;
  if Item.ItemType in [t_IndustrialLaser..t_CustomWeapon] then
  begin
    BonusKind :=
        WeaponDamageClasses[ClassifyWeaponDamageFlags(TWeapon(Item).GetWeaponInfo.DamageFlags)]
            .BonusKind;
    Inc((Item as TWeapon).MaxDamage, MicroModuleTemplates[ModuleIndex].StatBonuses[BonusKind]);
    Inc((Item as TWeapon).Range, MicroModuleTemplates[ModuleIndex].StatBonuses[bonWRadius]);
    if TWeapon(Item).GetWeaponInfo.ShotType in [wstTorpedo..wstRocket] then
      Inc((Item as TWeapon).AmmoCapacity, MicroModuleTemplates[ModuleIndex].StatBonuses[bonAmmo]);
  end;
  if MicroModuleTemplates[ModuleIndex].CustomFaction <> '' then
    Item.CustomFaction := MicroModuleTemplates[ModuleIndex].CustomFaction;
end;

procedure RemoveSpecialMicroModule(Item: TEquipment);
var
  BonusKind: TEquipmentBonusKind;
begin
  if (Item = nil) or (Item.SpecialModuleIndex = 0) then
    Exit;
  Item.Weight :=
      Round(
          Max(1, Item.Weight * 100 / MicroModuleTemplates[Item.SpecialModuleIndex - 1].SizePercent)
      );
  Item.Cost :=
      Round(
          Max(1, Item.Cost * 100 / MicroModuleTemplates[Item.SpecialModuleIndex - 1].CostPercent)
      );
  if Item.ItemType = t_Hull then
  begin
    (Item as THull).HullPoints := Min(Item.Weight, (Item as THull).HullPoints);
    if (Item.Cost < 0) or (Item.Cost > MaxMonetaryValue) then
      Item.Cost := MaxMonetaryValue;
  end;
  if Item.ItemType in [t_IndustrialLaser..t_CustomWeapon] then
  begin
    BonusKind :=
        WeaponDamageClasses[ClassifyWeaponDamageFlags(TWeapon(Item).GetWeaponInfo.DamageFlags)]
            .BonusKind;
    Dec(
        (Item as TWeapon).MaxDamage,
        MicroModuleTemplates[Item.SpecialModuleIndex - 1].StatBonuses[BonusKind]
    );
    Dec(
        (Item as TWeapon).Range,
        MicroModuleTemplates[Item.SpecialModuleIndex - 1].StatBonuses[bonWRadius]
    );
    if TWeapon(Item).GetWeaponInfo.ShotType in [wstTorpedo..wstRocket] then
      Dec(
          (Item as TWeapon).AmmoCapacity,
          MicroModuleTemplates[Item.SpecialModuleIndex - 1].StatBonuses[bonAmmo]
      );
  end;
  if (Item.CustomFaction <> '')
      and (MicroModuleTemplates[Item.SpecialModuleIndex - 1].CustomFaction
          = Item.CustomFaction) then
    Item.CustomFaction := '';
  Item.SpecialModuleIndex := 0;
end;

function TMicroModule.CalculateNodeExchangeValue(
    LowPriorityOfferCost,
    MediumPriorityOfferCost: Integer
): Integer;
begin
  Result := 0;
  if (MicroModuleTemplates[MicroModuleIndex - 1].Priority >= 0)
      and (MicroModuleTemplates[MicroModuleIndex - 1].Priority <= 30) then
  begin
    Result :=
        Round(RemapClamped(MicroModuleTemplates[MicroModuleIndex - 1].Priority, 0, 100, 2000, 100));
    Result :=
        SeededRandomIntRange(
            Round(Result * 0.8),
            Round(Result * 1.2),
            Result + GetPlayer.DockedTo.Id
        );
    Result := RoundAndTruncateToHundreds(Result / 1.5);
  end;
  if (MicroModuleTemplates[MicroModuleIndex - 1].Priority >= 31)
      and (MicroModuleTemplates[MicroModuleIndex - 1].Priority <= 69) then
  begin
    Result :=
        Round(RemapClamped(MicroModuleTemplates[MicroModuleIndex - 1].Priority, 0, 100, 2000, 100));
    Result :=
        SeededRandomIntRange(
            Round(Result * 0.8),
            Round(Result * 1.2),
            Result + GetPlayer.DockedTo.Id
        );
    Result := RoundAndTruncateToHundreds(Min(LowPriorityOfferCost div 2, Result / 1.5));
  end;
  if (MicroModuleTemplates[MicroModuleIndex - 1].Priority >= 70)
      and (MicroModuleTemplates[MicroModuleIndex - 1].Priority <= 100) then
  begin
    Result :=
        Round(RemapClamped(MicroModuleTemplates[MicroModuleIndex - 1].Priority, 0, 100, 2000, 100));
    Result :=
        SeededRandomIntRange(
            Round(Result * 0.8),
            Round(Result * 1.2),
            Result + GetPlayer.DockedTo.Id
        );
    Result := RoundAndTruncateToTens(Min(MediumPriorityOfferCost div 2, Result / 1.5));
  end;
  Result := Max(5, Round(Result * 0.3));
end;

function TMicroModule.GetHighlightedName: WideString;
begin
  Result := WrapTextInColor(MicroModuleTemplates[MicroModuleIndex - 1].Name, TextHighlightColorTag);
end;

function TMicroModule.CanInstallOn(Item: TEquipment): Boolean;
begin
  Result := False;
  if Item.MicroModuleIndex <> 0 then
    Exit;
  if (Item.SpecialModuleIndex <> 0)
      and MicroModuleTemplates[Item.SpecialModuleIndex - 1].BlocksMicroModuleSlot then
    Exit;
  if (MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonExtraAkrinEff] <> 0)
      and (Item.SpecialModuleIndex = 0) then
    Exit;
  if (MicroModuleTemplates[MicroModuleIndex - 1].StatBonuses[bonExtraAkrinPenalty] <> 0)
      and (Item.SpecialModuleIndex = 0) then
    Exit;
  if Item is TWeapon then
    Result := IsBonusCompatibleWithWeapon(MicroModuleIndex - 1, TWeapon(Item))
  else if Item is THull then
    Result := IsBonusCompatibleWithHull(MicroModuleIndex - 1, THull(Item))
  else
    Result := IsBonusCompatibleWithEquipment(MicroModuleIndex - 1, Item);
end;

function CanInstallMicroModule(ModuleIndex: Integer; Item: TEquipment): Boolean;
begin
  Result := False;
  if Item.MicroModuleIndex <> 0 then
    Exit;
  if (Item.SpecialModuleIndex <> 0)
      and MicroModuleTemplates[Item.SpecialModuleIndex - 1].BlocksMicroModuleSlot then
    Exit;
  if (MicroModuleTemplates[ModuleIndex].StatBonuses[bonExtraAkrinEff] <> 0)
      and (Item.SpecialModuleIndex = 0) then
    Exit;
  if (MicroModuleTemplates[ModuleIndex].StatBonuses[bonExtraAkrinPenalty] <> 0)
      and (Item.SpecialModuleIndex = 0) then
    Exit;
  if MicroModuleTemplates[ModuleIndex].SpecialOnly then
    Exit;
  if Item is TWeapon then
    Result := IsBonusCompatibleWithWeapon(ModuleIndex, TWeapon(Item))
  else if Item is THull then
    Result := IsBonusCompatibleWithHull(ModuleIndex, THull(Item))
  else
    Result := IsBonusCompatibleWithEquipment(ModuleIndex, Item);
end;

function IsBonusCompatibleWithEquipment(ModuleIndex: Integer; Item: TEquipment): Boolean;
begin
  Result := False;
  if not (Byte(Item.ItemType) in MicroModuleTemplates[ModuleIndex].AllowedItemTypes) then
    Exit;
  if Item.CustomFaction <> '' then
  begin
    if Pos(
            '<' + Item.CustomFaction + '>',
            MicroModuleTemplates[ModuleIndex].AllowedCustomHullFactions)
        > 0 then
    begin
      Result := True;
      Exit;
    end;
    if (Item.OwnerId = oiUninhabited)
        or ((Item.OwnerId = oiDominator)
            and (MicroModuleTemplates[ModuleIndex].AllowedDominatorSeriesMask
                <> [dsBlazer..dsTerron])) then
      Exit;
  end;
  Result := Item.OwnerId in MicroModuleTemplates[ModuleIndex].AllowedHullOwnerMask;
  if (Item.OwnerId = oiDominator)
      and not (Item.DominatorSeries
          in MicroModuleTemplates[ModuleIndex].AllowedDominatorSeriesMask) then
    Result := False;
end;

function IsBonusCompatibleWithHull(ModuleIndex: Integer; Hull: THull): Boolean;
begin
  Result := False;
  if not (Ord(t_Hull) in MicroModuleTemplates[ModuleIndex].AllowedItemTypes) then
    Exit;
  if Hull.CustomFaction <> '' then
  begin
    if Pos(
            '<' + Hull.CustomFaction + '>',
            MicroModuleTemplates[ModuleIndex].AllowedCustomHullFactions)
        > 0 then
    begin
      Result := True;
      Exit;
    end;
    if (Hull.OwnerId = oiUninhabited)
        or ((Hull.OwnerId = oiDominator)
            and (MicroModuleTemplates[ModuleIndex].AllowedDominatorSeriesMask
                <> [dsBlazer..dsTerron])) then
      Exit;
  end;
  if ((Hull.OwnerId in MicroModuleTemplates[ModuleIndex].AllowedHullOwnerMask)
          or (Hull.PirateBuilt
              and (oiPirate in MicroModuleTemplates[ModuleIndex].AllowedHullOwnerMask)))
      and ((Hull.OwnerId <> oiDominator)
          or (Hull.DominatorSeries
              in MicroModuleTemplates[ModuleIndex].AllowedDominatorSeriesMask)) then
    Result := True;
end;

function IsBonusCompatibleWithWeapon(ModuleIndex: Integer; Weapon: TWeapon): Boolean;
var
  AllowedTypes: WideString;
  Info: PWeaponInfo;
begin
  Result := False;
  if ((Weapon.CustomFaction <> '')
          and (Pos(
                  '<' + Weapon.CustomFaction + '>',
                  MicroModuleTemplates[ModuleIndex].AllowedCustomHullFactions)
              > 0))
      or ((Weapon.OwnerId in MicroModuleTemplates[ModuleIndex].AllowedHullOwnerMask)
          and ((Weapon.OwnerId <> oiDominator)
              or (Weapon.DominatorSeries
                  in MicroModuleTemplates[ModuleIndex].AllowedDominatorSeriesMask))
          and ((Weapon.CustomFaction = '')
              or ((Weapon.OwnerId <> oiUninhabited)
                  and ((Weapon.OwnerId <> oiDominator)
                      or (MicroModuleTemplates[ModuleIndex].AllowedDominatorSeriesMask
                          = [dsBlazer..dsTerron]))))) then
  begin
    if Weapon.ItemType in [t_IndustrialLaser..t_Lirecron] then
    begin
      if Byte(Weapon.ItemType) in MicroModuleTemplates[ModuleIndex].AllowedItemTypes then
        Result := True;
    end
    else if Weapon.ItemType = t_CustomWeapon then
    begin
      Info := Weapon.GetWeaponInfo;
      AllowedTypes := MicroModuleTemplates[ModuleIndex].AllowedCustomWeaponTypes;
      if AllowedTypes = 'Any' then
        Result := True
      else if (dkMissile in Info.DamageFlags) and (Pos('<WMissile>', AllowedTypes) > 0) then
        Result := True
      else if (dkSplinter in Info.DamageFlags) and (Pos('<WSplinter>', AllowedTypes) > 0) then
        Result := True
      else if (dkEnergy in Info.DamageFlags) and (Pos('<WEnergy>', AllowedTypes) > 0) then
        Result := True
      else if Pos('<' + Info.ConfigName + '>', AllowedTypes) > 0 then
        Result := True;
    end
    else
      Result := True;
  end;
end;

function CreateConfiguredArtefactByItemType(ItemType: TItemType; Owner: TOwnerId): TArtefact;
var
  Item: TArtefact;
begin
  Result := nil;
  if ItemType in [t_ArtefactHull..t_ArtFastRacks] then
  begin
    Item := TArtefact(CreateItemByType(ItemType));
    if ItemType = t_ArtefactTransmitter then
      TArtefactTransmitter(Item).InitTransmitter(Owner)
    else if ItemType = t_ArtefactTranclucator then
      TArtefactTranclucator(Item).InitTranclucator(Owner, nil, nil)
    else
      Item.Init(Owner, ItemType);
    Result := Item;
  end;
end;

function CreateRandomLootItem(
    Pool: TItemLootPool;
    Owner: TOwnerId;
    Seed: Cardinal
): TEquipmentWithActCode;
var
  Index, Count: Integer;
begin
  Count := Length(ArtefactLootPools[Ord(Pool)]);
  Index :=
      Count + Length(CustomArtefactLootPools[Ord(Pool)]) + Length(UselessItemLootPools[Ord(Pool)]);
  Index := SeededRandomIntRange(0, Index - 1, Seed);
  if Index < Length(ArtefactLootPools[Ord(Pool)]) then
    Result :=
        TObject(CreateConfiguredArtefactByItemType(ArtefactLootPools[Ord(Pool)][Index], Owner))
            as TEquipmentWithActCode
  else
  begin
    Dec(Index, Count);
    if Index < Length(CustomArtefactLootPools[Ord(Pool)]) then
    begin
      Result := TArtefactCustom.Create;
      Result.ConfigBlockName := CustomArtefactLootPools[Ord(Pool)][Index];
      TArtefactCustom(Result).LoadConfig(True);
      TArtefactCustom(Result).Data[1] := 0;
      TArtefactCustom(Result).Data[2] := 0;
      TArtefactCustom(Result).Data[3] := 0;
      TArtefactCustom(Result).Init(Owner, Result.ItemType);
    end
    else
    begin
      Dec(Index, Length(CustomArtefactLootPools[Ord(Pool)]));
      Result := TUselessItem.Create;
      TUselessItem(Result).Init(UselessItemLootPools[Ord(Pool)][Index], dsBlazer, 0, True);
      Result.OwnerId := Owner;
    end;
  end;
end;

constructor TArtefact.Create;
begin
  inherited Create;
  DisplayAsArtefact := True;
  Repair;
end;

destructor TArtefact.Destroy;
begin
  if (Galaxy <> nil) and not Galaxy.Destroying and (GetPlayer <> nil) then
    RunItemConfigActionCode(Self, satOnItemDestroy, nil, nil, nil, 0);
  inherited Destroy;
end;

procedure TArtefact.LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy);
begin
  inherited LoadFromBuffer(Buffer, Galaxy);
  if not (ItemType
      in [
          t_Artefact,
          t_ArtefactHull..t_ArtefactAntigrav,
          t_ArtDefToEnergy..t_ArtGiperJump,
          t_ArtBio..t_ArtFastRacks]) then
    Repair;
end;

procedure TArtefact.Init(Owner: TOwnerId; ItemType: TItemType);
var
  MinWeightScale, MaxWeightScale, MinCostScale, MaxCostScale: Single;
  MinExtraWeight, MaxExtraWeight, MinCost, MaxCost: Integer;
begin
  Self.ItemType := ItemType;
  OwnerId := Owner;
  if not (Self.ItemType in [t_Artefact..t_Artefact2]) then
    Weight := GetAverageItemSize(Self.ItemType);
  case ItemType of
    t_ArtefactHull:
    begin
      MinExtraWeight := 1;
      MaxExtraWeight := 5;
      MinWeightScale := 1;
      MaxWeightScale := 2;
      MinCostScale := 1;
      MaxCostScale := 3;
      MinCost := 1500;
      MaxCost := 3000;
    end;
    t_ArtefactFuel:
    begin
      MinExtraWeight := 1;
      MaxExtraWeight := 5;
      MinWeightScale := 1;
      MaxWeightScale := 2;
      MinCostScale := 1;
      MaxCostScale := 3;
      MinCost := 1500;
      MaxCost := 3000;
    end;
    t_ArtefactSpeed:
    begin
      MinExtraWeight := 1;
      MaxExtraWeight := 5;
      MinWeightScale := 1;
      MaxWeightScale := 2;
      MinCostScale := 1;
      MaxCostScale := 3;
      MinCost := 2000;
      MaxCost := 3000;
    end;
    t_ArtefactPower:
    begin
      MinExtraWeight := 1;
      MaxExtraWeight := 5;
      MinWeightScale := 1;
      MaxWeightScale := 2;
      MinCostScale := 1;
      MaxCostScale := 3;
      MinCost := 1000;
      MaxCost := 2000;
    end;
    t_ArtefactRadar:
    begin
      MinExtraWeight := 1;
      MaxExtraWeight := 3;
      MinWeightScale := 1;
      MaxWeightScale := 2;
      MinCostScale := 1;
      MaxCostScale := 3;
      MinCost := 1000;
      MaxCost := 1500;
    end;
    t_ArtefactScaner:
    begin
      MinExtraWeight := 1;
      MaxExtraWeight := 2;
      MinWeightScale := 1;
      MaxWeightScale := 2;
      MinCostScale := 1;
      MaxCostScale := 3;
      MinCost := 500;
      MaxCost := 1000;
    end;
    t_ArtefactDroid:
    begin
      MinExtraWeight := 1;
      MaxExtraWeight := 4;
      MinWeightScale := 1;
      MaxWeightScale := 2;
      MinCostScale := 1;
      MaxCostScale := 3;
      MinCost := 1500;
      MaxCost := 3000;
    end;
    t_ArtefactNano:
    begin
      MinExtraWeight := 1;
      MaxExtraWeight := 4;
      MinWeightScale := 1;
      MaxWeightScale := 2;
      MinCostScale := 1;
      MaxCostScale := 2;
      MinCost := 2000;
      MaxCost := 4000;
    end;
    t_ArtefactHook:
    begin
      MinExtraWeight := 1;
      MaxExtraWeight := 3;
      MinWeightScale := 1;
      MaxWeightScale := 2;
      MinCostScale := 1;
      MaxCostScale := 3;
      MinCost := 500;
      MaxCost := 1000;
    end;
    t_ArtefactDef:
    begin
      MinExtraWeight := 1;
      MaxExtraWeight := 5;
      MinWeightScale := 1;
      MaxWeightScale := 2;
      MinCostScale := 1;
      MaxCostScale := 3;
      MinCost := 1500;
      MaxCost := 2500;
    end;
    t_ArtefactAnalyzer:
    begin
      MinExtraWeight := 1;
      MaxExtraWeight := 2;
      MinWeightScale := 1;
      MaxWeightScale := 2;
      MinCostScale := 1;
      MaxCostScale := 2;
      MinCost := 500;
      MaxCost := 1000;
    end;
    t_ArtefactMiniExpl:
    begin
      MinExtraWeight := 1;
      MaxExtraWeight := 3;
      MinWeightScale := 1;
      MaxWeightScale := 2;
      MinCostScale := 1;
      MaxCostScale := 2;
      MinCost := 1500;
      MaxCost := 3000;
    end;
    t_ArtefactAntigrav:
    begin
      MinExtraWeight := 1;
      MaxExtraWeight := 3;
      MinWeightScale := 1;
      MaxWeightScale := 3;
      MinCostScale := 1;
      MaxCostScale := 3;
      MinCost := 1000;
      MaxCost := 2500;
    end;
    t_ArtefactTransmitter:
    begin
      MinExtraWeight := 1;
      MaxExtraWeight := 2;
      MinWeightScale := 1;
      MaxWeightScale := 3;
      MinCostScale := 1;
      MaxCostScale := 3;
      MinCost := 500;
      MaxCost := 1500;
    end;
    t_ArtefactBomb:
    begin
      MinExtraWeight := 1;
      MaxExtraWeight := 2;
      MinWeightScale := 1;
      MaxWeightScale := 6;
      MinCostScale := 1;
      MaxCostScale := 2;
      MinCost := 1000;
      MaxCost := 2000;
    end;
    t_ArtefactTranclucator:
    begin
      MinExtraWeight := 1;
      MaxExtraWeight := 3;
      MinWeightScale := 1;
      MaxWeightScale := 4;
      MinCostScale := 1;
      MaxCostScale := 3;
      MinCost := 1000;
      MaxCost := 2000;
    end;
    t_ArtDefToEnergy:
    begin
      MinExtraWeight := 1;
      MaxExtraWeight := 5;
      MinWeightScale := 1;
      MaxWeightScale := 2;
      MinCostScale := 1;
      MaxCostScale := 3;
      MinCost := 1500;
      MaxCost := 2500;
    end;
    t_ArtEnergyPulse:
    begin
      MinExtraWeight := 1;
      MaxExtraWeight := 5;
      MinWeightScale := 1;
      MaxWeightScale := 2;
      MinCostScale := 1;
      MaxCostScale := 3;
      MinCost := 1500;
      MaxCost := 2500;
    end;
    t_ArtEnergyDef:
    begin
      MinExtraWeight := 1;
      MaxExtraWeight := 5;
      MinWeightScale := 1;
      MaxWeightScale := 2;
      MinCostScale := 1;
      MaxCostScale := 3;
      MinCost := 1500;
      MaxCost := 2500;
    end;
    t_ArtSplinter:
    begin
      MinExtraWeight := 1;
      MaxExtraWeight := 5;
      MinWeightScale := 1;
      MaxWeightScale := 2;
      MinCostScale := 1;
      MaxCostScale := 3;
      MinCost := 1500;
      MaxCost := 2500;
    end;
    t_ArtDecelerate:
    begin
      MinExtraWeight := 1;
      MaxExtraWeight := 5;
      MinWeightScale := 1;
      MaxWeightScale := 2;
      MinCostScale := 1;
      MaxCostScale := 3;
      MinCost := 1500;
      MaxCost := 2500;
    end;
    t_ArtMissileDef:
    begin
      MinExtraWeight := 1;
      MaxExtraWeight := 5;
      MinWeightScale := 1;
      MaxWeightScale := 2;
      MinCostScale := 1;
      MaxCostScale := 3;
      MinCost := 1500;
      MaxCost := 2500;
    end;
    t_ArtForsage:
    begin
      MinExtraWeight := 1;
      MaxExtraWeight := 5;
      MinWeightScale := 1;
      MaxWeightScale := 2;
      MinCostScale := 1;
      MaxCostScale := 3;
      MinCost := 1500;
      MaxCost := 2500;
    end;
    t_ArtWeaponToSpeed:
    begin
      MinExtraWeight := 1;
      MaxExtraWeight := 5;
      MinWeightScale := 1;
      MaxWeightScale := 2;
      MinCostScale := 1;
      MaxCostScale := 3;
      MinCost := 1500;
      MaxCost := 2500;
    end;
    t_ArtGiperJump:
    begin
      MinExtraWeight := 1;
      MaxExtraWeight := 5;
      MinWeightScale := 1;
      MaxWeightScale := 2;
      MinCostScale := 1;
      MaxCostScale := 3;
      MinCost := 1500;
      MaxCost := 2500;
    end;
    t_ArtBlackHole:
    begin
      MinExtraWeight := 1;
      MaxExtraWeight := 5;
      MinWeightScale := 1;
      MaxWeightScale := 2;
      MinCostScale := 1;
      MaxCostScale := 3;
      MinCost := 1500;
      MaxCost := 2500;
    end;
    t_ArtDefToArms1:
    begin
      MinExtraWeight := 1;
      MaxExtraWeight := 5;
      MinWeightScale := 1;
      MaxWeightScale := 2;
      MinCostScale := 1;
      MaxCostScale := 3;
      MinCost := 1500;
      MaxCost := 2500;
    end;
    t_ArtDefToArms2:
    begin
      MinExtraWeight := 1;
      MaxExtraWeight := 5;
      MinWeightScale := 1;
      MaxWeightScale := 2;
      MinCostScale := 1;
      MaxCostScale := 3;
      MinCost := 1500;
      MaxCost := 2500;
    end;
    t_ArtArtefactor:
    begin
      MinExtraWeight := 1;
      MaxExtraWeight := 5;
      MinWeightScale := 1;
      MaxWeightScale := 2;
      MinCostScale := 1;
      MaxCostScale := 3;
      MinCost := 1500;
      MaxCost := 2500;
    end;
    t_ArtBio:
    begin
      MinExtraWeight := 1;
      MaxExtraWeight := 5;
      MinWeightScale := 1;
      MaxWeightScale := 2;
      MinCostScale := 1;
      MaxCostScale := 3;
      MinCost := 1500;
      MaxCost := 2500;
    end;
    t_ArtPDTurret:
    begin
      MinExtraWeight := 1;
      MaxExtraWeight := 9;
      MinWeightScale := 1;
      MaxWeightScale := 4;
      MinCostScale := 1;
      MaxCostScale := 3;
      MinCost := 1500;
      MaxCost := 2500;
    end;
    t_ArtFastRacks:
    begin
      MinExtraWeight := 1;
      MaxExtraWeight := 5;
      MinWeightScale := 1;
      MaxWeightScale := 2;
      MinCostScale := 1;
      MaxCostScale := 3;
      MinCost := 1500;
      MaxCost := 2500;
    end;
  else
    begin
      MinExtraWeight := 1;
      MaxExtraWeight := 5;
      MinWeightScale := 1;
      MaxWeightScale := 2;
      MinCostScale := 1;
      MaxCostScale := 3;
      MinCost := 1500;
      MaxCost := 2500;
    end;
  end;
  if GetPlayer <> nil then
    Inc(
        Weight,
        Round(
            SeededRandomIntRange(MinExtraWeight, MaxExtraWeight, Id * 317847)
                * RemapClamped(
                    GetPlayer.GetHull.Weight,
                    HullBaseSize * EquipmentSizeFactors[5] * 1.5,
                    HullBaseSize * EquipmentSizeFactors[1],
                    MinWeightScale,
                    MaxWeightScale)
        )
    );
  Cost :=
      RoundAndTruncateToTens(
          SeededRandomIntRange(MinCost, MaxCost, Id + 135671)
              * RemapClamped(Galaxy.TechLevel, 4, 8, MinCostScale, MaxCostScale)
      );
  Weight :=
      Round(
          Weight * GalaxyDifficultyTuning[Galaxy.DifficultyLevels[4]].QuestTimeAndExperienceFactor
      );
  Cost :=
      RoundAndTruncateToTens(
          Cost * GalaxyDifficultyTuning[Galaxy.DifficultyLevels[1]].QuestTimeAndExperienceFactor
      );
end;

function TArtefact.GetBitmapResourceName: WideString;
begin
  if Self is TArtefactCustom then
    Result := 'Bm.Items.' + GiResourceSuffix + ConfigBlockName + '_'
  else if ConfigBlockName <> '' then
    Result := 'Bm.Items.' + GiResourceSuffix + ConfigBlockName
  else
    Result := 'Bm.Items.' + GiResourceSuffix + ItemTypeNames[ItemType] + '_';
end;

function TArtefact.GetDisplayName: WideString;
begin
  if NameOverride <> '' then
    Result := NameOverride
  else
    Result := LocalizedText('Artefacts.' + ItemTypeNames[ItemType] + '.Name');
end;

function TArtefact.GetInfoText(ColorTag: WideString; Ship: Pointer): WideString;
begin
  if (ConfigBlockName <> '')
      and (LanguageDataConfig.GetBlock('Artefacts').CountBlocks(ConfigBlockName) > 0) then
    Result :=
        LocalizedColorText('Artefacts.' + ConfigBlockName + '.Text')
            + GetBonusDescription(ColorTag)
            + GetConditionText(True)
            + GetBoostStatusText
  else
    Result :=
        LocalizedColorText('Artefacts.' + ItemTypeNames[ItemType] + '.Text')
            + GetBonusDescription(ColorTag)
            + GetConditionText(True)
            + GetBoostStatusText;
end;

function TArtefact.GetDescriptionText: WideString;
begin
  Result := LocalizedColorText('Artefacts.' + ItemTypeNames[ItemType] + '.Description');
end;

function TArtefact.GetOnUseCodeText: WideString;
var
  Block: TBlockParEC;
begin
  Result := '';
  if ItemType in [t_Artefact..t_Artefact2] then
    Block :=
        LanguageDataConfig
            .GetBlock('Artefacts')
            .GetBlock('CustomArtefacts')
            .GetBlock(ConfigBlockName)
            .FindBlock('OnUseCode')
  else
    Block :=
        LanguageDataConfig
            .GetBlock('Artefacts')
            .GetBlock(ItemTypeNames[ItemType])
            .FindBlock('OnUseCode');
  if Block <> nil then
    Result := Block.ConcatenateValues;
end;

function TArtefact.GetActionCode: Pointer;
var
  Config: TBlockParEC;
begin
  if ActCodeInitialized then
  begin
    Result := ActionCode;
    Exit;
  end;
  Result := nil;
  ActCodeInitialized := True;
  if ItemType in [t_Artefact..t_Artefact2] then
    Config :=
        LanguageDataConfig
            .GetBlock('Artefacts')
            .GetBlock('CustomArtefacts')
            .GetBlock(ConfigBlockName)
  else
    Config := LanguageDataConfig.GetBlock('Artefacts').GetBlock(ItemTypeNames[ItemType]);
  if Config <> nil then
  begin
    if ItemType in [t_Artefact..t_Artefact2] then
      ActionCode := GetCachedActionCode(ArtefactScriptCache, ConfigBlockName, Config)
    else
      ActionCode := GetCachedActionCode(ArtefactKindScriptCache, ItemTypeNames[ItemType], Config);
    Result := ActionCode;
  end;
end;

function TArtefact.GetEffectiveType: TItemType;
begin
  if (ItemType in [t_Artefact, t_Artefact2]) and TArtefactCustom(Self).SharedEffect then
    Result := TArtefactCustom(Self).CountsAsItemType
  else
    Result := ItemType;
end;

procedure TArtefactTransmitter.InitTransmitter(Owner: TOwnerId);
begin
  Init(Owner, t_ArtefactTransmitter);
  Power :=
      RoundAndTruncateToTens(
          SeededRandomIntRange(MinTransmitterPower, AverageTransmitterPower, Id * 317321)
      );
end;

procedure TArtefactTransmitter.SaveToBuffer(Buffer: TBufEC);
begin
  inherited SaveToBuffer(Buffer);
  Buffer.AddIntegerValue(Power);
end;

procedure TArtefactTransmitter.LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy);
begin
  inherited LoadFromBuffer(Buffer, Galaxy);
  Power := Buffer.GetInt32;
end;

procedure TArtefactTransmitter.SaveToBlock(Block: TBlockParEC);
begin
  inherited SaveToBlock(Block);
  Block.AddParam(DecodeTextW('Prouwseor'), IntToStr(Power)); // 'Power'
end;

procedure TArtefactTransmitter.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  Power := StrToInt(Block.GetParam(DecodeTextW('Prouwseor'))); // 'Power'
end;

function TArtefactTransmitter.GetInfoText(ColorTag: WideString; Ship: Pointer): WideString;
var
  DisplayPower: Integer;
begin
  Result :=
      LocalizedColorText('Artefacts.' + ItemTypeNames[ItemType] + '.Text')
          + GetConditionText(True)
          + GetBoostStatusText;
  if Power < 0 then
    DisplayPower := 0
  else
    DisplayPower := Power;
  ReplaceTextToken(Result, '<Power>', IntToStr(DisplayPower), ColorTag);
end;

destructor TArtefactTranclucator.Destroy;
begin
  if Ship <> nil then
  begin
    TObject(Ship).Free;
    Ship := nil;
  end;
  inherited Destroy;
end;

procedure TArtefactTranclucator.InitTranclucator(
    Owner: TOwnerId;
    OwnerShip: Pointer;
    ExistingShip: Pointer
);
var
  Companion: TTranclucator;
  I: Integer;
  Item: TItem;
begin
  Init(Owner, t_ArtefactTranclucator);
  Ship := ExistingShip;
  if Ship = nil then
  begin
    Ship := TTranclucator.Create;
    Companion := TObject(Ship) as TTranclucator;
    Companion.Init(TObject(OwnerShip) as TShip, Owner, False);
    if OwnerShip <> nil then
    begin
      Companion.CurrentStar.Ships.Delete(Companion.CurrentStar.Ships.IndexOf(Companion));
      Companion.CurrentStar := nil;
    end;
  end;
  Companion := TObject(Ship) as TTranclucator;
  if Companion.ArtefactSize > 0 then
    Weight := Companion.ArtefactSize
  else
    Companion.ArtefactSize := Weight;
  ConfigBlockName := Companion.ArtefactSystemName;
  OwnerId := Companion.GetHull.OwnerId;
  for I := 1 to Companion.Inventory.Count - 1 do
  begin
    Item := Companion.Inventory[I];
    Inc(Cost, Item.Cost);
  end;
  for I := 0 to Companion.Artefacts.Count - 1 do
  begin
    Item := Companion.Artefacts[I];
    Inc(Cost, Item.Cost);
  end;
end;

procedure TArtefactTranclucator.SaveToBuffer(Buffer: TBufEC);
begin
  inherited SaveToBuffer(Buffer);
  (TObject(Ship) as TTranclucator).SaveToBuffer(Buffer);
end;

procedure TArtefactTranclucator.LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy);
begin
  inherited LoadFromBuffer(Buffer, Galaxy);
  Ship := TTranclucator.Create;
  (TObject(Ship) as TTranclucator).LoadFromBuffer(Buffer, Galaxy);
end;

function TArtefactTranclucator.Clone: TItem;
begin
  Result := nil;
end;

procedure TArtefactTranclucator.SaveToBlock(Block: TBlockParEC);
begin
  inherited SaveToBlock(Block);
  TTranclucator(Ship)
      .SaveToBlock(
          Block.AddBlockByPath(
              DecodeTextW('S5heifphI4d') + IntToStr(Cardinal(TTranclucator(Ship).Id))
          )); // 'ShipId'
end;

procedure TArtefactTranclucator.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  TTranclucator(Ship)
      .LoadFromBlock(
          Block.GetBlockByPath(
              DecodeTextW('S5heifphI4d') + IntToStr(Cardinal(TTranclucator(Ship).Id))
          )); // 'ShipId'
end;

procedure TArtefactTranclucator.ResolveLoadedReferences(Galaxy: TGalaxy);
begin
  inherited ResolveLoadedReferences(Galaxy);
  (TObject(Ship) as TTranclucator).ResolveLoadedReferences(Galaxy);
end;

procedure TArtefactTranclucator.ClearReferences;
begin
  inherited ClearReferences;
  (TObject(Ship) as TTranclucator).ClearObjectReferences;
end;

function TArtefactTranclucator.GetDisplayName: WideString;
begin
  if NameOverride <> '' then
    Result := NameOverride
  else if Ship <> nil then
  begin
    if Length((TObject(Ship) as TShip).Name) > 0 then
      Result := (TObject(Ship) as TShip).Name
    else
      Result :=
          LocalizedText('Artefacts.' + ItemTypeNames[ItemType] + '.Name')
              + '-'
              + IntToStr(Int64(Cardinal((TObject(Ship) as TShip).Id)));
  end
  else
    Result := LocalizedText('Artefacts.' + ItemTypeNames[ItemType] + '.Name');
end;

procedure TArtefactCustom.LoadConfig(ApplyConfiguredWeight: Boolean);
var
  Block: TBlockParEC;
  Name: WideString;
  Kind: TItemType;
begin
  Block := LanguageDataConfig.GetBlockByPath('Artefacts.CustomArtefacts.' + ConfigBlockName);
  if (Block.CountParams('NoWear') > 0) and (ExtractDigitsToIntW(Block.GetParam('NoWear')) <> 0) then
    ItemType := t_Artefact2
  else
    ItemType := t_Artefact;
  if ApplyConfiguredWeight then
    if Block.CountParams('Size') <= 0 then
      Weight := 10
    else
      Weight := ExtractDigitsToIntW(Block.GetParam('Size'));
  CountsAsItemType := t_Artefact;
  SharedUse := False;
  SharedEffect := False;
  if Block.CountParams('CountsAs') > 0 then
  begin
    Name := Block.GetParam('CountsAs');
    for Kind := Low(TItemType) to High(TItemType) do
      if (Kind
              in [
                  t_Artefact..t_ArtefactAntigrav,
                  t_ArtDefToEnergy..t_ArtGiperJump,
                  t_ArtDefToArms1..t_ArtFastRacks])
          and not (Kind in [t_Artefact..t_Artefact2])
          and (ItemTypeNames[Kind] = Name) then
      begin
        CountsAsItemType := Kind;
        Break;
      end;
    if CountsAsItemType <> t_Artefact then
    begin
      if Block.CountParams('SharedUse') > 0 then
        SharedUse := ExtractDigitsToIntW(Block.GetParam('SharedUse')) <> 0;
      if Block.CountParams('SharedEffect') > 0 then
        SharedEffect := ExtractDigitsToIntW(Block.GetParam('SharedEffect')) <> 0;
    end;
  end;
end;

procedure TArtefactCustom.SaveToBuffer(Buffer: TBufEC);
begin
  inherited SaveToBuffer(Buffer);
  Buffer.AddIntegerValue(Data[1]);
  Buffer.AddIntegerValue(Data[2]);
  Buffer.AddIntegerValue(Data[3]);
  if TextData1 = '' then
    Buffer.AddBoolean(False)
  else
  begin
    Buffer.AddBoolean(True);
    Buffer.AddWideStringZ(TextData1);
  end;
  if TextData2 = '' then
    Buffer.AddBoolean(False)
  else
  begin
    Buffer.AddBoolean(True);
    Buffer.AddWideStringZ(TextData2);
  end;
  if TextData3 = '' then
    Buffer.AddBoolean(False)
  else
  begin
    Buffer.AddBoolean(True);
    Buffer.AddWideStringZ(TextData3);
  end;
end;

procedure TArtefactCustom.LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy);
begin
  inherited LoadFromBuffer(Buffer, Galaxy);
  LoadConfig(False);
  Data[1] := Buffer.GetInt32;
  Data[2] := Buffer.GetInt32;
  Data[3] := Buffer.GetInt32;
  if LoadedSaveVersion >= 96 then
  begin
    if Buffer.GetBoolean then
      TextData1 := Buffer.ReadWideString;
    if Buffer.GetBoolean then
      TextData2 := Buffer.ReadWideString;
    if Buffer.GetBoolean then
      TextData3 := Buffer.ReadWideString;
  end;
end;

procedure TArtefactCustom.SaveToBlock(Block: TBlockParEC);
begin
  inherited SaveToBlock(Block);
  Block.AddParam(DecodeTextW('Drastuan' + IntToStr(1)), IntToStr(Data[1])); // 'Data1'
  Block.AddParam(DecodeTextW('Drastuan' + IntToStr(2)), IntToStr(Data[2])); // 'Data2'
  Block.AddParam(DecodeTextW('Drastuan' + IntToStr(3)), IntToStr(Data[3])); // 'Data3'
end;

procedure TArtefactCustom.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  Data[1] := StrToInt(Block.GetParam(DecodeTextW('Drastuan' + IntToStr(1)))); // 'Data1'
  Data[2] := StrToInt(Block.GetParam(DecodeTextW('Drastuan' + IntToStr(2)))); // 'Data2'
  Data[3] := StrToInt(Block.GetParam(DecodeTextW('Drastuan' + IntToStr(3)))); // 'Data3'
end;

function TArtefactCustom.GetInfoText(ColorTag: WideString; Ship: Pointer): WideString;
begin
  Result :=
      LocalizedColorText('Artefacts.CustomArtefacts.' + ConfigBlockName + '.Text')
          + GetBonusDescription(ColorTag)
          + GetConditionText(True)
          + GetBoostStatusText;
  ReplaceTextToken(Result, '<Data1>', IntToStr(Data[1]), ColorTag);
  ReplaceTextToken(Result, '<Data2>', IntToStr(Data[2]), ColorTag);
  ReplaceTextToken(Result, '<Data3>', IntToStr(Data[3]), ColorTag);
  ReplaceTextToken(Result, '<TextData1>', TextData1, ColorTag);
  ReplaceTextToken(Result, '<TextData2>', TextData2, ColorTag);
  ReplaceTextToken(Result, '<TextData3>', TextData3, ColorTag);
end;

function TArtefactCustom.GetDisplayName: WideString;
begin
  if NameOverride <> '' then
    Result := NameOverride
  else
    Result := LocalizedText('Artefacts.CustomArtefacts.' + ConfigBlockName + '.Name');
end;

function TArtefactCustom.GetDescriptionText: WideString;
begin
  Result := LocalizedColorText('Artefacts.CustomArtefacts.' + ConfigBlockName + '.Description');
end;

function TArtefact.GetBoostStatusText: WideString;
var
  Ship: TShip;
  I: Integer;
begin
  Result := '';
  if BrokenFlag <> 0 then
    Exit;
  Ship := nil;
  if GetInnermostScreenLoop = HangarScreen then
    Ship := HangarScreen.SelectedShip
  else if GetInnermostScreenLoop = ScannerScreen then
    Ship := ScannerScreen.ShipToInspect
  else if GetInnermostScreenLoop = ShipScreen then
    Ship := PlayerHoldShip;
  if Ship = nil then
    Exit;
  if Ship.CanBoostArtefact(GetEffectiveType, nil, True) then
  begin
    if EquippedFlag <> 0 then
      Result := #13#10' '#13#10 + LocalizedColorText('Artefacts.TextArtGettingBoost')
    else
      Result := #13#10' '#13#10 + LocalizedColorText('Artefacts.TextArtCanGetBoost');
  end
  else
    for I := 0 to Ship.Inventory.Count - 1 do
      if Ship.CanBoostArtefact(GetEffectiveType, TEquipment(Ship.Inventory[I]), True) then
      begin
        Result := #13#10' '#13#10 + LocalizedColorText('Artefacts.TextArtCanGetBoost');
        Break;
      end;
end;

function CreateItemByType(ItemType: TItemType): TItem;
begin
  Result := nil;
  case ItemType of
    t_Hull: Result := THull.Create;
    t_FuelTanks: Result := TFuelTanks.Create;
    t_Engine: Result := TEngine.Create;
    t_Radar: Result := TRadar.Create;
    t_Scaner: Result := TScaner.Create;
    t_RepairRobot: Result := TRepairRobot.Create;
    t_CargoHook: Result := TCargoHook.Create;
    t_DefGenerator: Result := TDefGenerator.Create;
    t_Protoplasm: Result := TProtoplasm.Create;
    t_UselessItem: Result := TUselessItem.Create;
    t_MicroModule: Result := TMicroModule.Create;
    t_Cistern: Result := TCistern.Create;
    t_Satellite: Result := TSatellite.Create;
    t_TreasureMap: Result := TTreasureMap.Create;
    t_UselessCountableItem: Result := TCountableItem.Create;
    t_ArtefactTransmitter: Result := TArtefactTransmitter.Create;
    t_ArtefactTranclucator: Result := TArtefactTranclucator.Create;
    t_Artefact, t_Artefact2: Result := TArtefactCustom.Create;
    t_CustomWeapon: Result := TCustomWeapon.Create;
  else
    if ItemType in [t_IndustrialLaser..t_Lirecron] then
      Result := TWeapon.Create
    else if ItemType in [t_Food..t_Narcotics] then
      Result := TGoods.Create
    else if ItemType in [t_ArtefactHull..t_ArtFastRacks] then
      Result := TArtefact.Create
    else
      Exception.Create('Error CreateItemByType'); // Native allocates without raising.
  end;
end;

function CreateDefaultItemByType(ItemType: TItemType): TItem;
var
  Item: TItem;
begin
  if ItemType in [t_ArtefactHull..t_ArtFastRacks] then
    Result := CreateConfiguredArtefactByItemType(ItemType, oiUninhabited)
  else if ItemType = t_Hull then
  begin
    Item := CreateItemByType(ItemType);
    THull(Item).Init(250, 1, RaceToOwner(GetPlayer.PilotRace), htRanger, -1, False);
    Result := Item;
  end
  else if ItemType = t_CustomWeapon then
    Result := nil
  else if ItemType in [t_Hull..t_CustomWeapon] then
    Result := CreateGeneratedEquipment(ItemType, 20, 1, oiUninhabited)
  else
  begin
    Item := CreateItemByType(ItemType);
    Result := Item;
    if Item <> nil then
      case ItemType of
        t_Protoplasm: TProtoplasm(Item).Init(10, 0);
        t_UselessItem:
          TUselessItem(Item)
              .Init(
                  DecodeTextW('EdxYahmrpelwefAjsktleoruoeiddc'),
                  dsBlazer,
                  0,
                  False); // 'ExampleAsteroid'
        t_MicroModule: TMicroModule(Item).Init(1);
        t_Cistern: TCistern(Item).Init(10, 10, oiUninhabited);
        t_Satellite:
          TSatellite(Item)
              .InitGenerated(
                  1,
                  GetPlayer.OwnerId,
                  NextRandomIntRange(1, 10000, Galaxy.RandomState));
      else
        if ItemType in [t_Food..t_Narcotics] then
          TGoods(Item).Init(ItemType, 10)
        else
        begin
          Item.Free;
          Result := nil;
        end;
      end;
  end;
end;

function CreateGeneratedEquipment(
    ItemType: TItemType;
    Weight, Level: Integer;
    Owner: TOwnerId
): TEquipment;
var
  Item: TItem;
  MinimumLevel: Integer;
  ActualLevel: Byte;
begin
  MinimumLevel := Max(1, Level);
  Result := nil;
  if ItemType in [t_Hull..t_CustomWeapon] then
  begin
    Item := CreateItemByType(ItemType);
    Result := TEquipment(Item);
    if Item <> nil then
    begin
      ActualLevel := Max(0, Min(MinimumLevel, 8));
      case ItemType of
        t_Hull: THull(Item).Init(Weight, ActualLevel, Owner, htRanger, -1, False);
        t_FuelTanks: TFuelTanks(Item).Init(Weight, ActualLevel, Owner);
        t_Engine: TEngine(Item).Init(Weight, ActualLevel, Owner);
        t_Radar: TRadar(Item).Init(Weight, ActualLevel, Owner);
        t_Scaner: TScaner(Item).Init(Weight, ActualLevel, Owner);
        t_RepairRobot: TRepairRobot(Item).Init(Weight, ActualLevel, Owner);
        t_CargoHook: TCargoHook(Item).Init(Weight, ActualLevel, Owner);
        t_DefGenerator: TDefGenerator(Item).Init(Weight, ActualLevel, Owner);
      else
        if ItemType = t_CustomWeapon then
          raise Exception.Create('Error CreateEq - cant create custom weapons')
        else if ItemType in [t_IndustrialLaser..t_CustomWeapon] then
          TWeapon(Item).Init(ItemType, Weight, ActualLevel, Owner)
        else
        begin
          Item.Free;
          Result := nil;
        end;
      end;
    end;
  end;
end;

function CreateGeneratedWeapon(Info: PWeaponInfo; Weight, Level: Integer; Owner: TOwnerId): TWeapon;
begin
  Result := TWeapon(CreateItemByType(Info.ItemType));
  if Info.ItemType in [t_IndustrialLaser..t_Lirecron] then
    Result.Init(Info.ItemType, Weight, Level, Owner)
  else
    TCustomWeapon(Result).InitCustom(Info, False, Weight, Level, Owner);
end;

function GetItemTypeBitmapPath(ItemType: TItemType): WideString;
begin
  Result := 'Bm.Items.' + GiResourceSuffix + ItemTypeNames[ItemType];
end;

function GetStackableItemTypeName(ItemType: TItemType): WideString;
begin
  Result := '';
  if ItemType in [t_Food..t_Narcotics] then
    Result := GoodsMarket[Ord(ItemType)].DisplayName
  else if ItemType = t_Protoplasm then
    Result := LocalizedText('Items.Nod.Name');
end;

function GetStackableItemName(Item: TItem): WideString;
begin
  if Item.ItemType = t_UselessCountableItem then
    Result :=
        LocalizedText(
            'Items.CustomCountables.' + (Item as TCountableItem).ConfigBlockName + '.Name'
        )
  else
    Result := GetStackableItemTypeName(Item.ItemType);
end;

function MigrateSavedItemType(ItemType: Byte): TItemType;
begin
  if (LoadedSaveVersion < 164) and (TItemType(ItemType) > t_Artefact) then
    Inc(ItemType);
  if (LoadedSaveVersion < 78) and (TItemType(ItemType) > t_ArtBio) then
    Inc(ItemType);
  if (LoadedSaveVersion < 131) and (TItemType(ItemType) > t_ArtPDTurret) then
    Inc(ItemType);
  if (LoadedSaveVersion < 78) and (TItemType(ItemType) > t_TorpedoTube) then
    Inc(ItemType, 3);
  if (LoadedSaveVersion < 127) and (TItemType(ItemType) > t_Lirecron) then
    Inc(ItemType);
  Result := TItemType(ItemType);
end;

end.
