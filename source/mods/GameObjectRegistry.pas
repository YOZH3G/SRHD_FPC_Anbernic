unit GameObjectRegistry;

{$I GameOptions.inc}

interface

// Check addresses before using RTTI on script-supplied object handles. This is
// a weak registry: it does not extend object lifetime or change save layouts.
procedure RegisterGameObject(Value: Pointer);
procedure UnregisterGameObject(Value: Pointer);
function IsLiveGameObject(Value: Pointer): Boolean;

implementation

const
  DeletedEntry = Pointer(1);

var
  Entries: array of Pointer;
  LiveCount, UsedCount: SizeUInt;
  // Keep table synchronization independent of game-state thread handoffs:
  // overlapping updates/lookups can corrupt entries or race with a rehash.
  // This lock protects bookkeeping, not object lifetime after a lookup.
  // With selective tracking, measured registry overhead was small compared
  // with normal turn processing, so retain synchronization for table safety.
  RegistryLock: TRTLCriticalSection;

function FirstSlot(Value: Pointer): SizeUInt;
begin
  Result := ((PtrUInt(Value) shr 4) xor (PtrUInt(Value) shr 17)) and (Length(Entries) - 1);
end;

// Call under RegistryLock with a nonempty table. Deleted slots keep the probe
// chain intact, so lookup and removal must advance to the same empty slot.
function FindSlot(Value: Pointer): SizeUInt;
begin
  Result := FirstSlot(Value);
  while (Entries[Result] <> nil) and (Entries[Result] <> Value) do
    Result := (Result + 1) and (Length(Entries) - 1);
end;

procedure Insert(Value: Pointer);
var
  I, Deleted: SizeUInt;
begin
  I := FirstSlot(Value);
  Deleted := High(SizeUInt);
  while Entries[I] <> nil do
  begin
    if Entries[I] = Value then
      Exit;
    if (Entries[I] = DeletedEntry) and (Deleted = High(SizeUInt)) then
      Deleted := I;
    I := (I + 1) and (Length(Entries) - 1);
  end;
  if Deleted <> High(SizeUInt) then
    I := Deleted
  else
    Inc(UsedCount);
  Entries[I] := Value;
  Inc(LiveCount);
end;

procedure RegisterGameObject(Value: Pointer);
var
  OldEntries, NewEntries: array of Pointer;
  NewSize, I: SizeInt;
begin
  if PtrUInt(Value) <= 1 then
    Exit;
  EnterCriticalSection(RegistryLock);
  try
    if (Length(Entries) = 0) or ((UsedCount + 1) * 4 >= SizeUInt(Length(Entries)) * 3) then
    begin
      NewSize := Length(Entries);
      if NewSize = 0 then
        NewSize := 1024
      else if LiveCount * 2 >= SizeUInt(NewSize) then
        NewSize := NewSize * 2;
      // Allocate before replacing the active table so a failed allocation
      // leaves existing object lifetimes registered.
      SetLength(NewEntries, NewSize);
      OldEntries := Entries;
      Entries := NewEntries;
      LiveCount := 0;
      UsedCount := 0;
      for I := 0 to High(OldEntries) do
        if (OldEntries[I] <> nil) and (OldEntries[I] <> DeletedEntry) then
          Insert(OldEntries[I]);
    end;
    Insert(Value);
  finally
    LeaveCriticalSection(RegistryLock);
  end;
end;

procedure UnregisterGameObject(Value: Pointer);
var
  I: SizeUInt;
begin
  if PtrUInt(Value) <= 1 then
    Exit;
  EnterCriticalSection(RegistryLock);
  try
    if Length(Entries) = 0 then
      Exit;
    I := FindSlot(Value);
    if Entries[I] = Value then
    begin
      Entries[I] := DeletedEntry;
      Dec(LiveCount);
    end;
  finally
    LeaveCriticalSection(RegistryLock);
  end;
end;

function IsLiveGameObject(Value: Pointer): Boolean;
begin
  Result := False;
  if PtrUInt(Value) <= 1 then
    Exit;
  EnterCriticalSection(RegistryLock);
  try
    if Length(Entries) = 0 then
      Exit;
    Result := Entries[FindSlot(Value)] = Value;
  finally
    LeaveCriticalSection(RegistryLock);
  end;
end;

initialization
  InitCriticalSection(RegistryLock);
finalization
  DoneCriticalSection(RegistryLock);
end.
