program MakeFlash;

uses
  Forms,
  FFlash in 'FFlash.pas' {Flash};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'MakeFlash';
  Application.CreateForm(TFlash, Flash);
  Application.Run;

end.
