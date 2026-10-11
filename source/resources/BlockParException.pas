unit BlockParException;

{$I GameOptions.inc}

interface

uses
  SysUtils;

type

  EBlockPar = class;

  EBlockPar = class(Exception)
    Reportable: Boolean;
    constructor Create(Message: AnsiString; AReportable: Boolean);
    function IsReportable: Boolean;
  end;

implementation

constructor EBlockPar.Create(Message: AnsiString; AReportable: Boolean);
begin
  inherited Create(Message);
  Reportable := AReportable;
end;

function EBlockPar.IsReportable: Boolean;
begin
  Result := Reportable
end;

end.
