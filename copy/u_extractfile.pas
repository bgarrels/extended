﻿unit u_extractfile;
{
Composant TExtractFile

Développé par:
Matthieu GIROUX
Licence LGPL

Composant non visuel permettant d'estraire d'un fichier

}
interface

{$IFDEF FPC}
{$mode Delphi}
{$ENDIF}

uses
  SysUtils, Classes,
{$IFDEF VERSIONS}
   fonctions_version,
{$ENDIF}
   U_ExtAbsCopy,
   DB;

{$IFDEF VERSIONS}
const
    gVer_TExtractFile : T_Version = ( Component : 'Composant TExtractFile' ;
                                               FileUnit : 'U_Extractfile' ;
                                               Owner : 'Matthieu Giroux' ;
                                               Comment : 'Extraction dans des fichiers.' ;
                                               BugsStory : '0.9.0.0 : Gestion en place.';
                                               UnitType : 3 ;
                                               Major : 0 ; Minor : 9 ; Release : 0 ; Build : 0 );

{$ENDIF}
type

    { TExtractFile }
    TEExtractOption = (eoCaseSentitive,eoMail,eoUnique);
    TEExtractOptions = set of TEExtractOption;


type

   { TExtExtractColumn }

   TExtExtractColumn = class(TCollectionItem)
   private
     FFieldName : String;
     FExtractChars, FExtractEnd : String ;
     FRight, FLeft : Boolean;
     procedure SetLeft  ( AValue : Boolean );
     procedure SetRight ( AValue : Boolean );
     procedure SetFieldName(const AValue: String);
   public
     constructor Create(ACollection: TCollection); override;
   published
     property TakeLeft  : Boolean     read FLeft  write SetLeft  default True;
     property TakeRight : Boolean     read FRight write SetRight default True;
     property FieldName : String read FFieldName write SetFieldName;
     property ExtractChars : String   read FExtractChars write FExtractChars;
     property ExtractEnd   : String   read FExtractEnd   write FExtractEnd;
   end;

   TExtExtractColumnClass = class of TExtExtractColumn;
   { TExtExtractColumns }

   TExtExtractColumns = class(TCollection)
   private
     function GetColumn ( Index: Integer): TExtExtractColumn;
     procedure SetColumn( Index: Integer; const Value: TExtExtractColumn);
   public
     function Add: TExtExtractColumn;
     {$IFDEF FPC}
    published
     {$ENDIF}
     property Items[Index: Integer]: TExtExtractColumn read GetColumn write SetColumn; default;
   end;


    TExtractFile = class(TAbsFileCopy, IFileCopyComponent)
     private
       FColumnsExtract : TExtExtractColumns;
       FExtractOptions : TEExtractOptions;
       FOnChange : TEChangeDirectoryEvent ;
       FOnSuccess : TECopyFinishEvent;
       FOnFailure : TECopyErrorEvent ;
       FBeforeExtract : TEReturnEvent ;
       FOnProgress       : TECopyEvent;
       FSource : String;
       FDestination : TDatasource;
       FInProgress : Boolean;
       procedure SetDestination(const AValue: TDataSource);
       procedure SetSource(const AValue: String);
     protected
       FInited : Boolean;
       function IsCopyOk(const ai_Error: Integer;  as_Message: String): Boolean; override;
       function  BeforeCopy : Boolean ; virtual;
       function CreateDestination ( const as_Destination : String ): Boolean; virtual;
       function GetColumns: TExtExtractColumns; virtual;
       function CreateColumns: TExtExtractColumns; virtual;
       procedure SetColumns(const AValue: TExtExtractColumns); virtual;
       { Déclarations protégées }
     public
       constructor Create ( AOwner : TComponent ) ; override;
       function InternalDefaultCopyFile  ( const as_Source, as_Destination : String ):Boolean; virtual;
       procedure InternalFinish ( const as_Source, as_Destination : String ); virtual;
       procedure PrepareCopy ; virtual;
       property InProgress : Boolean read FInprogress;
       Procedure CopySourceToDestination; virtual;
       destructor Destroy;override;
     published
       property ColumnsExtract: TExtExtractColumns read GetColumns write SetColumns;
       property ExtractOptions : TEExtractOptions read FExtractOptions write FExtractOptions;
       property DirSource : String read FSource write SetSource;
       property DataSource : TDatasource read FDestination write SetDestination;
       property OnSuccess : TECopyFinishEvent read FOnSuccess write FOnSuccess;
       property OnFailure : TECopyErrorEvent read FOnFailure write FOnFailure;
       property OnProgress : TECopyEvent read FOnProgress write Fonprogress;
       property OnBeforeExtract : TEReturnEvent read FBeforeExtract write FBeforeExtract;
       property OnChange : TEChangeDirectoryEvent read FOnChange write FOnChange;
     end;

