unit bnumber;

interface
type
//class numbers
TString = record
  int: array of byte;
  //float: array of byte;
  sign: boolean;//not used
  intSize : Integer;
  //floatSize : Integer;
end;
//class number ops
TBNumber = class
public
  constructor create(num : String);overload;
  constructor create(num : String; base : Integer);overload;
  constructor create(num : TBNumber);overload;
  destructor destroy();override;
  function print() : String;
  function toString() : String;
  procedure fromStringD(str : String);
  procedure fromStringH(str : String);
  procedure fromStringAsSymbol(str : String);
//ops
  procedure sum(operator : TBNumber);
  procedure mult(operator : TBNumber);
  procedure sub(operator : TBNumber; var int, remainder : TBNumber);
  function cmp(operator : TBNumber) : Integer;
  function size() : Integer;
private
  number : TString;
  procedure setNeedSize(newISize, newFSize : Integer);
end;
function test() : boolean;
implementation

uses SysUtils, Forms;
//for test only
function test() : boolean;
var
 n,
 m, m_mod, m_div : TBNumber;
 str1, str2 : String;
 a,b : integer;
begin
  result := false;
  for a := 1 to 9 do
    for b := 999 to 1010 do
    begin
      n := TBNumber.create(IntToStr(a));
      m := TBNumber.create(IntToStr(b));
      n.sub(m, m_div, m_mod);
      str1 := IntToStr(a div b);
      str2 := m_div.print;
      if(str1 <> str2)then
        exit;
      str1 := IntToStr(a mod b);
      str2 := m_mod.print;
      if(str1 <> str2)then
        exit;
      n.sum(m);
      str1 := IntToStr(a + b);
      str2 := n.print;
      if(str1 <> str2)then
        exit;
      freeAndNil(n);
      freeAndNil(m);
    end;
  result := true;
end;
//construct
constructor TBNumber.create(num : String; base : Integer);
begin
  //number.floatSize := 0;
  number.intSize := 0;
  case(base)of
  10:fromStringD(num);
  16:fromStringH(num);
  0:fromStringAsSymbol(num);
  end;
end;
//construct
constructor TBNumber.create(num : TBNumber);
var
  i:integer;
begin
  //number.floatSize := 0;
  number.intSize := num.number.intSize;
  SetLength(number.int,number.intSize);
  for i := 0 to num.number.intSize-1 do
    number.int[i] := num.number.int[i];
  number.sign := num.number.sign;
end;
//construct
constructor TBNumber.create(num : String);
begin
  //number.floatSize := 0;
  number.intSize := 0;
  fromStringD(num);
end;
//destruct
destructor TBNumber.destroy();
begin
  SetLength(number.int, 0);
  number.intSize := 0;
  //SetLength(number.float, 0);
end;
//print out
function TBNumber.print() : String;
var
  i : Integer;
begin
  {for i := 0 to number.floatSize-1 do
  begin
    result := IntToStr(number.float[i]) + result;
  end;
  result := ',' + result;}
  result := '';
  for i := 0 to number.intSize-1 do
  begin
    result := IntToStr(number.int[i]) + result;
  end;
  if(not number.sign)then
    result := '-' + result;
end;
//get by string of dec
procedure TBNumber.fromStringD(str : String);
const
  INTEGER_DIGITS = 0;
  FLOAT_DIGITS = 1;
var
  curDigits,
  strlen,
  floatnum,
  i :Integer;
  digits: set of char;
begin
  number.sign := true;
  digits := ['0','1'..'9'];
  repeat
    strlen := Length(str);
    if(strlen = 0)then
      str := '0'
    else
    {if((StrScan(PChar(str), '.') = nil)and(StrScan(PChar(str), ',') = nil))then
      str := str + ',0';}
    if(str[1] = '-')then
    begin
      str := strPos(PChar(str), '-')+1;
      number.sign := false;
      strlen := 0;
    end
    else
    if(str[1] = '+')then
    begin
      str := strPos(PChar(str), '+')+1;
      strlen := 0;
    end;
  until(strlen > 0);
  //curDigits := FLOAT_DIGITS;
  curDigits := INTEGER_DIGITS;
  floatnum := 0;
  if(strlen > 0)then
  begin
    for i:=0 to strlen - 1 do
    begin
      if(str[strlen - i] in digits)then
      begin
        case(curDigits)of
          INTEGER_DIGITS:
          begin
            setNeedSize(i - floatnum + 1, 0);
            number.Int[i - floatnum] := StrToInt(str[strlen - i]);
          end;
          {FLOAT_DIGITS:
          begin
            setNeedSize(0, i + 1);
            floatnum := i + 1;
            number.float[i] := StrToInt(str[strlen - i]);
          end;}
        end;
      end
      {else if((str[strlen - i] = ',')or(str[strlen - i] = '.')) then
      begin
        curDigits := INTEGER_DIGITS;
        floatnum := i + 1;
        continue;
      end}
      else raise Exception.Create('No valid number!');
    end
  end;
