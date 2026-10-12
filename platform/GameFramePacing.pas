unit GameFramePacing;
{$MODE DELPHI}

interface

type
  TGameFramePacer = record
  private
    NextCounter, Frequency, Fraction: QWord;
    FrameRate: Cardinal;
    Initialized: Boolean;
  public
    procedure Reset;
    function Ready(Counter, CounterFrequency: QWord; TargetFrameRate: Cardinal): Boolean;
  end;

implementation

procedure TGameFramePacer.Reset;
begin
  Initialized := False;
end;

function TGameFramePacer.Ready(
    Counter, CounterFrequency: QWord; TargetFrameRate: Cardinal
): Boolean;
var
  Interval: QWord;
begin
  if (CounterFrequency = 0) or (TargetFrameRate = 0) then
  begin
    Reset;
    Exit(True);
  end;
  if not Initialized or (Frequency <> CounterFrequency) or (FrameRate <> TargetFrameRate) then
  begin
    Frequency := CounterFrequency;
    FrameRate := TargetFrameRate;
    NextCounter := Counter;
    Fraction := 0;
    Initialized := True;
  end;
  if Counter < NextCounter then
    Exit(False);
  Interval := Frequency div FrameRate;
  if Interval = 0 then
    Interval := 1;
  // Preserve the refresh phase under ordinary scheduling jitter. After a
  // missed whole interval, resume from now instead of presenting a burst.
  if Counter - NextCounter >= Interval then
  begin
    NextCounter := Counter;
    Fraction := 0;
  end;
  Inc(NextCounter, Interval);
  Inc(Fraction, Frequency mod FrameRate);
  if Fraction >= FrameRate then
  begin
    Inc(NextCounter);
    Dec(Fraction, FrameRate);
  end;
  Result := True;
end;

end.
