unit aScriptFun;

{$I GameOptions.inc}

interface

uses
  Types,
  EC_BlockPar,
  EC_Expression,
  aItem,
  aShip;

procedure SF_GRun(av: array of TVarEC; code: TCodeEC);

procedure SF_GCntRun(av: array of TVarEC; code: TCodeEC);

procedure SF_GLastTurnRun(av: array of TVarEC; code: TCodeEC);

procedure SF_GAllCntRun(av: array of TVarEC; code: TCodeEC);

procedure SF_IsScriptActive(av: array of TVarEC; code: TCodeEC);

procedure SF_GetValueFromScript(av: array of TVarEC; code: TCodeEC);

procedure SF_RunFunctionFromScript(av: array of TVarEC; code: TCodeEC);

procedure SF_GetVariableName(av: array of TVarEC; code: TCodeEC);

procedure SF_GetVariableType(av: array of TVarEC; code: TCodeEC);

procedure SF_AddPlanetNews(av: array of TVarEC; code: TCodeEC);

procedure SF_AddJournalRecord(av: array of TVarEC; code: TCodeEC);

procedure SF_AutoBattle(av: array of TVarEC; code: TCodeEC);

procedure SF_GetOwner(av: array of TVarEC; code: TCodeEC);

procedure SF_GiveReward(av: array of TVarEC; code: TCodeEC);

procedure SF_GiveRewardByNom(av: array of TVarEC; code: TCodeEC);

procedure SF_CountReward(av: array of TVarEC; code: TCodeEC);

procedure SF_CountRewardByNom(av: array of TVarEC; code: TCodeEC);

procedure SF_DeleteRewardByNom(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipPicksItem(av: array of TVarEC; code: TCodeEC);

procedure SF_DropItem(av: array of TVarEC; code: TCodeEC);

procedure SF_DropScriptItem(av: array of TVarEC; code: TCodeEC);

procedure SF_DeleteEquipment(av: array of TVarEC; code: TCodeEC);

procedure SF_Rnd(av: array of TVarEC; code: TCodeEC);

procedure SF_GameDateTxtByTurn(av: array of TVarEC; code: TCodeEC);

procedure SF_StatusPlayer(av: array of TVarEC; code: TCodeEC);

procedure SF_Id(av: array of TVarEC; code: TCodeEC);

procedure SF_GalaxyMoney(av: array of TVarEC; code: TCodeEC);

procedure SF_SetName(av: array of TVarEC; code: TCodeEC);

procedure SF_UseTranclucator(av: array of TVarEC; code: TCodeEC);

procedure SF_HullDamage(av: array of TVarEC; code: TCodeEC);

procedure SF_Hitpoints(av: array of TVarEC; code: TCodeEC);

procedure SF_Hit(av: array of TVarEC; code: TCodeEC);

procedure SF_ChangeGlobalRelationsShips(av: array of TVarEC; code: TCodeEC);

procedure SF_ChangeGlobalRelationsPlanets(av: array of TVarEC; code: TCodeEC);

procedure SF_GlobalRelationsShips(av: array of TVarEC; code: TCodeEC);

procedure SF_GlobalRelationsPlanets(av: array of TVarEC; code: TCodeEC);

procedure SF_SetRelationGroup(av: array of TVarEC; code: TCodeEC);

procedure SF_SetRelationPlanet(av: array of TVarEC; code: TCodeEC);

procedure SF_GetRelationPlanet(av: array of TVarEC; code: TCodeEC);

procedure SF_CurTurn(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipType(av: array of TVarEC; code: TCodeEC);

procedure SF_ConName(av: array of TVarEC; code: TCodeEC);

procedure SF_StarName(av: array of TVarEC; code: TCodeEC);

procedure SF_StarMapLabel(av: array of TVarEC; code: TCodeEC);

procedure SF_PlanetName(av: array of TVarEC; code: TCodeEC);

procedure SF_IdToPlanet(av: array of TVarEC; code: TCodeEC);

procedure SF_IdToShip(av: array of TVarEC; code: TCodeEC);

procedure SF_IdToItem(av: array of TVarEC; code: TCodeEC);

procedure SF_PlanetSetGoods(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipName(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipRank(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipRankPoints(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipNextRankPoints(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipRaiseRank(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipStar(av: array of TVarEC; code: TCodeEC);

procedure SF_StarToCon(av: array of TVarEC; code: TCodeEC);

procedure SF_ConNear(av: array of TVarEC; code: TCodeEC);

procedure SF_ConStars(av: array of TVarEC; code: TCodeEC);

procedure SF_ConStar(av: array of TVarEC; code: TCodeEC);

procedure SF_GalaxyStars(av: array of TVarEC; code: TCodeEC);

procedure SF_GalaxyStar(av: array of TVarEC; code: TCodeEC);

procedure SF_StarAngleBetween(av: array of TVarEC; code: TCodeEC);

procedure SF_FindPlanet(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipCanJump(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipInStar(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipInPlanet(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipStatistic(av: array of TVarEC; code: TCodeEC);

procedure SF_PlayerDominatorStatistic(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipMoney(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipFuel(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipFuelLow(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipStrengthInBestRanger(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipStrengthInAverageRanger(av: array of TVarEC; code: TCodeEC);

procedure SF_ChanceToWin(av: array of TVarEC; code: TCodeEC);

procedure SF_RangerStatus(av: array of TVarEC; code: TCodeEC);

procedure SF_RangerPlaceInRating(av: array of TVarEC; code: TCodeEC);

procedure SF_RangerExcludedFromRating(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipFind(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipDestroy(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipDestroyType(av: array of TVarEC; code: TCodeEC);

procedure SF_ItemDestroy(av: array of TVarEC; code: TCodeEC);

procedure SF_RangersCapital(av: array of TVarEC; code: TCodeEC);

procedure SF_GroupToShip(av: array of TVarEC; code: TCodeEC);

procedure SF_OrderJump(av: array of TVarEC; code: TCodeEC);

procedure SF_OrderLanding(av: array of TVarEC; code: TCodeEC);

procedure SF_IsPlayer(av: array of TVarEC; code: TCodeEC);

procedure SF_GroupCount(av: array of TVarEC; code: TCodeEC);

procedure SF_GroupIn(av: array of TVarEC; code: TCodeEC);

procedure SF_CountIn(av: array of TVarEC; code: TCodeEC);

procedure SF_NearestGroup(av: array of TVarEC; code: TCodeEC);

procedure SF_ChangeState(av: array of TVarEC; code: TCodeEC);

procedure SF_StarAngle(av: array of TVarEC; code: TCodeEC);

procedure SF_NewsAdd(av: array of TVarEC; code: TCodeEC);

procedure SF_MsgAdd(av: array of TVarEC; code: TCodeEC);

procedure SF_Ether(av: array of TVarEC; code: TCodeEC);

procedure SF_CustomEther(av: array of TVarEC; code: TCodeEC);

procedure SF_EtherDelete(av: array of TVarEC; code: TCodeEC);

procedure SF_EtherIdAdd(av: array of TVarEC; code: TCodeEC);

procedure SF_EtherIdDelete(av: array of TVarEC; code: TCodeEC);

procedure SF_EtherState(av: array of TVarEC; code: TCodeEC);

procedure SF_ConChangeRelationToRanger(av: array of TVarEC; code: TCodeEC);

procedure SF_GetData(av: array of TVarEC; code: TCodeEC);

procedure SF_SetData(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipData(av: array of TVarEC; code: TCodeEC);

procedure SF_Format(av: array of TVarEC; code: TCodeEC);

procedure SF_DeleteTags(av: array of TVarEC; code: TCodeEC);

procedure SF_Dialog(av: array of TVarEC; code: TCodeEC);

procedure SF_DText(av: array of TVarEC; code: TCodeEC);

procedure SF_DAddText(av: array of TVarEC; code: TCodeEC);

procedure SF_DAdd(av: array of TVarEC; code: TCodeEC);

procedure SF_DAnswer(av: array of TVarEC; code: TCodeEC);

procedure SF_DChange(av: array of TVarEC; code: TCodeEC);

procedure SF_Player(av: array of TVarEC; code: TCodeEC);

procedure SF_ItemExist(av: array of TVarEC; code: TCodeEC);

procedure SF_ItemIn(av: array of TVarEC; code: TCodeEC);

procedure SF_ItemCount(av: array of TVarEC; code: TCodeEC);

procedure SF_DecayGoods(av: array of TVarEC; code: TCodeEC);

procedure SF_UpsurgeGoods(av: array of TVarEC; code: TCodeEC);

procedure SF_GoodsAdd(av: array of TVarEC; code: TCodeEC);

procedure SF_GoodsCount(av: array of TVarEC; code: TCodeEC);

procedure SF_GoodsCost(av: array of TVarEC; code: TCodeEC);

procedure SF_GoodsRuinsForBuy(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipGoods(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipGoodsIllegalOnPlanet(av: array of TVarEC; code: TCodeEC);

procedure SF_GoodsDrop(av: array of TVarEC; code: TCodeEC);

procedure SF_UselessItemCreate(av: array of TVarEC; code: TCodeEC);

procedure SF_GoodsSellPrice(av: array of TVarEC; code: TCodeEC);

procedure SF_GoodsBuyPrice(av: array of TVarEC; code: TCodeEC);

procedure SF_CountTurn(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipSetBad(av: array of TVarEC; code: TCodeEC);

procedure SF_GroupSetBad(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipSetPartner(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipJoin(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipOut(av: array of TVarEC; code: TCodeEC);

procedure SF_AllShipOut(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipInScript(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipInGameEvent(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipInCurScript(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipInNormalSpace(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipInHole(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipIsTakeoff(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipCntWeapon(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipWeapon(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipEqInSlot(av: array of TVarEC; code: TCodeEC);

procedure SF_ArtefactTypeInUse(av: array of TVarEC; code: TCodeEC);

procedure SF_ArtefactTypeBoosted(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipGroup(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipSpeed(av: array of TVarEC; code: TCodeEC);

procedure SF_EnginePower(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipJump(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipArmor(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipProtectability(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipDroidRepair(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipRadarRange(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipScanerPower(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipHookPower(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipHookRange(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipAverageDamage(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipHealthFactor(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipHealthFactorStatus(av: array of TVarEC; code: TCodeEC);

procedure SF_PlayerImmunity(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipStatusEffect(av: array of TVarEC; code: TCodeEC);

procedure SF_GroupIs(av: array of TVarEC; code: TCodeEC);

procedure SF_StateIs(av: array of TVarEC; code: TCodeEC);

procedure SF_Dist(av: array of TVarEC; code: TCodeEC);

procedure SF_Angle(av: array of TVarEC; code: TCodeEC);

procedure SF_Dist2Star(av: array of TVarEC; code: TCodeEC);

procedure SF_BuyPirate(av: array of TVarEC; code: TCodeEC);

procedure SF_BuyTransport(av: array of TVarEC; code: TCodeEC);

procedure SF_Name(av: array of TVarEC; code: TCodeEC);

procedure SF_ShortName(av: array of TVarEC; code: TCodeEC);

procedure SF_FirstGiveMoney(av: array of TVarEC; code: TCodeEC);

procedure SF_HaveProgramm(av: array of TVarEC; code: TCodeEC);

procedure SF_GetProgramm(av: array of TVarEC; code: TCodeEC);

procedure SF_SetProgramm(av: array of TVarEC; code: TCodeEC);

procedure SF_DomikProgramm(av: array of TVarEC; code: TCodeEC);

procedure SF_DomikProgrammDate(av: array of TVarEC; code: TCodeEC);

procedure SF_HoleMamaCreate(av: array of TVarEC; code: TCodeEC);

procedure SF_HoleCreate(av: array of TVarEC; code: TCodeEC);

procedure SF_TerronWeaponLock(av: array of TVarEC; code: TCodeEC);

procedure SF_TerronGrowLock(av: array of TVarEC; code: TCodeEC);

procedure SF_TerronLandingLock(av: array of TVarEC; code: TCodeEC);

procedure SF_TerronToStar(av: array of TVarEC; code: TCodeEC);

procedure SF_KellerLeave(av: array of TVarEC; code: TCodeEC);

procedure SF_KellerNewResearch(av: array of TVarEC; code: TCodeEC);

procedure SF_KellerKill(av: array of TVarEC; code: TCodeEC);

procedure SF_BlazerLanding(av: array of TVarEC; code: TCodeEC);

procedure SF_BlazerSelfDestruction(av: array of TVarEC; code: TCodeEC);

procedure SF_GalaxyShipId(av: array of TVarEC; code: TCodeEC);

procedure SF_NearCivilPlanet(av: array of TVarEC; code: TCodeEC);

procedure SF_SkipGreeting(av: array of TVarEC; code: TCodeEC);

procedure SF_Sound(av: array of TVarEC; code: TCodeEC);

procedure SF_Tips(av: array of TVarEC; code: TCodeEC);

procedure SF_TipsState(av: array of TVarEC; code: TCodeEC);

procedure SF_CT(av: array of TVarEC; code: TCodeEC);

procedure SF_BlockExist(av: array of TVarEC; code: TCodeEC);

procedure SF_GetMainData(av: array of TVarEC; code: TCodeEC);

procedure SF_GetGameOptions(av: array of TVarEC; code: TCodeEC);

procedure SF_ResourceExist(av: array of TVarEC; code: TCodeEC);

procedure SF_CurrentMods(av: array of TVarEC; code: TCodeEC);

procedure SF_RobotSupport(av: array of TVarEC; code: TCodeEC);

procedure SF_StarShips(av: array of TVarEC; code: TCodeEC);

procedure SF_StarPlanets(av: array of TVarEC; code: TCodeEC);

procedure SF_StarMissiles(av: array of TVarEC; code: TCodeEC);

procedure SF_StarAsteroids(av: array of TVarEC; code: TCodeEC);

procedure SF_GroupShip(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipItems(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipArts(av: array of TVarEC; code: TCodeEC);

procedure SF_PlayerTranclucators(av: array of TVarEC; code: TCodeEC);

procedure SF_ArtTranclucatorToShip(av: array of TVarEC; code: TCodeEC);

procedure SF_TranclucatorData(av: array of TVarEC; code: TCodeEC);

procedure SF_LinkItemToScript(av: array of TVarEC; code: TCodeEC);

procedure SF_ReleaseItemFromScript(av: array of TVarEC; code: TCodeEC);

procedure SF_ScriptItemData(av: array of TVarEC; code: TCodeEC);

procedure SF_ScriptItemTextData(av: array of TVarEC; code: TCodeEC);

procedure SF_ScriptItemToItem(av: array of TVarEC; code: TCodeEC);

procedure SF_GetShipPirateRank(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipPirateRankPoints(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipNextPirateRankPoints(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipInPirateClan(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipOnSidePirateClan(av: array of TVarEC; code: TCodeEC);

procedure SF_RaisePirateRank(av: array of TVarEC; code: TCodeEC);

procedure SF_ItemType(av: array of TVarEC; code: TCodeEC);

procedure SF_CustomWeaponType(av: array of TVarEC; code: TCodeEC);

procedure SF_ItemName(av: array of TVarEC; code: TCodeEC);

procedure SF_ItemFullName(av: array of TVarEC; code: TCodeEC);

procedure SF_ItemSize(av: array of TVarEC; code: TCodeEC);

procedure SF_ItemOwner(av: array of TVarEC; code: TCodeEC);

procedure SF_ItemSubrace(av: array of TVarEC; code: TCodeEC);

procedure SF_ItemCost(av: array of TVarEC; code: TCodeEC);

procedure SF_ItemIsInUse(av: array of TVarEC; code: TCodeEC);

procedure SF_ItemIsInSet(av: array of TVarEC; code: TCodeEC);

procedure SF_PlayerEqSet(av: array of TVarEC; code: TCodeEC);

procedure SF_ItemIsBroken(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipCanUseEq(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipCanRepairEq(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipTechLevelKnowledge(av: array of TVarEC; code: TCodeEC);

procedure SF_WeaponTarget(av: array of TVarEC; code: TCodeEC);

procedure SF_GetEquipmentStats(av: array of TVarEC; code: TCodeEC);

procedure SF_SetEquipmentStats(av: array of TVarEC; code: TCodeEC);

procedure SF_CreateHull(av: array of TVarEC; code: TCodeEC);

procedure SF_CreateEquipment(av: array of TVarEC; code: TCodeEC);

procedure SF_CreateArt(av: array of TVarEC; code: TCodeEC);

procedure SF_CreateCustomWeapon(av: array of TVarEC; code: TCodeEC);

procedure SF_CreateCustomArt(av: array of TVarEC; code: TCodeEC);

procedure SF_CustomArtData(av: array of TVarEC; code: TCodeEC);

procedure SF_CustomArtTextData(av: array of TVarEC; code: TCodeEC);

procedure SF_CreateMM(av: array of TVarEC; code: TCodeEC);

procedure SF_CreateNodes(av: array of TVarEC; code: TCodeEC);

procedure SF_CreateCustomCountableItem(av: array of TVarEC; code: TCodeEC);

procedure SF_CreateZond(av: array of TVarEC; code: TCodeEC);

procedure SF_ExistingZonds(av: array of TVarEC; code: TCodeEC);

procedure SF_FreeItem(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipJoinsClan(av: array of TVarEC; code: TCodeEC);

procedure SF_AddItemToShip(av: array of TVarEC; code: TCodeEC);

procedure SF_GetItemFromShip(av: array of TVarEC; code: TCodeEC);

procedure SF_GetArtFromShip(av: array of TVarEC; code: TCodeEC);

procedure SF_ArrangeItems(av: array of TVarEC; code: TCodeEC);

procedure SF_AddItemToPlanet(av: array of TVarEC; code: TCodeEC);

procedure SF_GetItemFromPlanet(av: array of TVarEC; code: TCodeEC);

procedure SF_AddItemToShop(av: array of TVarEC; code: TCodeEC);

procedure SF_GetItemFromShop(av: array of TVarEC; code: TCodeEC);

procedure SF_AddItemToStorage(av: array of TVarEC; code: TCodeEC);

procedure SF_GetItemFromStorage(av: array of TVarEC; code: TCodeEC);

procedure SF_FindItemInStorage(av: array of TVarEC; code: TCodeEC);

procedure SF_PutItemInVault(av: array of TVarEC; code: TCodeEC);

procedure SF_GetItemFromVault(av: array of TVarEC; code: TCodeEC);

procedure SF_DropItemInSystem(av: array of TVarEC; code: TCodeEC);

procedure SF_StopMovingItem(av: array of TVarEC; code: TCodeEC);

procedure SF_StarItems(av: array of TVarEC; code: TCodeEC);

procedure SF_GetItemFromStar(av: array of TVarEC; code: TCodeEC);

procedure SF_PlanetItems(av: array of TVarEC; code: TCodeEC);

procedure SF_StorageItems(av: array of TVarEC; code: TCodeEC);

procedure SF_StorageItemLocation(av: array of TVarEC; code: TCodeEC);

procedure SF_ShopItems(av: array of TVarEC; code: TCodeEC);

procedure SF_AddDialogOverride(av: array of TVarEC; code: TCodeEC);

procedure SF_AddDialogInject(av: array of TVarEC; code: TCodeEC);

procedure SF_InjectAnswer(av: array of TVarEC; code: TCodeEC);

procedure SF_AddDialogBlock(av: array of TVarEC; code: TCodeEC);

procedure SF_GotoGov(av: array of TVarEC; code: TCodeEC);

procedure SF_GetShipPlanet(av: array of TVarEC; code: TCodeEC);

procedure SF_GetShipHomePlanet(av: array of TVarEC; code: TCodeEC);

procedure SF_GetShipRuins(av: array of TVarEC; code: TCodeEC);

procedure SF_GetTalkShip(av: array of TVarEC; code: TCodeEC);

procedure SF_TalkByAI(av: array of TVarEC; code: TCodeEC);

procedure SF_GetTalkType(av: array of TVarEC; code: TCodeEC);

procedure SF_ScriptRun(av: array of TVarEC; code: TCodeEC);

procedure SF_SFT(av: array of TVarEC; code: TCodeEC);

procedure SF_StartTextQuest(av: array of TVarEC; code: TCodeEC);

procedure SF_CreateABShip(av: array of TVarEC; code: TCodeEC);

procedure SF_ConvertToABShip(av: array of TVarEC; code: TCodeEC);

procedure SF_ABShipModifiers(av: array of TVarEC; code: TCodeEC);

procedure SF_StartAB(av: array of TVarEC; code: TCodeEC);

procedure SF_StartRobots(av: array of TVarEC; code: TCodeEC);

procedure SF_MarkRobotsMapAsUsed(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipOwner(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipPilotRace(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipSkill(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipFace(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipFreeExp(av: array of TVarEC; code: TCodeEC);

procedure SF_GetShipExpByType(av: array of TVarEC; code: TCodeEC);

procedure SF_CoordX(av: array of TVarEC; code: TCodeEC);

procedure SF_CoordY(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipSetCoords(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipAngle(av: array of TVarEC; code: TCodeEC);

procedure SF_ObjectType(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipInHyperSpace(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipStatus(av: array of TVarEC; code: TCodeEC);

procedure SF_BuyRanger(av: array of TVarEC; code: TCodeEC);

procedure SF_BuyWarrior(av: array of TVarEC; code: TCodeEC);

procedure SF_BuyBigWarrior(av: array of TVarEC; code: TCodeEC);

procedure SF_BuyDomik(av: array of TVarEC; code: TCodeEC);

procedure SF_BuyDomikExtremal(av: array of TVarEC; code: TCodeEC);

procedure SF_BuyTranclucator(av: array of TVarEC; code: TCodeEC);

procedure SF_TransferShip(av: array of TVarEC; code: TCodeEC);

procedure SF_OrderLock(av: array of TVarEC; code: TCodeEC);

procedure SF_OrderForsage(av: array of TVarEC; code: TCodeEC);

procedure SF_OrderNone(av: array of TVarEC; code: TCodeEC);

procedure SF_OrderMove(av: array of TVarEC; code: TCodeEC);

procedure SF_OrderTeleport(av: array of TVarEC; code: TCodeEC);

procedure SF_OrderTakeOff(av: array of TVarEC; code: TCodeEC);

procedure SF_OrderFollowShip(av: array of TVarEC; code: TCodeEC);

procedure SF_OrderJumpHole(av: array of TVarEC; code: TCodeEC);

procedure SF_RelationToRanger(av: array of TVarEC; code: TCodeEC);

procedure SF_RelationToShip(av: array of TVarEC; code: TCodeEC);

procedure SF_StarOwner(av: array of TVarEC; code: TCodeEC);

procedure SF_StarBattle(av: array of TVarEC; code: TCodeEC);

procedure SF_StarSeries(av: array of TVarEC; code: TCodeEC);

procedure SF_StarHoles(av: array of TVarEC; code: TCodeEC);

procedure SF_StarNearbyStars(av: array of TVarEC; code: TCodeEC);

procedure SF_StarNearbyStarsDist(av: array of TVarEC; code: TCodeEC);

procedure SF_StarSetGraph(av: array of TVarEC; code: TCodeEC);

procedure SF_CreatePlanet(av: array of TVarEC; code: TCodeEC);

procedure SF_PlanetSetGraph(av: array of TVarEC; code: TCodeEC);

procedure SF_PlanetGetGraph(av: array of TVarEC; code: TCodeEC);

procedure SF_PlanetPopulation(av: array of TVarEC; code: TCodeEC);

procedure SF_PlanetOwner(av: array of TVarEC; code: TCodeEC);

procedure SF_PlanetRace(av: array of TVarEC; code: TCodeEC);

procedure SF_PlanetGov(av: array of TVarEC; code: TCodeEC);

procedure SF_PlanetEco(av: array of TVarEC; code: TCodeEC);

procedure SF_PlanetTerrain(av: array of TVarEC; code: TCodeEC);

procedure SF_PlanetTerrainExplored(av: array of TVarEC; code: TCodeEC);

procedure SF_PlanetOrbitRadius(av: array of TVarEC; code: TCodeEC);

procedure SF_PlanetOrbitalVelocity(av: array of TVarEC; code: TCodeEC);

procedure SF_PlanetSize(av: array of TVarEC; code: TCodeEC);

procedure SF_PlanetCurInvention(av: array of TVarEC; code: TCodeEC);

procedure SF_PlanetCurInventionPoints(av: array of TVarEC; code: TCodeEC);

procedure SF_PlanetInventionLevel(av: array of TVarEC; code: TCodeEC);

procedure SF_PlanetBoostInventions(av: array of TVarEC; code: TCodeEC);

procedure SF_PlanetWarriors(av: array of TVarEC; code: TCodeEC);

procedure SF_GalaxySectors(av: array of TVarEC; code: TCodeEC);

procedure SF_GalaxyTechLevel(av: array of TVarEC; code: TCodeEC);

procedure SF_GalaxyDominatorResearchPercent(av: array of TVarEC; code: TCodeEC);

procedure SF_GalaxyDominatorResearchMaterial(av: array of TVarEC; code: TCodeEC);

procedure SF_GalaxyDiffLevels(av: array of TVarEC; code: TCodeEC);

procedure SF_SectorVisible(av: array of TVarEC; code: TCodeEC);

procedure SF_HullHP(av: array of TVarEC; code: TCodeEC);

procedure SF_HullDamageSuspectibility(av: array of TVarEC; code: TCodeEC);

procedure SF_HullType(av: array of TVarEC; code: TCodeEC);

procedure SF_HullSpecial(av: array of TVarEC; code: TCodeEC);

procedure SF_HullSeries(av: array of TVarEC; code: TCodeEC);

procedure SF_GalaxyHoles(av: array of TVarEC; code: TCodeEC);

procedure SF_HoleCreate2(av: array of TVarEC; code: TCodeEC);

procedure SF_HoleStar1(av: array of TVarEC; code: TCodeEC);

procedure SF_HoleStar2(av: array of TVarEC; code: TCodeEC);

procedure SF_HoleX1(av: array of TVarEC; code: TCodeEC);

procedure SF_HoleY1(av: array of TVarEC; code: TCodeEC);

procedure SF_HoleX2(av: array of TVarEC; code: TCodeEC);

procedure SF_HoleY2(av: array of TVarEC; code: TCodeEC);

procedure SF_HoleTurnCreate(av: array of TVarEC; code: TCodeEC);

procedure SF_HoleMap(av: array of TVarEC; code: TCodeEC);

procedure SF_HoleGraph(av: array of TVarEC; code: TCodeEC);

procedure SF_StarRuins(av: array of TVarEC; code: TCodeEC);

procedure SF_CreateQuestItem(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipTurnBeforeEndOrder(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipOrder(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipOrderData1(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipOrderData2(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipOrderObj(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipDestination(av: array of TVarEC; code: TCodeEC);

procedure SF_BuildRuins(av: array of TVarEC; code: TCodeEC);

procedure SF_BuildCustomRuins(av: array of TVarEC; code: TCodeEC);

procedure SF_RuinsChangeType(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipStanding(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipSlots(av: array of TVarEC; code: TCodeEC);

procedure SF_MissileStar(av: array of TVarEC; code: TCodeEC);

procedure SF_MissileType(av: array of TVarEC; code: TCodeEC);

procedure SF_CustomMissileType(av: array of TVarEC; code: TCodeEC);

procedure SF_MissileOwner(av: array of TVarEC; code: TCodeEC);

procedure SF_MissileWeaponID(av: array of TVarEC; code: TCodeEC);

procedure SF_MissileTarget(av: array of TVarEC; code: TCodeEC);

procedure SF_MissileMaxDamage(av: array of TVarEC; code: TCodeEC);

procedure SF_MissileMinDamage(av: array of TVarEC; code: TCodeEC);

procedure SF_MissileLive(av: array of TVarEC; code: TCodeEC);

procedure SF_MissileSpeed(av: array of TVarEC; code: TCodeEC);

procedure SF_MissileAngle(av: array of TVarEC; code: TCodeEC);

procedure SF_AsteroidMinerals(av: array of TVarEC; code: TCodeEC);

procedure SF_AsteroidGraph(av: array of TVarEC; code: TCodeEC);

procedure SF_AsteroidRespawn(av: array of TVarEC; code: TCodeEC);

procedure SF_ArrayAdd(Args: array of TVarEC; Code: TCodeEC);

procedure SF_ArrayDelete(Args: array of TVarEC; Code: TCodeEC);

procedure SF_ArrayClear(Args: array of TVarEC; Code: TCodeEC);

procedure SF_ArrayDim(Args: array of TVarEC; Code: TCodeEC);

procedure SF_ArraySort(Args: array of TVarEC; Code: TCodeEC);

procedure SF_ArraySortPartial(Args: array of TVarEC; Code: TCodeEC);

procedure SF_ArrayRandomize(Args: array of TVarEC; Code: TCodeEC);

procedure SF_ArrayFind(Args: array of TVarEC; Code: TCodeEC);

procedure SF_ArrayFindInSorted(Args: array of TVarEC; Code: TCodeEC);

procedure SF_DistToNearestEnemySystem(av: array of TVarEC; code: TCodeEC);

procedure SF_StarEnemyThreatLevel(av: array of TVarEC; code: TCodeEC);

procedure SF_BuildListOfQuestPossibleLocations(av: array of TVarEC; code: TCodeEC);

procedure SF_FindItemInShip(av: array of TVarEC; code: TCodeEC);

procedure SF_GalaxyRangers(av: array of TVarEC; code: TCodeEC);

procedure SF_MakeShipEnterStar(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipGetBad(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipAddDropItem(av: array of TVarEC; code: TCodeEC);

procedure SF_BonusCount(av: array of TVarEC; code: TCodeEC);

procedure SF_SeriesCount(av: array of TVarEC; code: TCodeEC);

procedure SF_BonusPriority(av: array of TVarEC; code: TCodeEC);

procedure SF_BonusIsSpecial(av: array of TVarEC; code: TCodeEC);

procedure SF_BonusName(av: array of TVarEC; code: TCodeEC);

procedure SF_BonusNumInCfg(av: array of TVarEC; code: TCodeEC);

procedure SF_SeriesNumInCfg(av: array of TVarEC; code: TCodeEC);

procedure SF_BonusValue(av: array of TVarEC; code: TCodeEC);

procedure SF_FindBonusByName(av: array of TVarEC; code: TCodeEC);

procedure SF_FindSeriesByName(av: array of TVarEC; code: TCodeEC);

procedure SF_FindBonusByCustomTag(av: array of TVarEC; code: TCodeEC);

procedure SF_FindBonusByNameInCfg(av: array of TVarEC; code: TCodeEC);

procedure SF_BonusCustomTag(av: array of TVarEC; code: TCodeEC);

procedure SF_CreateEquipmentWithSpecial(av: array of TVarEC; code: TCodeEC);

procedure SF_SpecialToEquipment(av: array of TVarEC; code: TCodeEC);

procedure SF_ModuleToEquipment(av: array of TVarEC; code: TCodeEC);

procedure SF_EqSpecial(av: array of TVarEC; code: TCodeEC);

procedure SF_EqModule(av: array of TVarEC; code: TCodeEC);

procedure SF_MayAddBonusToEq(av: array of TVarEC; code: TCodeEC);

procedure SF_BuildListOfMMByPriority(av: array of TVarEC; code: TCodeEC);

procedure SF_BuildListOfNewShips(av: array of TVarEC; code: TCodeEC);

procedure SF_PlanetToStar(av: array of TVarEC; code: TCodeEC);

procedure SF_Chameleon(av: array of TVarEC; code: TCodeEC);

procedure SF_IsChameleon(av: array of TVarEC; code: TCodeEC);

procedure SF_PlayerChameleonCharges(av: array of TVarEC; code: TCodeEC);

procedure SF_PlayerChameleonCurType(av: array of TVarEC; code: TCodeEC);

procedure SF_PlayerChameleonDetected(av: array of TVarEC; code: TCodeEC);

procedure SF_PlayerLogicChameleon(av: array of TVarEC; code: TCodeEC);

procedure SF_SwitchToMirrorImage(av: array of TVarEC; code: TCodeEC);

procedure SF_EquipmentImageName(av: array of TVarEC; code: TCodeEC);

procedure SF_StarFonImage(av: array of TVarEC; code: TCodeEC);

procedure SF_ExtremalTakeOff(av: array of TVarEC; code: TCodeEC);

procedure SF_ForceNextDay(av: array of TVarEC; code: TCodeEC);

procedure SF_ScriptActionsRun(av: array of TVarEC; code: TCodeEC);

procedure SF_StarListToPlanetList(av: array of TVarEC; code: TCodeEC);

procedure SF_EndGame(av: array of TVarEC; code: TCodeEC);

procedure SF_CustomWin(av: array of TVarEC; code: TCodeEC);

procedure SF_CustomLose(av: array of TVarEC; code: TCodeEC);

procedure SF_PirateWin(av: array of TVarEC; code: TCodeEC);

procedure SF_StartVideo(av: array of TVarEC; code: TCodeEC);

procedure SF_StartMusic(av: array of TVarEC; code: TCodeEC);

procedure SF_MusicControls(av: array of TVarEC; code: TCodeEC);

procedure SF_NoComeKlingToStar(av: array of TVarEC; code: TCodeEC);

procedure SF_NoDropToShip(av: array of TVarEC; code: TCodeEC);

procedure SF_NoTargetToShip(av: array of TVarEC; code: TCodeEC);

procedure SF_NoTalkToShip(av: array of TVarEC; code: TCodeEC);

procedure SF_NoScanToShip(av: array of TVarEC; code: TCodeEC);

procedure SF_NoJump(av: array of TVarEC; code: TCodeEC);

procedure SF_NoLanding(av: array of TVarEC; code: TCodeEC);

procedure SF_NoShopUpdate(av: array of TVarEC; code: TCodeEC);

procedure SF_PlanetExtraFlags(av: array of TVarEC; code: TCodeEC);

procedure SF_NoDropItem(av: array of TVarEC; code: TCodeEC);

procedure SF_CanSellItem(av: array of TVarEC; code: TCodeEC);

procedure SF_TruceBetweenShips(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipInPrison(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipPartners(av: array of TVarEC; code: TCodeEC);

procedure SF_PlayerPirates(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipIsPartner(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipFreeSpace(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipWealth(av: array of TVarEC; code: TCodeEC);

procedure SF_DomiksDefeated(av: array of TVarEC; code: TCodeEC);

procedure SF_CoalitionDefeated(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipRefuel(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipRepairEq(av: array of TVarEC; code: TCodeEC);

procedure SF_ItemInScript(av: array of TVarEC; code: TCodeEC);

procedure SF_FindPlanetByAdvancement(av: array of TVarEC; code: TCodeEC);

procedure SF_StarListToTransitPlanetList(av: array of TVarEC; code: TCodeEC);

procedure SF_GalaxyEvents(av: array of TVarEC; code: TCodeEC);

procedure SF_GalaxyEventDate(av: array of TVarEC; code: TCodeEC);

procedure SF_GalaxyEventType(av: array of TVarEC; code: TCodeEC);

procedure SF_GalaxyEventData(av: array of TVarEC; code: TCodeEC);

procedure SF_GalaxyEventsTextData(av: array of TVarEC; code: TCodeEC);

procedure SF_PlanetNews(av: array of TVarEC; code: TCodeEC);

procedure SF_PlanetNewsDate(av: array of TVarEC; code: TCodeEC);

procedure SF_PlanetNewsType(av: array of TVarEC; code: TCodeEC);

procedure SF_PlanetNewsText(av: array of TVarEC; code: TCodeEC);

procedure SF_ControlledSystems(av: array of TVarEC; code: TCodeEC);

procedure SF_DeltaWin(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipInFear(av: array of TVarEC; code: TCodeEC);

procedure SF_CreateGoods(av: array of TVarEC; code: TCodeEC);

procedure SF_GetNodesFromShip(av: array of TVarEC; code: TCodeEC);

procedure SF_GetNodesFromStorage(av: array of TVarEC; code: TCodeEC);

procedure SF_RangerBaseNodes(av: array of TVarEC; code: TCodeEC);

procedure SF_RuinsAllowModernization(av: array of TVarEC; code: TCodeEC);

procedure SF_RuinsMicromoduleChain(av: array of TVarEC; code: TCodeEC);

procedure SF_DomikKilledInCurSystem(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipTypeN(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipSubType(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipChangeStar(av: array of TVarEC; code: TCodeEC);

procedure SF_IsFilm(av: array of TVarEC; code: TCodeEC);

procedure SF_FilmFlags(av: array of TVarEC; code: TCodeEC);

procedure SF_ShowEffect(av: array of TVarEC; code: TCodeEC);

procedure SF_ShowStaticEffect(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipConnect(av: array of TVarEC; code: TCodeEC);

procedure SF_FilmSound(av: array of TVarEC; code: TCodeEC);

procedure SF_FireWeapon(av: array of TVarEC; code: TCodeEC);

procedure SF_WeaponHit(av: array of TVarEC; code: TCodeEC);

procedure SF_DealDamageToShip(av: array of TVarEC; code: TCodeEC);

procedure SF_LaunchMissile(av: array of TVarEC; code: TCodeEC);

procedure SF_SpawnMissile(av: array of TVarEC; code: TCodeEC);

procedure SF_BonusText(av: array of TVarEC; code: TCodeEC);

procedure SF_PlanetPirateClan(av: array of TVarEC; code: TCodeEC);

procedure SF_Blazer(av: array of TVarEC; code: TCodeEC);

procedure SF_Keller(av: array of TVarEC; code: TCodeEC);

procedure SF_Terron(av: array of TVarEC; code: TCodeEC);

procedure SF_PirateType(av: array of TVarEC; code: TCodeEC);

procedure SF_PlayerQuestInProgress(av: array of TVarEC; code: TCodeEC);

procedure SF_PlayerQuestsCompleted(av: array of TVarEC; code: TCodeEC);

procedure SF_QuestsStatusByNom(av: array of TVarEC; code: TCodeEC);

procedure SF_PlayerPlanetaryBattlesCompleted(av: array of TVarEC; code: TCodeEC);

procedure SF_PlayerMayTakeSubCrack(av: array of TVarEC; code: TCodeEC);

procedure SF_SubCrackCost(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipCalcParam(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipRefit(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipImproveItems(av: array of TVarEC; code: TCodeEC);

procedure SF_ItemImprovement(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipFreeFlight(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipKillFactionInCurSystem(av: array of TVarEC; code: TCodeEC);

procedure SF_CapitalShipStats(av: array of TVarEC; code: TCodeEC);

procedure SF_PlayerBridge(av: array of TVarEC; code: TCodeEC);

procedure SF_PlayerDebt(av: array of TVarEC; code: TCodeEC);

procedure SF_PlayerDebtDate(av: array of TVarEC; code: TCodeEC);

procedure SF_PlayerDebtCnt(av: array of TVarEC; code: TCodeEC);

procedure SF_PlayerDeposit(av: array of TVarEC; code: TCodeEC);

procedure SF_PlayerDepositDate(av: array of TVarEC; code: TCodeEC);

procedure SF_PlayerDepositDay(av: array of TVarEC; code: TCodeEC);

procedure SF_PlayerDepositPercent(av: array of TVarEC; code: TCodeEC);

procedure SF_PlayerMedPolicy(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipCustomShipInfosCount(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipAddCustomShipInfo(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipDeleteCustomShipInfo(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipFindCustomShipInfoByType(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipCustomShipInfoDescription(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipCustomShipInfoData(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipCustomShipInfoTextData(av: array of TVarEC; code: TCodeEC);

procedure SF_StarCustomStarInfosCount(av: array of TVarEC; code: TCodeEC);

procedure SF_StarAddCustomStarInfo(av: array of TVarEC; code: TCodeEC);

procedure SF_StarDeleteCustomStarInfo(av: array of TVarEC; code: TCodeEC);

procedure SF_StarFindCustomStarInfoByType(av: array of TVarEC; code: TCodeEC);

procedure SF_StarCustomStarInfoData(av: array of TVarEC; code: TCodeEC);

procedure SF_ItemCanBeBroken(av: array of TVarEC; code: TCodeEC);

procedure SF_ItemFragility(av: array of TVarEC; code: TCodeEC);

procedure SF_ItemDurability(av: array of TVarEC; code: TCodeEC);

procedure SF_ItemLevel(av: array of TVarEC; code: TCodeEC);

procedure SF_ContainerFuel(av: array of TVarEC; code: TCodeEC);

procedure SF_ItemCharge(av: array of TVarEC; code: TCodeEC);

procedure SF_MissilesToRearm(av: array of TVarEC; code: TCodeEC);

procedure SF_WeaponAmmunition(av: array of TVarEC; code: TCodeEC);

procedure SF_WeaponMaxAmmunition(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipSpecialBonuses(av: array of TVarEC; code: TCodeEC);

procedure SF_ItemExtraSpecials(av: array of TVarEC; code: TCodeEC);

procedure SF_ItemExtraSpecialsCountByType(av: array of TVarEC; code: TCodeEC);

procedure SF_ItemExtraSpecialsAddByType(av: array of TVarEC; code: TCodeEC);

procedure SF_ItemExtraSpecialsDeleteByType(av: array of TVarEC; code: TCodeEC);

procedure SF_ExecuteCodeFromString(av: array of TVarEC; code: TCodeEC);

procedure SF_GenerateCodeStringFromBlock(av: array of TVarEC; code: TCodeEC);

procedure SF_ItemOnUseCode(av: array of TVarEC; code: TCodeEC);

procedure SF_ItemOnActCode(av: array of TVarEC; code: TCodeEC);

procedure SF_CreateActCodeEvent(av: array of TVarEC; code: TCodeEC);

procedure SF_CurItem(av: array of TVarEC; code: TCodeEC);

procedure SF_CurInfo(av: array of TVarEC; code: TCodeEC);

procedure SF_ScriptItemActShip(av: array of TVarEC; code: TCodeEC);

procedure SF_ScriptItemActObject1(av: array of TVarEC; code: TCodeEC);

procedure SF_ScriptItemActObject2(av: array of TVarEC; code: TCodeEC);

procedure SF_ScriptItemActionType(av: array of TVarEC; code: TCodeEC);

procedure SF_ScriptItemActParam(av: array of TVarEC; code: TCodeEC);

procedure SF_OnUseCodeTranclucator(av: array of TVarEC; code: TCodeEC);

procedure SF_OnUseCodeTransmitter(av: array of TVarEC; code: TCodeEC);

procedure SF_OnUseCodeBlackHole(av: array of TVarEC; code: TCodeEC);

procedure SF_OnUseCodeMissileDef(av: array of TVarEC; code: TCodeEC);

procedure SF_MessageBox(av: array of TVarEC; code: TCodeEC);

procedure SF_MessageBoxYesNo(av: array of TVarEC; code: TCodeEC);

procedure SF_CountBox(av: array of TVarEC; code: TCodeEC);

procedure SF_NumberBox(av: array of TVarEC; code: TCodeEC);

procedure SF_TextBox(av: array of TVarEC; code: TCodeEC);

procedure SF_ListBox(av: array of TVarEC; code: TCodeEC);

procedure SF_FormCurShip(av: array of TVarEC; code: TCodeEC);

procedure SF_UselessItemText(av: array of TVarEC; code: TCodeEC);

procedure SF_UselessItemData(av: array of TVarEC; code: TCodeEC);

procedure SF_GetAchievementSHU(av: array of TVarEC; code: TCodeEC);

procedure SF_GetAchievementGIRLSHIRE(av: array of TVarEC; code: TCodeEC);

procedure SF_GetAchievementGIRLSQUEST(av: array of TVarEC; code: TCodeEC);

procedure SF_GetAchievementPIRATEWIN(av: array of TVarEC; code: TCodeEC);

procedure SF_GetAchievementCOALLITION(av: array of TVarEC; code: TCodeEC);

procedure SF_GetAchievementHULL(av: array of TVarEC; code: TCodeEC);

procedure SF_UICheckElement(av: array of TVarEC; code: TCodeEC);

procedure SF_InterfaceState(av: array of TVarEC; code: TCodeEC);

procedure SF_InterfaceText(av: array of TVarEC; code: TCodeEC);

procedure SF_InterfaceImage(av: array of TVarEC; code: TCodeEC);

procedure SF_InterfacePos(av: array of TVarEC; code: TCodeEC);

procedure SF_InterfaceSize(av: array of TVarEC; code: TCodeEC);

procedure SF_ButtonClick(av: array of TVarEC; code: TCodeEC);

procedure SF_SetFocus(av: array of TVarEC; code: TCodeEC);

procedure SF_FormShipCurItem(av: array of TVarEC; code: TCodeEC);

procedure SF_UpdateFormShip(av: array of TVarEC; code: TCodeEC);

procedure SF_CurrentForm(av: array of TVarEC; code: TCodeEC);

procedure SF_FormChange(av: array of TVarEC; code: TCodeEC);

procedure SF_RunChildForm(av: array of TVarEC; code: TCodeEC);

procedure SF_OpenCustomForm(av: array of TVarEC; code: TCodeEC);

procedure SF_CloseCustomForm(av: array of TVarEC; code: TCodeEC);

procedure SF_CustomInterfaceState(av: array of TVarEC; code: TCodeEC);

procedure SF_CustomInterfaceText(av: array of TVarEC; code: TCodeEC);

procedure SF_CustomInterfaceImage(av: array of TVarEC; code: TCodeEC);

procedure SF_CustomInterfacePos(av: array of TVarEC; code: TCodeEC);

procedure SF_CustomInterfacePosZ(av: array of TVarEC; code: TCodeEC);

procedure SF_CustomInterfaceSize(av: array of TVarEC; code: TCodeEC);

procedure SF_StarMapCenterView(av: array of TVarEC; code: TCodeEC);

procedure SF_StarMapCurPosX(av: array of TVarEC; code: TCodeEC);

procedure SF_StarMapCurPosY(av: array of TVarEC; code: TCodeEC);

procedure SF_StarMapCustomSelectionMode(av: array of TVarEC; code: TCodeEC);

procedure SF_StarMapBlinkingMessage(av: array of TVarEC; code: TCodeEC);

procedure SF_BlinkingWarning(av: array of TVarEC; code: TCodeEC);

procedure SF_CustomWeaponTypes(av: array of TVarEC; code: TCodeEC);

procedure SF_InventNewCustomWeapon(av: array of TVarEC; code: TCodeEC);

procedure SF_GetCustomWeaponInfo(av: array of TVarEC; code: TCodeEC);

procedure SF_GetCustomWeaponData(av: array of TVarEC; code: TCodeEC);

procedure SF_GetCustomWeaponPrimaryDamageType(av: array of TVarEC; code: TCodeEC);

procedure SF_SetCustomWeaponAvailability(av: array of TVarEC; code: TCodeEC);

procedure SF_SetCustomWeaponPrimaryData(av: array of TVarEC; code: TCodeEC);

procedure SF_SetCustomWeaponSizeAndCost(av: array of TVarEC; code: TCodeEC);

procedure SF_SetCustomWeaponDamageData(av: array of TVarEC; code: TCodeEC);

procedure SF_SetCustomWeaponShotData(av: array of TVarEC; code: TCodeEC);

procedure SF_SetCustomMissileWeaponStats(av: array of TVarEC; code: TCodeEC);

procedure SF_SetCustomWeaponSE(av: array of TVarEC; code: TCodeEC);

procedure SF_StarCustomFaction(av: array of TVarEC; code: TCodeEC);

procedure SF_ShipCustomFaction(av: array of TVarEC; code: TCodeEC);

procedure SF_EqCustomFaction(av: array of TVarEC; code: TCodeEC);

procedure SF_PlanetCustomFaction(av: array of TVarEC; code: TCodeEC);

procedure SF_ImportedFunction(av: array of TVarEC; code: TCodeEC);

procedure SF_ImportAll(av: array of TVarEC; code: TCodeEC);

procedure SF_GalaxyPtr(av: array of TVarEC; code: TCodeEC);

procedure InitializeScriptBuiltinsAndConstants(Scope: TVarArrayEC);

implementation

uses
{$IFDEF NATIVE_UTILITY_FUNCTIONS_PACK}
  UtilityFunctionsPack,
{$ENDIF}
{$IFDEF NATIVE_AUTOSEARCH}
  AutoSearch,
{$ENDIF}
  BreakMessageGIException,
  aCalc,
  ab_Hit,
  Classes,
  SysUtils,
  aMyFunction,
  aConst,
  aScript,
  aGalaxy,
  Globals,
  GlobalsV,
  GI_MessageLoop,
  aPlanet,
  aPlayer,
  aNormalShip,
  aGalaxyStruct,
  aMissile,
  aAsteroid,
  aWarrior,
  aRuins,
  EC_Str,
  EC_Thread,
  GR_Main,
  ThreadCalc,
  fTalk,
  fGov,
  fRuinsTalk,
  aRanger,
  fShip2,
  GI_XviD,
  GR_Music,
  GameSystem,
  Math,
  aKling,
  SE_Space,
  SE_Planet,
  EC_Struct,
  SE_Hole,
  aEFilm,
  fStarMap,
  fEquipmentShop,
  GR_Sound,
  aTranclucator,
  aPirate,
  aGalaxyEvent,
  aTransport,
  Robot,
  EC_Mem,
  GI_MessageBox,
  Achievements,
  fHangar,
  fScaner,
  aEFilmEnd,
  SE_Weapon,
  SE_GAIEffect,
  SE_Process,
  ab_Ship,
  ab_ShipAI,
  ab_W,
  SE_Ruins,
  GI_GraphButton,
  GI_Label,
  GI_Edit,
  GI_GAI,
  GI_GI,
  GI_Image,
  fTextBox,
  fListBox,
  fCount1,
  fCount2,
  fCustom,
  SE_Ship2,
  fScore,
  fAbout,
  fPanelMain,
  fGoodsShop2,
  fGalaxy2,
  GI_GraphBuf;

procedure SF_GRun(av: array of TVarEC; code: TCodeEC);
begin
  ScriptTemplateStartRequested := True;
end;

procedure SF_GCntRun(av: array of TVarEC; code: TCodeEC);
var
  Index: Integer;
begin
  if High(av) <> 1 then
    raise Exception.Create('Error.Script SF_GCntRun');
  Index := FindScriptTemplateIndex(av[1].AsString);
  if Index < 0 then
    raise Exception.Create('Error.Script.NotFound SF_GCntRun');
  av[0].AsInteger := TScriptTemplUnit(ScriptTemplates[Index]).UseCount;
end;

procedure SF_GLastTurnRun(av: array of TVarEC; code: TCodeEC);
var
  Index: Integer;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script SF_GCntRun');
  Index := FindScriptTemplateIndex(av[1].AsString);
  if Index < 0 then
    raise Exception.Create('Error.Script.NotFound SF_GLastTurnRun');
  if (High(av) >= 2) and (TScriptTemplUnit(ScriptTemplates[Index]).UseCount < 1) then
    av[0].AsInteger := av[2].AsInteger
  else
    av[0].AsInteger := TScriptTemplUnit(ScriptTemplates[Index]).LastTurn;
end;

procedure SF_GAllCntRun(av: array of TVarEC; code: TCodeEC);
var
  Count, ClassId, I: Integer;
begin
  if High(av) >= 1 then
  begin
    ClassId := av[1].AsInteger;
    Count := 0;
    for I := 0 to Galaxy.Scripts.Count - 1 do
      if TScript(Galaxy.Scripts[I]).ClassId = ClassId then
        Inc(Count);
    av[0].AsInteger := Count;
  end
  else
    av[0].AsInteger := Galaxy.Scripts.Count;
end;

procedure SF_IsScriptActive(av: array of TVarEC; code: TCodeEC);
var
  Index: Integer;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script IsScriptActive');
  av[0].AsInteger := 0;
  Index := FindScriptTemplateIndex(av[1].AsString);
  if Index >= 0 then
    av[0].AsInteger := Ord(TScriptTemplUnit(ScriptTemplates[Index]).ActiveScriptIndex >= 0);
end;

procedure SF_GetValueFromScript(av: array of TVarEC; code: TCodeEC);
var
  Index, LastArg: Integer;
  Script: TScript;
  Value: TVarEC;
begin
  LastArg := High(av);
  if LastArg < 2 then
    raise Exception.Create('Error.Script GetValueFromScript');
  if av[1].AsString = '' then
  begin
    Value := ScriptFunctionScope.GetVarNE(av[2].AsString);
    if Value = nil then
      raise Exception.Create('Error.Script GetValueFromScript - var ' + av[2].AsString + ' not found');
  end
  else
  begin
    Index := FindScriptTemplateIndex(av[1].AsString);
    if Index < 0 then
      Exit;
    Index := TScriptTemplUnit(ScriptTemplates[Index]).ActiveScriptIndex;
    if Index < 0 then
      Exit;
    Script := Galaxy.Scripts[Index];
    Value := Script.InitCode.LocalVar.GetVarNE(av[2].AsString);
    if Value = nil then
      Value := Script.TurnCode.LocalVar.GetVarNE(av[2].AsString);
    if Value = nil then
      Value := ScriptFunctionScope.GetVarNE(av[2].AsString);
    if Value = nil then
      raise Exception.Create('Error.Script GetValueFromScript - var ' + av[2].AsString + ' not found in script ' + av[1].AsString);
  end;
  Index := 2;
  while (Value.ValueKind = vkArray) and (Index < LastArg) do
  begin
    Inc(Index);
    if av[Index].ValueKind = vkString then
      Value := Value.AsArray.NamedItems[av[Index].AsString]
    else
      Value := Value.AsArray[av[Index].AsInteger];
  end;
  case Value.ValueKind of
    // Cross-script reads copy the cell, including addresses kept in legacy int variables.
    vkInt:
    begin
      av[0].ConvertToKind(vkInt);
      av[0].AsDword := Value.AsDword;
    end;
    vkDword: av[0].AsDword := Value.AsDword;
    vkFloat: av[0].AsFloat := Value.AsFloat;
    vkString: av[0].AsString := Value.AsString;
    vkArray: av[0].AsInteger := Value.AsArray.Count;
  end;
end;
procedure SF_RunFunctionFromScript(av: array of TVarEC; code: TCodeEC);
var
  Index, LastArg, I: Integer;
  Script, SavedScript: TScript;
  Value: TVarEC;
  Name: WideString;
  CallCode: TCodeEC;
begin
  LastArg := High(av);
  if LastArg < 2 then
    raise Exception.Create('Error.Script RunFunctionFromScript');
  Index := FindScriptTemplateIndex(av[1].AsString);
  if Index < 0 then
    Exit;
  Index := TScriptTemplUnit(ScriptTemplates[Index]).ActiveScriptIndex;
  if Index < 0 then
    Exit;
  Script := Galaxy.Scripts[Index];
  Name := 'g_' + av[2].AsString;
  Value := Script.InitCode.LocalVar.GetVarNE(Name);
  if Value = nil then
    Value := Script.TurnCode.LocalVar.GetVarNE(Name);
  if (Value = nil) or (Value.ValueKind <> vkFunction) then
    raise Exception.Create('Error.Script RunFunctionFromScript - function ' + Name + ' not found in script ' + av[1].AsString);
  CallCode := TCodeEC.Create;
  CallCode.CopyFromFast(Value.AsFunction);
  for I := 3 to LastArg do
    if CallCode.LocalVar[I - 3].Kind = vkRef then
      CallCode.LocalVar[I - 3].SetRef(av[I])
    else
      CallCode.LocalVar[I - 3].Assume(av[I], False);
  SavedScript := CurrentScript;
  try
    CallCode.LocalVar.NamedItems['result'].SetRef(av[0]);
    CurrentScript := Script;
    CallCode.Run(ScriptProcess);
  except
    on E: EBreakMessageGI do
    begin
      CallCode.Free;
      raise;
    end;
    on E: Exception do
      raise ExceptionExpressionEC.Create('Error in function ' + Value.Name + ' (' + E.ClassName + ' ' + E.Message + ')');
  end;
  { Native exceptions bypass context restoration; only EBreakMessageGI frees CallCode. }
  CurrentScript := SavedScript;
  CallCode.Free;
end;

procedure SF_GetVariableName(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script GetVariableName');
  av[0].AsString := av[1].Name;
end;

procedure SF_GetVariableType(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script GetVariableType');
  av[0].AsInteger := Ord(av[1].ValueKind);
end;

procedure SF_AddPlanetNews(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script AddPlanetNews');
  if High(av) > 1 then
    Galaxy.AddPlanetNews(TGalaxyNewsKind(av[2].AsInteger), av[1].AsString)
  else
    Galaxy.AddPlanetNews(gnScript, av[1].AsString);
end;

procedure SF_AddJournalRecord(av: array of TVarEC; code: TCodeEC);
var
  Entry: TJournalRecord;
  I, Turn: Integer;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script AddJournalRecord');
  if High(av) = 1 then
    GetPlayer.AddJournalRecord(av[1].AsString)
  else
  begin
    Turn := av[2].AsInteger;
    Entry := TJournalRecord.Create;
    Entry.Text := av[1].AsString;
    Entry.DateTurn := Turn;
    if (GetPlayer.JournalRecords.Count <= 0)
        or (TJournalRecord(GetPlayer.JournalRecords[GetPlayer.JournalRecords.Count - 1]).DateTurn <= Turn) then
    begin
      GetPlayer.JournalRecords.Add(Entry);
      Exit;
    end;
    for I := GetPlayer.JournalRecords.Count - 2 downto 0 do
      if TJournalRecord(GetPlayer.JournalRecords[I]).DateTurn <= Turn then
      begin
        GetPlayer.JournalRecords.Insert(I + 1, Entry);
        Exit;
      end;
    GetPlayer.JournalRecords.Insert(0, Entry);
  end;
end;

procedure SF_AutoBattle(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) <> 1 then
    raise Exception.Create('Error.Script AutoBattle');
  PendingPlayerFollowTarget := TShip(av[1].AsDword);
end;

procedure SF_GetOwner(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  Owner: Integer;
begin
  if High(av) <> 1 then
    raise Exception.Create('Error.Script SF_GetOwner');
  Ship := TShip(av[1].AsDword);
  Owner := Ord(Ship.OwnerId);
  av[0].AsInteger := Owner;
end;

procedure SF_GiveReward(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  Owner: TOwnerId;
  Kind: TAwardKind;
  Award: Integer;
begin
  if High(av) < 3 then
    raise Exception.Create('Error.Script SF_GiveReward');
  Ship := TShip(av[1].AsDword);
  Owner := TOwnerId(av[2].AsInteger);
  Kind := TAwardKind(av[3].AsInteger);
  Award := (Ship as TNormalShip).SelectAward(Owner, [Kind], [stKling..rstCustomStation]);
  if Award = AwardNotFound then
    RaiseWideMessage('Error RewardNumber=255');
  Ship.AddAward(Award);
  av[0].AsInteger := Award;
end;

procedure SF_GiveRewardByNom(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script SF_GiveRewardByNom');
  Ship := TShip(av[1].AsDword);
  Ship.AddAward(av[2].AsInteger);
end;

procedure SF_CountReward(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  Kind: TAwardKind;
  Index, Count: Integer;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script SF_CountReward');
  Ship := TShip(av[1].AsDword);
  if High(av) = 1 then
  begin
    if (Ship.AwardIds = nil) or (Ship.AwardIds.Count = 0) then
    begin
      av[0].AsString := '';
      Exit;
    end;
    av[0].AsString := IntToWideString(Integer(Ship.AwardIds[0]));
    for Index := 1 to Ship.AwardIds.Count - 1 do
      av[0].AsString := av[0].AsString + ',' + IntToWideString(Integer(Ship.AwardIds[Index]));
  end
  else
  begin
    Kind := TAwardKind(av[2].AsInteger);
    if Ship.AwardIds = nil then
    begin
      av[0].AsInteger := 0;
      Exit;
    end;
    Count := 0;
    for Index := 0 to Ship.AwardIds.Count - 1 do
      if SysToReward(LookupLocalizedTextByKey('Reward.' + SysUtils.IntToStr(Integer(Ship.AwardIds[Index])) + '.Type')) = Kind then
        Inc(Count);
    av[0].AsInteger := Count;
  end;
end;

procedure SF_CountRewardByNom(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  Index, Count, Award: Integer;
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script SF_CountRewardByNom');
  Ship := TShip(av[1].AsDword);
  Award := av[2].AsInteger;
  if Ship.AwardIds = nil then
  begin
    av[0].AsInteger := 0;
    Exit;
  end;
  Count := 0;
  for Index := 0 to Ship.AwardIds.Count - 1 do
    if Integer(Ship.AwardIds[Index]) = Award then
      Inc(Count);
  av[0].AsInteger := Count;
end;

procedure SF_DeleteRewardByNom(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  Index, Count, Award: Integer;
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script SF_DeleteRewardByNom');
  Ship := TShip(av[1].AsDword);
  Award := av[2].AsInteger;
  if High(av) > 2 then
    Count := av[3].AsInteger
  else
    Count := 1;
  av[0].AsInteger := 0;
  if Ship.AwardIds <> nil then
    for Index := Ship.AwardIds.Count - 1 downto 0 do
      if (Integer(Ship.AwardIds[Index]) = Award) or (Award = -1) then
      begin
        Ship.AwardIds.Delete(Index);
        av[0].AsInteger := av[0].AsInteger + 1;
        if av[0].AsInteger >= Count then
          Break;
      end;
end;

procedure SF_ShipPicksItem(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  Item: TItem;
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script SF_ShipPicksItem');
  Ship := TShip(av[1].AsDword);
  Item := TItem(av[2].AsDword);
  if High(av) = 2 then
  begin
    if Ship.HasPickupTarget(Item) then
      av[0].AsInteger := 1
    else if Ship.IsRecentlyDroppedItem(Item) then
      av[0].AsInteger := -1
    else
      av[0].AsInteger := 0;
    Exit;
  end;
  if av[3].AsInteger > 0 then
  begin
    Ship.AddPickupTarget(Item, False);
    if Ship.IsRecentlyDroppedItem(Item) then
      Ship.RecentlyDroppedItemIds.Delete(Ship.RecentlyDroppedItemIds.IndexOf(Item));
    Exit;
  end;
  if av[3].AsInteger < 0 then
  begin
    Ship.RemovePickupTarget(Item);
    Ship.AddRecentlyDroppedItem(Item);
    Exit;
  end;
  Ship.RemovePickupTarget(Item);
  if Ship.IsRecentlyDroppedItem(Item) then
    Ship.RecentlyDroppedItemIds.Delete(Ship.RecentlyDroppedItemIds.IndexOf(Item));
end;

procedure SF_DropItem(av: array of TVarEC; code: TCodeEC);
label
  Done;
var
  Ship: TShip;
  Item: TEquipment;
  Kind: TItemType;
  Index, SavedNoDrop: Integer;
  Found: Boolean;
  Equipped: Byte;
  Binding: TScriptItem;
begin
  Found := False;
  if High(av) < 2 then
    raise Exception.Create('Error.Script SF_DropItem');
  Ship := TShip(av[1].AsDword);
  if (av[2].ValueKind = vkDword) and (av[2].AsDword > $10000) then
  begin
    Item := TEquipment(av[2].AsDword);
    if High(av) >= 3 then
    begin
      Binding := TScriptItem(av[3].AsDword);
      if Binding.Item <> nil then
        Binding.Item.ScriptItem := nil;
      Binding.Item := Item;
      Item.ScriptItem := Binding;
    end;
    SavedNoDrop := Item.NoDropFlag;
    Item.NoDropFlag := 0;
    Ship.DropItemIntoStar(Item);
    if Ship.CurrentStar.Items.IndexOf(Item) >= 0 then
      Item.NoDropFlag := SavedNoDrop;
    Found := True;
  end
  else
  begin
    Kind := TItemType(av[2].AsInteger);
    Equipped := 0;
    if High(av) >= 3 then
      Equipped := av[3].AsInteger;
    for Index := 0 to Ship.Inventory.Count - 1 do
    begin
      Item := Ship.Inventory[Index];
      if Item.ItemType <> Kind then
        Continue;
      if Item.EquippedFlag <> Equipped then
        Continue;
      if High(av) >= 4 then
      begin
        Binding := TScriptItem(av[4].AsDword);
        if Binding.Item <> nil then
          Binding.Item.ScriptItem := nil;
        Binding.Item := Item;
        Item.ScriptItem := Binding;
      end;
      SavedNoDrop := Item.NoDropFlag;
      Item.NoDropFlag := 0;
      Ship.DropItemIntoStar(Item);
      if Ship.CurrentStar.Items.IndexOf(Item) >= 0 then
        Item.NoDropFlag := SavedNoDrop;
      Found := True;
      goto Done;
    end;
    for Index := 0 to Ship.Artefacts.Count - 1 do
    begin
      Item := Ship.Artefacts[Index];
      if Item.ItemType <> Kind then
        Continue;
      if Item.EquippedFlag <> Equipped then
        Continue;
      if High(av) >= 4 then
      begin
        Binding := TScriptItem(av[4].AsDword);
        if Binding.Item <> nil then
          Binding.Item.ScriptItem := nil;
        Binding.Item := Item;
        Item.ScriptItem := Binding;
      end;
      SavedNoDrop := Item.NoDropFlag;
      Item.NoDropFlag := 0;
      Ship.DropItemIntoStar(Item);
      if Ship.CurrentStar.Items.IndexOf(Item) >= 0 then
        Item.NoDropFlag := SavedNoDrop;
      Found := True;
      Break;
    end;
  end;
  Done:
  if not Found then
    raise Exception.Create('Error.Script SF_DropItem - item not found');
end;

procedure SF_DropScriptItem(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  Binding: TScriptItem;
  SavedNoDrop: Integer;
begin
  if High(av) <> 2 then
    raise Exception.Create('Error.Script DropScriptItem');
  Ship := TShip(av[1].AsDword);
  Binding := TScriptItem(av[2].AsDword);
  if (Binding.Item = nil)
      or ((Ship.Inventory.IndexOf(Binding.Item) < 0) and (Ship.Artefacts.IndexOf(Binding.Item) < 0))
      or not Ship.InNormalSpace then
    Exit;
  SavedNoDrop := Binding.Item.NoDropFlag;
  Binding.Item.NoDropFlag := 0;
  Ship.DropItemIntoStar(Binding.Item);
  if Binding.Item <> nil then
    Binding.Item.NoDropFlag := SavedNoDrop;
end;

procedure SF_DeleteEquipment(av: array of TVarEC; code: TCodeEC);
var
  Index: Integer;
  Ship: TShip;
  Item: TItem;
  Kind: TItemType;
begin
  if High(av) <> 2 then
    raise Exception.Create('Error.Script SF_DeleteEquipment');
  Ship := TShip(av[1].AsDword);
  Index := 0;
  Kind := TItemType(av[2].AsInteger);
  while Index < Ship.Inventory.Count do
  begin
    Item := Ship.Inventory[Index];
    if (Item.ScriptItem = nil) and (Item.ItemType = Kind) then
    begin
      Ship.Inventory.Delete(Index);
      Item.Free;
    end
    else
      Inc(Index);
  end;
  Ship.RefreshDerivedStats(True);
end;

procedure SF_Rnd(av: array of TVarEC; code: TCodeEC);
var
  LowValue, HighValue: Integer;
  Seed: Cardinal;
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script Rnd');
  if High(av) > 2 then
  begin
    Seed := av[3].AsDword;
    av[0].AsInteger := NextRandomIntRange(av[1].AsInteger, av[2].AsInteger, Seed);
  end
  else if Galaxy <> nil then
    av[0].AsInteger := NextRandomIntRange(av[1].AsInteger, av[2].AsInteger, Galaxy.RandomState)
  else
  begin
    LowValue := av[1].AsInteger;
    HighValue := av[2].AsInteger;
    av[0].AsInteger := LowValue + Random(HighValue - LowValue + 1);
  end;
end;

procedure SF_GameDateTxtByTurn(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) <> 1 then
    raise Exception.Create('Error.Script GameDateTxtByTurn');
  av[0].AsString := FormatGameTurnDate(av[1].AsInteger);
end;

procedure SF_StatusPlayer(av: array of TVarEC; code: TCodeEC);
begin
  case GetPlayer.GetDominantCareer of
    rcTrader: av[0].AsInteger := 1;
    rcWarrior: av[0].AsInteger := 0;
    rcPirate: av[0].AsInteger := -1;
  end;
end;

procedure SF_Id(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
begin
  if High(av) <> 1 then
    raise Exception.Create('Error.Script SF_Id');
  Obj := TObject(av[1].AsDword);
  if Obj is TShip then
    av[0].AsDword := TShip(Obj).Id
  else if Obj is TPlanet then
    av[0].AsDword := TPlanet(Obj).Id
  else if Obj is TStar then
    av[0].AsDword := TStar(Obj).Id
  else if Obj is TConstellation then
    av[0].AsDword := TConstellation(Obj).Id
  else if Obj is TItem then
    av[0].AsDword := TItem(Obj).Id
  else if Obj is THole then
    av[0].AsDword := THole(Obj).Id
  else if Obj is TMissile then
    av[0].AsDword := TMissile(Obj).Id
  else if Obj is TAsteroid then
    av[0].AsDword := TAsteroid(Obj).Id
  else
    raise Exception.Create('Error.Script SF_Id 2');
end;

procedure SF_GalaxyMoney(av: array of TVarEC; code: TCodeEC);
var
  Owner: TOwnerId;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script SF_GalaxyMoney');
  Owner := oiHuman;
  if High(av) >= 2 then
    Owner := TOwnerId(av[2].AsInteger);
  case av[1].AsInteger of
    0: av[0].AsInteger := Galaxy.ComputeScaledMiniMoney(Owner);
    1: av[0].AsInteger := Galaxy.ComputeScaledSmallMoney(Owner);
    2: av[0].AsInteger := Galaxy.ComputeScaledAverageMoney(Owner);
    3: av[0].AsInteger := Galaxy.ComputeScaledBigMoney(Owner);
    4: av[0].AsInteger := Galaxy.ComputeScaledHugeMoney(Owner);
  else
    raise Exception.Create('Error.Script SF_GalaxyMoney');
  end;
end;

procedure SF_SetName(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
begin
  if High(av) <> 2 then
    raise Exception.Create('Error.Script SF_SetName');
  Obj := TObject(av[1].AsDword);
  if Obj is TShip then
    TShip(Obj).Name := av[2].AsString
  else if Obj is TPlanet then
    TPlanet(Obj).Name := av[2].AsString
  else if Obj is TStar then
    TStar(Obj).Name := av[2].AsString
  else if Obj is TItem then
    TItem(Obj).NameOverride := av[2].AsString;
end;

procedure SF_UseTranclucator(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  Obj: TObject;
  Artefact: TArtefactTranclucator;
  Drone: TTranclucator;
  Index: Integer;
  Angle: Single;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script SF_UseTranclucator');
  av[0].AsDword := 0;
  Ship := TShip(av[1].AsDword);
  if not Ship.InHyperspace then
  begin
    Obj := nil;
    if High(av) > 1 then
      Obj := TObject(av[2].AsDword)
    else
      for Index := 0 to Ship.Artefacts.Count - 1 do
      begin
        Obj := Ship.Artefacts[Index];
        if (Obj is TArtefactTranclucator) and (TArtefactTranclucator(Obj).BrokenFlag = 0) then
          Break;
      end;
    if (Obj <> nil) and (Obj is TArtefactTranclucator) then
    begin
      Artefact := Obj as TArtefactTranclucator;
      Drone := TTranclucator(Artefact.Ship);
      Artefact.Ship := nil;
      Drone.CurrentStar := Ship.CurrentStar;
      Ship.CurrentStar.Ships.Add(Drone);
      if Ship.InNormalSpace then
      begin
        Angle := SeededRandomIntRange(0, 360, Drone.Id * (Ship.CurrentStar.GenerationSeed * Cardinal(Galaxy.CurrentTurn))) * Pi / 180;
        Drone.Position.X := Sin(Angle) * 100 + Ship.Position.X;
        Drone.Position.Y := Ship.Position.Y - Cos(Angle) * 100;
      end
      else if Ship.CurrentPlanet <> nil then
        Drone.CurrentPlanet := Ship.CurrentPlanet
      else if Ship.DockedTo <> nil then
        Drone.DockedTo := Ship.DockedTo;
      Drone.Graphic.SetPosition(Drone.Position);
      Drone.OwnerShip := Ship;
      Index := Ship.Artefacts.IndexOf(Artefact);
      if Index >= 0 then
        Ship.Artefacts.Delete(Index);
      Index := Ship.Inventory.IndexOf(Artefact);
      if Index >= 0 then
        Ship.Inventory.Delete(Index);
      Artefact.Free;
      Ship.RefreshDerivedStats(True);
      Drone.NextDay;
      av[0].AsDword := PtrUInt(Drone);
    end;
  end;
end;

procedure SF_HullDamage(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Hull: THull;
begin
  if High(av) <> 1 then
    raise Exception.Create('Error.Script HullDamage');
  Obj := TObject(av[1].AsDword);
  if Obj is TShip then
    Hull := TShip(Obj).GetHull
  else if Obj is TScriptItem then
    Hull := THull(TScriptItem(Obj).Item)
  else
    Hull := THull(Obj);
  av[0].AsInteger := 100 - Round(Hull.HullPoints / Hull.Weight * 100);
end;

procedure SF_Hitpoints(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Hull: THull;
begin
  if High(av) <> 1 then
    raise Exception.Create('Error.Script Hitpoints');
  Obj := TObject(av[1].AsDword);
  if Obj is TShip then
    Hull := TShip(Obj).GetHull
  else if Obj is TScriptItem then
    Hull := THull(TScriptItem(Obj).Item)
  else
    Hull := THull(Obj);
  av[0].AsInteger := Hull.HullPoints;
end;

procedure SF_Hit(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  Binding: TScriptShip;
begin
  if High(av) < 1 then
    Ship := CurrentScript.CurrentShip
  else
    Ship := TShip(av[1].AsDword);
  if Ship = nil then
    Exit;
  Binding := GetScriptShipBindingForContext(Ship, CurrentScript);
  if High(av) < 2 then
    av[0].AsInteger := Ord(Binding.Hit or Binding.HitPlayer)
  else if av[2].AsInteger <> 0 then
  begin
    av[0].AsInteger := Ord(Binding.HitPlayer);
    if High(av) > 2 then
      Binding.HitPlayer := av[3].AsInteger <> 0;
  end
  else
  begin
    av[0].AsInteger := Ord(Binding.Hit);
    if High(av) > 2 then
      Binding.Hit := av[3].AsInteger <> 0;
  end;
end;

procedure SF_ChangeGlobalRelationsShips(av: array of TVarEC; code: TCodeEC);
var
  Ranger: TObject;
  Scope: TObject;
  Mode: TRelationChangeMode;
  ShipTypes: THullShipTypeMask;
  Owners: TOwnerMask;
begin
  if High(av) <> 6 then
    raise Exception.Create('Error.Script ChangeGlobalRelationsShips');
  if av[1].AsDword = 0 then
    Exit;
  Ranger := TObject(av[1].AsDword);
  if (Ranger = nil) or not (Ranger is TRanger) then
    Exit;
  if (av[2].AsDword > 0) and (av[2].AsDword < $FF) then
    Scope := TScriptConstellation(CurrentScript.Constellations[av[2].AsDword]).Constellation
  else if av[2].AsDword <> 0 then
    Scope := TObject(av[2].AsDword)
  else
    Scope := nil;
  case av[3].AsDword of
    0: Mode := rcmCapAt;
    1: Mode := rcmRaiseTo;
    2: Mode := rcmIncrease;
    3: Mode := rcmDecrease;
  else
    Mode := rcmCapAt;
  end;
  ShipTypes := THullShipTypeMask(Word(av[5].AsDword));
  Owners := TOwnerMask(Byte(av[6].AsDword));
  TRanger(Ranger).ChangeShipRelations(Scope, Mode, av[4].AsInteger, ShipTypes, Owners);
end;

procedure SF_ChangeGlobalRelationsPlanets(av: array of TVarEC; code: TCodeEC);
var
  Ranger: TObject;
  Scope: TObject;
  Mode: TRelationChangeMode;
  Owners: TOwnerMask;
begin
  if High(av) <> 5 then
    raise Exception.Create('Error.Script ChangeGlobalRelationsPlanets');
  Ranger := TObject(av[1].AsDword);
  if (Ranger = nil) or not (Ranger is TRanger) then
    Exit;
  if (av[2].AsDword > 0) and (av[2].AsDword < $FF) then
    Scope := TScriptConstellation(CurrentScript.Constellations[av[2].AsDword]).Constellation
  else if av[2].AsDword <> 0 then
    Scope := TObject(av[2].AsDword)
  else
    Scope := nil;
  case av[3].AsDword of
    0: Mode := rcmCapAt;
    1: Mode := rcmRaiseTo;
    2: Mode := rcmIncrease;
    3: Mode := rcmDecrease;
  else
    Mode := rcmCapAt;
  end;
  Owners := TOwnerMask(Byte(av[5].AsDword));
  TRanger(Ranger).ChangePlanetRelations(Scope, Mode, av[4].AsInteger, Owners);
end;

procedure SF_GlobalRelationsShips(av: array of TVarEC; code: TCodeEC);
var
  Ranger: TObject;
  Scope: TObject;
  ShipTypes: THullShipTypeMask;
  Owners: TOwnerMask;
begin
  if High(av) <> 4 then
    raise Exception.Create('Error.Script GlobalRelationsShips');
  Ranger := TObject(av[1].AsDword);
  if (Ranger = nil) or not (Ranger is TRanger) then
    Exit;
  if (av[2].AsDword > 0) and (av[2].AsDword < $FF) then
    Scope := TScriptConstellation(CurrentScript.Constellations[av[2].AsDword]).Constellation
  else if av[2].AsDword <> 0 then
    Scope := TObject(av[2].AsDword)
  else
    Scope := nil;
  ShipTypes := THullShipTypeMask(Word(av[3].AsDword));
  Owners := TOwnerMask(Byte(av[4].AsDword));
  av[0].AsInteger := TRanger(Ranger).GlobalRelationsShips(Scope, ShipTypes, Owners);
end;

procedure SF_GlobalRelationsPlanets(av: array of TVarEC; code: TCodeEC);
var
  Ranger: TObject;
  Scope: TObject;
  Owners: TOwnerMask;
begin
  if High(av) <> 3 then
    raise Exception.Create('Error.Script GlobalRelationsPlanets');
  Ranger := TObject(av[1].AsDword);
  if (Ranger = nil) or not (Ranger is TRanger) then
    Exit;
  if (av[2].AsDword > 0) and (av[2].AsDword < $FF) then
    Scope := TScriptConstellation(CurrentScript.Constellations[av[2].AsDword]).Constellation
  else if av[2].AsDword <> 0 then
    Scope := TObject(av[2].AsDword)
  else
    Scope := nil;
  Owners := TOwnerMask(Byte(av[3].AsDword));
  av[0].AsInteger := TRanger(Ranger).GlobalRelationsPlanets(Scope, Owners);
end;

procedure SF_SetRelationGroup(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) <> 3 then
    raise Exception.Create('Error.Script SetRelationGroup');
  CurrentScript.SetGroupRelation(av[1].AsInteger, av[2].AsInteger, TRelationLevel(av[3].AsInteger));
end;

procedure SF_SetRelationPlanet(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) <> 3 then
    raise Exception.Create('Error.Script SetRelationPlanet');
  CurrentScript.SetPlanetRelation(av[2].AsInteger, TPlanet(av[1].AsDword), TRelationLevel(av[3].AsInteger));
end;

procedure SF_GetRelationPlanet(av: array of TVarEC; code: TCodeEC);
var
  Planet: TPlanet;
begin
  if High(av) <> 2 then
    raise Exception.Create('Error.Script GetRelationPlanet');
  Planet := TPlanet(av[1].AsDword);
  av[0].AsDword := Planet.RelationToShip(TShip(av[2].AsDword));
end;

procedure SF_CurTurn(av: array of TVarEC; code: TCodeEC);
begin
  av[0].AsInteger := Galaxy.CurrentTurn;
  if High(av) > 0 then
    Galaxy.CurrentTurn := av[1].AsInteger;
end;

procedure SF_ShipType(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script ShipType');
  Ship := TShip(av[1].AsDword);
  if GetPlayer.RuinsProxy = Ship then
    av[0].AsString := 'PlayerBridge'
  else if Ship.TypeNameOverrideKey <> '' then
    av[0].AsString := Ship.TypeNameOverrideKey
  else if (Ship.ScriptShip <> nil)
      and (TScriptShip(Ship.ScriptShip).Script.ScriptFileName = 'Script.PC_fem_rangers')
      and (TScriptShip(Ship.ScriptShip).GetGroup.Name = 'GroupFem') then
    av[0].AsString := 'FemRanger'
  else
    av[0].AsString := Ship.GetTypeNameKey;
  if High(av) > 1 then
  begin
    if av[2].AsString = Ship.GetTypeNameKey then
      Ship.TypeNameOverrideKey := ''
    else
      Ship.TypeNameOverrideKey := av[2].AsString;
  end;
end;

procedure SF_ConName(av: array of TVarEC; code: TCodeEC);
var
  Constellation: TConstellation;
begin
  if High(av) <> 1 then
    raise Exception.Create('Error.Script ConName');
  if av[1].AsDword < Cardinal(Galaxy.Constellations.Count) then
    Constellation := Galaxy.Constellations[av[1].AsDword]
  else
    Constellation := TConstellation(av[1].AsDword);
  av[0].AsString := Constellation.GetName;
end;

procedure SF_StarName(av: array of TVarEC; code: TCodeEC);
var
  Obj: TStar;
begin
  if High(av) <> 1 then
    raise Exception.Create('Error.Script StarName');
  Obj := TStar(av[1].AsDword);
  av[0].AsString := Obj.Name;
end;

procedure SF_StarMapLabel(av: array of TVarEC; code: TCodeEC);
var
  Star: TStar;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script StarMapLabel');
  Star := TStar(av[1].AsDword);
  av[0].AsString := Star.MapLabel;
  if High(av) > 1 then
    Star.MapLabel := av[2].AsString;
end;

procedure SF_PlanetName(av: array of TVarEC; code: TCodeEC);
var
  Obj: TPlanet;
begin
  if High(av) <> 1 then
    raise Exception.Create('Error.Script PlanetName');
  Obj := TPlanet(av[1].AsDword);
  av[0].AsString := Obj.Name;
end;

procedure SF_IdToPlanet(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) <> 1 then
    raise Exception.Create('Error.Script IdToPlanet');
  av[0].AsDword := PtrUInt(Galaxy.IdToPlanet(av[1].AsDword));
end;

procedure SF_IdToShip(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script IdToShip');
  av[0].AsDword := PtrUInt(Galaxy.IdToShip(av[1].AsDword, (High(av) > 1) and (av[2].AsInteger <> 0)));
end;

procedure SF_IdToItem(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) <> 1 then
    raise Exception.Create('Error.Script IdToItem');
  av[0].AsDword := PtrUInt(Galaxy.IdToItem(av[1].AsDword, False));
end;

procedure SF_PlanetSetGoods(av: array of TVarEC; code: TCodeEC);
var
  GoodsIndex: TGoodsIndex;
begin
  if High(av) <> 3 then
    raise Exception.Create('Error.Script PlanetSetGoods');
  GoodsIndex := av[2].AsInteger;
  TPlanet(av[1].AsDword).Goods[GoodsIndex].Count := av[3].AsInteger;
end;

procedure SF_ShipName(av: array of TVarEC; code: TCodeEC);
var
  Obj: TShip;
begin
  if High(av) <> 1 then
    raise Exception.Create('Error.Script ShipName');
  Obj := TShip(av[1].AsDword);
  av[0].AsString := Obj.GetName;
end;

procedure SF_ShipRank(av: array of TVarEC; code: TCodeEC);
var
  Ship: TNormalShip;
begin
  if High(av) <> 1 then
    raise Exception.Create('Error.Script ShipRank');
  Ship := TObject(av[1].AsDword) as TNormalShip;
  av[0].AsInteger := Ship.Rank;
end;

procedure SF_ShipRankPoints(av: array of TVarEC; code: TCodeEC);
var
  Ship: TNormalShip;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script ShipRankPoints');
  Ship := TObject(av[1].AsDword) as TNormalShip;
  av[0].AsInteger := Ship.RankPoints;
  if High(av) > 1 then
    Ship.RankPoints := av[2].AsInteger;
end;

procedure SF_ShipNextRankPoints(av: array of TVarEC; code: TCodeEC);
var
  Ship: TNormalShip;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script ShipNextRankPoints');
  Ship := TObject(av[1].AsDword) as TNormalShip;
  av[0].AsInteger := CoalitionRankPointThresholds[Ship.Rank];
end;

procedure SF_ShipRaiseRank(av: array of TVarEC; code: TCodeEC);
var
  Ship: TNormalShip;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script ShipRaiseRank');
  Ship := TObject(av[1].AsDword) as TNormalShip;
  if High(av) > 1 then
  begin
    Ship.Rank := av[2].AsInteger;
    Ship.RankPoints := 0;
  end
  else
    Ship.TryPromoteRank;
end;

procedure SF_ShipStar(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) <> 1 then
    raise Exception.Create('Error.Script ShipStar');
  Ship := TShip(av[1].AsDword);
  av[0].AsDword := PtrUInt(Ship.CurrentStar);
end;

procedure SF_StarToCon(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) <> 1 then
    raise Exception.Create('Error.Script StarToCon');
  av[0].AsDword := PtrUInt(TStar(av[1].AsDword).Constellation);
end;

procedure SF_ConNear(av: array of TVarEC; code: TCodeEC);
var
  I, Count, J, ArgCount: Integer;
  Constellation, Neighbor, Candidate: TConstellation;
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script ConNear');
  Constellation := TConstellation(av[1].AsDword);
  Count := Constellation.AdjacentConstellations.Count;
  ArgCount := High(av) - 1;
  for I := 0 to Count - 1 do
  begin
    Neighbor := Constellation.AdjacentConstellations[I];
    for J := 0 to ArgCount - 1 do
    begin
      Candidate := TConstellation(av[2 + J].AsDword);
      if Neighbor = Candidate then
      begin
        av[0].AsInteger := 1;
        Exit;
      end;
    end;
  end;
  av[0].AsInteger := 0;
end;

procedure SF_ConStars(av: array of TVarEC; code: TCodeEC);
var
  Constellation: TConstellation;
begin
  if High(av) <> 1 then
    raise Exception.Create('Error.Script ConStars');
  Constellation := TConstellation(av[1].AsDword);
  av[0].AsInteger := Constellation.Stars.Count;
end;

procedure SF_ConStar(av: array of TVarEC; code: TCodeEC);
var
  Constellation: TConstellation;
  Index: Integer;
begin
  if High(av) <> 2 then
    raise Exception.Create('Error.Script ConStar');
  Constellation := TConstellation(av[1].AsDword);
  Index := av[2].AsInteger;
  if (Index < 0) or (Index >= Constellation.Stars.Count) then
    av[0].AsDword := 0
  else
    av[0].AsDword := PtrUInt(Constellation.Stars[Index]);
end;

procedure SF_GalaxyStars(av: array of TVarEC; code: TCodeEC);
begin
  av[0].AsInteger := Galaxy.Stars.Count;
end;

procedure SF_GalaxyStar(av: array of TVarEC; code: TCodeEC);
var
  Index: Integer;
begin
  if High(av) <> 1 then
    raise Exception.Create('Error.Script GalaxyStar');
  Index := av[1].AsInteger;
  if (Index < 0) or (Index >= Galaxy.Stars.Count) then
    av[0].AsDword := 0
  else
    av[0].AsDword := PtrUInt(Galaxy.Stars[Index]);
end;

procedure SF_StarAngleBetween(av: array of TVarEC; code: TCodeEC);
var
  Star1, CenterStar, Star2: TStar;
  MinAngle, MaxAngle, Angle: Single;
begin
  if High(av) <> 5 then
    raise Exception.Create('Error.Script StarAngleBetween');
  Star1 := TStar(av[1].AsDword);
  CenterStar := TStar(av[2].AsDword);
  Star2 := TStar(av[3].AsDword);
  MinAngle := av[4].AsFloat;
  MaxAngle := av[5].AsFloat;
  Angle :=
      Abs(
          HeadingDifferenceDegrees(
              PointBearingDegrees(CenterStar.Position, Star1.Position),
              PointBearingDegrees(CenterStar.Position, Star2.Position)
          )
      );
  if (Angle >= MinAngle) and (Angle <= MaxAngle) then
    av[0].AsInteger := 1
  else
    av[0].AsInteger := 0;
end;

procedure SF_FindPlanet(av: array of TVarEC; code: TCodeEC);
var
  Star: TStar;
  Planet: TPlanet;
  Filters, Filter: WideString;
  MinFraction, MaxFraction: Single;
  I, Count, J, FilterCount: Integer;
  Planets: TList;
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script FindPlanet');
  Star := TStar(av[1].AsDword);
  Filters := av[2].AsString;
  if High(av) >= 3 then
    MinFraction := av[3].AsFloat / 100
  else
    MinFraction := 0;
  if High(av) >= 4 then
    MaxFraction := av[4].AsFloat / 100
  else
    MaxFraction := 1;
  Planets := TList.Create;
  Count := Star.Planets.Count;
  FilterCount := CountDelimitedPartsW(Filters, ',');
  for I := 0 to Count - 1 do
  begin
    Planet := Star.Planets[I];
    // Native $609AC2 exhausts to FilterCount; define empty filters as accept-all.
    J := 0;
    while J < FilterCount do
    begin
      Filter := ExtractDelimitedPartW(Filters, J, ',');
      if (Filter = 'NotMaloc') and (Planet.OwnerId = oiMaloc) then
        Break;
      if (Filter = 'NotPeleng') and (Planet.OwnerId = oiPeleng) then
        Break;
      if (Filter = 'NotPeople') and (Planet.OwnerId = oiHuman) then
        Break;
      if (Filter = 'NotFei') and (Planet.OwnerId = oiFeyan) then
        Break;
      if (Filter = 'NotGaal') and (Planet.OwnerId = oiGaal) then
        Break;
      if (Filter = 'NotKling') and (Planet.OwnerId = oiDominator) then
        Break;
      if (Filter = 'NotPirateClan') and (Planet.OwnerId = oiPirate) then
        Break;
      if (Filter = 'NotNone') and (Planet.OwnerId = oiUninhabited) then
        Break;
      Inc(J);
    end;
    if J >= FilterCount then
      Planets.Add(Planet);
  end;
  if Planets.Count < 1 then
  begin
    av[0].AsDword := 0;
    Planets.Free;
    Exit;
  end;
  begin
    I := Round((Planets.Count - 1) * MinFraction);
    J := Round((Planets.Count - 1) * MaxFraction);
    I := I + NextRandomIntRange(0, J - I, Star.RandomState);
    av[0].AsDword := PtrUInt(Planets[I]);
  end;
  Planets.Free;
end;

procedure SF_ShipCanJump(av: array of TVarEC; code: TCodeEC);
var
  FromStar, ToStar: TStar;
  I, Count, JumpRange, Fuel, Distance: Integer;
  CheckFuel: Boolean;
  Ship: TShip;
begin
  if High(av) < 3 then
    raise Exception.Create('Error.Script CanJump');
  Ship := TShip(av[1].AsDword);
  av[0].AsInteger := 0;
  if (Ship.GetFuelTanks = nil) or (Ship.GetEngine = nil) then
    Exit;
  JumpRange := Ship.GetJumpRange;
  Count := High(av) - 1;
  Fuel := 0;
  CheckFuel := False;
  if (av[Count + 1].ValueKind = vkInt) and (av[Count + 1].AsInteger = 1) then
  begin
    CheckFuel := True;
    Fuel := Ship.GetFuelTanks.Fuel;
    Dec(Count);
  end;
  for I := 2 to Count do
  begin
    FromStar := TStar(av[I].AsDword);
    ToStar := TStar(av[I + 1].AsDword);
    Distance := Round(PointDistance(ToStar.Position, FromStar.Position));
    if CheckFuel then
    begin
      JumpRange := Min(JumpRange, Fuel);
      Dec(Fuel, Distance);
    end;
    if Distance > JumpRange then
      Exit;
  end;
  av[0].AsInteger := 1;
end;

procedure SF_ShipInStar(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) <> 2 then
    raise Exception.Create('Error.Script ShipInStar');
  if (av[1].AsDword <> 0) and (TShip(av[1].AsDword).CurrentStar = TStar(av[2].AsDword)) then
    av[0].AsInteger := 1
  else
    av[0].AsInteger := 0;
end;

procedure SF_ShipInPlanet(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) <> 2 then
    raise Exception.Create('Error.Script ShipInPlanet');
  if TShip(av[1].AsDword).CurrentPlanet = TPlanet(av[2].AsDword) then
    av[0].AsInteger := 1
  else
    av[0].AsInteger := 0;
end;

procedure SF_ShipStatistic(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  NormalShip: TNormalShip;
  Ship: TShip;
  I: Integer;
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script ShipStatistic');
  Obj := TObject(av[1].AsDword);
  NormalShip := nil;
  if Obj is TNormalShip then
  begin
    NormalShip := TNormalShip(Obj);
    Ship := NormalShip;
  end
  else if (Obj is TShip) and (av[2].AsInteger in [10, 11]) then
    Ship := TShip(Obj)
  else
    raise Exception.Create('Error.Script ShipStatistic - illegal object type');
  case av[2].AsInteger of
    0:
    begin
      av[0].AsInteger := NormalShip.TotalShipKillCount;
      if High(av) > 2 then
        NormalShip.TotalShipKillCount := av[3].AsInteger;
    end;
    1:
    begin
      av[0].AsInteger := NormalShip.PirateKillCount;
      if High(av) > 2 then
        NormalShip.PirateKillCount := av[3].AsInteger;
    end;
    2:
    begin
      av[0].AsInteger := NormalShip.DominatorKillCount;
      if High(av) > 2 then
        NormalShip.DominatorKillCount := av[3].AsInteger;
    end;
    3:
    begin
      av[0].AsInteger := NormalShip.LiberatedSystemCount;
      if High(av) > 2 then
        NormalShip.LiberatedSystemCount := av[3].AsInteger;
    end;
    4:
    begin
      av[0].AsInteger := NormalShip.CivilianKillCount;
      if High(av) > 2 then
        NormalShip.CivilianKillCount := av[3].AsInteger;
    end;
    5:
    begin
      av[0].AsInteger := NormalShip.MilitaryKillCount;
      if High(av) > 2 then
        NormalShip.MilitaryKillCount := av[3].AsInteger;
    end;
    6:
    begin
      av[0].AsInteger := NormalShip.RangerKillCount;
      if High(av) > 2 then
        NormalShip.RangerKillCount := av[3].AsInteger;
    end;
    7:
      if GetPlayer = NormalShip then
      begin
        av[0].AsInteger := GetPlayer.BlackHoleKillCount;
        if High(av) > 2 then
          GetPlayer.BlackHoleKillCount := av[3].AsInteger;
      end;
    8:
      if GetPlayer = NormalShip then
      begin
        av[0].AsInteger := GetPlayer.HyperspaceKillCount;
        if High(av) > 2 then
          GetPlayer.HyperspaceKillCount := av[3].AsInteger;
      end;
    9:
    begin
      av[0].AsInteger := NormalShip.TradeLossBalance;
      if High(av) > 2 then
        NormalShip.TradeLossBalance := av[3].AsInteger;
    end;
    10:
    begin
      av[0].AsDword := PtrUInt(Ship.HomePlanet);
      if High(av) > 2 then
      begin
        if Ship is TWarrior then
        begin
          I := Ship.HomePlanet.Warriors.IndexOf(Ship);
          if I >= 0 then
            Ship.HomePlanet.Warriors.Delete(I);
          TPlanet(av[3].AsDword).Warriors.Add(Ship);
        end
        else if Ship is TTransport then
        begin
          Dec(Ship.HomePlanet.HomeTransportCount);
          Inc(TPlanet(av[3].AsDword).HomeTransportCount);
        end
        else if Ship is TRanger then
        begin
          Dec(Ship.HomePlanet.HomeRangerCount);
          Inc(TPlanet(av[3].AsDword).HomeRangerCount);
        end;
        Ship.HomePlanet := TPlanet(av[3].AsDword);
      end;
    end;
    11:
    begin
      av[0].AsInteger := Ship.CreationTurn;
      if High(av) > 2 then
        Ship.CreationTurn := av[3].AsInteger;
    end;
    12: av[0].AsInteger := NormalShip.CalculateMass;
    13:
    begin
      av[0].AsInteger := NormalShip.ContrabandProfit;
      if High(av) > 2 then
        NormalShip.ContrabandProfit := av[3].AsInteger;
    end;
  else
    raise Exception.Create('Error.Script ShipStatistic');
  end;
end;

procedure SF_PlayerDominatorStatistic(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script PlayerDominatorStatistic');
  av[0].AsInteger := GetPlayer.DominatorKillsByType[TKlingType(av[1].AsInteger)];
  if High(av) > 1 then
    GetPlayer.DominatorKillsByType[TKlingType(av[1].AsInteger)] := av[2].AsInteger;
end;

procedure SF_ShipMoney(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script ShipMoney');
  Ship := TShip(av[1].AsDword);
  av[0].AsInteger := Ship.Money;
  if High(av) >= 2 then
    Ship.SetMoney(Max(0, av[2].AsInteger));
end;

procedure SF_ShipFuel(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script ShipFuel');
  Ship := TShip(av[1].AsDword);
  if (Ship = nil) or (Ship.GetFuelTanks = nil) then
    av[0].AsInteger := 0
  else
    av[0].AsInteger := Ship.GetFuelTanks.Fuel;
  if (High(av) >= 2) and (Ship.GetFuelTanks <> nil) then
  begin
    Ship.GetFuelTanks.Fuel := av[2].AsInteger;
    if Ship.GetFuelTanks.Fuel < 0 then
      Ship.GetFuelTanks.Fuel := 0;
  end;
end;

procedure SF_ShipFuelLow(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) <> 1 then
    raise Exception.Create('Error.Script ShipFuelLow');
  Ship := TShip(av[1].AsDword);
  if Ship.GetFuelTanks = nil then
    av[0].AsInteger := 1
  else if Ship.GetFuelTanks.Fuel < Ship.GetFuelTanks.Capacity then
    av[0].AsInteger := 1
  else
    av[0].AsInteger := 0;
end;

procedure SF_ShipStrengthInBestRanger(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) <> 1 then
    raise Exception.Create('Error.Script ShipStrengthInBestRanger');
  Ship := TShip(av[1].AsDword);
  av[0].AsFloat := Ship.StrengthInBestRanger;
end;

procedure SF_ShipStrengthInAverageRanger(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) <> 1 then
    raise Exception.Create('Error.Script ShipStrength');
  Ship := TShip(av[1].AsDword);
  av[0].AsFloat := Ship.Strength / Galaxy.AverageRangerStrength;
end;

procedure SF_ChanceToWin(av: array of TVarEC; code: TCodeEC);
var
  Ship, Target: TShip;
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script ChanceToWin');
  Ship := TShip(av[1].AsDword);
  Target := TShip(av[2].AsDword);
  if (High(av) > 2) and (av[3].AsInteger <> 0) then
    av[0].AsFloat := Ship.ChanceToWin(Target)
  else
    av[0].AsInteger := Ship.GetWinChancePercent(Target);
end;

procedure SF_RangerStatus(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script RangerStatus');
  Obj := TObject(av[1].AsDword);
  if High(av) > 1 then
  begin
    if av[2].AsString = 'EminentWarrior' then
      av[0].AsInteger := Ord(Galaxy.EminentCareerShips[rcWarrior] = Obj)
    else if av[2].AsString = 'EminentTrader' then
      av[0].AsInteger := Ord(Galaxy.EminentCareerShips[rcTrader] = Obj)
    else if av[2].AsString = 'EminentPirate' then
      av[0].AsInteger := Ord(Galaxy.EminentCareerShips[rcPirate] = Obj)
    else
      raise Exception.Create(AnsiString('Error.Script RangerStatus - unknown keyword ' + av[2].AsString));
    Exit;
  end;
  if not (Obj is TRanger) then
    raise Exception.Create('Error.Script RangerStatus 2');
  av[0].AsInteger := Ord((Obj as TRanger).GetDominantCareer);
end;

procedure SF_RangerPlaceInRating(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
begin
  if High(av) <> 1 then
    raise Exception.Create('Error.Script RangerPlaceInRating');
  Obj := TObject(av[1].AsDword);
  if not (Obj is TRanger) then
    raise Exception.Create('Error.Script RangerPlaceInRating 2');
  av[0].AsInteger := (Obj as TRanger).PlaceInRating;
end;

procedure SF_RangerExcludedFromRating(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Ranger: TRanger;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script RangerExcludedFromRating');
  Obj := TObject(av[1].AsDword);
  if not (Obj is TRanger) then
    raise Exception.Create('Error.Script RangerExcludedFromRating 2');
  Ranger := TRanger(Obj);
  av[0].AsInteger := Ord(Ranger.ExcludedFromRating);
  if High(av) <= 1 then
    Exit;
  Ranger.ExcludedFromRating := av[2].AsInteger <> 0;
  if Ranger.ExcludedFromRating then
  begin
    if Galaxy.EminentCareerShips[rcTrader] = Ranger then
      Galaxy.EminentCareerShips[rcTrader] := nil;
    if Galaxy.EminentCareerShips[rcPirate] = Ranger then
      Galaxy.EminentCareerShips[rcPirate] := nil;
    if Galaxy.EminentCareerShips[rcWarrior] = Ranger then
      Galaxy.EminentCareerShips[rcWarrior] := nil;
  end;
end;

procedure SF_ShipFind(av: array of TVarEC; code: TCodeEC);
var
  Kind: TShipType;
  Star: TStar;
  Ship: TShip;
  I: Integer;
begin
  if High(av) <> 1 then
    raise Exception.Create('Error.Script ShipFind');
  av[0].AsDword := 0;
  if GetPlayer <> nil then
  begin
    Kind := TShipType(av[1].AsInteger);
    Star := GetPlayer.CurrentStar;
    for I := 0 to Star.Ships.Count - 1 do
    begin
      Ship := Star.Ships[I];
      if Ship.TypeId = Kind then
      begin
        av[0].AsDword := PtrUInt(Ship);
        Exit;
      end;
    end;
  end;
end;

procedure SF_ShipDestroy(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script ShipDestroy');
  if av[1].AsDword = 0 then
  begin
    av[0].AsInteger := 0;
    Exit;
  end;

  av[0].AsInteger := Ord(TShip(av[1].AsDword).DestroyQueued);
  if High(av) <= 1 then
    TShip(av[1].AsDword).DestroyQueued := True
  else if av[2].AsInteger >= 0 then
    TShip(av[1].AsDword).DestroyQueued := Boolean(av[2].AsInteger);
end;

procedure SF_ShipDestroyType(av: array of TVarEC; code: TCodeEC);
var
  I, J: Integer;
  Star: TStar;
  Ship: TShip;
  Kind: Integer;
begin
  if High(av) <> 1 then
    raise Exception.Create('Error.Script ShipDestroyType');
  Kind := av[1].AsInteger;
  for I := 0 to Galaxy.Stars.Count - 1 do
  begin
    Star := Galaxy.Stars[I];
    for J := 0 to Star.Ships.Count - 1 do
    begin
      Ship := Star.Ships[J];
      if (Kind = 1)
          and (Ship.TypeId = stKling)
          and (TKling(Ship).DominatorSeries = dsBlazer)
          and (TKling(Ship).KlingType <> ktBoss)
          and not Ship.HasIndependentScriptFaction then
        Ship.DestroyQueued := True;
    end;
  end;
end;

procedure SF_ItemDestroy(av: array of TVarEC; code: TCodeEC);
var
  Item: TItem;
  Obj: TObject;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script ItemDestroy');
  Obj := TObject(av[1].AsDword);
  Item := nil;
  if Obj is TItem then
    Item := TItem(Obj);
  if Obj is TScriptItem then
    Item := TScriptItem(Obj).Item;
  if Item <> nil then
  begin
    av[0].AsInteger := Item.DestroyFlag;
    if High(av) > 1 then
      Item.DestroyFlag := av[2].AsInteger;
  end;
end;

procedure SF_RangersCapital(av: array of TVarEC; code: TCodeEC);
begin
  av[0].AsInteger := Galaxy.AverageRangerCapital;
end;

procedure SF_GroupToShip(av: array of TVarEC; code: TCodeEC);
var
  Count: Integer;
  Binding: TScriptShip;
  I, GroupIndex: Integer;
  Ship: TShip;
begin
  if High(av) <> 1 then
    raise Exception.Create('Error.Script GroupToShip');
  GroupIndex := av[1].AsInteger;
  Ship := nil;
  Count := CurrentScript.Ships.Count;
  for I := 0 to Count - 1 do
  begin
    Binding := CurrentScript.Ships[I];
    if Binding.GroupIndex = GroupIndex then
    begin
      Ship := Binding.Ship;
      if Ship <> GetPlayer then
      begin
        av[0].AsDword := PtrUInt(Ship);
        Exit;
      end;
    end;
  end;
  av[0].AsDword := PtrUInt(Ship);
end;

procedure SF_OrderJump(av: array of TVarEC; code: TCodeEC);
var
  Absolute: Boolean;
  SavedOrderLock: Byte;
  Ship: TShip;
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script OrderJump');
  Absolute := False;
  if High(av) >= 3 then
    Absolute := Boolean(av[3].AsInteger);
  Ship := TShip(av[1].AsDword);
  if Ship = nil then
    Exit;
  if Ship.CurrentPlanet <> nil then
    AppendLogLineThreadSafe(
        AnsiString('Warning! ' + GetScriptContextDescription + ' orders ship ' + Ship.GetFullName(' ') + ' to jump while landed on planet!')
    );
  SavedOrderLock := Ship.AbsoluteScriptOrder;
  Ship.AbsoluteScriptOrder := 0;
  Ship.OrderJump(TStar(av[2].AsDword), Absolute);
  Ship.AbsoluteScriptOrder := SavedOrderLock;
  if GetPlayer = Ship then
    PendingPlayerFollowTarget := nil;
  if (GetPlayer = Ship) and (GetInnermostScreenLoop = StarMapScreen) and (StarMapScreen.Mode = smmOrders) then
  begin
    StarMapScreen.ClearPathOverlay(True);
    StarMapScreen.BuildShipPathOverlay(Ship, False, '');
  end;
end;

procedure SF_OrderLanding(av: array of TVarEC; code: TCodeEC);
var
  Absolute: Boolean;
  SavedOrderLock: Byte;
  Ship: TShip;
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script OrderLanding');
  Absolute := False;
  if High(av) >= 3 then
    Absolute := Boolean(av[3].AsInteger);
  Ship := TShip(av[1].AsDword);
  if Ship = nil then
    Exit;
  SavedOrderLock := Ship.AbsoluteScriptOrder;
  Ship.AbsoluteScriptOrder := 0;
  Ship.OrderLanding(TObject(av[2].AsDword), Absolute);
  Ship.AbsoluteScriptOrder := SavedOrderLock;
  if GetPlayer = Ship then
    PendingPlayerFollowTarget := nil;
  if (GetPlayer = Ship) and (GetInnermostScreenLoop = StarMapScreen) and (StarMapScreen.Mode = smmOrders) then
  begin
    StarMapScreen.ClearPathOverlay(True);
    StarMapScreen.BuildShipPathOverlay(Ship, False, '');
  end;
end;

procedure SF_IsPlayer(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) <> 1 then
    raise Exception.Create('Error.Script IsPlayer');
  Ship := TShip(av[1].AsDword);
  av[0].AsInteger := Ord(GetPlayer = Ship);
end;

procedure SF_GroupCount(av: array of TVarEC; code: TCodeEC);
var
  Binding: TScriptShip;
  I, ShipCount, GroupIndex, Count: Integer;
begin
  if High(av) <> 1 then
    raise Exception.Create('Error.Script GroupCount');
  GroupIndex := av[1].AsInteger;
  Count := 0;
  ShipCount := CurrentScript.Ships.Count;
  for I := 0 to ShipCount - 1 do
  begin
    Binding := CurrentScript.Ships[I];
    if Binding.GroupIndex = GroupIndex then
      Inc(Count);
  end;
  av[0].AsInteger := Count;
end;

procedure SF_GroupIn(av: array of TVarEC; code: TCodeEC);
var
  GroupIndex: Integer;
  Location: TObject;
  I, Count: Integer;
  Binding: TScriptShip;
  Found: Boolean;
begin
  if High(av) <> 2 then
    raise Exception.Create('Error.Script GroupIn');
  GroupIndex := av[1].AsInteger;
  Location := TObject(av[2].AsDword);
  Found := False;
  if Location is TConstellation then
  begin
    Count := CurrentScript.Ships.Count;
    for I := 0 to Count - 1 do
    begin
      Binding := CurrentScript.Ships[I];
      if Binding.GroupIndex <> GroupIndex then
        Continue;
      if Binding.Ship.CurrentStar.Constellation <> Location then
      begin
        av[0].AsInteger := 0;
        Exit;
      end;
      Found := True;
    end;
  end
  else if Location is TStar then
  begin
    Count := CurrentScript.Ships.Count;
    for I := 0 to Count - 1 do
    begin
      Binding := CurrentScript.Ships[I];
      if Binding.GroupIndex <> GroupIndex then
        Continue;
      if Binding.Ship.CurrentStar <> Location then
      begin
        av[0].AsInteger := 0;
        Exit;
      end;
      Found := True;
    end;
  end
  else if Location is TPlanet then
  begin
    Count := CurrentScript.Ships.Count;
    for I := 0 to Count - 1 do
    begin
      Binding := CurrentScript.Ships[I];
      if Binding.GroupIndex <> GroupIndex then
        Continue;
      if (Binding.Ship = GetPlayer) and (GetPlayer.RuinsMode <> 0) then
      begin
        if GetPlayer.RuinsSavedPlanet <> Location then
        begin
          av[0].AsInteger := 0;
          Exit;
        end;
      end
      else
      begin
        if not Binding.Ship.IsOnPlanet or (Binding.Ship.CurrentPlanet <> Location) then
        begin
          av[0].AsInteger := 0;
          Exit;
        end;
        Found := True;
      end;
    end;
  end
  else if Location is TShip then
  begin
    Count := CurrentScript.Ships.Count;
    for I := 0 to Count - 1 do
    begin
      Binding := CurrentScript.Ships[I];
      if Binding.GroupIndex <> GroupIndex then
        Continue;
      if (Binding.Ship = GetPlayer) and (GetPlayer.RuinsMode <> 0) then
      begin
        if GetPlayer.RuinsSavedDockedTo <> Location then
        begin
          av[0].AsInteger := 0;
          Exit;
        end;
      end
      else
      begin
        if not Binding.Ship.IsDockedToShip or (Binding.Ship.DockedTo <> Location) then
        begin
          av[0].AsInteger := 0;
          Exit;
        end;
        Found := True;
      end;
    end;
  end
  else if Location is TScriptPlace then
  begin
    Count := CurrentScript.Ships.Count;
    for I := 0 to Count - 1 do
    begin
      Binding := CurrentScript.Ships[I];
      if Binding.GroupIndex <> GroupIndex then
        Continue;
      if not TScriptPlace(Location).ShipInPlace(Binding.Ship) then
      begin
        av[0].AsInteger := 0;
        Exit;
      end;
      Found := True;
    end;
  end;
  av[0].AsInteger := Ord(Found);
end;

procedure SF_CountIn(av: array of TVarEC; code: TCodeEC);
var
  GroupIndex: Integer;
  Location: TObject;
  I, Count, FoundCount: Integer;
  Binding: TScriptShip;
  ExcludeHyperspace: Boolean;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script CountIn');
  GroupIndex := av[1].AsInteger;
  { Native code reads argument 2 both as this flag and as the location below. }
  ExcludeHyperspace := (High(av) > 1) and (av[2].AsInteger <> 0);
  FoundCount := 0;
  if High(av) = 1 then
  begin
    Count := CurrentScript.Ships.Count;
    for I := 0 to Count - 1 do
    begin
      Binding := CurrentScript.Ships[I];
      if Binding.GroupIndex = GroupIndex then
        Inc(FoundCount);
    end;
  end
  else
  begin
    Location := TObject(av[2].AsDword);
    if Location is TConstellation then
    begin
      Count := CurrentScript.Ships.Count;
      for I := 0 to Count - 1 do
      begin
        Binding := CurrentScript.Ships[I];
        if ExcludeHyperspace and Binding.Ship.InHyperspace then
          Continue;
        if (Binding.GroupIndex = GroupIndex) and (Binding.Ship.CurrentStar.Constellation = Location) then
          Inc(FoundCount);
      end;
    end
    else if Location is TStar then
    begin
      Count := CurrentScript.Ships.Count;
      for I := 0 to Count - 1 do
      begin
        Binding := CurrentScript.Ships[I];
        if ExcludeHyperspace and Binding.Ship.InHyperspace then
          Continue;
        if ExcludeHyperspace and (Binding.Ship.DockedTo <> nil) and Binding.Ship.DockedTo.InHyperspace then
          Continue;
        if (Binding.GroupIndex = GroupIndex) and (Binding.Ship.CurrentStar = Location) then
          Inc(FoundCount);
      end;
    end
    else if Location is TPlanet then
    begin
      Count := CurrentScript.Ships.Count;
      for I := 0 to Count - 1 do
      begin
        Binding := CurrentScript.Ships[I];
        if (Binding.GroupIndex = GroupIndex)
            and (Binding.Ship = GetPlayer)
            and (GetPlayer.RuinsMode <> 0)
            and (GetPlayer.RuinsSavedPlanet = Location) then
          Inc(FoundCount)
        else if (Binding.GroupIndex = GroupIndex) and Binding.Ship.IsOnPlanet and (Binding.Ship.CurrentPlanet = Location) then
          Inc(FoundCount);
      end;
    end
    else if Location is TShip then
    begin
      Count := CurrentScript.Ships.Count;
      for I := 0 to Count - 1 do
      begin
        Binding := CurrentScript.Ships[I];
        if (Binding.GroupIndex = GroupIndex)
            and (Binding.Ship = GetPlayer)
            and (GetPlayer.RuinsMode <> 0)
            and (GetPlayer.RuinsSavedDockedTo = Location) then
          Inc(FoundCount)
        else if (Binding.GroupIndex = GroupIndex) and Binding.Ship.IsDockedToShip and (Binding.Ship.DockedTo = Location) then
          Inc(FoundCount);
      end;
    end
    else if Location is TScriptPlace then
    begin
      Count := CurrentScript.Ships.Count;
      for I := 0 to Count - 1 do
      begin
        Binding := CurrentScript.Ships[I];
        if (Binding.GroupIndex = GroupIndex) and TScriptPlace(Location).ShipInPlace(Binding.Ship) then
          Inc(FoundCount);
      end;
    end;
  end;
  av[0].AsInteger := FoundCount;
end;

procedure SF_NearestGroup(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  Binding: TScriptShip;
  I, ShipCount, J, GroupCount, GroupIndex: Integer;
  Distance, BestDistance: Single;
begin
  if High(av) < 3 then
    raise Exception.Create('Error.Script NearestGroup');
  Ship := TShip(av[1].AsDword);
  GroupIndex := av[2].AsInteger;
  BestDistance := 1e15;
  ShipCount := CurrentScript.Ships.Count;
  GroupCount := High(av) - 1;
  for I := 0 to ShipCount - 1 do
  begin
    Binding := CurrentScript.Ships[I];
    // Native $60C276 exhausts to GroupCount; Break retains the matching group index.
    // High(av)>=3 above guarantees this scan has at least two groups.
    J := 0;
    while J < GroupCount do
    begin
      if av[2 + J].AsInteger = Binding.GroupIndex then
        Break;
      Inc(J);
    end;
    if J >= GroupCount then
      Continue;
    if (Binding.Ship.CurrentStar = Ship.CurrentStar) and Binding.Ship.InNormalSpace then
    begin
      Distance := PointDistanceSquared(Ship.Position, Binding.Ship.Position);
      if Distance < BestDistance then
      begin
        BestDistance := Distance;
        GroupIndex := Binding.GroupIndex;
      end;
    end;
  end;
  av[0].AsInteger := GroupIndex;
end;

procedure SF_ChangeState(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  Index, StateCount: Integer;
  Snapshot: TScriptContextSnapshot;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script ChangeState');
  if av[1].ValueKind <> vkString then
    Index := av[1].AsInteger
  else
  begin
    StateCount := CurrentScript.States.Count;
    // Native $60C3E6 exhausts to StateCount; an empty list must do so too.
    Index := 0;
    while Index < StateCount do
    begin
      if TScriptState(CurrentScript.States[Index]).Name = av[1].AsString then
        Break;
      Inc(Index);
    end;
    if Index >= CurrentScript.States.Count then
      raise Exception.Create('Error.Script ChangeState ' + av[1].AsString);
  end;
  ScriptSnap(Snapshot);
  if High(av) >= 2 then
    Ship := TShip(av[2].AsDword)
  else
    Ship := CurrentScript.CurrentShip;
  CurrentScript.ChangeState(GetScriptShipBindingForContext(Ship, CurrentScript), Index);
  ScriptUnSnap(Snapshot);
end;

procedure SF_StarAngle(av: array of TVarEC; code: TCodeEC);
var
  First, Second: TStar;
begin
  if High(av) <> 2 then
    raise Exception.Create('Error.Script StarAngle');
  First := TStar(av[1].AsDword);
  Second := TStar(av[2].AsDword);
  av[0].AsFloat := PointBearingDegrees(First.Position, Second.Position);
end;

procedure SF_NewsAdd(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) <> 1 then
    raise Exception.Create('Error.Script NewsAdd');
  AddOrUpdatePlayerBubble(pmGalaxyNews, Galaxy.CurrentTurn, av[1].AsString, '');
end;

procedure SF_MsgAdd(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  Binding: TScriptShip;
  GroupIndex, I, Count: Integer;
begin
  if High(av) <> 2 then
    raise Exception.Create('Error.Script NewsAdd');
  Ship := nil;
  GroupIndex := av[2].AsInteger;
  Count := CurrentScript.Ships.Count;
  for I := 0 to Count - 1 do
  begin
    Binding := CurrentScript.Ships[I];
    if Binding.GroupIndex = GroupIndex then
    begin
      Ship := Binding.Ship;
      Break;
    end;
  end;
  if (Ship = nil) or GetPlayer.InHyperspace or (GetPlayer.CurrentStar <> Ship.CurrentStar) then
    av[0].AsInteger := 0
  else
  begin
    with AddOrUpdatePlayerBubble(pmRadio, Galaxy.CurrentTurn, av[1].AsString, '') do
      Targets[0].ShipId := Ship.Id;
    av[0].AsInteger := 1;
  end;
end;

procedure SF_Ether(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  InPlayerSystem: Boolean;
  Key: WideString;
  Kind: TPlayerMessageKind;
  MessageEntry: TMessagePlayer;
begin
  if High(av) < 3 then
    raise Exception.Create('Error.Script Ether');
  av[0].AsInteger := 0;
  Kind := TPlayerMessageKind(av[1].AsInteger);
  Key := av[2].AsString;
  Obj := nil;
  InPlayerSystem := False;
  if High(av) >= 4 then
  begin
    Obj := TObject(av[4].AsDword);
    if Obj = nil then
      Exit;
    if Obj is TShip then
    begin
      if TShip(Obj).InNormalSpace then
        if GetPlayer.InNormalSpace then
          InPlayerSystem := GetPlayer.CurrentStar = TShip(Obj).CurrentStar;
    end
    else if Obj is TPlanet then
    begin
      if GetPlayer.InNormalSpace then
        InPlayerSystem := GetPlayer.CurrentStar = TPlanet(Obj).CurrentStar;
    end
    else
      raise Exception.Create('Error.Script Ether objtype');
  end;
  if not (Kind in [pmRadio, pmRadioPlayer]) or (Obj = nil) or InPlayerSystem then
  begin
    if (Kind = pmQuestActive) and (Key <> '') and (CurrentScript <> nil) and (CurrentScript.EtherIds.IndexOf(Key) < 0) then
      CurrentScript.EtherIds.Add(Key);
    MessageEntry :=
        AddOrUpdatePlayerBubble(
            Kind,
            Galaxy.CurrentTurn,
            ReplaceAllWideString(ReplaceAllWideString(av[3].AsString, '<clr>', TextHighlightColorTag), '<clrEnd>', EndColorTag),
            Key
        );
    if Obj <> nil then
    begin
      if Obj is TShip then
        MessageEntry.Targets[0].ShipId := TShip(Obj).Id
      else
        MessageEntry.Targets[0].PlanetId := TPlanet(Obj).Id;
    end;
    if High(av) >= 5 then
      Obj := TObject(av[5].AsDword)
    else
      Obj := nil;
    if Obj <> nil then
    begin
      if Obj is TShip then
        MessageEntry.Targets[1].ShipId := TShip(Obj).Id
      else
        MessageEntry.Targets[1].PlanetId := TPlanet(Obj).Id;
    end;
    if High(av) >= 6 then
      Obj := TObject(av[6].AsDword)
    else
      Obj := nil;
    if Obj <> nil then
    begin
      if Obj is TShip then
        MessageEntry.Targets[2].ShipId := TShip(Obj).Id
      else
        MessageEntry.Targets[2].PlanetId := TPlanet(Obj).Id;
    end;
    av[0].AsInteger := 1;
  end;
end;

procedure SF_CustomEther(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  InPlayerSystem: Boolean;
  Key: WideString;
  Kind: TPlayerMessageKind;
  MessageEntry: TMessagePlayer;
begin
  if High(av) < 4 then
    raise Exception.Create('Error.Script Ether');
  av[0].AsInteger := 0;
  Kind := TPlayerMessageKind(av[2].AsInteger);
  Key := av[3].AsString;
  Obj := nil;
  InPlayerSystem := False;
  if High(av) >= 5 then
  begin
    Obj := TObject(av[5].AsDword);
    if Obj = nil then
      Exit;
    if Obj is TShip then
    begin
      if TShip(Obj).InNormalSpace then
        if GetPlayer.InNormalSpace then
          InPlayerSystem := GetPlayer.CurrentStar = TShip(Obj).CurrentStar;
    end
    else if Obj is TPlanet then
    begin
      if GetPlayer.InNormalSpace then
        InPlayerSystem := GetPlayer.CurrentStar = TPlanet(Obj).CurrentStar;
    end
    else
      raise Exception.Create('Error.Script Ether objtype');
  end;
  if not (Kind in [pmRadio, pmRadioPlayer]) or (Obj = nil) or InPlayerSystem then
  begin
    if (Kind = pmQuestActive) and (Key <> '') and (CurrentScript <> nil) and (CurrentScript.EtherIds.IndexOf(Key) < 0) then
      CurrentScript.EtherIds.Add(Key);
    MessageEntry :=
        AddOrUpdatePlayerBubble(
            Kind,
            Galaxy.CurrentTurn,
            ReplaceAllWideString(ReplaceAllWideString(av[4].AsString, '<clr>', TextHighlightColorTag), '<clrEnd>', EndColorTag),
            Key
        );
    MessageEntry.ImageNameOverride := av[1].AsString;
    if Obj <> nil then
    begin
      if Obj is TShip then
        MessageEntry.Targets[0].ShipId := TShip(Obj).Id
      else
        MessageEntry.Targets[0].PlanetId := TPlanet(Obj).Id;
    end;
    if High(av) >= 6 then
      Obj := TObject(av[6].AsDword)
    else
      Obj := nil;
    if Obj <> nil then
    begin
      if Obj is TShip then
        MessageEntry.Targets[1].ShipId := TShip(Obj).Id
      else
        MessageEntry.Targets[1].PlanetId := TPlanet(Obj).Id;
    end;
    if High(av) >= 7 then
      Obj := TObject(av[7].AsDword)
    else
      Obj := nil;
    if Obj <> nil then
    begin
      if Obj is TShip then
        MessageEntry.Targets[2].ShipId := TShip(Obj).Id
      else
        MessageEntry.Targets[2].PlanetId := TPlanet(Obj).Id;
    end;
    av[0].AsInteger := 1;
  end;
end;

procedure SF_EtherDelete(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) <> 1 then
    raise Exception.Create('Error.Script EtherDelete');
  RemovePlayerBubbleByKey(av[1].AsString);
end;

procedure SF_EtherIdAdd(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) <> 1 then
    raise Exception.Create('Error.Script EtherIdAdd');
  CurrentScript.EtherIds.Add(av[1].AsString);
end;

procedure SF_EtherIdDelete(av: array of TVarEC; code: TCodeEC);
var
  Index: Integer;
begin
  if High(av) <> 1 then
    raise Exception.Create('Error.Script EtherIdDelete');
  while True do
  begin
    Index := CurrentScript.EtherIds.IndexOf(av[1].AsString);
    if Index < 0 then
      Break;
    CurrentScript.EtherIds.Delete(Index);
  end;
end;

procedure SF_EtherState(av: array of TVarEC; code: TCodeEC);
var
  MessageEntry: TMessagePlayer;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script EtherState');
  MessageEntry := FindPlayerBubbleByKey(av[1].AsString, False);
  if MessageEntry = nil then
    av[0].AsInteger := -1
  else
    av[0].AsInteger := Ord(MessageEntry.Kind);
end;

procedure SF_ConChangeRelationToRanger(av: array of TVarEC; code: TCodeEC);
var
  Ranger: TRanger;
  Sector: TConstellation;
  Amount: Integer;
  Star: TStar;
  Planet: TPlanet;
  StarIndex, PlanetIndex, StarCount, PlanetCount: Integer;
begin
  if High(av) <> 3 then
    raise Exception.Create('Error.Script ConChangeRelationToRanger');
  Sector := TConstellation(av[1].AsDword);
  Ranger := TRanger(av[2].AsDword);
  Amount := av[3].AsInteger;
  StarCount := Sector.Stars.Count;
  for StarIndex := 0 to StarCount - 1 do
  begin
    Star := Sector.Stars[StarIndex];
    PlanetCount := Star.Planets.Count;
    for PlanetIndex := 0 to PlanetCount - 1 do
    begin
      Planet := Star.Planets[PlanetIndex];
      if Planet.OwnerId <> oiUninhabited then
        Planet.ChangeRelationToRanger(Ranger, Amount);
    end;
  end;
end;

procedure SF_GetData(av: array of TVarEC; code: TCodeEC);
var
  Index: Integer;
  Ship: TShip;
begin
  Index := 0;
  if High(av) >= 1 then
    Index := av[1].AsInteger;
  if High(av) >= 2 then
  begin
    Ship := TShip(av[2].AsDword);
    if (Ship = GetPlayer) and (CurrentScript = nil) then
      Exit;
  end
  else
    Ship := CurrentScript.CurrentShip;
  if Ship = GetPlayer then
    av[0].AsDword := GetScriptShipBindingForContext(Ship, CurrentScript).Data[Index]
  else
    av[0].AsDword := TScriptShip(Ship.ScriptShip).Data[Index];
end;

procedure SF_SetData(av: array of TVarEC; code: TCodeEC);
var
  Index: Integer;
  Ship: TShip;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script SetData');
  Index := 0;
  if High(av) >= 2 then
    Index := av[2].AsInteger;
  if High(av) >= 3 then
  begin
    Ship := TShip(av[3].AsDword);
    if (Ship = GetPlayer) and (CurrentScript = nil) then
      Exit;
  end
  else
    Ship := CurrentScript.CurrentShip;
  if Ship = GetPlayer then
    GetScriptShipBindingForContext(Ship, CurrentScript).Data[Index] := av[1].AsDword
  else
    TScriptShip(Ship.ScriptShip).Data[Index] := av[1].AsDword;
end;

procedure SF_ShipData(av: array of TVarEC; code: TCodeEC);
begin
  av[0].AsDword := GetScriptShipBindingForContext(CurrentScript.CurrentShip, CurrentScript).Data[0];
  if High(av) >= 1 then
    GetScriptShipBindingForContext(CurrentScript.CurrentShip, CurrentScript).Data[0] := av[1].AsDword;
end;

procedure SF_Format(av: array of TVarEC; code: TCodeEC);
var
  Text, Color: WideString;
  I, Count: Integer;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script Format');
  if High(av) = 1 then
  begin
    Text := av[1].AsString;
    Text := ReplaceAllWideString(Text, '<br>', #13#10);
    Text := ReplaceAllWideString(Text, '<ll>', #13#10' '#13#10);
    if GetPlayer <> nil then
      Text := ReplaceAllWideString(Text, '<Player>', TextHighlightColorTag + GetPlayer.Name + EndColorTag);
    av[0].AsString := Text;
    Exit;
  end;
  Text := av[1].AsString;
  Count := (High(av) - 1) div 2;
  if Count * 2 + 1 < High(av) then
  begin
    Color := av[High(av)].AsString;
    if Color <> '' then
      Color := '<color=' + Color + '>';
  end
  else
    Color := TextHighlightColorTag;
  for I := 0 to Count - 1 do
    Text := ReplaceAllWideString(Text, av[2 + I * 2].AsString, WrapTextInColor(av[2 + I * 2 + 1].AsString, Color));
  av[0].AsString := Text;
end;

procedure SF_DeleteTags(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script DeleteTags');
  av[0].AsString := RemoveTextTagsW(av[1].AsString);
end;

procedure SF_Dialog(av: array of TVarEC; code: TCodeEC);
var
  I, Count, J, ShipCount: Integer;
  Obj: TObject;
  Binding: TScriptShip;
  Immediate: Boolean;
  Snapshot: TScriptContextSnapshot;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script Dialog');
  av[0].AsInteger := 0;
  if ExitScreenLoop then
    Exit;
  if GetPlayer = nil then
    Exit;
  if (High(av) = 1) and (av[1].AsDword = 0) then
    Exit;
  if not GetPlayer.InNormalSpace then
    Exit;
  if CurrentScreenId <> screenStarMap then
    Exit;
  if TalkDialogActive then
    Exit;
  Immediate := TurnCalculationPhase in [tcpIdle, tcpGalaxyFinished, tcpPlayerStarFinished, tcpPlayerStarPrepared];
  ScriptSnap(Snapshot);
  if High(av) = 1 then
  begin
    if Immediate then
    begin
      TalkShip := TShip(av[1].AsDword);
      TalkScripted := False;
      ScriptDialogIndex := -1;
      StarMapScreen.RunTalkDialogs;
      av[0].AsInteger := 1;
    end
    else if TShip(av[1].AsDword).OpenPlayerConversation(False) then
      av[0].AsInteger := 1;
    ScriptUnSnap(Snapshot);
    Exit;
  end;
  Count := Length(av) - 2;
  for I := 0 to Count - 1 do
  begin
    Obj := TObject(av[2 + I].AsDword);
    // This argument accepts a small group ID or a full object address.
    if PtrUInt(Obj) < $10000 then
    begin
      ShipCount := CurrentScript.Ships.Count;
      for J := 0 to ShipCount - 1 do
      begin
        Binding := CurrentScript.Ships[J];
        if (Binding.GroupIndex = Integer(Obj)) and (GetPlayer <> Binding.Ship) then
        begin
          ScriptDialogIndex := -1;
          CurrentScript.CallDialog(av[1].AsInteger);
          if ScriptDialogIndex >= 0 then
          begin
            if Immediate then
            begin
              TalkShip := Binding.Ship;
              TalkScripted := False;
              StarMapScreen.RunTalkDialogs;
              av[0].AsInteger := 1;
            end
            else if Binding.Ship.OpenPlayerConversation(False) then
              av[0].AsInteger := 1;
            ScriptUnSnap(Snapshot);
            Exit;
          end;
        end;
      end;
    end
    else if Obj is TShip then
    begin
      ScriptDialogIndex := -1;
      CurrentScript.CallDialog(av[1].AsInteger);
      if ScriptDialogIndex >= 0 then
      begin
        if Immediate then
        begin
          TalkShip := TShip(Obj);
          TalkScripted := False;
          StarMapScreen.RunTalkDialogs;
          av[0].AsInteger := 1;
        end
        else if TShip(Obj).OpenPlayerConversation(False) then
          av[0].AsInteger := 1;
        ScriptUnSnap(Snapshot);
        Exit;
      end;
    end
    else if Obj is TPlanet then
    begin
      ScriptDialogIndex := -1;
      CurrentScript.CallDialog(av[1].AsInteger);
      if (ScriptDialogIndex >= 0) and TPlanet(Obj).RequestDialog then
      begin
        av[0].AsInteger := 1;
        ScriptUnSnap(Snapshot);
        Exit;
      end;
    end;
  end;
end;

procedure SF_DText(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script DText');
  if GetPlayer.IsDockedToShip then
    RuinsTalkScreen.DialogText :=
        ReplaceAllWideString(ReplaceAllWideString(av[1].AsString, '<clr>', TextHighlightColorTag), '<clrEnd>', EndColorTag)
  else if not GetPlayer.IsOnPlanet then
    TalkScreen.DialogText :=
        ReplaceAllWideString(ReplaceAllWideString(av[1].AsString, '<clr>', TextHighlightColorTag), '<clrEnd>', EndColorTag)
  else
    GovernmentScreen.DialogText :=
        ReplaceAllWideString(ReplaceAllWideString(av[1].AsString, '<clr>', TextHighlightColorTag), '<clrEnd>', EndColorTag);
end;

procedure SF_DAddText(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script DAddText');
  if GetPlayer.IsDockedToShip then
    RuinsTalkScreen.DialogText :=
        RuinsTalkScreen.DialogText
            + ReplaceAllWideString(ReplaceAllWideString(av[1].AsString, '<clr>', TextHighlightColorTag), '<clrEnd>', EndColorTag)
  else if not GetPlayer.IsOnPlanet then
    TalkScreen.DialogText :=
        TalkScreen.DialogText
            + ReplaceAllWideString(ReplaceAllWideString(av[1].AsString, '<clr>', TextHighlightColorTag), '<clrEnd>', EndColorTag)
  else
    GovernmentScreen.DialogText :=
        GovernmentScreen.DialogText
            + ReplaceAllWideString(ReplaceAllWideString(av[1].AsString, '<clr>', TextHighlightColorTag), '<clrEnd>', EndColorTag);
end;

procedure SF_DAdd(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) <> 1 then
    raise Exception.Create('Error.Script DAdd');
  CurrentScript.BuildDialogAnswer(av[1].AsInteger);
end;

procedure SF_DAnswer(av: array of TVarEC; code: TCodeEC);
var
  Count: Integer;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script DAnswer');
  if GetPlayer.IsDockedToShip then
  begin
    if ExtractDelimitedPartW(LowerCase(AnsiString(av[1].AsString)), 0, '~') = 'takeoff' then
    begin
      Count := CountDelimitedPartsW(av[1].AsString, '~');
      if Count > 1 then
        RuinsTalkScreen.AddScriptTakeoffChoice(ExtractDelimitedRangeW(av[1].AsString, 1, Count - 1, '~'))
      else
        RuinsTalkScreen.AddScriptTakeoffChoice('');
    end
    else if (ExtractDelimitedPartW(LowerCase(AnsiString(av[1].AsString)), 0, '~') = 'exit')
        or (ExtractDelimitedPartW(LowerCase(AnsiString(av[1].AsString)), 0, '~') = 'fastexit') then
    begin
      if GetPlayer.RuinsMode > 0 then
        GetPlayer.CloseRuinsModeScreen
      else
        RuinsTalkScreen.ContinueScriptDialog;
    end
    else if ExtractDelimitedPartW(LowerCase(AnsiString(av[1].AsString)), 0, '~') = 'continue' then
    begin
      RuinsTalkScreen.ContinueScriptDialog;
    end
    else if LowerCase(AnsiString(av[1].AsString)) = 'main' then
    begin
      RuinsTalkScreen.M_Main(False);
    end
    else if ExtractDelimitedPartW(LowerCase(AnsiString(av[1].AsString)), 0, '~') = 'exit_news' then
    begin
      Count := CountDelimitedPartsW(av[1].AsString, '~');
      if Count > 1 then
        RuinsTalkScreen.AddScriptNewsExitChoice(ExtractDelimitedRangeW(av[1].AsString, 1, Count - 1, '~'))
      else
        RuinsTalkScreen.AddScriptNewsExitChoice('');
    end
    else if ExtractDelimitedPartW(LowerCase(AnsiString(av[1].AsString)), 0, '~') = 'exit_end' then
    begin
      Count := CountDelimitedPartsW(av[1].AsString, '~');
      if Count > 1 then
        RuinsTalkScreen.AddScriptGameEndChoice(ExtractDelimitedRangeW(av[1].AsString, 1, Count - 1, '~'))
      else
        RuinsTalkScreen.AddScriptGameEndChoice('');
    end
    else if ExtractDelimitedPartW(LowerCase(AnsiString(av[1].AsString)), 0, '~') = 'hangar' then
    begin
      Count := CountDelimitedPartsW(av[1].AsString, '~');
      if Count > 1 then
        RuinsTalkScreen.AddScriptHangarChoice(ExtractDelimitedRangeW(av[1].AsString, 1, Count - 1, '~'))
      else
        RuinsTalkScreen.AddScriptHangarChoice('');
    end
    else if ExtractDelimitedPartW(LowerCase(AnsiString(av[1].AsString)), 0, '~') = 'restart' then
    begin
      Count := CountDelimitedPartsW(av[1].AsString, '~');
      if Count > 1 then
        RuinsTalkScreen.AddScriptRestartChoice(ExtractDelimitedRangeW(av[1].AsString, 1, Count - 1, '~'))
      else
        RuinsTalkScreen.AddScriptRestartChoice('');
    end
    else if ExtractDelimitedPartW(LowerCase(AnsiString(av[1].AsString)), 0, '~') = 'goods' then
    begin
      Count := CountDelimitedPartsW(av[1].AsString, '~');
      if Count > 1 then
        RuinsTalkScreen.AddScriptGoodsChoice(ExtractDelimitedRangeW(av[1].AsString, 1, Count - 1, '~'))
      else
        RuinsTalkScreen.AddScriptGoodsChoice('');
    end
    else if ExtractDelimitedPartW(LowerCase(AnsiString(av[1].AsString)), 0, '~') = 'block' then
    begin
      Count := CountDelimitedPartsW(av[1].AsString, '~');
      if Count > 1 then
        RuinsTalkScreen.AddChoice('- ' + ExtractDelimitedRangeW(av[1].AsString, 1, Count - 1, '~'), 0, ScriptDialogBlockCallback)
      else
        RuinsTalkScreen.AddChoice('', 0, ScriptDialogBlockCallback);
    end
    else if ExtractDelimitedPartW(LowerCase(AnsiString(av[1].AsString)), 0, '~') = 'snap' then
    begin
      Count := CountDelimitedPartsW(av[1].AsString, '~');
      if Count > 1 then
        RuinsTalkScreen.AddChoice(
            '- ' + ExtractDelimitedRangeW(av[1].AsString, 1, Count - 1, '~'),
            CurrentScript.CurrentAnswer,
            RuinsTalkScreen.RunScriptAnswerKeepingScroll
        )
      else
        RuinsTalkScreen.AddChoice('', CurrentScript.CurrentAnswer, RuinsTalkScreen.RunScriptAnswerKeepingScroll);
    end
    else
      RuinsTalkScreen.AddChoice('- ' + av[1].AsString, CurrentScript.CurrentAnswer, RuinsTalkScreen.RunScriptAnswer);
  end
  else if not GetPlayer.IsOnPlanet then
  begin
    if (ExtractDelimitedPartW(LowerCase(AnsiString(av[1].AsString)), 0, '~') = 'exit')
        or (ExtractDelimitedPartW(LowerCase(AnsiString(av[1].AsString)), 0, '~') = 'takeoff') then
    begin
      Count := CountDelimitedPartsW(av[1].AsString, '~');
      if Count > 1 then
        TalkScreen.AddScriptExitChoice(ExtractDelimitedRangeW(av[1].AsString, 1, Count - 1, '~'))
      else
        TalkScreen.AddScriptExitChoice('');
    end
    else if ExtractDelimitedPartW(LowerCase(AnsiString(av[1].AsString)), 0, '~') = 'fastexit' then
    begin
      Count := CountDelimitedPartsW(av[1].AsString, '~');
      if Count > 1 then
        TalkScreen.AddChoice('- ' + ExtractDelimitedRangeW(av[1].AsString, 1, Count - 1, '~'), 0, TalkScreen.FastExit, 0)
      else
        TalkScreen.AddChoice('', 0, TalkScreen.FastExit, 0);
    end
    else if LowerCase(AnsiString(av[1].AsString)) = 'main' then
    begin
      ScriptDialogIndex := -1;
      TalkScreen.CodeMsgOut(True);
    end
    else if ExtractDelimitedPartW(LowerCase(AnsiString(av[1].AsString)), 0, '~') = 'exit_end' then
    begin
      GameEndReason := gerTerronConversion;
      Count := CountDelimitedPartsW(av[1].AsString, '~');
      if Count > 1 then
        TalkScreen.AddScriptExitChoice(ExtractDelimitedRangeW(av[1].AsString, 1, Count - 1, '~'))
      else
        TalkScreen.AddScriptExitChoice('');
    end
    else if ExtractDelimitedPartW(LowerCase(AnsiString(av[1].AsString)), 0, '~') = 'restart' then
    begin
      Count := CountDelimitedPartsW(av[1].AsString, '~');
      if Count > 1 then
        TalkScreen.AddScriptRestartChoice(ExtractDelimitedRangeW(av[1].AsString, 1, Count - 1, '~'))
      else
        TalkScreen.AddScriptRestartChoice('');
    end
    else if ExtractDelimitedPartW(LowerCase(AnsiString(av[1].AsString)), 0, '~') = 'block' then
    begin
      Count := CountDelimitedPartsW(av[1].AsString, '~');
      if Count > 1 then
        TalkScreen.AddChoice('- ' + ExtractDelimitedRangeW(av[1].AsString, 1, Count - 1, '~'), 0, ScriptDialogBlockCallback, 0)
      else
        TalkScreen.AddChoice('', 0, ScriptDialogBlockCallback, 0);
    end
    else if ExtractDelimitedPartW(LowerCase(AnsiString(av[1].AsString)), 0, '~') = 'snap' then
    begin
      Count := CountDelimitedPartsW(av[1].AsString, '~');
      if Count > 1 then
        TalkScreen.AddChoice(
            '- ' + ExtractDelimitedRangeW(av[1].AsString, 1, Count - 1, '~'),
            CurrentScript.CurrentAnswer,
            TalkScreen.RunScriptAnswerKeepingScroll,
            0
        )
      else
        TalkScreen.AddChoice('', CurrentScript.CurrentAnswer, TalkScreen.RunScriptAnswerKeepingScroll, 0);
    end
    else
      TalkScreen.AddChoice('- ' + av[1].AsString, CurrentScript.CurrentAnswer, TalkScreen.RunScriptAnswer, 0);
  end
  else
  begin
    if ExtractDelimitedPartW(LowerCase(AnsiString(av[1].AsString)), 0, '~') = 'takeoff' then
    begin
      Count := CountDelimitedPartsW(av[1].AsString, '~');
      if Count > 1 then
        GovernmentScreen.AddScriptTakeoffChoice(ExtractDelimitedRangeW(av[1].AsString, 1, Count - 1, '~'))
      else
        GovernmentScreen.AddScriptTakeoffChoice('');
    end
    else if ExtractDelimitedPartW(LowerCase(AnsiString(av[1].AsString)), 0, '~') = 'planet' then
    begin
      Count := CountDelimitedPartsW(av[1].AsString, '~');
      if Count > 1 then
        GovernmentScreen.AddScriptPlanetChoice(ExtractDelimitedRangeW(av[1].AsString, 1, Count - 1, '~'))
      else
        GovernmentScreen.AddScriptPlanetChoice('');
    end
    else if ExtractDelimitedPartW(LowerCase(AnsiString(av[1].AsString)), 0, '~') = 'goods' then
    begin
      Count := CountDelimitedPartsW(av[1].AsString, '~');
      if Count > 1 then
        GovernmentScreen.AddScriptGoodsChoice(ExtractDelimitedRangeW(av[1].AsString, 1, Count - 1, '~'))
      else
        GovernmentScreen.AddScriptGoodsChoice('');
    end
    else if ExtractDelimitedPartW(LowerCase(AnsiString(av[1].AsString)), 0, '~') = 'shop' then
    begin
      Count := CountDelimitedPartsW(av[1].AsString, '~');
      if Count > 1 then
        GovernmentScreen.AddScriptShopChoice(ExtractDelimitedRangeW(av[1].AsString, 1, Count - 1, '~'))
      else
        GovernmentScreen.AddScriptShopChoice('');
    end
    else if ExtractDelimitedPartW(LowerCase(AnsiString(av[1].AsString)), 0, '~') = 'hangar' then
    begin
      Count := CountDelimitedPartsW(av[1].AsString, '~');
      if Count > 1 then
        GovernmentScreen.AddScriptHangarChoice(ExtractDelimitedRangeW(av[1].AsString, 1, Count - 1, '~'))
      else
        GovernmentScreen.AddScriptHangarChoice('');
    end
    else if ExtractDelimitedPartW(LowerCase(AnsiString(av[1].AsString)), 0, '~') = 'restart' then
    begin
      Count := CountDelimitedPartsW(av[1].AsString, '~');
      if Count > 1 then
        GovernmentScreen.AddScriptRestartChoice(ExtractDelimitedRangeW(av[1].AsString, 1, Count - 1, '~'))
      else
        GovernmentScreen.AddScriptRestartChoice('');
    end
    else if ExtractDelimitedPartW(LowerCase(AnsiString(av[1].AsString)), 0, '~') = 'exit_news' then
    begin
      Count := CountDelimitedPartsW(av[1].AsString, '~');
      if Count > 1 then
        GovernmentScreen.AddScriptNewsExitChoice(ExtractDelimitedRangeW(av[1].AsString, 1, Count - 1, '~'))
      else
        GovernmentScreen.AddScriptNewsExitChoice('');
    end
    else if (ExtractDelimitedPartW(LowerCase(AnsiString(av[1].AsString)), 0, '~') = 'exit')
        or (ExtractDelimitedPartW(LowerCase(AnsiString(av[1].AsString)), 0, '~') = 'fastexit') then
    begin
      GovernmentScreen.ContinueScriptDialog;
    end
    else if LowerCase(AnsiString(av[1].AsString)) = 'main' then
    begin
      GovernmentScreen.BuildGovernmentChoices(False);
    end
    else if ExtractDelimitedPartW(LowerCase(AnsiString(av[1].AsString)), 0, '~') = 'block' then
    begin
      Count := CountDelimitedPartsW(av[1].AsString, '~');
      if Count > 1 then
        GovernmentScreen.AddChoice('- ' + ExtractDelimitedRangeW(av[1].AsString, 1, Count - 1, '~'), 0, ScriptDialogBlockCallback)
      else
        GovernmentScreen.AddChoice('', 0, ScriptDialogBlockCallback);
    end
    else if ExtractDelimitedPartW(LowerCase(AnsiString(av[1].AsString)), 0, '~') = 'snap' then
    begin
      Count := CountDelimitedPartsW(av[1].AsString, '~');
      if Count > 1 then
        GovernmentScreen.AddChoice(
            '- ' + ExtractDelimitedRangeW(av[1].AsString, 1, Count - 1, '~'),
            CurrentScript.CurrentAnswer,
            GovernmentScreen.RunScriptAnswerKeepingScroll
        )
      else
        GovernmentScreen.AddChoice('', CurrentScript.CurrentAnswer, GovernmentScreen.RunScriptAnswerKeepingScroll);
    end
    else
      GovernmentScreen.AddChoice('- ' + av[1].AsString, CurrentScript.CurrentAnswer, GovernmentScreen.RunScriptAnswer);
  end;
end;

procedure SF_DChange(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) <> 1 then
    raise Exception.Create('Error.Script DChange');
  ScriptDialogIndex := av[1].AsInteger;
end;

procedure SF_Player(av: array of TVarEC; code: TCodeEC);
begin
  av[0].AsDword := PtrUInt(GetPlayer);
end;

procedure SF_ItemExist(av: array of TVarEC; code: TCodeEC);
var
  Item: TScriptItem;
begin
  if High(av) <> 1 then
    raise Exception.Create('Error.Script ItemExist');
  Item := TScriptItem(av[1].AsDword);
  if Item.Item = nil then
    av[0].AsInteger := 0
  else
    av[0].AsInteger := 1;
end;

procedure SF_ItemIn(av: array of TVarEC; code: TCodeEC);
var
  Star: TStar;
  Ship: TShip;
  Planet: TPlanet;
  Obj: TObject;
  Item: TItem;
  Binding: TScriptShip;
  I: Integer;
begin
  if High(av) <> 2 then
    raise Exception.Create('Error.Script ItemInStar');
  Obj := TObject(av[1].AsDword);
  if Obj is TScriptItem then
    Item := TScriptItem(Obj).Item
  else
    Item := TItem(Obj);
  if Item = nil then
  begin
    av[0].AsInteger := 0;
    Exit;
  end;

  Obj := TObject(av[2].AsDword);
  // This argument accepts a small group ID or a full object address.
  if PtrUInt(Obj) < $10000 then
  begin
    for I := 0 to CurrentScript.Ships.Count - 1 do
    begin
      Binding := CurrentScript.Ships[I];
      { Native group lookup excludes inventory slot zero. }
      if (Binding.GroupIndex = Integer(Obj))
          and ((Binding.Ship.Inventory.IndexOf(Item) > 0) or (Binding.Ship.Artefacts.IndexOf(Item) > 0)) then
      begin
        av[0].AsInteger := 1;
        Exit;
      end;
    end;
    av[0].AsInteger := 0;
  end
  else if Obj is TStar then
  begin
    Star := Obj as TStar;
    if Star.Items.IndexOf(Item) < 0 then
      av[0].AsInteger := 0
    else
      av[0].AsInteger := 1;
  end
  else if Obj is TShip then
  begin
    Ship := Obj as TShip;
    if (Ship.Inventory.IndexOf(Item) < 0) and (Ship.Artefacts.IndexOf(Item) < 0) then
      av[0].AsInteger := 0
    else
      av[0].AsInteger := 1;
  end
  else if Obj is TPlanet then
  begin
    Planet := Obj as TPlanet;
    if (GetPlayer.CurrentPlanet = Planet) and (TemporaryShopSlots <> nil) then
    begin
      if FindShopSlotByItem(Item) = nil then
        av[0].AsInteger := 0
      else
        av[0].AsInteger := 1;
    end
    else if Planet.EquipmentShop.IndexOf(Item) < 0 then
      av[0].AsInteger := 0
    else
      av[0].AsInteger := 1;
  end;
end;

procedure SF_ItemCount(av: array of TVarEC; code: TCodeEC);
var
  Kind: TItemType;
  Ship: TShip;
  I, Count: Integer;
begin
  if High(av) <> 2 then
    raise Exception.Create('Error.Script SF_ItemCount');
  Ship := TShip(av[1].AsDword);
  Kind := TItemType(av[2].AsInteger);
  Count := 0;
  for I := 0 to Ship.Inventory.Count - 1 do
    if TItem(Ship.Inventory[I]).ItemType = Kind then
      Inc(Count);
  for I := 0 to Ship.Artefacts.Count - 1 do
    if TItem(Ship.Artefacts[I]).ItemType = Kind then
      Inc(Count);
  av[0].AsInteger := Count;
end;

procedure SF_DecayGoods(av: array of TVarEC; code: TCodeEC);
var
  Kind: TGoodsIndex;
  Obj: TObject;
begin
  if High(av) <> 2 then
    raise Exception.Create('Error.Script DecayGoods');
  Kind := av[2].AsInteger;
  Obj := TObject(av[1].AsDword);
  if Obj is TPlanet then
    (Obj as TPlanet).ForceGoodsScarcity(True, [Kind]);
end;

procedure SF_UpsurgeGoods(av: array of TVarEC; code: TCodeEC);
var
  Kind: TGoodsIndex;
begin
  if High(av) <> 2 then
    raise Exception.Create('Error.Script DecayGoods');
  Kind := av[2].AsInteger;
  TPlanet(av[1].AsDword).ForceGoodsSurplus(True, [Kind]);
end;

procedure SF_GoodsAdd(av: array of TVarEC; code: TCodeEC);
var
  Kind: TGoodsIndex;
  Obj: TObject;
begin
  if High(av) <> 3 then
    raise Exception.Create('Error.Script GoodsAdd');
  Kind := av[2].AsInteger;
  Obj := TObject(av[1].AsDword);
  if Obj is TPlanet then
    with TPlanet(Obj).Goods[Kind] do
    begin
      Inc(Count, av[3].AsInteger);
      av[0].AsInteger := Count;
    end
  else if Obj is TRuins then
    with TRuins(Obj).ShopGoods[Kind] do
    begin
      Inc(Count, av[3].AsInteger);
      av[0].AsInteger := Count;
    end
  else if Obj is TShip then
    with TShip(Obj).CargoGoods[Kind] do
    begin
      Inc(Count, av[3].AsInteger);
      av[0].AsInteger := Count;
    end;
end;

procedure SF_GoodsCount(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  Kind: TGoodsIndex;
begin
  if High(av) <> 2 then
    raise Exception.Create('Error.Script GoodsCount');
  Ship := TShip(av[1].AsDword);
  Kind := av[2].AsInteger;
  av[0].AsInteger := Ship.CargoGoods[Kind].Count;
end;

procedure SF_GoodsCost(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  Kind: TGoodsIndex;
begin
  if High(av) <> 2 then
    raise Exception.Create('Error.Script GoodsCost');
  Ship := TShip(av[1].AsDword);
  Kind := av[2].AsInteger;
  av[0].AsInteger := Ship.CargoGoods[Kind].TotalCost;
end;

procedure SF_GoodsRuinsForBuy(av: array of TVarEC; code: TCodeEC);
var
  Kind: TGoodsIndex;
begin
  if High(av) <> 2 then
    raise Exception.Create('Error.Script GoodsRuinsForBuy');
  Kind := av[2].AsInteger;
  TRuins(av[1].AsDword).ForceGoodsForSale([Kind]);
end;

procedure SF_ShipGoods(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  Kind: TGoodsIndex;
  Quantity, Cost: Integer;
begin
  if High(av) < 3 then
    raise Exception.Create('Error.Script ShipGoods');
  Ship := TShip(av[1].AsDword);
  Kind := av[2].AsInteger;
  Quantity := av[3].AsInteger;
  Quantity := Max(Quantity, -Ship.CargoGoods[Kind].Count);
  if High(av) > 3 then
    Cost := av[4].AsInteger
  else if Quantity > 0 then
    Cost := Quantity * GoodsMarket[Kind].AveragePrice
  else
    Cost := Round(Quantity * Ship.CargoGoods[Kind].TotalCost / Ship.CargoGoods[Kind].Count);
  Inc(Ship.CargoGoods[Kind].Count, Quantity);
  Inc(Ship.CargoGoods[Kind].TotalCost, Cost);
end;

procedure SF_ShipGoodsIllegalOnPlanet(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  Planet: TPlanet;
  Kind: Byte;
begin
  if High(av) < 3 then
    raise Exception.Create('Error.Script ShipGoodsIllegalOnPlanet');
  Ship := TShip(av[1].AsDword);
  Kind := av[2].AsInteger;
  Planet := TPlanet(av[3].AsDword);
  av[0].AsInteger := 0;
  if (Kind in [Ord(t_Food)..Ord(t_Narcotics)]) and (Planet.OwnerId <> oiPirate) then
  begin
    if not GoodsLegalOnPlanet[Kind, Planet.RaceId, Planet.Government] then
      av[0].AsInteger := 1
    else if (Kind in [Ord(t_Food), Ord(t_Medicine)]) and Ship.IsHealthEffectActive(heNewMolizone) then
      av[0].AsInteger := 1;
  end;
end;

procedure SF_GoodsDrop(av: array of TVarEC; code: TCodeEC);
var
  Kind: TGoodsIndex;
  Ship: TShip;
  Quantity: Integer;
  Item: TItem;
  ScriptItem: TScriptItem;
  Goods: TGoods;
  Angle: Single;
  Star: TStar;
begin
  if High(av) < 3 then
    raise Exception.Create('Error.Script GoodsDrop');
  Ship := TShip(av[1].AsDword);
  Kind := av[2].AsInteger;
  Quantity := Min(Ship.CargoGoods[Kind].Count, av[3].AsInteger);
  if Quantity < 1 then
  begin
    av[0].AsInteger := 0;
    Exit;
  end;

  if GetPlayer <> Ship then
  begin
    Ship.DropGoodsIntoSpace(Kind, Quantity);
    Item := PMovingDropItemEntry(Ship.CurrentStar.MovingDropItems[Ship.CurrentStar.MovingDropItems.Count - 1]).Payload as TItem;
  end
  else
  begin
    SoundManager.PlaySound('Sound.Drop');
    Dec(Ship.CargoGoods[Kind].Count, Quantity);
    Star := GetPlayer.CurrentStar;
    Goods := TGoods.Create;
    Goods.Init(TItemType(Kind), Quantity);
    Star.Items.Add(Goods);
    Angle := SeededRandomIntRange(0, 360, Kind * (Cardinal(Galaxy.CurrentTurn) * GetPlayer.CurrentStar.GenerationSeed)) * Pi / 180;
    Goods.Position.X := GetPlayer.Position.X + Sin(Angle) * 100;
    Goods.Position.Y := GetPlayer.Position.Y - Cos(Angle) * 100;
    Goods.GetGraphObject.SetPosition(Goods.Position);
    Item := Goods;
  end;
  if High(av) >= 4 then
  begin
    ScriptItem := TScriptItem(av[4].AsDword);
    if ScriptItem.Item <> nil then
      ScriptItem.Item.ScriptItem := nil;
    ScriptItem.Item := Item;
    Item.ScriptItem := ScriptItem;
  end;
  av[0].AsInteger := 1;
end;

procedure SF_UselessItemCreate(av: array of TVarEC; code: TCodeEC);
var
  Item: TItem;
  ScriptItem: TScriptItem;
  Place: TScriptPlace;
  Angle: Single;
begin
  if High(av) < 3 then
    raise Exception.Create('Error.Script UselessItemCreate');
  Item := TUselessItem.Create;
  (Item as TUselessItem).Init(av[1].AsString, TDominatorSeries(RandomIntRange(0, 2)), 0, False);
  ScriptItem := TScriptItem(av[2].AsDword);
  if ScriptItem.Item <> nil then
    ScriptItem.Item.ScriptItem := nil;
  ScriptItem.Item := Item;
  Item.ScriptItem := ScriptItem;
  Place := TScriptPlace(av[3].AsDword);
  if not (Place.PlaceKind in ScriptSpawnPlaceKinds) then
    RaiseWideMessage('Error.Script UselessItemCreate place');
  Place.OriginStar.Items.Add(Item);
  Item.Position := Place.GetPoint;
  Angle := HeadingDegreesToRadians(SeededRandomIntRange(0, 359, Item.Id * Place.OriginStar.GenerationSeed));
  Item.Position.X := Item.Position.X + Sin(Angle) * Place.Radius;
  Item.Position.Y := Item.Position.Y - Cos(Angle) * Place.Radius;
end;

procedure SF_GoodsSellPrice(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Kind: TGoodsIndex;
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script GoodsSellPrice');
  Obj := TObject(av[1].AsDword);
  Kind := av[2].AsInteger;
  if Obj is TRuins then
    av[0].AsInteger := TRuins(Obj).ShopGoods[Kind].BaseSalePrice
  else
    av[0].AsInteger := TPlanet(Obj).Goods[Kind].BaseSalePrice;
  if High(av) > 2 then
  begin
    if Obj is TRuins then
      TRuins(Obj).ShopGoods[Kind].BaseSalePrice := av[3].AsInteger
    else
      TPlanet(Obj).Goods[Kind].BaseSalePrice := av[3].AsInteger;
  end;
end;

procedure SF_GoodsBuyPrice(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Kind: TGoodsIndex;
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script GoodsSellPrice');
  Obj := TObject(av[1].AsDword);
  Kind := av[2].AsInteger;
  if Obj is TRuins then
    av[0].AsInteger := TRuins(Obj).ShopGoods[Kind].PurchasePrice
  else
    av[0].AsInteger := TPlanet(Obj).Goods[Kind].PurchasePrice;
  if High(av) > 2 then
  begin
    if Obj is TRuins then
      TRuins(Obj).ShopGoods[Kind].PurchasePrice := av[3].AsInteger
    else
      TPlanet(Obj).Goods[Kind].PurchasePrice := av[3].AsInteger;
  end;
end;

procedure SF_CountTurn(av: array of TVarEC; code: TCodeEC);
var
  Ship, OtherShip: TShip;
  Turns: Integer;
  Obj: TObject;
  Planet: TPlanet;
  Place: TScriptPlace;
  Landed: Boolean;
  Position: TPointF;
  Star: TStar;
begin
  if High(av) <> 2 then
    raise Exception.Create('Error.Script CountTurn');
  Turns := 0;
  Ship := TShip(av[1].AsDword);
  Obj := TObject(av[2].AsDword);
  if Obj is TScriptPlace then
  begin
    Place := Obj as TScriptPlace;
    if (Place.PlaceKind = spkPlanetPosition) or (Place.PlaceKind = spkDockedPlanet) then
    begin
      Planet := TObject(Place.TargetValue) as TPlanet;
      Position := Planet.GetPosition;
    end
    else
    begin
      Planet := nil;
      Position := Place.GetPoint;
    end;
    Landed := Place.PlaceKind = spkDockedPlanet;
    Star := Place.OriginStar;
  end
  else if Obj is TPlanet then
  begin
    Planet := Obj as TPlanet;
    Landed := False;
    Position := Planet.GetPosition;
    Star := Planet.CurrentStar;
  end
  else if Obj is TShip then
  begin
    Landed := False;
    Planet := nil;
    OtherShip := Obj as TShip;
    while OtherShip.DockedTo <> nil do
      OtherShip := OtherShip.DockedTo;
    if OtherShip.CurrentPlanet <> nil then
    begin
      Planet := OtherShip.CurrentPlanet;
      Landed := True;
      Position := Planet.GetPosition;
      Star := Planet.CurrentStar;
    end
    else
    begin
      Position := OtherShip.Position;
      Star := OtherShip.CurrentStar;
      if OtherShip.InHyperspace then
        Position := OtherShip.GetArrivalPosition(OtherShip.TransitOriginStar);
    end;
  end
  else
    raise Exception.Create('Error.Script CountTurn 1');
  if (Ship.CurrentPlanet = Planet) and Landed then
  begin
    av[0].AsInteger := 0;
    Exit;
  end;
  if Ship.CurrentPlanet <> nil then
    Inc(Turns);
  if Landed then
    Inc(Turns);
  if (Ship.CurrentPlanet <> nil) and (Ship.CurrentPlanet = Planet) then
  begin
    av[0].AsInteger := Turns;
    Exit;
  end;
  if Star = Ship.CurrentStar then
  begin
    if Ship.CurrentPlanet = nil then
      Inc(Turns, Ceil(PointDistance(Position, Ship.Position) / Max(1, Ship.Speed)))
    else
      Inc(Turns, Ceil(PointDistance(Position, Ship.CurrentPlanet.GetPosition) / Max(1, Ship.Speed)));
  end
  else
  begin
    if Ship.CurrentPlanet = nil then
      Inc(Turns, Ceil(PointDistance(Ship.GetJumpDeparturePoint(Star), Ship.Position) / Max(1, Ship.Speed)))
    else
      Inc(Turns, Ceil(PointDistance(Ship.GetJumpDeparturePoint(Star), Ship.CurrentPlanet.GetPosition) / Max(1, Ship.Speed)));
    Inc(Turns, Ship.CalculateJumpTravelDays(Ship.CurrentStar, Star));
    Inc(Turns, Ceil(PointDistance(Position, Ship.GetArrivalPosition(Star)) / Max(1, Ship.Speed)));
  end;
  av[0].AsInteger := Turns;
end;

procedure SF_ShipSetBad(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) <> 2 then
    raise Exception.Create('Error.Script ShipSetBad');
  if av[1].AsDword <> 0 then
    TShip(av[1].AsDword).EnemyShip := TShip(av[2].AsDword);
end;

procedure SF_GroupSetBad(av: array of TVarEC; code: TCodeEC);
var
  GroupIndex, I, Count: Integer;
  Binding: TScriptShip;
begin
  if High(av) <> 2 then
    raise Exception.Create('Error.Script GroupSetBad');
  GroupIndex := av[1].AsInteger;
  Count := CurrentScript.Ships.Count;
  for I := 0 to Count - 1 do
  begin
    Binding := CurrentScript.Ships[I];
    if Binding.GroupIndex = GroupIndex then
      Binding.Ship.EnemyShip := TShip(av[2].AsDword);
  end;
end;

procedure SF_ShipSetPartner(av: array of TVarEC; code: TCodeEC);
var
  Ship, Partner: TShip;
begin
  if High(av) <> 3 then
    raise Exception.Create('Error.Script ShipSetPartner');
  Ship := TShip(av[1].AsDword);
  Partner := TShip(av[2].AsDword);
  if (Ship is TPirate) and (Ship.PartnerShip <> Partner) then
  begin
    if GetPlayer = Ship.PartnerShip then
      GetPlayer.PiratePartners.Remove(Ship);
    if GetPlayer = Partner then
      GetPlayer.PiratePartners.Add(Ship);
  end;
  Ship.PartnerShip := Partner;
  Ship.PartnershipDaysRemaining := av[3].AsInteger;
end;

procedure SF_ShipJoin(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  Binding: TScriptShip;
  StateIndex, I: Integer;
  Snapshot: TScriptContextSnapshot;
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script ShipJoin');
  Ship := TShip(av[2].AsDword);
  if Ship = nil then
    Exit;
  if (Ship <> GetPlayer) and (Ship.ScriptShip <> nil) then
  begin
    if TScriptShip(Ship.ScriptShip).Script <> CurrentScript then
      AppendLogLineThreadSafe(
          AnsiString(
              'Warning.Script ShipJoin ('
                  + CurrentScript.ScriptFileName
                  + '): ship '
                  + Ship.GetFullName(' ')
                  + ' was already in another script ('
                  + TScriptShip(Ship.ScriptShip).Script.ScriptFileName
                  + ')'
          )
      );
    TScriptShip(Ship.ScriptShip).Script.UnbindShip(Ship);
    Ship.ScriptShip := nil;
  end;
  ScriptSnap(Snapshot);
  CurrentScript.BindShip(av[1].AsInteger, Ship);
  Binding := GetScriptShipBindingForContext(Ship, CurrentScript);
  if (High(av) >= 3) and (av[3].ValueKind = vkString) then
  begin
    StateIndex := -1;
    if av[3].AsString = '' then
      StateIndex := TScriptGroup(CurrentScript.Groups[Binding.GroupIndex]).InitialStateIndex
    else
      for I := 0 to CurrentScript.States.Count - 1 do
        if TScriptState(CurrentScript.States[I]).Name = av[3].AsString then
        begin
          StateIndex := I;
          Break;
        end;
    if StateIndex < 0 then
      raise Exception.Create('Error.Script ShipJoin cant find state ' + av[3].AsString);
  end
  { A nonstring third argument suppresses the state change; it is not a state index. }
  else if High(av) >= 3 then
    StateIndex := -1
  else
    StateIndex := TScriptGroup(CurrentScript.Groups[Binding.GroupIndex]).InitialStateIndex;
  if High(av) >= 4 then
    Binding.Data[0] := av[4].AsDword;
  if High(av) >= 5 then
    Binding.Data[1] := av[5].AsDword;
  if High(av) >= 6 then
    Binding.Data[2] := av[6].AsDword;
  if High(av) >= 7 then
    Binding.Data[3] := av[7].AsDword;
  if StateIndex >= 0 then
    CurrentScript.ChangeState(Binding, StateIndex);
  ScriptUnSnap(Snapshot);
end;

procedure SF_ShipOut(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then
    Ship := CurrentScript.CurrentShip
  else
    Ship := TShip(av[1].AsDword);
  if Ship = nil then
    Exit;
  if Ship = GetPlayer then
    CurrentScript.UnbindShip(Ship)
  else if Ship.ScriptShip <> nil then
    TScriptShip(Ship.ScriptShip).Script.UnbindShip(Ship);
end;

procedure SF_AllShipOut(av: array of TVarEC; code: TCodeEC);
begin
  CurrentScript.ClearShipBindings;
end;

procedure SF_ShipInScript(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script ShipInScript');
  if TShip(av[1].AsDword).HasScriptBindings
      or (((High(av) <= 1) or (av[2].AsInteger <> 0)) and (TShip(av[1].AsDword).AbsoluteScriptOrder > 0)) then
    av[0].AsInteger := 1
  else
    av[0].AsInteger := 0;
end;

procedure SF_ShipInGameEvent(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) <> 1 then
    raise Exception.Create('Error.Script ShipInGameEvent');
  Ship := TShip(av[1].AsDword);
  av[0].AsInteger := 0;
  if (Ship is TWarrior) and ((Ship as TWarrior).LiberationGroup <> nil) then
    av[0].AsInteger := 1;
  if (Ship is TRuins) and ((Ship as TRuins).FlyToStar <> nil) then
    av[0].AsInteger := 1;
end;

procedure SF_ShipInCurScript(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) <> 1 then
    raise Exception.Create('Error.Script ShipInCurScript');
  if TShip(av[1].AsDword).HasScriptBindings
      and (GetScriptShipBindingForContext(TShip(av[1].AsDword), CurrentScript).Script = CurrentScript) then
    av[0].AsInteger := 1
  else
    av[0].AsInteger := 0;
end;

procedure SF_ShipInNormalSpace(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) <> 1 then
    raise Exception.Create('Error.Script ShipInNormalSpace');
  if (av[1].AsDword <> 0) and TShip(av[1].AsDword).InNormalSpace then
    av[0].AsInteger := 1
  else
    av[0].AsInteger := 0;
end;

procedure SF_ShipInHole(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script ShipInHole');
  Ship := TShip(av[1].AsDword);
  if (High(av) > 1) and (av[2].AsInteger <> 0) then
    while Ship.DockedTo <> nil do
      Ship := Ship.DockedTo;
  if Ship.InHyperspace and (Ship.Order = soJumpHole) then
    av[0].AsInteger := 1
  else
    av[0].AsInteger := 0;
end;

procedure SF_ShipIsTakeoff(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) <> 1 then
    raise Exception.Create('Error.Script ShipIsTakeoff');
  Ship := TShip(av[1].AsDword);
  if Ship.Order = soTakeoff then
    av[0].AsInteger := 1
  else
    av[0].AsInteger := 0;
end;

procedure SF_ShipCntWeapon(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) <> 1 then
    raise Exception.Create('Error.Script ShipCntWeapon');
  av[0].AsInteger := TShip(av[1].AsDword).WeaponCount;
end;

procedure SF_ShipWeapon(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  I: Integer;
begin
  if High(av) <> 2 then
    raise Exception.Create('Error.Script ShipWeapon');
  Ship := TShip(av[1].AsDword);
  I := av[2].AsInteger;
  if (I <= 0) or (Ship.WeaponCount < I) then
    av[0].AsDword := 0
  else
    av[0].AsDword := PtrUInt(Ship.Weapons[I]);
end;

procedure SF_ShipEqInSlot(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  ItemType: TItemType;
  SlotIndex: Integer;
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script ShipEqInSlot');
  Ship := TShip(av[1].AsDword);
  ItemType := TItemType(av[2].AsInteger);
  if ItemType in [t_Hull..t_DefGenerator] then
    av[0].AsDword := PtrUInt(Ship.EquipmentCache.Slots[ItemType])
  else
  begin
    if High(av) < 3 then
      SlotIndex := 0
    else
      SlotIndex := av[3].AsInteger - 1;
    Ship.RefreshAssignedItemSlots;
    av[0].AsDword := PtrUInt(Ship.FindEquippedItemInSlot(ItemType, SlotIndex));
  end;
end;

procedure SF_ArtefactTypeInUse(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  Item: TArtefact;
  ItemType: TItemType;
  Name: WideString;
  I, Count: Integer;
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script ArtefactTypeInUse');
  Ship := TShip(av[1].AsDword);
  Item := nil;
  if (av[2].ValueKind = vkDword) and (av[2].AsDword > $FFFF) then
    Item := TArtefact(av[2].AsDword);
  Name := '';
  if (Item <> nil) and (Item.GetEffectiveType in [t_Artefact, t_Artefact2]) then
    Name := Item.ConfigBlockName
  else if av[2].ValueKind = vkString then
    Name := av[2].AsString;
  if Name <> '' then
  begin
    Count := 0;
    for I := 0 to Ship.Artefacts.Count - 1 do
    begin
      Item := Ship.Artefacts[I];
      if (Item.ItemType in [t_Artefact, t_Artefact2])
          and (Item.ConfigBlockName = Name)
          and (Item.BrokenFlag = 0)
          and (Item.EquippedFlag <> 0) then
        Inc(Count);
    end;
    av[0].AsInteger := Count;
  end
  else
  begin
    if Item <> nil then
      ItemType := TArtefact(av[2].AsDword).GetEffectiveType
    else
      ItemType := TItemType(av[2].AsInteger);
    av[0].AsInteger := Ship.CountActiveArtefacts(ItemType);
  end;
end;

procedure SF_ArtefactTypeBoosted(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  ItemType: TItemType;
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script ArtefactTypeBoosted');
  Ship := TShip(av[1].AsDword);
  if (av[2].ValueKind = vkDword) and (av[2].AsDword > $FF) then
    ItemType := TArtefact(av[2].AsDword).GetEffectiveType
  else
    ItemType := TItemType(av[2].AsInteger);
  av[0].AsInteger := Ord(Ship.CanBoostArtefact(ItemType, nil, False));
end;

procedure SF_ShipGroup(av: array of TVarEC; code: TCodeEC);
var
  Binding: TScriptShip;
begin
  if High(av) <> 1 then
    raise Exception.Create('Error.Script ShipGroup');
  Binding := GetScriptShipBindingForContext(TShip(av[1].AsDword), CurrentScript);
  if Binding <> nil then
    av[0].AsInteger := Binding.GroupIndex
  else
    av[0].AsInteger := -1;
end;

procedure SF_ShipSpeed(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) <> 1 then
    raise Exception.Create('Error.Script ShipSpeed');
  av[0].AsInteger := TShip(av[1].AsDword).Speed;
end;

procedure SF_EnginePower(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Engine: TEngine;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script EnginePower');
  Obj := TObject(av[1].AsDword);
  Engine := nil;
  if Obj is TEngine then
    Engine := TEngine(Obj)
  else if (Obj is TScriptItem) and ((Obj as TScriptItem).Item <> nil) and ((Obj as TScriptItem).Item is TEngine) then
    Engine := TEngine((Obj as TScriptItem).Item)
  else if Obj is TShip then
    Engine := TShip(Obj).GetEngine;
  if Engine <> nil then
  begin
    av[0].AsInteger := Engine.OutputPercent;
    if High(av) > 1 then
      Engine.OutputPercent := av[2].AsInteger;
  end
  else
    av[0].AsInteger := 0;
end;

procedure SF_ShipJump(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) <> 1 then
    raise Exception.Create('Error.Script ShipJump');
  av[0].AsInteger := TShip(av[1].AsDword).GetJumpRange;
end;

procedure SF_ShipArmor(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) <> 1 then
    raise Exception.Create('Error.Script ShipArmor');
  av[0].AsInteger := TShip(av[1].AsDword).GetArmor;
end;

procedure SF_ShipProtectability(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) <> 1 then
    raise Exception.Create('Error.Script ShipProtectability');
  av[0].AsInteger := Round((1 - TShip(av[1].AsDword).GetDefenseDamageFactor) * 100);
end;

procedure SF_ShipDroidRepair(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) <> 1 then
    raise Exception.Create('Error.Script ShipDroidRepair');
  av[0].AsInteger := 0;
  Ship := TShip(av[1].AsDword);
  if Ship.IsEquipmentUsable(Ship.GetRepairRobot) then
    av[0].AsInteger := Ship.CalculateRepairPoints(Ship.GetRepairRobot);
end;

procedure SF_ShipRadarRange(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) <> 1 then
    raise Exception.Create('Error.Script ShipRadarRange');
  av[0].AsInteger := TShip(av[1].AsDword).GetRadarRange;
end;

procedure SF_ShipScanerPower(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) <> 1 then
    raise Exception.Create('Error.Script ShipScanerPower');
  av[0].AsInteger := TShip(av[1].AsDword).GetScannerPower;
end;

procedure SF_ShipHookPower(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) <> 1 then
    raise Exception.Create('Error.Script ShipHookPower');
  av[0].AsInteger := 0;
  Ship := TShip(av[1].AsDword);
  if Ship.IsEquipmentUsable(Ship.GetCargoHook) then
    av[0].AsInteger := Ship.CalculateCargoHookPower(Ship.GetCargoHook);
end;

procedure SF_ShipHookRange(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) <> 1 then
    raise Exception.Create('Error.Script ShipHookRange');
  av[0].AsInteger := 0;
  Ship := TShip(av[1].AsDword);
  if Ship.IsEquipmentUsable(Ship.GetCargoHook) then
    av[0].AsInteger := Ship.GetCargoHookRange;
end;

procedure SF_ShipAverageDamage(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  I, MinDamage, MaxDamage: Integer;
  Weapon: TWeapon;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script ShipAverageDamage');
  Ship := TShip(av[1].AsDword);
  MinDamage := 0;
  MaxDamage := 0;
  for I := 1 to Ship.WeaponCount do
  begin
    Weapon := Ship.Weapons[I];
    if not Ship.IsEquipmentUsable(Weapon) then
      Continue;
    if Weapon.GetWeaponInfo.ShotType in [wstMissile, wstRocket] then
    begin
      MinDamage := MinDamage + Ship.GetWeaponMinDamage(Weapon) * Weapon.GetAttackCount * Weapon.GetShotCount;
      MaxDamage := MaxDamage + Ship.GetWeaponMaxDamage(Weapon) * Weapon.GetAttackCount * Weapon.GetShotCount;
    end
    else
    begin
      MinDamage := MinDamage + Ship.GetWeaponMinDamage(Weapon) * Weapon.GetAttackCount;
      MaxDamage := MaxDamage + Ship.GetWeaponMaxDamage(Weapon) * Weapon.GetAttackCount;
    end;
  end;
  if High(av) > 1 then
  begin
    if av[2].AsInteger = 0 then
      av[0].AsInteger := MinDamage
    else if av[2].AsInteger = 1 then
      av[0].AsInteger := MaxDamage
    else
      av[0].AsInteger := Round((MinDamage + MaxDamage) * 0.5);
  end
  else
    av[0].AsInteger := Round((MinDamage + MaxDamage) * 0.5);
end;

procedure SF_ShipHealthFactor(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  Index, Remaining, Duration: Integer;
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script ShipHealthFactor');
  Ship := TShip(av[1].AsDword);
  Index := av[2].AsInteger;
  Remaining := 0;
  if Ship = nil then
  begin
    if Index = 0 then
      av[0].AsInteger := RadiationHealthDefinitions[1].Duration
    else
      av[0].AsInteger := CaptainHealthDefinitions[TCaptainHealthEffect(Index)].Duration;
    Exit;
  end;
  if Index = 0 then
  begin
    if Ship.HasRadiationSickness then
      Remaining := Ship.RadiationHealth[1].ExpireTurn - Galaxy.CurrentTurn;
    if High(av) > 2 then
    begin
      Duration := av[3].AsInteger;
      if Duration = -1 then
        Duration := RadiationHealthDefinitions[1].Duration;
      if Duration = 0 then
      begin
        Ship.RadiationHealth[1].Progress := 0;
        Ship.RadiationHealth[1].ExpireTurn := 0;
      end;
      if (Remaining = 0) and (Duration > 0) then
      begin
        Ship.RadiationHealth[1].Progress := 0.5;
        Ship.RadiationHealth[1].ExpireTurn := Galaxy.CurrentTurn + Duration;
      end;
      if (Remaining > 0) and (Duration > 0) then
        Ship.RadiationHealth[1].ExpireTurn := Galaxy.CurrentTurn + Duration;
    end;
  end
  else if (Index > 0) and (Index <= 24) then
  begin
    if Ship.IsHealthEffectActive(TCaptainHealthEffect(Index)) then
      Remaining := Ship.CaptainHealth[TCaptainHealthEffect(Index)].ExpireTurn - Galaxy.CurrentTurn;
    if High(av) > 2 then
    begin
      Duration := av[3].AsInteger;
      if Duration = -1 then
        Duration := CaptainHealthDefinitions[TCaptainHealthEffect(Index)].Duration;
      if Duration = 0 then
      begin
        Ship.CaptainHealth[TCaptainHealthEffect(Index)].Progress := 0;
        Ship.CaptainHealth[TCaptainHealthEffect(Index)].ExpireTurn := 0;
      end;
      if (Remaining = 0) and (Duration > 0) then
      begin
        Ship.CaptainHealth[TCaptainHealthEffect(Index)].Progress := 100;
        Ship.CaptainHealth[TCaptainHealthEffect(Index)].ExpireTurn := Galaxy.CurrentTurn + Duration;
      end;
      if (Remaining > 0) and (Duration > 0) then
        Ship.CaptainHealth[TCaptainHealthEffect(Index)].ExpireTurn := Galaxy.CurrentTurn + Duration;
    end;
  end;
  av[0].AsInteger := Remaining;
end;

procedure SF_ShipHealthFactorStatus(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  Index: Integer;
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script ShipHealthFactorStatus');
  Ship := TShip(av[1].AsDword);
  Index := av[2].AsInteger;
  if Index = 0 then
  begin
    av[0].AsFloat := Ship.RadiationHealth[1].Progress;
    if High(av) > 2 then
      Ship.RadiationHealth[1].Progress := av[3].AsFloat;
  end
  else if (Index > 0) and (Index <= 24) then
  begin
    av[0].AsInteger := Round(Ship.CaptainHealth[TCaptainHealthEffect(Index)].Progress);
    if High(av) > 2 then
      Ship.CaptainHealth[TCaptainHealthEffect(Index)].Progress := av[3].AsInteger;
  end
  else
    av[0].AsInteger := 0;
end;

procedure SF_PlayerImmunity(av: array of TVarEC; code: TCodeEC);
begin
  av[0].AsInteger := GetPlayer.DiseaseImmunity;
  if High(av) >= 1 then
    GetPlayer.DiseaseImmunity := av[1].AsInteger;
end;

procedure SF_ShipStatusEffect(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  EffectType: TCombatStatusEffectType;
  Index: Integer;
  Strength: Single;
  Source: TShip;
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script ShipStatusEffect');
  Ship := TShip(av[1].AsDword);
  EffectType := TCombatStatusEffectType(av[2].AsInteger);
  Index := Ship.FindCombatStatusEffect(EffectType);
  if Index < 0 then
    av[0].AsFloat := 0
  else
    av[0].AsFloat := PCombatStatusEffect(Ship.CombatStatusEffects[Index]).Strength;
  if High(av) <= 2 then
    Exit;
  Strength := av[3].AsFloat;
  if High(av) > 3 then
    Source := TShip(av[4].AsDword)
  else
    Source := nil;
  if Strength > 0 then
    Ship.AddCombatStatusStrength(EffectType, Strength, Source)
  else if Strength < 0 then
    Ship.ReduceCombatStatusStrength(EffectType, -Strength);
end;

procedure SF_GroupIs(av: array of TVarEC; code: TCodeEC);
var
  I, Count, GroupIndex: Integer;
  Binding: TScriptShip;
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script GroupIs');
  Binding := GetScriptShipBindingForContext(TShip(av[1].AsDword), CurrentScript);
  if (Binding = nil) or (Binding.Script <> CurrentScript) then
  begin
    av[0].AsInteger := 0;
    Exit;
  end;
  GroupIndex := Binding.GroupIndex;
  Count := Length(av) - 2;
  for I := 0 to Count - 1 do
    if av[2 + I].AsInteger = GroupIndex then
    begin
      av[0].AsInteger := 1;
      Exit;
    end;
  av[0].AsInteger := 0;
end;

procedure SF_StateIs(av: array of TVarEC; code: TCodeEC);
var
  I, Count: Integer;
  State: TScriptState;
  Binding: TScriptShip;
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script StateIs');
  Binding := GetScriptShipBindingForContext(TShip(av[1].AsDword), CurrentScript);
  if Binding = nil then
  begin
    av[0].AsInteger := 0;
    Exit;
  end;
  State := Binding.State;
  if State = nil then
  begin
    av[0].AsInteger := 0;
    Exit;
  end;
  Count := Length(av) - 2;
  for I := 0 to Count - 1 do
    if State.Name = av[2 + I].AsString then
    begin
      av[0].AsInteger := 1;
      Exit;
    end;
  av[0].AsInteger := 0;
end;

procedure SF_Dist(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Point1, Point2: TPointF;
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script Dist');
  av[0].AsInteger := 0;
  Obj := TObject(av[1].AsDword);
  if Obj = nil then
    Exit;
  if Obj is TShip then
    Point1 := (Obj as TShip).Position
  else if Obj is TItem then
    Point1 := (Obj as TItem).Position
  else if Obj is TScriptItem then
  begin
    if (Obj as TScriptItem).Item <> nil then
      Point1 := (Obj as TScriptItem).Item.Position
    else
      raise Exception.Create('Error.Script Dist 1');
  end
  else if Obj is TScriptPlace then
    Point1 := (Obj as TScriptPlace).GetPoint
  else if Obj is TPlanet then
    Point1 := (Obj as TPlanet).GetPosition
  else if Obj is TStar then
    Point1 := (Obj as TStar).Position
  else if Obj is TAsteroid then
    Point1 := (Obj as TAsteroid).Position
  else if Obj is TMissile then
    Point1 := (Obj as TMissile).Position
  else
    raise Exception.Create('Error.Script Dist 2');
  Obj := TObject(av[2].AsDword);
  if Obj <> nil then
  begin
    if Obj is TShip then
      Point2 := (Obj as TShip).Position
    else if Obj is TItem then
      Point2 := (Obj as TItem).Position
    else if Obj is TScriptItem then
    begin
      if (Obj as TScriptItem).Item <> nil then
        Point2 := (Obj as TScriptItem).Item.Position
      else
        raise Exception.Create('Error.Script Dist 3');
    end
    else if Obj is TScriptPlace then
      Point2 := (Obj as TScriptPlace).GetPoint
    else if Obj is TPlanet then
      Point2 := (Obj as TPlanet).GetPosition
    else if Obj is TStar then
      Point2 := (Obj as TStar).Position
    else if Obj is TAsteroid then
      Point2 := (Obj as TAsteroid).Position
    else if Obj is TMissile then
      Point2 := (Obj as TMissile).Position
    else
      raise Exception.Create('Error.Script Dist 4');
    av[0].AsInteger := Round(PointDistance(Point1, Point2));
  end;
end;

procedure SF_Angle(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Point1, Point2: TPointF;
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script Angle');
  av[0].AsInteger := 0;
  Obj := TObject(av[1].AsDword);
  if Obj = nil then
    Exit;
  if Obj is TShip then
    Point1 := (Obj as TShip).Position
  else if Obj is TItem then
    Point1 := (Obj as TItem).Position
  else if Obj is TScriptItem then
  begin
    if (Obj as TScriptItem).Item <> nil then
      Point1 := (Obj as TScriptItem).Item.Position
    else
      raise Exception.Create('Error.Script Dist 1');
  end
  else if Obj is TScriptPlace then
    Point1 := (Obj as TScriptPlace).GetPoint
  else if Obj is TPlanet then
    Point1 := (Obj as TPlanet).GetPosition
  else if Obj is TStar then
    Point1 := (Obj as TStar).Position
  else if Obj is TAsteroid then
    Point1 := (Obj as TAsteroid).Position
  else if Obj is TMissile then
    Point1 := (Obj as TMissile).Position
  else
    raise Exception.Create('Error.Script Dist 2');
  Obj := TObject(av[2].AsDword);
  if Obj <> nil then
  begin
    if Obj is TShip then
      Point2 := (Obj as TShip).Position
    else if Obj is TItem then
      Point2 := (Obj as TItem).Position
    else if Obj is TScriptItem then
    begin
      if (Obj as TScriptItem).Item <> nil then
        Point2 := (Obj as TScriptItem).Item.Position
      else
        raise Exception.Create('Error.Script Dist 3');
    end
    else if Obj is TScriptPlace then
      Point2 := (Obj as TScriptPlace).GetPoint
    else if Obj is TPlanet then
      Point2 := (Obj as TPlanet).GetPosition
    else if Obj is TStar then
      Point2 := (Obj as TStar).Position
    else if Obj is TAsteroid then
      Point2 := (Obj as TAsteroid).Position
    else if Obj is TMissile then
      Point2 := (Obj as TMissile).Position
    else
      raise Exception.Create('Error.Script Dist 4');
    av[0].AsInteger := Round(PointBearingDegrees(Point2, Point1));
  end;
end;

procedure SF_Dist2Star(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) <> 2 then
    raise Exception.Create('Error.Script DistStar');
  av[0].AsFloat := PointDistanceSquared(TStar(av[1].AsDword).Position, TStar(av[2].AsDword).Position);
end;

procedure SF_BuyPirate(av: array of TVarEC; code: TCodeEC);
var
  Planet: TPlanet;
  Ship: TPirate;
  MoneyPercent: Integer;
  WasMainPiratePlanet: Boolean;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script BuyPirate');
  MoneyPercent := 100;
  if High(av) > 1 then
    MoneyPercent := av[2].AsInteger;
  Planet := TPlanet(av[1].AsDword);
  if Planet <> nil then
  begin
    WasMainPiratePlanet := Planet.IsMainPiratePlanet;
    Planet.IsMainPiratePlanet := False;
    Ship := Planet.BuyPirate(MoneyPercent);
    Planet.IsMainPiratePlanet := WasMainPiratePlanet;
    av[0].AsDword := PtrUInt(Ship);
  end;
end;

procedure SF_BuyTransport(av: array of TVarEC; code: TCodeEC);
var
  Planet: TPlanet;
  Ship: TTransport;
  Kind: Byte;
  MoneyPercent: Integer;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script BuyTransport');
  Planet := TPlanet(av[1].AsDword);
  MoneyPercent := 100;
  if High(av) > 2 then
    MoneyPercent := av[3].AsInteger;
  if Planet <> nil then
  begin
    if High(av) > 1 then
      case av[2].AsInteger of
        0: Kind := 3;
        1: Kind := 4;
        2: Kind := 5;
      else
        Kind := 0;
      end
    else
      Kind := 0;
    Ship := Planet.SpawnTransport(Kind, MoneyPercent);
    av[0].AsDword := PtrUInt(Ship);
  end;
end;

procedure SF_Name(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
begin
  if High(av) <> 1 then
    raise Exception.Create('Error.Script Name');
  Obj := TObject(av[1].AsDword);
  if Obj is TStar then
    av[0].AsString := TStar(Obj).Name
  else if Obj is TConstellation then
    av[0].AsString := TConstellation(Obj).GetName
  else if Obj is TPlanet then
    av[0].AsString := TPlanet(Obj).Name
  else if Obj is TShip then
    av[0].AsString := TShip(Obj).GetFullName(' ')
  else if Obj is TScriptItem then
  begin
    if TScriptItem(Obj).Item = nil then
      av[0].AsString := 'NameError'
    else
      av[0].AsString := TScriptItem(Obj).Item.GetDisplayName;
  end
  else if Obj is TItem then
    av[0].AsString := TItem(Obj).GetDisplayName
  else
    av[0].AsString := 'NameError';
end;

procedure SF_ShortName(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
begin
  if High(av) <> 1 then
    raise Exception.Create('Error.Script Name');
  Obj := TObject(av[1].AsDword);
  if Obj is TStar then
    av[0].AsString := TStar(Obj).Name
  else if Obj is TPlanet then
    av[0].AsString := TPlanet(Obj).Name
  else if Obj is TShip then
    av[0].AsString := TShip(Obj).GetName
  else if Obj is TScriptItem then
  begin
    if TScriptItem(Obj).Item = nil then
      av[0].AsString := 'NameError'
    else
      av[0].AsString := TScriptItem(Obj).Item.GetShortName;
  end
  else if Obj is TItem then
    av[0].AsString := TItem(Obj).GetShortName
  else
    av[0].AsString := 'NameError';
end;

procedure SF_FirstGiveMoney(av: array of TVarEC; code: TCodeEC);
begin
  av[0].AsInteger := Round(300 * GalaxyDifficultyTuning[Galaxy.DifficultyLevels[1]].ArcadeRewardScale);
end;

procedure SF_HaveProgramm(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) <> 1 then
    raise Exception.Create('Error.Script HaveProgramm');
  av[0].AsInteger := Ord(GetPlayer.HasProgram(TProgramIndex(av[1].AsDword)));
end;

procedure SF_GetProgramm(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script GetProgramm');
  av[0].AsInteger := GetPlayer.ProgramCounts[TProgramIndex(av[1].AsDword)];
end;

procedure SF_SetProgramm(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script SetProgramm');
  av[0].AsInteger := Ord(GetPlayer.HasProgram(TProgramIndex(av[1].AsDword)));
  GetPlayer.ProgramCounts[TProgramIndex(av[1].AsDword)] := av[2].AsInteger;
end;

procedure SF_DomikProgramm(av: array of TVarEC; code: TCodeEC);
var
  Ship: TKling;
  ProgramId: TProgramIndex;
  Count: Integer;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script DomikProgramm');
  Ship := TKling(av[1].AsDword);
  av[0].AsInteger := Ord(Ship.ActiveProgramId);
  if High(av) <= 1 then
    Exit;
  ProgramId := TProgramIndex(av[2].AsDword);
  Ship.ActiveProgramId := ProgramId;
  case ProgramId of
    prgShipwreck:
    begin
      if High(av) > 2 then
        Count := av[3].AsInteger
      else
        Count := SeededRandomIntRange(1, 3, Galaxy.CurrentTurn);
      Ship.DropItemsForDominatorProgram(Count);
    end;
    prgSelfDestruction: Ship.DestroyQueued := True;
    prgDisconnection:
    begin
      Ship.OrderNone(False);
      Ship.ClearWeaponTargets(nil);
    end;
  end;
end;

procedure SF_DomikProgrammDate(av: array of TVarEC; code: TCodeEC);
var
  Ship: TKling;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script DomikProgrammDate');
  Ship := TKling(av[1].AsDword);
  av[0].AsInteger := Ship.ActiveProgramAppliedTurn;
  if High(av) > 1 then
    Ship.ActiveProgramAppliedTurn := av[2].AsInteger;
end;

procedure SF_HoleMamaCreate(av: array of TVarEC; code: TCodeEC);
var
  Angle, Scale: Single;
  Hole: THole;
  I: Integer;
  Film: TEFilmObj;
begin
  Hole := THole.Create;
  Hole.InitializeGraphic('');
  THoleSE(Hole.Graphic).SetState(1);
  Hole.Star1 := BlazerShip.CurrentStar;
  Hole.Position1.X := BlazerShip.Position.X - GetPlayer.Position.X;
  Hole.Position1.Y := BlazerShip.Position.Y - GetPlayer.Position.Y;
  Scale := 1 / Sqrt(Sqr(Hole.Position1.X) + Sqr(Hole.Position1.Y));
  Hole.Position2.X := Hole.Position1.X * Scale;
  Hole.Position2.Y := Hole.Position1.Y * Scale;
  Hole.Position1.X := BlazerShip.Position.X + Hole.Position2.X * 200;
  Hole.Position1.Y := BlazerShip.Position.Y + Hole.Position2.Y * 200;
  Scale := Sqrt(Sqr(Hole.Position1.X) + Sqr(Hole.Position1.Y));
  if Scale < BlazerShip.CurrentStar.SafeRadius then
  begin
    Hole.Position1.X := BlazerShip.Position.X - Hole.Position2.Y * 200;
    Hole.Position1.Y := BlazerShip.Position.Y + Hole.Position2.X * 200;
    Scale := Sqrt(Sqr(Hole.Position1.X) + Sqr(Hole.Position1.Y));
    if Scale < BlazerShip.CurrentStar.SafeRadius then
    begin
      Hole.Position1.X := BlazerShip.Position.X + Hole.Position2.Y * 200;
      Hole.Position1.Y := BlazerShip.Position.Y - Hole.Position2.X * 200;
    end;
  end;
  Hole.Star2 := nil;
  Angle := 1E20;
  for I := 0 to Galaxy.Stars.Count - 1 do
  begin
    Scale := PointDistanceSquared(BlazerShip.CurrentStar.Position, TStar(Galaxy.Stars[I]).Position);
    if (Scale > 5) and (Scale < Angle) then
    begin
      Angle := Scale;
      Hole.Star2 := Galaxy.Stars[I];
    end;
  end;
  Angle := HeadingDegreesToRadians(SeededRandomIntRange(0, 359, Galaxy.RandomState));
  Scale := SeededRandomIntRange(1000, 2000, Galaxy.RandomState);
  Hole.Position2 := MakePointF(Sin(Angle) * Scale, -Cos(Angle) * Scale);
  Hole.CreatedTurn := Galaxy.CurrentTurn;
  Hole.HoleType := 2;
  Galaxy.Holes.Add(Hole);
  if not Hole.Star1.RecordingTurnFilm and not Hole.Star2.RecordingTurnFilm then
    Exit;
  Film := PrimaryFilm.AddObject(Hole.Id, Hole.Graphic);
  PrimaryFilm.SetObjectPosition(0, Film, Hole.Position1);
  PrimaryFilm.SetHoleState(0, Film, 1);
  PrimaryFilm.AttachObject(0, Film);
end;

procedure SF_HoleCreate(av: array of TVarEC; code: TCodeEC);
var
  Hole: THole;
  Angle: Single;
  Place: TScriptPlace;
  Film: TEFilmObj;
begin
  if High(av) <> 2 then
    raise Exception.Create('Error.Script HoleCreate');
  Hole := THole.Create;
  Hole.InitializeGraphic('');
  THoleSE(Hole.Graphic).SetState(1);
  Hole.CreatedTurn := Galaxy.CurrentTurn;
  Hole.HoleType := 1;
  Place := TScriptPlace(av[1].AsDword);
  if not (Place.PlaceKind in ScriptSpawnPlaceKinds) then
    RaiseWideMessage('Error.Script HoleCreate place 1');
  Hole.Star1 := Place.OriginStar;
  Angle := HeadingDegreesToRadians(SeededRandomIntRange(0, 359, Hole.Id * Hole.Star1.GenerationSeed));
  Hole.Position1 := Place.GetPoint;
  Hole.Position1.X := Hole.Position1.X + Sin(Angle) * Place.Radius;
  Hole.Position1.Y := Hole.Position1.Y - Cos(Angle) * Place.Radius;
  Place := TScriptPlace(av[2].AsDword);
  if not (Place.PlaceKind in ScriptSpawnPlaceKinds) then
    RaiseWideMessage('Error.Script HoleCreate place 2');
  Hole.Star2 := Place.OriginStar;
  Angle := HeadingDegreesToRadians(SeededRandomIntRange(0, 359, Hole.Id * Hole.Star2.GenerationSeed));
  Hole.Position2 := Place.GetPoint;
  Hole.Position2.X := Hole.Position2.X + Sin(Angle) * Place.Radius;
  Hole.Position2.Y := Hole.Position2.Y - Cos(Angle) * Place.Radius;
  Galaxy.Holes.Add(Hole);
  if Hole.Star1.RecordingTurnFilm or Hole.Star2.RecordingTurnFilm then
  begin
    Film := PrimaryFilm.AddObject(Hole.Id, Hole.Graphic);
    PrimaryFilm.SetObjectPosition(0, Film, Hole.Position1);
    PrimaryFilm.SetHoleState(0, Film, 1);
    PrimaryFilm.AttachObject(0, Film);
  end
  else if GetPlayer.InNormalSpace and ((GetPlayer.CurrentStar = Hole.Star1) or (GetPlayer.CurrentStar = Hole.Star2)) then
    StarMapScreen.PendingHoleRefresh := Hole;
end;

procedure SF_TerronWeaponLock(av: array of TVarEC; code: TCodeEC);
begin
  Galaxy.TerronWeaponLockTurn := Galaxy.CurrentTurn;
end;

procedure SF_TerronGrowLock(av: array of TVarEC; code: TCodeEC);
begin
  Galaxy.TerronGrowLockTurn := Galaxy.CurrentTurn;
end;

procedure SF_TerronLandingLock(av: array of TVarEC; code: TCodeEC);
begin
  Galaxy.TerronLandingLockTurn := Galaxy.CurrentTurn;
end;

procedure SF_TerronToStar(av: array of TVarEC; code: TCodeEC);
begin
  Galaxy.TerronToStarTurn := Galaxy.CurrentTurn;
end;

procedure SF_KellerLeave(av: array of TVarEC; code: TCodeEC);
begin
  Galaxy.KellerLeaveTurn := Galaxy.CurrentTurn;
end;

procedure SF_KellerNewResearch(av: array of TVarEC; code: TCodeEC);
begin
  Galaxy.KellerResearchTargetStarId := av[1].AsDword;
end;

procedure SF_KellerKill(av: array of TVarEC; code: TCodeEC);
begin
  KellerFinishRequested := True;
end;

procedure SF_BlazerLanding(av: array of TVarEC; code: TCodeEC);
var
  Index: Integer;
  Weapon: TWeapon;
begin
  if High(av) <> 1 then
    raise Exception.Create('Error.Script BlazerLanding');
  Galaxy.BlazerLandingPlanetId := av[1].AsDword;
  if BlazerShip <> nil then
  begin
    BlazerShip.RefreshCurrentStanding;
    BlazerShip.EnemyShip := nil;
    for Index := 1 to BlazerShip.WeaponCount do
    begin
      Weapon := BlazerShip.Weapons[Index];
      if Weapon <> nil then
        Weapon.Target := nil;
    end;
  end;
end;

procedure SF_BlazerSelfDestruction(av: array of TVarEC; code: TCodeEC);
begin
  Galaxy.BlazerSelfDestructTurn := Galaxy.CurrentTurn;
end;

procedure SF_GalaxyShipId(av: array of TVarEC; code: TCodeEC);
begin
  av[0].AsInteger := Galaxy.NextShipId;
end;

procedure SF_NearCivilPlanet(av: array of TVarEC; code: TCodeEC);
var
  Index: Integer;
  Distance, BestDistance: Single;
  Ship: TShip;
  Planet: TPlanet;
begin
  if High(av) <> 1 then
    raise Exception.Create('Error.Script NearCivilPlanet');
  Ship := TShip(av[1].AsDword);
  av[0].AsDword := 0;
  BestDistance := 1E30;
  for Index := 0 to Ship.CurrentStar.Planets.Count - 1 do
  begin
    Planet := Ship.CurrentStar.Planets[Index];
    if Planet.OwnerId <> oiUninhabited then
    begin
      Distance := PointDistanceSquared(Ship.Position, Planet.GetPosition);
      if Distance < BestDistance then
      begin
        BestDistance := Distance;
        av[0].AsDword := PtrUInt(Planet);
      end;
    end;
  end;
end;

procedure SF_SkipGreeting(av: array of TVarEC; code: TCodeEC);
begin
  CurrentScript.SkipGreeting := True;
end;

procedure SF_Sound(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) <> 1 then
    raise Exception.Create('Error.Script Sound');
  SoundManager.PlaySound(av[1].AsString);
end;

procedure SF_Tips(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) <> 1 then
    raise Exception.Create('Error.Script Tips');
  ShowPlayerTipOnce(av[1].AsInteger);
end;

procedure SF_TipsState(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) <> 1 then
    raise Exception.Create('Error.Script TipsState');
  av[0].AsInteger := Ord(HasShownPlayerTip(av[1].AsInteger));
end;

procedure SF_CT(av: array of TVarEC; code: TCodeEC);
var
  Text: WideString;
  Block: TBlockParEC;

  procedure AddConfigBlock(
      Block: TBlockParEC;
      Dest: TVarEC
  ); { Nested in SF_CT. Appends to Dest's existing array; empty child blocks contain one vkEmpty placeholder. }
  var
    I: Integer;
    Value: TVarEC;
  begin
    for I := 0 to Block.GetParamCount - 1 do
    begin
      Value := TVarEC.Create(vkString);
      Value.AsString := Block.GetParamValue(I);
      Value.Name := Block.GetParamName(I);
      Dest.AsArray.AddItem(Value);
    end;
    for I := 0 to Block.GetBlockCount - 1 do
    begin
      Value := TVarEC.Create(vkArray);
      Value.AsArray := TVarArrayEC.Create;
      Value.Name := Block.GetBlockNameByIndex(I);
      AddConfigBlock(Block.GetBlockByIndex(I), Value);
      if Value.AsArray.Count = 0 then
        Value.AsArray.AddItem(TVarEC.Create(vkEmpty));
      Dest.AsArray.AddItem(Value);
    end;
  end;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script CT');
  if High(av) > 1 then
  begin
    if av[2].ValueKind = vkEmpty then
    begin
      av[2].ConvertToKind(vkArray);
      av[2].AsArray := TVarArrayEC.Create;
    end
    else if av[2].ValueKind <> vkArray then
      raise Exception.Create('Error.Script CT - 2nd argument is not an array');
    av[2].AsArray.Clear;
    if av[1].AsString = '' then
      Block := LanguageDataConfig
    else
      Block := LanguageDataConfig.FindBlockByPath(av[1].AsString);
    if Block <> nil then
      AddConfigBlock(Block, av[2]);
    av[0].AsInteger := av[2].AsArray.Count;
    if av[2].AsArray.Count = 0 then
      av[2].AsArray.AddItem(TVarEC.Create(vkEmpty));
  end
  else
  begin
    Text := LocalizedColorText(av[1].AsString);
    if FindTextOffsetW(Text, '<') >= 0 then
    begin
      Text := ReplaceAllWideString(Text, '<br>', #13#10);
      if GetPlayer <> nil then
        Text := ReplaceAllWideString(Text, '<PlayerFull>', WrapTextInColor(GetPlayer.GetFullName(' '), TextHighlightColorTag));
    end;
    av[0].AsString := ReplaceAllWideString(Text, #13#10' ', #13#10);
  end;
end;

procedure SF_BlockExist(av: array of TVarEC; code: TCodeEC);
var
  Path: WideString;
  I, Count: Integer;
  Block: TBlockParEC;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script BlockExist');
  Path := av[1].AsString;
  Count := CountDelimitedPartsW(Path, '.');
  if High(av) < 2 then
    Block := LanguageDataConfig
  else if av[2].AsString = 'Lang' then
    Block := LanguageDataConfig
  else if av[2].AsString = 'Main' then
    Block := MainDataConfig
  else if av[2].AsString = 'Config' then
    Block := UserSettingsConfig
  else
    raise Exception.Create('Error.Script BlockExist - unknown type ' + av[2].AsString);
  av[0].AsInteger := 0;
  for I := 0 to Count - 1 do
  begin
    if Block.CountBlocks(ExtractDelimitedPartW(Path, I, '.')) = 0 then
      Exit;
    Block := Block.GetBlock(ExtractDelimitedPartW(Path, I, '.'));
  end;
  av[0].AsInteger := 1;
end;

procedure SF_GetMainData(av: array of TVarEC; code: TCodeEC);
var
  Block: TBlockParEC;

  procedure AddMainDataBlock(
      Block: TBlockParEC;
      Dest: TVarEC
  ); { Nested in SF_GetMainData. Appends to Dest's existing array; empty child blocks contain one vkEmpty placeholder. }
  var
    I: Integer;
    Value: TVarEC;
  begin
    for I := 0 to Block.GetParamCount - 1 do
    begin
      Value := TVarEC.Create(vkString);
      Value.AsString := Block.GetParamValue(I);
      Value.Name := Block.GetParamName(I);
      Dest.AsArray.AddItem(Value);
    end;
    for I := 0 to Block.GetBlockCount - 1 do
    begin
      Value := TVarEC.Create(vkArray);
      Value.AsArray := TVarArrayEC.Create;
      Value.Name := Block.GetBlockNameByIndex(I);
      AddMainDataBlock(Block.GetBlockByIndex(I), Value);
      if Value.AsArray.Count = 0 then
        Value.AsArray.AddItem(TVarEC.Create(vkEmpty));
      Dest.AsArray.AddItem(Value);
    end;
  end;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script GetMainData');
  if High(av) > 1 then
  begin
    if av[2].ValueKind = vkEmpty then
    begin
      av[2].ConvertToKind(vkArray);
      av[2].AsArray := TVarArrayEC.Create;
    end
    else if av[2].ValueKind <> vkArray then
      raise Exception.Create('Error.Script GetMainData - 2nd argument is not an array');
    av[2].AsArray.Clear;
    if av[1].AsString = '' then
      Block := MainDataConfig
    else
      Block := MainDataConfig.FindBlockByPath(av[1].AsString);
    if Block <> nil then
      AddMainDataBlock(Block, av[2]);
    av[0].AsInteger := av[2].AsArray.Count;
    if av[2].AsArray.Count = 0 then
      av[2].AsArray.AddItem(TVarEC.Create(vkEmpty));
  end
  else if MainDataConfig.CountParamsByPath(av[1].AsString) > 0 then
    av[0].AsString := MainDataConfig.GetParamByPath(av[1].AsString)
  else
    av[0].AsString := '';
end;

procedure SF_GetGameOptions(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) <> 1 then
    raise Exception.Create('Error.Script GetGameOptions');
  if av[1].AsString = 'ResolutionX' then
    av[0].AsInteger := GameScreenWidth
  else if av[1].AsString = 'ResolutionY' then
    av[0].AsInteger := GameScreenHeight
  else
    try
      av[0].AsString := UserSettingsConfig.GetParam(av[1].AsString);
    except
      av[0].AsString := '';
    end;
end;

procedure SF_ResourceExist(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) <> 1 then
    raise Exception.Create('Error.Script ResourceExist');
  av[0].AsInteger := Ord(CacheDataRoot.FileExistsByPath(av[1].AsString));
end;

procedure SF_CurrentMods(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then
    av[0].AsInteger := CountDelimitedPartsW(SelectedMods, ',')
  else if av[1].ValueKind = vkString then
    av[0].AsInteger := Ord(FindTextOffsetW(SelectedModsDisplaySuffix, ', ' + av[1].AsString + ',') >= 0)
  else if av[1].AsInteger = -1 then
    av[0].AsString := SelectedMods
  else
    av[0].AsString := ExtractDelimitedPartW(SelectedMods, av[1].AsInteger, ',');
end;

procedure SF_RobotSupport(av: array of TVarEC; code: TCodeEC);
begin
  av[0].AsInteger := Ord((RobotInterface <> nil) and (RobotInterface.Support() = 0));
end;

procedure SF_StarShips(av: array of TVarEC; code: TCodeEC);
var
  Star: TStar;
  Index: Integer;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script StarShips');
  Star := TStar(av[1].AsDword);
  if Star <> nil then
  begin
    if High(av) = 1 then
      av[0].AsInteger := Star.Ships.Count
    else
    begin
      Index := av[2].AsInteger;
      if (Index >= 0) and (Index < Star.Ships.Count) then
        av[0].AsDword := PtrUInt(Star.Ships[Index])
      else
        av[0].AsDword := 0;
    end;
  end;
end;

procedure SF_StarPlanets(av: array of TVarEC; code: TCodeEC);
var
  Star: TStar;
  Index: Integer;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script StarPlanets');
  Star := TStar(av[1].AsDword);
  if Star <> nil then
  begin
    if High(av) = 1 then
      av[0].AsInteger := Star.Planets.Count
    else
    begin
      Index := av[2].AsInteger;
      if (Index >= 0) and (Index < Star.Planets.Count) then
        av[0].AsDword := PtrUInt(Star.Planets[Index])
      else
        av[0].AsDword := 0;
    end;
  end;
end;

procedure SF_StarMissiles(av: array of TVarEC; code: TCodeEC);
var
  Star: TStar;
  Index: Integer;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script StarMissiles');
  Star := TStar(av[1].AsDword);
  if Star <> nil then
  begin
    if High(av) = 1 then
      av[0].AsInteger := Star.Missiles.Count
    else
    begin
      Index := av[2].AsInteger;
      if (Index >= 0) and (Index < Star.Missiles.Count) then
        av[0].AsDword := PtrUInt(Star.Missiles[Index])
      else
        av[0].AsDword := 0;
    end;
  end;
end;

procedure SF_StarAsteroids(av: array of TVarEC; code: TCodeEC);
var
  Star: TStar;
  Index: Integer;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script StarAsteroids');
  Star := TStar(av[1].AsDword);
  if Star <> nil then
  begin
    if High(av) = 1 then
      av[0].AsInteger := Star.Asteroids.Count
    else
    begin
      Index := av[2].AsInteger;
      if (Index >= 0) and (Index < Star.Asteroids.Count) then
        av[0].AsDword := PtrUInt(Star.Asteroids[Index])
      else
        av[0].AsDword := 0;
    end;
  end;
end;

procedure SF_GroupShip(av: array of TVarEC; code: TCodeEC);
var
  Binding: TScriptShip;
  I, Count, GroupIndex, FoundCount, WantedCount: Integer;
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script GroupShip');
  GroupIndex := av[1].AsInteger;
  WantedCount := av[2].AsInteger + 1;
  FoundCount := 0;
  av[0].AsDword := 0;
  Count := CurrentScript.Ships.Count;
  for I := 0 to Count - 1 do
  begin
    Binding := CurrentScript.Ships[I];
    if Binding.GroupIndex = GroupIndex then
    begin
      Inc(FoundCount);
      if FoundCount = WantedCount then
        av[0].AsDword := PtrUInt(Binding.Ship);
    end;
  end;
end;

procedure SF_ShipItems(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  Index: Integer;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script SF_ShipItems');
  Ship := TShip(av[1].AsDword);
  if Ship <> nil then
  begin
    if High(av) = 1 then
      av[0].AsInteger := Ship.Inventory.Count
    else
    begin
      Index := av[2].AsInteger;
      if (Index >= 0) and (Index < Ship.Inventory.Count) then
        av[0].AsDword := PtrUInt(Ship.Inventory[Index])
      else
        av[0].AsDword := 0;
    end;
  end;
end;

procedure SF_ShipArts(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  Index: Integer;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script SF_ShipArts');
  Ship := TShip(av[1].AsDword);
  if Ship <> nil then
  begin
    if High(av) = 1 then
      av[0].AsInteger := Ship.Artefacts.Count
    else
    begin
      Index := av[2].AsInteger;
      if (Index >= 0) and (Index < Ship.Artefacts.Count) then
        av[0].AsDword := PtrUInt(Ship.Artefacts[Index])
      else
        av[0].AsDword := 0;
    end;
  end;
end;

procedure SF_PlayerTranclucators(av: array of TVarEC; code: TCodeEC);
var
  Star: TStar;
  Ship: TShip;
  I, J, Count, Wanted: Integer;
begin
  Count := -1;
  Wanted := -1;
  if High(av) >= 1 then
    Wanted := av[1].AsInteger;
  for I := 0 to Galaxy.Stars.Count - 1 do
  begin
    Star := Galaxy.Stars[I];
    for J := 0 to Star.Ships.Count - 1 do
    begin
      Ship := Star.Ships[J];
      if Ship is TTranclucator then
        if (Ship as TTranclucator).OwnerShip = GetPlayer then
        begin
          Inc(Count);
          if Count = Wanted then
          begin
            av[0].AsDword := PtrUInt(Ship);
            Exit;
          end;
        end;
    end;
  end;
  av[0].AsInteger := Count + 1;
end;

procedure SF_ArtTranclucatorToShip(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Item: TItem;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script SF_ArtTranclucatorToShip');
  Obj := TObject(av[1].AsDword);
  Item := nil;
  if Obj is TItem then
    Item := TItem(Obj);
  if Obj is TScriptItem then
    Item := TScriptItem(Obj).Item;
  if Item <> nil then
    if Item is TArtefactTranclucator then
      av[0].AsDword := PtrUInt((Item as TArtefactTranclucator).Ship);
end;

procedure SF_TranclucatorData(av: array of TVarEC; code: TCodeEC);
var
  Ship: TTranclucator;
  WriteValue: Boolean;
  Kind: Integer;
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script SF_TranclucatorData');
  Ship := TTranclucator(av[1].AsDword);
  if av[2].ValueKind = vkString then
  begin
    if av[2].AsString = 'Proprietor' then
      Kind := 0
    else if av[2].AsString = 'ArtSize' then
      Kind := 1
    else if av[2].AsString = 'ArtSysName' then
      Kind := 2
    else if av[2].AsString = 'Docking' then
      Kind := 3
    else if av[2].AsString = 'SeekItems' then
      Kind := 4
    else if av[2].AsString = 'AutoArrange' then
      Kind := 5
    else if av[2].AsString = 'LandStorage' then
      Kind := 6
    else if av[2].AsString = 'LandPermitPlanets' then
      Kind := 7
    else if av[2].AsString = 'LandPermitRuins' then
      Kind := 8
    else if av[2].AsString = 'SeekPermitNone' then
      Kind := 9
    else if av[2].AsString = 'SeekPermitArtefact' then
      Kind := 10
    else if av[2].AsString = 'SeekPermitMicromodule' then
      Kind := 11
    else if av[2].AsString = 'SeekPermitEquipment' then
      Kind := 12
    else if av[2].AsString = 'SeekPermitUseless' then
      Kind := 13
    else if av[2].AsString = 'SeekPermitGoods' then
      Kind := 14
    else if av[2].AsString = 'SeekPermitNode' then
      Kind := 15
    else
      raise Exception.Create('Error.Script SF_TranclucatorData - unknown property ' + av[2].AsString);
  end
  else
    Kind := av[2].AsInteger;
  WriteValue := High(av) > 2;
  case Kind of
    0:
    begin
      av[0].AsDword := PtrUInt(Ship.OwnerShip);
      if WriteValue then
        Ship.OwnerShip := TShip(av[3].AsDword);
    end;
    1:
    begin
      av[0].AsInteger := Ship.ArtefactSize;
      if WriteValue then
        Ship.ArtefactSize := av[3].AsInteger;
    end;
    2:
    begin
      av[0].AsString := Ship.ArtefactSystemName;
      if WriteValue then
        Ship.ArtefactSystemName := av[3].AsString;
    end;
    3:
    begin
      av[0].AsInteger := Ord(Ship.FollowOwner);
      if WriteValue then
        Ship.FollowOwner := av[3].AsInteger <> 0;
    end;
    4:
    begin
      av[0].AsInteger := Ord(Ship.SeekItems);
      if WriteValue then
        Ship.SeekItems := av[3].AsInteger <> 0;
    end;
    5:
    begin
      av[0].AsInteger := Ord(Ship.AutoArrange);
      if WriteValue then
        Ship.AutoArrange := av[3].AsInteger <> 0;
    end;
    6:
    begin
      av[0].AsInteger := Ord(Ship.StoreOnLanding);
      if WriteValue then
        Ship.StoreOnLanding := av[3].AsInteger <> 0;
    end;
    7:
    begin
      av[0].AsInteger := Ord(Ship.StoragePermissions[tskPlanet]);
      if WriteValue then
        Ship.StoragePermissions[tskPlanet] := av[3].AsInteger <> 0;
    end;
    8:
    begin
      av[0].AsInteger := Ord(Ship.StoragePermissions[tskStation]);
      if WriteValue then
        Ship.StoragePermissions[tskStation] := av[3].AsInteger <> 0;
    end;
    9:
    begin
      av[0].AsInteger := Ord(Ship.CollectionPermissions[tckOther]);
      if WriteValue then
        Ship.CollectionPermissions[tckOther] := av[3].AsInteger <> 0;
    end;
    10:
    begin
      av[0].AsInteger := Ord(Ship.CollectionPermissions[tckArtefact]);
      if WriteValue then
        Ship.CollectionPermissions[tckArtefact] := av[3].AsInteger <> 0;
    end;
    11:
    begin
      av[0].AsInteger := Ord(Ship.CollectionPermissions[tckMicroModule]);
      if WriteValue then
        Ship.CollectionPermissions[tckMicroModule] := av[3].AsInteger <> 0;
    end;
    12:
    begin
      av[0].AsInteger := Ord(Ship.CollectionPermissions[tckEquipment]);
      if WriteValue then
        Ship.CollectionPermissions[tckEquipment] := av[3].AsInteger <> 0;
    end;
    13:
    begin
      av[0].AsInteger := Ord(Ship.CollectionPermissions[tckUseless]);
      if WriteValue then
        Ship.CollectionPermissions[tckUseless] := av[3].AsInteger <> 0;
    end;
    14:
    begin
      av[0].AsInteger := Ord(Ship.CollectionPermissions[tckGoods]);
      if WriteValue then
        Ship.CollectionPermissions[tckGoods] := av[3].AsInteger <> 0;
    end;
    15:
    begin
      av[0].AsInteger := Ord(Ship.CollectionPermissions[tckCountable]);
      if WriteValue then
        Ship.CollectionPermissions[tckCountable] := av[3].AsInteger <> 0;
    end;
  else
    raise Exception.Create('Error.Script SF_TranclucatorData - unknown property ' + IntToWideString(Kind));
  end;
end;

procedure SF_LinkItemToScript(av: array of TVarEC; code: TCodeEC);
var
  Binding: TScriptItem;
  Item: TItem;
  I: Integer;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script SF_LinkItemToScript');
  Item := TItem(av[1].AsDword);
  if Item.ScriptItem <> nil then
    (Item.ScriptItem as TScriptItem).Item := nil;
  if High(av) < 2 then
  begin
    if CurrentScript = nil then
      raise Exception.Create('Error.Script SF_LinkItemToScript - no script');
    Binding := nil;
    for I := 0 to CurrentScript.Items.Count - 1 do
    begin
      Binding := CurrentScript.Items[I];
      if (Binding.Name = '') and (Binding.Item = nil) then
        Break;
      Binding := nil;
    end;
    if Binding = nil then
    begin
      Binding := TScriptItem.Create;
      Binding.Script := CurrentScript;
      CurrentScript.Items.Add(Binding);
    end;
    if Binding.ActionCode <> nil then
      Binding.ActionCode.Free;
    Binding.ActionCode := nil;
    Binding.ActionCodeInitialized := False;
    Binding.OnActionText := '';
    Binding.CanSell := True;
  end
  else
    Binding := TScriptItem(av[2].AsDword);
  if Binding.Item <> nil then
    Binding.Item.ScriptItem := nil;
  Binding.Item := Item;
  Item.ScriptItem := Binding;
end;

procedure SF_ReleaseItemFromScript(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Binding: TScriptItem;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script ReleaseItemFromScript');
  Obj := TObject(av[1].AsDword);
  Binding := nil;
  if Obj is TItem then
    Binding := TScriptItem(TItem(Obj).ScriptItem);
  if Obj is TScriptItem then
    Binding := TScriptItem(Obj);
  if Binding.Item <> nil then
    Binding.Item.ScriptItem := nil;
  Binding.Item := nil;
end;

procedure SF_ScriptItemData(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Binding: TScriptItem;
  Index: Integer;
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script ScriptItemData');
  Obj := TObject(av[1].AsDword);
  Binding := nil;
  if Obj is TItem then
    Binding := TScriptItem(TItem(Obj).ScriptItem);
  if Obj is TScriptItem then
    Binding := TScriptItem(Obj);
  av[0].AsInteger := 0;
  Index := av[2].AsInteger;
  case Index of
    1: av[0].AsInteger := Binding.Data[1];
    2: av[0].AsInteger := Binding.Data[2];
    3: av[0].AsInteger := Binding.Data[3];
  else
    raise Exception.Create('Error.Script ScriptItemData no');
  end;
  if High(av) > 2 then
    case Index of
      1: Binding.Data[1] := av[3].AsInteger;
      2: Binding.Data[2] := av[3].AsInteger;
      3: Binding.Data[3] := av[3].AsInteger;
    end;
end;

procedure SF_ScriptItemTextData(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Binding: TScriptItem;
  Index: Integer;
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script ScriptItemTextData');
  Obj := TObject(av[1].AsDword);
  Binding := nil;
  if Obj is TItem then
    Binding := TScriptItem(TItem(Obj).ScriptItem);
  if Obj is TScriptItem then
    Binding := TScriptItem(Obj);
  av[0].AsString := '';
  Index := av[2].AsInteger;
  case Index of
    1: av[0].AsString := Binding.TextData1;
    2: av[0].AsString := Binding.TextData2;
    3: av[0].AsString := Binding.TextData3;
  else
    raise Exception.Create('Error.Script ScriptItemTextData no');
  end;
  if High(av) > 2 then
    case Index of
      1: Binding.TextData1 := av[3].AsString;
      2: Binding.TextData2 := av[3].AsString;
      3: Binding.TextData3 := av[3].AsString;
    end;
end;

procedure SF_ScriptItemToItem(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script ScriptItemToItem');
  Obj := TObject(av[1].AsDword);
  av[0].AsDword := 0;
  if Obj <> nil then
  begin
    if Obj is TItem then
      av[0].AsDword := PtrUInt(Obj)
    else if Obj is TScriptItem then
      av[0].AsDword := PtrUInt(TScriptItem(Obj).Item);
  end;
end;

procedure SF_GetShipPirateRank(av: array of TVarEC; code: TCodeEC);
var
  Ship: TNormalShip;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script GetShipPirateRank');
  Ship := TNormalShip(av[1].AsDword);
  av[0].AsDword := Ship.PirateRank;
end;

procedure SF_ShipPirateRankPoints(av: array of TVarEC; code: TCodeEC);
var
  Ship: TNormalShip;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script ShipPirateRankPoints');
  Ship := TObject(av[1].AsDword) as TNormalShip;
  av[0].AsDword := Ship.PirateRankPoints;
  if High(av) > 1 then
    Ship.PirateRankPoints := av[2].AsDword;
end;

procedure SF_ShipNextPirateRankPoints(av: array of TVarEC; code: TCodeEC);
var
  Ship: TNormalShip;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script ShipNextPirateRankPoints');
  Ship := TObject(av[1].AsDword) as TNormalShip;
  av[0].AsInteger := PirateRankPointThresholds[Ship.PirateRank];
end;

procedure SF_ShipInPirateClan(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script ShipInPirateClan');
  Ship := TShip(av[1].AsDword);
  if GetPlayer = Ship then
    av[0].AsDword := Ord(GetPlayer.PirateClanReal)
  else
    av[0].AsDword := Ord(Ship.OwnerId = oiPirate);
end;

procedure SF_ShipOnSidePirateClan(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script ShipOnSidePirateClan');
  Ship := TShip(av[1].AsDword);
  av[0].AsDword := Ord(Ship.OwnerId = oiPirate);
end;

procedure SF_RaisePirateRank(av: array of TVarEC; code: TCodeEC);
var
  Ship: TNormalShip;
  Rank: Cardinal;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script RaisePirateRank');
  Ship := TNormalShip(av[1].AsDword);
  if High(av) > 1 then
    Ship.PirateRank := av[2].AsInteger
  else
  begin
    Rank := Ship.PirateRank;
    if Rank < 7 then
      Ship.PirateRank := Rank + 1;
  end;
  if GetPlayer = Ship then
    GetPlayer.AchievementStats.CheckBaronAchievement;
end;

procedure SF_ItemType(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Value: Byte;
  Item: TItem;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script ItemType');
  Value := 0;
  Obj := TObject(av[1].AsDword);
  Item := nil;
  if Obj is TItem then
    Item := TItem(Obj);
  if Obj is TScriptItem then
    Item := TScriptItem(Obj).Item;
  if Item <> nil then
  begin
    Value := Ord(Item.ItemType);
  end;
  av[0].AsDword := Value;
end;

procedure SF_CustomWeaponType(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Item: TItem;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script CustomWeaponType');
  av[0].AsString := '';
  Obj := TObject(av[1].AsDword);
  Item := nil;
  if Obj is TItem then
    Item := TItem(Obj);
  if Obj is TScriptItem then
    Item := TScriptItem(Obj).Item;
  if Item = nil then
    Exit;
  if not (Item is TCustomWeapon) then
    Exit;
  av[0].AsString := (Item as TCustomWeapon).GetWeaponInfo.ConfigName;
end;

procedure SF_ItemName(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Text: WideString;
  Item: TItem;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script ItemName');
  Obj := TObject(av[1].AsDword);
  Item := nil;
  Text := '';
  if Obj is TItem then
    Item := TItem(Obj);
  if Obj is TScriptItem then
    Item := TScriptItem(Obj).Item;
  if Item <> nil then
    Text := Item.GetShortName;
  av[0].AsString := Text;
end;

procedure SF_ItemFullName(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Text: WideString;
  Item: TItem;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script ItemFullName');
  Obj := TObject(av[1].AsDword);
  Item := nil;
  Text := '';
  if Obj is TItem then
    Item := TItem(Obj);
  if Obj is TScriptItem then
    Item := TScriptItem(Obj).Item;
  if Item <> nil then
    Text := Item.GetDisplayName;
  av[0].AsString := Text;
end;

procedure SF_ItemSize(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Value: Integer;
  IsCountable, IsGoods: Boolean;
  Item: TItem;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script ItemSize');
  Obj := TObject(av[1].AsDword);
  Item := nil;
  if Obj is TItem then
    Item := TItem(Obj);
  if Obj is TScriptItem then
    Item := TScriptItem(Obj).Item;
  if Item <> nil then
  begin
    IsGoods := Item.ItemType in [t_Food..t_Narcotics];
    IsCountable := not IsGoods and (Item is TCountableItem);
    if (IsCountable or IsGoods) and (High(av) > 1) and (av[2].ValueKind = vkString) and (av[2].AsString = 'Count') then
    begin
      if IsCountable then
        av[0].AsDword := TCountableItem(Item).StackCount
      else
        av[0].AsDword := TGoods(Item).Quantity;
    end
    else
      av[0].AsDword := Item.Weight;
    if (High(av) > 1) and (av[2].ValueKind <> vkString) then
    begin
      Value := av[2].AsInteger;
      if IsCountable then
      begin
        if (High(av) > 2) and (av[3].ValueKind = vkString) and (av[3].AsString = 'Count') then
        begin
          Item.Cost := Round(Item.Cost * Value / Max(1, TCountableItem(Item).StackCount));
          TCountableItem(Item).StackCount := Value;
          Item.Weight := Value * TCountableItem(Item).GetUnitSize;
        end
        else
        begin
          Item.Cost := Round(Item.Cost * Value / Max(1, Item.Weight));
          Item.Weight := Value;
          TCountableItem(Item).StackCount := Max(1, Value div TCountableItem(Item).GetUnitSize);
        end;
      end
      else if IsGoods then
      begin
        { Native Count-mode goods handling reads the countable-item offset, then
          rescales Cost again below. Both rounded rescalings affect the result. }
        if (High(av) > 2) and (av[3].ValueKind = vkString) and (av[3].AsString = 'Count') then
          Item.Cost := Round(Item.Cost * Value / Max(1, TCountableItem(Item).StackCount))
        else
          Item.Cost := Round(Item.Cost * Value / Max(1, Item.Weight));
        Item.Cost := Round(Item.Cost * Value / Max(1, Item.Weight));
        TGoods(Item).Quantity := Value;
        Item.Weight := Value;
      end
      else
        Item.Weight := Value;
    end;
  end
  else if Obj is TTranclucator then
  begin
    av[0].AsDword := TTranclucator(Obj).ArtefactSize;
    if High(av) > 1 then
      TTranclucator(Obj).ArtefactSize := av[2].AsInteger;
  end;
end;

procedure SF_ItemOwner(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Value: Byte;
  Item: TItem;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script ItemOwner');
  Value := 0;
  Obj := TObject(av[1].AsDword);
  Item := nil;
  if Obj is TItem then
    Item := TItem(Obj);
  if Obj is TScriptItem then
    Item := TScriptItem(Obj).Item;
  if Item <> nil then
  begin
    Value := Ord(Item.OwnerId);
    if High(av) > 1 then
      Item.OwnerId := TOwnerId(av[2].AsDword);
  end;
  av[0].AsDword := Value;
end;

procedure SF_ItemSubrace(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Value: Byte;
  Item: TEquipment;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script ItemSubrace');
  Value := 0;
  Obj := TObject(av[1].AsDword);
  Item := nil;
  if Obj is TItem then
    Item := TEquipment(Obj);
  if Obj is TScriptItem then
    Item := TScriptItem(Obj).Item as TEquipment;
  if Item <> nil then
  begin
    Value := Ord(Item.DominatorSeries);
    if High(av) > 1 then
      Item.DominatorSeries := TDominatorSeries(av[2].AsDword);
  end;
  av[0].AsDword := Value;
end;

procedure SF_ItemCost(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Value: Cardinal;
  Item: TItem;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script ItemCost');
  Value := 0;
  Obj := TObject(av[1].AsDword);
  Item := nil;
  if Obj is TItem then
    Item := TItem(Obj);
  if Obj is TScriptItem then
    Item := TScriptItem(Obj).Item;
  if Item <> nil then
  begin
    Value := Item.Cost;
    if High(av) > 1 then
      Item.Cost := av[2].AsInteger;
  end;
  av[0].AsDword := Value;
end;

procedure SF_ItemIsInUse(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Item: TItem;
  Ship: TShip;
  I: Integer;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script ItemIsInUse');
  Obj := TObject(av[1].AsDword);
  av[0].AsInteger := 0;
  Item := nil;
  if Obj is TItem then
    Item := TItem(Obj);
  if Obj is TScriptItem then
    Item := TScriptItem(Obj).Item;
  if Item = nil then
    Exit;
  if (Item is TEquipment) and ((Item as TEquipment).EquippedFlag <> 0) then
    av[0].AsInteger := Integer((Item as TEquipment).AssignedSlotData) + 1;
  if (High(av) <= 2) or not (Item is TEquipment) then
    Exit;
  Ship := TShip(av[2].AsDword);
  if Ship <> nil then
  begin
    if Item is TArtefact then
    begin
      if av[3].AsInteger <> 0 then
      begin
        TEquipment(Item).Equip;
        if High(av) > 3 then
          TEquipment(Item).AssignedSlotData := av[4].AsInteger - 1;
      end
      else
        (Item as TArtefact).Unequip;
    end
    else if Item is TWeapon then
    begin
      if av[3].AsInteger <> 0 then
      begin
        Ship.EquipItem(TEquipment(Item));
        if High(av) > 3 then
          TEquipment(Item).AssignedSlotData := av[4].AsInteger - 1;
      end
      else
        for I := 1 to Ship.WeaponCount do
          if Ship.Weapons[I] = Item then
            Ship.UnequipSlot(Item.ItemType, I);
    end
    else
    begin
      if av[3].AsInteger <> 0 then
      begin
        Ship.EquipItem(TEquipment(Item));
        if High(av) > 3 then
          TEquipment(Item).AssignedSlotData := av[4].AsInteger - 1;
      end
      else
        Ship.UnequipSlot(Item.ItemType, 0);
    end;
    Ship.RefreshAssignedItemSlots;
    Ship.RefreshDerivedStats(True);
    Ship.ScriptItemsAct(satOnNonStandartEqChange, nil, nil, 0);
  end;
end;

procedure SF_ItemIsInSet(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Item: TItem;
  SetIndex: Integer;
  I: Integer;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script ItemIsInSet');
  Obj := TObject(av[1].AsDword);
  Item := nil;
  av[0].AsInteger := 0;
  if Obj is TItem then
    Item := TItem(Obj);
  if Obj is TScriptItem then
    Item := TScriptItem(Obj).Item;
  if Item = nil then
    Exit;
  if High(av) > 1 then
  begin
    SetIndex := av[2].AsInteger - 1;
    if (SetIndex >= 0) and (SetIndex <= 9) then
      for I := Low(GetPlayer.EquipmentConfigurations[SetIndex].EquipmentIds)
          to High(GetPlayer.EquipmentConfigurations[SetIndex].EquipmentIds) do
        if GetPlayer.EquipmentConfigurations[SetIndex].EquipmentIds[I] = Item.Id then
        begin
          av[0].AsInteger := 1;
          Exit;
        end;
  end
  else
    for SetIndex := Low(GetPlayer.EquipmentConfigurations) to High(GetPlayer.EquipmentConfigurations) do
    begin
      for I := Low(GetPlayer.EquipmentConfigurations[SetIndex].EquipmentIds)
          to High(GetPlayer.EquipmentConfigurations[SetIndex].EquipmentIds) do
        if GetPlayer.EquipmentConfigurations[SetIndex].EquipmentIds[I] = Item.Id then
        begin
          av[0].AsInteger := SetIndex + 1;
          Exit;
        end;
      for I := Low(GetPlayer.EquipmentConfigurations[SetIndex].ArtefactIds)
          to High(GetPlayer.EquipmentConfigurations[SetIndex].ArtefactIds) do
        if GetPlayer.EquipmentConfigurations[SetIndex].ArtefactIds[I] = Item.Id then
        begin
          av[0].AsInteger := SetIndex + 1;
          Exit;
        end;
    end;
end;

procedure SF_PlayerEqSet(av: array of TVarEC; code: TCodeEC);
var
  Index: Integer;
begin
  if High(av) < 1 then
    av[0].AsInteger := GetPlayer.SelectedEquipmentConfiguration + 1
  else
  begin
    Index := av[1].AsInteger - 1;
    if GetPlayer.SelectedEquipmentConfiguration = Index then
      av[0].AsInteger := 2
    else if GetPlayer.HasEquipmentConfiguration(Index) then
      av[0].AsInteger := 1
    else
      av[0].AsInteger := 0;
    if High(av) > 1 then
    begin
      if av[2].AsInteger = 2 then
      begin
        GetPlayer.ApplyEquipmentConfiguration(Index);
        GetPlayer.SelectedEquipmentConfiguration := Index;
      end
      else if av[2].AsInteger = 1 then
      begin
        GetPlayer.SaveEquipmentConfiguration(Index);
        GetPlayer.SelectedEquipmentConfiguration := Index;
      end;
    end;
  end;
end;

procedure SF_ItemIsBroken(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Broken: Byte;
  Item: TItem;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script ItemIsBroken');
  Obj := TObject(av[1].AsDword);
  Broken := 0;
  Item := nil;
  if Obj is TItem then
    Item := TItem(Obj);
  if Obj is TScriptItem then
    Item := TScriptItem(Obj).Item;
  if Item <> nil then
  begin
    if Item is TEquipment then
      Broken := (Item as TEquipment).BrokenFlag;
    if Item is TArtefact then
      Broken := (Item as TArtefact).BrokenFlag;
  end;
  if Broken <> 0 then
    av[0].AsInteger := 1
  else
    av[0].AsInteger := 0;
end;

procedure SF_ShipCanUseEq(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Item: TItem;
  Ship: TShip;
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script ShipCanUseEq');
  Ship := TShip(av[1].AsDword);
  Obj := TObject(av[2].AsDword);
  if Obj is TItem then
    Item := TItem(Obj)
  else if Obj is TScriptItem then
    Item := TScriptItem(Obj).Item
  else
    Item := nil;
  av[0].AsInteger := 0;
  if Item <> nil then
    if Item is TEquipment then
      av[0].AsInteger := Ord(Ship.CanUseEquipmentTech(TEquipment(Item)));
end;

procedure SF_ShipCanRepairEq(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Item: TItem;
  Ship: TShip;
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script ShipCanRepairEq');
  Ship := TShip(av[1].AsDword);
  Obj := TObject(av[2].AsDword);
  if Obj is TItem then
    Item := TItem(Obj)
  else if Obj is TScriptItem then
    Item := TScriptItem(Obj).Item
  else
    Item := nil;
  av[0].AsInteger := 0;
  if Item <> nil then
    if Item is TEquipment then
      av[0].AsInteger := Ord(Ship.CanRepairEquipmentTech(TEquipment(Item)));
end;

procedure SF_ShipTechLevelKnowledge(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script ShipTechLevelKnowledge');
  Ship := TShip(av[1].AsDword);
  av[0].AsInteger := Ship.TechKnowledge;
  if High(av) > 1 then
    Ship.TechKnowledge := av[2].AsInteger;
end;

procedure SF_WeaponTarget(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Item: TItem;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script WeaponTarget');
  Obj := TObject(av[1].AsDword);
  av[0].AsDword := 0;
  Item := nil;
  if Obj is TItem then
    Item := TItem(Obj);
  if Obj is TScriptItem then
    Item := TScriptItem(Obj).Item;
  if (Item <> nil) and (Item is TWeapon) and ((Item as TWeapon).EquippedFlag <> 0) then
  begin
    av[0].AsDword := PtrUInt((Item as TWeapon).Target);
    if High(av) > 1 then
      (Item as TWeapon).Target := TObject(av[2].AsDword);
  end;
end;

procedure SF_GetEquipmentStats(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Item: TItem;
  Stat: Integer;
  Text: WideString;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script GetEquipmentStats');
  Obj := TObject(av[1].AsDword);
  Stat := 0;
  Item := nil;
  if Obj is TItem then
    Item := TItem(Obj);
  if Obj is TScriptItem then
    Item := TScriptItem(Obj).Item;
  if Item = nil then
    Exit;
  if High(av) > 1 then
  begin
    if av[2].ValueKind = vkString then
    begin
      if Item is TEquipment then
      begin
        Text := av[2].AsString;
        TEquipment(Item).ReplaceInfoTokens(Text, '', nil);
        av[0].AsString := Text;
      end
      else
        av[0].AsString := '';
      Exit;
    end;
    Stat := av[2].AsInteger;
  end;
  if Item.ItemType in WeaponItemTypes then
    case Stat of
      0: av[0].AsInteger := (Item as TWeapon).MaxDamage;
      1: av[0].AsInteger := (Item as TWeapon).MinDamage;
      2: av[0].AsInteger := (Item as TWeapon).Range;
      3: av[0].AsInteger := Ord(ClassifyWeaponDamageFlags((Item as TWeapon).GetWeaponInfo.DamageFlags));
      4: av[0].AsInteger := (Item as TWeapon).GetAttackCount;
      5: av[0].AsInteger := (Item as TWeapon).GetShotCount;
      6: av[0].AsDword := Dword((Item as TWeapon).GetDamageFlags);
    end
  else
    case Item.ItemType of
      t_Hull:
        case Stat of
          0: av[0].AsInteger := (Item as THull).Armor;
          1: av[0].AsInteger := (Item as THull).GetSlotCount(sskWeapon);
          2: av[0].AsInteger := (Item as THull).GetSlotCount(sskArtefact);
          3: av[0].AsInteger := (Item as THull).GetSlotCount(sskRadar);
          4: av[0].AsInteger := (Item as THull).GetSlotCount(sskScanner);
          5: av[0].AsInteger := (Item as THull).GetSlotCount(sskRepairRobot);
          6: av[0].AsInteger := (Item as THull).GetSlotCount(sskCargoHook);
          7: av[0].AsInteger := (Item as THull).GetSlotCount(sskDefGenerator);
          8: av[0].AsInteger := (Item as THull).GetSlotCount(sskAfterburner);
        end;
      t_FuelTanks:
        case Stat of
          0: av[0].AsInteger := (Item as TFuelTanks).Capacity;
          1: av[0].AsInteger := (Item as TFuelTanks).Fuel;
        end;
      t_Engine:
        case Stat of
          0: av[0].AsInteger := (Item as TEngine).Speed;
          1: av[0].AsInteger := (Item as TEngine).JumpRange;
        end;
      t_Radar: av[0].AsInteger := (Item as TRadar).Range;
      t_Scaner: av[0].AsInteger := (Item as TScaner).ScanPower;
      t_RepairRobot: av[0].AsInteger := (Item as TRepairRobot).RepairPoints;
      t_CargoHook:
        case Stat of
          0: av[0].AsInteger := (Item as TCargoHook).PickupPower;
          1: av[0].AsInteger := (Item as TCargoHook).Range;
          2: av[0].AsFloat := (Item as TCargoHook).MinPullSpeed;
          3: av[0].AsFloat := (Item as TCargoHook).MaxPullSpeed;
        end;
      t_DefGenerator: av[0].AsInteger := Round(100 - (Item as TDefGenerator).DamageFactor * 100);
      t_Cistern:
        case Stat of
          0: av[0].AsInteger := (Item as TCistern).Capacity;
          1: av[0].AsInteger := (Item as TCistern).Fuel;
        end;
      t_Satellite:
        case Stat of
          0: av[0].AsInteger := (Item as TSatellite).WaterExplorationRate;
          1: av[0].AsInteger := (Item as TSatellite).LandExplorationRate;
          2: av[0].AsInteger := (Item as TSatellite).HillExplorationRate;
          3: av[0].AsFloat := (Item as TSatellite).WearPerTurn;
        end;
    end;
  if av[0].ValueKind = vkEmpty then
    av[0].AsInteger := 0;
end;

procedure SF_SetEquipmentStats(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Item: TItem;
  Stat: Integer;
  Value: Cardinal;
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script SetEquipmentStats');
  Obj := TObject(av[1].AsDword);
  Value := av[2].AsDword;
  Stat := 0;
  if High(av) > 2 then
    Stat := av[3].AsInteger;
  Item := nil;
  if Obj is TItem then
    Item := TItem(Obj);
  if Obj is TScriptItem then
    Item := TScriptItem(Obj).Item;
  if Item = nil then
    Exit;
  if Item.ItemType in WeaponItemTypes then
    case Stat of
      0: (Item as TWeapon).MaxDamage := Value;
      1: (Item as TWeapon).MinDamage := Value;
      2: (Item as TWeapon).Range := Value;
    end
  else
    case Item.ItemType of
      t_Hull: (Item as THull).Armor := Value;
      t_FuelTanks:
        case Stat of
          0: (Item as TFuelTanks).Capacity := Value;
          1: (Item as TFuelTanks).Fuel := Value;
        end;
      t_Engine:
        case Stat of
          0: (Item as TEngine).Speed := Value;
          1: (Item as TEngine).JumpRange := Value;
        end;
      t_Radar: (Item as TRadar).Range := Value;
      t_Scaner: (Item as TScaner).ScanPower := Value;
      t_RepairRobot: (Item as TRepairRobot).RepairPoints := Value;
      t_CargoHook:
        case Stat of
          0: (Item as TCargoHook).PickupPower := Value;
          1: (Item as TCargoHook).Range := Value;
          2: (Item as TCargoHook).MinPullSpeed := av[2].AsFloat;
          3: (Item as TCargoHook).MaxPullSpeed := av[2].AsFloat;
        end;
      t_DefGenerator: (Item as TDefGenerator).DamageFactor := Integer(100 - Value) * 0.01;
      t_Cistern:
        case Stat of
          0: (Item as TCistern).Capacity := Value;
          1: (Item as TCistern).Fuel := Value;
        end;
      t_Satellite:
        case Stat of
          0: (Item as TSatellite).WaterExplorationRate := Value;
          1: (Item as TSatellite).LandExplorationRate := Value;
          2: (Item as TSatellite).HillExplorationRate := Value;
          3: (Item as TSatellite).WearPerTurn := av[2].AsFloat;
        end;
    end;
end;

procedure SF_CreateHull(av: array of TVarEC; code: TCodeEC);
var
  Hull: THull;
  HullType: THullType;
  Owner: TOwnerId;
  Level, Capacity, Series: Integer;
  PirateBuilt: Boolean;
begin
  if High(av) < 4 then
    raise Exception.Create('Error.Script CreateHull');
  HullType := THullType(av[1].AsDword);
  Capacity := av[2].AsInteger;
  Level := av[3].AsInteger;
  Owner := TOwnerId(av[4].AsDword);
  Series := -1;
  PirateBuilt := False;
  if High(av) > 4 then
    Series := av[5].AsInteger;
  if High(av) > 5 then
    PirateBuilt := av[6].AsInteger <> 0;
  Hull := THull.Create;
  Hull.Init(Capacity, Level, Owner, HullType, Series, PirateBuilt);
  av[0].AsDword := PtrUInt(Hull);
end;

procedure SF_CreateEquipment(av: array of TVarEC; code: TCodeEC);
var
  Item: TEquipment;
  Kind: TItemType;
  Owner: TOwnerId;
  Weight, Level: Integer;
begin
  if High(av) < 4 then
    raise Exception.Create('Error.Script CreateEquipment');
  Kind := TItemType(av[1].AsDword);
  Weight := av[2].AsInteger;
  Level := av[3].AsInteger;
  Owner := TOwnerId(av[4].AsDword);
  if Kind = t_Cistern then
  begin
    Item := TCistern.Create;
    TCistern(Item).Init(Level, Weight, Owner);
  end
  else
    Item := CreateGeneratedEquipment(Kind, Weight, Byte(Level), Owner);
  av[0].AsDword := PtrUInt(Item);
end;

procedure SF_CreateArt(av: array of TVarEC; code: TCodeEC);
var
  Item: TArtefact;
  Kind: TItemType;
  Owner: TOwnerId;
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script CreateArt');
  Kind := TItemType(av[1].AsDword);
  Owner := TOwnerId(av[2].AsDword);
  Item := CreateConfiguredArtefactByItemType(Kind, Owner);
  av[0].AsDword := PtrUInt(Item);
end;

procedure SF_CreateCustomWeapon(av: array of TVarEC; code: TCodeEC);
var
  Item: TWeapon;
  Owner: TOwnerId;
  Weight, Level: Integer;
  Info: PWeaponInfo;
begin
  if High(av) < 4 then
    raise Exception.Create('Error.Script CreateEquipment');
  Info := Galaxy.RequireCustomWeaponInfo(av[1].AsString);
  Weight := av[2].AsInteger;
  Level := av[3].AsInteger;
  Owner := TOwnerId(av[4].AsDword);
  // The October executable retains only the low seven bits of script levels.
  Item := CreateGeneratedWeapon(Info, Weight, TTechLevel(Level and $7F), Owner);
  av[0].AsDword := PtrUInt(Item);
end;

procedure SF_CreateCustomArt(av: array of TVarEC; code: TCodeEC);
var
  Item: TArtefactCustom;
  ConfigName: WideString;
  Owner: TOwnerId;
  Weight, Cost: Integer;
begin
  if High(av) < 4 then
    raise Exception.Create('Error.Script CreateCustomArt');
  ConfigName := av[1].AsString;
  Weight := av[2].AsInteger;
  Cost := av[3].AsInteger;
  Owner := TOwnerId(av[4].AsDword);
  Item := TArtefactCustom.Create;
  Item.ConfigBlockName := ConfigName;
  Item.LoadConfig(True);
  Item.Data[1] := 0;
  Item.Data[2] := 0;
  Item.Data[3] := 0;
  Item.Weight := Weight;
  Item.Cost := Cost;
  Item.OwnerId := Owner;
  av[0].AsDword := PtrUInt(Item);
end;

procedure SF_CustomArtData(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Item: TItem;
  Index: Integer;
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script CustomArtData');
  Obj := TObject(av[1].AsDword);
  Item := nil;
  if Obj is TItem then
    Item := TItem(Obj);
  if Obj is TScriptItem then
    Item := TScriptItem(Obj).Item;
  av[0].AsInteger := 0;
  if not (Item is TArtefactCustom) then
    Exit;
  Index := av[2].AsInteger;
  case Index of
    1: av[0].AsInteger := (Item as TArtefactCustom).Data[1];
    2: av[0].AsInteger := (Item as TArtefactCustom).Data[2];
    3: av[0].AsInteger := (Item as TArtefactCustom).Data[3];
  else
    raise Exception.Create('Error.Script CustomArtData no');
  end;
  if High(av) > 2 then
    case Index of
      1: (Item as TArtefactCustom).Data[1] := av[3].AsInteger;
      2: (Item as TArtefactCustom).Data[2] := av[3].AsInteger;
      3: (Item as TArtefactCustom).Data[3] := av[3].AsInteger;
    end;
end;

procedure SF_CustomArtTextData(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Item: TItem;
  Index: Integer;
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script CustomArtTextData');
  Obj := TObject(av[1].AsDword);
  Item := nil;
  if Obj is TItem then
    Item := TItem(Obj);
  if Obj is TScriptItem then
    Item := TScriptItem(Obj).Item;
  av[0].AsString := '';
  if not (Item is TArtefactCustom) then
    Exit;
  Index := av[2].AsInteger;
  case Index of
    1: av[0].AsString := (Item as TArtefactCustom).TextData1;
    2: av[0].AsString := (Item as TArtefactCustom).TextData2;
    3: av[0].AsString := (Item as TArtefactCustom).TextData3;
  else
    raise Exception.Create('Error.Script CustomArtTextData no');
  end;
  if High(av) > 2 then
    case Index of
      1: (Item as TArtefactCustom).TextData1 := av[3].AsString;
      2: (Item as TArtefactCustom).TextData2 := av[3].AsString;
      3: (Item as TArtefactCustom).TextData3 := av[3].AsString;
    end;
end;

procedure SF_CreateMM(av: array of TVarEC; code: TCodeEC);
var
  Index: Integer;
  Item: TMicroModule;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script CreateMM');
  Index := av[1].AsInteger;
  Item := TMicroModule.Create;
  Item.Init(Index);
  av[0].AsDword := PtrUInt(Item);
end;

procedure SF_CreateNodes(av: array of TVarEC; code: TCodeEC);
var
  Item: TProtoplasm;
  DropFlag: Boolean;
  Series: TDominatorSeries;
  Count: Integer;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script CreateNodes');
  Count := av[1].AsInteger;
  DropFlag := False;
  Series := dsBlazer;
  if High(av) > 1 then
    Series := TDominatorSeries(av[2].AsInteger);
  if High(av) > 2 then
    DropFlag := av[3].AsInteger <> 0;
  Item := TProtoplasm.Create;
  Item.Init(Count, Ord(DropFlag));
  Item.DominatorSeries := Series;
  av[0].AsDword := PtrUInt(Item);
end;

procedure SF_CreateCustomCountableItem(av: array of TVarEC; code: TCodeEC);
var
  ConfigName: WideString;
  Count: Integer;
  DropFlag: Boolean;
  Item: TCountableItem;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script CreateCustomCountableItem');
  ConfigName := av[1].AsString;
  if High(av) > 1 then
    Count := av[2].AsInteger
  else
    Count := 1;
  if High(av) > 2 then
    DropFlag := av[3].AsInteger <> 0
  else
    DropFlag := False;
  Item := TCountableItem.Create;
  Item.Init(ConfigName, Count, Ord(DropFlag));
  av[0].AsDword := PtrUInt(Item);
end;

procedure SF_CreateZond(av: array of TVarEC; code: TCodeEC);
var
  Item: TSatellite;
  Owner: TOwnerId;
  Kind: Byte;
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script CreateZond');
  Kind := av[1].AsDword;
  Owner := TOwnerId(av[2].AsDword);
  Item := TSatellite.Create;
  Item.InitGenerated(Kind, Owner, NextRandomIntRange(1, 10000, Galaxy.RandomState));
  if High(av) > 4 then
  begin
    Item.WaterExplorationRate := av[3].AsInteger;
    Item.LandExplorationRate := av[4].AsInteger;
    Item.HillExplorationRate := av[5].AsInteger;
  end;
  av[0].AsDword := PtrUInt(Item);
end;

procedure SF_ExistingZonds(av: array of TVarEC; code: TCodeEC);
var
  Index: Integer;
begin
  if High(av) < 1 then
    av[0].AsInteger := Galaxy.CountExistingSatellites
  else
  begin
    Index := av[1].AsInteger;
    if (Index >= 0) and (Index < GetPlayer.Satellites.Count) then
    begin
      if (High(av) > 1) and (av[2].AsInteger = 1) then
        av[0].AsDword := PtrUInt(TSatellite(GetPlayer.Satellites[Index]).TargetPlanet)
      else
        av[0].AsDword := PtrUInt(GetPlayer.Satellites[Index]);
    end
    else
      av[0].AsDword := 0;
  end;
end;

procedure SF_FreeItem(av: array of TVarEC; code: TCodeEC);
var
  Item: TItem;
  Obj: TObject;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script FreeItem');
  Obj := TObject(av[1].AsDword);
  Item := nil;
  if Obj is TItem then
    Item := TItem(Obj);
  if Obj is TScriptItem then
    Item := TScriptItem(Obj).Item;
  if Item = nil then
    Exit;
  if Item.ScriptItem <> nil then
    (Item.ScriptItem as TScriptItem).Item := nil;
  Item.Free;
end;

procedure SF_ShipJoinsClan(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script ShipJoinsClan');
  Ship := TShip(av[1].AsDword);
  if (Ship.TypeId = stPirate) and (Ship.OwnerId <> oiPirate) then
  begin
    Inc(Galaxy.PirateClanCount);
    Dec(Galaxy.PirateCount);
  end;
  Ship.OwnerId := oiPirate;
  if GetPlayer = Ship then
    GetPlayer.PirateClanReal := True;
end;

procedure SF_AddItemToShip(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  Item, Other: TItem;
  GoodsKind: TGoodsIndex;
  Index: Integer;
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script AddItemToShip');
  Ship := TShip(av[1].AsDword);
  Item := TItem(av[2].AsDword);
  if Item is TGoods then
  begin
    GoodsKind := Byte((Item as TGoods).ItemType);
    Inc(Ship.CargoGoods[GoodsKind].Count, (Item as TGoods).Weight);
    Inc(Ship.CargoGoods[GoodsKind].TotalCost, Item.Cost);
    Item.Free;
  end
  else if Item is TCountableItem then
  begin
    for Index := 1 to Ship.Inventory.Count - 1 do
    begin
      Other := Ship.Inventory[Index];
      if not (Item as TCountableItem).CanMerge(Other) then
        Continue;
      (Other as TCountableItem).Merge(Item);
      Item.Free;
      Item := nil;
      Break;
    end;
    if Item <> nil then
      Ship.Inventory.Add(Item);
  end
  else if (Item is THull) and (Ship.GetHull = nil) then
  begin
    Ship.Inventory.Insert(0, Item);
    Ship.EquipItem(TEquipment(Item));
    THull(Item).OwnerShip := Ship;
    Ship.RefreshAssignedItemSlots;
    Ship.RefreshDerivedStats(True);
    Ship.ScriptItemsAct(satOnNonStandartEqChange, nil, nil, 0);
  end
  else if Item is TArtefact then
    Ship.Artefacts.Add(Item)
  else if Item is TEquipment then
    Ship.Inventory.Add(Item);
end;

procedure SF_GetItemFromShip(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  Item: TItem;
  Index, WeaponIndex: Integer;
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script GetItemFromShip');
  Ship := TShip(av[1].AsDword);
  av[0].AsDword := 0;
  if Ship <> nil then
  begin
    if (av[2].ValueKind = vkDword) and (av[2].AsDword > $10000) then
    begin
      Item := TItem(av[2].AsDword);
      Index := Ship.Inventory.IndexOf(Item);
      if Index < 0 then
        Exit;
    end
    else
    begin
      Index := av[2].AsInteger;
      if (Index < 0) or (Index >= Ship.Inventory.Count) then
        Exit;
      Item := Ship.Inventory[Index];
      if (av[2].ValueKind = vkDword) and (av[2].AsDword = 0) and (Item is THull) then
        AppendLogLineThreadSafe(
            'Warning, GetItemFromShip received 0 from dword-type variable and will remove hull from ship '
                + Ship.GetFullName(' ')
                + ' ('
                + GetScriptContextDescription
                + ')'
        );
    end;
    av[0].AsDword := PtrUInt(Item);
    if Ship.GetHull = Item then
    begin
      Ship.GetHull.OwnerShip := nil;
      Ship.UnequipSlot(t_Hull, 0);
    end
    else if (Item is TEquipment) and ((Item as TEquipment).EquippedFlag <> 0) then
    begin
      if Item.ItemType in [t_FuelTanks..t_DefGenerator] then
        Ship.UnequipSlot(Item.ItemType, 0);
      if Item is TWeapon then
        for WeaponIndex := 1 to Ship.CountEquippedWeapons do
          if Ship.Weapons[WeaponIndex] = Item then
          begin
            Ship.UnequipSlot(WeaponCategoryItemType, WeaponIndex);
            Break;
          end;
    end;
    Ship.Inventory.Delete(Index);
  end;
end;

procedure SF_GetArtFromShip(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  Item: TEquipment;
  Index: Integer;
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script GetArtFromShip');
  Ship := TShip(av[1].AsDword);
  av[0].AsDword := 0;
  if Ship <> nil then
  begin
    if (av[2].ValueKind = vkDword) and (av[2].AsDword > $10000) then
    begin
      Item := TEquipment(av[2].AsDword);
      Index := Ship.Artefacts.IndexOf(Item);
      if Index < 0 then
        Exit;
    end
    else
    begin
      Index := av[2].AsInteger;
      if (Index < 0) or (Index >= Ship.Artefacts.Count) then
        Exit;
      Item := Ship.Artefacts[Index];
    end;
    Item.Unequip;
    av[0].AsDword := PtrUInt(Item);
    Ship.Artefacts.Delete(Index);
  end;
end;

procedure SF_ArrangeItems(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script ArrangeItems');
  Ship := TShip(av[1].AsDword);
  Ship.AutoEquipInventory;
  Ship.AutoEquipArtefacts;
  Ship.DropCargoUntilNotOverloaded;
  Ship.RefreshAssignedItemSlots;
end;

procedure SF_AddItemToPlanet(av: array of TVarEC; code: TCodeEC);
var
  Planet: TPlanet;
  Item: TItem;
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script AddItemToPlanet');
  Planet := TPlanet(av[1].AsDword);
  Item := TItem(av[2].AsDword);
  av[0].AsInteger := 0;
  if (Planet <> nil) and (Item <> nil) and Planet.AddSurfaceLootEntry(Item) then
  begin
    Planet.NormalizeSurfaceLootEntries;
    av[0].AsInteger := 1;
  end;
end;

procedure SF_GetItemFromPlanet(av: array of TVarEC; code: TCodeEC);
var
  Planet: TPlanet;
  Entry: PPlanetSurfaceLootEntry;
  Index: Integer;
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script GetItemFromPlanet');
  Planet := TPlanet(av[1].AsDword);
  Index := av[2].AsInteger;
  av[0].AsDword := 0;
  if (Planet <> nil) and (Planet.SurfaceLootEntries <> nil) and (Index >= 0) and (Index < Planet.SurfaceLootEntries.Count) then
  begin
    Entry := Planet.SurfaceLootEntries[Index];
    av[0].AsDword := PtrUInt(Entry.Item);
    Planet.SurfaceLootEntries.Delete(Index);
    Entry.Item := nil;
    Dispose(Entry);
  end;
end;

procedure SF_AddItemToShop(av: array of TVarEC; code: TCodeEC);
var
  Shop: TObject;
  Item: TItem;
  Refresh: Boolean;
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script AddItemToShop');
  Shop := TObject(av[1].AsDword);
  Item := TItem(av[2].AsDword);
  av[0].AsInteger := 0;
  Refresh := (TemporaryShopSlots <> nil) and ((TemporaryShopPlanet = Shop) or (TemporaryShopStation = Shop));
  if Item = nil then
    Exit;
  if Shop is TPlanet then
  begin
    if Refresh then
      RestoreTemporaryShopStock;
    (Shop as TPlanet).EquipmentShop.Add(Item);
    av[0].AsInteger := 1;
    if Refresh then
    begin
      BuildTemporaryShopSlotGrid;
      EquipmentShopScreen.ClearGoodsControls;
      EquipmentShopScreen.BuildGoodsControls;
      EquipmentShopScreen.UpdateScrollButtons;
    end;
  end
  else if Shop is TRuins then
  begin
    if Refresh then
      RestoreTemporaryShopStock;
    (Shop as TRuins).EquipmentShop.Add(Item);
    av[0].AsInteger := 1;
    if Refresh then
    begin
      BuildTemporaryShopSlotGrid;
      EquipmentShopScreen.ClearGoodsControls;
      EquipmentShopScreen.BuildGoodsControls;
      EquipmentShopScreen.UpdateScrollButtons;
    end;
  end;
end;

procedure SF_GetItemFromShop(av: array of TVarEC; code: TCodeEC);
var
  Shop: TObject;
  Index: Integer;
  Refresh: Boolean;
  Items: TList;
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script GetItemFromShop');
  Shop := TObject(av[1].AsDword);
  av[0].AsDword := 0;
  if Shop <> nil then
  begin
    Refresh := (TemporaryShopSlots <> nil) and ((TemporaryShopPlanet = Shop) or (TemporaryShopStation = Shop));
    if Refresh then
      RestoreTemporaryShopStock;
    if Shop is TPlanet then
      Items := TPlanet(Shop).EquipmentShop
    else if Shop is TRuins then
      Items := TRuins(Shop).EquipmentShop
    else
      Exit;
    if (av[2].ValueKind = vkDword) and (av[2].AsDword > $10000) then
    begin
      Index := Items.IndexOf(Pointer(av[2].AsDword));
      if Index >= 0 then
      begin
        av[0].AsDword := av[2].AsDword;
        Items.Delete(Index);
      end;
    end
    else
    begin
      Index := av[2].AsInteger;
      if (Index >= 0) and (Index < Items.Count) then
      begin
        av[0].AsDword := PtrUInt(Items[Index]);
        Items.Delete(Index);
      end;
    end;
    if Refresh then
    begin
      BuildTemporaryShopSlotGrid;
      EquipmentShopScreen.ClearGoodsControls;
      EquipmentShopScreen.BuildGoodsControls;
      EquipmentShopScreen.UpdateScrollButtons;
    end;
  end;
end;

procedure SF_AddItemToStorage(av: array of TVarEC; code: TCodeEC);
var
  Index: Integer;
  Location: TObject;
  Item: TItem;
  Entry: PStorageEntry;
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script AddItemToStorage');
  Location := TObject(av[1].AsDword);
  Item := TItem(av[2].AsDword);
  if Item is TGoods then
    for Index := 0 to GetPlayer.StorageEntries.Count - 1 do
    begin
      Entry := GetPlayer.StorageEntries[Index];
      if Entry.LocationOwner <> Location then
        Continue;
      if not (Entry.Item is TGoods) then
        Continue;
      with Entry.Item as TGoods do
      begin
        if ItemType = Item.ItemType then
        begin
          Inc(Quantity, TGoods(Item).Quantity);
          Inc(Weight, Item.Weight);
          Inc(Cost, Item.Cost);
          Item.Free;
          GetPlayer.RefreshStorageBubbles;
          Exit;
        end;
      end;
    end;
  if Item is TCountableItem then
    for Index := 0 to GetPlayer.StorageEntries.Count - 1 do
    begin
      Entry := GetPlayer.StorageEntries[Index];
      if Entry.LocationOwner <> Location then
        Continue;
      if not (Entry.Item is TCountableItem) then
        Continue;
      with Entry.Item as TCountableItem do
      begin
        if not CanMerge(Item) then
          Continue;
        Merge(Item);
        Item.Free;
        GetPlayer.RefreshStorageBubbles;
        Exit;
      end;
    end;
  if (Location <> nil) and (Item <> nil) then
  begin
    GetPlayer.AddItemToPlayerStorage(Item, Location, -1);
    GetPlayer.RefreshStorageBubbles;
  end;
end;

procedure SF_GetItemFromStorage(av: array of TVarEC; code: TCodeEC);
var
  Index: Integer;
  Entry: PStorageEntry;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script GetItemFromStorage');
  Index := av[1].AsInteger;
  av[0].AsDword := 0;
  if (Index >= 0) and (Index < GetPlayer.StorageEntries.Count) then
  begin
    Entry := GetPlayer.StorageEntries[Index];
    GetPlayer.StorageEntries.Delete(Index);
    GetPlayer.RefreshStorageBubbles;
    av[0].AsDword := PtrUInt(Entry.Item);
    Dispose(Entry);
  end;
end;

procedure SF_FindItemInStorage(av: array of TVarEC; code: TCodeEC);
var
  Index: Integer;
  Item: TItem;
  Entry: PStorageEntry;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script FindItemInStorage');
  Item := TItem(av[1].AsDword);
  av[0].AsInteger := -1;
  for Index := 0 to GetPlayer.StorageEntries.Count - 1 do
  begin
    Entry := GetPlayer.StorageEntries[Index];
    if Entry.Item <> Item then
      Continue;
    av[0].AsInteger := Index;
    Break;
  end;
end;

procedure SF_PutItemInVault(av: array of TVarEC; code: TCodeEC);
var
  Item: TObject;
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script PutItemInVault');
  if av[2].AsDword = 0 then
  begin
    Item := Galaxy.GetStoredItem(av[1].AsString, True);
    if Item <> nil then
      Item.Free;
  end
  else
    Galaxy.StoreItem(av[1].AsString, TObject(av[2].AsDword));
end;

procedure SF_GetItemFromVault(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script GetItemFromVault');
  av[0].AsDword := PtrUInt(Galaxy.GetStoredItem(av[1].AsString, (High(av) < 2) or (av[2].AsInteger <> 0)));
end;

procedure SF_DropItemInSystem(av: array of TVarEC; code: TCodeEC);
var
  Star: TStar;
  Obj: TObject;
  Item: TItem;
  Destination, Position: TPointF;
  Entry: PMovingDropItemEntry;
  StepIndex: Integer;
begin
  if High(av) < 4 then
    raise Exception.Create('Error.Script DropItemInSystem');
  Star := TStar(av[1].AsDword);
  Obj := TObject(av[2].AsDword);
  if Obj is TScriptItem then
    Item := TScriptItem(Obj).Item
  else
    Item := TItem(Obj);
  Position.X := av[3].AsInteger;
  Position.Y := av[4].AsInteger;
  if High(av) < 6 then
  begin
    Item.Position := Position;
    Star.Items.Add(Item);
    if Star.RecordingTurnFilm then
    begin
      StepIndex := Star.CurrentStepIndex;
      Item.FilmObject := TEFilm(PrimaryFilm).AddObject(Item.Id, Item.GetGraphObject);
      TEFilm(PrimaryFilm).SetObjectPosition(StepIndex, Item.FilmObject, Item.Position);
      TEFilm(PrimaryFilm).AttachObject(StepIndex, Item.FilmObject);
    end;
  end
  else
  begin
    Destination.X := av[5].AsFloat;
    Destination.Y := av[6].AsFloat;
    av[0].AsInteger := 0;
    if (Star <> nil) and (Item <> nil) then
    begin
      Item.Position := Position;
      Entry := AllocEC(SizeOf(TMovingDropItemEntry));
      Entry.Payload := Item;
      Entry.Destination := Destination;
      Entry.SourceShipId := 0;
      Entry.InsertedIntoStar := False;
      Entry.DeployTranclucator := 0;
      av[0].AsInteger := Star.MovingDropItems.Add(Entry);
    end;
  end;
end;

procedure SF_StopMovingItem(av: array of TVarEC; code: TCodeEC);
var
  Star: TStar;
  Obj: TObject;
  Item: TItem;
  Entry: PMovingDropItemEntry;
  Index, StepIndex: Integer;
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script StopMovingItem');
  Star := TStar(av[1].AsDword);
  Obj := TObject(av[2].AsDword);
  if Obj is TScriptItem then
    Item := TScriptItem(Obj).Item
  else
    Item := TItem(Obj);
  av[0].AsInteger := 0;
  for Index := 0 to Star.MovingDropItems.Count - 1 do
  begin
    Entry := Star.MovingDropItems[Index];
    if Entry.Payload <> Item then
      Continue;
    Entry.Payload := nil;
    Star.MovingDropItems.Delete(Index);
    FreeEC(Entry);
    Star.Items.Add(Item);
    if Star.RecordingTurnFilm then
    begin
      StepIndex := Star.CurrentStepIndex;
      Item.FilmObject := TEFilm(PrimaryFilm).AddObject(Item.Id, Item.GetGraphObject);
      TEFilm(PrimaryFilm).SetObjectPosition(StepIndex, Item.FilmObject, Item.Position);
      TEFilm(PrimaryFilm).AttachObject(StepIndex, Item.FilmObject);
    end;
    av[0].AsInteger := 1;
    Break;
  end;
end;

procedure SF_StarItems(av: array of TVarEC; code: TCodeEC);
var
  Star: TStar;
  Index: Integer;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script StarItems');
  Star := TStar(av[1].AsDword);
  if Star <> nil then
  begin
    if High(av) = 1 then
      av[0].AsInteger := Star.Items.Count
    else
    begin
      Index := av[2].AsInteger;
      if (Index >= 0) and (Index < Star.Items.Count) then
        av[0].AsDword := PtrUInt(Star.Items[Index])
      else
        av[0].AsDword := 0;
    end;
  end
  else
    av[0].AsInteger := 0;
end;

procedure SF_GetItemFromStar(av: array of TVarEC; code: TCodeEC);
var
  Star: TStar;
  Item: TItem;
  Index: Integer;
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script GetItemFromStar');
  Star := TStar(av[1].AsDword);
  av[0].AsDword := 0;
  if Star <> nil then
  begin
    if (av[2].ValueKind = vkDword) and (av[2].AsDword > $10000) then
    begin
      Item := TItem(av[2].AsDword);
      Index := Star.Items.IndexOf(Item);
      if Index < 0 then
        Exit;
    end
    else
    begin
      Index := av[2].AsInteger;
      if (Index < 0) or (Index >= Star.Items.Count) then
        Exit;
      Item := Star.Items[Index];
    end;
    if not Star.RecordingTurnFilm then
      Item.ReleaseGraphObject
    else
    begin
      if Item.GraphObject <> nil then
      begin
        TEFilm(PrimaryFilm).DetachObject(Star.CurrentStepIndex, Item.FilmObject);
        Star.PendingFilmObjectRemovals.Add(Item.FilmObject);
        ReleaseSpaceObject(Item.GraphObject);
      end;
    end;
    Star.Items.Delete(Index);
    Star.ClearItemReferences(Item);
    av[0].AsDword := PtrUInt(Item);
  end;
end;

procedure SF_PlanetItems(av: array of TVarEC; code: TCodeEC);
var
  Planet: TPlanet;
  Index, Count: Integer;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script PlanetItems');
  Planet := TPlanet(av[1].AsDword);
  if Planet <> nil then
  begin
    if Planet.SurfaceLootEntries <> nil then
      Count := Planet.SurfaceLootEntries.Count
    else
      Count := 0;
    if High(av) = 1 then
      av[0].AsInteger := Count
    else
    begin
      Index := av[2].AsInteger;
      if (Index >= 0) and (Index < Count) then
        av[0].AsDword := PtrUInt(PPlanetSurfaceLootEntry(Planet.SurfaceLootEntries[Index]).Item)
      else
        av[0].AsDword := 0;
    end;
  end
  else
    av[0].AsDword := 0;
end;

procedure SF_StorageItems(av: array of TVarEC; code: TCodeEC);
var
  Index: Integer;
begin
  if High(av) < 1 then
    av[0].AsInteger := GetPlayer.StorageEntries.Count
  else
  begin
    Index := av[1].AsInteger;
    if (Index >= 0) and (Index < GetPlayer.StorageEntries.Count) then
      av[0].AsDword := PtrUInt(PStorageEntry(GetPlayer.StorageEntries[Index]).Item)
    else
      av[0].AsDword := 0;
  end;
end;

procedure SF_StorageItemLocation(av: array of TVarEC; code: TCodeEC);
var
  Index: Integer;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script StorageItemLocation');
  Index := av[1].AsInteger;
  av[0].AsDword := 0;
  if (Index >= 0) and (Index < GetPlayer.StorageEntries.Count) then
    av[0].AsDword := PtrUInt(PStorageEntry(GetPlayer.StorageEntries[Index]).LocationOwner);
end;

procedure SF_ShopItems(av: array of TVarEC; code: TCodeEC);
var
  Shop: TObject;
  Wanted, Index, Count: Integer;
  Items: TList;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script ShopItems');
  Shop := TObject(av[1].AsDword);
  if Shop = nil then
    raise Exception.Create('Error.Script ShopItems shop=nil');
  if Shop is TPlanet then
    Items := TPlanet(Shop).EquipmentShop
  else if Shop is TRuins then
    Items := TRuins(Shop).EquipmentShop
  else
    raise Exception.Create('Error.Script ShopItems obj not a shop');
  if High(av) = 1 then
  begin
    Count := 0;
    if (TemporaryShopSlots <> nil) and ((GetPlayer.CurrentPlanet = Shop) or (GetPlayer.DockedTo = Shop)) then
    begin
      for Index := 0 to TemporaryShopSlots.Count - 1 do
        if TemporaryShopSlots[Index] <> nil then
          if TShopSlot(TemporaryShopSlots[Index]).Item <> nil then
            Inc(Count);
    end
    else
      for Index := 0 to Items.Count - 1 do
        if Items[Index] <> nil then
          Inc(Count);
    av[0].AsInteger := Count;
  end
  else
  begin
    Wanted := av[2].AsInteger;
    av[0].AsDword := 0;
    if (TemporaryShopSlots <> nil) and ((GetPlayer.CurrentPlanet = Shop) or (GetPlayer.DockedTo = Shop)) then
    begin
      Count := -1;
      for Index := 0 to TemporaryShopSlots.Count - 1 do
        if TemporaryShopSlots[Index] <> nil then
          if TShopSlot(TemporaryShopSlots[Index]).Item <> nil then
          begin
            Inc(Count);
            if Count = Wanted then
            begin
              av[0].AsDword := PtrUInt(TShopSlot(TemporaryShopSlots[Index]).Item);
              Break;
            end;
          end;
    end
    else if (Wanted >= 0) and (Wanted < Items.Count) then
      av[0].AsDword := PtrUInt(Items[Wanted]);
  end;
end;

procedure SF_AddDialogOverride(av: array of TVarEC; code: TCodeEC);
var
  Entry: PScriptDialogOverride;
  DialogName: WideString;
  Index: Integer;
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script AddDialogOverride');
  DialogName := av[1].AsString;
  if CountDelimitedPartsW(DialogName, ':') > 1 then
  begin
    Index := FindScriptTemplateIndex(ExtractDelimitedPartW(DialogName, 0, ':'));
    if Index < 0 then
      Exit;
    Index := TScriptTemplUnit(ScriptTemplates[Index]).ActiveScriptIndex;
    if Index < 0 then
      Exit;
    New(Entry);
    Entry.Script := Galaxy.Scripts[Index];
    Entry.DialogName := ExtractDelimitedPartW(DialogName, 1, ':');
  end
  else
  begin
    New(Entry);
    Entry.Script := CurrentScript;
    Entry.DialogName := DialogName;
  end;
  Entry.Priority := av[2].AsInteger;
  if High(av) > 2 then
    Entry.AnswerData := av[3].AsDword
  else
    Entry.AnswerData := 0;
  if ScriptDialogOverrides = nil then
    ScriptDialogOverrides := TObjectList.Create;
  ScriptDialogOverrides.Add(Entry);
end;

procedure SF_AddDialogInject(av: array of TVarEC; code: TCodeEC);
var
  Entry: PScriptDialogInjection;
  DialogName: WideString;
  Index: Integer;
begin
  if High(av) < 4 then
    raise Exception.Create('Error.Script AddDialogInject');
  DialogName := av[1].AsString;
  if CountDelimitedPartsW(DialogName, ':') > 1 then
  begin
    Index := FindScriptTemplateIndex(ExtractDelimitedPartW(DialogName, 0, ':'));
    if Index < 0 then
      Exit;
    Index := TScriptTemplUnit(ScriptTemplates[Index]).ActiveScriptIndex;
    if Index < 0 then
      Exit;
    New(Entry);
    Entry.Script := Galaxy.Scripts[Index];
    Entry.DialogName := ExtractDelimitedPartW(DialogName, 1, ':');
  end
  else
  begin
    New(Entry);
    Entry.Script := CurrentScript;
    Entry.DialogName := DialogName;
  end;
  Entry.Text := av[2].AsString;
  Entry.Answer := av[3].AsString;
  Entry.Priority := av[4].AsInteger;
  if High(av) > 4 then
    Entry.ReplaceGreeting := av[5].AsInteger <> 0
  else
    Entry.ReplaceGreeting := False;
  if High(av) > 5 then
    Entry.AnswerData := av[6].AsDword
  else
    Entry.AnswerData := 0;
  if High(av) > 6 then
  begin
    Entry.ActionCode := av[7].AsString;
    Entry.ActionScript := CurrentScript;
  end
  else
  begin
    Entry.ActionCode := '';
    Entry.ActionScript := nil;
  end;
  if ScriptDialogInjections = nil then
    ScriptDialogInjections := TObjectList.Create;
  ScriptDialogInjections.Add(Entry);
end;

procedure SF_InjectAnswer(av: array of TVarEC; code: TCodeEC);
var
  Text, Mode: WideString;
  Count, Index: Integer;
  Entry: PScriptDialogInjection;
begin
  if High(av) < 3 then
    raise Exception.Create('Error.Script InjectAnswer');
  Text := av[1].AsString;
  if CountDelimitedPartsW(Text, ':') > 1 then
  begin
    Index := FindScriptTemplateIndex(ExtractDelimitedPartW(Text, 0, ':'));
    if Index < 0 then
      Exit;
    Index := TScriptTemplUnit(ScriptTemplates[Index]).ActiveScriptIndex;
    if Index < 0 then
      Exit;
    New(Entry);
    Entry.Script := Galaxy.Scripts[Index];
    Entry.DialogName := ExtractDelimitedPartW(Text, 1, ':');
  end
  else
  begin
    New(Entry);
    Entry.Script := CurrentScript;
    Entry.DialogName := Text;
  end;
  Entry.Text := '';
  Entry.Answer := av[2].AsString;
  Entry.Priority := 0;
  Entry.AnswerData := av[3].AsDword;
  Entry.ReplaceGreeting := False;
  if High(av) > 3 then
  begin
    Entry.ActionCode := av[4].AsString;
    Entry.ActionScript := CurrentScript;
  end
  else
  begin
    Entry.ActionCode := '';
    Entry.ActionScript := nil;
  end;
  if ScriptDialogInjections = nil then
    ScriptDialogInjections := TObjectList.Create;
  ScriptDialogInjections.Add(Entry);
  Text := Entry.Answer;
  Mode := '';
  Count := CountDelimitedPartsW(Text, '~');
  if Count > 1 then
  begin
    Mode := ExtractDelimitedPartW(Text, 0, '~');
    Text := ExtractDelimitedRangeW(Text, 1, Count - 1, '~');
  end;
  if GetPlayer.IsDockedToShip then
  begin
    if Mode = 'block' then
      RuinsTalkScreen.AddChoice(Text, 0, ScriptDialogBlockCallback)
    else if Mode = 'snap' then
      RuinsTalkScreen.AddChoice(Text, PtrInt(Entry), RuinsTalkScreen.RunInjectedDialogKeepingScroll)
    else
      RuinsTalkScreen.AddChoice(Entry.Answer, PtrInt(Entry), RuinsTalkScreen.RunInjectedDialog);
  end
  else if GetPlayer.IsOnPlanet then
  begin
    if Mode = 'block' then
      GovernmentScreen.AddChoice(Text, 0, ScriptDialogBlockCallback)
    else if Mode = 'snap' then
      GovernmentScreen.AddChoice(Text, PtrInt(Entry), GovernmentScreen.RunInjectedAnswerKeepingScroll)
    else
      GovernmentScreen.AddChoice(Entry.Answer, PtrInt(Entry), GovernmentScreen.RunInjectedAnswer);
  end
  else if Mode = 'block' then
    TalkScreen.AddChoice(Text, 0, ScriptDialogBlockCallback, 0)
  else if Mode = 'snap' then
    TalkScreen.AddChoice(Text, PtrInt(Entry), TalkScreen.RunInjectedAnswerKeepingScroll, 0)
  else
    TalkScreen.AddChoice(Entry.Answer, PtrInt(Entry), TalkScreen.RunInjectedAnswer, 0);
end;

procedure SF_AddDialogBlock(av: array of TVarEC; code: TCodeEC);
var
  Entry: PScriptDialogBlock;
  I: Integer;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script AddDialogBlock');
  if ScriptDialogBlocks = nil then
    ScriptDialogBlocks := TObjectList.Create;
  for I := 0 to ScriptDialogBlocks.Count - 1 do
  begin
    Entry := ScriptDialogBlocks[I];
    if (Entry.Script = CurrentScript) and (Entry.Text = av[1].AsString) then
    begin
      if High(av) > 1 then
        Entry.Mode := av[2].AsInteger
      else
        Entry.Mode := 2;
      Exit;
    end;
  end;
  New(Entry);
  Entry.Text := av[1].AsString;
  Entry.Script := CurrentScript;
  if High(av) > 1 then
    Entry.Mode := av[2].AsInteger
  else
    Entry.Mode := 2;
  ScriptDialogBlocks.Add(Entry);
end;

procedure SF_GotoGov(av: array of TVarEC; code: TCodeEC);
begin
  av[0].AsInteger := GetPlayer.PendingDockDialogue;
  if High(av) >= 1 then
    GetPlayer.PendingDockDialogue := av[1].AsInteger;
end;

procedure SF_GetShipPlanet(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script GetShipPlanet');
  Ship := TShip(av[1].AsDword);
  if GetPlayer.RuinsProxy = Ship then
    av[0].AsDword := PtrUInt(GetPlayer.RuinsSavedPlanet)
  else
    av[0].AsDword := PtrUInt(Ship.CurrentPlanet);
end;

procedure SF_GetShipHomePlanet(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script GetShipHomePlanet');
  Ship := TShip(av[1].AsDword);
  av[0].AsDword := PtrUInt(Ship.HomePlanet);
end;

procedure SF_GetShipRuins(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script GetShipRuins');
  Ship := TShip(av[1].AsDword);
  if GetPlayer.RuinsProxy = Ship then
    av[0].AsDword := PtrUInt(GetPlayer.RuinsSavedDockedTo)
  else
    av[0].AsDword := PtrUInt(Ship.DockedTo);
end;

procedure SF_GetTalkShip(av: array of TVarEC; code: TCodeEC);
begin
  av[0].AsDword := PtrUInt(TalkShip);
end;

procedure SF_TalkByAI(av: array of TVarEC; code: TCodeEC);
begin
  if TalkScripted then
    av[0].AsInteger := 1
  else
    av[0].AsInteger := 0;
end;

procedure SF_GetTalkType(av: array of TVarEC; code: TCodeEC);
begin
  av[0].AsInteger := Ord(TalkType);
end;

procedure SF_ScriptRun(av: array of TVarEC; code: TCodeEC);
var
  Star: TStar;
  Planet: TPlanet;
  Name: WideString;
  I: Integer;
  Script: TScript;
begin
  if High(av) < 3 then
    raise Exception.Create('Error.Script ScriptRun');
  Star := TStar(av[1].AsDword);
  Planet := TPlanet(av[2].AsDword);
  Name := av[3].AsString;
  av[0].AsInteger := 0;
  for I := 0 to Galaxy.Scripts.Count - 1 do
  begin
    Script := Galaxy.Scripts[I];
    if Script.ScriptFileName = Name then
    begin
      if Script.Ships.Count > 0 then
        Exit;
      if TryRestartScript(Script, Star, Planet) then
        av[0].AsInteger := 1;
      Exit;
    end;
  end;
  if TryStartScriptByName(Star, Planet, Name) then
    av[0].AsInteger := 1;
end;

procedure SF_SFT(av: array of TVarEC; code: TCodeEC);
var
  I: Integer;

  procedure LogArray(Prefix: WideString; Value: TVarEC); { Nested in SF_SFT; Value must resolve to an array. }
  var
    I: Integer;
    Item: TVarEC;
    Path: WideString;
  begin
    for I := 0 to Value.AsArray.Count - 1 do
    begin
      Item := Value.AsArray[I];
      if Item.Name <> '' then
        Path := Prefix + '''' + Item.Name + ''''
      else
        Path := Prefix + IntToWideString(I);
      if Item.ValueKind <> vkArray then
        AppendLogLineThreadSafe(AnsiString(Path + ']=' + Item.AsString))
      else
        LogArray(Path + ',', Item);
    end;
  end;
begin
  if High(av) < 1 then
    Exit;
  for I := 1 to High(av) do
    if av[I].ValueKind = vkArray then
      LogArray(av[I].Name + '[', av[I])
    else
      AppendLogLineThreadSafe(AnsiString(av[I].AsString));
end;

procedure SF_StartTextQuest(av: array of TVarEC; code: TCodeEC);
var
  Request: PQueuedTextQuest;
begin
  if High(av) = 0 then
  begin
    av[0].AsInteger := QueuedTextQuests.Count;
    Exit;
  end;

  New(Request);
  Request.Name := av[1].AsString;
  if High(av) > 1 then
    Request.SuccessCaption := av[2].AsString
  else
    Request.SuccessCaption := '';
  if High(av) > 2 then
    Request.FailureCaption := av[3].AsString
  else
    Request.FailureCaption := '';
  Request.Script := CurrentScript;
  QueuedTextQuests.Add(Request);
  if CurrentScript <> nil then
    CurrentScript.InitCode.LocalVar.NamedItems['GQuestStatus'].AsInteger := Ord(sqsQueued);
  av[0].AsInteger := 1;
end;

procedure SF_CreateABShip(av: array of TVarEC; code: TCodeEC);
var
  Ship: TabShipAI;
  Obj: TObject;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script CreateABShip');
  if CurrentScript <> StagedArcadeShipScript then
    StagedArcadeShips.Clear;
  StagedArcadeShipScript := CurrentScript;
  Ship := TabShipAI.Create;
  Ship.SpawnGraphKey := av[1].AsString;
  Ship.RandomRewardsDisabled := True;
  if High(av) > 1 then
    Ship.Team := av[2].AsInteger
  else
    Ship.Team := 0;
  if High(av) > 2 then
    Ship.HealthScalePercent := av[3].AsInteger
  else
    Ship.HealthScalePercent := 100;
  if High(av) > 3 then
    Ship.DamageScalePercent := av[4].AsInteger
  else
    Ship.DamageScalePercent := 100;
  if High(av) > 4 then
    Ship.ScriptLabel := av[5].AsString
  else
    Ship.ScriptLabel := '';
  if High(av) > 5 then
  begin
    Obj := TObject(av[6].AsDword);
    if av[6].AsInteger = -1 then
      Ship.RandomRewardsDisabled := False
    else if Obj is TScriptItem then
      Ship.RewardObject := TScriptItem(Obj).Item
    else
      Ship.RewardObject := Obj;
  end
  else
    Ship.RewardObject := nil;
  StagedArcadeShips.Add(Ship);
  av[0].AsDword := PtrUInt(Ship);
end;

procedure SF_ConvertToABShip(av: array of TVarEC; code: TCodeEC);
var
  I: Integer;
  Source: TShip;
  Ship: TabShipAI;
  Weapon: TWeapon;
  Obj: TObject;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script ConvertToABShip');
  if CurrentScript <> StagedArcadeShipScript then
    StagedArcadeShips.Clear;
  StagedArcadeShipScript := CurrentScript;
  Source := TShip(av[1].AsDword);
  if Source <> nil then
  begin
    Ship := TabShipAI.Create;
    Ship.RandomRewardsDisabled := True;
    if Source.Graphic is TRuinsSE then
      Ship.CreateRuinsVisual(Source.Graphic.GraphKey, Max(Source.Graphic.Size.X, Source.Graphic.Size.Y))
    else
      Ship.CreateShipVisual(Source.Graphic.GraphKey, Source.Graphic.Size.X);
    Ship.ConvertedFromGameShip := True;
    Ship.MaxHealth := Source.GetHull.Weight;
    Ship.Health := Source.GetHull.HullPoints;
    Ship.WeaponCount := 0;
    Source.RefreshAssignedItemSlots;
    for I := 0 to 4 do
    begin
      Weapon := Source.FindEquippedItemInSlot(WeaponCategoryItemType, I) as TWeapon;
      if Source.IsEquipmentUsable(Weapon) then
      begin
        if Weapon.ItemType <> t_CustomWeapon then
          ab_Weapon_Initialize(@Ship.Weapons[I], Ord(Weapon.ItemType))
        else
          ab_Weapon_Initialize(@Ship.Weapons[I], Weapon.GetWeaponInfo.ArcadeWeaponType);
        Ship.Weapons[I].SlotData := Weapon.AssignedSlotData;
        Inc(Ship.WeaponCount);
      end;
    end;
    Ship.PrimaryWeapon := 0;
    if High(av) > 1 then
      Ship.Team := av[2].AsInteger
    else
      Ship.Team := 0;
    if High(av) > 2 then
      Ship.HealthScalePercent := av[3].AsInteger
    else
      Ship.HealthScalePercent := 100;
    if High(av) > 3 then
      Ship.DamageScalePercent := av[4].AsInteger
    else
      Ship.DamageScalePercent := 100;
    if High(av) > 4 then
      Ship.ScriptLabel := av[5].AsString
    else
      Ship.ScriptLabel := '';
    if High(av) > 5 then
    begin
      Obj := TObject(av[6].AsDword);
      if av[6].AsInteger = -1 then
        Ship.RandomRewardsDisabled := False
      else if Obj is TScriptItem then
        Ship.RewardObject := TScriptItem(Obj).Item
      else
        Ship.RewardObject := Obj;
    end
    else
      Ship.RewardObject := nil;
    StagedArcadeShips.Add(Ship);
    av[0].AsDword := PtrUInt(Ship);
  end;
end;

procedure SF_ABShipModifiers(av: array of TVarEC; code: TCodeEC);
var
  Ship: TabShip;
  Value: PSingle;
  Name: WideString;
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script PlayerABDamageMod');
  if TPlayer(av[1].AsDword) = GetPlayer then
    Ship := PlayerArcadeShip
  else
    Ship := TabShip(av[1].AsDword);
  if Ship = nil then
  begin
    av[0].AsInteger := 0;
    Exit;
  end;

  Name := LowerCase(AnsiString(av[2].AsString));
  if Name = 'damage' then
    Value := @Ship.WeaponDamageScale
  else if Name = 'recharge' then
    Value := @Ship.AmmoRechargeScale
  else if Name = 'speed' then
    Value := @Ship.MovementScale
  else if Name = 'gravity' then
    Value := @Ship.GravityScale
  else if Name = 'regen' then
    Value := @Ship.RegenerationRate
  else if Name = 'fragility' then
    Value := @Ship.DamageTakenScale
  else if Name = 'luck' then
    Value := @Ship.LuckScale
  else
    Exit;
  av[0].AsInteger := Round(100 * Value^);
  if High(av) > 2 then
    Value^ := av[3].AsInteger * 0.01;
end;

procedure SF_StartAB(av: array of TVarEC; code: TCodeEC);
var
  Request: PScriptABRequest;
begin
  if High(av) = 0 then
  begin
    av[0].AsInteger := QueuedArcadeBattles.Count;
    Exit;
  end;

  if CurrentScript <> StagedArcadeShipScript then
    StagedArcadeShips.Clear;
  StagedArcadeShipScript := CurrentScript;
  New(Request);
  Request.MapName := av[1].AsString;
  Request.BackgroundId := 0;
  Request.BackgroundMapName := '';
  Request.Script := CurrentScript;
  Request.Ships := TObjectList.Create;
  while StagedArcadeShips.Count > 0 do
  begin
    Request.Ships.Add(StagedArcadeShips[0]);
    StagedArcadeShips.Delete(0);
  end;
  if High(av) > 1 then
  begin
    if av[2].ValueKind = vkInt then
      Request.BackgroundId := av[2].AsInteger
    else if av[2].ValueKind = vkString then
      Request.BackgroundMapName := av[2].AsString;
  end;
  QueuedArcadeBattles.Add(Request);
  if CurrentScript <> nil then
    CurrentScript.InitCode.LocalVar.NamedItems['GABStatus'].AsInteger := 1;
  av[0].AsInteger := 1;
end;

procedure SF_StartRobots(av: array of TVarEC; code: TCodeEC);
var
  Request: PScriptPBRequest;
begin
  if High(av) = 0 then
  begin
    av[0].AsInteger := QueuedPlanetaryBattles.Count;
    Exit;
  end;

  if High(av) < 5 then
    raise Exception.Create('Error.Script StartRobots');
  New(Request);
  Request.MapName := av[1].AsString;
  Request.StartText := av[2].AsString;
  Request.SuccessText := av[3].AsString;
  Request.FailureText := av[4].AsString;
  Request.PlaceText := av[5].AsString;
  if High(av) > 5 then
    Request.StartText := av[6].AsString + Request.StartText
  else
    Request.StartText := '621' + Request.StartText;
  Request.Script := CurrentScript;
  QueuedPlanetaryBattles.Add(Request);
  if CurrentScript <> nil then
    CurrentScript.InitCode.LocalVar.NamedItems['GRobotStatus'].AsInteger := 1;
end;

procedure SF_MarkRobotsMapAsUsed(av: array of TVarEC; code: TCodeEC);
var
  I: Integer;
  Name: WideString;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script MarkRobotsMapAsUsed');
  Name := av[1].AsString;
  for I := 0 to High(RobotMapDefinitions) do
  begin
    if RobotMapDefinitions[I].Map <> Name then
      Continue;
    SetLength(GetPlayer.PlanetBattleHistory, High(GetPlayer.PlanetBattleHistory) + 2);
    with GetPlayer.PlanetBattleHistory[High(GetPlayer.PlanetBattleHistory)] do
    begin
      MapId := RobotMapDefinitions[I].Id;
      Statistics.SignedTimeMs := 0;
      Statistics.RobotsBuilt := 0;
      Statistics.RobotsDestroyed := 0;
      Statistics.TurretsBuilt := 0;
      Statistics.TurretsDestroyed := 0;
      Statistics.BuildingsDestroyed := 0;
      ResultCode := 1;
      CompletionMode := 0;
      DateTurn := Galaxy.CurrentTurn;
    end;
    if High(av) > 1 then
      if av[2].AsInteger <> 0 then
        GetPlayer.LastPlanetBattleTurn := Galaxy.CurrentTurn;
  end;
  // Falls through after matches; the error is unconditional.
  raise Exception.Create(AnsiString('Error.Script MarkRobotsMapAsUsed map not found ' + Name));
end;

procedure SF_ShipOwner(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  WasPirateClan, IsPirateClan: Boolean;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script ShipOwner');
  Ship := TShip(av[1].AsDword);
  if Ship <> nil then
  begin
    av[0].AsInteger := Ord(Ship.OwnerId);
    if High(av) > 1 then
    begin
      WasPirateClan := (Ship.TypeId = stPirate) and (Ship.OwnerId = oiPirate);
      Ship.OwnerId := TOwnerId(av[2].AsInteger);
      IsPirateClan := (Ship.TypeId = stPirate) and (Ship.OwnerId = oiPirate);
      if WasPirateClan and not IsPirateClan then
      begin
        Dec(Galaxy.PirateClanCount);
        Inc(Galaxy.PirateCount);
      end;
      if IsPirateClan and not WasPirateClan then
      begin
        Inc(Galaxy.PirateClanCount);
        Dec(Galaxy.PirateCount);
      end;
    end;
  end
  else
    av[0].AsInteger := -1;
end;

procedure SF_ShipPilotRace(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script ShipPilotRace');
  Ship := TShip(av[1].AsDword);
  if Ship <> nil then
  begin
    av[0].AsInteger := Ord(Ship.PilotRace);
    if High(av) > 1 then
      Ship.PilotRace := TOwnerId(av[2].AsInteger);
  end
  else
    av[0].AsInteger := -1;
end;

procedure SF_ShipSkill(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  Skill, Value: Integer;
  Current: Boolean;
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script ShipSkill');
  Ship := TShip(av[1].AsDword);
  if Ship = nil then
    Exit;
  Current := False;
  if av[2].ValueKind = vkString then
  begin
    if av[2].AsString = 'Accuracy' then
      Skill := 0
    else if av[2].AsString = 'AccuracyCur' then
    begin
      Skill := 0;
      Current := True;
    end
    else if av[2].AsString = 'Mobility' then
      Skill := 1
    else if av[2].AsString = 'MobilityCur' then
    begin
      Skill := 1;
      Current := True;
    end
    else if av[2].AsString = 'Technical' then
      Skill := 2
    else if av[2].AsString = 'TechnicalCur' then
    begin
      Skill := 2;
      Current := True;
    end
    else if av[2].AsString = 'Trader' then
      Skill := 3
    else if av[2].AsString = 'TraderCur' then
    begin
      Skill := 3;
      Current := True;
    end
    else if av[2].AsString = 'Charm' then
      Skill := 4
    else if av[2].AsString = 'CharmCur' then
    begin
      Skill := 4;
      Current := True;
    end
    else if av[2].AsString = 'Leadership' then
      Skill := 5
    else if av[2].AsString = 'LeadershipCur' then
    begin
      Skill := 5;
      Current := True;
    end
    else
      raise Exception.Create('Error.Script ShipSkill unknown query ' + av[2].AsString);
  end
  else
  begin
    Skill := av[2].AsInteger;
    if (Skill < 0) or (Skill > 5) then
      raise Exception.Create('Error.Script ShipSkill - invalid skill index');
  end;
  if Current then
    av[0].AsInteger := Ship.GetEffectiveSkillLevel(TPilotSkill(Skill))
  else
    av[0].AsInteger := Ship.BaseSkills[TPilotSkill(Skill)];
  if High(av) > 2 then
  begin
    Value := av[3].AsInteger;
    Ship.BaseSkills[TPilotSkill(Skill)] := Max(0, Min(6, Value));
  end;
end;

procedure SF_ShipFace(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script ShipFace');
  Ship := TShip(av[1].AsDword);
  if Ship = nil then
    Exit;
  if High(av) > 1 then
  begin
    if av[2].ValueKind = vkString then
    begin
      if av[2].AsString = 'Init' then
      begin
        if Ship.PortraitFaceId = -1 then
          Ship.GetCaptainPortraitResourceBase;
        av[0].AsInteger := Ship.PortraitFaceId;
      end
      else if av[2].AsString = 'New' then
      begin
        Ship.PortraitFaceId := -1;
        Ship.GetCaptainPortraitResourceBase;
        av[0].AsInteger := Ship.PortraitFaceId;
      end
      else if av[2].AsString = 'Path' then
        av[0].AsString := Ship.GetCaptainPortraitResourceBase
      else
        raise Exception.Create('Error.Script ShipFace unknown keyword - ' + av[2].AsString);
    end
    else
    begin
      av[0].AsInteger := Ship.PortraitFaceId;
      Ship.PortraitFaceId := av[2].AsInteger;
    end;
  end
  else
    av[0].AsInteger := Ship.PortraitFaceId;
end;

procedure SF_ShipFreeExp(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script ShipFreeExp');
  Ship := TShip(av[1].AsDword);
  if Ship = nil then
    Exit;
  av[0].AsInteger := Ship.FreeExperience;
  if High(av) > 1 then
    Ship.FreeExperience := av[2].AsInteger;
end;

procedure SF_GetShipExpByType(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script GetShipExpByType');
  Ship := TShip(av[1].AsDword);
  if Ship = nil then
    Exit;
  if (High(av) = 1) or (GetPlayer <> Ship) then
    av[0].AsInteger := Ship.TotalExperience
  else
    case av[2].AsInteger of
      1: av[0].AsInteger := GetPlayer.ExperienceByDominators;
      2: av[0].AsInteger := GetPlayer.ExperienceByPirates;
      3: av[0].AsInteger := GetPlayer.ExperienceByNormals;
      4: av[0].AsInteger := GetPlayer.ExperienceByTraderCareer;
      5:
        av[0].AsInteger :=
            GetPlayer.TotalExperience
                - GetPlayer.ExperienceByDominators
                - GetPlayer.ExperienceByPirates
                - GetPlayer.ExperienceByNormals
                - GetPlayer.ExperienceByTraderCareer;
    else
      av[0].AsInteger := Ship.TotalExperience;
    end;
end;

procedure SF_CoordX(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Position: TPointF;
  Link: PConstellationStarLink;
  Index: Integer;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script CoordX');
  Obj := TObject(av[1].AsDword);
  av[0].AsInteger := 0;
  if Obj = nil then
    Exit;
  if Obj is TShip then
    Position := (Obj as TShip).Position
  else if Obj is TItem then
    Position := (Obj as TItem).Position
  else if Obj is TScriptItem then
  begin
    if (Obj as TScriptItem).Item <> nil then
      Position := (Obj as TScriptItem).Item.Position
    else
      raise Exception.Create('Error.Script CoordX - script item does not exist');
  end
  else if Obj is TScriptPlace then
    Position := (Obj as TScriptPlace).GetPoint
  else if Obj is TPlanet then
    Position := (Obj as TPlanet).GetPosition
  else if Obj is TStar then
    Position := (Obj as TStar).Position
  else if Obj is TAsteroid then
    Position := (Obj as TAsteroid).Position
  else if Obj is TMissile then
    Position := (Obj as TMissile).Position
  else
    raise Exception.Create('Error.Script CoordX - Object type not supported');
  av[0].AsInteger := Round(Position.X);
  if High(av) <= 1 then
    Exit;
  Position.X := av[2].AsInteger;
  if Obj is TShip then
    (Obj as TShip).Position := Position
  else if Obj is TItem then
    (Obj as TItem).Position := Position
  else if Obj is TScriptItem then
    (Obj as TScriptItem).Item.Position := Position
  else if Obj is TScriptPlace then
  begin
    with IntegerPointToPolar(Classes.Point(Round(Position.X), Round(Position.Y))) do
    begin
      (Obj as TScriptPlace).Radius := Round(Radius);
      (Obj as TScriptPlace).AngleOffset := AngleRadians;
    end;
  end
  else if Obj is TPlanet then
  begin
    (Obj as TPlanet).Orbit := TPolarPoint(IntegerPointToPolar(Classes.Point(Round(Position.X), Round(Position.Y))));
    (Obj as TPlanet).Graphic.SetPosition(Position);
  end
  else if Obj is TStar then
  begin
    with TStar(Obj).Constellation.StarLinks do
      for Index := 0 to Count - 1 do
      begin
        Link := Items[Index];
        if (Link.StartPoint.X = TStar(Obj).Position.X) and (Link.StartPoint.Y = TStar(Obj).Position.Y) then
        begin
          Link.StartPoint.X := Position.X;
          Link.StartPoint.Y := Position.Y;
        end;
        if (Link.EndPoint.X = TStar(Obj).Position.X) and (Link.EndPoint.Y = TStar(Obj).Position.Y) then
        begin
          Link.EndPoint.X := Position.X;
          Link.EndPoint.Y := Position.Y;
        end;
      end;
    (Obj as TStar).Position := Position;
  end
  else if Obj is TAsteroid then
    (Obj as TAsteroid).Position := Position
  else if Obj is TMissile then
    (Obj as TMissile).Position := Position;
end;

procedure SF_CoordY(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Position: TPointF;
  Link: PConstellationStarLink;
  Index: Integer;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script CoordY');
  Obj := TObject(av[1].AsDword);
  av[0].AsInteger := 0;
  if Obj = nil then
    Exit;
  if Obj is TShip then
    Position := (Obj as TShip).Position
  else if Obj is TItem then
    Position := (Obj as TItem).Position
  else if Obj is TScriptItem then
  begin
    if (Obj as TScriptItem).Item <> nil then
      Position := (Obj as TScriptItem).Item.Position
    else
      raise Exception.Create('Error.Script CoordY - script item does not exist');
  end
  else if Obj is TScriptPlace then
    Position := (Obj as TScriptPlace).GetPoint
  else if Obj is TPlanet then
    Position := (Obj as TPlanet).GetPosition
  else if Obj is TStar then
    Position := (Obj as TStar).Position
  else if Obj is TAsteroid then
    Position := (Obj as TAsteroid).Position
  else if Obj is TMissile then
    Position := (Obj as TMissile).Position
  else
    raise Exception.Create('Error.Script CoordY - Object type not supported');
  av[0].AsInteger := Round(Position.Y);
  if High(av) <= 1 then
    Exit;
  Position.Y := av[2].AsInteger;
  if Obj is TShip then
    (Obj as TShip).Position := Position
  else if Obj is TItem then
    (Obj as TItem).Position := Position
  else if Obj is TScriptItem then
    (Obj as TScriptItem).Item.Position := Position
  else if Obj is TScriptPlace then
  begin
    with IntegerPointToPolar(Classes.Point(Round(Position.X), Round(Position.Y))) do
    begin
      (Obj as TScriptPlace).Radius := Round(Radius);
      (Obj as TScriptPlace).AngleOffset := AngleRadians;
    end;
  end
  else if Obj is TPlanet then
  begin
    (Obj as TPlanet).Orbit := TPolarPoint(IntegerPointToPolar(Classes.Point(Round(Position.X), Round(Position.Y))));
    (Obj as TPlanet).Graphic.SetPosition(Position);
  end
  else if Obj is TStar then
  begin
    with TStar(Obj).Constellation.StarLinks do
      for Index := 0 to Count - 1 do
      begin
        Link := Items[Index];
        if (Link.StartPoint.X = TStar(Obj).Position.X) and (Link.StartPoint.Y = TStar(Obj).Position.Y) then
        begin
          Link.StartPoint.X := Position.X;
          Link.StartPoint.Y := Position.Y;
        end;
        if (Link.EndPoint.X = TStar(Obj).Position.X) and (Link.EndPoint.Y = TStar(Obj).Position.Y) then
        begin
          Link.EndPoint.X := Position.X;
          Link.EndPoint.Y := Position.Y;
        end;
      end;
    (Obj as TStar).Position := Position;
  end
  else if Obj is TAsteroid then
    (Obj as TAsteroid).Position := Position
  else if Obj is TMissile then
    (Obj as TMissile).Position := Position;
end;

procedure SF_ShipSetCoords(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 3 then
    raise Exception.Create('Error.Script ShipSetCoords');
  Ship := TShip(av[1].AsDword);
  if Ship = nil then
    Exit;
  Ship.Position.X := av[2].AsInteger;
  Ship.Position.Y := av[3].AsInteger;
  Ship.Graphic.SetPosition(Ship.Position);
end;

procedure SF_ShipAngle(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script ShipAngle');
  Ship := TShip(av[1].AsDword);
  if Ship = nil then
    Exit;
  av[0].AsFloat := Ship.MovementDirection;
  if High(av) > 1 then
  begin
    Ship.MovementDirection := av[2].AsFloat;
    Ship.Graphic.SetAngle(HeadingDegreesToByte(Ship.MovementDirection));
  end;
end;

procedure SF_ObjectType(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script ObjectType');
  av[0].AsInteger := 0;
  Obj := TObject(av[1].AsDword);
  if Obj is TStar then
    av[0].AsInteger := 1
  else if Obj is THole then
    av[0].AsInteger := 2
  else if Obj is TPlanet then
    av[0].AsInteger := 3
  else if Obj is TRuins then
    av[0].AsInteger := 4
  else if Obj is TShip then
    av[0].AsInteger := 5
  else if Obj is TItem then
    av[0].AsInteger := 6
  else if Obj is TMissile then
    av[0].AsInteger := 7
  else if Obj is TAsteroid then
    av[0].AsInteger := 8;
end;

procedure SF_ShipInHyperSpace(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script ShipInHyperSpace');
  av[0].AsInteger := 0;
  Ship := TShip(av[1].AsDword);
  if Ship = nil then
    Exit;
  if (High(av) > 1) and (av[2].AsInteger <> 0) then
    while Ship.DockedTo <> nil do
      Ship := Ship.DockedTo;
  av[0].AsInteger := Ord(Ship.InHyperspace);
end;

procedure SF_ShipStatus(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Ranger: TRanger;
  Career: TRangerCareer;
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script ShipStatus');
  Obj := TObject(av[1].AsDword);
  if Obj is TRanger then
    Ranger := TRanger(Obj)
  else
    raise Exception.Create('Error.Script ShipStatus - not Ranger');
  Career := TRangerCareer(av[2].AsInteger);
  av[0].AsInteger := Ranger.CareerStatus[Career];
  if High(av) > 2 then
    Ranger.CareerStatus[Career] := av[3].AsInteger;
end;

procedure SF_BuyRanger(av: array of TVarEC; code: TCodeEC);
var
  Planet: TPlanet;
  Ship: TShip;
  MoneyPercent: Integer;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script BuyRanger');
  MoneyPercent := 100;
  if High(av) > 1 then
    MoneyPercent := av[2].AsInteger;
  Planet := TPlanet(av[1].AsDword);
  if Planet <> nil then
  begin
    Ship := TShip(Planet.BuyRanger(MoneyPercent));
    av[0].AsDword := PtrUInt(Ship);
  end;
end;

procedure SF_BuyWarrior(av: array of TVarEC; code: TCodeEC);
var
  Planet: TPlanet;
  Ship: TShip;
  MoneyPercent: Integer;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script BuyWarrior');
  MoneyPercent := 100;
  if High(av) > 1 then
    MoneyPercent := av[2].AsInteger;
  Planet := TPlanet(av[1].AsDword);
  if Planet <> nil then
  begin
    Ship := TShip(Planet.BuyWarrior(MoneyPercent));
    av[0].AsDword := PtrUInt(Ship);
  end;
end;

procedure SF_BuyBigWarrior(av: array of TVarEC; code: TCodeEC);
var
  Planet: TPlanet;
  Ship: TShip;
  MoneyPercent: Integer;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script BuyBigWarrior');
  MoneyPercent := 100;
  if High(av) > 1 then
    MoneyPercent := av[2].AsInteger;
  Planet := TPlanet(av[1].AsDword);
  if Planet <> nil then
  begin
    Ship := TShip(Planet.BuyFlagship(MoneyPercent));
    av[0].AsDword := PtrUInt(Ship);
  end;
end;

procedure SF_BuyDomik(av: array of TVarEC; code: TCodeEC);
var
  Planet: TPlanet;
  Ship: TShip;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script BuyDomik');
  Planet := TPlanet(av[1].AsDword);
  if Planet <> nil then
  begin
    Ship := TShip(Planet.SpawnWeightedDominatorShip);
    av[0].AsDword := PtrUInt(Ship);
  end;
end;

procedure SF_BuyDomikExtremal(av: array of TVarEC; code: TCodeEC);
var
  Planet: TPlanet;
  Ship: TShip;
  SavedSeries: TDominatorSeries;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script BuyDomikExtremal');
  Planet := TPlanet(av[1].AsDword);
  if Planet <> nil then
  begin
    if High(av) = 1 then
      Ship := TShip(Planet.SpawnWeightedDominatorShip)
    else if High(av) = 2 then
      Ship := TShip(Planet.SpawnDominatorShip(TKlingType(av[2].AsInteger)))
    else
    begin
      SavedSeries := Planet.CurrentStar.DominatorSeries;
      Planet.CurrentStar.DominatorSeries := TDominatorSeries(av[3].AsInteger);
      Ship := TShip(Planet.SpawnDominatorShip(TKlingType(av[2].AsInteger)));
      Planet.CurrentStar.DominatorSeries := SavedSeries;
    end;
    av[0].AsDword := PtrUInt(Ship);
  end;
end;

procedure SF_BuyTranclucator(av: array of TVarEC; code: TCodeEC);
var
  Planet: TPlanet;
  Ship: TShip;
  BasicEquipment: Boolean;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script BuyTrank');
  Planet := TPlanet(av[1].AsDword);
  if Planet <> nil then
  begin
    BasicEquipment := True;
    if High(av) > 1 then
      BasicEquipment := av[2].AsInteger <> 0;
    Ship := TShip(Planet.SpawnTranclucator(BasicEquipment));
    av[0].AsDword := PtrUInt(Ship);
  end;
end;

procedure SF_TransferShip(av: array of TVarEC; code: TCodeEC);
var
  Destination: TObject;
  OldStar, NewStar: TStar;
  Planet: TPlanet;
  Ship, Station: TShip;
  Index: Integer;
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script TransferShip');
  Ship := TShip(av[1].AsDword);
  if Ship = nil then
    Exit;
  OldStar := Ship.CurrentStar;
  if OldStar <> nil then
  begin
    Destination := TObject(av[2].AsDword);
    if Destination <> nil then
    begin
      if not (Destination is TStar) and not (Destination is TPlanet) and not (Destination is TShip) then
        raise Exception.Create('Error.Script TransferShip - invalid destination');
      Planet := nil;
      Station := nil;
      if Destination is TPlanet then
      begin
        Planet := TPlanet(Destination);
        NewStar := Planet.CurrentStar;
      end
      else if Destination is TShip then
      begin
        Station := TShip(Destination);
        NewStar := Station.CurrentStar;
      end
      else
        NewStar := TStar(Destination);
      Index := OldStar.Ships.IndexOf(Ship);
      if (Index >= 0) and (OldStar.Ships.Count > Index) then
        OldStar.Ships.Delete(Index);
      NewStar.Ships.Add(Ship);
      Ship.CurrentStar := NewStar;
      if Ship.CurrentPlanet <> nil then
      begin
        if Ship is TNormalShip then
          (Ship as TNormalShip).LastDockedPlanet := Ship.CurrentPlanet;
      end
      else if (Ship.DockedTo <> nil) and (Ship is TRanger) then
        (Ship as TRanger).LastDockedNonPlanetLocation := Ship.DockedTo;
      if (GetPlayer = Ship) and (TemporaryShopSlots <> nil) then
        RestoreTemporaryShopStock;
      Ship.CurrentPlanet := Planet;
      Ship.DockedTo := Station;
      Ship.Order := soNone;
      Ship.OrderStateData := 0;
      Ship.OrderTarget := nil;
      Ship.OrderDestination.X := 0;
      Ship.OrderDestination.Y := 0;
      Ship.OrderAbsolute := False;
      Ship.InHyperspace := False;
      if GetPlayer = Ship then
        if GetPlayer.IsDocked then
        begin
          BuildTemporaryShopSlotGrid;
          EquipmentShopScreen.ClearGoodsControls;
          EquipmentShopScreen.BuildGoodsControls;
        end;
    end;
  end;
end;

procedure SF_OrderLock(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script OrderLock');
  Ship := TShip(av[1].AsDword);
  if Ship = nil then
    Exit;
  av[0].AsInteger := Ship.AbsoluteScriptOrder;
  if High(av) > 1 then
    Ship.AbsoluteScriptOrder := av[2].AsInteger;
end;

procedure SF_OrderForsage(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script OrderForsage');
  Ship := TShip(av[1].AsDword);
  av[0].AsInteger := 0;
  if Ship = nil then
    Exit;
  if Ship.AfterburnerActive then
    av[0].AsInteger := 1;
  if High(av) <= 1 then
    Exit;
  if av[2].AsInteger <> 0 then
    Ship.AfterburnerActive := (Ship.GetSlotCount(sskAfterburner) > 0) and Ship.IsEquipmentUsable(Ship.GetEngine)
  else
    Ship.AfterburnerActive := False;
  Ship.RefreshDerivedStats(True);
  if (GetPlayer = Ship) and (GetInnermostScreenLoop = StarMapScreen) and (StarMapScreen.Mode = smmOrders) then
  begin
    StarMapScreen.ClearPathOverlay(True);
    GetPlayer.BuildOrderMovementPath(FullPathNodeLimit);
    StarMapScreen.BuildShipPathOverlay(Ship, False, '');
  end;
end;

procedure SF_OrderNone(av: array of TVarEC; code: TCodeEC);
var
  SavedOrderLock: Byte;
  Ship: TShip;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script OrderNone');
  Ship := TShip(av[1].AsDword);
  if Ship = nil then
    Exit;
  SavedOrderLock := Ship.AbsoluteScriptOrder;
  Ship.AbsoluteScriptOrder := 0;
  Ship.OrderNone(False);
  Ship.AbsoluteScriptOrder := SavedOrderLock;
  if GetPlayer = Ship then
    PendingPlayerFollowTarget := nil;
  if (GetPlayer = Ship) and (GetInnermostScreenLoop = StarMapScreen) and (StarMapScreen.Mode = smmOrders) then
  begin
    StarMapScreen.ClearPathOverlay(True);
    StarMapScreen.BuildShipPathOverlay(Ship, False, '');
  end;
end;

procedure SF_OrderMove(av: array of TVarEC; code: TCodeEC);
var
  Absolute: Boolean;
  Destination: TPointF;
  SavedOrderLock: Byte;
  Ship: TShip;
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script OrderMove');
  Ship := TShip(av[1].AsDword);
  if Ship = nil then
    Exit;
  SavedOrderLock := Ship.AbsoluteScriptOrder;
  Ship.AbsoluteScriptOrder := 0;
  if High(av) > 2 then
  begin
    Absolute := False;
    if High(av) > 3 then
      Absolute := av[4].AsInteger <> 0;
    Destination.X := av[2].AsInteger;
    Destination.Y := av[3].AsInteger;
    Ship.OrderMove(Destination, Absolute);
  end
  else
  begin
    if (av[2].ValueKind = vkDword) and (TObject(av[2].AsDword) is TScriptPlace) then
    begin
      Absolute := False;
      if High(av) > 2 then
        Absolute := av[3].AsInteger <> 0;
      Ship.OrderMove(
          TScriptPlace(av[2].AsDword).GetRandomPoint((Ship.Seed + Ship.CurrentStar.GenerationSeed) * Cardinal(Galaxy.CurrentTurn)),
          Absolute
      );
    end
    else
      raise Exception.Create('Error.Script OrderMove invalid place');
  end;
  Ship.AbsoluteScriptOrder := SavedOrderLock;
  if GetPlayer = Ship then
    PendingPlayerFollowTarget := nil;
  if (GetPlayer = Ship) and (GetInnermostScreenLoop = StarMapScreen) and (StarMapScreen.Mode = smmOrders) then
  begin
    StarMapScreen.ClearPathOverlay(True);
    StarMapScreen.BuildShipPathOverlay(Ship, False, '');
  end;
end;

procedure SF_OrderTeleport(av: array of TVarEC; code: TCodeEC);
var
  Absolute: Boolean;
  Destination: TPointF;
  SavedOrderLock: Byte;
  Ship: TShip;
  TransitionData: Integer;
begin
  if High(av) < 4 then
    raise Exception.Create('Error.Script OrderTeleport');
  Absolute := False;
  if High(av) > 4 then
    Absolute := av[5].AsInteger <> 0;
  Destination.X := av[3].AsInteger;
  Destination.Y := av[4].AsInteger;
  TransitionData := 10;
  if High(av) > 5 then
    TransitionData := av[6].AsInteger;
  if av[1].AsDword <> 0 then
    if av[2].AsDword <> 0 then
    begin
      Ship := TShip(av[1].AsDword);
      if Ship <> nil then
      begin
        SavedOrderLock := Ship.AbsoluteScriptOrder;
        Ship.AbsoluteScriptOrder := 0;
        Ship.OrderTeleport(TStar(av[2].AsDword), Destination, TransitionData, Absolute);
        Ship.AbsoluteScriptOrder := SavedOrderLock;
        if GetPlayer = Ship then
          PendingPlayerFollowTarget := nil;
        if (GetPlayer = Ship) and (GetInnermostScreenLoop = StarMapScreen) and (StarMapScreen.Mode = smmOrders) then
        begin
          StarMapScreen.ClearPathOverlay(True);
          StarMapScreen.BuildShipPathOverlay(Ship, False, '');
        end;
      end;
    end;
end;

procedure SF_OrderTakeOff(av: array of TVarEC; code: TCodeEC);
var
  SavedOrderLock: Byte;
  Ship: TShip;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script OrderTakeOff');
  Ship := TShip(av[1].AsDword);
  if Ship = nil then
    Exit;
  SavedOrderLock := Ship.AbsoluteScriptOrder;
  Ship.AbsoluteScriptOrder := 0;
  Ship.OrderTakeoff;
  Ship.AbsoluteScriptOrder := SavedOrderLock;
end;

procedure SF_OrderFollowShip(av: array of TVarEC; code: TCodeEC);
var
  Absolute: Boolean;
  FollowMode: TFollowMode;
  SavedOrderLock: Byte;
  Ship: TShip;
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script OrderFollowShip');
  Absolute := False;
  FollowMode := fmFollowNear;
  if High(av) > 2 then
    FollowMode := TFollowMode(Byte(av[3].AsInteger));
  if High(av) > 3 then
    Absolute := av[4].AsInteger <> 0;
  if (av[1].AsDword <> 0) and (av[2].AsDword <> 0) then
  begin
    Ship := TShip(av[1].AsDword);
    if Ship <> nil then
    begin
      SavedOrderLock := Ship.AbsoluteScriptOrder;
      Ship.AbsoluteScriptOrder := 0;
      Ship.OrderFollowShip(TShip(av[2].AsDword), FollowMode, Absolute);
      Ship.AbsoluteScriptOrder := SavedOrderLock;
      if (GetPlayer = Ship) and (GetInnermostScreenLoop = StarMapScreen) and (StarMapScreen.Mode = smmOrders) then
      begin
        StarMapScreen.ClearPathOverlay(True);
        StarMapScreen.BuildShipPathOverlay(Ship, False, '');
      end;
    end;
  end;
end;

procedure SF_OrderJumpHole(av: array of TVarEC; code: TCodeEC);
var
  Absolute: Boolean;
  Ship: TShip;
  Hole: THole;
  SavedOrderLock: Byte;
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script OrderJumpHole');
  Ship := TShip(av[1].AsDword);
  Hole := THole(av[2].AsDword);
  if (Ship <> nil) and (Hole <> nil) then
  begin
    Absolute := False;
    if High(av) > 2 then
      Absolute := av[3].AsInteger <> 0;
    SavedOrderLock := Ship.AbsoluteScriptOrder;
    Ship.AbsoluteScriptOrder := 0;
    Ship.OrderJumpHole(Hole, Absolute);
    Ship.AbsoluteScriptOrder := SavedOrderLock;
    if GetPlayer = Ship then
      PendingPlayerFollowTarget := nil;
    if (GetPlayer = Ship) and (GetInnermostScreenLoop = StarMapScreen) and (StarMapScreen.Mode = smmOrders) then
    begin
      StarMapScreen.ClearPathOverlay(True);
      StarMapScreen.BuildShipPathOverlay(Ship, False, '');
    end;
  end;
end;

procedure SF_RelationToRanger(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Ranger: TRanger;
  Relation: Byte;
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script RelationToRanger');
  av[0].AsInteger := 0;
  Obj := TObject(av[1].AsDword);
  Ranger := TRanger(av[2].AsDword);
  if Ranger <> nil then
  begin
    if Obj is TPlanet then
    begin
      av[0].AsInteger := Integer(TPlanet(Obj).RangerRelations[Galaxy.Rangers.IndexOf(Ranger)]);
      if High(av) > 2 then
      begin
        if av[3].AsInteger < 0 then
          Relation := 0
        else if av[3].AsInteger > 100 then
          Relation := 100
        else
          Relation := av[3].AsInteger;
        TPlanet(Obj).RangerRelations[Galaxy.Rangers.IndexOf(Ranger)] := Pointer(Relation);
      end;
    end
    else if Obj is TShip then
    begin
      if (TShip(Obj).RangerRelations <> nil) and (TShip(Obj).RangerRelations.Count > 0) then
        av[0].AsInteger := Integer(TShip(Obj).RangerRelations[Galaxy.Rangers.IndexOf(Ranger)])
      else
        av[0].AsInteger := TShip(Obj).RelationToShip(Ranger);
      if (High(av) > 2) and (TShip(Obj).RangerRelations <> nil) and (TShip(Obj).RangerRelations.Count > 0) then
      begin
        if av[3].AsInteger < 0 then
          Relation := 0
        else if av[3].AsInteger > 100 then
          Relation := 100
        else
          Relation := av[3].AsInteger;
        TShip(Obj).RangerRelations[Galaxy.Rangers.IndexOf(Ranger)] := Pointer(Relation);
      end;
    end;
  end;
end;

procedure SF_RelationToShip(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Ship: TShip;
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script RelationToShip');
  av[0].AsInteger := 0;
  Obj := TObject(av[1].AsDword);
  Ship := TShip(av[2].AsDword);
  if Ship <> nil then
  begin
    if Obj is TPlanet then
      av[0].AsInteger := TPlanet(Obj).RelationToShip(Ship)
    else if Obj is TShip then
      av[0].AsInteger := TShip(Obj).RelationToShip(Ship);
  end;
end;

procedure SF_StarOwner(av: array of TVarEC; code: TCodeEC);
var
  Star: TStar;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script StarOwner');
  Star := TStar(av[1].AsDword);
  av[0].AsInteger := 0;
  if Star = nil then
    Exit;
  av[0].AsInteger := Ord(Star.ControlFaction);
  if High(av) > 1 then
    Star.ControlFaction := TStarFaction(av[2].AsInteger);
end;

procedure SF_StarBattle(av: array of TVarEC; code: TCodeEC);
var
  Star: TStar;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script StarBattle');
  Star := TStar(av[1].AsDword);
  av[0].AsInteger := 0;
  if Star = nil then
    Exit;
  av[0].AsInteger := Star.Battle;
end;

procedure SF_StarSeries(av: array of TVarEC; code: TCodeEC);
var
  Star: TStar;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script StarSeries');
  Star := TStar(av[1].AsDword);
  av[0].AsInteger := 0;
  if Star = nil then
    Exit;
  av[0].AsInteger := Ord(Star.DominatorSeries);
  if High(av) > 1 then
    Star.DominatorSeries := TDominatorSeries(av[2].AsInteger);
end;

procedure SF_StarHoles(av: array of TVarEC; code: TCodeEC);
var
  Star: TStar;
  Hole: THole;
  I, Wanted, Found: Integer;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script StarSeries');
  Star := TStar(av[1].AsDword);
  Wanted := -1;
  Found := -1;
  av[0].AsDword := 0;
  if High(av) > 1 then
    Wanted := av[2].AsInteger;
  for I := 0 to Galaxy.Holes.Count - 1 do
  begin
    Hole := Galaxy.Holes[I];
    if (Hole.Star1 = Star) or (Hole.Star2 = Star) then
    begin
      Inc(Found);
      if Found = Wanted then
      begin
        av[0].AsDword := PtrUInt(Hole);
        Exit;
      end;
    end;
  end;
  if High(av) = 1 then
    av[0].AsInteger := Found + 1;
end;

procedure SF_StarNearbyStars(av: array of TVarEC; code: TCodeEC);
var
  Star: TStar;
  Index: Integer;
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script StarNearbyStars');
  av[0].AsDword := 0;
  Star := TStar(av[1].AsDword);
  if Star <> nil then
  begin
    Index := av[2].AsInteger;
    if (Index >= 0) and (Index < Galaxy.Stars.Count) then
      av[0].AsDword := PtrUInt(Star.StarDistances[Index].Star);
  end;
end;

procedure SF_StarNearbyStarsDist(av: array of TVarEC; code: TCodeEC);
var
  Star: TStar;
  Index: Integer;
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script StarNearbyStarsDist');
  av[0].AsDword := 0;
  Star := TStar(av[1].AsDword);
  if Star = nil then
    Exit;
  Index := av[2].AsInteger;
  if (Index >= 0) and (Index < Galaxy.Stars.Count) then
    av[0].AsInteger := Star.StarDistances[Index].Distance;
end;

procedure SF_StarSetGraph(av: array of TVarEC; code: TCodeEC);
var
  Star: TStar;
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script StarSetGraph');
  Star := TStar(av[1].AsDword);
  ReleaseSpaceObject(Star.Graphic);
  RetainSpaceObject(Star.Graphic, CreateSpaceObjectByName('Star', av[2].AsString, Point(0, 0)));
  Star.SystemProcessName := 'Process.Normal';
  Star.Graphic.SetPosition(MakePointF(0, 0));
end;

procedure SF_CreatePlanet(av: array of TVarEC; code: TCodeEC);
var
  I: Integer;
  Planet: TPlanet;
  Star: TStar;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script CreatePlanet');
  Star := TStar(av[1].AsDword);
  Planet := TPlanet.Create;
  Planet.InitGeneratedUninhabited(Star);
  Galaxy.Planets.Add(Planet);
  av[0].AsDword := PtrUInt(Planet);
  if High(av) < 2 then
    Star.Planets.Add(Planet)
  else
  begin
    Planet.Orbit.Radius := av[2].AsInteger;
    if TPlanet(Star.Planets.Last).Orbit.Radius < Planet.Orbit.Radius then
      Star.Planets.Add(Planet)
    else
      for I := 0 to Star.Planets.Count - 1 do
        if TPlanet(Star.Planets[I]).Orbit.Radius > Planet.Orbit.Radius then
        begin
          Star.Planets.Insert(I, Planet);
          Exit;
        end;
  end;
end;

procedure SF_PlanetSetGraph(av: array of TVarEC; code: TCodeEC);
var
  Planet: TPlanet;
  RotationInterval: Word;
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script PlanetSetGraph');
  Planet := TPlanet(av[1].AsDword);
  if av[2].ValueKind = vkString then
  begin
    Planet.GraphName := av[2].AsString;
    RotationInterval := Planet.Graphic.RotationTimerInterval;
    ReleaseSpaceObject(TObjectSE(Planet.Graphic));
    RetainSpaceObject(TObjectSE(Planet.Graphic), CreateSpaceObjectByName('Planet', Planet.GraphName, Point(0, 0)));
    Planet.Graphic.SetRotationTimerInterval(RotationInterval);
  end
  else
  begin
    Planet.SpriteTemplateIndex := av[2].AsInteger;
    ReleaseSpaceObject(TObjectSE(Planet.Graphic));
    RetainSpaceObject(TObjectSE(Planet.Graphic), TPlanetSE.Create);
    PlanetSpaceTemplates[Planet.SpriteTemplateIndex].SpaceObject.CopyTo(Planet.Graphic);
    Planet.GraphName := Planet.Graphic.GraphKey;
  end;
  Planet.Graphic.SetPosition(PolarToPoint(Planet.Orbit));
  Planet.GraphicRadius := Planet.Graphic.Radius;
end;

procedure SF_PlanetGetGraph(av: array of TVarEC; code: TCodeEC);
var
  Planet: TPlanet;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script PlanetGetGraph');
  Planet := TPlanet(av[1].AsDword);
  av[0].AsString := Planet.GraphName;
end;

procedure SF_PlanetPopulation(av: array of TVarEC; code: TCodeEC);
var
  Planet: TPlanet;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script PlanetPopulation');
  Planet := TPlanet(av[1].AsDword);
  if Planet = nil then
    Exit;
  av[0].AsInteger := Planet.Population;
  if High(av) > 1 then
    Planet.Population := av[2].AsInteger;
end;

procedure SF_PlanetOwner(av: array of TVarEC; code: TCodeEC);
var
  Planet: TPlanet;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script PlanetOwner');
  Planet := TPlanet(av[1].AsDword);
  if Planet = nil then
    Exit;
  av[0].AsInteger := Ord(Planet.OwnerId);
  if High(av) > 1 then
  begin
    Planet.OwnerId := TOwnerId(av[2].AsInteger);
    Planet.UpdateOwnerFlags;
  end;
end;

procedure SF_PlanetRace(av: array of TVarEC; code: TCodeEC);
var
  Planet: TPlanet;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script PlanetRace');
  Planet := TPlanet(av[1].AsDword);
  if Planet = nil then
    Exit;
  av[0].AsInteger := Ord(Planet.RaceId);
  if High(av) > 1 then
    Planet.RaceId := TOwnerId(av[2].AsInteger);
end;

procedure SF_PlanetGov(av: array of TVarEC; code: TCodeEC);
var
  Planet: TPlanet;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script PlanetGov');
  Planet := TPlanet(av[1].AsDword);
  if Planet = nil then
    Exit;
  av[0].AsInteger := Ord(Planet.Government);
  if High(av) > 1 then
    Planet.Government := TPlanetGovernment(av[2].AsInteger);
end;

procedure SF_PlanetEco(av: array of TVarEC; code: TCodeEC);
var
  Planet: TPlanet;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script PlanetEco');
  Planet := TPlanet(av[1].AsDword);
  if Planet = nil then
    Exit;
  av[0].AsInteger := Ord(Planet.Economy);
  if High(av) > 1 then
    Planet.Economy := TPlanetEconomy(av[2].AsInteger);
end;

procedure SF_PlanetTerrain(av: array of TVarEC; code: TCodeEC);
var
  Planet: TPlanet;
  Terrain: TPlanetTerrainKind;
  Value, I: Integer;
  Entry: PPlanetSurfaceLootEntry;
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script PlanetTerrain');
  Planet := TPlanet(av[1].AsDword);
  Terrain := TPlanetTerrainKind(av[2].AsInteger);
  case Terrain of
    ptWater: av[0].AsInteger := Planet.WaterTiles;
    ptLand: av[0].AsInteger := Planet.LandTiles;
    ptHill: av[0].AsInteger := Planet.HillTiles;
  else
    raise Exception.Create('Error.Script PlanetTerrain ttype');
  end;
  if High(av) <= 2 then
    Exit;
  Value := av[3].AsInteger;
  case Terrain of
    ptWater: Planet.WaterTiles := Value;
    ptLand: Planet.LandTiles := Value;
    ptHill: Planet.HillTiles := Value;
  end;
  if Planet.SurfaceLootEntries <> nil then
    for I := 0 to Planet.SurfaceLootEntries.Count - 1 do
    begin
      Entry := Planet.SurfaceLootEntries[I];
      if Entry.TerrainKind = Terrain then
        Entry.SurfaceTileIndex := Min(Entry.SurfaceTileIndex, Value);
    end;
end;

procedure SF_PlanetTerrainExplored(av: array of TVarEC; code: TCodeEC);
var
  Planet: TPlanet;
  Terrain: TPlanetTerrainKind;
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script PlanetTerrainExplored');
  Planet := TPlanet(av[1].AsDword);
  Terrain := TPlanetTerrainKind(av[2].AsInteger);
  case Terrain of
    ptWater: av[0].AsInteger := Planet.WaterExplored;
    ptLand: av[0].AsInteger := Planet.LandExplored;
    ptHill: av[0].AsInteger := Planet.HillExplored;
  else
    raise Exception.Create('Error.Script PlanetTerrainExplored ttype');
  end;
  if High(av) <= 2 then
    Exit;
  case Terrain of
    ptWater: Planet.WaterExplored := av[3].AsInteger;
    ptLand: Planet.LandExplored := av[3].AsInteger;
    ptHill: Planet.HillExplored := av[3].AsInteger;
  end;
end;

procedure SF_PlanetOrbitRadius(av: array of TVarEC; code: TCodeEC);
var
  Planet: TPlanet;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script PlanetOrbitRadius');
  Planet := TPlanet(av[1].AsDword);
  av[0].AsInteger := Round(Planet.Orbit.Radius);
  if High(av) > 1 then
    Planet.Orbit.Radius := av[2].AsInteger;
end;

procedure SF_PlanetOrbitalVelocity(av: array of TVarEC; code: TCodeEC);
var
  Planet: TPlanet;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script PlanetOrbitalVelocity');
  Planet := TPlanet(av[1].AsDword);
  av[0].AsInteger := Round(10 * Planet.OrbitalVelocity);
  if High(av) > 1 then
    Planet.OrbitalVelocity := av[2].AsInteger * 0.1;
end;

procedure SF_PlanetSize(av: array of TVarEC; code: TCodeEC);
var
  Planet: TPlanet;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script PlanetSize');
  Planet := TPlanet(av[1].AsDword);
  av[0].AsInteger := Planet.Radius;
  if High(av) > 1 then
    Planet.Radius := av[2].AsInteger;
end;

procedure SF_PlanetCurInvention(av: array of TVarEC; code: TCodeEC);
var
  Planet: TPlanet;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script PlanetCurInvention');
  Planet := TPlanet(av[1].AsDword);
  av[0].AsInteger := Ord(Planet.CurrentInvention);
  if High(av) > 1 then
    Planet.CurrentInvention := TPlanetInvention(av[2].AsInteger);
end;

procedure SF_PlanetCurInventionPoints(av: array of TVarEC; code: TCodeEC);
var
  Planet: TPlanet;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script PlanetCurInventionPoints');
  Planet := TPlanet(av[1].AsDword);
  av[0].AsFloat := Planet.CurrentInventionPoints;
  if High(av) > 1 then
    Planet.CurrentInventionPoints := av[2].AsFloat;
end;

procedure SF_PlanetInventionLevel(av: array of TVarEC; code: TCodeEC);
var
  Planet: TPlanet;
  Index: TPlanetInvention;
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script PlanetInventionLevel');
  Planet := TPlanet(av[1].AsDword);
  Index := TPlanetInvention(av[2].AsInteger);
  av[0].AsInteger := Planet.InventionLevels[Index];
  if High(av) > 2 then
    Planet.InventionLevels[Index] := av[3].AsInteger;
end;

procedure SF_PlanetBoostInventions(av: array of TVarEC; code: TCodeEC);
var
  Planet: TPlanet;
  Count, I: Integer;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script PlanetBoostInventions');
  Planet := TPlanet(av[1].AsDword);
  if High(av) > 1 then
    Count := av[2].AsInteger
  else
    Count := 1;
  for I := 1 to Count do
    Planet.AdvanceInventionProgress;
end;

procedure SF_PlanetWarriors(av: array of TVarEC; code: TCodeEC);
var
  Planet: TPlanet;
  Index: Integer;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script PlanetWarriors');
  Planet := TPlanet(av[1].AsDword);
  if High(av) = 1 then
    av[0].AsInteger := Planet.Warriors.Count
  else
  begin
    Index := av[2].AsInteger;
    if (Index >= 0) and (Index < Planet.Warriors.Count) then
      av[0].AsDword := PtrUInt(Planet.Warriors[Index])
    else
      av[0].AsDword := 0;
  end;
end;

procedure SF_GalaxySectors(av: array of TVarEC; code: TCodeEC);
var
  Index: Integer;
begin
  if High(av) = 0 then
    av[0].AsInteger := Galaxy.Constellations.Count
  else
  begin
    Index := av[1].AsInteger;
    if (Index >= 0) and (Index < Galaxy.Constellations.Count) then
      av[0].AsDword := PtrUInt(Galaxy.Constellations[Index])
    else
      av[0].AsDword := 0;
  end;
end;

procedure SF_GalaxyTechLevel(av: array of TVarEC; code: TCodeEC);
begin
  av[0].AsInteger := Galaxy.TechLevel;
end;

procedure SF_GalaxyDominatorResearchPercent(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then
    av[0].AsFloat :=
        (Galaxy.DominatorResearch[dsBlazer].Progress
                + Galaxy.DominatorResearch[dsKeller].Progress
                + Galaxy.DominatorResearch[dsTerron].Progress)
            / 3
  else
  begin
    av[0].AsFloat := Galaxy.DominatorResearch[TDominatorSeries(av[1].AsInteger)].Progress;
    if High(av) > 1 then
      Galaxy.DominatorResearch[TDominatorSeries(av[1].AsInteger)].Progress := av[2].AsFloat;
  end;
end;

procedure SF_GalaxyDominatorResearchMaterial(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script GalaxyDominatorResearchMaterial');
  av[0].AsInteger := Galaxy.DominatorResearch[TDominatorSeries(av[1].AsInteger)].Material;
  if High(av) > 1 then
    Galaxy.DominatorResearch[TDominatorSeries(av[1].AsInteger)].Material := av[2].AsInteger;
end;

procedure SF_GalaxyDiffLevels(av: array of TVarEC; code: TCodeEC);
var
  I, Total: Integer;
begin
  if High(av) > 0 then
    av[0].AsInteger := (Galaxy.DifficultyLevels[TGalaxyDifficultyIndex(av[1].AsInteger)] + 1) * 50
  else
  begin
    Total := 0;
    for I := 0 to 7 do
      Inc(Total, (Galaxy.DifficultyLevels[Byte(I)] + 1) * 50);
    av[0].AsInteger := Round(Total * 0.125);
  end;
end;

procedure SF_SectorVisible(av: array of TVarEC; code: TCodeEC);
var
  Sector: TConstellation;
  I: Integer;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script SectorVisible');
  Sector := TConstellation(av[1].AsDword);
  if Sector <> nil then
  begin
    av[0].AsInteger := Ord(Sector.Visible);
    if High(av) > 1 then
      Sector.Visible := av[2].AsInteger <> 0;
  end;
  if (High(av) > 1) and (av[2].AsInteger = 1) and (MainPiratePlanet <> nil) and (MainPiratePlanet.CurrentStar.Constellation = Sector) then
    for I := 0 to Galaxy.Constellations.Count - 1 do
      TConstellation(Galaxy.Constellations[I]).RestoreHiddenForm;
end;

procedure SF_HullHP(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Hull: THull;
  Ship: TShip;
  Amount: Integer;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script HullHP');
  av[0].AsInteger := 0;
  Obj := TObject(av[1].AsDword);
  if Obj is TShip then
    Hull := TShip(Obj).GetHull
  else if Obj is THull then
    Hull := THull(Obj)
  else if (Obj is TScriptItem) and ((Obj as TScriptItem).Item is THull) then
    Hull := (Obj as TScriptItem).Item as THull
  else
    Exit;
  av[0].AsInteger := Hull.HullPoints;
  if High(av) > 1 then
  begin
    if av[2].ValueKind = vkString then
    begin
      Amount := Round(av[2].AsInteger * 0.01 * Hull.Weight);
      if Pos('UpTo', av[2].AsString) = 1 then
        Hull.HullPoints := Max(Hull.HullPoints, Amount)
      else if Pos('DownTo', av[2].AsString) = 1 then
        Hull.HullPoints := Min(Hull.HullPoints, Amount)
      else if Pos('To', av[2].AsString) = 1 then
        Hull.HullPoints := Amount
      else if Pos('Plus', av[2].AsString) = 1 then
        Hull.HullPoints := Max(Hull.HullPoints, Min(Hull.Weight, Hull.HullPoints + Amount))
      else if Pos('Minus', av[2].AsString) = 1 then
        Dec(Hull.HullPoints, Amount)
      else
        raise Exception.Create('Error.Script HullHP - unknown key ' + av[2].AsString);
    end
    else
      Hull.HullPoints := av[2].AsInteger;
    if Obj is TShip then
      Ship := TShip(Obj)
    else
      Ship := TShip(Hull.OwnerShip);
    if (Ship <> nil) and Ship.IsHullDestroyed and not Ship.DestroyQueued then
    begin
      if av[0].AsInteger > 0 then
        Ship.ScriptItemsAct(satOnDeath, nil, nil, 0);
      if (Ship.CurrentStar <> nil) and Ship.CurrentStar.RecordingTurnFilm then
        Ship.CurrentStar.ClearShipReferences(Obj);
    end;
  end;
end;

procedure SF_HullDamageSuspectibility(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Hull: THull;
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script HullDamageSuspectibility');
  av[0].AsInteger := 0;
  Obj := TObject(av[1].AsDword);
  if Obj is TShip then
    Hull := TShip(Obj).GetHull
  else if Obj is THull then
    Hull := THull(Obj)
  else if (Obj is TScriptItem) and ((Obj as TScriptItem).Item is THull) then
    Hull := (Obj as TScriptItem).Item as THull
  else
    Exit;
  av[0].AsInteger := Round(Hull.GetFragilityFactor([TDamageKind(av[2].AsDword)]) * 100);
end;

procedure SF_HullType(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Hull: THull;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script HullType');
  av[0].AsInteger := 0;
  Obj := TObject(av[1].AsDword);
  if Obj is TShip then
    Hull := TShip(Obj).GetHull
  else if Obj is THull then
    Hull := THull(Obj)
  else if (Obj is TScriptItem) and ((Obj as TScriptItem).Item is THull) then
    Hull := (Obj as TScriptItem).Item as THull
  else
    Exit;
  av[0].AsInteger := Ord(Hull.HullType);
  if High(av) > 1 then
    Hull.HullType := THullType(av[2].AsInteger);
end;

procedure SF_HullSpecial(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Hull: THull;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script HullSpecial');
  av[0].AsInteger := 0;
  Obj := TObject(av[1].AsDword);
  if Obj is TShip then
    Hull := TShip(Obj).GetHull
  else if Obj is THull then
    Hull := THull(Obj)
  else if (Obj is TScriptItem) and ((Obj as TScriptItem).Item is THull) then
    Hull := (Obj as TScriptItem).Item as THull
  else
    Exit;
  av[0].AsInteger := Hull.SpecialModuleIndex - 1;
  if High(av) > 1 then
    Hull.SpecialModuleIndex := av[2].AsInteger + 1;
end;

procedure SF_HullSeries(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Hull: THull;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script HullSeries');
  av[0].AsInteger := 0;
  Obj := TObject(av[1].AsDword);
  if Obj is TShip then
    Hull := TShip(Obj).GetHull
  else if Obj is THull then
    Hull := THull(Obj)
  else if (Obj is TScriptItem) and ((Obj as TScriptItem).Item is THull) then
    Hull := (Obj as TScriptItem).Item as THull
  else
    Exit;
  av[0].AsInteger := Hull.HullSeries;
  if High(av) > 1 then
    Hull.HullSeries := av[2].AsInteger;
end;

procedure SF_GalaxyHoles(av: array of TVarEC; code: TCodeEC);
var
  Index: Integer;
begin
  if High(av) = 0 then
    av[0].AsInteger := Galaxy.Holes.Count
  else
  begin
    Index := av[1].AsInteger;
    if (Index >= 0) and (Index < Galaxy.Holes.Count) then
      av[0].AsDword := PtrUInt(Galaxy.Holes[Index])
    else
      av[0].AsDword := 0;
  end;
end;

procedure SF_HoleCreate2(av: array of TVarEC; code: TCodeEC);
var
  Hole: THole;
  Angle, Radius: Single;
  Star1, Star2: TStar;
  FilmObject: TEFilmObj;
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script HoleCreate2');
  Star1 := TStar(av[1].AsDword);
  Star2 := TStar(av[2].AsDword);
  Hole := THole.Create;
  if High(av) < 3 then
    Hole.InitializeGraphic('')
  else
    Hole.InitializeGraphic(av[3].AsString);
  THoleSE(Hole.Graphic).SetState(1);
  Hole.CreatedTurn := Galaxy.CurrentTurn;
  Hole.HoleType := 1;
  Hole.Star1 := Star1;
  Hole.Star2 := Star2;
  Angle := HeadingDegreesToRadians(SeededRandomIntRange(0, 359, Galaxy.RandomState));
  Radius := SeededRandomIntRange(1000, 2000, Galaxy.RandomState);
  Hole.Position1.X := Sin(Angle) * Radius;
  Hole.Position1.Y := Cos(Angle) * -Radius;
  Angle := HeadingDegreesToRadians(SeededRandomIntRange(0, 359, Galaxy.RandomState));
  Radius := SeededRandomIntRange(1000, 2000, Galaxy.RandomState);
  Hole.Position2.X := Sin(Angle) * Radius;
  Hole.Position2.Y := Cos(Angle) * -Radius;
  Galaxy.Holes.Add(Hole);
  av[0].AsDword := PtrUInt(Hole);
  if Hole.Star1.RecordingTurnFilm or Hole.Star2.RecordingTurnFilm then
  begin
    FilmObject := TEFilm(PrimaryFilm).AddObject(Hole.Id, Hole.Graphic);
    TEFilm(PrimaryFilm).SetObjectPosition(0, FilmObject, Hole.Position1);
    TEFilm(PrimaryFilm).SetHoleState(0, FilmObject, 1);
    TEFilm(PrimaryFilm).AttachObject(0, FilmObject);
  end
  else if GetPlayer.InNormalSpace and ((GetPlayer.CurrentStar = Hole.Star1) or (GetPlayer.CurrentStar = Hole.Star2)) then
    StarMapScreen.PendingHoleRefresh := Hole;
end;

procedure SF_HoleStar1(av: array of TVarEC; code: TCodeEC);
var
  Hole: THole;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script HoleStar1');
  Hole := THole(av[1].AsDword);
  if Hole <> nil then
  begin
    av[0].AsDword := PtrUInt(Hole.Star1);
    if High(av) > 1 then
      Hole.Star1 := TStar(av[2].AsDword);
  end;
end;

procedure SF_HoleStar2(av: array of TVarEC; code: TCodeEC);
var
  Hole: THole;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script HoleStar2');
  Hole := THole(av[1].AsDword);
  if Hole <> nil then
  begin
    av[0].AsDword := PtrUInt(Hole.Star2);
    if High(av) > 1 then
      Hole.Star2 := TStar(av[2].AsDword);
  end;
end;

procedure SF_HoleX1(av: array of TVarEC; code: TCodeEC);
var
  Hole: THole;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script HoleX1');
  Hole := THole(av[1].AsDword);
  if Hole = nil then
    Exit;
  av[0].AsInteger := Round(Hole.Position1.X);
  if High(av) > 1 then
    Hole.Position1.X := av[2].AsInteger;
end;

procedure SF_HoleY1(av: array of TVarEC; code: TCodeEC);
var
  Hole: THole;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script HoleY1');
  Hole := THole(av[1].AsDword);
  if Hole = nil then
    Exit;
  av[0].AsInteger := Round(Hole.Position1.Y);
  if High(av) > 1 then
    Hole.Position1.Y := av[2].AsInteger;
end;

procedure SF_HoleX2(av: array of TVarEC; code: TCodeEC);
var
  Hole: THole;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script HoleX2');
  Hole := THole(av[1].AsDword);
  if Hole = nil then
    Exit;
  av[0].AsInteger := Round(Hole.Position2.X);
  if High(av) > 1 then
    Hole.Position2.X := av[2].AsInteger;
end;

procedure SF_HoleY2(av: array of TVarEC; code: TCodeEC);
var
  Hole: THole;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script HoleY2');
  Hole := THole(av[1].AsDword);
  if Hole = nil then
    Exit;
  av[0].AsInteger := Round(Hole.Position2.Y);
  if High(av) > 1 then
    Hole.Position2.Y := av[2].AsInteger;
end;

procedure SF_HoleTurnCreate(av: array of TVarEC; code: TCodeEC);
var
  Hole: THole;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script HoleTurnCreate');
  Hole := THole(av[1].AsDword);
  av[0].AsInteger := 0;
  if Hole = nil then
    Exit;
  av[0].AsInteger := Hole.CreatedTurn;
  if High(av) > 1 then
    Hole.CreatedTurn := av[2].AsInteger;
end;

procedure SF_HoleMap(av: array of TVarEC; code: TCodeEC);
var
  Hole: THole;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script HoleMap');
  Hole := THole(av[1].AsDword);
  if Hole <> nil then
  begin
    av[0].AsString := Hole.ArcadeMapName;
    if High(av) > 1 then
      Hole.ArcadeMapName := av[2].AsString;
  end
  else
    av[0].AsString := '';
end;

procedure SF_HoleGraph(av: array of TVarEC; code: TCodeEC);
var
  Hole: THole;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script HoleGraph');
  Hole := THole(av[1].AsDword);
  if Hole <> nil then
  begin
    av[0].AsString := Hole.Graphic.GraphKey;
    if High(av) > 1 then
    begin
      if Hole.Graphic <> nil then
        ReleaseSpaceObject(Hole.Graphic);
      RetainSpaceObject(Hole.Graphic, CreateSpaceObjectByName('Hole', av[2].AsString, Point(0, 0)));
      Hole.Graphic.SetPosition(MakePointF(0, 0));
    end;
  end
  else
    av[0].AsString := '';
end;

procedure SF_StarRuins(av: array of TVarEC; code: TCodeEC);
var
  Star: TStar;
  Ship: TShip;
  I, Found: Integer;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script StarRuins');
  Star := TStar(av[1].AsDword);
  if Star <> nil then
  begin
    Found := -1;
    if High(av) = 1 then
    begin
      for I := 0 to Star.Ships.Count - 1 do
      begin
        Ship := Star.Ships[I];
        if Ship is TRuins then
          Inc(Found);
      end;
      av[0].AsInteger := Found + 1;
      Exit;
    end;
    if av[2].ValueKind = vkString then
    begin
      for I := 0 to Star.Ships.Count - 1 do
      begin
        Ship := Star.Ships[I];
        if Ship is TRuins then
        begin
          if ((Ship.TypeNameOverrideKey <> '') and (Ship.TypeNameOverrideKey = av[2].AsString))
              or ((Ship.TypeNameOverrideKey = '') and (ShipTypeNames[Ship.TypeId].Name = av[2].AsString)) then
          begin
            av[0].AsDword := PtrUInt(Ship);
            Exit;
          end;
        end;
      end;
    end
    else
      for I := 0 to Star.Ships.Count - 1 do
      begin
        Ship := Star.Ships[I];
        if Ship is TRuins then
        begin
          Inc(Found);
          if Found = av[2].AsInteger then
          begin
            av[0].AsDword := PtrUInt(Ship);
            Exit;
          end;
        end;
      end;
    av[0].AsDword := 0;
  end;
end;

procedure SF_CreateQuestItem(av: array of TVarEC; code: TCodeEC);
var
  Item: TUselessItem;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script CreateQuestItem');
  Item := TUselessItem.Create;
  Item.Init(av[1].AsString, dsBlazer, 0, False);
  if High(av) = 1 then
    Item.OwnerId := oiUninhabited
  else if av[2].AsInteger >= 0 then
    Item.OwnerId := TOwnerId(av[2].AsInteger);
  av[0].AsDword := PtrUInt(Item);
end;

procedure SF_ShipTurnBeforeEndOrder(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script ShipTurnBeforeEndOrder');
  Ship := TShip(av[1].AsDword);
  av[0].AsInteger := Ship.EstimateOrderTravelTurns;
end;

procedure SF_ShipOrder(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script ShipOrder');
  Ship := TShip(av[1].AsDword);
  if (High(av) > 1) and (av[2].ValueKind = vkString) then
  begin
    if av[2].AsString = 'X' then
    begin
      av[0].AsFloat := Ship.OrderDestination.X;
      if High(av) > 2 then
        Ship.OrderDestination.X := av[3].AsFloat;
    end
    else if av[2].AsString = 'Y' then
    begin
      av[0].AsFloat := Ship.OrderDestination.Y;
      if High(av) > 2 then
        Ship.OrderDestination.Y := av[3].AsFloat;
    end
    else
      raise Exception.Create('Error.Script ShipOrder - unknown key ' + av[2].AsString);
    Exit;
  end;
  if (GetPlayer = Ship) and (PendingPlayerFollowTarget <> nil) then
    av[0].AsInteger := -1
  else
    av[0].AsInteger := Ord(Ship.Order);
  if High(av) > 1 then
    Ship.Order := TShipOrder(av[2].AsDword);
end;

procedure SF_ShipOrderData1(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  LowWord, HighWord: Word;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script ShipOrderData1');
  Ship := TShip(av[1].AsDword);
  HighWord := Ship.OrderStateData shr 16;
  LowWord := Ship.OrderStateData and $FFFF;
  av[0].AsInteger := LowWord;
  if High(av) > 1 then
    Ship.OrderStateData := (Integer(HighWord) shl 16) + (av[2].AsInteger and $FFFF);
end;

procedure SF_ShipOrderData2(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  LowWord, HighWord: Word;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script ShipOrderData2');
  Ship := TShip(av[1].AsDword);
  HighWord := Ship.OrderStateData shr 16;
  LowWord := Ship.OrderStateData and $FFFF;
  av[0].AsInteger := HighWord;
  if High(av) > 1 then
    Ship.OrderStateData := Integer(LowWord) + ((av[2].AsInteger and $FFFF) shl 16);
end;

procedure SF_ShipOrderObj(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script ShipOrderObj');
  Ship := TShip(av[1].AsDword);
  if Ship <> nil then
  begin
    if (GetPlayer = Ship) and (PendingPlayerFollowTarget <> nil) then
      av[0].AsDword := PtrUInt(PendingPlayerFollowTarget)
    else
      av[0].AsDword := PtrUInt(Ship.OrderTarget);
    if High(av) > 1 then
    begin
      if (GetPlayer = Ship) and (PendingPlayerFollowTarget <> nil) then
        PendingPlayerFollowTarget := TShip(av[2].AsDword)
      else
        Ship.OrderTarget := TObject(av[2].AsDword);
    end;
  end;
end;

procedure SF_ShipDestination(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script ShipDestination');
  Obj := TObject(av[1].AsDword);
  if Obj <> nil then
  begin
    if GetPlayer = Obj then
    begin
      av[0].AsDword := PtrUInt(GetPlayer.QueuedTravelTarget);
      if High(av) > 1 then
        GetPlayer.QueuedTravelTarget := TStar(av[2].AsDword);
    end
    else if Obj is TRuins then
    begin
      if (High(av) > 1) and (av[2].ValueKind = vkString) and (av[2].AsString = 'Date') then
      begin
        // Native Date query reads the target pointer at +558, while its setter writes FlyDate at +55C.
        av[0].AsInteger := Integer(TRuins(Obj).FlyToStar);
        if High(av) > 2 then
          TRuins(Obj).FlyDate := av[3].AsInteger;
      end
      else
      begin
        av[0].AsDword := PtrUInt(TRuins(Obj).FlyToStar);
        if High(av) > 1 then
          TRuins(Obj).FlyToStar := TStar(av[2].AsDword);
        if High(av) > 2 then
          TRuins(Obj).FlyDate := av[3].AsInteger;
      end;
    end
    else
      av[0].AsDword := 0;
  end;
end;

procedure SF_BuildRuins(av: array of TVarEC; code: TCodeEC);
var
  Star: TStar;
  Station: TRuins;
  Kind: Integer;
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script BuildRuins');
  Star := TStar(av[1].AsDword);
  if Star <> nil then
  begin
    Station := nil;
    Kind := av[2].AsInteger;
    if TShipType(Kind) in [rstRangerCenter..rstCustomStation] then
    begin
      Station := TRuins.Create;
      Station.Init(TStationType(Kind), Star, '');
    end;
    av[0].AsDword := PtrUInt(Station);
  end;
end;

procedure SF_BuildCustomRuins(av: array of TVarEC; code: TCodeEC);
var
  Star: TStar;
  Station: TRuins;
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script BuildCustomRuins');
  Star := TStar(av[1].AsDword);
  if Star <> nil then
  begin
    Station := TRuins.Create;
    av[0].AsDword := PtrUInt(Station);
    Station.Init(rstCustomStation, Star, av[2].AsString);
    if High(av) > 2 then
      Station.CurrentStanding := TShipStanding(av[3].AsInteger)
    else
      Station.CurrentStanding := ssUnaligned;
  end;
end;

procedure SF_RuinsChangeType(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Station: TRuins;
  Index: TShipType;
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script RuinsChangeType');
  Obj := TObject(av[1].AsDword);
  if not (Obj is TRuins) then
    Exit;
  Station := TRuins(Obj);
  if av[2].ValueKind = vkString then
    for Index := rstRangerCenter to rstCustomStation do
      if av[2].AsString = ShipTypeNames[Index].Name then
      begin
        Station.TypeId := Index;
        Exit;
      end;
  Index := TShipType(av[2].AsInteger);
  if Index in [rstRangerCenter..rstCustomStation] then
    Station.TypeId := Index;
end;

procedure SF_ShipStanding(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script ShipStanding');
  Ship := TShip(av[1].AsDword);
  if Ship = nil then
    Exit;
  av[0].AsInteger := Ord(Ship.CurrentStanding);
  if High(av) > 1 then
    Ship.CurrentStanding := TShipStanding(av[2].AsInteger);
end;

procedure SF_ShipSlots(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script ShipSlots');
  Ship := TShip(av[1].AsDword);
  av[0].AsInteger := 0;
  if Ship <> nil then
    case av[2].AsInteger of
      1: av[0].AsInteger := Ship.GetSlotCount(sskWeapon);
      2: av[0].AsInteger := Ship.GetSlotCount(sskArtefact);
      3: av[0].AsInteger := Ship.GetSlotCount(sskRadar);
      4: av[0].AsInteger := Ship.GetSlotCount(sskScanner);
      5: av[0].AsInteger := Ship.GetSlotCount(sskRepairRobot);
      6: av[0].AsInteger := Ship.GetSlotCount(sskCargoHook);
      7: av[0].AsInteger := Ship.GetSlotCount(sskDefGenerator);
      8: av[0].AsInteger := Ship.GetSlotCount(sskAfterburner);
    end;
end;

procedure SF_MissileStar(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script MissileStar');
  av[0].AsDword := PtrUInt(TMissile(av[1].AsDword).CurrentStar);
end;

procedure SF_MissileType(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script MissileType');
  av[0].AsInteger := Ord(TMissile(av[1].AsDword).ItemType);
end;

procedure SF_CustomMissileType(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script CustomMissileType');
  av[0].AsString := TMissile(av[1].AsDword).GetWeaponInfo.ConfigName;
end;

procedure SF_MissileOwner(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script MissileOwner');
  av[0].AsDword := PtrUInt(TMissile(av[1].AsDword).OwnerShip);
  if High(av) > 1 then
    TMissile(av[1].AsDword).OwnerShip := TShip(av[2].AsDword);
end;

procedure SF_MissileWeaponID(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script MissileWeaponID');
  av[0].AsDword := PtrUInt(TMissile(av[1].AsDword).WeaponId);
end;

procedure SF_MissileTarget(av: array of TVarEC; code: TCodeEC);
var
  Missile: TMissile;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script MissileTarget');
  Missile := TMissile(av[1].AsDword);
  if Missile.Target <> nil then
    av[0].AsDword := PtrUInt(Missile.Target)
  else
    av[0].AsDword := PtrUInt(Missile.PreviousTarget);
  if High(av) > 1 then
    TMissile(av[1].AsDword).Target := TObject(av[2].AsDword);
end;

procedure SF_MissileMaxDamage(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script MissileMaxDamage');
  av[0].AsInteger := TMissile(av[1].AsDword).MaxDamage;
  if High(av) > 1 then
    TMissile(av[1].AsDword).MaxDamage := av[2].AsInteger;
end;

procedure SF_MissileMinDamage(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script MissileMinDamage');
  av[0].AsInteger := TMissile(av[1].AsDword).MinDamage;
  if High(av) > 1 then
    TMissile(av[1].AsDword).MinDamage := av[2].AsInteger;
end;

procedure SF_MissileLive(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script MissileLive');
  av[0].AsInteger := TMissile(av[1].AsDword).FlightTicks;
  if High(av) > 1 then
    TMissile(av[1].AsDword).FlightTicks := av[2].AsInteger;
end;

procedure SF_MissileSpeed(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script MissileSpeed');
  av[0].AsInteger := Round(TMissile(av[1].AsDword).Speed);
  if High(av) > 1 then
    TMissile(av[1].AsDword).Speed := av[2].AsInteger;
end;

procedure SF_MissileAngle(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script MissileAngle');
  av[0].AsInteger := Round(TMissile(av[1].AsDword).Direction);
  if High(av) > 1 then
    TMissile(av[1].AsDword).Direction := av[2].AsInteger;
end;

procedure SF_AsteroidMinerals(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script AsteroidMinerals');
  av[0].AsInteger := TAsteroid(av[1].AsDword).MineralCount;
  if High(av) > 1 then
    TAsteroid(av[1].AsDword).MineralCount := av[2].AsInteger;
end;

procedure SF_AsteroidGraph(av: array of TVarEC; code: TCodeEC);
var
  Asteroid: TAsteroid;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script AsteroidGraph');
  Asteroid := TAsteroid(av[1].AsDword);
  av[0].AsString := Asteroid.GraphObject.GraphKey;
  if High(av) > 1 then
  begin
    ReleaseSpaceObject(Asteroid.GraphObject);
    RetainSpaceObject(
        Asteroid.GraphObject,
        CreateSpaceObjectByName(ExtractDelimitedPartW(av[2].AsString, 0, '.'), av[2].AsString, Point(0, 0))
    );
  end;
end;

procedure SF_AsteroidRespawn(av: array of TVarEC; code: TCodeEC);
var
  Asteroid: TAsteroid;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script AsteroidRespawn');
  Asteroid := TAsteroid(av[1].AsDword);
  if Asteroid <> nil then
    Asteroid.Respawn;
end;

procedure SF_ArrayAdd(Args: array of TVarEC; Code: TCodeEC);
var
  NewValue, SourceValue: TVarEC;
begin
  if High(Args) < 2 then
    raise Exception.Create('Error.Script ArrayAdd');
  if Args[1].ValueKind <> vkArray then
    raise Exception.Create('Error.Script ArrayAdd - not array');
  SourceValue := Args[2].Resolve;
  NewValue := TVarEC.Create(SourceValue.ValueKind);
  NewValue.AssignFrom(SourceValue, False);
  if High(Args) > 2 then
    NewValue.Name := Args[3].AsString;
  Args[1].AsArray.AddItem(NewValue);
  Args[0].AsInteger := Args[1].AsArray.Count;
end;

procedure SF_ArrayDelete(Args: array of TVarEC; Code: TCodeEC);
var
  ElementIndex: Integer;
begin
  if High(Args) < 2 then
    raise Exception.Create('Error.Script ArrayDelete');
  if Args[1].ValueKind <> vkArray then
    raise Exception.Create('Error.Script ArrayDelete - not array');
  if Args[2].ValueKind = vkString then
    Args[1].AsArray.DeleteByName(Args[2].AsString)
  else
  begin
    ElementIndex := Args[2].AsInteger;
    if (ElementIndex >= 0) and (ElementIndex < Args[1].AsArray.Count) then
      Args[1].AsArray.Delete(ElementIndex);
  end;
  Args[0].AsInteger := Args[1].AsArray.Count;
end;

procedure SF_ArrayClear(Args: array of TVarEC; Code: TCodeEC);
begin
  if High(Args) < 1 then
    raise Exception.Create('Error.Script ArrayClear');
  if Args[1].ValueKind <> vkArray then
    raise Exception.Create('Error.Script ArrayClear - not array');
  Args[1].AsArray.Clear;
  { Native arrays retain one empty placeholder after this operation. }
  Args[1].AsArray.AddItem(TVarEC.Create(vkEmpty));
end;

procedure SF_ArrayDim(Args: array of TVarEC; Code: TCodeEC);
begin
  if High(Args) < 1 then
    raise Exception.Create('Error.Script ArrayDim');
  if Args[1].ValueKind <> vkArray then
    raise Exception.Create('Error.Script ArrayDim - not array');
  Args[0].AsInteger := Args[1].AsArray.Count;
end;

procedure SF_ArraySort(Args: array of TVarEC; Code: TCodeEC);
var
  ArrayCount, ElementCount, I, ElementIndex, ArrayIndex: Integer;
  SwapValue: TVarEC;
begin
  ArrayCount := High(Args);
  if ArrayCount < 1 then
    raise Exception.Create('Error.Script ArraySort');
  if Args[1].ValueKind <> vkArray then
    raise Exception.Create('Error.Script ArraySort - not array');
  ElementCount := Args[1].AsArray.Count;
  if ElementCount < 2 then
    Exit;
  if ArrayCount > 1 then
    for I := 2 to ArrayCount do
    begin
      if Args[I].ValueKind <> vkArray then
        raise Exception.Create('Error.Script ArraySort - type mismatch');
      if Args[I].AsArray.Count <> ElementCount then
        raise Exception.Create('Error.Script ArraySort - size mismatch');
    end;
  for I := 1 to ElementCount - 1 do
    for ElementIndex := ElementCount - 1 downto I do
      if Args[1].AsArray[ElementIndex].AsInteger < Args[1].AsArray[ElementIndex - 1].AsInteger then
        for ArrayIndex := 1 to ArrayCount do
        begin
          SwapValue := Args[ArrayIndex].AsArray[ElementIndex];
          Args[ArrayIndex].AsArray[ElementIndex] := Args[ArrayIndex].AsArray[ElementIndex - 1];
          Args[ArrayIndex].AsArray[ElementIndex - 1] := SwapValue;
        end;
end;

procedure SF_ArraySortPartial(Args: array of TVarEC; Code: TCodeEC);
var
  ArrayCount, ElementCount, I, ElementIndex, ArrayIndex, MinIndex: Integer;
  SwapValue: TVarEC;
begin
  ArrayCount := High(Args) - 1;
  if ArrayCount < 1 then
    raise Exception.Create('Error.Script ArraySortPartial');
  if Args[2].ValueKind <> vkArray then
    raise Exception.Create('Error.Script ArraySortPartial - not array');
  ElementCount := Args[2].AsArray.Count;
  MinIndex := Args[1].AsInteger;
  if ElementCount < 2 then
    Exit;
  if ArrayCount > 1 then
    for I := 2 to ArrayCount do
    begin
      if Args[I + 1].ValueKind <> vkArray then
        raise Exception.Create('Error.Script ArraySortPartial - type mismatch');
      if Args[I + 1].AsArray.Count <> ElementCount then
        raise Exception.Create('Error.Script ArraySortPartial - size mismatch');
    end;
  // Native operation: one backward adjacent-swap pass. MinIndex is unchecked;
  // each comparison also reads ElementIndex - 1.
  for ElementIndex := ElementCount - 1 downto MinIndex do
    if Args[2].AsArray[ElementIndex].AsInteger < Args[2].AsArray[ElementIndex - 1].AsInteger then
      for ArrayIndex := 1 to ArrayCount do
      begin
        SwapValue := Args[ArrayIndex + 1].AsArray[ElementIndex];
        Args[ArrayIndex + 1].AsArray[ElementIndex] := Args[ArrayIndex + 1].AsArray[ElementIndex - 1];
        Args[ArrayIndex + 1].AsArray[ElementIndex - 1] := SwapValue;
      end;
end;

procedure SF_ArrayRandomize(Args: array of TVarEC; Code: TCodeEC);
var
  LastArgIndex, ElementCount, I, SwapIndex1, SwapIndex2, ArrayArgIndex, SwapCount: Integer;
  Seed: Cardinal;
  SwapValue: TVarEC;
  HasSeed: Boolean;
begin
  LastArgIndex := High(Args);
  if LastArgIndex < 2 then
    raise Exception.Create('Error.Script ArrayRandomize');
  if Args[2].ValueKind <> vkArray then
    raise Exception.Create('Error.Script ArrayRandomize - not array');
  ElementCount := Args[2].AsArray.Count;
  if ElementCount < 2 then
    Exit;
  SwapCount := Args[1].AsInteger;
  HasSeed := False;
  if Args[LastArgIndex].ValueKind <> vkArray then
  begin
    Seed := Args[LastArgIndex].AsDword;
    HasSeed := True;
    Dec(LastArgIndex);
  end;
  for I := 3 to LastArgIndex do
  begin
    if Args[I].ValueKind <> vkArray then
      raise Exception.Create('Error.Script ArrayRandomize - type mismatch');
    if Args[I].AsArray.Count <> ElementCount then
      raise Exception.Create('Error.Script ArrayRandomize - size mismatch');
  end;
  for I := 1 to SwapCount do
  begin
    if HasSeed then
    begin
      SwapIndex1 := NextRandomIntRange(0, ElementCount - 1, Seed);
      SwapIndex2 := NextRandomIntRange(0, ElementCount - 1, Seed);
    end
    else if Galaxy = nil then
    begin
      SwapIndex1 := RandomIntRange(0, ElementCount - 1);
      SwapIndex2 := RandomIntRange(0, ElementCount - 1);
    end
    else
    begin
      SwapIndex1 := NextRandomIntRange(0, ElementCount - 1, Galaxy.RandomState);
      SwapIndex2 := NextRandomIntRange(0, ElementCount - 1, Galaxy.RandomState);
    end;
    if SwapIndex1 <> SwapIndex2 then
      for ArrayArgIndex := 2 to LastArgIndex do
      begin
        SwapValue := Args[ArrayArgIndex].AsArray[SwapIndex1];
        Args[ArrayArgIndex].AsArray[SwapIndex1] := Args[ArrayArgIndex].AsArray[SwapIndex2];
        Args[ArrayArgIndex].AsArray[SwapIndex2] := SwapValue;
      end;
  end;
end;

procedure SF_ArrayFind(Args: array of TVarEC; Code: TCodeEC);
var
  ElementIndex: Integer;
begin
  if High(Args) < 2 then
    raise Exception.Create('Error.Script ArrayFind');
  if Args[1].ValueKind <> vkArray then
    raise Exception.Create('Error.Script ArrayFind - not array');
  Args[0].AsInteger := -1;
  // Both integer kinds can carry object addresses in legacy scripts.
  if Args[2].ValueKind in [vkInt, vkDword] then
  begin
    for ElementIndex := 0 to Args[1].AsArray.Count - 1 do
      if Args[1].AsArray[ElementIndex].AsDword = Args[2].AsDword then
      begin
        Args[0].AsInteger := ElementIndex;
        Exit;
      end;
  end
  else if Args[2].ValueKind = vkString then
  begin
    for ElementIndex := 0 to Args[1].AsArray.Count - 1 do
      if Args[1].AsArray[ElementIndex].AsString = Args[2].AsString then
      begin
        Args[0].AsInteger := ElementIndex;
        Exit;
      end;
  end
  else if Args[2].ValueKind = vkFloat then
  begin
    for ElementIndex := 0 to Args[1].AsArray.Count - 1 do
      if Args[1].AsArray[ElementIndex].AsFloat = Args[2].AsFloat then
      begin
        Args[0].AsInteger := ElementIndex;
        Exit;
      end;
  end;
end;
procedure SF_ArrayFindInSorted(Args: array of TVarEC; Code: TCodeEC);
var
  ElementCount, TargetValue, HighValue, LowValue, HighIndex, LowIndex: Integer;
  ProbeValue, ProbeIndex, Pass, InterpolationPassCount, ScanDirection: Integer;
begin
  if High(Args) < 2 then
    raise Exception.Create('Error.Script ArrayFindInSorted');
  if Args[1].ValueKind <> vkArray then
    raise Exception.Create('Error.Script ArrayFindInSorted - not array');
  ProbeIndex := 0;
  ElementCount := Args[1].AsArray.Count;
  TargetValue := Args[2].AsInteger;
  LowIndex := 0;
  { The native search reads both endpoints without an empty-array check. }
  LowValue := Args[1].AsArray[0].AsInteger;
  HighIndex := ElementCount - 1;
  HighValue := Args[1].AsArray[ElementCount - 1].AsInteger;
  InterpolationPassCount := 3;
  if (TargetValue > HighValue) or (TargetValue < LowValue) then
  begin
    Args[0].AsInteger := -1;
    Exit;
  end;
  if TargetValue = HighValue then
  begin
    Args[0].AsInteger := HighIndex;
    Exit;
  end;
  if TargetValue = LowValue then
  begin
    Args[0].AsInteger := LowIndex;
    Exit;
  end;
  if HighValue = LowValue then
  begin
    Args[0].AsInteger := -1;
    Exit;
  end;
  for Pass := 1 to InterpolationPassCount do
  begin
    ProbeIndex := Round((TargetValue - LowValue) * (HighIndex - LowIndex) / (HighValue - LowValue) + LowIndex);
    ProbeValue := Args[1].AsArray[ProbeIndex].AsInteger;
    if ProbeValue > TargetValue then
    begin
      HighIndex := ProbeIndex;
      HighValue := ProbeValue;
    end
    else
    begin
      LowIndex := ProbeIndex;
      LowValue := ProbeValue;
    end;
    if TargetValue = HighValue then
    begin
      Args[0].AsInteger := HighIndex;
      Exit;
    end;
    if TargetValue = LowValue then
    begin
      Args[0].AsInteger := LowIndex;
      Exit;
    end;
    if HighValue = LowValue then
    begin
      Args[0].AsInteger := -1;
      Exit;
    end;
  end;
  if ProbeIndex = HighIndex then
    ScanDirection := -1
  else
    ScanDirection := 1;
  Inc(ProbeIndex, ScanDirection);
  ProbeValue := Args[1].AsArray[ProbeIndex].AsInteger;
  while (ProbeValue <> TargetValue)
      and (ProbeIndex < HighIndex)
      and (ProbeIndex > LowIndex)
      and ((TargetValue - ProbeValue) * ScanDirection > 0) do
  begin
    Inc(ProbeIndex, ScanDirection);
    ProbeValue := Args[1].AsArray[ProbeIndex].AsInteger;
  end;
  if ProbeValue = TargetValue then
    Args[0].AsInteger := ProbeIndex
  else
    Args[0].AsInteger := -1;
end;

procedure SF_DistToNearestEnemySystem(av: array of TVarEC; code: TCodeEC);
var
  I: Integer;
  Star, Other: TStar;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script DistToNearestEnemySystem');
  Star := TStar(av[1].AsDword);
  I := 0;
  while I < Galaxy.Stars.Count do
  begin
    Other := Star.StarDistances[I].Star as TStar;
    if (Other.ControlFaction = sfDominators) or (Other.Status.CustomFaction <> '') then
      Break;
    Inc(I);
  end;
  if I = Galaxy.Stars.Count then
    av[0].AsInteger := -1
  else
    av[0].AsInteger := Star.StarDistances[I].Distance;
end;

procedure SF_StarEnemyThreatLevel(av: array of TVarEC; code: TCodeEC);
var
  Star, Other: TStar;
  Ship: TShip;
  I, J: Integer;
  Standings: TShipStandings;
  IncludePirates: Boolean;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script StarEnemyThreatLeve');
  Star := TStar(av[1].AsDword);
  IncludePirates := (High(av) > 1) and (av[2].AsInteger = 1);
  if Star = nil then
    raise Exception.Create('Error.Script StarEnemyThreatLevel');
  if (Star.ControlFaction = sfDominators)
      or (Star.Status.CustomFaction <> '')
      or (IncludePirates and (Star.ControlFaction = sfPirates)) then
  begin
    av[0].AsInteger := 3;
    Exit;
  end;
  if Star.Battle <> 0 then
  begin
    av[0].AsInteger := 2;
    Exit;
  end;
  if Galaxy.KellerTargetStar = Star then
  begin
    av[0].AsInteger := 1;
    Exit;
  end;
  Standings := [ssDominator, ssCustom];
  if IncludePirates then
    Standings := Standings + [ssPirateActive, ssPirateMilitary];
  for J := 0 to Star.Ships.Count - 1 do
  begin
    Ship := Star.Ships[J];
    if ((Ship.CurrentPlanet = nil) or (Ship.CurrentPlanet.OwnerId <> oiUninhabited)) and (Ship.CurrentStanding in Standings) then
    begin
      av[0].AsInteger := 1;
      Exit;
    end;
  end;
  for I := 1 to Galaxy.Stars.Count - 1 do
  begin
    Other := TStar(Star.StarDistances[I].Star);
    // Native code tests the original star's custom/pirate fields here.
    if (Other.ControlFaction = sfDominators)
        or (Star.Status.CustomFaction <> '')
        or (IncludePirates and (Star.ControlFaction = sfPirates)) then
      for J := 0 to Other.Ships.Count - 1 do
      begin
        Ship := Other.Ships[J];
        if (Ship.OrderTarget = Star) and (Ship.CurrentStanding in Standings) then
        begin
          av[0].AsInteger := 1;
          Exit;
        end;
        if (Ship is TRuins) and (TRuins(Ship).FlyToStar = Star) and (Ship.CurrentStanding in Standings) then
        begin
          av[0].AsInteger := 1;
          Exit;
        end;
      end;
  end;
  av[0].AsInteger := 0;
end;

procedure SF_BuildListOfQuestPossibleLocations(av: array of TVarEC; code: TCodeEC);
var
  I, J, K, MinDistance, MaxDistance, Count: Integer;
  Star, Candidate: TStar;
  Allowed: Boolean;
  Value: TVarEC;
begin
  if High(av) < 4 then
    raise Exception.Create('Error.Script BuildListOfQuestPossibleLocations');
  if av[1].ValueKind = vkEmpty then
  begin
    av[1].ConvertToKind(vkArray);
    av[1].AsArray := TVarArrayEC.Create;
  end
  else if av[1].ValueKind <> vkArray then
    raise Exception.Create('Error.Script BuildListOfQuestPossibleLocations - not array');
  Star := TStar(av[2].AsDword);
  MinDistance := av[3].AsInteger;
  MaxDistance := av[4].AsInteger;
  av[1].AsArray.Clear;
  I := 1;
  while (I < Galaxy.Stars.Count) and (Star.StarDistances[I].Distance <= MaxDistance) do
  begin
    Candidate := Star.StarDistances[I].Star;
    if (Star.StarDistances[I].Distance >= MinDistance)
        and (Candidate.ControlFaction = sfCoalition)
        and (Candidate.Status.CustomFaction = '')
        and (Candidate.Battle = 0)
        and (Galaxy.KellerTargetStar <> Candidate)
        and Candidate.IsConstellationVisible then
    begin
      Allowed := True;
      if High(av) > 4 then
        for J := 5 to High(av) do
          if TStar(av[J].AsDword) = Candidate then
            Allowed := False;
      if Allowed then
      begin
        Value := TVarEC.Create(vkDword);
        Value.AsDword := PtrUInt(Candidate);
        av[1].AsArray.AddItem(Value);
      end;
    end;
    Inc(I);
  end;
  Count := av[1].AsArray.Count;
  for I := Count - 1 downto 0 do
  begin
    Star := TStar(av[1].AsArray[I].AsDword);
    J := 0;
    Allowed := True;
    while Allowed and (J < Star.Ships.Count) do
      if TShip(Star.Ships[J]).TypeId = stKling then
      begin
        Allowed := False;
        av[1].AsArray.Delete(I);
      end
      else
        Inc(J);
  end;
  Count := av[1].AsArray.Count;
  I := 0;
  while (I < Galaxy.Stars.Count) and (Count > 0) do
  begin
    Star := Galaxy.Stars[I];
    if Star.ControlFaction = sfDominators then
      for J := 0 to Star.Ships.Count - 1 do
        if (TShip(Star.Ships[J]).TypeId = stKling) and (TShip(Star.Ships[J]).OrderTarget is TStar) then
        begin
          Candidate := TShip(Star.Ships[J]).OrderTarget as TStar;
          for K := av[1].AsArray.Count - 1 downto 0 do
            if TStar(av[1].AsArray[K].AsDword) = Candidate then
            begin
              av[1].AsArray.Delete(K);
              Count := av[1].AsArray.Count;
            end;
        end;
    Inc(I);
  end;
  Count := av[1].AsArray.Count;
  av[0].AsInteger := Count;
  if Count = 0 then
    av[1].AsArray.AddItem(TVarEC.Create(vkEmpty));
end;

procedure SF_FindItemInShip(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  Item: TItem;
  Obj: TObject;
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script FindItemInShip');
  Ship := TShip(av[1].AsDword);
  Obj := TObject(av[2].AsDword);
  Item := nil;
  if Obj is TItem then
    Item := TItem(Obj);
  if Obj is TScriptItem then
    Item := TScriptItem(Obj).Item;
  av[0].AsInteger := -1;
  if Item <> nil then
  begin
    av[0].AsInteger := Ship.Inventory.IndexOf(Item);
    if av[0].AsInteger < 0 then
      av[0].AsInteger := Ship.Artefacts.IndexOf(Item);
  end;
end;

procedure SF_GalaxyRangers(av: array of TVarEC; code: TCodeEC);
var
  Index: Integer;
begin
  if High(av) = 0 then
    av[0].AsInteger := Galaxy.Rangers.Count
  else
  begin
    Index := av[1].AsInteger;
    if (Index >= 0) and (Index < Galaxy.Rangers.Count) then
      av[0].AsDword := PtrUInt(Galaxy.Rangers[Index])
    else
      av[0].AsDword := 0;
  end;
end;

procedure SF_MakeShipEnterStar(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  Star, Origin: TStar;
  State: Word;
  I: Integer;
  SavedOrderLock: Byte;
begin
  if High(av) < 4 then
    raise Exception.Create('Error.Script MakeShipEnterStar');
  Ship := TShip(av[1].AsDword);
  Star := TStar(av[2].AsDword);
  Origin := TStar(av[3].AsDword);
  State := av[4].AsDword;
  if (GetPlayer = Ship) and (TemporaryShopSlots <> nil) then
    RestoreTemporaryShopStock;
  I := Ship.CurrentStar.Ships.IndexOf(Ship);
  if I >= 0 then
    Ship.CurrentStar.Ships.Delete(I);
  Ship.CurrentStar := Origin;
  SavedOrderLock := Ship.AbsoluteScriptOrder;
  Ship.AbsoluteScriptOrder := 0;
  Ship.OrderJump(Star, True);
  Ship.AbsoluteScriptOrder := SavedOrderLock;
  Star.Ships.Add(Ship);
  Ship.CurrentStar := Star;
  Ship.OrderStateData := State;
  Ship.InHyperspace := True;
  Ship.TransitOriginStar := Origin;
  Ship.MovementDirection := PointBearingDegrees(Origin.Position, Star.Position);
  if (Ship is TNormalShip) and ((Ship as TNormalShip).LastDockedPlanet = nil) then
    (Ship as TNormalShip).LastDockedPlanet := (Ship as TNormalShip).HomePlanet;
  Ship.CurrentPlanet := nil;
  Ship.DockedTo := nil;
end;

procedure SF_ShipGetBad(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script ShipGetBad');
  if av[1].AsDword <> 0 then
    av[0].AsDword := PtrUInt(TShip(av[1].AsDword).EnemyShip);
end;

procedure SF_ShipAddDropItem(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  Item: TItem;
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script ShipAddDropItem');
  Ship := TShip(av[1].AsDword);
  Item := TItem(av[2].AsDword);
  if (Ship <> nil) and (Item <> nil) then
    av[0].AsInteger := Ship.GuaranteedDeathDropItems.Add(Item);
end;

procedure SF_BonusCount(av: array of TVarEC; code: TCodeEC);
begin
  av[0].AsInteger := MicroModuleTemplateCount;
end;

procedure SF_SeriesCount(av: array of TVarEC; code: TCodeEC);
begin
  av[0].AsInteger := HullSeriesCount;
end;

procedure SF_BonusPriority(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script BonusPriority');
  if (av[1].AsInteger < 0) or (av[1].AsInteger >= MicroModuleTemplateCount) then
    raise Exception.Create('Error.Script BonusPriority - number out of range');
  av[0].AsInteger := MicroModuleTemplates[av[1].AsInteger].Priority;
end;

procedure SF_BonusIsSpecial(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script BonusIsSpecial');
  if (av[1].AsInteger < 0) or (av[1].AsInteger >= MicroModuleTemplateCount) then
    raise Exception.Create('Error.Script BonusIsSpecial - number out of range');
  av[0].AsInteger := Ord(MicroModuleTemplates[av[1].AsInteger].SpecialOnly);
end;

procedure SF_BonusName(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script BonusName');
  if (av[1].AsInteger < 0) or (av[1].AsInteger >= MicroModuleTemplateCount) then
    raise Exception.Create('Error.Script BonusName - number out of range');
  av[0].AsString := MicroModuleTemplates[av[1].AsInteger].Name;
end;

procedure SF_BonusNumInCfg(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script BonusNumInCfg');
  if av[1].AsInteger = -1 then
    av[0].AsString := ''
  else
  begin
    if (av[1].AsInteger < 0) or (av[1].AsInteger >= MicroModuleTemplateCount) then
      raise Exception.Create('Error.Script BonusNumInCfg - number out of range');
    av[0].AsString := MicroModuleTemplates[av[1].AsInteger].ConfigName;
  end;
end;

procedure SF_SeriesNumInCfg(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script SeriesNumInCfg');
  if av[1].AsInteger = -1 then
    av[0].AsString := ''
  else
  begin
    if (av[1].AsInteger < 0) or (av[1].AsInteger >= HullSeriesCount) then
      raise Exception.Create('Error.Script SeriesNumInCfg - number out of range');
    av[0].AsString := HullSeriesDefinitions[av[1].AsInteger].SystemName;
  end;
end;

procedure SF_BonusValue(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script BonusValue');
  if (av[1].AsInteger < 0) or (av[1].AsInteger >= MicroModuleTemplateCount) then
    raise Exception.Create('Error.Script BonusValue - number out of range');
  av[0].AsInteger := MicroModuleTemplates[av[1].AsInteger].StatBonuses[TEquipmentBonusKind(av[2].AsInteger)];
end;

procedure SF_FindBonusByName(av: array of TVarEC; code: TCodeEC);
var
  Index: Integer;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script FindBonusByName');
  av[0].AsInteger := -1;
  for Index := 0 to High(MicroModuleTemplates) do
    if MicroModuleTemplates[Index].Name = av[1].AsString then
    begin
      av[0].AsInteger := Index;
      Break;
    end;
end;

procedure SF_FindSeriesByName(av: array of TVarEC; code: TCodeEC);
var
  Index: Integer;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script FindSeriesByName');
  av[0].AsInteger := -1;
  for Index := 0 to High(HullSeriesDefinitions) do
    if HullSeriesDefinitions[Index].Name = av[1].AsString then
    begin
      av[0].AsInteger := Index;
      Break;
    end;
end;

procedure SF_FindBonusByCustomTag(av: array of TVarEC; code: TCodeEC);
var
  Index, Occurrence: Integer;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script FindBonusByCustomTag');
  av[0].AsInteger := -1;
  Occurrence := 0;
  if High(av) > 1 then
    Occurrence := av[2].AsInteger;
  for Index := 0 to MicroModuleTemplateCount - 1 do
  begin
    if MicroModuleTemplates[Index].CustomTag <> av[1].AsString then
      Continue;
    if Occurrence = 0 then
    begin
      av[0].AsInteger := Index;
      Break;
    end;
    Dec(Occurrence);
  end;
end;

procedure SF_FindBonusByNameInCfg(av: array of TVarEC; code: TCodeEC);
var
  Index: Integer;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script FindBonusByNameInCfg');
  av[0].AsInteger := -1;
  for Index := 0 to High(MicroModuleTemplates) do
    if MicroModuleTemplates[Index].ConfigName = av[1].AsString then
    begin
      av[0].AsInteger := Index;
      Break;
    end;
end;

procedure SF_BonusCustomTag(av: array of TVarEC; code: TCodeEC);
var
  Block: TBlockParEC;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script BonusCustomTag');
  Block := LanguageDataConfig.GetBlockByPath('MicroModuls.' + MicroModuleTemplates[av[1].AsInteger].ConfigName);
  if Block.CountParams('CustomTag') <= 0 then
    av[0].AsString := ''
  else
    av[0].AsString := Block.GetParamByPath('CustomTag');
end;

procedure SF_CreateEquipmentWithSpecial(av: array of TVarEC; code: TCodeEC);
var
  Item: TEquipment;
  Kind: TItemType;
  Mask: TItemTypeSelection;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script CreateEquipmentWithSpecial');
  if not MicroModuleTemplates[av[1].AsInteger].SpecialOnly then
    raise Exception.Create('Error.Script CreateEquipmentWithSpecial - not special');
  Mask := MicroModuleTemplates[av[1].AsInteger].AllowedItemTypes;
  Kind := TItemType(PickRandomItemTypeFromSeed(Mask, Galaxy.RandomState));
  if High(av) > 3 then
    Item := CreateGeneratedEquipment(Kind, av[2].AsInteger, av[3].AsInteger, TOwnerId(av[4].AsInteger))
  else
    Item := TEquipment(CreateDefaultItemByType(Kind));
  ApplySpecialMicroModule(av[1].AsInteger, Item);
  av[0].AsDword := PtrUInt(Item);
end;

procedure SF_SpecialToEquipment(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  RawItem: TItem;
  Item: TEquipment;
  Level, PriorityLimit, Chosen, Count, MinimumPriority, BestPriority, Index: Integer;
  Template: PMicroModuleTemplate;
  RandomMode, IsHull, IsWeapon, IsOther: Boolean;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script SpecialToEquipment');
  RandomMode := (High(av) = 1) or ((av[1].ValueKind = vkDword) and (av[1].AsDword > $FFFF));
  if RandomMode then
    Obj := TObject(av[1].AsDword)
  else
    Obj := TObject(av[2].AsDword);
  RawItem := nil;
  if Obj is TItem then
    RawItem := TItem(Obj);
  if Obj is TScriptItem then
    RawItem := TScriptItem(Obj).Item;
  if (RawItem <> nil) and (RawItem is TEquipment) then
    Item := TEquipment(RawItem)
  else
    raise Exception.Create('Error.Script SpecialToEquipment - not eq');
  if RandomMode then
  begin
    IsWeapon := Item is TWeapon;
    IsHull := not IsWeapon and (Item is THull);
    IsOther := not IsHull and not IsWeapon;
    if High(av) > 1 then
      Level := av[2].AsInteger
    else
      Level := Galaxy.TechLevel;
    PriorityLimit := Round(100 * Level / 8);
    BestPriority := 0;
    Count := 0;
    Template := @MicroModuleTemplates[0];
    for Index := 0 to MicroModuleTemplateCount - 1 do
    begin
      if Template.SpecialOnly
          and ((Template.OfferStationTypes <> []) or (Template.OfferStationNames <> '<>') or Template.OnPlanets)
          and (not IsWeapon or IsBonusCompatibleWithWeapon(Index, TWeapon(Item)))
          and (not IsHull or IsBonusCompatibleWithHull(Index, THull(Item)))
          and (not IsOther or IsBonusCompatibleWithEquipment(Index, Item))
          and (Template.Priority <= PriorityLimit) then
      begin
        if Count = 0 then
          BestPriority := Template.Priority
        else
          BestPriority := Max(BestPriority, Template.Priority);
        MicroModuleCandidateIndices[Count] := Index;
        Inc(Count);
      end;
      Inc(Template);
    end;
    if Count <= 0 then
      av[0].AsInteger := -1
    else
    begin
      MinimumPriority := Max(0, BestPriority - 40);
      for Index := 0 to 100 do
      begin
        Chosen := NextRandomIntRange(0, Count - 1, Galaxy.RandomState);
        if MicroModuleTemplates[MicroModuleCandidateIndices[Chosen]].Priority >= MinimumPriority then
          Break;
      end;
      Item.SpecialModuleIndex := 0;
      ApplySpecialMicroModule(MicroModuleCandidateIndices[Chosen], Item);
      av[0].AsInteger := MicroModuleCandidateIndices[Chosen];
    end;
  end
  else if av[1].AsInteger >= 0 then
  begin
    Item.SpecialModuleIndex := 0;
    ApplySpecialMicroModule(av[1].AsInteger, Item);
  end
  else
    RemoveSpecialMicroModule(Item);
end;

procedure SF_ModuleToEquipment(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  RawItem: TItem;
  Item: TEquipment;
  Attempts, BasePriority, Step, Index, Level: Integer;
  RandomMode: Boolean;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script ModuleToEquipment');
  RandomMode := (High(av) = 1) or ((av[1].ValueKind = vkDword) and (av[1].AsDword > $FFFF));
  if RandomMode then
    Obj := TObject(av[1].AsDword)
  else
    Obj := TObject(av[2].AsDword);
  RawItem := nil;
  if Obj is TItem then
    RawItem := TItem(Obj);
  if Obj is TScriptItem then
    RawItem := TScriptItem(Obj).Item;
  if (RawItem <> nil) and (RawItem is TEquipment) then
    Item := TEquipment(RawItem)
  else
    raise Exception.Create('Error.Script ModuleToEquipment - not eq');
  if RandomMode then
  begin
    if High(av) > 1 then
      Obj := TObject(av[2].AsDword)
    else
      Obj := nil;
    if High(av) > 2 then
      Level := av[3].AsInteger
    else
      Level := Galaxy.TechLevel;
    Attempts := 0;
    Step := 0;
    repeat
      BasePriority := Round(RemapClamped(Level, 3, 7, 70, 0));
      Index :=
          Galaxy.SelectMicroModuleForEquipment(
              BasePriority + 5 * Step,
              Min(BasePriority + 40 + 20 * Step, 100),
              AdvanceRandomSeed(Galaxy.RandomState),
              Obj,
              Item
          );
      if CanInstallMicroModule(Index, Item) then
      begin
        Item.MicroModuleIndex := 0;
        ApplyMicroModule(Index, Item);
        av[0].AsInteger := Index;
        Exit;
      end;
      Inc(Attempts);
      if Attempts mod 10 = 0 then
        Inc(Step);
    until Attempts > 50;
    av[0].AsInteger := -1;
  end
  else if av[1].AsInteger >= 0 then
  begin
    Item.MicroModuleIndex := 0;
    ApplyMicroModule(av[1].AsInteger, Item);
  end
  else
    RemoveMicroModule(Item);
end;

procedure SF_EqSpecial(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Item: TEquipment;
  Missile: TMissile;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script EqSpecial');
  av[0].AsInteger := 0;
  Obj := TObject(av[1].AsDword);
  if Obj is TMissile then
  begin
    Missile := TMissile(Obj);
    av[0].AsInteger := Missile.SpecialModuleIndex - 1;
    if High(av) > 1 then
      Missile.SpecialModuleIndex := av[2].AsInteger + 1;
  end;
  if Obj is TEquipment then
    Item := TEquipment(Obj)
  else if (Obj is TScriptItem) and ((Obj as TScriptItem).Item is TEquipment) then
    Item := (Obj as TScriptItem).Item as TEquipment
  else
    Exit;
  av[0].AsInteger := Item.SpecialModuleIndex - 1;
  if High(av) > 1 then
    Item.SpecialModuleIndex := av[2].AsInteger + 1;
end;

procedure SF_EqModule(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Item: TEquipment;
  Missile: TMissile;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script EqModule');
  av[0].AsInteger := 0;
  Obj := TObject(av[1].AsDword);
  if Obj is TMissile then
  begin
    Missile := TMissile(Obj);
    av[0].AsInteger := Missile.MicroModuleIndex - 1;
    if High(av) > 1 then
      Missile.MicroModuleIndex := av[2].AsInteger + 1;
  end;
  if Obj is TEquipment then
    Item := TEquipment(Obj)
  else if (Obj is TScriptItem) and ((Obj as TScriptItem).Item is TEquipment) then
    Item := (Obj as TScriptItem).Item as TEquipment
  else
    Exit;
  av[0].AsInteger := Item.MicroModuleIndex - 1;
  if High(av) > 1 then
    Item.MicroModuleIndex := av[2].AsInteger + 1;
end;

procedure SF_MayAddBonusToEq(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Item: TEquipment;
  Index: Integer;
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script MayAddModuleToEq');
  av[0].AsInteger := 0;
  Index := av[1].AsInteger;
  Obj := TObject(av[2].AsDword);
  if Obj is TEquipment then
    Item := TEquipment(Obj)
  else if (Obj is TScriptItem) and ((Obj as TScriptItem).Item is TEquipment) then
    Item := (Obj as TScriptItem).Item as TEquipment
  else
    Exit;
  if (Item.SpecialModuleIndex <> 0) and MicroModuleTemplates[Item.SpecialModuleIndex - 1].BlocksMicroModuleSlot then
    Exit;
  if Item is TWeapon then
    av[0].AsInteger := Ord(IsBonusCompatibleWithWeapon(Index, TWeapon(Item)))
  else if Item is THull then
    av[0].AsInteger := Ord(IsBonusCompatibleWithHull(Index, THull(Item)))
  else
    av[0].AsInteger := Ord(IsBonusCompatibleWithEquipment(Index, Item));
end;

procedure SF_BuildListOfMMByPriority(av: array of TVarEC; code: TCodeEC);
var
  I, LowPriority, HighPriority, Count: Integer;
  Value: TVarEC;
  ExcludeRacial: Boolean;
begin
  if High(av) < 3 then
    raise Exception.Create('Error.Script BuildListOfMMByPriority');
  if av[1].ValueKind = vkEmpty then
  begin
    av[1].ConvertToKind(vkArray);
    av[1].AsArray := TVarArrayEC.Create;
  end
  else if av[1].ValueKind <> vkArray then
    raise Exception.Create('Error.Script BuildListOfMMByPriority - not array');
  if High(av) > 3 then
    ExcludeRacial := av[4].AsInteger <> 0
  else
    ExcludeRacial := True;
  if av[2].AsInteger < av[3].AsInteger then
  begin
    HighPriority := av[3].AsInteger;
    LowPriority := av[2].AsInteger;
  end
  else
  begin
    HighPriority := av[2].AsInteger;
    LowPriority := av[3].AsInteger;
  end;
  av[1].AsArray.Clear;
  for I := 0 to MicroModuleTemplateCount - 1 do
  begin
    if MicroModuleTemplates[I].SpecialOnly then
      Continue;
    if (MicroModuleTemplates[I].Priority > HighPriority)
        or (MicroModuleTemplates[I].Priority < LowPriority)
        or ((Byte(ExcludeRacial) and Byte(MicroModuleTemplates[I].RacialRestriction)) <> 0) then
      Continue;
    Value := TVarEC.Create(vkInt);
    Value.AsInteger := I;
    av[1].AsArray.AddItem(Value);
  end;
  Count := av[1].AsArray.Count;
  av[0].AsInteger := Count;
  if Count = 0 then
    av[1].AsArray.AddItem(TVarEC.Create(vkEmpty));
end;

procedure SF_BuildListOfNewShips(av: array of TVarEC; code: TCodeEC);
var
  MinimumId: Cardinal;
  Mask: TShipTypeMask;
  IncludeScripted: Boolean;
  FactionCount: Integer;
  Factions: array of WideString;
  TypeCount: Integer;
  CustomTypes: array of WideString;
  Text: WideString;
  Value: TVarEC;
  I, J, K, L, Count: Integer;
  Star: TStar;
  Planet: TPlanet;
  Ship: TShip;

  procedure CheckShip(
      Ship: TShip
  ); { Requires SF_BuildListOfNewShips' live frame. The custom-type filter is applied only when the faction filter is enabled. }
  var
    Found: Boolean;
    I: Integer;
  begin
    if Cardinal(Ship.Id) < MinimumId then
      Exit;
    if not (Ship.TypeId in Mask) then
      Exit;
    if ((Ship.ScriptShip <> nil) or (Ship.AbsoluteScriptOrder <> 0)) and not IncludeScripted then
      Exit;
    if FactionCount >= 0 then
    begin
      if Ship.ScriptShip <> nil then
        Text := TScriptShip(Ship.ScriptShip).StateText
      else
        Text := '';
      if (FactionCount = 0) and (Text <> '') then
        Exit;
      Found := FactionCount = 0;
      for I := 0 to FactionCount - 1 do
        if Text = Factions[I] then
        begin
          Found := True;
          Break;
        end;
      if not Found then
        Exit;
      // The native custom-type filter is nested inside the enabled faction filter.
      if TypeCount >= 0 then
      begin
        Text := Ship.TypeNameOverrideKey;
        if (TypeCount = 0) and (Text <> '') then
          Exit;
        Found := TypeCount = 0;
        for I := 0 to TypeCount - 1 do
          if Text = CustomTypes[I] then
          begin
            Found := True;
            Break;
          end;
        if not Found then
          Exit;
      end;
    end;
    Value := TVarEC.Create(vkInt);
    Value.AsDword := PtrUInt(Ship);
    av[1].AsArray.AddItem(Value);
  end;

  procedure CheckItem(Item: TItem); { Requires SF_BuildListOfNewShips' live frame. Ignores nil and non-Tranclucator artefacts. }
  begin
    if Item <> nil then
      if Item is TArtefactTranclucator then
        CheckShip(TArtefactTranclucator(Item).Ship as TShip);
  end;

begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script BuildListOfNewShips');
  if av[1].ValueKind = vkEmpty then
  begin
    av[1].ConvertToKind(vkArray);
    av[1].AsArray := TVarArrayEC.Create;
  end
  else if av[1].ValueKind <> vkArray then
    raise Exception.Create('Error.Script BuildListOfNewShips - not array');
  av[1].AsArray.Clear;
  MinimumId := av[2].AsDword;
  if (High(av) > 2) and (av[3].AsDword <> 0) then
    Word(Mask) := av[3].AsDword
  else
    Mask := [stKling..stWarrior, rstRangerCenter..rstCustomStation];
  // Parsed by the native routine but never consulted.
  if (High(av) > 3) and (av[4].AsDword <> 0) then
    av[4].AsDword;
  IncludeScripted := False;
  if (High(av) > 4) and (av[5].AsInteger <> 0) then
    IncludeScripted := True;
  if High(av) > 5 then
  begin
    Text := av[6].AsString;
    if Text = '' then
    begin
      FactionCount := 0;
      Factions := nil;
    end
    else
    begin
      FactionCount := CountDelimitedPartsW(Text, ',');
      SetLength(Factions, FactionCount);
      for I := 0 to FactionCount - 1 do
        Factions[I] := ExtractDelimitedPartW(Text, I, ',');
    end;
    if High(av) > 6 then
    begin
      Text := av[7].AsString;
      if Text = '' then
      begin
        TypeCount := 0;
        CustomTypes := nil;
      end
      else
      begin
        TypeCount := CountDelimitedPartsW(Text, ',');
        SetLength(CustomTypes, TypeCount);
        for I := 0 to TypeCount - 1 do
          CustomTypes[I] := ExtractDelimitedPartW(Text, I, ',');
      end;
    end
    else
    begin
      CustomTypes := nil;
      TypeCount := -1;
    end;
  end
  else
  begin
    Factions := nil;
    FactionCount := -1;
    CustomTypes := nil;
    TypeCount := -1;
  end;
  for I := 0 to Galaxy.Stars.Count - 1 do
  begin
    Star := Galaxy.Stars[I];
    for J := 0 to Star.Ships.Count - 1 do
    begin
      Ship := Star.Ships[J];
      if Ship.TypeId <> stWarrior then
        CheckShip(Ship);
    end;
    if stWarrior in Mask then
      for J := 0 to Star.Planets.Count - 1 do
      begin
        Planet := Star.Planets[J];
        for K := 0 to Planet.Warriors.Count - 1 do
        begin
          Ship := Planet.Warriors[K];
          CheckShip(Ship);
        end;
      end;
  end;
  if stTranclucator in Mask then
  begin
    for I := 0 to Galaxy.Stars.Count - 1 do
    begin
      Star := Galaxy.Stars[I];
      for J := 0 to Star.Ships.Count - 1 do
      begin
        Ship := Star.Ships[J];
        if Ship.TypeId <> stWarrior then
          for K := 0 to Ship.Artefacts.Count - 1 do
            CheckItem(TItem(Ship.Artefacts[K]));
      end;
      for J := 0 to Star.Planets.Count - 1 do
      begin
        Planet := Star.Planets[J];
        for K := 0 to Planet.Warriors.Count - 1 do
        begin
          Ship := Planet.Warriors[K];
          for L := 0 to Ship.Artefacts.Count - 1 do
            CheckItem(TItem(Ship.Artefacts[L]));
        end;
      end;
      for J := 0 to Star.Items.Count - 1 do
        CheckItem(TItem(Star.Items[J]));
      for J := 0 to Star.MovingDropItems.Count - 1 do
        CheckItem(PMovingDropItemEntry(Star.MovingDropItems[J]).Payload as TItem);
    end;
    for I := 0 to GetPlayer.StorageEntries.Count - 1 do
      CheckItem(PStorageEntry(GetPlayer.StorageEntries[I]).Item);
  end;
  Count := av[1].AsArray.Count;
  av[0].AsInteger := Count;
  if Count = 0 then
    av[1].AsArray.AddItem(TVarEC.Create(vkEmpty));
end;

procedure SF_PlanetToStar(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script PlanetToStar');
  av[0].AsDword := PtrUInt(TPlanet(av[1].AsDword).CurrentStar);
end;

procedure SF_Chameleon(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script Chameleon');
  Ship := TShip(av[1].AsDword);
  if Ship = nil then
    Ship := GetPlayer;
  if (High(av) > 1) and (av[2].AsString <> '') then
  begin
    if av[2].AsString = 'GraphName' then
    begin
      av[0].AsString := Ship.GraphName;
      Exit;
    end;
    ReleaseSpaceObject(Ship.Graphic);
    RetainSpaceObject(Ship.Graphic, CreateSpaceObjectByName(ExtractDelimitedPartW(av[2].AsString, 0, '.'), av[2].AsString, Point(0, 0)));
    Ship.GraphName := av[2].AsString;
    Ship.Graphic.SetPosition(Ship.Position);
    Ship.Graphic.SetAngle(HeadingDegreesToByte(Ship.MovementDirection));
    Ship.Graphic.SetAlpha(0);
    Ship.ScriptChameleon := True;
    Ship.ChameleonActive := False;
    Ship.RefreshDerivedStats(True);
    Ship.RefreshGraphicSize;
  end
  else
  begin
    Ship.ScriptChameleon := False;
    ReleaseSpaceObject(Ship.Graphic);
    Ship.RefreshGraphic;
  end;
  if (High(av) > 2) and (av[3].AsInteger <> 0) and (CurrentScreenId = screenStarMap) then
  begin
    RequestedScreenId := screenStarMap;
    TMessageLoopGI(RegisteredScreens[CurrentScreenId]).RequestClose(1);
  end;
end;

procedure SF_IsChameleon(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script IsChameleon');
  Ship := TShip(av[1].AsDword);
  if Ship = nil then
    Ship := GetPlayer;
  if Ship.ScriptChameleon then
    av[0].AsInteger := 1
  else
    av[0].AsInteger := 0;
end;

procedure SF_PlayerChameleonCharges(av: array of TVarEC; code: TCodeEC);
var
  Index: TDominatorSeries;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script PlayerChameleonCharges');
  Index := TDominatorSeries(av[1].AsInteger);
  av[0].AsInteger := GetPlayer.ChameleonCharges[Index];
  if High(av) > 1 then
    GetPlayer.ChameleonCharges[Index] := av[2].AsInteger;
end;

procedure SF_PlayerChameleonCurType(av: array of TVarEC; code: TCodeEC);
begin
  if not GetPlayer.ChameleonActive then
    av[0].AsInteger := -1
  else
    av[0].AsInteger := Ord(GetPlayer.ChameleonSeries);
  if High(av) > 0 then
    if av[1].AsInteger < 0 then
      GetPlayer.ChameleonActive := False
    else
    begin
      GetPlayer.ChameleonActive := True;
      GetPlayer.ChameleonSeries := TDominatorSeries(av[1].AsInteger);
    end;
end;

procedure SF_PlayerChameleonDetected(av: array of TVarEC; code: TCodeEC);
var
  Index: TDominatorSeries;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script PlayerChameleonDetected');
  Index := TDominatorSeries(av[1].AsInteger);
  av[0].AsInteger := Ord(GetPlayer.ChameleonDetected[Index]);
  if High(av) > 1 then
    GetPlayer.ChameleonDetected[Index] := av[2].AsInteger <> 0;
end;

procedure SF_PlayerLogicChameleon(av: array of TVarEC; code: TCodeEC);
var
  Index: TDominatorSeries;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script PlayerLogicChameleon');
  Index := TDominatorSeries(av[1].AsInteger);
  av[0].AsInteger := GetPlayer.ChameleonLogic[Index];
  if High(av) > 1 then
    GetPlayer.ChameleonLogic[Index] := av[2].AsInteger;
end;

procedure SF_SwitchToMirrorImage(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  Hull: THull;
  Mirror: TShip2SE;
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script SwitchToMirrorImage');
  Ship := TShip(av[1].AsDword);
  if Ship = nil then
    Ship := GetPlayer;
  if Ship.ScriptChameleon and (av[2].ValueKind = vkString) then
  begin
    Mirror := CreateSpaceObjectByName('Ship2', av[2].AsString, Point(0, 0)) as TShip2SE;
    Mirror.CopyDataFromMirrorImage(Ship.Graphic);
    Mirror.Free;
    Ship.GraphName := Ship.Graphic.GraphKey;
    Exit;
  end;
  Hull := Ship.GetHull;
  if Hull.HullType <> htSpecial then
    raise Exception.Create('Error.Script SwitchToMirrorImage: Not a special hull');
  Hull.SpecialModuleIndex := av[2].AsInteger + 1;
  if Ship.ScriptChameleon or Ship.ChameleonActive or Ship.GraphDominator then
    Exit;
  Mirror := CreateSpaceObjectByName('Ship2', 'Ship.Akrin.' + Hull.GetSpecialKindGraph, Point(0, 0)) as TShip2SE;
  Mirror.CopyDataFromMirrorImage(Ship.Graphic);
  Mirror.Free;
  Ship.GraphName := Ship.Graphic.GraphKey;
end;

procedure SF_EquipmentImageName(av: array of TVarEC; code: TCodeEC);
var
  TypeOrItem: PtrUInt;
  Obj: TObject;
  Item: TItem;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script EquipmentImageName');
  if (av[1].ValueKind = vkString) and (av[1].AsString = 'GetImagePath') then
  begin
    if High(av) < 2 then
      raise Exception.Create('Error.Script EquipmentImageName 2');
    Item := TItem(av[2].AsDword);
    av[0].AsString := Item.GetBitmapResourceName;
    Exit;
  end;
  TypeOrItem := av[1].AsDword;
  if TypeOrItem < 256 then
  begin
    av[0].AsString := ItemTypeNames[TItemType(TypeOrItem)];
    Exit;
  end;
  Obj := TObject(TypeOrItem);
  av[0].AsString := '';
  Item := nil;
  if Obj is TItem then
    Item := TItem(Obj);
  if Obj is TScriptItem then
    Item := TScriptItem(Obj).Item;
  if (Item <> nil) and (Item is TEquipment) then
  begin
    av[0].AsString := (Item as TEquipment).ConfigBlockName;
    if High(av) > 1 then
    begin
      TEquipment(Item).ConfigBlockName := av[2].AsString;
      if Item is TEquipmentWithActCode then
      begin
        TEquipmentWithActCode(Item).ActionCode := nil;
        TEquipmentWithActCode(Item).ActCodeInitialized := False;
        if Item is TUselessItem then
          TUselessItem(Item).CheckIfWeDisplayAsArtefact;
        if Item is TArtefactCustom then
          TArtefactCustom(Item).LoadConfig(False);
      end;
    end;
  end
  else if Obj is TTranclucator then
  begin
    av[0].AsString := (Obj as TTranclucator).ArtefactSystemName;
    if High(av) > 1 then
      (Obj as TTranclucator).ArtefactSystemName := av[2].AsString;
  end;
end;

procedure SF_StarFonImage(av: array of TVarEC; code: TCodeEC);
var
  Star: TStar;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script StarFonImage');
  Star := TStar(av[1].AsDword);
  av[0].AsInteger := Star.BackgroundImage;
  if High(av) > 1 then
    Star.BackgroundImage := av[2].AsInteger;
end;

procedure SF_ExtremalTakeOff(av: array of TVarEC; code: TCodeEC);
begin
  ScriptTakeoffRequested := True;
end;

procedure SF_ForceNextDay(av: array of TVarEC; code: TCodeEC);
begin
  ScriptEndTurnRequested := True;
end;

procedure SF_ScriptActionsRun(av: array of TVarEC; code: TCodeEC);
begin
  ScriptRequestThread.Execute;
end;

procedure SF_StarListToPlanetList(av: array of TVarEC; code: TCodeEC);
var
  I, J, Priority, Count, EnemyDistance: Integer;
  Score, Penalty: Double;
  Star: TStar;
  Planet, BestPlanet: TPlanet;
  Temp: TVarEC;
  ScorePtr: PDouble;
  Scores: TList;
  Weights: array[oiMaloc..oiGaal] of Integer;
begin
  if High(av) < 6 then
    raise Exception.Create('Error.Script StarListToPlanetList');
  if av[1].ValueKind <> vkArray then
    raise Exception.Create('Error.Script StarListToPlanetList - not array');
  if (High(av) > 6) and (av[7].ValueKind <> vkArray) then
    raise Exception.Create('Error.Script StarListToPlanetList - not array');
  Penalty := 0;
  if High(av) > 7 then
    Penalty := av[8].AsInteger / 100;
  Weights[oiMaloc] := av[2].AsInteger;
  Weights[oiPeleng] := av[3].AsInteger;
  Weights[oiHuman] := av[4].AsInteger;
  Weights[oiFeyan] := av[5].AsInteger;
  Weights[oiGaal] := av[6].AsInteger;
  Count := av[1].AsArray.Count;
  for I := Count - 1 downto 0 do
  begin
    Star := TStar(av[1].AsArray[I].AsDword);
    Priority := 0;
    BestPlanet := nil;
    for J := 0 to Star.Planets.Count - 1 do
    begin
      Planet := Star.Planets[J];
      if (Planet.OwnerId in [oiMaloc..oiGaal]) and (Weights[Planet.OwnerId] > Priority) then
      begin
        BestPlanet := Planet;
        Priority := Weights[Planet.OwnerId];
      end;
    end;
    if Priority > 0 then
      av[1].AsArray[I].AsDword := PtrUInt(BestPlanet)
    else
      av[1].AsArray.Delete(I);
  end;
  Count := av[1].AsArray.Count;
  if Count > 0 then
  begin
    Scores := TList.Create;
    for I := 0 to Count - 1 do
    begin
      Planet := TPlanet(av[1].AsArray[I].AsDword);
      Star := Planet.CurrentStar;
      J := 0;
      while (J < Galaxy.Stars.Count)
          and ((Star.StarDistances[J].Star as TStar).ControlFaction <> sfDominators)
          and ((Star.StarDistances[J].Star as TStar).Status.CustomFaction = '') do
        Inc(J);
      if J = Galaxy.Stars.Count then
        EnemyDistance := 1
      else
        EnemyDistance := Star.StarDistances[J].Distance;
      Score := EnemyDistance * Weights[Planet.OwnerId];
      if High(av) > 6 then
        for J := 0 to av[7].AsArray.Count - 1 do
          if (TStar(av[7].AsArray[J].AsDword) = Star) or (av[7].AsArray[J].AsDword = Star.Id) then
            Score := Score * Penalty;
      New(ScorePtr);
      ScorePtr^ := Score;
      Scores.Add(ScorePtr);
    end;
    for I := 1 to Count - 1 do
      for J := Count - 1 downto I do
        if PDouble(Scores[J])^ > PDouble(Scores[J - 1])^ then
        begin
          Temp := av[1].AsArray[J];
          av[1].AsArray[J] := av[1].AsArray[J - 1];
          av[1].AsArray[J - 1] := Temp;
          Score := PDouble(Scores[J])^;
          PDouble(Scores[J])^ := PDouble(Scores[J - 1])^;
          PDouble(Scores[J - 1])^ := Score;
        end;
    for I := 0 to Scores.Count - 1 do
      Dispose(PDouble(Scores[I]));
    Scores.Free;
  end;
  av[0].AsInteger := Count;
  if Count = 0 then
    av[1].AsArray.AddItem(TVarEC.Create(vkEmpty));
end;

procedure SF_EndGame(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) > 0 then
  begin
    GameEndReason := av[1].AsInteger;
    RequestedScreenId := screenGameEnd;
    TMessageLoopGI(RegisteredScreens[CurrentScreenId]).RequestClose(1);
  end
  else
  begin
    ScoreScreen.RecordPlayerResult(GetPlayer <> nil);
    AboutScreen.ReturnToScores := True;
    RequestedScreenId := screenAbout;
    TMessageLoopGI(RegisteredScreens[CurrentScreenId]).RequestClose(1);
  end;
end;

procedure SF_CustomWin(av: array of TVarEC; code: TCodeEC);
var
  Event: TGalaxyEvent;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script CustomWin');
  Event := AddGalaxyEvent('CustomWin');
  Event.AddTextData(av[1].AsString);
  if High(av) > 1 then
    Event.AddTextData(av[2].AsString)
  else
    Event.AddTextData('');
  GameEndReason := gerDefault;
  RequestedScreenId := screenGameEnd;
  TMessageLoopGI(RegisteredScreens[CurrentScreenId]).RequestClose(1);
end;

procedure SF_CustomLose(av: array of TVarEC; code: TCodeEC);
var
  Event: TGalaxyEvent;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script CustomLose');
  Event := AddGalaxyEvent('CustomLose');
  Event.AddTextData(av[1].AsString);
  if High(av) > 1 then
    Event.AddTextData(av[2].AsString)
  else
    Event.AddTextData('');
  GameEndReason := gerDefault;
  RequestedScreenId := screenGameEnd;
  TMessageLoopGI(RegisteredScreens[CurrentScreenId]).RequestClose(1);
end;

procedure SF_PirateWin(av: array of TVarEC; code: TCodeEC);
begin
  av[0].AsInteger := Galaxy.PirateWinType;
  if (High(av) > 0) and (av[1].AsInteger >= 1) and (av[1].AsInteger <= 5) then
  begin
    Galaxy.PirateWinTurn := Galaxy.CurrentTurn;
    Galaxy.PirateWinType := av[1].AsInteger;
  end;
end;

procedure SF_StartVideo(av: array of TVarEC; code: TCodeEC);
var
  Request: PScriptVDRequest;
  SavedCategory: WideString;
  Video: TxvidGI;
begin
  if High(av) = 0 then
  begin
    av[0].AsInteger := QueuedVideos.Count;
    Exit;
  end;

  if High(av) < 2 then
    raise Exception.Create('Error.Script StartVideo');
  if GetInnermostScreenLoop = ShipScreen then
  begin
    ShipScreen.ShipLoopSound.SetVolume(0);
    Video := ShipScreen.GetByName('Film') as TxvidGI;
    Video.SetActive(True);
    if not Video.ImageOpen(av[1].AsString, False) then
    begin
      ShipScreen.StopScriptVideo;
      Exit;
    end;

    if MusicEnabled then
    begin
      MusicManager.StopImmediately;
      while MusicManager.IsPlaying do
        SysUtils.Sleep(1);
    end;
    if MusicEnabled then
    begin
      SavedCategory := MusicManager.CategoryOverride;
      MusicManager.CategoryOverride := '';
      MusicManager.PlayCategory(av[2].AsString);
      while not MusicManager.IsPlaying do
        SysUtils.Sleep(1);
      MusicManager.CategoryOverride := SavedCategory;
    end;
    ShipScreen.ScriptVideoStartedAt := GameTickCount;
    if ShipScreen.ScriptVideoTimer <> nil then
    begin
      ShipScreen.CancelCallbackTimer(ShipScreen.ScriptVideoTimer);
      ShipScreen.ScriptVideoTimer := nil;
    end;
    ShipScreen.ScriptVideoTimer := ShipScreen.ScheduleCallbackTimer(5, 5, ShipScreen.AdvanceScriptVideo);
  end
  else
  begin
    New(Request);
    Request.Video := av[1].AsString;
    Request.Soundtrack := av[2].AsString;
    Request.Script := CurrentScript;
    QueuedVideos.Add(Request);
    if CurrentScript <> nil then
      CurrentScript.InitCode.LocalVar.NamedItems['GVideoStatus'].AsInteger := 1;
    RequestedScreenId := CurrentScreenId;
    TMessageLoopGI(RegisteredScreens[CurrentScreenId]).RequestClose(1);
  end;
end;

procedure SF_StartMusic(av: array of TVarEC; code: TCodeEC);
var
  SavedCategory: WideString;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script StartMusic');
  if not MusicEnabled then
    Exit;
  if GetInnermostScreenLoop = StarMapScreen then
    StarMapScreen.BattleMusicSelected := True;
  MusicManager.StopImmediately;
  while MusicManager.IsPlaying do
    SysUtils.Sleep(1);
  if CountDelimitedPartsW(av[1].AsString, '.') > 1 then
    MusicManager.PlayFile(av[1].AsString)
  else
  begin
    SavedCategory := MusicManager.CategoryOverride;
    MusicManager.CategoryOverride := '';
    MusicManager.PlayCategory(av[1].AsString);
    MusicManager.CategoryOverride := SavedCategory;
  end;
end;

procedure SF_MusicControls(av: array of TVarEC; code: TCodeEC);
var
  Command: WideString;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script MusicControls');
  Command := av[1].AsString;
  if Command = 'SetPlayListOverride' then
  begin
    if High(av) < 2 then
      raise Exception.Create('Error.Script MusicControls 2');
    MusicManager.CategoryOverride := av[2].AsString;
    if MusicEnabled and (MusicManager.CategoryOverride <> '') then
      MusicManager.PlayCategory('');
  end
  else if Command = 'GetPlayListOverride' then
    av[0].AsString := MusicManager.CategoryOverride
  else if Command = 'GetCurFile' then
    av[0].AsString := MusicManager.Current.GetFileName
  else if Command = 'StopCurFile' then
    MusicManager.RequestFadeOut;
end;

procedure SF_NoComeKlingToStar(av: array of TVarEC; code: TCodeEC);
var
  Star: TStar;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script NoComeKlingToStar');
  Star := TStar(av[1].AsDword);
  if Star = nil then
    Exit;
  if Star.NoComeKling then
    av[0].AsInteger := 1
  else
    av[0].AsInteger := 0;
  if High(av) > 1 then
    Star.NoComeKling := av[2].AsInteger <> 0;
end;

procedure SF_NoDropToShip(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script NoDropToShip');
  Ship := TShip(av[1].AsDword);
  if Ship = nil then
    Exit;
  if Ship.NoDrop then
    av[0].AsInteger := 1
  else
    av[0].AsInteger := 0;
  if High(av) > 1 then
    Ship.NoDrop := av[2].AsInteger <> 0;
end;

procedure SF_NoTargetToShip(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script NoTargetToShip');
  Ship := TShip(av[1].AsDword);
  if Ship = nil then
    Exit;
  av[0].AsInteger := Ship.TargetingRestriction;
  if High(av) > 1 then
    Ship.TargetingRestriction := av[2].AsInteger;
end;

procedure SF_NoTalkToShip(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then
  begin
    av[0].AsInteger := Ord(GetPlayer.TalkLocked);
    Exit;
  end;
  if (High(av) = 1) and ((av[1].ValueKind <> vkDword) or (av[1].AsDword < $FF)) then
  begin
    av[0].AsInteger := Ord(GetPlayer.TalkLocked);
    GetPlayer.TalkLocked := av[1].AsInteger <> 0;
    Exit;
  end;
  Ship := TShip(av[1].AsDword);
  if Ship = nil then
    Exit;
  if Ship.NoTalk then
    av[0].AsInteger := 1
  else
    av[0].AsInteger := 0;
  if High(av) > 1 then
    Ship.NoTalk := av[2].AsInteger <> 0;
end;

procedure SF_NoScanToShip(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then
  begin
    av[0].AsInteger := Ord(GetPlayer.ScanLocked);
    Exit;
  end;
  if (High(av) = 1) and ((av[1].ValueKind <> vkDword) or (av[1].AsDword < $FF)) then
  begin
    av[0].AsInteger := Ord(GetPlayer.ScanLocked);
    GetPlayer.ScanLocked := av[1].AsInteger <> 0;
    Exit;
  end;
  Ship := TShip(av[1].AsDword);
  if Ship = nil then
    Exit;
  if Ship.NoScan then
    av[0].AsInteger := 1
  else
    av[0].AsInteger := 0;
  if High(av) > 1 then
    Ship.NoScan := av[2].AsInteger <> 0;
end;

procedure SF_NoJump(av: array of TVarEC; code: TCodeEC);
begin
  if GetPlayer.NoJump then
    av[0].AsInteger := 1
  else
    av[0].AsInteger := 0;
  if High(av) > 0 then
    GetPlayer.NoJump := av[1].AsInteger <> 0;
end;

procedure SF_NoLanding(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script NoLanding');
  av[0].AsInteger := 0;
  Obj := TObject(av[1].AsDword);
  if Obj is TPlanet then
  begin
    if (Obj as TPlanet).NoLanding then
      av[0].AsInteger := 1;
    if High(av) > 1 then
      (Obj as TPlanet).NoLanding := av[2].AsInteger <> 0;
  end
  else if Obj is TRuins then
  begin
    if (Obj as TRuins).NoLanding then
      av[0].AsInteger := 1;
    if High(av) > 1 then
      (Obj as TRuins).NoLanding := av[2].AsInteger <> 0;
  end;
end;

procedure SF_NoShopUpdate(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script NoShopUpdate');
  av[0].AsInteger := 0;
  Obj := TObject(av[1].AsDword);
  if Obj is TPlanet then
  begin
    av[0].AsInteger := (Obj as TPlanet).ShopUpdateMode;
    if High(av) > 1 then
      (Obj as TPlanet).ShopUpdateMode := av[2].AsInteger;
  end
  else if Obj is TRuins then
  begin
    av[0].AsInteger := Ord((Obj as TRuins).ShopUpdateMode);
    if High(av) > 1 then
      (Obj as TRuins).ShopUpdateMode := TShopUpdateMode(av[2].AsInteger);
  end;
end;

procedure SF_PlanetExtraFlags(av: array of TVarEC; code: TCodeEC);
var
  Planet: TPlanet;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script PlanetExtraFlags');
  av[0].AsInteger := 0;
  Planet := TPlanet(av[1].AsDword);
  av[0].AsInteger := Ord(Planet.NoAutomaticShipSpawning) + 2 * Ord(Planet.NoRandomEvents);
  if High(av) > 1 then
  begin
    Planet.NoAutomaticShipSpawning := av[2].AsInteger and 1 > 0;
    Planet.NoRandomEvents := av[2].AsInteger and 2 > 0;
  end;
end;

procedure SF_NoDropItem(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Item: TItem;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script NoDropItem');
  av[0].AsInteger := 0;
  Item := nil;
  Obj := TObject(av[1].AsDword);
  if Obj is TItem then
    Item := TItem(Obj);
  if Obj is TScriptItem then
    Item := TScriptItem(Obj).Item;
  if Item <> nil then
  begin
    av[0].AsInteger := Item.NoDropFlag;
    if High(av) > 1 then
      Item.NoDropFlag := av[2].AsInteger;
  end;
end;

procedure SF_CanSellItem(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Binding: TScriptItem;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script CanSellItem');
  av[0].AsInteger := 1;
  Binding := nil;
  Obj := TObject(av[1].AsDword);
  if Obj is TItem then
    Binding := TScriptItem(TItem(Obj).ScriptItem);
  if Obj is TScriptItem then
    Binding := TScriptItem(Obj);
  if Binding <> nil then
  begin
    if not Binding.CanSell then
      av[0].AsInteger := 0;
    if High(av) > 1 then
      Binding.CanSell := av[2].AsInteger <> 0;
  end;
end;

procedure SF_TruceBetweenShips(av: array of TVarEC; code: TCodeEC);
var
  Ship1, Ship2, Partner1, Partner2: TShip;
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script TruceBetweenShips');
  Ship1 := TShip(av[1].AsDword);
  Ship2 := TShip(av[2].AsDword);
  if (Ship1 <> nil) and (Ship2 <> nil) then
  begin
    Partner1 := Ship1.PartnerShip;
    Partner2 := Ship2.PartnerShip;
    if (Partner1 <> nil) and (Partner2 <> nil) and ((Partner1.EnemyShip = Partner2) or (Partner2.EnemyShip = Partner1)) then
      Partner1.TruceWithShip(Partner2);
    if (Partner1 <> nil) and ((Partner1.EnemyShip = Ship2) or (Ship2.EnemyShip = Partner1)) then
      Partner1.TruceWithShip(Ship2);
    if (Partner2 <> nil) and ((Ship1.EnemyShip = Partner2) or (Partner2.EnemyShip = Ship1)) then
      Ship1.TruceWithShip(Partner2);
    Ship1.TruceWithShip(Ship2);
  end;
end;

procedure SF_ShipInPrison(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script ShipInPrison');
  av[0].AsInteger := 0;
  Ship := TShip(av[1].AsDword);
  if Ship.CurrentPlanet <> nil then
  begin
    if GetPlayer = Ship then
    begin
      if GetPlayer.InPrison then
        av[0].AsInteger := 1;
    end
    else
      case Ship.TypeId of
        stRanger:
        begin
          av[0].AsInteger := (Ship as TRanger).PrisonTermRemaining;
          if High(av) > 1 then
            (Ship as TRanger).PrisonTermRemaining := av[2].AsInteger;
        end;
        stPirate:
        begin
          av[0].AsInteger := (Ship as TPirate).PrisonTermRemaining;
          if High(av) > 1 then
            (Ship as TPirate).PrisonTermRemaining := av[2].AsInteger;
        end;
      end;
  end;
end;

procedure SF_ShipPartners(av: array of TVarEC; code: TCodeEC);
var
  Ship, Partner: TShip;
  Index, Wanted, Found: Integer;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script ShipPartners');
  Ship := TShip(av[1].AsDword);
  Wanted := -1;
  Found := -1;
  av[0].AsDword := 0;
  if High(av) > 1 then
    Wanted := av[2].AsInteger;
  for Index := 0 to Galaxy.Rangers.Count - 1 do
  begin
    Partner := Galaxy.Rangers[Index];
    if Partner.PartnerShip = Ship then
    begin
      Inc(Found);
      if Found = Wanted then
      begin
        av[0].AsDword := PtrUInt(Partner);
        Exit;
      end;
    end;
  end;
  if High(av) = 1 then
    av[0].AsInteger := Found + 1;
end;

procedure SF_PlayerPirates(av: array of TVarEC; code: TCodeEC);
var
  Index, Count: Integer;
begin
  if GetPlayer.PiratePartners = nil then
    Count := 0
  else
    Count := GetPlayer.PiratePartners.Count;
  if High(av) < 1 then
    av[0].AsInteger := Count
  else
  begin
    Index := av[1].AsInteger;
    if (Index < 0) or (Index >= Count) then
      av[0].AsDword := 0
    else
      av[0].AsDword := PtrUInt(GetPlayer.PiratePartners[Index]);
  end;
end;

procedure SF_ShipIsPartner(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script ShipIsPartner');
  Ship := TShip(av[1].AsDword);
  if Ship <> nil then
  begin
    if (High(av) > 1) and (av[2].AsInteger <> 0) then
      av[0].AsInteger := Ship.PartnershipDaysRemaining
    else
      av[0].AsDword := PtrUInt(Ship.PartnerShip);
  end;
end;

procedure SF_ShipFreeSpace(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) <> 1 then
    raise Exception.Create('Error.Script ShipFreeSpace');
  Ship := TShip(av[1].AsDword);
  if Ship <> nil then
    av[0].AsInteger := Ship.CargoFreeSpace;
end;

procedure SF_ShipWealth(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) <> 1 then
    raise Exception.Create('Error.Script ShipWealth');
  Ship := TShip(av[1].AsDword);
  if Ship <> nil then
    av[0].AsInteger := Ship.Wealth;
end;

procedure SF_DomiksDefeated(av: array of TVarEC; code: TCodeEC);
var
  Series: TDominatorSeries;
begin
  if High(av) < 1 then
  begin
    if not Galaxy.HasUnresolvedDominatorSeries([dsBlazer, dsKeller, dsTerron]) then
      av[0].AsInteger := 1
    else
      av[0].AsInteger := 0;
  end
  else
  begin
    Series := TDominatorSeries(av[1].AsInteger);
    case Series of
      dsBlazer:
        if Galaxy.BlazerSeriesResolvedTurn = 0 then
          av[0].AsInteger := 0
        else if (Galaxy.BlazerLandingPlanetId <> 0) and (BlazerShip <> nil) then
          av[0].AsInteger := 3
        else if Galaxy.BlazerSelfDestructTurn <> 0 then
          av[0].AsInteger := 2
        else
          av[0].AsInteger := 1;
      dsKeller:
        if Galaxy.KellerSeriesResolvedTurn = 0 then
          av[0].AsInteger := 0
        else if Galaxy.KellerLeaveTurn <> 0 then
          av[0].AsInteger := 2
        else if Galaxy.KellerResearchTargetStarId <> 0 then
          av[0].AsInteger := 3
        else
          av[0].AsInteger := 1;
      dsTerron:
        if Galaxy.TerronSeriesResolvedTurn = 0 then
          av[0].AsInteger := 0
        else if Galaxy.TerronToStarTurn <> 0 then
          av[0].AsInteger := 2
        else if Galaxy.TerronLandingLockTurn <> 0 then
          av[0].AsInteger := 3
        else
          av[0].AsInteger := 1;
    else
      av[0].AsInteger := 0;
    end;
  end;
end;

procedure SF_CoalitionDefeated(av: array of TVarEC; code: TCodeEC);
begin
  if Galaxy.CoalitionDefeatedTurn <> 0 then
    av[0].AsInteger := 1
  else
    av[0].AsInteger := 0;
  if High(av) > 0 then
  begin
    if av[1].AsInteger = 1 then
      Galaxy.CoalitionDefeatedTurn := Galaxy.CurrentTurn
    else
      Galaxy.CoalitionDefeatedTurn := 0;
  end;
end;

procedure SF_ShipRefuel(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script ShipRefuel');
  Ship := TShip(av[1].AsDword);
  if Ship <> nil then
    if Ship.GetFuelTanks <> nil then
      Ship.GetFuelTanks.Fuel := Ship.GetFuelTanks.Capacity;
end;

procedure SF_ShipRepairEq(av: array of TVarEC; code: TCodeEC);
var
  Index: Integer;
  Equipment: TEquipment;
  Artefact: TArtefact;
  Ship: TShip;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script ShipRepairEq');
  Ship := TShip(av[1].AsDword);
  for Index := Ship.Inventory.Count - 1 downto 1 do
  begin
    Equipment := Ship.Inventory[Index];
    if Equipment.EquippedFlag <> 0 then
      Equipment.Repair;
  end;
  for Index := 0 to Ship.Artefacts.Count - 1 do
  begin
    Artefact := Ship.Artefacts[Index];
    if Artefact.EquippedFlag <> 0 then
      Artefact.Repair;
  end;
end;

procedure SF_ItemInScript(av: array of TVarEC; code: TCodeEC);
var
  Item: TItem;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script ItemInScript');
  Item := TItem(av[1].AsDword);
  if (Item <> nil) and (Item.ScriptItem <> nil) then
    av[0].AsInteger := Ord(TScriptItem(Item.ScriptItem).Name = '') + 1
  else
    av[0].AsInteger := 0;
end;

procedure SF_FindPlanetByAdvancement(av: array of TVarEC; code: TCodeEC);
var
  Score: Integer;
  Planet: TPlanet;
  MaxScore, MinScore, TargetScore, BestDistance, Percent, I, J, Faction: Integer;
  Star: TStar;
  BestPlanet: TPlanet;

  procedure CalcValue; { Nested in SF_FindPlanetByAdvancement; reads its selected planet and writes its local score. }
  var
    I: TPlanetInvention;
  begin
    Score := 0;
    for I := Low(TPlanetInvention) to High(TPlanetInvention) do
      Score := Score + Planet.InventionLevels[I];
    for I := piHull to piMainTech do
      Score := Score + 2 * Planet.InventionLevels[I];
    Score :=
        Score + 8 * Planet.InventionLevels[piMainTech] + 4 * Planet.InventionLevels[piHull] + 2 * Planet.InventionLevels[piRepairRobot];
  end;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script FindPlanetByAdvancement');
  Faction := 0;
  if High(av) > 1 then
    Faction := av[2].AsInteger;
  Percent := Max(Min(av[1].AsInteger, 100), 0);
  MaxScore := 0;
  MinScore := 1000;
  for I := 0 to Galaxy.Stars.Count - 1 do
  begin
    Star := Galaxy.Stars[I];
    if (Faction < 0) or ((TStarFaction(Faction) = Star.ControlFaction) and (Star.Status.CustomFaction = '')) then
      for J := 0 to Star.Planets.Count - 1 do
      begin
        Planet := Star.Planets[J];
        if Planet.OwnerId <> oiUninhabited then
        begin
          CalcValue;
          MaxScore := Max(Score, MaxScore);
          MinScore := Min(Score, MinScore);
        end;
      end;
  end;
  TargetScore := MinScore + Round(Percent * (MaxScore - MinScore) / 100);
  BestDistance := 0;
  BestPlanet := nil;
  for I := 0 to Galaxy.Stars.Count - 1 do
  begin
    Star := Galaxy.Stars[I];
    if (Faction < 0) or ((TStarFaction(Faction) = Star.ControlFaction) and (Star.Status.CustomFaction = '')) then
      for J := 0 to Star.Planets.Count - 1 do
      begin
        Planet := Star.Planets[J];
        if Planet.OwnerId <> oiUninhabited then
        begin
          CalcValue;
          if (BestPlanet = nil) or (Abs(Score - TargetScore) < BestDistance) then
          begin
            BestPlanet := Planet;
            BestDistance := Abs(Score - TargetScore);
          end;
        end;
      end;
  end;
  av[0].AsDword := PtrUInt(BestPlanet);
end;

procedure SF_StarListToTransitPlanetList(av: array of TVarEC; code: TCodeEC);
var
  I, J, K, Count, DirectDistance, Detour, Limit, BaseDistance: Integer;
  Score, BestScore, Penalty: Double;
  Star, Origin, Destination: TStar;
  Planet, BestPlanet: TPlanet;
  Temp: TVarEC;
  ScorePtr: PDouble;
  Scores: TList;
  Weights: array[0..4] of Integer;
begin
  if High(av) < 4 then
    raise Exception.Create('Error.Script StarListToTransitPlanetList');
  BaseDistance := 10;
  Origin := TStar(av[2].AsDword);
  Destination := TStar(av[3].AsDword);
  Limit := BaseDistance + av[4].AsInteger;
  DirectDistance := Round(PointDistance(Origin.Position, Destination.Position));
  if av[1].ValueKind <> vkArray then
    raise Exception.Create('Error.Script StarListToTransitPlanetList - not array');
  if High(av) > 8 then
    for I := Low(Weights) to High(Weights) do
      Weights[I] := av[I + 5].AsInteger
  else
    for I := Low(Weights) to High(Weights) do
      Weights[I] := 100;
  if (High(av) > 10) and (av[10].ValueKind <> vkArray) then
    raise Exception.Create('Error.Script StarListToTransitPlanetList - not array2');
  Penalty := 0;
  if High(av) > 10 then
    Penalty := av[11].AsInteger / 100;
  Scores := TList.Create;
  I := 0;
  while I < av[1].AsArray.Count do
  begin
    Star := TStar(av[1].AsArray[I].AsDword);
    Detour :=
        Round(PointDistance(Star.Position, Destination.Position))
            + Round(PointDistance(Star.Position, Origin.Position))
            - DirectDistance
            + BaseDistance;
    BestPlanet := nil;
    BestScore := 0;
    for J := 0 to Star.Planets.Count - 1 do
    begin
      Planet := Star.Planets[J];
      if Integer(Planet.OwnerId) < 5 then
      begin
        Score := Detour * Weights[Ord(Planet.OwnerId)] / 100;
        if High(av) > 10 then
          for K := 0 to av[10].AsArray.Count - 1 do
            if (TPlanet(av[10].AsArray[K].AsDword) = Planet) or (av[10].AsArray[K].AsDword = Planet.Id) then
              Score := Score * Penalty;
        if ((BestPlanet = nil) and (Limit >= Score) and (Score > 0)) or ((Score < BestScore) and (Score > 0)) then
        begin
          BestPlanet := Planet;
          BestScore := Score;
        end;
      end;
    end;
    if (Star = Origin) or (Star = Destination) or (BestPlanet = nil) then
      av[1].AsArray.Delete(I)
    else
    begin
      av[1].AsArray[I].AsDword := PtrUInt(BestPlanet);
      New(ScorePtr);
      ScorePtr^ := BestScore;
      Scores.Add(ScorePtr);
      Inc(I);
    end;
  end;
  Count := av[1].AsArray.Count;
  if Count > 0 then
  begin
    for I := 1 to Count - 1 do
      for J := Count - 1 downto I do
        if PDouble(Scores[J])^ < PDouble(Scores[J - 1])^ then
        begin
          Temp := av[1].AsArray[J];
          av[1].AsArray[J] := av[1].AsArray[J - 1];
          av[1].AsArray[J - 1] := Temp;
          Score := PDouble(Scores[J])^;
          PDouble(Scores[J])^ := PDouble(Scores[J - 1])^;
          PDouble(Scores[J - 1])^ := Score;
        end;
    for I := 0 to Scores.Count - 1 do
      Dispose(PDouble(Scores[I]));
    Scores.Free;
  end;
  av[0].AsInteger := Count;
  if Count = 0 then
    av[1].AsArray.AddItem(TVarEC.Create(vkEmpty));
end;

procedure SF_GalaxyEvents(av: array of TVarEC; code: TCodeEC);
begin
  av[0].AsInteger := Galaxy.GalaxyEvents.Count;
end;

procedure SF_GalaxyEventDate(av: array of TVarEC; code: TCodeEC);
var
  Index: Integer;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script GalaxyEventDate');
  av[0].AsInteger := 0;
  Index := av[1].AsInteger;
  if (Index >= 0) and (Index < Galaxy.GalaxyEvents.Count) then
    av[0].AsInteger := TGalaxyEvent(Galaxy.GalaxyEvents[Index]).Turn;
end;

procedure SF_GalaxyEventType(av: array of TVarEC; code: TCodeEC);
var
  Index: Integer;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script GalaxyEventType');
  av[0].AsString := '';
  Index := av[1].AsInteger;
  if (Index >= 0) and (Index < Galaxy.GalaxyEvents.Count) then
    av[0].AsString := TGalaxyEvent(Galaxy.GalaxyEvents[Index]).EventType;
end;

procedure SF_GalaxyEventData(av: array of TVarEC; code: TCodeEC);
var
  Index: Integer;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script GalaxyEventData');
  av[0].AsInteger := 0;
  Index := av[1].AsInteger;
  if (Index >= 0) and (Index < Galaxy.GalaxyEvents.Count) then
  begin
    if High(av) > 1 then
      av[0].AsInteger := TGalaxyEvent(Galaxy.GalaxyEvents[Index]).GetData(av[2].AsInteger)
    else
      av[0].AsInteger := TGalaxyEvent(Galaxy.GalaxyEvents[Index]).Data.Count;
  end;
end;

procedure SF_GalaxyEventsTextData(av: array of TVarEC; code: TCodeEC);
var
  Index: Integer;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script GalaxyEventTextData');
  Index := av[1].AsInteger;
  if (Index >= 0) and (Index < Galaxy.GalaxyEvents.Count) then
  begin
    if High(av) > 1 then
      av[0].AsString := TGalaxyEvent(Galaxy.GalaxyEvents[Index]).GetTextData(av[2].AsInteger)
    else
      av[0].AsInteger := TGalaxyEvent(Galaxy.GalaxyEvents[Index]).TextData.Count;
  end
  else
    av[0].AsInteger := 0;
end;

procedure SF_PlanetNews(av: array of TVarEC; code: TCodeEC);
begin
  av[0].AsInteger := Galaxy.PlanetNews.Count;
end;

procedure SF_PlanetNewsDate(av: array of TVarEC; code: TCodeEC);
var
  Index: Integer;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script PlanetNewsDate');
  av[0].AsInteger := 0;
  Index := av[1].AsInteger;
  if (Index >= 0) and (Index < Galaxy.PlanetNews.Count) then
    av[0].AsInteger := PPlanetNewsEntry(Galaxy.PlanetNews[Index]).Turn;
end;

procedure SF_PlanetNewsType(av: array of TVarEC; code: TCodeEC);
var
  Index: Integer;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script PlanetNewsType');
  av[0].AsInteger := 0;
  Index := av[1].AsInteger;
  if (Index >= 0) and (Index < Galaxy.PlanetNews.Count) then
    av[0].AsInteger := Ord(PPlanetNewsEntry(Galaxy.PlanetNews[Index]).NewsType);
end;

procedure SF_PlanetNewsText(av: array of TVarEC; code: TCodeEC);
var
  Index: Integer;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script PlanetNewsText');
  av[0].AsString := '';
  Index := av[1].AsInteger;
  if (Index >= 0) and (Index < Galaxy.PlanetNews.Count) then
  begin
    av[0].AsString := PPlanetNewsEntry(Galaxy.PlanetNews[Index]).Text;
    if High(av) > 1 then
      PPlanetNewsEntry(Galaxy.PlanetNews[Index]).Text := av[2].AsString;
  end;
end;

procedure SF_ControlledSystems(av: array of TVarEC; code: TCodeEC);
var
  Index, Count: Integer;
  Faction: TStarFaction;
  Star: TStar;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script ControlledSystems');
  Faction := TStarFaction(av[1].AsInteger);
  Count := 0;
  for Index := 0 to Galaxy.Stars.Count - 1 do
  begin
    Star := Galaxy.Stars[Index];
    if (Star.Status.CustomFaction = '') and (Star.ControlFaction = Faction) then
      Inc(Count);
  end;
  av[0].AsInteger := Count;
end;

procedure SF_DeltaWin(av: array of TVarEC; code: TCodeEC);
var
  Faction: TStarFaction;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script DeltaWin');
  Faction := TStarFaction(av[1].AsInteger);
  av[0].AsInteger := Galaxy.WarDeltaWin[Faction];
  if High(av) > 1 then
    Galaxy.WarDeltaWin[Faction] := av[2].AsInteger;
end;

procedure SF_ShipInFear(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script ShipInFear');
  Ship := TShip(av[1].AsDword);
  if (Ship <> nil) and Ship.InFear then
    av[0].AsInteger := 1
  else
    av[0].AsInteger := 0;
end;

procedure SF_CreateGoods(av: array of TVarEC; code: TCodeEC);
var
  Item: TGoods;
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script CreateGoods');
  Item := TGoods.Create;
  Item.Init(TItemType(av[1].AsInteger), av[2].AsInteger);
  av[0].AsDword := PtrUInt(Item);
  if High(av) > 2 then
    Item.NaturalFlag := av[3].AsInteger <> 0;
end;

procedure SF_GetNodesFromShip(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  Index, Remaining, Total: Integer;
  Item: TItem;
  Nodes: TProtoplasm;
  Series: Integer;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script GetNodesFromShip');
  Ship := TShip(av[1].AsDword);
  Remaining := 0;
  Total := 0;
  Series := -1;
  if High(av) > 1 then
    Remaining := av[2].AsInteger;
  if High(av) > 2 then
    Series := av[3].AsInteger;
  for Index := Ship.Inventory.Count - 1 downto 0 do
  begin
    Item := Ship.Inventory[Index];
    if not (Item is TProtoplasm) then
      Continue;
    Nodes := Item as TProtoplasm;
    if (Series >= 0) and (Ord(Nodes.DominatorSeries) <> Series) then
      Continue;
    Inc(Total, Nodes.StackCount);
    if Remaining >= Nodes.StackCount then
    begin
      Dec(Remaining, Nodes.StackCount);
      Ship.Inventory.Delete(Index);
      Nodes.Free;
    end
    else
    begin
      Dec(Nodes.StackCount, Remaining);
      Nodes.Weight := Nodes.StackCount;
      Nodes.Cost := 10 * Nodes.StackCount;
      Remaining := 0;
    end;
  end;
  if (High(av) > 1) and (av[2].AsInteger > 0) then
    av[0].AsInteger := Remaining
  else
    av[0].AsInteger := Total;
end;

procedure SF_GetNodesFromStorage(av: array of TVarEC; code: TCodeEC);
var
  Index, Remaining, NewCount: Integer;
  Entry: PStorageEntry;
  Nodes: TProtoplasm;
  Location: TObject;
  Series: Integer;
begin
  Location := nil;
  if High(av) >= 1 then
    Location := TObject(av[1].AsDword);
  av[0].AsInteger := 0;
  Remaining := 0;
  Series := -1;
  if High(av) > 1 then
    Remaining := av[2].AsInteger;
  if High(av) > 2 then
    Series := av[3].AsInteger;
  Index := 0;
  while Index < GetPlayer.StorageEntries.Count do
  begin
    Entry := GetPlayer.StorageEntries[Index];
    if ((Entry.LocationOwner = Location) or (Location = nil)) and (Entry.Item.ItemType = t_Protoplasm) then
    begin
      Nodes := TProtoplasm(Entry.Item);
      // Native does not advance Index when the series differs.
      if (Series >= 0) and (Ord(Nodes.DominatorSeries) <> Series) then
        Continue;
      av[0].AsInteger := av[0].AsInteger + Nodes.Weight;
      if Remaining <= 0 then
      begin
        Inc(Index);
        Continue;
      end;
      if Remaining < Nodes.StackCount then
      begin
        NewCount := Nodes.StackCount - Remaining;
        Nodes.Cost := Round(Nodes.Cost / Nodes.StackCount * NewCount);
        Nodes.StackCount := NewCount;
        Nodes.Weight := NewCount;
        Remaining := 0;
        Inc(Index);
      end
      else
      begin
        Dec(Remaining, Nodes.Weight);
        GetPlayer.StorageEntries.Delete(Index);
        Entry.Item.Free;
        Dispose(Entry);
      end;
    end
    else
      Inc(Index);
  end;
end;

procedure SF_RangerBaseNodes(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script RangerBaseNodes');
  av[0].AsInteger := TRanger(av[1].AsDword).BaseNodes;
  if High(av) > 1 then
    TRanger(av[1].AsDword).BaseNodes := av[2].AsInteger;
end;

procedure SF_RuinsAllowModernization(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script RuinsAllowModernization');
  if TRuins(av[1].AsDword).ModernizationSponsor then
    av[0].AsInteger := 1
  else
    av[0].AsInteger := 0;
  if High(av) > 1 then
    TRuins(av[1].AsDword).ModernizationSponsor := av[2].AsInteger <> 0;
end;

procedure SF_RuinsMicromoduleChain(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Station: TRuins;
  Kind, Index: Integer;
  InvertRarity: Boolean;
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script RuinsMicromoduleChain');
  Obj := TObject(av[1].AsDword);
  if not (Obj is TRuins) then
    raise Exception.Create('Error.Script RuinsMicromoduleChain - not a ruins');
  Station := TRuins(Obj);
  Kind := av[2].AsInteger;
  if High(av) = 2 then
  begin
    for Index := 0 to 50 do
    begin
      av[0].AsInteger := Station.SelectServiceMicroModule(Kind, Index, False);
      if GetPlayer.NeedsMicroModule(av[0].AsInteger + 1) then
        Break;
    end;
  end
  else
  begin
    Index := av[3].AsInteger;
    if High(av) > 3 then
      InvertRarity := av[4].AsInteger <> 0
    else
      InvertRarity := False;
    av[0].AsInteger := Station.SelectServiceMicroModule(Kind, Index, InvertRarity);
  end;
end;

procedure SF_DomikKilledInCurSystem(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then
    av[0].AsInteger := GetPlayer.CurrentSystemKills.Dominator
  else
    av[0].AsInteger := TNormalShip(av[1].AsDword).CurrentSystemKills.Dominator;
end;

procedure SF_ShipTypeN(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script ShipTypeN');
  Ship := TShip(av[1].AsDword);
  av[0].AsInteger := Ord(Ship.TypeId);
end;

procedure SF_ShipSubType(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script ShipSubType');
  Ship := TShip(av[1].AsDword);
  if Ship is TKling then
    av[0].AsInteger := Ord(TKling(Ship).KlingType)
  else if Ship is TTransport then
    av[0].AsInteger := Ord(TTransport(Ship).TransportType)
  else if Ship is TWarrior then
    av[0].AsInteger := Ord(TWarrior(Ship).WarriorType)
  else if Ship is TPirate then
    av[0].AsInteger := TPirate(Ship).PirateType
  else if Ship is TRanger then
    av[0].AsInteger := Ord(TRanger(Ship).PreferredCareer)
  else
    av[0].AsInteger := 0;
  if High(av) <= 1 then
    Exit;
  if Ship is TKling then
    TKling(Ship).KlingType := TKlingType(av[2].AsInteger)
  else if Ship is TTransport then
    TTransport(Ship).TransportType := TTransportType(av[2].AsInteger)
  else if Ship is TWarrior then
    TWarrior(Ship).WarriorType := TWarriorType(av[2].AsInteger)
  else if Ship is TPirate then
    TPirate(Ship).PirateType := av[2].AsInteger
  else if Ship is TRanger then
    TRanger(Ship).PreferredCareer := TRangerCareer(av[2].AsInteger);
end;

procedure SF_ShipChangeStar(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script ShipChangeStar');
  if (TShip(av[1].AsDword) = GetPlayer) and (TemporaryShopSlots <> nil) then
    RestoreTemporaryShopStock;
  TShip(av[1].AsDword).TransferToStar(TStar(av[2].AsDword));
  if TShip(av[1].AsDword) = GetPlayer then
  begin
    PlayerStar := GetPlayer.CurrentStar;
    PlayerStar.RefreshMovementStepParameters;
  end;
end;

procedure SF_IsFilm(av: array of TVarEC; code: TCodeEC);
begin
  if StarMapScreen.Mode = smmTurnFilm then
    av[0].AsInteger := 1
  else
    av[0].AsInteger := 0;
  SysUtils.Sleep(1);
end;

procedure SF_FilmFlags(av: array of TVarEC; code: TCodeEC);
var
  Kind: Cardinal;
  Arg: Integer;
  Star: TStar;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script FilmFlags');
  if av[1].AsDword <= 3 then
  begin
    Star := PlayerStar;
    Kind := av[1].AsDword;
    Arg := 2;
  end
  else
  begin
    if High(av) < 2 then
      raise Exception.Create('Error.Script FilmFlags');
    Star := TStar(av[1].AsDword);
    Kind := av[2].AsDword;
    Arg := 3;
  end;
  case Kind of
    0: av[0].AsInteger := Ord(Star.RecordingTurnFilm);
    1:
    begin
      av[0].AsInteger := Ord(Star.PlayerCombatOccurred);
      if High(av) >= Arg then
        Star.PlayerCombatOccurred := av[Arg].AsInteger <> 0;
    end;
    2:
    begin
      av[0].AsInteger := Ord(Star.InterruptLongTravel);
      if High(av) >= Arg then
        Star.InterruptLongTravel := av[Arg].AsInteger <> 0;
    end;
    3:
    begin
      av[0].AsInteger := Ord(Star.KeepFilmRunning);
      if High(av) >= Arg then
        Star.KeepFilmRunning := av[Arg].AsInteger <> 0;
    end;
  end;
end;

procedure SF_ShowEffect(av: array of TVarEC; code: TCodeEC);
var
  Effect: TWeaponSE;
  Entry: PEFilmEndEntry;
  TargetGraphic, SourceGraphic: TObjectSE;
  TargetFilm, SourceFilm: TEFilmObj;
  Name: WideString;
  Target, Source: TObject;
  Item: TItem;
  Damage, ShotVisual, Variant, Destruction: Integer;
  Destroyed, PlaySound: Boolean;
  Color: Cardinal;
  Film: TEFilmObj;
  Step: Integer;
begin
  if High(av) < 3 then
    raise Exception.Create('Error.Script ShowEffect');
  Name := av[1].AsString;
  ShotVisual := av[2].AsInteger;
  Target := TObject(av[3].AsDword);
  Source := nil;
  if High(av) > 3 then
    Source := TObject(av[4].AsDword);
  Damage := 0;
  if High(av) > 4 then
    Damage := av[5].AsInteger;
  Destroyed := False;
  if High(av) > 5 then
    Destroyed := av[6].AsInteger <> 0;
  PlaySound := True;
  if High(av) > 6 then
    PlaySound := av[7].AsInteger <> 0;
  if High(av) >= 10 then
    Color := CurrentPixelFormat.PackRgb(av[8].AsInteger, av[9].AsInteger, av[10].AsInteger)
  else if Target is TShip then
  begin
    if GetPlayer = Target then
      Color := OwnerToFilmColor(RaceToOwner(GetPlayer.PilotRace))
    else if TShip(Target).HasNamedScriptFaction then
      Color := CustomFactionToFilmColor(TScriptShip(TShip(Target).ScriptShip).StateText)
    else
      Color := OwnerToFilmColor(TShip(Target).OwnerId);
  end
  else
    Color := 0;
  Variant := -1;
  if High(av) >= 11 then
    Variant := av[11].AsInteger;
  Effect := TWeaponSE.Create(Name, Point(0, 0), ShotVisual, Variant);
  if (PlayerStar <> nil) and PlayerStar.RecordingTurnFilm then
  begin
    if PrimaryFilm <> nil then
    begin
      TargetFilm := nil;
      if Target is TShip then
        TargetFilm := TShip(Target).FilmObject
      else if Target is TPlanet then
        TargetFilm := TPlanet(Target).FilmObject
      else if Target is TStar then
        TargetFilm := PrimaryFilm.FindObject(ClassSEtoName(TStar(Target).Graphic), TStar(Target).Graphic.GraphKey, TStar(Target).Id)
      else if Target is THole then
        TargetFilm := TEFilmObj(THole(Target).FilmObjectId)
      else if Target is TMissile then
        TargetFilm := TMissile(Target).FilmObject
      else if Target is TAsteroid then
        TargetFilm := TAsteroid(Target).FilmObject
      else
      begin
        Item := nil;
        if Target is TItem then
          Item := Target as TItem
        else if Target is TScriptItem then
          Item := TScriptItem(Target).Item;
        if Item <> nil then
          TargetFilm := Item.FilmObject;
      end;
      SourceFilm := nil;
      if Source <> nil then
      begin
        if Source is TShip then
          SourceFilm := TShip(Source).FilmObject
        else if Source is TPlanet then
          SourceFilm := TPlanet(Source).FilmObject
        else if Source is TStar then
          SourceFilm := PrimaryFilm.FindObject(ClassSEtoName(TStar(Source).Graphic), TStar(Source).Graphic.GraphKey, TStar(Source).Id)
        else if Source is THole then
          SourceFilm := TEFilmObj(THole(Source).FilmObjectId)
        else if Source is TMissile then
          SourceFilm := TMissile(Source).FilmObject
        else if Source is TAsteroid then
          SourceFilm := TAsteroid(Source).FilmObject
        else
        begin
          Item := nil;
          if Source is TItem then
            Item := Source as TItem
          else if Source is TScriptItem then
            Item := TScriptItem(Source).Item;
          if Item <> nil then
            SourceFilm := Item.FilmObject;
        end;
      end;
      Step := PlayerStar.CurrentStepIndex;
      Film := PrimaryFilm.AddObject(0, Effect);
      PrimaryFilm.SetWeaponEndpoints(Step, Film, SourceFilm, TargetFilm);
      PrimaryFilm.SetWeaponHit(Step, Film, Word(Color), Damage, Destroyed, PlaySound);
      if Destroyed and (av[6].AsInteger > 1) then
      begin
        Destruction := av[6].AsInteger - 1;
        PrimaryFilm.SetDestructionEffect(Step, Film, Destruction);
        if Destruction = 5 then
          PrimaryFilm.SetObjectAlpha(Step, TargetFilm, 0);
      end;
      PrimaryFilm.AttachObject(Step, Film);
    end;
  end
  else
  begin
    TargetGraphic := nil;
    if Target is TShip then
      TargetGraphic := TShip(Target).Graphic
    else if Target is TPlanet then
      TargetGraphic := TPlanet(Target).Graphic
    else if Target is TStar then
      TargetGraphic := TStar(Target).Graphic
    else if Target is THole then
      TargetGraphic := THole(Target).Graphic
    else if Target is TMissile then
      TargetGraphic := TMissile(Target).Graphic
    else if Target is TAsteroid then
      TargetGraphic := TAsteroid(Target).GraphObject
    else
    begin
      Item := nil;
      if Target is TItem then
        Item := Target as TItem
      else if Target is TScriptItem then
        Item := TScriptItem(Target).Item;
      if Item <> nil then
        TargetGraphic := Item.GetGraphObject;
    end;
    if TargetGraphic <> nil then
    begin
      SourceGraphic := nil;
      if Source <> nil then
      begin
        if Source is TShip then
          SourceGraphic := TShip(Source).Graphic
        else if Source is TPlanet then
          SourceGraphic := TPlanet(Source).Graphic
        else if Source is TStar then
          SourceGraphic := TStar(Source).Graphic
        else if Source is THole then
          SourceGraphic := THole(Source).Graphic
        else if Source is TMissile then
          SourceGraphic := TMissile(Source).Graphic
        else if Source is TAsteroid then
          SourceGraphic := TAsteroid(Source).GraphObject
        else
        begin
          Item := nil;
          if Source is TItem then
            Item := Source as TItem
          else if Source is TScriptItem then
            Item := TScriptItem(Source).Item;
          if Item <> nil then
            SourceGraphic := Item.GetGraphObject;
        end;
      end;
      Effect.SetEndpoints(SourceGraphic, TargetGraphic);
      Effect.SetHit(Color, Damage, Destroyed, PlaySound);
      if GetInnermostScreenLoop = StarMapScreen then
      begin
        if TrailingFilmEffects = nil then
          TrailingFilmEffects := TEFilmEnd.Create;
        Entry := TrailingFilmEffects.AppendEntry;
        RetainSpaceObject(Entry.SceneObject, Effect);
        RetainSpaceObject(Entry.RelatedObject1, nil);
        Entry.SceneObject.AttachToSpace(SpaceProcess.Space);
      end
      else
        StarMapScreen.PendingSceneObjects.Add(Effect);
    end;
  end;
end;

procedure SF_ShowStaticEffect(av: array of TVarEC; code: TCodeEC);
var
  X, Y: Integer;
  Effect: TGAIEffectSE;
  Name: WideString;
  Scale: Single;
  Film: TEFilmObj;
  Step: Integer;
  Entry: PEFilmEndEntry;
begin
  if High(av) < 3 then
    raise Exception.Create('Error.Script ShowStaticEffect');
  Name := av[1].AsString;
  X := av[2].AsInteger;
  Y := av[3].AsInteger;
  if High(av) > 3 then
    Scale := av[4].AsInteger * 0.01
  else
    Scale := 1;
  if (PlayerStar <> nil) and PlayerStar.RecordingTurnFilm then
  begin
    if PrimaryFilm <> nil then
    begin
      Effect := TGAIEffectSE.Create('Effect.' + Name, Point(0, 0));
      Step := PlayerStar.CurrentStepIndex;
      Film := PrimaryFilm.AddObject(0, Effect);
      PrimaryFilm.SetEffectImagePosition(Step, Film, Point(X, Y));
      PrimaryFilm.SetEffectDurationScale(Step, Film, Scale);
      PrimaryFilm.AttachObject(Step, Film);
    end;
  end
  else
  begin
    Effect := TGAIEffectSE.Create('Effect.' + Name, Point(0, 0));
    Effect.SetImagePosition(Point(X, Y));
    Effect.SetDurationScale(Scale);
    if GetInnermostScreenLoop = StarMapScreen then
    begin
      if TrailingFilmEffects = nil then
        TrailingFilmEffects := TEFilmEnd.Create;
      Entry := TrailingFilmEffects.AppendEntry;
      RetainSpaceObject(Entry.SceneObject, Effect);
      RetainSpaceObject(Entry.RelatedObject1, nil);
      Entry.SceneObject.AttachToSpace(SpaceProcess.Space);
    end
    else
      StarMapScreen.PendingSceneObjects.Add(Effect);
  end;
end;

procedure SF_ShipConnect(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  Star: TStar;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script ShipConnect');
  Ship := TShip(av[1].AsDword);
  if Ship = nil then
    raise Exception.Create('Error.Script ShipConnect ship=nil');
  Star := Ship.CurrentStar;
  if Star = nil then
    raise Exception.Create('Error.Script ShipConnect ship.FCurStar=nil');
  Ship.PrepareTurnMovement(Star.CurrentStepIndex, True);
  Ship.FilmAlpha := 0;
  if Star.MovementStepCount - 1 <= Star.CurrentStepIndex then
    Ship.FilmAlpha := 255
  else
  begin
    if (Star.MovementStepCount - Star.CurrentStepIndex - 1) * Ship.FilmAlphaStep < 255 then
      Ship.FilmAlphaStep := 255 / (Star.MovementStepCount - Star.CurrentStepIndex - 1);
  end;
  if Ship.MovementPath.ActiveHead <> nil then
    Ship.ClearMovementPath;
  Ship.BuildOrderMovementPath(Star.MovementStepCount);
end;

procedure SF_FilmSound(av: array of TVarEC; code: TCodeEC);
var
  FilmObject: TEFilmObj;
  Text: WideString;
  Obj: TObject;
  Item: TItem;
  Step: Integer;
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script FilmSound');
  if (PlayerStar = nil) or not PlayerStar.RecordingTurnFilm or (PrimaryFilm = nil) then
    Exit;
  Text := av[1].AsString;
  Obj := TObject(av[2].AsDword);
  FilmObject := nil;
  if Obj is TShip then
    FilmObject := TShip(Obj).FilmObject
  else if Obj is TPlanet then
    FilmObject := TPlanet(Obj).FilmObject
  else if Obj is TStar then
    FilmObject := PrimaryFilm.FindObject(ClassSEtoName(TStar(Obj).Graphic), TStar(Obj).Graphic.GraphKey, TStar(Obj).Id)
  else if Obj is THole then
    FilmObject := TEFilmObj(THole(Obj).FilmObjectId)
  else if Obj is TMissile then
    FilmObject := TMissile(Obj).FilmObject
  else if Obj is TAsteroid then
    FilmObject := TAsteroid(Obj).FilmObject
  else
  begin
    Item := nil;
    if Obj is TItem then
      Item := Obj as TItem
    else if Obj is TScriptItem then
      Item := TScriptItem(Obj).Item;
    if Item <> nil then
      FilmObject := Item.FilmObject;
  end;
  Step := PlayerStar.CurrentStepIndex;
  PrimaryFilm.PlayObjectSound(Step, FilmObject, Text);
end;

procedure SF_FireWeapon(av: array of TVarEC; code: TCodeEC);
var
  Target: TObject;
  Ship: TShip;
  Weapon: TWeapon;
  RecordFilm: Boolean;
begin
  if High(av) < 3 then
    raise Exception.Create('Error.Script FireWeapon');
  Ship := TShip(av[1].AsDword);
  Target := TObject(av[2].AsDword);
  Weapon := TWeapon(av[3].AsDword);
  RecordFilm := Ship.CurrentStar.RecordingTurnFilm;
  if Target is TMissile then
    Ship.FireWeaponAtMissile(Weapon, Target, RecordFilm)
  else if Target is TShip then
    Ship.FireWeaponAtShip(Weapon, TShip(Target), RecordFilm)
  else if Target is TItem then
    Ship.FireWeaponAtItem(Weapon, TItem(Target), RecordFilm)
  else if Target is TAsteroid then
    Ship.FireWeaponAtAsteroid(Weapon, Target, RecordFilm);
end;

procedure SF_WeaponHit(av: array of TVarEC; code: TCodeEC);
var
  Target: TObject;
  Ship: TShip;
  Weapon: TWeapon;
  Range: Integer;
  Color: Cardinal;
  Hit: Boolean;
  Missile: TMissile;
  Star: TStar;
  Flags: TDamageFlagSet;
begin
  if High(av) < 3 then
    raise Exception.Create('Error.Script WeaponHit');
  Ship := TShip(av[1].AsDword);
  Target := TObject(av[2].AsDword);
  Weapon := TWeapon(av[3].AsDword);
  Range := -1;
  if High(av) > 3 then
    Range := av[4].AsInteger;
  if Target is TShip then
    av[0].AsInteger := TShip(Target).ApplyWeaponHit(Ship, Weapon, Range, Color, Flags, 1, 0)
  else if Target is TMissile then
  begin
    Missile := TMissile(Target);
    Hit := Missile.CanBeHit(Ship, Weapon);
    Hit := Ship.ScriptItemsAct(satOnWeaponShot, Missile, Weapon, Ord(Hit)) <> 0;
    if Hit then
    begin
      Star := Missile.CurrentStar;
      if Star.RecordingTurnFilm then
      begin
        PrimaryFilm.DetachObject(Star.CurrentStepIndex, Missile.FilmObject);
        Star.PendingFilmObjectRemovals.Add(Missile.FilmObject);
        ReleaseSpaceObject(Missile.Graphic);
      end;
      Missile.Free;
    end;
    av[0].AsInteger := Ord(Hit);
  end;
end;

procedure SF_DealDamageToShip(av: array of TVarEC; code: TCodeEC);
var
  Source: TObject;
  Ship: TShip;
  Damage: Integer;
  Flags: TDamageFlagSet;
  Range: Integer;
  Color: Cardinal;
begin
  if High(av) < 3 then
    raise Exception.Create('Error.Script DealDamageToShip');
  Ship := TShip(av[1].AsDword);
  Source := TObject(av[2].AsDword);
  Damage := av[3].AsInteger;
  if (Source <> nil) and (Source is TItem) then
    av[0].AsInteger := Ship.ApplyExplosionDamage(nil, Source, Damage, nil)
  else
  begin
    if High(av) > 3 then
      Dword(Flags) := av[4].AsDword
    else
      Flags := [dkEnergy];
    if High(av) > 4 then
      Range := av[5].AsInteger
    else
      Range := -1;
    av[0].AsInteger := Ship.ApplyDamage(Source, Damage, Range, Color, Flags);
  end;
end;

procedure SF_LaunchMissile(av: array of TVarEC; code: TCodeEC);
var
  Target, Obj: TObject;
  Ship: TShip;
  Weapon: TWeapon;
  Shot: Integer;
  Missile: TMissile;
  Step: Integer;
begin
  if High(av) < 3 then
    raise Exception.Create('Error.Script LaunchMissile');
  Ship := TShip(av[1].AsDword);
  Target := TObject(av[2].AsDword);
  Obj := TObject(av[3].AsDword);
  if Obj is TScriptItem then
    Weapon := TWeapon(TScriptItem(Obj).Item)
  else
    Weapon := TWeapon(Obj);
  Shot := 0;
  if High(av) > 3 then
    Shot := av[4].AsInteger;
  if Weapon is TCustomWeapon then
  begin
    Missile := TCustomMissile.Create;
    TCustomMissile(Missile).InitializeShot(Ship.CurrentStar, Ship, Weapon, Target, Shot);
  end
  else
  begin
    Missile := TMissile.Create;
    Missile.InitializeShot(Ship.CurrentStar, Ship, Weapon, Target, Shot);
  end;
  Ship.ScriptItemsAct(satOnMissileShot, Missile, Weapon, 0);
  av[0].AsDword := PtrUInt(Missile);
  if Ship.CurrentStar.RecordingTurnFilm then
  begin
    Step := Ship.CurrentStar.CurrentStepIndex;
    Missile.PrepareTurnMovement(Step, True, True);
    PrimaryFilm.DetachObject(0, Missile.FilmObject);
  end;
end;

procedure SF_SpawnMissile(av: array of TVarEC; code: TCodeEC);
var
  Star: TStar;
  Target: TObject;
  X, Y: Integer;
  Direction: Single;
  MinDamage, MaxDamage: Integer;
  Speed: Single;
  Kind: TItemType;
  Module, Special: Integer;
  Missile: TMissile;
  Step: Integer;
begin
  if High(av) < 9 then
    raise Exception.Create('Error.Script SpawnMissile');
  Star := TStar(av[1].AsDword);
  Target := TObject(av[2].AsDword);
  X := av[3].AsInteger;
  Y := av[4].AsInteger;
  Direction := av[5].AsInteger;
  MinDamage := av[6].AsInteger;
  MaxDamage := av[7].AsInteger;
  Speed := av[8].AsInteger;
  if High(av) > 9 then
  begin
    Module := av[10].AsInteger + 1;
    Special := av[11].AsInteger + 1;
  end
  else
  begin
    Module := 0;
    Special := 0;
  end;
  if av[9].ValueKind = vkString then
  begin
    Missile := TCustomMissile.Create;
    TCustomMissile(Missile)
        .InitializeUnownedShot(Star, Target, X, Y, Direction, MinDamage, MaxDamage, Speed, av[9].AsString, Module, Special);
  end
  else
  begin
    Kind := TItemType(av[9].AsInteger);
    Missile := TMissile.Create;
    Missile.InitializeUnownedShot(Star, Target, X, Y, Direction, MinDamage, MaxDamage, Speed, Kind, Module, Special);
  end;
  av[0].AsDword := PtrUInt(Missile);
  if Star.RecordingTurnFilm then
  begin
    Step := Star.CurrentStepIndex;
    Missile.PrepareTurnMovement(Step, True, True);
    PrimaryFilm.DetachObject(0, Missile.FilmObject);
  end;
end;

procedure SF_BonusText(av: array of TVarEC; code: TCodeEC);
var
  Index, Count: Integer;
  Text: WideString;
  Bonus: TEquipmentBonusKind;
  Value: Integer;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script BonusText');
  Index := av[1].AsInteger;
  if (Index < 0) or (Index >= MicroModuleTemplateCount) then
  begin
    av[0].AsString := '';
    Exit;
  end;

  if High(av) < 2 then
  begin
    av[0].AsString := GetMicroModuleInfoText(Index, TextHighlightColorTag);
    Exit;
  end;

  Count := av[2].AsInteger;
  Text := LocalizedColorText('MicroModuls.' + MicroModuleTemplates[Index].ConfigName + '.ExText');
  if Text <> '' then
  begin
    ReplaceTextToken(Text, '<ExCount>', IntToStr(Count), TextHighlightColorTag);
    if MicroModuleTemplates[Index].SeparatedNumbers then
      for Bonus := Low(TEquipmentBonusKind) to High(TEquipmentBonusKind) do
      begin
        Value := Count * MicroModuleTemplates[Index].StatBonuses[Bonus];
        if Value > 0 then
          ReplaceTextToken(Text, '<' + EquipmentBonusNames[Bonus] + '>', '+' + IntToStr(Value), TextHighlightColorTag)
        else if Value < 0 then
          ReplaceTextToken(Text, '<' + EquipmentBonusNames[Bonus] + '>', IntToStr(Value), TextHighlightColorTag)
        else
          ReplaceTextToken(Text, '<' + EquipmentBonusNames[Bonus] + '>', '--', TextHighlightColorTag);
      end;
  end;
  av[0].AsString := WrapTextInColor(Text, GetMicroModuleTextColorTag(Index));
end;

procedure SF_PlanetPirateClan(av: array of TVarEC; code: TCodeEC);
begin
  av[0].AsDword := PtrUInt(MainPiratePlanet);
end;

procedure SF_Blazer(av: array of TVarEC; code: TCodeEC);
begin
  av[0].AsDword := PtrUInt(BlazerShip);
end;

procedure SF_Keller(av: array of TVarEC; code: TCodeEC);
begin
  av[0].AsDword := PtrUInt(KellerShip);
end;

procedure SF_Terron(av: array of TVarEC; code: TCodeEC);
begin
  av[0].AsDword := PtrUInt(TerronShip);
end;

procedure SF_PirateType(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script PirateType');
  Ship := TShip(av[1].AsDword);
  if Ship is TPirate then
    av[0].AsInteger := TPirate(Ship).PirateType
  else
    av[0].AsInteger := 0;
end;

procedure SF_PlayerQuestInProgress(av: array of TVarEC; code: TCodeEC);
var
  Quest: PQuest;
  Index: Integer;
  Planet: TPlanet;
begin
  if GetPlayer.Quests <> nil then
  begin
    if High(av) > 0 then
      Planet := TPlanet(av[1].AsDword)
    else
      Planet := nil;
    for Index := 0 to GetPlayer.Quests.Count - 1 do
    begin
      Quest := GetPlayer.Quests[Index];
      if ((Planet = nil) or (Quest.Planet = Planet)) and not Quest.Successful then
      begin
        av[0].AsInteger := 1;
        Exit;
      end;
    end;
  end;
  av[0].AsInteger := 0;
end;

procedure SF_PlayerQuestsCompleted(av: array of TVarEC; code: TCodeEC);
var
  Quest: PPlayerOldQuest;
  Index: Integer;
begin
  av[0].AsInteger := 0;
  if (PlayerOldQuests <> nil) and (PlayerOldQuests.Count > 0) then
    for Index := 0 to PlayerOldQuests.Count - 1 do
    begin
      Quest := PlayerOldQuests[Index];
      if ((High(av) < 1) or (TQuestType(av[1].AsInteger) = Quest.QuestType)) and (Quest.Successful) then
        av[0].AsInteger := av[0].AsInteger + 1;
    end;
end;

procedure SF_QuestsStatusByNom(av: array of TVarEC; code: TCodeEC);
var
  Kind: TQuestType;
  Number, Index: Integer;
  OldQuest: PPlayerOldQuest;
  Quest: PQuest;
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script QuestsStatusByNom');
  Kind := TQuestType(av[1].AsInteger);
  Number := av[2].AsInteger;
  if (PlayerOldQuests <> nil) and (PlayerOldQuests.Count > 0) then
    for Index := 0 to PlayerOldQuests.Count - 1 do
    begin
      OldQuest := PlayerOldQuests[Index];
      if (OldQuest.QuestType = Kind) and (OldQuest.QuestNumber = Number) then
      begin
        if OldQuest.Successful then
          av[0].AsInteger := 3
        else
          av[0].AsInteger := 4;
        Exit;
      end;
    end;
  if (GetPlayer.Quests <> nil) and (GetPlayer.Quests.Count > 0) then
    for Index := 0 to GetPlayer.Quests.Count - 1 do
    begin
      Quest := GetPlayer.Quests[Index];
      if (Quest.QuestType = Kind) and (Quest.QuestNumber = Number) then
      begin
        if Quest.Successful then
          av[0].AsInteger := 2
        else
          av[0].AsInteger := 1;
        Exit;
      end;
    end;
  av[0].AsInteger := 0;
end;

procedure SF_PlayerPlanetaryBattlesCompleted(av: array of TVarEC; code: TCodeEC);
begin
  av[0].AsInteger := GetPlayer.PlanetBattles;
end;

procedure SF_PlayerMayTakeSubCrack(av: array of TVarEC; code: TCodeEC);
begin
  if GetPlayer.MayTakeSubCrack then
    av[0].AsInteger := 1
  else
    av[0].AsInteger := 0;
end;

procedure SF_SubCrackCost(av: array of TVarEC; code: TCodeEC);
begin
  av[0].AsInteger := GetPlayer.GetSubCrackCost;
end;

procedure SF_ShipCalcParam(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script ShipCalcParam');
  TShip(av[1].AsDword).RefreshDerivedStats(True);
end;

procedure SF_ShipRefit(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script ShipRefit');
  av[0].AsInteger := 0;
  Ship := TShip(av[1].AsDword);
  if High(av) > 2 then
    if av[3].AsInteger > Ship.Money then
      Ship.SetMoney(av[3].AsInteger);
  Ship.BuyEquipmentAtLocation(True);
  if High(av) > 1 then
    if Ship.GetHull.Weight < av[2].AsInteger then
    begin
      Ship.GetHull.Weight := av[2].AsInteger;
      Ship.GetHull.HullPoints := av[2].AsInteger;
    end;
  Ship.RefreshDerivedStats(True);
  av[0].AsInteger := 1;
end;

procedure SF_ShipImproveItems(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  I, Count: Integer;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script ShipImproveItems');
  av[0].AsInteger := 0;
  Ship := TShip(av[1].AsDword);
  Count := 1;
  if High(av) > 1 then
    Count := av[2].AsInteger;
  for I := 1 to Count do
    Ship.ImproveRandomEquipment(False);
  Ship.RefreshDerivedStats(True);
  if Ship.GetDesiredCargoFreeSpace > Ship.CargoFreeSpace then
  begin
    Ship.GetHull.Weight := Ship.GetHull.Weight - Ship.CargoFreeSpace + Ship.GetDesiredCargoFreeSpace;
    if (Ship.CurrentPlanet <> nil) or (Ship.DockedTo <> nil) or (Ship.CurrentStar = nil) then
      Ship.GetHull.HullPoints := Ship.GetHull.Weight;
  end;
  Ship.RefreshDerivedStats(True);
end;

procedure SF_ItemImprovement(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Item: TItem;
  Equipment: TEquipment;
  SavedId, Kind: Integer;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script SF_ItemImprovement');
  Obj := TObject(av[1].AsDword);
  Item := nil;
  if Obj is TItem then
    Item := TItem(Obj);
  if Obj is TScriptItem then
    Item := TScriptItem(Obj).Item;
  av[0].AsInteger := 0;
  if Item.ItemType in [t_Hull..t_CustomWeapon] then
  begin
    Equipment := TEquipment(Item);
    if not Equipment.HasStandardStats then
      av[0].AsInteger := 1;
    if High(av) > 1 then
    begin
      Kind := av[2].AsInteger;
      if (Kind < 0) or (Kind > 3) then
        Kind := 3;
      if High(av) > 2 then
        Equipment.DetailImprovement := av[3].AsInteger
      else
        Equipment.DetailImprovement := 0;
      if High(av) > 3 then
      begin
        SavedId := Equipment.Id;
        Equipment.Id := av[4].AsDword;
        Equipment.Improve(TImprovementKind(Kind));
        Equipment.Id := SavedId;
      end
      else
        Equipment.Improve(TImprovementKind(Kind));
    end;
  end;
end;

procedure SF_ShipFreeFlight(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  Snapshot: TScriptContextSnapshot;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script SF_ShipFreeFlight');
  Ship := TShip(av[1].AsDword);
  ScriptSnap(Snapshot);
  if (High(av) < 2) or (av[2].AsInteger = 0) then
    Ship.NextDayLogic
  else
    case av[2].AsInteger of
      1: Ship.AssignWeaponTargetsInStar;
      2: Ship.SelectEnemyShipInStar;
      3: Ship.EngageEnemyShip;
      4: Ship.DropCargoUntilNotOverloaded;
      5: Ship.AutoApplyMicroModules;
      6: Ship.QueueItemsWithinPickupRange;
    end;
  ScriptUnSnap(Snapshot);
end;

procedure SF_ShipKillFactionInCurSystem(av: array of TVarEC; code: TCodeEC);
type
  TKillFactionIndex = 0..3;
  TKillCounts = array[0..3] of Word;
var
  Obj: TObject;
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script SF_ShipKillFactionInCurSystem');
  Obj := TObject(av[1].AsDword);
  if not (Obj is TNormalShip) then
  begin
    av[0].AsInteger := 0;
    Exit;
  end;

  if av[2].AsInteger = -1 then
  begin
    av[0].AsInteger := (Obj as TNormalShip).CurrentSystemKills.Custom;
    if High(av) > 2 then
      (Obj as TNormalShip).CurrentSystemKills.Custom := av[3].AsInteger;
  end
  else
  begin
    av[0].AsInteger := TKillCounts((Obj as TNormalShip).CurrentSystemKills)[TKillFactionIndex(av[2].AsInteger)];
    if High(av) > 2 then
    begin
      TKillCounts((Obj as TNormalShip).CurrentSystemKills)[TKillFactionIndex(av[2].AsInteger)] := av[3].AsInteger;
      TShip(Obj).RefreshCurrentStanding;
    end;
  end;
end;

procedure SF_CapitalShipStats(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Ship: TShip;
  Hull: THull;
begin
  av[0].AsInteger := 0;
  if High(av) < 1 then
    raise Exception.Create('Error.Script SF_CapitalShipStats');
  Obj := TObject(av[1].AsDword);
  Ship := nil;
  Hull := nil;
  if Obj is TScriptShip then
    Ship := (Obj as TScriptShip).Ship;
  if Obj is TShip then
    Ship := TShip(Obj);
  if Ship <> nil then
    Hull := Ship.GetHull;
  if Obj is THull then
    Hull := THull(Obj);
  if Hull = nil then
    Exit;
  av[0].AsInteger := Hull.CapitalShip;
  if High(av) <= 1 then
    Exit;
  Hull.CapitalShip := av[2].AsInteger;
  if Hull.CapitalShip = 1 then
  begin
    Hull.InterceptorsEnabled := True;
    if High(av) > 2 then
      Hull.EnergyMax := av[3].AsInteger
    else
      Hull.EnergyMax := 1000;
    Hull.Energy := Min(Hull.Energy, Hull.EnergyMax);
  end
  else
  begin
    Hull.InterceptorsEnabled := False;
    Hull.EnergyMax := 0;
    Hull.Energy := 0;
  end;
end;

procedure SF_PlayerBridge(av: array of TVarEC; code: TCodeEC);
var
  Mode: Integer;
begin
  av[0].AsInteger := GetPlayer.RuinsMode;
  if High(av) > 0 then
  begin
    Mode := av[1].AsInteger;
    if High(av) > 1 then
      GetPlayer.RuinsStatusText := av[2].AsString
    else
      GetPlayer.RuinsStatusText := '';
    if Mode > 0 then
      GetPlayer.EnterRuinsMode(Mode)
    else
      GetPlayer.CloseRuinsModeScreen;
  end;
end;

procedure SF_PlayerDebt(av: array of TVarEC; code: TCodeEC);
begin
  av[0].AsInteger := GetPlayer.DebtAmount;
  if High(av) > 0 then
    GetPlayer.DebtAmount := av[1].AsInteger;
end;

procedure SF_PlayerDebtDate(av: array of TVarEC; code: TCodeEC);
begin
  av[0].AsInteger := GetPlayer.DebtDueTurn;
  if High(av) > 0 then
    GetPlayer.DebtDueTurn := av[1].AsInteger;
end;

procedure SF_PlayerDebtCnt(av: array of TVarEC; code: TCodeEC);
begin
  av[0].AsInteger := GetPlayer.DebtDefaultCount;
  if High(av) > 0 then
    GetPlayer.DebtDefaultCount := av[1].AsInteger;
end;

procedure SF_PlayerDeposit(av: array of TVarEC; code: TCodeEC);
begin
  av[0].AsInteger := GetPlayer.DepositAmount;
  if High(av) > 0 then
    GetPlayer.DepositAmount := av[1].AsInteger;
end;

procedure SF_PlayerDepositDate(av: array of TVarEC; code: TCodeEC);
begin
  av[0].AsInteger := GetPlayer.DepositStartTurn;
  if High(av) > 0 then
    GetPlayer.DepositStartTurn := av[1].AsInteger;
end;

procedure SF_PlayerDepositDay(av: array of TVarEC; code: TCodeEC);
begin
  av[0].AsInteger := GetPlayer.DepositDayCount;
  if High(av) > 0 then
    GetPlayer.DepositDayCount := av[1].AsInteger;
end;

procedure SF_PlayerDepositPercent(av: array of TVarEC; code: TCodeEC);
begin
  av[0].AsInteger := Round(GetPlayer.DepositInterestRate * 100);
  if High(av) > 0 then
    GetPlayer.DepositInterestRate := av[1].AsInteger * 0.01;
end;

procedure SF_PlayerMedPolicy(av: array of TVarEC; code: TCodeEC);
begin
  av[0].AsInteger := GetPlayer.MedicalPolicyTicks;
  if High(av) > 0 then
    GetPlayer.MedicalPolicyTicks := av[1].AsInteger;
end;

procedure SF_ShipCustomShipInfosCount(av: array of TVarEC; code: TCodeEC);
var
  I, Count: Integer;
  Ship: TShip;
  Info: PCustomShipInfo;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script ShipCustomShipInfosCount');
  Ship := TShip(av[1].AsDword);
  Count := 0;
  for I := 0 to Ship.CustomShipInfos.Count - 1 do
  begin
    Info := Ship.CustomShipInfos[I];
    if not Info.DeleteQueued then
      Inc(Count);
  end;
  av[0].AsInteger := Count;
end;

procedure SF_ShipAddCustomShipInfo(av: array of TVarEC; code: TCodeEC);
var
  Info: PCustomShipInfo;
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script ShipAddCustomShipInfo');
  New(Info);
  TShip(av[1].AsDword).CustomShipInfos.Add(Info);
  Info.ActionCode := nil;
  Info.TypeName := av[2].AsString;
  Info.ActionCodeInitialized := False;
  Info.DeleteQueued := False;
  if High(av) > 2 then
    Info.Description := av[3].AsString
  else
    Info.Description := '';
  if High(av) > 3 then
    Info.Data[1] := av[4].AsInteger
  else
    Info.Data[1] := 0;
  if High(av) > 4 then
    Info.Data[2] := av[5].AsInteger
  else
    Info.Data[2] := 0;
  if High(av) > 5 then
    Info.Data[3] := av[6].AsInteger
  else
    Info.Data[3] := 0;
  if High(av) > 6 then
    Info.TextData1 := av[7].AsString
  else
    Info.TextData1 := '';
  if High(av) > 7 then
    Info.TextData2 := av[8].AsString
  else
    Info.TextData2 := '';
  if High(av) > 8 then
    Info.TextData3 := av[9].AsString
  else
    Info.TextData3 := '';
  Info.StatusEffect :=
      LanguageDataConfig
              .GetBlock('ShipInfo')
              .GetBlock('AddInfo')
              .GetBlock('CustomInfos')
              .GetBlock(Info.TypeName)
              .CountParams('StatusEffect')
          > 0;
  av[0].AsDword := PtrUInt(Info);
end;

procedure SF_ShipDeleteCustomShipInfo(av: array of TVarEC; code: TCodeEC);
var
  Index, I: Integer;
  Info: PCustomShipInfo;
  Ship: TShip;
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script ShipDeleteCustomShipInfo');
  Ship := TShip(av[1].AsDword);
  if av[2].ValueKind = vkString then
  begin
    for I := 0 to Ship.CustomShipInfos.Count - 1 do
    begin
      Info := Ship.CustomShipInfos[I];
      if Info.DeleteQueued then
        Continue;
      if Info.TypeName <> av[2].AsString then
        Continue;
      Info.DeleteQueued := True;
      Exit;
    end;
    Exit;
  end;
  if (av[2].AsDword > 10000) and (av[2].AsInteger <> -1) then
  begin
    if (Ship = nil) or (Ship.CustomShipInfos.IndexOf(PCustomShipInfo(av[2].AsDword)) >= 0) then
      PCustomShipInfo(av[2].AsDword).DeleteQueued := True;
    Exit;
  end;
  Index := av[2].AsInteger;
  if Index < 0 then
    Exit;
  Info := nil;
  for I := 0 to Ship.CustomShipInfos.Count - 1 do
  begin
    Info := Ship.CustomShipInfos[I];
    if Info.DeleteQueued then
      Continue;
    Dec(Index);
    if Index < 0 then
      Break;
  end;
  if (Index < 0) and (Info <> nil) then
    Info.DeleteQueued := True;
end;

procedure SF_ShipFindCustomShipInfoByType(av: array of TVarEC; code: TCodeEC);
var
  I, Index: Integer;
  Info: PCustomShipInfo;
  Ship: TShip;
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script ShipFindCustomShipInfoByType');
  Ship := TShip(av[1].AsDword);
  Index := 0;
  for I := 0 to Ship.CustomShipInfos.Count - 1 do
  begin
    Info := Ship.CustomShipInfos[I];
    if Info.DeleteQueued then
      Continue;
    if Info.TypeName = av[2].AsString then
    begin
      av[0].AsInteger := Index;
      Exit;
    end;
    Inc(Index);
  end;
  av[0].AsInteger := -1;
end;

procedure SF_ShipCustomShipInfoDescription(av: array of TVarEC; code: TCodeEC);
var
  I, Index: Integer;
  Info: PCustomShipInfo;
  Ship: TShip;
  Block: TBlockParEC;
begin
  { Native validation accepts one argument even though lookup below reads av[2]. }
  if High(av) < 1 then
    raise Exception.Create('Error.Script ShipCustomShipInfoDescription');
  av[0].AsString := '';
  Ship := TShip(av[1].AsDword);
  if av[2].ValueKind = vkString then
  begin
    Info := nil;
    for I := 0 to Ship.CustomShipInfos.Count - 1 do
    begin
      Info := Ship.CustomShipInfos[I];
      if not Info.DeleteQueued and (Info.TypeName = av[2].AsString) then
        Break;
    end;
    if (Info = nil) or (Info.TypeName <> av[2].AsString) then
      Exit;
  end
  else if (av[2].AsDword > 10000) and (av[2].AsInteger <> -1) then
  begin
    Info := PCustomShipInfo(av[2].AsDword);
    if (Ship <> nil) and (Ship.CustomShipInfos.IndexOf(Info) < 0) then
      Exit;
  end
  else
  begin
    Index := av[2].AsInteger;
    if Index < 0 then
      Exit;
    Info := nil;
    for I := 0 to Ship.CustomShipInfos.Count - 1 do
    begin
      Info := Ship.CustomShipInfos[I];
      if Info.DeleteQueued then
        Continue;
      Dec(Index);
      if Index < 0 then
        Break;
    end;
    if (Index >= 0) or (Info = nil) then
      Exit;
  end;
  av[0].AsString := Info.Description;
  if av[0].AsString = '' then
  begin
    Block := LanguageDataConfig.GetBlock('ShipInfo').GetBlock('AddInfo').GetBlock('CustomInfos').GetBlock(Info.TypeName);
    if Block.CountParams('Description') <> 0 then
      av[0].AsString := Block.GetParam('Description');
  end;
  if High(av) > 2 then
    Info.Description := av[3].AsString;
end;

procedure SF_ShipCustomShipInfoData(av: array of TVarEC; code: TCodeEC);
var
  I, Index, DataIndex: Integer;
  Info: PCustomShipInfo;
  Ship: TShip;
begin
  if High(av) < 3 then
    raise Exception.Create('Error.Script ShipCustomShipInfoData');
  av[0].AsInteger := 0;
  Ship := TShip(av[1].AsDword);
  if av[2].ValueKind = vkString then
  begin
    Info := nil;
    for I := 0 to Ship.CustomShipInfos.Count - 1 do
    begin
      Info := Ship.CustomShipInfos[I];
      if not Info.DeleteQueued and (Info.TypeName = av[2].AsString) then
        Break;
    end;
    if (Info = nil) or (Info.TypeName <> av[2].AsString) then
      Exit;
  end
  else if (av[2].AsDword > 10000) and (av[2].AsInteger <> -1) then
  begin
    Info := PCustomShipInfo(av[2].AsDword);
    if (Ship <> nil) and (Ship.CustomShipInfos.IndexOf(Info) < 0) then
      Exit;
  end
  else
  begin
    Index := av[2].AsInteger;
    if Index < 0 then
      Exit;
    Info := nil;
    for I := 0 to Ship.CustomShipInfos.Count - 1 do
    begin
      Info := Ship.CustomShipInfos[I];
      if Info.DeleteQueued then
        Continue;
      Dec(Index);
      if Index < 0 then
        Break;
    end;
    if (Index >= 0) or (Info = nil) then
      Exit;
  end;
  DataIndex := av[3].AsInteger;
  case DataIndex of
    1: av[0].AsInteger := Info.Data[1];
    2: av[0].AsInteger := Info.Data[2];
    3: av[0].AsInteger := Info.Data[3];
  else
    raise Exception.Create('Error.Script ShipCustomShipInfoData ind');
  end;
  if High(av) > 3 then
    case DataIndex of
      1: Info.Data[1] := av[4].AsInteger;
      2: Info.Data[2] := av[4].AsInteger;
      3: Info.Data[3] := av[4].AsInteger;
    end;
end;

procedure SF_ShipCustomShipInfoTextData(av: array of TVarEC; code: TCodeEC);
var
  I, Index, DataIndex: Integer;
  Info: PCustomShipInfo;
  Ship: TShip;
begin
  if High(av) < 3 then
    raise Exception.Create('Error.Script ShipCustomShipInfoTextData');
  av[0].AsString := '';
  Ship := TShip(av[1].AsDword);
  if av[2].ValueKind = vkString then
  begin
    Info := nil;
    for I := 0 to Ship.CustomShipInfos.Count - 1 do
    begin
      Info := Ship.CustomShipInfos[I];
      if not Info.DeleteQueued and (Info.TypeName = av[2].AsString) then
        Break;
    end;
    if (Info = nil) or (Info.TypeName <> av[2].AsString) then
      Exit;
  end
  else if (av[2].AsDword > 10000) and (av[2].AsInteger <> -1) then
  begin
    Info := PCustomShipInfo(av[2].AsDword);
    if (Ship <> nil) and (Ship.CustomShipInfos.IndexOf(Info) < 0) then
      Exit;
  end
  else
  begin
    Index := av[2].AsInteger;
    if Index < 0 then
      Exit;
    Info := nil;
    for I := 0 to Ship.CustomShipInfos.Count - 1 do
    begin
      Info := Ship.CustomShipInfos[I];
      if Info.DeleteQueued then
        Continue;
      Dec(Index);
      if Index < 0 then
        Break;
    end;
    if (Index >= 0) or (Info = nil) then
      Exit;
  end;
  DataIndex := av[3].AsInteger;
  case DataIndex of
    1: av[0].AsString := Info.TextData1;
    2: av[0].AsString := Info.TextData2;
    3: av[0].AsString := Info.TextData3;
  else
    raise Exception.Create('Error.Script ShipCustomShipInfoData ind');
  end;
  if High(av) > 3 then
    case DataIndex of
      1: Info.TextData1 := av[4].AsString;
      2: Info.TextData2 := av[4].AsString;
      3: Info.TextData3 := av[4].AsString;
    end;
end;

procedure SF_StarCustomStarInfosCount(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script StarCustomStarInfosCount');
  av[0].AsInteger := TStar(av[1].AsDword).CustomSystemInfos.Count;
end;

procedure SF_StarAddCustomStarInfo(av: array of TVarEC; code: TCodeEC);
var
  Info: TCustomSystemInfo;
  Star: TStar;
begin
  if High(av) < 3 then
    raise Exception.Create('Error.Script StarAddCustomStarInfo');
  Star := TStar(av[1].AsDword);
  Info := TCustomSystemInfo.Create;
  Star.CustomSystemInfos.Add(Info);
  Info.TypeTag := av[2].AsString;
  Info.Name := av[3].AsString;
  if High(av) > 3 then
    Info.Distance := av[4].AsInteger
  else
    Info.Distance := 0;
  if High(av) > 4 then
    Info.Icon := av[5].AsString
  else
    Info.Icon := '';
  if High(av) > 5 then
    Info.Info := av[6].AsString
  else
    Info.Info := '';
end;

procedure SF_StarDeleteCustomStarInfo(av: array of TVarEC; code: TCodeEC);
var
  I: Integer;
  Info: TCustomSystemInfo;
  Star: TStar;
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script StarDeleteCustomStarInfo');
  Star := TStar(av[1].AsDword);
  if av[2].ValueKind = vkString then
  begin
    for I := 0 to Star.CustomSystemInfos.Count - 1 do
    begin
      Info := Star.CustomSystemInfos[I];
      if Info.TypeTag <> av[2].AsString then
        Continue;
      Star.CustomSystemInfos.Delete(I);
      Info.Free;
      Break;
    end;
    Exit;
  end;
  I := av[2].AsInteger;
  if (I < 0) or (Star.CustomSystemInfos.Count <= I) then
    Exit;
  Info := Star.CustomSystemInfos[I];
  Star.CustomSystemInfos.Delete(I);
  Info.Free;
end;

procedure SF_StarFindCustomStarInfoByType(av: array of TVarEC; code: TCodeEC);
var
  I: Integer;
  Info: TCustomSystemInfo;
  Star: TStar;
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script StarFindCustomStarInfoByType');
  Star := TStar(av[1].AsDword);
  for I := 0 to Star.CustomSystemInfos.Count - 1 do
  begin
    Info := Star.CustomSystemInfos[I];
    if Info.TypeTag <> av[2].AsString then
      Continue;
    av[0].AsInteger := I;
    Exit;
  end;
  av[0].AsInteger := -1;
end;

procedure SF_StarCustomStarInfoData(av: array of TVarEC; code: TCodeEC);
var
  I: Integer;
  Info: TCustomSystemInfo;
  Star: TStar;
begin
  if High(av) < 3 then
    raise Exception.Create('Error.Script StarCustomStarInfoData');
  av[0].AsString := '';
  Star := TStar(av[1].AsDword);
  I := av[2].AsInteger;
  if (I < 0) or (Star.CustomSystemInfos.Count <= I) then
    Exit;
  Info := Star.CustomSystemInfos[I];
  if av[3].AsString = 'Name' then
  begin
    av[0].AsString := Info.Name;
    if High(av) > 3 then
      Info.Name := av[4].AsString;
  end
  else if av[3].AsString = 'Dist' then
  begin
    av[0].AsInteger := Info.Distance;
    if High(av) > 3 then
      Info.Distance := av[4].AsInteger;
  end
  else if av[3].AsString = 'Icon' then
  begin
    av[0].AsString := Info.Icon;
    if High(av) > 3 then
      Info.Icon := av[4].AsString;
  end
  else if av[3].AsString = 'Info' then
  begin
    av[0].AsString := Info.Info;
    if High(av) > 3 then
      Info.Info := av[4].AsString;
  end
  else
    raise Exception.Create('Error.Script StarCustomStarInfoData 2');
end;

procedure SF_ItemCanBeBroken(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  CanBreak: Boolean;
  Item: TItem;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script ItemCanBeBroken');
  CanBreak := False;
  Obj := TObject(av[1].AsDword);
  Item := nil;
  if Obj is TItem then
    Item := TItem(Obj);
  if Obj is TScriptItem then
    Item := TScriptItem(Obj).Item;
  if Item <> nil then
    CanBreak :=
        (Item.ItemType in [t_FuelTanks..t_CustomWeapon, t_Satellite])
            or (Item.ItemType
                in [t_Artefact, t_ArtefactHull..t_ArtefactAntigrav, t_ArtDefToEnergy..t_ArtGiperJump, t_ArtBio..t_ArtFastRacks]);
  av[0].AsDword := Ord(CanBreak);
end;

procedure SF_ItemFragility(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Item: TItem;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script ItemFragility');
  Obj := TObject(av[1].AsDword);
  Item := nil;
  if Obj is TItem then
    Item := TItem(Obj);
  if Obj is TScriptItem then
    Item := TScriptItem(Obj).Item;
  av[0].AsFloat := 1;
  if (Item = nil) or not (Item is TEquipment) then
    Exit;
  av[0].AsFloat := TEquipment(Item).GetFragilityFactor([]);
end;

procedure SF_ItemDurability(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  OldValue, NewValue: Integer;
  Item: TItem;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script ItemDurability');
  OldValue := 100;
  Obj := TObject(av[1].AsDword);
  Item := nil;
  if Obj is TItem then
    Item := TItem(Obj);
  if Obj is TScriptItem then
    Item := TScriptItem(Obj).Item;
  if Item <> nil then
    if Item is TEquipment then
    begin
      OldValue := Round((Item as TEquipment).ConditionPercent);
      if High(av) > 1 then
      begin
        NewValue := Min(av[2].AsInteger, 100);
        (Item as TEquipment).ConditionPercent := NewValue;
        (Item as TEquipment).BrokenFlag := Ord(NewValue <= 0);
      end;
    end;
  av[0].AsInteger := OldValue;
end;

procedure SF_ItemLevel(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  OldLevel, NewLevel: Integer;
  Item: TItem;
  OldBase, NewBase: TEquipment;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script ItemLevel');
  Obj := TObject(av[1].AsDword);
  Item := nil;
  OldLevel := 0;
  if Obj is TItem then
    Item := TItem(Obj);
  if Obj is TScriptItem then
    Item := TScriptItem(Obj).Item;
  if Item <> nil then
    if Item.ItemType in [t_Hull..t_CustomWeapon] then
    begin
      OldLevel := (Item as TEquipment).GetLevel;
      if High(av) > 1 then
      begin
        NewLevel := Max(1, av[2].AsInteger);
        if Item is TWeapon then
        begin
          OldBase := CreateGeneratedWeapon(TWeapon(Item).GetWeaponInfo, Item.Weight, OldLevel, Item.OwnerId);
          NewBase := CreateGeneratedWeapon(TWeapon(Item).GetWeaponInfo, Item.Weight, NewLevel, Item.OwnerId);
        end
        else
        begin
          OldBase := CreateGeneratedEquipment(Item.ItemType, Item.Weight, OldLevel, Item.OwnerId);
          NewBase := CreateGeneratedEquipment(Item.ItemType, Item.Weight, NewLevel, Item.OwnerId);
        end;
        case Item.ItemType of
          t_Hull:
          begin
            THull(Item).TechLevel := NewLevel;
            THull(Item).Armor := THull(Item).Armor + THull(NewBase).Armor - THull(OldBase).Armor;
          end;
          t_FuelTanks:
          begin
            TFuelTanks(Item).TechLevel := NewLevel;
            TFuelTanks(Item).Capacity := TFuelTanks(Item).Capacity + TFuelTanks(NewBase).Capacity - TFuelTanks(OldBase).Capacity;
            TFuelTanks(Item).Fuel := Max(0, Min(TFuelTanks(Item).Fuel, TFuelTanks(Item).Capacity));
          end;
          t_Engine:
          begin
            TEngine(Item).TechLevel := NewLevel;
            TEngine(Item).Speed := TEngine(Item).Speed + TEngine(NewBase).Speed - TEngine(OldBase).Speed;
            TEngine(Item).JumpRange := TEngine(Item).JumpRange + TEngine(NewBase).JumpRange - TEngine(OldBase).JumpRange;
          end;
          t_Radar:
          begin
            TRadar(Item).TechLevel := NewLevel;
            TRadar(Item).Range := TRadar(Item).Range + TRadar(NewBase).Range - TRadar(OldBase).Range;
          end;
          t_Scaner:
          begin
            TScaner(Item).TechLevel := NewLevel;
            TScaner(Item).ScanPower := TScaner(Item).ScanPower + TScaner(NewBase).ScanPower - TScaner(OldBase).ScanPower;
          end;
          t_RepairRobot:
          begin
            TRepairRobot(Item).TechLevel := NewLevel;
            TRepairRobot(Item).RepairPoints :=
                TRepairRobot(Item).RepairPoints + TRepairRobot(NewBase).RepairPoints - TRepairRobot(OldBase).RepairPoints;
          end;
          t_CargoHook:
          begin
            TCargoHook(Item).TechLevel := NewLevel;
            TCargoHook(Item).PickupPower :=
                TCargoHook(Item).PickupPower + TCargoHook(NewBase).PickupPower - TCargoHook(OldBase).PickupPower;
            TCargoHook(Item).Range := TCargoHook(Item).Range + TCargoHook(NewBase).Range - TCargoHook(OldBase).Range;
            TCargoHook(Item).MinPullSpeed :=
                TCargoHook(Item).MinPullSpeed + TCargoHook(NewBase).MinPullSpeed - TCargoHook(OldBase).MinPullSpeed;
            TCargoHook(Item).MaxPullSpeed :=
                TCargoHook(Item).MaxPullSpeed + TCargoHook(NewBase).MaxPullSpeed - TCargoHook(OldBase).MaxPullSpeed;
          end;
          t_DefGenerator:
          begin
            TDefGenerator(Item).TechLevel := NewLevel;
            TDefGenerator(Item).DamageFactor :=
                TDefGenerator(Item).DamageFactor + TDefGenerator(NewBase).DamageFactor - TDefGenerator(OldBase).DamageFactor;
          end;
        else
          if Item.ItemType in WeaponItemTypes then
          begin
            TWeapon(Item).TechLevel := NewLevel;
            TWeapon(Item).Range := TWeapon(Item).Range + TWeapon(NewBase).Range - TWeapon(OldBase).Range;
            TWeapon(Item).MinDamage := TWeapon(Item).MinDamage + TWeapon(NewBase).MinDamage - TWeapon(OldBase).MinDamage;
            TWeapon(Item).MaxDamage := TWeapon(Item).MaxDamage + TWeapon(NewBase).MaxDamage - TWeapon(OldBase).MaxDamage;
            TWeapon(Item).AmmoCapacity := TWeapon(Item).AmmoCapacity + TWeapon(NewBase).AmmoCapacity - TWeapon(OldBase).AmmoCapacity;
            TWeapon(Item).Ammo := Max(0, TWeapon(Item).Ammo + TWeapon(NewBase).Ammo - TWeapon(OldBase).Ammo);
          end;
        end;
        OldBase.Free;
        NewBase.Free;
      end;
    end;
  av[0].AsInteger := OldLevel;
end;

procedure SF_ContainerFuel(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script ContainerFuel');
  Obj := TObject(av[1].AsDword);
  if Obj is TFuelTanks then
  begin
    av[0].AsInteger := TFuelTanks(Obj).Fuel;
    if High(av) > 1 then
      TFuelTanks(Obj).Fuel := av[2].AsInteger;
  end
  else if Obj is TCistern then
  begin
    av[0].AsInteger := TCistern(Obj).Fuel;
    if High(av) > 1 then
      TCistern(Obj).Fuel := av[2].AsInteger;
  end
  else
    av[0].AsInteger := 0;
end;

procedure SF_ItemCharge(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script ItemCharge');
  Obj := TObject(av[1].AsDword);
  if Obj is TArtefactTransmitter then
  begin
    av[0].AsInteger := TArtefactTransmitter(Obj).Power;
    if High(av) > 1 then
      TArtefactTransmitter(Obj).Power := av[2].AsInteger;
  end
  else
    av[0].AsInteger := 0;
end;

procedure SF_MissilesToRearm(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Needed, Count: Integer;
  Item: TItem;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script MissilesToRearm');
  Obj := TObject(av[1].AsDword);
  Needed := 0;
  Item := nil;
  if Obj is TItem then
    Item := TItem(Obj);
  if Obj is TScriptItem then
    Item := TScriptItem(Obj).Item;
  if Item <> nil then
    if TWeapon(Item).GetWeaponInfo.ShotType in [wstTorpedo..wstRocket] then
    begin
      // Native checks the base equipment class here, then accesses weapon fields.
      Needed := TWeapon(Item as TEquipment).AmmoCapacity - TWeapon(Item as TEquipment).Ammo;
      if High(av) > 1 then
      begin
        Count := av[2].AsInteger;
        TWeapon(Item as TEquipment).Ammo := Max(0, Min(TWeapon(Item as TEquipment).AmmoCapacity, TWeapon(Item as TEquipment).Ammo + Count));
      end;
    end;
  av[0].AsInteger := Needed;
end;

procedure SF_WeaponAmmunition(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Item: TItem;
  Weapon: TWeapon;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script WeaponAmmunition');
  Obj := TObject(av[1].AsDword);
  Item := nil;
  if Obj is TItem then
    Item := TItem(Obj);
  if Obj is TScriptItem then
    Item := TScriptItem(Obj).Item;
  if (Item = nil) or not (Item is TWeapon) then
    av[0].AsInteger := 0
  else
  begin
    Weapon := Item as TWeapon;
    av[0].AsInteger := Weapon.Ammo;
    if High(av) > 1 then
      Weapon.Ammo := av[2].AsInteger;
  end;
end;

procedure SF_WeaponMaxAmmunition(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Item: TItem;
  Weapon: TWeapon;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script WeaponAmmunition');
  Obj := TObject(av[1].AsDword);
  Item := nil;
  if Obj is TItem then
    Item := TItem(Obj);
  if Obj is TScriptItem then
    Item := TScriptItem(Obj).Item;
  if (Item = nil) or not (Item is TWeapon) then
  begin
    av[0].AsInteger := 0;
    Exit;
  end;

  Weapon := Item as TWeapon;
  av[0].AsInteger := Weapon.AmmoCapacity;
  if High(av) > 1 then
    Weapon.AmmoCapacity := av[2].AsInteger;
end;

procedure SF_ShipSpecialBonuses(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
  Kind: TEquipmentBonusKind;
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script SF_ShipSpecialBonuses');
  Ship := TShip(av[1].AsDword);
  Kind := TEquipmentBonusKind(av[2].AsInteger);
  if (High(av) > 2) and (av[3].ValueKind = vkString) and (av[3].AsString = 'Total') then
    av[0].AsInteger := Ship.GetTotalStatBonus(Kind)
  else
  begin
    av[0].AsInteger := Ship.GetOwnStatBonus(Kind);
    if High(av) > 2 then
      Ship.SetStatBonus(Kind, av[3].AsInteger);
  end;
end;

procedure SF_ItemExtraSpecials(av: array of TVarEC; code: TCodeEC);
var
  Item: TEquipment;
  Index, Count: Integer;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script SF_ItemExtraSpecials');
  if (High(av) = 1) and (TItem(av[1].AsDword).ItemType in [t_Food..t_Narcotics]) then
  begin
    av[0].AsInteger := 0;
    Exit;
  end;

  Item := TEquipment(av[1].AsDword);
  if Item.ExtraSpecials = nil then
    Count := 0
  else
    Count := Item.ExtraSpecials.Count;
  if High(av) < 2 then
    av[0].AsInteger := Count
  else
  begin
    Index := av[2].AsInteger;
    if (Index < 0) or (Index >= Count) then
      av[0].AsInteger := -1
    else
      av[0].AsInteger := PExtraSpecial(Item.ExtraSpecials[Index]).ModuleIndexPlusOne - 1;
  end;
end;

procedure SF_ItemExtraSpecialsCountByType(av: array of TVarEC; code: TCodeEC);
var
  Item: TEquipment;
  ModuleIndex, Index: Integer;
  Entry: PExtraSpecial;
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script SF_ItemExtraSpecialsCountByType');
  if TItem(av[1].AsDword).ItemType in [t_Food..t_Narcotics] then
  begin
    av[0].AsInteger := 0;
    Exit;
  end;

  Item := TEquipment(av[1].AsDword);
  ModuleIndex := av[2].AsInteger + 1;
  av[0].AsInteger := 0;
  if Item.ExtraSpecials = nil then
    Exit;
  for Index := 0 to Item.ExtraSpecials.Count - 1 do
  begin
    Entry := Item.ExtraSpecials[Index];
    if Entry.ModuleIndexPlusOne = ModuleIndex then
    begin
      av[0].AsInteger := Entry.Count;
      Exit;
    end;
  end;
end;

procedure SF_ItemExtraSpecialsAddByType(av: array of TVarEC; code: TCodeEC);
var
  Item: TEquipment;
  ModuleIndex, Index, Found, Count: Integer;
  Entry: PExtraSpecial;
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script SF_ItemExtraSpecialsAddByType');
  Item := TEquipment(av[1].AsDword);
  ModuleIndex := av[2].AsInteger + 1;
  if ModuleIndex <= 0 then
    raise Exception.Create('Error.Script SF_ItemExtraSpecialsAddByType invalid bonus');
  if High(av) > 2 then
    Count := av[3].AsInteger
  else
    Count := 1;
  if Item.ExtraSpecials = nil then
  begin
    if Count <= 0 then
      Exit;
    Item.ExtraSpecials := TList.Create;
  end;
  Entry := nil;
  Found := -1;
  for Index := 0 to Item.ExtraSpecials.Count - 1 do
    if PExtraSpecial(Item.ExtraSpecials[Index]).ModuleIndexPlusOne = ModuleIndex then
    begin
      Entry := Item.ExtraSpecials[Index];
      Found := Index;
      Break;
    end;
  if Entry <> nil then
  begin
    Inc(Entry.Count, Count);
    if Entry.Count <= 0 then
    begin
      Dispose(Entry);
      Item.ExtraSpecials.Delete(Found);
      if Item.ExtraSpecials.Count = 0 then
      begin
        Item.ExtraSpecials.Free;
        Item.ExtraSpecials := nil;
      end;
    end;
  end
  else
  begin
    New(Entry);
    Item.ExtraSpecials.Add(Entry);
    Entry.ModuleIndexPlusOne := ModuleIndex;
    Entry.Count := Count;
  end;
end;

procedure SF_ItemExtraSpecialsDeleteByType(av: array of TVarEC; code: TCodeEC);
var
  Item: TEquipment;
  ModuleIndex, Index, Found, Count: Integer;
  Entry: PExtraSpecial;
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script SF_ItemExtraSpecialsDeleteByType');
  Item := TEquipment(av[1].AsDword);
  ModuleIndex := av[2].AsInteger + 1;
  if High(av) > 2 then
    Count := av[3].AsInteger
  else
    Count := 1;
  if Item.ExtraSpecials = nil then
    Exit;
  Entry := nil;
  Found := -1;
  for Index := 0 to Item.ExtraSpecials.Count - 1 do
    if PExtraSpecial(Item.ExtraSpecials[Index]).ModuleIndexPlusOne = ModuleIndex then
    begin
      Entry := Item.ExtraSpecials[Index];
      Found := Index;
      Break;
    end;
  if Entry <> nil then
  begin
    Dec(Entry.Count, Count);
    if Entry.Count <= 0 then
    begin
      Dispose(Entry);
      Item.ExtraSpecials.Delete(Found);
      if Item.ExtraSpecials.Count = 0 then
      begin
        Item.ExtraSpecials.Free;
        Item.ExtraSpecials := nil;
      end;
    end;
  end;
end;

procedure SF_ExecuteCodeFromString(av: array of TVarEC; code: TCodeEC);
var
  SourceText: WideString;
  RunCode: TCodeEC;
  SavedScript: TScript;
  I, Count: Integer;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script SF_ExecuteCodeFromString');
  SourceText := av[1].AsString;
  if High(av) = 1 then
  begin
    if code <> nil then
      ExecuteScriptText(SourceText, code.LocalVar)
    else
      ExecuteScriptText(SourceText, nil);
  end
  else
  begin
    SavedScript := CurrentScript;
    RunCode := CompileScriptText(SourceText);
    RunCode.LinkAll(SharedScriptVariables, False);
    RunCode.LinkAll(ScriptFunctionScope, False);
    RunCode.ScriptFunLinked := True;
    if code <> nil then
      RunCode.LinkAll(code.LocalVar, False);
    Count := (High(av) - 1) div 2;
    for I := 1 to Count do
      RunCode.LocalVar.Add(av[2 * I].AsString, av[2 * I + 1].ValueKind).Assume(av[2 * I + 1], True);
    try
      RunCode.Run(ScriptProcess);
    except
      on E: EBreakMessageGI do
        ;
      on E: Exception do
      begin
        AppendLogLineThreadSafe(E.ClassName + ' ' + E.Message);
        LogScriptCallHistory;
        AppendLogLineThreadSafe('Error while executing code from string: ');
        if Length(SourceText) <= 256 then
          AppendLogLineThreadSafe(AnsiString(SourceText))
        else
          AppendLogLineThreadSafe(AnsiString(Copy(SourceText, 1, 256) + ' ...'));
        raise;
      end;
    end;
    if High(av) mod 2 = 0 then
      av[0].Assume(RunCode.LocalVar.NamedItems[av[High(av)].AsString], True);
    CurrentScript := SavedScript;
    RunCode.Free;
  end;
end;

procedure SF_GenerateCodeStringFromBlock(av: array of TVarEC; code: TCodeEC);
var
  Path: WideString;
  I, Count: Integer;
  Block: TBlockParEC;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script SF_GenerateCodeStringFromBlock');
  av[0].AsString := '';
  Path := av[1].AsString;
  Count := CountDelimitedPartsW(Path, '.');
  if (High(av) > 1) and (av[2].AsInteger <> 0) then
    Block := MainDataConfig
  else
    Block := LanguageDataConfig;
  for I := 0 to Count - 1 do
  begin
    Block := Block.FindBlockByPath(ExtractDelimitedPartW(Path, I, '.'));
    if Block = nil then
    begin
      AppendLogLineThreadSafe(
          AnsiString('Warning.Script SF_GenerateCodeStringFromBlock - cant find block ' + av[1].AsString + ' [' + IntToStr(I) + ']')
      );
      Exit;
    end;
  end;
  av[0].AsString := Block.ConcatenateValues;
  if av[0].AsString = '' then
    AppendLogLineThreadSafe(AnsiString('Warning.Script SF_GenerateCodeStringFromBlock - no code at ' + av[1].AsString));
end;

procedure SF_ItemOnUseCode(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Binding: TScriptItem;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script ItemOnUseCode');
  Obj := TObject(av[1].AsDword);
  Binding := nil;
  if Obj is TItem then
    Binding := TScriptItem(TItem(Obj).ScriptItem);
  if Obj is TScriptItem then
    Binding := TScriptItem(Obj);
  if Binding <> nil then
  begin
    av[0].AsString := Binding.OnUseText;
    if High(av) > 1 then
      Binding.OnUseText := av[2].AsString;
  end
  else
    av[0].AsString := '';
end;

procedure SF_ItemOnActCode(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Binding: TScriptItem;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script ItemOnActCode');
  Obj := TObject(av[1].AsDword);
  Binding := nil;
  if Obj is TItem then
    Binding := TScriptItem(TItem(Obj).ScriptItem);
  if Obj is TScriptItem then
    Binding := TScriptItem(Obj);
  if Binding <> nil then
  begin
    av[0].AsString := Binding.OnActionText;
    if High(av) > 1 then
    begin
      Binding.ActionCodeInitialized := False;
      if High(av) > 3 then
        Binding.OnActionText := '[' + av[3].AsString + '|' + av[4].AsString + ']' + av[2].AsString
      else if High(av) = 3 then
        Binding.OnActionText := '[' + av[3].AsString + '|]' + av[2].AsString
      else
        Binding.OnActionText := av[2].AsString;
    end;
  end
  else
    av[0].AsString := '';
end;

procedure SF_CreateActCodeEvent(av: array of TVarEC; code: TCodeEC);
var
  ActionType: TScriptActionType;
  Obj, Object1, Object2: TObject;
  Info: PCustomShipInfo;
  Ship: TShip;
  Param, I: Integer;
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script CreateActCodeEvent');
  ActionType := TScriptActionType(av[1].AsInteger);
  if av[2].ValueKind = vkString then
  begin
    if High(av) < 3 then
      raise Exception.Create('Error.Script CreateActCodeEvent cant call info without ship');
    Obj := TObject(av[3].AsDword);
    if not (Obj is TShip) then
      raise Exception.Create('Error.Script CreateActCodeEvent cant call info - not a ship');
    Ship := TShip(Obj);
    for I := 0 to Ship.CustomShipInfos.Count - 1 do
    begin
      Info := Ship.CustomShipInfos[I];
      if Info.DeleteQueued then
        Continue;
      if Info.TypeName <> av[2].AsString then
        Continue;
      if High(av) >= 4 then
        Object1 := TObject(av[4].AsDword)
      else
        Object1 := nil;
      if High(av) >= 5 then
        Object2 := TObject(av[5].AsDword)
      else
        Object2 := nil;
      if High(av) >= 6 then
        Param := av[6].AsInteger
      else
        Param := 0;
      av[0].AsInteger := RunCustomShipInfoActionCode(Info, ActionType, Ship, Object1, Object2, Param);
      Exit;
    end;
    av[0].AsInteger := 0;
    Exit;
  end;
  Obj := TObject(av[2].AsDword);
  av[0].AsInteger := 0;
  if Obj is TShip then
  begin
    if High(av) >= 3 then
      Object1 := TObject(av[3].AsDword)
    else
      Object1 := nil;
    if High(av) >= 4 then
      Object2 := TObject(av[4].AsDword)
    else
      Object2 := nil;
    if High(av) >= 5 then
      Param := av[5].AsInteger
    else
      Param := 0;
    av[0].AsInteger := (Obj as TShip).ScriptItemsAct(ActionType, Object1, Object2, Param);
  end
  else if Obj is TItem then
  begin
    if High(av) >= 3 then
      Ship := TShip(av[3].AsDword)
    else
      Ship := nil;
    if High(av) >= 4 then
      Object1 := TObject(av[4].AsDword)
    else
      Object1 := nil;
    if High(av) >= 5 then
      Object2 := TObject(av[5].AsDword)
    else
      Object2 := nil;
    if High(av) >= 6 then
      Param := av[6].AsInteger
    else
      Param := 0;
    if TItem(Obj).ScriptItem <> nil then
      av[0].AsInteger := TScriptItem(TItem(Obj).ScriptItem).RunActionCode(ActionType, Ship, Object1, Object2, Param);
    if Obj is TEquipmentWithActCode then
      av[0].AsInteger := RunItemConfigActionCode(TItem(Obj), ActionType, Ship, Object1, Object2, Param);
  end;
end;

procedure SF_CurItem(av: array of TVarEC; code: TCodeEC);
begin
  if ScriptItemContextStack.Count < 1 then
    av[0].AsDword := PtrUInt(ScriptUseItem)
  else
    av[0].AsDword := PtrUInt(ScriptItemContextStack[ScriptItemContextStack.Count - 1]);
end;

procedure SF_CurInfo(av: array of TVarEC; code: TCodeEC);
begin
  if ScriptItemInfoContextStack.Count < 1 then
    av[0].AsDword := 0
  else
    av[0].AsDword := PtrUInt(ScriptItemInfoContextStack[ScriptItemInfoContextStack.Count - 1]);
end;

procedure SF_ScriptItemActShip(av: array of TVarEC; code: TCodeEC);
begin
  if ScriptActionShipStack.Count < 1 then
    av[0].AsDword := 0
  else
    av[0].AsDword := PtrUInt(ScriptActionShipStack[ScriptActionShipStack.Count - 1]);
end;

procedure SF_ScriptItemActObject1(av: array of TVarEC; code: TCodeEC);
begin
  if ScriptActionObject1Stack.Count < 1 then
    av[0].AsDword := 0
  else
    av[0].AsDword := PtrUInt(ScriptActionObject1Stack[ScriptActionObject1Stack.Count - 1]);
end;

procedure SF_ScriptItemActObject2(av: array of TVarEC; code: TCodeEC);
begin
  if ScriptActionObject2Stack.Count < 1 then
    av[0].AsDword := 0
  else
    av[0].AsDword := PtrUInt(ScriptActionObject2Stack[ScriptActionObject2Stack.Count - 1]);
end;

procedure SF_ScriptItemActionType(av: array of TVarEC; code: TCodeEC);
var
  Matches: Boolean;
begin
  if ScriptActionTypeStack.Count < 1 then
    av[0].AsDword := 0
  else if High(av) <= 0 then
    av[0].AsDword := Cardinal(ScriptActionTypeStack[ScriptActionTypeStack.Count - 1])
  else
  begin
    Matches := Integer(ScriptActionTypeStack[ScriptActionTypeStack.Count - 1]) = av[1].AsInteger;
    if Matches and (High(av) > 1) then
      if av[1].AsInteger = 43 then
        Matches := PtrUInt(ScriptActionParamStack[ScriptActionParamStack.Count - 1]) = av[2].AsDword
      else
        Matches := Integer(ScriptActionParamStack[ScriptActionParamStack.Count - 1]) = av[2].AsInteger;
    av[0].AsDword := Ord(Matches);
  end;
end;

procedure SF_ScriptItemActParam(av: array of TVarEC; code: TCodeEC);
begin
  // Purchase action 43 carries a destination object; other actions use signed
  // 32-bit numbers. Keep the pointer intact through both reads and writes.
  if ScriptActionParamStack.Count < 1 then
    av[0].AsInteger := 0
  else if (ScriptActionTypeStack.Count > 0) and (PtrUInt(ScriptActionTypeStack[ScriptActionTypeStack.Count - 1]) = 43) then
  begin
    av[0].AsDword := PtrUInt(ScriptActionParamStack[ScriptActionParamStack.Count - 1]);
    if High(av) > 0 then
      ScriptActionParamStack[ScriptActionParamStack.Count - 1] := Pointer(av[1].AsDword);
  end
  else
  begin
    av[0].AsInteger := Integer(ScriptActionParamStack[ScriptActionParamStack.Count - 1]);
    if High(av) > 0 then
      ScriptActionParamStack[ScriptActionParamStack.Count - 1] := Pointer(av[1].AsInteger);
  end;
end;

procedure SF_OnUseCodeTranclucator(av: array of TVarEC; code: TCodeEC);
var
  Item: TArtefactTranclucator;
  Ship: TTranclucator;
  Index: Integer;
  Angle: Single;
  Entry: PStorageEntry;
  Star: TStar;
  Other: TObject;
begin
  if (ScriptUseItem <> nil) and (ScriptUseItem is TArtefactTranclucator) then
    Item := TArtefactTranclucator(ScriptUseItem)
  else
  begin
    if High(av) < 1 then
      Exit;
    if av[1].AsDword = 0 then
      Exit;
    if not (TObject(av[1].AsDword) is TArtefactTranclucator) then
      Exit;
    Item := TArtefactTranclucator(av[1].AsDword);
  end;
  if GetPlayer <> nil then
  begin
    Ship := Item.Ship as TTranclucator;
    av[0].AsDword := PtrUInt(Ship);
    if GetPlayer.InNormalSpace then
    begin
      SoundManager.PlaySound('Sound.UseATranc');
      Item.Ship := nil;
      Ship.CurrentStar := GetPlayer.CurrentStar;
      GetPlayer.CurrentStar.Ships.Add(Ship);
      Angle :=
          SeededRandomIntRange(0, 360, Cardinal(Ship.Id) * (Cardinal(Galaxy.CurrentTurn) * GetPlayer.CurrentStar.GenerationSeed))
              * Pi
              / 180;
      Ship.Position.X := GetPlayer.Position.X + Sin(Angle) * 100;
      Ship.Position.Y := GetPlayer.Position.Y - Cos(Angle) * 100;
      Ship.Graphic.SetPosition(Ship.Position);
      Ship.OwnerShip := GetPlayer;
      Index := GetPlayer.Artefacts.IndexOf(Item);
      if Index >= 0 then
        GetPlayer.Artefacts.Delete(Index);
      Index := GetPlayer.Inventory.IndexOf(Item);
      if Index >= 0 then
        GetPlayer.Inventory.Delete(Index);
      Item.Free;
      if ScriptUseItem = Item then
        ScriptUseItem := nil;
      GetPlayer.RefreshDerivedStats(True);
      Ship.NextDay;
      GetPlayer.AchievementStats.CheckTranclucatorFleetAchievement;
      Star := GetPlayer.CurrentStar;
      if GetPlayer.ChameleonActive then
        for Index := 0 to Star.Ships.Count - 1 do
        begin
          Other := Star.Ships[Index];
          if (Other is TKling) and not TShip(Other).HasIndependentScriptFaction then
            TKling(Other).DetectAttackingPlayer(GetPlayer);
        end;
    end
    else if ShipScreen.TryDeployTranclucator(Ship) then
    begin
      Item.Ship := nil;
      Index := GetPlayer.Artefacts.IndexOf(Item);
      if Index >= 0 then
        GetPlayer.Artefacts.Delete(Index);
      Index := GetPlayer.Inventory.IndexOf(Item);
      if Index >= 0 then
        GetPlayer.Inventory.Delete(Index);
      for Index := 0 to GetPlayer.StorageEntries.Count - 1 do
      begin
        Entry := GetPlayer.StorageEntries[Index];
        if Entry.Item = Item then
        begin
          GetPlayer.StorageEntries.Delete(Index);
          GetPlayer.RefreshStorageBubbles;
          Dispose(Entry);
          Break;
        end;
      end;
      Item.Free;
      if ScriptUseItem = Item then
        ScriptUseItem := nil;
      GetPlayer.RefreshDerivedStats(True);
      SoundManager.PlaySound('Sound.UseATranc');
      ShowMessageBoxGI(ShipScreen, LocalizedColorText('FormShip.UseTranclucator'), mbgOK or mbgUnused04);
    end
    else
    begin
      SoundManager.PlaySound('Sound.NoMoney');
      ShowMessageBoxGI(ShipScreen, LocalizedColorText('FormShip.NotUseTranclucator'), mbgCancel or mbgUnused04);
    end;
  end;
end;

procedure SF_OnUseCodeTransmitter(av: array of TVarEC; code: TCodeEC);
var
  Artefact: TArtefactTransmitter;
  ShowFeedback: Boolean;
begin
  if (ScriptUseItem <> nil) and (ScriptUseItem is TArtefactTransmitter) then
    Artefact := TArtefactTransmitter(ScriptUseItem)
  else
  begin
    if (High(av) < 1) or (av[1].AsDword = 0) or not (TObject(av[1].AsDword) is TArtefactTransmitter) then
      Exit;
    Artefact := TArtefactTransmitter(av[1].AsDword);
  end;
  if High(av) > 1 then
    ShowFeedback := av[2].AsInteger <> 0
  else
    ShowFeedback := True;
  if not (GetPlayer.InNormalSpace or not ShowFeedback) then
  begin
    SoundManager.PlaySound('Sound.NoMoney');
    ShowMessageBoxGI(ShipScreen, LocalizedColorText('FormShip.UseOnlyInSpace'), mbgCancel or mbgUnused04);
  end
  else if GetPlayer.UseDominatorTransmitter(Artefact) then
  begin
    if ShowFeedback then
    begin
      SoundManager.PlaySound('Sound.UseATranc');
      ShowMessageBoxGI(
          ShipScreen,
          FormatText1(LocalizedColorText('FormShip.UseTransmitter'), TextHighlightColorTag, '<Star>', GetPlayer.CurrentStar.Name),
          mbgCancel or mbgUnused04
      );
    end;
  end
  else if ShowFeedback then
  begin
    SoundManager.PlaySound('Sound.NoMoney');
    // The native failure message reads ScriptUseItem even when an explicit artefact was supplied.
    ShowMessageBoxGI(
        ShipScreen,
        FormatText1(
            LocalizedColorText('FormShip.NotUseTransmitter'),
            TextHighlightColorTag,
            '<Count>',
            WideString(IntToStr(MinTransmitterPower - (ScriptUseItem as TArtefactTransmitter).Power))
        ),
        mbgCancel or mbgUnused04
    );
  end;
end;

procedure SF_OnUseCodeBlackHole(av: array of TVarEC; code: TCodeEC);
var
  Item: TArtefact;
  Index: Integer;
  Angle, Distance: Single;
  Hole: THole;
  Event: TGalaxyEvent;
begin
  av[0].AsDword := 0;
  if (ScriptUseItem <> nil) and (ScriptUseItem is TArtefact) then
    Item := TArtefact(ScriptUseItem)
  else
  begin
    if High(av) < 1 then
      Exit;
    if av[1].AsDword = 0 then
      Exit;
    if not (TObject(av[1].AsDword) is TArtefact) then
      Exit;
    Item := TArtefact(av[1].AsDword);
  end;
  if GetPlayer <> nil then
  begin
    if not GetPlayer.InNormalSpace then
    begin
      SoundManager.PlaySound('Sound.NoMoney');
      ShowMessageBoxGI(ShipScreen, LocalizedColorText('FormShip.UseOnlyInSpace'), mbgCancel or mbgUnused04);
    end
    else
    begin
      Index := GetPlayer.Artefacts.IndexOf(Item);
      if Index >= 0 then
        GetPlayer.Artefacts.Delete(Index);
      Index := GetPlayer.Inventory.IndexOf(Item);
      if Index >= 0 then
        GetPlayer.Inventory.Delete(Index);
      Item.Free;
      if ScriptUseItem = Item then
        ScriptUseItem := nil;
      GetPlayer.RefreshDerivedStats(True);
      Hole := THole.Create;
      av[0].AsDword := PtrUInt(Hole);
      Hole.InitializeGraphic('');
      THoleSE(Hole.Graphic).SetState(1);
      Hole.Star1 := GetPlayer.CurrentStar;
      Angle := ArcTan2(GetPlayer.Position.X, -GetPlayer.Position.Y);
      Distance := Max(GetPlayer.CurrentStar.SafeRadius + 100, Sqrt(PointDistanceSquared(GetPlayer.Position, MakePointF(0, 0))) + 200);
      Hole.Position1 := MakePointF(Sin(Angle) * Distance, -Cos(Angle) * Distance);
      Hole.Star2 := nil;
      for Index := 0 to Galaxy.Stars.Count - 1 do
        if TStar(Galaxy.Stars[Index]).IsConstellationVisible then
        begin
          Distance := PointDistanceSquared(GetPlayer.CurrentStar.Position, TStar(Galaxy.Stars[Index]).Position);
          if (Distance > 400) and (Distance < 2500) then
            if (Hole.Star2 = nil) or (NextRandomIntRange(0, 100, GetPlayer.RandomState) < 50) then
            begin
              Hole.Star2 := TStar(Galaxy.Stars[Index]);
              if NextRandomIntRange(0, 100, GetPlayer.RandomState) < 20 then
                Break;
            end;
        end;
      if Hole.Star2 = nil then
        Hole.Star2 := GetPlayer.CurrentStar;
      Angle := HeadingDegreesToRadians(SeededRandomIntRange(0, 359, Galaxy.RandomState));
      Distance := SeededRandomIntRange(1000, 2000, Galaxy.RandomState);
      Hole.Position2 := MakePointF(Sin(Angle) * Distance, -Cos(Angle) * Distance);
      Hole.CreatedTurn := Galaxy.CurrentTurn;
      Hole.HoleType := 1;
      StarMapScreen.PendingHoleRefresh := Hole;
      Galaxy.Holes.Add(Hole);
      Event := AddGalaxyEvent('PlayerUsesSubportal');
      Event.AddData(Hole.Id);
      Event.AddData(Hole.CreatedTurn);
      Galaxy.PrimeIntegrityChecksum1(523);
      ShipScreen.CloseClicked(nil);
    end;
  end;
end;

procedure SF_OnUseCodeMissileDef(av: array of TVarEC; code: TCodeEC);
var
  I: Integer;
begin
  if GetPlayer = nil then
    Exit;
  if not GetPlayer.InNormalSpace then
  begin
    SoundManager.PlaySound('Sound.NoMoney');
    ShowMessageBoxGI(ShipScreen, LocalizedColorText('FormShip.UseOnlyInSpace'), mbgCancel or mbgUnused04);
  end
  else
  begin
    for I := 0 to GetPlayer.CurrentStar.Missiles.Count - 1 do
      with TMissile(GetPlayer.CurrentStar.Missiles[I]) do
        if GetPlayer = OwnerShip then
          FlightTicks := 10000;
    ShowMessageBoxGI(ShipScreen, LocalizedColorText('FormShip.UseMissileDef'), mbgCancel or mbgUnused04);
  end;
end;

procedure SF_MessageBox(av: array of TVarEC; code: TCodeEC);
var
  Options: Cardinal;
  OffsetX, OffsetY: Integer;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script MessageBox');
  if High(av) < 2 then
    Options := mbgCancel or mbgUnused04
  else
    Options := av[2].AsInteger;
  if High(av) < 3 then
    OffsetX := 0
  else
    OffsetX := av[3].AsInteger;
  if High(av) < 4 then
    OffsetY := 0
  else
    OffsetY := av[4].AsInteger;
  ShowMessageBoxGI(GetInnermostScreenLoop, av[1].AsString, Options, 0, OffsetX, OffsetY);
end;

procedure SF_MessageBoxYesNo(av: array of TVarEC; code: TCodeEC);
var
  Options: Cardinal;
  OffsetX, OffsetY: Integer;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script MessageBoxYesNo');
  if High(av) < 2 then
    Options := mbgOK or mbgCancel or mbgQuestion
  else
    Options := av[2].AsInteger or mbgOK or mbgCancel;
  if High(av) < 3 then
    OffsetX := 0
  else
    OffsetX := av[3].AsInteger;
  if High(av) < 4 then
    OffsetY := 0
  else
    OffsetY := av[4].AsInteger;
  av[0].AsInteger := 0;
  if ShowMessageBoxGI(GetInnermostScreenLoop, av[1].AsString, Options, 0, OffsetX, OffsetY) = mbgResultOK then
    av[0].AsInteger := 1;
end;

procedure SF_CountBox(av: array of TVarEC; code: TCodeEC);
var
  Value: Integer;
  Minimum, Maximum, Limit, UnitValue, Available, TotalLimit: Integer;
begin
  if High(av) < 4 then
    raise Exception.Create('Error.Script CountBox');
  // The native routine reads these strings here, then reads them again for the dialog call.
  av[1].AsString;
  av[2].AsString;
  Minimum := av[3].AsInteger;
  Maximum := av[4].AsInteger;
  if High(av) > 4 then
    UnitValue := av[5].AsInteger
  else
    UnitValue := 0;
  if High(av) > 6 then
    Limit := av[7].AsInteger
  else
    Limit := Maximum;
  if High(av) > 7 then
    Available := av[8].AsInteger
  else
    Available := Maximum;
  if High(av) > 8 then
    TotalLimit := av[9].AsInteger
  else
    TotalLimit := 100000000;
  if High(av) > 9 then
    Value := av[10].AsInteger
  else
    Value := Minimum;
  if ShowCountDialog(
          GetInnermostScreenLoop,
          'GI,' + av[1].AsString,
          av[2].AsString,
          Minimum,
          Maximum,
          Limit,
          UnitValue,
          Available,
          TotalLimit,
          Value)
      = 1 then
    av[0].AsInteger := Value
  else
    av[0].AsString := 'Cancel';
end;

procedure SF_NumberBox(av: array of TVarEC; code: TCodeEC);
var
  Value, Index: Integer;
  Caption, AlternateCaption, Description: WideString;
  Minimum, Maximum, Limit: Integer;
  Choices: TList;
  Entry: PWideString;
begin
  if High(av) < 4 then
    raise Exception.Create('Error.Script NumberBox');
  Caption := 'GI,' + av[1].AsString;
  Description := av[2].AsString;
  Minimum := av[3].AsInteger;
  Maximum := av[4].AsInteger;
  if High(av) > 4 then
    Limit := av[5].AsInteger
  else
    Limit := Maximum;
  if (High(av) > 5) and (av[6].AsString <> '') then
    AlternateCaption := 'GI,' + av[6].AsString
  else
    AlternateCaption := '';
  if High(av) > 6 then
    Value := av[7].AsInteger
  else
    Value := Minimum;
  Choices := nil;
  if High(av) > 7 then
  begin
    Choices := TList.Create;
    if av[8].ValueKind = vkArray then
      for Index := 0 to av[8].AsArray.Count - 1 do
      begin
        New(Entry);
        Entry^ := av[8].AsArray[Index].AsString;
        Choices.Add(Entry);
      end
    else
      for Index := 8 to High(av) do
      begin
        New(Entry);
        Entry^ := av[Index].AsString;
        Choices.Add(Entry);
      end;
  end;
  if ShowNumberDialog(GetInnermostScreenLoop, Caption, AlternateCaption, Description, Minimum, Maximum, Limit, Choices, Value) = 1 then
    av[0].AsInteger := Value
  else
    av[0].AsString := 'Cancel';
  if Choices = nil then
    Exit;
  while Choices.Count > 0 do
  begin
    // Native frees the pointer cell without finalizing its WideString.
    Dispose(Choices[0]);
    Choices.Delete(0);
  end;
  Choices.Free;
end;

procedure SF_TextBox(av: array of TVarEC; code: TCodeEC);
var
  Caption, Value: WideString;
  MaximumLength, OffsetX, OffsetY: Integer;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script TextBox');
  Caption := av[1].AsString;
  Value := '';
  if High(av) > 1 then
    Value := av[2].AsString;
  MaximumLength := 30;
  if High(av) > 2 then
    MaximumLength := av[3].AsInteger;
  if High(av) < 4 then
    OffsetX := 0
  else
    OffsetX := av[4].AsInteger;
  if High(av) < 5 then
    OffsetY := 0
  else
    OffsetY := av[5].AsInteger;
  av[0].AsString := Value;
  if ShowTextInputDialog(GetInnermostScreenLoop, Caption, Value, MaximumLength, OffsetX, OffsetY) = 1 then
    av[0].AsString := Value;
end;

procedure SF_ListBox(av: array of TVarEC; code: TCodeEC);
var
  Caption: WideString;
  Choices: TList;
  Index, OffsetX, OffsetY: Integer;
  Entry: PWideString;
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script ListBox');
  Caption := av[1].AsString;
  Choices := TList.Create;
  Index := -1;
  if av[2].ValueKind = vkArray then
    for Index := 0 to av[2].AsArray.Count - 1 do
    begin
      New(Entry);
      Entry^ := av[2].AsArray[Index].AsString;
      Choices.Add(Entry);
    end
  else
    for Index := 2 to High(av) do
    begin
      New(Entry);
      Entry^ := av[Index].AsString;
      Choices.Add(Entry);
    end;
  // The original scalar form also treats these argument positions as choices.
  if High(av) < 3 then
    OffsetX := 0
  else
    OffsetX := av[3].AsInteger;
  if High(av) < 4 then
    OffsetY := 0
  else
    OffsetY := av[4].AsInteger;
  if ShowListDialog(GetInnermostScreenLoop, Index, Caption, Choices, OffsetX, OffsetY) = 1 then
    av[0].AsInteger := Index
  else
    av[0].AsInteger := -1;
  while Choices.Count > 0 do
  begin
    // Native frees the pointer cell without finalizing its WideString.
    Dispose(Choices[0]);
    Choices.Delete(0);
  end;
  Choices.Free;
end;

procedure SF_FormCurShip(av: array of TVarEC; code: TCodeEC);
begin
  if GetInnermostScreenLoop = HangarScreen then
    av[0].AsDword := PtrUInt(HangarScreen.SelectedShip)
  else if GetInnermostScreenLoop = ScannerScreen then
    av[0].AsDword := PtrUInt(ScannerScreen.ShipToInspect)
  else if GetInnermostScreenLoop = ShipScreen then
    av[0].AsDword := PtrUInt(PlayerHoldShip)
  else
    av[0].AsDword := 0;
end;

procedure SF_UselessItemText(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Item: TItem;
  Text: WideString;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script UselessItemText');
  Obj := TObject(av[1].AsDword);
  Item := nil;
  Text := '';
  if Obj is TItem then
    Item := TItem(Obj);
  if Obj is TScriptItem then
    Item := TScriptItem(Obj).Item;
  if (Item <> nil) and (Item is TUselessItem) then
  begin
    Text := (Item as TUselessItem).CustomText;
    if High(av) > 1 then
      (Item as TUselessItem).CustomText := av[2].AsString;
  end;
  av[0].AsString := Text;
end;

procedure SF_UselessItemData(av: array of TVarEC; code: TCodeEC);
var
  Obj: TObject;
  Item: TItem;
  Value, Index: Integer;
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script UselessItemData');
  Obj := TObject(av[1].AsDword);
  Index := av[2].AsInteger;
  Item := nil;
  Value := 0;
  if Obj is TItem then
    Item := TItem(Obj);
  if Obj is TScriptItem then
    Item := TScriptItem(Obj).Item;
  if (Item <> nil) and (Item is TUselessItem) and (Index > 0) and (Index <= 3) then
  begin
    Value := (Item as TUselessItem).Data[Index - 1];
    if High(av) > 2 then
      (Item as TUselessItem).Data[Index - 1] := av[3].AsInteger;
  end;
  av[0].AsInteger := Value;
end;

procedure SF_GetAchievementSHU(av: array of TVarEC; code: TCodeEC);
begin
  TryUnlockAchievement('SHU');
end;

procedure SF_GetAchievementGIRLSHIRE(av: array of TVarEC; code: TCodeEC);
begin
  TryUnlockAchievement('GIRLSHIRE');
end;

procedure SF_GetAchievementGIRLSQUEST(av: array of TVarEC; code: TCodeEC);
begin
  TryUnlockAchievement('GIRLSQUEST');
end;

procedure SF_GetAchievementPIRATEWIN(av: array of TVarEC; code: TCodeEC);
begin
  TryUnlockAchievement('PIRATEWIN');
end;

procedure SF_GetAchievementCOALLITION(av: array of TVarEC; code: TCodeEC);
begin
  TryUnlockAchievement('COALLITION');
end;

procedure SF_GetAchievementHULL(av: array of TVarEC; code: TCodeEC);
begin
  TryUnlockAchievement('HULL');
end;

procedure SF_UICheckElement(av: array of TVarEC; code: TCodeEC);
var
  FormName, Path, Query: WideString;
  Form: TMessageLoopGI;
  Control: TObjectGI;
begin
  if High(av) < 3 then
    raise Exception.Create('Error.Script UICheckElement');
  FormName := av[1].AsString;
  Path := av[2].AsString;
  Control := nil;
  if FormName = '' then
    Form := GetInnermostScreenLoop
  else
    Form := FindMessageLoop(FormName);
  if Form <> nil then
    Control := Form.FindControlByPath(Path);
  if Control = nil then
    raise Exception.Create('Error.Script UICheckElement - cant find ' + Path + ' (' + FormName + ')');
  Query := av[3].AsString;
  if Query = 'IsActive' then
    av[0].AsInteger := Ord(Control.Active)
  else if Query = 'PosX' then
    av[0].AsInteger := Control.LocalPosition.X
  else if Query = 'PosY' then
    av[0].AsInteger := Control.LocalPosition.Y
  else if Query = 'SizeX' then
    av[0].AsInteger := Control.ClientSize.X
  else if Query = 'SizeY' then
    av[0].AsInteger := Control.ClientSize.Y
  else if Query = 'IsDisable' then
  begin
    if not (Control is TGraphButtonGI) then
      raise Exception.Create('Error.Script UICheckElement - ' + Path + ' (' + FormName + ') is not a button');
    av[0].AsInteger := Ord(TGraphButtonGI(Control).Disabled);
  end
  else if Query = 'Text' then
  begin
    if Control is TEditGI then
    begin
      av[0].AsString := TEditGI(Control).Text;
      if High(av) > 3 then
        TEditGI(Control).SetText(av[4].AsString);
    end
    else if Control is TLabelGI then
      av[0].AsString := TLabelGI(Control).GetText
    else
      raise Exception.Create('Error.Script UICheckElement - ' + Path + ' (' + FormName + ') is not a label or edit');
  end
  else if Query = 'Help' then
  begin
    av[0].AsString := Control.HelpText;
    if High(av) > 3 then
      Control.HelpText := av[4].AsString;
  end
  else if Query = 'CursorPos' then
  begin
    if Control is TEditGI then
    begin
      av[0].AsInteger := TEditGI(Control).CaretPosition;
      if High(av) > 3 then
        TEditGI(Control).SetCaretPosition(av[4].AsInteger);
    end
    else
      raise Exception.Create('Error.Script UICheckElement - ' + Path + ' (' + FormName + ') is not an edit');
  end
  else if Query = 'IsFocused' then
    av[0].AsInteger := Ord(Form.FocusedControl = Control)
  else if Query = 'Image' then
  begin
    if Control is TgaiGI then
    begin
      av[0].AsString := TgaiGI(Control).GetImagePath;
      if TgaiGI(Control).GetFirstFrameImagePath <> '' then
        av[0].AsString := av[0].AsString + '|' + TgaiGI(Control).GetFirstFrameImagePath;
    end
    else if Control is TgiGI then
      av[0].AsString := TgiGI(Control).GetImagePath
    else if Control is TImageGI then
      av[0].AsString := TImageGI(Control).GetImagePath
    else
      raise Exception.Create('Error.Script UICheckElement - ' + Path + ' (' + FormName + ') is not a image');
  end
  else if Query = 'CurFrame' then
  begin
    if not (Control is TgaiGI) then
      raise Exception.Create('Error.Script UICheckElement - ' + Path + ' (' + FormName + ') is not a gai');
    av[0].AsInteger := TgaiGI(Control).SequenceFrame;
    if High(av) > 3 then
      TgaiGI(Control).SetSequenceFrame(av[4].AsInteger);
  end
  else if Query = 'IsDown' then
  begin
    if Control is TGraphButtonGI then
    begin
      av[0].AsInteger := Ord(TGraphButtonGI(Control).Down);
      if High(av) > 3 then
        TGraphButtonGI(Control).SetDown(av[4].AsInteger <> 0);
    end
    else
      raise Exception.Create('Error.Script UICheckElement - ' + Path + ' (' + FormName + ') is not a button');
  end
  else if Query = 'Rescale' then
  begin
    if Control is TGraphBufGI then
    begin
      if High(av) < 4 then
        raise Exception.Create('Error.Script UICheckElement - Rescale option can not be used without image path');
      if (High(av) > 4) and (av[5].AsString = 'GI') then
        TGraphBufGI(Control).LoadScaledGiPath(av[4].AsString)
      else
        TGraphBufGI(Control).LoadScaledBitmapPathAsRgba(av[4].AsString);
    end
    else
      raise Exception.Create('Error.Script UICheckElement - ' + Path + ' (' + FormName + ') is not a graph buffer');
  end
  else
    raise Exception.Create('Error.Script UICheckElement - query not recognized - ' + Query);
end;

procedure SF_InterfaceState(av: array of TVarEC; code: TCodeEC);
var
  FormName, Path: WideString;
  I: Integer;
  Entry: TInterfaceStateOverride;
  Form: TMessageLoopGI;
  Control: TObjectGI;
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script InterfaceState');
  FormName := av[1].AsString;
  Path := av[2].AsString;
  if Galaxy = nil then
  begin
    Form := FindMessageLoop(FormName);
    if Form = nil then
      raise Exception.Create('ML not found - ' + FormName);
    Control := Form.FindControlByPath(Path);
    if Control = nil then
      AppendLogLineThreadSafe(AnsiString('Object not found - ' + Path))
    else
    begin
      av[0].AsInteger := Ord(Control.Active);
      if (Control is TGraphButtonGI) and TGraphButtonGI(Control).Disabled and Control.Active then
        av[0].AsInteger := 2;
      if High(av) > 2 then
      begin
        Control.SetActive(av[3].AsInteger > 0);
        if (av[3].AsInteger > 1) and (Control is TGraphButtonGI) then
          TGraphButtonGI(Control).SetDisabled(av[3].AsInteger = 2);
      end;
    end;
    Exit;
  end;
  for I := 0 to Galaxy.InterfaceStateOverrides.Count - 1 do
  begin
    Entry := Galaxy.InterfaceStateOverrides[I];
    if (Entry.FormName <> FormName) or (Entry.ControlPath <> Path) then
      Continue;
    av[0].AsInteger := Entry.GetState;
    if High(av) > 2 then
    begin
      if av[3].AsInteger < 0 then
      begin
        Galaxy.InterfaceStateOverrides.Delete(I);
        Entry.Free;
      end
      else
        Entry.SetState(av[3].AsInteger);
    end;
    Exit;
  end;
  av[0].AsInteger := -1;
  if (High(av) <= 2) or (av[3].AsInteger < 0) then
    Exit;
  Entry := TInterfaceStateOverride.Create;
  Galaxy.InterfaceStateOverrides.Add(Entry);
  Entry.Initialize(FormName, Path, av[3].AsInteger);
end;

procedure SF_InterfaceText(av: array of TVarEC; code: TCodeEC);
var
  FormName, Path: WideString;
  I: Integer;
  Entry: TInterfaceTextOverride;
  Form: TMessageLoopGI;
  Control: TObjectGI;
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script InterfaceText');
  FormName := av[1].AsString;
  Path := av[2].AsString;
  if Galaxy = nil then
  begin
    Form := FindMessageLoop(FormName);
    if Form = nil then
      raise Exception.Create('ML not found - ' + FormName);
    Control := Form.FindControlByPath(Path);
    if Control = nil then
      AppendLogLineThreadSafe(AnsiString('Object not found - ' + Path))
    else
    begin
      if not (Control is TLabelGI) then
        raise Exception.Create('Object is not a label - ' + Path);
      av[0].AsString := TLabelGI(Control).GetText;
      if High(av) > 2 then
        TLabelGI(Control).SetText(av[3].AsString);
    end;
    Exit;
  end;
  for I := 0 to Galaxy.InterfaceTextOverrides.Count - 1 do
  begin
    Entry := Galaxy.InterfaceTextOverrides[I];
    if (Entry.FormName <> FormName) or (Entry.ControlPath <> Path) then
      Continue;
    av[0].AsString := Entry.GetText;
    if High(av) > 2 then
    begin
      if av[3].AsString = '' then
      begin
        Galaxy.InterfaceTextOverrides.Delete(I);
        Entry.Free;
      end
      else
        Entry.SetText(av[3].AsString);
    end;
    Exit;
  end;
  av[0].AsString := '';
  if (High(av) <= 2) or (av[3].AsString = '') then
    Exit;
  Entry := TInterfaceTextOverride.Create;
  Galaxy.InterfaceTextOverrides.Add(Entry);
  Entry.Initialize(FormName, Path, av[3].AsString);
end;

procedure SF_InterfaceImage(av: array of TVarEC; code: TCodeEC);
var
  FormName, Path: WideString;
  I: Integer;
  Entry: TInterfaceImageOverride;
  Form: TMessageLoopGI;
  Control: TObjectGI;
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script InterfaceImage');
  FormName := av[1].AsString;
  Path := av[2].AsString;
  if Galaxy = nil then
  begin
    Form := FindMessageLoop(FormName);
    if Form = nil then
      raise Exception.Create('ML not found - ' + FormName);
    Control := Form.FindControlByPath(Path);
    if Control = nil then
      AppendLogLineThreadSafe(AnsiString('Object not found - ' + Path))
    else
    begin
      if Control is TgaiGI then
      begin
        av[0].AsString := TgaiGI(Control).GetImagePath;
        if TgaiGI(Control).GetFirstFrameImagePath <> '' then
          av[0].AsString := av[0].AsString + '|' + TgaiGI(Control).GetFirstFrameImagePath;
      end
      else if Control is TgiGI then
        av[0].AsString := TgiGI(Control).GetImagePath
      else if Control is TImageGI then
        av[0].AsString := TImageGI(Control).GetImagePath
      else
        av[0].AsString := Control.ConfigPath;
      if High(av) > 2 then
      begin
        if (CountDelimitedPartsW(av[3].AsString, ':') > 1) and (ExtractDelimitedPartW(av[3].AsString, 0, ':') = 'Style') then
          Control.SetConfigPath(ExtractDelimitedPartW(av[3].AsString, 1, ':'))
        else if Control is TgaiGI then
        begin
          if CountDelimitedPartsW(av[3].AsString, '|') < 2 then
            TgaiGI(Control).SetImagePath(av[3].AsString)
          else
          begin
            TgaiGI(Control).SetFirstFrameImagePath(ExtractDelimitedPartW(av[3].AsString, 1, '|'));
            TgaiGI(Control).SetImagePath(ExtractDelimitedPartW(av[3].AsString, 0, '|'));
          end;
          TgaiGI(Control).PrimeImageCaches;
          TgaiGI(Control).SequenceIndex := 0;
          TgaiGI(Control).UpdateAutoGeometry;
          TgaiGI(Control).RestartPlayback;
        end
        else if Control is TgiGI then
          TgiGI(Control).SetImagePath(av[3].AsString)
        else if Control is TImageGI then
          TImageGI(Control).SetImagePath(av[3].AsString)
        else
          raise Exception.Create('Object is not an image - ' + Path);
      end;
    end;
    Exit;
  end;
  for I := 0 to Galaxy.InterfaceImageOverrides.Count - 1 do
  begin
    Entry := Galaxy.InterfaceImageOverrides[I];
    if (Entry.FormName <> FormName) or (Entry.ControlPath <> Path) then
      Continue;
    av[0].AsString := Entry.GetImagePath;
    if High(av) > 2 then
    begin
      if av[3].AsString = '' then
      begin
        Galaxy.InterfaceImageOverrides.Delete(I);
        Entry.Free;
      end
      else
        Entry.SetImagePath(av[3].AsString);
    end;
    Exit;
  end;
  av[0].AsString := '';
  if (High(av) <= 2) or (av[3].AsString = '') then
    Exit;
  Entry := TInterfaceImageOverride.Create;
  Galaxy.InterfaceImageOverrides.Add(Entry);
  Entry.Initialize(FormName, Path, av[3].AsString);
end;

procedure SF_InterfacePos(av: array of TVarEC; code: TCodeEC);
var
  FormName, Path: WideString;
  I: Integer;
  X, Y, Z: Integer;
  Entry: TInterfacePosOverride;
  Form: TMessageLoopGI;
  Control: TObjectGI;
begin
  if High(av) < 5 then
    raise Exception.Create('Error.Script InterfacePos');
  FormName := av[1].AsString;
  Path := av[2].AsString;
  X := av[3].AsInteger;
  Y := av[4].AsInteger;
  Z := av[5].AsInteger;
  if Galaxy = nil then
  begin
    Form := FindMessageLoop(FormName);
    if Form = nil then
      raise Exception.Create('ML not found - ' + FormName);
    Control := Form.FindControlByPath(Path);
    if Control = nil then
      AppendLogLineThreadSafe(AnsiString('Object not found - ' + Path))
    else
    begin
      Control.SetPosition(Point(X, Y));
      Control.SetDepth(Z);
    end;
    Exit;
  end;
  for I := 0 to Galaxy.InterfacePositionOverrides.Count - 1 do
  begin
    Entry := Galaxy.InterfacePositionOverrides[I];
    if (Entry.FormName <> FormName) or (Entry.ControlPath <> Path) then
      Continue;
    if (X = 0) and (Y = 0) and (Z = 0) then
    begin
      Galaxy.InterfacePositionOverrides.Delete(I);
      Entry.Free;
    end
    else
      Entry.SetPosition(X, Y, Z);
    Exit;
  end;
  if (X = 0) and (Y = 0) and (Z = 0) then
    Exit;
  Entry := TInterfacePosOverride.Create;
  Galaxy.InterfacePositionOverrides.Add(Entry);
  Entry.Initialize(FormName, Path, X, Y, Z);
end;

procedure SF_InterfaceSize(av: array of TVarEC; code: TCodeEC);
var
  FormName, Path: WideString;
  I: Integer;
  X, Y: Integer;
  Entry: TInterfaceSizeOverride;
  Form: TMessageLoopGI;
  Control: TObjectGI;
begin
  if High(av) < 4 then
    raise Exception.Create('Error.Script InterfaceSize');
  FormName := av[1].AsString;
  Path := av[2].AsString;
  X := av[3].AsInteger;
  Y := av[4].AsInteger;
  if Galaxy = nil then
  begin
    Form := FindMessageLoop(FormName);
    if Form = nil then
      raise Exception.Create('ML not found - ' + FormName);
    Control := Form.FindControlByPath(Path);
    if Control = nil then
      AppendLogLineThreadSafe(AnsiString('Object not found - ' + Path))
    else
    begin
      Control.SetSize(Point(X, Y));
    end;
    Exit;
  end;
  for I := 0 to Galaxy.InterfaceSizeOverrides.Count - 1 do
  begin
    Entry := Galaxy.InterfaceSizeOverrides[I];
    if (Entry.FormName <> FormName) or (Entry.ControlPath <> Path) then
      Continue;
    if (X = 0) and (Y = 0) then
    begin
      Galaxy.InterfaceSizeOverrides.Delete(I);
      Entry.Free;
    end
    else
      Entry.SetSize(X, Y);
    Exit;
  end;
  if (X = 0) and (Y = 0) then
    Exit;
  Entry := TInterfaceSizeOverride.Create;
  Galaxy.InterfaceSizeOverrides.Add(Entry);
  Entry.Initialize(FormName, Path, X, Y);
end;

procedure SF_ButtonClick(av: array of TVarEC; code: TCodeEC);
var
  FormName, Path: WideString;
  Control: TObjectGI;
  Form: TMessageLoopGI;
  Button: TGraphButtonGI;
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script ButtonClick');
  FormName := av[1].AsString;
  Path := av[2].AsString;
  if FormName = '' then
    Form := GetInnermostScreenLoop
  else
    Form := FindMessageLoop(FormName);
  if Form = nil then
    raise Exception.Create('Error.Script ButtonClick - ML not found');
  Control := Form.FindControlByPath(Path);
  if Control = nil then
    raise Exception.Create('Error.Script ButtonClick - Object not found');
  if not (Control is TGraphButtonGI) then
    raise Exception.Create('Error.Script ButtonClick - Object not a button');
  Button := Control as TGraphButtonGI;
  if (High(av) < 3) or (av[3].ValueKind <> vkString) or (av[3].AsString = 'AllCode') then
  begin
    if Assigned(Button.UpCallback) then
      Button.UpCallback(Button)
    else if Assigned(Button.DownCallback) then
      Button.DownCallback(Button);
  end;
  if (High(av) > 2) and ((av[3].AsString = 'ScriptCode') or (av[3].AsString = 'AllCode')) then
    if Button.OnPressCode <> nil then
    begin
      Form.ExecuteUiCode(Button.OnPressCode, 0);
      Form.RefreshMouseDispatch;
    end;
end;

procedure SF_SetFocus(av: array of TVarEC; code: TCodeEC);
var
  FormName, Path: WideString;
  Control: TObjectGI;
  Form: TMessageLoopGI;
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script SetFocus');
  FormName := av[1].AsString;
  Path := av[2].AsString;
  if FormName = '' then
    Form := GetInnermostScreenLoop
  else
    Form := FindMessageLoop(FormName);
  if Form = nil then
    raise Exception.Create('Error.Script SetFocus - ML not found');
  Control := Form.FindControlByPath(Path);
  if Control = nil then
    raise Exception.Create('Error.Script SetFocus - Object not found');
  Form.SetFocusedControl(Control);
end;

procedure SF_FormShipCurItem(av: array of TVarEC; code: TCodeEC);
var
  Query: Integer;
  Item: TObject;
begin
  if GetInnermostScreenLoop <> ShipScreen then
    raise Exception.Create('Error.Script FormShipCurItem');
  if High(av) < 1 then
  begin
    if not (ShipScreen.SelectedHoldKind in [phkEquipment, phkArtefact]) then
      av[0].AsDword := 0
    else
      av[0].AsDword := PtrUInt(ShipScreen.SelectedHoldItem);
    Exit;
  end;

  if av[1].ValueKind = vkString then
  begin
    if av[1].AsString = 'MoveType' then
      Query := 0
    else if av[1].AsString = 'StackableType' then
      Query := 1
    else if av[1].AsString = 'StackableCount' then
      Query := 2
    else if av[1].AsString = 'StackableCost' then
      Query := 3
    else if av[1].AsString = 'PutBack' then
      Query := 4
    else if av[1].AsString = 'Destroy' then
      Query := 5
    else if av[1].AsString = 'Detach' then
      Query := 6
    else if av[1].AsString = 'Replace' then
      Query := 7
    else
      raise Exception.Create('Error.Script FormShipCurItem - query not recognized: ' + av[1].AsString);
  end
  // The native numeric-query path reads argument 3, without an additional arity check.
  else
    Query := av[3].AsInteger;
  case Query of
    0: av[0].AsInteger := Integer(ShipScreen.SelectedHoldKind);
    1: av[0].AsInteger := ShipScreen.SelectedGoodsIndex;
    2: av[0].AsInteger := ShipScreen.SelectedGoodsQuantity;
    3: av[0].AsInteger := ShipScreen.SelectedGoodsCost;
    4: ShipScreen.ReturnSelectedHoldEntry;
    5:
    begin
      if ShipScreen.SelectedHoldItem <> nil then
        ShipScreen.SelectedHoldItem.Free;
      ShipScreen.SelectedHoldItem := nil;
      ShipScreen.SelectedHoldKind := phkEmpty;
      PlayerHoldShip.RefreshDerivedStats(True);
      if not ShipScreen.IsCursorImageSelected('Main') then
        ShipScreen.SetCursorByName('Main');
      ShipScreen.RefreshShipView;
    end;
    6:
    begin
      av[0].AsDword := PtrUInt(ShipScreen.SelectedHoldItem);
      ShipScreen.SelectedHoldItem := nil;
      ShipScreen.SelectedHoldKind := phkEmpty;
      PlayerHoldShip.RefreshDerivedStats(True);
      if not ShipScreen.IsCursorImageSelected('Main') then
        ShipScreen.SetCursorByName('Main');
      ShipScreen.RefreshShipView;
    end;
    7:
    begin
      if (High(av) < 2) or (av[2].AsDword = 0) then
        raise Exception.Create('Error.Script FormShipCurItem no replacing item');
      if (ShipScreen.SelectedHoldItem = nil) or not (ShipScreen.SelectedHoldKind in [phkEquipment, phkArtefact]) then
        raise Exception.Create('Error.Script FormShipCurItem no item to replace');
      Item := TObject(av[2].AsDword);
      av[0].AsDword := PtrUInt(ShipScreen.SelectedHoldItem);
      ShipScreen.SelectedHoldItem := TItem(Item);
      if Item is TArtefact then
        ShipScreen.SelectedHoldKind := phkArtefact
      else
        ShipScreen.SelectedHoldKind := phkEquipment;
      PlayerHoldShip.RefreshDerivedStats(True);
      ShipScreen.UpdateActionCursor(True);
      ShipScreen.RefreshShipView;
    end;
  else
    // Native creates this exception without raising or freeing it.
    Exception.Create('Error.Script FormShipCurItem - query not recognized: ' + IntToWideString(Query));
  end;
end;

procedure SF_UpdateFormShip(av: array of TVarEC; code: TCodeEC);
begin
  if GetInnermostScreenLoop <> ShipScreen then
    Exit;
  ShipScreen.ShipStateChanged := True;
  ShipScreen.ReopenRequested := True;
  ShipScreen.PlayTransitionSounds := False;
  ShipScreen.CloseClicked(nil);
end;

procedure SF_CurrentForm(av: array of TVarEC; code: TCodeEC);
begin
  av[0].AsString := GetInnermostScreenLoop.RegisteredLoopName;
end;

procedure SF_FormChange(av: array of TVarEC; code: TCodeEC);
var
  Id: TGameScreenId;
  Name: WideString;
begin
  if High(av) < 1 then
  begin
    if RegisteredScreens[RequestedScreenId] = nil then
      av[0].AsString := ''
    else
      av[0].AsString := TMessageLoopGI(RegisteredScreens[RequestedScreenId]).RegisteredLoopName;
    Exit;
  end;

  Name := av[1].AsString;
  for Id := screenNone to screenAchievements do
    if (RegisteredScreens[Id] <> nil)
        and (RegisteredScreens[Id] is TMessageLoopGI)
        and ((RegisteredScreens[Id] as TMessageLoopGI).RegisteredLoopName = Name) then
    begin
      RequestedScreenId := Id;
      if ShipScreen = RegisteredScreens[Id] then
      begin
        if High(av) >= 2 then
          ShipScreen.ShipToInspect := TShip(av[2].AsDword);
        ShipReturnScreenId := CurrentScreenId;
        if (CurrentScreenId = screenStarMap)
            or not (RegisteredScreens[CurrentScreenId] is TMessageLoopGIWithMainPanel)
            or (TMessageLoopGIWithMainPanel(RegisteredScreens[CurrentScreenId]).MainPanel = nil) then
        begin
          ShipReturnScreenId := CurrentScreenId;
          GetInnermostScreenLoop.RequestClose(1);
        end
        else
          TMessageLoopGIWithMainPanel(RegisteredScreens[CurrentScreenId]).MainPanel.ShipClicked(nil);
        Exit;
      end;
      if ScannerScreen = RegisteredScreens[Id] then
      begin
        if High(av) >= 2 then
          ScannerTarget := TObject(av[2].AsDword)
        else
          ScannerTarget := nil;
        ScannerReturnScreenId := FormToId(GetInnermostScreenLoop);
      end;
      GetInnermostScreenLoop.RequestClose(1);
      Exit;
    end;
  raise Exception.Create('Error.Script FormChange - ML not found');
end;

procedure SF_RunChildForm(av: array of TVarEC; code: TCodeEC);
var
  Id: TGameScreenId;
  Name: WideString;
  Parent, Root, Child: TMessageLoopGI;
  Background, ChildBackground: TObjectGI;
  State: TCursorStateGI;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script RunChildForm');
  Name := av[1].AsString;
  for Id := screenNone to screenAchievements do
  begin
    if (RegisteredScreens[Id] = nil)
        or not (RegisteredScreens[Id] is TMessageLoopGI)
        or ((RegisteredScreens[Id] as TMessageLoopGI).RegisteredLoopName <> Name) then
      Continue;
    Child := TMessageLoopGI(RegisteredScreens[Id]);
    Parent := GetInnermostScreenLoop;
    ChildBackground := nil;
    Background := Child.FindControlByPath('BGBuf');
    if Background <> nil then
    begin
      CaptureScreenBackground(True, 0);
      (Background as TGraphBufGI).BindExternalGraphBuf(AuxRenderBuffer);
    end
    else
    begin
      ChildBackground := Child.FindControlByPath('BGBufChild');
      if ChildBackground <> nil then
      begin
        CaptureScreenBackground(True, 0);
        (ChildBackground as TGraphBufGI).BindExternalGraphBuf(AuxRenderBuffer);
        ChildBackground.SetActive(True);
      end;
    end;
    Parent.RootUiObject.OnModalSuspend;
    Parent.CaptureCursorState(@State);
    Parent.SetCursorActive(False);
    Parent.DrawQueuedUpdateRects;
    Child.ParentLoop := Parent;
    Parent.ChildLoop := Child;
    if (Child = GalaxyScreen) and (High(av) >= 2) then
      GalaxyScreen.ViewMode := av[2].AsInteger;
    if Child.Run = 1 then
      av[0].AsInteger := 1
    else
      av[0].AsInteger := 0;
    if ChildBackground <> nil then
      ChildBackground.SetActive(False);
    Child.ParentLoop := nil;
    Parent.ChildLoop := nil;
    if ((Background <> nil) or (ChildBackground <> nil)) and (Parent.ParentLoop <> nil) then
    begin
      Root := Parent.ParentLoop;
      while Root.ParentLoop <> nil do
        Root := Root.ParentLoop;
      FullFrameRedrawRequested := True;
      Root.DrawFrame;
      CaptureScreenBackground(True, 0);
    end;
    Parent.InvalidateViewport;
    Parent.RestoreCursorState(@State);
    Parent.UpdateCursorPosition;
    Parent.RootUiObject.OnModalResume;
    Parent.Present;
    PostMouseMoveMessage;
    Exit;
  end;
  raise Exception.Create('Error.Script RunChildForm - ML not found');
end;

procedure SF_OpenCustomForm(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script OpenCustomForm');
  av[0].AsInteger := ShowCustomDialog(GetInnermostScreenLoop, av[1].AsString);
end;

procedure SF_CloseCustomForm(av: array of TVarEC; code: TCodeEC);
var
  ResultCode: Integer;
begin
  if CurrentCustomDialog = nil then
    raise Exception.Create('Error.Script CloseCustomForm - no custom form');
  if High(av) > 0 then
    ResultCode := av[1].AsInteger
  else
    ResultCode := 1;
  CurrentCustomDialog.RequestClose(ResultCode);
end;

procedure SF_CustomInterfaceState(av: array of TVarEC; code: TCodeEC);
var
  Control: TObjectGI;
  Form: TMessageLoopGI;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script CustomInterfaceState');
  Form := CurrentCustomDialog;
  if Form = nil then
    raise Exception.Create('Error.Script CustomInterfaceState - no custom form');
  Control := Form.FindControlByPath(av[1].AsString);
  if Control = nil then
    raise Exception.Create('Error.Script CustomInterfaceState - object not found');
  av[0].AsInteger := Ord(Control.Active);
  if High(av) > 1 then
    Control.SetActive(av[2].AsInteger > 0);
  if Control is TGraphButtonGI then
  begin
    if Control.Active then
      av[0].AsInteger := Ord(TGraphButtonGI(Control).Disabled) + av[0].AsInteger;
    if High(av) > 1 then
      TGraphButtonGI(Control).SetDisabled(av[2].AsInteger = 2);
  end;
end;

procedure SF_CustomInterfaceText(av: array of TVarEC; code: TCodeEC);
var
  Control: TObjectGI;
  Form: TMessageLoopGI;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script CustomInterfaceText');
  Form := CurrentCustomDialog;
  if Form = nil then
    raise Exception.Create('Error.Script CustomInterfaceText - no custom form');
  Control := Form.FindControlByPath(av[1].AsString);
  if Control = nil then
    raise Exception.Create('Error.Script CustomInterfaceText - object not found: ' + av[1].AsString);
  if Control is TLabelGI then
    av[0].AsString := TLabelGI(Control).GetText
  else if Control is TEditGI then
    av[0].AsString := TEditGI(Control).Text
  else
    raise Exception.Create('Error.Script CustomInterfaceText - object is not a label or edit: ' + av[1].AsString);
  if High(av) > 1 then
  begin
    if Control is TLabelGI then
      TLabelGI(Control).SetText(av[2].AsString)
    else if Control is TEditGI then
      TEditGI(Control).SetText(av[2].AsString);
  end;
end;

procedure SF_CustomInterfaceImage(av: array of TVarEC; code: TCodeEC);
var
  Control: TObjectGI;
  Form: TMessageLoopGI;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script CustomInterfaceImage');
  Form := CurrentCustomDialog;
  if Form = nil then
    raise Exception.Create('Error.Script CustomInterfaceImage - no custom form');
  Control := Form.FindControlByPath(av[1].AsString);
  if Control = nil then
    raise Exception.Create('Error.Script CustomInterfaceImage - object not found: ' + av[1].AsString);
  if Control is TgaiGI then
  begin
    av[0].AsString := TgaiGI(Control).GetImagePath;
    if TgaiGI(Control).GetFirstFrameImagePath <> '' then
      av[0].AsString := av[0].AsString + '|' + TgaiGI(Control).GetFirstFrameImagePath;
  end
  else if Control is TgiGI then
    av[0].AsString := TgiGI(Control).GetImagePath
  else if Control is TImageGI then
    av[0].AsString := TImageGI(Control).GetImagePath
  else
    av[0].AsString := Control.ConfigPath;
  if High(av) <= 1 then
    Exit;
  if (CountDelimitedPartsW(av[2].AsString, ':') > 1) and (ExtractDelimitedPartW(av[2].AsString, 0, ':') = 'Style') then
    Control.SetConfigPath(ExtractDelimitedPartW(av[2].AsString, 1, ':'))
  else if Control is TgaiGI then
  begin
    if CountDelimitedPartsW(av[2].AsString, '|') < 2 then
      TgaiGI(Control).SetImagePath(av[2].AsString)
    else
    begin
      TgaiGI(Control).SetFirstFrameImagePath(ExtractDelimitedPartW(av[2].AsString, 1, '|'));
      TgaiGI(Control).SetImagePath(ExtractDelimitedPartW(av[2].AsString, 0, '|'));
    end;
    TgaiGI(Control).PrimeImageCaches;
    TgaiGI(Control).SequenceIndex := 0;
    TgaiGI(Control).UpdateAutoGeometry;
    TgaiGI(Control).RestartPlayback;
  end
  else if Control is TgiGI then
    TgiGI(Control).SetImagePath(av[2].AsString)
  else if Control is TImageGI then
    TImageGI(Control).SetImagePath(av[2].AsString)
  else
    raise Exception.Create('Error.Script CustomInterfaceImage - object is not a image: ' + av[1].AsString);
end;

procedure SF_CustomInterfacePos(av: array of TVarEC; code: TCodeEC);
var
  Control: TObjectGI;
  Form: TMessageLoopGI;
begin
  if High(av) < 3 then
    raise Exception.Create('Error.Script CustomInterfacePos');
  Form := CurrentCustomDialog;
  if Form = nil then
    raise Exception.Create('Error.Script CustomInterfacePos - no custom form');
  Control := Form.FindControlByPath(av[1].AsString);
  if Control = nil then
    raise Exception.Create('Error.Script CustomInterfacePos - object not found');
  Control.SetPosition(Point(av[2].AsInteger, av[3].AsInteger));
end;

procedure SF_CustomInterfacePosZ(av: array of TVarEC; code: TCodeEC);
var
  Control: TObjectGI;
  Form: TMessageLoopGI;
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script CustomInterfacePosZ');
  Form := CurrentCustomDialog;
  if Form = nil then
    raise Exception.Create('Error.Script CustomInterfacePosZ - no custom form');
  Control := Form.FindControlByPath(av[1].AsString);
  if Control = nil then
    raise Exception.Create('Error.Script CustomInterfacePosZ - object not found');
  Control.SetDepth(av[2].AsInteger);
end;

procedure SF_CustomInterfaceSize(av: array of TVarEC; code: TCodeEC);
var
  Control: TObjectGI;
  Form: TMessageLoopGI;
begin
  if High(av) < 3 then
    raise Exception.Create('Error.Script CustomInterfacePos');
  Form := CurrentCustomDialog;
  if Form = nil then
    raise Exception.Create('Error.Script CustomInterfacePos - no custom form');
  Control := Form.FindControlByPath(av[1].AsString);
  if Control = nil then
    raise Exception.Create('Error.Script CustomInterfacePos - object not found');
  Control.SetSize(Point(av[2].AsInteger, av[3].AsInteger));
end;

procedure SF_StarMapCenterView(av: array of TVarEC; code: TCodeEC);
var
  Position: TPointF;
  Index, Count: Integer;
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script StarMapCenterView');
  Position.X := av[1].AsInteger;
  Position.Y := av[2].AsInteger;
  StarMapScreen.SetMapCenterManually(TruncatePointF(Position));
  SpaceViewPosition := Position;
  if (High(av) < 3) or (RegisteredScreens[CurrentScreenId] <> StarMapScreen) then
    Exit;
  Count := av[3].AsInteger;
  for Index := 0 to Count - 1 do
    StarMapScreen.AddMapAnimation(Position, 'Bm.SI.' + GiResourceSuffix + 'Ring', 200 * Index);
end;

procedure SF_StarMapCurPosX(av: array of TVarEC; code: TCodeEC);
begin
  av[0].AsInteger := StarMapScreen.GetMapCenter.X;
end;

procedure SF_StarMapCurPosY(av: array of TVarEC; code: TCodeEC);
begin
  av[0].AsInteger := StarMapScreen.GetMapCenter.Y;
end;

procedure SF_StarMapCustomSelectionMode(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 10 then
    raise Exception.Create('Error.Script StarMapCustomSelectionMode');
  if GetInnermostScreenLoop <> StarMapScreen then
    Exit;
  if av[1].ValueKind = vkString then
  begin
    StarMapScreen.CustomSelectionInfoName := av[1].AsString;
    StarMapScreen.CustomSelectionItem := nil;
  end
  else
  begin
    StarMapScreen.CustomSelectionInfoName := '';
    StarMapScreen.CustomSelectionItem := TItem(av[1].AsDword);
  end;
  StarMapScreen.CustomSelectionRadius := av[2].AsInteger;
  StarMapScreen.CustomSelectionAllowedCursor := av[3].AsString;
  StarMapScreen.CustomSelectionDeniedCursor := av[4].AsString;
  StarMapScreen.CustomSelectionSuccessText := av[5].AsString;
  StarMapScreen.CustomSelectionOutOfRangeText := av[6].AsString;
  StarMapScreen.CustomSelectionFailureText := av[7].AsString;
  StarMapScreen.CustomSelectionColor := CurrentPixelFormat.PackRgb(av[8].AsInteger, av[9].AsInteger, av[10].AsInteger);
  StarMapScreen.BeginCustomSelection;
end;

procedure SF_StarMapBlinkingMessage(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) <> 1 then
    raise Exception.Create('Error.Script StarMapBlinkingMessage');
  StarMapScreen.ShowLargeHelp(av[1].AsString);
end;

procedure SF_BlinkingWarning(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) <> 1 then
    raise Exception.Create('Error.Script BlinkingWarning');
  if av[1].AsString = 'Money' then
  begin
    if CurrentScreenId = screenShip then
      ShipScreen.StartMoneyWarning
    else if (CurrentScreenId = screenGoodsShop) and GetPlayer.InNormalSpace then
      GoodsShopScreen.FlashMoneyWarning
    else if RegisteredScreens[CurrentScreenId] is TMessageLoopGIWithMainPanel then
      TMessageLoopGIWithMainPanel(RegisteredScreens[CurrentScreenId]).MainPanel.FlashMoneyWarning;
  end
  else if (av[1].AsString = 'Space') and (CurrentScreenId <> screenShip) then
  begin
    if (CurrentScreenId = screenGoodsShop) and GetPlayer.InNormalSpace then
      GoodsShopScreen.FlashCargoWarning
    else if RegisteredScreens[CurrentScreenId] is TMessageLoopGIWithMainPanel then
      TMessageLoopGIWithMainPanel(RegisteredScreens[CurrentScreenId]).MainPanel.FlashCargoWarning;
  end;
end;

procedure SF_CustomWeaponTypes(av: array of TVarEC; code: TCodeEC);
var
  Index: Integer;
begin
  if High(av) < 1 then
    av[0].AsInteger := Galaxy.CustomWeaponTypes.Count
  else
  begin
    Index := av[1].AsInteger;
    if (Index >= 0) and (Galaxy.CustomWeaponTypes.Count > Index) then
      av[0].AsString := PWeaponInfo(Galaxy.CustomWeaponTypes[Index]).ConfigName
    else
      av[0].AsString := '';
  end;
end;

procedure SF_InventNewCustomWeapon(av: array of TVarEC; code: TCodeEC);
var
  Info, Base: PWeaponInfo;
  Kind: TItemType;
  I: Integer;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script InventNewCustomWeapon');
  Info := Galaxy.GetOrCreateCustomWeaponInfo(av[1].AsString);
  av[0].AsDword := PtrUInt(Info);
  if High(av) > 1 then
    Kind := TItemType(av[2].AsInteger)
  else
    Kind := t_IndustrialLaser;
  if not (Kind in [t_IndustrialLaser..t_Lirecron]) then
    raise Exception.Create(AnsiString('Error.Script InventNewCustomWeapon - invalid type ' + av[2].AsString));
  Base := @WeaponInfos[Kind];
  Info.TechLevel := Base.TechLevel;
  Info.InventionIndex := Base.InventionIndex;
  Info.CostFactor := Base.CostFactor;
  Info.MinDamage := Base.MinDamage;
  Info.MaxDamage := Base.MaxDamage;
  Info.AverageSize := Base.AverageSize;
  Info.AverageRange := Base.AverageRange;
  Info.ShotSpeedPercent := Base.ShotSpeedPercent;
  Info.MissileRange := Base.MissileRange;
  Info.MissileMaxSpeed := Base.MissileMaxSpeed;
  Info.MissileMinSpeed := Base.MissileMinSpeed;
  Info.MissileChanceToBeHit := Base.MissileChanceToBeHit;
  Info.DamageFlags := Base.DamageFlags;
  Info.ShotType := Base.ShotType;
  Info.ShotCount := Base.ShotCount;
  Info.AttackCount := Base.AttackCount;
  Info.SecondaryDamageRadius := Base.SecondaryDamageRadius;
  Info.MiningFactor := Base.MiningFactor;
  Info.PrimarySE := Base.PrimarySE;
  Info.SecondarySE := Base.SecondarySE;
  Info.AreaSE := Base.AreaSE;
  Info.DefaultPalette := Base.DefaultPalette;
  Info.Availability := Base.Availability;
  Info.ArcadeWeaponType := Base.ArcadeWeaponType;
  for I := Low(Info.DamageScaleByLevel) to High(Info.DamageScaleByLevel) do
    Info.DamageScaleByLevel[I] := Base.DamageScaleByLevel[I];
end;

procedure SF_GetCustomWeaponInfo(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script GetCustomWeaponInfo');
  av[0].AsDword := PtrUInt(Galaxy.RequireCustomWeaponInfo(av[1].AsString));
end;

procedure SF_GetCustomWeaponData(av: array of TVarEC; code: TCodeEC);
var
  Info: PWeaponInfo;
  Key: WideString;
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script GetCustomWeaponStats');
  if av[1].ValueKind = vkString then
    Info := Galaxy.RequireCustomWeaponInfo(av[1].AsString)
  else
    Info := @WeaponInfos[TItemType(av[1].AsInteger)];
  Key := av[2].AsString;
  if Key = 'TechLevel' then
    av[0].AsInteger := Info.TechLevel
  else if Key = 'AverageSize' then
    av[0].AsInteger := Info.AverageSize
  else if Key = 'AverageRadius' then
    av[0].AsInteger := Info.AverageRange
  else if Key = 'MissileRadius' then
    av[0].AsInteger := Info.MissileRange
  else if Key = 'SecondaryDamageRadius' then
    av[0].AsFloat := Info.SecondaryDamageRadius
  else if Key = 'MaxDamage' then
    av[0].AsInteger := Info.MaxDamage
  else if Key = 'MinDamage' then
    av[0].AsInteger := Info.MinDamage
  else if Key = 'DamageType' then
    av[0].AsDword := Dword(Info.DamageFlags)
  else if Key = 'kCost' then
    av[0].AsFloat := Info.CostFactor
  else if Key = 'AttackCount' then
    av[0].AsInteger := Info.AttackCount
  else if Key = 'ShotCount' then
    av[0].AsInteger := Info.ShotCount
  else if Key = 'ShotType' then
    case Info.ShotType of
      wstNormal: av[0].AsString := 'Normal';
      wstSplash: av[0].AsString := 'Splash';
      wstExploder: av[0].AsString := 'Exploder';
      wstAreaDamage: av[0].AsString := 'AreaDamage';
      wstTorpedo: av[0].AsString := 'Torpedo';
      wstMissile: av[0].AsString := 'Missile';
      wstRocket: av[0].AsString := 'Rocket';
      wstChain: av[0].AsString := 'Chain';
    end
  else if Key = 'Availability' then
    case Info.Availability of
      waFree: av[0].AsString := 'Free';
      waCoalitionOnly: av[0].AsString := 'CoalitionOnly';
      waPirateOnly: av[0].AsString := 'PirateOnly';
      waNotSold: av[0].AsString := 'NotSold';
      waNotSoldAndNodeRepair: av[0].AsString := 'NotSoldAndNodeRepair';
      waMalocOnly: av[0].AsString := 'MalocOnly';
      waPelengOnly: av[0].AsString := 'PelengOnly';
      waPeopleOnly: av[0].AsString := 'PeopleOnly';
      waFeiOnly: av[0].AsString := 'FeiOnly';
      waGaalOnly: av[0].AsString := 'GaalOnly';
      waSystemOnly: av[0].AsString := 'SystemOnly';
    else
      raise Exception.Create('Error.Script GetCustomWeaponStats - unknown availability type');
    end
  else
    raise Exception.Create(AnsiString('Error.Script GetCustomWeaponStats - unknown stat ' + Key));
end;

procedure SF_GetCustomWeaponPrimaryDamageType(av: array of TVarEC; code: TCodeEC);
var
  Info: PWeaponInfo;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script GetCustomWeaponPrimaryDamageType');
  if av[1].ValueKind = vkString then
    Info := Galaxy.RequireCustomWeaponInfo(av[1].AsString)
  else
    Info := @WeaponInfos[TItemType(av[1].AsInteger)];
  av[0].AsInteger := Ord(ClassifyWeaponDamageFlags(Info.DamageFlags));
end;

procedure SF_SetCustomWeaponAvailability(av: array of TVarEC; code: TCodeEC);
var
  Info: PWeaponInfo;
  Text: WideString;
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script SetCustomWeaponAvailability');
  Info := PWeaponInfo(av[1].AsDword);
  av[0].AsDword := PtrUInt(Info);
  Text := av[2].AsString;
  if Text = 'Free' then
    Info.Availability := waFree
  else if Text = 'CoalitionOnly' then
    Info.Availability := waCoalitionOnly
  else if Text = 'PirateOnly' then
    Info.Availability := waPirateOnly
  else if Text = 'NotSold' then
    Info.Availability := waNotSold
  else if Text = 'NotSoldAndNodeRepair' then
    Info.Availability := waNotSoldAndNodeRepair
  else if Text = 'MalocOnly' then
    Info.Availability := waMalocOnly
  else if Text = 'PelengOnly' then
    Info.Availability := waPelengOnly
  else if Text = 'PeopleOnly' then
    Info.Availability := waPeopleOnly
  else if Text = 'FeiOnly' then
    Info.Availability := waFeiOnly
  else if Text = 'GaalOnly' then
    Info.Availability := waGaalOnly
  else if Text = 'SystemOnly' then
    Info.Availability := waSystemOnly
  else
    Info.Availability := waFree;
end;

procedure SF_SetCustomWeaponPrimaryData(av: array of TVarEC; code: TCodeEC);
var
  Info: PWeaponInfo;
begin
  if High(av) < 4 then
    raise Exception.Create('Error.Script SetCustomWeaponPrimaryData');
  Info := PWeaponInfo(av[1].AsDword);
  av[0].AsDword := PtrUInt(Info);
  Info.TechLevel := av[2].AsInteger;
  if not (TItemType(av[3].AsInteger) in [t_IndustrialLaser..t_Lirecron]) then
    raise Exception.Create('Error.Script SetCustomWeaponPrimaryData invalid tech');
  Info.InventionIndex := WeaponInfos[TItemType(av[3].AsInteger)].InventionIndex;
  Info.ArcadeWeaponType := av[4].AsInteger;
end;

procedure SF_SetCustomWeaponSizeAndCost(av: array of TVarEC; code: TCodeEC);
var
  Info: PWeaponInfo;
begin
  if High(av) < 3 then
    raise Exception.Create('Error.Script SetCustomWeaponSizeAndCost');
  Info := PWeaponInfo(av[1].AsDword);
  av[0].AsDword := PtrUInt(Info);
  Info.CostFactor := av[2].AsFloat;
  Info.AverageSize := av[3].AsInteger;

end;

procedure SF_SetCustomWeaponDamageData(av: array of TVarEC; code: TCodeEC);
const
  EmptyFlags = [];
var
  Info: PWeaponInfo;
  Flag: Byte;
  Flags: TDamageFlagSet;
  I, Count: Integer;
  Text: WideString;
begin
  if High(av) < 4 then
    raise Exception.Create('Error.Script SetCustomWeaponDamageData');
  Info := PWeaponInfo(av[1].AsDword);
  av[0].AsDword := PtrUInt(Info);
  Info.MinDamage := av[2].AsInteger;
  Info.MaxDamage := av[3].AsInteger;
  Flags := EmptyFlags;
  if av[4].ValueKind = vkString then
  begin
    Text := ',' + av[4].AsString + ',';
    for Flag := Low(WeaponDamageFlagNames) to High(WeaponDamageFlagNames) do
      if Pos(',' + WeaponDamageFlagNames[Flag] + ',', Text) > 0 then
        Include(Flags, TDamageKind(Flag));
  end
  else
    Dword(Flags) := av[4].AsDword;
  Info.DamageFlags := Flags;
  if (High(av) > 4) and (av[5].ValueKind = vkString) then
  begin
    Text := av[5].AsString;
    Count := CountDelimitedPartsW(Text, ',');
    for I := Low(Info.DamageScaleByLevel) to Min(High(Info.DamageScaleByLevel), Count) do
      Info.DamageScaleByLevel[I] := ExtractDecimalToSingleW(ExtractDelimitedPartW(Text, I - 1, ','));
  end
  else
    for I := Low(Info.DamageScaleByLevel) to Min(High(Info.DamageScaleByLevel), High(av) - 4) do
      if not (av[4 + I].ValueKind in [vkInt, vkDword]) or (av[4 + I].AsInteger <> 0) then
        Info.DamageScaleByLevel[I] := av[4 + I].AsFloat;
end;

procedure SF_SetCustomWeaponShotData(av: array of TVarEC; code: TCodeEC);
var
  Info: PWeaponInfo;
  Text: WideString;
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script SetCustomWeaponShotData');
  Info := PWeaponInfo(av[1].AsDword);
  av[0].AsDword := PtrUInt(Info);
  Text := av[2].AsString;
  Info.ShotType := wstNormal;
  Info.ShotCount := 1;
  if Pos('Normal', Text) <= 0 then
  begin
    if Pos('Splash', Text) > 0 then
      Info.ShotType := wstSplash
    else if Pos('Exploder', Text) > 0 then
      Info.ShotType := wstExploder
    else if Pos('AreaDamage', Text) > 0 then
      Info.ShotType := wstAreaDamage
    else if Pos('Torpedo', Text) > 0 then
      Info.ShotType := wstTorpedo
    else if Pos('Missile', Text) > 0 then
      Info.ShotType := wstMissile
    else if Pos('Rocket', Text) > 0 then
      Info.ShotType := wstRocket
    else if Pos('Chain', Text) > 0 then
      Info.ShotType := wstChain;
  end;
  if Info.ShotType in [wstChain, wstMissile, wstRocket] then
    Info.ShotCount := ExtractDigitsToIntW(Text);
  if High(av) > 2 then
    Info.ShotSpeedPercent := av[3].AsInteger;
  if High(av) > 3 then
    Info.AverageRange := av[4].AsInteger;
  if High(av) > 4 then
    Info.SecondaryDamageRadius := av[5].AsInteger;
  if High(av) > 5 then
    Info.MiningFactor := av[6].AsFloat;
  if High(av) > 6 then
    Info.AttackCount := av[7].AsInteger;

end;

procedure SF_SetCustomMissileWeaponStats(av: array of TVarEC; code: TCodeEC);
var
  Info: PWeaponInfo;
begin
  if High(av) < 5 then
    raise Exception.Create('Error.Script SetCustomMissileWeaponStats');
  Info := PWeaponInfo(av[1].AsDword);
  av[0].AsDword := PtrUInt(Info);
  Info.MissileRange := av[2].AsInteger;
  Info.MissileMaxSpeed := av[3].AsInteger;
  Info.MissileMinSpeed := av[4].AsInteger;
  Info.MissileChanceToBeHit := av[5].AsInteger;

end;

procedure SF_SetCustomWeaponSE(av: array of TVarEC; code: TCodeEC);
var
  Info: PWeaponInfo;
begin
  if High(av) < 5 then
    raise Exception.Create('Error.Script SetCustomWeaponSE');
  Info := PWeaponInfo(av[1].AsDword);
  av[0].AsDword := PtrUInt(Info);
  Info.PrimarySE := av[2].AsString;
  Info.SecondarySE := av[3].AsString;
  Info.AreaSE := av[4].AsString;
  Info.DefaultPalette := av[5].AsInteger;

end;

procedure SF_StarCustomFaction(av: array of TVarEC; code: TCodeEC);
var
  Obj: TStar;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script StarCustomFaction');
  Obj := TStar(av[1].AsDword);
  av[0].AsString := Obj.Status.CustomFaction;
  if High(av) > 1 then
  begin
    Obj.Status.CustomFaction := av[2].AsString;
    if av[2].AsString = '' then
      Obj.ResetControlFaction;
  end;
end;

procedure SF_ShipCustomFaction(av: array of TVarEC; code: TCodeEC);
var
  Ship: TShip;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script ShipCustomFaction');
  Ship := TShip(av[1].AsDword);
  if GetPlayer = Ship then
  begin
    if High(av) > 1 then
      raise Exception.Create('Error.Script ShipCustomFaction Player');
    av[0].AsString := '';
    Exit;
  end;
  if Ship.ScriptShip = nil then
  begin
    if High(av) > 1 then
      raise Exception.Create('Error.Script ShipCustomFaction non-script ship');
    av[0].AsString := '';
    Exit;
  end;
  av[0].AsString := TScriptShip(Ship.ScriptShip).StateText;
  if High(av) > 1 then
  begin
    TScriptShip(Ship.ScriptShip).StateText := av[2].AsString;
    Ship.RefreshCurrentStanding;
  end;
end;

procedure SF_EqCustomFaction(av: array of TVarEC; code: TCodeEC);
var
  Obj: TEquipment;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script EqCustomFaction');
  Obj := TEquipment(av[1].AsDword);
  av[0].AsString := Obj.CustomFaction;
  if High(av) > 1 then
  begin
    Obj.CustomFaction := av[2].AsString;
  end;
end;

procedure SF_PlanetCustomFaction(av: array of TVarEC; code: TCodeEC);
var
  Obj: TPlanet;
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script PlanetCustomFaction');
  Obj := TPlanet(av[1].AsDword);
  av[0].AsString := Obj.CustomFaction;
  if High(av) > 1 then
  begin
    Obj.CustomFaction := av[2].AsString;
  end;
end;

procedure SF_ImportedFunction(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 2 then
    raise Exception.Create('Error.Script ImportedFunction');
  av[0].ConvertToKind(vkLibraryFun);
  av[0].AsString := av[1].AsString + ',' + av[2].AsString;
  if ScriptLibraryCache = nil then
    ScriptLibraryCache := TLibraryCache.Create;
  ScriptLibraryCache.InitFunction(av[0]);
end;

procedure SF_ImportAll(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then
    raise Exception.Create('Error.Script ImportAll');
  if ScriptLibraryCache = nil then
    ScriptLibraryCache := TLibraryCache.Create;
  ScriptLibraryCache.GetLib(av[1].AsString).InitAllFunctions(code.LocalVar);
  code.LinkAll(code.LocalVar, False);
end;

procedure SF_GalaxyPtr(av: array of TVarEC; code: TCodeEC);
begin
  if High(av) < 1 then
    av[0].AsDword := PtrUInt(Galaxy)
  else if av[1].AsString = 'StarCnt' then
    av[0].AsDword := PtrUInt(@GalaxyStarCount)
  else
    raise Exception.Create('Error.Script GalaxyPtr, unknown value ' + av[1].AsString);
end;

procedure InitializeScriptBuiltinsAndConstants(Scope: TVarArrayEC);
var
  WeaponIndex: Integer;
  ActionIndex: TScriptActionType;
  BonusIndex: TEquipmentBonusKind;
begin
  RegisterExpressionBuiltins(Scope);
  Scope.Add('GRun', vkExternFun).AsExternFun := @SF_GRun;
  Scope.Add('GCntRun', vkExternFun).AsExternFun := @SF_GCntRun;
  Scope.Add('GLastTurnRun', vkExternFun).AsExternFun := @SF_GLastTurnRun;
  Scope.Add('GAllCntRun', vkExternFun).AsExternFun := @SF_GAllCntRun;
  Scope.Add('IsScriptActive', vkExternFun).AsExternFun := @SF_IsScriptActive;
  Scope.Add('GetValueFromScript', vkExternFun).AsExternFun := @SF_GetValueFromScript;
  Scope.Add('RunFunctionFromScript', vkExternFun).AsExternFun := @SF_RunFunctionFromScript;
  Scope.Add('GetVariableName', vkExternFun).AsExternFun := @SF_GetVariableName;
  Scope.Add('GetVariableType', vkExternFun).AsExternFun := @SF_GetVariableType;
  Scope.Add('StatusPlayer', vkExternFun).AsExternFun := @SF_StatusPlayer;
  Scope.Add('AddPlanetNews', vkExternFun).AsExternFun := @SF_AddPlanetNews;
  Scope.Add('AddJournalRecord', vkExternFun).AsExternFun := @SF_AddJournalRecord;
  Scope.Add('AutoBattle', vkExternFun).AsExternFun := @SF_AutoBattle;
  Scope.Add('GetOwner', vkExternFun).AsExternFun := @SF_GetOwner;
  Scope.Add('GiveReward', vkExternFun).AsExternFun := @SF_GiveReward;
  Scope.Add('GiveRewardByNom', vkExternFun).AsExternFun := @SF_GiveRewardByNom;
  Scope.Add('CountReward', vkExternFun).AsExternFun := @SF_CountReward;
  Scope.Add('CountRewardByNom', vkExternFun).AsExternFun := @SF_CountRewardByNom;
  Scope.Add('DeleteRewardByNom', vkExternFun).AsExternFun := @SF_DeleteRewardByNom;
  Scope.Add('Rnd', vkExternFun).AsExternFun := @SF_Rnd;
  Scope.Add('GameDateTxtByTurn', vkExternFun).AsExternFun := @SF_GameDateTxtByTurn;
  Scope.Add('Id', vkExternFun).AsExternFun := @SF_Id;
  Scope.Add('SetName', vkExternFun).AsExternFun := @SF_SetName;
  Scope.Add('UseTranclucator', vkExternFun).AsExternFun := @SF_UseTranclucator;
  Scope.Add('HullDamage', vkExternFun).AsExternFun := @SF_HullDamage;
  Scope.Add('Hitpoints', vkExternFun).AsExternFun := @SF_Hitpoints;
  Scope.Add('Hit', vkExternFun).AsExternFun := @SF_Hit;
  Scope.Add('ChangeGlobalRelationsShips', vkExternFun).AsExternFun := @SF_ChangeGlobalRelationsShips;
  Scope.Add('ChangeGlobalRelationsPlanets', vkExternFun).AsExternFun := @SF_ChangeGlobalRelationsPlanets;
  Scope.Add('GlobalRelationsShips', vkExternFun).AsExternFun := @SF_GlobalRelationsShips;
  Scope.Add('GlobalRelationsPlanets', vkExternFun).AsExternFun := @SF_GlobalRelationsPlanets;
  Scope.Add('SetRelationGroup', vkExternFun).AsExternFun := @SF_SetRelationGroup;
  Scope.Add('SetRelationPlanet', vkExternFun).AsExternFun := @SF_SetRelationPlanet;
  Scope.Add('GetRelationPlanet', vkExternFun).AsExternFun := @SF_GetRelationPlanet;
  Scope.Add('CurTurn', vkExternFun).AsExternFun := @SF_CurTurn;
  Scope.Add('ShipType', vkExternFun).AsExternFun := @SF_ShipType;
  Scope.Add('ConName', vkExternFun).AsExternFun := @SF_ConName;
  Scope.Add('StarName', vkExternFun).AsExternFun := @SF_StarName;
  Scope.Add('StarMapLabel', vkExternFun).AsExternFun := @SF_StarMapLabel;
  Scope.Add('PlanetName', vkExternFun).AsExternFun := @SF_PlanetName;
  Scope.Add('IdToPlanet', vkExternFun).AsExternFun := @SF_IdToPlanet;
  Scope.Add('IdToShip', vkExternFun).AsExternFun := @SF_IdToShip;
  Scope.Add('IdToItem', vkExternFun).AsExternFun := @SF_IdToItem;
  Scope.Add('PlanetSetGoods', vkExternFun).AsExternFun := @SF_PlanetSetGoods;
  Scope.Add('ShipName', vkExternFun).AsExternFun := @SF_ShipName;
  Scope.Add('ShipRank', vkExternFun).AsExternFun := @SF_ShipRank;
  Scope.Add('ShipRankPoints', vkExternFun).AsExternFun := @SF_ShipRankPoints;
  Scope.Add('ShipNextRankPoints', vkExternFun).AsExternFun := @SF_ShipNextRankPoints;
  Scope.Add('ShipRaiseRank', vkExternFun).AsExternFun := @SF_ShipRaiseRank;
  Scope.Add('ShipStar', vkExternFun).AsExternFun := @SF_ShipStar;
  Scope.Add('StarToCon', vkExternFun).AsExternFun := @SF_StarToCon;
  Scope.Add('ConNear', vkExternFun).AsExternFun := @SF_ConNear;
  Scope.Add('ConStars', vkExternFun).AsExternFun := @SF_ConStars;
  Scope.Add('ConStar', vkExternFun).AsExternFun := @SF_ConStar;
  Scope.Add('GalaxyStars', vkExternFun).AsExternFun := @SF_GalaxyStars;
  Scope.Add('GalaxyStar', vkExternFun).AsExternFun := @SF_GalaxyStar;
  Scope.Add('StarAngleBetween', vkExternFun).AsExternFun := @SF_StarAngleBetween;
  Scope.Add('FindPlanet', vkExternFun).AsExternFun := @SF_FindPlanet;
  Scope.Add('IsPlayer', vkExternFun).AsExternFun := @SF_IsPlayer;
  Scope.Add('GroupCount', vkExternFun).AsExternFun := @SF_GroupCount;
  Scope.Add('GroupIn', vkExternFun).AsExternFun := @SF_GroupIn;
  Scope.Add('CountIn', vkExternFun).AsExternFun := @SF_CountIn;
  Scope.Add('ChangeState', vkExternFun).AsExternFun := @SF_ChangeState;
  Scope.Add('NearestGroup', vkExternFun).AsExternFun := @SF_NearestGroup;
  Scope.Add('StarAngle', vkExternFun).AsExternFun := @SF_StarAngle;
  Scope.Add('NewsAdd', vkExternFun).AsExternFun := @SF_NewsAdd;
  Scope.Add('MsgAdd', vkExternFun).AsExternFun := @SF_MsgAdd;
  Scope.Add('Ether', vkExternFun).AsExternFun := @SF_Ether;
  Scope.Add('CustomEther', vkExternFun).AsExternFun := @SF_CustomEther;
  Scope.Add('EtherDelete', vkExternFun).AsExternFun := @SF_EtherDelete;
  Scope.Add('EtherIdAdd', vkExternFun).AsExternFun := @SF_EtherIdAdd;
  Scope.Add('EtherIdDelete', vkExternFun).AsExternFun := @SF_EtherIdDelete;
  Scope.Add('EtherState', vkExternFun).AsExternFun := @SF_EtherState;
  Scope.Add('ConChangeRelationToRanger', vkExternFun).AsExternFun := @SF_ConChangeRelationToRanger;
  Scope.Add('GetData', vkExternFun).AsExternFun := @SF_GetData;
  Scope.Add('SetData', vkExternFun).AsExternFun := @SF_SetData;
  Scope.Add('ShipData', vkExternFun).AsExternFun := @SF_ShipData;
  Scope.Add('Format', vkExternFun).AsExternFun := @SF_Format;
  Scope.Add('DeleteTags', vkExternFun).AsExternFun := @SF_DeleteTags;
  Scope.Add('Dialog', vkExternFun).AsExternFun := @SF_Dialog;
  Scope.Add('DText', vkExternFun).AsExternFun := @SF_DText;
  Scope.Add('DAddText', vkExternFun).AsExternFun := @SF_DAddText;
  Scope.Add('DAdd', vkExternFun).AsExternFun := @SF_DAdd;
  Scope.Add('DChange', vkExternFun).AsExternFun := @SF_DChange;
  Scope.Add('DAnswer', vkExternFun).AsExternFun := @SF_DAnswer;
  Scope.Add('Player', vkExternFun).AsExternFun := @SF_Player;
  Scope.Add('ItemExist', vkExternFun).AsExternFun := @SF_ItemExist;
  Scope.Add('ItemIn', vkExternFun).AsExternFun := @SF_ItemIn;
  Scope.Add('ItemCost', vkExternFun).AsExternFun := @SF_ItemCost;
  Scope.Add('ItemCount', vkExternFun).AsExternFun := @SF_ItemCount;
  Scope.Add('ShipPicksItem', vkExternFun).AsExternFun := @SF_ShipPicksItem;
  Scope.Add('DropItem', vkExternFun).AsExternFun := @SF_DropItem;
  Scope.Add('DropScriptItem', vkExternFun).AsExternFun := @SF_DropScriptItem;
  Scope.Add('DeleteEquipment', vkExternFun).AsExternFun := @SF_DeleteEquipment;
  Scope.Add('DecayGoods', vkExternFun).AsExternFun := @SF_DecayGoods;
  Scope.Add('UpsurgeGoods', vkExternFun).AsExternFun := @SF_UpsurgeGoods;
  Scope.Add('GoodsAdd', vkExternFun).AsExternFun := @SF_GoodsAdd;
  Scope.Add('GoodsCount', vkExternFun).AsExternFun := @SF_GoodsCount;
  Scope.Add('GoodsCost', vkExternFun).AsExternFun := @SF_GoodsCost;
  Scope.Add('GoodsRuinsForBuy', vkExternFun).AsExternFun := @SF_GoodsRuinsForBuy;
  Scope.Add('ShipGoods', vkExternFun).AsExternFun := @SF_ShipGoods;
  Scope.Add('ShipGoodsIllegalOnPlanet', vkExternFun).AsExternFun := @SF_ShipGoodsIllegalOnPlanet;
  Scope.Add('GoodsDrop', vkExternFun).AsExternFun := @SF_GoodsDrop;
  Scope.Add('UselessItemCreate', vkExternFun).AsExternFun := @SF_UselessItemCreate;
  Scope.Add('GoodsSellPrice', vkExternFun).AsExternFun := @SF_GoodsSellPrice;
  Scope.Add('GoodsBuyPrice', vkExternFun).AsExternFun := @SF_GoodsBuyPrice;
  Scope.Add('CountTurn', vkExternFun).AsExternFun := @SF_CountTurn;
  Scope.Add('ShipSetBad', vkExternFun).AsExternFun := @SF_ShipSetBad;
  Scope.Add('GroupSetBad', vkExternFun).AsExternFun := @SF_GroupSetBad;
  Scope.Add('ShipSetPartner', vkExternFun).AsExternFun := @SF_ShipSetPartner;
  Scope.Add('ShipJoin', vkExternFun).AsExternFun := @SF_ShipJoin;
  Scope.Add('ShipOut', vkExternFun).AsExternFun := @SF_ShipOut;
  Scope.Add('AllShipOut', vkExternFun).AsExternFun := @SF_AllShipOut;
  Scope.Add('ShipInScript', vkExternFun).AsExternFun := @SF_ShipInScript;
  Scope.Add('ShipInGameEvent', vkExternFun).AsExternFun := @SF_ShipInGameEvent;
  Scope.Add('ShipInCurScript', vkExternFun).AsExternFun := @SF_ShipInCurScript;
  Scope.Add('ShipInNormalSpace', vkExternFun).AsExternFun := @SF_ShipInNormalSpace;
  Scope.Add('ShipInHole', vkExternFun).AsExternFun := @SF_ShipInHole;
  Scope.Add('ShipIsTakeoff', vkExternFun).AsExternFun := @SF_ShipIsTakeoff;
  Scope.Add('ShipCntWeapon', vkExternFun).AsExternFun := @SF_ShipCntWeapon;
  Scope.Add('ShipWeapon', vkExternFun).AsExternFun := @SF_ShipWeapon;
  Scope.Add('ShipEqInSlot', vkExternFun).AsExternFun := @SF_ShipEqInSlot;
  Scope.Add('ArtefactTypeInUse', vkExternFun).AsExternFun := @SF_ArtefactTypeInUse;
  Scope.Add('ArtefactTypeBoosted', vkExternFun).AsExternFun := @SF_ArtefactTypeBoosted;
  Scope.Add('ShipSpeed', vkExternFun).AsExternFun := @SF_ShipSpeed;
  Scope.Add('EnginePower', vkExternFun).AsExternFun := @SF_EnginePower;
  Scope.Add('ShipJump', vkExternFun).AsExternFun := @SF_ShipJump;
  Scope.Add('ShipArmor', vkExternFun).AsExternFun := @SF_ShipArmor;
  Scope.Add('ShipProtectability', vkExternFun).AsExternFun := @SF_ShipProtectability;
  Scope.Add('ShipDroidRepair', vkExternFun).AsExternFun := @SF_ShipDroidRepair;
  Scope.Add('ShipRadarRange', vkExternFun).AsExternFun := @SF_ShipRadarRange;
  Scope.Add('ShipScanerPower', vkExternFun).AsExternFun := @SF_ShipScanerPower;
  Scope.Add('ShipHookPower', vkExternFun).AsExternFun := @SF_ShipHookPower;
  Scope.Add('ShipHookRange', vkExternFun).AsExternFun := @SF_ShipHookRange;
  Scope.Add('ShipAverageDamage', vkExternFun).AsExternFun := @SF_ShipAverageDamage;
  Scope.Add('ShipHealthFactor', vkExternFun).AsExternFun := @SF_ShipHealthFactor;
  Scope.Add('ShipHealthFactorStatus', vkExternFun).AsExternFun := @SF_ShipHealthFactorStatus;
  Scope.Add('PlayerImmunity', vkExternFun).AsExternFun := @SF_PlayerImmunity;
  Scope.Add('ShipStatusEffect', vkExternFun).AsExternFun := @SF_ShipStatusEffect;
  Scope.Add('ShipGroup', vkExternFun).AsExternFun := @SF_ShipGroup;
  Scope.Add('ShipCanJump', vkExternFun).AsExternFun := @SF_ShipCanJump;
  Scope.Add('ShipInStar', vkExternFun).AsExternFun := @SF_ShipInStar;
  Scope.Add('ShipInPlanet', vkExternFun).AsExternFun := @SF_ShipInPlanet;
  Scope.Add('ShipStatistic', vkExternFun).AsExternFun := @SF_ShipStatistic;
  Scope.Add('PlayerDominatorStatistic', vkExternFun).AsExternFun := @SF_PlayerDominatorStatistic;
  Scope.Add('ShipMoney', vkExternFun).AsExternFun := @SF_ShipMoney;
  Scope.Add('ShipFuel', vkExternFun).AsExternFun := @SF_ShipFuel;
  Scope.Add('ShipFuelLow', vkExternFun).AsExternFun := @SF_ShipFuelLow;
  Scope.Add('ShipStrengthInBestRanger', vkExternFun).AsExternFun := @SF_ShipStrengthInBestRanger;
  Scope.Add('ShipStrengthInAverageRanger', vkExternFun).AsExternFun := @SF_ShipStrengthInAverageRanger;
  Scope.Add('ChanceToWin', vkExternFun).AsExternFun := @SF_ChanceToWin;
  Scope.Add('ShipFind', vkExternFun).AsExternFun := @SF_ShipFind;
  Scope.Add('RangerStatus', vkExternFun).AsExternFun := @SF_RangerStatus;
  Scope.Add('RangerPlaceInRating', vkExternFun).AsExternFun := @SF_RangerPlaceInRating;
  Scope.Add('RangerExcludedFromRating', vkExternFun).AsExternFun := @SF_RangerExcludedFromRating;
  Scope.Add('GalaxyMoney', vkExternFun).AsExternFun := @SF_GalaxyMoney;
  Scope.Add('ShipDestroy', vkExternFun).AsExternFun := @SF_ShipDestroy;
  Scope.Add('ShipDestroyType', vkExternFun).AsExternFun := @SF_ShipDestroyType;
  Scope.Add('ItemDestroy', vkExternFun).AsExternFun := @SF_ItemDestroy;
  Scope.Add('RangersCapital', vkExternFun).AsExternFun := @SF_RangersCapital;
  Scope.Add('GroupToShip', vkExternFun).AsExternFun := @SF_GroupToShip;
  Scope.Add('OrderLanding', vkExternFun).AsExternFun := @SF_OrderLanding;
  Scope.Add('OrderJump', vkExternFun).AsExternFun := @SF_OrderJump;
  Scope.Add('GroupIs', vkExternFun).AsExternFun := @SF_GroupIs;
  Scope.Add('StateIs', vkExternFun).AsExternFun := @SF_StateIs;
  Scope.Add('Dist', vkExternFun).AsExternFun := @SF_Dist;
  Scope.Add('Angle', vkExternFun).AsExternFun := @SF_Angle;
  Scope.Add('Dist2Star', vkExternFun).AsExternFun := @SF_Dist2Star;
  Scope.Add('BuyPirate', vkExternFun).AsExternFun := @SF_BuyPirate;
  Scope.Add('BuyTransport', vkExternFun).AsExternFun := @SF_BuyTransport;
  Scope.Add('Name', vkExternFun).AsExternFun := @SF_Name;
  Scope.Add('ShortName', vkExternFun).AsExternFun := @SF_ShortName;
  Scope.Add('FirstGiveMoney', vkExternFun).AsExternFun := @SF_FirstGiveMoney;
  Scope.Add('HaveProgramm', vkExternFun).AsExternFun := @SF_HaveProgramm;
  Scope.Add('GetProgramm', vkExternFun).AsExternFun := @SF_GetProgramm;
  Scope.Add('SetProgramm', vkExternFun).AsExternFun := @SF_SetProgramm;
  Scope.Add('DomikProgramm', vkExternFun).AsExternFun := @SF_DomikProgramm;
  Scope.Add('DomikProgrammDate', vkExternFun).AsExternFun := @SF_DomikProgrammDate;
  Scope.Add('HoleMamaCreate', vkExternFun).AsExternFun := @SF_HoleMamaCreate;
  Scope.Add('HoleCreate', vkExternFun).AsExternFun := @SF_HoleCreate;
  Scope.Add('TerronWeaponLock', vkExternFun).AsExternFun := @SF_TerronWeaponLock;
  Scope.Add('TerronGrowLock', vkExternFun).AsExternFun := @SF_TerronGrowLock;
  Scope.Add('TerronLandingLock', vkExternFun).AsExternFun := @SF_TerronLandingLock;
  Scope.Add('TerronToStar', vkExternFun).AsExternFun := @SF_TerronToStar;
  Scope.Add('KellerLeave', vkExternFun).AsExternFun := @SF_KellerLeave;
  Scope.Add('KellerNewResearch', vkExternFun).AsExternFun := @SF_KellerNewResearch;
  Scope.Add('KellerKill', vkExternFun).AsExternFun := @SF_KellerKill;
  Scope.Add('BlazerLanding', vkExternFun).AsExternFun := @SF_BlazerLanding;
  Scope.Add('BlazerSelfDestruction', vkExternFun).AsExternFun := @SF_BlazerSelfDestruction;
  Scope.Add('GalaxyShipId', vkExternFun).AsExternFun := @SF_GalaxyShipId;
  Scope.Add('NearCivilPlanet', vkExternFun).AsExternFun := @SF_NearCivilPlanet;
  Scope.Add('SkipGreeting', vkExternFun).AsExternFun := @SF_SkipGreeting;
  Scope.Add('Sound', vkExternFun).AsExternFun := @SF_Sound;
  Scope.Add('Tips', vkExternFun).AsExternFun := @SF_Tips;
  Scope.Add('TipsState', vkExternFun).AsExternFun := @SF_TipsState;
  Scope.Add('CT', vkExternFun).AsExternFun := @SF_CT;
  Scope.Add('BlockExist', vkExternFun).AsExternFun := @SF_BlockExist;
  Scope.Add('GetMainData', vkExternFun).AsExternFun := @SF_GetMainData;
  Scope.Add('GetGameOptions', vkExternFun).AsExternFun := @SF_GetGameOptions;
  Scope.Add('ResourceExist', vkExternFun).AsExternFun := @SF_ResourceExist;
  Scope.Add('SFT', vkExternFun).AsExternFun := @SF_SFT;
  Scope.Add('CurrentMods', vkExternFun).AsExternFun := @SF_CurrentMods;
  Scope.Add('RobotSupport', vkExternFun).AsExternFun := @SF_RobotSupport;
  Scope.Add('UselessItem', vkInt).AsInteger := Ord(t_UselessItem);
  Scope.Add('ForLiberationSystem', vkInt).AsInteger := Ord(atLiberation);
  Scope.Add('ForAccomplishment', vkInt).AsInteger := Ord(atAccomplishment);
  Scope.Add('ForSecretMission', vkInt).AsInteger := Ord(atSecretMission);
  Scope.Add('ForCowardice', vkInt).AsInteger := Ord(atCowardice);
  Scope.Add('ForPerfidy', vkInt).AsInteger := Ord(atPerfidy);
  Scope.Add('ForPlanetBattle', vkInt).AsInteger := Ord(atPlanetBattle);
  Scope.Add('Maloc', vkInt).AsInteger := Ord(oiMaloc);
  Scope.Add('Peleng', vkInt).AsInteger := Ord(oiPeleng);
  Scope.Add('People', vkInt).AsInteger := Ord(oiHuman);
  Scope.Add('Fei', vkInt).AsInteger := Ord(oiFeyan);
  Scope.Add('Gaal', vkInt).AsInteger := Ord(oiGaal);
  Scope.Add('Kling', vkInt).AsInteger := Ord(oiDominator);
  Scope.Add('None', vkInt).AsInteger := Ord(oiUninhabited);
  Scope.Add('PirateClan', vkInt).AsInteger := Ord(oiPirate);
  Scope.Add('t_Food', vkInt).AsInteger := Ord(t_Food);
  Scope.Add('t_Medicine', vkInt).AsInteger := Ord(t_Medicine);
  Scope.Add('t_Technics', vkInt).AsInteger := Ord(t_Technics);
  Scope.Add('t_Luxury', vkInt).AsInteger := Ord(t_Luxury);
  Scope.Add('t_Minerals', vkInt).AsInteger := Ord(t_Minerals);
  Scope.Add('t_Alcohol', vkInt).AsInteger := Ord(t_Alcohol);
  Scope.Add('t_Arms', vkInt).AsInteger := Ord(t_Arms);
  Scope.Add('t_Narcotics', vkInt).AsInteger := Ord(t_Narcotics);
  Scope.Add('t_Artefact', vkInt).AsInteger := Ord(t_Artefact);
  Scope.Add('t_Artefact2', vkInt).AsInteger := Ord(t_Artefact2);
  Scope.Add('t_ArtefactHull', vkInt).AsInteger := Ord(t_ArtefactHull);
  Scope.Add('t_ArtefactFuel', vkInt).AsInteger := Ord(t_ArtefactFuel);
  Scope.Add('t_ArtefactSpeed', vkInt).AsInteger := Ord(t_ArtefactSpeed);
  Scope.Add('t_ArtefactPower', vkInt).AsInteger := Ord(t_ArtefactPower);
  Scope.Add('t_ArtefactRadar', vkInt).AsInteger := Ord(t_ArtefactRadar);
  Scope.Add('t_ArtefactScaner', vkInt).AsInteger := Ord(t_ArtefactScaner);
  Scope.Add('t_ArtefactDroid', vkInt).AsInteger := Ord(t_ArtefactDroid);
  Scope.Add('t_ArtefactNano', vkInt).AsInteger := Ord(t_ArtefactNano);
  Scope.Add('t_ArtefactHook', vkInt).AsInteger := Ord(t_ArtefactHook);
  Scope.Add('t_ArtefactDef', vkInt).AsInteger := Ord(t_ArtefactDef);
  Scope.Add('t_ArtefactAnalyzer', vkInt).AsInteger := Ord(t_ArtefactAnalyzer);
  Scope.Add('t_ArtefactMiniExpl', vkInt).AsInteger := Ord(t_ArtefactMiniExpl);
  Scope.Add('t_ArtefactAntigrav', vkInt).AsInteger := Ord(t_ArtefactAntigrav);
  Scope.Add('t_ArtefactTransmitter', vkInt).AsInteger := Ord(t_ArtefactTransmitter);
  Scope.Add('t_ArtefactBomb', vkInt).AsInteger := Ord(t_ArtefactBomb);
  Scope.Add('t_ArtefactTranclucator', vkInt).AsInteger := Ord(t_ArtefactTranclucator);
  Scope.Add('t_Hull', vkInt).AsInteger := Ord(t_Hull);
  Scope.Add('t_FuelTanks', vkInt).AsInteger := Ord(t_FuelTanks);
  Scope.Add('t_Engine', vkInt).AsInteger := Ord(t_Engine);
  Scope.Add('t_Radar', vkInt).AsInteger := Ord(t_Radar);
  Scope.Add('t_Scaner', vkInt).AsInteger := Ord(t_Scaner);
  Scope.Add('t_RepairRobot', vkInt).AsInteger := Ord(t_RepairRobot);
  Scope.Add('t_CargoHook', vkInt).AsInteger := Ord(t_CargoHook);
  Scope.Add('t_DefGenerator', vkInt).AsInteger := Ord(t_DefGenerator);
  for WeaponIndex := 1 to CountItemTypesInMask([t_IndustrialLaser..t_Lirecron]) do
    Scope.Add('t_Weapon' + IntToStr(WeaponIndex), vkInt).AsInteger :=
        Ord(GetItemTypeFromMask([t_IndustrialLaser..t_Lirecron], WeaponIndex));
  Scope.Add('t_CustomWeapon', vkInt).AsInteger := Ord(t_CustomWeapon);
  Scope.Add('t_Protoplasm', vkInt).AsInteger := Ord(t_Protoplasm);
  Scope.Add('t_UselessItem', vkInt).AsInteger := Ord(t_UselessItem);
  Scope.Add('ReWar', vkInt).AsInteger := Ord(rlHostile);
  Scope.Add('ReBad', vkInt).AsInteger := Ord(rlBad);
  Scope.Add('ReNormal', vkInt).AsInteger := Ord(rlNormal);
  Scope.Add('ReGood', vkInt).AsInteger := Ord(rlGood);
  Scope.Add('ReBest', vkInt).AsInteger := Ord(rlExcellent);
  Scope.Add('Trader', vkInt).AsInteger := Ord(rcTrader);
  Scope.Add('Pirate', vkInt).AsInteger := Ord(rcPirate);
  Scope.Add('Warrior', vkInt).AsInteger := Ord(rcWarrior);
  Scope.Add('t_Kling', vkInt).AsInteger := Ord(stKling);
  Scope.Add('t_Ranger', vkInt).AsInteger := Ord(stRanger);
  Scope.Add('t_Transport', vkInt).AsInteger := Ord(stTransport);
  Scope.Add('t_Pirate', vkInt).AsInteger := Ord(stPirate);
  Scope.Add('t_Warrior', vkInt).AsInteger := Ord(stWarrior);
  Scope.Add('t_Tranclucator', vkInt).AsInteger := Ord(stTranclucator);
  Scope.Add('t_RC', vkInt).AsInteger := Ord(rstRangerCenter);
  Scope.Add('t_PB', vkInt).AsInteger := Ord(rstPirateBase);
  Scope.Add('t_WB', vkInt).AsInteger := Ord(rstMilitaryBase);
  Scope.Add('t_SB', vkInt).AsInteger := Ord(rstScienceBase);
  Scope.Add('t_BK', vkInt).AsInteger := Ord(rstBusinessCenter);
  Scope.Add('t_MC', vkInt).AsInteger := Ord(rstMedicalBase);
  Scope.Add('t_CB', vkInt).AsInteger := Ord(rstDominion);
  Scope.Add('t_UB', vkInt).AsInteger := Ord(rstCustomStation);
  Scope.Add('progKellerCall', vkInt).AsInteger := Ord(prgKellerCall);
  Scope.Add('progLogicalNegation', vkInt).AsInteger := Ord(prgLogicalNegation);
  Scope.Add('progDematerial', vkInt).AsInteger := Ord(prgDematerial);
  Scope.Add('progEnergotron', vkInt).AsInteger := Ord(prgEnergotron);
  Scope.Add('progSabCrack', vkInt).AsInteger := Ord(prgSabCrack);
  Scope.Add('progIntercom', vkInt).AsInteger := Ord(prgIntercom);
  Scope.Add('StarShips', vkExternFun).AsExternFun := @SF_StarShips;
  Scope.Add('StarPlanets', vkExternFun).AsExternFun := @SF_StarPlanets;
  Scope.Add('StarMissiles', vkExternFun).AsExternFun := @SF_StarMissiles;
  Scope.Add('StarAsteroids', vkExternFun).AsExternFun := @SF_StarAsteroids;
  Scope.Add('GroupShip', vkExternFun).AsExternFun := @SF_GroupShip;
  Scope.Add('ShipItems', vkExternFun).AsExternFun := @SF_ShipItems;
  Scope.Add('ShipArts', vkExternFun).AsExternFun := @SF_ShipArts;
  Scope.Add('PlayerTranclucators', vkExternFun).AsExternFun := @SF_PlayerTranclucators;
  Scope.Add('ArtTranclucatorToShip', vkExternFun).AsExternFun := @SF_ArtTranclucatorToShip;
  Scope.Add('TranclucatorData', vkExternFun).AsExternFun := @SF_TranclucatorData;
  Scope.Add('LinkItemToScript', vkExternFun).AsExternFun := @SF_LinkItemToScript;
  Scope.Add('ReleaseItemFromScript', vkExternFun).AsExternFun := @SF_ReleaseItemFromScript;
  Scope.Add('ScriptItemData', vkExternFun).AsExternFun := @SF_ScriptItemData;
  Scope.Add('ScriptItemTextData', vkExternFun).AsExternFun := @SF_ScriptItemTextData;
  Scope.Add('ScriptItemToItem', vkExternFun).AsExternFun := @SF_ScriptItemToItem;
  Scope.Add('GetShipPirateRank', vkExternFun).AsExternFun := @SF_GetShipPirateRank;
  Scope.Add('ShipPirateRankPoints', vkExternFun).AsExternFun := @SF_ShipPirateRankPoints;
  Scope.Add('ShipNextPirateRankPoints', vkExternFun).AsExternFun := @SF_ShipNextPirateRankPoints;
  Scope.Add('ShipInPirateClan', vkExternFun).AsExternFun := @SF_ShipInPirateClan;
  Scope.Add('ShipOnSidePirateClan', vkExternFun).AsExternFun := @SF_ShipOnSidePirateClan;
  Scope.Add('RaisePirateRank', vkExternFun).AsExternFun := @SF_RaisePirateRank;
  Scope.Add('ItemType', vkExternFun).AsExternFun := @SF_ItemType;
  Scope.Add('CustomWeaponType', vkExternFun).AsExternFun := @SF_CustomWeaponType;
  Scope.Add('ItemName', vkExternFun).AsExternFun := @SF_ItemName;
  Scope.Add('ItemFullName', vkExternFun).AsExternFun := @SF_ItemFullName;
  Scope.Add('ItemSize', vkExternFun).AsExternFun := @SF_ItemSize;
  Scope.Add('ItemOwner', vkExternFun).AsExternFun := @SF_ItemOwner;
  Scope.Add('ItemSubrace', vkExternFun).AsExternFun := @SF_ItemSubrace;
  Scope.Add('ItemIsInUse', vkExternFun).AsExternFun := @SF_ItemIsInUse;
  Scope.Add('ItemIsInSet', vkExternFun).AsExternFun := @SF_ItemIsInSet;
  Scope.Add('PlayerEqSet', vkExternFun).AsExternFun := @SF_PlayerEqSet;
  Scope.Add('ItemIsBroken', vkExternFun).AsExternFun := @SF_ItemIsBroken;
  Scope.Add('ShipCanUseEq', vkExternFun).AsExternFun := @SF_ShipCanUseEq;
  Scope.Add('ShipCanRepairEq', vkExternFun).AsExternFun := @SF_ShipCanRepairEq;
  Scope.Add('ShipTechLevelKnowledge', vkExternFun).AsExternFun := @SF_ShipTechLevelKnowledge;
  Scope.Add('WeaponTarget', vkExternFun).AsExternFun := @SF_WeaponTarget;
  Scope.Add('GetEquipmentStats', vkExternFun).AsExternFun := @SF_GetEquipmentStats;
  Scope.Add('SetEquipmentStats', vkExternFun).AsExternFun := @SF_SetEquipmentStats;
  Scope.Add('CreateHull', vkExternFun).AsExternFun := @SF_CreateHull;
  Scope.Add('CreateEquipment', vkExternFun).AsExternFun := @SF_CreateEquipment;
  Scope.Add('CreateArt', vkExternFun).AsExternFun := @SF_CreateArt;
  Scope.Add('CreateCustomWeapon', vkExternFun).AsExternFun := @SF_CreateCustomWeapon;
  Scope.Add('CreateCustomArt', vkExternFun).AsExternFun := @SF_CreateCustomArt;
  Scope.Add('CustomArtData', vkExternFun).AsExternFun := @SF_CustomArtData;
  Scope.Add('CustomArtTextData', vkExternFun).AsExternFun := @SF_CustomArtTextData;
  Scope.Add('CreateMM', vkExternFun).AsExternFun := @SF_CreateMM;
  Scope.Add('CreateNodes', vkExternFun).AsExternFun := @SF_CreateNodes;
  Scope.Add('CreateCustomCountableItem', vkExternFun).AsExternFun := @SF_CreateCustomCountableItem;
  Scope.Add('CreateZond', vkExternFun).AsExternFun := @SF_CreateZond;
  Scope.Add('ExistingZonds', vkExternFun).AsExternFun := @SF_ExistingZonds;
  Scope.Add('FreeItem', vkExternFun).AsExternFun := @SF_FreeItem;
  Scope.Add('ShipJoinsClan', vkExternFun).AsExternFun := @SF_ShipJoinsClan;
  Scope.Add('AddItemToShip', vkExternFun).AsExternFun := @SF_AddItemToShip;
  Scope.Add('GetItemFromShip', vkExternFun).AsExternFun := @SF_GetItemFromShip;
  Scope.Add('GetArtFromShip', vkExternFun).AsExternFun := @SF_GetArtFromShip;
  Scope.Add('ArrangeItems', vkExternFun).AsExternFun := @SF_ArrangeItems;
  Scope.Add('AddItemToPlanet', vkExternFun).AsExternFun := @SF_AddItemToPlanet;
  Scope.Add('GetItemFromPlanet', vkExternFun).AsExternFun := @SF_GetItemFromPlanet;
  Scope.Add('AddItemToShop', vkExternFun).AsExternFun := @SF_AddItemToShop;
  Scope.Add('GetItemFromShop', vkExternFun).AsExternFun := @SF_GetItemFromShop;
  Scope.Add('AddItemToStorage', vkExternFun).AsExternFun := @SF_AddItemToStorage;
  Scope.Add('GetItemFromStorage', vkExternFun).AsExternFun := @SF_GetItemFromStorage;
  Scope.Add('FindItemInStorage', vkExternFun).AsExternFun := @SF_FindItemInStorage;
  Scope.Add('PutItemInVault', vkExternFun).AsExternFun := @SF_PutItemInVault;
  Scope.Add('GetItemFromVault', vkExternFun).AsExternFun := @SF_GetItemFromVault;
  Scope.Add('DropItemInSystem', vkExternFun).AsExternFun := @SF_DropItemInSystem;
  Scope.Add('StopMovingItem', vkExternFun).AsExternFun := @SF_StopMovingItem;
  Scope.Add('StarItems', vkExternFun).AsExternFun := @SF_StarItems;
  Scope.Add('GetItemFromStar', vkExternFun).AsExternFun := @SF_GetItemFromStar;
  Scope.Add('PlanetItems', vkExternFun).AsExternFun := @SF_PlanetItems;
  Scope.Add('StorageItems', vkExternFun).AsExternFun := @SF_StorageItems;
  Scope.Add('StorageItemLocation', vkExternFun).AsExternFun := @SF_StorageItemLocation;
  Scope.Add('ShopItems', vkExternFun).AsExternFun := @SF_ShopItems;
  Scope.Add('AddDialogOverride', vkExternFun).AsExternFun := @SF_AddDialogOverride;
  Scope.Add('AddDialogInject', vkExternFun).AsExternFun := @SF_AddDialogInject;
  Scope.Add('InjectAnswer', vkExternFun).AsExternFun := @SF_InjectAnswer;
  Scope.Add('AddDialogBlock', vkExternFun).AsExternFun := @SF_AddDialogBlock;
  Scope.Add('GotoGov', vkExternFun).AsExternFun := @SF_GotoGov;
  Scope.Add('GetShipPlanet', vkExternFun).AsExternFun := @SF_GetShipPlanet;
  Scope.Add('GetShipHomePlanet', vkExternFun).AsExternFun := @SF_GetShipHomePlanet;
  Scope.Add('GetShipRuins', vkExternFun).AsExternFun := @SF_GetShipRuins;
  Scope.Add('GetTalkShip', vkExternFun).AsExternFun := @SF_GetTalkShip;
  Scope.Add('GetTalkType', vkExternFun).AsExternFun := @SF_GetTalkType;
  Scope.Add('TalkByAI', vkExternFun).AsExternFun := @SF_TalkByAI;
  Scope.Add('ScriptRun', vkExternFun).AsExternFun := @SF_ScriptRun;
  Scope.Add('CreateABShip', vkExternFun).AsExternFun := @SF_CreateABShip;
  Scope.Add('ConvertToABShip', vkExternFun).AsExternFun := @SF_ConvertToABShip;
  Scope.Add('ABShipModifiers', vkExternFun).AsExternFun := @SF_ABShipModifiers;
  Scope.Add('StartAB', vkExternFun).AsExternFun := @SF_StartAB;
  Scope.Add('StartTextQuest', vkExternFun).AsExternFun := @SF_StartTextQuest;
  Scope.Add('StartRobots', vkExternFun).AsExternFun := @SF_StartRobots;
  Scope.Add('MarkRobotsMapAsUsed', vkExternFun).AsExternFun := @SF_MarkRobotsMapAsUsed;
  Scope.Add('ShipOwner', vkExternFun).AsExternFun := @SF_ShipOwner;
  Scope.Add('ShipPilotRace', vkExternFun).AsExternFun := @SF_ShipPilotRace;
  Scope.Add('ShipSkill', vkExternFun).AsExternFun := @SF_ShipSkill;
  Scope.Add('ShipFace', vkExternFun).AsExternFun := @SF_ShipFace;
  Scope.Add('ShipFreeExp', vkExternFun).AsExternFun := @SF_ShipFreeExp;
  Scope.Add('GetShipExpByType', vkExternFun).AsExternFun := @SF_GetShipExpByType;
  Scope.Add('CoordX', vkExternFun).AsExternFun := @SF_CoordX;
  Scope.Add('CoordY', vkExternFun).AsExternFun := @SF_CoordY;
  Scope.Add('ShipSetCoords', vkExternFun).AsExternFun := @SF_ShipSetCoords;
  Scope.Add('ShipAngle', vkExternFun).AsExternFun := @SF_ShipAngle;
  Scope.Add('ObjectType', vkExternFun).AsExternFun := @SF_ObjectType;
  Scope.Add('ShipInHyperSpace', vkExternFun).AsExternFun := @SF_ShipInHyperSpace;
  Scope.Add('ShipStatus', vkExternFun).AsExternFun := @SF_ShipStatus;
  Scope.Add('BuyRanger', vkExternFun).AsExternFun := @SF_BuyRanger;
  Scope.Add('BuyWarrior', vkExternFun).AsExternFun := @SF_BuyWarrior;
  Scope.Add('BuyBigWarrior', vkExternFun).AsExternFun := @SF_BuyBigWarrior;
  Scope.Add('BuyDomik', vkExternFun).AsExternFun := @SF_BuyDomik;
  Scope.Add('BuyDomikExtremal', vkExternFun).AsExternFun := @SF_BuyDomikExtremal;
  Scope.Add('BuyTranclucator', vkExternFun).AsExternFun := @SF_BuyTranclucator;
  Scope.Add('TransferShip', vkExternFun).AsExternFun := @SF_TransferShip;
  Scope.Add('OrderForsage', vkExternFun).AsExternFun := @SF_OrderForsage;
  Scope.Add('OrderNone', vkExternFun).AsExternFun := @SF_OrderNone;
  Scope.Add('OrderMove', vkExternFun).AsExternFun := @SF_OrderMove;
  Scope.Add('OrderTeleport', vkExternFun).AsExternFun := @SF_OrderTeleport;
  Scope.Add('OrderTakeOff', vkExternFun).AsExternFun := @SF_OrderTakeOff;
  Scope.Add('OrderFollowShip', vkExternFun).AsExternFun := @SF_OrderFollowShip;
  Scope.Add('OrderJumpHole', vkExternFun).AsExternFun := @SF_OrderJumpHole;
  Scope.Add('RelationToRanger', vkExternFun).AsExternFun := @SF_RelationToRanger;
  Scope.Add('RelationToShip', vkExternFun).AsExternFun := @SF_RelationToShip;
  Scope.Add('StarOwner', vkExternFun).AsExternFun := @SF_StarOwner;
  Scope.Add('StarBattle', vkExternFun).AsExternFun := @SF_StarBattle;
  Scope.Add('StarSeries', vkExternFun).AsExternFun := @SF_StarSeries;
  Scope.Add('StarHoles', vkExternFun).AsExternFun := @SF_StarHoles;
  Scope.Add('StarNearbyStars', vkExternFun).AsExternFun := @SF_StarNearbyStars;
  Scope.Add('StarNearbyStarsDist', vkExternFun).AsExternFun := @SF_StarNearbyStarsDist;
  Scope.Add('StarSetGraph', vkExternFun).AsExternFun := @SF_StarSetGraph;
  Scope.Add('CreatePlanet', vkExternFun).AsExternFun := @SF_CreatePlanet;
  Scope.Add('PlanetSetGraph', vkExternFun).AsExternFun := @SF_PlanetSetGraph;
  Scope.Add('PlanetGetGraph', vkExternFun).AsExternFun := @SF_PlanetGetGraph;
  Scope.Add('PlanetPopulation', vkExternFun).AsExternFun := @SF_PlanetPopulation;
  Scope.Add('PlanetOwner', vkExternFun).AsExternFun := @SF_PlanetOwner;
  Scope.Add('PlanetRace', vkExternFun).AsExternFun := @SF_PlanetRace;
  Scope.Add('PlanetGov', vkExternFun).AsExternFun := @SF_PlanetGov;
  Scope.Add('PlanetEco', vkExternFun).AsExternFun := @SF_PlanetEco;
  Scope.Add('PlanetTerrain', vkExternFun).AsExternFun := @SF_PlanetTerrain;
  Scope.Add('PlanetTerrainExplored', vkExternFun).AsExternFun := @SF_PlanetTerrainExplored;
  Scope.Add('PlanetOrbitRadius', vkExternFun).AsExternFun := @SF_PlanetOrbitRadius;
  Scope.Add('PlanetOrbitalVelocity', vkExternFun).AsExternFun := @SF_PlanetOrbitalVelocity;
  Scope.Add('PlanetSize', vkExternFun).AsExternFun := @SF_PlanetSize;
  Scope.Add('PlanetCurInvention', vkExternFun).AsExternFun := @SF_PlanetCurInvention;
  Scope.Add('PlanetCurInventionPoints', vkExternFun).AsExternFun := @SF_PlanetCurInventionPoints;
  Scope.Add('PlanetInventionLevel', vkExternFun).AsExternFun := @SF_PlanetInventionLevel;
  Scope.Add('PlanetBoostInventions', vkExternFun).AsExternFun := @SF_PlanetBoostInventions;
  Scope.Add('PlanetWarriors', vkExternFun).AsExternFun := @SF_PlanetWarriors;
  Scope.Add('GalaxySectors', vkExternFun).AsExternFun := @SF_GalaxySectors;
  Scope.Add('GalaxyTechLevel', vkExternFun).AsExternFun := @SF_GalaxyTechLevel;
  Scope.Add('GalaxyDominatorResearchPercent', vkExternFun).AsExternFun := @SF_GalaxyDominatorResearchPercent;
  Scope.Add('GalaxyDominatorResearchMaterial', vkExternFun).AsExternFun := @SF_GalaxyDominatorResearchMaterial;
  Scope.Add('GalaxyDiffLevels', vkExternFun).AsExternFun := @SF_GalaxyDiffLevels;
  Scope.Add('SectorVisible', vkExternFun).AsExternFun := @SF_SectorVisible;
  Scope.Add('HullHP', vkExternFun).AsExternFun := @SF_HullHP;
  Scope.Add('HullDamageSuspectibility', vkExternFun).AsExternFun := @SF_HullDamageSuspectibility;
  Scope.Add('HullType', vkExternFun).AsExternFun := @SF_HullType;
  Scope.Add('HullSpecial', vkExternFun).AsExternFun := @SF_HullSpecial;
  Scope.Add('HullSeries', vkExternFun).AsExternFun := @SF_HullSeries;
  Scope.Add('GalaxyHoles', vkExternFun).AsExternFun := @SF_GalaxyHoles;
  Scope.Add('HoleCreate2', vkExternFun).AsExternFun := @SF_HoleCreate2;
  Scope.Add('HoleStar1', vkExternFun).AsExternFun := @SF_HoleStar1;
  Scope.Add('HoleStar2', vkExternFun).AsExternFun := @SF_HoleStar2;
  Scope.Add('HoleX1', vkExternFun).AsExternFun := @SF_HoleX1;
  Scope.Add('HoleY1', vkExternFun).AsExternFun := @SF_HoleY1;
  Scope.Add('HoleX2', vkExternFun).AsExternFun := @SF_HoleX2;
  Scope.Add('HoleY2', vkExternFun).AsExternFun := @SF_HoleY2;
  Scope.Add('HoleTurnCreate', vkExternFun).AsExternFun := @SF_HoleTurnCreate;
  Scope.Add('HoleMap', vkExternFun).AsExternFun := @SF_HoleMap;
  Scope.Add('HoleGraph', vkExternFun).AsExternFun := @SF_HoleGraph;
  Scope.Add('StarRuins', vkExternFun).AsExternFun := @SF_StarRuins;
  Scope.Add('CreateQuestItem', vkExternFun).AsExternFun := @SF_CreateQuestItem;
  Scope.Add('ShipOrder', vkExternFun).AsExternFun := @SF_ShipOrder;
  Scope.Add('ShipTurnBeforeEndOrder', vkExternFun).AsExternFun := @SF_ShipTurnBeforeEndOrder;
  Scope.Add('ShipOrderData1', vkExternFun).AsExternFun := @SF_ShipOrderData1;
  Scope.Add('ShipOrderData2', vkExternFun).AsExternFun := @SF_ShipOrderData2;
  Scope.Add('ShipOrderObj', vkExternFun).AsExternFun := @SF_ShipOrderObj;
  Scope.Add('ShipDestination', vkExternFun).AsExternFun := @SF_ShipDestination;
  Scope.Add('BuildRuins', vkExternFun).AsExternFun := @SF_BuildRuins;
  Scope.Add('BuildCustomRuins', vkExternFun).AsExternFun := @SF_BuildCustomRuins;
  Scope.Add('RuinsChangeType', vkExternFun).AsExternFun := @SF_RuinsChangeType;
  Scope.Add('ShipStanding', vkExternFun).AsExternFun := @SF_ShipStanding;
  Scope.Add('ShipSlots', vkExternFun).AsExternFun := @SF_ShipSlots;
  Scope.Add('MissileStar', vkExternFun).AsExternFun := @SF_MissileStar;
  Scope.Add('MissileType', vkExternFun).AsExternFun := @SF_MissileType;
  Scope.Add('CustomMissileType', vkExternFun).AsExternFun := @SF_CustomMissileType;
  Scope.Add('MissileOwner', vkExternFun).AsExternFun := @SF_MissileOwner;
  Scope.Add('MissileWeaponID', vkExternFun).AsExternFun := @SF_MissileWeaponID;
  Scope.Add('MissileTarget', vkExternFun).AsExternFun := @SF_MissileTarget;
  Scope.Add('MissileMaxDamage', vkExternFun).AsExternFun := @SF_MissileMaxDamage;
  Scope.Add('MissileMinDamage', vkExternFun).AsExternFun := @SF_MissileMinDamage;
  Scope.Add('MissileLive', vkExternFun).AsExternFun := @SF_MissileLive;
  Scope.Add('MissileSpeed', vkExternFun).AsExternFun := @SF_MissileSpeed;
  Scope.Add('MissileAngle', vkExternFun).AsExternFun := @SF_MissileAngle;
  Scope.Add('AsteroidMinerals', vkExternFun).AsExternFun := @SF_AsteroidMinerals;
  Scope.Add('AsteroidGraph', vkExternFun).AsExternFun := @SF_AsteroidGraph;
  Scope.Add('AsteroidRespawn', vkExternFun).AsExternFun := @SF_AsteroidRespawn;
  Scope.Add('ArrayAdd', vkExternFun).AsExternFun := @SF_ArrayAdd;
  Scope.Add('ArrayDelete', vkExternFun).AsExternFun := @SF_ArrayDelete;
  Scope.Add('ArrayClear', vkExternFun).AsExternFun := @SF_ArrayClear;
  Scope.Add('ArrayDim', vkExternFun).AsExternFun := @SF_ArrayDim;
  Scope.Add('ArraySort', vkExternFun).AsExternFun := @SF_ArraySort;
  Scope.Add('ArraySortPartial', vkExternFun).AsExternFun := @SF_ArraySortPartial;
  Scope.Add('ArrayRandomize', vkExternFun).AsExternFun := @SF_ArrayRandomize;
  Scope.Add('ArrayFind', vkExternFun).AsExternFun := @SF_ArrayFind;
  Scope.Add('ArrayFindInSorted', vkExternFun).AsExternFun := @SF_ArrayFindInSorted;
  Scope.Add('DistToNearestEnemySystem', vkExternFun).AsExternFun := @SF_DistToNearestEnemySystem;
  Scope.Add('StarEnemyThreatLevel', vkExternFun).AsExternFun := @SF_StarEnemyThreatLevel;
  Scope.Add('BuildListOfQuestPossibleLocations', vkExternFun).AsExternFun := @SF_BuildListOfQuestPossibleLocations;
  Scope.Add('FindItemInShip', vkExternFun).AsExternFun := @SF_FindItemInShip;
  Scope.Add('GalaxyRangers', vkExternFun).AsExternFun := @SF_GalaxyRangers;
  Scope.Add('MakeShipEnterStar', vkExternFun).AsExternFun := @SF_MakeShipEnterStar;
  Scope.Add('ShipGetBad', vkExternFun).AsExternFun := @SF_ShipGetBad;
  Scope.Add('ShipAddDropItem', vkExternFun).AsExternFun := @SF_ShipAddDropItem;
  Scope.Add('OrderLock', vkExternFun).AsExternFun := @SF_OrderLock;
  Scope.Add('BonusCount', vkExternFun).AsExternFun := @SF_BonusCount;
  Scope.Add('SeriesCount', vkExternFun).AsExternFun := @SF_SeriesCount;
  Scope.Add('BonusPriority', vkExternFun).AsExternFun := @SF_BonusPriority;
  Scope.Add('BonusIsSpecial', vkExternFun).AsExternFun := @SF_BonusIsSpecial;
  Scope.Add('BonusName', vkExternFun).AsExternFun := @SF_BonusName;
  Scope.Add('BonusNumInCfg', vkExternFun).AsExternFun := @SF_BonusNumInCfg;
  Scope.Add('SeriesNumInCfg', vkExternFun).AsExternFun := @SF_SeriesNumInCfg;
  Scope.Add('BonusValue', vkExternFun).AsExternFun := @SF_BonusValue;
  Scope.Add('FindBonusByName', vkExternFun).AsExternFun := @SF_FindBonusByName;
  Scope.Add('FindSeriesByName', vkExternFun).AsExternFun := @SF_FindSeriesByName;
  Scope.Add('FindBonusByCustomTag', vkExternFun).AsExternFun := @SF_FindBonusByCustomTag;
  Scope.Add('FindBonusByNameInCfg', vkExternFun).AsExternFun := @SF_FindBonusByNameInCfg;
  Scope.Add('BonusCustomTag', vkExternFun).AsExternFun := @SF_BonusCustomTag;
  Scope.Add('CreateEquipmentWithSpecial', vkExternFun).AsExternFun := @SF_CreateEquipmentWithSpecial;
  Scope.Add('SpecialToEquipment', vkExternFun).AsExternFun := @SF_SpecialToEquipment;
  Scope.Add('ModuleToEquipment', vkExternFun).AsExternFun := @SF_ModuleToEquipment;
  Scope.Add('EqSpecial', vkExternFun).AsExternFun := @SF_EqSpecial;
  Scope.Add('EqModule', vkExternFun).AsExternFun := @SF_EqModule;
  Scope.Add('MayAddBonusToEq', vkExternFun).AsExternFun := @SF_MayAddBonusToEq;
  Scope.Add('BuildListOfMMByPriority', vkExternFun).AsExternFun := @SF_BuildListOfMMByPriority;
  Scope.Add('BuildListOfNewShips', vkExternFun).AsExternFun := @SF_BuildListOfNewShips;
  Scope.Add('PlanetToStar', vkExternFun).AsExternFun := @SF_PlanetToStar;
  Scope.Add('Chameleon', vkExternFun).AsExternFun := @SF_Chameleon;
  Scope.Add('IsChameleon', vkExternFun).AsExternFun := @SF_IsChameleon;
  Scope.Add('PlayerChameleonCharges', vkExternFun).AsExternFun := @SF_PlayerChameleonCharges;
  Scope.Add('PlayerChameleonCurType', vkExternFun).AsExternFun := @SF_PlayerChameleonCurType;
  Scope.Add('PlayerChameleonDetected', vkExternFun).AsExternFun := @SF_PlayerChameleonDetected;
  Scope.Add('PlayerLogicChameleon', vkExternFun).AsExternFun := @SF_PlayerLogicChameleon;
  Scope.Add('SwitchToMirrorImage', vkExternFun).AsExternFun := @SF_SwitchToMirrorImage;
  Scope.Add('EquipmentImageName', vkExternFun).AsExternFun := @SF_EquipmentImageName;
  Scope.Add('StarFonImage', vkExternFun).AsExternFun := @SF_StarFonImage;
  Scope.Add('ExtremalTakeOff', vkExternFun).AsExternFun := @SF_ExtremalTakeOff;
  Scope.Add('ForceNextDay', vkExternFun).AsExternFun := @SF_ForceNextDay;
  Scope.Add('ScriptActionsRun', vkExternFun).AsExternFun := @SF_ScriptActionsRun;
  Scope.Add('StarListToPlanetList', vkExternFun).AsExternFun := @SF_StarListToPlanetList;
  Scope.Add('EndGame', vkExternFun).AsExternFun := @SF_EndGame;
  Scope.Add('CustomWin', vkExternFun).AsExternFun := @SF_CustomWin;
  Scope.Add('CustomLose', vkExternFun).AsExternFun := @SF_CustomLose;
  Scope.Add('PirateWin', vkExternFun).AsExternFun := @SF_PirateWin;
  Scope.Add('StartVideo', vkExternFun).AsExternFun := @SF_StartVideo;
  Scope.Add('StartMusic', vkExternFun).AsExternFun := @SF_StartMusic;
  Scope.Add('MusicControls', vkExternFun).AsExternFun := @SF_MusicControls;
  Scope.Add('NoComeKlingToStar', vkExternFun).AsExternFun := @SF_NoComeKlingToStar;
  Scope.Add('NoDropToShip', vkExternFun).AsExternFun := @SF_NoDropToShip;
  Scope.Add('NoTargetToShip', vkExternFun).AsExternFun := @SF_NoTargetToShip;
  Scope.Add('NoTalkToShip', vkExternFun).AsExternFun := @SF_NoTalkToShip;
  Scope.Add('NoScanToShip', vkExternFun).AsExternFun := @SF_NoScanToShip;
  Scope.Add('NoJump', vkExternFun).AsExternFun := @SF_NoJump;
  Scope.Add('NoLanding', vkExternFun).AsExternFun := @SF_NoLanding;
  Scope.Add('NoShopUpdate', vkExternFun).AsExternFun := @SF_NoShopUpdate;
  Scope.Add('PlanetExtraFlags', vkExternFun).AsExternFun := @SF_PlanetExtraFlags;
  Scope.Add('NoDropItem', vkExternFun).AsExternFun := @SF_NoDropItem;
  Scope.Add('CanSellItem', vkExternFun).AsExternFun := @SF_CanSellItem;
  Scope.Add('TruceBetweenShips', vkExternFun).AsExternFun := @SF_TruceBetweenShips;
  Scope.Add('ShipInPrison', vkExternFun).AsExternFun := @SF_ShipInPrison;
  Scope.Add('ShipPartners', vkExternFun).AsExternFun := @SF_ShipPartners;
  Scope.Add('PlayerPirates', vkExternFun).AsExternFun := @SF_PlayerPirates;
  Scope.Add('ShipIsPartner', vkExternFun).AsExternFun := @SF_ShipIsPartner;
  Scope.Add('ShipFreeSpace', vkExternFun).AsExternFun := @SF_ShipFreeSpace;
  Scope.Add('ShipWealth', vkExternFun).AsExternFun := @SF_ShipWealth;
  Scope.Add('DomiksDefeated', vkExternFun).AsExternFun := @SF_DomiksDefeated;
  Scope.Add('CoalitionDefeated', vkExternFun).AsExternFun := @SF_CoalitionDefeated;
  Scope.Add('ShipRefuel', vkExternFun).AsExternFun := @SF_ShipRefuel;
  Scope.Add('ShipRepairEq', vkExternFun).AsExternFun := @SF_ShipRepairEq;
  Scope.Add('ItemInScript', vkExternFun).AsExternFun := @SF_ItemInScript;
  Scope.Add('FindPlanetByAdvancement', vkExternFun).AsExternFun := @SF_FindPlanetByAdvancement;
  Scope.Add('StarListToTransitPlanetList', vkExternFun).AsExternFun := @SF_StarListToTransitPlanetList;
  Scope.Add('GalaxyEvents', vkExternFun).AsExternFun := @SF_GalaxyEvents;
  Scope.Add('GalaxyEventDate', vkExternFun).AsExternFun := @SF_GalaxyEventDate;
  Scope.Add('GalaxyEventType', vkExternFun).AsExternFun := @SF_GalaxyEventType;
  Scope.Add('GalaxyEventData', vkExternFun).AsExternFun := @SF_GalaxyEventData;
  Scope.Add('GalaxyEventsTextData', vkExternFun).AsExternFun := @SF_GalaxyEventsTextData;
  Scope.Add('PlanetNews', vkExternFun).AsExternFun := @SF_PlanetNews;
  Scope.Add('PlanetNewsDate', vkExternFun).AsExternFun := @SF_PlanetNewsDate;
  Scope.Add('PlanetNewsType', vkExternFun).AsExternFun := @SF_PlanetNewsType;
  Scope.Add('PlanetNewsText', vkExternFun).AsExternFun := @SF_PlanetNewsText;
  Scope.Add('ControlledSystems', vkExternFun).AsExternFun := @SF_ControlledSystems;
  Scope.Add('DeltaWin', vkExternFun).AsExternFun := @SF_DeltaWin;
  Scope.Add('ShipInFear', vkExternFun).AsExternFun := @SF_ShipInFear;
  Scope.Add('CreateGoods', vkExternFun).AsExternFun := @SF_CreateGoods;
  Scope.Add('GetNodesFromShip', vkExternFun).AsExternFun := @SF_GetNodesFromShip;
  Scope.Add('GetNodesFromStorage', vkExternFun).AsExternFun := @SF_GetNodesFromStorage;
  Scope.Add('RangerBaseNodes', vkExternFun).AsExternFun := @SF_RangerBaseNodes;
  Scope.Add('RuinsAllowModernization', vkExternFun).AsExternFun := @SF_RuinsAllowModernization;
  Scope.Add('RuinsMicromoduleChain', vkExternFun).AsExternFun := @SF_RuinsMicromoduleChain;
  Scope.Add('DomikKilledInCurSystem', vkExternFun).AsExternFun := @SF_DomikKilledInCurSystem;
  Scope.Add('ShipTypeN', vkExternFun).AsExternFun := @SF_ShipTypeN;
  Scope.Add('ShipSubType', vkExternFun).AsExternFun := @SF_ShipSubType;
  Scope.Add('ShipChangeStar', vkExternFun).AsExternFun := @SF_ShipChangeStar;
  Scope.Add('IsFilm', vkExternFun).AsExternFun := @SF_IsFilm;
  Scope.Add('FilmFlags', vkExternFun).AsExternFun := @SF_FilmFlags;
  Scope.Add('ShowEffect', vkExternFun).AsExternFun := @SF_ShowEffect;
  Scope.Add('ShowStaticEffect', vkExternFun).AsExternFun := @SF_ShowStaticEffect;
  Scope.Add('ShipConnect', vkExternFun).AsExternFun := @SF_ShipConnect;
  Scope.Add('FilmSound', vkExternFun).AsExternFun := @SF_FilmSound;
  Scope.Add('FireWeapon', vkExternFun).AsExternFun := @SF_FireWeapon;
  Scope.Add('WeaponHit', vkExternFun).AsExternFun := @SF_WeaponHit;
  Scope.Add('DealDamageToShip', vkExternFun).AsExternFun := @SF_DealDamageToShip;
  Scope.Add('LaunchMissile', vkExternFun).AsExternFun := @SF_LaunchMissile;
  Scope.Add('SpawnMissile', vkExternFun).AsExternFun := @SF_SpawnMissile;
  Scope.Add('BonusText', vkExternFun).AsExternFun := @SF_BonusText;
  Scope.Add('PlanetPirateClan', vkExternFun).AsExternFun := @SF_PlanetPirateClan;
  Scope.Add('Blazer', vkExternFun).AsExternFun := @SF_Blazer;
  Scope.Add('Keller', vkExternFun).AsExternFun := @SF_Keller;
  Scope.Add('Terron', vkExternFun).AsExternFun := @SF_Terron;
  Scope.Add('PirateType', vkExternFun).AsExternFun := @SF_PirateType;
  Scope.Add('PlayerQuestInProgress', vkExternFun).AsExternFun := @SF_PlayerQuestInProgress;
  Scope.Add('PlayerQuestsCompleted', vkExternFun).AsExternFun := @SF_PlayerQuestsCompleted;
  Scope.Add('QuestsStatusByNom', vkExternFun).AsExternFun := @SF_QuestsStatusByNom;
  Scope.Add('PlayerPlanetaryBattlesCompleted', vkExternFun).AsExternFun := @SF_PlayerPlanetaryBattlesCompleted;
  Scope.Add('PlayerMayTakeSubCrack', vkExternFun).AsExternFun := @SF_PlayerMayTakeSubCrack;
  Scope.Add('SubCrackCost', vkExternFun).AsExternFun := @SF_SubCrackCost;
  Scope.Add('ShipCalcParam', vkExternFun).AsExternFun := @SF_ShipCalcParam;
  Scope.Add('ShipRefit', vkExternFun).AsExternFun := @SF_ShipRefit;
  Scope.Add('ShipImproveItems', vkExternFun).AsExternFun := @SF_ShipImproveItems;
  Scope.Add('ItemImprovement', vkExternFun).AsExternFun := @SF_ItemImprovement;
  Scope.Add('ShipFreeFlight', vkExternFun).AsExternFun := @SF_ShipFreeFlight;
  Scope.Add('ShipKillFactionInCurSystem', vkExternFun).AsExternFun := @SF_ShipKillFactionInCurSystem;
  Scope.Add('CapitalShipStats', vkExternFun).AsExternFun := @SF_CapitalShipStats;
  Scope.Add('PlayerBridge', vkExternFun).AsExternFun := @SF_PlayerBridge;
  Scope.Add('PlayerDebt', vkExternFun).AsExternFun := @SF_PlayerDebt;
  Scope.Add('PlayerDebtDate', vkExternFun).AsExternFun := @SF_PlayerDebtDate;
  Scope.Add('PlayerDebtCnt', vkExternFun).AsExternFun := @SF_PlayerDebtCnt;
  Scope.Add('PlayerDeposit', vkExternFun).AsExternFun := @SF_PlayerDeposit;
  Scope.Add('PlayerDepositDate', vkExternFun).AsExternFun := @SF_PlayerDepositDate;
  Scope.Add('PlayerDepositDay', vkExternFun).AsExternFun := @SF_PlayerDepositDay;
  Scope.Add('PlayerDepositPercent', vkExternFun).AsExternFun := @SF_PlayerDepositPercent;
  Scope.Add('PlayerMedPolicy', vkExternFun).AsExternFun := @SF_PlayerMedPolicy;
  Scope.Add('ShipCustomShipInfosCount', vkExternFun).AsExternFun := @SF_ShipCustomShipInfosCount;
  Scope.Add('ShipAddCustomShipInfo', vkExternFun).AsExternFun := @SF_ShipAddCustomShipInfo;
  Scope.Add('ShipDeleteCustomShipInfo', vkExternFun).AsExternFun := @SF_ShipDeleteCustomShipInfo;
  Scope.Add('ShipFindCustomShipInfoByType', vkExternFun).AsExternFun := @SF_ShipFindCustomShipInfoByType;
  Scope.Add('ShipCustomShipInfoDescription', vkExternFun).AsExternFun := @SF_ShipCustomShipInfoDescription;
  Scope.Add('ShipCustomShipInfoData', vkExternFun).AsExternFun := @SF_ShipCustomShipInfoData;
  Scope.Add('ShipCustomShipInfoTextData', vkExternFun).AsExternFun := @SF_ShipCustomShipInfoTextData;
  Scope.Add('StarCustomStarInfosCount', vkExternFun).AsExternFun := @SF_StarCustomStarInfosCount;
  Scope.Add('StarAddCustomStarInfo', vkExternFun).AsExternFun := @SF_StarAddCustomStarInfo;
  Scope.Add('StarDeleteCustomStarInfo', vkExternFun).AsExternFun := @SF_StarDeleteCustomStarInfo;
  Scope.Add('StarFindCustomStarInfoByType', vkExternFun).AsExternFun := @SF_StarFindCustomStarInfoByType;
  Scope.Add('StarCustomStarInfoData', vkExternFun).AsExternFun := @SF_StarCustomStarInfoData;
  Scope.Add('ItemCanBeBroken', vkExternFun).AsExternFun := @SF_ItemCanBeBroken;
  Scope.Add('ItemFragility', vkExternFun).AsExternFun := @SF_ItemFragility;
  Scope.Add('ItemDurability', vkExternFun).AsExternFun := @SF_ItemDurability;
  Scope.Add('ItemLevel', vkExternFun).AsExternFun := @SF_ItemLevel;
  Scope.Add('ContainerFuel', vkExternFun).AsExternFun := @SF_ContainerFuel;
  Scope.Add('ItemCharge', vkExternFun).AsExternFun := @SF_ItemCharge;
  Scope.Add('MissilesToRearm', vkExternFun).AsExternFun := @SF_MissilesToRearm;
  Scope.Add('WeaponAmmunition', vkExternFun).AsExternFun := @SF_WeaponAmmunition;
  Scope.Add('WeaponMaxAmmunition', vkExternFun).AsExternFun := @SF_WeaponMaxAmmunition;
  Scope.Add('ShipSpecialBonuses', vkExternFun).AsExternFun := @SF_ShipSpecialBonuses;
  Scope.Add('ItemExtraSpecials', vkExternFun).AsExternFun := @SF_ItemExtraSpecials;
  Scope.Add('ItemExtraSpecialsCountByType', vkExternFun).AsExternFun := @SF_ItemExtraSpecialsCountByType;
  Scope.Add('ItemExtraSpecialsAddByType', vkExternFun).AsExternFun := @SF_ItemExtraSpecialsAddByType;
  Scope.Add('ItemExtraSpecialsDeleteByType', vkExternFun).AsExternFun := @SF_ItemExtraSpecialsDeleteByType;
  Scope.Add('ExecuteCodeFromString', vkExternFun).AsExternFun := @SF_ExecuteCodeFromString;
  Scope.Add('GenerateCodeStringFromBlock', vkExternFun).AsExternFun := @SF_GenerateCodeStringFromBlock;
  Scope.Add('ItemOnUseCode', vkExternFun).AsExternFun := @SF_ItemOnUseCode;
  Scope.Add('ItemOnActCode', vkExternFun).AsExternFun := @SF_ItemOnActCode;
  Scope.Add('CreateActCodeEvent', vkExternFun).AsExternFun := @SF_CreateActCodeEvent;
  Scope.Add('CurItem', vkExternFun).AsExternFun := @SF_CurItem;
  Scope.Add('CurInfo', vkExternFun).AsExternFun := @SF_CurInfo;
  Scope.Add('ScriptItemActShip', vkExternFun).AsExternFun := @SF_ScriptItemActShip;
  Scope.Add('ScriptItemActObject1', vkExternFun).AsExternFun := @SF_ScriptItemActObject1;
  Scope.Add('ScriptItemActObject2', vkExternFun).AsExternFun := @SF_ScriptItemActObject2;
  Scope.Add('ScriptItemActParam', vkExternFun).AsExternFun := @SF_ScriptItemActParam;
  Scope.Add('ScriptItemActionType', vkExternFun).AsExternFun := @SF_ScriptItemActionType;
  Scope.Add('OnUseCodeTranclucator', vkExternFun).AsExternFun := @SF_OnUseCodeTranclucator;
  Scope.Add('OnUseCodeTransmitter', vkExternFun).AsExternFun := @SF_OnUseCodeTransmitter;
  Scope.Add('OnUseCodeBlackHole', vkExternFun).AsExternFun := @SF_OnUseCodeBlackHole;
  Scope.Add('OnUseCodeMissileDef', vkExternFun).AsExternFun := @SF_OnUseCodeMissileDef;
  Scope.Add('MessageBox', vkExternFun).AsExternFun := @SF_MessageBox;
  Scope.Add('MessageBoxYesNo', vkExternFun).AsExternFun := @SF_MessageBoxYesNo;
  Scope.Add('CountBox', vkExternFun).AsExternFun := @SF_CountBox;
  Scope.Add('NumberBox', vkExternFun).AsExternFun := @SF_NumberBox;
  Scope.Add('TextBox', vkExternFun).AsExternFun := @SF_TextBox;
  Scope.Add('ListBox', vkExternFun).AsExternFun := @SF_ListBox;
  Scope.Add('FormCurShip', vkExternFun).AsExternFun := @SF_FormCurShip;
  Scope.Add('UselessItemText', vkExternFun).AsExternFun := @SF_UselessItemText;
  Scope.Add('UselessItemData', vkExternFun).AsExternFun := @SF_UselessItemData;
  Scope.Add('GetAchievementSHU', vkExternFun).AsExternFun := @SF_GetAchievementSHU;
  Scope.Add('GetAchievementGIRLSHIRE', vkExternFun).AsExternFun := @SF_GetAchievementGIRLSHIRE;
  Scope.Add('GetAchievementGIRLSQUEST', vkExternFun).AsExternFun := @SF_GetAchievementGIRLSQUEST;
  Scope.Add('GetAchievementPIRATEWIN', vkExternFun).AsExternFun := @SF_GetAchievementPIRATEWIN;
  Scope.Add('GetAchievementCOALLITION', vkExternFun).AsExternFun := @SF_GetAchievementCOALLITION;
  Scope.Add('GetAchievementHULL', vkExternFun).AsExternFun := @SF_GetAchievementHULL;
  Scope.Add('UICheckElement', vkExternFun).AsExternFun := @SF_UICheckElement;
  Scope.Add('InterfaceState', vkExternFun).AsExternFun := @SF_InterfaceState;
  Scope.Add('InterfaceText', vkExternFun).AsExternFun := @SF_InterfaceText;
  Scope.Add('InterfaceImage', vkExternFun).AsExternFun := @SF_InterfaceImage;
  Scope.Add('InterfacePos', vkExternFun).AsExternFun := @SF_InterfacePos;
  Scope.Add('InterfaceSize', vkExternFun).AsExternFun := @SF_InterfaceSize;
  Scope.Add('ButtonClick', vkExternFun).AsExternFun := @SF_ButtonClick;
  Scope.Add('SetFocus', vkExternFun).AsExternFun := @SF_SetFocus;
  Scope.Add('CurrentForm', vkExternFun).AsExternFun := @SF_CurrentForm;
  Scope.Add('FormShipCurItem', vkExternFun).AsExternFun := @SF_FormShipCurItem;
  Scope.Add('UpdateFormShip', vkExternFun).AsExternFun := @SF_UpdateFormShip;
  Scope.Add('FormChange', vkExternFun).AsExternFun := @SF_FormChange;
  Scope.Add('RunChildForm', vkExternFun).AsExternFun := @SF_RunChildForm;
  Scope.Add('OpenCustomForm', vkExternFun).AsExternFun := @SF_OpenCustomForm;
  Scope.Add('CloseCustomForm', vkExternFun).AsExternFun := @SF_CloseCustomForm;
  Scope.Add('CustomInterfaceState', vkExternFun).AsExternFun := @SF_CustomInterfaceState;
  Scope.Add('CustomInterfaceText', vkExternFun).AsExternFun := @SF_CustomInterfaceText;
  Scope.Add('CustomInterfaceImage', vkExternFun).AsExternFun := @SF_CustomInterfaceImage;
  Scope.Add('CustomInterfacePos', vkExternFun).AsExternFun := @SF_CustomInterfacePos;
  Scope.Add('CustomInterfacePosZ', vkExternFun).AsExternFun := @SF_CustomInterfacePosZ;
  Scope.Add('CustomInterfaceSize', vkExternFun).AsExternFun := @SF_CustomInterfaceSize;
  Scope.Add('StarMapCenterView', vkExternFun).AsExternFun := @SF_StarMapCenterView;
  Scope.Add('StarMapCurPosX', vkExternFun).AsExternFun := @SF_StarMapCurPosX;
  Scope.Add('StarMapCurPosY', vkExternFun).AsExternFun := @SF_StarMapCurPosY;
  Scope.Add('StarMapCustomSelectionMode', vkExternFun).AsExternFun := @SF_StarMapCustomSelectionMode;
  Scope.Add('StarMapBlinkingMessage', vkExternFun).AsExternFun := @SF_StarMapBlinkingMessage;
  Scope.Add('BlinkingWarning', vkExternFun).AsExternFun := @SF_BlinkingWarning;
  Scope.Add('CustomWeaponTypes', vkExternFun).AsExternFun := @SF_CustomWeaponTypes;
  Scope.Add('InventNewCustomWeapon', vkExternFun).AsExternFun := @SF_InventNewCustomWeapon;
  Scope.Add('GetCustomWeaponInfo', vkExternFun).AsExternFun := @SF_GetCustomWeaponInfo;
  Scope.Add('GetCustomWeaponData', vkExternFun).AsExternFun := @SF_GetCustomWeaponData;
  Scope.Add('GetCustomWeaponPrimaryDamageType', vkExternFun).AsExternFun := @SF_GetCustomWeaponPrimaryDamageType;
  Scope.Add('SetCustomWeaponAvailability', vkExternFun).AsExternFun := @SF_SetCustomWeaponAvailability;
  Scope.Add('SetCustomWeaponSE', vkExternFun).AsExternFun := @SF_SetCustomWeaponSE;
  Scope.Add('SetCustomWeaponPrimaryData', vkExternFun).AsExternFun := @SF_SetCustomWeaponPrimaryData;
  Scope.Add('SetCustomWeaponSizeAndCost', vkExternFun).AsExternFun := @SF_SetCustomWeaponSizeAndCost;
  Scope.Add('SetCustomWeaponDamageData', vkExternFun).AsExternFun := @SF_SetCustomWeaponDamageData;
  Scope.Add('SetCustomWeaponShotData', vkExternFun).AsExternFun := @SF_SetCustomWeaponShotData;
  Scope.Add('SetCustomMissileWeaponStats', vkExternFun).AsExternFun := @SF_SetCustomMissileWeaponStats;
  Scope.Add('StarCustomFaction', vkExternFun).AsExternFun := @SF_StarCustomFaction;
  Scope.Add('ShipCustomFaction', vkExternFun).AsExternFun := @SF_ShipCustomFaction;
  Scope.Add('EqCustomFaction', vkExternFun).AsExternFun := @SF_EqCustomFaction;
  Scope.Add('PlanetCustomFaction', vkExternFun).AsExternFun := @SF_PlanetCustomFaction;
  Scope.Add('ImportedFunction', vkExternFun).AsExternFun := @SF_ImportedFunction;
  Scope.Add('ImportAll', vkExternFun).AsExternFun := @SF_ImportAll;
  Scope.Add('GalaxyPtr', vkExternFun).AsExternFun := @SF_GalaxyPtr;
  Scope.Add('t_ArtDefToEnergy', vkInt).AsInteger := Ord(t_ArtDefToEnergy);
  Scope.Add('t_ArtEnergyPulse', vkInt).AsInteger := Ord(t_ArtEnergyPulse);
  Scope.Add('t_ArtEnergyDef', vkInt).AsInteger := Ord(t_ArtEnergyDef);
  Scope.Add('t_ArtSplinter', vkInt).AsInteger := Ord(t_ArtSplinter);
  Scope.Add('t_ArtDecelerate', vkInt).AsInteger := Ord(t_ArtDecelerate);
  Scope.Add('t_ArtMissileDef', vkInt).AsInteger := Ord(t_ArtMissileDef);
  Scope.Add('t_ArtForsage', vkInt).AsInteger := Ord(t_ArtForsage);
  Scope.Add('t_ArtWeaponToSpeed', vkInt).AsInteger := Ord(t_ArtWeaponToSpeed);
  Scope.Add('t_ArtGiperJump', vkInt).AsInteger := Ord(t_ArtGiperJump);
  Scope.Add('t_ArtBlackHole', vkInt).AsInteger := Ord(t_ArtBlackHole);
  Scope.Add('t_ArtDefToArms1', vkInt).AsInteger := Ord(t_ArtDefToArms1);
  Scope.Add('t_ArtDefToArms2', vkInt).AsInteger := Ord(t_ArtDefToArms2);
  Scope.Add('t_ArtArtefactor', vkInt).AsInteger := Ord(t_ArtArtefactor);
  Scope.Add('t_ArtBio', vkInt).AsInteger := Ord(t_ArtBio);
  Scope.Add('t_ArtPDTurret', vkInt).AsInteger := Ord(t_ArtPDTurret);
  Scope.Add('t_ArtFastRacks', vkInt).AsInteger := Ord(t_ArtFastRacks);
  Scope.Add('t_Cistern', vkInt).AsInteger := Ord(t_Cistern);
  Scope.Add('t_Satellite', vkInt).AsInteger := Ord(t_Satellite);
  Scope.Add('t_MicroModule', vkInt).AsInteger := Ord(t_MicroModule);
  Scope.Add('t_UselessCountableItem', vkInt).AsInteger := Ord(t_UselessCountableItem);
  Scope.Add('TalkMoney', vkInt).AsInteger := Ord(tkMoneyDemand);
  Scope.Add('TalkGoods', vkInt).AsInteger := Ord(tkGoodsDemand);
  Scope.Add('TalkTruce', vkInt).AsInteger := Ord(tkTruceOffer);
  Scope.Add('TalkAttack', vkInt).AsInteger := Ord(tkAttack);
  Scope.Add('TalkBreakPartner', vkInt).AsInteger := Ord(tkPartnerBreak);
  Scope.Add('TalkPartnerTheEnd', vkInt).AsInteger := Ord(tkPartnerEnd);
  Scope.Add('TalkPartnerRiot', vkInt).AsInteger := Ord(tkPartnerRiot);
  for BonusIndex := Low(TEquipmentBonusKind) to High(TEquipmentBonusKind) do
    Scope.Add(EquipmentBonusNames[BonusIndex], vkInt).AsInteger := Ord(BonusIndex);
  for ActionIndex := Low(TScriptActionType) to High(TScriptActionType) do
    Scope.Add(ScriptActionTypeNames[ActionIndex], vkInt).AsInteger := Ord(ActionIndex);
  ScriptRequestThread := TScriptThread.Create;
  ScriptRequestThread.SetPriority(ThreadPriorityBelowNormal);
  ScriptItemContextStack := TList.Create;
  ScriptItemInfoContextStack := TList.Create;
  ScriptActionShipStack := TList.Create;
  ScriptActionObject1Stack := TList.Create;
  ScriptActionObject2Stack := TList.Create;
  ScriptActionParamStack := TList.Create;
  ScriptActionTypeStack := TList.Create;
  QueuedTextQuests := TList.Create;
  QueuedArcadeBattles := TList.Create;
  QueuedPlanetaryBattles := TList.Create;
  QueuedVideos := TList.Create;
  StagedArcadeShips := TObjectList.Create;
end;

end.
