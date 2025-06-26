program Project1;

uses
  System.StartUpCopy,
  FMX.Forms,
  Unit1 in 'Unit1.pas' {Form1},
  uDM in 'uDM.pas' {Baza},
  uMain in 'uMain.pas' {formMain},
  uMain2 in 'uMain2.pas' {formMain2};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TBaza, Baza);
  Application.CreateForm(TformMain, formMain);
  Application.CreateForm(TformMain2, formMain2);
  Application.Run;
end.
