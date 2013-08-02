unit u_regframeworkcomponents;

{$IFDEF FPC}
{$mode Delphi}
{$ENDIF}


{$I ..\DLCompilers.inc}
{$I ..\extends.inc}

interface

uses
  Classes,
{$IFDEF FPC}
  lresources,
{$ENDIF}
  SysUtils;

procedure Register;

implementation

uses  {$IFDEF FPC}
  unite_messages, u_extDBDirectoryEdit,
  {$ELSE}
  unite_messages_delphi,
  {$ENDIF}
     U_ExtDBNavigator,
     u_framework_dbcomponents, u_framework_components,
     U_OnFormInfoIni,U_ExtNumEdits,U_ExtColorCombos,
     u_extsearchedit, U_ExtComboInsert,
{$IFDEF FPC}
     ComponentEditors, dbpropedits, PropEdits,
{$ELSE}
     DBReg, Designintf,
{$ENDIF}
     U_ExtDBImage, U_ExtDBImageList, U_ExtImage,
     U_ExtPictCombo, U_ExtDBPictCombo, U_ExtMapImageIndex,
     u_extdbgrid, PDBCheck, PCheck, u_scrollclones,
     u_extradios, u_extimagelist;

procedure Register;
begin
  RegisterComponents(CST_PALETTE_COMPOSANTS_INVISIBLE, [TOnFormInfoIni, TExtMapImages]);
  RegisterComponents(CST_PALETTE_COMPOSANTS_DB, [TPDBCheck,
                                                TExtDBColorCombo,TFWDBComboBox,
                                                TExtDBComboInsert,
                                                TFWDBDateEdit, TFWDBDateTimePicker,
                                                {$IFDEF FPC}TExtDBDirectoryEdit,{$ENDIF}
                                                TFWDBEdit, TExtDBGrid,
                                                TExtDBImage,TExtDBImageList,
                                                TFWDBLookupCombo,
                                                TFWDBMemo, TExtDBNavigator,
                                                TExtDBNumEdit,TExtDBPictCombo,
                                                TExtSearchDBEdit,TFWDBSpinEdit]);
  RegisterComponents(CST_PALETTE_COMPOSANTS   , [TPCheck,TExtClonedPanel,TExtColorCombo,
                                                TFWComboBox, TFWDateEdit,
                                                TFWDateTimePicker, TFWEdit,TFWGrid,
                                                TExtImage,TExtImageList,
                                                TFWLabel,TFWMemo,
                                                TExtNumEdit,TExtPictCombo,TExtRadioGroup,TFWSpinEdit]);
  RegisterPropertyEditor ( TypeInfo(string), TExtDBNavigator, 'SortField', {$IFDEF FPC}TFieldProperty{$ELSE}TDataFieldProperty{$ENDIF});
  RegisterPropertyEditor ( TypeInfo(string), TExtSearchDBEdit, 'FieldKey'   , {$IFDEF FPC}TFieldProperty{$ELSE}TDataFieldProperty{$ENDIF});
end;

{$IFDEF FPC}
initialization
  {$i u_framework_components.lrs}
  {$i u_framework_dbcomponents.lrs}
  {$I U_RegImageComponents.lrs}
  {$i U_ExtDBNavigator.lrs}
  {$i U_DBListView.lrs}
  {$i U_OnFormInfoIni.lrs}
  {$i u_extsearchedit.lrs}
  {$i U_ExtComboInsert.lrs}
  {$i U_ExtColorCombos.lrs}
  {$i u_extdbdirectoryedit.lrs}
  {$i U_ExtNumEdits.lrs}
  {$i u_extdbgrid.lrs}
  {$i U_ExtPictCombo.lrs}
  {$i U_ExtDBImageList.lrs}
  {$i U_ExtImageList.lrs}
  {$i u_extmapimageindex.lrs}
  {$i u_extimage.lrs}
  {$i u_scrollclones.lrs}
  {$i PDBCheck.lrs}
  {$i PCheck.lrs}
  {$I u_extmenucustomize.lrs}
{$ENDIF}
end.
