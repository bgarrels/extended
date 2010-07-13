unit U_ExtDBImage;

interface

{$i ..\extends.inc}
{$IFDEF FPC}
{$Mode Delphi}
{$ENDIF}

uses Graphics,
{$IFDEF TNT}
     TntExtCtrls,
{$ELSE}
     ExtCtrls,
{$ENDIF}
     DB, DBCtrls,
     Classes;

type TExtDBImage = class( {$IFDEF TNT}TTntImage{$ELSE}TImage{$ENDIF} )
     private
       FDataLink: TFieldDataLink;
       procedure p_SetDatafield  ( const Value : String );
       procedure p_SetDatasource ( const Value : TDatasource );
       function  fds_GetDatasource : TDatasource;
       function  fs_GetDatafield : String;
     protected
       procedure p_ActiveChange(Sender: TObject); virtual;
       procedure p_DataChange(Sender: TObject); virtual;
       procedure p_UpdateData(Sender: TObject); virtual;
       procedure p_SetImage ; virtual;
     public
       procedure LoadFromStream ( const astream : TStream ); virtual;
       function  LoadFromFile   ( const afile   : String ):Boolean; virtual;
       constructor Create(AOwner: TComponent); override;
       destructor Destroy ; override;
     published
       property Datafield : String read fs_GetDatafield write p_SetDatafield ;
       property Datasource : TDatasource read fds_GetDatasource write p_SetDatasource ;
     end;


implementation

uses fonctions_images, Controls;

{ TExtDBImage }

procedure TExtDBImage.p_ActiveChange(Sender: TObject);
begin
  p_SetImage;
end;

constructor TExtDBImage.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDataLink := TFieldDataLink.Create ;
  FDataLink.DataSource := nil ;
  FDataLink.FieldName  := '' ;
  FDataLink.Control := Self;
  FDataLink.OnDataChange := p_DataChange;
  FDataLink.OnUpdateData := p_UpdateData;
  FDataLink.OnActiveChange := p_ActiveChange;
end;

procedure TExtDBImage.p_DataChange(Sender: TObject);
begin
  p_SetImage;
end;

destructor TExtDBImage.Destroy;
begin
  FDataLink.Free;
  inherited;
end;

function TExtDBImage.fs_GetDatafield: String;
begin
  if assigned ( FDataLink ) then
    Begin
      Result := FDataLink.FieldName ;
    End
   Else
    Result := '';

end;

function TExtDBImage.LoadFromFile(const afile: String):Boolean;
begin
  Result := False;
  if  assigned ( FDataLink.Field ) then
    Begin
      p_SetImageFileToField(afile, FDataLink.Field, Picture, True);
      Result := True;
    End;
end;

procedure TExtDBImage.LoadFromStream(const astream: TStream);
begin
  p_SetStreamToImage( astream, Picture, True );
end;

function TExtDBImage.fds_GetDatasource: TDatasource;
begin
  if assigned ( FDataLink ) then
    Begin
      Result := FDataLink.Datasource ;
    End
   Else
    Result := Datasource;

end;

procedure TExtDBImage.p_SetDatafield(const Value: String);
begin
  if assigned ( FDataLink )
  and ( Value <> FDataLink.FieldName ) then
    Begin
      FDataLink.FieldName := Value;
    End;
end;

procedure TExtDBImage.p_SetDatasource(const Value: TDatasource);
begin
  if assigned ( FDataLink )
  and ( Value <> FDataLink.Datasource ) then
    Begin
      FDataLink.Datasource := Value;
    End;
end;

procedure TExtDBImage.p_SetImage;
begin
  if assigned ( FDataLink )
  and FDataLink.Active
  and assigned ( FDataLink.Field )
  and not FDataLink.Field.IsNull Then
    Begin
      p_SetFieldToImage ( FDataLink.Field, Self.Picture, True );
    End
   Else
    Picture.Bitmap.Assign(nil);
end;

procedure TExtDBImage.p_UpdateData(Sender: TObject);
begin
  p_SetImage;
end;

end.
