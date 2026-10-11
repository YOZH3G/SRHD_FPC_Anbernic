unit ab_WorldImage;

{$I GameOptions.inc}

interface

uses
  GameHeap,
  EC_Struct,
  GI_Image;

const

  afmRestart = 0;

  afmRandomStart = 1;

type

  PointerToTabWorldImage = ^TabWorldImage;

  PabWorldImage = PointerToTabWorldImage;

  TabWorldImage = record
    Prev: PabWorldImage;
    Next: PabWorldImage;
    Position: TVector3D;
    Image: TImageGI;
    FrontImagePath: WideString;
    BackImagePath: WideString;
    FrontDepth: Single;
    BackDepth: Single;
    Dirty: Boolean;
    FrameMode: Integer;
    LoopAnimation: Boolean;
    Finished: Boolean;
    StopAnimation: Boolean;
  end;

var

  WorldImageHeap: TGameHeapHandle = 0;

  FirstWorldImage: PabWorldImage = nil;

  LastWorldImage: PabWorldImage = nil;

procedure ab_WorldImage_Clear;

function ab_WorldImage_Add: PabWorldImage;

procedure ab_WorldImage_Delete(Entry: PabWorldImage);

function ab_WorldImage_Create(
    Position: TVector3D;
    const FrontPath: WideString;
    const BackPath: WideString;
    StopAnimation: Boolean
): PabWorldImage;

procedure ab_WorldImage_Set(
    Entry: PabWorldImage;
    Position: TVector3D;
    const FrontPath: WideString;
    const BackPath: WideString
);

procedure ab_WorldImage_SetPosition(Entry: PabWorldImage; Position: TVector3D);

procedure ab_WorldImage_SetDepth(Entry: PabWorldImage; FrontDepth: Single; BackDepth: Single);

procedure ab_WorldImage_SetFrameMode(Entry: PabWorldImage; Value: Integer);

procedure ab_WorldImage_SetLooping(Entry: PabWorldImage; Value: Boolean);

procedure ab_WorldImage_Update;

implementation

uses
  Types,
  Classes,
  SysUtils,
  EC_Mem,
  GI_Tail,
  ab_Global,
  Globals,
  aMyFunction;

procedure ab_WorldImage_Clear;
begin
  while not (FirstWorldImage = nil) do
    ab_WorldImage_Delete(LastWorldImage);
  if WorldImageHeap <> 0 then
  begin
    GameHeap.HeapDestroy(WorldImageHeap);
    WorldImageHeap := 0;
  end;
end;

function ab_WorldImage_Add: PabWorldImage;
var
  Entry: PabWorldImage;
begin
  if WorldImageHeap = 0 then
  begin
    WorldImageHeap := GameHeap.HeapCreate(1, $8000, 0);
    if WorldImageHeap = 0 then
      raise Exception.Create('ab_WorldImage_Add.HeapCreate');
  end;
  Entry := AllocClearFromHeapEC(WorldImageHeap, SizeOf(TabWorldImage));
  if LastWorldImage <> nil then
    LastWorldImage.Next := Entry;
  Entry.Prev := LastWorldImage;
  Entry.Next := nil;
  LastWorldImage := Entry;
  if FirstWorldImage = nil then
    FirstWorldImage := Entry;
  Result := Entry;
end;

procedure ab_WorldImage_Delete(Entry: PabWorldImage);
begin
  if Entry.Prev <> nil then
    Entry.Prev.Next := Entry.Next;
  if Entry.Next <> nil then
    Entry.Next.Prev := Entry.Prev;
  if LastWorldImage = Entry then
    LastWorldImage := Entry.Prev;
  if FirstWorldImage = Entry then
    FirstWorldImage := Entry.Next;
  if Entry.Image <> nil then
  begin
    Entry.Image.Free;
    Entry.Image := nil;
  end;
  Entry.FrontImagePath := '';
  Entry.BackImagePath := '';
  if WorldImageHeap <> 0 then
    FreeFromHeapEC(WorldImageHeap, Entry);
end;

function ab_WorldImage_Create(
    Position: TVector3D;
    const FrontPath, BackPath: WideString;
    StopAnimation: Boolean
): PabWorldImage;
var
  Entry: PabWorldImage;
begin
  Entry := ab_WorldImage_Add;
  Entry.Position := Position;
  Entry.FrontImagePath := FrontPath;
  Entry.BackImagePath := BackPath;
  Entry.Dirty := True;
  Entry.LoopAnimation := True;
  Entry.Finished := False;
  Entry.FrontDepth := WorldImageFrontDepth;
  Entry.BackDepth := WorldImageBackDepth;
  Entry.FrameMode := afmRestart;
  Entry.StopAnimation := StopAnimation;
  Result := Entry;
end;

procedure ab_WorldImage_Set(
    Entry: PabWorldImage;
    Position: TVector3D;
    const FrontPath, BackPath: WideString
);
begin
  Entry.Position := Position;
  Entry.FrontImagePath := FrontPath;
  Entry.BackImagePath := BackPath;
  Entry.LoopAnimation := True;
  Entry.Finished := False;
  Entry.FrontDepth := WorldImageFrontDepth;
  Entry.BackDepth := WorldImageBackDepth;
  Entry.FrameMode := afmRestart;
  Entry.Dirty := True;
