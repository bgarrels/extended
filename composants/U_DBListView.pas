{*********************************************************************}
{                                                                     }
{                                                                     }
{             Matthieu Giroux                                         }
{             TDBListView  :                                          }
{             Composant liste avec chargements it�ratifs des donn�es  }
{             22 D�cembre 2006                                        }
{                                                                     }
{                                                                     }
{*********************************************************************}

{$I ..\Compilers.inc}
{$I ..\extends.inc}

unit U_DBListView;

{$IFDEF FPC}
{$mode Delphi}
{$ELSE}
{$R *.Res}
{$ENDIF}

interface
// Datasource : Le Datasource � afficher dans la liste avec un param�tre dans le query
// cr�� par Matthieu Giroux en Mars 2004

// 29-9-2004 : abandon compl�t� dans la gestion panier


uses
{$IFDEF FPC}
   LCLIntf, LCLType, lmessages, SQLDB, RxLookup, lresources,
{$ELSE}
  Windows, DBTables, JvListView,
{$ENDIF}
   Messages, SysUtils, Classes, Graphics, Controls,
   Forms, Dialogs, Db, StdCtrls,
{$IFDEF EADO}
   ADODB,
{$ENDIF}
{$IFDEF DBEXPRESS}
   SQLExpr,
{$ENDIF}
{$IFDEF DELPHI_9_UP}
   WideStrings ,
{$ENDIF}
{$IFDEF VERSIONS}
   fonctions_version,
{$ENDIF}
   SyncObjs,
   ComCtrls, fonctions_variant;

{$IFDEF VERSIONS}
const
    gVer_TDBListView : T_Version = ( Component : 'Composant TDBListView' ;
                                               FileUnit : 'U_GroupView' ;
                                               Owner : 'Matthieu Giroux' ;
                                               Comment : 'Liste chargeable au fur et � mesure.' ;
                                               BugsStory : '1.0.0.0 : Chargement automatique OK.';
                                               UnitType : 3 ;
                                               Major : 1 ; Minor : 0 ; Release : 0 ; Build : 0 );


{$ENDIF}
type
  TSortOrder = (soAscending,soDescending);
  EListScrollEvent = procedure ( const Sender: TObject; const Dataset : TDataset; var LoadList : Boolean ) of object;
  ESortStartEvent = procedure( const Sender: TObject; const Column: Integer; var Enable: Boolean) of object;
// Premi�re d�claration
  TDBListView = class ;

  // Lien de donn�es et gestion des �v�nements de mise � jour
  TUltimListViewDatalink = Class(TDataLink)
   Private
    // Parent propri�taire des �v�nements li�s au lien de donn�es
    glst_View: TDBListView;
   Public
    Constructor Create( alsv_List : TDBListView); Virtual;
   Protected
    Procedure ActiveChanged; Override;
    Procedure DataSetChanged; Override;
    Procedure EditingChanged; Override;
   public
    procedure p_SetListNil ;
    property DBListView : TDBListView read glst_View ;
   End;

   // Gestion de dblist � chargements interm�diaires

  { TDBListView }

  TDBListView = class({$IFDEF FPC} TListView {$ELSE} TJvListView {$ENDIF} )
   private
    {$IFDEF EADO}
    ge_OldFetchComplete : TRecordsetEvent ;
    ge_WaitForFetch : TEvent ;
    ge_OldFetchProgress : TfetchProgressEvent ;
    {$ENDIF}
    // Tout a �t� charg� ? : A-t-on atteint la fin du dataset
    ge_BeforeScroll : EListScrollEvent;
    ge_AfterScroll  : TDatasetNotifyEvent;
    FSortColumn : Integer;
    FSortOrder  : TSortOrder;

    //Mode asynchrone
    gb_fetched : Boolean ;
    gi_Fetch,
    gi_FetchTotal : Integer ;
    // Images du composant
    {$IFNDEF FPC}
    ResInstance : THandle;
    {$ENDIF}
    // Premi�re fois que l'on ouvre le TDBListView
    gb_HasLoaded  : Boolean;
    // R�cup�re le datasource li�
    function fds_GetDatasource : TdataSource;
    // Gestion automatique du scrolling quand la liste n'est pas charg�e
    procedure p_scrolling ;
    // Gestion automatique du scrolling
    // Message : informations sur le d�placement en cours
    procedure WMVScroll(var Message: TWMVScroll); message WM_VSCROLL;
    // Gestion automatique du scrolling
    // Message : informations sur le d�placement en cours
    procedure WMMouseWheel(var Message: {$IFDEF FPC}TLMMouseEvent{$ELSE}TWMMouseWheel{$ENDIF}); message {$IFDEF FPC}LM_MOUSEWHEEL{$ELSE}WM_MOUSEWHEEL{$ENDIF};

    // Surcharge de l'�v�nement OnCustomDrawItem
    // �v�nement de dessin des items
    // Peint les couleurs de lignes vers l'unit� mc_fonctions_groupes
    // aclv_Liste : La liste de l'�v�nement
    // alit_Item  : L'item � peindre
    // acds_Etat  : Obligtoire pour l'�v�nement
    // ab_Defaut  : Obligtoire pour l'�v�nement
    procedure p_PaintFondItem ( aclv_Liste : TCustomListView ; alit_Item : TListItem ; acds_Etat : TCustomDrawState ; var ab_Defaut : Boolean );
    //function fb_ParentVisible(const awco_Control: TWinControl): Boolean;
    procedure p_LibereCleDatasource;
    procedure p_LibereChampsListe;
    //Affectation de DataFieldsDisplay
    procedure p_SetChampsListe ( const Value: String );
    //    procedure p_DatasourceOnOpen(Dataset: Tdataset);
   protected
    // On a transf�r� tous les items
    gsts_ChampsListe : TStringList ;
    gb_AllLoaded ,
    gb_AllFetched : Boolean ;
    gb_CaseInSensitive,
    gb_LoadList   ,
    // Mode tout s�lectionn�
    gb_AllSelect    : Boolean ;
    // Le num�ro de la colonne de la cl� dans la liste
    gt_ColonneCle    : Array of Integer ;
    // Surcharge de l'�v�nement OnCustomDrawItem
    gdip_OldOnDrawItemProp : TLVCustomDrawItemEvent ;
   ///////////
  // Cl�s  //
   ///////////
  // Cl� primaire du datasource
    gstl_CleDataSource : TStringlist ;
  // Panier : Liste des cl�s o� on a mis des unit�s dans le panier
//    lstl_KeysListOut      ,
//    lt_CleOrigine2        ,
    gt_CleOrigine         : tt_TableauVarOption ;
    // Pour plus tard : � laisser
    gvar_CleOrigineEnCours,
    //
    gvar_CleDestination : Variant ;
    // Lien de donn�es avec mise � jour automatique
    gdl_DataLink : TUltimListViewDatalink ;
    // Item en cours
    gVG_ListItem       ,
    // Items s�lectionn�s
    gVG_items_selected : TListItem ;
    // Sauvegarde de l'ancienne couleur
    gcol_AncienneCouleur   : TColor ;
    // Cl� primaire de la table des unit�s
    gs_CleUnite     ,
    // Champs des sous-�l�ments ( colonne 1 � N )
    // Table de datasource pour la mise � jour
    gs_TableSource   : {$IFDEF FPC} AnsiString{$ELSE}String{$ENDIF};
    gs_ChampsListe : String;
    // Propri�t� Montre Tous les enregistrements : Annule l'utilit� du composant
    gb_MontreTout    ,
