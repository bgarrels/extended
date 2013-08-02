﻿unit u_framework_dbcomponents;

{*********************************************************************}
{                                                                     }
{                                                                     }
{             TFWDBEdit, TFWDBDateEdit, TFWDBLookupCombo,             }
{             TFWDBDateTimePicker, TFWDBMemo :                        }
{             Composants avec couleurs de focus, d'édition            }
{             Créateur : Matthieu Giroux                              }
{             31 Mars 2011                                            }
{                                                                     }
{                                                                     }
{*********************************************************************}


{$I ..\DLCompilers.inc}
{$I ..\extends.inc}
{$IFDEF FPC}
{$mode Delphi}
{$ENDIF}

////////////////////////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
{$IFDEF FPC}
   LCLIntf, LCLType,
   SQLDB, lmessages,
   dbdateedit,
{$ELSE}
   Windows, Mask, DBTables, ActnMan,
{$ENDIF}
{$IFDEF RXCOMBO}
  RxLookup,
{$ENDIF}
{$IFDEF JEDI}
  JvDBLookup,jvDBUltimGrid, jvDBControls, JvDBDateTimePicker,
{$ENDIF}
{$IFDEF VERSIONS}
  fonctions_version,
{$ENDIF}
  Graphics, Controls, Classes, ExtCtrls, Dialogs,
  Buttons, Forms, DBCtrls,
  SysUtils,
  TypInfo, Variants, u_extcomponent,
{$IFDEF TNT}
   TntStdCtrls, TntDBCtrls,
{$ENDIF}
  fonctions_erreurs, DB, Messages,
  u_framework_components;

{$IFDEF VERSIONS}
const
    gVer_framework_DBcomponents : T_Version = ( Component : 'Data interactivity components' ;
                                               FileUnit : 'u_framework_dbcomponents' ;
                                               Owner : 'Matthieu Giroux' ;
                                               Comment : 'U_CustomFrameWork Data interactivity.' ;
                                               BugsStory : '0.9.0.5 : UTF 8.'
                                                         + '0.9.0.4 : Added FWDBCombobox.'
                                                         + '0.9.0.3 : Using RXLookupCombo on FPC.'
                                                         + '0.9.0.2 : Paint Edits or not on FWDBGrid.'
                                                         + '0.9.0.1 : FWDBGrid tested on Delphi, with Controls on Columns.'
                                                         + '0.9.0.0 : Création à partir de u_framework_components.';
                                               UnitType : 3 ;
                                               Major : 0 ; Minor : 9 ; Release : 0 ; Build : 5 );

{$ENDIF}
type

{ TFWDBEdit }

   TFWDBEdit = class ( {$IFDEF TNT}TTntDBEdit{$ELSE}TDBEdit{$ENDIF}, IFWComponent, IFWComponentEdit )
      private
       FBeforeEnter, FBeforeExit : TNotifyEvent;
       FLabel : TFWLabel ;
       FOldColor ,
       FColorFocus ,
       FColorReadOnly,
       FColorEdit ,
       FColorLabel : TColor;
       FBeforePopup : TPopUpMenuEvent;
       FOnPopup : TNotifyEvent;
       FAlwaysSame : Boolean;
       FNotifyOrder : TNotifyEvent;
       procedure p_setLabel ( const alab_Label : TFWLabel );
       procedure WMPaint(var Message: {$IFDEF FPC}TLMPaint{$ELSE}TWMPaint{$ENDIF}); message {$IFDEF FPC}LM_PAINT{$ELSE}WM_PAINT{$ENDIF};
      protected
       procedure MouseDown( Button : TMouseButton; Shift : TShiftState; X,Y : Integer); override;
       procedure Notification(AComponent: TComponent; Operation: TOperation); override;
      public

       constructor Create ( AOwner : TComponent ); override;
       procedure DoEnter; override;
       procedure DoExit; override;
       procedure Loaded; override;
       procedure SetOrder ; virtual;
      published
       property FWBeforeEnter : TnotifyEvent read FBeforeEnter write FBeforeEnter stored False;
       property FWBeforeExit  : TnotifyEvent read FBeforeExit  write FBeforeExit stored False ;
       property ColorLabel : TColor read FColorLabel write FColorLabel default CST_LBL_SELECT ;
       property ColorFocus : TColor read FColorFocus write FColorFocus default CST_EDIT_SELECT ;
       property ColorEdit : TColor read FColorEdit write FColorEdit default CST_EDIT_STD ;
       property ColorReadOnly : TColor read FColorReadOnly write FColorReadOnly default CST_EDIT_READ ;
       property Color stored False ;
       property MyLabel : TFWLabel read FLabel write p_setLabel;
       property AlwaysSame : Boolean read FAlwaysSame write FAlwaysSame default true;
       property OnOrder : TNotifyEvent read FNotifyOrder write FNotifyOrder;
       property BeforePopup : TPopUpMenuEvent read FBeforePopup write FBeforePopup;
       property OnPopup : TNotifyEvent read FOnPopup write FOnPopup;
       property OnMouseEnter;
       property OnMouseLeave;
       property PopupMenu;
     End;

   { TFWDBDateEdit }

   TFWDBDateEdit = class ( {$IFDEF FPC}TDBDateEdit{$ELSE}TJvDBDateEdit{$ENDIF}, IFWComponent, IFWComponentEdit )
      private
       FBeforeEnter, FBeforeExit : TNotifyEvent;
       FLabel : TFWLabel ;
       FOldColor ,
       FColorFocus ,
       FColorReadOnly,
       FColorEdit ,
       FColorLabel : TColor;
       FAlwaysSame : Boolean;
       FNotifyOrder : TNotifyEvent;
       FBeforePopup : TPopUpMenuEvent;
       FOnPopup : TNotifyEvent;
       procedure p_setLabel ( const alab_Label : TFWLabel );
       procedure WMPaint(var Message: {$IFDEF FPC}TLMPaint{$ELSE}TWMPaint{$ENDIF}); message {$IFDEF FPC}LM_PAINT{$ELSE}WM_PAINT{$ENDIF};
      protected
       procedure MouseDown( Button : TMouseButton; Shift : TShiftState; X,Y : Integer); override;
       procedure Notification(AComponent: TComponent; Operation: TOperation); override;
      public

       constructor Create ( AOwner : TComponent ); override;
       procedure DoEnter; override;
       procedure DoExit; override;
       procedure Loaded; override;
       procedure SetOrder ; virtual;
      published
       property FWBeforeEnter : TnotifyEvent read FBeforeEnter write FBeforeEnter stored False;
       property FWBeforeExit  : TnotifyEvent read FBeforeExit  write FBeforeExit stored False ;
       property ColorLabel : TColor read FColorLabel write FColorLabel default CST_LBL_SELECT ;
       property ColorFocus : TColor read FColorFocus write FColorFocus default CST_EDIT_SELECT ;
       property ColorEdit : TColor read FColorEdit write FColorEdit default CST_EDIT_STD ;
       property ColorReadOnly : TColor read FColorReadOnly write FColorReadOnly default CST_EDIT_READ ;
       property Color stored False ;
       property MyLabel : TFWLabel read FLabel write p_setLabel;
       property AlwaysSame : Boolean read FAlwaysSame write FAlwaysSame default true;
       property OnOrder : TNotifyEvent read FNotifyOrder write FNotifyOrder;
       property BeforePopup : TPopUpMenuEvent read FBeforePopup write FBeforePopup;
       property OnPopup : TNotifyEvent read FOnPopup write FOnPopup;
       property OnMouseEnter;
       property OnMouseLeave;
       property PopupMenu;
     End;



   { TFWDBDateTimePicker }

   TFWDBDateTimePicker = class ( {$IFDEF FPC}TFWDateTimePicker{$ELSE}TJvDBDateTimePicker{$ENDIF}, IFWComponent, IFWComponentEdit )
      private
        FReadOnly : Boolean;
        FBeforePopup : TPopUpMenuEvent;
        FOnPopup : TNotifyEvent;
       {$IFDEF FPC}
         FDataLink: TFieldDataLink;
         function GetDataField: string;
         function GetDataSource: TDataSource;
         function GetField: TField;
         procedure SetDataField(const AValue: string);
         procedure SetDataSource(AValue: TDataSource);
         procedure WMCut(var Message: TMessage); message {$IFDEF FPC} LM_CUT {$ELSE} WM_CUT {$ENDIF};
         procedure WMPaste(var Message: TMessage); message {$IFDEF FPC} LM_PASTE {$ELSE} WM_PASTE {$ENDIF};
       {$IFDEF FPC}
       {$ELSE}
         procedure WMUndo(var Message: TMessage); message WM_UNDO;
       {$ENDIF}
         procedure CMExit(var Message: {$IFDEF FPC} TLMExit {$ELSE} TCMExit {$ENDIF}); message CM_EXIT;
         procedure CMGetDataLink(var Message: TMessage); message CM_GETDATALINK;
      protected
         procedure MouseDown( Button : TMouseButton; Shift : TShiftState; X,Y : Integer); override;
         procedure UpdateDate; override;
         procedure ActiveChange(Sender: TObject); virtual;
         procedure DataChange(Sender: TObject); virtual;
         procedure UpdateData(Sender: TObject); virtual;
         function GetReadOnly: Boolean; virtual;
         procedure SetReadOnly(AValue: Boolean); virtual;
         procedure KeyDown(var Key: Word; Shift: TShiftState); override;
         procedure KeyPress(var Key: Char); override;
         procedure Notification(AComponent: TComponent; Operation: TOperation); override;
       public
         procedure Loaded; override;
         constructor Create(AOwner: TComponent); override;
         destructor Destroy; override;
         function ExecuteAction(AAction: TBasicAction): Boolean; override;
         function UpdateAction(AAction: TBasicAction): Boolean; override;
         property Field: TField read GetField;
       published
         property Date stored False ;
         property Time stored False ;
         property DataField: string read GetDataField write SetDataField stored True;
         property DataSource: TDataSource read GetDataSource write SetDataSource stored True;
         property ReadOnly: Boolean read GetReadOnly write SetReadOnly default false;
       {$ELSE}
       FBeforeEnter, FBeforeExit : TNotifyEvent;
       FLabel : TFWLabel ;
       FOldColor ,
       FColorFocus ,
       FColorReadOnly,
       FColorEdit ,
       FColorLabel : TColor;
       FAlwaysSame : Boolean;
       FNotifyOrder : TNotifyEvent;
       procedure p_setLabel ( const alab_Label : TFWLabel );
       procedure WMPaint(var Message: {$IFDEF FPC}TLMPaint{$ELSE}TWMPaint{$ENDIF}); message {$IFDEF FPC}LM_PAINT{$ELSE}WM_PAINT{$ENDIF};
       procedure WMRButtonDown(var Msg: TWMRButtonDown); message WM_RBUTTONDOWN;
      protected
       procedure Notification(AComponent: TComponent; Operation: TOperation); override;
      public

       constructor Create ( AOwner : TComponent ); override;
       procedure DoEnter; override;
       procedure DoExit; override;
       procedure Loaded; override;
       procedure SetOrder ; virtual;
      published
       property FWBeforeEnter : TnotifyEvent read FBeforeEnter write FBeforeEnter stored False;
       property FWBeforeExit  : TnotifyEvent read FBeforeExit  write FBeforeExit stored False ;
       property ColorLabel : TColor read FColorLabel write FColorLabel default CST_LBL_SELECT ;
       property ColorFocus : TColor read FColorFocus write FColorFocus default CST_EDIT_SELECT ;
       property ColorEdit : TColor read FColorEdit write FColorEdit default CST_EDIT_STD ;
       property ColorReadOnly : TColor read FColorReadOnly write FColorReadOnly default CST_EDIT_READ ;
       property Color stored False ;
       property MyLabel : TFWLabel read FLabel write p_setLabel;
       property AlwaysSame : Boolean read FAlwaysSame write FAlwaysSame default true;
       property OnOrder : TNotifyEvent read FNotifyOrder write FNotifyOrder;
       {$ENDIF}
       property BeforePopup : TPopUpMenuEvent read FBeforePopup write FBeforePopup;
       property OnPopup : TNotifyEvent read FOnPopup write FOnPopup;
       property PopupMenu;
     End;



   { TFWDBLookupCombo }
   TFWDBLookupCombo = class ( {$IFDEF JEDI}TJvDBLookupCombo{$ELSE}{$IFDEF RXCOMBO}TRxDBLookupCombo{$ELSE}TDBLookupComboBox{$ENDIF}{$ENDIF}, IFWComponent, IFWComponentEdit )
      private
       FBeforeEnter, FBeforeExit : TNotifyEvent;
       FLabel : TFWLabel ;
       FOldColor ,
       FColorReadOnly,
       FColorFocus ,
       FColorEdit ,
       FColorLabel : TColor;
       FAlwaysSame : Boolean;
       FNotifyOrder : TNotifyEvent;
       FBeforePopup : TPopUpMenuEvent;
       FOnPopup : TNotifyEvent;
       procedure p_setLabel ( const alab_Label : TFWLabel );
       procedure WMPaint(var Message: {$IFDEF FPC}TLMPaint{$ELSE}TWMPaint{$ENDIF}); message {$IFDEF FPC}LM_PAINT{$ELSE}WM_PAINT{$ENDIF};
      protected
       procedure MouseDown( Button : TMouseButton; Shift : TShiftState; X,Y : Integer); override;
       procedure Notification(AComponent: TComponent; Operation: TOperation); override;
      public

       constructor Create ( AOwner : TComponent ); override;
       procedure DoEnter; override;
       procedure DoExit; override;
       procedure Loaded; override;
       procedure SetOrder ; virtual;
      published
       property FWBeforeEnter : TnotifyEvent read FBeforeEnter write FBeforeEnter stored False;
       property FWBeforeExit  : TnotifyEvent read FBeforeExit  write FBeforeExit stored False ;
       property ColorLabel : TColor read FColorLabel write FColorLabel default CST_LBL_SELECT ;
       property ColorFocus : TColor read FColorFocus write FColorFocus default CST_EDIT_SELECT ;
       property ColorEdit : TColor read FColorEdit write FColorEdit default CST_EDIT_STD ;
       property ColorReadOnly : TColor read FColorReadOnly write FColorReadOnly default CST_EDIT_READ ;
       property Color stored False ;
       property MyLabel : TFWLabel read FLabel write p_setLabel;
       property AlwaysSame : Boolean read FAlwaysSame write FAlwaysSame default true;
       property OnOrder : TNotifyEvent read FNotifyOrder write FNotifyOrder;
       property BeforePopup : TPopUpMenuEvent read FBeforePopup write FBeforePopup;
       property OnPopup : TNotifyEvent read FOnPopup write FOnPopup;
       property OnMouseEnter;
       property OnMouseLeave;
       property PopupMenu;
     End;

   { TFWDBComboBox }
   TFWDBComboBox = class ( TDBComboBox, IFWComponent, IFWComponentEdit )
      private
       FBeforeEnter, FBeforeExit : TNotifyEvent;
       FLabel : TFWLabel ;
       FOldColor ,
       FColorReadOnly,
       FColorFocus ,
       FColorEdit ,
       FColorLabel : TColor;
       FAlwaysSame : Boolean;
       FNotifyOrder : TNotifyEvent;
       FBeforePopup : TPopUpMenuEvent;
       FOnPopup : TNotifyEvent;
       procedure p_setLabel ( const alab_Label : TFWLabel );
       procedure WMPaint(var Message: {$IFDEF FPC}TLMPaint{$ELSE}TWMPaint{$ENDIF}); message {$IFDEF FPC}LM_PAINT{$ELSE}WM_PAINT{$ENDIF};
      protected
       procedure MouseDown( Button : TMouseButton; Shift : TShiftState; X,Y : Integer); override;
       procedure Notification(AComponent: TComponent; Operation: TOperation); override;
      public

       constructor Create ( AOwner : TComponent ); override;
       procedure DoEnter; override;
       procedure DoExit; override;
       procedure Loaded; override;
       procedure SetOrder ; virtual;
      published
       property FWBeforeEnter : TnotifyEvent read FBeforeEnter write FBeforeEnter stored False;
       property FWBeforeExit  : TnotifyEvent read FBeforeExit  write FBeforeExit stored False ;
       property ColorLabel : TColor read FColorLabel write FColorLabel default CST_LBL_SELECT ;
       property ColorFocus : TColor read FColorFocus write FColorFocus default CST_EDIT_SELECT ;
       property ColorEdit : TColor read FColorEdit write FColorEdit default CST_EDIT_STD ;
       property ColorReadOnly : TColor read FColorReadOnly write FColorReadOnly default CST_EDIT_READ ;
       property Color stored False ;
       property MyLabel : TFWLabel read FLabel write p_setLabel;
       property AlwaysSame : Boolean read FAlwaysSame write FAlwaysSame default true;
       property OnOrder : TNotifyEvent read FNotifyOrder write FNotifyOrder;
       property BeforePopup : TPopUpMenuEvent read FBeforePopup write FBeforePopup;
       property OnPopup : TNotifyEvent read FOnPopup write FOnPopup;
       property OnMouseEnter;
       property OnMouseLeave;
       property PopupMenu;
     End;

   { TFWDBMemo }

   TFWDBMemo = class ( TDBMemo, IFWComponent, IFWComponentEdit )
      private
       FBeforeEnter, FBeforeExit : TNotifyEvent;
       FLabel : TFWLabel ;
       FOldColor ,
       FColorFocus ,
       FColorReadOnly,
       FColorEdit ,
       FColorLabel : TColor;
       FAlwaysSame : Boolean;
       FNotifyOrder : TNotifyEvent;
       FBeforePopup : TPopUpMenuEvent;
       FOnPopup : TNotifyEvent;
       procedure p_setLabel ( const alab_Label : TFWLabel );
       procedure WMPaint(var Message: {$IFDEF FPC}TLMPaint{$ELSE}TWMPaint{$ENDIF}); message {$IFDEF FPC}LM_PAINT{$ELSE}WM_PAINT{$ENDIF};
      protected
       procedure MouseDown( Button : TMouseButton; Shift : TShiftState; X,Y : Integer); override;
       procedure Notification(AComponent: TComponent; Operation: TOperation); override;
      public

       constructor Create ( AOwner : TComponent ); override;
       procedure DoEnter; override;
       procedure DoExit; override;
       procedure Loaded; override;
       procedure SetOrder ; virtual;
      published
       property FWBeforeEnter : TnotifyEvent read FBeforeEnter write FBeforeEnter stored False;
       property FWBeforeExit  : TnotifyEvent read FBeforeExit  write FBeforeExit stored False ;
       property ColorLabel : TColor read FColorLabel write FColorLabel default CST_LBL_SELECT ;
       property ColorFocus : TColor read FColorFocus write FColorFocus default CST_EDIT_SELECT ;
       property ColorEdit : TColor read FColorEdit write FColorEdit default CST_EDIT_STD ;
       property ColorReadOnly : TColor read FColorReadOnly write FColorReadOnly default CST_EDIT_READ ;
       property Color stored False ;
       property MyLabel : TFWLabel read FLabel write p_setLabel;
       property AlwaysSame : Boolean read FAlwaysSame write FAlwaysSame default true;
       property OnOrder : TNotifyEvent read FNotifyOrder write FNotifyOrder;
       property BeforePopup : TPopUpMenuEvent read FBeforePopup write FBeforePopup;
       property OnPopup : TNotifyEvent read FOnPopup write FOnPopup;
       property OnMouseEnter;
       property OnMouseLeave;
       property PopupMenu;
     End;


     { TFWDBSpinEdit }

     TFWDBSpinEdit  = class( TFWSpinEdit )
       private
         FDataLink: TFieldDataLink;
         {$IFNDEF FPC}
         FReadOnly : Boolean;
         {$ENDIF}
         function GetDataField: string;
         function GetDataSource: TDataSource;
         function GetField: TField;
         procedure SetDataField(const AValue: string);
         procedure SetDataSource(AValue: TDataSource);
         procedure WMCut(var Message: TMessage); message {$IFDEF FPC} LM_CUT {$ELSE} WM_CUT {$ENDIF};
         procedure WMPaste(var Message: TMessage); message {$IFDEF FPC} LM_PASTE {$ELSE} WM_PASTE {$ENDIF};
       {$IFDEF FPC}
       {$ELSE}
         procedure WMUndo(var Message: TMessage); message WM_UNDO;
       {$ENDIF}
         procedure CMExit(var Message: {$IFDEF FPC} TLMExit {$ELSE} TCMExit {$ENDIF}); message CM_EXIT;
         procedure CMGetDataLink(var Message: TMessage); message CM_GETDATALINK;
       protected
         procedure ActiveChange(Sender: TObject); virtual;
         procedure DataChange(Sender: TObject); virtual;
         procedure UpdateData(Sender: TObject); virtual;
         function GetReadOnly: Boolean; {$IFDEF FPC}override{$ELSE}virtual{$ENDIF};
         {$IFNDEF FPC}
         procedure SetReadOnly(AValue: Boolean); virtual;
         {$ENDIF}
         procedure SetValue({$IFDEF FPC}const {$ENDIF}AValue: {$IFDEF FPC}Double{$ELSE}Extended{$ENDIF}); {$IFNDEF FPC}override ;{$ENDIF}
         procedure KeyDown(var Key: Word; Shift: TShiftState); override;
         procedure KeyPress(var Key: Char); override;
         procedure Notification(AComponent: TComponent; Operation: TOperation); override;
       public
         procedure Loaded; override;
         procedure Change; override;
         constructor Create(AOwner: TComponent); override;
         destructor Destroy; override;
         function ExecuteAction(AAction: TBasicAction): Boolean; override;
         function UpdateAction(AAction: TBasicAction): Boolean; override;
         property Field: TField read GetField;
       published
         property Value stored False ;
         property DataField: string read GetDataField write SetDataField stored True;
         property DataSource: TDataSource read GetDataSource write SetDataSource stored True;
         {$IFNDEF FPC}
         property ReadOnly: Boolean read GetReadOnly write SetReadOnly default false;
         {$ENDIF}
       end;

implementation



{ TFWDBEdit }

procedure TFWDBEdit.p_setLabel(const alab_Label: TFWLabel);
begin
  if alab_Label <> FLabel Then
    Begin
      FLabel := alab_Label;
      FLabel.MyEdit := Self;
    End;
end;

procedure TFWDBEdit.SetOrder;
begin
  if assigned ( FNotifyOrder ) then
    FNotifyOrder ( Self );
end;

constructor TFWDBEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FAlwaysSame := True;
  FColorLabel := CST_LBL_SELECT;
  FColorEdit  := CST_EDIT_STD;
  FColorFocus := CST_EDIT_SELECT;
  FColorReadOnly := CST_EDIT_READ;
  FBeforePopup:=nil;
  FOnPopup:=nil;
end;

procedure TFWDBEdit.DoEnter;
begin
  if assigned ( FBeforeEnter ) Then
    FBeforeEnter ( Self );
  // Si on arrive sur une zone de saisie, on met en valeur son tlabel par une couleur
  // de fond bleu et son libellé en marron (sauf si le libellé est sélectionné
  // avec la souris => cas de tri)
  p_setLabelColorEnter ( FLabel, FColorLabel, FAlwaysSame );
  p_setCompColorEnter  ( Self, FColorFocus, FAlwaysSame );
  inherited DoEnter;
end;

procedure TFWDBEdit.DoExit;
begin
  if assigned ( FBeforeExit ) Then
    FBeforeExit ( Self );
  inherited DoExit;
  p_setLabelColorExit ( FLabel, FAlwaysSame );
  p_setCompColorExit ( Self, FOldColor, FAlwaysSame );

end;

procedure TFWDBEdit.Loaded;
begin
  inherited Loaded;
  FOldColor := Color;
  if  FAlwaysSame
   Then
    Color := gCol_Edit ;
end;

procedure TFWDBEdit.WMPaint(var Message: {$IFDEF FPC}TLMPaint{$ELSE}TWMPaint{$ENDIF});
Begin
  p_setCompColorReadOnly ( Self,FColorEdit,FColorReadOnly, FAlwaysSame, ReadOnly );
  inherited;
End;

procedure TFWDBEdit.MouseDown(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);
  if Button = mbRight Then
   fb_ShowPopup (Self,PopUpMenu,FBeforePopup,FOnPopup);
end;

procedure TFWDBEdit.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if  ( Operation  = opRemove )
  and ( AComponent = FLabel   )
   Then FLabel := nil;
end;

{$IFDEF FPC}
{ TFWDBDateTimePicker }

constructor TFWDBDateTimePicker.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDataLink := TFieldDataLink.Create ;
  FDataLink.DataSource := nil ;
  FDataLink.FieldName  := '' ;
  FDataLink.Control := Self;
  FDataLink.OnDataChange := DataChange;
  FDataLink.OnUpdateData := UpdateData;
  FDataLink.OnActiveChange := ActiveChange;
  ControlStyle := ControlStyle + [csReplicatable];
end;

destructor TFWDBDateTimePicker.Destroy;
begin
  inherited Destroy;
  FDataLink.Free ;
end;

procedure TFWDBDateTimePicker.Loaded;
begin
  inherited Loaded;
  if (csDesigning in ComponentState) then
    Begin
      DataChange(Self);
    End ;
end;

procedure TFWDBDateTimePicker.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation <> opRemove) Then Exit;
  if (FDataLink <> nil) and
    (AComponent = DataSource) then DataSource := nil;
