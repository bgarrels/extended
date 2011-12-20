unit u_buttons_extension;

{$IFDEF FPC}
{$mode Delphi}
{$ENDIF}

{$I ..\DLCompilers.inc}
{$I ..\extends.inc}

interface

uses
 {$IFNDEF FPC}
    Windows,
 {$ENDIF}
  Classes, SysUtils,
  {$IFDEF VERSIONS}
  fonctions_version,
  {$ENDIF}
  u_buttons_appli,
  TFlatSpeedButtonUnit, Graphics;

{$IFDEF VERSIONS}
const
    gVer_buttons_ext : T_Version = ( Component : 'Buttons extension' ;
                                       FileUnit : 'u_buttons_extension' ;
                                       Owner : 'Matthieu Giroux' ;
                                       Comment : 'Composants boutons étendus.' ;
                                       BugsStory : '0.8.0.0 : Not tested.';
                                       UnitType : 3 ;
                                       Major : 0 ; Minor : 8 ; Release : 0 ; Build : 0 );
{$ENDIF}

procedure p_Load_Buttons_Appli ( const FGLyph : TBitmap; const as_Resource : String );

type
    TFSSpeedButton = class ( TFlatSpeedButton, IFWButton )
      published
       property Glyph stored False;
     End;

    TFSClose = class ( TFSSpeedButton,IFWButton )
      private
      public
       constructor Create ( AOwner : TComponent ) ; override;
       procedure Loaded; override;
       procedure Click; override;
      published
       property Width default CST_FWWIDTH_CLOSE_BUTTON ;
     End;

{ TFSOK }
   TFSOK = class ( TFSSpeedButton,IFWButton )
      public
       constructor Create ( AOwner : TComponent ) ; override;
       procedure Loaded; override;
     End;

{ TFSInsert }
   TFSInsert = class ( TFSSpeedButton,IFWButton )
      public
       constructor Create ( AOwner : TComponent ) ; override;
     End;
{ TFSAdd }
   TFSAdd = class ( TFSSpeedButton,IFWButton )
      public
       constructor Create ( AOwner : TComponent ) ; override;
     End;

{ TFSDelete }
  TFSDelete = class ( TFSSpeedButton,IFWButton )
     public
      constructor Create ( AOwner : TComponent ) ; override;
    End;

{ TFSDocument }
   TFSDocument = class ( TFSSpeedButton,IFWButton )
      public
       procedure Loaded; override;
     End;

{ TFSQuit }
   TFSQuit = class ( TFSSpeedButton,IFWButton )
      public
       constructor Create ( AOwner : TComponent ) ; override;
     End;

{ TFSErase }
   TFSErase = class ( TFSSpeedButton,IFWButton )
      public
       constructor Create ( AOwner : TComponent ) ; override;
     End;

{ TFSSaveAs }
   TFSSaveAs = class ( TFSSpeedButton,IFWButton )
      public
       constructor Create ( AOwner : TComponent ) ; override;
     End;

   { TFSLoad }
      TFSLoad = class ( TFSSpeedButton,IFWButton )
         private
         public
          constructor Create ( AOwner : TComponent ) ; override;
        End;

{ TFSPrint }
   TFSPrint = class ( TFSSpeedButton,IFWButton )
      public
       constructor Create ( AOwner : TComponent ) ; override;
     End;

{ TFSCancel }
   TFSCancel = class ( TFSSpeedButton,IFWButton )
      public
       constructor Create ( AOwner : TComponent ) ; override;
      published
       property Caption stored False;
     End;


{ TFSPreview }
   TFSPreview = class ( TFSSpeedButton,IFWButton )
      public
       procedure Loaded; override;
     End;

{ TFSNext }
   TFSNext = class ( TFSSpeedButton,IFWButton )
      public
       procedure Loaded; override;
     End;

{ TFSPrior }
   TFSPrior= class ( TFSSpeedButton,IFWButton )
      public
       procedure Loaded; override;
     End;

{ TFSCopy }
   TFSCopy = class ( TFSSpeedButton,IFWButton )
      private
      public
       constructor Create ( AOwner : TComponent ) ; override;
     End;

{ TFSInit }
   TFSInit = class ( TFSSpeedButton,IFWButton )
      public
       procedure Loaded; override;
     End;

{ TFSConfig }
   TFSConfig = class ( TFSSpeedButton,IFWButton )
      public
       procedure Loaded; override;
     End;

{ TFSImport }
   TFSImport = class ( TFSSpeedButton,IFWButton )
      public
       procedure Loaded; override;
     End;
{ TFSTrash }
   TFSTrash = class ( TFSSpeedButton,IFWButton )
      public
       procedure Loaded; override;
     End;

{ TFSExport }
   TFSExport = class ( TFSSpeedButton,IFWButton )
      public
       procedure Loaded; override;
     End;

{$IFDEF GROUPVIEW}