//    lb_DevalideInsert,
  // Propri�t� Couleurs de lignes automatiques
    gb_CouleursLignes: Boolean;
    procedure p_setSortOrder ( AValue : TSortOrder ); virtual;
    function fs_SortDataset(const adat_Dataset: TDataSet): String; virtual;
    procedure p_setSortColumn(AValue: Integer); virtual;
    procedure p_SetClePrimaireListe(const a_Value: {$IFDEF FPC} AnsiString{$ELSE}String{$ENDIF});
    procedure p_CreeListeChampsDisplay ( as_ChampsListe : String ); virtual;
    procedure p_AffecteEvenementsDatasource; virtual;
    procedure EditingChanged; virtual;
    // Affectation du composant dans la propri�t� DataSource
    // test si n'existe pas
    // Mise � jour du nom de table
    // a_Value : Le datasource
    function GetNextItem(const StartItem: TListItem; const States: {$IFDEF FPC}TListItemStates{$ELSE} TItemStates{$ENDIF}): TListItem; virtual;
    procedure p_SetDataSourceGroup ( const a_Value: TDataSource ); virtual;
    function fs_PrepareTri: String; virtual;
    {$IFDEF EADO}
    procedure p_RefreshLoaded(DataSet: TCustomADODataSet; const Error: Error;
      var EventStatus: TEventStatus); virtual;
    procedure p_FetchProgressLoaded(DataSet: TCustomADODataSet; ProGress,
      MaxProgress: Integer; var EventStatus: TEventStatus); virtual;
    procedure p_SetFetchLoaded; virtual;

    procedure p_SetUnFetch; virtual;
      {$ENDIF}
    Procedure p_DataSetChanged; virtual;
    function  fb_ScrollBarVisible(Code: Word): Boolean;
    procedure Resize; override;
    procedure p_MajBoutons ( const ai_ItemsAjoutes : Integer ); virtual;
    procedure p_ReinitialisePasTout; dynamic;
    function  fb_PeutTrier  : Boolean ; dynamic;
    function  fb_PrepareTri ( const ai_column : Integer ) : Boolean;
    function  fb_PeutAjouter  ( const adat_Dataset : TDataset ; const ab_AjouteItemPlus : Boolean)  : Boolean ; virtual;
    function  fb_ChangeEtatItem  ( const adat_Dataset : TDataset  ; const ab_AjouteItemPlus : Boolean )  : Boolean ; virtual;
    function  fb_RemplitEnregistrements ( const adat_Dataset : TDataset ; const ab_InsereCles : Boolean ) : Boolean; dynamic;
    function  fb_RemplitListe : Boolean ; virtual;
    procedure Loaded; override;
    {$IFDEF DELPHI}
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    {$ENDIF}
    Procedure DataLinkActiveChanged; virtual;
    procedure DoEnter ; override;
    procedure DoExit ; override;
    procedure p_AssignColonnesSubitems;
    procedure p_AssignSort ( const as_ChampsOrdonner : String ) ; virtual;
    property HasLoad:Boolean read gb_HasLoaded ;
   public
    // Bookmark pour le chargement interm�diaire
    gbm_DernierEnregistrement : TBookmarkStr ;
    {$IFDEF FPC}
    procedure SelectAll ; dynamic;
    {$ENDIF}
    procedure p_LoadListView ; virtual;
    procedure p_UpdateListView ; virtual;
    procedure p_LibereBookmark ; virtual;
    // Met � jour le composant
    procedure p_MetAjour; virtual;
    Function  fb_FetchIsLoaded : Boolean ; virtual;
    procedure p_SetSortDirectionAsc(const ab_Ascendant: Boolean);
    constructor Create ( acom_owner : TComponent ); override;
    destructor Destroy ; override;
    Procedure p_AjouteEnregistrements ; dynamic;
    Procedure p_AjouteEnregistrementsSynchrones; dynamic;
    procedure p_Reinitialise ; dynamic;
    function  fi_FindItem ( const avar_TexteItem : Variant ) : Integer ; overload;
    procedure ColClick( alsc_colonne : TListColumn ); override;
    procedure Refresh ;
    property ListLoaded : Boolean read gb_AllLoaded ;
    property AllSelect  : Boolean read gb_AllSelect ;
     {$IFDEF EADO}
    // Mode asynchrone
    property FetchedAll : Boolean read gb_AllFetched ;
    property Fetched    : Boolean read gb_Fetched ;
    property FetchCount : Integer read gi_Fetch ;
    property FetchTotal : Integer read gi_FetchTotal ;
    property FetchEvent : TEvent  read ge_WaitForFetch ;
    {$ENDIF}
   published
    // Datasource principal �dit�
    property Datasource : TDataSource read fds_GetDatasource write p_SetDataSourceGroup;
    // cl� du query
    // du Datasource des groupes �dit�s
    property DataKeyUnit : {$IFDEF FPC}AnsiString {$ELSE}string{$ENDIF} read gs_CleUnite write p_SetClePrimaireListe;
    // Champs suppl�mentaires affich�s
    property DataFieldsDisplay : String read gs_ChampsListe write p_SetChampsListe;
    // la liste utilise-t-elle les couleurs de lecture ?
    property DataRowColors : Boolean read gb_CouleursLignes write gb_CouleursLignes default True;
    // La liste est-elle charg�e en entier
    property DataShowAll : Boolean read gb_MontreTout write gb_MontreTout default False;
    // Nombre de pages � charger
    //    property DataLoadPages : Word read lw_NombrePages write p_SetNombrePages stored False ;
    property BeforeDataScroll : EListScrollEvent  read ge_BeforeScroll write ge_BeforeScroll ;
    property AfterDataScroll  : TDatasetNotifyEvent read ge_AfterScroll  write ge_AfterScroll ;
    // Table du Datasource principal �dit�
    property DataTableUnit : {$IFDEF FPC}AnsiString {$ELSE}string{$ENDIF} read gs_TableSource write gs_TableSource;
    property SortColumn : Integer read FSortColumn write p_setSortColumn default 0;
    property SortOrder : TSortOrder read FSortOrder write p_setSortOrder default soAscending;
   end;


  // Message de confirmation d'enregistrement avant le tri
const
     // nombre par d�faut de pages � charger
{$IFDEF FPC}
     CST_GROUPE_PAGES_CHARGER = 1 ;
{$ELSE}
     CST_GROUPE_PAGES_CHARGER = 3 ;
{$ENDIF}
     CST_GROUPE_COULEUR_FOCUS = clSkyBlue ;
     CST_GROUPE_TRANS_TOTAL   = 1 ;
     CST_GROUPE_TRANS_SIMPLE  = 0 ;
     CST_GROUPE_TRANS_RETOUR   = 2 ;
     CST_GROUPE_TRANS_DESTI   = 1 ;
     CST_GROUPE_TRANS_EXCLU   = 0 ;


var gcol_CouleurFocus : TColor = CST_GROUPE_COULEUR_FOCUS ;
    gcol_CouleurLignePaire   : Tcolor = clInfoBk ;
    gcol_CouleurLigneImpaire : Tcolor = clWhite  ;
    // Ev�nement centralis� de syncho du mode asynchrone
{$IFDEF EADO}
    ge_GroupFetchLoading : TEvent = Nil ;
{$ENDIF}

implementation

uses TypInfo, fonctions_string, fonctions_proprietes, Variants,  ExtCtrls,
     fonctions_erreurs, fonctions_dbcomponents, 
     fonctions_db, fonctions_init, unite_messages ;

 ///////////////////////////////////////////////////////////////
// TUltimListViewDatalink                                     //
//////////////////////////////////////////////////////////////

// Cr�ation � partir du listview
// alsv_List : La liste associ�e
Constructor TUltimListViewDatalink.Create( alsv_List : TDBListView);
Begin
  Inherited Create;
  glst_View := alsv_List ;
End;

// Utilis� : le dataset est ouvert ou non
Procedure TUltimListViewDatalink.ActiveChanged;
Begin
  inherited ;
  // Si il existe un Datasource on continue
  if not assigned ( Dataset )
  or not ( Dataset.State in [dsBrowse,dsInsert ] ) Then
    Exit ;
  glst_View.p_LoadListView ;
End;

// Mise � jour du composant
procedure TDBListView.p_MetAjour ;

Begin
  p_Reinitialise ;
  p_AjouteEnregistrements;
End ;
// non Utilis� : On change de groupe dans DataSetChanged
{Procedure TUltimListViewDatalink.DataSetScrolled(Distance: Integer);
Begin
  inherited ;
End;
 }
// Utilis� : On a supprim� un groupe
Procedure TUltimListViewDatalink.DataSetChanged;
Begin
  inherited ;
  if not assigned ( Dataset )
  or not ( Dataset.State in [dsBrowse,dsInsert ] ) Then
    Exit ;
  glst_View.p_UpdateListView;
End;


// Proc�dure : p_SetListNil
// D�sactiver le lien � la destruction
procedure TUltimListViewDatalink.p_SetListNil ;
Begin
  glst_View := Nil ;
End ;

// Utilis� : On a chang� d'�tat
// Gestion des mises � jour de la cl� primaire des groupes
Procedure TUltimListViewDatalink.EditingChanged;
Begin
  inherited ;
  if not assigned ( glst_View ) Then
    Exit ;
  glst_View.EditingChanged;
End;

 ///////////////////////////////////////////////////////////////
