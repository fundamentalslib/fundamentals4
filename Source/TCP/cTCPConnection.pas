{******************************************************************************}
{                                                                              }
{   Library:          Fundamentals 4.00                                        }
{   File name:        cTCPConnection.pas                                       }
{   File version:     4.21                                                     }
{   Description:      TCP connection.                                          }
{                                                                              }
{   Copyright:        Copyright (c) 2007-2015, David J Butler                  }
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
{   2008/12/23  0.01  Initial development.                                     }
{   2010/11/07  0.02  Revision.                                                }
{   2010/11/12  0.03  Refactor for asynchronous operation.                     }
{   2010/12/03  0.04  Connection proxies.                                      }
{   2010/12/17  0.05  Throttling.                                              }
{   2010/12/19  0.06  Multiple connection proxies.                             }
{   2010/12/29  0.07  Report read/write rates.                                 }
{   2011/01/02  0.08  Bug fix in PollSocket routine.                           }
{   2011/06/16  0.09  Fix TriggerRead with proxies.                            }
{   2011/06/18  0.10  Fix Read error in PollSocket when closed by proxies.     }
{   2011/06/25  0.11  Improve Write notifications.                             }
{   2011/06/26  0.12  Implement defered shutdown if write buffer not empty.    }
{   2011/07/03  0.13  WriteBufferEmpty event.                                  }
{   2011/07/04  0.14  Trigger read events outside lock.                        }
{   2011/07/24  0.15  Discard method.                                          }
{   2011/07/31  0.16  Defer close from proxy until after read.                 }
{   2011/09/03  4.17  Revise for Fundamentals 4.                               }
{   2011/09/10  4.18  Improve locking granularity.                             }
{   2011/09/15  4.19  Improve polling efficiency.                              }
{   2011/10/06  4.20  Fix TCPTick frequency.                                   }
{   2015/03/14  4.21  RawByteString changes.                                   }
{                                                                              }
{******************************************************************************}

{$INCLUDE cTCP.inc}

unit cTCPConnection;

interface

uses
  { System }
  SysUtils,
  {$IFDEF WindowsPlatform}
  Windows,
  {$ENDIF}
  SyncObjs,

  { Fundamentals }
  cUtils,
  cSocket,
  cTCPBuffer;



