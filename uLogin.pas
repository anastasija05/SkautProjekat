unit uLogin;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.Objects, FMX.Edit, FMX.Controls.Presentation, FMX.StdCtrls, uRegister, uLoginZaposleni, uDM, uMain, uRezervacija, uIstorija;

type
  TformLogin = class(TForm)
    loginSlika: TImage;
    footer: TLayout;
    header: TLayout;
    klijent: TLayout;
    forestTekst: TText;
    drvoSlika: TImage;
    usernameLinija: TLine;
    usernameLabel: TLabel;
    editUsername: TEdit;
    sifraLinija: TLine;
    labelSifra: TLabel;
    editSifra: TEdit;
    Text1: TText;
    buttonLogin: TButton;
    registracijaText: TText;
    zaposleniText: TText;
    cbPrikaziSifru: TCheckBox;
    procedure registracijaTextClick(Sender: TObject);
    procedure zaposleniTextClick(Sender: TObject);
    procedure buttonLoginClick(Sender: TObject);
    procedure cbPrikaziSifruChange(Sender: TObject);
  private
    { Private declarations }
  public
     GuestName, GuestLastName, GuestEmail, GuestPhone, GuestUsername, GuestPassword, username: string;
     GuestID: integer;
  end;

var
  formLogin: TformLogin;

implementation

uses uNalog;

{$R *.fmx}

procedure TformLogin.buttonLoginClick(Sender: TObject);
var pwd: string;
begin
    username := editUsername.Text;
    if trim(editUsername.Text)='' then
      begin
        ShowMessage('Molimo vas unesite korisnicko ime!');
        editUsername.SetFocus;
      end;
    if trim(editSifra.Text)='' then
      begin
        ShowMessage('Molimo vas unesite sifru!');
        editUsername.SetFocus;
      end
    else
      begin
      //PROVERA DA LI USERNAME I SIFRA POSTOJI U BAZI
        with baza do begin
          dm.open;
          qtemp.sql.clear;
          qtemp.SQL.Text:='Select * FROM gosti WHERE username= '+quotedstr(editUsername.text);
          qtemp.Open;
            if qtemp.RecordCount > 0 then
              begin
                pwd:=qtemp.FieldByName('sifra').AsString;
                if pwd= editSifra.Text then
                  begin
                    // Pretpostavimo da ste provjerili korisničko ime i lozinku i da je prijava uspješna.
                    // Dohvatite ID gosta na temelju korisničkog imena.
                    qtemp.SQL.Text := 'SELECT gostID FROM gosti WHERE username = :username;';
                    qtemp.ParamByName('username').AsString := editUsername.Text; // Zamijenite s pravim poljem za korisničko ime
                    qtemp.Open;
                    GuestID := qtemp.FieldByName('gostID').AsInteger;
                    qtemp.Close;
                    // Sada kad imate ID gosta, možete dohvatiti njihovo ime iz baze.
                    qtemp.SQL.Text := 'SELECT ime, prezime, broj_telefona, email, sifra, username FROM gosti WHERE gostID = :gostID;';
                    qtemp.ParamByName('gostID').AsInteger := GuestID;
                    qtemp.Open;
                    GuestName := qtemp.FieldByName('ime').AsString;
                    GuestLastName := qtemp.FieldByName('prezime').AsString;
                    GuestEmail := qtemp.FieldByName('email').AsString;
                    GuestPhone := qtemp.FieldByName('broj_telefona').AsString;
                    GuestUsername := qtemp.FieldByName('username').AsString;
                    GuestPassword := qtemp.FieldByName('sifra').AsString;
                    qtemp.Close;

                    // Za NALOG
                    formNalog.email := GuestEmail;
                    formNalog.username := GuestUsername;
                    formNalog.ime := GuestName;
                    formNalog.prezime := GuestLastName;
                    formNalog.password := GuestPassword;
                    formNalog.telefon := GuestPhone;
                    //Za Rezervaciju
                    formRezervacija.idgosta := GuestID;
                    //Za istoriju
                    formIstorija.idgosta := GuestID;

                    formLogin.Hide;
                    if not Assigned(formMain) then
                    formMain:= tformmain.Create(self);
                    formMain.ShowModal(
                                      procedure(Modalresult: TmodalResult)
                                        begin
                                          if ModalResult = mrClose then Application.Terminate
                                        end);
                  end
              else
                 begin
                  ShowMessage('Pogresna Sifra!');
                 end;
              end
            else begin
              ShowMessage('Korisnicko ime nije validno!')
            end;
           end;
          end;
        end;

///// ZATVARANJE I OTVARANJE REGISTERA I ZAPOSLENI LOGINA!
procedure TformLogin.cbPrikaziSifruChange(Sender: TObject);
begin
 editSifra.Password:= not cbPrikaziSifru.IsChecked;
end;

procedure TformLogin.registracijaTextClick(Sender: TObject);
begin

 Hide;

 formRegister.Show;

end;

procedure TformLogin.zaposleniTextClick(Sender: TObject);
begin
    Hide;

    formLoginZaposleni.Show;
end;

end.
