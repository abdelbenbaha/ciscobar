program ciscobar;

uses
  System.StartUpCopy,
  FMX.Forms,
  Skia.FMX,
  unitSearch in 'unitSearch.pas' {frmSearch},
  unitFirst in 'unitFirst.pas' {frmFirst},
  unitCommon in 'unitCommon.pas' {dmCommon: TDataModule};

{$R *.res}

begin
  GlobalUseSkia := True;
  Application.Initialize;
  Application.CreateForm(TdmCommon, dmCommon);
  Application.CreateForm(TfrmSearch, frmSearch);
  Application.Run;
end.
