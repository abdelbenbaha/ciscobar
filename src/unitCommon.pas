unit unitCommon;

interface

uses
  System.SysUtils, System.Classes, System.ImageList, FMX.ImgList,
  FMX.SVGIconImageList, FMX.Types, System.Net.URLClient, System.Net.HttpClient,
  System.Net.HttpClientComponent,Neslib.Xml,Neslib.Xml.Types,System.IOUtils,System.NetEncoding,System.RegularExpressions,fmx.Platform;

type
  TdmCommon = class(TDataModule)
    iconsSmall: TSVGIconImageList;
    iconsBig: TSVGIconImageList;
    httpClient: TNetHTTPClient;
    httpRequest: TNetHTTPRequest;
    procedure httpClientValidateServerCertificate(const Sender: TObject;
      const ARequest: TURLRequest; const Certificate: TCertificate;
      var Accepted: Boolean);
    procedure httpClientAuthEvent(const Sender: TObject;
      AnAuthTarget: TAuthTargetType; const ARealm, AURL: string; var AUserName,
      APassword: string; var AbortAuth: Boolean;
      var Persistence: TAuthPersistenceType);
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
  public
   applicationData:string;
   applicationPath:string;
   applicationStrings:TStrings;
   currentLanguage:string;
   function prepareAXLRequest(version,bodyns,body:string):string;
   function makeURL(baseURL,path:string):string;
   function isValidXML(aText:string):boolean;

   function getCCMVersion(const baseURL:string;out status:string):string;
   function execSearchQuery(const baseURL,version,searchQuery: string; out status: string): string;


   procedure writeParameter(aCategory,aName,aValue:string;aDescription:string='';isEncrypted:boolean=false);
   function readParameter(aCategory,aName:string):string;

   procedure setCredentials(aServer,aUsername,aPassword:string);
   function validateCredentials(aServer,aUsername,aPassword:string;out status:string):boolean;

   procedure loadStrings(const languageCode:string);
   function getStringByName(const name:string):string;

   end;

const
  appName='Ciscobar';//application name
  settingsFilename='settings.xml';//settings file

  axlService='axl';
  webDialerService='webdialer/services/WebdialerSoapService70';

var
  dmCommon: TdmCommon;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}
{$R *.dfm}
{$ifdef MSWINDOWS}
uses Winapi.Windows;
type
  DATA_BLOB = record
    cbData: DWORD;
    pbData: PAnsiChar;
  end;
  PDATA_BLOB = ^DATA_BLOB;

  const
  CRYPTPROTECT_UI_FORBIDDEN = $1;
  CRYPTDLL = 'Crypt32.dll';

function CryptProtectData(const DataIn: DATA_BLOB; szDataDescr: PWideChar;
  OptionalEntropy: PDATA_BLOB; Reserved, PromptStruct: Pointer; dwFlags: DWORD;
  var DataOut: DATA_BLOB): BOOL; stdcall; external CRYPTDLL name 'CryptProtectData';
function CryptUnprotectData(const DataIn: DATA_BLOB; szDataDescr: PWideChar;
  OptionalEntropy: PDATA_BLOB; Reserved, PromptStruct: Pointer; dwFlags: DWORD;
  var DataOut: DATA_BLOB): Bool; stdcall; external CRYPTDLL name 'CryptUnprotectData';
{$endif}

procedure TdmCommon.httpClientAuthEvent(const Sender: TObject;
  AnAuthTarget: TAuthTargetType; const ARealm, AURL: string; var AUserName,
  APassword: string; var AbortAuth: Boolean;
  var Persistence: TAuthPersistenceType);
begin
if length(httpClient.CredentialsStorage.Credentials)>0 then
  begin
  AUserName:=httpClient.CredentialsStorage.Credentials[0].UserName;
  APassword:=httpClient.CredentialsStorage.Credentials[0].Password;
  end;

end;

procedure TdmCommon.httpClientValidateServerCertificate(const Sender: TObject;
  const ARequest: TURLRequest; const Certificate: TCertificate;
  var Accepted: Boolean);
begin
Accepted:=true;//TOBECHECKED
end;


function TdmCommon.isValidXML(aText:string):Boolean;
begin
  with TXmlDocument.Create do
   try
   parse(aText);
   result:=true;
   except
   result:=false;
   end;
end;

