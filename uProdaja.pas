unit uProdaja;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects, FMX.Edit, FMX.Controls.Presentation, FMX.Layouts, FMX.Memo.Types,
  FMX.ListView.Types, FMX.ListView.Appearances, FMX.ListView.Adapters.Base,
  FMX.ListView, FMX.ScrollBox, FMX.Memo, FMX.ListBox,
  Data.DB, FireDAC.Comp.Client, FireDAC.Stan.Param,
  uDM;

type
  TfrmProdaja = class(TForm)
    loginSlika: TImage;
    footer: TLayout;
    header: TLayout;
    klijent: TLayout;
    lbIgrac: TLabel;
    lbKupac: TLabel;
    lbCena: TLabel;
    cbIgrac: TComboBox;
    cbKupac: TComboBox;
    edCena: TEdit;
    edVazido: TEdit;
    mmNapomena: TMemo;
    lbNapomena: TLabel;
    lvPonude: TListView;
    btnKrairajPonudu: TButton;
    btnPrihvati: TButton;
    btnOdbij: TButton;
    procedure FormCreate(Sender: TObject);
    procedure cbIgracChange(Sender: TObject);
    procedure btnKrairajPonuduClick(Sender: TObject);
    procedure btnPrihvatiClick(Sender: TObject);
    procedure btnOdbijClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    procedure LoadIgraci;
    procedure LoadKupci;
    procedure LoadPonudeZaIgraca(AIgracID: Integer);
    function  ComboItemID(ACombo: TComboBox): Integer;
    function  SelectedPonudaID: Integer;
    procedure Audit(const AEntitet: string; AID: Integer; const AAkcija, ADetalji: string);
  public
  end;

var
  frmProdaja: TfrmProdaja;

implementation

uses umain;

{$R *.fmx}

{=========================== Lifecycle ===========================}

procedure TfrmProdaja.FormCreate(Sender: TObject);
begin
  if not Baza.dm.Connected then
    Baza.dm.Connected := True;

  LoadIgraci;
  LoadKupci;

  if cbIgrac.Items.Count > 0 then
  begin
    cbIgrac.ItemIndex := 0;
    cbIgracChange(cbIgrac);
  end;

  // default rok ponude (YYYY-MM-DD)
  edVazido.Text := FormatDateTime('yyyy-mm-dd', Now + 7);
end;

{=========================== Loading =============================}

procedure TfrmProdaja.LoadIgraci;
var Q: TFDQuery;
begin
  cbIgrac.Clear;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Baza.dm;
    Q.SQL.Text :=
      'SELECT igrac_id, ime || '' '' || prezime AS full_name ' +
      'FROM igraci ORDER BY prezime, ime';
    Q.Open;
    while not Q.Eof do
    begin
      cbIgrac.Items.AddObject(
        Q.FieldByName('full_name').AsString,
        TObject(Q.FieldByName('igrac_id').AsInteger)
      );
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

procedure TfrmProdaja.LoadKupci;
var Q: TFDQuery;
begin
  cbKupac.Clear;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Baza.dm;
    Q.SQL.Text := 'SELECT klub_id, naziv FROM klubovi ORDER BY naziv';
    Q.Open;
    while not Q.Eof do
    begin
      cbKupac.Items.AddObject(
        Q.FieldByName('naziv').AsString,
        TObject(Q.FieldByName('klub_id').AsInteger)
      );
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

procedure TfrmProdaja.cbIgracChange(Sender: TObject);
begin
  if cbIgrac.ItemIndex >= 0 then
    LoadPonudeZaIgraca(ComboItemID(cbIgrac));
end;

procedure TfrmProdaja.LoadPonudeZaIgraca(AIgracID: Integer);
var
  Q: TFDQuery;
  Item: TListViewItem;
begin
  lvPonude.Items.Clear;

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Baza.dm;
    Q.SQL.Text :=
      'SELECT p.ponuda_id, k.naziv AS klub, p.cena, p.status, p.vazido, p.created_at '+
      'FROM ponude p JOIN klubovi k ON k.klub_id = p.klub_id '+
      'WHERE p.igrac_id = :id '+
      'ORDER BY p.created_at DESC';
    Q.ParamByName('id').AsInteger := AIgracID;
    Q.Open;

    while not Q.Eof do
    begin
      Item := lvPonude.Items.Add;
      Item.Tag := Q.FieldByName('ponuda_id').AsInteger;
      Item.Text := Format('#%d | %s | Cena: %.2f | Status: %s | Kreirano: %s',
        [ Item.Tag,
          Q.FieldByName('klub').AsString,
          Q.FieldByName('cena').AsFloat,
          Q.FieldByName('status').AsString,
          Q.FieldByName('created_at').AsString
        ]);
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

