{******************************************************************************}
{                                                                              }
{   Library:          Fundamentals 4.00                                        }
{   File name:        cTCPClient.pas                                           }
{   File version:     4.12                                                     }
{   Description:      TCP client.                                              }
{                                                                              }
{   Copyright:        Copyright (c) 2007-2012, David J Butler                  }
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
{   2008/08/15  0.01  Initial development.                                     }
{   2010/11/07  0.02  Revision.                                                }
{   2010/11/12  0.03  Refactor for asynchronous operation.                     }
{   2010/12/02  0.04  TLS support.                                             }
{   2010/12/20  0.05  Various enhancements.                                    }
{   2011/04/22  0.06  Thread safe Start/Stop.                                  }
{   2011/06/18  0.07  IsConnected, IsConnectionClosed, etc.                    }
{   2011/06/25  0.08  Improved logging.                                        }
{   2011/09/03  4.09  Revise for Fundamentals 4.                               }
{   2011/09/10  4.10  Synchronised events option.                              }
{   2011/10/06  4.11  Remove wait condition on startup.                        }
{   2011/11/07  4.12  Allow client to be restarted after being stopped.        }
{                     Added WaitForStartup property to optionally enable       }
{                     waiting for thread initialisation.                       }
{                                                                              }
{******************************************************************************}

{$INCLUDE cTCP.inc}

unit cTCPClient;

interface

uses
  { System }
  {$IFDEF OS_MSWIN}
  Messages,
  Windows,
  {$ENDIF}
  SysUtils,
  SyncObjs,
  Classes,
  { Fundamentals }
  cUtils,
  { Sockets }
  cSocketLib,
  cSocket,
  { TCP }
  cTCPConnection
  { Socks }
  {$IFDEF TCPCLIENT_SOCKS},
  cSocksClient
  {$ENDIF}
  { TLS }
  {$IFDEF TCPCLIENT_TLS},
  cTLSConnection,
  cTLSClient
  {$ENDIF}
  ;