{                                                                              }
{ TCP Connection                                                               }
{                                                                              }
type
  ETCPConnection = class(Exception);

  TTCPConnection = class;

  TTCPLogType = (
    tlDebug,
    tlInfo,
    tlError);

  TTCPConnectionProxyState = (
    prsInit,        // proxy is initialising
    prsNegotiating, // proxy is negotiating, connection data is not yet being transferred
    prsFiltering,   // proxy has successfully completed negotiation and is actively filtering connection data
    prsFinished,    // proxy has successfully completed operation and can be bypassed
    prsError,       // proxy has failed and connection is invalid
    prsClosed);     // proxy has closed the connection

  TTCPConnectionProxy = class
  private
    FConnection : TTCPConnection;
    FNextProxy  : TTCPConnectionProxy;
    FState      : TTCPConnectionProxyState;

  protected
    procedure Log(const LogType: TTCPLogType; const LogMsg: String; const LogLevel: Integer = 0); overload;
    procedure Log(const LogType: TTCPLogType; const LogMsg: String; const LogArgs: array of const; const LogLevel: Integer = 0); overload;
    function  GetStateStr: RawByteString;
    procedure SetState(const State: TTCPConnectionProxyState);
    procedure ConnectionClose;
    procedure ConnectionPutReadData(const Buf; const BufSize: Integer);
    procedure ConnectionPutWriteData(const Buf; const BufSize: Integer);
    procedure ProxyStart; virtual; abstract;

  public
    class function ProxyName: String; virtual;

    constructor Create(const Connection: TTCPConnection);

    property  State: TTCPConnectionProxyState read FState;
    property  StateStr: RawByteString read GetStateStr;
    procedure Start;
    procedure ProcessReadData(const Buf; const BufSize: Integer); virtual; abstract;
    procedure ProcessWriteData(const Buf; const BufSize: Integer); virtual; abstract;
  end;

  TTCPConnectionProxyList = class
  private
    FList : array of TTCPConnectionProxy;

    function  GetCount: Integer;
    function  GetItem(const Idx: Integer): TTCPConnectionProxy;
    function  GetLastItem: TTCPConnectionProxy;

  public
    destructor Destroy; override;

    property  Count: Integer read GetCount;
    property  Item[const Idx: Integer]: TTCPConnectionProxy read GetItem; default;
    procedure Add(const Proxy: TTCPConnectionProxy);
    property  LastItem: TTCPConnectionProxy read GetLastItem;
  end;

  TTCPConnectionState = (
    cnsInit,
    cnsProxyNegotiation,
    cnsConnected,
    cnsClosed);

  TTCPConnectionTransferState = record
    LastUpdate   : LongWord;
    ByteCount    : Int64;
    TransferRate : LongWord;
  end;

  TRawByteCharSet = set of AnsiChar;

  TTCPConnectionNotifyEvent = procedure (Sender: TTCPConnection) of object;
  TTCPConnectionStateChangeEvent = procedure (Sender: TTCPConnection; State: TTCPConnectionState) of object;
  TTCPConnectionLogEvent = procedure (Sender: TTCPConnection; LogType: TTCPLogType; LogMsg: String; LogLevel: Integer) of object;

  TTCPConnection = class
  protected
    FSocket             : TSysSocket;

    FOnLog              : TTCPConnectionLogEvent;
    FOnStateChange      : TTCPConnectionStateChangeEvent;
    FOnRead             : TTCPConnectionNotifyEvent;
    FOnWrite            : TTCPConnectionNotifyEvent;
    FOnClose            : TTCPConnectionNotifyEvent;
    FOnReadBufferFull   : TTCPConnectionNotifyEvent;
    FOnWriteBufferEmpty : TTCPConnectionNotifyEvent;

    FLock               : TCriticalSection;
    FState              : TTCPConnectionState;

    FProxyList          : TTCPConnectionProxyList;
    FProxyConnection    : Boolean;

    FReadBuffer         : TTCPBuffer;
    FReadBufferMaxSize  : Integer;
    FWriteBuffer        : TTCPBuffer;
    FWriteBufferMaxSize : Integer;

    FReadThrottle       : Boolean;
    FReadThrottleRate   : Integer;
    FWriteThrottle      : Boolean;
    FWriteThrottleRate  : Integer;

    FReadTransferState  : TTCPConnectionTransferState;
    FWriteTransferState : TTCPConnectionTransferState;

    FReadEventPending   : Boolean;
    FReadBufferFull     : Boolean;
    FReadSelectPending  : Boolean;
    FWriteEventPending  : Boolean;
    FShutdownPending    : Boolean;
    FClosePending       : Boolean;

    procedure Init; virtual;

    procedure Lock;
    procedure Unlock;

    procedure Log(const LogType: TTCPLogType; const LogMsg: String; const LogLevel: Integer = 0); overload;
    procedure Log(const LogType: TTCPLogType; const LogMsg: String; const LogArgs: array of const; const LogLevel: Integer = 0); overload;

    function  GetState: TTCPConnectionState;
    function  GetStateStr: RawByteString;
    procedure SetState(const State: TTCPConnectionState);

    procedure SetClosed;

    procedure SetReadBufferMaxSize(const ReadBufferMaxSize: Integer);
    procedure SetWriteBufferMaxSize(const WriteBufferMaxSize: Integer);

    procedure SetReadThrottle(const ReadThrottle: Boolean);
    procedure SetWriteThrottle(const WriteThrottle: Boolean);

    function  GetReadRate: Integer;
    function  GetWriteRate: Integer;

    function  GetReadBufferSize: Integer;
    function  GetWriteBufferSize: Integer;

    procedure TriggerRead;
    procedure TriggerWrite;
    procedure TriggerClose;
    procedure TriggerReadBufferFull;
    procedure TriggerWriteBufferEmpty;

    function  GetFirstActiveProxy: TTCPConnectionProxy;

    procedure ProxyProcessReadData(const Buf; const BufSize: Integer; out ReadEventPending: Boolean);
    procedure ProxyProcessWriteData(const Buf; const BufSize: Integer);

    procedure ProxyConnectionClose(const Proxy: TTCPConnectionProxy);
    procedure ProxyConnectionPutReadData(const Proxy: TTCPConnectionProxy; const Buf; const BufSize: Integer);
    procedure ProxyConnectionPutWriteData(const Proxy: TTCPConnectionProxy; const Buf; const BufSize: Integer);

    procedure ProxyLog(const Proxy: TTCPConnectionProxy; const LogType: TTCPLogType; const LogMsg: String; const LogLevel: Integer);
    procedure ProxyStateChange(const Proxy: TTCPConnectionProxy; const State: TTCPConnectionProxyState);

    procedure StartProxies(out ProxiesFinished: Boolean);

    function  FillBufferFromSocket(out RecvClosed, ReadEventPending, ReadBufFullEvent: Boolean): Integer;
    function  EmptyBufferToSocket(out BufferEmptyBefore, BufferEmptied: Boolean): Integer;

    function  LocateChrInBuffer(const Delimiter: TRawByteCharSet; const MaxSize: Integer): Integer;
    function  LocateStrInBuffer(const Delimiter: RawByteString; const MaxSize: Integer): Integer;

    function  ReadFromBuffer(var Buf; const BufSize: Integer): Integer;
    function  ReadFromSocket(var Buf; const BufSize: Integer): Integer;

    function  DiscardFromBuffer(const Size: Integer): Integer;

    function  WriteToBuffer(const Buf; const BufSize: Integer): Integer;
    function  WriteToSocket(const Buf; const BufSize: Integer): Integer;
    function  WriteToTransport(const Buf; const BufSize: Integer): Integer;

    procedure DoShutdown;

  public
    constructor Create(const Socket: TSysSocket);
    destructor Destroy; override;

    property  Socket: TSysSocket read FSocket;

    property  OnLog: TTCPConnectionLogEvent read FOnLog write FOnLog;
    property  OnStateChange: TTCPConnectionStateChangeEvent read FOnStateChange write FOnStateChange;
    property  OnRead: TTCPConnectionNotifyEvent read FOnRead write FOnRead;
    property  OnWrite: TTCPConnectionNotifyEvent read FOnWrite write FOnWrite;
    property  OnClose: TTCPConnectionNotifyEvent read FOnClose write FOnClose;
    property  OnReadBufferFull: TTCPConnectionNotifyEvent read FOnReadBufferFull write FOnReadBufferFull;
    property  OnWriteBufferEmpty: TTCPConnectionNotifyEvent read FOnWriteBufferEmpty write FOnWriteBufferEmpty;

    procedure AddProxy(const Proxy: TTCPConnectionProxy);

    property  State: TTCPConnectionState read GetState;
    property  StateStr: RawByteString read GetStateStr;
    procedure Start;

    property  ReadBufferMaxSize: Integer read FReadBufferMaxSize write SetReadBufferMaxSize;
    property  WriteBufferMaxSize: Integer read FWriteBufferMaxSize write SetWriteBufferMaxSize;

    property  ReadThrottle: Boolean read FReadThrottle write SetReadThrottle;
    property  ReadThrottleRate: Integer read FReadThrottleRate write FReadThrottleRate;
    property  WriteThrottle: Boolean read FWriteThrottle write SetWriteThrottle;
    property  WriteThrottleRate: Integer read FWriteThrottleRate write FWriteThrottleRate;

    property  ReadRate: Integer read GetReadRate;
    property  WriteRate: Integer read GetWriteRate;

    property  ReadBufferSize: Integer read GetReadBufferSize;
    property  WriteBufferSize: Integer read GetWriteBufferSize;

    procedure PollSocket(out Idle, Terminated: Boolean);

    function  Read(var Buf; const BufSize: Integer): Integer;
    function  ReadStr(const StrLen: Integer): RawByteString;

    function  Discard(const Size: Integer): Integer;

    function  Peek(var Buf; const BufSize: Integer): Integer;
    function  PeekByte(out B: Byte): Boolean;
    function  PeekStr(const StrLen: Integer): RawByteString;

    function  PeekDelimited(var Buf; const BufSize: Integer; const Delimiter: TRawByteCharSet; const MaxSize: Integer = -1): Integer; overload;
    function  PeekDelimited(var Buf; const BufSize: Integer; const Delimiter: RawByteString; const MaxSize: Integer = -1): Integer; overload;

    function  ReadLine(var Line: RawByteString; const Delimiter: RawByteString; const MaxLineLength: Integer = -1): Boolean;

    function  Write(const Buf; const BufSize: Integer): Integer;
    function  WriteStrA(const Str: RawByteString): Integer;
    function  WriteStrW(const Str: WideString): Integer;
    function  WriteStr(const Str: String): Integer;

    procedure Close;
    procedure Shutdown;
  end;

  TTCPConnectionClass = class of TTCPConnection;



{                                                                              }
{ TCP timer helpers                                                            }
{                                                                              }
function  TCPGetTick: LongWord;
function  TCPTickDelta(const D1, D2: LongWord): Integer;
function  TCPTickDeltaU(const D1, D2: LongWord): LongWord;



implementation

uses
  { Fundamentals }
  cSocketLib;



{                                                                              }
{ Error and debug strings                                                      }
{                                                                              }
const
  SError_InvalidParameter = 'Invalid parameter';

  SConnectionProxyState : array[TTCPConnectionProxyState] of RawByteString = (
    'Init',
    'Negotiating',
    'Filtering',
    'Finished',
    'Error',
    'Closed'
    );

  SConnectionState : array[TTCPConnectionState] of RawByteString = (
    'Init',
    'ProxyNegotiation',
    'Connected',
    'Closed'
    );



{                                                                              }
{ TCP Connection Proxy                                                         }
{                                                                              }
class function TTCPConnectionProxy.ProxyName: String;
begin
  Result := ClassName;
end;

constructor TTCPConnectionProxy.Create(const Connection: TTCPConnection);
begin
  Assert(Assigned(Connection));
  inherited Create;
  FState := prsInit;
  FConnection := Connection;
end;

procedure TTCPConnectionProxy.Log(const LogType: TTCPLogType; const LogMsg: String; const LogLevel: Integer);
begin
  FConnection.ProxyLog(self, LogType, LogMsg, LogLevel);
