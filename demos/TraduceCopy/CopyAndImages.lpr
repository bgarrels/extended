program CopyAndImages;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms
  { you can add units after this }, U_FormCopy, u_aboutbox,
  lazrichview, JvXPBarLaz, lazextcomponents, ExtCopy, lazmanframes;

begin
  Application.Initialize;
  Application.CreateForm ( TF_Copier, F_Copier );
  Application.CreateForm ( tF_AboutBox, F_AboutBox );
  Application.Run;
end.
