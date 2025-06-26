unit uMain2;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects, FMX.Controls.Presentation, FMX.ListBox, FMX.Layouts;

type
  TformMain2 = class(TForm)
    S: TImage;
    klijent: TLayout;
    ComboBox1: TComboBox;
    Button1: TButton;
    Button2: TButton;
    Text2: TText;
    usernameLabel: TLabel;
    ComboBox2: TComboBox;
    Label1: TLabel;
    ComboBox3: TComboBox;
    Label2: TLabel;
    ComboBox4: TComboBox;
    Label3: TLabel;
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  formMain2: TformMain2;

implementation

uses umain;

{$R *.fmx}

procedure TformMain2.Button1Click(Sender: TObject);
begin
    showmessage('Nije u funkciji');
end;

procedure TformMain2.Button2Click(Sender: TObject);
begin
   formMain2.hide;
   formMain.show;
end;

end.
