unit U_RegisterExtDBNav;

// Proc�dure d'enregistrement du navigateur de donn�es
// Cr�� par Matthieu Giroux le 3/12/2006

interface

{$I ..\Compilers.inc}

procedure Register ;

implementation

uses
  U_ExtDBNavigator,
{$IFDEF FPC}
  lresources,
{$ELSE}
   DesignIntf, DBReg,
{$ENDIF}
   Classes ;


procedure Register;
begin
  RegisterComponents('Extended', [TExtDBNavigator]);
{$IFDEF DELPHI}
  RegisterPropertyEditor ( TypeInfo(string), TExtDBNavigator, 'SortField', TDataFieldProperty);
{$ENDIF}
end;

initialization
{$IFDEF FPC}
  {$i U_ExtDBNavigator.lrs}
{$ENDIF}
end.
