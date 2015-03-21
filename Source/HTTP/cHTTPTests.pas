{******************************************************************************}
{                                                                              }
{  2011/06/11  0.01  Initial version.                                          }
{  2011/06/23  0.02  Simple test case.                                         }
{                                                                              }
{******************************************************************************}

{$INCLUDE cHTTP.inc}

{$IFDEF HTTP_SELFTEST}
  {$DEFINE HTTP_SELFTEST_LOG_TO_CONSOLE}
  {$DEFINE HTTPSERVER_SELFTEST}
  {$DEFINE HTTPCLIENT_SELFTEST}
  {.DEFINE HTTPCLIENT_SELFTEST_WEB1}
  {.DEFINE HTTPCLIENT_SELFTEST_WEB2}
  {$DEFINE HTTPCLIENTSERVER_SELFTEST}
  {$IFDEF HTTP_TLS}
    {$DEFINE HTTPCLIENTSERVER_SELFTEST_HTTPS}
  {$ENDIF}
{$ENDIF}

unit cHTTPTests;

interface

uses
  cHTTPUtils,
  cHTTPClient,
  cHTTPServer;



{                                                                              }
{ Test cases                                                                   }
{                                                                              }
{$IFDEF HTTP_SELFTEST}
procedure SelfTest;
{$ENDIF}



implementation

uses
  SysUtils,
  SyncObjs,
  cUtils,
  cSocketLib
  {$IFDEF HTTP_TLS},
  cTLSHandshake
  {$ENDIF};



{$IFDEF HTTP_SELFTEST}
{$ASSERTIONS ON}

{                                                                              }
{ Test cases - Server                                                          }
{                                                                              }
{$IFDEF HTTPSERVER_SELFTEST}
type
  THTTPServerTestObj = class
    Lock : TCriticalSection;
    constructor Create;
    destructor Destroy; override;
    procedure HTTPServerLog(Server: TF4HTTPServer; LogType: THTTPServerLogType; Msg: String; LogLevel: Integer);
  end;

constructor THTTPServerTestObj.Create;
begin
  inherited Create;
  Lock := TCriticalSection.Create;
end;

destructor THTTPServerTestObj.Destroy;
begin
  FreeAndNil(Lock);
  inherited Destroy;
end;

procedure THTTPServerTestObj.HTTPServerLog(Server: TF4HTTPServer; LogType: THTTPServerLogType; Msg: String; LogLevel: Integer);
begin
  {$IFDEF HTTP_SELFTEST_LOG_TO_CONSOLE}
  Lock.Acquire;
  try
    Writeln(Msg);
  finally
    Lock.Release;
  end;
  {$ENDIF}
end;

procedure SelfTest_Server;
var
  Srv : TF4HTTPServer;
  Tst : THTTPServerTestObj;
begin
  Tst := THTTPServerTestObj.Create;
  Srv := TF4HTTPServer.Create(nil);
  try
    Srv.OnLog := Tst.HTTPServerLog;
    Srv.AddressFamily := safIP4;
    Srv.ServerPort := 8088;
    Assert(not Srv.Active);
    Srv.Active := True;
    Assert(Srv.Active);
    Sleep(100);
    Assert(Srv.Active);
    Srv.Active := False;
    Assert(not Srv.Active);
  finally
    Srv.Free;
    Tst.Free;
  end;
end;
{$ENDIF}




{                                                                              }
{ Test cases - Client                                                          }
{                                                                              }
{$IFDEF HTTPCLIENT_SELFTEST}
type
  THTTPClientTestObj = class
    Lock : TCriticalSection;
    constructor Create;
    destructor Destroy; override;
    procedure HTTPClientLog(Client: TF4HTTPClient; LogType: THTTPClientLogType; Msg: String; Level: Integer);
  end;

constructor THTTPClientTestObj.Create;
begin
  inherited Create;
  Lock := TCriticalSection.Create;
end;

destructor THTTPClientTestObj.Destroy;
begin
  FreeAndNil(Lock);
  inherited Destroy;
end;

procedure THTTPClientTestObj.HTTPClientLog(Client: TF4HTTPClient; LogType: THTTPClientLogType; Msg: String; Level: Integer);
begin
  {$IFDEF HTTP_SELFTEST_LOG_TO_CONSOLE}
  Lock.Acquire;
  try
    Writeln(Msg);
  finally
    Lock.Release;
  end;
  {$ENDIF}
end;

