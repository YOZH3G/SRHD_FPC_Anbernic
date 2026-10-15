unit SE_Garbage;

{$I GameOptions.inc}

interface

procedure CheckMemoryUsage;

implementation

uses
  GameDiagnostics,
  GameSystem,
  GR_Main,
  aGalaxy;

var
  CheckingMemoryUsage: Boolean = False;
  LowMemoryWarningShown: Boolean = False;

procedure CheckMemoryUsage;
var
  Status: TMemoryStatusEx;

  procedure ShowLowMemoryWarning(TextKey: WideString); { Nested in CheckMemoryUsage; unused caller-popped static link. }
  begin
    if (not LowMemoryWarningShown) and (Galaxy <> nil) then
    begin
      LowMemoryWarningShown := True;
      LogGameMessage(gllWarning, 'memory', 'Low-memory warning: ' + TextKey);
      LogMemoryUsage;
      Galaxy.ShowLocalizedWarning(TextKey);
    end;
  end;
begin
  if not CheckingMemoryUsage then
  begin
    CheckingMemoryUsage := True;
    try
      Status.Length := SizeOf(Status);
      QueryGameMemory(Status);
      if Status.AvailVirtual shr 20 < 100 then
        ShowLowMemoryWarning('Warning.LowVirtualMemory');
      if Status.AvailPhys shr 20 < 100 then
        ShowLowMemoryWarning('Warning.LowPhysicalMemory');
    finally
      CheckingMemoryUsage := False;
    end;
  end;
end;

end.
