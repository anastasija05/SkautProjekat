unit Unit1;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.Objects, FMX.Edit, FMX.Controls.Presentation, FMX.StdCtrls, uDM;

type
  TForm1 = class(TForm)
    loginSlika: TImage;
    footer: TLayout;
    header: TLayout;
    klijent: TLayout;
    usernameLinija: TLine;
    usernameLabel: TLabel;
    editUsername: TEdit;
    sifraLinija: TLine;
    labelSifra: TLabel;
    editSifra: TEdit;
    Text1: TText;
    buttonLogin: TButton;
    registracijaText: TText;
    cbPrikaziSifru: TCheckBox;
    Text2: TText;
    Text3: TText;
    procedure cbPrikaziSifruChange(Sender: TObject);
    procedure buttonLoginClick(Sender: TObject);
    procedure registracijaTextClick(Sender: TObject);
    procedure Text3Click(Sender: TObject);
  private
    { Private declarations }
  public
    GuestName, GuestLastName, GuestEmail, GuestPhone, GuestUsername, GuestPassword, username: string;
    GuestID: Integer;
  end;

var
  Form1: TForm1;

implementation

uses uMain;

{$R *.fmx}

procedure TForm1.buttonLoginClick(Sender: TObject);
var
  PwdDB: string;
begin
  // 1) Provera praznih polja
  if Trim(editUsername.Text) = '' then
  begin
    ShowMessage('Molimo vas unesite korisničko ime!');
    editUsername.SetFocus;
    Exit;
  end;

  if Trim(editSifra.Text) = '' then
  begin
    ShowMessage('Molimo vas unesite šifru!');
    editSifra.SetFocus;
    Exit;
  end;

  // 2) Povezivanje na bazu (ako već nije)
  if not Baza.dm.Connected then
    Baza.dm.Connected := True;

  // 3) Provera korisnika
  with Baza.Qtemp do
  begin
    Close;
    SQL.Clear;
    SQL.Text :=
      'SELECT gostID, ime, prezime, email, telefon, username, sifra ' +
      'FROM gosti WHERE username = :username';
    ParamByName('username').AsString := editUsername.Text;
    Open;

    if IsEmpty then
    begin
      ShowMessage('Korisničko ime nije validno!');
      Exit;
    end;

    // 4) Provera šifre
    PwdDB := FieldByName('sifra').AsString;
    if PwdDB <> editSifra.Text then
    begin
      ShowMessage('Pogrešna šifra!');
      Exit;
    end;

    // 5) Uspesan login → čuvamo podatke o gostu
    GuestID       := FieldByName('gostID').AsInteger;
    GuestName     := FieldByName('ime').AsString;
    GuestLastName := FieldByName('prezime').AsString;
    GuestEmail    := FieldByName('email').AsString;
    GuestPhone    := FieldByName('telefon').AsString;
    GuestUsername := FieldByName('username').AsString;
    GuestPassword := PwdDB;

    username := GuestUsername;

    // 6) Otvaranje glavne forme
    Self.Hide;
    if not Assigned(formMain) then
      formMain := TformMain.Create(Self);

    formMain.ShowModal(
      procedure(ModalResult: TModalResult)
      begin
        if ModalResult = mrClose then
          Application.Terminate;
      end
    );
  end;
end;

procedure TForm1.cbPrikaziSifruChange(Sender: TObject);
begin
  editSifra.Password := not cbPrikaziSifru.IsChecked;
end;

procedure TForm1.registracijaTextClick(Sender: TObject);
begin
  ShowMessage('Ova opcija je još u izradi!');
end;

procedure TForm1.Text3Click(Sender: TObject);
begin
  ShowMessage('Ova opcija je još u izradi!');
end;

end.