// TDBListView                                            //
//////////////////////////////////////////////////////////////
// Cr�ation du composant : premi�re intialisation
// acom_owner : Le composant propri�taire
constructor TDBListView.create ( acom_owner : Tcomponent );
begin
  inherited create ( acom_owner );

  FSortOrder := soAscending;
  FSortColumn := 0 ;
    // Mode asynchrone
  {$IFDEF EADO}
  ge_WaitForFetch := Nil ;
  {$ENDIF}
  gsts_ChampsListe   := nil ;
  gstl_CleDataSource := nil ;

  p_LibereBookmark ;
  gi_Fetch := 0 ;
  gb_fetched := False ;
  gi_FetchTotal := 0 ;
  // Prmi�re fois que le composant s'initialise
  gb_HasLoaded := False ;

  gb_LoadList       := False ;
  gb_AllSelect      := False ;
  gb_MontreTout     := False ;
  gb_CouleursLignes := True ;
  // Le lien de donn�e doit �tre initialis� avant : c'est un lien vers une propri�t�
  gdl_DataLink := TUltimListViewDatalink.Create ( Self );
  // Initialisation avant la cr�ation : plus s�r
  gbm_DernierEnregistrement := '' ;
//  gb_TrieAsc                := True ;
  // Cr�ation
  {$IFDEF DELPHI}
  ResInstance:= FindResourceHInstance(HInstance);
  {$ENDIF}
  // Couleurs de lignes par d�faut
  DataRowColors := True ;
  // On utilise le composant en montrant partiellement le donn�es
  DataShowAll   := False ;
  // S�lection d'une ligne enti�re
  RowSelect := True;
  // Gestion du drag and drop
  DragMode := dmAutomatic ;
  gb_AllLoaded := gb_AllFetched and ( not assigned ( gdl_DataLink.DataSet ) or not gdl_DataLink.DataSet.Active or gdl_DataLink.DataSet.IsEmpty );
  // On peut s�lectionner plusieurs unit�s
  MultiSelect := True ;
end;

// destruction du composant : destruction des objets
destructor TDBListView.destroy;
begin
  // Lib�ration du bookmark si il existe
  p_LibereBookmark ;
  inherited;
  {$IFDEF EADO}
  if ( gdl_DataLink.DataSet is TCustomADODataset ) Then
    Begin
      ( gdl_DataLink.DataSet as TCustomADODataset ).OnFetchProgress := ge_OldFetchProgress ;
      ( gdl_DataLink.DataSet as TCustomADODataset ).OnFetchComplete := ge_OldFetchComplete ;
//      ( gdl_DataLink.DataSet as TCustomADODataset ).AfterOpen       := ge_AfterOpen ;
    End ;
  {$ENDIF}
  // Lib�ration du lien de donn�es de la liste
  gdl_DataLink.Datasource := Nil ;
  gdl_DataLink.Free ;
  gdl_DataLink := nil ;

  // Lib�ration des listes de champs
  p_LibereChampsListe;
  p_LibereCleDatasource;
  Finalize ( gt_CleOrigine     );
    // Lien datasource � lib�rer ensuite : lien vers une propri�t�
end;

// destruction du composant : destruction des objets
procedure TDBListView.p_LibereCleDatasource;
begin
  // Lib�ration du stringlist si il existe
  gstl_CleDataSource.Free ;
  gstl_CleDataSource := nil ;
end;

// destruction du composant : destruction des objets
procedure TDBListView.p_LibereChampsListe;
begin
  // Lib�ration du stringlist si il existe
  if assigned ( gsts_ChampsListe   ) Then  gsts_ChampsListe  .Free ;
  gsts_ChampsListe   := nil ;
end;

procedure TDBListView.EditingChanged;
begin

end;
{$IFDEF EADO}
// Fonction : fb_WaitForLoadingFirstFetch
// Mode asynchrone : Attente d'un chargement d'items dans la liste
// A appeler avant de cr�er l'�v�nement ge_GroupFetchLoading et apr�s tout �a mettre p_AjouteEnregistrementsSynchrones
// Retour : Dataset actif ou pas
Function  fb_WaitForLoadingFirstFetch : Boolean ;
Begin
  While assigned ( ge_GroupFetchLoading ) and ( ge_GroupFetchLoading.WaitFor ( 100 ) = wrSignaled ) do
     Begin
       Application.ProcessMessages ;

     End ;
  Result := True ;
End ;
{$ENDIF}
// Mode asynchrone : A-t-on charg� suffisamment d'items dans la liste
Function  TDBListView.fb_FetchIsLoaded : Boolean ;
Begin
  // On prend en consid�ration la taile �cran et non la taille du composant qui varie en fonction de la fiche
  Result := ( Items.Count > 0 ) and (( Font.Height <= 0 ) and ( gi_Fetch - 1 > Screen.Height )) or (( Font.Height > 0 ) and ( gi_Fetch - 1 > Screen.Height div ( Font.Height - 1 )));
  gb_Fetched := Result ;
End ;

procedure TDBListView.p_MajBoutons(const ai_ItemsAjoutes: Integer);
begin
End ;

// R�initialisation : Appel�e pour recharger au tri
procedure TDBListView.p_ReinitialisePasTout ;
Begin
  // h�ritage de la r�initilisation

  Items.Clear;
  Invalidate ;
  p_LibereBookmark;
  gb_AllLoaded := gb_AllFetched and not assigned ( gdl_DataLink.DataSet ) or not gdl_DataLink.DataSet.Active or gdl_DataLink.DataSet.IsEmpty ;
End ;



// Affectation de SORTDirection : il faut utiliser cette proc�dure pour synchroniser TDBListView
// ab_Ascendant    : Le tri est ascendant ou non
procedure TDBListView.p_SetSortDirectionAsc(const ab_Ascendant : Boolean );
begin
  // V�rification de la validit� du sort
  if ab_Ascendant
   Then SortOrder := soAscending
   Else SortOrder := soDescending ;
end;


procedure TDBListView.p_setSortOrder(AValue: TSortOrder);
begin
  if AValue <> FSortOrder then
    Begin
      p_ReinitialisePasTout;
      FSortOrder := AValue ;
      fb_PrepareTri ( FSortColumn );
      p_AjouteEnregistrements;
    End
end;

procedure TDBListView.p_setSortColumn(AValue: Integer);
begin
  if AValue <> FSortColumn then
    Begin
      p_ReinitialisePasTout;
      fb_PrepareTri ( AValue );
      p_AjouteEnregistrements;
    End
end;

// Trier le dataset : Utilis� par le composant MCAdvGroupView
// Assigner la prorpr�t� sort au bon dataset
// as_ChampsOrdonner : La valeur � affecter
procedure TDBListView.p_AssignSort ( const as_ChampsOrdonner : String );
Begin
  // c'est un composant : v�rification de l'existance de la propri�t�
  if  assigned ( gdl_DataLink.DataSet )
  and          ( gdl_DataLink.DataSet.Active )
   Then
    // affectation
    p_SetComponentProperty( gdl_DataLink.DataSet, 'Sort', as_ChampsOrdonner );
End ;

// �v�nement de dessin des items
// Peint les couleurs de lignes vers l'unit� mc_fonctions_groupes
// aclv_Liste : La liste de l'�v�nement
// alit_Item  : L'item � peindre
// acds_Etat  : Obligtoire pour l'�v�nement
// ab_Defaut  : Obligtoire pour l'�v�nement
procedure TDBListView.p_PaintFondItem ( aclv_Liste : TCustomListView ; alit_Item : TListItem ; acds_Etat : TCustomDrawState ; var ab_Defaut : Boolean );
begin
  if gb_CouleursLignes // Si propri�t� DataRowColors � true
   Then
  If ( alit_Item.Index div 2 = alit_Item.Index / 2 )
   Then  aclv_Liste.Canvas.Brush.Color := gcol_CouleurLignePaire
   Else  aclv_Liste.Canvas.Brush.Color := gcol_CouleurLigneImpaire  ;
//    p_groupeCustomDrawItem( aclv_Liste, alit_Item ); /// Peinture des coulerus de lignes
  if assigned ( gdip_OldOnDrawItemProp ) // Ancien �v�nement
   Then
    gdip_OldOnDrawItemProp ( aclv_Liste, alit_Item, acds_Etat, ab_Defaut );
end;
// Ev�nement sur focus : Changement de couleur
procedure TDBListView.DoEnter;
begin
  // Changement de la couleur d'ent�te sur focus
  Color := gcol_CouleurFocus ;
  // Proc�dure surcharg�e
  inherited;
end;

// Ev�nement d�focus : r�tablissement de la couleur
procedure TDBListView.DoExit;
begin
   // R�tablissement de la couleur d'ent�te
  Color := gcol_AncienneCouleur ;
  // Proc�dure surcharg�e
  inherited;
end;


