unit uMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts, Unit1, FMX.ListBox,
  FMX.Edit;

type
  TformMain = class(TForm)
    S: TImage;
    klijent: TLayout;
    Text2: TText;
    usernameLabel: TLabel;
    ComboBox1: TComboBox;
    Button1: TButton;
    Button2: TButton;
    ListBoxItem1: TListBoxItem;
    ListBoxItem2: TListBoxItem;
    ListBoxItem3: TListBoxItem;
    ListBoxItem4: TListBoxItem;
    ListBoxItem5: TListBoxItem;
    btnProdaja: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure btnProdajaClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  formMain: TformMain;


implementation

uses uMain2,uProdaja ;


{$R *.fmx}

procedure TformMain.btnProdajaClick(Sender: TObject);
begin
  Self.Hide;
  if not Assigned(frmProdaja) then
    frmProdaja := TfrmProdaja.Create(Self);
  frmProdaja.Show;
end;

procedure TformMain.Button1Click(Sender: TObject);
begin
    formMain.Hide;
    formMain2.show;
end;

procedure TformMain.Button2Click(Sender: TObject);
begin
    formMain.hide;
    form1.show;
end;


end.
