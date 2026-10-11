unit aNormalShip;

{$I GameOptions.inc}

interface

uses
  EC_Buf,
  EC_BlockPar,
  aGalaxyStruct,
  aConst,
  aGalaxy,
  aPlanet,
  aShip;

type

  TNormalShip = class;

  TAwardTypeMask = set of TAwardKind;

  TSystemKillCountArray = array[0..3] of Word;

  TSystemKillCounts = packed record
    Normal: Word;
    Dominator: Word;
    Pirate: Word;
    Custom: Word;
  end;

  TNormalShip = class(TShip)
    LastDockedPlanet: TPlanet;
    TotalShipKillCount: Integer;
    PirateKillCount: Integer;
    DominatorKillCount: Integer;
    LiberatedSystemCount: Integer;
    CivilianKillCount: Integer;
    MilitaryKillCount: Integer;
    RangerKillCount: Integer;
    CurrentSystemKills: TSystemKillCounts;
    PendingLiberationCeremonyPlanet: TPlanet;
    PendingLiberationContribution: Integer;
    Rank: TShipRank;
    RankPoints: Word;
    LastPlayerExtortionTurn: Integer;
    PirateRank: TShipRank;
    PirateRankPoints: Cardinal;
    procedure SaveToBuffer(Buffer: TBufEC); override;
    procedure LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy); override;
    procedure ResolveLoadedReferences(Galaxy: TGalaxy); override;
    procedure ClearObjectReferences; override;
    procedure SaveToBlock(Block: TBlockParEC); override;
    procedure LoadFromBlock(Block: TBlockParEC); override;
    procedure NextDay; override;
    procedure UpdateAfterburnerState; override;
    constructor Create;
    destructor Destroy; override;
    function CollectLiberationRewards: WideString;
    function AwardRandomMedal: WideString;
    procedure ProcessShipKill(Victim: TShip);
    procedure CheckKillCountAwards(Victim: TShip);
    procedure UpdateRelationsForNearbyCombat;
    function SelectAward(Owner: TOwnerId; Kinds: TAwardTypeMask; VictimTypes: TShipTypeMask): Byte;
    function GetAwardInfo(AwardId: Byte): TRewardInfo;
    function GetRankName: WideString;
    function GetRankLongName: WideString;
    function GetRankDescription: WideString;
    function GetNextRankName: WideString;
    function GetRankPointsToNextRank: Word;
    procedure AddRankPoints(Amount: Word);
    function TryPromoteRank: Boolean;
    function CanPromoteRank: Boolean;
    function GetPirateRankName: WideString;
    function GetPirateRankLongName: WideString;
    function GetPirateRankDescription: WideString;
    function GetNextPirateRankName: WideString;
    function GetPirateRankPointsToNextRank: Word;
    procedure AddPirateRankPoints(Amount: Cardinal);
    function TryPromotePirateRank: Boolean;
    function CanPromotePirateRank: Boolean;
    function SelectSituationalMessage(Automatic: Boolean): WideString;
    procedure TrainSkillsAutomatically;
  end;

procedure ProcessSystemLiberationRewards(SourceShip: TNormalShip; Star: TStar);

implementation

uses
  EC_Str,
  aGalaxyEvent,
  Classes,
  Achievements,
  aMyFunction,
  aRanger,
  GlobalsV,
  GR_Main,
  Math,
  SysUtils,
  aItem,
  aPlayer,
  aKling,
  aPirate,
  aTransport,
  aWarrior,
  aTranclucator,
  Globals;

constructor TNormalShip.Create;
begin
  inherited Create;
  TotalShipKillCount := 0;
  PirateKillCount := 0;
  DominatorKillCount := 0;
  LiberatedSystemCount := 0;
  CurrentSystemKills.Dominator := 0;
  CurrentSystemKills.Pirate := 0;
  CurrentSystemKills.Normal := 0;
  CurrentSystemKills.Custom := 0;
  PendingLiberationCeremonyPlanet := nil;
  PendingLiberationContribution := 0;
  Rank := 0;
  RankPoints := 0;
  LastDockedPlanet := nil;
  LastPlayerExtortionTurn := 0;
  PirateRank := 0;
  PirateRankPoints := 0;
end;

destructor TNormalShip.Destroy;
var
  Career: TRangerCareer;
begin
  for Career := Low(TRangerCareer) to High(TRangerCareer) do
    if Galaxy.EminentCareerShips[Career] = Self then
      Galaxy.EminentCareerShips[Career] := nil;
  inherited Destroy;
end;

procedure TNormalShip.SaveToBuffer(Buffer: TBufEC);
begin
  inherited SaveToBuffer(Buffer);
  Buffer.AddIntegerValue(TotalShipKillCount);
  Buffer.AddIntegerValue(PirateKillCount);
  Buffer.AddIntegerValue(DominatorKillCount);
  Buffer.AddIntegerValue(LiberatedSystemCount);
  Buffer.AddIntegerValue(CivilianKillCount);
  Buffer.AddIntegerValue(MilitaryKillCount);
  Buffer.AddIntegerValue(RangerKillCount);
  Buffer.AddWideChar(WideChar(CurrentSystemKills.Dominator));
  Buffer.AddWideChar(WideChar(CurrentSystemKills.Pirate));
  Buffer.AddWideChar(WideChar(CurrentSystemKills.Normal));
  Buffer.AddWideChar(WideChar(CurrentSystemKills.Custom));
  if PendingLiberationCeremonyPlanet = nil then
    Buffer.AddDWord(0)
  else
    Buffer.AddDWord(PendingLiberationCeremonyPlanet.Id);
  Buffer.AddIntegerValue(PendingLiberationContribution);
  Buffer.AddAnsiChar(AnsiChar(Rank));
  Buffer.AddWideChar(WideChar(RankPoints));
  Buffer.AddAnsiChar(AnsiChar(PirateRank));
  Buffer.AddDWord(PirateRankPoints);
  if LastDockedPlanet = nil then
    Buffer.AddDWord(0)
  else
    Buffer.AddDWord(LastDockedPlanet.Id);
  Buffer.AddIntegerValue(LastPlayerExtortionTurn);
end;

procedure TNormalShip.LoadFromBuffer(Buffer: TBufEC; Galaxy: TGalaxy);
begin
  inherited LoadFromBuffer(Buffer, Galaxy);
  if LoadedSaveVersion >= 57 then
  begin
    TotalShipKillCount := Buffer.GetInt32;
    PirateKillCount := Buffer.GetInt32;
    DominatorKillCount := Buffer.GetInt32;
    LiberatedSystemCount := Buffer.GetInt32;
    CivilianKillCount := Buffer.GetInt32;
    MilitaryKillCount := Buffer.GetInt32;
    RangerKillCount := Buffer.GetInt32;
  end
  else
  begin
    TotalShipKillCount := Buffer.GetWord;
    PirateKillCount := Buffer.GetWord;
    DominatorKillCount := Buffer.GetWord;
    LiberatedSystemCount := Buffer.GetWord;
    CivilianKillCount := Buffer.GetWord;
    MilitaryKillCount := Buffer.GetWord;
    RangerKillCount := Buffer.GetWord;
  end;
  CurrentSystemKills.Dominator := Buffer.GetWord;
  CurrentSystemKills.Pirate := Buffer.GetWord;
  CurrentSystemKills.Normal := Buffer.GetWord;
  if LoadedSaveVersion >= 153 then
    CurrentSystemKills.Custom := Buffer.GetWord;
  PendingLiberationCeremonyPlanet := TPlanet(Buffer.GetUInt32);
  if LoadedSaveVersion >= 80 then
    PendingLiberationContribution := Buffer.GetInt32
  else
    PendingLiberationContribution := 0;
  Rank := Buffer.GetByte;
  RankPoints := Buffer.GetWord;
  PirateRank := Buffer.GetByte;
  PirateRankPoints := Buffer.GetUInt32;
  if (LoadedSaveVersion < 126) and (Buffer.GetByte <> 0) then
    OwnerId := oiPirate;
  LastDockedPlanet := TPlanet(Buffer.GetUInt32);
  LastPlayerExtortionTurn := Buffer.GetInt32;
end;

procedure TNormalShip.ResolveLoadedReferences(Galaxy: TGalaxy);
begin
  inherited ResolveLoadedReferences(Galaxy);
  PendingLiberationCeremonyPlanet :=
      TObject(Galaxy.IdToPlanet(Cardinal(PendingLiberationCeremonyPlanet))) as TPlanet;
  LastDockedPlanet := TObject(Galaxy.IdToPlanet(Cardinal(LastDockedPlanet))) as TPlanet;
end;

procedure TNormalShip.ClearObjectReferences;
begin
  inherited ClearObjectReferences;
  PendingLiberationCeremonyPlanet := nil;
  LastDockedPlanet := nil;
end;

procedure TNormalShip.SaveToBlock(Block: TBlockParEC);
begin
  inherited SaveToBlock(Block);
  Block.AddParam(DecodeTextW('Roarnuke'), WideString(IntToStr(Rank))); // 'Rank'
  Block.AddParam(
      DecodeTextW('RearnaksProcitnotas'),
      WideString(IntToStr(RankPoints))
  ); // 'RankPoints'
  Block.AddParam(
      DecodeTextW('PlivroaktrenRiasnuk'),
      WideString(IntToStr(PirateRank))
  ); // 'PirateRank'
  Block.AddParam(
      DecodeTextW('PhilroaAtrelRoasnAkoPiopionatos'),
      WideString(IntToStr(PirateRankPoints))
  ); // 'PirateRankPoints'
end;

procedure TNormalShip.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  Rank := StrToInt(AnsiString(Block.GetParam(DecodeTextW('Roarnuke')))); // 'Rank'
  RankPoints :=
      StrToInt(AnsiString(Block.GetParam(DecodeTextW('RearnaksProcitnotas')))); // 'RankPoints'
  PirateRank :=
      StrToInt(AnsiString(Block.GetParam(DecodeTextW('PlivroaktrenRiasnuk')))); // 'PirateRank'
  PirateRankPoints :=
      Word(
          StrToInt(AnsiString(Block.GetParam(DecodeTextW('PhilroaAtrelRoasnAkoPiopionatos'))))
      ); // 'PirateRankPoints'
end;

procedure TNormalShip.NextDay;
var
  MessageText: WideString;
  Stage: Integer;
begin
  inherited NextDay;
  Stage := 0;
  try
    if InHyperspace then
    begin
      CurrentSystemKills.Dominator := 0;
      CurrentSystemKills.Pirate := 0;
      CurrentSystemKills.Normal := 0;
      CurrentSystemKills.Custom := 0;
    end;
    if (GetPlayer = Self) and not GetPlayer.ProcessPendingPlayerFollowTargeting then
      Exit;
    if (CurrentPlanet <> nil) and (PendingLiberationCeremonyPlanet = CurrentPlanet) then
      CollectLiberationRewards;
    Stage := 1;
    RecomputeFearState;
    if (GetPlayer <> nil)
        and (GetPlayer.CurrentStar = CurrentStar)
        and (Order <> soNone)
        and PlayerStarDayPrepared
        and (TurnsSinceLastShipMessage > 5)
        and (((Integer(Seed) * Galaxy.CurrentTurn) mod 7) = 0)
        and InNormalSpace
        and GetPlayer.InNormalSpace
        and (PointDistance(Position, GetPlayer.Position) < GetRadarRange)
        and not PlayerAutomaticControl
        and not GetPlayer.ProcessPendingPlayerFollowTargeting
        and (ScriptShip = nil)
        and (LiberationGroup = nil) then
    begin
      MessageText := SelectSituationalMessage(True);
      if MessageText <> '' then
        ShowMessageToPlayer(MessageText);
    end;
    Stage := 2;
    UpdateRelationsForNearbyCombat;
  except
    on E: Exception do
    begin
      AppendLogLineThreadSafe(E.ClassName + ' ' + E.Message);
      raise Exception.Create(
          'Error in procedure TNormalShip.NextDay '
              + GetFullName(' ')
              + ' label = '
              + IntToStr(Stage));
    end;
  end;
end;

function TNormalShip.CollectLiberationRewards: WideString;
const
  RewardPrograms = [prgShipwreck..prgDisconnection];
  RewardKinds = [atLiberation, atAccomplishment];
  RewardVictims = [stKling..rstCustomStation];
var
  I, MinimumPriority, RewardKind, Quantity, ModuleIndex, TotalPriority, Priority, Roll: Integer;
  CongratulationsCount: Integer;
  TextBlock: TBlockParEC;
  Prefix: WideString;
  Award: Byte;
  AwardWeight, ProgramWeight, ArtefactWeight, ModuleWeight: Single;
  RewardItem: TItem;
  ProgramIndex: TProgramIndex;
  ModuleItem: TMicroModule;
  Event: TGalaxyEvent;
