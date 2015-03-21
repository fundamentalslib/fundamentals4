{******************************************************************************}
{                                                                              }
{   Library:          Fundamentals 4.00                                        }
{   File name:        cHTTPClient.pas                                          }
{   File version:     4.09                                                     }
{   Description:      HTTP client.                                             }
{                                                                              }
{   Copyright:        Copyright (c) 2009-2013, David J Butler                  }
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
{                                                                              }
{  2009/09/03  0.01  Initial development.                                      }
{  2011/06/12  0.02  Further development.                                      }
{  2011/06/14  0.03  HTTPS support.                                            }
{  2011/06/17  0.04  Cookies.                                                  }
{  2011/06/18  0.05  Multiple requests on same connection.                     }
{  2011/06/19  0.06  Response content mechanisms.                              }
{  2011/07/31  0.07  Connection close support.                                 }
{  2011/10/06  4.08  SynchronisedEvents option.                                }
{  2013/03/23  4.09  CustomHeader property.                                    }
{  2013/03/24  4.10  SetRequestContentWwwFormUrlEncodedField method.           }
{                                                                              }
{******************************************************************************}

{$INCLUDE cHTTP.inc}

unit cHTTPClient;

interface

uses
  { System }
  Windows,
  SysUtils,
  Classes,
  SyncObjs,
  { Fundamentals }
  cUtils,
  cStrings,
  { Fundamentals TCP }
  cTCPConnection,
  cTCPClient,
  { Fundamentals HTTP }
  cHTTPUtils;



