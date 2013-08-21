unit main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, Mask, bnumber, Menus;

type
  TForm1 = class(TForm)
    mMsg: TMemo;
    sbbar: TStatusBar;
    bProgress: TProgressBar;
    log: TMemo;
    mm: TMainMenu;
    N1: TMenuItem;
    nGen: TMenuItem;
    nClose: TMenuItem;
    mReceive: TMemo;
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure progress();
    procedure nCloseClick(Sender: TObject);
    procedure nGenClick(Sender: TObject);
  private
    { Private declarations }
    p,//simple
    g,//g^phi(p)=1 mod p
    r,//r=g^k mod(p)
    s,//m = xr+rs mod p
    y//y=g^x mod(p)
   : TBNumber;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation
uses umd5, unod;
{$R *.dfm}
procedure TForm1.progress();
begin
  if(bProgress.Position = bProgress.Max)then
    bProgress.Position := 0
  else
    bProgress.Position := bProgress.Position + 1;
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  if(not test()) then ShowMessage('Ошибка при операциях с БЧ!');
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  g := nil;
  p := nil;
  r := nil;
  y := nil;
  s := nil;
end;

procedure TForm1.nCloseClick(Sender: TObject);
begin
  close();
end;

procedure TForm1.nGenClick(Sender: TObject);
var
  n,//key length
  i,
  nk//part of n
   : integer;
  m, m_mod, m_div,
  e0, e1, e2, p_minus1,//1, 2
  tmp,
  eb,db,//sender
  ea,da,//receiver
  m1,m2,m3,m_test, half
   : TBNumber;
  h : String;
  simple: boolean;//is simple?
begin
  half := nil;
  m_mod := nil;
  m_div := nil;
  tmp := nil;
  m1 := nil;
  m2 := nil;
  m3 := nil;
  m_test := nil;
  m := nil;
  FreeAndNil(s);
  FreeAndNil(r);
  FreeAndNil(y);
  FreeAndNil(g);
  FreeAndNil(p);
