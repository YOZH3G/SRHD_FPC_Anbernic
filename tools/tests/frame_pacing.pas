program FramePacing;
{$MODE DELPHI}
uses SysUtils, GameFramePacing;
var
  Pacer: TGameFramePacer;
  Tick, Count, Rate: Integer;

procedure Require(Value: Boolean; const Message: string);
begin
  if not Value then raise Exception.Create(Message);
end;

begin
  for Rate in [50, 60, 120] do
  begin
    Pacer.Reset;
    Count := 0;
    // A deliberately coarse counter exposes loss of fractional intervals.
    // The old millisecond gate cannot submit 60 or 120 frames in this window.
    for Tick := 0 to 999 do
      if Pacer.Ready(Tick, 1000, Rate) then Inc(Count);
    Require(Count = Rate, 'Fractional refresh rate drift');
  end;
  Pacer.Reset;
  Require(Pacer.Ready(0, 1000, 50), 'First frame must be immediate');
  Require(not Pacer.Ready(19, 1000, 50), 'Early frame');
  Require(Pacer.Ready(20, 1000, 50), 'Exact deadline was rejected');
  Require(Pacer.Ready(43, 1000, 50), 'Late frame was rejected');
  Require(Pacer.Ready(60, 1000, 50), 'Scheduling jitter shifted the refresh phase');
  Require(Pacer.Ready(5000, 1000, 50), 'Resume after a stall');
  Require(not Pacer.Ready(5001, 1000, 50), 'Catch-up burst after a stall');
  Require(Pacer.Ready(5020, 1000, 50), 'Stall recovery deadline');
  Require(Pacer.Ready(5021, 1000, 100), 'New refresh rate retained the old deadline');
  Require(not Pacer.Ready(5030, 1000, 100), 'New refresh rate allows early frames');
  Require(Pacer.Ready(5031, 1000, 100), 'New refresh rate deadline');
  Require(Pacer.Ready(5032, 1000000, 100), 'New counter frequency retained old units');
  Require(not Pacer.Ready(5033, 1000000, 100), 'Counter frequency conversion');
  Require(Pacer.Ready(5034, 1000000, 0), 'Disabled limiter');
  Require(Pacer.Ready(5034, 1000000, 0), 'Disabled limiter still imposes a deadline');
  Require(Pacer.Ready(5034, 0, 50), 'Unavailable counter frequency');
  Pacer.Reset;
  Require(Pacer.Ready(0, 1000, 50), 'Reset retained a future deadline');
  // Remaining must agree with Ready so callers can sleep until the deadline.
  Pacer.Reset;
  Require(Pacer.Remaining(0, 1000, 50) = 0, 'Uninitialized pacer reported a wait');
  Require(Pacer.Ready(0, 1000, 50), 'First frame after reset');
  Require(Pacer.Remaining(5, 1000, 50) = 15, 'Remaining interval');
  Require(Pacer.Remaining(19, 1000, 50) = 1, 'Remaining before deadline');
  Require(Pacer.Remaining(20, 1000, 50) = 0, 'Remaining at deadline');
  Require(Pacer.Remaining(25, 1000, 50) = 0, 'Remaining after deadline');
  Require(Pacer.Remaining(5, 1000, 100) = 0, 'Rate change must not wait for the old deadline');
  Require(Pacer.Remaining(5, 2000, 50) = 0, 'Frequency change must not wait in old units');
  Require(Pacer.Remaining(5, 1000, 0) = 0, 'Disabled limiter reported a wait');
  Require(not Pacer.Ready(19, 1000, 50), 'Remaining changed the deadline');
  Require(Pacer.Ready(20, 1000, 50), 'Deadline after Remaining queries');
  WriteLn('PASS: 50/60/120 Hz, exact deadlines, jitter, stalls, rate changes, reset and remaining time');
end.