implementation

uses Forms, TypInfo, StrUtils, Dialogs;

{ TExtExtractColumns }

function TExtExtractColumns.GetColumn(Index: Integer): TExtExtractColumn;
begin
  Result:=Items[index] as TExtExtractColumn;
end;

procedure TExtExtractColumns.SetColumn(Index: Integer;
  const Value: TExtExtractColumn);
begin
  Items[Index]:=Value;
end;

function TExtExtractColumns.Add: TExtExtractColumn;
begin
  Result:=Inherited Add as TExtExtractColumn;
end;

{ TExtExtractColumn }

procedure TExtExtractColumn.SetLeft(AValue: Boolean);
begin
  // need a true value
  if  not AValue
  and not FRight Then
   Exit;
  FLeft:=AValue;
end;

procedure TExtExtractColumn.SetRight(AValue: Boolean);
begin
  // need a true value
  if  not AValue
  and not FLeft Then
   Exit;
  FRight:=AValue;
end;

procedure TExtExtractColumn.SetFieldName(const AValue: String);
begin
  if AValue <> FFieldName Then
   Begin
     FFieldName:= AValue;
   end;
end;

constructor TExtExtractColumn.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FLeft :=True;
  FRight:=True;
end;

{TExtractFile}

// DoInit TExtractFile component
constructor TExtractFile.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FInited := False;
  FInProgress := False;
  FColumnsExtract:=CreateColumns;
end;

// destination property
procedure TExtractFile.SetDestination(const AValue: TDataSource);
begin
  if FDestination <> AValue Then
    Begin
      FDestination := AValue;
    End;
end;

// Source property and event
procedure TExtractFile.SetSource(const AValue: String);
begin
  if FSource <> AValue Then
    Begin
      FSource := AValue;
      if not ( csDesigning in ComponentState )
      and Assigned ( FOnChange )
       Then
        FOnChange ( Self, FSource, '' );
    End;
end;

// Event BeforeExtract
function TExtractFile.BeforeCopy: Boolean;
begin
  Result := True ;
  if  assigned ( FDestination )
  and assigned ( FDestination.DataSet ) Then
   with FDestination.Dataset do
    try
      if Active Then
        Exit;
      Open;
      if FColumnsExtract.Count <= 0 Then
        Result := False ;
    Except
      Result := False ;
    end
   Else
    Result := False;
  if Assigned ( FBeforeExtract ) Then
    FBeforeExtract ( Self, Result );

end;

function TExtractFile.CreateDestination(const as_Destination: String): Boolean;
begin
  Result := True;
end;

function TExtractFile.GetColumns: TExtExtractColumns;
begin
  Result := FColumnsExtract;
end;

function TExtractFile.CreateColumns: TExtExtractColumns;
begin
  Result:=TExtExtractColumns.Create(TExtExtractColumn);
end;

procedure TExtractFile.SetColumns(const AValue: TExtExtractColumns);
begin
  FColumnsExtract.Assign(AValue);
end;

// verifying Extractd copy
function TExtractFile.IsCopyOk ( const ai_Error : Integer ;  as_Message : String ):Boolean;
begin
  Result := True ;
  if  ( ai_Error <> 0 ) then
    Begin
      if assigned ( FOnFailure ) then
        Begin
            FOnFailure ( Self, ai_Error, as_Message, Result );
        End ;
    End ;
