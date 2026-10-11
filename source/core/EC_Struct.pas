unit EC_Struct;

{$I GameOptions.inc}

interface

uses
  Types;

type

  TObjectEx = class;

  PointerToTPointF = ^TPointF;

  TPointF = record
    X: Single;
    Y: Single;
  end;

  PPointF = PointerToTPointF;

  TVector3D = record
    X: Double;
    Y: Double;
    Z: Double;
  end;

  TObjectEx = class(TObject)
    constructor Create;
    destructor Destroy; override;
  end;

var

  StartupCleanupObject: TObject;

function SquaredDistanceToPoint(const Point: TPoint; X: Integer; Y: Integer): Integer; inline;

function MakePointF(X: Single; Y: Single): TPointF;

function MakeVector3D(X: Double; Y: Double; Z: Double): TVector3D;

function TruncatePointF(Point: TPointF): TPoint;

function RoundPointF(Point: TPointF): TPoint;

function PointToPointF(Point: TPoint): TPointF;

function HalfPoint(Point: TPoint): TPoint;

function AddPoints(Left: TPoint; Right: TPoint): TPoint;

function SubtractPoints(Left: TPoint; Right: TPoint): TPoint;

function HalfPointF(Point: TPointF): TPointF;

function AddPointsF(Left: TPointF; Right: TPointF): TPointF;

function SubtractPointsF(Left: TPointF; Right: TPointF): TPointF;

function IntersectRects(out Intersection: TRect; const First: TRect; const Second: TRect): Boolean;

implementation

function SquaredDistanceToPoint(const Point: TPoint; X, Y: Integer): Integer; inline;
begin
  Result := Sqr(Point.X - X) + Sqr(Point.Y - Y);
end;

function MakePointF(X, Y: Single): TPointF;
begin
  Result.X := X;
  Result.Y := Y;
end;

function MakeVector3D(X, Y, Z: Double): TVector3D;
begin
  Result.X := X;
  Result.Y := Y;
  Result.Z := Z;
end;

function TruncatePointF(Point: TPointF): TPoint;
begin
  Result.X := Trunc(Point.X);
  Result.Y := Trunc(Point.Y);
end;

function RoundPointF(Point: TPointF): TPoint;
begin
  Result.X := Round(Point.X);
  Result.Y := Round(Point.Y);
end;

function PointToPointF(Point: TPoint): TPointF;
begin
  Result.X := Point.X;
  Result.Y := Point.Y;
end;

function HalfPoint(Point: TPoint): TPoint;
begin
  Result.X := Point.X div 2;
  Result.Y := Point.Y div 2;
end;

function AddPoints(Left, Right: TPoint): TPoint;
begin
  Result.X := Left.X + Right.X;
  Result.Y := Left.Y + Right.Y;
end;

function SubtractPoints(Left, Right: TPoint): TPoint;
begin
  Result.X := Left.X - Right.X;
  Result.Y := Left.Y - Right.Y;
end;

function HalfPointF(Point: TPointF): TPointF;
begin
  Result.X := Point.X / 2;
  Result.Y := Point.Y / 2;
end;

function AddPointsF(Left, Right: TPointF): TPointF;
begin
  Result.X := Left.X + Right.X;
  Result.Y := Left.Y + Right.Y;
end;

function SubtractPointsF(Left, Right: TPointF): TPointF;
begin
  Result.X := Left.X - Right.X;
  Result.Y := Left.Y - Right.Y;
end;

function IntersectRects(out Intersection: TRect; const First, Second: TRect): Boolean;
begin
  // Preserve the assembly's four overlap tests, even for inverted rectangles.
  // In particular, failure must leave Intersection untouched when it aliases an input.
  Result :=
      (Second.Left < First.Right)
          and (Second.Right > First.Left)
          and (Second.Top < First.Bottom)
          and (Second.Bottom > First.Top);
  if not Result then
    Exit;
  if First.Left > Second.Left then
    Intersection.Left := First.Left
  else
    Intersection.Left := Second.Left;
  if First.Right < Second.Right then
    Intersection.Right := First.Right
  else
    Intersection.Right := Second.Right;
  if First.Top > Second.Top then
    Intersection.Top := First.Top
  else
    Intersection.Top := Second.Top;
  if First.Bottom < Second.Bottom then
    Intersection.Bottom := First.Bottom
  else
    Intersection.Bottom := Second.Bottom;
end;

constructor TObjectEx.Create;
begin
  inherited Create;
end;

destructor TObjectEx.Destroy;
begin
  inherited Destroy;
end;

end.
