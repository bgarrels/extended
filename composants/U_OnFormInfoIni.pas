{*********************************************************************}
{                                                                     }
{                                                                     }
{             Matthieu Giroux                                         }
{             TOnFormInfoIni :                                       }
{             Objet de sauvegarde d'informations de Forms             }
{             20 F�vrier 2003                                         }
{                                                                     }
{                                                                     }
{*********************************************************************}

unit U_OnFormInfoIni;


{$IFDEF FPC}
{$mode Delphi}
{$ENDIF}


interface
// Listes des informations sauvegard�es dans le fichier ini de l'application :
// Les donn�es objets Edit
// La position des Objets (avec l'utilisation des Panels et des RxSplitters et RbSplitter)
// L'index de la pageactive des PageControls (onglets)
// L'index des objets CheckBoxex, RadioBoutons, RadioGroups ,PopupMenus
// les positions de la fen�tre

{$I ..\Compilers.inc}
{$I ..\extends.inc}

uses
{$IFDEF FPC}
  LCLIntf, lresources,
{$ELSE}
  RTLConsts,
  Windows, Mask, Consts, ShellAPI, JvToolEdit, U_ExtPageControl,
{$ENDIF}
{$IFDEF RX}
  RxLookup,
{$ENDIF}
  SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  IniFiles, StdCtrls, ComCtrls, ExtCtrls,
  Variants, Menus, Buttons,
{$IFDEF VERSIONS}
  fonctions_version,
{$ENDIF}
  ExtDlgs,
  fonctions_init, DBGrids;

{$IFDEF VERSIONS}
  const
    gVer_TSvgFormInfoIni : T_Version = ( Component : 'Composant TOnFormInfoIni' ;
                                               FileUnit : 'U_OnFormInfoIni' ;
                                               Owner : 'Matthieu Giroux' ;
                                               Comment : 'Gestion de l''ini � mettre sur une fiche.' ;
                                               BugsStory : '1.0.1.0 : Testing DirectoryEdit, MaskEdit, on WINDOWS.' +#13#10 +
                                                           '1.0.0.1 : Grouping.' +#13#10 +
                                                           '1.0.0.1 : Lesser Bug, not searching the component in form.' +#13#10 +
                                                           '1.0.0.0 : Gestion de beaucoup de composants.';
                                               UnitType : 3 ;
                                               Major : 1 ; Minor : 0 ; Release : 1 ; Build : 0 );

{$ENDIF}
const CST_INI_DIRECTORYEDIT_DIR  = {$IFDEF FPC} 'Directory' {$ELSE} 'Text' {$ENDIF};
type
  // Liste des objets dont on veut conserver les donner dans le fichier INI
  TSauveEditObjet = (feTEdit, feTCheck, feTComboValue, feTComboBox, feTColorCombo,feTCurrencyEdit,feTDateEdit,
        {$IFDEF DELPHI}
        feTDateTimePicker,
        {$ENDIF}
  feTDirectoryEdit,feTFileNameEdit,feTGrid,feTListBox, feTListView, feTMemo, feTPageControl, feTPopup, feTRadio, feTRadioGroup, feTRichEdit,feTSpinEdit,
  feTVirtualTrees );
  TEventIni = procedure ( const AInifile : TCustomInifile ; var Continue : Boolean ) of object;
  TSauveEditObjets = set of TSauveEditObjet;

  { TOnFormInfoIni }

  TOnFormInfoIni = class(TComponent)
  private
    FSauveEditObjets: TSauveEditObjets;
    FSauvePosObjet,
    FAutoUpdate,
    FSauvePosForm:      Boolean;
    FOnIniLoad, FOnIniWrite : TEventIni;
  protected
    FUpdateAll ,
    FAutoChargeIni: Boolean;
    FormAOwner:     TCustomForm;
    FormOldDestroy: TNotifyEvent;
    FormOldCreate:  TNotifyEvent;
    FormOldShow:    TNotifyEvent;
//    procedure loaded; override;
    function GetfeSauveEdit(aSauveObjet:TSauveEditObjets;aObjet :TSauveEditObjet):Boolean ;
    // traitement de la position de la af_Form mise dans le create
    procedure p_LecturePositionFenetre(aFiche:TCustomForm);
    procedure p_EcriturePositionFenetre(const aFiche:TCustomForm);

  public
    Constructor Create(AOwner:TComponent); override;
    procedure ExecuteLecture(aLocal:Boolean); virtual;
    procedure p_ExecuteLecture(const aF_Form: TCustomForm); virtual;
    procedure ExecuteEcriture(aLocal: Boolean); virtual;
    procedure p_ExecuteEcriture(const aF_Form: TCustomForm); virtual;
    procedure p_LectureColonnes(const aF_Form: TCustomForm); virtual;

    property AutoUpdate : Boolean read FAutoUpdate write FAutoUpdate default True;
    property AutoLoad   : Boolean read FAutoChargeIni write FAutoChargeIni default True;
  published
    // Propri�t� qui conserve la position des objets d'une form
    property SauvePosObjects: Boolean read FSauvePosObjet write FSauvePosObjet default False;
    // Propri�t� qui conserve les donn�es des objets d'une form
    property SauveEditObjets: TSauveEditObjets read FSauveEditObjets write FSauveEditObjets nodefault;
    // Propri�t� qui conserve la position(index) des objets PageControl (onglets)
    property SauvePosForm: Boolean read FSauvePosForm  write FSauvePosForm default False;
    property OnIniLoad  : TEventIni read FOnIniLoad write FOnIniLoad ;
    property OnIniWrite : TEventIni read FOnIniWrite write FOnIniWrite;
    procedure LaFormDestroy(Sender: TObject);
    procedure LaFormShow(Sender: TObject);
    procedure LaFormCreate(Sender: TObject);
  end;

implementation

uses TypInfo, Grids, U_ExtNumEdits,
{$IFDEF FPC}
     EditBtn,
{$ELSE}
{$IFDEF RX}
     rxToolEdit,
{$ENDIF}
{$ENDIF}
{$IFDEF VIRTUALTREES}
     VirtualTrees ,
{$ENDIF}
     unite_messages, fonctions_proprietes;

////////////////////////////////////////////////////////////////////////////////
// retourne le nom de la machine
////////////////////////////////////////////////////////////////////////////////
function FW_Read_Computer_Name : string;
begin
  Result := f_IniFWReadComputerName;
end;

////////////////////////////////////////////////////////////////////////////////
// Retourne le fichier INI
////////////////////////////////////////////////////////////////////////////////
function GetFileIni: string;
begin
  Result := ExtractFilePath(Application.ExeName) + CST_Avant_Fichier + FW_Read_Computer_Name + '.ini';
end;

////////////////////////////////////////////////////////////////////////////////
// permet de sauver dans un ini le contenu d'un m�mo, d'un Combobox, d'un ListBox, d'un RichEdit
// et d'un fa�on g�n�rale, le contenu des composants qui le stocke dans des TStrings
////////////////////////////////////////////////////////////////////////////////
procedure SauveTStringsDansIni(FIni:TIniFile; SectionIni:string; LeTStrings:TStrings; ItemIndex:integer);
var i: integer;
begin
  Fini.EraseSection(SectionIni); // on efface toute la section d�crite par SectionIni
  for i := 0 to LeTStrings.Count - 1 do // pour chaque ligne du Tstrings
  begin
    // on aura ainsi dans le fichier ini et dans la section consid�r� :
    // L0= suivi du contenu de la premi�re ligne du TStrings. puis L1= etc..
    FIni.WriteString(SectionIni, 'L' + IntToStr(i), LeTStrings[i]);// �crit dans le fichier ini
  end;
  FIni.WriteInteger(SectionIni, 'ItemIndex', ItemIndex);
end;


////////////////////////////////////////////////////////////////////////////////
// permet de lire le contenu d'un ini qui a �t� sauv� par SauveTStringsDansIni
////////////////////////////////////////////////////////////////////////////////
procedure LitTstringsDeIni(FIni: TIniFile; SectionIni: string; LeTStrings: TStrings; var ItemIndex: integer);
var i: integer;
begin
  ItemIndex := -1;
  if FIni.SectionExists(SectionIni) then
    begin
      LeTStrings.Clear;
      i := 0;
      while FIni.ValueExists(SectionIni, 'L' + IntToStr(i)) do
        begin
          LeTStrings.Add(FIni.ReadString(SectionIni, 'L' + IntToStr(i), ''));
          inc(i);
        end;
      ItemIndex := Fini.ReadInteger(SectionIni, 'ItemIndex', 0);
    end;
end;


////////////////////////////////////////////////////////////////////////////////
// Constructeur de l'objet TOnFormInfoIni
////////////////////////////////////////////////////////////////////////////////
Constructor TOnFormInfoIni.Create(AOwner:TComponent);
var lmet_MethodToAdd  : TMethod;
begin
  Inherited Create(AOwner);
  FAutoChargeIni := True;
  FAutoUpdate    := True;
  FSauvePosObjet := False;
  FSauvePosForm  := False;
  FOnIniLoad     := nil;
  FOnIniWrite    := nil;
  if not (csDesigning in ComponentState)  //si on est pas en mode conception
  and ( AOwner is TCustomForm ) then
    begin
      lmet_MethodToAdd.Data := Self;
      lmet_MethodToAdd.Code := MethodAddress('LaFormDestroy' );
      FormAOwner           := TCustomForm(AOwner);        // La forme propri�taire de notre composant
      FormOldDestroy       := TNotifyEvent ( fmet_getComponentMethodProperty ( FormAOwner, 'OnDestroy' )); // Sauvegarde de l'�v�nement OnDestroy
      p_SetComponentMethodProperty ( FormAOwner, 'OnDestroy', lmet_MethodToAdd );        // Idem pour OnDestroy
      FormOldCreate        := TNotifyEvent ( fmet_getComponentMethodProperty ( FormAOwner, 'OnCreate' ));  // Sauvegarde de l'�v�nement OnClose
      lmet_MethodToAdd.Code := MethodAddress('LaFormCreate' );
      p_SetComponentMethodProperty ( FormAOwner, 'OnCreate', lmet_MethodToAdd );         // Idem pour OnClose
      FormOldShow          := TNotifyEvent ( fmet_getComponentMethodProperty ( FormAOwner, 'OnShow' ));  // Sauvegarde de l'�v�nement OnShow
      lmet_MethodToAdd.Code := MethodAddress('LaFormShow' );
      p_SetComponentMethodProperty ( FormAOwner, 'OnShow', lmet_MethodToAdd );     // Idem pour OnShow
    End;
end;


////////////////////////////////////////////////////////////////////////////////
// Au chargement de l'objet TOnFormInfoIni, on lit les donn�es dans le fichier ini
////////////////////////////////////////////////////////////////////////////////
{procedure TOnFormInfoIni.loaded;
begin
  inherited;
  if not Assigned(FormAOwner) then
    Exit;
end;
}
////////////////////////////////////////////////////////////////////////////////
// � la fermeture de la form, on �crit les donn�es dans le fichier ini
////////////////////////////////////////////////////////////////////////////////
procedure TOnFormInfoIni.LaFormDestroy ( Sender: TObject );
begin
  if Assigned(FormAOwner)
   then
    p_ExecuteEcriture(FormAOwner);
  if Assigned(FormOldDestroy) then FormOldDestroy(Sender);
end;

////////////////////////////////////////////////////////////////////////////////
// � la fermeture de la form, on �crit les donn�es dans le fichier ini
////////////////////////////////////////////////////////////////////////////////
procedure TOnFormInfoIni.LaFormCreate ( Sender: TObject );
var
  Indice :integer;

begin
  FUpdateAll := False ;
  FAutoUpdate := True ;
  if Assigned(FormOldCreate) then FormOldCreate(Sender);
  f_GetMemIniFile;
  if Assigned(FInifile) then
    try
      Self.Updating ;
          // Traitement de la position de la af_Form
      if (TFormStyle ( flin_getComponentProperty ( FormAOwner, 'FormStyle' )) <> fsMDIChild) and (FSauvePosForm) then
        p_LecturePositionFenetre(FormAOwner);

    finally
      Self.Updated;
    end;
end;

procedure TOnFormInfoIni.LaFormShow(Sender: TObject);

begin
  try
    if Assigned(FormOldShow)
     then FormOldShow(Sender);
  Except

  end;
  if FAutoChargeIni then
    p_ExecuteLecture(TForm(Self.Owner));
end;


////////////////////////////////////////////////////////////////////////////////
// Fonction qui regarde dans la propri�t� TSauveEditObjets de TOnFormInfoIni
// et renvoie la valeur de sauvegarde d'un objet de la form
////////////////////////////////////////////////////////////////////////////////
function TOnFormInfoIni.GetfeSauveEdit(aSauveObjet:TSauveEditObjets;aObjet :TSauveEditObjet):Boolean;
begin
  Result := False;
  if aObjet in aSauveObjet then
    Result := True;
end;

////////////////////////////////////////////////////////////////////////////////
// Lecture des donn�es dans le fichier ini
////////////////////////////////////////////////////////////////////////////////
procedure TOnFormInfoIni.ExecuteLecture ( aLocal:Boolean);
var i: integer;
begin
  // automatisation
  if Assigned(FormAOwner)
   then
    if aLocal Then // Demande si la fiche a �t� ouverte
     Begin
       for i := 0 to Application.ComponentCount - 1 do //pour chaque fiche de l'application
         if ( Application.Components[i] is TForm )
         and (FormAOwner.Name = (TForm(Application.Components[i])).Name) then
           p_ExecuteLecture(TForm(Application.Components[i])); //fin pour chaque fiche de l'application
     End
    Else  p_ExecuteLecture(FormAOwner);
end;


////////////////////////////////////////////////////////////////////////////////
// Lecture des donn�es dans le fichier INI
////////////////////////////////////////////////////////////////////////////////
procedure TOnFormInfoIni.p_ExecuteLecture(const aF_Form: TCustomForm);
var
  mit: TMenuItem;
  j, Indice, Rien, valItemIndex, li_Taille : integer;
  ls_Temp : String ;
  ab_continue : Boolean;
  lcom_Component : Tcomponent ;

  function fli_ReadInteger (const as_ComponentName : String; const ali_Default : Longint ):Longint;
  Begin
    Result := FInifile.ReadInteger ( af_Form.Name, as_ComponentName, ali_Default );
  end;

  function fs_ReadString ( const as_ComponentName, as_Default : String ):String;
  Begin
    Result := FInifile.ReadString ( af_Form.Name, as_ComponentName, as_Default );
  end;
  function fb_ReadHighComponents: Boolean;
  Begin
    Result := False;
    if (lcom_Component is TDBGrid) and
       GetfeSauveEdit(FSauveEditObjets, feTGrid) then
      begin
        f_IniReadGridFromIni ( FInifile, aF_Form.Name, lcom_Component as TDBGrid );
        // No continue because other use of grid
      end;

    if (lcom_Component.ClassNameIs ( 'TBaseVirtualTree' ))
     and   GetfeSauveEdit(FSauveEditObjets, feTVirtualTrees) then
        begin
          {$IFDEF DELPHI}
          f_IniReadVirtualTreeFromIni ( FInifile, aF_Form.Name, lcom_Component as TBaseVirtualTree );
          {$ENDIF}
        // No continue because other use of tree
      end;

    if (lcom_Component is TCustomListView)
     and   GetfeSauveEdit(FSauveEditObjets, feTListView) then
        begin
          f_IniReadListViewFromIni ( FInifile, aF_Form.Name, lcom_Component as TCustomListView );
        // No continue because other use of listview
      end;

    // lecture de la position des objets Panels et Rxsplitters
    if (   (lcom_Component Is TPanel )
        or (lcom_Component is TCustomListView )
        {$IFDEF VIRTUALTREES}
        or (lcom_Component is TBaseVirtualTree  )
        {$ENDIF}
        or (lcom_Component is TCustomGrid ))
    and FSauvePosObjet then
      begin
        li_Taille := fli_ReadInteger ( lcom_Component.Name +'.Width', TControl (lcom_Component).Width);
        if li_Taille > 0 Then
          TControl(lcom_Component).Width := li_Taille ;
        li_Taille := fli_ReadInteger ( lcom_Component.Name +'.Height',TControl (lcom_Component).Height);
        if li_Taille > 0 Then
          TControl(lcom_Component).Height:= li_Taille ;
        Result := True;
      end;
  end;

  function fb_ReadOptions: Boolean;
  Begin
    Result := False;
    // lecture des CheckBoxes
    if (   (lcom_Component is TCheckBox)
        or (lcom_Component.ClassNameIs( 'TJvXPCheckbox' ))
        or (lcom_Component.ClassNameIs( 'TPCheck' )))
     and GetfeSauveEdit ( FSauveEditObjets, feTCheck ) then
      begin
        p_SetComponentBoolProperty(lcom_Component,'Checked', FInifile.ReadBool(af_Form.name,lcom_Component.Name,fb_getComponentBoolProperty(lcom_Component, 'Checked')));
        Result := True;
      end;
    // lecture des RadioBoutons
    if (lcom_Component is TRadioButton) and GetfeSauveEdit ( FSauveEditObjets, feTRadio ) then
      begin
        TRadioButton(lcom_Component).Checked:= FInifile.ReadBool(af_Form.name,lcom_Component.Name,true);
        Result := True;
      end;
    // lecture des groupes de RadioBoutons
    if (lcom_Component is TRadioGroup)  and GetfeSauveEdit ( FSauveEditObjets, feTRadioGroup ) then
      begin
        TRadioGroup(lcom_Component).ItemIndex:= fli_ReadInteger (lcom_Component.Name,0);
        Result := True;
      end;

  end;

  function fb_ReadEdits: Boolean;
  Begin
    Result := False;
    if (lcom_Component is TEdit) and GetfeSauveEdit(FSauveEditObjets ,feTedit) then
      begin
        ls_Temp := fs_ReadString(lcom_Component.Name,'');
        if ( ls_Temp <> '' ) Then
          TCustomEdit(lcom_Component).Text := ls_Temp ;
        Result := True;
      end;

    if GetfeSauveEdit(FSauveEditObjets ,feTDateEdit) Then
      if (lcom_Component is {$IFDEF FPC} TDateEdit {$ELSE} TJvCustomDateEdit {$ENDIF}) then
        Begin
          {$IFDEF FPC} TDateEdit {$ELSE} TJvCustomDateEdit {$ENDIF}(lcom_Component).Date := StrToDateTime(fs_ReadString(lcom_Component.Name,DateToStr(Date)));
          Result := True;
        End;

    if  GetfeSauveEdit(FSauveEditObjets ,feTEdit) Then
      if (lcom_Component is TExtNumEdit) then
        begin
          TExtNumEdit(lcom_Component).Text := fs_ReadString(lcom_Component.Name,' ');
          Result := True;
        end;

  end;
  function fb_ReadFiles: Boolean;
  Begin
    Result := False;
    if GetfeSauveEdit(FSauveEditObjets ,feTFileNameEdit) Then
      Begin
        {$IFDEF DELPHI}
      if (lcom_Component is  TJvFileNameEdit) then
        begin
          TJvFileNameEdit (lcom_Component).Text := fs_ReadString( lcom_Component.Name, GetCurrentDir);
          Result := True;
        end;
         {$ENDIF}
     {$IFDEF RX}
      if (lcom_Component is TFileNameEdit ) then
        begin
          TFileNameEdit (lcom_Component).Text := fs_ReadString( lcom_Component.Name, GetCurrentDir);
          Result := True;
        end;
        {$ENDIF}
      End ;

  end;

  function fb_ReadDirectories: Boolean;
  Begin
    Result := False;
    if GetfeSauveEdit(FSauveEditObjets ,feTDirectoryEdit) Then
      Begin
        if (lcom_Component.ClassNameIs('TJvDirectoryEdit')) then
          begin
            ls_Temp := fs_ReadString(lcom_Component.Name, GetCurrentDir );
            If DirectoryExists( ls_Temp ) Then
              p_SetComponentProperty (lcom_Component, 'Text', ls_temp )
             Else
              p_SetComponentProperty (lcom_Component, 'Text', GetCurrentDir );
            Result := True;
          end;
        if (lcom_Component is TDirectoryEdit) then
          begin
            ls_Temp := fs_ReadString(lcom_Component.Name, GetCurrentDir );
//            Showmessage ( lcom_Component.Name + ' '+ ls_Temp + ' ' +fs_ReadString(lcom_Component.Name, '' ) );
            If DirectoryExists( ls_Temp ) Then
              p_SetComponentProperty (lcom_Component, CST_INI_DIRECTORYEDIT_DIR, ls_Temp )
             Else
              p_SetComponentProperty (lcom_Component, CST_INI_DIRECTORYEDIT_DIR, GetCurrentDir );
            Result := True;
          end;
      End;

  end;

  function fb_ReadSpecialEdits: Boolean;
  Begin
    Result := False;
    {$IFDEF DELPHI}
    if GetfeSauveEdit(FSauveEditObjets ,feTDateTimePicker) Then
      if (lcom_Component is TDateTimePicker) then
        begin
          if fs_ReadString(lcom_Component.Name,'%�@�*�')<>'%�@�*�' then TDateTimePicker(lcom_Component).DateTime:=StrToDateTime( fs_ReadString(lcom_Component.Name,''));
          Result := True;
        end;
    {$ENDIF}
    if GetfeSauveEdit(FSauveEditObjets ,feTSpinEdit)
    and (   (lcom_Component.ClassNameIs( 'TSpinEdit'))
         or (lcom_Component.ClassNameIs( 'TRxSpinEdit')))
       then
        begin
          p_SetComponentProperty(lcom_Component, 'Value', fli_ReadInteger (lcom_Component.Name,flin_getComponentProperty(lcom_Component, 'Value')));
          Result := True;
        end;

  end;

  function fb_ReadMemos: Boolean;
  Begin
    Result := False;
    if (lcom_Component is TMemo) and GetfeSauveEdit(FSauveEditObjets ,feTMemo)        then
      begin
        LitTstringsDeIni(FInifile, lcom_Component.Name,TCustomMemo(lcom_Component).Lines,rien );
        Result := True;
      end;
    if {$IFDEF FPC}(lcom_Component.ClassNameIs('TRichView') or lcom_Component.ClassNameIs('TRichMemo') {$ELSE} (lcom_Component is  TCustomRichEdit {$ENDIF})
    and GetfeSauveEdit(FSauveEditObjets ,feTRichEdit)
    and ( fobj_getComponentObjectProperty(lcom_Component, 'Lines' ) <> nil)
     then
      begin
        LitTstringsDeIni(FInifile, lcom_Component.Name,fobj_getComponentObjectProperty(lcom_Component, 'Lines' ) as TStrings,rien);
        Result := True;
      end;
  end;

  function fb_ReadCombos: Boolean;
  Begin
    Result := False;
    if (lcom_Component is TCustomComboBox) and GetfeSauveEdit(FSauveEditObjets ,feTComboValue)
    and not assigned ( fobj_getComponentObjectProperty(lcom_Component,'Datasource'))
     then
      begin
          p_SetComponentProperty(lcom_Component, 'Text', fs_ReadString(lcom_Component.Name+'.Text',''));
      End;
    if (lcom_Component.CLassNameIs( 'TExtColorCombo')) and GetfeSauveEdit(FSauveEditObjets ,feTColorCombo)
     then
      begin
          p_SetComponentProperty(lcom_Component, 'Value', fs_ReadString(lcom_Component.Name+'.Value',''));
      End;
{$IFDEF RX}
    if GetfeSauveEdit(FSauveEditObjets ,feTComboValue)
    and (lcom_Component is {$IFDEF FPC}TRxCustomDBLookupCombo{$ELSE}TRxLookupControl{$ENDIF})
    and not assigned ( fobj_getComponentObjectProperty(lcom_Component,'Datasource'))
     Then
      begin
        {$IFNDEF FPC}
        if (lcom_Component is TRxDBLookupList ) Then
          (lcom_Component as TRxDBLookupList).DisplayValue := fs_ReadString(lcom_Component.Name + '.Value', '')
         else
         {$ENDIF}
          if (lcom_Component is TRxDBLookupCombo ) Then
          {$IFDEF FPC}
            (lcom_Component as TRxDBLookupCombo).LookupDisplayIndex := fli_ReadInteger (lcom_Component.Name + '.Index', -1);
          {$ELSE}
           (lcom_Component as TRxDBLookupCombo).DisplayValue := fs_ReadString(lcom_Component.Name + '.Index', '');
           {$ENDIF}
      End;
{$ENDIF}
    if (lcom_Component is TCustomComboBox) and GetfeSauveEdit(FSauveEditObjets ,feTComboBox)    then
      begin
        valItemIndex := -1 ;
        LitTstringsDeIni(FInifile, lcom_Component.Name,TCustomComboBox(lcom_Component).Items,valItemIndex);
        if  ( valItemIndex>=0)
        and ( valItemIndex<=TCustomComboBox(lcom_Component).Items.Count-1)
         then
          TCustomComboBox(lcom_Component).ItemIndex:=valItemIndex;
        Result := True;
      end;
  end;

  function fb_ReadListBoxes: Boolean;
  Begin
    Result := False;
    if (lcom_Component is TListBox) and GetfeSauveEdit(FSauveEditObjets ,feTListBox)     then
      begin
        LitTstringsDeIni(FInifile, lcom_Component.Name,TCustomListBox(lcom_Component).Items,valItemIndex);
        if valItemIndex<=TCustomListBox(lcom_Component).Items.Count-1 then TCustomListBox(lcom_Component).ItemIndex:=valItemIndex;
          Result := True;
      end;

  end;

  function fb_ReadInteractivityComponents: Boolean;
  var k : Longint;
  Begin
    Result := False;
    // lecture de la page de contr�le(onglets)
    if ((lcom_Component is TPageControl)) and GetfeSauveEdit ( FSauveEditObjets, feTPageControl )   then
      begin
        TPageControl(lcom_Component).ActivePageIndex := fli_ReadInteger ( lcom_Component.Name , 0);
        Result := True;
      end;
    // lecture de PopupMenu
    if (lcom_Component is TPopupMenu) and GetfeSauveEdit ( FSauveEditObjets, feTPopup )  then
      begin
        mit := TMenu(lcom_Component).Items;
        for k := 0 to mit.Count-1 do
          begin
            if mit.Items[k].RadioItem then
              mit.Items[k].Checked := FInifile.ReadBool (af_Form.Name, lcom_Component.Name+'_'+mit.Items[k].Name,true)
            else
              mit.Items[k].Checked := FInifile.ReadBool (af_Form.Name, lcom_Component.Name+'_'+mit.Items[k].Name,False);
          end;
        Result := True;
      end;

  end;

begin
  FAutoChargeIni := False;
  Rien := 0;
  f_GetMemIniFile;
 {$IFDEF FPC}
    if FSauvePosObjet
    and ( Owner is TCustomForm ) Then
      Begin
        ( Owner as TCustomForm ).BeginUpdateBounds;
      End;
 {$ENDIF}
  if Assigned(FInifile) then
    try
      ab_continue := True;

      Self.Updating;

      If Assigned ( FOnIniLoad ) Then
        FOnIniLoad ( FInifile, ab_continue );

      // traitement des composants de la af_Form
      if ab_continue Then
        for j := 0 to af_Form.ComponentCount - 1 do
          begin
            try
              lcom_Component := aF_Form.Components[j];

              if fb_ReadHighComponents Then
                continue;
              if FSauveEditObjets <> [] Then
                Begin
                  if fb_ReadOptions  Then
                    continue;

                  if fb_ReadEdits Then
                    Continue;

                  if fb_ReadSpecialEdits  Then
                    Continue;

                  if fb_ReadFiles Then
                    Continue;

                  if fb_ReadDirectories  Then
                    Continue;

                  if fb_ReadCombos  Then
                    Continue;

                  if fb_ReadListBoxes Then
                    Continue;

                  if fb_ReadInteractivityComponents Then
                    Continue;
                  if fb_ReadMemos Then
                    Continue;

                end;
            except
            end;
        end
      Else
       ab_continue := False;

    finally

   {$IFDEF FPC}
      if ab_continue Then
        Begin
          if FSauvePosObjet
          and ( Owner is TCustomForm ) Then
            ( Owner as TCustomForm ).EndUpdateBounds;
        end;
   {$ENDIF}
      Self.Updated;
    end;
end;

////////////////////////////////////////////////////////////////////////////////
// Ecriture des donn�es dans le fichier ini
////////////////////////////////////////////////////////////////////////////////
procedure TOnFormInfoIni.ExecuteEcriture(aLocal:Boolean);
var i : Integer ;
    ab_continue : Boolean ;

begin

  if not assigned ( FormAOwner )
   Then
    Exit ;
  FUpdateAll := True ;
  ab_continue := True;
  f_GetMemIniFile;
  If Assigned ( FOnIniWrite ) Then
    FOnIniWrite ( FInifile, ab_continue );
  if ab_continue Then
    try
      For i:=0 to application.ComponentCount-1 do //pour chaque af_Form de l'application
      begin
        if ( application.Components[i] is TCustomForm )
        and ((FormAOwner.Name = ( TForm ( application.Components[i] )).Name) and aLocal) or (Not aLocal)
         Then
          p_ExecuteEcriture ( TCustomForm ( application.Components[i] ));
      end; //fin pour chaque af_Form de l'application
    finally
      FUpdateAll := False ;

      if FAutoUpdate Then
        Begin
          fb_iniWriteFile ( FInifile, False );
          Application.ProcessMessages ;

        End ;
    End ;
end;

////////////////////////////////////////////////////////////////////////////////
// Ecriture des donn�es dans le fichier INI
////////////////////////////////////////////////////////////////////////////////
procedure TOnFormInfoIni.p_ExecuteEcriture ( const af_Form : TCustomForm ) ;
var
  mit: TMenuItem;
  j, Indice: integer;
//  lvt_EnteteArbre : TVTHeader ;
//  lgd_grid: TDBGrid;
//  lsv_ListView : TListView ;
  lcom_Component : TComponent;
  procedure p_WriteString ( const as_ComponentName, as_Value : String );
  Begin
    FInifile.WriteString ( af_Form.Name, as_ComponentName, as_Value );
  End;

  procedure p_WriteInteger ( const as_ComponentName : String; const ai_Value : Longint );
  Begin
    FInifile.WriteInteger ( af_Form.Name, as_ComponentName, ai_Value );
  End;

  function fb_WriteHighComponents : Boolean;
  Begin
    Result := False;
    if (lcom_Component is TDBGrid) and
       GetfeSauveEdit(FSauveEditObjets, feTGrid) then
      begin
        p_IniWriteGridToIni ( FInifile, af_Form.Name, lcom_Component as TDBGrid );
      end;

        if (lcom_Component.ClassNameIs ( 'TBaseVirtualTree' ))
         and   GetfeSauveEdit(FSauveEditObjets, feTVirtualTrees) then
          begin
            {$IFDEF DELPHI}
            p_IniWriteVirtualTreeToIni ( FInifile, af_Form.Name, lcom_Component as TBaseVirtualTree );
            {$ENDIF}
          end;

        if (lcom_Component is TListView)
         and   GetfeSauveEdit(FSauveEditObjets, feTListView) then
          begin
            p_IniWriteListViewToIni ( FInifile, af_Form.Name, lcom_Component as TListView );
          end;

    // �criture des positions des objets Panels et RxSplitters
    if FSauvePosObjet then
    begin
      if      (lcom_Component is TPanel)
      or (lcom_Component.ClassNameIs ( 'TBaseVirtualTree' ))
      or (lcom_Component is TCustomGrid)
      or (lcom_Component is TCustomListView) Then
       begin
        if TControl(lcom_Component).Width  > 0 Then
          p_WriteInteger(lcom_Component.Name+'.Width',TControl(lcom_Component).Width);
        if TControl(lcom_Component).Height > 0 Then
          p_WriteInteger(lcom_Component.Name+'.Height',TControl(lcom_Component).Height);
        Result := True;
      end;
    end;
  end;
  function fb_WriteEdits : Boolean;
  Begin
    Result := False;
    if (lcom_Component is TEdit)           and GetfeSauveEdit(FSauveEditObjets ,feTEdit) then
      begin
        p_WriteString(lcom_Component.Name,TCustomEdit(lcom_Component).Text);
        Result := True;
      end;
    if (lcom_Component is TExtNumEdit)   and GetfeSauveEdit(FSauveEditObjets ,feTCurrencyEdit) then
      begin
        p_WriteString(lcom_Component.Name,TExtNumEdit(lcom_Component).Text);
        Result := True;
      end;
    if (lcom_Component is {$IFDEF FPC} TDateEdit {$ELSE} TJvCustomDateEdit {$ENDIF})       and GetfeSauveEdit(FSauveEditObjets ,feTDateEdit) then
      begin
        p_WriteString(lcom_Component.Name,DateTimeToStr({$IFDEF FPC} TDateEdit {$ELSE} TJvCustomDateEdit {$ENDIF}(lcom_Component).Date));
        Result := True;
      end;
  end;
  function fb_WriteSpecialEdits : Boolean;
  Begin
    Result := False;
    if GetfeSauveEdit(FSauveEditObjets ,feTSpinEdit)
    and  (   (lcom_Component.ClassNameIs( 'TSpinEdit'))
          or (lcom_Component.ClassNameIs( 'TRxSpinEdit')))
     then
      begin
        p_WriteInteger(lcom_Component.Name,flin_getComponentProperty(lcom_Component, 'Value' ));
        Result := True;
      end;

  end;

  function fb_WriteOptions : Boolean;
  Begin
    Result := False;
    if ((lcom_Component is TCheckBox)
    or (lcom_Component.ClassNameIs( 'TJvXPCheckbox' ))
    or (lcom_Component.ClassNameIs( 'TPCheck' )))
    and GetfeSauveEdit(FSauveEditObjets, feTCheck )
     then
      begin
        FInifile.WriteBool(af_Form.name,lcom_Component.Name,fb_getComponentBoolProperty ( lcom_Component, 'Checked' ));
        Result := True;
      end;
    if (lcom_Component is TRadioButton)    and GetfeSauveEdit(FSauveEditObjets, feTRadio )      then
      begin
        FInifile.WriteBool(af_Form.name,lcom_Component.Name,TRadioButton(lcom_Component).Checked);
        Result := True;
      end;
    if (lcom_Component is TRadioGroup)     and GetfeSauveEdit(FSauveEditObjets, feTRadioGroup )       then
      begin
        p_WriteInteger(lcom_Component.Name,TRadioGroup(lcom_Component).ItemIndex);
        Result := True;
      end;

  end;

  function fb_WriteDirectories : Boolean;
  Begin
    Result := False;
    if GetfeSauveEdit(FSauveEditObjets ,feTDirectoryEdit) then
      begin
        if (lcom_Component.ClassNameIs('TJvDirectoryEdit')) then
          Begin
            p_WriteString(lcom_Component.Name,fs_getComponentProperty(lcom_Component, 'Text'));
            Result := True;
          End;
        if (lcom_Component is TDirectoryEdit) then
          begin
            p_WriteString(lcom_Component.Name,fs_getComponentProperty(lcom_Component, CST_INI_DIRECTORYEDIT_DIR ));
            Result := True;
          end;
      end;

  end;

  function fb_WriteFiles : Boolean;
  Begin
    Result := False;
    if GetfeSauveEdit(FSauveEditObjets ,feTFileNameEdit) Then
      Begin
      {$IFDEF DELPHI}
        If (lcom_Component is TJvFileNameEdit) then
          begin
            p_WriteString(lcom_Component.Name,TJvFileNameEdit(lcom_Component).Text);
            Result := True;
          end;
       {$ENDIF}
      {$IFDEF RX}
        If (lcom_Component is TFileNameEdit) then
          begin
            p_WriteString(lcom_Component.Name,TFileNameEdit(lcom_Component).Text);
            Result := True;
          end;
       {$ENDIF}
      End ;

  end;

  function fb_WriteMemos : Boolean;
  Begin
    Result := False;
    if (lcom_Component is TMemo)           and GetfeSauveEdit(FSauveEditObjets ,feTMemo)            then
      begin
        SauveTStringsDansIni(FInifile, lcom_Component.Name,TMemo(lcom_Component).Lines,0);
        Result := True;
      end;
    if {$IFDEF FPC}(lcom_Component.ClassNameIs('TRichView') or lcom_Component.ClassNameIs('TRichMemo') {$ELSE} (lcom_Component is  TCustomRichEdit {$ENDIF})
    and GetfeSauveEdit(FSauveEditObjets ,feTRichEdit)
    and ( fobj_getComponentObjectProperty(lcom_Component, 'Lines' ) <> nil)
     then
      begin
        SauveTStringsDansIni(FInifile, lcom_Component.Name,fobj_getComponentObjectProperty(lcom_Component, 'Lines' ) as TStrings,0);
        Result := True;
      end;

  end;

  function fb_WriteCombos : Boolean;
  Begin
    Result := False;
    if (lcom_Component.CLassNameIs( 'TExtColorCombo')) and GetfeSauveEdit(FSauveEditObjets ,feTColorCombo)
     then
      begin
          p_WriteInteger(lcom_Component.Name+ '.Value', Flin_getComponentProperty (lcom_Component, 'Value'));
          // No continue : Maybe a customcombo
      End;
    if (lcom_Component is TCustomComboBox) and GetfeSauveEdit(FSauveEditObjets ,feTComboValue)
    and not assigned ( fobj_getComponentObjectProperty(lcom_Component,'Datasource'))
     Then
      begin
        p_WriteString(lcom_Component.Name+'.Text',fs_getComponentProperty(lcom_Component, 'Text'));
          // No continue : Maybe a customcombo
      End;
  {$IFDEF RX}
    if GetfeSauveEdit(FSauveEditObjets ,feTComboValue)
    and (lcom_Component is {$IFDEF FPC}TRxCustomDBLookupCombo{$ELSE}TRxLookupControl{$ENDIF})
    and not assigned ( fobj_getComponentObjectProperty(lcom_Component,'Datasource'))
     then
      begin
       {$IFNDEF FPC}
        if (lcom_Component is TRxDBLookupList) Then
          p_WriteString(lcom_Component.Name + '.Value', (lcom_Component as TRxDBLookupList).DisplayValue)
         else
        {$ENDIF}
          if (lcom_Component is TRxDBLookupCombo) Then
          {$IFDEF FPC}
            p_WriteInteger(lcom_Component.Name + '.Index', (lcom_Component as TRxDBLookupCombo).LookupDisplayIndex);
          {$ELSE}
            p_WriteString(lcom_Component.Name + '.Value', (lcom_Component as TRxDBLookupCombo).DisplayValue);
           {$ENDIF}
          // No continue : Maybe a customcombo
      End;
  {$ENDIF}
    if (lcom_Component is TCustomComboBox)       and GetfeSauveEdit(FSauveEditObjets ,feTComboBox)        then
      begin
        SauveTStringsDansIni(FInifile, lcom_Component.Name,TCustomComboBox(lcom_Component).Items,TCustomComboBox(lcom_Component).ItemIndex);
        Result := True;
      end;

  end;

  function fb_WriteInteractivityComponents : Boolean;
  var k : Cardinal;
  Begin
    Result := False;
    // �criture de la position des colonnes des grilles
    // Ecriture de la page de contr�le(onglets)
    if (lcom_Component is TPageControl)     and GetfeSauveEdit(FSauveEditObjets, feTPageControl )   then
      begin
        p_WriteInteger(lcom_Component.Name,TPageControl(lcom_Component).ActivePageIndex );
        Result := True;
      end;
    // Ecriture de PopupMenu
    if (lcom_Component is TPopupMenu )     and GetfeSauveEdit(FSauveEditObjets, feTPopup )  then
      begin
        mit := TMenu(lcom_Component).Items;
        for k := 0 to mit.Count-1 do
          begin
            FInifile.WriteBool (af_Form.Name, lcom_Component.Name+'_'+mit.Items[k].Name , mit.Items[k].Checked);
          end;
        Result := True;
      end;
  End;

  function fb_WriteListBoxes : Boolean;
  Begin
    Result := False;
    if (lcom_Component is TListBox)        and GetfeSauveEdit(FSauveEditObjets ,feTListBox)         then
      begin
        SauveTStringsDansIni(FInifile, lcom_Component.Name,TCustomListBox(lcom_Component).Items,TListBox(lcom_Component).ItemIndex);
        Result := True;
      end;
  {$IFDEF DELPHI}
    if (lcom_Component is TDateTimePicker) and GetfeSauveEdit(FSauveEditObjets ,feTDateTimePicker)  then
      begin
        p_WriteString(lcom_Component.Name,DateTimeToStr(TDateTimePicker(lcom_Component).DateTime));
        Result := True;
      end;
  {$ENDIF}

  End;

begin
  f_GetMemIniFile();
  if not Assigned(FInifile) then Exit;

      // traitement de la position de la af_Form
  if (TFormStyle ( flin_getComponentProperty ( af_Form, 'FormStyle' )) <> fsMDIChild) and (FSauvePosForm)  then
    p_EcriturePositionFenetre(af_Form);

      // Traitement des composants de la af_Form
  For j:=0 to af_Form.ComponentCount-1 do
    begin
      lcom_Component := af_Form.Components[j];
      Try
        if fb_WriteHighComponents Then
          Continue;

        // �criture des donn�es des objets dans le fichier ini.
        if FSauveEditObjets <> [] Then
        begin
          if fb_WriteEdits Then
            Continue;
          if fb_WriteSpecialEdits Then
            Continue;
          if fb_WriteOptions Then
            Continue;
          if fb_WriteDirectories Then
            Continue;
          if fb_WriteFiles Then
            Continue;
          if fb_WriteMemos Then
            Continue;
          if fb_WriteCombos Then
            continue ;
          if fb_WriteListBoxes Then
            Continue;
          if fb_WriteInteractivityComponents Then
            Continue;
        end;
        Except
        end;
      end;
  if not FUpdateAll
  and FAutoUpdate Then
    Begin
      fb_iniWriteFile ( FInifile, False );
    End;

end;

////////////////////////////////////////////////////////////////////////////////
//  Lecture de la position des colonnes des grilles dans le fichier INI
////////////////////////////////////////////////////////////////////////////////
procedure TOnFormInfoIni.p_LectureColonnes(const aF_Form: TCustomForm);

begin
end;


////////////////////////////////////////////////////////////////////////////////
// Lecture des donn�es dans le fichier INI concernant la fen�tre uniquement
// traitement de la position de la af_Form mise dans le create
////////////////////////////////////////////////////////////////////////////////
procedure TOnFormInfoIni.p_LecturePositionFenetre(aFiche: TCustomForm);
var li_etat, li_ScreenHeight, li_ScreenWidth: integer;
begin
  // R�solution de l'�cran
  li_ScreenHeight := f_IniReadSectionInt (aFiche.Name,'Screen.Height',Screen.Height);
  li_ScreenWidth := f_IniReadSectionInt (aFiche.Name,'Screen.Width',Screen.Width);

  li_etat := f_IniReadSectionInt (aFiche.Name,aFiche.name+'.WindowState',0);
  // positionnement de la fen�tre
  p_SetComponentProperty ( aFiche, 'Position', poDesigned );
  if li_etat = 0 then
    aFiche.WindowState := wsNormal
  else
    if li_etat = 1 then
    begin
      p_SetComponentProperty ( aFiche, 'Position', poDefault );
      p_SetComponentProperty ( aFiche, 'WindowState', wsMaximized );
      end
    else
      p_SetComponentProperty ( aFiche, 'WindowState', wsMinimized );

  if li_etat <> 1 then
  begin
    aFiche.Width := f_IniReadSectionInt (aFiche.Name,aFiche.name+'.Width',aFiche.Width) ;
    aFiche.Height:= f_IniReadSectionInt (aFiche.Name,aFiche.name+'.Height',aFiche.Height);
    aFiche.Top   := f_IniReadSectionInt (aFiche.Name,aFiche.name+'.Top',aFiche.Top);
    aFiche.Left  := f_IniReadSectionInt (aFiche.Name,aFiche.name+'.Left',aFiche.Left);

    if Screen.Height <> li_ScreenHeight then
    begin
      aFiche.Width := Round(aFiche.Width * Screen.Width / li_ScreenWidth)  ;
      aFiche.Height:= Round(aFiche.Height * Screen.Height/li_ScreenHeight) ;
      aFiche.Top   := Round(aFiche.Top * Screen.Height/li_ScreenHeight) ;
      aFiche.Left  := Round(aFiche.Left * Screen.Width/li_ScreenWidth);
    end;

  end;
end;

////////////////////////////////////////////////////////////////////////////////
// Ecriture des donn�es dans le fichier ini concernant la fen�tre
////////////////////////////////////////////////////////////////////////////////
procedure TOnFormInfoIni.p_EcriturePositionFenetre ( const aFiche: TCustomForm);
var li_etat: integer;
begin
  p_IniWriteSectionInt(aFiche.Name,'Screen.Height',Screen.Height);
  p_IniWriteSectionInt(aFiche.Name,'Screen.Width',Screen.Width);

  // Etat de la fen�tre
  if aFiche.WindowState = wsNormal then
    li_etat := 0
  else
    if aFiche.WindowState = wsMaximized then
      li_etat := 1
    else
      li_etat := 2;
  // sauvegarde de son �tat
  p_IniWriteSectionInt(aFiche.Name,aFiche.name+'.WindowState',li_etat);

  // sauvegarde de sa position si la fen�tre n'est pas au Maximun
  if li_etat <> 1 then
    begin
      p_IniWriteSectionInt (aFiche.Name,aFiche.name+'.Width',aFiche.Width);
      p_IniWriteSectionInt (aFiche.Name,aFiche.name+'.Height',aFiche.Height);
      p_IniWriteSectionInt (aFiche.Name,aFiche.name+'.Top',aFiche.Top);
      p_IniWriteSectionInt (aFiche.Name,aFiche.name+'.Left',aFiche.Left);
    end;
end;

{$IFDEF VERSIONS}
initialization
  p_ConcatVersion ( gVer_TSvgFormInfoIni );
{$ENDIF}
end.
