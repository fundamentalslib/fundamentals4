{******************************************************************************}
{                                                                              }
{   Library:          Fundamentals 4.00                                        }
{   File name:        cTCPTests.pas                                            }
{   File version:     4.04                                                     }
{   Description:      TCP components.                                          }
{                                                                              }
{   Copyright:        Copyright (c) 2007-2011, David J Butler                  }
{                     All rights reserved.                                     }
{                     This file is licensed under the BSD License.             }
{                     See http://www.opensource.org/licenses/bsd-license.php   }
{                     Redistribution and use in source and binary forms, with  }
{                     or without modification, are permitted provided that     }
{                     the following conditions are met:                        }
{                     Redistributions of source code must retain the above     }
{                     copyright notice, this list of conditions and the        }
{                     following disclaimer.                                    }
{                     THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND   }
{                     CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED          }
{                     WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED   }
{                     WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A          }
{                     PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL     }
{                     THE REGENTS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,    }
{                     INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR             }
{                     CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,    }
{                     PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF     }
{                     USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)         }
{                     HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER   }
{                     IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING        }
{                     NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE   }
{                     USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE             }
{                     POSSIBILITY OF SUCH DAMAGE.                              }
{                                                                              }
{   Home page:        http://fundementals.sourceforge.net                      }
{   Forum:            http://sourceforge.net/forum/forum.php?forum_id=2117     }
{   E-mail:           fundamentals.library@gmail.com                           }
{                                                                              }
{ Revision history:                                                            }
{   2010/12/15  0.01  Test for TLS client/server.                              }
{   2011/01/02  0.02  Test for large buffers.                                  }
{   2011/04/22  0.03  Simple buffer tests.                                     }
{   2011/04/22  4.04  Test for multiple connections.                           }
{   2011/10/13  4.05  SSL3 tests.                                              }
{   2012/04/19  4.06  Test for stopping and restarting client.                 }
{                                                                              }
{ Todo:                                                                        }
{ - Test case socks proxy                                                      }
{ - Test case buffer full/empty events                                         }
{ - Test case deferred shutdown                                                }
{ - Test case throttling                                                       }
{ - Test case read/write rate reporting                                        }
{ - Test case multiple proxies                                                 }
{ - Test case writing large chunks                                             }
{ - Test case performance                                                      }
{ - Test case stress test (throughput and number of connections)               }
{ - See SSL3 test case                                                         }
{******************************************************************************}

{$INCLUDE cTCP.inc}

{$IFDEF DEBUG}
{$IFDEF SELFTEST}
  {$DEFINE TCP_SELFTEST}
  {$DEFINE TCP_SELFTEST_LOG_TO_CONSOLE}
{$ENDIF}
{$ENDIF}

{$IFDEF TCP_SELFTEST}
{$IFDEF TCPSERVER_TLS}
  {$DEFINE TCPSERVER_SELFTEST}
  {$DEFINE TCPSERVER_SELFTEST_TLS}
{$ENDIF}
{$ENDIF}

{$IFDEF TCP_SELFTEST}
  {$DEFINE TCPCLIENT_SELFTEST}
  {.DEFINE TCPCLIENT_SELFTEST_TLS_LOCAL_PROXY}
  {$DEFINE TCPCLIENT_SELFTEST_TLS_WEB}
  {$DEFINE TCPCLIENT_SELFTEST_WEB}
{$ENDIF}

{$IFDEF TCP_SELFTEST}
  {$IFDEF TCPCLIENT_TLS}
  {$IFDEF TCPSERVER_TLS}
    {$DEFINE TCPCLIENTSERVER_SELFTEST}
    {$DEFINE TCPCLIENTSERVER_SELFTEST_TLS}
  {$ENDIF}
  {$ENDIF}
{$ENDIF}

{$IFDEF TCPCLIENT_TLS}
  {$DEFINE TCP_USES_TLS}
{$ENDIF}
{$IFDEF TCPSERVER_TLS}
  {$DEFINE TCP_USES_TLS}
{$ENDIF}

unit cTCPTests;

interface



{                                                                              }
{ Test cases                                                                   }
{                                                                              }
{$IFDEF TCP_SELFTEST}
procedure SelfTest;
{$ENDIF}



implementation

uses
  {$IFDEF OS_MSWIN}
  Windows,
  {$ENDIF}
  SysUtils,
  SyncObjs,
  cSocketLib,
  {$IFDEF TCP_USES_TLS}
  cTLSConnection,
  cTLSClient,
  {$ENDIF}
  cTCPBuffer,
  cTCPConnection,
  cTCPClient,
  cTCPServer;



{$IFDEF TCP_SELFTEST}
{$ASSERTIONS ON}

{                                                                              }
{ Test cases - Buffer                                                          }
{                                                                              }
procedure SelfTest_Buffer;
var A : TTCPBuffer;
    S : AnsiString;
    I, L : Integer;
begin
  TCPBufferInitialise(A, 1500, 1000);
  Assert(TCPBufferUsed(A) = 0);
  Assert(TCPBufferAvailable(A) = 1500);
  TCPBufferSetMaxSize(A, 2000);
  Assert(TCPBufferAvailable(A) = 2000);
  S := 'Fundamentals';
  L := Length(S);
  TCPBufferAddBuf(A, S[1], L);
  Assert(TCPBufferUsed(A) = L);
  Assert(not TCPBufferEmpty(A));
  FillChar(S[1], L, 'X');
  Assert(S = 'XXXXXXXXXXXX');
  TCPBufferPeek(A, S[1], 3);
  Assert(S = 'FunXXXXXXXXX');
  FillChar(S[1], L, #0);
  TCPBufferRemove(A, S[1], L);
  Assert(S = 'Fundamentals');
  Assert(TCPBufferUsed(A) = 0);
  S := 'X';
  for I := 1 to 2001 do
    begin
      S[1] := AnsiChar(I mod 256);
      TCPBufferAddBuf(A, S[1], 1);
      Assert(TCPBufferUsed(A) = I);
      Assert(TCPBufferAvailable(A) = 2000 - I);
    end;
  for I := 1 to 2001 do
    begin
      S[1] := 'X';
      TCPBufferRemove(A, S[1], 1);
      Assert(S[1] = AnsiChar(I mod 256));
      Assert(TCPBufferUsed(A) = 2001 - I);
    end;
  Assert(TCPBufferEmpty(A));
  TCPBufferShrink(A);
  Assert(TCPBufferEmpty(A));
  TCPBufferFinalise(A);
end;



{                                                                              }
{ Test cases - Server                                                          }
{                                                                              }
{$IFDEF TCPSERVER_SELFTEST}
procedure SelfTest_Server_Simple;
var S : TF4TCPServer;
    I : Integer;
begin
  S := TF4TCPServer.Create(nil);
  try
    // init
    S.AddressFamily := iaIP4;
    S.ServerPort := 12345;
    S.MaxClients := -1;
    Assert(S.State = ssInit);
    Assert(not S.Active);
    // activate
    S.Active := True;
    Assert(S.Active);
    I := 0;
    repeat
      Inc(I);
      Sleep(1);
    until (S.State <> ssStarting) or (I >= 5000);
    Assert(S.State = ssReady);
    Assert(S.ClientCount = 0);
    // shut down
    S.Active := False;
    Assert(not S.Active);
    Assert(S.State = ssClosed);
  finally
    S.Free;
  end;

  S := TF4TCPServer.Create(nil);
  try
    // init
    S.AddressFamily := iaIP4;
    S.ServerPort := 12345;
    S.MaxClients := -1;
    Assert(S.State = ssInit);
    for I := 1 to 10 do
      begin
        // activate
        Assert(not S.Active);
        S.Active := True;
        Assert(S.Active);
        // deactivate
        S.Active := False;
        Assert(not S.Active);
        Assert(S.State = ssClosed);
      end;
  finally
    S.Free;
  end;
end;

{$IFDEF TCPSERVER_SELFTEST_TLS}
procedure SelfTest_Server_TLS;
var S : TF4TCPServer;
begin
  S := TF4TCPServer.Create(nil);
  try
    // init
    S.AddressFamily := iaIP4;
    S.ServerPort := 12345;
    S.TLSEnabled := True;
    S.TLSServer.PrivateKeyRSAPEM := // from stunnel.pem file
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
    S.Active := True;
  finally
    S.Free;
  end;
end;
{$ENDIF}

procedure SelfTest_Server;
begin
  SelfTest_Server_Simple;
  {$IFDEF TCPSERVER_SELFTEST_TLS}
  SelfTest_Server_TLS;
  {$ENDIF}
end;
{$ENDIF}



{                                                                              }
{ Test cases - Client                                                          }
{                                                                              }
{$IFDEF TCPCLIENT_SELFTEST}
type
  TTCPClientSelfTestObj = class
    States  : array[TTCPClientState] of Boolean;
    Connect : Boolean;
    LogMsg  : AnsiString;
    Lock    : TCriticalSection;
    constructor Create;
    destructor Destroy; override;
    procedure ClientLog(Sender: TF4TCPClient; LogType: TTCPClientLogType; LogMsg: String; LogLevel: Integer);
    procedure ClientConnect(Client: TF4TCPClient);
    procedure ClientStateChanged(Client: TF4TCPClient; State: TTCPClientState);
  end;

constructor TTCPClientSelfTestObj.Create;
begin
  inherited Create;
  Lock := TCriticalSection.Create;
end;

destructor TTCPClientSelfTestObj.Destroy;
begin
  FreeAndNil(Lock);
  inherited Destroy;
end;

procedure TTCPClientSelfTestObj.ClientLog(Sender: TF4TCPClient; LogType: TTCPClientLogType; LogMsg: String; LogLevel: Integer);
begin
  {$IFDEF TCP_SELFTEST_LOG_TO_CONSOLE}
  Lock.Acquire;
  try
    Writeln(LogLevel:2, ' ', LogMsg);
  finally
    Lock.Release;
  end;
  {$ENDIF}
end;

procedure TTCPClientSelfTestObj.ClientConnect(Client: TF4TCPClient);
begin
  Connect := True;
end;

procedure TTCPClientSelfTestObj.ClientStateChanged(Client: TF4TCPClient; State: TTCPClientState);
begin
  States[State] := True;
end;

{$IFDEF TCPCLIENT_SELFTEST_WEB}
procedure SelfTest_Client_Web;
var C : TF4TCPClient;
    S : AnsiString;
    A : TTCPClientSelfTestObj;
begin
  A := TTCPClientSelfTestObj.Create;
  C := TF4TCPClient.Create(nil);
  try
    // init
    C.OnLog := A.ClientLog;
    C.LocalHost := '0.0.0.0';
    C.Host := 'www.google.com';
    C.Port := '80';
    C.OnStateChanged := A.ClientStateChanged;
    C.OnConnected := A.ClientConnect;
    C.WaitForStartup := True;
    Assert(not C.Active);
    Assert(C.State = csInit);
    Assert(C.IsConnectionClosed);
    Assert(not A.Connect);
    // start
    C.Active := True;
    Assert(C.Active);
    Assert(C.State <> csInit);
    Assert(A.States[csStarting]);
    Assert(C.IsConnectingOrConnected);
    Assert(not C.IsConnectionClosed);
    // wait connect
    C.WaitConnect(8000);
    Assert(C.IsConnected);
    Assert(C.State = csReady);
    Assert(C.Connection.State = cnsConnected);
    Assert(A.Connect);
    Assert(A.States[csConnecting]);
    Assert(A.States[csConnected]);
    Assert(A.States[csReady]);
    // send request
    C.Connection.WriteStrA(
        'GET / HTTP/1.1'#13#10 +
        'Host: www.google.com'#13#10 +
        'Date: 7 Nov 2013 12:34:56 GMT'#13#10 +
        #13#10);
    // wait response
    C.WaitReceive(1, 5000);
    // read response
    S := C.Connection.ReadStr(C.Connection.ReadBufferSize);
    Assert(S <> '');
    // close
    C.Connection.Close;
    C.WaitClose(2000);
    Assert(not C.IsConnected);
    Assert(C.IsConnectionClosed);
    Assert(C.Connection.State = cnsClosed);
    // stop
    C.Active := False;
    Assert(not C.Active);
    Assert(C.IsConnectionClosed);
  finally
    C.Free;
    A.Free;
  end;
end;
{$ENDIF}

{$IFDEF TCPCLIENT_TLS}
{$IFDEF TCPCLIENT_SELFTEST_TLS_LOCAL_PROXY}
// Test TLS with local proxy
procedure SelfTest_Client_TLS1(const TLSClientOptions: TTCPClientTLSOptions);
var C : TF4TCPClient;
    I, L : Integer;
    S : AnsiString;
    A : TTCPClientSelfTestObj;
begin
  A := TTCPClientSelfTestObj.Create;
  C := TF4TCPClient.Create(nil);
  try
    // init
    C.OnLog := A.ClientLog;
    C.TLSEnabled := True;
    C.TLSClientOptions := TLSClientOptions;
    C.LocalHost := '0.0.0.0';
    C.Host := '127.0.0.1';
    C.Port := '443';
    C.WaitForStartup := True;
    // start
    C.Active := True;
    Assert(C.Active);
    // wait connect
    I := 0;
    repeat
      Sleep(1);
      Inc(I);
    until (
            (C.State in [csReady, csClosed]) and
            (C.TLSClient.ConnectionState in [tlscoApplicationData, tlscoErrorBadProtocol, tlscoCancelled, tlscoClosed]) and
            (C.Connection.State = cnsConnected)
          ) or
          (I = 5000);
    Assert(C.State = csReady);
    Assert(C.Connection.State = cnsConnected);
    Assert(C.TLSClient.ConnectionState = tlscoApplicationData);
    // send
    S :=
        'GET / HTTP/1.1'#13#10 +
        'Host: www.google.com'#13#10 +
        'Date: 17 Dec 2010 12:34:56 GMT'#13#10 +
        'User-Agent: Experimental'#13#10 +
        #13#10;
    C.Connection.Write(S[1], Length(S));
    C.WaitTransmit(5000);
    // read
    C.WaitReceive(1, 5000);
    L := C.Connection.ReadBufferSize;
    Assert(L > 0);
    SetLength(S, L);
    Assert(C.Connection.Read(S[1], L) = L);
    Assert(Copy(S, 1, 6) = 'HTTP/1');
    // close
    C.ShutdownAndWait(1000, 1000);
    Assert(C.Connection.State = cnsClosed);
    // stop
    C.Active := False;
    Assert(not C.Active);
  finally
    C.Free;
    A.Free;
  end;
end;
{$ENDIF}

{$IFDEF TCPCLIENT_SELFTEST_TLS_WEB}
// Test TLS with web site
const
  TLSTest2Host = 'www.google.com';
  // TLSTest2Host = 'tls.woodgrovebank.com';
  // TLSTest2Host = 'www.gmail.com';

procedure SelfTest_Client_TLS2(const TLSClientOptions: TTCPClientTLSOptions);
var C : TF4TCPClient;
    I, L : Integer;
    S : AnsiString;
    A : TTCPClientSelfTestObj;
begin
  A := TTCPClientSelfTestObj.Create;
  C := TF4TCPClient.Create(nil);
  try
    // init
    C.OnLog := A.ClientLog;
    C.TLSEnabled := True;
    C.TLSOptions := TLSClientOptions;
    C.LocalHost := '0.0.0.0';
    C.Host := TLSTest2Host;
    C.Port := '443';
    C.TLSEnabled := True;
    C.TLSOptions := TLSClientOptions;
    // start
    C.Active := True;
    Assert(C.Active);
    // wait connect
    I := 0;
    repeat
      Sleep(1);
      Inc(I);
    until (
            (C.State in [csReady, csClosed]) and
            (C.TLSClient.ConnectionState in [tlscoApplicationData, tlscoErrorBadProtocol, tlscoCancelled, tlscoClosed]) and
            (C.Connection.State = cnsConnected)
          ) or
          (I = 5000);
    Assert(C.State = csReady);
    Assert(C.Connection.State = cnsConnected);
    Assert(C.TLSClient.ConnectionState = tlscoApplicationData);
    // send
    S :=
        'GET / HTTP/1.1'#13#10 +
        'Host: ' + TLSTest2Host + #13#10 +
        'Date: 11 Oct 2011 12:34:56 GMT'#13#10 +
        #13#10;
    C.Connection.Write(S[1], Length(S));
    C.WaitTransmit(5000);
    // read
    C.WaitReceive(1, 5000);
    L := C.Connection.ReadBufferSize;
    Assert(L > 0);
    SetLength(S, L);
    Assert(C.Connection.Read(S[1], L) = L);
    Assert(Copy(S, 1, 6) = 'HTTP/1');
    // close
    C.BlockingShutdown(1000, 1000);
    Assert(C.Connection.State = cnsClosed);
    // stop
    C.Active := False;
    Assert(not C.Active);
  finally
    C.Free;
    A.Free;
  end;
end;
{$ENDIF}
{$ENDIF}

procedure SelfTest_Client;
begin
  {$IFDEF TCPCLIENT_SELFTEST_WEB}
  SelfTest_Client_Web;
  {$ENDIF}
  {$IFDEF TCPCLIENT_TLS}
  {$IFDEF TCPCLIENT_SELFTEST_TLS_LOCAL_PROXY}
  // SelfTest_Client_TLS1([ctoDontUseSSL3, ctoDontUseTLS10, ctoDontUseTLS11]); // TLS 1.2 - not supported by stunnel
  // SelfTest_Client_TLS1([ctoDontUseSSL3, ctoDontUseTLS10, ctoDontUseTLS12]); // TLS 1.1 - not supported by stunnel
  SelfTest_Client_TLS1([ctoDontUseSSL3, ctoDontUseTLS11, ctoDontUseTLS12]); // TLS 1.0
  {$ENDIF}
  {$IFDEF TCPCLIENT_SELFTEST_TLS_WEB}
  // SelfTest_Client_TLS2([]);
  //SelfTest_Client_TLS2([ctoDontUseTLS10, ctoDontUseTLS11, ctoDontUseTLS12]); // SSL 3
  SelfTest_Client_TLS2([ctoDontUseSSL3,  ctoDontUseTLS11, ctoDontUseTLS12]); // TLS 1.0
  //SelfTest_Client_TLS2([ctoDontUseSSL3,  ctoDontUseTLS10, ctoDontUseTLS12]); // TLS 1.1
  //SelfTest_Client_TLS2([ctoDontUseSSL3,  ctoDontUseTLS10, ctoDontUseTLS11]); // TLS 1.2
  {$ENDIF}
  {$ENDIF}
end;
{$ENDIF}



{                                                                              }
{ Test cases - Client/Server                                                   }
{                                                                              }
{$IFDEF TCPCLIENTSERVER_SELFTEST}
type
  TClientServerTestMode = (
    tmSimple,
    tmTLS);

  TTCPDebugObj = class
    Lock : TCriticalSection;
    constructor Create;
    destructor Destroy; override;
    procedure Log(Msg: String);
    procedure ClientLog(Client: TF4TCPClient; LogType: TTCPClientLogType; Msg: String; LogLevel: Integer);
    procedure ServerLog(Sender: TF4TCPServer; LogType: TTCPLogType; Msg: String; LogLevel: Integer);
  end;

constructor TTCPDebugObj.Create;
begin
  inherited Create;
  Lock := TCriticalSection.Create;
end;

destructor TTCPDebugObj.Destroy;
begin
  FreeAndNil(Lock);
  inherited Destroy;
end;

{$IFDEF TCP_SELFTEST_LOG_TO_CONSOLE}
procedure TTCPDebugObj.Log(Msg: String);
var S : String;
begin
  S := FormatDateTime('hh:nn:ss.zzz', Now) + ' ' + Msg;
  Lock.Acquire;
  try
    Writeln(S);
  finally
    Lock.Release;
  end;
end;
{$ELSE}
procedure TTCPDebugObj.Log(Msg: String);
begin
end;
{$ENDIF}

procedure TTCPDebugObj.ClientLog(Client: TF4TCPClient; LogType: TTCPClientLogType; Msg: String; LogLevel: Integer);
begin
  Log('C[' + IntToStr(Client.Tag) + ']:' + Msg);
end;

procedure TTCPDebugObj.ServerLog(Sender: TF4TCPServer; LogType: TTCPLogType; Msg: String; LogLevel: Integer);
begin
  Log('S:' + Msg);
end;

procedure SelfTestClientServer(
          const Mode: TClientServerTestMode;
          const TestClientCount: Integer;
          const TestLargeBlock: Boolean
          {$IFDEF TCPCLIENTSERVER_SELFTEST_TLS};
          const TLSClientOptions: TTCPCLientTLSOptions = [ctoDontUseSSL3]
          {$ENDIF}
          );

  procedure WaitClientConnected(const Client: TF4TCPClient);
  var I : Integer;
  begin
    // wait for client to connect and finish TLS
    I := 0;
    repeat
      Inc(I);
      Sleep(1);
    until (I >= 8000) or
          (
           (Client.State in [csReady, csClosed])
           {$IFDEF TCPCLIENTSERVER_SELFTEST_TLS}
           and
           (
              not Client.TLSEnabled or
             (Client.TLSClient.IsFinishedState or Client.TLSClient.IsReadyState)
           )
          {$ENDIF}
          );
    Assert(Client.State = csReady);
    Assert(Client.Connection.State = cnsConnected);
    {$IFDEF TCPCLIENTSERVER_SELFTEST_TLS}
    Assert(not Client.TLSEnabled or Client.TLSClient.IsReadyState);
    {$ENDIF}
  end;

const
  LargeBlockSize = 256 * 1024;

var C : array of TF4TCPClient;
    S : TF4TCPServer;
    T : array of TTCPServerClient;
    I, J, K : Integer;
    F : AnsiString;
    {$IFDEF TCPCLIENTSERVER_SELFTEST_TLS}
    // CtL : TTLSCertificateList;
    {$ENDIF}
    DebugObj : TTCPDebugObj;
begin
  DebugObj := TTCPDebugObj.Create;
  S := TF4TCPServer.Create(nil);
  SetLength(C, TestClientCount);
  SetLength(T, TestClientCount);
  for K := 0 to TestClientCount - 1 do
    begin
      C[K] := TF4TCPClient.Create(nil);
      // init client
      C[K].Tag := K + 1;
      C[K].OnLog := DebugObj.ClientLog;
      {$IFDEF TCPCLIENTSERVER_SELFTEST_TLS}
      C[K].TLSOptions := TLSClientOptions;
      {$ENDIF}
    end;
  try
    // init server
    S.OnLog := DebugObj.ServerLog;
    S.AddressFamily := iaIP4;
    S.BindAddress := '127.0.0.1';
    S.ServerPort := 12345;
    S.MaxClients := -1;
    {$IFDEF TCPCLIENTSERVER_SELFTEST_TLS}
    S.TLSEnabled := Mode = tmTLS;

    (*
    S.TLSServer.PrivateKeyRSAPEM := // from stunnel pem file
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
    S.TLSServer.CertificateList := CtL;
    *)

    S.TLSServer.PEMText :=
      '-----BEGIN CERTIFICATE-----' +
      'MIIDQjCCAiqgAwIBAgIJAKDslQh3d8kdMA0GCSqGSIb3DQEBBQUAMB8xHTAbBgNV' +
      'BAMTFHd3dy5ldGVybmFsbGluZXMuY29tMB4XDTExMTAxODEwMzYwOVoXDTIxMTAx' +
      'NTEwMzYwOVowHzEdMBsGA1UEAxMUd3d3LmV0ZXJuYWxsaW5lcy5jb20wggEiMA0G' +
      'CSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCw/7d6zyehR69DaJCGbk3oMP7pSWya' +
      'U1tDMG+CdqikLqHoo3SBshbvquOVFcy9yY8fECTbNXfOjhV0M6SJgGQ/SP/nfZgx' +
      'MHAK9sWc5G6V5sqPqrTRgkv0Wu25mdO6FRh8DIxOMY0Ppqno5hHZ0emSj1amvtWX' +
      'zBD6pXNGgrFln6HL2eyCwqlL0wTXWO/YrvblF/83Ln9i6luVQ9NtACQBiPcYqoNM' +
      '1OG142xYNpRNp7zrHkNCQeXVxmC6goCgj0BmcSqrUPayLdgkgv8hniUwLYQIt91r' +
      'cxJwGNWxlbLgqQqTdhecKp01JVgO8jy3yFpMEoqCj9+BuuxVqDfvHK1tAgMBAAGj' +
      'gYAwfjAdBgNVHQ4EFgQUbLgD+S3ZSNlU1nxTsjTmAQIfpCQwTwYDVR0jBEgwRoAU' +
      'bLgD+S3ZSNlU1nxTsjTmAQIfpCShI6QhMB8xHTAbBgNVBAMTFHd3dy5ldGVybmFs' +
      'bGluZXMuY29tggkAoOyVCHd3yR0wDAYDVR0TBAUwAwEB/zANBgkqhkiG9w0BAQUF' +
      'AAOCAQEACSQTcPC8ga5C/PysnoTNAk4OB+hdgMoS3Fv7ROUV9GqgYED6rJo0+CxD' +
      'g19GLlKt/aBlglh4Ddc7X84dWtftS4JIjjVVkWevt8/sDoZ+ISd/tC9aDX3gOAlW' +
      'RORhfp3Qtyy0AjZcIOAGNkzkotuMG/uOVifPFhTNXwa8hHOGN60riGXEj5sNFFop' +
      'EaxplTfakVq8TxlQivnIETjrEbVX8XkOl4nlsHevC2suXE1ZkQIbQoaAy0WzGGUR' +
      '54GBIzXf32t80S71w5rs/mzVaGOeTZYcHtv5Epd9CNVrEle6w0NW9R7Ov4gXI9n8' +
      'GV9jITGfsOdqu7j9Iaf7MVj+JRE7Dw==' +
      '-----END CERTIFICATE-----' +
      '-----BEGIN RSA PRIVATE KEY-----' +
      'MIIEpQIBAAKCAQEAsP+3es8noUevQ2iQhm5N6DD+6UlsmlNbQzBvgnaopC6h6KN0' +
      'gbIW76rjlRXMvcmPHxAk2zV3zo4VdDOkiYBkP0j/532YMTBwCvbFnORulebKj6q0' +
      '0YJL9FrtuZnTuhUYfAyMTjGND6ap6OYR2dHpko9Wpr7Vl8wQ+qVzRoKxZZ+hy9ns' +
      'gsKpS9ME11jv2K725Rf/Ny5/YupblUPTbQAkAYj3GKqDTNThteNsWDaUTae86x5D' +
      'QkHl1cZguoKAoI9AZnEqq1D2si3YJIL/IZ4lMC2ECLfda3MScBjVsZWy4KkKk3YX' +
      'nCqdNSVYDvI8t8haTBKKgo/fgbrsVag37xytbQIDAQABAoIBAQCdnZnOCtrHjAZO' +
      'iLbqfx9xPPBC3deQNdp3IpKqIvBaBAy6FZSSSfySwCKZiCgieXKxvraTXjGqBmyk' +
      'ZbiHmYWrtV3szrLQWsnreYTQCbtQUYzgEquiRd1NZAt907XvZwm+rY3js8xhu5Bi' +
      'jT4oMf1FPc9z/UxHOLmF+f+FMqy2SM2Fxh3jAsxJBaMVEJXpqdQDI86CATgYrqVY' +
      'mlAWQcQ8pL0wwRctZ+XgjQH52V3sk4cIzqIBTO+MN6emmxDl9JdrGZKRei9YEIhG' +
      'mFeXH7rsGg+TZtfvu1M9Kfy2fdgNwTUoTTn93v8gcrwCbyvl5JCzKy07Om/aOXFr' +
      'I8bSWXIhAoGBANu07hegU99zIhvTWmh2Fuml0Lr+cHcZTObh+oeZg1xaDUrlnFOY' +
      '3fyA5x5Jxib3V7OOAeIz/AsmcYq/649nR8NfeiizY5or84Fy1mazRR8diGDV3nUG' +
      'ZATv6yaOY/z31FOLaxT95tDvqWK+Qr5cykq4e6XDDp9P8odCIjJmUdt7AoGBAM48' +
      'vCjtGQ99BVwkcFIj0IacRj3YKzsp06W6V2Z+czlKctJAMAQN8hu9IcXMEIUsi9GD' +
      'MkyzzxjvGRdmIuS58IFqRbr/fIAQLVpY9SPAL771ZCFHmIrKrCYiLYAcg/BSoR29' +
      'me6aFaEcLBFvzHPFNymdyMsaOHSRMZYUlq6VUbI3AoGBAINJeMURf00VRZqPD4VA' +
      'm6x+813qUVY5/iQxgT2qVD7JaQwKbQHfZTdP58vHlesO/o9DGokLO1+GV27sBF0r' +
      'AE0VLrBHkgs8nEQMVWYFVhaj1SzYYBhZ+0af/0qI5+LwTSanNxPSLS1JKVTiEIwk' +
      'cpV37Bs/letJIMoGkNzBG8UlAoGBAKrSfZt8f3RnvmfKusoeZhsJF9kj0vMHOwob' +
      'ZUc8152Nf7uMdPj2wCGfr3iRBOH5urnH7ILBsHjbmjHaZG6FYKMg7i7sbSf5vkcG' +
      'Rc3d4u5NfSlfjwbuxlYzmvJxLAuDtXXX1MdgEyhGGG485uDBamZrDaTEzBwpIyRH' +
      'W2OxxGBTAoGAZHJQKTajcqQQoRSgPPWWU3X8zdlu5hCgNU54bXaPAfJ6IBWvicMZ' +
      'QLw+9mtshtz+Xy0aBbkxUeUlwwzexb9rg1KZppTq/yRqkOlEkI3ZdqiclTK13BCh' +
      '6r6dC2qqq+DVm9Nlm/S9Gab9YSIA0g5MFg5WLwu1KNwuOODE4Le/91c=' +
      '-----END RSA PRIVATE KEY-----';


    {$ENDIF}
    Assert(S.State = ssInit);
    Assert(not S.Active);
    // start server
    S.Start;
    Assert(S.Active);
    I := 0;
    repeat
      Inc(I);
      Sleep(1);
    until (S.State <> ssStarting) or (I >= 5000);
    Assert(S.State = ssReady);
    Assert(S.ClientCount = 0);
    for K := 0 to TestClientCount - 1 do
      begin
        // init client
        C[K].AddressFamily := cafIP4;
        C[K].Host := '127.0.0.1';
        C[K].Port := '12345';
        {$IFDEF TCPCLIENTSERVER_SELFTEST_TLS}
        C[K].TLSEnabled := Mode = tmTLS;
        {$ENDIF}
        Assert(C[K].State = csInit);
        Assert(not C[K].Active);
        // start client
        C[K].WaitForStartup := True;
        C[K].Start;
        Assert(Assigned(C[K].Connection));
        Assert(C[K].Active);
      end;
    for K := 0 to TestClientCount - 1 do
      // wait for client to connect
      WaitClientConnected(C[K]);
    // wait for server connections
    I := 0;
    repeat
      Inc(I);
      Sleep(1);
    until (S.ClientCount >= TestClientCount) or (I >= 5000);
    Assert(S.ClientCount = TestClientCount);
    // wait for server clients
    for K := 0 to TestClientCount - 1 do
      begin
        T[K] := S.GetClientReferenceByIndex(K);
        Assert(Assigned(T[K]));
        Assert(T[K].State in [scsStarting, scsNegotiating, scsReady]);
        Assert(T[K].Connection.State in [cnsProxyNegotiation, cnsConnected]);
        {$IFDEF TCPCLIENTSERVER_SELFTEST_TLS}
        I := 0;
        repeat
          Inc(I);
          Sleep(1);
        until (T[K].Connection.State = cnsConnected) or (I >= 5000);
        Assert(T[K].Connection.State = cnsConnected);
        Assert(not C[K].TLSEnabled or T[K].TLSClient.IsReadyState);
        {$ENDIF}
      end;
    // read & write (small block): client to server
    for K := 0 to TestClientCount - 1 do
      C[K].Connection.WriteStrA('Fundamentals');
    for K := 0 to TestClientCount - 1 do
      begin
        DebugObj.Log('{RWS:' + IntToStr(K + 1) + ':A}');
        I := 0;
        repeat
          Inc(I);
          Sleep(1);
        until (T[K].Connection.ReadBufferSize >= 12) or (I >= 5000);
        DebugObj.Log('{RWS:' + IntToStr(K + 1) + ':B}');
        Assert(T[K].Connection.ReadBufferSize = 12);
        F := T[K].Connection.PeekStr(3);
        Assert(F = 'Fun');
        F := T[K].Connection.ReadStr(12);
        Assert(F = 'Fundamentals');
        DebugObj.Log('{RWS:' + IntToStr(K + 1) + ':Z}');
      end;
    // read & write (small block): server to client
    for K := 0 to TestClientCount - 1 do
      T[K].Connection.WriteStrA('123');
    for K := 0 to TestClientCount - 1 do
      begin
        C[K].WaitReceive(3, 5000);
        F := C[K].Connection.ReadStr(3);
        Assert(F = '123');
      end;
    if TestLargeBlock then
      begin
        // read & write (large block): client to server
        SetLength(F, LargeBlockSize);
        FillChar(F[1], LargeBlockSize, #1);
        for K := 0 to TestClientCount - 1 do
          C[K].Connection.WriteStrA(F);
        for K := 0 to TestClientCount - 1 do
          begin
            J := LargeBlockSize;
            repeat
              I := 0;
              repeat
                Inc(I);
                Sleep(1);
                Assert(C[K].State = csReady);
                Assert(T[K].State = scsReady);
              until (T[K].Connection.ReadBufferSize > 0) or (I >= 5000);
              Assert(T[K].Connection.ReadBufferSize > 0);
              F := T[K].Connection.ReadStr(T[K].Connection.ReadBufferSize);
              Assert(Length(F) > 0);
              for I := 1 to Length(F) do
                Assert(F[I] = #1);
              Dec(J, Length(F));
            until J <= 0;
            Assert(J = 0);
            Sleep(2);
            Assert(T[K].Connection.ReadBufferSize = 0);
          end;
        // read & write (large block): server to client
        SetLength(F, LargeBlockSize);
        FillChar(F[1], LargeBlockSize, #1);
        for K := 0 to TestClientCount - 1 do
          T[K].Connection.WriteStrA(F);
        for K := 0 to TestClientCount - 1 do
          begin
            J := LargeBlockSize;
            repeat
              C[K].WaitReceive(1, 5000);
              Assert(C[K].State = csReady);
              Assert(T[K].State = scsReady);
              Assert(C[K].Connection.ReadBufferSize > 0);
              F := C[K].Connection.ReadStr(C[K].Connection.ReadBufferSize);
              Assert(Length(F) > 0);
              for I := 1 to Length(F) do
                Assert(F[I] = #1);
              Dec(J, Length(F));
            until J <= 0;
            Assert(J = 0);
            Sleep(2);
            Assert(C[K].Connection.ReadBufferSize = 0);
          end;
      end;
    // release reference
    for K := 0 to TestClientCount - 1 do
      T[K].ReleaseReference;
    // stop clients
    for K := TestClientCount - 1 downto 0 do
      begin
        C[K].Stop;
        Assert(C[K].State = csStopped);
      end;
    I := 0;
    repeat
      Inc(I);
      Sleep(1);
    until (S.ClientCount = 0) or (I >= 5000);
    Assert(S.ClientCount = 0);
    // stop server
    S.Stop;
    Assert(not S.Active);
  finally
    for K := TestClientCount - 1 downto 0 do
      C[K].Free;
    S.Free;
    DebugObj.Free;
  end;
end;

procedure SelfTestClientServer_StopStart;
const
  TestClientCount = 3;
  TestRepeatCount = 3;
var C : array of TF4TCPClient;
    S : TF4TCPServer;
    I, K : Integer;
    J : Integer;
    DebugObj : TTCPDebugObj;
begin
  DebugObj := TTCPDebugObj.Create;
  S := TF4TCPServer.Create(nil);
  SetLength(C, TestClientCount);
  for K := 0 to TestClientCount - 1 do
    begin
      C[K] := TF4TCPClient.Create(nil);
      // init client
      C[K].Tag := K + 1;
      C[K].OnLog := DebugObj.ClientLog;
    end;
  try
    // init server
    S.OnLog := DebugObj.ServerLog;
    S.AddressFamily := iaIP4;
    S.BindAddress := '127.0.0.1';
    S.ServerPort := 12345;
    S.MaxClients := -1;
    Assert(S.State = ssInit);
    Assert(not S.Active);
    // start server
    S.Start;
    Assert(S.Active);
    I := 0;
    repeat
      Inc(I);
      Sleep(1);
    until (S.State <> ssStarting) or (I >= 5000);
    Assert(S.State = ssReady);
    Assert(S.ClientCount = 0);
    // init clients
    for K := 0 to TestClientCount - 1 do
      begin
        C[K].AddressFamily := cafIP4;
        C[K].Host := '127.0.0.1';
        C[K].Port := '12345';
        C[K].WaitForStartup := True;
        Assert(C[K].State = csInit);
        Assert(not C[K].Active);
      end;
    // test quickly starting and stopping clients
    for J := 0 to TestRepeatCount - 1 do
      begin
        // start client
        for K := 0 to TestClientCount - 1 do
          begin
            C[K].Start;
            // connection must exist when Start exits
            Assert(Assigned(C[K].Connection));
            Assert(C[K].Active);
          end;
        // delay
        if J > 0 then
          Sleep(J - 1);
        // stop clients
        for K := TestClientCount - 1 downto 0 do
          begin
            C[K].Stop;
            Assert(C[K].State = csStopped);
            Assert(not Assigned(C[K].Connection));
          end;
      end;
    // stop server
    S.Stop;
    Assert(not S.Active);
  finally
    for K := TestClientCount - 1 downto 0 do
      C[K].Free;
    S.Free;
    DebugObj.Free;
  end;
end;

procedure SelfTest_ClientServer;
begin
  Writeln('{STCS1}');
  SelfTestClientServer(tmSimple, 1,  True);
  Writeln('{STCS2}');
  SelfTestClientServer(tmSimple, 2,  True);
  Writeln('{STCS5}');
  SelfTestClientServer(tmSimple, 5,  True);
  {$IFNDEF LINUX} // FAILS
  Writeln('{STCS30}');
  SelfTestClientServer(tmSimple, 30, False);
  {$ENDIF}
  Writeln('{STCS.SS}');
  SelfTestClientServer_StopStart;
  {$IFDEF TCPCLIENTSERVER_SELFTEST_TLS}
  // SelfTestClientServer(tmTLS, 1, True, [ctoDontUseTLS10, ctoDontUseTLS11, ctoDontUseTLS12]); // SSL 3.0
  Writeln('{STCS.TLS}');
  SelfTestClientServer(tmTLS, 1, True, [ctoDontUseSSL3,  ctoDontUseTLS10, ctoDontUseTLS11]); // TLS 1.2
  //SelfTestClientServer(tmTLS, 1, True, [ctoDontUseSSL3,  ctoDontUseTLS10, ctoDontUseTLS12]); // TLS 1.1
  //SelfTestClientServer(tmTLS, 1, True, [ctoDontUseSSL3,  ctoDontUseTLS11, ctoDontUseTLS12]); // TLS 1.0
  {$ENDIF}
  Writeln('{STCSFin}');
end;
{$ENDIF}

procedure SelfTest;
begin
  Writeln('{ST1}');
  SelfTest_Buffer;
  {$IFDEF TCPSERVER_SELFTEST}
  Writeln('{ST2}');
  SelfTest_Server;
  {$ENDIF}
  {$IFDEF TCPCLIENT_SELFTEST}
  Writeln('{ST3}');
  SelfTest_Client;
  {$ENDIF}
  {$IFDEF TCPCLIENTSERVER_SELFTEST}
  Writeln('{ST4}');
  SelfTest_ClientServer;
  {$ENDIF}
  Writeln('{STFin}');
end;
{$ENDIF}



end.