function TdmCommon.prepareAXLRequest(version:string;bodyns:string;body:string):string;
var node:TXmlNode;
begin
if (bodyns='')then exit;
if version='' then version:='1.0';
 with TXmlDocument.Create do
 try
   with Root.AddElement('soapenv:Envelope') do
    begin
    AddAttribute('xmlns:soapenv','http://schemas.xmlsoap.org/soap/envelope/');
    AddAttribute('xmlns:ns',format('http://www.cisco.com/AXL/API/%s',[version]));
    AddElement('soapenv:Header');
    with AddElement('soapenv:Body') do
     begin
      node:=AddElement(format('ns:%s',[bodyns]));
      if body<>'' then
       with TStringList.Create do
        try
        text:=body;
        node.AddElement(Names[0]).AddText(ValueFromIndex[0]);
        finally
         Free;
        end;
     end;
   end;
    Result:=ToXml([TXmlOutputOption.Indent]);
 finally

 end;
end;

function TdmCommon.getCCMVersion(const baseURL:string;out status: string): string;
var reqXML:TstringStream;

begin
result:='';
status:='';
if baseURL='' then exit;

 reqXML:=TStringStream.Create(dmCommon.prepareAXLRequest('','getCCMVersion',''));
 try
    with dmcommon.httpRequest.Post(baseURL,reqXML,nil,nil) do
     case StatusCode of
     200:
         begin
           if not dmCommon.isValidXML(ContentAsString) then
           status:=getStringByName('unknownError')
           else
            with TXmlDocument.Create do
            try
            parse(ContentAsString);
            result:=DocumentElement.ElementByName('soapenv:Body').
                    ElementByName('ns:getCCMVersionResponse').
                    ElementByName('return').
                    ElementByName('componentVersion').
                    ElementByName('version').Text;
            finally
            Clear;
            end;
           end;
     401:
         begin
          status:=getStringByName('invalidCredentials');
         end;
     404:
         begin
         status:=getStringByName('invalidCucm');
         end;
     else
         begin
         status:=getStringByName('unknownError');
         end;

     end;
 except
 on e:ENetHTTPClientException do
  status:=getStringByName('checkNetwork');
 end;
end;

procedure TdmCommon.DataModuleCreate(Sender: TObject);
var
LocaleSvc: IFMXLocaleService;
begin
  applicationPath:=GetCurrentDir;
  applicationData:=TPath.GetHomePath+Tpath.DirectorySeparatorChar+appName;
  if not TDirectory.Exists(applicationData) then
    TDirectory.CreateDirectory(applicationData);
  if TPlatformServices.Current.SupportsPlatformService(IFMXLocaleService, LocaleSvc) then
    currentLanguage := LocaleSvc.GetCurrentLangID
  else
    currentLanguage := 'en';
  loadStrings(currentLanguage);
end;

function TdmCommon.execSearchQuery(const baseURL,version,searchQuery: string; out status: string): string;
var reqXML:TstringStream;
    child:TXmlNode;
begin
result:='';
status:='';
if (baseURL='') or (searchQuery='')  then exit;

 reqXML:=TStringStream.Create(dmCommon.prepareAXLRequest(version,'executeSQLQuery',searchQuery));
 try
    with dmcommon.httpRequest.Post(baseURL,reqXML,nil,nil) do
     case StatusCode of
     200:
         begin
           if not dmCommon.isValidXML(ContentAsString) then
           status:=getStringByName('unknownError')
           else
            Result:=ContentAsString;
         end;
     401:
         begin
         end;
     404:
         begin
         end;
     else
         begin
         end;

     end;
 except
 on e:ENetHTTPClientException do
  status:=getStringByName('checkNetwork');
 end;
end;