{ TFSGroupButton }

    { TFSGroupButtonActions }

    TFSGroupButtonActions = class ( TFSSpeedButton,IFWButton )
     public
      constructor Create ( AOwner : TComponent ) ; override;
     published
      property Width  default CST_WIDTH_BUTTONS_ACTIONS;
      property Height default CST_HEIGHT_BUTTONS_ACTIONS;
    end;


   { TFSBasket }

   TFSBasket = class ( TFSGroupButtonActions )
      public
       constructor Create ( AOwner : TComponent ) ; override;
      published
       property Caption stored False;
     End;

   { TFSRecord }

   TFSRecord = class ( TFSGroupButtonActions )
      public
       constructor Create ( AOwner : TComponent ) ; override;
      published
       property Caption stored False;
     End;

   { TFSGroupButtonMoving }

   TFSGroupButtonMoving = class ( TFSSpeedButton,IFWButton )
   public
    constructor Create ( AOwner : TComponent ) ; override;
   published
    property Width  default CST_WIDTH_BUTTONS_MOVING;
    property Height default CST_HEIGHT_BUTTONS_MOVING;
   end;
   { TFSOutSelect }
    TFSOutSelect = class ( TFSGroupButtonMoving )
       public
        procedure Loaded; override;
      End;

   { TFSOutAll }


   TFSOutAll = class ( TFSGroupButtonMoving )
      public
       procedure Loaded; override;
     End;

{ TFSInSelect }
   TFSInSelect = class ( TFSGroupButtonMoving )
      public
       procedure Loaded; override;
     End;

{ TFSInAll }
   TFSInAll = class ( TFSGroupButtonMoving )
      public
       procedure Loaded; override;
     End;

{$ENDIF}

implementation

uses {$IFDEF FPC}ObjInspStrConsts,
     {$ELSE}Consts, VDBConsts, {$ENDIF}
     unite_messages, Dialogs,
     Forms ;


{$IFNDEF FPC}
var Buttons_Appli_ResInstance             : THandle      = 0 ;
{$ENDIF}

procedure p_Load_Buttons_Appli ( const FGLyph : TBitmap; const as_Resource : String );
Begin
  {$IFDEF FPC}
    FGLyph.BeginUpdate;
    FGLyph.FreeImage;
    FGlyph.LoadFromLazarusResource( as_Resource );
    FGLyph.EndUpdate;
    FGLyph.Modified:=True;
  {$ELSE}
    if ( Buttons_Appli_ResInstance = 0 ) Then
      Buttons_Appli_ResInstance:= FindResourceHInstance(HInstance);
    FGlyph.Bitmap.LoadFromResourceName(Buttons_Appli_ResInstance, as_Resource );
  {$ENDIF}
end;

{ TFSTrash }

procedure TFSTrash.Loaded;
begin
  p_Load_Buttons_Appli ( Glyph, CST_FWTRASH );
  inherited Loaded;

end;

{ TFSLoad }

constructor TFSLoad.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  {$IFDEF FPC}
  caption := oiStdActFileOpenHint;
  {$ENDIF}
  p_Load_Buttons_Appli ( Glyph, CST_FWLOAD );
end;

{ TFSDocument }

procedure TFSDocument.Loaded;
begin
  p_Load_Buttons_Appli ( Glyph, CST_FWDOCUMENT );
  inherited Loaded;

end;

{ TFSDelete }

constructor TFSDelete.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  {$IFDEF FPC}
  Caption := srVK_DELETE;
  {$ELSE}
//  Caption := SDeleteRecord;
  {$ENDIF}
  p_Load_Buttons_Appli ( Glyph, CST_FWDELETE );
end;

{ TFSClose }


procedure TFSClose.Click;
begin
  if not assigned ( OnClick )
  and ( Owner is TCustomForm ) then
    with Owner as TCustomForm do
     Begin
      Close;
      Exit;
     End;
  inherited;

end;

constructor TFSClose.Create(AOwner: TComponent);
begin
  inherited;
  Caption := SCloseButton;
  Width := CST_FWWIDTH_CLOSE_BUTTON;
end;

procedure TFSClose.Loaded;
begin
  p_Load_Buttons_Appli ( Glyph, CST_FWCLOSE );
  inherited Loaded;

end;

{ TFSCancel }

constructor TFSCancel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  {$IFDEF FPC}
  Caption := oiStdActDataSetCancel1Hint;
  {$ELSE}
  Caption := SMsgDlgCancel;
  {$ENDIF}
  p_Load_Buttons_Appli ( Glyph, CST_FWCANCEL );
end;

{ TFSOK }

constructor TFSOK.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  {$IFDEF FPC}
  Caption := oisOk2;
  {$ELSE}
  Caption := SMsgDlgOK;
  {$ENDIF}
end;

procedure TFSOK.Loaded;
begin
  p_Load_Buttons_Appli ( Glyph, CST_FWOK );
  inherited Loaded;

end;

{ TFSInsert }

