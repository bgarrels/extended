{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit ExtCopy; 

interface

uses
    u_traducefile, U_ExtFileCopy, u_regextfilecopy, fonctions_file, 
  u_extabscopy, u_extractfile, unit_messagescopy, LazarusPackageIntf;

implementation

procedure Register; 
begin
  RegisterUnit('u_regextfilecopy', @u_regextfilecopy.Register); 
end; 

initialization
  RegisterPackage('ExtCopy', @Register); 
end.