// Affectation de la propri�t� Nombre de pages
// a_Value : valeur � tester : test si �gale � z�ro
{procedure TDBListView.p_SetNombrePages(const a_Value: Word);
begin
  lw_NombrePages := a_Value ;
  if lw_NombrePages = 0 // Il ne faut pas que �a soit �gal � z�ro
   Then lw_NombrePages := GS_PAGES_CHARGER ; // Alors on met la constante par d�faut
end;}
// Cherche un item : Utiliser plut�t le locate du dataset
// as_TexteItem : Item principal ou cl� � trouver
// R�sultat : num�ro de l'item ou -1
function TDBListView.fi_FindItem ( const avar_TexteItem : Variant ) : Integer ;
// Compteur
var li_i , li_j : Integer ;
    lb_Trouve : Boolean ;
Begin
// Rien n'est encore trouv�
  Result := -1 ;
  // Parcourt des items principaux
  for li_i := 0 to Items.Count - 1 do
    Begin
      lb_Trouve := False ;
      for li_j := 0 to high ( gt_ColonneCle ) do
      // Si on le trouve
        if (     ( gt_ColonneCle [ 0 ]    <= 0    )
             and ( VarCompareValue ( Items [ li_i ].Caption, avar_TexteItem ) = vrEqual ))
        or (     ( gt_ColonneCle [ 0 ]    > 0    )
             and ( VarCompareValue ( Items [ li_i ].SubItems [ gt_ColonneCle [ 0 ] - 1 ], avar_TexteItem ) = vrEqual ))
         Then
          Begin
            // Retourne le compteur
            lb_Trouve := True ;
          End ;
      if lb_Trouve Then
        Begin
          Result := li_i ;
          // C'est fini
          Break ;
        End ;
    End ;
End ;

// Gestion du scroll quand la liste n'est pas charg�e
// Message : informations sur le d�placement en cours
procedure TDBListView.WMMouseWheel(var Message: {$IFDEF FPC}TLMMouseEvent{$ELSE}TWMMouseWheel{$ENDIF});
begin
  inherited ;
  if ( ComponentState * [csLoading,csDestroying,csDesigning] = [] ) Then
    p_scrolling ;
End ;

// Gestion du scroll quand la liste n'est pas charg�e
// Message : informations sur le d�placement en cours
procedure TDBListView.WMVScroll(var Message: TWMVScroll);
//  lw_PagesACharger : Word        ; // Variable temporaire de test de page
begin
  inherited ;
  if ( ComponentState * [csLoading,csDestroying,csDesigning] = [] ) Then
    p_scrolling ;
end;

/////////////////////////////////////////////////////////////////////////////
// Fonction : ScrollBarVisible
// En entr�e : la scrollbar en code windows
// En sortie : Scrollbar visible ou pas
/////////////////////////////////////////////////////////////////////////////
function TDBListView.fb_ScrollBarVisible(Code: Word): Boolean;
var
  lSI_infos        : TScrollInfo ; // Infos suppl�mentaires de scroll
  lw_NPage         : Cardinal ;
//  lw_PagesACharger : Word        ; // Variable temporaire de test de page
begin
  // Param�tres de r�cup�ration
  lSI_infos.cbSize := sizeof(lSI_infos);
  lSI_infos.fMask := SIF_ALL;
  //R�cup�re les infos
  GetScrollInfo(Self.Handle, SB_VERT, lSI_infos);
  lw_NPage := lSI_infos.nPage ;
  Result := ( lw_NPage > 0 ) and ( lSI_infos.nMin >= 0 ) and ( lSI_infos.nMax > 0 ) and ( lSI_infos.nMin < lSI_infos.nMax ) and ( lSI_infos.nMax div lw_NPage > 0 );
end;
procedure TDBListView.p_UpdateListView;
begin
End;

procedure TDBListView.p_LoadListView;
begin
  // Si il existe
  if assigned ( gdl_DataLink.DataSet )
  and not ( csDestroying in ComponentState ) Then
    // et si il est inactif
    if Datasource.DataSet.Active
     Then
       DataLinkActiveChanged
      Else
       // Alors on met � jour la liste
       Begin
         gb_AllLoaded := True ;
         {$IFDEF EADO}
         p_SetUnFetch;
         {$ENDIF}
       End;
end;


/////////////////////////////////////////////////////////////////////////////
// Proc�dure surcharg�e : Resize
// Description : Refresh possible au redimensionnement
/////////////////////////////////////////////////////////////////////////////
procedure TDBListView.Resize;
begin
  inherited ;
    // Tout n'est pas charg�
  if  gb_LoadList
  and not gb_AllLoaded
  and not gb_MontreTout
  // Il y a peut-�tre retaillage � la destruction
  and ( ComponentState * [csLoading,csDestroying,csDesigning] = [] )
  // Les items ne sont peut-�tre pas montrables
  and ( Self.Height > Font.Height - 1 )
  // On annule pour le mode asynchrone car d�j� en cours de chargement
  and not  fb_ScrollBarVisible ( SB_VERT ) Then
  // Tout n'est pas montr� et scrollvert non visible
  // Donc il n'y a pas assez des donn�es pr�sentes
    Begin
      // On rafraichit
      p_AjouteEnregistrements ;
    End;

end;

// Rafra�chissement de la liste
procedure TDBListView.Refresh;
begin
  P_Reinitialise ;
  p_AjouteEnregistrements ;
End;

// Gestion automatique du scrolling quand la liste n'est pas charg�e
procedure TDBListView.p_scrolling ;
var
  lSI_infos        : TScrollInfo ; // Infos suppl�mentaires de scroll
  li_NPage         : Cardinal ;
//  lw_PagesACharger : Word        ; // Variable temporaire de test de page
begin
  inherited ;
  if not Visible
  or (not ( Owner is TControl ) or not ( Owner as TControl ).Visible ) Then
    Exit;
  // Tout n'est pas charg�
  if not gb_AllLoaded
   Then
    Begin
      // Param�tres de r�cup�ration
      lSI_infos.cbSize := sizeof(lSI_infos);
      lSI_infos.fMask := SIF_ALL;
      //R�cup�re les infos
      GetScrollInfo(Self.Handle, SB_VERT, lSI_infos);

      li_NPage := lSI_infos.nPage ;
      // r�cup�re les param�tres de nombre de pages visibles
      if ( lSI_infos.nMax < lSI_infos.nPos + li_NPage * CST_GROUPE_PAGES_CHARGER )
//      if  ( lSI_infos.nPos > ( lSI_infos.nMax - lSI_infos.nPage ) div 2  )
       Then
        // Alors ajoute des donn�es
        p_AjouteEnregistrements ;
//      p_MiseAjourScrollBar ;
    End ;
end;

//////////////////////////////////////////////////////////////////////////////////
// Ev�nement : p_FetchProgressLoaded
// Description : Ev�nement qui se produit en mode assynchrone quand des enregistrements ont �t� charg�s
// Param�tres  : DataSet     : La Dataset ADO du mode assynchrone
//               ProGress    : Progression, nombre d'enregistrements charg�s
//               MaxProgress : Total voulu
//               EventStatus : Ev�nements de la command SQL
//////////////////////////////////////////////////////////////////////////////////
{$IFDEF EADO}
procedure TDBListView.p_FetchProgressLoaded(DataSet: TCustomADODataSet; ProGress, MaxProgress : Integer; var EventStatus: TEventStatus);
Begin
  if not assigned ( Owner )
  or not ( Owner is TWinControl )
  or not ( Owner as TWinControl ).Visible
//  or not ( Dataset.Active )
//  or ( DataSet <> gdl_DataLink.DataSet ) Then
   Then
    Begin
      Exit ;
    End ;
  try
    if assigned ( ge_oldfetchProgress ) Then
      ge_oldfetchProgress ( Dataset, Progress, MaxProgress, EventStatus );
  Except
    on e: Exception do
      f_GereException ( e, Dataset );
  End ;

  // On indique que tout n'est plus compl�tement charg�
  gb_AllLoaded := False ;

  // On ne charge que quelques items lors d'un fetch ( on est en mode asynchrone )
  // On est dans le fetch qui va ajouter les items
  if not gb_fetched Then
    Begin
      try
        // Gestion du fetch en mode asynchrone
        // Boucle d'attente de fetch
        // Elle doit attendre un �ventuel autre Fetch en cours
        // Sinon le programme et windows se perdent
        // On n'est pas en multi-t�ches sur un ordinateur avec un windows !
        fb_WaitForLoadingFirstFetch ;

       // Cet �v�nement est cr�� avant p_AjouteEnregistrementsSynchrones : Il y a deux failles dans le passage du multi-t�che au mono-t�che : La proc�dure utilis�e dans le multi-t�che et l'�v�nement multi-t�ches
       try
          ge_GroupFetchLoading := TEvent.Create ( nil, True, True, '' );
          ge_WaitForFetch.Free ;
          ge_WaitForFetch := Nil ;

        // On ne peut appeler p_AjouteEnregistrementsSynchrones que si on a appel� fb_WaitForLoadingFirstFetch et cr�� ge_GroupFetchLoading
          p_AjouteEnregistrementsSynchrones;
          // L'�v�nement est mult-t�che et seul p_AjouteEnregistrementsSynchrones �tait mono-t�che : Lib�ration de l'�v�nement de synchro
        finally
          ge_GroupFetchLoading.Free ;
          ge_GroupFetchLoading := Nil ;
        End ;
      finally
      End;
    End ;

  // Nom d'enregistrements en total
  gi_FetchTotal := MaxProgress ;
  // Progression
  gi_Fetch := ProGress ;

  // On ne charge que quelques items
  // Mise � jour de gb_fetched en cons�quence
  fb_FetchIsLoaded ;
