unit aGalaxyStruct;

{$I GameOptions.inc}

interface

uses
  Types;

const

  GalaxyWarmupTurns = 300;

  TurnsPerYear = 365;

  MaxMonetaryValue = 100000000;

  BaseMovementStepsPerTurn = 200;

  FullPathNodeLimit = 999999;

  AsteroidTargetRangeSquared = 1000000;

  InterceptorTargetRangeSquared = 1000000;

  TerronTransformationFlag = $40000000;

  RelationBadMin = 10;

  RelationNormalMin = 30;

  RelationGoodMin = 60;

  RelationExcellentMin = 80;

  MaxSavedListCount = 10000;

  HoleExitOrderState = -65536;

  OrderTargetShipFlag = $80000000;

  StoredItemPlanetFlag = $80000000;

  TaggedObjectIdMask = $7FFFFFFF;

  UnspecifiedGoods = 42;

  NoGreetingGoods = 50;

  FirstLicensedQuestId = 10000;

  AwardNotFound = $FF;

type

  PointerToTGoodsTradePriceEntry = ^TGoodsTradePriceEntry;

  PointerToTPlanetBattleStatistics = ^TPlanetBattleStatistics;

  {$Z4}
  TCaptainHealthEffect = (
      heBlindness = 1,
      heChekumash = 2,
      heHolyFanaticism = 3,
      heComplexImmunocide = 4,
      heMysteriousLuatanza = 5,
      heDrugAddiction = 6,
      heWhirlwindConcussion = 7,
      hePulledMuscle = 8,
      heGrandMalosausus = 9,
      heBitterPelenosia = 10,
      heAkaSezyanka = 11,
      heNewMolizone = 12,
      heMaloqSizha = 13,
      heOneEyedKhamas = 14,
      heStardust = 15,
      heSuperTechnician = 16,
      heGaalianAlacrity = 17,
      heBloodDjogar = 18,
      heRagobamWhisper = 19,
      heShakhmandooLeader = 20,
      hePsychotropicCache = 21,
      heBusinessMark = 22,
      heDoubleplex = 23,
      heAbsoluteStatus = 24
  );

  TCaptainDisease = heBlindness..heNewMolizone;

  TCaptainStimulant = heMaloqSizha..heAbsoluteStatus;

  {$Z1}
  TShipType = (
      stKling = 0,
      stRanger = 1,
      stTransport = 2,
      stPirate = 3,
      stWarrior = 4,
      stTranclucator = 5,
      rstRangerCenter = 6,
      rstPirateBase = 7,
      rstMilitaryBase = 8,
      rstScienceBase = 9,
      rstBusinessCenter = 10,
      rstMedicalBase = 11,
      rstDominion = 12,
      rstCustomStation = 13
  );

  TStationType = rstRangerCenter..rstCustomStation;

  {$Z1}
  THullType = (
      htRanger = 0,
      htWarrior = 1,
      htPirate = 2,
      htTransport = 3,
      htLiner = 4,
      htDiplomat = 5,
      htKling = 6,
      htTranclucator = 7,
      htStation = 8,
      htSpecial = 9,
      htFlagship = 10
  );

  {$Z1}
  TScriptActionType = (
      satOnStep = 0,
      satOnWeaponShot = 1,
      satOnMissileShot = 2,
      satOnDealingDamage = 3,
      satOnDealingFatalDamage = 4,
      satOnDealingKamikazeDamage = 5,
      satOnTakingDamage = 6,
      satOnTakingDamageEn = 7,
      satOnTakingDamageSp = 8,
      satOnTakingDamageMi = 9,
      satOnWeaponShot2 = 10,
      satOnMissileShot2 = 11,
      satOnGettingWeaponHit = 12,
      satOnGettingMissileHit = 13,
      satOnDroidRepair = 14,
      satOnItemPickUp = 15,
      satOnScan = 16,
      satOnChameleonConfusion = 17,
      satOnScanPossibility = 18,
      satOnAnotherItem = 19,
      satOnAnotherItem2 = 20,
      satOnAnotherGoods = 21,
      satOnItemHit = 22,
      satOnMissileHittingObject = 23,
      satOnEnteringForm = 24,
      satOnLeavingForm = 25,
      satOnReEnteringForm = 26,
      satOnEnteringOtherShip = 27,
      satOnLeavingOtherShip = 28,
      satOnReEnteringOtherShip = 29,
      satOnPlayerSkillIncrease = 30,
      satOnPlayerTalkedWithShip = 31,
      satOnShipTalkedWithPlayer = 32,
      satOnDropItem = 33,
      satOnDropItemFixed = 34,
      satOnMovingItemToStorage = 35,
      satOnReduceEqBattle = 36,
      satOnReduceEqUse = 37,
      satOnReduceEqForce = 38,
      satOnReduceEqForsage = 39,
      satOnItemDestroy = 40,
      satOnPlayerChangeHull = 41,
      satOnPlayerUseMM = 42,
      satOnPlayerBuyEq = 43,
      satOnItemEquip = 44,
      satOnItemDeEquip = 45,
      satOnTrancPacking = 46,
      satOnShipBuysGoods = 47,
      satOnShipSellsGoods = 48,
      satOnShowingItemInfo = 49,
      satOnShowingShipInfo = 50,
      satOnShowingStarInfo = 51,
      satOnNonStandartEqChange = 52,
      satOnCustomTargetting = 53,
      satOnCustomTargettingCheck = 54,
      satOnStartAB = 55,
      satOnABItemDrop = 56,
      satOnGovItemReward = 57,
      satOnCheckingUsability = 58,
      satOnCheckingUsability2 = 59,
      satOnCheckingUsabilityGoods = 60,
      satOnDeath = 61
  );

  {$Z1}
  TShipStanding = (
      ssDominator = 0,
      ssUnaligned = 1,
      ssCoalitionMilitary = 2,
      ssCoalitionActive = 3,
      ssCoalitionPassive = 4,
      ssNeutral = 5,
      ssPiratePassive = 6,
      ssPirateActive = 7,
      ssPirateMilitary = 8,
      ssCustom = 9
  );

  {$Z1}
  TAwardKind = (
      atLiberation = 0,
      atAccomplishment = 1,
      atSecretMission = 2,
      atCowardice = 3,
      atPerfidy = 4,
      atPlanetBattle = 5
  );

  {$Z4}
  TScriptStandingOverrideMode = (ssmNormal = 0, ssmCustomFaction = 1, ssmFixed = 2);

  {$Z1}
  TGreetingShipCategory = (
      gscTransport = 0,
      gscLiner = 1,
      gscDiplomat = 2,
      gscRanger = 3,
      gscPirate = 4,
      gscWarrior = 5,
      gscKling = 6,
      gscPirateClan = 7
  );

  {$Z1}
  TCoalitionProject = (
      cpCreateRangerCenter = 0,
      cpCreatePirateBase = 1,
      cpCreateMilitaryBase = 2,
      cpCreateScienceBase = 3,
      cpCreateBusinessCenter = 4,
      cpCreateMedicalBase = 5,
      cpRangersSubsidy = 6,
      cpPiratesSubsidy = 7,
      cpTransportSubsidy = 8,
      cpLostSubsidy = 9,
      cpWarSubsidy = 10,
      cpWarOperation = 11
  );

  {$Z1}
  TTalkKind = (
      tkMoneyDemand = 0,
      tkGoodsDemand = 1,
      tkTruceOffer = 2,
      tkAttack = 3,
      tkPartnerBreak = 4,
      tkPartnerEnd = 5,
      tkPartnerRiot = 6
  );

  {$Z1}
  TExperienceSource =
      (esUnscaled = 0, esDominators = 1, esPirates = 2, esNormalShips = 3, esTraderCareer = 4);

  TPercent = 0..100;

  TShipRank = 0..7;

  {$Z1}
  TPilotSkill = (
      psAccuracy = 0,
      psManeuverability = 1,
      psTechnical = 2,
      psTrading = 3,
      psCharisma = 4,
      psLeadership = 5
  );

  {$Z1}
  TProgramIndex = (
      prgKellerCall = 0,
      prgLogicalNegation = 1,
      prgDematerial = 2,
      prgEnergotron = 3,
      prgSabCrack = 4,
      prgIntercom = 5,
      prgShipwreck = 6,
      prgWeaponBlocking = 7,
      prgInsanity = 8,
      prgShock = 9,
      prgSelfDestruction = 10,
      prgDisconnection = 11
  );

  TPlanetBattleStatistics = record
    SignedTimeMs: Integer;
    RobotsBuilt: Integer;
    RobotsDestroyed: Integer;
    TurretsBuilt: Integer;
    TurretsDestroyed: Integer;
    BuildingsDestroyed: Integer;
  end;

  PPlanetBattleStatistics = PointerToTPlanetBattleStatistics;

  TGreetingCountMask = set of 0..15;

  {$Z1}
  TWeaponShotType = (
      wstNormal = 0,
      wstChain = 1,
      wstSplash = 2,
      wstExploder = 3,
      wstAreaDamage = 4,
      wstTorpedo = 5,
      wstMissile = 6,
      wstRocket = 7
  );

  TShipTypeMask = set of TShipType;

  {$Z1}
  TWeaponAvailability = (
      waFree = 0,
      waCoalitionOnly = 1,
      waPirateOnly = 2,
      waNotSold = 3,
      waNotSoldAndNodeRepair = 4,
      waMalocOnly = 5,
      waPelengOnly = 6,
      waPeopleOnly = 7,
      waFeiOnly = 8,
      waGaalOnly = 9,
      waSystemOnly = 10
  );

  TWeaponAvailabilityMask = set of TWeaponAvailability;

  {$Z1}
  TKlingType = (
      ktBoss = 0,
      ktEquantor = 1,
      ktUrgant = 2,
      ktSmersh = 3,
      ktMenoc = 4,
      ktShtip = 5,
      ktBertor = 6,
      ktKlig = 7
  );

  {$Z1}
  TDominatorSeries = (dsBlazer = 0, dsKeller = 1, dsTerron = 2);

  {$Z1}
  TRangerCareer = (rcTrader = 0, rcPirate = 1, rcWarrior = 2);

  TRangerCareerSet = set of TRangerCareer;

  {$Z1}
  TPlanetInvention = (
      piHull = 0,
      piFuelTanks = 1,
      piEngine = 2,
      piRadar = 3,
      piScanner = 4,
      piRepairRobot = 5,
      piCargoHook = 6,
      piMainTech = 7,
      piIndustrialLaser = 8,
      piFragmentationCannon = 9,
      piFlux = 10,
      piMissileLauncher = 11,
      piTreton = 12,
      piWavePhaser = 13,
      piFlowBlaster = 14,
      piElectronicCutter = 15,
      piMultiresonator = 16,
      piAtomicVision = 17,
      piDisintegrator = 18,
      piTurbogravitron = 19
  );

  TGalaxyDifficultyIndex = 0..7;

  TDifficultyLevel = 0..9;

  TGalaxyDifficultyLevels = array[0..7] of TDifficultyLevel;

  {$Z1}
  TPlanetEconomy = (peAgricultural = 0, peMixed = 1, peIndustrial = 2);

  TPlanetEconomies = set of TPlanetEconomy;

  {$Z1}
  TPlanetGovernment =
      (pgAnarchy = 0, pgDictatorship = 1, pgMonarchy = 2, pgRepublic = 3, pgDemocracy = 4);

  TPlanetGovernments = set of TPlanetGovernment;

  {$Z1}
  TShopUpdateMode = (sumNormal = 0, sumDisabled = 1, sumEquipmentOnly = 2, sumGoodsOnly = 3);

  {$Z1}
  TStarFaction = (sfCoalition = 0, sfDominators = 1, sfPirates = 2);

  TGalaxyCustomRules = packed record
    Enabled: Boolean;
    DominatorStrength: Byte;
    DominatorAggression: Byte;
    DominatorSpawn: Byte;
    PirateAggression: Byte;
    CoalitionAggression: Byte;
    AsteroidModifier: Byte;
    SunDamageModifier: Byte;
    ExtraInventions: Byte;
    AcrynModifier: Byte;
    NodeDropModifier: Byte;
    ArcadeDropValueModifier: Byte;
    DropValueModifier: Byte;
    AgriculturalPlanetWeight: Byte;
    MixedPlanetWeight: Byte;
    IndustrialPlanetWeight: Byte;
    ExtraRangers: Byte;
    ArcadeHitpointsModifier: Byte;
    ArcadeDamageModifier: Byte;
    AIJunkTolerance: Byte;
    ChaoticRandom: Boolean;
    UnrestrictedEquipmentKnowledge: Boolean;
    StationsNearStars: Boolean;
    FullStationTargeting: Boolean;
    SpecialShips: Boolean;
    ZeroStartingExperience: Boolean;
    ArcadeBattleRoyale: Boolean;
    DominatorRacialWeapons: Boolean;
    StartInCenter: Boolean;
    MaxRangeMissiles: Boolean;
    OldHyperspace: Boolean;
    PirateNodes: Boolean;
    AIUseShops: Boolean;
    StationsUseShop: Boolean;
    DuplicateArtefacts: Boolean;
    HullGrowth: Byte;
    ArcadeEquipmentChange: Boolean;
    OldSpeedCalculation: Boolean;
    OldMissileBonuses: Boolean;
  end;

  TGoodsTradePriceEntry = packed record
    Count: Integer;
    PriceState: Single;
    PurchasePrice: Integer;
    BaseSalePrice: Integer;
  end;

  PGoodsTradePriceEntry = PointerToTGoodsTradePriceEntry;

  TGoodsIndex = 0..7;

  TGoodsTextOrder = array[TGoodsIndex] of TGoodsIndex;

  TDominatorSeriesNameTable = array[TDominatorSeries] of WideString;

  TEngineLevelStats = record
    Speed: Word;
    JumpRange: ShortInt;
  end;

  TEngineLevelStatsTable = array[1..8] of TEngineLevelStats;

  TCargoHookLevelStats = record
    PickupPower: Integer;
    Range: Integer;
    MinPullSpeed: Single;
    MaxPullSpeed: Single;
  end;

  TCargoHookLevelStatsTable = array[1..8] of TCargoHookLevelStats;

  {$Z1}
  TDamageKind = (dkEnergy = 0, dkSplinter = 1, dkMissile = 2, dkDroidBlock = 19);

  TDamageFlagSet = set of TDamageKind;