//####################### sender
  sbBar.Panels[0].Text := 'вычисляем дайджест M: m = h(M):';
  h := mMsg.Lines.GetText();//вычисляем дайджест M: m = h(M):
  log.Lines.add('Сообщение:' + h);
  m := TBNumber.create(h, 0);
  n := m.size;
  log.lines.Add('m=' + m.print);
  //выбирается простое p
  sbBar.Panels[0].Text := 'выбирается простое p';
  e0 := TBNumber.create('0');
  e1 := TBNumber.create('1');
  e2 := TBNumber.create('2');
  //генерируем простое число, тупо, но для генерации случайного числа много усилий нужно)
  repeat
    randomize;
    h := '';
    for i := 0 to n-1 do
      h := h + IntToStr(random(10));
    if(h[1] = '0')then
      h[1] := '1';
    FreeAndNil(p);
    p := TBNumber.create(h);
    tmp := TBNumber.create('2');
    //простое?
    p.sub(e2, half, m_mod);
    FreeAndNil(m_mod);
    simple := true;
    while(tmp.cmp(half) <= 0) do
    begin
      p.sub(tmp, m_mod, m_div);
      freeAndNil(m_mod);
      if(m_div.cmp(e0) = 0)then
      begin
        freeAndNil(m_div);
        simple := false;
        break;
      end;
      freeAndNil(m_div);
      progress();
      application.ProcessMessages;
      tmp.sum(e1);
    end;
    if(m.cmp(p) >= 0)then simple := false;
    FreeAndNil(tmp);
  until(simple);
  //p := TBNumber.create('7');
  log.Lines.add('p=' + p.print);
  p_minus1 := TBNumber.create(p);
  p_minus1.sum(TBNumber.create('-1'));
  //выбирается 1 < eb < p-1 взаимно простое с p-1
  sbBar.Panels[0].Text := 'выбирается простое 1 < eb < p-1';
  repeat
    repeat
      randomize;
      h := '';
      if(n > 1)then
        nk := 0
      else
        nk := n;
      while(nk = 0)do
        nk := random(n);
      for i := 1 to nk do
        h := h + IntToStr(random(10));
      if(h[1] = '0')then
        h[1] := '1';
      FreeAndNil(eb);
      eb := TBNumber.create(h);
    until(p.cmp(eb) > 0);
    progress();
    application.ProcessMessages;
    //взаимно ппростое с p-1?
  until(p.cmp(eb) >= 0)and(eb.cmp(e1) <> 0)and(nod(p_minus1,eb).cmp(e1) = 0);
  log.Lines.add('eb=' + eb.print);

  //вычисляется db : db* eb = 1 mod p-1
  sbBar.Panels[0].Text := 'вычисляется db : db* eb = 1 mod p-1';
  db :=  TBNumber.create(eb);
    repeat
      db.sum(e1);
      progress();
      application.ProcessMessages;
      FreeAndNil(tmp);
      tmp :=  TBNumber.create(db);
      tmp.mult(eb);
      FreeAndNil(m_div);
      FreeAndNil(m_mod);
      tmp.sub(p_minus1, m_div, m_mod);
    until(m_mod.cmp(e1) = 0);
  FreeAndNil(tmp);
  FreeAndNil(m_div);
  FreeAndNil(m_mod);
  log.Lines.add('db=' + db.print);
  //вычисляется r=g^k mod(p)
  sbBar.Panels[0].Text := 'вычисляется m1=m^eb mod(p)';
  FreeAndNil(tmp);
  FreeAndNil(m1);
  FreeAndNil(m_div);
  tmp := TBNumber.create(e1);
  m.sub(p, m_div, m1);
  FreeAndNil(m_div);
  m_div := TBNumber.create(m1);
  while(tmp.cmp(eb) < 0)do
  begin
    m1.mult(m_div);
    tmp.sum(e1);
    progress();
    application.ProcessMessages;
  end;
  FreeAndNil(tmp);
  tmp := TBNumber.create(m1);
  FreeAndNil(m1);
  FreeAndNil(m_div);
  tmp.sub(p, m_div, m1);
  FreeAndNil(tmp);
  FreeAndNil(m_div);
  log.Lines.add('m1=' + m1.print);
//####################### receiver
  //выбирается 1 < ea < p-1 взаимно простое с p-1
  sbBar.Panels[0].Text := 'выбирается простое 1 < ea < p-1';
  repeat
    repeat
      randomize;
      h := '';
      if(n > 1)then
        nk := 0
      else
        nk := n;
      while(nk = 0)do
        nk := random(n);
      for i := 1 to nk do
        h := h + IntToStr(random(10));
      if(h[1] = '0')then
        h[1] := '1';
      FreeAndNil(ea);
      ea := TBNumber.create(h);
    until(p_minus1.cmp(ea) > 0);
    progress();
    application.ProcessMessages;
    //взаимно ппростое с p-1?
  until(p.cmp(ea) >= 0)and(ea.cmp(e1) <> 0)and(nod(p_minus1,ea).cmp(e1) = 0);
  log.Lines.add('ea=' + ea.print);

  //вычисляется da : da* ea = 1 mod p-1
  sbBar.Panels[0].Text := 'вычисляется da : da* ea = 1 mod p-1';
  da :=  TBNumber.create(ea);
    repeat
      da.sum(e1);
      progress();
      application.ProcessMessages;
      FreeAndNil(tmp);
      tmp :=  TBNumber.create(da);
      tmp.mult(ea);
      FreeAndNil(m_div);
      FreeAndNil(m_mod);
      tmp.sub(p_minus1, m_div, m_mod);
    until(m_mod.cmp(e1) = 0);
  FreeAndNil(tmp);
  FreeAndNil(m_div);
  FreeAndNil(m_mod);
  log.Lines.add('da=' + da.print);