end;

procedure TTCPConnectionProxy.Log(const LogType: TTCPLogType; const LogMsg: String; const LogArgs: array of const; const LogLevel: Integer);
begin
  Log(LogType, Format(LogMsg, LogArgs), LogLevel);
end;

function TTCPConnectionProxy.GetStateStr: RawByteString;
begin
  Result := SConnectionProxyState[FState];
end;

procedure TTCPConnectionProxy.SetState(const State: TTCPConnectionProxyState);
begin
  if State = FState then
    exit;
  {$IFDEF TCP_DEBUG}
  Log(tlDebug, 'State:%s', [SConnectionProxyState[State]]);
  {$ENDIF}
  FState := State;
  FConnection.ProxyStateChange(self, State);
end;

procedure TTCPConnectionProxy.ConnectionClose;
begin
  {$IFDEF TCP_DEBUG}
  Log(tlDebug, 'Close');
  {$ENDIF}
  FConnection.ProxyConnectionClose(self);
end;

procedure TTCPConnectionProxy.ConnectionPutReadData(const Buf; const BufSize: Integer);
begin
  {$IFDEF TCP_DEBUG}
  Log(tlDebug, 'PutRead:%db', [BufSize]);
  {$ENDIF}
  FConnection.ProxyConnectionPutReadData(self, Buf, BufSize);
end;

procedure TTCPConnectionProxy.ConnectionPutWriteData(const Buf; const BufSize: Integer);
begin
  {$IFDEF TCP_DEBUG}
  Log(tlDebug, 'PutWrite:%db', [BufSize]);
  {$ENDIF}
  FConnection.ProxyConnectionPutWriteData(self, Buf, BufSize);
end;

procedure TTCPConnectionProxy.Start;
begin
  {$IFDEF TCP_DEBUG}
  Log(tlDebug, 'Start');
  {$ENDIF}
  ProxyStart;
end;



{                                                                              }
{ TCP Connection Proxy List                                                    }
{                                                                              }
destructor TTCPConnectionProxyList.Destroy;
var I : Integer;
begin
  for I := Length(FList) - 1 downto 0 do
    FreeAndNil(FList[I]);
  inherited Destroy;
end;

function TTCPConnectionProxyList.GetCount: Integer;
begin
  Result := Length(FList);
end;

function TTCPConnectionProxyList.GetItem(const Idx: Integer): TTCPConnectionProxy;
begin
  Assert((Idx >= 0) and (Idx < Length(FList)));
  Result := FList[Idx];
end;

function TTCPConnectionProxyList.GetLastItem: TTCPConnectionProxy;
var L : Integer;
begin
  L := Length(FList);
  if L = 0 then
    Result := nil
  else
    Result := FList[L - 1];
end;

procedure TTCPConnectionProxyList.Add(const Proxy: TTCPConnectionProxy);
var L : Integer;
begin
  Assert(Assigned(Proxy));
  L := Length(FList);
  SetLength(FList, L + 1);
  FList[L] := Proxy;
end;



{                                                                              }
{ TCP timer helpers                                                            }
{                                                                              }
function TCPGetTick: LongWord;
begin
  Result := Trunc(Frac(Now) * $5265C00);
end;

{$IFOPT Q+}{$DEFINE QOn}{$ELSE}{$UNDEF QOn}{$ENDIF}{$Q-}
function TCPTickDelta(const D1, D2: LongWord): Integer; {$IFDEF UseInline}inline;{$ENDIF}
begin
  Result := Integer(D2 - D1);
end;

function TCPTickDeltaU(const D1, D2: LongWord): LongWord; {$IFDEF UseInline}inline;{$ENDIF}
begin
  Result := LongWord(D2 - D1);
end;
{$IFDEF QOn}{$Q+}{$ENDIF}



{                                                                              }
{ TCP CompareMem helper                                                        }
{                                                                              }
{$IFDEF ASM386_DELPHI}
function TCPCompareMem(const Buf1; const Buf2; const Count: Integer): Boolean;
asm
      // EAX = Buf1, EDX = Buf2, ECX = Count
      OR      ECX, ECX
      JLE     @Fin1
      CMP     EAX, EDX
      JE      @Fin1
      PUSH    ESI
      PUSH    EDI
      MOV     ESI, EAX
      MOV     EDI, EDX
      MOV     EDX, ECX
      SHR     ECX, 2
      XOR     EAX, EAX
      REPE    CMPSD
      JNE     @Fin0
      MOV     ECX, EDX
      AND     ECX, 3
      REPE    CMPSB
      JNE     @Fin0
      INC     EAX
@Fin0:
      POP     EDI
      POP     ESI
      RET
@Fin1:
      MOV     AL, 1
end;
{$ELSE}
function TCPCompareMem(const Buf1; const Buf2; const Count: Integer): Boolean;
var P, Q : Pointer;
    D, I : Integer;
begin
  P := @Buf1;
  Q := @Buf2;
  if (Count <= 0) or (P = Q) then
    begin
      Result := True;
      exit;
    end;
  D := LongWord(Count) div 4;
  for I := 1 to D do
    if PLongWord(P)^ = PLongWord(Q)^ then
      begin
        Inc(PLongWord(P));
        Inc(PLongWord(Q));
      end
    else
      begin
        Result := False;
        exit;
      end;
  D := LongWord(Count) and 3;
  for I := 1 to D do
    if PByte(P)^ = PByte(Q)^ then
      begin
        Inc(PByte(P));
        Inc(PByte(Q));
      end
    else
      begin
        Result := False;
        exit;
      end;
  Result := True;
end;
{$ENDIF}



{                                                                              }
{ TCP Connection Transfer Statistics                                           }
{                                                                              }

// Reset transfer statistics
procedure TCPConnectionTransferReset(var State: TTCPConnectionTransferState);
begin
  State.LastUpdate := TCPGetTick;
  State.ByteCount := 0;
  State.TransferRate := 0;
end;

// Update the transfer's internal state for elapsed time
procedure TCPConnectionTransferUpdate(var State: TTCPConnectionTransferState;
          const CurrentTick: LongWord;
          out Elapsed: Integer);
begin
  Elapsed := TCPTickDelta(State.LastUpdate, CurrentTick);
  Assert(Elapsed >= 0);
  // wait at least 1000ms between updates
  if Elapsed < 1000 then
    exit;
  // update transfer rate
  State.TransferRate := (State.ByteCount * 1000) div Elapsed; // bytes per second
  // scale down
  while Elapsed > 60 do
    begin
      Elapsed := Elapsed div 2;
      State.ByteCount := State.ByteCount div 2;
    end;
  State.LastUpdate := TCPTickDeltaU(LongWord(Elapsed), CurrentTick);
end;

// Returns the number of bytes that can be transferred with this throttle in place
function TCPConnectionTransferThrottledSize(var State: TTCPConnectionTransferState;
         const CurrentTick: LongWord;
         const MaxTransferRate: Integer;
         const BufferSize: Integer): Integer;
