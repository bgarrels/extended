﻿unit u_regextfilecopy;
{
Composant TExtFileCopy

DÃ©veloppÃ© par:
Matthieu GIROUX

Composant non visuel permettant de copier un fichier plus rapidement
que par le fonction copy de windows.
Compatible Linux
Attention: La gestion de la RAM Ã©tant calamiteuse sous Win9x, l'
utilisation de ce composant provoque une grosse une forte baisse de la
mÃ©moire disponible. Sous WinNT/2000 il n' y a pas de problèmes


Version actuelle: 1.0

Mises à jour:
}

interface
{$IFDEF FPC}
{$mode Delphi}
{$ENDIF}

uses
  SysUtils,
  Classes ;

{$I ..\DLCompilers.inc}
{$I ..\extends.inc}

procedure Register;

implementation

uses U_ExtFileCopy,
{$IFDEF FPC}
     ComponentEditors, dbpropedits, PropEdits, lresources,
{$ELSE}
     DBReg, Designintf,
{$ENDIF}
     u_traducefile,
     u_extractfile;

{TExtFileCopy}


procedure Register;
begin
  RegisterComponents('Extended', [TExtFileCopy, TTraduceFile, TExtractFile]);
  RegisterPropertyEditor ( TypeInfo({$IFDEF FPC}ShortString {$ELSE}string{$ENDIF}), TExtractFile, 'FieldName'   , {$IFDEF FPC}TFieldProperty{$ELSE}TDataFieldProperty{$ENDIF});

end;


initialization
{$IFDEF FPC}
{$i U_ExtFileCopy.lrs}
{$i u_traducefile.lrs}
{$i u_extractfile.lrs}
{$ENDIF}

end.