end;
//get by string as symbols
procedure TBNumber.fromStringAsSymbol(str : String);
var
  strlen,
  i :Integer;
  tmp : String;
begin
  number.sign := true;
  repeat
    strlen := Length(str);
    if(strlen = 0)then
      str := '0'
    else
  until(strlen > 0);
  tmp := '';
  for i:=1 to strlen do
    tmp := tmp + IntToStr(ord(str[i]));
  repeat
    strlen := Length(tmp);
    if(strlen = 0)then
      tmp := '0'
    else
  until(strlen > 0);
  setNeedSize(strlen, 0);
  if(strlen > 0)then
    for i:=0 to strlen - 1 do
      number.Int[i] := StrToInt(tmp[i+1]);
end;
//get by string of hex
procedure TBNumber.fromStringH(str : String);
var
  strlen,
  i :Integer;
  digits: set of char;
  tmp,
  module : TBNumber;
  dig : String;
begin
  number.sign := true;
  number.intSize := 0;
  setLength(number.int, 1);
  number.int[0] := 0;
  digits := ['0','1'..'9'];
  strlen := Length(str);
  module := TBNumber.create('1');
  tmp := TBNumber.create('0');
  if(strlen > 0)then
  begin
    for i:=0 to strlen - 1 do
    begin
        dig := '0';
        if(str[strlen - i] in digits)then
          dig := str[strlen - i]
        else
        case(str[strlen - i])of
        'A': dig := '10';
        'a': dig := '10';
        'B': dig := '11';
        'b': dig := '11';
        'C': dig := '12';
        'c': dig := '12';
        'D': dig := '13';
        'd': dig := '13';
        'E': dig := '14';
        'e': dig := '14';
        'F': dig := '15';
        'f': dig := '15';
        end;
        freeAndNil(tmp);
        tmp := TBNumber.create(dig);
        tmp.mult(module);
        self.sum(tmp);
        module.mult(TBNumber.create('16'));
    end
  end;
  freeAndNil(module);
  freeAndNil(tmp);
end;
//get by string
procedure TBNumber.setNeedSize(newISize, newFSize : Integer);
begin
  if(number.intSize <> newISize)and(newISize <> 0)then
  begin
    number.intSize := newISize;
    SetLength(number.int, newISize);
  end;
  {if(number.floatSize <> newFSize)and(newFSize <> 0)then
  begin
    number.floatSize := newFSize;
    SetLength(number.float, newFSize);
  end;}
end;
//for ops
{function TBNumber.getValue() : TString;
begin
  result := number;
end;}
//sum
procedure TBNumber.sum(operator : TBNumber);
var
  sum : Array of byte;
  size,
  tmp, val,
  i,
  max,
  min : Integer;
  op1, op2 : TString;
  minus: boolean;
begin
  minus := false;
  if(number.sign <> operator.number.sign)then
  begin
    i := cmp(operator);
    if(i = -1)then
      number.sign := operator.number.sign
    else
    if(i = 0)then
    begin
      fromStringD('');
      exit;
    end;
    minus := true;
  end;
if(minus)then
begin
  tmp := 0;
{  if(operator.getValue().floatSize > number.floatSize)then
  begin
    max := operator.getValue().floatSize;
    min := number.floatSize;
    op2 := number;
    op1 := operator.getValue();
  end
  else
  begin
    op2 := operator.getValue();
    op1 := number;
    max := number.floatSize;
    min := operator.getValue().floatSize;
  end;
  size := max;
  SetLength(sum, size);
  for i := 0 to size-1 do
  begin
    sum[i] := op1.float[i];
  end;
  i := 0;
  while(i < min)do
  begin
    tmp := op1.float[max - min + i] + op2.float[i] + tmp;
    sum[max - min + i] := tmp mod 10;
    tmp := tmp div 10;
    i := i + 1;
  end;
  setNeedSize(0, size);
  for i := 0 to size-1 do
  begin
    number.float[i] := sum[i];
  end;
  SetLength(sum, 0);
}

  size := 0;
  SetLength(sum, size);
  if(cmp(operator) = -1)then
  begin
    max := operator.number.intSize;
    min := number.intSize;
    op2 := number;
    op1 := operator.number;
  end
  else
  begin
    op2 := operator.number;
    op1 := number;
    max := number.intSize;
    min := operator.number.intSize;
  end;
  size := max;
  SetLength(sum, size);
  i := 0;
  while(i < min)do
  begin
    {while(op1.int[i] < abs(tmp))do
    begin
      op1.int[i] := op1.int[i] + 1;
      tmp := tmp * 10;
    end;}
    tmp := op1.int[i] - op2.int[i] + tmp;
    if(tmp < 0)then
    begin
        val := tmp mod 10;
        while(val < 0)do
          val := val + 10;
        sum[i] := val;
    end
    else
      sum[i] := tmp mod 10;
    if(tmp < 0)then
      tmp := -1
    else
      tmp := tmp div 10;
    i := i + 1;
  end;
  while((tmp <> 0)or(max > i))do
  begin
    if(size <= i)then
    begin
      size := i + 1;
      SetLength(sum, size);
    end;
    if(max > i)then
      tmp := op1.int[i] + tmp;
    if(tmp < 0)then
    begin
        val := tmp mod 10;
        while(val < 0)do
          val := val + 10;
        sum[i] := val;
    end
    else
      sum[i] := tmp mod 10;
    if(tmp < 0)and(tmp div 10 <> 0)then
      tmp := -1
    else
      tmp := tmp div 10;
    inc(i);
  end;
  i:= size-1;
  while(sum[i] = 0)do
  begin
    dec(size);
    dec(i);
  end;
  setNeedSize(size, 0);
  for i := 0 to size-1 do
  begin
    number.int[i] := sum[i];
  end;
  SetLength(sum, 0);