{                                                                              }
{ THTTPClient                                                                  }
{                                                                              }
type
  THTTPClientLogType = (
    cltDebug,
    cltInfo,
    cltError);

  THTTPClientAddressFamily = (
    cafIP4,
    cafIP6);

  THTTPClientMethod = (
    cmGET,
    cmPOST,
    cmCustom);

  THTTPKeepAliveOption = (
    kaDefault,
    kaKeepAlive,
    kaClose);

  {$IFDEF HTTP_TLS}
  THTTPSClientOption = (
    csoDontUseSSL3,
    csoDontUseTLS10,
    csoDontUseTLS11,
    csoDontUseTLS12);

  THTTPSClientOptions = set of THTTPSClientOption;
  {$ENDIF}

  THTTP4ClientState = (
    hcsInit,
    hcsStarting,
    hcsStopping,
    hcsStopped,
    hcsConnectFailed,
    hcsConnected_Ready,
    hcsSendingRequest,
    hcsSendingContent,
    hcsAwaitingResponse,
    hcsReceivedResponse,
    hcsReceivingContent,
    hcsResponseComplete,
    hcsResponseCompleteAndClosing,
    hcsResponseCompleteAndClosed,
    hcsRequestInterruptedAndClosed,
    hcsRequestFailed);

  TF4HTTPClient = class;

  TSyncProc = procedure of object;

  THTTPClientEvent = procedure (Client: TF4HTTPClient) of object;
  THTTPClientLogEvent = procedure (Client: TF4HTTPClient; LogType: THTTPClientLogType; Msg: String; Level: Integer) of object;
  THTTPClientStateEvent = procedure (Client: TF4HTTPClient; State: THTTP4ClientState) of object;
  THTTPClientContentEvent = procedure (Client: TF4HTTPClient; const Buf; const Size: Integer) of object;

  TF4HTTPClient = class(TComponent)
  protected
    FSynchronisedEvents : Boolean;
    
    // event handlers
    FOnLog                     : THTTPClientLogEvent;
    FOnStateChange             : THTTPClientStateEvent;
    FOnStart                   : THTTPClientEvent;
    FOnStop                    : THTTPClientEvent;
    FOnActive                  : THTTPClientEvent;
    FOnInactive                : THTTPClientEvent;
    FOnResponseHeader          : THTTPClientEvent;
    FOnResponseContentBuffer   : THTTPClientContentEvent;
    FOnResponseContentComplete : THTTPClientEvent;
    FOnResponseComplete        : THTTPClientEvent;
    FOnThreadWait              : THTTPClientEvent;
    FOnMainThreadWait          : THTTPClientEvent;

    // host
    FAddressFamily : THTTPClientAddressFamily;
    FHost          : AnsiString;
    FPort          : AnsiString;

    // https
    {$IFDEF HTTP_TLS}
    FUseHTTPS      : Boolean;
    FHTTPSOptions  : THTTPSClientOptions;
    {$ENDIF}

    // http proxy
    FUseHTTPProxy  : Boolean;
    FHTTPProxyHost : AnsiString;
    FHTTPProxyPort : AnsiString;

    // http request
    FMethod        : THTTPClientMethod;
    FMethodCustom  : AnsiString;
    FURI           : AnsiString;
    FUserAgent     : AnsiString;
    FKeepAlive     : THTTPKeepAliveOption;
    FReferer       : AnsiString;
    FCookie        : AnsiString;
    FAuthorization : AnsiString;
    FCustomHeaders : THTTPCustomHeaders;

    // request content parameters
    FRequestContentType   : AnsiString;
    FRequestContentWriter : THTTPContentWriter;

    // other parameters
    FUserObject : TObject;
    FUserData   : Pointer;
    FUserTag    : NativeInt;

    // state
    FLock              : TCriticalSection;
    FState             : THTTP4ClientState;
    FErrorMsg          : String;
    FActive            : Boolean;
    FActivateOnLoaded  : Boolean;
    FViaHTTPProxy      : Boolean;
    FTCPClient         : TF4TCPClient;
    FHTTPParser        : THTTPParser;
    FInRequest         : Boolean;
    FInDoStart         : Boolean;
    FInDoStop          : Boolean;
    
    FRequestPending     : Boolean;
    FRequest            : THTTPRequest;
    FRequestHasContent  : Boolean;

    FResponse               : THTTPResponse;
    FResponseCode           : Integer;
    FResponseCookies        : TStrings;
    FResponseContentReader  : THTTPContentReader;
    FResponseRequireClose   : Boolean;
    FResponseContentBufPtr  : Pointer;
    FResponseContentBufSize : Integer;
    FSyncLogType            : THTTPClientLogType;
    FSyncLogMsg             : String;
    FSyncLogLevel           : Integer;

    procedure Init; virtual;
    procedure InitDefaults; virtual;

    procedure Loaded; override;

    procedure Synchronize(const SyncProc: TSyncProc);

    procedure SyncLog;
    procedure Log(const LogType: THTTPClientLogType; const Msg: String; const Level: Integer = 0); overload;
    procedure Log(const LogType: THTTPClientLogType; const Msg: String; const Args: array of const; const Level: Integer = 0); overload;

    procedure Lock;
    procedure Unlock;

    function  GetState: THTTP4ClientState;
    function  GetStateStr: String;
    procedure SetState(const State: THTTP4ClientState);

    procedure CheckNotActive;
    function  IsBusyStarting: Boolean;
    function  IsBusyWithRequest: Boolean;
    procedure CheckNotBusyWithRequest;

    procedure SetSynchronisedEvents(const SynchronisedEvents: Boolean);

    procedure SetAddressFamily(const AddressFamily: THTTPClientAddressFamily);
    procedure SetHost(const Host: AnsiString);
    procedure SetPort(const Port: AnsiString);
    function  GetPortInt: Integer;
    procedure SetPortInt(const PortInt: Integer);

    {$IFDEF HTTP_TLS}
    procedure SetUseHTTPS(const UseHTTPS: Boolean);
    procedure SetHTTPSOptions(const HTTPSOptions: THTTPSClientOptions);
    {$ENDIF}

    procedure SetUseHTTPProxy(const UseHTTPProxy: Boolean);
    procedure SetHTTPProxyHost(const HTTPProxyHost: AnsiString);
    procedure SetHTTPProxyPort(const HTTPProxyPort: AnsiString);

    procedure SetMethod(const Method: THTTPClientMethod);
    procedure SetMethodCustom(const MethodCustom: AnsiString);
    procedure SetURI(const URI: AnsiString);

    procedure SetUserAgent(const UserAgent: AnsiString);
    procedure SetKeepAlive(const KeepAlive: THTTPKeepAliveOption);
    procedure SetReferer(const Referer: AnsiString);
    procedure SetAuthorization(const Authorization: AnsiString);

    function  GetCustomHeaderByName(const FieldName: AnsiString): PHTTPCustomHeader;
    function  AddCustomHeader(const FieldName: AnsiString): PHTTPCustomHeader;
    function  GetCustomHeader(const FieldName: AnsiString): AnsiString;
    procedure SetCustomHeader(const FieldName: AnsiString; const FieldValue: AnsiString);

    procedure SetRequestContentType(const RequestContentType: AnsiString);
    function  GetRequestContentMechanism: THTTPContentWriterMechanism;
    procedure SetRequestContentMechanism(const RequestContentMechanism: THTTPContentWriterMechanism);
    function  GetRequestContentStr: AnsiString;
    procedure SetRequestContentStr(const RequestContentStr: AnsiString);
    function  GetRequestContentStream: TStream;
    procedure SetRequestContentStream(const RequestContentStream: TStream);
    function  GetRequestContentFileName: String;
    procedure SetRequestContentFileName(const RequestContentFileName: String);

    function  GetResponseContentMechanism: THTTPContentReaderMechanism;
    procedure SetResponseContentMechanism(const ResponseContentMechanism: THTTPContentReaderMechanism);
    function  GetResponseContentFileName: String;
    procedure SetResponseContentFileName(const ResponseContentFileName: String);
    function  GetResponseContentStream: TStream;
    procedure SetResponseContentStream(const ResponseContentStream: TStream);

    procedure SyncTriggerStateChanged;
    procedure SyncTriggerStart;
    procedure SyncTriggerStop;
    procedure SyncTriggerActive;
    procedure SyncTriggerInactive;
    procedure SyncTriggerResponseHeader;
    procedure SyncTriggerResponseContentBuffer;
    procedure SyncTriggerResponseContentComplete;
    procedure SyncTriggerResponseComplete;

    procedure TriggerStateChanged;
    procedure TriggerStart;
    procedure TriggerStop;
    procedure TriggerActive;
    procedure TriggerInactive;
    procedure TriggerResponseHeader;
    procedure TriggerResponseContentBuffer(const Buf; const BufSize: Integer);
    procedure TriggerResponseContentComplete;
    procedure TriggerResponseComplete;

    procedure ProcessResponseHeader;
    procedure SetResponseComplete;
    procedure SetResponseCompleteThenClosed;

    procedure InitTCPClientHost;
    procedure InitTCPClient;

    procedure TCPClientLog(Client: TF4TCPClient; LogType: TTCPClientLogType; Msg: String; LogLevel: Integer);
    procedure TCPClientIdle(Client: TF4TCPClient);
    procedure TCPClientStateChanged(Client: TF4TCPClient; State: TTCPClientState);
    procedure TCPClientError(Client: TF4TCPClient; ErrorMsg: String; ErrorCode: Integer);
    procedure TCPClientConnected(Client: TF4TCPClient);
    procedure TCPClientConnectFailed(Client: TF4TCPClient);
    procedure TCPClientReady(Client: TF4TCPClient);
    procedure TCPClientRead(Client: TF4TCPClient);
    procedure TCPClientWrite(Client: TF4TCPClient);
    procedure TCPClientClose(Client: TF4TCPClient);

    procedure ResetRequest;

    procedure SetRequestFailedFromException(const E: Exception);

    function  InitRequestContent: Int64;
    procedure FinaliseRequestContent;

    procedure PrepareHTTPRequest;
    function  GetHTTPRequestStr: AnsiString;

    procedure SendStr(const S: AnsiString);
    procedure SendRequest;

    procedure InitResponseContent;
    procedure HandleResponseContent(const Buf; const Size: Integer);
    procedure FinaliseResponseContent(const Success: Boolean);

    procedure ContentWriterLog(const Sender: THTTPContentWriter; const LogMsg: String);
    function  ContentWriterWriteProc(const Sender: THTTPContentWriter;
              const Buf; const Size: Integer): Integer;

    procedure ContentReaderLog(const Sender: THTTPContentReader; const LogMsg: String; const LogLevel: Integer);
    function  ContentReaderReadProc(const Sender: THTTPContentReader;
              var Buf; const Size: Integer): Integer;
    procedure ContentReaderContentProc(const Sender: THTTPContentReader;
              const Buf; const Size: Integer);
    procedure ContentReaderCompleteProc(const Sender: THTTPContentReader);

    procedure ReadResponseHeader;
    procedure ReadResponseContent;
    procedure ReadResponse;

    procedure DoStartTCPClient;
    procedure DoStart;
    procedure DoStopTCPClient;
    procedure DoStop;
    procedure SetActive(const Active: Boolean);

    function  GetResponseContentStr: AnsiString;

    procedure Wait;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    // When SynchronisedEvents is set, events handlers are called in the main thread
    // through the TThread.Synchronise mechanism. If not set, events handlers may
    // be called from any thread. In this case event handler should handle their
    // own synchronisation if required.
    property  SynchronisedEvents: Boolean read FSynchronisedEvents write SetSynchronisedEvents default False;
    
    property  OnLog: THTTPClientLogEvent read FOnLog write FOnLog;

    property  OnStateChange: THTTPClientStateEvent read FOnStateChange write FOnStateChange;
    property  OnStart: THTTPClientEvent read FOnStart write FOnStart;
    property  OnStop: THTTPClientEvent read FOnStop write FOnStop;
    property  OnActive: THTTPClientEvent read FOnActive write FOnActive;
    property  OnInactive: THTTPClientEvent read FOnInactive write FOnInactive;
    property  OnResponseHeader: THTTPClientEvent read FOnResponseHeader write FOnResponseHeader;
    property  OnResponseContentBuffer: THTTPClientContentEvent read FOnResponseContentBuffer write FOnResponseContentBuffer;
    property  OnResponseContentComplete: THTTPClientEvent read FOnResponseContentComplete write FOnResponseContentComplete;
    property  OnResponseComplete: THTTPClientEvent read FOnResponseComplete write FOnResponseComplete;

    property  AddressFamily: THTTPClientAddressFamily read FAddressFamily write SetAddressFamily default cafIP4;
    property  Host: AnsiString read FHost write SetHost;
    property  Port: AnsiString read FPort write SetPort;
    property  PortInt: Integer read GetPortInt write SetPortInt;

    {$IFDEF HTTP_TLS}
    property  UseHTTPS: Boolean read FUseHTTPS write SetUseHTTPS default False;
    property  HTTPSOptions: THTTPSClientOptions read FHTTPSOptions write SetHTTPSOptions default [];
    {$ENDIF}

    property  UseHTTPProxy: Boolean read FUseHTTPProxy write SetUseHTTPProxy default False;
    property  HTTPProxyHost: AnsiString read FHTTPProxyHost write SetHTTPProxyHost;
    property  HTTPProxyPort: AnsiString read FHTTPProxyPort write SetHTTPProxyPort;

    property  Method: THTTPClientMethod read FMethod write SetMethod default cmGET;
    property  MethodCustom: AnsiString read FMethodCustom write SetMethodCustom;
    property  URI: AnsiString read FURI write SetURI;

    property  UserAgent: AnsiString read FUserAgent write SetUserAgent;
    property  KeepAlive: THTTPKeepAliveOption read FKeepAlive write SetKeepAlive default kaDefault;
    property  Referer: AnsiString read FReferer write SetReferer;
    property  Cookie: AnsiString read FCookie write FCookie;
    property  Authorization: AnsiString read FAuthorization write SetAuthorization;
    procedure SetBasicAuthorization(const Username, Password: AnsiString);
    property  CustomHeader[const FieldName: AnsiString]: AnsiString read GetCustomHeader write SetCustomHeader;

    property  RequestContentType: AnsiString read FRequestContentType write SetRequestContentType;
    property  RequestContentMechanism: THTTPContentWriterMechanism read GetRequestContentMechanism write SetRequestContentMechanism default hctmString;
    property  RequestContentStr: AnsiString read GetRequestContentStr write SetRequestContentStr;
    property  RequestContentStream: TStream read GetRequestContentStream write SetRequestContentStream;
    property  RequestContentFileName: String read GetRequestContentFileName write SetRequestContentFileName;

    procedure SetRequestContentWwwFormUrlEncodedField(const FieldName, FieldValue: AnsiString);

    property  ResponseContentMechanism: THTTPContentReaderMechanism read GetResponseContentMechanism write SetResponseContentMechanism default hcrmEvent;
    property  ResponseContentFileName: String read GetResponseContentFileName write SetResponseContentFileName;
    property  ResponseContentStream: TStream read GetResponseContentStream write SetResponseContentStream;

    property  State: THTTP4ClientState read GetState;
    property  StateStr: String read GetStateStr;
    property  Active: Boolean read FActive write SetActive default False;

    procedure Request;
    function  RequestIsBusy: Boolean;
    function  RequestIsSuccess: Boolean;

    property  ErrorMsg: String read FErrorMsg;

    property  ResponseRecord: THTTPResponse read FResponse;
    property  ResponseCode: Integer read FResponseCode;
    property  ResponseCookies: TStrings read FResponseCookies;
    property  ResponseContentStr: AnsiString read GetResponseContentStr;

    property  UserObject: TObject read FUserObject write FUserObject;
    property  UserData: Pointer read FUserData write FUserData;
    property  UserTag: NativeInt read FUserTag write FUserTag;

    // Blocking helpers
    // These functions will block until a result is available or timeout expires.
    // When blocking occurs in the main thread, OnMainThreadWait is called.
    // When blocking occurs in another thread, OnThreadWait is called.
    // Usually the handler for OnMainThreadWait calls Application.ProcessMessages.
    // Note:
    // These functions should not be called from this object's event handlers.
    function  WaitRequestNotBusy(const Timeout: Integer): Boolean;

    property  OnThreadWait: THTTPClientEvent read FOnThreadWait write FOnThreadWait;
    property  OnMainThreadWait: THTTPClientEvent read FOnMainThreadWait write FOnMainThreadWait;
  end;

  EHTTPClient = class(Exception);