begin
  if AwardIds = nil then
    AwardWeight := 80
  else
    AwardWeight := RemapClamped(AwardIds.Count, 0, 15, 80, 10);
  if (Self is TRanger) and (Self as TRanger).HasProgram(prgIntercom) then
    ProgramWeight :=
        RemapClamped((Self as TRanger).CountProgramsInFilter(RewardPrograms), 0, 10, 80, 10)
  else
    ProgramWeight := 0;
  if Self is TPlayer then
    ArtefactWeight := RemapClamped(Artefacts.Count, 0, 6, 80, 10)
  else
    ArtefactWeight := 0;
  if Self is TPlayer then
    ModuleWeight := RandomIntRange(10, 90)
  else
    ModuleWeight := 0;
  if (AwardWeight = 0) and (ProgramWeight = 0) and (ArtefactWeight = 0) and (ModuleWeight = 0) then
    ModuleWeight := 1;
  if AwardWeight > 0 then
    AwardWeight :=
        AwardWeight
            * SeededRandomIntRange(
                5,
                25,
                CurrentPlanet.GenerationSeed + Galaxy.CurrentTurn div 100 + 1667);
  if ProgramWeight > 0 then
    ProgramWeight :=
        ProgramWeight
            * SeededRandomIntRange(
                5,
                25,
                CurrentPlanet.GenerationSeed + Galaxy.CurrentTurn div 100 + 197673);
  if ArtefactWeight > 0 then
    ArtefactWeight :=
        ArtefactWeight
            * SeededRandomIntRange(
                5,
                25,
                CurrentPlanet.GenerationSeed + Galaxy.CurrentTurn div 100 + 719671);
  if ModuleWeight > 0 then
    ModuleWeight :=
        ModuleWeight
            * SeededRandomIntRange(
                5,
                25,
                CurrentPlanet.GenerationSeed + Galaxy.CurrentTurn div 107 + 1967);
  if (CurrentPlanet.OwnerId = oiPirate) and (AwardWeight > 0) then
    AwardWeight := 1;
  if (AwardWeight > 0)
      and (AwardWeight >= Max(ModuleWeight, Max(ProgramWeight, ArtefactWeight))) then
    RewardKind := 1
  else if (ProgramWeight > 0)
      and (ProgramWeight >= Max(ModuleWeight, Max(AwardWeight, ArtefactWeight))) then
    RewardKind := 2
  else if (ArtefactWeight > 0)
      and (ArtefactWeight >= Max(ModuleWeight, Max(AwardWeight, ProgramWeight))) then
    RewardKind := 3
  else if (ModuleWeight > 0)
      and (ModuleWeight >= Max(ArtefactWeight, Max(AwardWeight, ProgramWeight))) then
    RewardKind := 4
  else
  begin
    RaiseWideMessage('CongratulationsLiberator');
    RewardKind := 0;
  end;
  if GetPlayer = Self then
  begin
    if CurrentPlanet.OwnerId <> oiPirate then
    begin
      if CurrentPlanet.CurrentStar.PreviousControlFaction = sfDominators then
        Result :=
            LocalizedColorText(
                'PlanetCongratulations.LiberationStarNormalsFromKling.'
                    + OwnerToSys(CurrentPlanet.OwnerId)
                    + 'Text'
            )
      else
        Result :=
            LocalizedColorText(
                'PlanetCongratulations.LiberationStarNormalsFromPirateClan.'
                    + OwnerToSys(CurrentPlanet.OwnerId)
                    + 'Text'
            );
    end
    else
    begin
      if CurrentPlanet.CurrentStar.PreviousControlFaction = sfCoalition then
        Prefix := 'PlanetCongratulations.LiberationStarPirateClanFromNormals.'
      else
        Prefix := 'PlanetCongratulations.LiberationStarPirateClanFromKling.';
      TotalPriority := 0;
      // Native $73E713-$73E71F zeroes the frame, including I; both empty scans retain 0.
      I := 0;
      for I := 0 to StrToInt(LookupLocalizedTextByKey(Prefix + 'CongratulationsCount')) - 1 do
      begin
        TextBlock := LanguageDataConfig.FindBlockByPath(Prefix + IntToStr(I));
        if TextBlock <> nil then
        begin
          if TextBlock.CountParams('Priority') <= 0 then
            Priority := 10
          else
            Priority := StrToInt(LookupLocalizedTextByKey(Prefix + IntToStr(I) + '.Priority'));
          Inc(TotalPriority, Priority);
        end;
      end;
      Roll :=
          SeededRandomIntRange(
              1,
              TotalPriority,
              Integer(Seed) * ((Integer(Seed) + Galaxy.CurrentTurn) div 20)
          );
      CongratulationsCount := StrToInt(LookupLocalizedTextByKey(Prefix + 'CongratulationsCount'));
      // Native $73EEA1 leaves I untouched when there are no entries.
      // $73EF99 exhausts to CongratulationsCount; a priority match retains its index.
      if CongratulationsCount > 0 then
      begin
        I := 0;
        while I < CongratulationsCount do
        begin
          TextBlock := LanguageDataConfig.FindBlockByPath(Prefix + IntToStr(I));
          if TextBlock <> nil then
          begin
            if TextBlock.CountParams('Priority') <= 0 then
              Priority := 10
            else
              Priority := StrToInt(LookupLocalizedTextByKey(Prefix + IntToStr(I) + '.Priority'));
            Dec(TotalPriority, Priority);
            if Roll > TotalPriority then
              Break;
          end;
          Inc(I);
        end;
      end;
      Result := LocalizedColorText(Prefix + IntToStr(I) + '.Text');
    end;
  end
  else
    Result := '';
  if CurrentPlanet.OwnerId <> oiPirate then
    Prefix := 'PlanetCongratulations.LiberationAwardNormals.'
  else
    Prefix := 'PlanetCongratulations.LiberationAwardPirateClan.';
  case RewardKind of
    1:
    begin
      Award := SelectAward(RaceToOwner(CurrentPlanet.RaceId), RewardKinds, RewardVictims);
      AddAward(Award);
      if GetPlayer = Self then
      begin
        Result := Result + #13#10 + LocalizedColorText(Prefix + 'AddReward');
        ReplaceTextToken(Result, '<Reward>', GetAwardInfo(Award).Name, TextHighlightColorTag);
      end
      else
        Result := '';
    end;
    2:
      if Self is TRanger then
      begin
        ProgramIndex := (Self as TRanger).SelectRandomProgramIdFromFilter(RewardPrograms);
        Quantity :=
            SeededRandomIntRange(
                1,
                Round(
                    RemapClamped(
                        (Self as TRanger).CountProgramsInFilter(RewardPrograms),
                        2,
                        10,
                        GalaxyDifficultyTuning[Galaxy.DifficultyLevels[7]]
                            .MaximumQuestProgramRewardCount,
                        1
                    )
                ),
                Integer(ProgramIndex) + CurrentStar.GenerationSeed * (Galaxy.CurrentTurn div 25)
            );
        Inc((Self as TRanger).ProgramCounts[ProgramIndex], Quantity);
        if GetPlayer = Self then
        begin
          Result := Result + #13#10 + LocalizedColorText(Prefix + 'AddProgramms');
          ReplaceTextToken(
              Result,
              '<Programm>',
              (Self as TRanger).GetProgramName(ProgramIndex),
              TextHighlightColorTag
          );
          ReplaceTextToken(Result, '<Count>', IntToStr(Quantity), TextHighlightColorTag);
        end
        else
          Result := '';
      end;
    3:
    begin
      RewardItem :=
          CreateRandomLootItem(
              ilpReward,
              CurrentPlanet.OwnerId,
              (Integer(CurrentPlanet.GenerationSeed) + Galaxy.CurrentTurn) div 50 + 123424767
          );
      if RewardItem is TArtefactTranclucator then
        TTranclucator(TArtefactTranclucator(RewardItem).Ship).OwnerShip := Self;
      if RewardItem is TArtefact then
        Artefacts.Add(RewardItem)
      else
        Inventory.Add(RewardItem);
      if GetPlayer = Self then
      begin
        GetPlayer.ScriptItemsAct(satOnGovItemReward, RewardItem, nil, 0);
        Result :=
            Result
                + #13#10
                + LocalizedColorText(Prefix + 'AddArtefact')
                + #13#10
                + RewardItem.GetDescriptionText;
        ReplaceTextToken(Result, '<Artefact>', RewardItem.GetDisplayName, TextHighlightColorTag);
      end
      else
        Result := '';
    end;
    4:
    begin
      I := 0;
      repeat
        MinimumPriority := Round(RemapClamped(Galaxy.TechLevel, 3, 8, 70, 20));
        ModuleIndex :=
            Galaxy.SelectMicroModule(
                MinimumPriority,
                Min(MinimumPriority + 30, 100),
                Galaxy.CurrentTurn div 77 + 17 * I + CurrentPlanet.Id,
                CurrentPlanet
            );
        Inc(I);
        if I > 50 then
          Break;
      until GetPlayer.NeedsMicroModule(ModuleIndex + 1);
      ModuleItem := TMicroModule.Create;
      ModuleItem.Init(ModuleIndex);
      ModuleItem.OwnerId := CurrentPlanet.OwnerId;
      if GetPlayer = Self then
      begin
        GetPlayer.ScriptItemsAct(satOnGovItemReward, ModuleItem, nil, 0);
        Event := AddGalaxyEvent('PlayerReceivesMMAsReward');
        Event.AddData(ModuleItem.Id);
        Event.AddData(ModuleItem.MicroModuleIndex - 1);
      end;
      Inventory.Add(ModuleItem);
      if GetPlayer = Self then
      begin
        Result :=
            Result
                + #13#10
                + LocalizedColorText(Prefix + 'AddNod')
                + #13#10
                + ModuleItem.GetInfoText(TextHighlightColorTag, nil);
        ReplaceTextToken(
            Result,
            '<Nod>',
            MicroModuleTemplates[ModuleIndex].Name,
            TextHighlightColorTag
        );
      end
      else
        Result := '';
    end;
  end;
  I :=
      RoundAndTruncateToTens(
          SeededRandomIntRange(
                  250,
                  Galaxy.ScaleIntByTechLevel(500, 1000),
                  (Integer(CurrentPlanet.GenerationSeed) + Galaxy.CurrentTurn) div 100)
              + Ln(PendingLiberationContribution * 0.2 + 1) * 1000
      );
  GainExperience(I, esUnscaled);
  if GetPlayer = Self then
  begin
    Result :=
        Result
            + #13#10
            + ' '
            + #13#10
            + WrapTextInColor(LocalizedColorText(Prefix + 'AddPoints'), DarkGreenColorTag);
    ReplaceTextToken(Result, '<Points>', IntToStr(I), '');
  end
  else
    Result := '';
  if GetPlayer = Self then
  begin
    ReplaceTextToken(Result, '<Star>', CurrentPlanet.CurrentStar.Name, TextHighlightColorTag);
    ReplaceTextToken(Result, '<Planet>', CurrentPlanet.Name, TextHighlightColorTag);
  end;
  PendingLiberationCeremonyPlanet := nil;
  PendingLiberationContribution := 0;
end;

function TNormalShip.AwardRandomMedal: WideString;
var
  Award: Byte;
begin
  if CurrentPlanet <> nil then
    Award :=
        SelectAward(
            RaceToOwner(CurrentPlanet.RaceId),
            [atLiberation, atAccomplishment],
            [stKling..rstCustomStation]
        )
  else if DockedTo <> nil then
    Award :=
        SelectAward(
            RaceToOwner(DockedTo.PilotRace),
            [atLiberation, atAccomplishment],
            [stKling..rstCustomStation]
        )
  else
    Award := SelectAward(oiHuman, [atLiberation, atAccomplishment], [stKling..rstCustomStation]);
  AddAward(Award);
  Result := GetAwardInfo(Award).Name;
end;

procedure TNormalShip.ProcessShipKill(Victim: TShip);
var
  I, SharedExperience, ExperienceDelta, ActivityAmount: Integer;
  Experience, RankReward, PirateReward: Integer;
  SourceKind: TExperienceSource;
  OtherShip: TShip;
  OtherNormal: TNormalShip;
  Event: TGalaxyEvent;
  Quest: PQuest;
  QuestTargetKill: Boolean;

  procedure RecordShipKillCategory(
      Ship: TNormalShip;
      Victim: TShip
  ); { Nested helper; unused caller-popped static link. }
  begin
    case Victim.TypeId of
      stTransport:
        if Victim.OwnerId <> oiPirate then
        begin
          Inc(Ship.CivilianKillCount);
          if GetPlayer = Ship then
            TryAddAchievementProgress('BLACKHEAD', 1);
          Ship.CheckKillCountAwards(Victim);
        end;
      stWarrior:
      begin
        Inc(Ship.MilitaryKillCount);
        Ship.CheckKillCountAwards(Victim);
      end;
      stRanger:
        if ((Victim as TRanger).GetDominantCareer <> rcPirate)
            and (Victim.OwnerId <> oiPirate)
            and not (Victim as TRanger).ExcludedFromRating then
        begin
          Inc(Ship.RangerKillCount);
          Ship.CheckKillCountAwards(Victim);
        end;
    end;
  end;