procedure TdmCommon.writeParameter(aCategory,aName,aValue:string;aDescription:string='';isEncrypted:boolean=false);
var settingFile:string;
begin
with TXmlDocument.Create do
 try
  settingFile:=applicationData+TPath.DirectorySeparatorChar+settingsFilename;
  if TFile.Exists(settingFile) then
   load(settingFile);
  if Root.ElementByName(aCategory)=nil then
   Root.AddElement(aCategory);
  if root.ElementByName(aCategory).ElementByName(aName)=nil then
    begin
      if aDescription<>'' then
      root.ElementByName(aCategory).AddComment(aDescription);
      root.ElementByName(aCategory).AddElement(aName);
    end;
   if not root.ElementByName(aCategory).ElementByName(aName).IsEmpty then
     root.ElementByName(aCategory).ElementByName(aName).RemoveAllChildren;

   if isEncrypted then
   begin
   if root.ElementByName(aCategory).ElementByName(aName).AttributeByName('encrypted')=nil then
    root.ElementByName(aCategory).ElementByName(aName).AddAttribute('encrypted','');
   {$ifdef MSWINDOWS}
     var dataIn,dataOut:DATA_BLOB;

     dataIn.pbData:=pointer(rawbytestring(aValue));
     dataIn.cbData:=length(rawbytestring(aValue));
     CryptProtectData(dataIn,nil,nil,nil,nil,0,dataOut);

     var output:RawByteString;
     SetString(output,dataOut.pbData,dataOut.cbData);
     root.ElementByName(aCategory).ElementByName(aName).AddText(TNetEncoding.Base64String.Encode(output));

   {$endif}
   end
   else
   root.ElementByName(aCategory).ElementByName(aName).AddText(aValue);
   Save(settingFile)
 finally
  Clear;
 end;

end;

function TdmCommon.readParameter(aCategory,aName:string):string;
var settingFile:string;
begin
with TXmlDocument.Create do
 try
  settingFile:=applicationData+TPath.DirectorySeparatorChar+settingsFilename;
  if not  TFile.Exists(settingFile) then exit('');
  load(settingFile);
  if (Root.ElementByName(aCategory)<>nil) and (root.ElementByName(aCategory).ElementByName(aName)<>nil) then
   begin
     if root.ElementByName(aCategory).ElementByName(aName).AttributeByName('encrypted')=nil then
      exit(root.ElementByName(aCategory).ElementByName(aName).Text)
     else
     begin
     {$ifdef MSWINDOWS}
       var dataIn,dataOut:DATA_BLOB;
       var aValue:RawByteString;

       aValue:=TNetEncoding.Base64String.Decode(root.ElementByName(aCategory).ElementByName(aName).Text);
       if aValue='' then exit('');

       dataIn.pbData:=pointer(aValue);
       dataIn.cbData:=length(aValue);
       CryptUnprotectData(dataIn,nil,nil,nil,nil,0,dataOut);
       var output:RawByteString;
       SetString(output,dataOut.pbData,dataOut.cbData);
       exit(output);
     {$endif}
     end;

   end;
 finally
  Clear;
 end;

end;


procedure TdmCommon.setCredentials(aServer,aUsername,aPassword:string);
begin
  if (aServer='') or (aUsername='') or (aPassword='') then exit;
    try
    httpClient.CredentialsStorage.ClearCredentials;
    //add username and password to Credentials storage.
    httpClient.CredentialsStorage.AddCredential(TCredentialsStorage.TCredential.Create(TAuthTargetType.Server,'',aServer,aUsername,aPassword));
    except
    //
    end;
end;

function TdmCommon.validateCredentials(aServer,aUsername,aPassword:string;out status:string):boolean;
begin
result:=false;
 if (aServer='') or (aUsername='') or (aPassword='') then
 begin
 status:=getStringByName('emptyFields');
 exit;
 end;

 if not(TRegEx.IsMatch(aServer,'^(https:\/\/)?([\da-zA-Z\.-\/:]+)$')) then
 begin
 status:=getStringByName('invalidUrl');
 exit;
 end;
 Result:=true;
end;

function TdmCommon.makeURL(baseURL,path:string):string;
begin
if not baseURL.EndsWith('/') then
 baseURL:=baseURL+'/';
if not Path.EndsWith('/') then
 path:=path+'/';
Result:=baseURL+path;
end;

procedure TdmCommon.loadStrings(const languageCode:string);
begin
if not assigned(applicationStrings) then
 applicationStrings:=TStringList.Create;
  with TXmlDocument.Create do
   try
   Load(applicationPath+Tpath.DirectorySeparatorChar+'locales'+Tpath.DirectorySeparatorChar+languageCode+'.xml');
   var child:TXmlNode;
   child:=DocumentElement.FirstChild;
    while (child <> nil) do
    begin
    applicationStrings.AddPair(child.Value,child.text);
    child := child.NextSibling;
    end;
   finally
    Clear;
   end;
end;

function TdmCommon.getStringByName(const name:string):string;
begin
  result:=applicationStrings.Values[name];
end;

end.
