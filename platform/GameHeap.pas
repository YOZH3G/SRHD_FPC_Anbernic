unit GameHeap;

{$MODE DELPHI}
{$POINTERMATH ON}

interface

type
  TGameHeapHandle = PtrUInt;

const
  HEAP_ZERO_MEMORY = 8;

function GetProcessHeap: TGameHeapHandle;
function HeapCreate(Flags: Cardinal; InitialSize, MaximumSize: SizeUInt): TGameHeapHandle;
function HeapDestroy(Heap: TGameHeapHandle): Boolean;
function HeapAlloc(Heap: TGameHeapHandle; Flags: Cardinal; ByteCount: SizeUInt): Pointer;
function HeapReAlloc(
    Heap: TGameHeapHandle;
    Flags: Cardinal;
    Data: Pointer;
    ByteCount: SizeUInt
): Pointer;
function HeapFree(Heap: TGameHeapHandle; Flags: Cardinal; Data: Pointer): Boolean;

implementation

uses
  SysUtils;

type
  PHeapBlock = ^THeapBlock;
  THeapBlock = record
    Prev, Next: PHeapBlock;
  end;

  TGameHeap = class
    First: PHeapBlock;
    Lock: TRTLCriticalSection;
    constructor Create;
    destructor Destroy; override;
  end;

constructor TGameHeap.Create;
begin
  inherited Create;
  InitCriticalSection(Lock);
end;

destructor TGameHeap.Destroy;
var
  Block: PHeapBlock;
begin
  // Arcade pools release outstanding allocations when their heap is destroyed.
  // Keep that ownership without depending on a Windows heap or a C allocator.
  while First <> nil do
  begin
    Block := First;
    First := Block.Next;
    FreeMem(Block);
  end;
  DoneCriticalSection(Lock);
  inherited Destroy;
end;

function GetProcessHeap: TGameHeapHandle;
begin
  Result := 1;
end;

function HeapCreate(Flags: Cardinal; InitialSize, MaximumSize: SizeUInt): TGameHeapHandle;
begin
  // All game heaps are growable. FPC manages reservation and synchronization;
  // the original initial-size and HEAP_NO_SERIALIZE hints need no equivalent.
  if MaximumSize <> 0 then
    raise Exception.Create('Game heaps must be growable');
  Result := TGameHeapHandle(TGameHeap.Create);
end;

function HeapDestroy(Heap: TGameHeapHandle): Boolean;
begin
  Result := Heap > GetProcessHeap;
  if Result then
    TGameHeap(Heap).Free;
end;

function HeapAlloc(Heap: TGameHeapHandle; Flags: Cardinal; ByteCount: SizeUInt): Pointer;
var
  Owner: TGameHeap;
  Block: PHeapBlock;
begin
  Result := nil;
  if Heap = 0 then
    Exit;
  // Windows permits zero-byte allocations and returns a freeable address.
  if ByteCount = 0 then
    ByteCount := 1;
  try
    if Heap = GetProcessHeap then
      GetMem(Result, ByteCount)
    else
    begin
      if ByteCount > High(SizeUInt) - SizeUInt(SizeOf(THeapBlock)) then
        Exit;
      GetMem(Block, ByteCount + SizeOf(THeapBlock));
      if Block = nil then
        Exit;
      Owner := TGameHeap(Heap);
      EnterCriticalSection(Owner.Lock);
      try
        Block.Prev := nil;
        Block.Next := Owner.First;
        if Owner.First <> nil then
          Owner.First.Prev := Block;
        Owner.First := Block;
      finally
        LeaveCriticalSection(Owner.Lock);
      end;
      Result := Block + 1;
    end;
    if (Result <> nil) and (Flags and HEAP_ZERO_MEMORY <> 0) then
      FillChar(Result^, ByteCount, 0);
  except
    // EC_Mem retries after releasing texture caches. Do not change FPC's global
    // ReturnNilIfGrowHeapFails setting: other threads use the same allocator.
    on E: EOutOfMemory do
      Result := nil;
  end;
end;

function HeapReAlloc(
    Heap: TGameHeapHandle;
    Flags: Cardinal;
    Data: Pointer;
    ByteCount: SizeUInt
): Pointer;
var
  Owner: TGameHeap;
  Block, Resized, Prev, Next: PHeapBlock;
begin
  Result := nil;
  if (Heap = 0) or (Data = nil) then
    Exit;
  // Game reallocations never request zero-filling of the extended region.
  if Flags <> 0 then
    raise Exception.Create('Unsupported game heap reallocation flags');
  if ByteCount = 0 then
    ByteCount := 1;
  try
    if Heap = GetProcessHeap then
    begin
      Result := Data;
      ReAllocMem(Result, ByteCount);
    end
    else
    begin
      if ByteCount > High(SizeUInt) - SizeUInt(SizeOf(THeapBlock)) then
        Exit;
      Owner := TGameHeap(Heap);
      EnterCriticalSection(Owner.Lock);
      try
        Block := PHeapBlock(Data) - 1;
        Prev := Block.Prev;
        Next := Block.Next;
        Resized := Block;
        ReAllocMem(Resized, ByteCount + SizeOf(THeapBlock));
        if Resized = nil then
          Exit;
        if Prev = nil then
          Owner.First := Resized
        else
          Prev.Next := Resized;
        if Next <> nil then
          Next.Prev := Resized;
        Result := Resized + 1;
      finally
        LeaveCriticalSection(Owner.Lock);
      end;
    end;
  except
    on E: EOutOfMemory do
      Result := nil;
  end;
end;

function HeapFree(Heap: TGameHeapHandle; Flags: Cardinal; Data: Pointer): Boolean;
var
  Owner: TGameHeap;
  Block: PHeapBlock;
begin
  Result := Heap <> 0;
  if not Result or (Data = nil) then
    Exit;
  if Heap = GetProcessHeap then
    FreeMem(Data)
  else
  begin
    Owner := TGameHeap(Heap);
    Block := PHeapBlock(Data) - 1;
    EnterCriticalSection(Owner.Lock);
    try
      if Block.Prev = nil then
        Owner.First := Block.Next
      else
        Block.Prev.Next := Block.Next;
      if Block.Next <> nil then
        Block.Next.Prev := Block.Prev;
    finally
      LeaveCriticalSection(Owner.Lock);
    end;
    FreeMem(Block);
  end;
end;

end.