{                                                                              }
{ TCP Client                                                                   }
{                                                                              }
type
  ETCPClient = class(Exception);

  TTCPClientState = (
    csInit,        // Client initialise
    csStarting,    // Client starting (thread starting up)
    csStarted,     // Client activated (thread running)
    csResolving,   // IP resolving
    csResolved,    // IP resolved
    csConnecting,  // TCP connecting
    csConnected,   // TCP connected
    csNegotiating, // Connection proxy negotiation
    csReady,       // Client ready, connection negotiated and ready
    csClosed,      // Connection closed
    csStopped      // Client stopped
    );
  TTCPClientStates = set of TTCPClientState;

  TTCPClientLogType = (
    cltDebug,
    cltInfo,
    cltError);

  TTCPClientAddressFamily = (
    cafIP4,
    cafIP6);

  {$IFDEF TCPCLIENT_TLS}
  TTCPClientTLSOption = (
    ctoDontUseSSL3,
    ctoDontUseTLS10,
    ctoDontUseTLS11,
    ctoDontUseTLS12);

  TTCPClientTLSOptions = set of TTCPClientTLSOption;
  {$ENDIF}

  TF4TCPClient = class;

  TTCPClientNotifyEvent = procedure (Client: TF4TCPClient) of object;
  TTCPClientLogEvent = procedure (Client: TF4TCPClient; LogType: TTCPClientLogType; Msg: String; LogLevel: Integer) of object;
  TTCPClientStateEvent = procedure (Client: TF4TCPClient; State: TTCPClientState) of object;
  TTCPClientErrorEvent = procedure (Client: TF4TCPClient; ErrorMsg: String; ErrorCode: Integer) of object;

  TSyncProc = procedure of object;

  TTCPClientThread = class(TThread)
  protected
    FTCPClient : TF4TCPClient;
    procedure Execute; override;
  public
    constructor Create(const TCPClient: TF4TCPClient);
    property Terminated;
  end;

  TF4TCPClient = class(TComponent)
  protected
    // parameters
    FAddressFamily      : TTCPClientAddressFamily;
    FHost               : AnsiString;
    FPort               : AnsiString;
    FLocalHost          : AnsiString;
    FLocalPort          : AnsiString;

    {$IFDEF TCPCLIENT_SOCKS}
    FSocksEnabled       : Boolean;
    FSocksHost          : AnsiString;
    FSocksPort          : AnsiString;
    FSocksAuth          : Boolean;
    FSocksUsername      : AnsiString;
    FSocksPassword      : AnsiString;
    {$ENDIF}

    {$IFDEF TCPCLIENT_TLS}
    FTLSEnabled         : Boolean;
    FTLSOptions         : TTCPClientTLSOptions;
    {$ENDIF}

    FSynchronisedEvents : Boolean;
    FWaitForStartup     : Boolean;

    FUserTag            : NativeInt;
    FUserObject         : TObject;

    // event handlers
    FOnLog             : TTCPClientLogEvent;
    FOnStateChanged    : TTCPClientStateEvent;
    FOnError           : TTCPClientErrorEvent;
    FOnStart           : TTCPClientNotifyEvent;
    FOnStop            : TTCPClientNotifyEvent;
    FOnActive          : TTCPClientNotifyEvent;
    FOnInactive        : TTCPClientNotifyEvent;
    FOnIdle            : TTCPClientNotifyEvent;
    FOnStarted         : TTCPClientNotifyEvent;
    FOnConnected       : TTCPClientNotifyEvent;
    FOnConnectFailed   : TTCPClientNotifyEvent;
    FOnNegotiating     : TTCPClientNotifyEvent;
    FOnReady           : TTCPClientNotifyEvent;
    FOnRead            : TTCPClientNotifyEvent;
    FOnWrite           : TTCPClientNotifyEvent;
    FOnClose           : TTCPClientNotifyEvent;
    FOnStopped         : TTCPClientNotifyEvent;
    FOnMainThreadWait  : TTCPClientNotifyEvent;
    FOnThreadWait      : TTCPClientNotifyEvent;

    // state
    FLock              : TCriticalSection;
    FState             : TTCPClientState;
    FIsStopping        : Boolean;
    FProcessThread     : TTCPClientThread;
    FErrorMsg          : String;
    FErrorCode         : Integer;
    FActive            : Boolean;
    FActivateOnLoaded  : Boolean;
    FIPAddressFamily   : TIPAddressFamily;
    FSocket            : TSysSocket;
    FLocalAddr         : TSocketAddr;
    FConnectAddr       : TSocketAddr;
    FConnection        : TTCPConnection;
    FSyncListLog       : TList;
    FSyncLogType       : TTCPClientLogType;
    FSyncLogMsg        : AnsiString;
    FSyncLogLevel      : Integer;

    {$IFDEF TCPCLIENT_TLS}
    FTLSProxy          : TTCPConnectionProxy;
    FTLSClient         : TTLSClient;
    {$ENDIF}

    {$IFDEF TCPCLIENT_SOCKS}
    FSocksResolvedAddr : TSocketAddr;
    {$ENDIF}

  protected
    procedure Init; virtual;
    procedure InitDefaults; virtual;

    procedure Synchronize(const SyncProc: TSyncProc);

    procedure SyncLog;
    procedure Log(const LogType: TTCPClientLogType; const Msg: String; const LogLevel: Integer = 0); overload;
    procedure Log(const LogType: TTCPClientLogType; const Msg: String; const Args: array of const; const LogLevel: Integer = 0); overload;

    procedure Lock;
    procedure Unlock;

    function  GetState: TTCPClientState;
    function  GetStateStr: RawByteString;
    procedure SetState(const State: TTCPClientState);

    procedure CheckNotActive;
    procedure CheckActive;

    procedure SetAddressFamily(const AddressFamily: TTCPClientAddressFamily);
    procedure SetHost(const Host: AnsiString);
    procedure SetPort(const Port: AnsiString);
    function  GetPortInt: Integer;
    procedure SetPortInt(const PortInt: Integer);
    procedure SetLocalHost(const LocalHost: AnsiString);
    procedure SetLocalPort(const LocalPort: AnsiString);

    {$IFDEF TCPCLIENT_SOCKS}
    procedure SetSocksProxy(const SocksProxy: Boolean);
    procedure SetSocksHost(const SocksHost: AnsiString);
    procedure SetSocksPort(const SocksPort: AnsiString);
    procedure SetSocksAuth(const SocksAuth: Boolean);
    procedure SetSocksUsername(const SocksUsername: AnsiString);
    procedure SetSocksPassword(const SocksPassword: AnsiString);
    {$ENDIF}

    {$IFDEF TCPCLIENT_TLS}
    procedure SetTLSEnabled(const TLSEnabled: Boolean);
    procedure SetTLSOptions(const TLSOptions: TTCPClientTLSOptions);
    {$ENDIF}

    procedure SetSynchronisedEvents(const SynchronisedEvents: Boolean);
    procedure SetWaitForStartup(const WaitForStartup: Boolean);

    procedure SetActive(const Active: Boolean);
    procedure Loaded; override;

    procedure SyncTriggerError;
    procedure SyncTriggerStateChanged;
    procedure SyncTriggerStart;
    procedure SyncTriggerStop;
    procedure SyncTriggerActive;
    procedure SyncTriggerInactive;
    procedure SyncTriggerStarted;
    procedure SyncTriggerConnected;
    procedure SyncTriggerNegotiating;
    procedure SyncTriggerConnectFailed;
    procedure SyncTriggerReady;
    procedure SyncTriggerRead;
    procedure SyncTriggerWrite;
    procedure SyncTriggerClose;
    procedure SyncTriggerStopped;

    procedure TriggerError; virtual;
    procedure TriggerStateChanged; virtual;
    procedure TriggerStart; virtual;
    procedure TriggerStop; virtual;
    procedure TriggerActive; virtual;
    procedure TriggerInactive; virtual;
    procedure TriggerIdle; virtual;
    procedure TriggerStarted; virtual;
    procedure TriggerConnected; virtual;
    procedure TriggerNegotiating; virtual;
    procedure TriggerConnectFailed; virtual;
    procedure TriggerReady; virtual;
    procedure TriggerRead; virtual;
    procedure TriggerWrite; virtual;
    procedure TriggerClose; virtual;
    procedure TriggerStopped; virtual;

    procedure SetError(const ErrorMsg: String; const ErrorCode: Integer);
    procedure SetStarted;
    procedure SetConnected;
    procedure SetNegotiating;
    procedure SetReady;
    procedure SetClosed;
    procedure SetStopped;

    procedure SocketLog(Sender: TSysSocket; LogType: TSysSocketLogType; Msg: String);

    procedure ConnectionLog(Sender: TTCPConnection; LogType: TTCPLogType; LogMsg: String; LogLevel: Integer);
    procedure ConnectionStateChange(Sender: TTCPConnection; State: TTCPConnectionState);
    procedure ConnectionRead(Sender: TTCPConnection);
    procedure ConnectionWrite(Sender: TTCPConnection);
    procedure ConnectionClose(Sender: TTCPConnection);

    {$IFDEF TCPCLIENT_TLS}
    procedure InstallTLSProxy;
    function  GetTLSClient: TTLSClient;
    {$ENDIF}

    {$IFDEF TCPCLIENT_SOCKS}
    procedure InstallSocksProxy;
    {$ENDIF}

    function  GetConnection: TTCPConnection;
    procedure CreateConnection;
    procedure FreeConnection;

    procedure DoResolve;
    procedure DoConnect;
    procedure DoClose;

    procedure StartThread;
    procedure StopThread;
    {$IFDEF OS_MSWIN}
    function  ProcessMessage(var MsgTerminated: Boolean): Boolean;
    {$ENDIF}
    procedure ThreadExecute(const Thread: TTCPClientThread);

    procedure DoStart;
    procedure DoStop;

    procedure Wait; virtual;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    property  AddressFamily: TTCPClientAddressFamily read FAddressFamily write SetAddressFamily default cafIP4;
    property  Host: AnsiString read FHost write SetHost;
    property  Port: AnsiString read FPort write SetPort;
    property  PortInt: Integer read GetPortInt write SetPortInt;
    property  LocalHost: AnsiString read FLocalHost write SetLocalHost;
    property  LocalPort: AnsiString read FLocalPort write SetLocalPort;

    {$IFDEF TCPCLIENT_SOCKS}
    property  SocksEnabled: Boolean read FSocksEnabled write SetSocksProxy default False;
    property  SocksHost: AnsiString read FSocksHost write SetSocksHost;
    property  SocksPort: AnsiString read FSocksPort write SetSocksPort;
    property  SocksAuth: Boolean read FSocksAuth write SetSocksAuth default False;
    property  SocksUsername: AnsiString read FSocksUsername write SetSocksUsername;
    property  SocksPassword: AnsiString read FSocksPassword write SetSocksPassword;
    {$ENDIF}

    {$IFDEF TCPCLIENT_TLS}
    property  TLSEnabled: Boolean read FTLSEnabled write SetTLSEnabled default False;
    property  TLSOptions: TTCPClientTLSOptions read FTLSOptions write SetTLSOptions default [ctoDontUseSSL3];
    {$ENDIF}

    // When SynchronisedEvents is set, events handlers are called in the main thread
    // through the TThread.Synchronise mechanism. If not set, events handlers may
    // be called from any thread. In this case event handler should handle their
    // own synchronisation if required.
    property  SynchronisedEvents: Boolean read FSynchronisedEvents write SetSynchronisedEvents default False;

    property  OnLog: TTCPClientLogEvent read FOnLog write FOnLog;
    property  OnStateChanged: TTCPClientStateEvent read FOnStateChanged write FOnStateChanged;
    property  OnError: TTCPClientErrorEvent read FOnError write FOnError;
    property  OnStart: TTCPClientNotifyEvent read FOnStart write FOnStart;
    property  OnStop: TTCPClientNotifyEvent read FOnStop write FOnStop;
    property  OnActive: TTCPClientNotifyEvent read FOnActive write FOnActive;
    property  OnInactive: TTCPClientNotifyEvent read FOnInactive write FOnInactive;
    property  OnIdle: TTCPClientNotifyEvent read FOnIdle write FOnIdle;
    property  OnStarted: TTCPClientNotifyEvent read FOnStarted write FOnStarted;
    property  OnConnected: TTCPClientNotifyEvent read FOnConnected write FOnConnected;
    property  OnConnectFailed: TTCPClientNotifyEvent read FOnConnectFailed write FOnConnectFailed;
    property  OnNegotiating: TTCPClientNotifyEvent read FOnNegotiating write FOnNegotiating;
    property  OnReady: TTCPClientNotifyEvent read FOnReady write FOnReady;
    property  OnRead: TTCPClientNotifyEvent read FOnRead write FOnRead;
    property  OnWrite: TTCPClientNotifyEvent read FOnWrite write FOnWrite;
    property  OnClose: TTCPClientNotifyEvent read FOnClose write FOnClose;
    property  OnStopped: TTCPClientNotifyEvent read FOnStopped write FOnStopped;

    property  State: TTCPClientState read GetState;
    property  StateStr: RawByteString read GetStateStr;

    function  IsConnecting: Boolean;
    function  IsConnectingOrConnected: Boolean;
    function  IsConnected: Boolean;
    function  IsConnectionClosed: Boolean;

    // When WaitForStartup is set, the call to Start or Active := True will only return
    // when the thread has started and the Connection property is available.
    // This option is usally only needed in a non-GUI application.
    // Note:
    // When this is set to True in a GUI application with SynchronisedEvents True,
    // the OnMainThreadWait handler must call Application.ProcessMessages otherwise
    // blocking conditions may occur.
    property  WaitForStartup: Boolean read FWaitForStartup write SetWaitForStartup default False;

    property  Active: Boolean read FActive write SetActive default False;
    procedure Start;
    procedure Stop;

    property  ErrorMessage: String read FErrorMsg;
    property  ErrorCode: Integer read FErrorCode;

    {$IFDEF TCPCLIENT_TLS}
    property  TLSClient: TTLSClient read GetTLSClient;
    procedure StartTLS;
    {$ENDIF}

    // The Connection property is only available when the client is active,
    // when not active it is nil.
    property  Connection: TTCPConnection read GetConnection;

    // Blocking helpers
    // These functions will block until a result is available or timeout expires.
    // When blocking occurs in the main thread, OnMainThreadWait is called.
    // When blocking occurs in another thread, OnThreadWait is called.
    // Usually the handler for OnMainThreadWait calls Application.ProcessMessages.
    // Note:
    // These functions should not be called from this object's event handlers.
    property  OnThreadWait: TTCPClientNotifyEvent read FOnThreadWait write FOnThreadWait;
    property  OnMainThreadWait: TTCPClientNotifyEvent read FOnMainThreadWait write FOnMainThreadWait;

    function  WaitState(const States: TTCPClientStates; const TimeOut: Integer): TTCPClientState;
    function  WaitConnect(const TimeOut: Integer): Boolean;
    function  WaitReceive(const ReadBufferSize: Integer; const TimeOut: Integer): Boolean;
    function  WaitTransmit(const TimeOut: Integer): Boolean;
    function  WaitClose(const TimeOut: Integer): Boolean;

    procedure BlockingClose(const TimeOut: Integer);
    procedure BlockingShutdown(
              const TransmitTimeOut: Integer;
              const CloseTimeOut: Integer);

    // User defined values
    property  UserTag: NativeInt read FUserTag write FUserTag;
    property  UserObject: TObject read FUserObject write FUserObject;
  end;



