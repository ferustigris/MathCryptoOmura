//алгоритм Евклида
unit unod;
interface
uses bnumber, sysUtils;
function nod(a, b: TBNumber) : TBnumber;
implementation
//find NOD(a,b) and return it
function nod(a, b: TBNumber) : TBnumber;
var
  r1,r2,m,q :TBNumber;
begin
  if(a.cmp(b) > 0)then
  begin
    r1 := TBNumber.create(a);
    r2 := TBNumber.create(b);
  end
  else
  if(a.cmp(b) < 0)then
  begin
    r1 := TBNumber.create(b);
    r2 := TBNumber.create(a);
  end
  else
  begin
    result := TBNumber.create(a);
    exit;
  end;
  m := nil;
  q := nil;
  while(r2.cmp(TBNumber.create('0')) <> 0)do
  begin
    r1.sub(r2, m, q);
    freeAndNil(r1);
    r1 := TBNumber.create(r2);
    freeAndNil(r2);
    r2 := TBNumber.create(q);
    freeAndNil(m);
    freeAndNil(q);
  end;
  result := TBNumber.create(r1);
  freeAndNil(r1);
  freeAndNil(r2);
end;
end.
 