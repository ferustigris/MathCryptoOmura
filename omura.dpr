program omura;

uses
  Forms,
  main in 'main.pas' {Form1},
  bnumber in 'bnumber.pas',
  umd5 in 'umd5.pas',
  unod in 'unod.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