{                                                                              }
{ Component                                                                    }
{                                                                              }
type
  TFnd4HTTPClient = class(TF4HTTPClient)
  published
    property  SynchronisedEvents;

    property  OnLog;

    property  OnStateChange;
    property  OnStart;
    property  OnStop;
    property  OnActive;
    property  OnInactive;
    property  OnResponseHeader;
    property  OnResponseContentBuffer;
    property  OnResponseContentComplete;
    property  OnResponseComplete;

    property  AddressFamily;
    property  Host;
    property  Port;
    property  PortInt;

    {$IFDEF HTTP_TLS}
    property  UseHTTPS;
    property  HTTPSOptions;
    {$ENDIF}

    property  UseHTTPProxy;
    property  HTTPProxyHost;
    property  HTTPProxyPort;

    property  Method;
    property  MethodCustom;
    property  URI;

    property  UserAgent;
    property  KeepAlive;
    property  Referer;
    property  Cookie;
    property  Authorization;

    property  RequestContentType;
    property  RequestContentMechanism;
    property  RequestContentStr;
    property  RequestContentFileName;

    property  ResponseContentMechanism;
    property  ResponseContentFileName;

    property  Active;
  end;

{$IFDEF HTTPCLIENT_CUSTOM}
  {$INCLUDE cHTTPClientIntf.inc}
{$ENDIF}



implementation

uses
  {$IFDEF HTTPCLIENT_CUSTOM}
    {$INCLUDE cHTTPClientUses.inc}
  {$ENDIF}
  { Fundamentals }
  cDateTime,
  cSocketLib
  {$IFDEF HTTP_TLS},
  cTLSClient
  {$ENDIF};



{                                                                              }
{ HTTP Client constants                                                        }
{                                                                              }
const
  HTTPCLIENT_PORT     = 80;
  HTTPCLIENT_PORT_STR = '80';

  HTTPCLIENT_METHOD_GET  = 'GET';
  HTTPCLIENT_METHOD_POST = 'POST';

  HTTPCLIENT_ResponseHeader_MaxSize  = 16384;
  HTTPCLIENT_ResponseHeader_Delim    = #13#10#13#10;
  HTTPCLIENT_ResponseHeader_DelimLen = Length(HTTPCLIENT_ResponseHeader_Delim);

  HTTPCLIENT_UserAgent = 'Mozilla/5.0 (compatible; Fundamentals/4.0)';

  HTTP4ClientState_All = [
    hcsInit,
    hcsStarting,
    hcsStopping,
    hcsStopped,
    hcsConnectFailed,
    hcsConnected_Ready,
    hcsSendingRequest,
    hcsSendingContent,
    hcsAwaitingResponse,
    hcsReceivedResponse,
    hcsReceivingContent,
    hcsResponseComplete,
    hcsResponseCompleteAndClosing,
    hcsResponseCompleteAndClosed,
    hcsRequestInterruptedAndClosed,
    hcsRequestFailed
  ];

  HTTP4ClientState_BusyWithRequest = [
    hcsSendingRequest,
    hcsSendingContent,
    hcsAwaitingResponse,
    hcsReceivedResponse,
    hcsReceivingContent
  ];

  HTTP4ClientState_Closed = [
    hcsInit,
    hcsStopped,
    hcsConnectFailed,
    hcsResponseCompleteAndClosed,
    hcsRequestInterruptedAndClosed
  ];

  HTTPClientState_ResponseComplete = [
    hcsResponseComplete,
    hcsResponseCompleteAndClosing,
    hcsResponseCompleteAndClosed
  ];



{                                                                              }
{ Errors and debug strings                                                     }
{                                                                              }
const
  SError_NotAllowedWhileActive          = 'Operation not allowed while active';
  SError_NotAllowedWhileBusyWithRequest = 'Operation not allowed while busy with request';

  SError_MethodNotSet     = 'Method not set';
  SError_URINotSet        = 'URI not set';
  SError_HostNotSet       = 'Host not set';
  SError_InvalidParameter = 'Invalid parameter';

  SClientState : array[THTTP4ClientState] of String = (
      'Initialise',
      'Starting',
      'Stopping',
      'Stopped',
      'ConnectFailed',
      'Connected',
      'SendingRequest',
      'SendingContent',
      'AwaitingResponse',
      'ReceivedResponse',
      'ReceivingContent',
      'ResponseComplete',
      'ResponseCompleteAndClosing',
      'ResponseCompleteAndClosed',
      'RequestInterruptedAndClosed',
      'RequestFailed'
      );



{                                                                              }
{ THTTPClient                                                                  }
{                                                                              }
constructor TF4HTTPClient.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Init;
end;

procedure TF4HTTPClient.Init;
begin
  FLock := TCriticalSection.Create;
  FResponseCookies := TStringList.Create;
  FHTTPParser := THTTPParser.Create;
  FRequestContentWriter := THTTPContentWriter.Create(
      ContentWriterWriteProc);
  FRequestContentWriter.OnLog := ContentWriterLog;
  FResponseContentReader := THTTPContentReader.Create(
      ContentReaderReadProc,
      ContentReaderContentProc,
      ContentReaderCompleteProc);
  FResponseContentReader.OnLog := ContentReaderLog;
  FState := hcsInit;
  FActivateOnLoaded := False;
  InitHTTPRequest(FRequest);
  InitHTTPResponse(FResponse);
  InitDefaults;
end;

procedure TF4HTTPClient.InitDefaults;
begin
  FSynchronisedEvents := False;
  FMethod := cmGET;
  FPort := HTTPCLIENT_PORT_STR;
  {$IFDEF HTTP_TLS}
  FUseHTTPS := False;
  FHTTPSOptions := [];
  {$ENDIF}
  FUseHTTPProxy := False;
  FUserAgent := HTTPCLIENT_UserAgent;
  FRequestContentWriter.Mechanism := hctmString;
  FResponseContentReader.Mechanism := hcrmEvent;
  FUserObject := nil;
  FUserData := nil;
  FUserTag := 0;
