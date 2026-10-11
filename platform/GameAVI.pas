unit GameAVI;

{$MODE DELPHI}

interface

uses
  Classes;

type
  // The game's cinematics use one Xvid video stream in a RIFF AVI container.
  // Index chunk offsets, keeping compressed frame data in the file until needed.
  TGameAVI = class
  private
    Input: TFileStream;
    Frames: array of record
      Offset: Int64;
      Size: Cardinal;
    end;
    FrameUsed, StreamCount, VideoStream: Integer;
    procedure Scan(Last: Int64; InMovie: Boolean; StreamIndex: Integer; Depth: Integer);
    function ReadWord32: Cardinal;
  public
    Width, Height: Integer;
    FramesPerSecond: Double;
    constructor Create(const FileName: UnicodeString);
    destructor Destroy; override;
    function ReadFrame(Index: Integer; Dest: Pointer; Capacity: Integer): Integer;
    property FrameCount: Integer read FrameUsed;
  end;

implementation

uses
  SysUtils,
  GameSystem;

function TGameAVI.ReadWord32: Cardinal;
begin
  Input.ReadBuffer(Result, SizeOf(Result));
  Result := LEtoN(Result);
end;

procedure TGameAVI.Scan(Last: Int64; InMovie: Boolean; StreamIndex: Integer; Depth: Integer);
var
  ID, Size, ListType, Kind, Scale, Rate: Cardinal;
  Next, Start: Int64;
  Index: Integer;
begin
  if Depth > 16 then
    raise EReadError.Create('AVI lists nested too deeply');
  while Input.Position + 8 <= Last do
  begin
    ID := ReadWord32;
    Size := ReadWord32;
    Start := Input.Position;
    Next := Start + Size;
    if Next > Last then
      raise EReadError.Create('Truncated AVI chunk');
    if (ID = $5453494C) or (ID = $46464952) then // LIST / RIFF
    begin
      if Size < 4 then
        raise EReadError.Create('Invalid AVI list');
      ListType := ReadWord32;
      Index := StreamIndex;
      if ListType = $6C727473 then // strl
      begin
        Index := StreamCount;
        Inc(StreamCount);
      end;
      Scan(Next, InMovie or (ListType = $69766F6D), Index, Depth + 1);
    end
    else if (ID = $68727473) and (Size >= 56) then // strh
    begin
      Kind := ReadWord32;
      if (Kind = $73646976) and (VideoStream < 0) then // vids
      begin
        VideoStream := StreamIndex;
        Input.Position := Start + 20;
        Scale := ReadWord32;
        Rate := ReadWord32;
        if (Scale = 0) or (Rate = 0) then
          raise EReadError.Create('Invalid AVI frame rate');
        FramesPerSecond := Rate / Scale;
      end;
    end
    else if (ID = $66727473) and (StreamIndex = VideoStream) and (Size >= 40) then // strf
    begin
      ReadWord32; // BITMAPINFOHEADER size
      Width := Integer(ReadWord32);
      Height := Abs(Integer(ReadWord32));
    end
    else if InMovie and ((ID shr 16 = $6364) or (ID shr 16 = $6264)) then // ##dc / ##db
    begin
      Index := (Integer(ID and $FF) - Ord('0')) * 10 + Integer((ID shr 8) and $FF) - Ord('0');
      if Index = VideoStream then
      begin
        if FrameUsed = Length(Frames) then
          SetLength(Frames, FrameUsed + 1024);
        Frames[FrameUsed].Offset := Start;
        Frames[FrameUsed].Size := Size;
        Inc(FrameUsed);
      end;
    end;
    // RIFF chunk payloads are padded to even bytes; the padding is not frame data.
    Input.Position := Next + (Size and 1);
  end;
end;

constructor TGameAVI.Create(const FileName: UnicodeString);
var
  Size: Cardinal;
begin
  inherited Create;
  VideoStream := -1;
  Input := TFileStream.Create(UTF8Encode(NativeGamePath(FileName)), fmOpenRead or fmShareDenyNone);
  if ReadWord32 <> $46464952 then
    raise EReadError.Create('Not an AVI file');
  Size := ReadWord32;
  if ReadWord32 <> $20495641 then
    raise EReadError.Create('Not an AVI file');
  if Int64(Size) + 8 > Input.Size then
    raise EReadError.Create('Truncated AVI file');
  Scan(Int64(Size) + 8, False, -1, 0);
  // Large AVI files may append RIFF AVIX segments, which contain more movi lists.
  Scan(Input.Size, False, -1, 0);
  if (VideoStream < 0) or (Width <= 0) or (Height <= 0) or (FrameUsed = 0) then
    raise EReadError.Create('AVI has no usable video stream');
end;

destructor TGameAVI.Destroy;
begin
  Input.Free;
  inherited Destroy;
end;

function TGameAVI.ReadFrame(Index: Integer; Dest: Pointer; Capacity: Integer): Integer;
begin
  if (Index < 0) or (Index >= FrameUsed) then
    raise EReadError.Create('AVI frame out of range');
  if Frames[Index].Size > High(Integer) then
    raise EReadError.Create('AVI frame too large');
  Input.Position := Frames[Index].Offset;
  Result := Frames[Index].Size;
  if Result > Capacity then
    raise EReadError.Create('AVI frame exceeds decode buffer');
  if Result > 0 then
    Input.ReadBuffer(Dest^, Result);
end;

end.
