program RaySphereSmoke;
{$MODE delphi}
uses
  SysUtils, Math, EC_Struct, ab_Global;
var
  Origin, PointOnRay, Center, Hit: TVector3D;
begin
  SetExceptionMask([exInvalidOp, exDenormalized, exZeroDivide, exOverflow, exUnderflow, exPrecision]);
  Origin := MakeVector3D(0, 0, -2);
  PointOnRay := MakeVector3D(0, 0, -1);
  Center := MakeVector3D(0, 0, 0);
  if not TryIntersectRayWithSphere(Origin, PointOnRay, Center, 1, Hit) then
    Halt(1);
  if (Abs(Hit.X) > 1e-8) or (Abs(Hit.Y) > 1e-8) or (Abs(Hit.Z + 1) > 1e-8) then
    Halt(2);
  if Origin.Z <> -2 then
    Halt(3);
  // Match the game's call, where input and output refer to the same vector.
  if not TryIntersectRayWithSphere(Origin, PointOnRay, Center, 1, Origin) then
    Halt(4);
  if Abs(Origin.Z + 1) > 1e-8 then
    Halt(5);
  Origin := MakeVector3D(2, 0, -2);
  PointOnRay := MakeVector3D(2, 0, -1);
  if TryIntersectRayWithSphere(Origin, PointOnRay, Center, 1, Hit) then
    Halt(6);
  WriteLn('PASS: ray/sphere hit, miss, unchanged input and aliased output');
end.
