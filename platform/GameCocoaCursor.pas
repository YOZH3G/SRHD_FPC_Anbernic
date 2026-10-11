unit GameCocoaCursor;

{$MODE DELPHI}
{$MODESWITCH OBJECTIVEC1}
{$LINKFRAMEWORK AppKit}

interface

procedure ReapplyCocoaCursor;

implementation

// pasfmt's Delphi parser does not recognize Objective Pascal class declarations.
{pasfmt off}
type
  TCocoaCursor = objcclass external name 'NSCursor'
    class function currentCursor: TCocoaCursor; message 'currentCursor';
    procedure set_; message 'set';
  end;

procedure ReapplyCocoaCursor;
begin
  // Use AppKit's application cursor, including SDL's invisible cursor, without
  // changing the cursor stack or the process-wide hide count.
  TCocoaCursor.currentCursor.set_;
end;

end.