var Elapsed, Quota, QuotaFree : Integer;
begin
  Assert(MaxTransferRate > 0);
  TCPConnectionTransferUpdate(State, CurrentTick, Elapsed);
  Quota := ((Elapsed + 30) * MaxTransferRate) div 1000; // quota allowed over Elapsed period
  QuotaFree := Quota - State.ByteCount;                 // quota remaining
  if QuotaFree >= BufferSize then
    Result := BufferSize else
  if QuotaFree <= 0 then
    Result := 0
  else
    Result := QuotaFree;
end;

// Updates transfer statistics for a number of bytes transferred
procedure TCPConnectionTransferredBytes(var State: TTCPConnectionTransferState;
          const ByteCount: Integer); {$IFDEF UseInline}inline;{$ENDIF}
begin
  Inc(State.ByteCount, ByteCount);
end;



{                                                                              }
{ TCP Connection                                                               }
{                                                                              }
constructor TTCPConnection.Create(const Socket: TSysSocket);
begin
  Assert(Assigned(Socket));
  inherited Create;
  FSocket := Socket;
  Init;
end;

destructor TTCPConnection.Destroy;
begin
  TCPBufferFinalise(FWriteBuffer);
  TCPBufferFinalise(FReadBuffer);
  FreeAndNil(FProxyList);
  FreeAndNil(FLock);
  inherited Destroy;
end;

procedure TTCPConnection.Init;
begin
  FState := cnsInit;
  FReadBufferMaxSize  := TCP_BUFFER_DEFAULTMAXSIZE;
  FWriteBufferMaxSize := TCP_BUFFER_DEFAULTMAXSIZE;
  FReadThrottle  := False;
  FWriteThrottle := False;
  FLock := TCriticalSection.Create;
  FProxyList := TTCPConnectionProxyList.Create;
  FProxyConnection := False;
  TCPBufferInitialise(FReadBuffer,  FReadBufferMaxSize,  TCP_BUFFER_DEFAULTBUFSIZE);
  TCPBufferInitialise(FWriteBuffer, FWriteBufferMaxSize, TCP_BUFFER_DEFAULTBUFSIZE);
end;

procedure TTCPConnection.Lock;
begin
  if Assigned(FLock) then
    FLock.Acquire;
end;

procedure TTCPConnection.Unlock;
begin
  if Assigned(FLock) then
    FLock.Release;
end;

procedure TTCPConnection.Log(const LogType: TTCPLogType; const LogMsg: String; const LogLevel: Integer);
begin
  if Assigned(FOnLog) then
    FOnLog(self, LogType, LogMsg, LogLevel);
end;

procedure TTCPConnection.Log(const LogType: TTCPLogType; const LogMsg: String; const LogArgs: array of const; const LogLevel: Integer);
begin
  Log(LogType, Format(LogMsg, LogArgs), LogLevel);
end;

function TTCPConnection.GetState: TTCPConnectionState;
begin
  Lock;
  try
    Result := FState;
  finally
    Unlock;
  end;
end;

function TTCPConnection.GetStateStr: RawByteString;
begin
  Result := SConnectionState[GetState];
end;

procedure TTCPConnection.SetState(const State: TTCPConnectionState);
begin
  {$IFDEF TCP_DEBUG}
  Log(tlDebug, 'State:%s', [SConnectionState[State]]);
  {$ENDIF}
  Lock;
  try
    Assert(State <> FState);
    FState := State;
  finally
    Unlock;
  end;
  if Assigned(FOnStateChange) then
    FOnStateChange(self, State);
end;

procedure TTCPConnection.SetClosed;
begin
  if FState = cnsClosed then
    exit;
  SetState(cnsClosed);
  TriggerClose;
end;

procedure TTCPConnection.AddProxy(const Proxy: TTCPConnectionProxy);
var P : TTCPConnectionProxy;
    DoNeg : Boolean;
begin
  {$IFDEF TCP_DEBUG}
  Log(tlDebug, 'AddProxy:%s', [Proxy.ProxyName]);
  {$ENDIF}

  if not Assigned(Proxy) then
    raise ETCPConnection.Create(SError_InvalidParameter);
  Lock;
  try
    // add to list
    P := FProxyList.LastItem;
    FProxyList.Add(Proxy);
    if Assigned(P) then
      P.FNextProxy := Proxy;
    Proxy.FNextProxy := nil;
    FProxyConnection := True;
    // restart negotiation if connected
    DoNeg := (FState = cnsConnected);
  finally
    Unlock;
  end;
  if DoNeg then
    begin
      SetState(cnsProxyNegotiation);
      Proxy.Start;
    end;
end;

procedure TTCPConnection.SetReadBufferMaxSize(const ReadBufferMaxSize: Integer);
begin
  Lock;
  try
    FReadBufferMaxSize := ReadBufferMaxSize;
    TCPBufferSetMaxSize(FReadBuffer, ReadBufferMaxSize);
  finally
    Unlock;
  end;
end;

procedure TTCPConnection.SetWriteBufferMaxSize(const WriteBufferMaxSize: Integer);
begin
  Lock;
  try
    FWriteBufferMaxSize := WriteBufferMaxSize;
    TCPBufferSetMaxSize(FWriteBuffer, WriteBufferMaxSize);
  finally
    Unlock;
  end;
end;

procedure TTCPConnection.SetReadThrottle(const ReadThrottle: Boolean);
begin
  if FReadThrottle = ReadThrottle then
    exit;
  FReadThrottle := ReadThrottle;
end;

procedure TTCPConnection.SetWriteThrottle(const WriteThrottle: Boolean);
begin
  if FWriteThrottle = WriteThrottle then
    exit;
  FWriteThrottle := WriteThrottle;
end;

function TTCPConnection.GetReadRate: Integer;
var E : Integer;
begin
  Lock;
  try
    if not FReadThrottle then
      TCPConnectionTransferUpdate(FReadTransferState, TCPGetTick, E);
    Result := FReadTransferState.TransferRate;
  finally
    Unlock;
  end;
end;

function TTCPConnection.GetWriteRate: Integer;
var E : Integer;
begin
  Lock;
  try
    if not FWriteThrottle then
      TCPConnectionTransferUpdate(FWriteTransferState, TCPGetTick, E);
    Result := FWriteTransferState.TransferRate;
  finally
    Unlock;
  end;
end;

function TTCPConnection.GetReadBufferSize: Integer;
begin
  Lock;
  try
    Result := FReadBuffer.Used;
  finally
    Unlock;
  end;
end;

function TTCPConnection.GetWriteBufferSize: Integer;
begin
  Lock;
  try
    Result := FWriteBuffer.Used;
  finally
    Unlock;
  end;
end;

procedure TTCPConnection.TriggerRead;
begin
  if Assigned(FOnRead) then
    FOnRead(self);
end;

procedure TTCPConnection.TriggerWrite;
begin
  if Assigned(FOnWrite) then
    FOnWrite(self);
end;

procedure TTCPConnection.TriggerClose;
begin
  if Assigned(FOnClose) then
    FOnClose(self);
end;

procedure TTCPConnection.TriggerReadBufferFull;
begin
  if Assigned(FOnReadBufferFull) then
    FOnReadBufferFull(self);
end;

procedure TTCPConnection.TriggerWriteBufferEmpty;
begin
  if Assigned(FOnWriteBufferEmpty) then
    FOnWriteBufferEmpty(self);
end;