{=========================== Helpers =============================}

function TfrmProdaja.ComboItemID(ACombo: TComboBox): Integer;
begin
  if ACombo.ItemIndex < 0 then Exit(0);
  Result := Integer(ACombo.Items.Objects[ACombo.ItemIndex]);
end;

function TfrmProdaja.SelectedPonudaID: Integer;
begin
  if (lvPonude.ItemIndex < 0) or (lvPonude.Items.Count = 0) then Exit(0);
  Result := lvPonude.Items[lvPonude.ItemIndex].Tag;
end;

procedure TfrmProdaja.Audit(const AEntitet: string; AID: Integer; const AAkcija, ADetalji: string);
var Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Baza.dm;
    Q.SQL.Text :=
      'INSERT INTO istorija_promena (entitet, entitet_id, akcija, detalji) '+
      'VALUES (:e, :id, :a, :d)';
    Q.ParamByName('e').AsString   := AEntitet;
    Q.ParamByName('id').AsInteger := AID;
    Q.ParamByName('a').AsString   := AAkcija;
    Q.ParamByName('d').AsString   := ADetalji;
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

{=========================== Actions =============================}

procedure TfrmProdaja.btnKrairajPonuduClick(Sender: TObject);
var
  igracID, kupacID: Integer;
  cena: Double;
  vazidoISO: string;
  Q: TFDQuery;
  NewPonudaID: Int64;
begin
  igracID := ComboItemID(cbIgrac);
  kupacID := ComboItemID(cbKupac);

  if (igracID = 0) or (kupacID = 0) then
    raise Exception.Create('Izaberi igrača i kupca (klub).');

  if not TryStrToFloat(edCena.Text.Replace(',', '.'), cena) then
    raise Exception.Create('Neispravna cena.');

  if Trim(edVazido.Text) <> '' then
  begin
    if Length(edVazido.Text) <> 10 then
      raise Exception.Create('Datum unesi kao YYYY-MM-DD.');
    vazidoISO := edVazido.Text;
  end
  else
    vazidoISO := '';

  // INSERT ponude
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Baza.dm;
    Q.SQL.Text :=
      'INSERT INTO ponude (igrac_id, klub_id, cena, status, vazido, napomena) '+
      'VALUES (:igrac, :klub, :cena, ''NA_CEKANJU'', :vazido, :napomena)';
    Q.ParamByName('igrac').AsInteger := igracID;
    Q.ParamByName('klub').AsInteger  := kupacID;
    Q.ParamByName('cena').AsFloat    := cena;
    if vazidoISO <> '' then Q.ParamByName('vazido').AsString := vazidoISO else Q.ParamByName('vazido').Clear;
    Q.ParamByName('napomena').AsString := mmNapomena.Text;
    Q.ExecSQL;
  finally
    Q.Free;
  end;

  // poslednji insert id
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Baza.dm;
    Q.SQL.Text := 'SELECT last_insert_rowid()';
    Q.Open;
    NewPonudaID := Q.Fields[0].AsLargeInt;
  finally
    Q.Free;
  end;

  // audit
  Audit('ponuda', NewPonudaID, 'KREIRANO',
        Format('igrac_id=%d, klub_id=%d, cena=%.2f', [igracID, kupacID, cena]));

  LoadPonudeZaIgraca(igracID);
  ShowMessage('Ponuda je kreirana.');
end;

procedure TfrmProdaja.btnPrihvatiClick(Sender: TObject);
var
  pid, igracID: Integer;
  klubNaziv, izKluba: string;
  cena: Double;
  Q: TFDQuery;
  NewTransferID: Int64;