begin
  if Self = Victim then
    Exit;
  SourceKind := esNormalShips;
  QuestTargetKill := False;
  if GetPlayer = Self then
  begin
    Event := AddGalaxyEvent('PlayerKillsShip');
    Event.AddData(Ord(Victim.TypeId));
    Event.AddData(Victim.CurrentStar.Id);
    Event.AddData(Victim.Id);
    Event.AddData(Ord(Victim.OwnerId));
    Event.AddTextData(Victim.GetName);
    Event.AddData(Victim.GetFullHullRelativeStrengthPercent);
    Event.AddTextData(Victim.GetFullName(' '));
    Event.AddTextData(Victim.TypeNameOverrideKey);
    if Victim is TKling then
      Event.AddData(Byte((Victim as TKling).KlingType))
    else if Victim is TTransport then
      Event.AddData(Byte((Victim as TTransport).TransportType))
    else if Victim is TWarrior then
      Event.AddData(Byte((Victim as TWarrior).WarriorType))
    else if Victim is TPirate then
      Event.AddData(Byte((Victim as TPirate).PirateType))
    else
      Event.AddData(0);
    for I := 0 to GetPlayer.Quests.Count - 1 do
    begin
      Quest := GetPlayer.Quests[I];
      if not Quest.Successful
          and (Quest.QuestType = qtKillShip)
          and (Quest.ObjectiveTarget = Victim) then
        QuestTargetKill := True;
    end;
  end;
  if GetPlayer = PartnerShip then
  begin
    Event := AddGalaxyEvent('PlayerCompanionKillsShip');
    Event.AddData(Ord(Victim.TypeId));
    Event.AddData(Victim.CurrentStar.Id);
    Event.AddData(Victim.Id);
    Event.AddData(Ord(Victim.OwnerId));
    Event.AddTextData(Victim.GetName);
    Event.AddData(Ord(Self.TypeId));
    Event.AddData(Self.Id);
    Event.AddData(Ord(Self.OwnerId));
    Event.AddTextData(Self.GetName);
    Event.AddData(Victim.GetFullHullRelativeStrengthPercent);
    Event.AddTextData(Victim.GetFullName(' '));
    Event.AddTextData(Victim.TypeNameOverrideKey);
    if Victim is TKling then
      Event.AddData(Byte((Victim as TKling).KlingType))
    else if Victim is TTransport then
      Event.AddData(Byte((Victim as TTransport).TransportType))
    else if Victim is TWarrior then
      Event.AddData(Byte((Victim as TWarrior).WarriorType))
    else if Victim is TPirate then
      Event.AddData(Byte((Victim as TPirate).PirateType))
    else
      Event.AddData(0);
  end;
  Experience := 0;
  RankReward := 0;
  PirateReward := 0;
  Inc(TotalShipKillCount);
  if CurrentStanding = ssCustom then
    Exit;
  if Victim.CurrentStanding = ssCustom then
  begin
    IncrementWordSaturating(CurrentSystemKills.Custom);
    RankReward := 10;
    Experience := NextRandomIntRange(250, 500, Galaxy.RandomState);
    SourceKind := esUnscaled;
    if Self is TRanger then
    begin
      if GetPlayer = Self then
        ActivityAmount := 4
      else
        ActivityAmount := 8;
      if Galaxy.CoalitionDefeatedTurn = 0 then
        (Self as TRanger).AddWarriorCareerActivity(Byte(ActivityAmount));
    end;
    if (PartnerShip <> nil)
        and (PartnerShip is TNormalShip)
        and (PartnerShip.CurrentStar = CurrentStar)
        and PartnerShip.InNormalSpace then
      (PartnerShip as TNormalShip).AddRankPoints(6);
    if OwnerId = oiPirate then
      PirateReward := 8;
  end
  else if (Victim.TypeId = stTransport) and (Self is TRanger) then
  begin
    if not QuestTargetKill then
      IncrementWordSaturating(CurrentSystemKills.Normal);
    if (PartnerShip <> nil)
        and (PartnerShip is TNormalShip)
        and (PartnerShip.CurrentStar = CurrentStar)
        and PartnerShip.InNormalSpace
        and ((PartnerShip as TNormalShip).CurrentSystemKills.Normal = 0) then
      Inc(TNormalShip(PartnerShip).CurrentSystemKills.Normal);
    Experience :=
        Round(
            NextRandomIntRange(100, 250, Galaxy.RandomState)
                * (Ord(TNormalShip(Victim).Rank) * 0.1 + 1)
        );
    if OwnerId = oiPirate then
    begin
      PirateReward := 8;
      Experience := Round(Experience * 1.5);
    end;
    if GetPlayer = Self then
      ActivityAmount := 4
    else
      ActivityAmount := 1;
    (Self as TRanger).AddPirateCareerActivity(Byte(ActivityAmount));
  end
  else if (Victim is TRanger) and (Self is TRanger) then
  begin
    if (Victim as TRanger).GetDominantCareer = rcPirate then
    begin
      SourceKind := esPirates;
      RankReward := 10;
      (Self as TRanger).AddWarriorCareerActivity(4);
      Experience :=
          Round(
              NextRandomIntRange(250, 500, Galaxy.RandomState)
                  * (Ord(TNormalShip(Victim).PirateRank) * 0.1 + 1)
          );
    end
    else
    begin
      if not QuestTargetKill then
      begin
        IncrementWordSaturating(CurrentSystemKills.Normal);
        if (PartnerShip <> nil)
            and (PartnerShip is TNormalShip)
            and (PartnerShip.CurrentStar = CurrentStar)
            and PartnerShip.InNormalSpace
            and ((PartnerShip as TNormalShip).CurrentSystemKills.Normal = 0) then
          Inc(TNormalShip(PartnerShip).CurrentSystemKills.Normal);
      end;
      if GetPlayer = Self then
        ActivityAmount := 8
      else
        ActivityAmount := 2;
      (Self as TRanger).AddPirateCareerActivity(Byte(ActivityAmount));
      Experience :=
          Round(
              NextRandomIntRange(100, 250, Galaxy.RandomState)
                  * (Ord(TNormalShip(Victim).Rank) * 0.1 + 1)
          );
      if OwnerId = oiPirate then
      begin
        PirateReward := 24;
        Experience := Round(Experience * 1.5);
      end;
    end;
  end
  else if (Victim is TRanger) and (Self is TPirate) then
  begin
    if TRanger(Victim).GetDominantCareer <> rcPirate then
    begin
      Inc(CurrentSystemKills.Normal);
      if (PartnerShip <> nil)
          and (PartnerShip is TNormalShip)
          and (PartnerShip.CurrentStar = CurrentStar)
          and PartnerShip.InNormalSpace
          and ((PartnerShip as TNormalShip).CurrentSystemKills.Normal = 0) then
        Inc(TNormalShip(PartnerShip).CurrentSystemKills.Normal);
      PirateReward := 24;
    end;
  end
  else if Victim is TPirate then
  begin
    SourceKind := esPirates;
    if (Victim.OwnerId = oiPirate) and not QuestTargetKill then
    begin
      IncrementWordSaturating(CurrentSystemKills.Pirate);
      if (PartnerShip <> nil)
          and (PartnerShip is TNormalShip)
          and (PartnerShip.CurrentStar = CurrentStar)
          and PartnerShip.InNormalSpace
          and ((PartnerShip as TNormalShip).CurrentSystemKills.Pirate = 0) then
        Inc(TNormalShip(PartnerShip).CurrentSystemKills.Pirate);
    end;
    Inc(PirateKillCount);
    if GetPlayer = Self then
      TryAddAchievementProgress('SHIELD', 1);
    Experience :=
        Round(
            NextRandomIntRange(250, 500, Galaxy.RandomState)
                * (Ord(TNormalShip(Victim).PirateRank) * 0.1 + 1)
        );
    RankReward := 10;
    if OwnerId = oiPirate then
      Experience := Experience div 2;
    if Self is TRanger then
      (Self as TRanger).AddWarriorCareerActivity(4);
  end
  else if Victim is TKling then
  begin
    Inc(DominatorKillCount);
    if GetPlayer = Self then
      Inc(GetPlayer.DominatorKillsByType[(Victim as TKling).KlingType]);
    IncrementWordSaturating(CurrentSystemKills.Dominator);
    RankReward := DominatorShipDefinitions[(Victim as TKling).KlingType].RankPoints;
    Experience :=
        Round(
            DominatorShipDefinitions[(Victim as TKling).KlingType].KillExperience
                * Galaxy.GetDominatorKillExperienceScale
        );
    SourceKind := esDominators;
    if Self is TRanger then
    begin
      if GetPlayer = Self then
        ActivityAmount := 4
      else
        ActivityAmount := 8;
      if Galaxy.CoalitionDefeatedTurn = 0 then
        (Self as TRanger).AddWarriorCareerActivity(Byte(ActivityAmount));
      if GetPlayer = Self then
        GetPlayer.TryAwardDominatorPrograms(Victim);
      if (GetPlayer = Self) and GetPlayer.HasRadiationSickness then
        Experience := Round(GetPlayer.RadiationHealth[1].Progress * Experience);
    end;
    if (PartnerShip <> nil)
        and (PartnerShip is TNormalShip)
        and (PartnerShip.CurrentStar = CurrentStar)
        and PartnerShip.InNormalSpace then
    begin
      (PartnerShip as TNormalShip)
          .AddRankPoints(
              DominatorShipDefinitions[(Victim as TKling).KlingType].RankPoints div 2 + 1);
      if (PartnerShip as TNormalShip).CurrentSystemKills.Dominator = 0 then
        Inc(TNormalShip(PartnerShip).CurrentSystemKills.Dominator);
    end;
    if OwnerId = oiPirate then
      PirateReward := DominatorShipDefinitions[(Victim as TKling).KlingType].PirateRankPoints;
  end
  else if Victim is TWarrior then
  begin
    IncrementWordSaturating(CurrentSystemKills.Normal);
    if (PartnerShip <> nil)
        and (PartnerShip is TNormalShip)
        and (PartnerShip.CurrentStar = CurrentStar)
        and PartnerShip.InNormalSpace
        and ((PartnerShip as TNormalShip).CurrentSystemKills.Normal = 0) then
      Inc(TNormalShip(PartnerShip).CurrentSystemKills.Normal);
    if OwnerId = oiPirate then
    begin
      Experience :=
          Round(
              NextRandomIntRange(250, 500, Galaxy.RandomState)
                  * (Ord(TNormalShip(Victim).Rank) * 0.1 + 1)
          );
      if (Victim as TWarrior).WarriorType = wtFlagship then
      begin
        Experience := Experience * 2;
        PirateReward := 60;
      end
      else
        PirateReward := 16;
    end;
    if Self is TRanger then
    begin
      if GetPlayer = Self then
        ActivityAmount := 8
      else
        ActivityAmount := 2;
      (Self as TRanger).AddPirateCareerActivity(Byte(ActivityAmount));
    end;
  end
  else if Victim.TypeId = stTransport then
  begin
    IncrementWordSaturating(CurrentSystemKills.Normal);
    if (PartnerShip <> nil)
        and (PartnerShip is TNormalShip)
        and (PartnerShip.CurrentStar = CurrentStar)
        and PartnerShip.InNormalSpace
        and ((PartnerShip as TNormalShip).CurrentSystemKills.Normal = 0) then
      Inc(TNormalShip(PartnerShip).CurrentSystemKills.Normal);
    if OwnerId = oiPirate then
      PirateReward := 8;
  end
  else if (Victim.TypeId in [rstRangerCenter..rstCustomStation])
      and (Victim.CurrentStanding = ssCoalitionMilitary) then
  begin
    IncrementWordSaturating(CurrentSystemKills.Normal);
    if (PartnerShip <> nil)
        and (PartnerShip is TNormalShip)
        and (PartnerShip.CurrentStar = CurrentStar)
        and PartnerShip.InNormalSpace
        and ((PartnerShip as TNormalShip).CurrentSystemKills.Normal = 0) then
      Inc(TNormalShip(PartnerShip).CurrentSystemKills.Normal);
    if OwnerId = oiPirate then
      PirateReward := 32;
    if Self is TRanger then
    begin
      if GetPlayer = Self then
        ActivityAmount := 8
      else
        ActivityAmount := 2;
      (Self as TRanger).AddPirateCareerActivity(Byte(ActivityAmount));
    end;
  end
  else if (Victim.TypeId in [rstRangerCenter..rstCustomStation])
      and (Victim.CurrentStanding = ssCoalitionActive) then
  begin
    Inc(CurrentSystemKills.Normal);
    if (PartnerShip <> nil)
        and (PartnerShip is TNormalShip)
        and (PartnerShip.CurrentStar = CurrentStar)
        and PartnerShip.InNormalSpace
        and ((PartnerShip as TNormalShip).CurrentSystemKills.Normal = 0) then
      Inc(TNormalShip(PartnerShip).CurrentSystemKills.Normal);
    if OwnerId = oiPirate then
      PirateReward := 24;
    if Self is TRanger then
    begin
      if GetPlayer = Self then
        ActivityAmount := 4
      else
        ActivityAmount := 1;
      (Self as TRanger).AddPirateCareerActivity(Byte(ActivityAmount));
    end;
  end
  else if (Victim.TypeId in [rstRangerCenter..rstCustomStation])
      and (Victim.CurrentStanding in [ssCoalitionPassive..ssPiratePassive]) then
  begin
    if CurrentStar.ControlFaction = sfCoalition then
    begin
      IncrementWordSaturating(CurrentSystemKills.Normal);
      if (PartnerShip <> nil)
          and (PartnerShip is TNormalShip)
          and (PartnerShip.CurrentStar = CurrentStar)
          and PartnerShip.InNormalSpace
          and ((PartnerShip as TNormalShip).CurrentSystemKills.Normal = 0) then
        Inc(TNormalShip(PartnerShip).CurrentSystemKills.Normal);
    end;
    if CurrentStar.ControlFaction = sfPirates then
    begin
      IncrementWordSaturating(CurrentSystemKills.Pirate);
      if (PartnerShip <> nil)
          and (PartnerShip is TNormalShip)
          and (PartnerShip.CurrentStar = CurrentStar)
          and PartnerShip.InNormalSpace
          and ((PartnerShip as TNormalShip).CurrentSystemKills.Pirate = 0) then
        Inc(TNormalShip(PartnerShip).CurrentSystemKills.Pirate);
    end;
    if (Victim.TypeId <> rstPirateBase) and (Self is TRanger) then
    begin
      if GetPlayer = Self then
        ActivityAmount := 4
      else
        ActivityAmount := 1;
      (Self as TRanger).AddPirateCareerActivity(Byte(ActivityAmount));
    end;
    if (Victim.TypeId = rstPirateBase) and (Self is TRanger) then
    begin
      if GetPlayer = Self then
        ActivityAmount := 4
      else
        ActivityAmount := 1;
      (Self as TRanger).AddWarriorCareerActivity(Byte(ActivityAmount));
    end;
  end
  else if (Victim.TypeId in [rstRangerCenter..rstCustomStation])
      and (Victim.CurrentStanding in [ssPirateActive..ssPirateMilitary]) then
  begin
    if CurrentStar.ControlFaction = sfPirates then
    begin
      IncrementWordSaturating(CurrentSystemKills.Pirate);
      if (PartnerShip <> nil)
          and (PartnerShip is TNormalShip)
          and (PartnerShip.CurrentStar = CurrentStar)
          and PartnerShip.InNormalSpace
          and ((PartnerShip as TNormalShip).CurrentSystemKills.Pirate = 0) then
        Inc(TNormalShip(PartnerShip).CurrentSystemKills.Pirate);
    end;
    if Self is TRanger then
    begin
      if GetPlayer = Self then
        ActivityAmount := 4
      else
        ActivityAmount := 1;
      (Self as TRanger).AddWarriorCareerActivity(Byte(ActivityAmount));
    end;
  end;
  if Victim.CurrentStanding <> ssCustom then
  begin
    if (GetPlayer = Self) and (GetPlayer.PirateLicenseTicks > 0) then
    begin
      if Victim is TWarrior then
      begin
        if (Victim as TWarrior).WarriorType = wtFlagship then
          Inc(GetPlayer.PirateLicenseCash, Round(Galaxy.AverageRangerCapital / 2000))
        else
          Inc(GetPlayer.PirateLicenseCash, Round(Galaxy.AverageRangerCapital / 6000));
      end;
      if Victim.TypeId = rstMilitaryBase then
        Inc(GetPlayer.PirateLicenseCash, Round(Galaxy.AverageRangerCapital / 2000));
    end;
    if (GetPlayer = Self) and (CurrentStar.ControlFaction = sfCoalition) then
      GetPlayer.AchievementStats.CheckHaterAchievement;
    RecordShipKillCategory(Self, Victim);
  end;
  if Self is TPirate then
    (Self as TPirate).RaidPressure := 0;
  if (RankReward > 0) or (Experience > 0) or (PirateReward > 0) then
  begin
    if RankReward > 0 then
    begin
      if OwnerId <> oiPirate then
        AddRankPoints(Word(RankReward));
      RankReward := RankReward div 2 + 1;
    end;
    if Experience > 0 then
    begin
      GainExperience(Experience, SourceKind);
      if (PartnerShip <> nil)
          and (PartnerShip.CurrentStar = CurrentStar)
          and PartnerShip.InNormalSpace then
      begin
        SharedExperience :=
            Round(
                Experience
                    * LeadershipExperiencePercent[PartnerShip.GetEffectiveSkillLevel(psLeadership)]
                    * 0.01
            );
        if GetPlayer = PartnerShip then
        begin
          Event := AddGalaxyEvent('PlayerGotExpFromPartner');
          Event.AddData(Id);
          Event.AddData(PartnerShip.GetEffectiveSkillLevel(psLeadership));
          if SourceKind = esDominators then
            ExperienceDelta := GetPlayer.ExperienceByDominators
          else if SourceKind = esPirates then
            ExperienceDelta := GetPlayer.ExperienceByPirates
          else if SourceKind = esNormalShips then
            ExperienceDelta := GetPlayer.ExperienceByNormals
          else
            ExperienceDelta := 0;
          GetPlayer.GainExperience(SharedExperience, SourceKind);
          if SourceKind = esDominators then
            ExperienceDelta := GetPlayer.ExperienceByDominators - ExperienceDelta
          else if SourceKind = esPirates then
            ExperienceDelta := GetPlayer.ExperienceByPirates - ExperienceDelta
          else if SourceKind = esNormalShips then
            ExperienceDelta := GetPlayer.ExperienceByNormals - ExperienceDelta;
          Event.AddData(Ord(SourceKind));
          Event.AddData(SharedExperience);
          Event.AddData(ExperienceDelta);
        end
        else
          (PartnerShip as TNormalShip).GainExperience(SharedExperience, SourceKind);
      end;
      Experience := Experience div 2 + 1;
    end;
    if PirateReward > 0 then
    begin
      if OwnerId = oiPirate then
        AddPirateRankPoints(PirateReward);
      PirateReward := PirateReward div 2 + 1;
    end;
    for I := 0 to CurrentStar.Ships.Count - 1 do
    begin
      OtherShip := CurrentStar.Ships[I];
      if (OtherShip = Self)
          or not OtherShip.InNormalSpace
          or not OtherShip.IsAttackingShip(Victim) then
        Continue;
      if (OtherShip is TTranclucator) and (GetPlayer = TTranclucator(OtherShip).OwnerShip) then
      begin
        Event := AddGalaxyEvent('PlayerTranclucatorAssistKillsShip');
        Event.AddData(Ord(Victim.TypeId));
        Event.AddData(Victim.CurrentStar.Id);
        Event.AddData(Victim.Id);
        Event.AddData(Ord(Victim.OwnerId));
        Event.AddTextData(Victim.GetName);
        Event.AddData(OtherShip.Id);
        Event.AddData(Ord(OtherShip.OwnerId));
        Event.AddTextData(OtherShip.GetName);
        Event.AddData(Victim.GetFullHullRelativeStrengthPercent);
        Event.AddTextData(Victim.GetFullName(' '));
        Event.AddTextData(Victim.TypeNameOverrideKey);
        if Victim is TKling then
          Event.AddData(Byte((Victim as TKling).KlingType))
        else if Victim is TTransport then
          Event.AddData(Byte((Victim as TTransport).TransportType))
        else if Victim is TWarrior then
          Event.AddData(Byte((Victim as TWarrior).WarriorType))
        else if Victim is TPirate then
          Event.AddData(Byte((Victim as TPirate).PirateType))
        else
          Event.AddData(0);
      end;
      if not (OtherShip is TNormalShip) then
        Continue;
      OtherNormal := TNormalShip(OtherShip);
      if GetPlayer = OtherShip then
      begin
        Event := AddGalaxyEvent('PlayerAssistKillsShip');
        Event.AddData(Ord(Victim.TypeId));
        Event.AddData(Victim.CurrentStar.Id);
        Event.AddData(Victim.Id);
        Event.AddData(Ord(Victim.OwnerId));
        Event.AddTextData(Victim.GetName);
        Event.AddData(Victim.GetFullHullRelativeStrengthPercent);
        Event.AddTextData(Victim.GetFullName(' '));
        Event.AddTextData(Victim.TypeNameOverrideKey);
        if Victim is TKling then
          Event.AddData(Byte((Victim as TKling).KlingType))
        else if Victim is TTransport then
          Event.AddData(Byte((Victim as TTransport).TransportType))
        else if Victim is TWarrior then
          Event.AddData(Byte((Victim as TWarrior).WarriorType))
        else if Victim is TPirate then
          Event.AddData(Byte((Victim as TPirate).PirateType))
        else
          Event.AddData(0);
      end;
      if GetPlayer = OtherShip.PartnerShip then
      begin
        Event := AddGalaxyEvent('PlayerCompanionAssistKillsShip');
        Event.AddData(Ord(Victim.TypeId));
        Event.AddData(Victim.CurrentStar.Id);
        Event.AddData(Victim.Id);
        Event.AddData(Ord(Victim.OwnerId));
        Event.AddTextData(Victim.GetName);
        Event.AddData(Ord(OtherShip.TypeId));
        Event.AddData(OtherShip.Id);
        Event.AddData(Ord(OtherShip.OwnerId));
        Event.AddTextData(OtherShip.GetName);
        Event.AddData(Victim.GetFullHullRelativeStrengthPercent);
        Event.AddTextData(Victim.GetFullName(' '));
        Event.AddTextData(Victim.TypeNameOverrideKey);
        if Victim is TKling then
          Event.AddData(Byte((Victim as TKling).KlingType))
        else if Victim is TTransport then
          Event.AddData(Byte((Victim as TTransport).TransportType))
        else if Victim is TWarrior then
          Event.AddData(Byte((Victim as TWarrior).WarriorType))
        else if Victim is TPirate then
          Event.AddData(Byte((Victim as TPirate).PirateType))
        else
          Event.AddData(0);
      end;
      if OtherNormal is TPirate then
        (OtherNormal as TPirate).RaidPressure := 0;
      if (RankReward > 0) and (OtherNormal.OwnerId <> oiPirate) then
        OtherNormal.AddRankPoints(Word(RankReward));
      if Experience > 0 then
        OtherNormal.GainExperience(Experience, SourceKind);
      if (PirateReward > 0) and (OtherNormal.OwnerId = oiPirate) then
        OtherNormal.AddPirateRankPoints(PirateReward);
      Inc(OtherNormal.TotalShipKillCount);
      if Victim.CurrentStanding = ssCustom then
        IncrementWordSaturating(OtherNormal.CurrentSystemKills.Custom)
      else if Victim is TKling then
      begin
        Inc(OtherNormal.DominatorKillCount);
        IncrementWordSaturating(OtherNormal.CurrentSystemKills.Dominator);
        if GetPlayer = OtherShip then
          Inc(GetPlayer.DominatorKillsByType[(Victim as TKling).KlingType]);
      end
      else if (Victim is TPirate)
          or ((Victim is TRanger) and ((Victim as TRanger).GetDominantCareer = rcPirate)) then
      begin
        if (Victim.OwnerId = oiPirate) and not QuestTargetKill then
          IncrementWordSaturating(OtherNormal.CurrentSystemKills.Pirate);
        Inc(OtherNormal.PirateKillCount);
        if (GetPlayer = OtherShip) and (Victim is TPirate) then
          TryAddAchievementProgress('SHIELD', 1);
      end
      else if (Victim is TNormalShip) and (Victim.OwnerId in PlanetOwnerMasks.Coalition) then
      begin
        if not QuestTargetKill then
          IncrementWordSaturating(OtherNormal.CurrentSystemKills.Normal);
      end
      else if (Victim.TypeId in [rstRangerCenter..rstCustomStation])
          and (Victim.CurrentStanding in FactionStandingMasks[CurrentStar.ControlFaction]) then
        IncrementWordSaturating(
            TSystemKillCountArray(OtherNormal.CurrentSystemKills)[Ord(CurrentStar.ControlFaction)]
        );
      RecordShipKillCategory(OtherNormal, Victim);
    end;
  end;
