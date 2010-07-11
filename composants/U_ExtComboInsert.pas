{*********************************************************************}
{                                                                     }
{                                                                     }
{             TExtDBComboInsert :                               }
{             Objet issu d'un TCustomComboBox qui associe les         }
{             avantages de la DBComoBox et de la DBLookUpComboBox     }
{             Cr�ateur : Matthieu Giroux                          }
{             31 Mars 2005                                            }
{             Version 1.0                                             }
{                                                                     }
{                                                                     }
{*********************************************************************}

unit U_ExtComboInsert;

{$I ..\Compilers.inc}

interface

uses Variants, Windows, Messages, Controls, Classes,
     Graphics, Menus, Mask, ComCtrls, DB,DBCtrls,
     fonctions_version, JvDBLookup ;

{$IFDEF VERSIONS}
  const
    gVer_TDBLookupComboInsert : T_Version = ( Component : 'Composant TDBComboBoxInsert' ;
                                               FileUnit : 'U_DBComboBoxInsert' ;
                                               Owner : 'Matthieu Giroux' ;
                                               Comment : 'Insertion automatique dans une DBComboLookupEdit.' ;
                                               BugsStory : '1.0.1.2 : Bug validation au post.' +#13#10
                                                         + '1.0.1.1 : Bug rafra�chissement quand pas de focus.' +#13#10
                                                         + '1.0.1.0 : Propri�t� Modify.' +#13#10
                                                         + '1.0.0.0 : Version b�ta inadapt�e, r�utilisation du code de la TJvDBLookupComboEdit.' +#13#10
                                                         + '0.9.0.0 : En place � tester.';
                                               UnitType : 3 ;
                                               Major : 1 ; Minor : 0 ; Release : 1 ; Build : 2 );

{$ENDIF}
type

  TExtDBComboInsert = class;

  TPopupDataWindow = class(TJvPopupDataWindow)
  private
  protected
    FComboEditor: TExtDBComboInsert;
    FChanging : Boolean ;
    procedure ListLinkActiveChanged; override;
  public
    constructor Create(AOwner: TComponent); override;
  end;

{ TExtDBComboInsert }
  TExtDBComboInsert = class(TJvDBLookupEdit)
  private
    // On est en train d'�crire dans la combo
    FModify : Boolean ;
    // Valeur affich�e
    FDisplayValue : Variant ;
    // Lien de donn�es
    FDataLink: TFieldDataLink;
    // Canevas de peinture du composant
    FCanvas: TControlCanvas;
    // Focus sur le composant
    FFocused: Boolean;
    // En train de mettre � jour ou pas
    FUpdate ,
    // Beep sur erreur
    FBeepOnError: Boolean;
    function GetCanvas: TCanvas;
    function GetDataField: string;
    function GetDataSource: TDataSource;
    function GetField: TField;
    function GetTextMargins: TPoint;
    procedure ResetMaxLength;
    procedure SetDataField(const Value: string);
    procedure SetDataSource(Value: TDataSource);
    procedure SetFocused(Value: Boolean);
    procedure UpdateData(Sender: TObject);
    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
    procedure CMGetDataLink(var Msg: TMessage); message CM_GETDATALINK;
    function GetDisplayValue: String;
  protected
    OldText : String ;
    procedure PopupCloseUp(Sender: TObject; Accept: Boolean); override;
    procedure ActiveChange(Sender: TObject); virtual ;
    procedure DataChange(Sender: TObject); virtual ;
    procedure EditingChange(Sender: TObject); virtual ;
//    procedure ListLinkActiveChanged; override ;
    procedure InsertLookup ( const Update : Boolean ); virtual ;
    procedure WMCut(var Msg: TMessage); message WM_CUT;
    procedure WMPaste(var Msg: TMessage); message WM_PASTE;
    procedure WMUndo(var Msg: TMessage); message WM_UNDO;
    procedure DoEnter; override;
    procedure DoExit; override;

    function GetReadOnly: Boolean; override; // suppress the warning
    procedure SetReadOnly(Value: Boolean); override;
    procedure Change; override;
    procedure DoChange; override;
    function EditCanModify: Boolean; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
    procedure Loaded; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure Reset; override;
  public
    property Modify : Boolean read FModify ;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function ExecuteAction(Action: TBasicAction): Boolean; override;
    function UpdateAction(Action: TBasicAction): Boolean; override;
    // function UseRightToLeftAlignment: Boolean; override;
    property Field: TField read GetField;
    property Canvas: TCanvas read GetCanvas;
    property DisplayValue : Variant read FDisplayValue write FDisplayValue;
  published
    property Anchors;
    property AutoSelect;
    property AutoSize;
    property BeepOnError: Boolean read FBeepOnError write FBeepOnError default True;
    property BiDiMode;
    property BorderStyle;
    property CharCase;
    property Color;
    property Constraints;
    property DataField: string read GetDataField write SetDataField;
    property DataSource: TDataSource read GetDataSource write SetDataSource;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property Font;
    property ImeMode;
    property ImeName;
    property MaxLength;
    property ParentBiDiMode;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property PasswordChar;
    property PopupMenu;
    property ReadOnly: Boolean read GetReadOnly write SetReadOnly default False;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Visible;
    property OnChange;
    property OnClick;
    property OnContextPopup;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDock;
    property OnStartDrag;
  end;

  procedure Register;

implementation

uses
  SysUtils, Forms, StdCtrls, fonctions_erreurs,
  JvConsts, JvToolEdit, unite_messages;

{ TPopupDataWindow }

////////////////////////////////////////////////////////////////////////////////
// Constructeur : create
// description : Cr�ation de la liste en popup
////////////////////////////////////////////////////////////////////////////////
constructor TPopupDataWindow.Create(AOwner: TComponent);
begin
  // Initialisation
  FChanging := False ;
  // combo parent
  FComboEditor := AOwner as TExtDBComboInsert ;
  inherited Create(AOwner);
end;

////////////////////////////////////////////////////////////////////////////////
// procedure : ListLinkActiveChanged
// description : Ouverture des donn�es : affectation de datafield
////////////////////////////////////////////////////////////////////////////////
procedure TPopupDataWindow.ListLinkActiveChanged;
begin
  inherited;
  if  assigned ( LookupSource )
  and assigned ( LookupSource.DataSet )
  and LookupSource.DataSet.Active Then
    try
      FComboEditor.Text := FComboEditor.GetDisplayValue ;
    finally
    End ;
end;


{ TExtDBComboInsert }


////////////////////////////////////////////////////////////////////////////////
// procedure : Register
// description : Enregistrement du composant dans la palette des composants
////////////////////////////////////////////////////////////////////////////////
procedure Register;
begin
  RegisterComponents(CST_PALETTE_COMPOSANTS, [TExtDBComboInsert]);
end;


////////////////////////////////////////////////////////////////////////////////
// Constructeur : Create
// description  : Initialisation du composant
////////////////////////////////////////////////////////////////////////////////
constructor TExtDBComboInsert.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  // Pas de modification ni de mise � jour � la cr�ation
  FModify := False ;
  FUpdate := False ;
  // style lookup
  ControlStyle := ControlStyle + [csReplicatable];
  // Cr�ation du canevas
  FCanvas := TControlCanvas.Create;
  FCanvas.Control := Self;
  // Cr�ation du lien
  FDataLink := TFieldDataLink.Create;
  FDataLink.Control := Self;
  // Changement dans les donn�es
  FDataLink.OnDataChange := DataChange;
  // Edition des donn�es
  FDataLink.OnEditingChange := EditingChange;
  // Mise � jour des donn�es
  FDataLink.OnUpdateData := UpdateData;
  // Activation des donn�es
  FDataLink.OnActiveChange := ActiveChange;
  // Beep sur erreur par d�faut
  FBeepOnError := True;
  // Mode cr�ation pour informer la popup
  ControlState := ControlState + [csCreating];
  // Cr�ation popup
  try
    // Une ancienne popup existe d�j�
    FPopup.Free ;
    // Cr�ation du descendant de TPopupDataWindow
    FPopup := TPopupDataWindow.Create(Self);
    // ev�nement d'affectation de donn�e
    TJvPopupDataWindow(FPopup).OnCloseUp := PopupCloseUp;
    // Glyph de combo par d�faut
    GlyphKind := gkDropDown; { force update }
  finally
    ControlState := ControlState - [csCreating];
  end;
end;

////////////////////////////////////////////////////////////////////////////////
// Destructeur : Destroy
// description : Destruction des objets cr��s au create
////////////////////////////////////////////////////////////////////////////////
destructor TExtDBComboInsert.Destroy;
begin
  // Lien de donn�es
  FDataLink.Free;
  FDataLink := nil;
  inherited Destroy;
  // (rom) destroy Canvas AFTER inherited Destroy
  // canevas de peinture du composant
  FCanvas.Free;
end;

////////////////////////////////////////////////////////////////////////////////
// proc�dure   : ResetMaxLength
// description : V�rifications avant affectation de la taille du texte � rien
////////////////////////////////////////////////////////////////////////////////
procedure TExtDBComboInsert.ResetMaxLength;
var
  F: TField;
begin
  if (MaxLength > 0) and Assigned(DataSource) and Assigned(DataSource.DataSet) then
  begin
    F := DataSource.DataSet.FindField(DataField);
    if Assigned(F) and (F.DataType in [ftString, ftWideString]) and (F.Size = MaxLength) then
      MaxLength := 0;
  end;
end;

////////////////////////////////////////////////////////////////////////////////
// proc�dure   : Loaded
// description : Initialisations apr�s le chargement des autres composants
////////////////////////////////////////////////////////////////////////////////
procedure TExtDBComboInsert.Loaded;
begin
  inherited Loaded;
  ResetMaxLength;
  if csDesigning in ComponentState then
    DataChange(Self);
end;


////////////////////////////////////////////////////////////////////////////////
// proc�dure   : Notification
// description : enl�ve les liens vers les composants supprim�s dans la fiche
// param�tres  : AComponent : Le composant test�
//               Operation  : supprim� ou ajout�
////////////////////////////////////////////////////////////////////////////////
procedure TExtDBComboInsert.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (FDataLink <> nil) and (AComponent = DataSource) then
    DataSource := nil;
end;

////////////////////////////////////////////////////////////////////////////////
// proc�dure   : KeyDown
// description : �v�nement enfoncement de touche
// param�tres  : Key : La touche appuy�e
//               Shift : Touche sp�ciale
////////////////////////////////////////////////////////////////////////////////
procedure TExtDBComboInsert.KeyDown(var Key: Word; Shift: TShiftState);
begin
  // new order, because result of inherited KeyDown(...) could be = 0
  // so, first set DataSet in Edit-Mode
  // certaines touches initient l'�dition des donn�es
  if Key in [VK_BACK, VK_DELETE, VK_UP, VK_DOWN, 32..255] then // taken from TDBComboBox.KeyDown(...)
    FDataLink.Edit;
  // Auto-insertion dans ce composant
  if Key in [VK_RETURN] Then
    InsertLookup ( True );
  inherited KeyDown(Key, Shift);
end;

////////////////////////////////////////////////////////////////////////////////
// proc�dure   : KeyPress
// description : �v�nement appuie sur touche
// param�tre   : Key : La touche appuy�e
////////////////////////////////////////////////////////////////////////////////
procedure TExtDBComboInsert.KeyPress(var Key: Char);
begin
  inherited KeyPress(Key);
  // v�rifications : Tout est-il renseign� correctement ?
  if (Key in [#32..#255]) and (FDataLink.Field <> nil) Then
    Begin
      FModify := True ;
       if  ( (( LookupDisplay = '' ) and not FDataLink.Field.IsValidChar(Key))
       or  ( ( LookupDisplay <> '' ) and
       ( not assigned ( LookupSource ) or not assigned ( LookupSource.DataSet ) or not assigned ( LookupSource.DataSet.FindField ( LookupDisplay ) ) or not LookupSource.DataSet.FindField ( LookupDisplay ).IsValidChar(Key)))) then
      begin
        if BeepOnError then
          SysUtils.Beep;
        Key := #0;
      end;
    End ;
    // Mode �dition sur certaines touches
  case Key of
    CtrlH, CtrlV, CtrlX, #32..#255:
      FDataLink.Edit;
    Esc:
    // annulation
      begin
        FDataLink.Reset;
        SelectAll;
//        Key := #0;
      end;
  end;
end;

////////////////////////////////////////////////////////////////////////////////
// fonction    : EditCanModify
// description : Edition puis retour du mode �dition
// param�tres  : r�sultat : en mode �dition ou pas
////////////////////////////////////////////////////////////////////////////////
function TExtDBComboInsert.EditCanModify: Boolean;
begin
  Result := FDataLink.Edit;
end;

////////////////////////////////////////////////////////////////////////////////
// proc�dure   : Reset
// description : Remet les donn�es originelles
////////////////////////////////////////////////////////////////////////////////
procedure TExtDBComboInsert.Reset;
begin
  FDataLink.Reset;
  SelectAll;
end;

////////////////////////////////////////////////////////////////////////////////
// proc�dure   : SetFocused
// description : Attribue la variable focus
// param�tre   : Value : Focus ou pas focus
////////////////////////////////////////////////////////////////////////////////
procedure TExtDBComboInsert.SetFocused(Value: Boolean);
begin
  if FFocused <> Value then
  begin
    FFocused := Value;
    // if (FAlignment <> taLeftJustify) and not IsMasked then Invalidate;
    FDataLink.Reset;
  end;
end;

////////////////////////////////////////////////////////////////////////////////
// proc�dure   : Change
// description : Ev�nement sur changement du datasourc principal
////////////////////////////////////////////////////////////////////////////////
procedure TExtDBComboInsert.Change;
begin
  // On avertit le lien de donn�es
  FDataLink.Modified;
  if assigned ( FDataLink.Dataset )
  and not ( FDataLink.Dataset.State in [dsInsert,dsEdit]) Then
    // Les donn�es viennent peut-�tre d'�tre valid�es
    FModify := False ;
  inherited Change;
end;

////////////////////////////////////////////////////////////////////////////////
// proc�dure   : DoChange
// description : Ev�nement sur changement du datasourc principal
////////////////////////////////////////////////////////////////////////////////
procedure TExtDBComboInsert.DoChange;
begin
  inherited DoChange;
end;


////////////////////////////////////////////////////////////////////////////////
// fonction    : GetDataSource
// description : R�cup�re le Datasource principal
// param�tre   : r�sultat : le Datasource principal
////////////////////////////////////////////////////////////////////////////////
function TExtDBComboInsert.GetDataSource: TDataSource;
begin
  Result := FDataLink.DataSource;
end;

////////////////////////////////////////////////////////////////////////////////
// proc�dure   : SetDataSource
// description : Attribue le Datasource principal
// param�tre   : Value : le futur Datasource principal
////////////////////////////////////////////////////////////////////////////////
procedure TExtDBComboInsert.SetDataSource(Value: TDataSource);
begin
  if not (FDataLink.DataSourceFixed and (csLoading in ComponentState)) then
    FDataLink.DataSource := Value;
  if Value <> nil then
    Value.FreeNotification(Self);
end;

////////////////////////////////////////////////////////////////////////////////
// fonction    : GetDataField
// description : R�cup�re le champ du Datasource principal
// param�tre   : r�sultat : le champ du Datasource principal
////////////////////////////////////////////////////////////////////////////////
function TExtDBComboInsert.GetDataField: string;
begin
  Result := FDataLink.FieldName;
end;

////////////////////////////////////////////////////////////////////////////////
// proc�dure   : SetDataField
// description : Attribue le champ du Datasource principal
// param�tre   : Value : le futur champ du Datasource principal
////////////////////////////////////////////////////////////////////////////////
procedure TExtDBComboInsert.SetDataField(const Value: string);
begin
  if not (csDesigning in ComponentState) then
    ResetMaxLength;
  FDataLink.FieldName := Value;
end;

////////////////////////////////////////////////////////////////////////////////
// fonction    : GetReadOnly
// description : R�cup�re la lecture seule
// param�tre   : r�sultat : lecture seule ou pas
////////////////////////////////////////////////////////////////////////////////
function TExtDBComboInsert.GetReadOnly: Boolean;
begin
  Result := FDataLink.ReadOnly or inherited GetReadOnly;
end;

////////////////////////////////////////////////////////////////////////////////
// proc�dure   : SetReadOnly
// description : Attribue la lecture seule
// param�tre   : Value : lecture seule ou pas
////////////////////////////////////////////////////////////////////////////////
procedure TExtDBComboInsert.SetReadOnly(Value: Boolean);
begin
  inherited SetReadOnly(Value);
  FDataLink.ReadOnly := Value;
end;

////////////////////////////////////////////////////////////////////////////////
// fonction    : GetCanvas
// description : R�cup�re le canevas de peinture du composant
// param�tre   : r�sultat : le canevas
////////////////////////////////////////////////////////////////////////////////
function TExtDBComboInsert.GetCanvas: TCanvas;
begin
  Result := FCanvas;
end;

////////////////////////////////////////////////////////////////////////////////
// fonction    : GetField
// description : R�cup�re le champ principal
// param�tre   : r�sultat : le champ
////////////////////////////////////////////////////////////////////////////////
function TExtDBComboInsert.GetField: TField;
begin
  Result := FDataLink.Field;
end;

////////////////////////////////////////////////////////////////////////////////
// Ev�nement   : ActiveChange
// description : Initialisation de la taille du texte
// param�tre   : Sender : pour l'�v�nement
////////////////////////////////////////////////////////////////////////////////
procedure TExtDBComboInsert.ActiveChange(Sender: TObject);
begin
  ResetMaxLength;
end;

////////////////////////////////////////////////////////////////////////////////
// fonction    : GetDisplayValue
// description : R�cup�re la valeur affich�e
// param�tre   : r�sultat : la valeur affich�e
////////////////////////////////////////////////////////////////////////////////
function  TExtDBComboInsert.GetDisplayValue : String ;
Begin
  Result := '' ;
    // Tests
  If  assigned ( FDataLink.Field )
  and not FDataLink.Field.IsNull
  and assigned ( LookupSource )
  and assigned ( LookupSource.DataSet )
  and assigned ( LookupSource.DataSet.FindField ( LookupDisplay ))
  and assigned ( LookupSource.DataSet.FindField ( LookupField   )) Then
    Begin
      if ( FPopup as TJvPopupDataWindow ).Locate ( LookupSource.DataSet.FindField ( LookupField   ), FDataLink.Field.AsString, True ) Then
        // r�cup�ration � partir de la listes
        Result := LookupSource.DataSet.FindField ( LookupDisplay ).AsString ;
    End ;
End ;

////////////////////////////////////////////////////////////////////////////////
// Ev�nement   : DataChange
// description : Changement dans les donn�es
// param�tre   : Sender : pour l'�v�nement
////////////////////////////////////////////////////////////////////////////////
procedure TExtDBComboInsert.DataChange(Sender: TObject);
begin
  if FDataLink.Field <> nil then
  begin
    // r�cup�ration du masque de saisie
    EditMask := FDataLink.Field.EditMask;
    if not (csDesigning in ComponentState) then
      if (FDataLink.Field.DataType in [ftString, ftWideString]) and (MaxLength = 0) then
        // Taille maxi
        MaxLength := FDataLink.Field.Size;
    if FFocused and FDataLink.CanModify then
      Begin
        // r�cup�ration des donn�es de la liste en mode lecture
        if  ( not ( FDataLink.DataSet.State in [dsEdit, dsInsert]) or FUpdate) Then
          Begin
            Text := GetDisplayValue ;
          End ;
      End
    else
    begin
      // affectation du texte � partir de la liste quand on n'est pas sur la combo
      EditText := GetDisplayValue ;// FDataLink.Field.DisplayText
      // V�rification de l'�dition du champ ailleurs
      if FDataLink.Editing then //and FDataLink.FModify || FModified is private in parent of fdatalink
        Modified := True;
    end;
  end
  else
  begin
    EditMask := '';
    if csDesigning in ComponentState then
      // Pas de donn�e : on montre le nom de la combo
      EditText := Name
    else
      EditText := '' ;
  end;
end;

////////////////////////////////////////////////////////////////////////////////
// Ev�nement   : EditingChange
// description : Changement dans l'�dition des donn�es
// param�tre   : Sender : pour l'�v�nement
////////////////////////////////////////////////////////////////////////////////
procedure TExtDBComboInsert.EditingChange(Sender: TObject);
begin
  //ReadOnly := not FDataLink.Editing;
end;

////////////////////////////////////////////////////////////////////////////////
// Ev�nement   : UpdateData
// description : Mise � jour apr�s l'�dition des donn�es
// param�tre   : Sender : pour l'�v�nement
////////////////////////////////////////////////////////////////////////////////
procedure TExtDBComboInsert.UpdateData(Sender: TObject);
begin
  // auto-insertion sp�cifique de ce composant
  InsertLookup ( False );
  // Validation de l'�dition
  ValidateEdit;
  // affectation
  FDataLink.Field.Value := LookupValue;
end;

////////////////////////////////////////////////////////////////////////////////
// Ev�nement message  : WMUndo
// description : Annulation
// param�tre   : Msg : donn�es du message
////////////////////////////////////////////////////////////////////////////////
procedure TExtDBComboInsert.WMUndo(var Msg: TMessage);
begin
  FDataLink.Edit;
  inherited;
end;

////////////////////////////////////////////////////////////////////////////////
// Ev�nement message  : WMPaste
// description : Coller
// param�tre   : Msg : donn�es du message
////////////////////////////////////////////////////////////////////////////////
procedure TExtDBComboInsert.WMPaste(var Msg: TMessage);
begin
  FDataLink.Edit;
  inherited;
end;

////////////////////////////////////////////////////////////////////////////////
// Ev�nement message  : WMCut
// description : Couper
// param�tre   : Msg : donn�es du message
////////////////////////////////////////////////////////////////////////////////
procedure TExtDBComboInsert.WMCut(var Msg: TMessage);
begin
  FDataLink.Edit;
  inherited;
end;

////////////////////////////////////////////////////////////////////////////////
// proc�dure   : DoEnter
// description : Attribue le focus au composant
////////////////////////////////////////////////////////////////////////////////
procedure TExtDBComboInsert.DoEnter;
begin
  // Affecte la propri�t� focused
  SetFocused(True);
  inherited DoEnter;
  // S�lectionne le texte
  SelectAll ;
  // pas de lecture seule ?
  if SysLocale.FarEast and FDataLink.CanModify then
    inherited ReadOnly := False;
end;

////////////////////////////////////////////////////////////////////////////////
// proc�dure   : InsertLookup
// description : Insertion automatique
// param�tre   : Update : validation du champ si pas en train de valider
////////////////////////////////////////////////////////////////////////////////
procedure TExtDBComboInsert.InsertLookup ( const Update : Boolean );
begin
  if ( csDesigning in ComponentState ) Then
    Exit ;
    // v�rifications
  if  assigned ( FDataLink.Dataset )
  and assigned ( LookupSource )
  and assigned ( LookupSource.DataSet )
  and assigned ( FDataLink.Field )
  and ( FDataLink.Dataset.State in [ dsEdit,dsInsert ]) Then
    try
      if ( Text <> '' ) Then
        // Si du texte est pr�sent
        Begin
          if not LookupSource.DataSet.Locate ( LookupDisplay, Text, [loCaseInsensitive] ) Then
            // Autoinsertion si pas dans la liste
            Begin
              LookupSource.DataSet.Insert ;
              LookupSource.DataSet.FieldByName ( LookupDisplay ).Value := Text ;
              LookupSource.DataSet.Post ;
              LookupValue := LookupSource.DataSet.FieldByName ( LookupField ).Value ;
              FUpdate := True ;
              if Update Then
                FDataLink.UpdateRecord;
            End
          Else
          // sinon affectation de Datafield uniquement
            Begin
              FUpdate := True ;
              if Update Then
                Begin
                  FDataLink.UpdateRecord;
                End ;
            End ;
        End
      Else
        // pas de texte : on remet le texte originel
        LookupValue := OldText ;
      FModify := False ;
    except
      SelectAll;
      SetFocus;
      raise;
    end;
  FUpdate := False ;
End ;

////////////////////////////////////////////////////////////////////////////////
// proc�dure   : DoExit
// description : D�focus du composant
////////////////////////////////////////////////////////////////////////////////
procedure TExtDBComboInsert.DoExit;
begin
  // Auto-insertion
  InsertLookup ( True );
  // Focused � False
  SetFocused(False);
  CheckCursor;
  inherited DoExit;
end;

////////////////////////////////////////////////////////////////////////////////
// Ev�nement message  : WMPaint
// description : Peinture de la combo
// param�tre   : Msg : donn�es du message
////////////////////////////////////////////////////////////////////////////////
procedure TExtDBComboInsert.WMPaint(var Msg: TWMPaint);
const
  AlignStyle: array [Boolean, TAlignment] of DWORD =
   ((WS_EX_LEFT, WS_EX_RIGHT, WS_EX_LEFT),
    (WS_EX_RIGHT, WS_EX_LEFT, WS_EX_LEFT));
var
  Left: Integer;
  Margins: TPoint;
  R: TRect;
  DC: HDC;
  PS: TPaintStruct;
  S: string;
  AAlignment: TAlignment;
  ExStyle: DWORD;
begin
  // destruction : pas besoin de peindre
  if csDestroying in ComponentState then
    Exit;
  // alignement horizontal en cours
  AAlignment := Alignment; //FAlignment;
  if UseRightToLeftAlignment then
    ChangeBiDiModeAlignment(AAlignment);
  if ((AAlignment = taLeftJustify) or FFocused) and
    not (csPaintCopy in ControlState) then
  begin
    if SysLocale.MiddleEast and HandleAllocated and (IsRightToLeft) then
    // alignement horizontal en cours
    begin { This keeps the right aligned text, right aligned }
      ExStyle := DWORD(GetWindowLong(Handle, GWL_EXSTYLE)) and (not WS_EX_RIGHT) and
        (not WS_EX_RTLREADING) and (not WS_EX_LEFTSCROLLBAR);
      if UseRightToLeftReading then
        ExStyle := ExStyle or WS_EX_RTLREADING;
      if UseRightToLeftScrollbar then
        ExStyle := ExStyle or WS_EX_LEFTSCROLLBAR;
      ExStyle := ExStyle or
        AlignStyle[UseRightToLeftAlignment, AAlignment];
      if DWORD(GetWindowLong(Handle, GWL_EXSTYLE)) <> ExStyle then
        SetWindowLong(Handle, GWL_EXSTYLE, ExStyle);
    end;
    inherited;
    Exit;
  end;

{ Since edit controls do not handle justification unless multi-line (and
  then only poorly) we will draw right and center justify manually unless
  the edit has the focus. }
  // Initialisation de la peinture
  DC := Msg.DC;
  if DC = 0 then
    DC := BeginPaint(Handle, PS);
  FCanvas.Handle := DC;
  try
    // couleur de police
    FCanvas.Font := Font;
    with FCanvas do
    begin
      R := ClientRect;
      if not (NewStyleControls and Ctl3D) and (BorderStyle = bsSingle) then
      // Mode simple
      begin
        Brush.Color := clWindowFrame;
        FrameRect(R);
        InflateRect(R, -1, -1);
      end;
      // Couleur de pinceau
      Brush.Color := Color;
      if not Enabled then
        // d�sactivation
        Font.Color := clGrayText;
      if (csPaintCopy in ControlState) and (FDataLink.Field <> nil) then
      begin
        //r�cup�ration du texte du champ
        S := FDataLink.Field.DisplayText;
        case CharCase of
          ecUpperCase:
            S := AnsiUpperCase(S);
          ecLowerCase:
            S := AnsiLowerCase(S);
        end;
      end
      else
        //r�cup�ration du texte d'�dition
        S := EditText;
        // mode mot de passe
      if PasswordChar <> #0 then
        FillChar(S[1], Length(S), PasswordChar);
        // Marges
      Margins := GetTextMargins;
      case AAlignment of
        taLeftJustify:
          Left := Margins.X;
        taRightJustify:
          Left := ClientWidth - TextWidth(S) - Margins.X - 1;
      else
        Left := (ClientWidth - TextWidth(S)) div 2;
      end;
      if SysLocale.MiddleEast then
        UpdateTextFlags;
        // affiche le texte
      TextRect(R, Left, Margins.Y, S);
    end;
  finally
    // lib�ration du canevas
    FCanvas.Handle := 0;
    if Msg.DC = 0 then
      EndPaint(Handle, PS);
  end;
end;

////////////////////////////////////////////////////////////////////////////////
// Ev�nement message  : CMGetDataLink
// description : R�cup�ration du handle du datalink
// param�tre   : Msg : donn�es du message
////////////////////////////////////////////////////////////////////////////////
procedure TExtDBComboInsert.CMGetDataLink(var Msg: TMessage);
begin
  Msg.Result := Integer(FDataLink);
end;

////////////////////////////////////////////////////////////////////////////////
// fonction    : GetTextMargins
// description : R�cup�re les marges sur le texte
// param�tre   : r�sultat : les marges du haut et du bas
////////////////////////////////////////////////////////////////////////////////
function TExtDBComboInsert.GetTextMargins: TPoint;
var
  DC: HDC;
  SaveFont: HFont;
  I: Integer;
  SysMetrics, Metrics: TTextMetric;
begin
  // mode style 3D ou pas
  if NewStyleControls then
  begin
    if BorderStyle = bsNone then
      I := 0
    else
      // mode enfoncement et superpos�
    if Ctl3D then
      I := 1
    else
      I := 2;
      // Nouvelles marges : avertir windows
    Result.X := SendMessage(Handle, EM_GETMARGINS, 0, 0) and $0000FFFF + I;
    Result.Y := I;
  end
  else
  begin
    // Aucune marge pr�d�finie sinon
    if BorderStyle = bsNone then
      I := 0
    else
    begin
      // calculs des marges autour du texte
      DC := GetDC(HWND_DESKTOP);
      GetTextMetrics(DC, SysMetrics);
      SaveFont := SelectObject(DC, Font.Handle);
      GetTextMetrics(DC, Metrics);
      SelectObject(DC, SaveFont);
      ReleaseDC(HWND_DESKTOP, DC);
      I := SysMetrics.tmHeight;
      if I > Metrics.tmHeight then
        I := Metrics.tmHeight;
      I := I div 4;
    end;
    Result.X := I;
    Result.Y := I;
  end;
end;

////////////////////////////////////////////////////////////////////////////////
// fonction    : ExecuteAction
// description : Ex�cute une classe d'action
// param�tre   : Action   : L'action r�pertori�e
//              r�sultat : Action ex�cut�e ou pas
////////////////////////////////////////////////////////////////////////////////
function TExtDBComboInsert.ExecuteAction(Action: TBasicAction): Boolean;
begin
  Result := inherited ExecuteAction(Action) or (FDataLink <> nil) and
    FDataLink.ExecuteAction(Action);
end;

////////////////////////////////////////////////////////////////////////////////
// fonction    : UpdateAction
// description : Ex�cute une classe d'action de mise � jour
// param�tre   : Action   : L'action r�pertori�e
//              r�sultat : Action ex�cut�e ou pas
////////////////////////////////////////////////////////////////////////////////
function TExtDBComboInsert.UpdateAction(Action: TBasicAction): Boolean;
begin
  Result := inherited UpdateAction(Action) or (FDataLink <> nil) and
    FDataLink.UpdateAction(Action);
end;

////////////////////////////////////////////////////////////////////////////////
// proc�dure Ev�nement : PopupCloseUp
// description : Affectation �venutelle � la fermeture de la liste
// Param�tres  : Sender : La liste
//               Accept : affectation ou pas
////////////////////////////////////////////////////////////////////////////////
procedure TExtDBComboInsert.PopupCloseUp(Sender: TObject;
  Accept: Boolean);
begin
  // v�rfications pour affectation
  if Accept
  and  assigned ( LookupSource )
  and assigned ( LookupSource.DataSet )
  and assigned ( LookupSource.DataSet.FindField ( LookupField ))
  and assigned ( FDataLink.Field ) Then
    try
      // affectation
      FDataLink.Dataset.edit ;
      FDataLink.Field.Value := LookupSource.DataSet.FindField ( LookupField ).Value ;
    finally
    End ;

  inherited;
end;

{$IFDEF VERSIONS}
initialization
  p_ConcatVersion ( gVer_TDBLookupComboInsert );
{$ENDIF}
end.