begin
  pid := SelectedPonudaID;
  if pid = 0 then
    raise Exception.Create('Izaberi ponudu u listi.');

  // detalji ponude + igrač
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Baza.dm;
    Q.SQL.Text :=
      'SELECT p.igrac_id, p.cena, k.naziv AS klub, i.trenutni_klub '+
      'FROM ponude p '+
      'JOIN klubovi k ON k.klub_id = p.klub_id '+
      'JOIN igraci i ON i.igrac_id = p.igrac_id '+
      'WHERE p.ponuda_id = :pid';
    Q.ParamByName('pid').AsInteger := pid;
    Q.Open;
    if Q.IsEmpty then
      raise Exception.Create('Ponuda ne postoji.');
    igracID   := Q.FieldByName('igrac_id').AsInteger;
    cena      := Q.FieldByName('cena').AsFloat;
    klubNaziv := Q.FieldByName('klub').AsString;
    izKluba   := Q.FieldByName('trenutni_klub').AsString;
  finally
    Q.Free;
  end;

  // status = PRIHVACENA + updated_at direktno (nema trigera)
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Baza.dm;
    Q.SQL.Text :=
      'UPDATE ponude '+
      '   SET status = ''PRIHVACENA'', '+
      '       updated_at = CURRENT_TIMESTAMP '+
      ' WHERE ponuda_id = :pid';
    Q.ParamByName('pid').AsInteger := pid;
    Q.ExecSQL;
  finally
    Q.Free;
  end;
  Audit('ponuda', pid, 'PRIHVACENO', '');

  // transfer
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Baza.dm;
    Q.SQL.Text :=
      'INSERT INTO transferi (ponuda_id, igrac_id, iz_kluba, u_klub, cena) '+
      'VALUES (:pid, :igrac, :iz, :u, :cena)';
    Q.ParamByName('pid').AsInteger   := pid;
    Q.ParamByName('igrac').AsInteger := igracID;
    Q.ParamByName('iz').AsString     := izKluba;
    Q.ParamByName('u').AsString      := klubNaziv;
    Q.ParamByName('cena').AsFloat    := cena;
    Q.ExecSQL;
  finally
    Q.Free;
  end;

  // poslednji transfer id (radi audita)
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Baza.dm;
    Q.SQL.Text := 'SELECT last_insert_rowid()';
    Q.Open;
    NewTransferID := Q.Fields[0].AsLargeInt;
  finally
    Q.Free;
  end;

  Audit('transfer', NewTransferID, 'KREIRANO', Format('ponuda_id=%d', [pid]));

  // promena kluba kod igrača
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Baza.dm;
    Q.SQL.Text := 'UPDATE igraci SET trenutni_klub = :u WHERE igrac_id = :id';
    Q.ParamByName('u').AsString   := klubNaziv;
    Q.ParamByName('id').AsInteger := igracID;
    Q.ExecSQL;
  finally
    Q.Free;
  end;

  Audit('igrac', igracID, 'IZMENJENO', 'Promena kluba usled transfera');

  LoadPonudeZaIgraca(igracID);
  ShowMessage('Ponuda prihvaćena i transfer zaveden.');
end;

procedure TfrmProdaja.Button2Click(Sender: TObject);
begin
    frmProdaja.hide;
    formMain.show;
end;

procedure TfrmProdaja.btnOdbijClick(Sender: TObject);
var
  pid, igracID: Integer;
  Q: TFDQuery;
begin
  pid := SelectedPonudaID;
  if pid = 0 then
    raise Exception.Create('Izaberi ponudu u listi.');

  // nađi igrača iz ponude
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Baza.dm;
    Q.SQL.Text := 'SELECT igrac_id FROM ponude WHERE ponuda_id = :pid';
    Q.ParamByName('pid').AsInteger := pid;
    Q.Open;
    if Q.IsEmpty then
      raise Exception.Create('Ponuda ne postoji.');
    igracID := Q.Fields[0].AsInteger;
  finally
    Q.Free;
  end;

  // status = ODBIJENA + updated_at direktno (nema trigera)
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Baza.dm;
    Q.SQL.Text :=
      'UPDATE ponude '+
      '   SET status = ''ODBIJENA'', '+
      '       updated_at = CURRENT_TIMESTAMP '+
      ' WHERE ponuda_id = :pid';
    Q.ParamByName('pid').AsInteger := pid;
    Q.ExecSQL;
  finally
    Q.Free;
  end;

  Audit('ponuda', pid, 'ODBIJENO', '');

  LoadPonudeZaIgraca(igracID);
  ShowMessage('Ponuda odbijena.');
end;

end.