end;

procedure ProcessSystemLiberationRewards(SourceShip: TNormalShip; Star: TStar);
var
  I, J: Integer;
  Ship: TShip;
  Normal: TNormalShip;
  Planet, CeremonyPlanet: TPlanet;
  Text: WideString;

  procedure LogPlayerEvent(
      Ship: TShip
  ); { Nested helper; caller-popped link, Star at ParentFrame-4. }
  var
    Event: TGalaxyEvent;
  begin
    if GetPlayer = Ship then
    begin
      Event := AddGalaxyEvent('PlayerLiberatesSystem');
      Event.AddData(Star.Id);
      Event.AddData(Byte(Star.ControlFaction));
      Event.AddData(Byte(Star.PreviousControlFaction));
      Event.AddData(GetPlayer.PendingLiberationContribution);
      Event.AddData(GetPlayer.PendingLiberationCeremonyPlanet.Id);
    end;
  end;
begin
  if Star.ControlFaction = sfCoalition then
  begin
    CeremonyPlanet := TObject(Star.FindFirstInhabitedPlanet) as TPlanet;
    for I := 0 to Star.Ships.Count - 1 do
    begin
      Ship := Star.Ships[I];
      if Ship is TNormalShip then
      begin
        Normal := Ship as TNormalShip;
        Normal.PendingLiberationCeremonyPlanet := nil;
        if ((Normal.CurrentSystemKills.Dominator > 0)
                and (Star.PreviousControlFaction = sfDominators))
            or ((Normal.CurrentSystemKills.Pirate > 0)
                and (Star.PreviousControlFaction = sfPirates)
                and (Normal.OwnerId <> oiPirate))
            or ((GetPlayer <> Ship)
                and (Ship.DaysSincePlayerSeen > 1)
                and (Normal.DominatorKillCount + Normal.PirateKillCount
                    > Normal.LiberatedSystemCount)) then
        begin
          if Star.PreviousControlFaction = sfDominators then
            Normal.PendingLiberationContribution := Normal.CurrentSystemKills.Dominator;
          if Star.PreviousControlFaction = sfPirates then
            Normal.PendingLiberationContribution := Normal.CurrentSystemKills.Pirate;
          Normal.CurrentSystemKills.Dominator := 0;
          Normal.CurrentSystemKills.Pirate := 0;
          Normal.CurrentSystemKills.Normal := 0;
          Normal.CurrentSystemKills.Custom := 0;
          Inc(Normal.LiberatedSystemCount);
          Normal.PendingLiberationCeremonyPlanet := CeremonyPlanet;
          if Normal.OwnerId <> oiPirate then
            Normal.AddRankPoints(30)
          else
            Normal.AddPirateRankPoints(16);
          Normal.GainExperience(NextRandomIntRange(250, 500, Galaxy.RandomState), esUnscaled);
          if Ship is TRanger then
            for J := 0 to Star.Planets.Count - 1 do
            begin
              Planet := Star.Planets[J];
              if Planet.IsCoalitionOwned then
                Planet.ChangeRelationToRanger(Ship, 100);
            end;
          if Ship.InNormalSpace and ((GetPlayer <> Ship) or PlayerAutomaticControl) then
            Ship.OrderLanding(CeremonyPlanet, True);
          LogPlayerEvent(Ship);
        end;
      end;
    end;
    if Galaxy.CoalitionDefeatedTurn = 0 then
    begin
      if Star.PreviousControlFaction = sfDominators then
      begin
        Text :=
            FormatText3(
                PickLocalizedTextVariant(
                    'GalaxyNews.Globals.NormalsTakeSystemFromKling',
                    SourceShip.Seed * (Galaxy.CurrentTurn div 10)
                ),
                TextHighlightColorTag,
                '<Star>',
                Star.Name,
                '<Sector>',
                Star.Constellation.GetName,
                '<Planet>',
                CeremonyPlanet.Name
            );
        Galaxy.AddPlanetNews(gnCoalitionTakesDominatorSystem, Text);
      end
      else
      begin
        Text :=
            FormatText3(
                PickLocalizedTextVariant(
                    'GalaxyNews.Globals.NormalsTakeSystemFromPirateClan',
                    SourceShip.Seed * (Galaxy.CurrentTurn div 10)
                ),
                TextHighlightColorTag,
                '<Star>',
                Star.Name,
                '<Sector>',
                Star.Constellation.GetName,
                '<Planet>',
                CeremonyPlanet.Name
            );
        Galaxy.AddPlanetNews(gnCoalitionTakesPirateSystem, Text);
      end;
      with AddOrUpdatePlayerBubble(pmGalaxyNews, Galaxy.CurrentTurn, Text, '') do
      begin
        if (GetPlayer.CurrentStar = Star) and GetPlayer.InNormalSpace then
          NotificationSoundKind := 1
        else
          NotificationSoundKind := 0;
        Targets[0].PlanetId := CeremonyPlanet.Id;
      end;
    end;
  end
  else if Star.ControlFaction = sfPirates then
  begin
    CeremonyPlanet := TObject(Star.FindFirstInhabitedPlanet) as TPlanet;
    for I := 0 to Star.Ships.Count - 1 do
    begin
      Ship := Star.Ships[I];
      if Ship is TNormalShip then
      begin
        Normal := Ship as TNormalShip;
        Normal.PendingLiberationCeremonyPlanet := nil;
        if ((Normal.CurrentSystemKills.Dominator > 0)
                and (Star.PreviousControlFaction = sfDominators))
            or ((Normal.CurrentSystemKills.Normal > 0)
                and (Star.PreviousControlFaction = sfCoalition)
                and (Normal.OwnerId = oiPirate))
            or ((GetPlayer <> Ship)
                and (Ship.DaysSincePlayerSeen > 1)
                and (Normal.MilitaryKillCount + Normal.DominatorKillCount
                    > Normal.LiberatedSystemCount)) then
        begin
          if Star.PreviousControlFaction = sfDominators then
            Normal.PendingLiberationContribution := Normal.CurrentSystemKills.Dominator;
          if Star.PreviousControlFaction = sfCoalition then
            Normal.PendingLiberationContribution := Normal.CurrentSystemKills.Normal;
          Normal.CurrentSystemKills.Dominator := 0;
          Normal.CurrentSystemKills.Pirate := 0;
          Normal.CurrentSystemKills.Normal := 0;
          Normal.CurrentSystemKills.Custom := 0;
          Inc(Normal.LiberatedSystemCount);
          Normal.PendingLiberationCeremonyPlanet := CeremonyPlanet;
          Normal.AddPirateRankPoints(16);
          Normal.GainExperience(NextRandomIntRange(250, 500, Galaxy.RandomState), esUnscaled);
          if Ship is TRanger then
            if MainPiratePlanet <> nil then
            begin
              MainPiratePlanet.ChangeRelationToRanger(Ship, 10);
              if (GetPlayer = Ship) and (GetPlayer.PirateLicenseTicks > 0) then
                Inc(GetPlayer.PirateLicenseCash, Round(Galaxy.AverageRangerCapital / 1000));
            end;
          if Ship.InNormalSpace and ((GetPlayer <> Ship) or PlayerAutomaticControl) then
            Ship.OrderLanding(CeremonyPlanet, True);
          LogPlayerEvent(Ship);
          if GetPlayer = Ship then
          begin
            Inc(GetPlayer.AchievementStats.SystemsCapturedForPirates);
            TrySetAchievementProgress(
                'PIRATE',
                GetPlayer.AchievementStats.SystemsCapturedForPirates
            );
          end;
        end;
      end;
    end;
    if Star.PreviousControlFaction = sfCoalition then
    begin
      Text :=
          FormatText3(
              PickLocalizedTextVariant(
                  'GalaxyNews.Globals.PirateClanTakeSystemFromNormals',
                  SourceShip.Seed * (Galaxy.CurrentTurn div 10)
              ),
              TextHighlightColorTag,
              '<Star>',
              Star.Name,
              '<Sector>',
              Star.Constellation.GetName,
              '<Planet>',
              CeremonyPlanet.Name
          );
      if Galaxy.CoalitionDefeatedTurn = 0 then
        Galaxy.AddPlanetNews(gnPiratesTakeCoalitionSystem, Text);
    end
    else
    begin
      if Galaxy.CoalitionDefeatedTurn = 0 then
        Text :=
            FormatText3(
                PickLocalizedTextVariant(
                    'GalaxyNews.Globals.PirateClanTakeSystemFromKling',
                    SourceShip.Seed * (Galaxy.CurrentTurn div 10)
                ),
                TextHighlightColorTag,
                '<Star>',
                Star.Name,
                '<Sector>',
                Star.Constellation.GetName,
                '<Planet>',
                CeremonyPlanet.Name
            )
      else
        Text :=
            FormatText3(
                PickLocalizedTextVariant(
                    'GalaxyNews.Globals.PirateClanTakeSystemFromKlingAlt',
                    SourceShip.Seed * (Galaxy.CurrentTurn div 10)
                ),
                TextHighlightColorTag,
                '<Star>',
                Star.Name,
                '<Sector>',
                Star.Constellation.GetName,
                '<Planet>',
                CeremonyPlanet.Name
            );
      if Galaxy.CoalitionDefeatedTurn = 0 then
        Galaxy.AddPlanetNews(gnPiratesTakeDominatorSystem, Text);
    end;
    with AddOrUpdatePlayerBubble(pmGalaxyNews, Galaxy.CurrentTurn, Text, '') do
    begin
      if (GetPlayer.CurrentStar = Star) and GetPlayer.InNormalSpace then
        NotificationSoundKind := 1
      else
        NotificationSoundKind := 0;
      Targets[0].PlanetId := CeremonyPlanet.Id;
    end;
  end;