end;

destructor TF4HTTPClient.Destroy;
begin
  FreeAndNil(FTCPClient);
  FreeAndNil(FRequestContentWriter);
  FreeAndNil(FResponseContentReader);
  FreeAndNil(FHTTPParser);
  FreeAndNil(FResponseCookies);
  FreeAndNil(FLock);
  inherited Destroy;
end;

procedure TF4HTTPClient.Loaded;
begin
  inherited Loaded;
  if FActivateOnLoaded then
    DoStart;
end;

procedure TF4HTTPClient.Synchronize(const SyncProc: TSyncProc);
begin
  {$IFDEF DELPHI6_DOWN}
  if GetCurrentThreadID = MainThreadID then
    SyncProc;
  {$ELSE}
  TThread.Synchronize(nil, SyncProc);
  {$ENDIF}
end;

procedure TF4HTTPClient.SyncLog;
begin
  if csDestroying in ComponentState then
    exit;
  if Assigned(FOnLog) then
    FOnLog(self, FSyncLogType, FSyncLogMsg, FSyncLogLevel);
end;

procedure TF4HTTPClient.Log(const LogType: THTTPClientLogType; const Msg: String; const Level: Integer);
begin
  if Assigned(FOnLog) then
    if FSynchronisedEvents and (GetCurrentThreadID <> MainThreadID) then
      begin
        FSyncLogType := LogType;
        FSyncLogMsg := Msg;
        FSyncLogLevel := Level;
        Synchronize(SyncLog);
      end
    else
      FOnLog(self, LogType, Msg, Level);
end;

procedure TF4HTTPClient.Log(const LogType: THTTPClientLogType; const Msg: String; const Args: array of const; const Level: Integer);
begin
  Log(LogType, Format(Msg, Args), Level);
end;

procedure TF4HTTPClient.Lock;
begin
  if Assigned(FLock) then
    FLock.Acquire;
end;

procedure TF4HTTPClient.Unlock;
begin
  if Assigned(FLock) then
    FLock.Release;
end;

function TF4HTTPClient.GetState: THTTP4ClientState;
begin
  Lock;
  try
    Result := FState;
  finally
    Unlock;
  end;
end;

function TF4HTTPClient.GetStateStr: String;
begin
  Result := SClientState[GetState];
end;

procedure TF4HTTPClient.SetState(const State: THTTP4ClientState);
begin
  Lock;
  try
    Assert(State <> FState);
    FState := State;
  finally
    Unlock;
  end;
  TriggerStateChanged;
end;

procedure TF4HTTPClient.CheckNotActive;
begin
  if not (csDesigning in ComponentState) then
    if FActive then
      raise EHTTPClient.Create(SError_NotAllowedWhileActive);
end;

function TF4HTTPClient.IsBusyStarting: Boolean;
begin
  Result := (FState = hcsStarting);
end;

function TF4HTTPClient.IsBusyWithRequest: Boolean;
begin
  Result := False;
  if FActive then
    if FState in HTTP4ClientState_BusyWithRequest then
      Result := True
    else
    if FRequestPending and (FState in [hcsStarting, hcsConnected_Ready]) then
      Result := True;
end;

procedure TF4HTTPClient.CheckNotBusyWithRequest;
begin
  if not (csDesigning in ComponentState) and not (csLoading in ComponentState) then
    begin
      Lock;
      try
        if IsBusyWithRequest then
          raise EHTTPClient.Create(SError_NotAllowedWhileBusyWithRequest);
      finally
        Unlock;
      end;
    end;
end;

procedure TF4HTTPClient.SetSynchronisedEvents(const SynchronisedEvents: Boolean);
begin
  if SynchronisedEvents = FSynchronisedEvents then
    exit;
  CheckNotActive;
  FSynchronisedEvents := SynchronisedEvents;
end;

procedure TF4HTTPClient.SetAddressFamily(const AddressFamily: THTTPClientAddressFamily);
begin
  if AddressFamily = FAddressFamily then
    exit;
  CheckNotBusyWithRequest;
  FAddressFamily := AddressFamily;
end;

procedure TF4HTTPClient.SetHost(const Host: AnsiString);
begin
  if Host = FHost then
    exit;
  CheckNotBusyWithRequest;
  FHost := Host;
end;

procedure TF4HTTPClient.SetPort(const Port: AnsiString);
begin
  if Port = FPort then
    exit;
  CheckNotBusyWithRequest;
  FPort := Port;
end;

function TF4HTTPClient.GetPortInt: Integer;
begin
  Result := StringToIntDefA(FPort, -1);
end;

procedure TF4HTTPClient.SetPortInt(const PortInt: Integer);
begin
  if (PortInt <= 0) or (PortInt >= $FFFF) then
    raise EHTTPClient.Create(SError_InvalidParameter);
  SetPort(IntToStringA(PortInt));
end;

{$IFDEF HTTP_TLS}
procedure TF4HTTPClient.SetUseHTTPS(const UseHTTPS: Boolean);
begin
  if UseHTTPS = FUseHTTPS then
    exit;
  CheckNotBusyWithRequest;
  FUseHTTPS := UseHTTPS;
end;

procedure TF4HTTPClient.SetHTTPSOptions(const HTTPSOptions: THTTPSClientOptions);
begin
  if HTTPSOptions = FHTTPSOptions then
    exit;
  CheckNotBusyWithRequest;
  FHTTPSOptions := HTTPSOptions;
end;
{$ENDIF}

procedure TF4HTTPClient.SetUseHTTPProxy(const UseHTTPProxy: Boolean);
begin
  if UseHTTPProxy = FUseHTTPProxy then
    exit;
  CheckNotBusyWithRequest;
  FUseHTTPProxy := UseHTTPProxy;
end;

procedure TF4HTTPClient.SetHTTPProxyHost(const HTTPProxyHost: AnsiString);
begin
  if HTTPProxyHost = FHTTPProxyHost then
    exit;
  CheckNotBusyWithRequest;
  FHTTPProxyHost := HTTPProxyHost;
end;

procedure TF4HTTPClient.SetHTTPProxyPort(const HTTPProxyPort: AnsiString);
begin
  if HTTPProxyPort = FHTTPProxyPort then
    exit;
  CheckNotBusyWithRequest;
  FHTTPProxyPort := HTTPProxyPort;
end;

procedure TF4HTTPClient.SetMethod(const Method: THTTPClientMethod);
begin
  if Method = FMethod then
    exit;
  CheckNotBusyWithRequest;
  FMethod := Method;
end;

procedure TF4HTTPClient.SetMethodCustom(const MethodCustom: AnsiString);
begin
  if MethodCustom = FMethodCustom then
    exit;
  CheckNotBusyWithRequest;
  FMethodCustom := MethodCustom;
end;

procedure TF4HTTPClient.SetURI(const URI: AnsiString);
begin
  if URI = FURI then
    exit;
  CheckNotBusyWithRequest;
  FURI := URI;
end;

procedure TF4HTTPClient.SetUserAgent(const UserAgent: AnsiString);
begin
  if UserAgent = FUserAgent then
    exit;
  CheckNotBusyWithRequest;
  FUserAgent := UserAgent;
end;

procedure TF4HTTPClient.SetKeepAlive(const KeepAlive: THTTPKeepAliveOption);
begin
  if KeepAlive = FKeepAlive then
    exit;
  CheckNotBusyWithRequest;
  FKeepAlive := KeepAlive;
end;

procedure TF4HTTPClient.SetReferer(const Referer: AnsiString);
begin
  if Referer = FReferer then
    exit;
  CheckNotBusyWithRequest;
  FReferer := Referer;
end;

procedure TF4HTTPClient.SetAuthorization(const Authorization: AnsiString);
begin
  if Authorization = FAuthorization then
    exit;
  CheckNotBusyWithRequest;
  FAuthorization := Authorization;