End ;
// Internal finish
procedure TExtractFile.InternalFinish ( const as_Source, as_Destination : String );
begin
  if assigned ( FOnSuccess ) then
    Begin
        FOnSuccess ( Self, as_Source, as_Destination, 0 );
    End ;
End ;

procedure TExtractFile.PrepareCopy;
begin

end;
function TExtractFile.InternalDefaultCopyFile  ( const as_Source, as_Destination : String ):Boolean;
var lstl_Strings : TStringList;
    ls_Temp, ls_temp2 : String;
    li_Begin,
    li_end,
    li_i, li_j : Integer;

    function fb_IsCorrectChar ( const ai_pos : Integer ):boolean;
    Begin
      Result := ( ls_Temp [ ai_pos ] in ['0'..'9','A'..'Z','a'..'z'] )or (( eoMail in ExtractOptions )and ( ls_Temp [ ai_pos ] in ['.','-'] ));
    End;
    procedure p_MiddleExtract ( const AColumn : TExtExtractColumn; var ai_BeginEnd : Integer; const ab_Prior : Boolean );
    Begin
      with AColumn do
      if FLeft and FRight Then
      Begin
        ai_BeginEnd := pos ( FExtractChars, ls_Temp );
        if ab_Prior Then
         Begin
           while (li_Begin>1 ) and fb_IsCorrectChar ( li_Begin - 1 )
             do
              Dec ( li_Begin );
         end
        Else
        Begin
          while (li_end<length(ls_Temp)) and fb_IsCorrectChar ( li_end + 1 )
            do
             Inc ( li_end );
        end

      end;
    End;

Begin
  Result := True;
  if FileExists(as_Source) Then
   Begin
    lstl_Strings := TStringList.Create;
    try
     lstl_Strings.LoadFromFile(as_Source);
     for li_i := 0 to lstl_Strings.Count - 1 do
     for li_j := 0 to FColumnsExtract.Count - 1 do
     with FColumnsExtract [ li_j ] do
      if FExtractChars > '' then
       Begin
         ls_Temp:=lstl_Strings [ li_i ];
         li_Begin := pos ( FExtractChars, ls_Temp );
         if  ( li_Begin > 0 ) Then
           Begin
             if not FLeft
              Then li_end:=posEx ( FExtractChars, ls_Temp, li_Begin + length ( FExtractChars ) )
              else if FRight Then
                 p_MiddleExtract ( FColumnsExtract [ li_j ], li_end, False );
             if ( li_end > 0 )
              Then
               Begin
                ls_temp2:=copy ( ls_Temp, li_Begin + length ( FExtractChars ), li_end - li_Begin - length ( FExtractChars )+1);
                with FDestination.DataSet do
                 if not ( eoUnique in FExtractOptions ) or not Locate(FFieldName,ls_temp2,[loCaseInsensitive]) Then
                 Begin
                   Append;
//                   ShowMessage(copy ( ls_Temp, li_Begin + length ( FBeginExtract ), li_end - li_Begin - length ( FBeginExtract )));
                   FieldByName(FFieldName).Value:=ls_temp2;
                   Post;
                 end;
               end;

           end;
       end;
    finally
      lstl_Strings.Free;
    end;
   End;
  InternalFinish(as_Source,as_Destination);
end;

// overrided Copy to Extract image file
procedure TExtractFile.CopySourceToDestination;
begin
  Finprogress := true;
  if not FileExists ( FSource )
  or not assigned ( FDestination )
  or not assigned ( FDestination.Dataset )
   Then
    Exit ;
  try
    InternalDefaultCopyFile ( FSource, '' );
  finally
    FinProgress := false;
  End ;
end;

destructor TExtractFile.Destroy;
begin
  inherited Destroy;
end;

{$IFDEF VERSIONS}
initialization
  p_ConcatVersion ( gVer_TExtractFile );
{$ENDIF}
end.