end;

procedure TNormalShip.CheckKillCountAwards(Victim: TShip);

  procedure Check(
      InitialThreshold, Multiplier: Integer;
      Count: Word;
      VictimType: TShipType
  ); { Caller-popped static link; ship at ParentFrame-4. }
  const
    BadAwards = [atPerfidy];
  var
    I, Threshold, Award: Integer;
    Text, ShipTypeName: WideString;
  begin
    if (Galaxy.CoalitionDefeatedTurn > 0) or (Count = High(Word)) then
      Exit;
    Threshold := InitialThreshold;
    I := 1;
    repeat
      if Count < Threshold then
        Break;
      if Count = Threshold then
      begin
        Award := Integer(SelectAward(OwnerId, BadAwards, [VictimType])) and $FF;
        if Award <> AwardNotFound then
        begin
          AddAward(Byte(Award));
          if GetPlayer = Self then
          begin
            ShipTypeName := ShipTypeNames[VictimType].Name;
            Text :=
                PickLocalizedTextVariant(
                    'GalaxyNews.BadReward.Kill' + ShipTypeName,
                    Seed + Cardinal(Galaxy.CurrentTurn div 10)
                );
            ReplaceTextToken(
                Text,
                '<Reward>',
                GetAwardInfo(Byte(Award)).Name,
                TextHighlightColorTag
            );
            AddOrUpdatePlayerBubble(pmGalaxyNews, Galaxy.CurrentTurn, Text, '');
          end;
        end;
        Break;
      end;
      Threshold := Min(Threshold * Multiplier, 10000000);
      Inc(I);
    until I = 9;
  end;
begin
  case Victim.TypeId of
    stTransport: Check(5, 5, Word(CivilianKillCount), stTransport);
    stWarrior: Check(3, 3, Word(MilitaryKillCount), stWarrior);
    stRanger:
      if TypeId = stRanger then
        Check(2, 4, Word(RangerKillCount), stRanger);
  end;
end;

procedure TNormalShip.UpdateRelationsForNearbyCombat;
var
  I: Integer;
  Ship, Target: TShip;
  Ranger: TRanger;
  Change: Boolean;
begin
  if not InNormalSpace or (GetPlayer = Self) then
    Exit;
  for I := 0 to CurrentStar.Ships.Count - 1 do
  begin
    Ship := CurrentStar.Ships[I];
    if (Ship is TRanger) and (Ship <> Self) and Ship.InNormalSpace then
    begin
      Ranger := Ship as TRanger;
      if (Ranger.OrderTarget is TShip) and (Ranger.OrderTarget = Ranger.EnemyShip) then
      begin
        Target := Ranger.OrderTarget as TShip;
        if GetRelationLevelToShip(Target) = rlExcellent then
        begin
          if (GetPlayer = Ship) or (NextRandomUnitFloat(RandomState) <= 0.1) then
          begin
            Change :=
                (Target.OrderTarget <> Ranger)
                    and (Target.GetRelationLevelToShip(Ranger) = rlHostile);
            if Change then
              ChangeRelationToRanger(Ranger, -2);
          end;
        end
        else if GetRelationLevelToShip(Target) = rlHostile then
        begin
          Change := Target.GetRelationLevelToShip(Ranger) = rlHostile;
          if Change then
            ChangeRelationToRanger(Ranger, 2);
        end;
      end;
    end;
  end;
end;

function TNormalShip.SelectAward(
    Owner: TOwnerId;
    Kinds: TAwardTypeMask;
    VictimTypes: TShipTypeMask
): Byte;
var
  I, Count: Integer;
  Candidates: TList;
  KillName: WideString;
begin
  Candidates := TList.Create;
  Count := StrToInt(LookupLocalizedTextByKey('Reward.Count')) - 1;
  for I := 0 to Count do
    if MatchesOwnerName(Owner, LookupLocalizedTextByKey('Reward.' + IntToStr(I) + '.Race'))
        and (SysToReward(LookupLocalizedTextByKey('Reward.' + IntToStr(I) + '.Type')) in Kinds)
        and MatchesCareerName(
            GetDominantCareer,
            LookupLocalizedTextByKey('Reward.' + IntToStr(I) + '.Status')) then
    begin
      KillName := LocalizedText('Reward.' + IntToStr(I) + '.Kill');
      if (Length(KillName) = 0) or (SysToShipType(KillName) in VictimTypes) then
        Candidates.Add(Pointer(I));
    end;
  if Candidates.Count > 0 then
  begin
    Result :=
        Byte(
            Candidates[
                SeededRandomIntRange(
                    0,
                    Candidates.Count - 1,
                    (Integer(Seed) + Galaxy.CurrentTurn) div 101
                )
            ]
        );
    if (AwardIds <> nil) and (AwardIds.IndexOf(Pointer(Result)) >= 0) then
      Result :=
          Byte(
              Candidates[
                  SeededRandomIntRange(
                      0,
                      Candidates.Count - 1,
                      (Integer(Seed) + 2 * Galaxy.CurrentTurn) div 101
                  )
              ]
          );
    if (AwardIds <> nil) and (AwardIds.IndexOf(Pointer(Result)) >= 0) then
      Result :=
          Byte(
              Candidates[
                  SeededRandomIntRange(
                      0,
                      Candidates.Count - 1,
                      (Integer(Seed) + 3 * Galaxy.CurrentTurn) div 101
                  )
              ]
          );
  end
  else
    Result := AwardNotFound;
  Candidates.Free;
end;

function TNormalShip.GetAwardInfo(AwardId: Byte): TRewardInfo;
begin
  Result.AwardId := AwardId;
  Result.Name := LookupLocalizedTextByKey('Reward.' + IntToStr(AwardId) + '.Name');
  Result.Text := LookupLocalizedTextByKey('Reward.' + IntToStr(AwardId) + '.Text');
end;

function TNormalShip.GetRankName: WideString;
begin
  Result := LocalizedText('Rank.' + CoalitionRankNames[Rank] + '.Name');
end;

function TNormalShip.GetRankLongName: WideString;
begin
  Result := LocalizedText('Rank.' + CoalitionRankNames[Rank] + '.NameBig');
end;

function TNormalShip.GetRankDescription: WideString;
begin
  Result := LocalizedColorText('Rank.' + CoalitionRankNames[Rank] + '.Text');
end;

function TNormalShip.GetNextRankName: WideString;
begin
  Result := LocalizedText('Rank.' + CoalitionRankNames[Rank + 1] + '.Name');
end;

function TNormalShip.GetRankPointsToNextRank: Word;
begin
  if (Rank < 7) and (CoalitionRankPointThresholds[Rank] > RankPoints) then
    Result := CoalitionRankPointThresholds[Rank] - RankPoints
  else
    Result := 0;
end;

procedure TNormalShip.AddRankPoints(Amount: Word);
var
  Needed: Integer;
begin
  Needed := GetRankPointsToNextRank;
  Inc(RankPoints, Min(Amount, Needed));
  if (Needed > 0)
      and (GetPlayer = Self)
      and GetPlayer.CanPromoteRank
      and (Galaxy.CoalitionDefeatedTurn = 0) then
    AddOrUpdatePlayerBubble(
        pmGalaxyNews,
        Galaxy.CurrentTurn,
        FormatText1(
            PickLocalizedTextVariant('GalaxyNews.WB.NewRank', Seed * (Galaxy.CurrentTurn div 10)),
            TextHighlightColorTag,
            '<Rank>',
            GetPlayer.GetNextRankName
        ),
        ''
    );
end;

function TNormalShip.TryPromoteRank: Boolean;
begin
  if (Rank < 7) and (GetRankPointsToNextRank = 0) then
  begin
    Inc(Rank);
    RankPoints := 0;
    Result := True;
  end
  else
    Result := False;
end;

