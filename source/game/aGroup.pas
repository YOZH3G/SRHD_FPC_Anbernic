unit aGroup;

{$I GameOptions.inc}

interface

uses
  Types,
  Classes,
  EC_Buf,
  EC_Struct,
  aGalaxy,
  aShip;

type

  TGroup = class;

  {$Z1}
  TGroupWaitMode = (GroupWaitArrival = 0, GroupWaitAssembly = 2, GroupWaitUntilTurn = 3);

  TGroupRouteOrder = record
    Kind: TShipOrder;
    Target: TObject;
    Destination: TPointF;
    WaitMode: TGroupWaitMode;
    WaitUntilTurn: Integer;
  end;

  TGroup = class(TObjectEx)
    CreatedTurn: Integer;
    GenerationSeed: Cardinal;
    RandomState: Cardinal;
    Ships: TList;
    Route: array of TGroupRouteOrder;
    TargetStar: TStar;
    AssemblyStar: TStar;
    constructor Create;
    destructor Destroy; override;
    procedure Save(Buffer: TBufEC);
    procedure Load(Buffer: TBufEC; Galaxy: TGalaxy);
    procedure ResolveLoadedReferences(Galaxy: TGalaxy);
    procedure AddShip(Ship: TShip);
    procedure NextDay;
    procedure Disband;
    function SelectLiberationTarget: Boolean;
    function BuildLiberationOrders: Boolean;
    function AreShipsAssembled: Boolean;
    procedure AdvanceRouteForShips;
    function GetShipGreeting(Ship: Pointer): WideString;
    function FindCentralMemberStar: TStar;
  end;

implementation

uses
  aConst,
  SysUtils,
  Math,
  aPlanet,
  aMyFunction,
  Globals,
  GlobalsV,
  aGalaxyStruct;

constructor TGroup.Create;
begin
  inherited Create;
  if Galaxy <> nil then
  begin
    CreatedTurn := Galaxy.CurrentTurn;
    GenerationSeed :=
        SeededRandomIntRange(100000, MaxInt, Galaxy.GenerationSeed * Galaxy.CurrentTurn);
    RandomState := GenerationSeed;
  end;
  Ships := TList.Create;
  SetLength(Route, 0);
  Route := nil;
  TargetStar := nil;
  AssemblyStar := nil;
end;

destructor TGroup.Destroy;
begin
  if Ships <> nil then
  begin
    Ships.Free;
    Ships := nil;
  end;
  inherited Destroy;
end;

procedure TGroup.Save(Buffer: TBufEC);
var
  I, Count: Integer;
  Ship: TShip;
  Order: TGroupRouteOrder;