end
else
begin
  tmp := 0;
  {if(operator.number.floatSize > number.floatSize)then
  begin
    max := operator.number.floatSize;
    min := number.floatSize;
    op2 := number;
    op1 := operator.number;
  end
  else
  begin
    op2 := operator.number;
    op1 := number;
    max := number.floatSize;
    min := operator.number.floatSize;
  end;
  size := max;
  SetLength(sum, size);
  for i := 0 to size-1 do
  begin
    sum[i] := op1.float[i];
  end;
  i := 0;
  while(i < min)do
  begin
    tmp := op1.float[max - min + i] + op2.float[i] + tmp;
    sum[max - min + i] := tmp mod 10;
    tmp := tmp div 10;
    i := i + 1;
  end;
  setNeedSize(0, size);
  for i := 0 to size-1 do
  begin
    number.float[i] := sum[i];
  end;
  SetLength(sum, 0);
  }

  size := 0;
  SetLength(sum, size);
  if(operator.number.intSize > number.intSize)then
  begin
    max := operator.number.intSize;
    min := number.intSize;
    op2 := number;
    op1 := operator.number;
  end
  else
  begin
    op2 := operator.number;
    op1 := number;
    max := number.intSize;
    min := operator.number.intSize;
  end;
  size := max;
  SetLength(sum, size);
  i := 0;
  while(i < min)do
  begin
    tmp := op1.int[i] + op2.int[i] + tmp;
    sum[i] := tmp mod 10;
    tmp := tmp div 10;
    i := i + 1;
  end;
  while((tmp <> 0)or(max > i))do
  begin
    if(size <= i)then
    begin
      size := i + 1;
      SetLength(sum, size);
    end;
    if(max > i)then
      tmp := op1.int[i] + tmp;
    sum[i] := tmp mod 10;
    tmp := tmp div 10;
    i := i + 1;
  end;
  setNeedSize(size, 0);
  for i := 0 to size-1 do
  begin
    number.int[i] := sum[i];
  end;
  SetLength(sum, 0);
end;

end;
//competition absolute values
function TBNumber.cmp(operator : TBNumber) : Integer;
var
  i : Integer;
  op1, op2 : TString;
begin
  result := 0;
  op1 := number;
  op2 := operator.number;
  if(op1.intSize = op2.intSize)then
  begin
    i := op1.intSize - 1;
    while(i >= 0)do
    begin
      if(op1.int[i] < op2.int[i])then
      begin
        result := -1;
        exit;
      end
      else
      if(op1.int[i] > op2.int[i])then
      begin
        result := 1;
        exit;
      end;
      i := i - 1;
    end;

    {if(op1.floatSize > op2.floatSize)then
      min := op2.floatSize
    else
      min := op1.floatSize;
    i := 0;
    while(i < min)do
    begin
      if(op1.float[op1.floatSize - i - 1] < op2.float[op2.floatSize - i - 1])then
      begin
        result := -1;
        exit;
      end
      else
      if(op1.float[op1.floatSize - i - 1] > op2.float[op2.floatSize - i - 1])then
      begin
        result := 1;
        exit;
      end;
      i := i + 1;
    end;
    if(op1.floatSize > op2.floatSize)then
      result := 1
    else
      result := -1;
    exit;}
  end
  else
  if(op1.intSize > op2.intSize)then
    result := 1
  else
  if(op1.intSize < op2.intSize)then
    result := -1;
end;
//subvision
procedure TBNumber.sub(operator : TBNumber; var int, remainder : TBNumber);
var
  m, d,
  e0, e1, e2,
  tmp : TBNumber;
  i, k, j,
  min, max,
  sized : integer;
