{ Ce fichier a �t� automatiquement cr�� par Lazarus. Ne pas l'�diter !
Cette source est seulement employ�e pour compiler et installer le paquet.
 }

unit lazcopy; 

interface

uses
  U_ExtFileCopy, u_traducefile, LazarusPackageIntf; 

implementation

procedure Register; 
begin
  RegisterUnit('U_ExtFileCopy', @U_ExtFileCopy.Register); 
  RegisterUnit('u_traducefile', @u_traducefile.Register); 
end; 

initialization
  RegisterPackage('lazcopy', @Register); 
end.