procedure TTCPConnection.ProxyConnectionClose(const Proxy: TTCPConnectionProxy);
begin
  Assert(FProxyConnection);

  // flag close pending; handled outside lock, after read pending
  Lock;
  try
    FClosePending := True;
  finally
    Unlock;
  end;
end;

function TTCPConnection.GetFirstActiveProxy: TTCPConnectionProxy;
var P : TTCPConnectionProxy;
begin
  Lock;
  try
    if FProxyList.Count = 0 then
      P := nil
    else
      P := FProxyList[0];
    while Assigned(P) and not (P.State in [prsNegotiating, prsFiltering]) do
      P := P.FNextProxy;
  finally
    Unlock;
  end;
  Result := P;
end;

procedure TTCPConnection.ProxyProcessReadData(const Buf; const BufSize: Integer; out ReadEventPending: Boolean);
var P : TTCPConnectionProxy;
begin
  Assert(FProxyConnection);
  Assert(FProxyList.Count > 0);

  ReadEventPending := False;
  P := GetFirstActiveProxy;
  if Assigned(P) then
    // pass to first active proxy
    P.ProcessReadData(Buf, BufSize)
  else
    begin
      // no active proxies, add data to read buffer
      Lock;
      try
        FProxyConnection := False;
        TCPBufferAddBuf(FReadBuffer, Buf, BufSize);
      finally
        Unlock;
      end;
      // allow user to read buffered data; flag pending event
      ReadEventPending := True;
    end;
end;

procedure TTCPConnection.ProxyProcessWriteData(const Buf; const BufSize: Integer);
var P : TTCPConnectionProxy;
begin
  Assert(FProxyConnection);
  Assert(FProxyList.Count > 0);

  P := GetFirstActiveProxy;
  if Assigned(P) then
    // pass to first active proxy
    P.ProcessWriteData(Buf, BufSize)
  else
    begin
      // no active proxies, send data
      Lock;      
      try
        FProxyConnection := False;
      finally
        Unlock;
      end;
      WriteToTransport(Buf, BufSize);
    end;
end;

function GetNextFilteringProxy(const Proxy: TTCPConnectionProxy): TTCPConnectionProxy;
var P : TTCPConnectionProxy;
begin
  Assert(Assigned(Proxy));

  P := Proxy.FNextProxy;
  while Assigned(P) and not (P.State = prsFiltering) do
    P := P.FNextProxy;
  Result := P;
end;

procedure TTCPConnection.ProxyConnectionPutReadData(const Proxy: TTCPConnectionProxy; const Buf; const BufSize: Integer);
var P : TTCPConnectionProxy;
begin
  P := GetNextFilteringProxy(Proxy);
  if Assigned(P) then
    // pass along proxy chain
    P.ProcessReadData(Buf, BufSize)
  else
    // last proxy, add to read buffer, regardless of available size
    // reading from socket is throttled in FillBufferFromSocket when read buffer fills up
    begin
      TCPBufferAddBuf(FReadBuffer, Buf, BufSize);
      // allow user to read buffered data; flag pending event
      FReadEventPending := True;
    end;
end;

procedure TTCPConnection.ProxyConnectionPutWriteData(const Proxy: TTCPConnectionProxy; const Buf; const BufSize: Integer);
var P : TTCPConnectionProxy;
begin
  P := GetNextFilteringProxy(Proxy);
  if Assigned(P) then
    // pass along proxy chain
    P.ProcessWriteData(Buf, BufSize)
  else
    // last proxy, add to write buffer, regardless of available size
    WriteToTransport(Buf, BufSize);
end;

procedure TTCPConnection.ProxyLog(const Proxy: TTCPConnectionProxy; const LogType: TTCPLogType; const LogMsg: String; const LogLevel: Integer);
begin
  Assert(Assigned(Proxy));
  {$IFDEF TCP_DEBUG}
  Log(LogType, 'Proxy[%s]:%s', [Proxy.ProxyName, LogMsg], LogLevel + 1);
  {$ENDIF}
end;

// called when a proxy changes state
procedure TTCPConnection.ProxyStateChange(const Proxy: TTCPConnectionProxy; const State: TTCPConnectionProxyState);
var P : TTCPConnectionProxy;
begin
  case State of
    prsFiltering,
    prsFinished :
      begin
        Lock;
        try
          P := Proxy.FNextProxy;
        finally
          Unlock;
        end;
        if Assigned(P) then
          P.Start
        else
          SetState(cnsConnected);
      end;
    prsError,
    prsClosed : ;
    prsNegotiating : ;
  end;
end;

procedure TTCPConnection.StartProxies(out ProxiesFinished: Boolean);
var L : Integer;
    P : TTCPConnectionProxy;
begin
  Lock;
  try
    L := FProxyList.Count;
    if L = 0 then
      begin
        // no proxies
        ProxiesFinished := True;
        exit;
      end;
    P := FProxyList.Item[0];
  finally
    Unlock;
  end;
  // start proxy negotiation
  SetState(cnsProxyNegotiation);
  P.Start;
  ProxiesFinished := False;
end;

procedure TTCPConnection.Start;
var F : Boolean;
begin
  Assert(FState = cnsInit);
  {$IFDEF TCP_DEBUG}
  Log(tlDebug, 'Start');
  {$ENDIF}
  Lock;
  try
    TCPConnectionTransferReset(FReadTransferState);
    TCPConnectionTransferReset(FWriteTransferState);
  finally
    Unlock;
  end;
  StartProxies(F);
  if F then
    SetState(cnsConnected);
end;

// Pre: Socket is non-blocking
function TTCPConnection.FillBufferFromSocket(out RecvClosed, ReadEventPending, ReadBufFullEvent: Boolean): Integer;
const
  BufferSize = TCP_BUFFER_DEFAULTMAXSIZE;
var
  Buffer : array[0..BufferSize - 1] of Byte;
  Avail, Size : Integer;
  IsHandleInvalid : Boolean;
begin
  Result := 0;
  RecvClosed := False;
  ReadEventPending := False;
  ReadBufFullEvent := False;
  Lock;
  try
    // check space available in read buffer
    Avail := TCPBufferAvailable(FReadBuffer);
    if Avail > BufferSize then
      Avail := BufferSize;
    if Avail <= 0 then
      // no space in buffer, don't read any more from socket
      // this will eventually throttle the actual TCP connection when the system's TCP receive buffer fills up
      // Set FReadBufferFull flag, since read event won't trigger again, this function must be called manually
      // next time there's space in the receive buffer
      begin
        if not FReadBufferFull then
          begin
            ReadBufFullEvent := True;
            FReadBufferFull := True;
          end;
        exit;
      end;
    IsHandleInvalid := FSocket.SocketHandleInvalid;
  finally
    Unlock;
  end;
  // receive from socket into local buffer
  if IsHandleInvalid then // socket may have been closed by a proxy while in this loop
    begin
      {$IFDEF TCP_DEBUG}
      Log(tlDebug, 'FillBufferFromSocket:SocketHandleInvalid');
      {$ENDIF}
      RecvClosed := True;
      exit;
    end;
  Size := FSocket.Recv(Buffer, Avail);
  if Size = 0 then
    begin
      {$IFDEF TCP_DEBUG}
      Log(tlDebug, 'FillBufferFromSocket:Close');
      {$ENDIF}
      // socket closed
      RecvClosed := True;
      exit;
    end;
  if Size < 0 then
    // nothing more to receive from socket
    exit;
  {$IFDEF TCP_DEBUG}
  Log(tlDebug, 'FillBufferFromSocket:Received:%db', [Size]);
  {$ENDIF}
  // data received
  Result := Size;
  if FProxyConnection then
    // pass local buffer to proxies to process
    ProxyProcessReadData(Buffer, Size, ReadEventPending)
  else
    // move from local buffer to read buffer
    begin
      Lock;
      try
        TCPBufferAddBuf(FReadBuffer, Buffer, Size);
      finally
        Unlock;
      end;
      // allow user to read buffered data; flag pending event
      ReadEventPending := True;
    end;