end;

procedure TF4HTTPClient.SetBasicAuthorization(const Username, Password: AnsiString);
begin
  SetAuthorization('Basic ' + MIMEBase64Encode(Username + ':' + Password));
end;

function TF4HTTPClient.GetCustomHeaderByName(const FieldName: AnsiString): PHTTPCustomHeader;
begin
  Result := HTTPCustomHeadersGetByName(FCustomHeaders, FieldName);
end;

function TF4HTTPClient.AddCustomHeader(const FieldName: AnsiString): PHTTPCustomHeader;
var P : PHTTPCustomHeader;
begin
  Assert(FieldName <> '');
  P := HTTPCustomHeadersAdd(FCustomHeaders);
  P^.FieldName := FieldName;
  Result := P;
end;

function TF4HTTPClient.GetCustomHeader(const FieldName: AnsiString): AnsiString;
var P : PHTTPCustomHeader;
begin
  P := GetCustomHeaderByName(FieldName);
  if Assigned(P) then
    Result := P^.FieldValue
  else
    Result := '';
end;

procedure TF4HTTPClient.SetCustomHeader(const FieldName: AnsiString; const FieldValue: AnsiString);
var P : PHTTPCustomHeader;
begin
  P := GetCustomHeaderByName(FieldName);
  if Assigned(P) then
    if StrEqualNoAsciiCaseA(FieldValue, P^.FieldValue) then
      exit;
  CheckNotBusyWithRequest;
  if not Assigned(P) then
    P := AddCustomHeader(FieldName);
  Assert(Assigned(P));
  P^.FieldValue := FieldValue;
end;

procedure TF4HTTPClient.SetRequestContentType(const RequestContentType: AnsiString);
begin
  if RequestContentType = FRequestContentType then
    exit;
  CheckNotBusyWithRequest;
  FRequestContentType := RequestContentType;
end;

function TF4HTTPClient.GetRequestContentMechanism: THTTPContentWriterMechanism;
begin
  Result := FRequestContentWriter.Mechanism;
end;

procedure TF4HTTPClient.SetRequestContentMechanism(const RequestContentMechanism: THTTPContentWriterMechanism);
begin
  if RequestContentMechanism = FRequestContentWriter.Mechanism then
    exit;
  CheckNotBusyWithRequest;
  FRequestContentWriter.Mechanism := RequestContentMechanism;
end;

function TF4HTTPClient.GetRequestContentStr: AnsiString;
begin
  Result := FRequestContentWriter.ContentString;
end;

procedure TF4HTTPClient.SetRequestContentStr(const RequestContentStr: AnsiString);
begin
  if RequestContentStr = FRequestContentWriter.ContentString then
    exit;
  CheckNotBusyWithRequest;
  FRequestContentWriter.ContentString := RequestContentStr;
end;

function TF4HTTPClient.GetRequestContentStream: TStream;
begin
  Result := FRequestContentWriter.ContentStream;
end;

procedure TF4HTTPClient.SetRequestContentStream(const RequestContentStream: TStream);
begin
  if RequestContentStream = FRequestContentWriter.ContentStream then
    exit;
  CheckNotBusyWithRequest;
  FRequestContentWriter.ContentStream := RequestContentStream;
end;

function TF4HTTPClient.GetRequestContentFileName: String;
begin
  Result := FRequestContentWriter.ContentFileName;
end;

procedure TF4HTTPClient.SetRequestContentFileName(const RequestContentFileName: String);
begin
  if RequestContentFileName = FRequestContentWriter.ContentFileName then
    exit;
  CheckNotBusyWithRequest;
  FRequestContentWriter.ContentFileName := RequestContentFileName;
end;

procedure TF4HTTPClient.SetRequestContentWwwFormUrlEncodedField(const FieldName, FieldValue: AnsiString);
var Req, S : AnsiString;
begin
  Req := GetRequestContentStr;
  if Req <> '' then
    S := '&'
  else
    S := '';
  S := S + FieldName + '=' + FieldValue;
  Req := Req + S;
  SetRequestContentType('application/x-www-form-urlencoded');
  SetRequestContentStr(Req);
end;

function TF4HTTPClient.GetResponseContentMechanism: THTTPContentReaderMechanism;
begin
  Result := FResponseContentReader.Mechanism;
end;

procedure TF4HTTPClient.SetResponseContentMechanism(const ResponseContentMechanism: THTTPContentReaderMechanism);
begin
  if ResponseContentMechanism = FResponseContentReader.Mechanism then
    exit;
  CheckNotBusyWithRequest;
  FResponseContentReader.Mechanism := ResponseContentMechanism;
end;

function TF4HTTPClient.GetResponseContentFileName: String;
begin
  Result := FResponseContentReader.ContentFileName;
end;

procedure TF4HTTPClient.SetResponseContentFileName(const ResponseContentFileName: String);
begin
  if ResponseContentFileName = FResponseContentReader.ContentFileName then
    exit;
  CheckNotBusyWithRequest;
  FResponseContentReader.ContentFileName := ResponseContentFileName;
end;

function TF4HTTPClient.GetResponseContentStream: TStream;
begin
  Result := FResponseContentReader.ContentStream;
end;

procedure TF4HTTPClient.SetResponseContentStream(const ResponseContentStream: TStream);
begin
  if ResponseContentStream = FResponseContentReader.ContentStream then
    exit;
  CheckNotBusyWithRequest;
  FResponseContentReader.ContentStream := ResponseContentStream;
end;

procedure TF4HTTPClient.SyncTriggerStateChanged;
begin
  if csDestroying in ComponentState then
    exit;
  if Assigned(FOnStateChange) then
    FOnStateChange(self, FState);
end;

procedure TF4HTTPClient.SyncTriggerStart;
begin
  if csDestroying in ComponentState then
    exit;
  if Assigned(FOnStart) then
    FOnStart(self);
end;

procedure TF4HTTPClient.SyncTriggerStop;
begin
  if csDestroying in ComponentState then
    exit;
  if Assigned(FOnStop) then
    FOnStop(self);
end;

procedure TF4HTTPClient.SyncTriggerActive;
begin
  if csDestroying in ComponentState then
    exit;
  if Assigned(FOnActive) then
    FOnActive(self);
end;

procedure TF4HTTPClient.SyncTriggerInactive;
begin
  if csDestroying in ComponentState then
    exit;
  if Assigned(FOnInactive) then
    FOnInactive(self);
end;

procedure TF4HTTPClient.SyncTriggerResponseHeader;
begin
  if csDestroying in ComponentState then
    exit;
  if Assigned(FOnResponseHeader) then
    FOnResponseHeader(self);
end;

procedure TF4HTTPClient.SyncTriggerResponseContentBuffer;
begin
  if csDestroying in ComponentState then
    exit;
  if Assigned(FOnResponseContentBuffer) then
    FOnResponseContentBuffer(self, FResponseContentBufPtr^, FResponseContentBufSize);
end;

procedure TF4HTTPClient.SyncTriggerResponseContentComplete;
begin
  if csDestroying in ComponentState then
    exit;
  if Assigned(FOnResponseContentComplete) then
    FOnResponseContentComplete(self);
end;

procedure TF4HTTPClient.SyncTriggerResponseComplete;
begin
  if csDestroying in ComponentState then
    exit;
  if Assigned(FOnResponseComplete) then
    FOnResponseComplete(self);
end;

procedure TF4HTTPClient.TriggerStateChanged;
begin
  {$IFDEF HTTP_DEBUG}
  Log(cltDebug, 'State:%s', [GetStateStr]);
  {$ENDIF}
  if Assigned(FOnStateChange) then
    if FSynchronisedEvents then
      Synchronize(SyncTriggerStateChanged)
    else
      FOnStateChange(self, FState);
end;

procedure TF4HTTPClient.TriggerStart;
begin
  {$IFDEF HTTP_DEBUG}
  Log(cltDebug, 'Start');
  {$ENDIF}
  if Assigned(FOnStart) then
    if FSynchronisedEvents then
      Synchronize(SyncTriggerStart)
    else
      FOnStart(self);