{                                                                              }
{ Component                                                                    }
{                                                                              }
type
  TFnd4TCPClient = class(TF4TCPClient)
  published
    property  Active;
    property  AddressFamily;
    property  Host;
    property  Port;
    property  LocalHost;
    property  LocalPort;

    {$IFDEF TCPCLIENT_SOCKS}
    property  SocksHost;
    property  SocksPort;
    property  SocksAuth;
    property  SocksUsername;
    property  SocksPassword;
    {$ENDIF}

    {$IFDEF TCPCLIENT_TLS}
    property  TLSEnabled;
    property  TLSOptions;
    {$ENDIF}

    property  SynchronisedEvents;
    property  WaitForStartup;

    property  OnLog;
    property  OnStateChanged;
    property  OnError;
    property  OnStart;
    property  OnStop;
    property  OnActive;
    property  OnInactive;
    property  OnIdle;
    property  OnStarted;
    property  OnConnected;
    property  OnConnectFailed;
    property  OnNegotiating;
    property  OnReady;
    property  OnRead;
    property  OnWrite;
    property  OnClose;
    property  OnStopped;
    property  OnThreadWait;
    property  OnMainThreadWait;

    property  UserTag;
    property  UserObject;
  end;



implementation

{$IFDEF TCPCLIENT_TLS}
uses
  { TLS }
  cTLSUtils;
{$ENDIF}



{                                                                              }
{ Error and debug strings                                                      }
{                                                                              }
const
  SError_NotAllowedWhileActive   = 'Operation not allowed while active';
  SError_NotAllowedWhileInactive = 'Operation not allowed while inactive';
  SError_TLSNotActive            = 'TLS not active';
  SError_ProxyNotReady           = 'Proxy not ready';
  SError_InvalidParameter        = 'Invalid parameter';
  SError_StartupFailed           = 'Startup failed';
  SError_HostNotSpecified        = 'Host not specified';
  SError_PortNotSpecified        = 'Port not specified';
  SError_Terminated              = 'Terminated';
  SError_TimedOut                = 'Timed out';

  SClientState : array[TTCPClientState] of RawByteString = (
      'Initialise',
      'Starting',
      'Started',
      'Resolving',
      'Resolved',
      'Connecting',
      'Connected',
      'Negotiating',
      'Ready',
      'Closed',
      'Stopped');



{                                                                              }
{ TCP Client State                                                             }
{                                                                              }
const
  TCPClientStates_All = [
      csInit,
      csStarting,
      csStarted,
      csResolving,
      csResolved,
      csConnecting,
      csConnected,
      csNegotiating,
      csReady,
      csClosed,
      csStopped
  ];

  TCPClientStates_Connecting = [
      csStarting,
      csStarted,
      csResolving,
      csResolved,
      csConnecting,
      csConnected,
      csNegotiating
  ];

  TCPClientStates_ConnectingOrConnected =
      TCPClientStates_Connecting + [
      csReady
  ];

  TCPClientStates_Connected = [
      csReady
  ];

  TCPClientStates_Closed = [
      csInit,
      csClosed,
      csStopped
  ];



{                                                                              }
{ TCP Client Socks Connection Proxy                                            }
{                                                                              }
{$IFDEF TCPCLIENT_SOCKS}
type
  TTCPClientSocksConnectionProxy = class(TTCPConnectionProxy)
  private
    FTCPClient   : TF4TCPClient;
    FSocksClient : TSocksClient;

    procedure SocksClientClientWrite(const Client: TSocksClient; const Buf; const BufSize: Integer);

  public
    class function ProxyName: String; override;
    
    constructor Create(const TCPClient: TF4TCPClient);
    destructor Destroy; override;

    procedure ProxyStart; override;
    procedure ProcessReadData(const Buf; const BufSize: Integer); override;
    procedure ProcessWriteData(const Buf; const BufSize: Integer); override;
  end;

class function TTCPClientSocksConnectionProxy.ProxyName: String;
begin
  Result := 'Socks';
end;

constructor TTCPClientSocksConnectionProxy.Create(const TCPClient: TF4TCPClient);
begin
  Assert(Assigned(TCPClient));
  inherited Create(TCPClient.Connection);
  FTCPClient := TCPClient;
  FSocksClient := TSocksClient.Create;
  FSocksClient.OnClientWrite := SocksClientClientWrite;
end;

destructor TTCPClientSocksConnectionProxy.Destroy;
begin
  FreeAndNil(FSocksClient);
  inherited Destroy;
end;

procedure TTCPClientSocksConnectionProxy.ProxyStart;
begin
  SetState(prsNegotiating);
  // initialise socks client parameters
  FSocksClient.SocksVersion := scvSocks5;
  case FTCPClient.FSocksResolvedAddr.AddrFamily of
    iaIP4 :
      begin
        FSocksClient.AddrType := scaIP4;
        FSocksClient.AddrIP4  := FTCPClient.FSocksResolvedAddr.AddrIP4;
      end;
    iaIP6 :
      begin
        FSocksClient.AddrType := scaIP6;
        FSocksClient.AddrIP6  := FTCPClient.FSocksResolvedAddr.AddrIP6;
      end;
  else
    raise ETCPClient.Create(SError_InvalidParameter);
  end;
  FSocksClient.AddrPort := FTCPClient.FSocksResolvedAddr.Port;
  if FTCPClient.SocksAuth then
    begin
      FSocksClient.AuthMethod := scamSocks5UserPass;
      FSocksClient.UserID     := FTCPClient.FSocksUsername;
      FSocksClient.Password   := FTCPClient.FSocksPassword;
    end
  else
    FSocksClient.AuthMethod := scamNone;
  // connect
  FSocksClient.Connect;
end;

procedure TTCPClientSocksConnectionProxy.SocksClientClientWrite(const Client: TSocksClient; const Buf; const BufSize: Integer);
begin
  ConnectionPutWriteData(Buf, BufSize);
end;

procedure TTCPClientSocksConnectionProxy.ProcessReadData(const Buf; const BufSize: Integer);
begin
  // check if negotiation completed previously
  case FSocksClient.ReqState of
    scrsSuccess : ConnectionPutReadData(Buf, BufSize); // pass data to connection
    scrsFailed  : ;
  else
    // pass data to socks client
    FSocksClient.ClientData(Buf, BufSize);
    // check completion
    case FSocksClient.ReqState of
      scrsSuccess : SetState(prsFinished);
      scrsFailed  : SetState(prsError);
    end;
  end;
end;

procedure TTCPClientSocksConnectionProxy.ProcessWriteData(const Buf; const BufSize: Integer);
begin
  if FSocksClient.ReqState <> scrsSuccess then
    raise ETCPClient.Create(SError_ProxyNotReady);
  ConnectionPutWriteData(Buf, BufSize);