end;

// Returns number of bytes written to socket
// Pre: Socket is non-blocking
function TTCPConnection.EmptyBufferToSocket(out BufferEmptyBefore, BufferEmptied: Boolean): Integer;
var P : Pointer;
    SizeBuf, SizeWrite, SizeWritten : Integer;
    E : Boolean;
begin
  BufferEmptied := False;
  Lock;
  try
    SizeBuf := TCPBufferUsed(FWriteBuffer);
    // get write size
    E := SizeBuf <= 0;
    BufferEmptyBefore := E;
    if E then
      SizeWrite := 0
    else
    if FWriteThrottle and (FWriteThrottleRate > 0) then // throttled writing
      SizeWrite := TCPConnectionTransferThrottledSize(FWriteTransferState, TCPGetTick, FWriteThrottleRate, SizeBuf)
    else
      SizeWrite := SizeBuf;
    // handle nothing to send
    if SizeWrite = 0 then
      begin
        Result := 0;
        exit;
      end;
    // get buffer pointer
    P := TCPBufferPtr(FWriteBuffer);
    // send to socket
    Assert(Assigned(P));
    SizeWritten := FSocket.Send(P^, SizeWrite);
    // handle nothing sent
    if SizeWritten = 0 then
      begin
        Result := 0;
        exit;
      end;
    Assert(SizeWritten >= 0);
    // update transfer statistics
    TCPConnectionTransferredBytes(FWriteTransferState, SizeWritten);
    // discard successfully sent bytes from connection buffer
    TCPBufferDiscard(FWriteBuffer, SizeWritten);
  finally
    Unlock;
  end;
  // check if buffer emptied
  if SizeWritten = SizeBuf then
    BufferEmptied := True;
  {$IFDEF TCP_DEBUG}
  Log(tlDebug, 'EmptyBufferToSocket:Fin:%d:%db:%db:%db',
      [Ord(BufferEmptied), SizeBuf, SizeWrite, SizeWritten]);
  {$ENDIF}
  Result := SizeWritten;
end;

// Processes by polling socket events
// Pre: Socket is non-blocking
procedure TTCPConnection.PollSocket(out Idle, Terminated: Boolean);
var Len : Integer;
    Select, ReadSelect, WriteSelect, ErrorSelect, Error, Fin : Boolean;
    ReadSelectPending : Boolean;
    RecvClosed, RecvReadEvent, RecvReadBufFullEvent, RecvCloseNow : Boolean;
    WriteBufEmptyBefore, WriteBufEmptied : Boolean;
    WriteEvent, WriteBufEmptyEvent, WriteShutdownNow : Boolean;
begin
  Assert(FState <> cnsInit);
  Idle := True;
  // handle closed socket
  if FSocket.SocketHandleInvalid then
    begin
      Terminated := True;
      exit;
    end;
  // prepare for select
  Lock;
  try
    // check and reset pending read select
    ReadSelectPending := FReadSelectPending;
    if ReadSelectPending then
      FReadSelectPending := False;
    // only query write if we need to process write related activities
    WriteSelect :=
        FWriteEventPending or
        FShutdownPending or
        not TCPBufferEmpty(FWriteBuffer);
  finally
    Unlock;
  end;
  ReadSelect := True;
  ErrorSelect := True;
  // select
  Error := False;
  try
    Select := FSocket.Select(0, ReadSelect, WriteSelect, ErrorSelect);
  except
    // select error
    Select := False;
    Error := True;
  end;
  // handle select failure
  if Error then
    begin
      // select error
      Terminated := True;
      exit;
    end;
  Terminated := False;
  if not Select then
    exit;
  // set pending read select
  if ReadSelectPending then
    ReadSelect := True;
  // process read
  if ReadSelect then
    begin
      // if not proxy, trigger read to allow user to read directly from socket
      // before buffering
      if not FProxyConnection then
        TriggerRead;
      Fin := False;
      repeat
        // receive data from socket into buffer
        Len := FillBufferFromSocket(RecvClosed, RecvReadEvent, RecvReadBufFullEvent);
        Lock;
        try
          // check pending flags
          if FReadEventPending then
            begin
              RecvReadEvent := True;
              FReadEventPending := False;
            end;
          RecvCloseNow := FClosePending;
          if RecvCloseNow then
            FClosePending := False;
        finally
          Unlock;
        end;
        if Len > 0 then
          begin
            // data received
            Idle := False;
          end else
          begin
            // nothing received
            Fin := True;
          end;
        // perform pending actions
        if RecvReadBufFullEvent then
          TriggerReadBufferFull;
        if RecvReadEvent then
          TriggerRead;
        if RecvCloseNow then
          begin
            Close;
            Fin := True;
          end
        else
          if RecvClosed then
            begin
              // socket closed
              SetClosed;
              Terminated := True;
              Fin := True;
            end;
      until Fin;
    end;
  // process write
  if WriteSelect then
    begin
      WriteEvent := False;
      WriteBufEmptyEvent := False;
      WriteShutdownNow := False;
      Len := EmptyBufferToSocket(WriteBufEmptyBefore, WriteBufEmptied);
      Lock;
      try
        // check write state
        if FWriteEventPending then
          begin
            WriteEvent := True;
            WriteBufEmptyEvent := True;
            FWriteEventPending := False;
          end;
        if WriteBufEmptied then
          WriteBufEmptyEvent := True;
        if WriteBufEmptyBefore and FShutdownPending then
          begin
            WriteShutdownNow := True;
            FShutdownPending := False;
          end;
      finally
        Unlock;
      end;
      if Len > 0 then
        begin
          // data sent
          Idle := False;
          WriteEvent := True;
        end else
        begin
          if Error then
            // socket send error
            Terminated := True;
          // nothing sent
        end;
      // trigger write
      if WriteEvent then
        TriggerWrite;
      // triger write buffer empty
      if WriteBufEmptyEvent then
        TriggerWriteBufferEmpty;
      // pending shutdown
      if WriteShutdownNow then
        DoShutdown;
    end;
end;

// LocateChrInBuffer
// Returns position of Delimiter in buffer
// Returns >= 0 if found in buffer
// Returns -1 if not found in buffer
// MaxSize specifies maximum bytes before delimiter, of -1 for no limit
function TTCPConnection.LocateChrInBuffer(const Delimiter: TRawByteCharSet; const MaxSize: Integer): Integer;
var BufSize : Integer;
    LocLen  : Integer;
    BufPtr  : PAnsiChar;
    I       : Integer;
