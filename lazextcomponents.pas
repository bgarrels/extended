{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit lazextcomponents;

interface

uses
  PDBCheck, PCheck, U_ExtColorCombos, U_DBListView, U_ExtNumEdits, 
  U_ExtDBNavigator, U_GroupView, u_extradios, u_scrollclones, 
  u_extDBDirectoryEdit, u_extautoedits, U_ExtComboInsert, 
  u_framework_components, u_framework_dbcomponents, u_extsearchedit, 
  LazarusPackageIntf;

implementation

procedure Register;
begin
end;

initialization
  RegisterPackage('lazextcomponents', @Register);
end.