end;

procedure ab_WorldImage_SetPosition(Entry: PabWorldImage; Position: TVector3D);
begin
  Entry.Position := Position;
end;

procedure ab_WorldImage_SetDepth(Entry: PabWorldImage; FrontDepth, BackDepth: Single);
begin
  Entry.FrontDepth := FrontDepth;
  Entry.BackDepth := BackDepth;
  Entry.Dirty := True;
end;

procedure ab_WorldImage_SetFrameMode(Entry: PabWorldImage; Value: Integer);
begin
  Entry.FrameMode := Value;
end;

procedure ab_WorldImage_SetLooping(Entry: PabWorldImage; Value: Boolean);
begin
  Entry.LoopAnimation := Value;
  Entry.Dirty := True;
  Entry.StopAnimation := False;
end;

procedure ab_WorldImage_Update;
var
  Entry: PabWorldImage;
  Frame: Integer;
  Position, Center: TVector3D;
begin
  Center := MakeVector3D(0, 0, 0);
  Center := ProjectPointByMatrix(SphereProjectionMatrix, Center);
  Entry := FirstWorldImage;
  while Entry <> nil do
  begin
    if Entry.Finished then
    begin
      if Entry.Image <> nil then
        Entry.Image.SetActive(False);
      Entry := Entry.Next;
      Continue;
    end;
    Position := ProjectPointByMatrix(SphereProjectionMatrix, Entry.Position);
    if Entry.Image = nil then
      Entry.Image := TImageGI.Create(ArcadeBattleScreen.WorldPanel);
    Frame := 0;
    if Entry.Image.GaiImageControl <> nil then
      Frame := Entry.Image.GaiImageControl.SequenceFrame;
    if not IsDepthBeforeSphereHorizon(Position.Z) then
    begin
      if (Entry.Image.Depth <> Entry.BackDepth) or Entry.Dirty then
      begin
        Entry.Image.SetActive(Entry.BackImagePath <> '');
        if Entry.Image.Active then
        begin
          Entry.Image.SetImagePath(Entry.BackImagePath);
          Entry.Image.SetSize(Entry.Image.GetContentSize);
          Entry.Image.SetOrigin(HalfPoint(Entry.Image.ClientSize));
          if (Entry.Image.GaiImageControl <> nil) and not Entry.StopAnimation then
          begin
            Entry.Image.GaiImageControl.UserValue := PtrInt(Entry);
            if not Entry.LoopAnimation then
              Entry.Image.GaiImageControl.CycleCompleteCallback :=
                  ArcadeBattleScreen.WorldImageCycleComplete
            else
              Entry.Image.GaiImageControl.CycleCompleteCallback := nil;
            if (Entry.FrameMode = afmRestart) and Entry.Dirty then
              Entry.Image.GaiImageControl.SetSequenceFrame(0)
            else if (Entry.FrameMode = afmRandomStart) and Entry.Dirty then
              Entry.Image.GaiImageControl.SetSequenceFrame(
                  RandomIntRange(0, Entry.Image.GaiImageControl.SequenceFrameCount - 1)
              )
            else
              Entry.Image.GaiImageControl.SetSequenceFrame(Frame);
            Entry.Image.RestartPlayback;
          end
          else
            Entry.Image.StopPlayback;
        end;
        Entry.Image.SetDepth(Entry.BackDepth);
      end;
    end
    else
    begin
      if (Entry.Image.Depth <> Entry.FrontDepth) or Entry.Dirty then
      begin
        Entry.Image.SetActive(Entry.FrontImagePath <> '');
        if Entry.Image.Active then
        begin
          Entry.Image.SetImagePath(Entry.FrontImagePath);
          Entry.Image.SetSize(Entry.Image.GetContentSize);
          Entry.Image.SetOrigin(HalfPoint(Entry.Image.ClientSize));
          if (Entry.Image.GaiImageControl <> nil) and not Entry.StopAnimation then
          begin
            Entry.Image.GaiImageControl.UserValue := PtrInt(Entry);
            if not Entry.LoopAnimation then
              Entry.Image.GaiImageControl.CycleCompleteCallback :=
                  ArcadeBattleScreen.WorldImageCycleComplete
            else
              Entry.Image.GaiImageControl.CycleCompleteCallback := nil;
            if (Entry.FrameMode = afmRestart) and Entry.Dirty then
              Entry.Image.GaiImageControl.SetSequenceFrame(0)
            else if (Entry.FrameMode = afmRandomStart) and Entry.Dirty then
              Entry.Image.GaiImageControl.SetSequenceFrame(
                  RandomIntRange(0, Entry.Image.GaiImageControl.SequenceFrameCount - 1)
              )
            else
              Entry.Image.GaiImageControl.SetSequenceFrame(Frame);
            Entry.Image.RestartPlayback;
          end
          else
            Entry.Image.StopPlayback;
        end;
        Entry.Image.SetDepth(Entry.FrontDepth);
      end;
    end;
    Entry.Dirty := False;
    Entry.Image.SetPosition(Classes.Point(Round(Position.X), Round(Position.Y)));
    Entry := Entry.Next;
  end;
end;

end.