procedure SelfTest_Client;
var H : TF4HTTPClient;
    T : THTTPClientTestObj;

  {$IFDEF HTTPCLIENT_SELFTEST_WEB1}
  // Test simple connect and request sequence
  procedure SelfTestWeb1;
  begin
    H.Host := 'www.google.com';
    H.Port := '80';
    H.Method := cmGET;
    H.URI := '/';
    Assert(not H.Active);
    H.Active := True;
    Assert(H.Active);
    repeat
      Sleep(10);
    until H.State in [hcsStopping, hcsConnectFailed, hcsConnected_Ready];
    Assert(H.State = hcsConnected_Ready);
    Sleep(100);
    H.Request;
    repeat
      Sleep(10);
    until H.State in [hcsStopping, hcsConnectFailed, hcsResponseComplete, hcsResponseCompleteAndClosing, hcsConnected_Ready];
    Assert(H.State = hcsResponseComplete);
    H.Active := False;
    Assert(not H.Active);
  end;
  {$ENDIF}

  {$IFDEF HTTPCLIENT_SELFTEST_WEB2}
  // Test multiple requests
  procedure SelfTestWeb2;
  begin
    H.Host := 'www.google.com';
    // H.Host := 'www.cnn.com';
    H.Port := '80';
    H.Method := cmGET;
    H.URI := '/';
    Assert(not H.Active);
    H.Request;
    repeat
      Sleep(10);
    until H.State in [hcsStopping, hcsConnectFailed, hcsResponseComplete, hcsResponseCompleteAndClosing];
    Assert(H.State = hcsResponseComplete);
    Sleep(500);
    H.Request;
    repeat
      Sleep(10);
    until H.State in [hcsStopping, hcsConnectFailed, hcsResponseComplete, hcsResponseCompleteAndClosing];
    Assert(H.State = hcsResponseComplete);
    H.Active := False;
    Assert(not H.Active);
  end;
  {$ENDIF}

begin
  T := THTTPClientTestObj.Create;
  H := TF4HTTPClient.Create(nil);
  try
    H.OnLog := T.HTTPClientLog;
    H.UserAgent := 'Experimental';
    {$IFDEF HTTPCLIENT_SELFTEST_WEB1}
    SelfTestWeb1;
    {$ENDIF}
    {$IFDEF HTTPCLIENT_SELFTEST_WEB2}
    SelfTestWeb2;
    {$ENDIF}
  finally
    H.Free;
    T.Free;
  end;
end;
{$ENDIF}



{                                                                              }
{ Test cases - Client/Server                                                   }
{                                                                              }
{$IFDEF HTTPCLIENTSERVER_SELFTEST}
type
  THTTPClientServerTestObj = class
    Lock : TCriticalSection;
    constructor Create;
    destructor Destroy; override;
    procedure Log(Msg: String);
    procedure HTTPClientLog(Client: TF4HTTPClient; LogType: THTTPClientLogType; Msg: String; Level: Integer);
    procedure HTTPClientResponseHeader(Client: TF4HTTPClient);
    procedure HTTPClientResponseComplete(Client: TF4HTTPClient);
    procedure HTTPServerLog(Server: TF4HTTPServer; LogType: THTTPServerLogType; Msg: String; LogLevel: Integer);
    procedure HTTPServerPrepareResponse(Server: TF4HTTPServer; Client: THTTPServerClient);
    procedure HTTPServerRequestComplete(Server: TF4HTTPServer; Client: THTTPServerClient);
  end;

constructor THTTPClientServerTestObj.Create;
begin
  inherited Create;
  Lock := TCriticalSection.Create;
end;

destructor THTTPClientServerTestObj.Destroy;
begin
  FreeAndNil(Lock);
  inherited Destroy;
end;

procedure THTTPClientServerTestObj.Log(Msg: String);
begin
  {$IFDEF HTTP_SELFTEST_LOG_TO_CONSOLE}
  Lock.Acquire;
  try
    Writeln(Msg);
  finally
    Lock.Release;
  end;
  {$ENDIF}
end;

procedure THTTPClientServerTestObj.HTTPClientLog(Client: TF4HTTPClient; LogType: THTTPClientLogType; Msg: String; Level: Integer);
begin
  Log('C:' + IntToStr(Level) + ':' + Msg);
end;

procedure THTTPClientServerTestObj.HTTPClientResponseHeader(Client: TF4HTTPClient);
begin
  Assert(Client.ResponseCode = 200);
  Assert(Client.ResponseRecord.Header.CommonHeaders.ContentType.Value = hctTextHtml);
