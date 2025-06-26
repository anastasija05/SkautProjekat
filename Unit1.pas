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
     GuestID: integer;
  end;

var
  Form1: TForm1;

implementation
        uses uMain;
{$R *.fmx}

procedure TForm1.buttonLoginClick(Sender: TObject);
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
                    qtemp.SQL.Text := 'SELECT gostID FROM gosti WHERE username = :username;';
                    qtemp.ParamByName('username').AsString := editUsername.Text;

                    form1.Hide;
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

procedure TForm1.cbPrikaziSifruChange(Sender: TObject);
begin
 editSifra.Password:= not cbPrikaziSifru.IsChecked;
end;

procedure TForm1.registracijaTextClick(Sender: TObject);
begin
  ShowMessage('Ova opcija je jos u izradi!');
end;

procedure TForm1.Text3Click(Sender: TObject);
begin
  ShowMessage('Ova opcija je jos u izradi!');
end;

end.