begin
  if MaxSize = 0 then
    begin
      Result := -1;
      exit;
    end;
  BufSize := FReadBuffer.Used;
  if BufSize <= 0 then
    begin
      Result := -1;
      exit;
    end;
  if MaxSize < 0 then
    LocLen := BufSize
  else
    if BufSize < MaxSize then
      LocLen := BufSize
    else
      LocLen := MaxSize;
  BufPtr := TCPBufferPtr(FReadBuffer);
  for I := 0 to LocLen - 1 do
    if BufPtr^ in Delimiter then
      begin
        Result := I;
        exit;
      end
    else
      Inc(BufPtr);
  Result := -1;
end;

// LocateStrInBuffer
// Returns position of Delimiter in buffer
// Returns >= 0 if found in buffer
// Returns -1 if not found in buffer
// MaxSize specifies maximum bytes before delimiter, of -1 for no limit
function TTCPConnection.LocateStrInBuffer(const Delimiter: RawByteString; const MaxSize: Integer): Integer;
var DelLen  : Integer;
    BufSize : Integer;
    LocLen  : Integer;
    BufPtr  : PAnsiChar;
    DelPtr  : PAnsiChar;
    I       : Integer;
begin
  if MaxSize = 0 then
    begin
      Result := -1;
      exit;
    end;
  DelLen := Length(Delimiter);
  if DelLen = 0 then
    begin
      Result := -1;
      exit;
    end;
  BufSize := FReadBuffer.Used;
  if BufSize < DelLen then
    begin
      Result := -1;
      exit;
    end;
  if MaxSize < 0 then
    LocLen := BufSize
  else
    if BufSize < MaxSize then
      LocLen := BufSize
    else
      LocLen := MaxSize;
  BufPtr := TCPBufferPtr(FReadBuffer);
  DelPtr := PAnsiChar(Delimiter);
  for I := 0 to LocLen - DelLen do
    if TCPCompareMem(BufPtr^, DelPtr^, DelLen) then
      begin
        Result := I;
        exit;
      end
    else
      Inc(BufPtr);
  Result := -1;
end;

// PeekDelimited
// Returns number of bytes transferred to buffer, including delimiter
// Returns -1 if not found in buffer
// Returns >= 0 if found.
// MaxSize specifies maximum bytes before delimiter, of -1 for no limit
function TTCPConnection.PeekDelimited(var Buf; const BufSize: Integer;
         const Delimiter: TRawByteCharSet; const MaxSize: Integer): Integer;
var DelPos : Integer;
    BufPtr : PAnsiChar;
    BufLen : Integer;
begin
  Lock;
  try
    DelPos := LocateChrInBuffer(Delimiter, MaxSize);
    if DelPos >= 0 then
      begin
        // found
        BufPtr := TCPBufferPtr(FReadBuffer);
        BufLen := DelPos + 1;
        if BufLen > BufSize then
          BufLen := BufSize;
        Move(BufPtr^, Buf, BufLen);
        Result := BufLen;
      end
    else
      Result := -1;
  finally
    Unlock;
  end;
end;

// PeekDelimited
// Returns number of bytes transferred to buffer, including delimiter
// Returns -1 if not found in buffer
// Returns >= 0 if found.
// MaxSize specifies maximum bytes before delimiter, of -1 for no limit
function TTCPConnection.PeekDelimited(var Buf; const BufSize: Integer;
         const Delimiter: RawByteString; const MaxSize: Integer): Integer;
var DelPos : Integer;
    BufPtr : PAnsiChar;
    BufLen : Integer;
begin
  Assert(Delimiter <> '');
  Lock;
  try
    DelPos := LocateStrInBuffer(Delimiter, MaxSize);
    if DelPos >= 0 then
      begin
        // found
        BufPtr := TCPBufferPtr(FReadBuffer);
        BufLen := DelPos + Length(Delimiter);
        if BufLen > BufSize then
          BufLen := BufSize;
        Move(BufPtr^, Buf, BufLen);
        Result := BufLen;
      end
    else
      Result := -1;
  finally
    Unlock;
  end;
end;

function TTCPConnection.ReadFromBuffer(var Buf; const BufSize: Integer): Integer;
begin
  Result := TCPBufferRemove(FReadBuffer, Buf, BufSize);
  if Result > 0 then
    if FReadBufferFull then
      begin
        FReadBufferFull := False;
        FReadSelectPending := True;
      end;
end;

function TTCPConnection.ReadFromSocket(var Buf; const BufSize: Integer): Integer;
begin
  Assert(BufSize > 0);

  if FSocket.SocketHandleInvalid then
    begin
      Result := 0;
      exit;
    end;
  Result := FSocket.Recv(Buf, BufSize);
  if Result = 0 then
    SetClosed else
  if Result < 0 then
    Result := 0;
end;

function TTCPConnection.DiscardFromBuffer(const Size: Integer): Integer;
begin
  Result := TCPBufferDiscard(FReadBuffer, Size);
  if Result > 0 then
    if FReadBufferFull then
      begin
        FReadBufferFull := False;
        FReadSelectPending := True;
      end;
end;

function TTCPConnection.Read(var Buf; const BufSize: Integer): Integer;
var
  BufPtr : PAnsiChar;
  SizeRead, SizeReadBuf, SizeReadSocket, SizeRemain, SizeTotal : Integer;
begin
  Lock;
  try
    // get read size
    if BufSize <= 0 then
      SizeRead := 0
    else
    if FReadThrottle then // throttled reading
      SizeRead := TCPConnectionTransferThrottledSize(FReadTransferState, TCPGetTick, FReadThrottleRate, BufSize)
    else
      SizeRead := BufSize;
    // handle nothing to read
    if SizeRead <= 0 then
      begin
        Result := 0;
        exit;
      end;
    // read from buffer
    SizeReadBuf := ReadFromBuffer(Buf, SizeRead);
    if SizeReadBuf = SizeRead then
      // required number of bytes was in buffer
      SizeReadSocket := 0
    else
    if FProxyConnection then
      // don't read directly from socket if this connection has proxies
      SizeReadSocket := 0
    else
      begin
        // calculate remaining bytes to read
        SizeRemain := SizeRead - SizeReadBuf;
        // read from socket
        BufPtr := @Buf;
        Inc(BufPtr, SizeReadBuf);
        SizeReadSocket := ReadFromSocket(BufPtr^, SizeRemain);
      end;
    SizeTotal := SizeReadBuf + SizeReadSocket;
    // update transfer statistics
    TCPConnectionTransferredBytes(FReadTransferState, SizeTotal);
  finally
    Unlock;
  end;
  {$IFDEF TCP_DEBUG}
  Log(tlDebug, 'Read:Fin:%db:%db:%db:%db',
      [BufSize, SizeRead, SizeReadBuf, SizeReadSocket]);
  {$ENDIF}
  // return number of bytes read
  Result := SizeTotal;
end;

function TTCPConnection.ReadStr(const StrLen: Integer): RawByteString;
var ReadLen : Integer;
begin
  if StrLen <= 0 then
    begin
      Result := '';
      exit;
    end;
  SetLength(Result, StrLen);
  ReadLen := Read(Result[1], StrLen);
  if ReadLen < StrLen then
    SetLength(Result, ReadLen);
end;

