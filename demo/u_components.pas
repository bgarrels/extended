﻿unit U_Components;

{$IFDEF FPC}
{$mode Delphi}
{$R *.lfm}
{$ELSE}
{$R *.DFM}
{$ENDIF}

interface

uses
{$IFDEF FPC}
  FileUtil, LResources,
{$ELSE}
  DBCtrls, TntDBCtrls, ComCtrls, JvExControls, JvDBLookup, TntDBGrids,
  JvExComCtrls, JvListView, TntStdCtrls, Mask,
{$ENDIF}
  Classes, SysUtils, db, Forms, Controls, Graphics, Dialogs, ExtCtrls, Grids,
  StdCtrls, U_FormMainIni, U_OnFormInfoIni, U_ExtColorCombos,
  U_ExtNumEdits, u_framework_components, U_ExtDBNavigator, U_DBListView,
  u_framework_dbcomponents, u_extsearchedit, U_ExtComboInsert, ZConnection, dbf,
  DBGrids ;

const CST_EXTENSION_DBF  = '.dbf' ;
      CST_NOM_FICHIER  = 'fiches' ;
type

  { TMyform }

  TMyform = class(TF_FormMainIni)
    Datasource: TDatasource;
    Datasource2: TDatasource;
    ExtDBComboInsert2: TExtDBComboInsert;
    ExtSearchDBEdit2: TExtSearchDBEdit;
    Search: TFWLabel;
    Search2: TFWLabel;
    Villes: TDbf;
    DBListView: TDBListView;
    ExtColorCombo: TExtColorCombo;
    ExtDBNavigator1: TExtDBNavigator;
    ExtNumEdit1: TExtNumEdit;
    FWDateEdit1 : TFWDateEdit;
    Nom: TFWDBEdit;
    Prenom: TFWDBEdit;
    FWEdit: TFWEdit;
    FWLabel1: TFWLabel;
    FWLabel2: TFWLabel;
    FWLabel3: TFWLabel;
    FWLabel4: TFWLabel;
    FWLabel5: TFWLabel;
    FWLabel6: TFWLabel;
    FWMemo: TFWMemo;
    Noms: TFWDBGrid;
    OnFormInfoIni: TOnFormInfoIni;
    Panel1: TPanel;
    Panel2: TPanel;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    DbfNoms: TDbf;
    procedure FormShow(Sender: TObject);
    procedure QuitterClick(Sender: TObject);
    procedure DbfNomsAfterPost(DataSet: TDataSet);
  private
    { private declarations }
  public
    { public declarations }
    constructor Create ( AOwner : TComponent ); override;
  end; 

var
  Myform: TMyform;

implementation

procedure TMyform.DbfNomsAfterPost(DataSet: TDataSet);
begin
  DBListView.Refresh;
end;

procedure TMyForm.FormShow(Sender: TObject);
begin
  Noms.Columns [ 0 ].SomeEdit := Nom;
  Noms.Columns [ 1 ].SomeEdit := Prenom;
  // On cherche ou crée le fichier CSV
  DbfNoms.FilePathFull := ExtractFileDir ( Application.ExeName );
  Villes .FilePathFull := ExtractFileDir ( Application.ExeName );
  DbfNoms.TableName:=CST_NOM_FICHIER+CST_EXTENSION_DBF;
  if not FileExists(DbfNoms.FilePathFull+DbfNoms.TableName) then
    DbfNoms.CreateTable;
  try
    // Un Dataset s'ouvre pour lire et écrire les données
    DbfNoms.Open;
    DbfNoms.PackTable;
    DbfNoms.RegenerateIndexes;
    Villes.Open;
  Except
    // Il s'agit d'une entrée/sortie donc on gère les exceptions
    on e:Exception do
      Begin
       ShowMessage ( 'Impossible d''ouvrir le fichier DBF : ' + E.Message );
       Exit;
      end;
  end;
end;

procedure TMyform.QuitterClick(Sender: TObject);
begin
  Close;
end;

constructor TMyform.Create(AOwner: TComponent);
begin
  AutoIni := True;
  inherited Create(AOwner);
end;

end.