end;

procedure THTTPClientServerTestObj.HTTPClientResponseComplete(Client: TF4HTTPClient);
begin
  Assert(Client.ResponseContentStr = '<HTML>Test</HTML>');
end;

procedure THTTPClientServerTestObj.HTTPServerLog(Server: TF4HTTPServer; LogType: THTTPServerLogType; Msg: String; LogLevel: Integer);
begin
  Log('S:' + IntToStr(LogLevel) + ':' + Msg);
end;

procedure THTTPClientServerTestObj.HTTPServerPrepareResponse(Server: TF4HTTPServer; Client: THTTPServerClient);
begin
  Client.ResponseCode := 200;
  Client.ResponseMsg := 'OK';
  Client.ResponseContentType := 'text/html';
  Client.ResponseContentMechanism := hctmString;
  Client.ResponseContentStr := '<HTML>Test</HTML>';
  Client.ResponseReady := True;
end;

procedure THTTPClientServerTestObj.HTTPServerRequestComplete(Server: TF4HTTPServer; Client: THTTPServerClient);
begin
end;

procedure SelfTest_ClientServer_Simple(const HTTPS: Boolean);
var
  Srv : TF4HTTPServer;
  Cln : TF4HTTPClient;
  Tst : THTTPClientServerTestObj;
  T : Integer;
  {$IFDEF HTTPCLIENTSERVER_SELFTEST_HTTPS}
  CtL : TTLSCertificateList;
  {$ENDIF}
