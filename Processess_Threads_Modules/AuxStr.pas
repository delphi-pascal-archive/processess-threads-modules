{$B-,V-}
{$IFDEF VER80}
  {$DEFINE USES_SYSUTILS}
{$ENDIF}
{$IFDEF WIN32}
  {$DEFINE USES_SYSUTILS}
{$ENDIF}

{.$LONGSTRINGS OFF} { ne short strings }

unit AuxStr;   { Verze 1.1 - 28.12.1993 }

{ Unit AuxiliaryStrings pro pomocn‚ slu§by s ýetØzci }

{ Copyright (c) 1991, 1993 by Mandys Tomas - Mandy Soft }
{ email: tomas.mandys@2p.cz }
{ URL: http://www.2p.cz }

{ Pozn mka : K¢dov n¡ Ÿeskìch koment ý… v k¢du Latin 2 (k¢dov  str nka 852) }

interface

type
  CString=array[0..255] of Char;     { pro pr ci s ASCIIZ stringem }

{ z kladn¡ }
function UpString(X:String):String;  { Pýev d¡ ýetØzec na velk  p¡smena }
function LoString(X:String):String;  { Pýev d¡ ýetØzec na mal  p¡smena }
function LTrim(X:String):String;     { Odstraåuje z ýetØzce mezery zleva }
function RTrim(X:String):String;     { Odstraåuje z ýetØzce mezery zprava }
function Trim(X:String):String;      { Odstraåuje z ýetØzce mezery zprava i zleva }
function GetString(var X:String;Index:Integer;Count:Integer):String; { Vyj¡m  Ÿ st ýetØzce X }
function ReplStr(X:String;Count:Integer):String; { Vrac¡ ýetØzec vzniklì Count-n sobnìm opakov n¡m ýetØzce X }
function ReplSpace(Count:Integer):String;  { Vrac¡ ýetØzec vzniklì Count-n sobnìm opakov n¡m mezery }
function LStr(X:String;Count:Integer):String;  { Vrac¡ Count znak… zleva z ýetØzce X,popý¡padØ dopln¡ mezery na konec }
function RStr(X:String;Count:Integer):String;  { Vrac¡ Count znak… zprava z ýetØzce X,popý¡padØ dopln¡ mezery na zaŸ tek }
function RevStr(X:String):String;  { Vrac¡ obr cenì ýetØzec proti X }
{$IFNDEF WIN32}
procedure SetLength(var S: string; NewLength: Integer);
{$ENDIF}

{$IFNDEF USES_SYSUTILS}
{ pr ce s datem a ‡asem }
function StrToTime(S: string; var Hour, Min, Sec: Word): Integer;
function TimeToStr(Hour, Min, Sec: Word): string;
function StrToDate(S: string; var Day, Month, Year: Word): Integer;
function DateToStr(Day, Month, Year: Word): string;

const
  TimeFormat: string[30]='%2d:%02d:%02d';
  DateFormat: string[30]='%2d.%2d.%4d';
{$ENDIF}

{ pr ce s cel˜mi ‡¡sly }
function StrToNum(S: string): LongInt;
function NumToHexStr(L: LongInt): string;  { zarovna na sudy pocet cislic }
function NumToStr(L: LongInt): string;
function NumToHexStrI(L: LongInt; N: Integer): string;  { podobne, ale zadava se pocet mist pro doplneni nulama }
function NumToStrI(L: LongInt; N: Integer): string;
function Bin2Hex(const S: string): string;
function Hex2Bin(const S: string): string;

function StripDecimals(S: string): string; { vypusti zbytecna desetinna mista }
function StripExponent(S: string): string; { vypusti zbytecny exponent }

const
  HexPrefix: Char='$';

{$IFNDEF USES_SYSUTILS}
  {$IFNDEF USES_DRIVERS}
{ p©evzato z Drivers }
procedure FormatStr(var Result: String; {$IFNDEF VER60} const {$ENDIF} Format: String; var Params);
  {$ENDIF}
{$ENDIF}

implementation
{$IFDEF USES_DRIVERS}
uses
  Drivers;
{$ENDIF}

function UpString;
var
  I: Integer;
  Y:String;
begin
Y:='';
for I:=1 to Length(X) do Y:=Y+UpCase(X[I]);
UpString:=Y;
end;

function LoString;
var
  I: Integer;
  Y:String;
begin
Y:=X;
for I:=1 to Length(X) do
  if (Y[I]>='A')and(Y[I]<='Z') then
    Y[I]:=Char(Byte(Y[I])-Byte('A')+Byte('a'));
LoString:=Y;
end;

function LTrim;
var
  I: Integer;
begin
I:=1;
while (I<=Length(X))and(X[I]=' ') do
  Inc(I);
Delete(X,1,I-1);
LTrim:=X;
end;

function RTrim;
var
  I: Integer;
begin
I:=Length(X);
while (I>0)and(X[I]=' ') do Dec(I);
RTrim:=Copy(X,1,I)
end;

function Trim;
begin
Trim:=LTrim(RTrim(X));
end;

function GetString;
begin
  GetString:=Copy(X,Index,Count);
  Delete(X,Index,Count);
end;

function ReplStr;
var
  Y:String;
begin
Y:='';
while (Count>0)and(Length(Y)<SizeOf(String)-1) do
  begin
  Y:=Y+X;
  Dec(Count);
  end;
ReplStr:=Y;
end;

function ReplSpace;
var
  Y:String;
begin
  SetLength(Y, Count);
  FillChar(Y[1],Count,' ');
  ReplSpace:=Y;
end;

function LStr;
begin
LStr:=Copy(X,1,Count)+ReplSpace(Byte(Length(X)<Count)*(Count-Length(X)));;
end;

function RStr;
begin
RStr:=ReplSpace(Byte(Length(X)<Count)*(Count-Length(X)))+
      Copy(X,Byte(Length(X)-Count>=0)*(Length(X)-Count)+1,Count);
end;

function RevStr;
var
  I:Integer;
  Y:String;
begin
SetLength(Y, Length(X));
for I:=1 to Length(X) do Y[I]:=X[Length(X)-I+1];
RevStr:=Y;
end;

{$IFNDEF USES_SYSUTILS}

function StrToTime;
var
  Err: Integer;
label 1;
begin
Val(Trim(Copy(S,1,2)),Hour,Err);
if Err<>0 then GoTo 1;
Val(Trim(Copy(S,4,2)),Min,Err);
if Err<>0 then GoTo 1;
Val(Trim(Copy(S,7,2)),Sec,Err);
1:
StrToTime:=Err;
end;

function TimeToStr;
var
  _A:record Hour,Min,Sec:LongInt; end;
  S: string;
begin
_A.Hour:=Hour; _A.Min:=Min; _A.Sec:=Sec;
{$V-}
FormatStr(S,TimeFormat,_A);
TimeToStr:=S;
end;

function StrToDate;
var
  Err: Integer;
label 1;
begin
Val(Trim(Copy(S,1,2)),Day,Err);
if Err<>0 then GoTo 1;
Val(Trim(Copy(S,4,2)),Month,Err);
if Err<>0 then GoTo 1;
Val(Trim(Copy(S,7,4)),Year,Err);
1:
StrToDate:=Err;
end;

function DateToStr;
var
  _A:record Day, Month, Year:LongInt; end;
  S: string;
begin
_A.Day:=Day; _A.Month:=Month; _A.Year:=Year;
{$V-}
FormatStr(S, DateFormat,_A);
DateToStr:=S;
end;
{$ENDIF}

function StrToNum;
var
  L: LongInt;
  Err: Integer;
  I, N: Integer;
label
  1;
begin
L:=0;
S:=Trim(S);
while (S<>'') and (S[1]='0') do Delete(S,1,1);
if S<>'' then
  begin
  if S[1]=HexPrefix then
    begin
    S:=UpString(S);
    for I:=2 to Length(S) do
      if not (S[I] in ['0'..'9','A'..'F']) then GoTo 1;
    N:=0;
    for I:=Length(S) downto 2 do
      begin
      if S[I] in ['0'..'9'] then Inc(L, LongInt( Byte(S[I])-Ord('0')) shl N )
                            else Inc(L, LongInt( Byte(S[I])-Ord('A')+10) shl N );
      Inc(N, 4);
      end;
    end else Val(S, L, Err);
  end;
1:
StrToNum:=L;
end;

function NumToHexStr;
var
  S: string[8];
  I: Integer;
const
  Digits : array[0..$F] of Char = '0123456789ABCDEF';
begin
I:=8; S[0]:=Char(SizeOf(S)-1);
repeat
  S[I]:=Digits[L and $0000000F];
  L:=L shr 4;
  S[I-1]:=Digits[L and $0000000F];
  L:=L shr 4;
  Dec(I,2);
until I<=0;

while (S[1]='0') and (S<>'') do
  Delete(S, 1, 1);

if S='' then S:='0' else
if Odd(Length(S)) then S:='0'+S;
NumToHexStr:=HexPrefix+S;
end;

function NumToStr;
var
  S: string;
begin
Str(L,S);
NumToStr:=S;
end;

function NumToStrI;
var
  S: string;
begin
S:= NumToStr(L);
if N > Length(S) then
  S:= ReplStr('0', N-Length(S))+S;
NumToStrI:= S;
end;

function NumToHexStrI;
var
  S: string;
begin
S:= NumToHexStr(L);
if N > Length(S)-1 then
  Insert(ReplStr('0', N-Length(S)+1), S, 2);
NumToHexStrI:= S;
end;

function Bin2Hex(const S: string): string;
var
  I: Integer;
  _Result: string;
begin
  _Result:= '';
  for I:= 1 to Length(S) do
    _Result:= _Result+ Copy(NumToHexStrI(Byte(S[I]), 2), 2, 2);
  Bin2Hex:= _Result;
end;

function Hex2Bin(const S: string): string;
var
  I: Integer;
  B: Integer;
  _Result: string;
begin
  _Result:= '';
  I:= 1;
  while I <= Length(S) do
  begin
    B:= StrToNum(HexPrefix+Copy(S, I, 2));
    _Result:= _Result + Chr(B);
    Inc(I, 2);
  end;
  Hex2Bin:= _Result;
end;

function StripDecimals; { predpoklada korektni float string }
var
  I, J: Integer;
label
  _Break;
begin
I:= Pos('.', S);
if I<>0 then
  begin
  J:= Pos('E', UpString(S));
  if J = 0 then J:= Length(S)
           else Dec(J);
  while J >= I do
    if S[J] in ['0','.'] then begin
                              Delete(S, J, 1);
                              Dec(J);
                              end
                         else goto _Break;
  end;
_Break:
StripDecimals:= S;
end;

function StripExponent; { predpoklada korektni float string }
var
  I: Integer;
label
  _Break;
begin
I:= Pos('E', UpString(S));
if I<>0 then
  begin
  while (I+2 <= Length(S)) and (S[I+2] = '0') do
    Delete(S, I+2, 1);
  while Length(S) >= I do
    if S[Length(S)] in ['E','e','+','-'] then SetLength(S, Length(S)-1)
                                         else goto _Break;
  end;
_Break:
StripExponent:= S;
end;

{$IFNDEF WIN32}
procedure SetLength;
begin
  S[0]:= Char(NewLength);
end;
{$ENDIF}

{$IFNDEF USES_SYSUTILS}
  {$IFNDEF USES_DRIVERS}
{ String formatting routines }
{$L FORMAT.OBJ}
procedure FormatStr; external {FORMAT};
  {$ENDIF}
{$ENDIF}

end.