begin
  Buffer.AddWideChar(WideChar(CreatedTurn));
  Buffer.AddDWord(GenerationSeed);
  Buffer.AddDWord(RandomState);
  Buffer.AddAnsiChar(#0);
  Count := Ships.Count;
  Buffer.AddWideChar(WideChar(Count));
  for I := 0 to Count - 1 do
  begin
    Ship := Ships[I];
    Buffer.AddDWord(Ship.Id);
  end;
  Count := Length(Route);
  Buffer.AddWideChar(WideChar(Count));
  for I := 0 to Count - 1 do
  begin
    Order := Route[I];
    Buffer.AddAnsiChar(AnsiChar(Order.Kind));
    if Order.Kind = soJump then
      Buffer.AddDWord((Order.Target as TStar).Id)
    else if Order.Kind = soJumpHole then
      Buffer.AddDWord((Order.Target as THole).Id)
    else if Order.Kind = soLand then
    begin
      if Order.Target is TShip then
        Buffer.AddDWord(Cardinal((Order.Target as TShip).Id) or OrderTargetShipFlag)
      else
        Buffer.AddDWord((Order.Target as TPlanet).Id);
    end
    else if Order.Kind = soFollowShip then
      Buffer.AddDWord((Order.Target as TShip).Id)
    else
      Buffer.AddDWord(0);
    Buffer.AddSingle(Order.Destination.X);
    Buffer.AddSingle(Order.Destination.Y);
    Buffer.AddAnsiChar(AnsiChar(Order.WaitMode));
    Buffer.AddIntegerValue(Order.WaitUntilTurn);
  end;
end;

procedure TGroup.Load(Buffer: TBufEC; Galaxy: TGalaxy);
var
  I, Count, OldestTurn: Integer;
begin
  CreatedTurn := Buffer.GetWord;
  OldestTurn := Galaxy.CurrentTurn - 1000;
  while CreatedTurn < OldestTurn do
    Inc(CreatedTurn, $10000);
  GenerationSeed := Buffer.GetUInt32;
  RandomState := Buffer.GetUInt32;
  Buffer.GetByte;
  Count := Buffer.GetWord;
  if (Count < 0) or (Count > MaxSavedListCount) then
    raise EAbort.Create('Err TGroup.Load FShips');
  for I := 0 to Count - 1 do
    Ships.Add(Pointer(Buffer.GetUInt32));
  Count := Buffer.GetWord;
  if (Count < 0) or (Count > MaxSavedListCount) then
    raise EAbort.Create('Err TGroup.Load FOrders');
  SetLength(Route, Count);
  for I := 0 to Count - 1 do
  begin
    Route[I].Kind := TShipOrder(Buffer.GetByte);
    Route[I].Target := TObject(Buffer.GetUInt32);
    Route[I].Destination.X := Buffer.GetSingle;
    Route[I].Destination.Y := Buffer.GetSingle;
    Route[I].WaitMode := TGroupWaitMode(Buffer.GetByte);
    Route[I].WaitUntilTurn := Buffer.GetInt32;
  end;
end;

procedure TGroup.ResolveLoadedReferences(Galaxy: TGalaxy);
var
  I: Integer;
  Ship: TShip;
begin
  for I := 0 to Ships.Count - 1 do
  begin
    Ships[I] := TObject(Galaxy.IdToShip(Cardinal(Ships[I]), True)) as TShip;
    Ship := Ships[I];
    Ship.LiberationGroup := Self;
  end;
  for I := 0 to Length(Route) - 1 do
  begin
    if Route[I].Kind = soJump then
      Route[I].Target := TObject(Galaxy.IdToStar(Cardinal(Route[I].Target))) as TStar
    else if Route[I].Kind = soJumpHole then
      Route[I].Target := TObject(Galaxy.IdToHole(Cardinal(Route[I].Target))) as THole
    else if Route[I].Kind = soLand then
    begin
      if Cardinal(Route[I].Target) and OrderTargetShipFlag = OrderTargetShipFlag then
        Route[I].Target :=
            TObject(Galaxy.IdToShip(Cardinal(Route[I].Target) and TaggedObjectIdMask, True))
                as TShip
      else
        Route[I].Target := TObject(Galaxy.IdToPlanet(Cardinal(Route[I].Target))) as TPlanet;
    end
    else if Route[I].Kind = soFollowShip then
      Route[I].Target := TObject(Galaxy.IdToShip(Cardinal(Route[I].Target), True)) as TShip
    else
      Route[I].Target := nil;
  end;
end;

procedure TGroup.AddShip(Ship: TShip);
begin
  Ships.Add(Ship);
  Ship.LiberationGroup := Self;
  Ship.LiberationGroupRouteIndex := 0;
end;

procedure TGroup.NextDay;
begin
  if Ships.Count = 0 then
  begin
    Galaxy.LiberationGroups.Delete(Galaxy.LiberationGroups.IndexOf(Self));
    Free;
  end
  else if Galaxy.CurrentTurn > CreatedTurn + 150 then
    Disband;
end;

procedure TGroup.Disband;
var
  I: Integer;
  Ship: TShip;
begin
  for I := Ships.Count - 1 downto 0 do
  begin
    Ship := Ships[I];
    Ship.LeaveLiberationGroup;
  end;
  Galaxy.LiberationGroups.Delete(Galaxy.LiberationGroups.IndexOf(Self));
  Free;
end;

function TGroup.SelectLiberationTarget: Boolean;
var
  Attempts: Integer;
begin
  TargetStar := Galaxy.SelectStarForLiberationAttack(FindCentralMemberStar, sfCoalition);
  Attempts := 0;
  while (TargetStar = nil)
      or TargetStar.HasLiberationGroupOrder
      or Galaxy.HasMilitaryBaseAssignedToStar(TargetStar) do
  begin
    if Attempts > 10 then
    begin
      TargetStar := nil;
      AssemblyStar := nil;
      Disband;
      Result := False;
      Exit;
    end;
    TargetStar := Galaxy.SelectStarForLiberationAttack(FindCentralMemberStar, sfCoalition);
    Inc(Attempts);
  end;
  AssemblyStar := TargetStar.FindNearestStarByFaction(sfCoalition, False);
  if (AssemblyStar = nil) or (PointDistance(AssemblyStar.Position, TargetStar.Position) > 28) then
  begin
    TargetStar := nil;
    AssemblyStar := nil;
    Result := False;
    Disband;
  end
  else
    Result := True;
end;

function TGroup.BuildLiberationOrders: Boolean;
var
  Planet: TPlanet;
  Text: WideString;
begin
  Result := True;
  if not (((TargetStar <> nil) and (AssemblyStar <> nil)) or SelectLiberationTarget) then
    Exit;
  SetLength(Route, 4);
  with Route[0] do
  begin
    Kind := soJump;
    Target := AssemblyStar;
    WaitMode := GroupWaitArrival;
    WaitUntilTurn := 0;
  end;
  Planet := TObject(AssemblyStar.FindFirstInhabitedPlanet) as TPlanet;
  if Planet = nil then
  begin
    Result := False;
    Disband;
    Exit;
  end;
  with Route[1] do
  begin
    Kind := soLand;
    Target := Planet;
    WaitMode := GroupWaitArrival;
    WaitUntilTurn := 0;
  end;
  with Route[2] do
  begin
    Kind := soMove;
    Target := nil;
    Destination := AssemblyStar.GetBoundaryPointTowardStar(TargetStar);
    WaitMode := GroupWaitUntilTurn;
    WaitUntilTurn := Galaxy.CurrentTurn + NextRandomIntRange(45, 55, RandomState);
  end;
  with Route[3] do
  begin
    Kind := soJump;
    Target := TargetStar;
    WaitMode := GroupWaitArrival;
    WaitUntilTurn := 0;
  end;
  if TargetStar.Status.CustomFaction <> '' then
    Text :=
        PickLocalizedTextVariant(
            'GalaxyNews.Group.WarriorLiberator.Create' + TargetStar.Status.CustomFaction,
            RandomState * (Galaxy.CurrentTurn mod 71)
        )
  else if TargetStar.ControlFaction = sfPirates then
    Text :=
        PickLocalizedTextVariant(
            'GalaxyNews.Group.WarriorLiberator.CreatePirates',
            RandomState * (Galaxy.CurrentTurn mod 71)
        )
  else
    Text :=
        PickLocalizedTextVariant(
            'GalaxyNews.Group.WarriorLiberator.Create',
            RandomState * (Galaxy.CurrentTurn mod 71)
        );
  ReplaceTextToken(Text, '<StarNormal>', AssemblyStar.Name, TextHighlightColorTag);
  ReplaceTextToken(Text, '<StarEnemy>', TargetStar.Name, TextHighlightColorTag);
  ReplaceTextToken(
      Text,
      '<SectorNormal>',
      AssemblyStar.Constellation.GetName,
      TextHighlightColorTag
  );
  ReplaceTextToken(Text, '<SectorEnemy>', TargetStar.Constellation.GetName, TextHighlightColorTag);
  ReplaceTextToken(
      Text,
      '<Date>',
      Galaxy.FormatTurnDate(Route[2].WaitUntilTurn),
      TextHighlightColorTag
  );
  Galaxy.AddPlanetNews(gnLiberationGroupCreated, Text);
end;

function TGroup.AreShipsAssembled: Boolean;
var
  I, RouteIndex: Integer;
  Ship: TShip;
begin
  Ship := Ships[0];
  RouteIndex := Ship.LiberationGroupRouteIndex;
  for I := 0 to Ships.Count - 1 do
  begin
    Ship := Ships[I];
    if (Ship.LiberationGroupRouteIndex <> RouteIndex)
        or not (Ship.Order in [soNone, soMove])
        or (PointDistanceSquared(Ship.Position, Route[RouteIndex].Destination) > 90000) then
    begin
      Result := False;
      Exit;
    end;
  end;
  Result := True;
end;

procedure TGroup.AdvanceRouteForShips;
var
  I: Integer;
  Ship: TShip;
begin
  for I := Ships.Count - 1 downto 0 do
  begin
    Ship := Ships[I];
    Inc(Ship.LiberationGroupRouteIndex);
    if Ship.LiberationGroupRouteIndex >= Length(Route) then
      Ship.LeaveLiberationGroup
    else
      Ship.ProcessLiberationGroupRoute;
  end;
end;

function TGroup.GetShipGreeting(Ship: Pointer): WideString;
var
  Star: TStar;
begin
  Result := '';
  if TShip(Ship).LiberationGroupRouteIndex <> 0 then
  begin
    Star := Route[3].Target as TStar;
    if Galaxy.CurrentTurn < Route[2].WaitUntilTurn then
      Result :=
          FormatText2(
              PickLocalizedTextVariant(
                  'ShipGreetings.Group.WarriorLiberatorBefore',
                  NextRandomIntRange(100, 1000, RandomState)
              ),
              TextHighlightColorTag,
              '<StarEnemy>',
              Star.Name,
              '<Date>',
              Galaxy.FormatTurnDate(Route[2].WaitUntilTurn)
          )
    else
      Result :=
          FormatText2(
              PickLocalizedTextVariant(
                  'ShipGreetings.Group.WarriorLiberatorAfter',
                  NextRandomIntRange(100, 1000, RandomState)
              ),
              TextHighlightColorTag,
              '<StarEnemy>',
              Star.Name,
              '<Date>',
              Galaxy.FormatTurnDate(Route[2].WaitUntilTurn)
          );
  end;
end;

function TGroup.FindCentralMemberStar: TStar;
var
  I, J, Distance, BestDistance: Integer;
  Ship: TShip;
  Planet: TPlanet;
begin
  Result := nil;
  BestDistance := MaxInt;
  for I := Ships.Count - 1 downto 0 do
  begin
    Ship := Ships[I];
    Distance := 0;
    for J := 0 to Galaxy.Planets.Count - 1 do
    begin
      Planet := Galaxy.Planets[J];
      Inc(Distance, Round(PointDistance(Ship.CurrentStar.Position, Planet.CurrentStar.Position)));
    end;
    if BestDistance > Distance then
    begin
      Result := Ship.CurrentStar;
      BestDistance := Distance;
    end;
  end;
end;

end.