begin
  Tst := THTTPClientServerTestObj.Create;
  Srv := TF4HTTPServer.Create(nil);
  Cln := TF4HTTPClient.Create(nil);
  try
    Srv.OnLog := Tst.HTTPServerLog;
    Cln.OnLog := Tst.HTTPClientLog;
    //
    Srv.OnPrepareResponse := Tst.HTTPServerPrepareResponse;
    Srv.OnRequestComplete := Tst.HTTPServerRequestComplete;
    Srv.AddressFamily := safIP4;
    Srv.ServerPort := 8795;
    {$IFDEF HTTPCLIENTSERVER_SELFTEST_HTTPS}
    if HTTPS then
      begin
        Srv.TCPServer.TLSServer.PrivateKeyRSAPEM := // from stunnel pem file
            'MIICXAIBAAKBgQCxUFMuqJJbI9KnB8VtwSbcvwNOltWBtWyaSmp7yEnqwWel5TFf' +
            'cOObCuLZ69sFi1ELi5C91qRaDMow7k5Gj05DZtLDFfICD0W1S+n2Kql2o8f2RSvZ' +
            'qD2W9l8i59XbCz1oS4l9S09L+3RTZV9oer/Unby/QmicFLNM0WgrVNiKywIDAQAB' +
            'AoGAKX4KeRipZvpzCPMgmBZi6bUpKPLS849o4pIXaO/tnCm1/3QqoZLhMB7UBvrS' +
            'PfHj/Tejn0jjHM9xYRHi71AJmAgzI+gcN1XQpHiW6kATNDz1r3yftpjwvLhuOcp9' +
            'tAOblojtImV8KrAlVH/21rTYQI+Q0m9qnWKKCoUsX9Yu8UECQQDlbHL38rqBvIMk' +
            'zK2wWJAbRvVf4Fs47qUSef9pOo+p7jrrtaTqd99irNbVRe8EWKbSnAod/B04d+cQ' +
            'ci8W+nVtAkEAxdqPOnCISW4MeS+qHSVtaGv2kwvfxqfsQw+zkwwHYqa+ueg4wHtG' +
            '/9+UgxcXyCXrj0ciYCqURkYhQoPbWP82FwJAWWkjgTgqsYcLQRs3kaNiPg8wb7Yb' +
            'NxviX0oGXTdCaAJ9GgGHjQ08lNMxQprnpLT8BtZjJv5rUOeBuKoXagggHQJAaUAF' +
            '91GLvnwzWHg5p32UgPsF1V14siX8MgR1Q6EfgKQxS5Y0Mnih4VXfnAi51vgNIk/2' +
            'AnBEJkoCQW8BTYueCwJBALvz2JkaUfCJc18E7jCP7qLY4+6qqsq+wr0t18+ogOM9' +
            'JIY9r6e1qwNxQ/j1Mud6gn6cRrObpRtEad5z2FtcnwY=';
        TLSCertificateListAppend(CtL,
          MIMEBase64Decode( // from stunnel pem file
            'MIICDzCCAXigAwIBAgIBADANBgkqhkiG9w0BAQQFADBCMQswCQYDVQQGEwJQTDEf' +
            'MB0GA1UEChMWU3R1bm5lbCBEZXZlbG9wZXJzIEx0ZDESMBAGA1UEAxMJbG9jYWxo' +
            'b3N0MB4XDTk5MDQwODE1MDkwOFoXDTAwMDQwNzE1MDkwOFowQjELMAkGA1UEBhMC' +
            'UEwxHzAdBgNVBAoTFlN0dW5uZWwgRGV2ZWxvcGVycyBMdGQxEjAQBgNVBAMTCWxv' +
            'Y2FsaG9zdDCBnzANBgkqhkiG9w0BAQEFAAOBjQAwgYkCgYEAsVBTLqiSWyPSpwfF' +
            'bcEm3L8DTpbVgbVsmkpqe8hJ6sFnpeUxX3Djmwri2evbBYtRC4uQvdakWgzKMO5O' +
            'Ro9OQ2bSwxXyAg9FtUvp9iqpdqPH9kUr2ag9lvZfIufV2ws9aEuJfUtPS/t0U2Vf' +
            'aHq/1J28v0JonBSzTNFoK1TYissCAwEAAaMVMBMwEQYJYIZIAYb4QgEBBAQDAgZA' +
            'MA0GCSqGSIb3DQEBBAUAA4GBAAhYFTngWc3tuMjVFhS4HbfFF/vlOgTu44/rv2F+' +
            'ya1mEB93htfNxx3ofRxcjCdorqONZFwEba6xZ8/UujYfVmIGCBy4X8+aXd83TJ9A' +
            'eSjTzV9UayOoGtmg8Dv2aj/5iabNeK1Qf35ouvlcTezVZt2ZeJRhqUHcGaE+apCN' +
            'TC9Y'));
        Srv.TCPServer.TLSServer.CertificateList := CtL;
      end;
    Srv.HTTPSEnabled := HTTPS;
    {$ENDIF}
    Srv.Active := True;
    Assert(Srv.Active);
    //
    Cln.OnResponseHeader := Tst.HTTPClientResponseHeader;
    Cln.OnResponseComplete := Tst.HTTPClientResponseComplete;
    Cln.ResponseContentMechanism := hcrmString;
    Cln.AddressFamily := cafIP4;
    Cln.Port := '8795';
    Cln.Host := '127.0.0.1';
    Cln.URI := '/';
    Cln.Method := cmGET;
    {$IFDEF HTTPCLIENTSERVER_SELFTEST_HTTPS}
    Cln.UseHTTPS := HTTPS;
    {$ENDIF}
    Cln.Active := True;
    Cln.Request;

    T := 0;
    repeat
      Sleep(1);
    until (T > 2000) or (Srv.ClientCount = 1);
    Assert(Srv.ClientCount = 1);

    T := 0;
    repeat
      Sleep(1);
    until (T > 2000) or (Cln.State in [hcsResponseComplete, hcsResponseCompleteAndClosed]);
    Assert(Cln.State in [hcsResponseComplete, hcsResponseCompleteAndClosed]);

    Cln.Active := False;
    Assert(not Cln.Active);

    T := 0;
    repeat
      Sleep(1);
    until (T > 2000) or (Srv.ClientCount = 0);
    Assert(Srv.ClientCount = 0);

    Srv.Active := False;
    Assert(not Srv.Active);
  finally
    Cln.Free;
    Srv.Free;
    Tst.Free;
  end;
end;

procedure SelfTest_ClientServer;
begin
  SelfTest_ClientServer_Simple(False);
  {$IFDEF HTTPCLIENTSERVER_SELFTEST_HTTPS}
  SelfTest_ClientServer_Simple(True);
  {$ENDIF}
end;
{$ENDIF}

procedure SelfTest;
begin
  {$IFDEF HTTPSERVER_SELFTEST}
  SelfTest_Server;
  {$ENDIF}
  {$IFDEF HTTPCLIENT_SELFTEST}
  SelfTest_Client;
  {$ENDIF}
  {$IFDEF HTTPCLIENTSERVER_SELFTEST}
  SelfTest_ClientServer;
  {$ENDIF}
end;
{$ENDIF}



end.