constructor TFSInsert.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  {$IFDEF FPC}
  Caption := srVK_INSERT;
  {$ELSE}
  Caption := SInsertRecord;
  {$ENDIF}
  p_Load_Buttons_Appli ( Glyph, CST_FWINSERT );
end;

{ TFSAdd }

constructor TFSAdd.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  p_Load_Buttons_Appli ( Glyph, CST_FWINSERT );
end;

{ TFSSaveAs }

constructor TFSSaveAs.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  {$IFDEF FPC}
  caption := oiStdActFileSaveAsHint;
  {$ENDIF}
  p_Load_Buttons_Appli ( Glyph, CST_FWSAVEAS );
end;

{ TFSQuit }

constructor TFSQuit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Caption := SCloseButton {$IFDEF FPC}+ ' ' + oisAll{$ENDIF};
  p_Load_Buttons_Appli ( Glyph, CST_FWQUIT );
end;

{ TFSerase }

constructor TFSErase.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  {$IFDEF FPC}
  Caption := oisDelete;
  {$ELSE}
  //Caption := SDeleteRecord;
  {$ENDIF}
  p_Load_Buttons_Appli ( Glyph, CST_FWERASE );
end;

{ TFSPrint }

constructor TFSPrint.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  {$IFDEF FPC}
  Caption := srVK_PRINT;
  {$ENDIF}
  p_Load_Buttons_Appli ( Glyph, CST_FWPRINT );
end;

{ TFSNext }

procedure TFSNext.Loaded;
begin
  p_Load_Buttons_Appli ( Glyph, CST_FWNEXT );
  inherited Loaded;

end;
{ TFSPrior }

procedure TFSPrior.Loaded;
begin
  p_Load_Buttons_Appli ( Glyph, CST_FWPRIOR );
  inherited Loaded;

end;

{ TFSPreview }

procedure TFSPreview.Loaded;
begin
  p_Load_Buttons_Appli ( Glyph, CST_FWPREVIEW );
  inherited Loaded;

end;

{ TFSInit }

procedure TFSInit.Loaded;
begin
  p_Load_Buttons_Appli ( Glyph, CST_FWINIT );
  inherited Loaded;

end;

{ TFSConfig }

procedure TFSConfig.Loaded;
begin
  p_Load_Buttons_Appli ( Glyph, CST_FWCONFIG );
  inherited Loaded;

end;

{ TFSImport }

procedure TFSImport.Loaded;
begin
  p_Load_Buttons_Appli ( Glyph, CST_FWIMPORT );
  inherited Loaded;

end;

{ TFSExport }

procedure TFSExport.Loaded;
begin
  p_Load_Buttons_Appli ( Glyph, CST_FWEXPORT );
  inherited Loaded;

end;

{ TFSCopy }

constructor TFSCopy.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  {$IFDEF FPC}
  Caption := oiStdActEditCopyShortHint;
  {$ENDIF}
  p_Load_Buttons_Appli ( Glyph, CST_FWCOPY );
end;

{$IFDEF GROUPVIEW}

{ TFSOutSelect }

procedure TFSOutSelect.Loaded;
begin
  p_Load_Buttons_Appli ( Glyph, CST_FWOUTSELECT );
  inherited Loaded;

end;

{ TFSBasket }

constructor TFSBasket.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  {$IFDEF FPC}
  Caption := oisUndo;
  {$ELSE}
  Caption := Gs_GROUPVIEW_Basket;
  {$ENDIF}
  p_Load_Buttons_Appli ( Glyph, CST_FWBASKET );
end;

{ TFSRecord }

constructor TFSRecord.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  {$IFDEF FPC}
  Caption := oisRecord;
  {$ELSE}
  Caption := Gs_GROUPVIEW_Record;
  {$ENDIF}
  p_Load_Buttons_Appli ( Glyph, CST_FWOK );
end;

{ TFSOutAll }

procedure TFSOutAll.Loaded;
begin
  p_Load_Buttons_Appli ( Glyph, CST_FWOUTALL );
  inherited Loaded;

end;

{ TFSInSelect }

procedure TFSInSelect.Loaded;
begin
  p_Load_Buttons_Appli ( Glyph, CST_FWINSELECT );
  inherited Loaded;

end;

{ TFSInAll }

procedure TFSInAll.Loaded;
begin
  p_Load_Buttons_Appli ( Glyph, CST_FWINALL );
  inherited Loaded;

end;



{ TFSGroupButtonActions }

constructor TFSGroupButtonActions.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Width  := CST_WIDTH_BUTTONS_ACTIONS;
  Height := CST_HEIGHT_BUTTONS_ACTIONS;
end;

{ TFSGroupButtonMoving }

constructor TFSGroupButtonMoving.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Width  := CST_WIDTH_BUTTONS_MOVING;
  Height := CST_HEIGHT_BUTTONS_MOVING;
  Caption := '';
end;

{$ENDIF}


initialization
{$IFDEF VERSIONS}
  p_ConcatVersion ( gVer_buttons_ext  );
{$ENDIF}

end.