const

  dkDecelerate = TDamageKind(3);

  dkDestruct = TDamageKind(4);

  dkDrain = TDamageKind(5);

  dkShock = TDamageKind(6);

  dkAcid = TDamageKind(7);

  dkMagnetic = TDamageKind(8);

  dkDecelerateA = TDamageKind(9);

  dkDecelerateAEx = TDamageKind(10);

  dkUndefendable = TDamageKind(11);

  dkNonLethal = TDamageKind(12);

  dkScanBonus = TDamageKind(13);

  dkBonusToDamaged = TDamageKind(14);

  dkMoreDrop = TDamageKind(15);

  dkDropCargo = TDamageKind(16);

  dkReduceEngine = TDamageKind(17);

  dkBlockWeapon = TDamageKind(18);

  DamageNoDeltaMask = 1 shl 20;

  EmptyDamageFlags = [dkEnergy..dkDroidBlock] - [dkEnergy..dkDroidBlock];

type

  TItemTypeMask = set of 0..79;

  {$Z1}
  TOwnerId = (
      oiMaloc = 0,
      oiPeleng = 1,
      oiHuman = 2,
      oiFeyan = 3,
      oiGaal = 4,
      oiDominator = 5,
      oiUninhabited = 6,
      oiPirate = 7
  );

  TPlanetGoodsFactors = record
    PriceFactor: Double;
    StockFactor: Double;
  end;

  TPlanetRaceMarketInfo = record
    InventionProgressScale: Single;
    InitialInventionBoostCount: Integer;
    GoodsFactors: array[TGoodsIndex] of TPlanetGoodsFactors;
    GovernmentRollThresholds: array[TPlanetGovernment] of Byte;
    RevolutionChance: Single;
    FriendlyRelationScale: Single;
    PirateRelationFactor: Single;
    UnknownFactor9C: Single;
    PirateRelationCeiling: Byte;
  end;

  TPlanetRaceMarketTable = array[oiMaloc..oiGaal] of TPlanetRaceMarketInfo;

  TByteMask = set of 0..7;

  TOwnerMask = set of TOwnerId;

  TShipStandings = set of TShipStanding;

  TDominatorSeriesMask = set of TDominatorSeries;

  TPlanetOwnerMasks = packed record
    Coalition: TOwnerMask;
    Dominators: TOwnerMask;
    PirateClan: TOwnerMask;
  end;

  TOwnerRelationRow = array[TOwnerId] of Byte;

  TOwnerRelationTable = array[TOwnerId] of TOwnerRelationRow;

  TFactionStandingMasks = array[TStarFaction] of TShipStandings;

  {$Z1}
  TQuestType =
      (qtSendLetter = 0, qtKillShip = 1, qtPlanetQuest = 2, qtDefendSystem = 3, qtDefendShip = 4);

  TQuestTypes = set of TQuestType;

  TQuestTuning = record
    RewardCapitalPercent: Byte;
    BaseDuration: Integer;
    BaseRewardMoney: Integer;
  end;

  TQuestTuningTable = array[TQuestType] of TQuestTuning;

  TQuestExperienceTable = array[TQuestType] of Integer;

  {$Z1}
  TRelationLevel = (rlHostile = 0, rlBad = 1, rlNormal = 2, rlGood = 3, rlExcellent = 4);

  TRelationLevels = set of TRelationLevel;

  TGalaxyDifficultyTuning = record
    GoodsEventDurationFactor: Single;
    QuestTimeAndExperienceFactor: Single;
    EquipmentWearFactor: Single;
    InventionProgressScale: Single;
    ArcadeRewardScale: Single;
    QuestMoneyFactor: Single;
    StartingPlayerMoney: Integer;
    InitialPirateControlPercent: Byte;
    MarketPriceBandSqueeze: Single;
    RandomHoleSpawnRollMaximum: Integer;
    MaximumDominatorResearchRate: Single;
    MaximumResearchMaterialConsumption: Byte;
    MaximumQuestProgramRewardCount: Byte;
    ArcadeDamageTakenScale: Single;
    CoalitionToPirateBalanceRatio: Single;
  end;

  TGalaxyDifficultyTuningTable = array[0..9] of TGalaxyDifficultyTuning;

  TFactionStrengthValues = array[TStarFaction] of Single;

  TStarStatus = record
    ThreatLevel: Byte;
    TrafficLevel: Byte;
    ControlFaction: TStarFaction;
    CustomFaction: WideString;
    Battle: Byte;
    DominatorSeries: TDominatorSeries;
    PreviousControlFaction: TStarFaction;
    CachedFactionStrength: TFactionStrengthValues;
    FactionStrengthCacheTurn: Integer;
  end;

  {$Z1}
  TGalaxyNewsKind = (
      gnScript = 0,
      gnRevolutionAnarchy = 1,
      gnRevolutionDictatorship = 2,
      gnRevolutionMonarchy = 3,
      gnRevolutionRepublic = 4,
      gnRevolutionDemocracy = 5,
      gnMineralDeposit = 6,
      gnMineralShortage = 7,
      gnArmsSurplus = 8,
      gnArmsShortage = 9,
      gnTechnicsSurplus = 10,
      gnFoodSurplus = 11,
      gnFoodShortage = 12,
      gnMedicineSurplus = 13,
      gnLuxurySurplus = 14,
      gnLuxuryShortage = 15,
      gnAlcoholSurplus = 16,
      gnAlcoholShortage = 17,
      gnTransportActivity = 18,
      gnManyPirates = 19,
      gnSomePirates = 20,
      gnNoPirates = 21,
      gnManyRangers = 22,
      gnEminentRangerLocation = 23,
      gnDominatorAttack = 24,
      gnDominatorAttackRepelled = 25,
      gnLiberationGroupCreated = 26,
      gnPirateAttack = 27,
      gnPirateAttackRepelled = 28,
      gnCoalitionTakesDominatorSystem = 29,
      gnCoalitionTakesPirateSystem = 30,
      gnPiratesTakeDominatorSystem = 31,
      gnPiratesTakeCoalitionSystem = 32,
      gnDominatorsTakeCoalitionSystem = 33,
      gnDominatorsTakePirateSystem = 34,
      gnCoalitionDefeated = 35,
      gnWormholeCreated = 36,
      gnEminentWarrior = 37,
      gnEminentTrader = 38,
      gnEminentPirate = 39,
      gnImprisonment = 40,
      gnStationCreated = 41,
      gnCoalitionInvestment = 42,
      gnDominatorResearchCompleted = 43,
      gnStationSpecialShip = 44,
      gnMilitaryBaseOperation = 45
  );

  TPlanetNews = record
    Id: Cardinal;
    Turn: Integer;
    NewsType: TGalaxyNewsKind;
    Text: WideString;
  end;

implementation

end.