End ;

//////////////////////////////////////////////////////////////////////////////////
// Ev�nement : p_RefreshLoaded
// Description : Ev�nement qui se produit en mode assynchrone quand tous les enregistrements ont �t� charg�s
// Param�tres  : DataSet     : La Dataset ADO du mode assynchrone
//               Error       : Erreur si EventStatus est � esErrorsOccured
//               EventStatus : Ev�nements de la command SQL
//////////////////////////////////////////////////////////////////////////////////
procedure TDBListView.p_RefreshLoaded(DataSet: TCustomADODataSet;
  const Error: Error; var EventStatus: TEventStatus);
var lt_Arg : Array [0..1] of String ;
Begin
{  if ( DataSet <> gdl_DataLink.DataSet )
  or ( not DataSet.Active  and ( EventStatus <> esErrorsOccured )) Then
    Begin
      Exit ;
    End ;}
  ge_WaitForFetch.Free ;
  ge_WaitForFetch := Nil ;
  try
    if assigned ( ge_oldfetchComplete ) Then
      ge_oldfetchComplete ( Dataset, Error, EventStatus );
  Except
    on e: Exception do
      f_GereException ( e, Dataset );
  End ;

  // Plus de fetch sur ce composant : Les donn�es sont charg�es
  gb_AllFetched := True ;
{
  if not assigned ( Owner )
  or not ( Owner is TWinControl )
  or not ( Owner as TWinControl ).Visible Then
    Begin
      Exit ;
    End ;
 }
  // Erreurs �ventuelles
  if EventStatus = esErrorsOccured  Then
    Begin
      lt_Arg [ 0 ] := 'du Dataset ' + gdl_DataLink.Dataset.Name ;
      lt_Arg [ 1 ] := Self.Name ;
      ShowMessage ( fs_RemplaceMsg ( GS_ERREUR_OUVERTURE + #13#10 + GS_FORM_ABANDON_OUVERTURE, lt_Arg ));
    End ;
End ;

////////////////////////////////////////////////////////////////////////////////////
// M�thode     : p_SetFetchLoaded
// Description : Gestion du mode asynchrone : Rien n'est charg� � l'ouverture
////////////////////////////////////////////////////////////////////////////////////

procedure TDBListView.p_SetFetchLoaded;
Begin
  if ( gdl_DataLink.DataSet is TCustomADoDAtaset )
  and (( gdl_DataLink.DataSet as TCustomADoDAtaset ).CursorLocation = clUseClient )
  and  ( eoAsyncExecute in ( gdl_DataLink.DataSet as TCustomADoDAtaset ).ExecuteOptions )
    Then
      Begin
          // Ovuerture du dataset asynchrone
        gb_AllFetched := False ;
        // Mise en place d' l'�v�nement de synchro du mode asynchrone
        // Attention ! L'�v�nement ne doit pas exister
//        if not assigned ( ge_GroupFetchOpening ) Then
        ge_WaitForFetch :=  TEvent.Create ( nil, True, True, '' );

      End ;
End ;

////////////////////////////////////////////////////////////////////////////////////
// M�thode     : p_SetUnFetch
// Description : Gestion du mode asynchrone : R�initialisation � la fermeture
////////////////////////////////////////////////////////////////////////////////////

procedure TDBListView.p_SetUnFetch;
Begin
  gb_AllFetched := True ;
  gi_FetchTotal := 0 ;
  gi_Fetch := 0 ;
  ge_WaitForFetch.Free ;
  ge_WaitForFetch := nil ;
End ;
{$ENDIF}
// Lib�re le bookmark en cours : Surcharg� pour les autres descendants
procedure TDBListView.p_LibereBookmark ;
Begin
  // si le bookmark existe
{  if  assigned ( gbm_DernierEnregistrement )
  // et son dataset associ� existe aussi
  and assigned ( gdl_DataLink.Datasource         )
  and assigned ( gdl_DataLink.DataSet )
   Then
   // Lib�ration du bookmark
    try
      gdl_DataLink.DataSet.FreeBookmark ( gbm_DernierEnregistrement );
    except
    End ;}
  // Mise � nil du bookmark
  gbm_DernierEnregistrement := '' ;
End ;

// R�initialise le composant : utilis� aussi lorsqu'on recharge le composant
procedure TDBListView.p_Reinitialise ;
Begin
  gb_LoadList        := False ;
  gb_AllFetched      := False;
  if assigned ( gdl_DataLink.DataSet )
  and gdl_DataLink.DataSet.Active
  and not gdl_DataLink.DataSet.IsEmpty then
    gdl_DataLink.DataSet.First;

  // Effacement des items
  {$IFDEF DELPHI}Items.{$ENDIF}BeginUpdate ;
  Items.Clear;
  {$IFDEF DELPHI}Items.{$ENDIF}EndUpdate ;
  Invalidate ;
  // Lib�ration du bookmark en cours : surcharg�
  p_LibereBookmark ;
  // A faire � la fin : Mode normal par d�faut
  gb_AllLoaded := False;
End ;
{
procedure TDBListView.p_MiseAjourScrollBar ;
var
  SIOld, SINew: TScrollInfo;
Begin
  if ( GetCount <= 0 )
   Then
    Exit ;
  if gb_AllLoaded
   Then
    Exit ;
  GetScrollInfo(Self.Handle, SB_VERT, SIOld);
  SINew := SIOld;
  if not gb_MontreTout
   Then
    begin
      SINew.nMin := 0;
      SINew.nPage := 1;
//      SINew.nMax := 100;
      if SINew.nPos <> 0
       then SINew.nPos := ( SINew.nMax - SINew.nPage ) div 2;

    end;
  if (SINew.nMin <> SIOld.nMin) or (SINew.nMax <> SIOld.nMax) or
    (SINew.nPage <> SIOld.nPage) or (SINew.nPos <> SIOld.nPos)
     then
      Begin
        Self.Updating ;
        BeginUpdate ;
        SetScrollInfo(Self.Handle, SB_VERT, SINew, True);
        EndUpdate ;

        Self.Updated ;
      End ;
End ;}
// Fin du chargement du composant
procedure TDBListView.Loaded;
{   im_FlecheHaute ,
   im_FlecheBasse : TBitmap ;}
begin
  inherited Loaded;
  // Affectation des bonnes valeurs
//  gb_TrieAsc := Sortdirection = sdAscending ;
  // a l'ex�cution
  if not ( csDesigning in ComponentState )
  // Si c'est la premi�re fois
  and not gb_HasLoaded
   Then
    Begin
      // Plus de premi�re fois
      gb_HasLoaded := True ;

      p_CreeListeChampsDisplay ( gs_champsListe );
      
{$IFDEF EADO}


      if ( gdl_DataLink.DataSet is TCustomADODataset ) Then
        Begin
//           ge_AfterOpen         := gdl_DataLink.DataSet.AfterOpen  ;
           ge_OldFetchComplete  := ( gdl_DataLink.DataSet as TCustomADODataset ).OnFetchComplete  ;
          ge_OldFetchProgress  := ( gdl_DataLink.DataSet as TCustomADODataset ).OnFetchProgress  ;
//          ( gdl_DataLink.DataSet as TCustomADODataset ).AfterOpen       := p_DatasourceOnOpen ; // fin de chargement au OnFetchComplete
          ( gdl_DataLink.DataSet as TCustomADODataset ).OnFetchComplete := p_RefreshLoaded; // fin de chargement au OnFetchComplete
           ( gdl_DataLink.DataSet as TCustomADODataset ).OnFetchProgress := p_FetchProgressLoaded; // fin de chargement au OnFetchComplete
        End ;
{$ENDIF}

      {$IFDEF ADVANCED}
      if  SortUpGlyph  .Empty
      and SortDownGlyph.Empty
       Then
        Begin
        // Cr�ation des images de recherche et d'ordonancement
          im_FlecheHaute := TBitmap.Create ;
          im_FlecheBasse := TBitmap.Create ;

          im_FlecheHaute.LoadFromResourceName(ResInstance, 'TRIHAUT' );
          im_FlecheBasse.LoadFromResourceName(ResInstance, 'TRIBAS' );

          im_FlecheBasse.Transparent := True ;
          im_FlecheHaute.Transparent := True ;
          SortUpGlyph  .Assign ( im_FlecheHaute );
          SortDownGlyph.Assign ( im_FlecheBasse );
          im_FlecheHaute.Dormant ;
          im_FlecheBasse.Dormant ;
          im_FlecheHaute.FreeImage ;
          im_FlecheBasse.FreeImage ;
          im_FlecheBasse.Handle := 0 ;
          im_FlecheHaute.Handle := 0 ;
          im_FlecheHaute.Free ;
          im_FlecheBasse.Free ;
        End ;
      {$ENDIF}
      p_AssignColonnesSubitems;
      p_AffecteEvenementsDatasource ;
      // Affectation des �v�nements
      gdip_OldOnDrawItemProp   := OnCustomdrawItem ;
      OnCustomdrawItem         := p_PaintFondItem ;
      // Et de la valeur temporaire de couleur d'ent�te
      gcol_AncienneCouleur := Color ;
    End ;
end;

procedure TDBListView.p_AffecteEvenementsDatasource ;
Begin
End;

// Ev�nement click colonne pour le tri
// alsc_colonne : la colonne � trier
procedure TDBListView.p_AssignColonnesSubitems;
var
   li_i, li_j : Integer;
begin
  if  ( assigned ( gsts_ChampsListe ))
  and ( assigned ( gstl_CleDataSource ))
    Then
      Begin
        if gstl_CleDataSource.Count > 0
         Then
          SetLength ( gt_ColonneCle, gstl_CleDataSource.Count );
        for li_i := 0 to high ( gt_ColonneCle ) do
          gt_ColonneCle [ li_i ] := -1  ;
        // Gestion des subitems de la ListView
        for li_i := 0 to gsts_ChampsListe.Count - 1 do
          for li_j := 0 to gstl_CleDataSource.Count - 1 do
            if gstl_CleDataSource [ li_j ] = gsts_ChampsListe [ li_i ] Then
              gt_ColonneCle [ li_j ] := li_i ;
        li_j := 0 ;
        for li_i := 0 to high ( gt_ColonneCle ) do
          if gt_ColonneCle [ li_i ] < 0 Then
            Begin
              gt_ColonneCle [ li_i ] := gsts_ChampsListe.Count + li_j ;
              inc ( li_j );
            End ;
      End ;
End ;
// Ev�nement click colonne pour le tri
// alsc_colonne : la colonne � trier
procedure TDBListView.ColClick( alsc_colonne : TListColumn );
begin
  //Pr�paration du tri et tri du bon dataset
  SortColumn := alsc_colonne.Index ;

  // Tri de la bonne colonne
//  gi_ColonneTrie := alsc_colonne.Index ;
{  // Si on montre tout
  if gb_MontreTout
  // Ou si tout est charg�
  or ( gb_AllLoaded )
  //Ou pas de bonne propri�t�s
  or not assigned ( gdl_DataLink.Datasource )
  or not assigned ( gdl_DataLink.DataSet )
  // ou lien non actif
  or not ( gdl_DataLink.DataSet.Active )
  // Ou ce n'est pas un dataset ADO
  or ( csDesigning in ComponentState )
   Then
   // Tri normal
    inherited ColClick ( alsc_colonne )
   Else}
   // Sinon r�tablissement des champs tri�s
//    Begin
//      if SortType <> stNone
//       Then
       // Mise � z�ro des items
       inherited ColClick ( alsc_colonne );

       // Mise � jour des neregistrements tri�s
       // Le composant doit quand m�me trier dans le vide pour la synchronisation
//    End ;
end;

// Pr�paration du tri des items de la liste
// ai_Index : Le no de colonne � trier
function TDBListView.fb_PrepareTri ( const ai_column : Integer ) : Boolean;
var ls_ChampsOrdonner : String ;
begin
  FSortColumn := ai_column ; 
  ls_ChampsOrdonner := fs_PrepareTri ;
    // On ne peut pas trier : quitter
   Result := fb_PeutTrier ;
  // Le sort va de toute fa�on se faire dans le AdvListView
   if Result
    Then
     // Assignation du sort dans le bon dataset
     p_AssignSort ( ls_ChampsOrdonner );
//   Showmessage (( gdl_DataLink.DataSet as TCustomADODataSet ).Sort + ' f ' + ls_ChampsOrdonner );
End ;

// Pr�paration du tri des items de la liste
// ai_Index : Le no de colonne � trier
function TDBListView.fs_PrepareTri ( ) : String;
begin
  // Le sort va de toute fa�on se faire dans le AdvListView
  // On donne donc la possibilit� de trier par d�faut
  Result := '' ;
  //  v�rification de l'existence de la propri�t� et du dataset
  if not assigned ( gdl_DataLink.Datasource )
  or not assigned ( gdl_DataLink.DataSet )
  or  ( SortColumn <  0               )
  or  ( SortColumn >= Columns.Count   )
   Then
    Exit ;
    // SI on cache la cl� dans la liste
      // On r�cup�re directement la colonne de DataFieldDiplay
    // On r�cup�re le bon champ
   Result := fs_stringChamp ( gs_ChampsListe, ';', SortColumn + 1 );
    // Rien : on quitte
   if Result = ''
    Then
     Exit ;
     // Si trie ascendant

   if SortOrder = soAscending
     // Alors ajout de ASC
    Then Result := Result + ' ASC'
     // Sinon ajout de DESC
    Else Result := Result + ' DESC' ;
    // On ne peut pas trier : quitter
//   Showmessage (( gdl_DataLink.DataSet as TCustomADODataSet ).Sort + ' f ' + ls_ChampsOrdonner );
End ;

// Peut-on trier ? : m�thode surcharg�e dans le descendant
// R�sultat : vrai
function TDBListView.fb_PeutTrier  : Boolean ;
Begin
  Result := True ;
End ;

// Peut-on ajouter des items ? Utilis� par le composant MCAdvGroupView
// adat_Dataset : Le dataset � ajouter dans la liste
// R�sultat : Vrai
function TDBListView.fb_PeutAjouter ( const adat_Dataset : TDataset ; const ab_AjouteItemPlus : Boolean)  : Boolean ;
Begin
  Result := True ;
End ;

// Mettre � jour l'�tat de l'item : Utilis� par le composant MCAdvGroupView pour tout mettre dans le listview
// adat_Dataset : Le dataset � ajouter dans la liste
// R�sultat : Vrai
function TDBListView.fb_ChangeEtatItem  ( const adat_Dataset : TDataset  ; const ab_AjouteItemPlus : Boolean ) : Boolean ;
Begin
  Result := True ;
End ;

// Ajoute les enregistrements : Surcharg� pour les autres descendants
// adat_Dataset : Le dataset � ajouter dans la liste
// R�sultat     : A-t-on chang� l'�tat de certains items ?
function TDBListView.fb_RemplitEnregistrements ( const adat_Dataset : TDataset ; const ab_InsereCles : Boolean ) : Boolean;
// Compteurs
var li_i   , li_j : Integer ;
//  Valeurs des champs suppl�mentaires � afficher
    lvar_AAfficher   : Variant ;
    // Propri�t� Nombre de pages d'items visibles � charger
    lw_NombrePages   : Word ;
begin
  // intialisation
  Result := False ;

  // Pas de champ cl� : quitte
  if assigned ( gstl_CleDataSource )
  and ( gstl_CleDataSource.Count = 0 )
//  or not assigned ( DataOtherList )
   Then
    Exit ;
  // intialisation du compteur
  li_i := 0 ;
  // Travail sur le dataset
  if not ( adat_Dataset.Active ) Then
    Exit ;

  Screen.Cursor := crHourGlass ;
  with adat_Dataset do
   try
    // Selon le dbadvlistview
{$IFDEF FPC}
    BeginUpdate ;
{$ELSE}
    Items.BeginUpdate ;
{$ENDIF}

		// Tant qu'on n'est pas � la fin du dataset
			while not eof do
				begin
					// si on ne peut pas ajouter le champ en cours on passe au suivant
					 if not fb_PeutAjouter  ( adat_Dataset, ab_InsereCles )
						Then
						 Begin
							 Next;
							 Continue ;
						 End ;
						 // Incr�ment du compteur
					inc ( li_i );
						// Ajout d'un item
					gVG_ListItem         := Items.Add ;
					 // Affectation de la cl� si on la montre
					if ( gs_ChampsListe <> '' )
					 Then
						Begin
							// R�cup�ration des champs
							lvar_AAfficher  := FieldValues [ gs_ChampsListe ];
							// C'est plusieurs champs
							if VarIsArray ( lvar_AAfficher )
							 Then
								Begin
									// Ajout des champs
									For li_j := VarArrayLowBound ( lvar_AAfficher, 1 ) to  VarArrayHighBound ( lvar_AAfficher, 1 ) do
										// Pas de cl� montr�e et premier champ
										if  ( li_j = VarArrayLowBound ( lvar_AAfficher, 1 ))
											// Alors affectation � l'item ( premi�re colonne )
										 Then gVG_ListItem.Caption := lvar_AAfficher [ li_j ]
										 // Sinon ajout dans les autres colonnes
										 Else if lvar_AAfficher [ li_j ] <> Null Then
											 gVG_ListItem.SubItems.Add ( lvar_AAfficher [ li_j ] )
										 Else
											 gVG_ListItem.SubItems.Add ( '' );
									End
							 // Il n' a qu'un champ
								Else gVG_ListItem.Caption := lvar_AAfficher ;
						End ;
					if ( gs_CleUnite <> '' )
          and ( FindField ( gs_CleUnite ) <> nil )
					 Then
						Begin
							lvar_AAfficher  := FieldValues [ gs_CleUnite ];
							if VarIsArray ( lvar_AAfficher )
							 Then
								Begin
									// Ajout des champs
									For li_j := VarArrayLowBound ( lvar_AAfficher, 1 ) to  VarArrayHighBound ( lvar_AAfficher, 1 ) do
										 // ajout � la fin des autres colonnes
										 if lvar_AAfficher [ li_j ] <> Null Then
											 gVG_ListItem.SubItems.Add ( lvar_AAfficher [ li_j ] )
										 Else
											 gVG_ListItem.SubItems.Add ( '' );
								End
							 // Il n' a qu'un champ
								Else
								 if  assigned ( gVG_ListItem.SubItems )
                 and ( gt_ColonneCle [ 0 ] >= gVG_ListItem.SubItems.Count -1 )
									Then
										if lvar_AAfficher <> Null Then
										 gVG_ListItem.SubItems.Add ( lvar_AAfficher )
										Else
										 gVG_ListItem.SubItems.Add ( '' );
						End;
					Result := fb_ChangeEtatItem ( adat_Dataset, ab_InsereCles or gb_AllSelect ) ;
					Next;

					if ab_InsereCles
					 Then
						Continue ;

					if Eof
					 Then
						Begin
							// On indique que tout est charg�
 							gb_AllLoaded := True ;
							// L'ajout est fini
							Break ;
						End ;
					if  ( not gb_MontreTout )
					 Then
						Begin
							if ( gbm_DernierEnregistrement <> '' )
							 Then
								Begin
									lw_NombrePages := 1 ;
									try
										// Toujours lib�rer le bookmark
										gbm_DernierEnregistrement := '' ;
									except
									End;
								End
						 Else lw_NombrePages := CST_GROUPE_PAGES_CHARGER ;
							// r�cup�re les param�tres de nombre de pages visibles
								// A-t-on charg� suffisamment d'enregistrements
							if (     ( Font.Height = 0 )
										and ( li_i >= ( Self.Height ) * lw_NombrePages ))
							or (     ( Font.Height <> 0 )
									and  ( li_i >= ( Self.Height div Font.Height ) * lw_NombrePages + 1 ))
							 Then
								Begin
									// R�cup�re le bookmark pour un chargement prochain d'enregistrements
									gbm_DernierEnregistrement := Bookmark ;
									// Fin de cette MAJ
									Break ;
								End ;
						End ;
				end;
			if Eof
			 Then
					// On indique que tout est charg�
					gb_AllLoaded := True ;
		Except
			// gestion des erreurs
			on e: Exception do
				f_GereException ( e, adat_Dataset );
		End ;
{$IFDEF FPC}
  EndUpdate ;
{$ELSE}
  Items.EndUpdate ;
{$ENDIF}
//  EndUpdate ;

  try
    Screen.Cursor := crDefault ;
    Invalidate ;
    p_MajBoutons ( li_i );
  Finally
  End ;
End ;
{$IFDEF DELPHI}
// Suppression des composants d�truits
// AComponent : Le composant � d�truire
// Operation  : Op�ration � effectuer : Suppression ou ajout
procedure TDBListView.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  // Suppression d'un datasource inexistant
  if  ( Assigned                   ( Datasource ))
  and ( AComponent.IsImplementorOf ( Datasource ))
   then
    Datasource := nil;
end;
{$ENDIF}

/// Le datasource a �t� activ� : on met � jour le composant : Proc�dure surcharg�e
procedure TDBListView.DataLinkActiveChanged;
begin
  {$IFDEF EADO}
  p_SetFetchLoaded;
  {$ENDIF}
  // A l'ex�cution
  If  ( ComponentState * [csLoading,csDestroying,csDesigning] = [] )
  and ( Owner is TWinControl ) Then
//  and fb_ParentVisible ( Self ) Then
    Begin
      // Initialisation
      p_Reinitialise;
      // Ajout des items
      p_AjouteEnregistrements ;
    End;

end;

{
/// Le datasource a �t� activ� : on met � jour le composant : Proc�dure surcharg�e
function TDBListView.fb_ParentVisible ( const awco_Control : TWinControl ): Boolean;
var lwco_Parent : TWinControl ;
begin
  Result := True ;
  if not assigned ( awco_Control )
  or not awco_Control.Visible Then
    Begin
      Result := False ;
      Exit ;
    End ;
  lwco_Parent := awco_Control.Parent ;
  // A l'ex�cution
  while assigned ( lwco_Parent ) do
//  and not ( lwco_Parent is TCustomForm ) do
    Begin
      if not ( lwco_Parent is TTabSheet )
      and not lwco_Parent.Visible Then
        Begin
          Result := False ;
          Exit ;
        End ;
      if ( lwco_Parent is TTabSheet ) Then
      if not ( lwco_Parent as TTabSheet ).TabVisible Then
        Begin
          Result := False ;
          Exit ;
        End ;
      // Initialisation
      lwco_Parent := lwco_Parent.Parent ;
    End;

end;
}

// R�cup�re le sort du dataset ou cr�e un sort � partir de la colonne en cours
// adat_ADODataset : le bon dataset : ici il y en a un seul
function TDBListView.fs_SortDataset ( const adat_Dataset : TDataSet ): String ;
// Sauvegarde temporaire du champ � trier
var ls_TrieGroupe, ls_Sort : String ;
Begin
  // Avec le dataset
  with adat_Dataset do
    // si le sort n'existe
    ls_Sort := fs_getComponentProperty(adat_Dataset, 'Sort');
    If Trim ( ls_Sort ) = ''
     Then
     // Il faut initialiser le sort
      Begin
        // Colonne 0
        Result := fs_PrepareTri ( );
      End
      // Si il y a quelque chose on garde la valeur
     Else Result := ls_Sort ;

//  ShowMessage ( Result );
End ;


// Insertion des items appelle fb_RemplitEnregistrements : Surcharg� pour les autres descendants
// R�sultat   : celui de fb_RemplitEnregistrements : A-t-on chang� l'�tat de certains items ?
function TDBListView.fb_RemplitListe:Boolean;
var ls_Sort : String;
Begin
  Result := False ;


  // Le composant ne doit pas �tre en train de se charger
  if csLoading in ComponentState then Exit;

  Screen.Cursor := crSQLWait ;
  // Si tout n'est pas charg�
  if not gb_AllLoaded
   Then
    Begin
    // On va l� o� on s'�tait arr�t�
      if ( gbm_DernierEnregistrement <> '' )
       Then
        Begin
          try
            if not gb_AllSelect Then
              gdl_DataLink.DataSet.Bookmark := gbm_DernierEnregistrement ;
            // Toujours lib�rer le bookmark
          except
          End;
        End
       Else
        Begin
        // Si il n'y aplus de bookmark
          ls_Sort := Trim ( fs_getComponentProperty(gdl_DataLink.DataSet, 'Sort' ));
          if  ( ls_Sort = '' )
           Then
             // On trie
             p_SetComponentProperty ( gdl_DataLink.DataSet, 'Sort', fs_SortDataset ( gdl_DataLink.DataSet ));
        End ;
    End ;
//   ShowMessage ( ( gdl_DataLink.DataSet as TCustomADODataset ).Sort );
// Ins�re les enregistrements dans la liste
  Result := fb_RemplitEnregistrements ( gdl_DataLink.DataSet, False );
  Screen.Cursor := crDefault ;
End ;
// Ajoute automatiquement n pages d'enregistrements ou tout
// Appelle fb_insere
procedure TDBListView.p_AjouteEnregistrements;
begin
  // La liste n'est pas encore compl�tement charg�e pour pouvoir ins�rer les enregistrements
  if not gb_HasLoaded
  or (not ( Owner is TControl ) or not ( Owner as TControl ).Visible ) Then
    Exit;

  // Gestion du fetch en mode asynchrone
  // Boucle d'attente habituelle synchrone
  // Elle doit attendre un �ventuel Fetch en cours
  // Sinon le programme et windows se perdent
  try
  /// Mode asynchorne sur l'application
    {$IFDEF FORMMAININI}
    {$IFDEF EADO}
    if gb_ApplicationAsynchrone Then
  // M�me si on n'utilise pas le mode asynchrone sur cette instance une autre instance peut d�marrer le mode asynchrone
  // Cet �v�nement est aussi cr�� dans le fetch : Il y a deux failles dans le passage du multi-t�che au mono-t�che : La proc�dure utilis�e dans le multi-t�che et l'�v�nement multi-t�ches
      ge_GroupFetchLoading := TEvent.Create ( nil, True, True, '' );
    {$ENDIF}
    {$ENDIF}
  // On ne peut appeler Synchrones que si on a appel� fb_WaitForLoadingFirstFetch et cr�� ge_GroupFetchLoading
    p_AjouteEnregistrementsSynchrones;

  // Lib�ration : Permet de faire un fetch
  finally
    {$IFDEF EADO}
    ge_GroupFetchLoading.Free ;
    ge_GroupFetchLoading := Nil ;
    {$ENDIF}
  End ;
End ;
// Ajoute automatiquement n pages d'enregistrements ou tout
// Appelle fb_insere
procedure TDBListView.p_AjouteEnregistrementsSynchrones;
begin

  // V�rification de l'existence des propri�t�s
  if  not assigned ( gdl_DataLink.DataSet )
  and not gb_AllSelect
//  or not ( ds_Groupes.DataSet is TCustomADODataset )
   Then
     // Si elles n'existent pas on quitte
    Exit ;

  fb_PrepareTri ( FSortColumn );
  gb_LoadList   := True ;
    // Curseur d'attente SQL
  screen.Cursor := crSQLWait    ;
  // Cette instruction optimise la rapidit� d'ajouts
  try
    // Insertion des enreigstrements dans la liste
    fb_RemplitListe;
    // Un endupdate suit toujours un beginupdate : Mise � jour du composant
  finally
    Invalidate ;
  End ;
    // R�tablissement du curseur
//  p_MiseAjourScrollBar ;
  screen.Cursor := crDefault ;
end;

// R�cup�re le datasource li�
function TDBListView.fds_GetDatasource : TdataSource;
begin
  if assigned ( gdl_DataLink ) // Test n�cessaire : le datalink n'est peut �tre pas cr��
   Then Result := gdl_DataLink.DataSource
   Else Result := nil ;
end;

// Affectation du composant dans la propri�t� DataSource
// test si n'existe pas
// Mise � jour du nom de table
// a_Value : Le datasource
procedure TDBListView.p_SetDataSourceGroup ( const a_Value: TDataSource );
var ls_Table : String;
begin
{$IFDEF DELPHI}
  ReferenceInterface ( DataSource, opRemove ); //Gestion de la destruction
{$ENDIF}
  if gdl_DataLink.Datasource <> a_Value then
  begin
    gdl_DataLink.Datasource := a_Value ; /// affectation
  end;
{$IFDEF DELPHI}
  ReferenceInterface ( DataSource, opInsert ); //Gestion de la destruction
{$ENDIF}
   // R�cup�ration de la table
  // Y-a-t-il un dataset
  if assigned ( gdl_DataLink.DataSet ) Then
    Begin
     ls_Table := trim (fs_getComponentProperty ( gdl_DataLink.DataSet, 'TableName' ));
     if ls_Table <> '' Then
       gs_TableSource := ls_Table;
    end;
end;

procedure TDBListView.p_DataSetChanged;
begin

end;

// Proc�dure p_SetChampsListe
// Affectation de DataFieldsDisplay
// cha�ne a_Value : La valeur � affecter
procedure TDBListView.p_SetChampsListe(const Value: String);
begin
  if ( gs_ChampsListe <> Value ) Then
    Begin
      gs_ChampsListe := Value ;

    End ;
end;
// Proc�dure p_SetChampsListe
// Affectation de DataFieldsDisplay
// cha�ne a_Value : La valeur � affecter
procedure TDBListView.p_CreeListeChampsDisplay ( as_ChampsListe : String );
begin
  p_LibereChampsListe;
  // S�paration des champs
  if ( as_ChampsListe <> '' ) Then
    p_ChampsVersListe ( gsts_ChampsListe, as_ChampsListe, ';' )
   Else
    gsts_ChampsListe := TStringList.Create ;
end;

function TDBListView.GetNextItem(const StartItem: TListItem; const States: {$IFDEF FPC}TListItemStates{$ELSE} TItemStates{$ENDIF}): TListItem;
var
  Index: Integer;
begin
  Result := nil;

  if HandleAllocated then
  begin
  {    case Direction of
    Flags := 0;
      sdAbove: Flags := LVNI_ABOVE;
      sdBelow: Flags := LVNI_BELOW;
      sdLeft: Flags := LVNI_TOLEFT;
      sdRight: Flags := LVNI_TORIGHT;
      sdAll: Flags := LVNI_ALL;
    end;}
//        Flags := LVNI_ALL;
    if StartItem <> nil then Index := StartItem.Index
    else Index := -1;
//    if lisCut in States then Flags := Flags or LVNI_CUT;
//    if lisDropTarget in States then Flags := Flags or LVNI_DROPHILITED;
//    if lisFocused in States then Flags := Flags or LVNI_FOCUSED;
//    if lisSelected in States then Flags := Flags or LVNI_SELECTED;
//    Index := ListView_GetNextItem(Handle, Index, Flags);
    inc ( Index );
    if ( Index <> -1 ) and ( Index < Items.Count ) then Result := Items[Index];
  end;
end;

// Affectation de la propri�t� DataKeyUnit
// a_Value : valeur � tester : test si �gale � z�ro
procedure TDBListView.p_SetClePrimaireListe(const a_Value: {$IFDEF FPC} AnsiString{$ELSE}String{$ENDIF} );
begin
  if ( gs_CleUnite <> a_Value ) Then
    Begin
      gs_CleUnite := Trim ( a_Value );
      p_LibereCleDatasource;
      if ( trim (gs_CleUnite) <> '' ) // Il ne faut pas que �a soit �gal '' pour la cr�ation cde la liste
       Then
         Begin
           p_ChampsVersListe ( gstl_CleDataSource, trim(gs_CleUnite), ';' );
         End;
    end;
end;

{$IFDEF FPC}
procedure TDBListView.SelectAll;
var I :Integer ;
begin
  BeginUpdate;
  for I := 0 to Items.Count - 1 do
    Items[I].Selected := True;
  EndUpdate;
end;
{$ENDIF}

{//
function TDBListView.fvar_RetourneCleItems ( const alsi_Item : TListItem ): Variant ;
var lt_TailleTableau : Array [ 0..1 ] of Integer ;
    li_i : Integer ;
Begin
  Result := Null ;
  if gstl_CleDataSource.Count = 1
   Then
     Begin
       Result := alsi_Item.Caption ;
     End
   Else
    if gstl_CleDataSource.Count > 1
     Then
      Begin
        lt_TailleTableau [ 0 ] := 0 ;
        lt_TailleTableau [ 1 ] := gstl_CleDataSource.Count ;
        Result := VarArrayCreate( lt_TailleTableau, varString );
        Result [ 0 ] := alsi_Item.Caption ;
        for li_i := 1 to gstl_CleDataSource.Count - 1 do
         Result [ li_i ] := alsi_Item.SubItems [ li_i - 1 ] ;
      End ;
End ;}

initialization
{$IFDEF FPC}
  {$i U_DBListView2.res}
{$ENDIF}
{$IFDEF VERSIONS}
  p_ConcatVersion ( gVer_TDBListView  );
{$ENDIF}
end.