end;
{$ENDIF}



{                                                                              }
{ TCP Client TLS Connection Proxy                                              }
{                                                                              }
{$IFDEF TCPCLIENT_TLS}
type
  TTCPClientTLSConnectionProxy = class(TTCPConnectionProxy)
  private
    FTCPClient : TF4TCPClient;
    FTLSClient : TTLSClient;

    procedure TLSClientTransportLayerSendProc(const Sender: TTLSConnection; const Buffer; const Size: Integer);
    procedure TLSClientLog(Sender: TTLSConnection; LogType: TTLSLogType; LogMsg: String; LogLevel: Integer);
    procedure TLSClientStateChange(Sender: TTLSConnection; State: TTLSConnectionState);

  public
    class function ProxyName: String; override;

    constructor Create(const TCPClient: TF4TCPClient);
    destructor Destroy; override;

    procedure ProxyStart; override;
    procedure ProcessReadData(const Buf; const BufSize: Integer); override;
    procedure ProcessWriteData(const Buf; const BufSize: Integer); override;
  end;

class function TTCPClientTLSConnectionProxy.ProxyName: String;
begin
  Result := 'TLS';
end;

function TCPClientTLSOptionsToTLSOptions(A: TTCPClientTLSOptions): TTLSClientOptions;
var TLSOpts : TTLSClientOptions;
begin
  TLSOpts := [];
  if ctoDontUseSSL3 in A then
    Include(TLSOpts, tlscoDontUseSSL3);
  if ctoDontUseTLS10 in A then
    Include(TLSOpts, tlscoDontUseTLS10);
  if ctoDontUseTLS11 in A then
    Include(TLSOpts, tlscoDontUseTLS11);
  if ctoDontUseTLS12 in A then
    Include(TLSOpts, tlscoDontUseTLS12);
  Result := TLSOpts;
end;

constructor TTCPClientTLSConnectionProxy.Create(const TCPClient: TF4TCPClient);
begin
  Assert(Assigned(TCPClient));

  inherited Create(TCPClient.FConnection);
  FTCPClient := TCPClient;
  FTLSClient := TTLSClient.Create(TLSClientTransportLayerSendProc);
  {$IFDEF TCP_DEBUG}
  FTLSClient.OnLog := TLSClientLog;
  {$ENDIF}
  FTLSClient.OnStateChange := TLSClientStateChange;
  FTLSClient.ClientOptions := TCPClientTLSOptionsToTLSOptions(FTCPClient.FTLSOptions);
end;

destructor TTCPClientTLSConnectionProxy.Destroy;
begin
  FreeAndNil(FTLSClient);
  inherited Destroy;
end;

procedure TTCPClientTLSConnectionProxy.ProxyStart;
begin
  SetState(prsNegotiating);
  FTLSClient.Start;
end;

procedure TTCPClientTLSConnectionProxy.TLSClientTransportLayerSendProc(const Sender: TTLSConnection; const Buffer; const Size: Integer);
begin
  ConnectionPutWriteData(Buffer, Size);
end;

procedure TTCPClientTLSConnectionProxy.TLSClientLog(Sender: TTLSConnection; LogType: TTLSLogType; LogMsg: String; LogLevel: Integer);
begin
  {$IFDEF TCP_DEBUG}
  Log(tlDebug, 'TLS:%s', [LogMsg], LogLevel + 1);
  {$ENDIF}
end;

procedure TTCPClientTLSConnectionProxy.TLSClientStateChange(Sender: TTLSConnection; State: TTLSConnectionState);
begin
  case State of
    tlscoApplicationData : SetState(prsFiltering);
    tlscoCancelled,
    tlscoErrorBadProtocol :
      begin
        ConnectionClose;
        SetState(prsError);
      end;
    tlscoClosed :
      begin
        ConnectionClose;
        SetState(prsClosed);
      end;
  end;
end;

procedure TTCPClientTLSConnectionProxy.ProcessReadData(const Buf; const BufSize: Integer);
const
  ReadBufSize = TLS_PLAINTEXT_FRAGMENT_MAXSIZE * 2;
var
  ReadBuf : array[0..ReadBufSize - 1] of Byte;
  L : Integer;
begin
  {$IFDEF TCP_DEBUG}
  Log(tlDebug, 'ProcessReadData:%db', [BufSize]);
  {$ENDIF}
  FTLSClient.ProcessTransportLayerReceivedData(Buf, BufSize);
  repeat
    L := FTLSClient.AvailableToRead;
    if L > ReadBufSize then
      L := ReadBufSize;
    if L > 0 then
      begin
        L := FTLSClient.Read(ReadBuf, L);
        if L > 0 then
          ConnectionPutReadData(ReadBuf, L);
      end;
  until L <= 0;
end;

procedure TTCPClientTLSConnectionProxy.ProcessWriteData(const Buf; const BufSize: Integer);
begin
  {$IFDEF TCP_DEBUG}
  Log(tlDebug, 'ProcessWriteData:%db', [BufSize]);
  {$ENDIF}
  FTLSClient.Write(Buf, BufSize);
end;
{$ENDIF}



{                                                                              }
{ TTCPClientProcessThread                                                      }
{                                                                              }
constructor TTCPClientThread.Create(const TCPClient: TF4TCPClient);
begin
  Assert(Assigned(TCPClient));
  FTCPClient := TCPClient;
  FreeOnTerminate := False;
  inherited Create(False);
end;

procedure TTCPClientThread.Execute;
begin
  Assert(Assigned(FTCPClient));
  FTCPClient.ThreadExecute(self);
end;



{                                                                              }
{ TTCPClient                                                                   }
{                                                                              }
constructor TF4TCPClient.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Init;
end;

procedure TF4TCPClient.Init;
begin
  FState := csInit;
  FActivateOnLoaded := False;
  FLock := TCriticalSection.Create;
  InitDefaults;
end;

procedure TF4TCPClient.InitDefaults;
begin
  FActive := False;
  FAddressFamily := cafIP4;
  {$IFDEF TCPCLIENT_SOCKS}
  FSocksEnabled := False;
  FSocksAuth := False;
  {$ENDIF}
  {$IFDEF TCPCLIENT_TLS}
  FTLSEnabled := False;
  FTLSOptions := [ctoDontUseSSL3];
  {$ENDIF}
  FSynchronisedEvents := False;
  FWaitForStartup := False;
end;

destructor TF4TCPClient.Destroy;
var I : Integer;
begin
  FreeAndNil(FProcessThread);
  if Assigned(FSyncListLog) then
    begin
      for I := FSyncListLog.Count - 1 downto 0 do
        Dispose(FSyncListLog.Items[0]);
      FreeAndNil(FSyncListLog);
    end;
  FreeAndNil(FConnection);
  FreeAndNil(FSocket);
  FreeAndNil(FLock);
  inherited Destroy;
end;

{ Synchronize }

procedure TF4TCPClient.Synchronize(const SyncProc: TSyncProc);
begin
  {$IFDEF DELPHI6_DOWN}
  if GetCurrentThreadID = MainThreadID then
    SyncProc
  else
  if Assigned(FProcessThread) then
    FProcessThread.Synchronize(SyncProc);
  {$ELSE}
  TThread.Synchronize(nil, SyncProc);
  {$ENDIF}
end;

{ Log }

type
  TTCPClientSyncLogData = record
    LogType  : TTCPClientLogType;
    LogMsg   : String;
    LogLevel : Integer;
  end;
  PTCPClientSyncLogData = ^TTCPClientSyncLogData;

procedure TF4TCPClient.SyncLog;
var SyncRec : PTCPClientSyncLogData;
begin
  if csDestroying in ComponentState then
    exit;
  Lock;
  try
    Assert(Assigned(FSyncListLog));
    Assert(FSyncListLog.Count > 0);
    SyncRec := FSyncListLog.Items[0];
    FSyncListLog.Delete(0);
  finally
    Unlock;
  end;
  if Assigned(FOnLog) then
    FOnLog(self, SyncRec.LogType, SyncRec.LogMsg, SyncRec.LogLevel);
  Dispose(SyncRec);