// Discard a number of bytes from the read buffer
// Returns the number of bytes actually discarded
// Similar to Read; no throttling; no reading directly from socket
function TTCPConnection.Discard(const Size: Integer): Integer;
var SizeDiscarded : Integer;
begin
  // handle nothing to discard
  if Size <= 0 then
    begin
      Result := 0;
      exit;
    end;
  Lock;
  try
    // discard from buffer
    SizeDiscarded := DiscardFromBuffer(Size);
    // update transfer statistics
    TCPConnectionTransferredBytes(FReadTransferState, SizeDiscarded);
  finally
    Unlock;
  end;
  {$IFDEF TCP_DEBUG}
  Log(tlDebug, 'DiscardedFromBuffer:%db:%db', [Size, SizeDiscarded]);
  {$ENDIF}
  // return number of bytes discarded
  Result := SizeDiscarded;
end;

function TTCPConnection.WriteToBuffer(const Buf; const BufSize: Integer): Integer;
begin
  TCPBufferAddBuf(FWriteBuffer, Buf, BufSize);
  Result := BufSize;
end;

function TTCPConnection.WriteToSocket(const Buf; const BufSize: Integer): Integer;
var L : Integer;
begin
  Assert(BufSize > 0);
  L := FSocket.Send(Buf, BufSize);
  // update transfer statistics
  TCPConnectionTransferredBytes(FWriteTransferState, L);
  // return number of bytes sent to socket
  Result := L;
end;

function TTCPConnection.WriteToTransport(const Buf; const BufSize: Integer): Integer;
var L : Integer;
    P : PAnsiChar;
    B : Boolean;
begin
  Result := 0;
  if BufSize <= 0 then
    exit;
  // if there is already data in the write buffer then add to the write buffer; or
  // if write is being throttled then add to the write buffer
  Lock;
  try
    B := (TCPBufferUsed(FWriteBuffer) > 0) or FWriteThrottle;
    if B then
      Result := WriteToBuffer(Buf, BufSize);
  finally
    Unlock;
  end;
  if B then
    begin
      {$IFDEF TCP_DEBUG}
      Log(tlDebug, 'WriteToTransport:WrittenToBuffer:%db:%db', [BufSize, Result]);
      {$ENDIF}
    end
  else
    begin
      // send the data directly to the socket
      Lock;
      try
        L := WriteToSocket(Buf, BufSize);
        if L < BufSize then
          begin
            // add the data not sent to the socket to the write buffer
            P := @Buf;
            Inc(P, L);
            WriteToBuffer(P^, BufSize - L);
          end
        else
          FWriteEventPending := True; // all data sent directly to socket
      finally
        Unlock;
      end;
      {$IFDEF TCP_DEBUG}
      Log(tlDebug, 'WriteToTransport:WrittenToSocketAndBuffer:%db:%db:%db', [BufSize, L, BufSize - L]);
      {$ENDIF}
      Result := BufSize;
    end;
end;

function TTCPConnection.Write(const Buf; const BufSize: Integer): Integer;
var IsProxy : Boolean;
begin
  if BufSize <= 0 then
    begin
      Result := 0;
      exit;
    end;
  Lock;
  try
    // if this connection has proxies then pass the data to the proxies
    IsProxy := FProxyConnection;
  finally
    Unlock;
  end;
  if IsProxy then
    begin
      ProxyProcessWriteData(Buf, BufSize);
      Result := BufSize;
    end
  else
    // send data to socket
    Result := WriteToTransport(Buf, BufSize);
  Assert(Result = BufSize);
end;

function TTCPConnection.WriteStrA(const Str: RawByteString): Integer;
var StrLen : Integer;
begin
  StrLen := Length(Str);
  if StrLen <= 0 then
    begin
      Result := 0;
      exit;
    end;
  Result := Write(Str[1], StrLen);
end;

function TTCPConnection.WriteStrW(const Str: WideString): Integer;
var StrLen : Integer;
begin
  StrLen := Length(Str);
  if StrLen <= 0 then
    begin
      Result := 0;
      exit;
    end;
  Result := Write(Str[1], StrLen * SizeOf(WideChar));
end;

function TTCPConnection.WriteStr(const Str: String): Integer;
begin
  {$IFDEF StringIsUnicode}
  Result := WriteStrA(UTF8Encode(Str));
  {$ELSE}
  Result := WriteStrA(Str);
  {$ENDIF}
end;

function TTCPConnection.Peek(var Buf; const BufSize: Integer): Integer;
begin
  Lock;
  try
    Result := TCPBufferPeek(FReadBuffer, Buf, BufSize);
  finally
    Unlock;
  end;
end;

function TTCPConnection.PeekByte(out B: Byte): Boolean;
begin
  Lock;
  try
    Result := TCPBufferPeekByte(FReadBuffer, B);
  finally
    Unlock;
  end;
end;

function TTCPConnection.PeekStr(const StrLen: Integer): RawByteString;
var PeekLen : Integer;
begin
  if StrLen <= 0 then
    begin
      Result := '';
      exit;
    end;
  SetLength(Result, StrLen);
  PeekLen := Peek(Result[1], StrLen);
  if PeekLen < StrLen then
    SetLength(Result, PeekLen);
end;

// Reads a line delimited by specified Delimiter
// MaxLineLength is maximum line length excluding the delimiter
// Returns False if line not available
// Returns True if line read
function TTCPConnection.ReadLine(var Line: RawByteString; const Delimiter: RawByteString; const MaxLineLength: Integer): Boolean;
var
  DelPos : Integer;
  DelLen : Integer;
begin
  Assert(Delimiter <> '');
  Lock;
  try
    DelPos := LocateStrInBuffer(Delimiter, MaxLineLength);
    Result := DelPos >= 0;
    if not Result then
      exit;
    SetLength(Line, DelPos);
    if DelPos > 0 then
      Read(PAnsiChar(Line)^, DelPos);
    DelLen := Length(Delimiter);
    Discard(DelLen);
  finally
    Unlock;
  end;
end;

procedure TTCPConnection.Close;
begin
  {$IFDEF TCP_DEBUG}
  Log(tlDebug, 'Close:%db:%db', [GetReadBufferSize, GetWriteBufferSize]);
  {$ENDIF}
  if GetState = cnsClosed then
    exit;
  SetClosed;
  FSocket.Close;
end;

procedure TTCPConnection.DoShutdown;
begin
  {$IFDEF TCP_DEBUG}
  Log(tlDebug, 'DoShutDown:%db:%db', [GetReadBufferSize, GetWriteBufferSize]);
  {$ENDIF}
  // Sends TCP FIN message to close connection and
  // disallow any further sending on the socket
  FSocket.Shutdown(ssSend);
end;

procedure TTCPConnection.Shutdown;
var ShutdownNow : Boolean;
begin
  {$IFDEF TCP_DEBUG}
  Log(tlDebug, 'ShutDown:%db:%db', [GetReadBufferSize, GetWriteBufferSize]);
  {$ENDIF}
  Lock;
  try
    ShutdownNow := False;
    if TCPBufferUsed(FWriteBuffer) > 0 then
      // defer shutdown until write buffer is emptied to socket
      FShutdownPending := True
    else
      ShutdownNow := True;
  finally
    Unlock;
  end;
  if ShutdownNow then
    DoShutDown;
end;



end.