begin
  if(assigned(int))then
    freeAndNil(int);
  int := nil;
  d := nil;
  if(assigned(remainder))then
    freeAndNil(remainder);
  remainder := nil;
  if(cmp(operator) = 0)then
  begin
    int := TBNumber.create('1');
    remainder := TBNumber.create('0');
    exit;
  end
  else
  if(cmp(operator) < 0)then
  begin
    int := TBNumber.create('0');
    remainder := TBNumber.create(Self);
    exit;
  end;
  e0 := TBNumber.create('0');
  e1 := TBNumber.create('1');
  e2 := TBNumber.create('2');
  int := TBNumber.create(e0);
  sized := 0;
  min := operator.number.intSize;
  max := number.intSize;
  k := 0;

  tmp := TBNumber.create(e0);
  tmp.setNeedSize(min, 0);
  for i := 0 to min-1 do
    tmp.number.int[i] := number.int[max - min + i];
  k := 0;
repeat
  m := TBNumber.create(e0);
  m.sum(operator);
  freeAndNil(d);
  d := TBNumber.create('0');
  while(tmp.cmp(m) >= 0)do
  begin
    d.sum(e1);
    m.sum(operator);
    application.ProcessMessages;
  end;
  sized := sized + d.number.intSize;
  int.setNeedSize(sized, 0);
  for j := d.number.intSize downto 1 do
    for i := int.number.intSize-1 downto 1 do
      int.number.int[i] := int.number.int[i - 1];
  for i := d.number.intSize-1 downto 0 do
    int.number.int[i] := d.number.int[i];

  freeAndNil(remainder);
  remainder := TBNumber.create(m);
  remainder.number.sign := not tmp.number.sign;
  remainder.sum(tmp);
  remainder.number.sign := not operator.number.sign;
  remainder.sum(operator);
  remainder.number.sign := true;
  freeAndNil(m);
  inc(k);
  if(max - min - k < 0)then break;
  tmp.setNeedSize(remainder.number.intSize+1,0);
  for i := tmp.number.intSize-1 downto 1 do
    tmp.number.int[i] := remainder.number.int[i - 1];
  tmp.number.int[0] := number.int[max - min - k];
until(false);
  FreeAndNil(e0);
  FreeAndNil(e1);
  FreeAndNil(e2);
  FreeAndNil(tmp);
end;
//mult
procedure TBNumber.mult(operator : TBNumber);
var
  sum : Array of byte;
  size,
  tmp1,
  tmp2,
  i, k,
  max,
  min : Integer;
  op1, op2 : TString;
begin
  if(cmp(TBNumber.create('0')) = 0)or(operator.cmp(TBNumber.create('0')) = 0)then
  begin
    setNeedSize(1,0);
    number.int[0] := 0;
    exit; 
  end;
  if(cmp(operator) = -1)then
  begin
    max := operator.number.intSize;
    min := number.intSize;
    op2 := number;
    op1 := operator.number;
  end
  else
  begin
    op2 := operator.number;
    op1 := number;
    max := number.intSize;
    min := operator.number.intSize;
  end;
  size := max + min + 1;
  SetLength(sum, size);
  k := 0;
  while(k < min) do
  begin
    tmp1 := 0;
    i := 0;
    while(i < max)do
    begin
      tmp1 := op1.int[i] * op2.int[k] + tmp1;
      tmp2 := sum[i+k] + tmp1;
      sum[i+k] := tmp2 mod 10;
      tmp1 := tmp2 div 10;
      inc(i);
    end;
    while(tmp1 <> 0)do
    begin
      tmp2 := sum[i+k] + tmp1;
      sum[i+k] := tmp2 mod 10;
      tmp1 := tmp2 div 10;
      inc(i);
    end;
    inc(k);
  end;
  i:= size-1;
  while(sum[i] = 0)do
  begin
    dec(size);
    dec(i);
  end;
  setNeedSize(size, 0);
  for i := 0 to size-1 do
  begin
    number.int[i] := sum[i];
  end;
  SetLength(sum, 0);
end;
//return size
function TBNumber.size() : Integer;
begin
  result := number.intSize;
end;
//print out how symbols codes
function TBNumber.toString() : String;
var
  i : Integer;
  tmp : String;
begin
  result := '';
  i := 0;
  if(number.intSize mod 2 <> 0)then
  begin
    setNeedSize(number.intSize+1, 0);
    number.int[number.intSize-1] := 0;
  end;
  while(i < number.intSize)do
  begin
    tmp := IntToStr(number.int[i]) + IntToStr(number.int[i+1]);
    result :=  result + chr(StrToInt(tmp));
    i := i + 2;
  end;
end;
end.