end;

procedure TF4TCPClient.Log(const LogType: TTCPClientLogType; const Msg: String; const LogLevel: Integer);
var SyncRec : PTCPClientSyncLogData;
begin
  if Assigned(FOnLog) then
    if FSynchronisedEvents and (GetCurrentThreadID <> MainThreadID) then
      begin
        New(SyncRec);
        SyncRec.LogType := LogType;
        SyncRec.LogMsg := Msg;
        SyncRec.LogLevel := LogLevel;
        Lock;
        try
          if not Assigned(FSyncListLog) then
            FSyncListLog := TList.Create;
          FSyncListLog.Add(SyncRec);
        finally
          Unlock;
        end;
        Synchronize(SyncLog);
      end
    else
      FOnLog(self, LogType, Msg, LogLevel);
end;

procedure TF4TCPClient.Log(const LogType: TTCPClientLogType; const Msg: String;
    const Args: array of const; const LogLevel: Integer);
begin
  Log(LogType, Format(Msg, Args), LogLevel);
end;

{ Lock }

procedure TF4TCPClient.Lock;
begin
  if Assigned(FLock) then
    FLock.Acquire;
end;

procedure TF4TCPClient.Unlock;
begin
  if Assigned(FLock) then
    FLock.Release;
end;

{ State }

function TF4TCPClient.GetState: TTCPClientState;
begin
  Lock;
  try
    Result := FState;
  finally
    Unlock;
  end;
end;

function TF4TCPClient.GetStateStr: RawByteString;
begin
  Result := SClientState[GetState];
end;

procedure TF4TCPClient.SetState(const State: TTCPClientState);
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

procedure TF4TCPClient.CheckNotActive;
begin
  if not (csDesigning in ComponentState) then
    if FActive then
      raise ETCPClient.Create(SError_NotAllowedWhileActive);
end;

procedure TF4TCPClient.CheckActive;
begin
  if not FActive then
    raise ETCPClient.Create(SError_NotAllowedWhileInactive);
end;

{ Property setters }

procedure TF4TCPClient.SetAddressFamily(const AddressFamily: TTCPClientAddressFamily);
begin
  if AddressFamily = FAddressFamily then
    exit;
  CheckNotActive;
  FAddressFamily := AddressFamily;
end;

procedure TF4TCPClient.SetHost(const Host: AnsiString);
begin
  if Host = FHost then
    exit;
  CheckNotActive;
  FHost := Host;
  {$IFDEF TCP_DEBUG}
  Log(cltDebug, 'Host:%s', [Host]);
  {$ENDIF}
end;

procedure TF4TCPClient.SetPort(const Port: AnsiString);
begin
  if Port = FPort then
    exit;
  CheckNotActive;
  FPort := Port;
  {$IFDEF TCP_DEBUG}
  Log(cltDebug, 'Port:%s', [Port]);
  {$ENDIF}
end;

function TF4TCPClient.GetPortInt: Integer;
begin
  Result := StringToIntDefA(FPort, -1)
end;

procedure TF4TCPClient.SetPortInt(const PortInt: Integer);
begin
  SetPort(IntToStringA(PortInt));
end;

procedure TF4TCPClient.SetLocalHost(const LocalHost: AnsiString);
begin
  if LocalHost = FLocalHost then
    exit;
  CheckNotActive;
  FLocalHost := LocalHost;
  {$IFDEF TCP_DEBUG}
  Log(cltDebug, 'LocalHost:%s', [LocalHost]);
  {$ENDIF}
end;

procedure TF4TCPClient.SetLocalPort(const LocalPort: AnsiString);
begin
  if LocalPort = FLocalPort then
    exit;
  CheckNotActive;
  FLocalPort := LocalPort;
end;

{$IFDEF TCPCLIENT_SOCKS}
procedure TF4TCPClient.SetSocksProxy(const SocksProxy: Boolean);
begin
  if SocksProxy = FSocksEnabled then
    exit;
  CheckNotActive;
  FSocksEnabled := SocksProxy;
end;

procedure TF4TCPClient.SetSocksHost(const SocksHost: AnsiString);
begin
  if SocksHost = FSocksHost then
    exit;
  CheckNotActive;
  FSocksHost := SocksHost;
end;

procedure TF4TCPClient.SetSocksPort(const SocksPort: AnsiString);
begin
  if SocksPort = FSocksPort then
    exit;
  CheckNotActive;
  FSocksHost := SocksHost;
end;

procedure TF4TCPClient.SetSocksAuth(const SocksAuth: Boolean);
begin
  if SocksAuth = FSocksAuth then
    exit;
  CheckNotActive;
  FSocksAuth := SocksAuth;
end;

procedure TF4TCPClient.SetSocksUsername(const SocksUsername: AnsiString);
begin
  if SocksUsername = FSocksUsername then
    exit;
  CheckNotActive;
  FSocksUsername := SocksUsername;
end;

procedure TF4TCPClient.SetSocksPassword(const SocksPassword: AnsiString);
begin
  if SocksPassword = FSocksPassword then
    exit;
  CheckNotActive;
  FSocksPassword := SocksPassword;
end;
{$ENDIF}

{$IFDEF TCPCLIENT_TLS}
procedure TF4TCPClient.SetTLSEnabled(const TLSEnabled: Boolean);
begin
  if TLSEnabled = FTLSEnabled then
    exit;
  CheckNotActive;
  FTLSEnabled := TLSEnabled;
  {$IFDEF TCP_DEBUG}
  Log(cltDebug, 'TLSEnabled:%d', [Ord(TLSEnabled)]);
  {$ENDIF}
end;

procedure TF4TCPClient.SetTLSOptions(const TLSOptions: TTCPClientTLSOptions);
begin
  if TLSOptions = FTLSOptions then
    exit;
  CheckNotActive;
  FTLSOptions := TLSOptions;
end;
{$ENDIF}

procedure TF4TCPClient.SetSynchronisedEvents(const SynchronisedEvents: Boolean);
begin
  if SynchronisedEvents = FSynchronisedEvents then
    exit;
  CheckNotActive;
  FSynchronisedEvents := SynchronisedEvents;
end;

procedure TF4TCPClient.SetWaitForStartup(const WaitForStartup: Boolean);
begin
  if WaitForStartup = FWaitForStartup then
    exit;
  CheckNotActive;
  FWaitForStartup := WaitForStartup;
end;

procedure TF4TCPClient.SetActive(const Active: Boolean);
begin
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

procedure TF4TCPClient.Loaded;
begin
  inherited Loaded;
  if FActivateOnLoaded then
    DoStart;
end;

{ SyncTrigger }

procedure TF4TCPClient.SyncTriggerError;
begin
  if csDestroying in ComponentState then
    exit;
  if Assigned(FOnError) then
    FOnError(self, FErrorMsg, FErrorCode);
end;

procedure TF4TCPClient.SyncTriggerStateChanged;
begin
  if csDestroying in ComponentState then
    exit;
  if Assigned(FOnStateChanged) then
    FOnStateChanged(self, FState);
end;

procedure TF4TCPClient.SyncTriggerStart;
begin
  if csDestroying in ComponentState then
    exit;
  if Assigned(FOnStart) then
    FOnStart(self);
end;

procedure TF4TCPClient.SyncTriggerStop;
begin
  if csDestroying in ComponentState then
    exit;
  if Assigned(FOnStop) then
    FOnStop(self);
end;

procedure TF4TCPClient.SyncTriggerActive;
begin
  if csDestroying in ComponentState then
    exit;
  if Assigned(FOnActive) then
    FOnActive(self);
end;

procedure TF4TCPClient.SyncTriggerInactive;
begin
  if csDestroying in ComponentState then
    exit;
  if Assigned(FOnInactive) then
    FOnInactive(self);
end;

procedure TF4TCPClient.SyncTriggerStarted;
begin
  if csDestroying in ComponentState then
    exit;
  if Assigned(FOnStarted) then
    FOnStarted(self);
end;