function TNormalShip.CanPromoteRank: Boolean;
begin
  Result := (Rank < 7) and (GetRankPointsToNextRank = 0);
end;

function TNormalShip.GetPirateRankName: WideString;
begin
  Result := LocalizedText('RankPirate.' + PirateRankNames[PirateRank] + '.Name');
end;

function TNormalShip.GetPirateRankLongName: WideString;
begin
  Result := LocalizedText('RankPirate.' + PirateRankNames[PirateRank] + '.NameBig');
end;

function TNormalShip.GetPirateRankDescription: WideString;
begin
  Result := LocalizedColorText('RankPirate.' + PirateRankNames[PirateRank] + '.Text');
end;

function TNormalShip.GetNextPirateRankName: WideString;
begin
  Result := LocalizedText('RankPirate.' + PirateRankNames[PirateRank + 1] + '.Name');
end;

function TNormalShip.GetPirateRankPointsToNextRank: Word;
begin
  if (PirateRank < 7) and (PirateRankPointThresholds[PirateRank] > PirateRankPoints) then
    Result := PirateRankPointThresholds[PirateRank] - PirateRankPoints
  else
    Result := 0;
end;

procedure TNormalShip.AddPirateRankPoints(Amount: Cardinal);
var
  Needed: Integer;
begin
  Needed := GetPirateRankPointsToNextRank;
  Inc(PirateRankPoints, Min(Amount, Needed));
end;

function TNormalShip.TryPromotePirateRank: Boolean;
begin
  if (PirateRank < 7) and (GetPirateRankPointsToNextRank = 0) then
  begin
    Inc(PirateRank);
    if GetPlayer = Self then
      GetPlayer.AchievementStats.CheckBaronAchievement;
    PirateRankPoints := 0;
    Result := True;
  end
  else
    Result := False;
end;

function TNormalShip.CanPromotePirateRank: Boolean;
begin
  Result := (PirateRank < 7) and (GetPirateRankPointsToNextRank = 0);
end;

function TNormalShip.SelectSituationalMessage(Automatic: Boolean): WideString;
var
  Definitions: array of TShipGreetingsInfo;
  LastIndex: Integer;
  SwapA, SwapB: TShipGreetingsInfo;
  ItemTypes, MessageText, BestText: WideString;
  I, J, K, Count, Minimum, EntryIndex, BestPriority, CandidatePriority: Integer;
  Good: Byte;
  Rejected: Boolean;
  Planet: TPlanet;
  Item: TItem;
  ShipKind: TShipType;
  CountMask: TGreetingCountMask;
  Other: TShip;

  procedure ShuffleDefinitions; { Nested helper; caller-popped static link. Copies definitions and swaps the first half against deterministic random positions. }
  var
    I, OtherIndex: Integer;
  begin
    SetLength(Definitions, ShipGreetingCount);
    for I := 0 to LastIndex do
      Definitions[I] := ShipGreetingDefinitions[I];
    for I := 0 to LastIndex div 2 do
    begin
      OtherIndex := SeededRandomIntRange(0, LastIndex, Seed + 7 * I);
      SwapA := Definitions[OtherIndex];
      SwapB := Definitions[I];
      Definitions[I] := SwapA;
      Definitions[OtherIndex] := SwapB;
    end;
  end;