end;

procedure TF4HTTPClient.TriggerStop;
begin
  {$IFDEF HTTP_DEBUG}
  Log(cltDebug, 'Stop');
  {$ENDIF}
  if Assigned(FOnStop) then
    if FSynchronisedEvents then
      Synchronize(SyncTriggerStop)
    else
      FOnStop(self);
end;

procedure TF4HTTPClient.TriggerActive;
begin
  {$IFDEF HTTP_DEBUG}
  Log(cltDebug, 'Active');
  {$ENDIF}
  if Assigned(FOnActive) then
    if FSynchronisedEvents then
      Synchronize(SyncTriggerActive)
    else
      FOnActive(self);
end;

procedure TF4HTTPClient.TriggerInactive;
begin
  {$IFDEF HTTP_DEBUG}
  Log(cltDebug, 'Inactive');
  {$ENDIF}
  if Assigned(FOnInactive) then
    if FSynchronisedEvents then
      Synchronize(SyncTriggerInactive)
    else
      FOnInactive(self);
end;

procedure TF4HTTPClient.TriggerResponseHeader;
begin
  {$IFDEF HTTP_DEBUG}
  Log(cltDebug, 'ResponseHeader:'#13#10'%s', [HTTPResponseToStr(FResponse)]);
  {$ENDIF}
  if Assigned(FOnResponseHeader) then
    if FSynchronisedEvents then
      Synchronize(SyncTriggerResponseHeader)
    else
      FOnResponseHeader(self);
end;

procedure TF4HTTPClient.TriggerResponseContentBuffer(const Buf; const BufSize: Integer);
begin
  {$IFDEF HTTP_DEBUG}
  Log(cltDebug, 'ContentBuffer:%db', [BufSize]);
  {$ENDIF}
  if Assigned(FOnResponseContentBuffer) then
    if FSynchronisedEvents then
      begin
        FResponseContentBufPtr := @Buf;
        FResponseContentBufSize := BufSize;
        Synchronize(SyncTriggerResponseContentBuffer);
      end
    else
      FOnResponseContentBuffer(self, Buf, BufSize);
end;

procedure TF4HTTPClient.TriggerResponseContentComplete;
begin
  {$IFDEF HTTP_DEBUG}
  Log(cltDebug, 'ContentComplete');
  {$ENDIF}
  if Assigned(FOnResponseContentComplete) then
    if FSynchronisedEvents then
      Synchronize(SyncTriggerResponseContentComplete)
    else
      FOnResponseContentComplete(self);
end;

procedure TF4HTTPClient.TriggerResponseComplete;
begin
  {$IFDEF HTTP_DEBUG}
  Log(cltDebug, 'ResponseComplete');
  {$ENDIF}
  if Assigned(FOnResponseComplete) then
    if FSynchronisedEvents then
      Synchronize(SyncTriggerResponseComplete)
    else
      FOnResponseComplete(self);
end;

procedure TF4HTTPClient.ProcessResponseHeader;
var L, I : Integer;
    B : TRawByteStringBuilder;
begin
  FResponseCode := FResponse.StartLine.Code;
  B := TRawByteStringBuilder.Create;
  try
    L := Length(FResponse.Header.SetCookies);
    FResponseCookies.Clear;
    for I := 0 to L - 1 do
      begin
        B.Clear;
        BuildStrHTTPSetCookieFieldValue(FResponse.Header.SetCookies[I], B, []);
        {$IFDEF StringIsUnicode}
        FResponseCookies.Add(B.AsString);
        {$ELSE}
        FResponseCookies.Add(B.AsAnsiString);
        {$ENDIF}
      end;
    FResponseRequireClose :=
      ( (FResponse.StartLine.Version.Version = hvHTTP10) and
        (FResponse.Header.CommonHeaders.Connection.Value = hcfNone)
      )
      or
      ( FResponse.Header.CommonHeaders.Connection.Value = hcfClose );
  finally
    B.Free;
  end;
end;

procedure TF4HTTPClient.SetResponseComplete;
begin
  if FState in [
      hcsResponseCompleteAndClosing,
      hcsResponseCompleteAndClosed,
      hcsResponseComplete,
      hcsRequestInterruptedAndClosed,
      hcsRequestFailed] then
    exit;

  SetState(hcsResponseComplete);
  TriggerResponseComplete;

  if FResponseRequireClose then
    begin
      SetState(hcsResponseCompleteAndClosing);
      FTCPClient.Connection.Shutdown;
    end;
end;

procedure TF4HTTPClient.SetResponseCompleteThenClosed;
begin
  Assert(FState in [hcsReceivedResponse, hcsReceivingContent]);

  SetState(hcsResponseComplete);
  TriggerResponseComplete;
  SetState(hcsResponseCompleteAndClosed);
end;

procedure TF4HTTPClient.InitTCPClientHost;
begin
  Assert(Assigned(FTCPClient));

  case FAddressFamily of
    cafIP4 : FTCPClient.AddressFamily := cTCPClient.cafIP4;
    cafIP6 : FTCPClient.AddressFamily := cTCPClient.cafIP6;
  else
    raise EHTTPClient.Create('Invalid HTTP client address family');
  end;
  if FHost = '' then
    raise EHTTPClient.Create(SError_HostNotSet);
  FTCPClient.Host := FHost;
  FTCPClient.Port := FPort;
  FTCPClient.LocalHost := '0.0.0.0';
end;

procedure TF4HTTPClient.InitTCPClient;
{$IFDEF HTTP_TLS}
var TLSOpt : TTCPClientTLSOptions;
{$ENDIF}
begin
  FTCPClient := TF4TCPClient.Create(nil);
  try
    FTCPClient.OnLog := TCPClientLog;
    FTCPClient.OnStateChanged := TCPClientStateChanged;
    FTCPClient.OnError := TCPClientError;
    FTCPClient.OnIdle := TCPClientIdle;
    FTCPClient.OnConnected := TCPClientConnected;
    FTCPClient.OnConnectFailed := TCPClientConnectFailed;
    FTCPClient.OnReady := TCPClientReady;
    FTCPClient.OnRead := TCPClientRead;
    FTCPClient.OnWrite := TCPClientWrite;
    FTCPClient.OnClose := TCPClientClose;
    FTCPClient.SocksEnabled := False;
    FTCPClient.SynchronisedEvents := False;
    {$IFDEF HTTP_TLS}
    FTCPClient.TLSEnabled := FUseHTTPS;
    TLSOpt := [];
    if csoDontUseSSL3 in FHTTPSOptions then
      Include(TLSOpt, ctoDontUseSSL3);
    if csoDontUseTLS10 in FHTTPSOptions then
      Include(TLSOpt, ctoDontUseTLS10);
    if csoDontUseTLS11 in FHTTPSOptions then
      Include(TLSOpt, ctoDontUseTLS11);
    if csoDontUseTLS12 in FHTTPSOptions then
      Include(TLSOpt, ctoDontUseTLS12);
    FTCPClient.TLSOptions := TLSOpt;
    {$ENDIF}
    InitTCPClientHost;
  except
    FreeAndNil(FTCPClient);
    raise;
  end;
end;

procedure TF4HTTPClient.TCPClientLog(Client: TF4TCPClient; LogType: TTCPClientLogType; Msg: String; LogLevel: Integer);
begin
  {$IFDEF HTTP_DEBUG}
  Log(cltDebug, 'TCP:%s', [Msg], LogLevel + 1);
  {$ENDIF}
end;

procedure TF4HTTPClient.TCPClientIdle(Client: TF4TCPClient);
begin
end;

procedure TF4HTTPClient.TCPClientStateChanged(Client: TF4TCPClient; State: TTCPClientState);
begin
  {$IFDEF HTTP_DEBUG}
  Log(cltDebug, 'TCP_StateChange:%s', [Client.StateStr]);
  {$ENDIF}
end;

procedure TF4HTTPClient.TCPClientError(Client: TF4TCPClient; ErrorMsg: String; ErrorCode: Integer);
begin
  {$IFDEF HTTP_DEBUG}
  Log(cltDebug, 'TCP_Error:%d:%s', [ErrorCode, ErrorMsg]);
  {$ENDIF}
end;

procedure TF4HTTPClient.TCPClientConnected(Client: TF4TCPClient);
begin
  {$IFDEF HTTP_DEBUG}
  Log(cltDebug, 'TCP_Connected');
  {$ENDIF}
end;

procedure TF4HTTPClient.TCPClientConnectFailed(Client: TF4TCPClient);
begin
  {$IFDEF HTTP_DEBUG}
  Log(cltDebug, 'TCP_ConnectFailed');
  {$ENDIF}
  SetState(hcsConnectFailed);
end;

procedure TF4HTTPClient.TCPClientReady(Client: TF4TCPClient);
var ReqPending : Boolean;
begin
  {$IFDEF HTTP_DEBUG}
  Log(cltDebug, 'TCP_Ready');
  {$ENDIF}
  SetState(hcsConnected_Ready);
  Lock;
  try
    ReqPending := FRequestPending;
  finally
    Unlock;
  end;
  if ReqPending then
    try
      try
        SendRequest;
      finally
        Lock;
        try
          FRequestPending := False;
        finally
          Unlock;
        end;
      end;
    except
      on E : Exception do
        SetRequestFailedFromException(E);
    end;
end;

procedure TF4HTTPClient.TCPClientRead(Client: TF4TCPClient);
begin
  {$IFDEF HTTP_DEBUG}
  Log(cltDebug, 'TCP_Read');
  {$ENDIF}
  ReadResponse;
end;

procedure TF4HTTPClient.TCPClientWrite(Client: TF4TCPClient);
begin
  {$IFDEF HTTP_DEBUG}
  Log(cltDebug, 'TCP_Write');
  {$ENDIF}
end;

procedure TF4HTTPClient.TCPClientClose(Client: TF4TCPClient);
begin
  {$IFDEF HTTP_DEBUG}
  Log(cltDebug, 'TCP_Close');
  {$ENDIF}
  case FState of
    hcsInit,
    hcsStopping,
    hcsConnectFailed,
    hcsResponseCompleteAndClosed,
    hcsRequestInterruptedAndClosed :
      exit;

    hcsResponseComplete,
    hcsResponseCompleteAndClosing :
      SetState(hcsResponseCompleteAndClosed);

    hcsStarting,
    hcsSendingRequest,
    hcsSendingContent,
    hcsAwaitingResponse :
      SetState(hcsRequestInterruptedAndClosed);

    hcsReceivedResponse :
      if not FResponse.HasContent and FResponseRequireClose then
        SetResponseCompleteThenClosed
      else
        SetState(hcsRequestInterruptedAndClosed);

    hcsReceivingContent :
      if FResponseRequireClose and FResponseContentReader.ContentComplete then
        SetResponseCompleteThenClosed
      else
        SetState(hcsRequestInterruptedAndClosed);
  end;
end;

procedure TF4HTTPClient.SetRequestFailedFromException(const E: Exception);
begin
  FErrorMsg := E.Message;
  SetState(hcsRequestFailed);
end;

function TF4HTTPClient.InitRequestContent: Int64;
var L : Int64;
begin
  FRequestContentWriter.InitContent(L);
  Result := L;
end;

procedure TF4HTTPClient.FinaliseRequestContent;
begin
  FRequestContentWriter.FinaliseContent;
end;

procedure TF4HTTPClient.InitResponseContent;
begin
  FResponseContentReader.InitReader(FResponse.Header.CommonHeaders);
end;

procedure TF4HTTPClient.HandleResponseContent(const Buf; const Size: Integer);
begin
end;

procedure TF4HTTPClient.FinaliseResponseContent(const Success: Boolean);
begin
end;

procedure TF4HTTPClient.ContentWriterLog(const Sender: THTTPContentWriter; const LogMsg: String);
begin
  {$IFDEF HTTP_DEBUG}
  Log(cltDebug, 'ContentWriter:%s', [LogMsg], 1);
  {$ENDIF}
end;

function TF4HTTPClient.ContentWriterWriteProc(const Sender: THTTPContentWriter;
         const Buf; const Size: Integer): Integer;
begin
  Result := FTCPClient.Connection.Write(Buf, Size);
end;

procedure TF4HTTPClient.ContentReaderLog(const Sender: THTTPContentReader; const LogMsg: String; const LogLevel: Integer);
begin
  {$IFDEF HTTP_DEBUG}
  Log(cltDebug, 'ContentReader:%s', [LogMsg], LogLevel + 1);
  {$ENDIF}
end;

function TF4HTTPClient.ContentReaderReadProc(const Sender: THTTPContentReader; var Buf; const Size: Integer): Integer;
begin
  Assert(Assigned(FTCPClient));
  Assert(FState in [hcsReceivingContent]);
  //
  Result := FTCPClient.Connection.Read(Buf, Size);
  {$IFDEF HTTP_DEBUG}
  Log(cltDebug, 'ContentReader_Read:%db:%db', [Size, Result]);
  {$ENDIF}
end;

procedure TF4HTTPClient.ContentReaderContentProc(const Sender: THTTPContentReader;
    const Buf; const Size: Integer);
begin
  {$IFDEF HTTP_DEBUG}
  Log(cltDebug, 'ContentReader_Content:%db', [Size]);
  {$ENDIF}
  TriggerResponseContentBuffer(Buf, Size);
  HandleResponseContent(Buf, Size);
end;

procedure TF4HTTPClient.ContentReaderCompleteProc(const Sender: THTTPContentReader);
begin
  {$IFDEF HTTP_DEBUG}
  Log(cltDebug, 'ContentReader_Complete');
  {$ENDIF}
  FinaliseResponseContent(True);
  TriggerResponseContentComplete;
  SetResponseComplete;
end;

procedure TF4HTTPClient.ReadResponseHeader;
const
  HdrBufSize = HTTPCLIENT_ResponseHeader_MaxSize + HTTPCLIENT_ResponseHeader_DelimLen;
var
  HdrBuf : array[0..HdrBufSize - 1] of Byte;
  HdrLen : Integer;
begin
  Assert(Assigned(FTCPClient));
  Assert(FState in [hcsAwaitingResponse]);
  //
  HdrLen := FTCPClient.Connection.PeekDelimited(
      HdrBuf[0], HdrBufSize,
      HTTPCLIENT_ResponseHeader_Delim,
      HTTPCLIENT_ResponseHeader_MaxSize);
  if HdrLen < 0 then
    exit;
  ClearHTTPResponse(FResponse);
  FHTTPParser.SetTextBuf(HdrBuf[0], HdrLen);
  FHTTPParser.ParseResponse(FResponse);
  if not FResponse.HeaderComplete then
    exit;
  FTCPClient.Connection.Discard(HdrLen);
  SetState(hcsReceivedResponse);
  ProcessResponseHeader;
  TriggerResponseHeader
end;

procedure TF4HTTPClient.ReadResponseContent;
begin
  FResponseContentReader.Process;
end;

procedure TF4HTTPClient.ReadResponse;
begin
  Assert(FTCPClient.State in [csReady, csClosed]);
  Assert(FState <> hcsResponseComplete);
  Assert(FState in [hcsAwaitingResponse, hcsReceivedResponse, hcsReceivingContent, hcsResponseCompleteAndClosing, hcsResponseCompleteAndClosed, hcsRequestInterruptedAndClosed]);
  //
  try
    if FState = hcsAwaitingResponse then
      ReadResponseHeader;
    if FState = hcsReceivedResponse then
      if FResponse.HasContent then
        begin
          InitResponseContent;
          SetState(hcsReceivingContent);
        end
      else
        SetResponseComplete;
    if FState = hcsReceivingContent then
      ReadResponseContent;
  except
    on E : Exception do
      SetRequestFailedFromException(E);
  end;
end;

procedure TF4HTTPClient.DoStartTCPClient;
begin
  InitTCPClient;
  FViaHTTPProxy := FUseHTTPProxy and (FHTTPProxyHost <> '');
  Assert(Assigned(FTCPClient));
  FTCPClient.Start;
end;

procedure TF4HTTPClient.DoStart;
begin
  Lock;
  try
    if FInDoStart then
      exit;
    FInDoStart := True;
  finally
    Unlock;
  end;
  try
    TriggerStart;
    SetState(hcsStarting);
    DoStartTCPClient;
    FActive := True;
    TriggerActive;
  finally
    Lock;
    try
      FInDoStart := False;
    finally
      Unlock;
    end;
  end;
end;

procedure TF4HTTPClient.DoStopTCPClient;
begin
  Assert(Assigned(FTCPClient));
  FTCPClient.Stop;
end;

procedure TF4HTTPClient.DoStop;
begin
  Lock;
  try
    if FInDoStart then
      exit;
    FInDoStop := True;
  finally
    Unlock;
  end;
  try
    TriggerStop;
    SetState(hcsStopping);
    DoStopTCPClient;
    SetState(hcsStopped);
    FActive := False;
    TriggerInactive;
  finally
    Lock;
    try
      FInDoStop := False;
    finally
      Unlock;
    end;
  end;
end;

procedure TF4HTTPClient.SetActive(const Active: Boolean);
begin
  if Active = FActive then
    exit;
  if csDesigning in ComponentState then
    FActive := Active else
  if csLoading in ComponentState then
    FActivateOnLoaded := Active
  else
    if Active then
      DoStart
    else
      DoStop;
end;

procedure TF4HTTPClient.PrepareHTTPRequest;
var C : THTTPConnectionFieldEnum;
    L : Int64;
begin
  ClearHTTPRequest(FRequest);

  case FMethod of
    cmGET    : FRequest.StartLine.Method.Value := hmGET;
    cmPOST   : FRequest.StartLine.Method.Value := hmPOST;
    cmCustom :
      begin
        if FMethodCustom = '' then
          raise EHTTPClient.Create(SError_MethodNotSet);
        FRequest.StartLine.Method.Value := hmCustom;
        FRequest.StartLine.Method.Custom := FMethodCustom;
      end;
  else
    raise EHTTPClient.Create(SError_MethodNotSet);
  end;

  if FURI = '' then
    raise EHTTPClient.Create(SError_URINotSet);
  FRequest.StartLine.URI := FURI;

  FRequest.StartLine.Version.Version := hvHTTP11;
  FRequest.Header.CommonHeaders.Date.Value := hdDateTime;
  FRequest.Header.CommonHeaders.Date.DateTime := Now;

  case FKeepAlive of
    kaKeepAlive : C := hcfKeepAlive;
    kaClose     : C := hcfClose;
  else
    C := hcfNone;
  end;
  if C <> hcfNone then
    if FViaHTTPProxy then
      FRequest.Header.CommonHeaders.ProxyConnection.Value := C
    else
      FRequest.Header.CommonHeaders.Connection.Value := C;

  FRequest.Header.FixedHeaders[hntHost] := FHost;
  FRequest.Header.FixedHeaders[hntUserAgent] := FUserAgent;
  FRequest.Header.FixedHeaders[hntReferer] := FReferer;
  FRequest.Header.FixedHeaders[hntAuthorization] := FAuthorization;

  if FCookie <> '' then
    begin
      FRequest.Header.Cookie.Value := hcoCustom;
      FRequest.Header.Cookie.Custom := FCookie;
    end;

  FRequest.Header.CustomHeaders := FCustomHeaders;

  if FRequestContentType <> '' then
    begin
      FRequest.Header.CommonHeaders.ContentType.Value := hctCustomString;
      FRequest.Header.CommonHeaders.ContentType.CustomStr := FRequestContentType;
      L := InitRequestContent;
      Assert(L >= 0);
      FRequest.Header.CommonHeaders.ContentLength.Value := hcltByteCount;
      FRequest.Header.CommonHeaders.ContentLength.ByteCount := L;
      FRequestHasContent := True;
    end
  else
    FRequestHasContent := False;
end;

function TF4HTTPClient.GetHTTPRequestStr: AnsiString;
begin
  Result := HTTPRequestToStr(FRequest);
  {$IFDEF HTTP_DEBUG}
  Log(cltDebug, 'RequestHeader:%db'#13#10'%s', [Length(Result), Result]);
  {$ENDIF}
end;

procedure TF4HTTPClient.SendStr(const S: AnsiString);
begin
  Assert(Assigned(FTCPClient));
  Assert(FState in [hcsSendingRequest, hcsSendingContent]);
  //
  FTCPClient.Connection.WriteStrA(S);
end;

procedure TF4HTTPClient.SendRequest;
begin
  Assert(FState in [hcsConnected_Ready, hcsResponseComplete, hcsResponseCompleteAndClosing]);
  //
  SetState(hcsSendingRequest);
  SendStr(GetHTTPRequestStr);
  if FRequestHasContent then
    begin
      SetState(hcsSendingContent);
      FRequestContentWriter.SendContent;
      FinaliseRequestContent;
    end;
  SetState(hcsAwaitingResponse);
end;

procedure TF4HTTPClient.ResetRequest;
begin
  FErrorMsg := '';
  ClearHTTPResponse(FResponse);
  FResponseCode := 0;
  FResponseCookies.Clear;
  FResponseContentReader.Reset;
  FRequestContentWriter.Reset;
end;

procedure TF4HTTPClient.Request;
var R_IsStarting : Boolean;
    R_Ready : Boolean;
    R_Connect : Boolean;
    R_IsActive : Boolean;
begin
  {$IFDEF DELPHI2007_UP}
  // prevent bogus compiler warnings in Delphi 2007+
  R_Ready := False;
  R_Connect := False;
  R_IsActive := False;
  {$ENDIF}
  Lock;
  try
    // check state
    if FInRequest or IsBusyWithRequest then
      raise EHTTPClient.Create(SError_NotAllowedWhileBusyWithRequest);
    FInRequest := True;
    R_IsActive := FActive;
    R_IsStarting := IsBusyStarting;
    R_Ready := FState in [hcsConnected_Ready, hcsResponseComplete];
    R_Connect := not R_IsStarting and not R_Ready;
    // initialise new request
    ResetRequest;
    PrepareHTTPRequest;
    FRequestPending := not R_Ready;
  finally
    Unlock;
  end;
  try
    if R_Connect then
      begin
        if R_IsActive then
          begin
            DoStopTCPClient;
            DoStartTCPClient;
          end
        else
          DoStart;
      end
    else
    if R_Ready then
      SendRequest;
  finally
    Lock;
    try
      FInRequest := False;
    finally
      Unlock;
    end;
  end;
end;

function TF4HTTPClient.RequestIsBusy: Boolean;
begin
  Lock;
  try
    Result := IsBusyWithRequest;
  finally
    Unlock;
  end;
end;

function TF4HTTPClient.RequestIsSuccess: Boolean;
begin
  Result := GetState in HTTPClientState_ResponseComplete;
end;

function TF4HTTPClient.GetResponseContentStr: AnsiString;
begin
  Result := FResponseContentReader.ContentString;
end;

procedure TF4HTTPClient.Wait;
begin
  if GetCurrentThreadID = MainThreadID then
    begin
      if Assigned(OnMainThreadWait) then
        FOnMainThreadWait(self);
    end
  else
    begin
      if Assigned(FOnThreadWait) then
        FOnThreadWait(self);
    end;
  Sleep(1);
end;

function TF4HTTPClient.WaitRequestNotBusy(const Timeout: Integer): Boolean;
var T : LongWord;
    R : Boolean;
begin
  T := TCPGetTick;
  repeat
    R := not RequestIsBusy;
    if R then
      break;
    if TCPTickDelta(T, TCPGetTick) >= TimeOut then
      break;
    Wait;
  until false;
  Result := R;
end;



{$IFDEF HTTPCLIENT_CUSTOM}
  {$INCLUDE cHTTPClientImpl.inc}
{$ENDIF}



end.