procedure TF4TCPClient.SyncTriggerConnected;
begin
  if csDestroying in ComponentState then
    exit;
  if Assigned(FOnConnected) then
    FOnConnected(self);
end;

procedure TF4TCPClient.SyncTriggerNegotiating;
begin
  if csDestroying in ComponentState then
    exit;
  if Assigned(FOnNegotiating) then
    FOnNegotiating(self);
end;

procedure TF4TCPClient.SyncTriggerConnectFailed;
begin
  if csDestroying in ComponentState then
    exit;
  if Assigned(FOnConnectFailed) then
    FOnConnectFailed(self);
end;

procedure TF4TCPClient.SyncTriggerReady;
begin
  if csDestroying in ComponentState then
    exit;
  if Assigned(FOnReady) then
    FOnReady(self);
end;

procedure TF4TCPClient.SyncTriggerRead;
begin
  if csDestroying in ComponentState then
    exit;
  if Assigned(FOnRead) then
    FOnRead(self);
end;

procedure TF4TCPClient.SyncTriggerWrite;
begin
  if csDestroying in ComponentState then
    exit;
  if Assigned(FOnWrite) then
    FOnWrite(self);
end;

procedure TF4TCPClient.SyncTriggerClose;
begin
  if csDestroying in ComponentState then
    exit;
  if Assigned(FOnClose) then
    FOnClose(self);
end;

procedure TF4TCPClient.SyncTriggerStopped;
begin
  if csDestroying in ComponentState then
    exit;
  if Assigned(FOnStopped) then
    FOnStopped(self);
end;

{ Trigger }

procedure TF4TCPClient.TriggerError;
begin
  Log(cltError, 'Error:%d:%s', [FErrorCode, FErrorMsg]);
  if Assigned(FOnError) then
    if FSynchronisedEvents then
      Synchronize(SyncTriggerError)
    else
      FOnError(self, FErrorMsg, FErrorCode);
end;

procedure TF4TCPClient.TriggerStateChanged;
begin
  {$IFDEF TCP_DEBUG}
  Log(cltDebug, 'State:%s', [GetStateStr]);
  {$ENDIF}
  if Assigned(FOnStateChanged) then
    if FSynchronisedEvents then
      Synchronize(SyncTriggerStateChanged)
    else
      FOnStateChanged(self, FState);
end;

procedure TF4TCPClient.TriggerStart;
begin
  {$IFDEF TCP_DEBUG}
  Log(cltDebug, 'Start');
  {$ENDIF}
  if Assigned(FOnStart) then
    if FSynchronisedEvents then
      Synchronize(SyncTriggerStart)
    else
      FOnStart(self);
end;

procedure TF4TCPClient.TriggerStop;
begin
  {$IFDEF TCP_DEBUG}
  Log(cltDebug, 'Stop');
  {$ENDIF}
  if Assigned(FOnStop) then
    if FSynchronisedEvents then
      Synchronize(SyncTriggerStop)
    else
      FOnStop(self);
end;

procedure TF4TCPClient.TriggerActive;
begin
  {$IFDEF TCP_DEBUG}
  Log(cltDebug, 'Active');
  {$ENDIF}
  if Assigned(FOnActive) then
    if FSynchronisedEvents then
      Synchronize(SyncTriggerActive)
    else
      FOnActive(self);
end;

procedure TF4TCPClient.TriggerInactive;
begin
  {$IFDEF TCP_DEBUG}
  Log(cltDebug, 'Inactive');
  {$ENDIF}
  if Assigned(FOnInactive) then
    if FSynchronisedEvents then
      Synchronize(SyncTriggerInactive)
    else
      FOnInactive(self);
end;

procedure TF4TCPClient.TriggerIdle;
begin
  if Assigned(FOnIdle) then
    FOnIdle(self);
  Sleep(1);
end;

procedure TF4TCPClient.TriggerStarted;
begin
  {$IFDEF TCP_DEBUG}
  Log(cltDebug, 'Started');
  {$ENDIF}
  if Assigned(FOnStarted) then
    if FSynchronisedEvents then
      Synchronize(SyncTriggerStarted)
    else
      FOnStarted(self);
end;

procedure TF4TCPClient.TriggerConnected;
begin
  {$IFDEF TCP_DEBUG}
  Log(cltDebug, 'Connected');
  {$ENDIF}
  if Assigned(FOnConnected) then
    if FSynchronisedEvents then
      Synchronize(SyncTriggerConnected)
    else
      FOnConnected(self);
end;

procedure TF4TCPClient.TriggerNegotiating;
begin
  {$IFDEF TCP_DEBUG}
  Log(cltDebug, 'Negotiating');
  {$ENDIF}
  if Assigned(FOnNegotiating) then
    if FSynchronisedEvents then
      Synchronize(SyncTriggerNegotiating)
    else
      FOnNegotiating(self);
end;

procedure TF4TCPClient.TriggerConnectFailed;
begin
  {$IFDEF TCP_DEBUG}
  Log(cltDebug, 'ConnectFailed');
  {$ENDIF}
  if Assigned(FOnConnectFailed) then
    if FSynchronisedEvents then
      Synchronize(SyncTriggerConnectFailed)
    else
      FOnConnectFailed(self);
end;

procedure TF4TCPClient.TriggerReady;
begin
  {$IFDEF TCP_DEBUG}
  Log(cltDebug, 'Ready');
  {$ENDIF}
  if Assigned(FOnReady) then
    if FSynchronisedEvents then
      Synchronize(SyncTriggerReady)
    else
      FOnReady(self);
end;

procedure TF4TCPClient.TriggerRead;
begin
  {$IFDEF TCP_DEBUG}
  Log(cltDebug, 'Read');
  {$ENDIF}
  if Assigned(FOnRead) then
    if FSynchronisedEvents then
      Synchronize(SyncTriggerRead)
    else
      FOnRead(self);
end;

procedure TF4TCPClient.TriggerWrite;
begin
  {$IFDEF TCP_DEBUG}
  Log(cltDebug, 'Write');
  {$ENDIF}
  if Assigned(FOnWrite) then
    if FSynchronisedEvents then
      Synchronize(SyncTriggerWrite)
    else
      FOnWrite(self);
end;

procedure TF4TCPClient.TriggerClose;
begin
  {$IFDEF TCP_DEBUG}
  Log(cltDebug, 'Close');
  {$ENDIF}
  if Assigned(FOnClose) then
    if FSynchronisedEvents then
      Synchronize(SyncTriggerClose)
    else
      FOnClose(self);
end;

procedure TF4TCPClient.TriggerStopped;
begin
  {$IFDEF TCP_DEBUG}
  Log(cltDebug, 'Stopped');
  {$ENDIF}
  if Assigned(FOnStopped) then
    if FSynchronisedEvents then
      Synchronize(SyncTriggerStopped)
    else
      FOnStopped(self);
end;

{ SetStates }

procedure TF4TCPClient.SetError(const ErrorMsg: String; const ErrorCode: Integer);
begin
  FErrorMsg := ErrorMsg;
  FErrorCode := ErrorCode;
  TriggerError;
end;

procedure TF4TCPClient.SetStarted;
begin
  SetState(csStarted);
  TriggerStarted;
end;

procedure TF4TCPClient.SetConnected;
begin
  SetState(csConnected);
  TriggerConnected;
  FConnection.Start;
end;

procedure TF4TCPClient.SetNegotiating;
begin
  SetState(csNegotiating);
  TriggerNegotiating;
end;

procedure TF4TCPClient.SetReady;
begin
  SetState(csReady);
  TriggerReady;
end;

procedure TF4TCPClient.SetClosed;
begin
  if GetState in [csClosed, csStopped] then
    exit;
  SetState(csClosed);
  TriggerClose;
end;

procedure TF4TCPClient.SetStopped;
begin
  SetState(csStopped);
  TriggerStopped;
end;

{ Socket }

procedure TF4TCPClient.SocketLog(Sender: TSysSocket; LogType: TSysSocketLogType; Msg: String);
begin
  {$IFDEF TCP_DEBUG}
  Log(cltDebug, 'Socket:%s', [Msg], 10);
  {$ENDIF}
end;

{ Connection events }