begin
  BestText := '';
  if (GetPlayer = PartnerShip) or GetPlayer.ChameleonActive or HasIndependentScriptFaction then
  begin
    Result := '';
    Exit;
  end;
  begin
    ItemTypes := '';
    BestPriority := -1;
    CandidatePriority := -1;
    Minimum := 0;
    LastIndex := ShipGreetingCount - 1;
    ShuffleDefinitions;
    EntryIndex :=
        SeededRandomIntRange(0, LastIndex, Integer(Seed * Cardinal(Galaxy.CurrentTurn)) div 20);
    for I := 0 to LastIndex do
    begin
      MessageText := '';
      IncrementWrapped(EntryIndex, Minimum, LastIndex);
      if IsFemaleHumanPilot <> (Definitions[EntryIndex].Female = 0) then
        Continue;
      if (Definitions[EntryIndex].CoalitionAlreadyDefeated <> gcAny)
          and (((Definitions[EntryIndex].CoalitionAlreadyDefeated = gcYes)
                  and (not (Galaxy.CoalitionDefeatedTurn <> 0)))
              or ((Definitions[EntryIndex].CoalitionAlreadyDefeated = gcNo)
                  and (Galaxy.CoalitionDefeatedTurn <> 0))) then
        Continue;
      if (Definitions[EntryIndex].DominatorsAlreadyDefeated <> gcAny)
          and (((Definitions[EntryIndex].DominatorsAlreadyDefeated = gcYes)
                  and (not (not Galaxy.HasUnresolvedDominatorSeries(
                      [dsBlazer, dsKeller, dsTerron]))))
              or ((Definitions[EntryIndex].DominatorsAlreadyDefeated = gcNo)
                  and (not Galaxy.HasUnresolvedDominatorSeries(
                      [dsBlazer, dsKeller, dsTerron])))) then
        Continue;
      if BestPriority > 0 then
      begin
        CandidatePriority := Definitions[EntryIndex].Priority;
        if CandidatePriority
                * SeededRandomIntRange(1, 100, Seed + EntryIndex * (Galaxy.CurrentTurn div 20))
            < BestPriority
                * SeededRandomIntRange(
                    1,
                    100,
                    Seed + EntryIndex * (Galaxy.CurrentTurn div 20) * 3) then
          Continue;
      end;
      Good := NoGreetingGoods;
      if Definitions[EntryIndex].Goods <> UnspecifiedGoods then
        Good := Definitions[EntryIndex].Goods;
      if (Definitions[EntryIndex].AutoTalk <> gcAny)
          and ((Automatic and (Definitions[EntryIndex].AutoTalk = gcNo))
              or (not Automatic and (Definitions[EntryIndex].AutoTalk = gcYes))) then
        Continue;
      if Definitions[EntryIndex].FlyType = gfAny then
        MessageText := LocalizedColorText('ShipGreetings.' + Definitions[EntryIndex].Name + '.Text')
      else
      begin
        if Definitions[EntryIndex].FlyType = gfToPlanet then
        begin
          if not (OrderTarget is TPlanet) then
            Continue;
          Planet := OrderTarget as TPlanet;
          if not (Planet.OwnerId in [oiMaloc..oiGaal, oiPirate]) then
            Continue;
          if CurrentStar.Status.CustomFaction <> '' then
            Continue;
          if (Definitions[EntryIndex].ToPlanetRace <> [])
              and not (Planet.RaceId in Definitions[EntryIndex].ToPlanetRace) then
            Continue;
          if (Definitions[EntryIndex].ToPlanetRelations <> [])
              and not (Planet.GetRelationLevelToShip(GetPlayer)
                  in Definitions[EntryIndex].ToPlanetRelations) then
            Continue;
          if Good <> NoGreetingGoods then
          begin
            if (Definitions[EntryIndex].ToPlanetGoodsCnt <> [])
                and not (Galaxy.ClassifyGoodsQuantity(Planet.Goods[Good].Count, Good)
                    in Definitions[EntryIndex].ToPlanetGoodsCnt) then
              Continue;
            if (Definitions[EntryIndex].ToPlanetGoodsSale <> [])
                and not (Galaxy
                        .ClassifyGoodsPrice(GetPlayer.ShopGoodsPurchasePrice(Good, Planet), Good)
                    in Definitions[EntryIndex].ToPlanetGoodsSale) then
              Continue;
            if (Definitions[EntryIndex].ToPlanetGoodsBuy <> [])
                and not (Galaxy.ClassifyGoodsPrice(GetPlayer.ShopGoodsSellPrice(Good, Planet), Good)
                    in Definitions[EntryIndex].ToPlanetGoodsBuy) then
              Continue;
          end;
          if (Definitions[EntryIndex].ToPlanetIsHomePlanet <> gcAny)
              and (((Definitions[EntryIndex].ToPlanetIsHomePlanet = gcYes)
                      and (not (HomePlanet = Planet)))
                  or ((Definitions[EntryIndex].ToPlanetIsHomePlanet = gcNo)
                      and (HomePlanet = Planet))) then
            Continue;
          if (Definitions[EntryIndex].ToPlanetRaceIsShipRace <> gcAny)
              and (((Definitions[EntryIndex].ToPlanetRaceIsShipRace = gcYes)
                      and (not (Planet.RaceId = PilotRace)))
                  or ((Definitions[EntryIndex].ToPlanetRaceIsShipRace = gcNo)
                      and (Planet.RaceId = PilotRace))) then
            Continue;
          if (Definitions[EntryIndex].ToPlanetRaceIsPlayerRace <> gcAny)
              and (((Definitions[EntryIndex].ToPlanetRaceIsPlayerRace = gcYes)
                      and (not (GetPlayer.PilotRace = Planet.RaceId)))
                  or ((Definitions[EntryIndex].ToPlanetRaceIsPlayerRace = gcNo)
                      and (GetPlayer.PilotRace = Planet.RaceId))) then
            Continue;
          if (Definitions[EntryIndex].ToPlanetEconomy <> [])
              and not (Planet.Economy in Definitions[EntryIndex].ToPlanetEconomy) then
            Continue;
          if (Definitions[EntryIndex].ToPlanetGovernment <> [])
              and not (Planet.Government in Definitions[EntryIndex].ToPlanetGovernment) then
            Continue;
          if (Definitions[EntryIndex].ToPlanetIsLastPlanet <> gcAny)
              and (((Definitions[EntryIndex].ToPlanetIsLastPlanet = gcYes)
                      and (not (LastDockedPlanet = Planet)))
                  or ((Definitions[EntryIndex].ToPlanetIsLastPlanet = gcNo)
                      and (LastDockedPlanet = Planet))) then
            Continue;
          if Definitions[EntryIndex].ToPlanetRaceIsLastPlanetRace <> gcAny then
          begin
            if not (LastDockedPlanet.OwnerId in [oiMaloc..oiGaal, oiPirate]) then
              Continue;
            if (((Definitions[EntryIndex].ToPlanetRaceIsLastPlanetRace = gcYes)
                    and (not (Planet.RaceId = LastDockedPlanet.RaceId)))
                or ((Definitions[EntryIndex].ToPlanetRaceIsLastPlanetRace = gcNo)
                    and (Planet.RaceId = LastDockedPlanet.RaceId))) then
              Continue;
          end;
          MessageText :=
              LocalizedColorText('ShipGreetings.' + Definitions[EntryIndex].Name + '.Text');
          MessageText :=
              ReplaceColoredToken(
                  MessageText,
                  '<ToPlanet>',
                  Planet.Name + GetLocalObjectLink(Planet, Automatic),
                  TextHighlightColorTag
              );
          if Good <> NoGreetingGoods then
          begin
            MessageText :=
                ReplaceColoredToken(
                    MessageText,
                    '<ToPlanetGoodsSale>',
                    IntToStr(GetPlayer.ShopGoodsPurchasePrice(Good, Planet)),
                    TextHighlightColorTag
                );
            MessageText :=
                ReplaceColoredToken(
                    MessageText,
                    '<ToPlanetGoodsBuy>',
                    IntToStr(GetPlayer.ShopGoodsSellPrice(Good, Planet)),
                    TextHighlightColorTag
                );
          end;
        end
        else if Definitions[EntryIndex].FlyType = gfToStar then
        begin
          if not (OrderTarget is TStar) then
            Continue;
          if (Definitions[EntryIndex].HomePlanetInToStar <> gcAny)
              and (((Definitions[EntryIndex].HomePlanetInToStar = gcYes)
                      and (not (HomePlanet.CurrentStar = OrderTarget)))
                  or ((Definitions[EntryIndex].HomePlanetInToStar = gcNo)
                      and (HomePlanet.CurrentStar = OrderTarget))) then
            Continue;
          if (Definitions[EntryIndex].HomePlanetInCurStar <> gcAny)
              and (((Definitions[EntryIndex].HomePlanetInCurStar = gcYes)
                      and (not (HomePlanet.CurrentStar = CurrentStar)))
                  or ((Definitions[EntryIndex].HomePlanetInCurStar = gcNo)
                      and (HomePlanet.CurrentStar = CurrentStar))) then
            Continue;
          Rejected := False;
          for ShipKind := stKling to stWarrior do
          begin
            case ShipKind of
              stKling: CountMask := Definitions[EntryIndex].KlingInToStar;
              stRanger: CountMask := Definitions[EntryIndex].RangerInToStar;
              stPirate: CountMask := Definitions[EntryIndex].PirateInToStar;
              stWarrior: CountMask := Definitions[EntryIndex].WarriorInToStar;
              stTransport: CountMask := Definitions[EntryIndex].TransportInToStar;
            end;
            if CountMask <> [] then
            begin
              Count := 0;
              for K := 0 to (OrderTarget as TStar).Ships.Count - 1 do
              begin
                Other := (OrderTarget as TStar).Ships[K];
                if not Other.HasScriptStateText
                    and (Other.TypeNameOverrideKey = '')
                    and (Other.TypeId = ShipKind) then
                  Inc(Count);
              end;
              Count := Min(10, Count);
              if not (Cardinal(Count) in CountMask) then
              begin
                Rejected := True;
                Break;
              end;
            end;
          end;
          if Rejected then
            Continue;
          if Definitions[EntryIndex].ToStarControlByKling <> gcAny then
          begin
            if (OrderTarget as TStar).Status.CustomFaction <> '' then
              Continue;
            if (((Definitions[EntryIndex].ToStarControlByKling = gcYes)
                    and (not ((OrderTarget as TStar).ControlFaction = sfDominators)))
                or ((Definitions[EntryIndex].ToStarControlByKling = gcNo)
                    and ((OrderTarget as TStar).ControlFaction = sfDominators))) then
              Continue;
          end;
          if Definitions[EntryIndex].ToStarControlByPirates <> gcAny then
          begin
            if (OrderTarget as TStar).Status.CustomFaction <> '' then
              Continue;
            if (((Definitions[EntryIndex].ToStarControlByPirates = gcYes)
                    and (not ((OrderTarget as TStar).ControlFaction = sfPirates)))
                or ((Definitions[EntryIndex].ToStarControlByPirates = gcNo)
                    and ((OrderTarget as TStar).ControlFaction = sfPirates))) then
              Continue;
          end;
          if (Definitions[EntryIndex].ToStarInBattle <> gcAny)
              and (((Definitions[EntryIndex].ToStarInBattle = gcYes)
                      and (not ((OrderTarget as TStar).Battle <> 0)))
                  or ((Definitions[EntryIndex].ToStarInBattle = gcNo)
                      and ((OrderTarget as TStar).Battle <> 0))) then
            Continue;
          MessageText :=
              LocalizedColorText('ShipGreetings.' + Definitions[EntryIndex].Name + '.Text');
          MessageText :=
              ReplaceColoredToken(
                  MessageText,
                  '<ToStar>',
                  (OrderTarget as TStar).Name,
                  TextHighlightColorTag
              );
        end
        else if Definitions[EntryIndex].FlyType = gfToItem then
        begin
          if (Order <> soMove) or not OrderAbsolute then
            Continue;
          Rejected := False;
          Item := nil;
          for J := 0 to CurrentStar.Items.Count - 1 do
          begin
            Item := CurrentStar.Items[J];
            // Native accepts either matching coordinate, rather than requiring both.
            if (GetPickupApproachPosition(Item.Position).X = OrderDestination.X)
                or (GetPickupApproachPosition(Item.Position).Y = OrderDestination.Y) then
            begin
              ItemTypes := Definitions[EntryIndex].ItemType;
              if (ItemTypes = '')
                  or (ItemTypes = 'Any')
                  or (FindTextPosW(Item.GetCategoryConfigName, ItemTypes) <> 0) then
              begin
                if (Definitions[EntryIndex].ShipNeedInItem <> gcAny)
                    and (((Definitions[EntryIndex].ShipNeedInItem = gcYes)
                            and not ShouldPickUpItem(Item))
                        or ((Definitions[EntryIndex].ShipNeedInItem = gcNo)
                            and ShouldPickUpItem(Item))) then
                  Continue;
                Rejected := True;
                Break;
              end;
            end;
          end;
          if not Rejected then
            Continue;
          MessageText :=
              LocalizedColorText('ShipGreetings.' + Definitions[EntryIndex].Name + '.Text');
          MessageText :=
              ReplaceColoredToken(
                  MessageText,
                  '<Item>',
                  Item.GetDisplayName + GetLocalObjectLink(Item, Automatic),
                  TextHighlightColorTag
              );
        end
        else if Definitions[EntryIndex].FlyType = gfToShip then
        begin
          if not (OrderTarget is TShip) then
            Continue;
          if (Definitions[EntryIndex].ToShipType <> [])
              and not ((OrderTarget as TShip).GetGreetingShipCategory
                  in Definitions[EntryIndex].ToShipType) then
            Continue;
          if (Definitions[EntryIndex].ToShipRace <> [])
              and not ((OrderTarget as TShip).PilotRace in Definitions[EntryIndex].ToShipRace) then
            Continue;
          if (Definitions[EntryIndex].ToShipInPlanet <> gcAny)
              and (((Definitions[EntryIndex].ToShipInPlanet = gcYes)
                      and (not ((OrderTarget as TShip).CurrentPlanet <> nil)))
                  or ((Definitions[EntryIndex].ToShipInPlanet = gcNo)
                      and ((OrderTarget as TShip).CurrentPlanet <> nil))) then
            Continue;
          if (Definitions[EntryIndex].ToShipBad <> gcAny)
              and (((Definitions[EntryIndex].ToShipBad = gcYes)
                      and (not ((OrderTarget as TShip).EnemyShip = Self)))
                  or ((Definitions[EntryIndex].ToShipBad = gcNo)
                      and ((OrderTarget as TShip).EnemyShip = Self))) then
            Continue;
          if (Definitions[EntryIndex].ToShipRelations <> [])
              and not (GetRelationLevelToShip(OrderTarget as TShip)
                  in Definitions[EntryIndex].ToShipRelations) then
            Continue;
          MessageText :=
              LocalizedColorText('ShipGreetings.' + Definitions[EntryIndex].Name + '.Text');
          MessageText :=
              ReplaceColoredToken(
                  MessageText,
                  '<ToShip>',
                  (OrderTarget as TShip).GetName + GetLocalObjectLink(OrderTarget, Automatic),
                  TextHighlightColorTag
              );
          MessageText :=
              ReplaceColoredToken(
                  MessageText,
                  '<ToFullShip>',
                  (OrderTarget as TShip).GetFullName(' ')
                      + GetLocalObjectLink(OrderTarget, Automatic),
                  TextHighlightColorTag
              );
          if (OrderTarget as TShip).CurrentPlanet <> nil then
          begin
            MessageText :=
                ReplaceColoredToken(
                    MessageText,
                    '<ToShipInPlanet>',
                    (OrderTarget as TShip).CurrentPlanet.GetFullName(' ')
                        + GetLocalObjectLink((OrderTarget as TShip).CurrentPlanet, Automatic),
                    TextHighlightColorTag
                );
          end;
        end;
      end;
      if (Definitions[EntryIndex].ShipType <> [])
          and not (GetGreetingShipCategory in Definitions[EntryIndex].ShipType) then
        Continue;
      if (Definitions[EntryIndex].Relations <> [])
          and not (GetRelationLevelToShip(GetPlayer) in Definitions[EntryIndex].Relations) then
        Continue;
      if (Definitions[EntryIndex].ShipRace <> [])
          and not (PilotRace in Definitions[EntryIndex].ShipRace) then
        Continue;
      if (Definitions[EntryIndex].PlayerRace <> [])
          and not (GetPlayer.PilotRace in Definitions[EntryIndex].PlayerRace) then
        Continue;
      if (Definitions[EntryIndex].ShipRaceIsPlayerRace <> gcAny)
          and (((Definitions[EntryIndex].ShipRaceIsPlayerRace = gcYes)
                  and (not (GetPlayer.PilotRace = PilotRace)))
              or ((Definitions[EntryIndex].ShipRaceIsPlayerRace = gcNo)
                  and (GetPlayer.PilotRace = PilotRace))) then
        Continue;
      if Definitions[EntryIndex].PlayerAttackGoodShip <> gcAny then
      begin
        if GetPlayer.OrderTarget is TShip then
        begin
          Other := GetPlayer.OrderTarget as TShip;
          Rejected :=
              (Other is TNormalShip)
                  and (GetPlayer <> Other.OrderTarget)
                  and (GetRelationLevelToShip(Other) = rlExcellent)
                  and (Other.GetRelationLevelToShip(GetPlayer) = rlHostile);
        end
        else
          Rejected := False;
        if Definitions[EntryIndex].PlayerAttackGoodShip = gcNo then
          if Rejected then
            Continue;
        if (Definitions[EntryIndex].PlayerAttackGoodShip = gcYes) and not Rejected then
          Continue;
        if Rejected then
        begin
          MessageText :=
              ReplaceColoredToken(
                  MessageText,
                  '<FullShipGood>',
                  (GetPlayer.OrderTarget as TShip).GetFullName(' ')
                      + GetLocalObjectLink(GetPlayer.OrderTarget, Automatic),
                  ''
              );
        end;
      end;
      if (Definitions[EntryIndex].InFear <> gcAny)
          and (((Definitions[EntryIndex].InFear = gcYes) and (not (InFear)))
              or ((Definitions[EntryIndex].InFear = gcNo) and (InFear))) then
        Continue;
      if Definitions[EntryIndex].ShipBadFlyToShip <> gcAny then
      begin
        Rejected := IsEnemyPursuingSelf;
        if (((Definitions[EntryIndex].ShipBadFlyToShip = gcYes) and (not (Rejected)))
            or ((Definitions[EntryIndex].ShipBadFlyToShip = gcNo) and (Rejected))) then
          Continue;
      end;
      if (Definitions[EntryIndex].ShipBadType <> [])
          and (EnemyShip <> nil)
          and not (EnemyShip.GetGreetingShipCategory in Definitions[EntryIndex].ShipBadType) then
        Continue;
      if (Definitions[EntryIndex].ShipBadRace <> [])
          and (EnemyShip <> nil)
          and not (EnemyShip.PilotRace in Definitions[EntryIndex].ShipBadRace) then
        Continue;
      if (Definitions[EntryIndex].ShipFlyToPlayer <> gcAny)
          and (((Definitions[EntryIndex].ShipFlyToPlayer = gcYes)
                  and (not (GetPlayer = OrderTarget)))
              or ((Definitions[EntryIndex].ShipFlyToPlayer = gcNo)
                  and (GetPlayer = OrderTarget))) then
        Continue;
      if (Definitions[EntryIndex].PlayerFlyToShip <> gcAny)
          and (((Definitions[EntryIndex].PlayerFlyToShip = gcYes)
                  and (not (GetPlayer.OrderTarget = Self)))
              or ((Definitions[EntryIndex].PlayerFlyToShip = gcNo)
                  and (GetPlayer.OrderTarget = Self))) then
        Continue;
      if (Definitions[EntryIndex].PlayerIsShipBad <> gcAny)
          and (((Definitions[EntryIndex].PlayerIsShipBad = gcYes) and (not (GetPlayer = EnemyShip)))
              or ((Definitions[EntryIndex].PlayerIsShipBad = gcNo)
                  and (GetPlayer = EnemyShip))) then
        Continue;
      if (Definitions[EntryIndex].ShipTurnBeforeEndOrder <> []) then
      begin
        Count := Min(10, EstimateOrderTravelTurns);
        if not (Cardinal(Count) in Definitions[EntryIndex].ShipTurnBeforeEndOrder) then
          Continue;
      end;
      if (Definitions[EntryIndex].PlayerTurnBeforeEndOrder <> []) then
      begin
        Count := Min(10, GetPlayer.EstimateOrderTravelTurns);
        if not (Cardinal(Count) in Definitions[EntryIndex].PlayerTurnBeforeEndOrder) then
          Continue;
      end;
      if (EnemyShip <> nil)
          and (EnemyShip.CurrentStar = CurrentStar)
          and EnemyShip.InNormalSpace
          and (Definitions[EntryIndex].ShipBadTurnBeforeEndOrder <> []) then
      begin
        Count := Min(10, EnemyShip.EstimateOrderTravelTurns);
        if not (Cardinal(Count) in Definitions[EntryIndex].ShipBadTurnBeforeEndOrder) then
          Continue;
      end;
      if (Self is TRanger)
          and (Definitions[EntryIndex].ShipStatus <> [])
          and not ((Self as TRanger).GetDominantCareer in Definitions[EntryIndex].ShipStatus) then
        Continue;
      if (Definitions[EntryIndex].PlayerStatus <> [])
          and not (GetPlayer.GetDominantCareer in Definitions[EntryIndex].PlayerStatus) then
        Continue;
      if (Definitions[EntryIndex].ShipStrength <> [])
          and not (GetRelativeStrengthCategory in Definitions[EntryIndex].ShipStrength) then
        Continue;
      if (Definitions[EntryIndex].PlayerStrength <> [])
          and not (GetPlayer.GetRelativeStrengthCategory
              in Definitions[EntryIndex].PlayerStrength) then
        Continue;
      if (Definitions[EntryIndex].ShipStructure <> [])
          and not (GetHullConditionCategory in Definitions[EntryIndex].ShipStructure) then
        Continue;
      if (Definitions[EntryIndex].PlayerStructure <> [])
          and not (GetPlayer.GetHullConditionCategory
              in Definitions[EntryIndex].PlayerStructure) then
        Continue;
      if (Self is TRanger)
          and not (Self as TRanger).ExcludedFromRating
          and (Definitions[EntryIndex].ShipRating <> [])
          and not (GetRangerRatingBand in Definitions[EntryIndex].ShipRating) then
        Continue;
      if (Definitions[EntryIndex].PlayerRating <> [])
          and not (GetPlayer.GetRangerRatingBand in Definitions[EntryIndex].PlayerRating) then
        Continue;
      if (Definitions[EntryIndex].ShipRank <> [])
          and not (Rank in Definitions[EntryIndex].ShipRank) then
        Continue;
      if (Definitions[EntryIndex].PlayerRank <> [])
          and not (GetPlayer.Rank in Definitions[EntryIndex].PlayerRank) then
        Continue;
      if (Definitions[EntryIndex].PlayerPirateRank <> [])
          and not (GetPlayer.PirateRank in Definitions[EntryIndex].PlayerPirateRank) then
        Continue;
      if (Self is TRanger)
          and not (Self as TRanger).ExcludedFromRating
          and (Definitions[EntryIndex].RatingShipWithPlayer <> [])
          and not (GetPlayer.GetShipRatingComparison(Self)
              in Definitions[EntryIndex].RatingShipWithPlayer) then
        Continue;
      if (Definitions[EntryIndex].RankShipWithPlayer <> [])
          and not (GetPlayer.GetShipRankComparison(Self)
              in Definitions[EntryIndex].RankShipWithPlayer) then
        Continue;
      if (Definitions[EntryIndex].RankShipWithPlayerExtra <> [])
          and not (GetPlayer.GetShipPirateRankComparison(Self)
              in Definitions[EntryIndex].RankShipWithPlayerExtra) then
        Continue;
      if (Definitions[EntryIndex].StrengthShipWithPlayer <> [])
          and not (GetPlayer.GetShipStrengthComparison(Self)
              in Definitions[EntryIndex].StrengthShipWithPlayer) then
        Continue;
      if Good <> NoGreetingGoods then
      begin
        if (Definitions[EntryIndex].ShipGoodsCnt <> [])
            and not (Galaxy.ClassifyGoodsQuantity(CargoGoods[Good].Count, Good)
                in Definitions[EntryIndex].ShipGoodsCnt) then
          Continue;
        if (Definitions[EntryIndex].PlayerGoodsCnt <> [])
            and not (Galaxy.ClassifyGoodsQuantity(GetPlayer.CargoGoods[Good].Count, Good)
                in Definitions[EntryIndex].PlayerGoodsCnt) then
          Continue;
        if (Definitions[EntryIndex].ShipHaveGoods <> gcAny)
            and (((Definitions[EntryIndex].ShipHaveGoods = gcYes) and (CargoGoods[Good].Count = 0))
                or ((Definitions[EntryIndex].ShipHaveGoods = gcNo)
                    and (CargoGoods[Good].Count > 0))) then
          Continue;
        if (Definitions[EntryIndex].PlayerHaveGoods <> gcAny)
            and (((Definitions[EntryIndex].PlayerHaveGoods = gcYes)
                    and (GetPlayer.CargoGoods[Good].Count = 0))
                or ((Definitions[EntryIndex].PlayerHaveGoods = gcNo)
                    and (GetPlayer.CargoGoods[Good].Count > 0))) then
          Continue;
      end;
      if (Definitions[EntryIndex].ShipGoodsTypeCnt <> [])
          and not (CountCargoGoodsTypes in Definitions[EntryIndex].ShipGoodsTypeCnt) then
        Continue;
      if (Definitions[EntryIndex].PlayerGoodsTypeCnt <> [])
          and not (GetPlayer.CountCargoGoodsTypes
              in Definitions[EntryIndex].PlayerGoodsTypeCnt) then
        Continue;
      if (Definitions[EntryIndex].ShipMayScanPlayer <> gcAny)
          and (((Definitions[EntryIndex].ShipMayScanPlayer = gcYes)
                  and (not (CanResolveObjectWithScanner(GetPlayer) and (GetRadarRange > 0))))
              or ((Definitions[EntryIndex].ShipMayScanPlayer = gcNo)
                  and (CanResolveObjectWithScanner(GetPlayer) and (GetRadarRange > 0)))) then
        Continue;
      Rejected := False;
      for ShipKind := stKling to stWarrior do
      begin
        case ShipKind of
          stKling: CountMask := Definitions[EntryIndex].KlingInCurStar;
          stRanger: CountMask := Definitions[EntryIndex].RangerInCurStar;
          stPirate: CountMask := Definitions[EntryIndex].PirateInCurStar;
          stWarrior: CountMask := Definitions[EntryIndex].WarriorInCurStar;
          stTransport: CountMask := Definitions[EntryIndex].TransportInCurStar;
        end;
        if CountMask <> [] then
        begin
          Count := 0;
          for K := 0 to CurrentStar.Ships.Count - 1 do
          begin
            Other := CurrentStar.Ships[K];
            if not Other.HasScriptStateText
                and (Other.TypeNameOverrideKey = '')
                and (Other.TypeId = ShipKind) then
              Inc(Count);
          end;
          Count := Min(10, Count);
          if not (Cardinal(Count) in CountMask) then
          begin
            Rejected := True;
            Break;
          end;
        end;
      end;
      if Rejected then
        Continue;
      if Definitions[EntryIndex].LastPlanetRace <> [] then
      begin
        if LastDockedPlanet = nil then
          Continue;
        if not (LastDockedPlanet.OwnerId in [oiMaloc..oiGaal, oiPirate]) then
          Continue;
        if LastDockedPlanet.CurrentStar.Status.CustomFaction <> '' then
          Continue;
        if not (LastDockedPlanet.RaceId in Definitions[EntryIndex].LastPlanetRace) then
          Continue;
        if (Definitions[EntryIndex].LastPlanetRelations <> [])
            and not (LastDockedPlanet.GetRelationLevelToShip(GetPlayer)
                in Definitions[EntryIndex].LastPlanetRelations) then
          Continue;
        if Good <> NoGreetingGoods then
        begin
          if (Definitions[EntryIndex].LastPlanetGoodsCnt <> [])
              and not (Galaxy.ClassifyGoodsQuantity(LastDockedPlanet.Goods[Good].Count, Good)
                  in Definitions[EntryIndex].LastPlanetGoodsCnt) then
            Continue;
          if (Definitions[EntryIndex].LastPlanetGoodsSale <> [])
              and not (Galaxy.ClassifyGoodsPrice(
                      GetPlayer.ShopGoodsPurchasePrice(Good, LastDockedPlanet),
                      Good)
                  in Definitions[EntryIndex].LastPlanetGoodsSale) then
            Continue;
          if (Definitions[EntryIndex].LastPlanetGoodsBuy <> [])
              and not (Galaxy.ClassifyGoodsPrice(
                      GetPlayer.ShopGoodsSellPrice(Good, LastDockedPlanet),
                      Good)
                  in Definitions[EntryIndex].LastPlanetGoodsBuy) then
            Continue;
        end;
        if (Definitions[EntryIndex].LastPlanetIsHomePlanet <> gcAny)
            and (((Definitions[EntryIndex].LastPlanetIsHomePlanet = gcYes)
                    and (not (LastDockedPlanet = HomePlanet)))
                or ((Definitions[EntryIndex].LastPlanetIsHomePlanet = gcNo)
                    and (LastDockedPlanet = HomePlanet))) then
          Continue;
        if Definitions[EntryIndex].LastPlanetRaceIsShipRace <> gcAny then
        begin
          if not (LastDockedPlanet.OwnerId in [oiMaloc..oiGaal, oiPirate]) then
            Continue;
          if (((Definitions[EntryIndex].LastPlanetRaceIsShipRace = gcYes)
                  and (not (LastDockedPlanet.RaceId = PilotRace)))
              or ((Definitions[EntryIndex].LastPlanetRaceIsShipRace = gcNo)
                  and (LastDockedPlanet.RaceId = PilotRace))) then
            Continue;
        end;
        if Definitions[EntryIndex].LastPlanetRaceIsPlayerRace <> gcAny then
        begin
          if not (LastDockedPlanet.OwnerId in [oiMaloc..oiGaal, oiPirate]) then
            Continue;
          if (((Definitions[EntryIndex].LastPlanetRaceIsPlayerRace = gcYes)
                  and (not (GetPlayer.PilotRace = LastDockedPlanet.RaceId)))
              or ((Definitions[EntryIndex].LastPlanetRaceIsPlayerRace = gcNo)
                  and (GetPlayer.PilotRace = LastDockedPlanet.RaceId))) then
            Continue;
        end;
        if (Definitions[EntryIndex].LastPlanetEconomy <> [])
            and not (LastDockedPlanet.Economy in Definitions[EntryIndex].LastPlanetEconomy) then
          Continue;
        if (Definitions[EntryIndex].LastPlanetGovernment <> [])
            and not (LastDockedPlanet.Government
                in Definitions[EntryIndex].LastPlanetGovernment) then
          Continue;
        if (Definitions[EntryIndex].LastPlanetInCurStar <> gcAny)
            and (((Definitions[EntryIndex].LastPlanetInCurStar = gcYes)
                    and (not (LastDockedPlanet.CurrentStar = CurrentStar)))
                or ((Definitions[EntryIndex].LastPlanetInCurStar = gcNo)
                    and (LastDockedPlanet.CurrentStar = CurrentStar))) then
          Continue;
        if Definitions[EntryIndex].LastPlanetDistToShipInTurn <> [] then
        begin
          Count := Min(10, EstimateTravelTurnsToPlanet(LastDockedPlanet));
          if Count = -1 then
            Continue;
          if not (Cardinal(Count) in Definitions[EntryIndex].LastPlanetDistToShipInTurn) then
            Continue;
        end;
        if LastDockedPlanet.CurrentStar <> CurrentStar then
        begin
          Rejected := False;
          for ShipKind := stKling to stWarrior do
          begin
            case ShipKind of
              stKling: CountMask := Definitions[EntryIndex].KlingInLastPlanetStar;
              stRanger: CountMask := Definitions[EntryIndex].RangerInLastPlanetStar;
              stPirate: CountMask := Definitions[EntryIndex].PirateInLastPlanetStar;
              stWarrior: CountMask := Definitions[EntryIndex].WarriorInLastPlanetStar;
              stTransport: CountMask := Definitions[EntryIndex].TransportInLastPlanetStar;
            end;
            if CountMask <> [] then
            begin
              Count := 0;
              for K := 0 to LastDockedPlanet.CurrentStar.Ships.Count - 1 do
              begin
                Other := LastDockedPlanet.CurrentStar.Ships[K];
                if not Other.HasScriptStateText
                    and (Other.TypeNameOverrideKey = '')
                    and (Other.TypeId = ShipKind) then
                  Inc(Count);
              end;
              Count := Min(10, Count);
              if not (Cardinal(Count) in CountMask) then
              begin
                Rejected := True;
                Break;
              end;
            end;
          end;
          if Rejected then
            Continue;
        end;
        MessageText :=
            ReplaceColoredToken(
                MessageText,
                '<LastPlanet>',
                LastDockedPlanet.Name + GetLocalObjectLink(LastDockedPlanet, Automatic),
                TextHighlightColorTag
            );
        MessageText :=
            ReplaceColoredToken(
                MessageText,
                '<LastPlanetStar>',
                LastDockedPlanet.CurrentStar.Name,
                TextHighlightColorTag
            );
        if Good <> NoGreetingGoods then
        begin
          MessageText :=
              ReplaceColoredToken(
                  MessageText,
                  '<LastPlanetGoodsSale>',
                  IntToStr(GetPlayer.ShopGoodsPurchasePrice(Good, LastDockedPlanet)),
                  TextHighlightColorTag
              );
          MessageText :=
              ReplaceColoredToken(
                  MessageText,
                  '<LastPlanetGoodsBuy>',
                  IntToStr(GetPlayer.ShopGoodsSellPrice(Good, LastDockedPlanet)),
                  TextHighlightColorTag
              );
        end;
      end;
      if MessageText <> '' then
      begin
        MessageText :=
            ReplaceColoredToken(
                MessageText,
                '<Ship>',
                GetName + GetLocalObjectLink(Self, Automatic),
                TextHighlightColorTag
            );
        MessageText :=
            ReplaceColoredToken(
                MessageText,
                '<FullShip>',
                GetFullName(' ') + GetLocalObjectLink(Self, Automatic),
                TextHighlightColorTag
            );
        if EnemyShip <> nil then
        begin
          MessageText :=
              ReplaceColoredToken(
                  MessageText,
                  '<ShipBad>',
                  EnemyShip.GetName + GetLocalObjectLink(EnemyShip, Automatic),
                  TextHighlightColorTag
              );
          MessageText :=
              ReplaceColoredToken(
                  MessageText,
                  '<FullShipBad>',
                  EnemyShip.GetFullName(' ') + GetLocalObjectLink(EnemyShip, Automatic),
                  TextHighlightColorTag
              );
        end;
        MessageText :=
            ReplaceColoredToken(MessageText, '<ShipRank>', GetRankName, TextHighlightColorTag);
        MessageText :=
            ReplaceColoredToken(
                MessageText,
                '<PlayerRank>',
                GetPlayer.GetRankName,
                TextHighlightColorTag
            );
        MessageText :=
            ReplaceColoredToken(MessageText, '<CurStar>', CurrentStar.Name, TextHighlightColorTag);
        if HomePlanet <> nil then
        begin
          MessageText :=
              ReplaceColoredToken(
                  MessageText,
                  '<HomePlanet>',
                  HomePlanet.Name + GetLocalObjectLink(HomePlanet, Automatic),
                  TextHighlightColorTag
              );
          MessageText :=
              ReplaceColoredToken(
                  MessageText,
                  '<HomePlanetStar>',
                  HomePlanet.CurrentStar.Name,
                  TextHighlightColorTag
              );
        end;
        BestText := MessageText;
        if CandidatePriority = -1 then
          BestPriority := Definitions[EntryIndex].Priority
        else
          BestPriority := CandidatePriority;
        if BestPriority >= 50 then
          Break;
      end;
    end;
    Result := BestText;
  end;