end;

procedure TFWDBDateTimePicker.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);
  if (Key = VK_DELETE) or ((Key = VK_INSERT) and (ssShift in Shift)) then
    FDataLink.Edit;
end;

procedure TFWDBDateTimePicker.KeyPress(var Key: Char);
begin
  inherited KeyPress(Key);
  if (Key in [#32..#255]) and (FDataLink.Field <> nil) and
    not FDataLink.Field.IsValidChar(Key) then
  begin
    {$IFDEF DELPHI}
    MessageBeep(0);
    {$ENDIF}
    Key := #0;
  end;
  case Key of
    ^H, ^V, ^X, #32..#255:
      FDataLink.Edit;
    #27:
      begin
        FDataLink.Reset;
        Key := #0;
      end;
  end;
end;

function TFWDBDateTimePicker.GetDataSource: TDataSource;
begin
  Result := FDataLink.DataSource;
end;

procedure TFWDBDateTimePicker.SetDataSource(AValue: TDataSource);
begin
  if not (FDataLink.DataSourceFixed and (csLoading in ComponentState)) then
    FDataLink.DataSource := AValue;
  if AValue <> nil then AValue.FreeNotification(Self);
end;

function TFWDBDateTimePicker.GetDataField: string;
begin
  Result := FDataLink.FieldName;
end;

procedure TFWDBDateTimePicker.SetDataField(const AValue: string);
begin
  if  assigned ( FDataLink.DataSet )
  and FDataLink.DataSet.Active Then
    Begin
      if assigned ( FDataLink.DataSet.FindField ( AValue ))
      and ( FDataLink.DataSet.FindField ( AValue ) is TNumericField ) Then
        FDataLink.FieldName := AValue;
    End
  Else
    FDataLink.FieldName := AValue;
end;

function TFWDBDateTimePicker.GetReadOnly: Boolean;
begin
  Result := FDataLink.ReadOnly or FReadOnly;
end;

procedure TFWDBDateTimePicker.SetReadOnly(AValue: Boolean);
begin
  FReadOnly := AValue;
end;

function TFWDBDateTimePicker.GetField: TField;
begin
  Result := FDataLink.Field;
end;

procedure TFWDBDateTimePicker.ActiveChange(Sender: TObject);
begin
  if FDataLink.Field <> nil then
    begin
      DateTime := FDataLink.Field.AsDateTime;
    end;
end;

procedure TFWDBDateTimePicker.DataChange(Sender: TObject);
begin
  if FDataLink.Field <> nil then
    begin
      DateTime := FDataLink.Field.AsDateTime;
    end;
end;


procedure TFWDBDateTimePicker.UpdateData(Sender: TObject);
begin
  if DateTime > -1 Then
    Begin
      FDataLink.Edit ;
      FDataLink.Field.Value := DateTime ;
    End ;
end;

procedure TFWDBDateTimePicker.WMPaste(var Message: TMessage);
begin
  FDataLink.Edit;
  inherited;
end;

procedure TFWDBDateTimePicker.WMCut(var Message: TMessage);
begin
  FDataLink.Edit;
  inherited;
end;

procedure TFWDBDateTimePicker.CMExit(var Message: {$IFDEF FPC} TLMExit {$ELSE} TCMExit {$ENDIF});
begin
  try
    FDataLink.UpdateRecord;
  except
    on e: Exception do
      Begin
        SetFocus;
        f_GereException ( e, FDataLink.DataSet, nil , False )
      End ;
  end;
  DoExit;
end;

procedure TFWDBDateTimePicker.CMGetDataLink(var Message: TMessage);
begin
  Message.Result := Integer(FDataLink);
end;

procedure TFWDBDateTimePicker.MouseDown(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  if Button = mbRight Then
   fb_ShowPopup (Self,PopUpMenu,FBeforePopup,FOnPopup);
end;

function TFWDBDateTimePicker.ExecuteAction(AAction: TBasicAction): Boolean;
begin
  Result := inherited ExecuteAction(AAction){$IFDEF DELPHI}  or (FDataLink <> nil) and
    FDataLink.ExecuteAction(AAction){$ENDIF};
end;

function TFWDBDateTimePicker.UpdateAction(AAction: TBasicAction): Boolean;
begin
  Result := inherited UpdateAction(AAction) {$IFDEF DELPHI}  or (FDataLink <> nil) and
    FDataLink.UpdateAction(AAction){$ENDIF};
end;

procedure TFWDBDateTimePicker.UpdateDate;
begin
 Inherited;
 if assigned ( FDataLink )
 and assigned ( FDataLink.Field )
 and ( FDataLink.Field.AsDateTime <> DateTime ) Then
  Begin
    FDataLink.Dataset.Edit ;
    FDataLink.Field.AsDateTime := DateTime ;
  End ;
end;

{$ELSE}


procedure TFWDBDateTimePicker.WMRButtonDown(var Msg: TWMRButtonDown);
begin
  inherited;
  fb_ShowPopup (Self,PopUpMenu,FBeforePopup,FOnPopup);
end;

{ TFWDBDateTimePicker }

procedure TFWDBDateTimePicker.p_setLabel(const alab_Label: TFWLabel);
begin
  if alab_Label <> FLabel Then
    Begin
      FLabel := alab_Label;
      FLabel.MyEdit := Self;
    End;
end;

procedure TFWDBDateTimePicker.SetOrder;
begin
  if assigned ( FNotifyOrder ) then
    FNotifyOrder ( Self );
end;

constructor TFWDBDateTimePicker.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FAlwaysSame := True;
  FColorLabel := CST_LBL_SELECT;
  FColorEdit  := CST_EDIT_STD;
  FColorFocus := CST_EDIT_SELECT;
  FColorReadOnly := CST_EDIT_READ;
end;

procedure TFWDBDateTimePicker.DoEnter;
begin
  if assigned ( FBeforeEnter ) Then
    FBeforeEnter ( Self );
  // Si on arrive sur une zone de saisie, on met en valeur son tlabel par une couleur
  // de fond bleu et son libellé en marron (sauf si le libellé est sélectionné
  // avec la souris => cas de tri)
  p_setLabelColorEnter ( FLabel, FColorLabel, FAlwaysSame );
  p_setCompColorEnter  ( Self, FColorFocus, FAlwaysSame );
  inherited DoEnter;
end;

procedure TFWDBDateTimePicker.DoExit;
begin
  if assigned ( FBeforeExit ) Then
    FBeforeExit ( Self );
  inherited DoExit;
  p_setLabelColorExit ( FLabel, FAlwaysSame );
  p_setCompColorExit ( Self, FOldColor, FAlwaysSame );

end;

procedure TFWDBDateTimePicker.Loaded;
begin
  inherited Loaded;
  FOldColor := Color;
  if  FAlwaysSame
   Then
    Color := gCol_Edit ;
end;

procedure TFWDBDateTimePicker.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;
  if Operation <> opRemove then
   Exit;
  if AComponent = FLabel then
    MyLabel := nil;
end;

procedure TFWDBDateTimePicker.WMPaint(var Message: {$IFDEF FPC}TLMPaint{$ELSE}TWMPaint{$ENDIF});
Begin
  p_setCompColorReadOnly ( Self,FColorEdit,FColorReadOnly, FAlwaysSame, ReadOnly );
  inherited;
End;

{$ENDIF}

{ TFWDBDateEdit }

procedure TFWDBDateEdit.p_setLabel(const alab_Label: TFWLabel);
begin
  if alab_Label <> FLabel Then
    Begin
      FLabel := alab_Label;
      FLabel.MyEdit := Self;
    End;
end;

procedure TFWDBDateEdit.SetOrder;
begin
  if assigned ( FNotifyOrder ) then
    FNotifyOrder ( Self );
end;

constructor TFWDBDateEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FAlwaysSame := True;
  FColorLabel := CST_LBL_SELECT;
  FColorEdit  := CST_EDIT_STD;
  FColorFocus := CST_EDIT_SELECT;
  FColorReadOnly := CST_EDIT_READ;
end;

procedure TFWDBDateEdit.DoEnter;
begin
  if assigned ( FBeforeEnter ) Then
    FBeforeEnter ( Self );
  // Si on arrive sur une zone de saisie, on met en valeur son tlabel par une couleur
  // de fond bleu et son libellé en marron (sauf si le libellé est sélectionné
  // avec la souris => cas de tri)
  p_setLabelColorEnter ( FLabel, FColorLabel, FAlwaysSame );
  p_setCompColorEnter  ( Self, FColorFocus, FAlwaysSame );
  inherited DoEnter;
end;

procedure TFWDBDateEdit.DoExit;
begin
  if assigned ( FBeforeExit ) Then
    FBeforeExit ( Self );
  inherited DoExit;
  p_setLabelColorExit ( FLabel, FAlwaysSame );
  p_setCompColorExit ( Self, FOldColor, FAlwaysSame );

end;

procedure TFWDBDateEdit.Loaded;
begin
  inherited Loaded;
  FOldColor := Color;
  if  FAlwaysSame
   Then
    Color := gCol_Edit ;
end;

procedure TFWDBDateEdit.WMPaint(var Message: {$IFDEF FPC}TLMPaint{$ELSE}TWMPaint{$ENDIF});
Begin
  p_setCompColorReadOnly ( Self,FColorEdit,FColorReadOnly, FAlwaysSame, ReadOnly );
  inherited;
End;

procedure TFWDBDateEdit.MouseDown(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);
  if Button = mbRight Then
   fb_ShowPopup (Self,PopUpMenu,FBeforePopup,FOnPopup);
end;

procedure TFWDBDateEdit.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if  ( Operation  = opRemove )
  and ( AComponent = FLabel   )
   Then FLabel := nil;
end;

{ TFWDBLookupCombo }

procedure TFWDBLookupCombo.p_setLabel(const alab_Label: TFWLabel);
begin
  if alab_Label <> FLabel Then
    Begin
      FLabel := alab_Label;
      FLabel.MyEdit := Self;
    End;
end;

procedure TFWDBLookupCombo.SetOrder;
begin
  if assigned ( FNotifyOrder ) then
    FNotifyOrder ( Self );
end;

constructor TFWDBLookupCombo.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FAlwaysSame := True;
  FColorLabel := CST_LBL_SELECT;
  FColorEdit  := CST_EDIT_STD;
  FColorFocus := CST_EDIT_SELECT;
  FColorReadOnly := CST_EDIT_READ;
end;

procedure TFWDBLookupCombo.DoEnter;
begin
  if assigned ( FBeforeEnter ) Then
    FBeforeEnter ( Self );
  // Si on arrive sur une zone de saisie, on met en valeur son tlabel par une couleur
  // de fond bleu et son libellé en marron (sauf si le libellé est sélectionné
  // avec la souris => cas de tri)
  p_setLabelColorEnter ( FLabel, FColorLabel, FAlwaysSame );
  p_setCompColorEnter  ( Self, FColorFocus, FAlwaysSame );
  inherited DoEnter;
end;

procedure TFWDBLookupCombo.DoExit;
begin
  if assigned ( FBeforeExit ) Then
    FBeforeExit ( Self );
  inherited DoExit;
  p_setLabelColorExit ( FLabel, FAlwaysSame );
  p_setCompColorExit ( Self, FOldColor, FAlwaysSame );

end;

procedure TFWDBLookupCombo.Loaded;
begin
  inherited Loaded;
  FOldColor := Color;
  if  FAlwaysSame
   Then
    Color := gCol_Edit ;
end;

procedure TFWDBLookupCombo.WMPaint(var Message: {$IFDEF FPC}TLMPaint{$ELSE}TWMPaint{$ENDIF});
Begin
  p_setCompColorReadOnly ( Self,FColorEdit,FColorReadOnly, FAlwaysSame, ReadOnly );
  inherited;
End;

procedure TFWDBLookupCombo.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);
  if Button = mbRight Then
   fb_ShowPopup (Self,PopUpMenu,FBeforePopup,FOnPopup);
end;

procedure TFWDBLookupCombo.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if  ( Operation  = opRemove )
  and ( AComponent = FLabel   )
   Then FLabel := nil;
end;

{ TFWDBComboBox }

procedure TFWDBComboBox.p_setLabel(const alab_Label: TFWLabel);
begin
  if alab_Label <> FLabel Then
    Begin
      FLabel := alab_Label;
      FLabel.MyEdit := Self;
    End;
end;

procedure TFWDBComboBox.SetOrder;
begin
  if assigned ( FNotifyOrder ) then
    FNotifyOrder ( Self );
end;

constructor TFWDBComboBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FAlwaysSame := True;
  FColorLabel := CST_LBL_SELECT;
  FColorEdit  := CST_EDIT_STD;
  FColorFocus := CST_EDIT_SELECT;
  FColorReadOnly := CST_EDIT_READ;
end;

procedure TFWDBComboBox.DoEnter;
begin
  if assigned ( FBeforeEnter ) Then
    FBeforeEnter ( Self );
  // Si on arrive sur une zone de saisie, on met en valeur son tlabel par une couleur
  // de fond bleu et son libellé en marron (sauf si le libellé est sélectionné
  // avec la souris => cas de tri)
  p_setLabelColorEnter ( FLabel, FColorLabel, FAlwaysSame );
  p_setCompColorEnter  ( Self, FColorFocus, FAlwaysSame );
  inherited DoEnter;
end;

procedure TFWDBComboBox.DoExit;
begin
  if assigned ( FBeforeExit ) Then
    FBeforeExit ( Self );
  inherited DoExit;
  p_setLabelColorExit ( FLabel, FAlwaysSame );
  p_setCompColorExit ( Self, FOldColor, FAlwaysSame );

end;

procedure TFWDBComboBox.Loaded;
begin
  inherited Loaded;
  FOldColor := Color;
  if  FAlwaysSame
   Then
    Color := gCol_Edit ;
end;

procedure TFWDBComboBox.WMPaint(var Message: {$IFDEF FPC}TLMPaint{$ELSE}TWMPaint{$ENDIF});
Begin
  p_setCompColorReadOnly ( Self,FColorEdit,FColorReadOnly, FAlwaysSame, ReadOnly );
  inherited;
End;

procedure TFWDBComboBox.MouseDown(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);
  if Button = mbRight Then
   fb_ShowPopup (Self,PopUpMenu,FBeforePopup,FOnPopup);
end;

procedure TFWDBComboBox.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if  ( Operation  = opRemove )
  and ( AComponent = FLabel   )
   Then FLabel := nil;
end;


{ TFWDBMemo }

procedure TFWDBMemo.p_setLabel(const alab_Label: TFWLabel);
begin
  if alab_Label <> FLabel Then
    Begin
      FLabel := alab_Label;
      FLabel.MyEdit := Self;
    End;
end;

procedure TFWDBMemo.SetOrder;
begin
  if assigned ( FNotifyOrder ) then
    FNotifyOrder ( Self );
end;

constructor TFWDBMemo.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FAlwaysSame := True;
  FColorLabel := CST_LBL_SELECT;
  FColorEdit  := CST_EDIT_STD;
  FColorFocus := CST_EDIT_SELECT;
  FColorReadOnly := CST_EDIT_READ;
end;

procedure TFWDBMemo.DoEnter;
begin
  if assigned ( FBeforeEnter ) Then
    FBeforeEnter ( Self );
  // Si on arrive sur une zone de saisie, on met en valeur son tlabel par une couleur
  // de fond bleu et son libellé en marron (sauf si le libellé est sélectionné
  // avec la souris => cas de tri)
  p_setLabelColorEnter ( FLabel, FColorLabel, FAlwaysSame );
  p_setCompColorEnter  ( Self, FColorFocus, FAlwaysSame );
  inherited DoEnter;
end;

procedure TFWDBMemo.DoExit;
begin
  if assigned ( FBeforeExit ) Then
    FBeforeExit ( Self );
  inherited DoExit;
  p_setLabelColorExit ( FLabel, FAlwaysSame );
  p_setCompColorExit ( Self, FOldColor, FAlwaysSame );

end;

procedure TFWDBMemo.Loaded;
begin
  inherited Loaded;
  FOldColor := Color;
  if  FAlwaysSame
   Then
    Color := gCol_Edit ;
end;

procedure TFWDBMemo.WMPaint(var Message: {$IFDEF FPC}TLMPaint{$ELSE}TWMPaint{$ENDIF});
Begin
  p_setCompColorReadOnly ( Self,FColorEdit,FColorReadOnly, FAlwaysSame, ReadOnly );
  inherited;
End;

procedure TFWDBMemo.MouseDown(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);
  if Button = mbRight Then
   fb_ShowPopup (Self,PopUpMenu,FBeforePopup,FOnPopup);
end;

procedure TFWDBMemo.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if  ( Operation  = opRemove )
  and ( AComponent = FLabel   )
   Then FLabel := nil;
end;

{ TFWDBSpinEdit }
constructor TFWDBSpinEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDataLink := TFieldDataLink.Create ;
  FDataLink.DataSource := nil ;
  FDataLink.FieldName  := '' ;
  FDataLink.Control := Self;
  FDataLink.OnDataChange := DataChange;
  FDataLink.OnUpdateData := UpdateData;
  FDataLink.OnActiveChange := ActiveChange;
  ControlStyle := ControlStyle + [csReplicatable];
end;

destructor TFWDBSpinEdit.Destroy;
begin
  inherited Destroy;
  FDataLink.Free ;
end;

procedure TFWDBSpinEdit.Loaded;
begin
  inherited Loaded;
  if (csDesigning in ComponentState) then
    Begin
      DataChange(Self);
    End ;
end;

procedure TFWDBSpinEdit.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (FDataLink <> nil) and
    (AComponent = DataSource) then DataSource := nil;
end;

procedure TFWDBSpinEdit.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);
  if (Key = VK_DELETE) or ((Key = VK_INSERT) and (ssShift in Shift)) then
    FDataLink.Edit;
end;

procedure TFWDBSpinEdit.KeyPress(var Key: Char);
begin
  inherited KeyPress(Key);
  if (Key in [#32..#255]) and (FDataLink.Field <> nil) and
    not FDataLink.Field.IsValidChar(Key) then
  begin
    {$IFDEF DELPHI}
    MessageBeep(0);
    {$ENDIF}
    Key := #0;
  end;
  case Key of
    ^H, ^V, ^X, #32..#255:
      FDataLink.Edit;
    #27:
      begin
        FDataLink.Reset;
        SelectAll;
        Key := #0;
      end;
  end;
end;

procedure TFWDBSpinEdit.Change;
begin
  inherited Change;
  if assigned ( FDataLink.Field ) Then
    if FDataLink.Field.IsNull then
      SetValue ( MinValue )
    Else
      SetValue ( FDataLink.Field.AsFloat );
  FDataLink.Modified;
end;

function TFWDBSpinEdit.GetDataSource: TDataSource;
begin
  Result := FDataLink.DataSource;
end;

procedure TFWDBSpinEdit.SetDataSource(AValue: TDataSource);
begin
  if not (FDataLink.DataSourceFixed and (csLoading in ComponentState)) then
    FDataLink.DataSource := AValue;
  if AValue <> nil then AValue.FreeNotification(Self);
end;

function TFWDBSpinEdit.GetDataField: string;
begin
  Result := FDataLink.FieldName;
end;

procedure TFWDBSpinEdit.SetDataField(const AValue: string);
begin
  if  assigned ( FDataLink.DataSet )
  and FDataLink.DataSet.Active Then
    Begin
      if assigned ( FDataLink.DataSet.FindField ( AValue ))
      and ( FDataLink.DataSet.FindField ( AValue ) is TNumericField ) Then
        FDataLink.FieldName := AValue;
    End
  Else
    FDataLink.FieldName := AValue;
end;

function TFWDBSpinEdit.GetReadOnly: Boolean;
begin
  Result := FDataLink.ReadOnly or {$IFDEF FPC}inherited{$ELSE}FReadOnly{$ENDIF};
end;

{$IFNDEF FPC}
procedure TFWDBSpinEdit.SetReadOnly(AValue: Boolean);
begin
  FReadOnly := AValue;
end;
{$ENDIF}

function TFWDBSpinEdit.GetField: TField;
begin
  Result := FDataLink.Field;
end;

procedure TFWDBSpinEdit.ActiveChange(Sender: TObject);
begin
  if FDataLink.Field <> nil then
    begin
      SetValue ( FDataLink.Field.AsFloat );
    end;
end;

procedure TFWDBSpinEdit.DataChange(Sender: TObject);
begin
  if FDataLink.Field <> nil then
    begin
      SetValue ( FDataLink.Field.AsFloat );
    end;
end;


procedure TFWDBSpinEdit.UpdateData(Sender: TObject);
begin
  if Value > -1 Then
    Begin
      FDataLink.Edit ;
      FDataLink.Field.Value := Value ;
    End ;
end;

{$IFDEF DELPHI}
procedure TFWDBSpinEdit.WMUndo(var Message: TMessage);
begin
  FDataLink.Edit;
  inherited;
end;
{$ENDIF}

procedure TFWDBSpinEdit.WMPaste(var Message: TMessage);
begin
  FDataLink.Edit;
  inherited;
end;

procedure TFWDBSpinEdit.WMCut(var Message: TMessage);
begin
  FDataLink.Edit;
  inherited;
end;

procedure TFWDBSpinEdit.CMExit(var Message: {$IFDEF FPC} TLMExit {$ELSE} TCMExit {$ENDIF});
begin
  try
    FDataLink.UpdateRecord;
  except
    on e: Exception do
      Begin
        SetFocus;
        f_GereException ( e, FDataLink.DataSet, nil , False )
      End ;
  end;
  DoExit;
end;

procedure TFWDBSpinEdit.CMGetDataLink(var Message: TMessage);
begin
  Message.Result := Integer(FDataLink);
end;

function TFWDBSpinEdit.ExecuteAction(AAction: TBasicAction): Boolean;
begin
  Result := inherited ExecuteAction(AAction){$IFDEF DELPHI}  or (FDataLink <> nil) and
    FDataLink.ExecuteAction(AAction){$ENDIF};
end;

function TFWDBSpinEdit.UpdateAction(AAction: TBasicAction): Boolean;
begin
  Result := inherited UpdateAction(AAction) {$IFDEF DELPHI}  or (FDataLink <> nil) and
    FDataLink.UpdateAction(AAction){$ENDIF};
end;

procedure TFWDBSpinEdit.SetValue({$IFDEF FPC}const {$ENDIF}AValue: {$IFDEF FPC}Double{$ELSE}Extended{$ENDIF});
begin
 if assigned ( FDataLink.Field )
 and ( FDataLink.Field.AsInteger <> AValue ) Then
  Begin
    FDataLink.Dataset.Edit ;
    FDataLink.Field.Value := AValue ;
  End ;
end;




{$IFDEF VERSIONS}
initialization
  // Gestion de version
  p_ConcatVersion(gVer_framework_DBcomponents);
{$ENDIF}
end.