procedure TF4TCPClient.ConnectionLog(Sender: TTCPConnection; LogType: TTCPLogType; LogMsg: String; LogLevel: Integer);
begin
  {$IFDEF TCP_DEBUG}
  Log(cltDebug, 'Connection:%s', [LogMsg], LogLevel + 1);
  {$ENDIF}
end;

procedure TF4TCPClient.ConnectionStateChange(Sender: TTCPConnection; State: TTCPConnectionState);
begin
  {$IFDEF TCP_DEBUG}
  Log(cltDebug, 'Connection_StateChange:%s', [Sender.StateStr]);
  {$ENDIF}
  case State of
    cnsProxyNegotiation : SetNegotiating;
    cnsConnected        : SetReady;
  end;
end;

procedure TF4TCPClient.ConnectionRead(Sender: TTCPConnection);
begin
  {$IFDEF TCP_DEBUG}
  Log(cltDebug, 'Connection_Read');
  {$ENDIF}
  TriggerRead;
end;

procedure TF4TCPClient.ConnectionWrite(Sender: TTCPConnection);
begin
  {$IFDEF TCP_DEBUG}
  Log(cltDebug, 'Connection_Write');
  {$ENDIF}
  TriggerWrite;
end;

procedure TF4TCPClient.ConnectionClose(Sender: TTCPConnection);
begin
  {$IFDEF TCP_DEBUG}
  Log(cltDebug, 'Connection_Close');
  {$ENDIF}
  SetClosed;
end;

{ Proxies }

{$IFDEF TCPCLIENT_TLS}
procedure TF4TCPClient.InstallTLSProxy;
var Proxy : TTCPClientTLSConnectionProxy;
begin
  {$IFDEF TCP_DEBUG}
  Log(cltDebug, 'InstallTLSProxy');
  {$ENDIF}
  Proxy := TTCPClientTLSConnectionProxy.Create(self);
  FTLSProxy := Proxy;
  FTLSClient := Proxy.FTLSClient;
  FConnection.AddProxy(Proxy);
end;

function TF4TCPClient.GetTLSClient: TTLSClient;
var C : TTLSClient;
begin
  C := FTLSClient;
  if not Assigned(C) then
    raise ETCPClient.Create(SError_TLSNotActive);
  Result := C;
end;
{$ENDIF}

{$IFDEF TCPCLIENT_SOCKS}
procedure TF4TCPClient.InstallSocksProxy;
begin
  {$IFDEF TCP_DEBUG}
  Log(cltDebug, 'InstallSocksProxy');
  {$ENDIF}
  FConnection.AddProxy(TTCPClientSocksConnectionProxy.Create(self));
end;
{$ENDIF}

{ Connection }

function TF4TCPClient.GetConnection: TTCPConnection;
begin
  Result := FConnection;
end;

procedure TF4TCPClient.CreateConnection;
var AF : TIPAddressFamily;
begin
  Lock;
  try
    Assert(FActive);
    Assert(FState = csStarting);
    Assert(not Assigned(FSocket));
    Assert(not Assigned(FConnection));

    case FAddressFamily of
      cafIP4 : AF := iaIP4;
      cafIP6 : AF := iaIP6;
    else
      raise ETCPClient.Create('Invalid address family');
    end;
    FIPAddressFamily := AF;
    FSocket := TSysSocket.Create(AF, ipTCP, False, INVALID_SOCKETHANDLE);
    {$IFDEF TCP_DEBUG}
    FSocket.OnLog := SocketLog;
    {$ENDIF}

    FConnection := TTCPConnection.Create(FSocket);
    FConnection.OnLog         := ConnectionLog;
    FConnection.OnStateChange := ConnectionStateChange;
    FConnection.OnRead        := ConnectionRead;
    FConnection.OnWrite       := ConnectionWrite;
    FConnection.OnClose       := ConnectionClose;
  finally
    Unlock;
  end;

  {$IFDEF TCPCLIENT_SOCKS}
  if FSocksEnabled then
    InstallSocksProxy;
  {$ENDIF}

  {$IFDEF TCPCLIENT_TLS}
  if FTLSEnabled then
    InstallTLSProxy;
  {$ENDIF}
end;

procedure TF4TCPClient.FreeConnection;
begin
  FreeAndNil(FConnection);
  FreeAndNil(FSocket);
end;

{ Resolve }

procedure TF4TCPClient.DoResolve;
var
  LocAddr : TSocketAddr;
  ConAddr : TSocketAddr;
begin
  Assert(FActive);
  Assert(FState = csStarted);
  Assert(FHost <> '');
  {$IFDEF TCP_DEBUG}
  Log(cltDebug, 'DoResolve');
  {$ENDIF}

  SetState(csResolving);
  LocAddr := cSocketLib.ResolveA(FLocalHost, FLocalPort, FIPAddressFamily, ipTCP);
  ConAddr := cSocketLib.ResolveA(FHost, FPort, FIPAddressFamily, ipTCP);

  Lock;
  try
    {$IFDEF TCPCLIENT_SOCKS}
    if FSocksEnabled then
      begin
        FSocksResolvedAddr := ConAddr;
        ConAddr := cSocketLib.ResolveA(FSocksHost, FSocksPort, FIPAddressFamily, ipTCP);
      end
    else
      InitSocketAddrNone(FSocksResolvedAddr);
    {$ENDIF}
    FConnectAddr := ConAddr;
    FLocalAddr := LocAddr;
  finally
    Unlock;
  end;
  SetState(csResolved);
end;

{ Connect / Close }

procedure TF4TCPClient.DoConnect;
begin
  Assert(FActive);
  Assert(FState = csResolved);
  Assert(Assigned(FSocket));
  {$IFDEF TCP_DEBUG}
  Log(cltDebug, 'DoConnect');
  {$ENDIF}

  SetState(csConnecting);
  FSocket.Bind(FLocalAddr);
  FSocket.Connect(FConnectAddr);
  SetConnected;
end;

procedure TF4TCPClient.DoClose;
begin
  Assert(Assigned(FSocket));
  Assert(Assigned(FConnection));
  {$IFDEF TCP_DEBUG}
  Log(cltDebug, 'DoClose');
  {$ENDIF}
  
  FConnection.Close;
  SetClosed;
end;

{ Thread }

procedure TF4TCPClient.StartThread;
begin
  {$IFDEF TCP_DEBUG}
  Log(cltDebug, 'StartThread');
  {$ENDIF}
  FProcessThread := TTCPClientThread.Create(self);
end;

procedure TF4TCPClient.StopThread;
begin
  {$IFDEF TCP_DEBUG}
  Log(cltDebug, 'StopThread');
  {$ENDIF}
  FreeAndNil(FProcessThread);
end;

{$IFDEF OS_MSWIN}
function TF4TCPClient.ProcessMessage(var MsgTerminated: Boolean): Boolean;
var Msg : TMsg;
begin
  Result := PeekMessage(Msg, 0, 0, 0, PM_REMOVE);
  if not Result then
    exit;
  if Msg.Message = WM_QUIT then
    begin
      MsgTerminated := True;
      exit;
    end;
  TranslateMessage(Msg);
  DispatchMessage(Msg);
end;
{$ENDIF}

procedure TF4TCPClient.ThreadExecute(const Thread: TTCPClientThread);

  function IsTerminated: Boolean;
  begin
    Result := Thread.Terminated;
  end;

  procedure SetErrorFromException(const E: Exception);
  begin
    if E is ESocketLib then
      SetError(E.Message, ESocketLib(E).ErrorCode)
    else
      SetError(E.Message, -1);
  end;

var
  ConIdle, ConTerminated : Boolean;
  {$IFDEF OS_MSWIN}
  MsgProcessed, MsgTerminated : Boolean;
  {$ENDIF}