//####################### sender
  //вычисляется m1=m^eb mod(p)
  sbBar.Panels[0].Text := 'вычисляется m1=m^eb mod(p)';
  FreeAndNil(tmp);
  FreeAndNil(m1);
  FreeAndNil(m_div);
  tmp := TBNumber.create(e1);
  m.sub(p, m_div, m1);
  FreeAndNil(m_div);
  m_div := TBNumber.create(m1);
  while(tmp.cmp(eb) < 0)do
  begin
    m1.mult(m_div);
    tmp.sum(e1);
    progress();
    application.ProcessMessages;
  end;
  FreeAndNil(tmp);
  tmp := TBNumber.create(m1);
  FreeAndNil(m1);
  FreeAndNil(m_div);
  tmp.sub(p, m_div, m1);
  FreeAndNil(tmp);
  FreeAndNil(m_div);
  log.Lines.add('m1=' + m1.print);
  //вычисляется m2=m1^ea mod(p)
  sbBar.Panels[0].Text := 'вычисляется m2=m1^ea mod(p)';
  FreeAndNil(tmp);
  FreeAndNil(m2);
  FreeAndNil(m_div);
  tmp := TBNumber.create(e1);
  m1.sub(p, m_div, m2);
  FreeAndNil(m_div);
  m_div := TBNumber.create(m2);
  while(tmp.cmp(ea) < 0)do
  begin
    m2.mult(m_div);
    tmp.sum(e1);
    progress();
    application.ProcessMessages;
  end;
  FreeAndNil(tmp);
  tmp := TBNumber.create(m2);
  FreeAndNil(m2);
  FreeAndNil(m_div);
  tmp.sub(p, m_div, m2);
  FreeAndNil(tmp);
  FreeAndNil(m_div);
  log.Lines.add('m2=' + m2.print);
//####################### sender
  //вычисляется m3=m2^db mod(p)
  sbBar.Panels[0].Text := 'вычисляется m3=m2^db mod(p)';
  FreeAndNil(tmp);
  FreeAndNil(m3);
  FreeAndNil(m_div);
  tmp := TBNumber.create(e1);
  m2.sub(p, m_div, m3);
  FreeAndNil(m_div);
  m_div := TBNumber.create(m3);
  while(tmp.cmp(db) < 0)do
  begin
    m3.mult(m_div);
    tmp.sum(e1);
    progress();
    application.ProcessMessages;
  end;
  FreeAndNil(tmp);
  tmp := TBNumber.create(m3);
  FreeAndNil(m3);
  FreeAndNil(m_div);
  tmp.sub(p, m_div, m3);
  FreeAndNil(tmp);
  FreeAndNil(m_div);
  log.Lines.add('m3=' + m3.print);
//####################### receiver
  //вычисляется m=m3^da mod(p)
  sbBar.Panels[0].Text := 'вычисляется m=m3^da mod(p)';
  FreeAndNil(tmp);
  FreeAndNil(m_test);
  FreeAndNil(m_div);
  tmp := TBNumber.create(e1);
  m3.sub(p, m_div, m_test);
  FreeAndNil(m_div);
  m_div := TBNumber.create(m_test);
  while(tmp.cmp(da) < 0)do
  begin
    m_test.mult(m_div);
    tmp.sum(e1);
    progress();
    application.ProcessMessages;
  end;
  FreeAndNil(tmp);
  tmp := TBNumber.create(m_test);
  FreeAndNil(m_test);
  FreeAndNil(m_div);
  tmp.sub(p, m_div, m_test);
  FreeAndNil(tmp);
  FreeAndNil(m_div);
  log.Lines.add('m_test=' + m_test.print);//chr
  log.Lines.add('m_test=' + m_test.toString);//chr
  mReceive.Lines.Clear;
  mReceive.Lines.setText(PChar(m_test.toString));
  FreeAndNil(e0);
  FreeAndNil(e1);
  FreeAndNil(e2);
  FreeAndNil(m3);
  FreeAndNil(m);
  FreeAndNil(m1);
  FreeAndNil(m2);
  FreeAndNil(m_test);
  FreeAndNil(p_minus1);
  FreeAndNil(m_div);
  FreeAndNil(m_mod);
  FreeAndNil(tmp);
  sbBar.Panels[0].Text := 'Завершено';
end;
end.