end;

procedure TNormalShip.UpdateAfterburnerState;
begin
  AfterburnerActive :=
      (GetSlotCount(sskAfterburner) > 0)
          and (GetEngine <> nil)
          and (GetEngine.ConditionPercent > 10)
          and (EstimateOrderTravelTurns > 1);
  RefreshDerivedStats(True);
end;

procedure TNormalShip.TrainSkillsAutomatically;
var
  Score, BestScore: Single;
  Skill, BestSkill: TPilotSkill;
  Bonus: Byte;
begin
  repeat
    BestScore := -1;
    BestSkill := psAccuracy;
    for Bonus := 22 to 27 do
    begin
      Skill := EquipmentBonusSkills[Bonus - 22];
      if BaseSkills[Skill] < 6 then
      begin
        Score :=
            Sqr(EvaluateStatBonus(TEquipmentBonusKind(Bonus), 1))
                / SkillTrainingCosts[BaseSkills[Skill] + 1, Skill];
        if Score > BestScore then
        begin
          BestScore := Score;
          BestSkill := Skill;
        end;
      end;
    end;
    if (BestScore < 0)
        or (SkillTrainingCosts[BaseSkills[BestSkill] + 1, BestSkill] > FreeExperience) then
      Break;
  until not TrainSkill(BestSkill);
end;

end.