begin
  Assert(Assigned(Thread));
  {$IFDEF TCP_DEBUG}
  Log(cltDebug, 'ThreadExecute');
  {$ENDIF}
  try
    // connection setup
    try
      // startup
      CreateConnection;
      if IsTerminated then
        exit;
      SetStarted;
      FSocket.SetBlocking(True);
      // resolve
      DoResolve;
      if IsTerminated then
        exit;
      // connect
      DoConnect;
      if IsTerminated then
        exit;
    except
      on E : Exception do
        begin
          SetErrorFromException(E);
          TriggerConnectFailed;
          exit;
        end;
    end;
    // poll loop
    try
      FSocket.SetBlocking(False);
      {$IFDEF OS_MSWIN}
      MsgTerminated := False;
      {$ENDIF}
      while not IsTerminated do
        begin
          FConnection.PollSocket(ConIdle, ConTerminated);
          if ConTerminated then
            begin
              Thread.Terminate;
              {$IFDEF TCP_DEBUG}
              Log(cltDebug, 'ThreadTerminate:ConnectionTerminated');
              {$ENDIF}
            end
          else
          if ConIdle then
            begin
              {$IFDEF OS_MSWIN}
              MsgProcessed := ProcessMessage(MsgTerminated);
              if MsgTerminated then
                begin
                  Thread.Terminate;
                  {$IFDEF TCP_DEBUG}
                  Log(cltDebug, 'ThreadTerminate:MsgTerminated');
                  {$ENDIF}
                end
              else
                if not MsgProcessed then
                  TriggerIdle;
              {$ELSE}
              TriggerIdle;
              {$ENDIF}
            end;
        end;
    except
      on E : Exception do
        if not Thread.Terminated then
          SetErrorFromException(E);
    end;
  finally
    if not Thread.Terminated then
      SetClosed;
  end;
  {$IFDEF TCP_DEBUG}
  Log(cltDebug, 'ThreadTerminate:Terminated=%d', [Ord(IsTerminated)]);
  {$ENDIF}
end;

{ Start / Stop }

const
  // milliseconds to wait for thread to startup,
  // this usually happens within 1 ms but could pause for a few seconds if the
  // system is busy
  ThreadStartupTimeOut = 15000; // 15 seconds

procedure TF4TCPClient.DoStart;
var
  IsStarting : Boolean;
  WaitForStart : Boolean;
begin
  // ensure only one thread is doing DoStart
  Lock;
  try
    if FActive then
      exit;
    IsStarting := False;
    WaitForStart := False;
    // validate paramters
    if FHost = '' then
      raise ETCPClient.Create(SError_HostNotSpecified);
    if FPort = '' then
      raise ETCPClient.Create(SError_PortNotSpecified);
    // check if already starting
    IsStarting := FState = csStarting;
    if not IsStarting then
      SetState(csStarting);
    WaitForStart := FWaitForStartup;
  finally
    Unlock;
  end;
  if IsStarting then
    begin
      // this thread is not doing startup, wait for other thread to complete startup
      if WaitForStart then
        if WaitState(TCPClientStates_All - [csStarting], ThreadStartupTimeOut) = csStarting then
          raise ETCPClient.Create(SError_StartupFailed); // timed out waiting for startup
      exit;
    end;
  Assert(not FActive);
  // notify start
  TriggerStart;
  // initialise active state
  Lock;
  try
    FErrorMsg := '';
    FErrorCode := 0;
    FActive := True;
  finally
    Unlock;
  end;
  // start thread
  StartThread;
  // wait for thread to complete startup
  if WaitForStart then
    if WaitState(TCPClientStates_All - [csStarting], ThreadStartupTimeOut) = csStarting then
      raise ETCPClient.Create(SError_StartupFailed); // timed out waiting for thread
    // connection object initialised
  // started
  TriggerActive;
end;

const
  ClientStopTimeOut = 15000; // 15 seconds

procedure TF4TCPClient.DoStop;
var
  IsStopping : Boolean;
begin
  // ensure only one thread is doing DoStop
  Lock;
  try
    if not FActive then
      exit;
    IsStopping := FIsStopping;
    if not IsStopping then
      FIsStopping := True;
  finally
    Unlock;
  end;
  if IsStopping then
    begin
      // this thread is not doing stop, wait for other thread to complete stop
      WaitState([csStopped], ClientStopTimeOut);
      exit;
    end;
  Assert(FActive);
  // stop
  try
    TriggerStop;
    StopThread;
    DoClose;
    FActive := False;
    TriggerInactive;
    SetStopped;
    FreeConnection;
  finally
    Lock;
    try
      FIsStopping := False;
    finally
      Unlock;
    end;
  end;
end;

procedure TF4TCPClient.Start;
begin
  DoStart;
end;

procedure TF4TCPClient.Stop;
begin
  DoStop;
end;

{ Connect state }

function TF4TCPClient.IsConnecting: Boolean;
begin
  Result := GetState in TCPClientStates_Connecting;
end;

function TF4TCPClient.IsConnectingOrConnected: Boolean;
begin
  Result := GetState in TCPClientStates_ConnectingOrConnected;
end;

function TF4TCPClient.IsConnected: Boolean;
begin
  Result := GetState in TCPClientStates_Connected;
end;

function TF4TCPClient.IsConnectionClosed: Boolean;
begin
  Result := GetState in TCPClientStates_Closed;
end;

{ TLS }

{$IFDEF TCPCLIENT_TLS}
procedure TF4TCPClient.StartTLS;
begin
  CheckActive;
  if FTLSEnabled then // TLS proxy already installed on activation
    exit;
  InstallTLSProxy;
end;
{$ENDIF}

{ Wait }

procedure TF4TCPClient.Wait;
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

// Wait until one of the States or time out
function TF4TCPClient.WaitState(const States: TTCPClientStates; const TimeOut: Integer): TTCPClientState;
var T : LongWord;
    S : TTCPClientState;
begin
  CheckActive;
  T := TCPGetTick;
  repeat
    S := GetState;
    if S in States then
      break;
    if TCPTickDelta(T, TCPGetTick) >= TimeOut then
      break;
    Wait;
  until False;
  Result := S;
end;

// Wait until connected (ready), closed or time out
function TF4TCPClient.WaitConnect(const TimeOut: Integer): Boolean;
begin
  Result := WaitState([csReady, csClosed, csStopped], TimeOut) = csReady;
end;

// Wait until amount of data received, closed or time out
function TF4TCPClient.WaitReceive(const ReadBufferSize: Integer; const TimeOut: Integer): Boolean;
var T : LongWord;
    L : Integer;
begin
  CheckActive;
  T := TCPGetTick;
  repeat
    L := FConnection.ReadBufferSize;
    if L >= ReadBufferSize then
      break;
    if TCPTickDelta(T, TCPGetTick) >= TimeOut then
      break;
    if GetState in [csClosed, csStopped] then
      break;
    Wait;
  until False;
  Result := L >= ReadBufferSize;
end;

// Wait until send buffer is cleared to socket, closed or time out
function TF4TCPClient.WaitTransmit(const TimeOut: Integer): Boolean;
var T : LongWord;
    L : Integer;
begin
  CheckActive;
  T := TCPGetTick;
  repeat
    L := FConnection.WriteBufferSize;
    if L = 0 then
      break;
    if TCPTickDelta(T, TCPGetTick) >= TimeOut then
      break;
    if GetState in [csClosed, csStopped] then
      break;
    Wait;
  until False;
  Result := L = 0;
end;

// Wait until socket is closed or time out
function TF4TCPClient.WaitClose(const TimeOut: Integer): Boolean;
begin
  Result := WaitState([csClosed, csStopped], TimeOut) = csClosed;
end;

{ Blocking }

procedure TF4TCPClient.BlockingClose(const TimeOut: Integer);
begin
  CheckActive;;
  DoClose;
  if not WaitClose(TimeOut) then
    raise ETCPClient.Create(SError_TimedOut);
end;

// Does a graceful shutdown and waits for connection to close or timeout
// Data received during shutdown is available after connection close
procedure TF4TCPClient.BlockingShutdown(const TransmitTimeOut: Integer; const CloseTimeOut: Integer);
begin
  CheckActive;
  if not WaitTransmit(TransmitTimeOut) then
    raise ETCPClient.Create(SError_TimedOut);
  FConnection.Shutdown;
  if not WaitClose(CloseTimeOut) then
    raise ETCPClient.Create(SError_TimedOut);
end;



end.

