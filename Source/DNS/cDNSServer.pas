{******************************************************************************}
{                                                                              }
{   Library:          Fundamentals 4.00                                        }
{   File name:        cDNSServer.pas                                           }
{   File version:     1.01                                                     }
{   Description:      DNS Server                                               }
{                                                                              }
{   Copyright:        Copyright (c) 2003-2015, David J Butler                  }
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
{   Source:           https://github.com/fundamentalslib                       }
{                                                                              }
{  Revision history:                                                           }
{    19/09/2003  1.00  Initial version.                                        }
{    25/02/2015  1.01  Revision.                                               }
{                                                                              }
{******************************************************************************}

{$INCLUDE cDNS.inc}

unit cDNSServer;

interface

uses
  { System }
  SysUtils,
  Classes,
  SyncObjs,

  { Fundamentals }
  cUtils,
  cSocketLib,
  cSocket,

  { DNS }
  cDNSUtils;



{                                                                              }
{ TdnsUDPServer                                                                }
{                                                                              }
type
  TdnsLogType = (
    dltDebug,
    dltInfo,
    dltError
    );

  TdnsUDPServer = class;

  TdnsUDPServerThread = class(TThread)
  protected
    FServer : TdnsUDPServer;
    procedure Execute; override;
  public
    constructor Create(const Server: TdnsUDPServer);
  end;

  TdnsUDPServerLogEvent = procedure (Sender: TdnsUDPServer;
      LogType: TdnsLogType; Msg: String; Level: Integer) of object;

  TdnsUDPServerPacketError = procedure (Sender: TdnsUDPServer;
      PacketError: String) of object;

  TdnsUDPServerQueryEvent = procedure (Sender: TdnsUDPServer;
      const MessageBuf; MessageBufSize: Integer;
      Address: TIP4Addr; Port: Integer;
      Header: TdnsMessageHeader;
      Attr: TdnsHeaderAttrInfo;
      Questions: TdnsQuestionInfoArray) of object;

  TdnsUDPServer = class
  protected
    FOnLog         : TdnsUDPServerLogEvent;
    FOnPacketError : TdnsUDPServerPacketError;
    FOnQuery       : TdnsUDPServerQueryEvent;

    FBindAddress   : RawByteString;

    FLock       : TCriticalSection;
    FUDP        : TSysSocket;
    FThread     : TThread;
    FActive     : Boolean;
    FTerminated : Boolean;

    procedure Init; virtual;

    procedure Lock;
    procedure Unlock;

    procedure Log(const LogType: TdnsLogType; const Msg: String; const Level: Integer = 0); overload;
    procedure Log(const LogType: TdnsLogType; const Msg: String; const Args: array of const; const Level: Integer = 0); overload;

    procedure SetTerminated(const Terminated: Boolean);

    procedure UDPLog(Sender: TSysSocket; LogType: TSysSocketLogType; Msg: String);

    procedure TriggerPacketError(const PacketError: String); virtual;
    procedure TriggerQuery(
              const MessageBuf; const MessageBufSize: Integer;
              const Address: TIP4Addr; const Port: Integer;
              const Header: TdnsMessageHeader;
              const Attr: TdnsHeaderAttrInfo;
              const Questions: TdnsQuestionInfoArray); virtual;
    procedure TriggerIdle;

    procedure StartUDP;
    procedure StopUDP;
    procedure Execute(const Thread: TdnsUDPServerThread);

    procedure DoStart;
    procedure DoStop;

  public
    constructor Create;
    destructor Destroy; override;

    property  OnLog: TdnsUDPServerLogEvent read FOnLog write FOnLog;
    property  OnPacketError: TdnsUDPServerPacketError read FOnPacketError write FOnPacketError;
    property  OnQuery: TdnsUDPServerQueryEvent read FOnQuery write FOnQuery;

    property  BindAddress: RawByteString read FBindAddress write FBindAddress;

    procedure Start;
    procedure Stop;
    property  Active: Boolean read FActive;
  end;



implementation



{                                                                              }
{ TdnsUDPServerThread                                                          }
{                                                                              }

constructor TdnsUDPServerThread.Create(const Server: TdnsUDPServer);
begin
  Assert(Assigned(Server));
  FServer := Server;
  FreeOnTerminate := False;
  inherited Create(False);
end;

procedure TdnsUDPServerThread.Execute;
begin
  Assert(Assigned(FServer));
  FServer.Execute(self);
end;



{                                                                              }
{ TdnsUDPServer                                                                }
{                                                                              }

constructor TdnsUDPServer.Create;
begin
  inherited Create;
  Init;
end;

destructor TdnsUDPServer.Destroy;
begin
  FreeAndNil(FLock);
  inherited Destroy;
end;

procedure TdnsUDPServer.Init;
begin
  FLock := TCriticalSection.Create;
  FActive := False;
  FTerminated := False;
  FBindAddress := '0.0.0.0';
end;

procedure TdnsUDPServer.Lock;
begin
  Assert(Assigned(FLock));
  FLock.Acquire;
end;

procedure TdnsUDPServer.Unlock;
begin
  Assert(Assigned(FLock));
  FLock.Release;
end;

procedure TdnsUDPServer.Log(const LogType: TdnsLogType; const Msg: String; const Level: Integer);
begin
  if Assigned(FOnLog) then
    FOnLog(self, LogType, Msg, Level);
end;

procedure TdnsUDPServer.Log(const LogType: TdnsLogType; const Msg: String; const Args: array of const; const Level: Integer);
begin
  Log(LogType, Format(Msg, Args), Level);
end;

procedure TdnsUDPServer.SetTerminated(const Terminated: Boolean);
begin
  FTerminated := Terminated;
end;

procedure TdnsUDPServer.UDPLog(Sender: TSysSocket; LogType: TSysSocketLogType;
  Msg: String);
begin
  Log(dltDebug, 'UDP:%s', [Msg], 1);
end;

procedure TdnsUDPServer.TriggerPacketError(const PacketError: String);
begin
  Log(dltError, 'PacketError:%s', [PacketError]);

  if Assigned(FOnPacketError) then
    FOnPacketError(self, PacketError);
end;

procedure TdnsUDPServer.TriggerQuery(
          const MessageBuf; const MessageBufSize: Integer;
          const Address: TIP4Addr; const Port: Integer;
          const Header: TdnsMessageHeader;
          const Attr: TdnsHeaderAttrInfo;
          const Questions: TdnsQuestionInfoArray);
begin
  Log(dltDebug, 'DNSQuery:%s:%d:%db', [IP4AddressStr(Address), Port, MessageBufSize]);

  if Assigned(FOnQuery) then
    FOnQuery(self, MessageBuf, MessageBufSize, Address, Port,
        Header, Attr, Questions);
end;

procedure TdnsUDPServer.TriggerIdle;
begin
  Sleep(1);
end;

const
  DNSUDPSERVER_MaxPacketSize = DNS_MaxRawRequestSize;

procedure TdnsUDPServer.StartUDP;
begin
  Log(dltInfo, 'StartUDP');

  try
    Assert(not Assigned(FUDP));
    FUDP := TSysSocket.Create(iaIP4, ipUDP);
    FUDP.OnLog := UDPLog;
    FUDP.Bind(FBindAddress, DNS_DefaultPortStr);
  except
    on E : Exception do
      begin
        Log(dltError, 'StartUDP:Error:%s', [E.Message]);
        FreeAndNil(FUDP);
        raise;
      end;
  end;
end;

procedure TdnsUDPServer.StopUDP;
begin
  Log(dltInfo, 'StopUDP');

  Assert(Assigned(FUDP));
  FUDP.Close;
  FreeAndNil(FUDP);
end;

procedure TdnsUDPServer.Execute(const Thread: TdnsUDPServerThread);
var
  RecvBuffer  : array[0..DNSUDPSERVER_MaxPacketSize] of Byte;
  RecvSize    : Integer;
  RecvAddress : TSocketAddr;
  Truncated   : Boolean;
  PacketValid : Boolean;
  PacketError : String;
  Header      : TdnsMessageHeader;
  Questions   : TdnsQuestionInfoArray;
  Attr        : TdnsHeaderAttrInfo;

  function IsTerminated: Boolean;
  begin
    Result :=
      FTerminated or
      Thread.Terminated;
  end;

begin
  if IsTerminated then
    exit;
  StartUDP;
  try
    if IsTerminated then
      exit;
    FUDP.SetBlocking(False);
    while not IsTerminated do
      begin
        RecvSize := FUDP.RecvFromEx(
            RecvBuffer[0], DNSUDPSERVER_MaxPacketSize,
            RecvAddress, Truncated);
        if IsTerminated then
          break;
        Assert(RecvSize <= DNSUDPSERVER_MaxPacketSize);
        if RecvSize <= 0 then
          TriggerIdle
        else
          begin
            PacketValid := True;
            PacketError := '';
            try
              DNS_DecodeQuery(RecvBuffer[0], RecvSize, Header, Questions);
              DNS_DecodeHeaderAttr(Header.Attr, Attr);
            except
              on E: Exception do
                begin
                  PacketValid := False;
                  PacketError := E.Message;
                end;
            end;
            try
              if not PacketValid then
                begin
                  Log(dltError, 'Decode:Error:%s', [PacketError]);
                  TriggerPacketError(PacketError);
                end
              else
                TriggerQuery(
                    RecvBuffer[0], RecvSize,
                    RecvAddress.AddrIP4, RecvAddress.Port,
                    Header, Attr, Questions)
            except
              on E: Exception do
                Log(dltError, 'Trigger:Error:%s', [E.Message]);
            end;
          end;
      end;
  finally
    StopUDP;
  end;
end;

procedure TdnsUDPServer.DoStart;
begin
  Assert(not Assigned(FThread));

  FThread := TdnsUDPServerThread.Create(self);
  FActive := True;
end;

procedure TdnsUDPServer.DoStop;
begin
  Assert(FActive);
  Assert(Assigned(FThread));

  SetTerminated(True);
  FThread.Terminate;
  FActive := False;
  FreeAndNil(FThread);
end;

procedure TdnsUDPServer.Start;
begin
  if FActive then
    exit;
  Log(dltInfo, 'dnsUDPServer:Start');
  DoStart;
  Log(dltInfo, 'dnsUDPServer:Started');
end;

procedure TdnsUDPServer.Stop;
begin
  if not FActive then
    exit;
  Log(dltInfo, 'dnsUDPServer:Stop');
  DoStop;
  Log(dltInfo, 'dnsUDPServer:Stopped');
end;



end.

