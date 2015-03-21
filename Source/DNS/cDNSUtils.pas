{******************************************************************************}
{                                                                              }
{   Library:          Fundamentals 4.00                                        }
{   File name:        cDNSUtils.pas                                            }
{   File version:     1.05                                                     }
{   Description:      General constants, structures, types and functions       }
{                     for DNS (Domain Name Service) implementations.           }
{                                                                              }
{   Copyright:        Copyright (c) 2001-2015, David J Butler                  }
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
{  Documentation:                                                              }
{    See RFC 1035                                                              }
{                                                                              }
{  Revision history:                                                           }
{                                                                              }
{    2001/02/09  1.00  Initial version.                                        }
{    2002/08/25  1.01  Revised.                                                }
{    2003/08/22  1.02  Revised.                                                }
{    2003/09/19  1.03  Server functions.                                       }
{    2009/12/04  1.04  Revised.                                                }
{    2015/03/14  1.05  Revised.                                                }
{                                                                              }
{******************************************************************************}

{$INCLUDE cDNS.inc}

unit cDNSUtils;

interface

uses
  { System }
  SysUtils,

  { Fundamentals }
  cUtils,
  cWinSock,
  cSocketLib;



{                                                                              }
{ DNS constants                                                                }
{                                                                              }
const
  DNS_DefaultPort        = 53;
  DNS_DefaultPortStr     = '53';
  DNS_MaxLabelSize       = 63;
  DNS_MaxNameSize        = 255;
  DNS_MaxUDPPacketSize   = 512;
  DNS_MaxRawRequestSize  = 1024;
  DNS_MaxRawResponseSize = 2048;



{                                                                              }
{ Error codes                                                                  }
{                                                                              }
const
  DNSE_None                    = 0;
  DNSE_Base                    = 10000;
  DNSE_Top                     = 19999;

  // Internal errors
  DNSE_InternalError           = DNSE_Base + 100;

  // Invalid parameter errors
  DNSE_InvalidParameter        = DNSE_Base + 200;
  DNSE_InvalidBuffer           = DNSE_Base + 201;
  DNSE_BufferOverflow          = DNSE_Base + 202;
  DNSE_DomainNameTooLong       = DNSE_Base + 203;
  DNSE_DomainLabelTooLong      = DNSE_Base + 204;
  DNSE_StringTooLong           = DNSE_Base + 205;
  DNSE_InvalidOpCode           = DNSE_Base + 206;

  // Error responses from server
  DNSE_ServerErrorResponse     = DNSE_Base + 300;
  DNSE_Response_FormatError    = DNSE_Base + 301;
  DNSE_Response_ServerFailure  = DNSE_Base + 302;
  DNSE_Response_NameError      = DNSE_Base + 303;
  DNSE_Response_NotImplemented = DNSE_Base + 304;
  DNSE_Response_Refused        = DNSE_Base + 305;
  DNSE_Response_NameExists     = DNSE_Base + 306;
  DNSE_Response_RRSetExists    = DNSE_Base + 307;
  DNSE_Response_RRSetNotExist  = DNSE_Base + 308;
  DNSE_Response_NotAuthorised  = DNSE_Base + 309;
  DNSE_Response_NotZone        = DNSE_Base + 310;

  // Lookup errors
  DNSE_LookupError             = DNSE_Base + 400;
  DNSE_LookupTimeOut           = DNSE_Base + 401;

function  DNS_ErrorString(const ErrorCode: Integer): String;



{                                                                              }
{ Exception                                                                    }
{                                                                              }
type
  EdnsError = class(Exception)
  protected
    FErrorCode : Integer;
  public
    constructor Create(const ErrorCode: Integer; const Msg: String = '');
    property ErrorCode: Integer read FErrorCode;
  end;



{                                                                              }
{ Header OPCODE field                                                          }
{                                                                              }
{    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+                         }
{    |  |   Opcode  |                                |                         }
{    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+                         }
{                                                                              }
const
  DNS_OPCODE_QUERY  = 0;
  DNS_OPCODE_IQUERY = 1;
  DNS_OPCODE_STATUS = 2;

type
  TdnsOperation = (
      dopQuery,
      dopInverseQuery,
      dopServerStatus);

function  DNS_EncodeOpCode(const Operation: TdnsOperation): Byte;
function  DNS_DecodeOpCode(const OpCode: Byte): TdnsOperation;



{                                                                              }
{ Header RCODE field                                                           }
{                                                                              }
{    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+                         }
{    |                                   |   RCODE   |                         }
{    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+                         }
{                                                                              }
const
  DNS_RCODE_NoError        = 0;
  DNS_RCODE_FormatError    = 1;
  DNS_RCODE_ServerFailure  = 2;
  DNS_RCODE_NameError      = 3;
  DNS_RCODE_NotImplemented = 4;
  DNS_RCODE_Refused        = 5;
  DNS_RCODE_NameExists     = 6;
  DNS_RCODE_RRSetExists    = 7;
  DNS_RCODE_RRSetNotExist  = 8;
  DNS_RCODE_NotAuthorised  = 9;
  DNS_RCODE_NotZone        = 10;



{                                                                              }
{ Header ATTR field                                                            }
{                                                                              }
{    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+                         }
{    |QR|   Opcode  |AA|TC|RD|RA|   Z    |   RCODE   |                         }
{    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+                         }
{                                                                              }
type
  TdnsHeaderAttrInfo = record
    Query              : Boolean;
    Operation          : TdnsOperation;
    Authorative        : Boolean;
    Truncated          : Boolean;
    RecursionDesired   : Boolean;
    RecursionAvailable : Boolean;
    ResponseCode       : Byte;
  end;

function  DNS_EncodeHeaderAttr(
          const Query: Boolean; const Operation: TdnsOperation;
          const Authoritative, Truncated, RecursionDesired, RecursionAvailable: Boolean;
          const ResponseCode: Byte): Word;
function  DNS_EncodeHeaderAttr_Query(
          const Operation: TdnsOperation;
          const RecursionDesired: Boolean): Word;
function  DNS_EncodeHeaderAttr_Response(
          const Attr: Word; const ResponseCode: Byte;
          const Authorative, RecursionAvailable: Boolean): Word;
procedure DNS_DecodeHeaderAttr(
          const Attr: Word; out Info: TdnsHeaderAttrInfo);



{                                                                              }
{ Message Header                                                               }
{                                                                              }
{    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+                         }
{    |                      ID                       |                         }
{    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+                         }
{    |QR|   Opcode  |AA|TC|RD|RA|   Z    |   RCODE   |                         }
{    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+                         }
{    |                    QDCOUNT                    |                         }
{    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+                         }
{    |                    ANCOUNT                    |                         }
{    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+                         }
{    |                    NSCOUNT                    |                         }
{    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+                         }
{    |                    ARCOUNT                    |                         }
{    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+                         }
{                                                                              }
type
  TdnsMessageHeader = packed record
    ID      : Word;
    Attr    : Word;
    QDCount : Word;  // Questions
    ANCount : Word;  // Answers
    NSCount : Word;  // Name Server records
    ARCount : Word;  // Additional records
  end;
  PdnsMessageHeader = ^TdnsMessageHeader;

const
  DNS_MessageHeaderSize = Sizeof(TdnsMessageHeader);

function  DNS_EncodeHeader_Query(
          var Buf; const BufSize: Integer;
          const ID: Word; const Operation: TdnsOperation;
          const RecursionDesired: Boolean;
          const QuestionCount: Word): Integer;
function  DNS_EncodeHeader_Response(
          var Buf; const BufSize: Integer;
          const Header: TdnsMessageHeader): Integer;
function  DNS_DecodeHeader_Query(
          const Buf; const BufSize: Integer;
          out Header: TdnsMessageHeader): Integer;



{                                                                              }
{ TYPE field                                                                   }
{                                                                              }
const
  // RFC 1035
  DNS_TYPE_A       = 1;   // Address
  DNS_TYPE_NS      = 2;   // Authoritative Name Server
  DNS_TYPE_MD      = 3;   // Mail Destination (obsolete)
  DNS_TYPE_MF      = 4;   // Mail Forwarder (obsolete)
  DNS_TYPE_CNAME   = 5;   // Canonical Name for an alias
  DNS_TYPE_SOA     = 6;   // Start Of a zone Authority
  DNS_TYPE_MB      = 7;   // Mailbox domain name (experimental)
  DNS_TYPE_MG      = 8;   // Mail group member (experimental)
  DNS_TYPE_MR      = 9;   // Mail rename domain name (experimental)
  DNS_TYPE_NULL    = 10;  // Null RR (experimental)
  DNS_TYPE_WKS     = 11;  // Well Known Service description
  DNS_TYPE_PTR     = 12;  // Domain Name Pointer
  DNS_TYPE_HINFO   = 13;  // Host information
  DNS_TYPE_MINFO   = 14;  // Mailbox of mail list information
  DNS_TYPE_MX      = 15;  // Mail Exchange
  DNS_TYPE_TXT     = 16;  // Text strings
  // RFC 1183
  DNS_TYPE_RP      = 17;  // The Responsible Person RR
  DNS_TYPE_AFSDB   = 18;  // AFS Data Base location
  DNS_TYPE_X25     = 19;  // X.25 routing (experimental)
  DNS_TYPE_ISDN    = 20;  // ISDN routing (experimental)
  DNS_TYPE_RT      = 21;  // Route Through
  // RFC 1706
  DNS_TYPE_NSAP    = 22;  // NSAP to DNS mapping
  DNS_TYPE_NSAPPTR = 23;
  // RFC 2065
  DNS_TYPE_SIG     = 24;  // Signature
  DNS_TYPE_KEY     = 25;  // Public key
  DNS_TYPE_NXT     = 30;  // Next name
  //
  DNS_TYPE_PX      = 26;
  // RFC 1712
  DNS_TYPE_GPOS    = 27;  // Geographical information
  //
  DNS_TYPE_AAAA    = 28;
  // RFC 1876
  DNS_TYPE_LOC     = 29;  // Location information
  // RFC 2052
  DNS_TYPE_SRV     = 33;  // Server information
  // RFC 2168
  DNS_TYPE_NAPTR   = 35;
  // RFC 2230
  DNS_TYPE_KX      = 36;  // Key Exchanger
  // Query
  DNS_QTYPE_AXFR   = 252; // Request for a transfer of an entire zone
  DNS_QTYPE_MAILB  = 253; // Request for mailbox-related records (MB, MG or MR)
  DNS_QTYPE_MAILA  = 254; // Request for mail agent RRs (Obsolete - see MX)
  DNS_QTYPE_ALL    = 255; // Request for all records

type
  TdnsQueryType = (
      dqtA,         // a host address
      dqtNS,        // an authoritative name server
      dqtCNAME,     // the canonical name for an alias
      dqtWKS,       // a well known service description
      dqtPTR,       // a domain name pointer
      dqtHINFO,     // host information
      dqtMX,        // mail exchange
      dqtTXT,       // text strings
      dqtAXFR,      // a request for a transfer of an entire zone
      dqtAll);      // a request for all records

function  DNS_RecordTypeStr(const RecordType: Word): RawByteString;
function  DNS_EncodeQueryType(const QueryRecordType: TdnsQueryType): Word;
function  DNS_DecodeQueryType(const QueryRecordType: Word): TdnsQueryType;



{                                                                              }
{ CLASS field                                                                  }
{                                                                              }
const
  DNS_CLASS_IN   = 1;   // Internet
  DNS_CLASS_CS   = 2;   // CSNET (obsolete)
  DNS_CLASS_CH   = 3;   // CHAOS
  DNS_CLASS_HS   = 4;   // Hesiod
  // Query
  DNS_QCLASS_ANY = 255; // Any class



{                                                                              }
{ Character String field                                                       }
{                                                                              }
function  DNS_DecodeString(const Buf; const BufSize: Integer; var Str: RawByteString): Integer;
function  DNS_EncodeString(const Buf; const BufSize: Integer; const S: RawByteString): Integer;



{                                                                              }
{ NAME field                                                                   }
{                                                                              }
type
  TdnsNameString = RawByteString;

function  DNS_EncodeName(var Buf; const BufSize: Integer; const Name: TdnsNameString): Integer;
function  DNS_DecodeName(const MsgBuf; const MsgBufSize: Integer;
          const Buf; const BufSize: Integer; var Name: TdnsNameString): Integer;
function  DNS_SkipName(const Buf; const BufSize: Integer): Integer;
function  DNS_MatchNameLabels(const Name1, Name2: TdnsNameString): Integer;
function  DNS_GetNameLabels(const Name: TdnsNameString): RawByteStringArray;



{                                                                              }
{ Questions                                                                    }
{                                                                              }
{   +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+                          }
{   |                                               |                          }
{   /                     QNAME                     /                          }
{   /                                               /                          }
{   +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+                          }
{   |                     QTYPE                     |                          }
{   +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+                          }
{   |                     QCLASS                    |                          }
{   +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+                          }
{                                                                              }
type
  TdnsQuestionInfo = record
    Name       : TdnsNameString;
    QueryType  : TdnsQueryType;
    QueryClass : Word;
  end;
  PdnsQuestionInfo = ^TdnsQuestionInfo;
  TdnsQuestionInfoArray = Array of TdnsQuestionInfo;

function  DNS_EncodeQuestion(
          var Buf; const BufSize: Integer;
          const Name: TdnsNameString;
          const QueryType: TdnsQueryType;
          const QueryClass: Word): Integer;
function  DNS_SkipQuestion(const Buf; const BufSize: Integer): Integer;
function  DNS_DecodeQuestion(
          const MsgBuf; const MsgBufSize: Integer;
          const Buf; const BufSize: Integer;
          out Question: TdnsQuestionInfo): Integer;



{                                                                              }
{ Resource Record                                                              }
{                                                                              }
{    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+                         }
{    |                                               |                         }
{    /                                               /                         }
{    /                      NAME                     /                         }
{    |                                               |                         }
{    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+                         }
{    |                      TYPE                     |                         }
{    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+                         }
{    |                     CLASS                     |                         }
{    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+                         }
{    |                      TTL                      |                         }
{    |                                               |                         }
{    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+                         }
{    |                   RDLENGTH                    |                         }
{    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--|                         }
{    /                     RDATA                     /                         }
{    /                                               /                         }
{    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+                         }
{                                                                              }
type
  TdnsRRInfo = record
    Name        : TdnsNameString;
    RecordType  : Word;
    RecordClass : Word;
    TTL         : LongWord;
    RecDataSize : Word;
    RecDataPtr  : Pointer;
  end;

procedure DNS_InitRRInfo(out RRInfo: TdnsRRInfo; const Name: TdnsNameString;
          const RecordType: Word; const TTL: LongWord);

function  DNS_DecodeRR(const MsgBuf; const MsgBufSize: Integer;
          const Buf; const BufSize: Integer;
          out Info: TdnsRRInfo): Integer;
function  DNS_EncodeRR_Header(var Buf; const BufSize: Integer;
          const Info: TdnsRRInfo; var RecDataSizeP: PWord): Integer;

procedure DNS_DecodeRecData_A(const Buf; const BufSize: Integer; out IP: TIP4Addr);
function  DNS_EncodeRecData_A(var Buf; const BufSize: Integer; const IP: TIP4Addr): Integer;
function  DNS_EncodeRR_A(
          var Buf; const BufSize: Integer;
          const Name: RawByteString; const TTL: LongWord;
          const IP: TIP4Addr): Integer;

procedure DNS_DecodeRecData_NS(const MsgBuf; const MsgBufSize: Integer;
          const Buf; const BufSize: Integer;
          out NSName: TdnsNameString);
function  DNS_EncodeRecData_NS(var Buf; const BufSize: Integer;
          const NSName: TdnsNameString): Integer;
function  DNS_EncodeRR_NS(var Buf; const BufSize: Integer;
          const Name: TdnsNameString; const TTL: LongWord;
          const NSName: TdnsNameString): Integer;

procedure DNS_DecodeRecData_CNAME(const MsgBuf; const MsgBufSize: Integer;
          const Buf; const BufSize: Integer;
          out CName: TdnsNameString);
function  DNS_EncodeRecData_CNAME(var Buf; const BufSize: Integer;
          const CName: TdnsNameString): Integer;
function  DNS_EncodeRR_CNAME(var Buf; const BufSize: Integer;
          const Name: TdnsNameString; const TTL: LongWord;
          const CName: TdnsNameString): Integer;

procedure DNS_DecodeRecData_PTR(const MsgBuf; const MsgBufSize: Integer;
          const Buf; const BufSize: Integer;
          out Name: TdnsNameString);

procedure DNS_DecodeRecData_HINFO(const Buf; const BufSize: Integer;
          out CPU, OS: RawByteString);

procedure DNS_DecodeRecData_MX(const MsgBuf; const MsgBufSize: Integer;
          const Buf; const BufSize: Integer;
          out Preference: Word; out Name: TdnsNameString);
function  DNS_EncodeRecData_MX(var Buf; const BufSize: Integer;
          const Preference: Word; const MXName: TdnsNameString): Integer;
function  DNS_EncodeRR_MX(var Buf; const BufSize: Integer;
          const Name: TdnsNameString; const TTL: LongWord;
          const Preference: Word; const MXName: TdnsNameString): Integer;

procedure DNS_DecodeRecData_SOA(const MsgBuf; const MsgBufSize: Integer;
          const Buf; const BufSize: Integer;
          out Domain, ResponsiblePerson: RawByteString;
          out Serial, Refresh, Retry, Expire: LongWord);



{                                                                              }
{ Query                                                                        }
{                                                                              }
function  DNS_EncodeQuery(var Buf; const BufSize: Integer;
          const Name: TdnsNameString; const ID: Word;
          const Operation: TdnsOperation;
          const RecordType: TdnsQueryType;
          const RecursionDesired: Boolean): Integer;
function  DNS_EncodeQuery_Str(const Name: TdnsNameString; const ID: Word;
          const Operation: TdnsOperation;
          const RecordType: TdnsQueryType;
          const RecursionDesired: Boolean): RawByteString;
function  DNS_DecodeQuery(const Buf; const BufSize: Integer;
          out Header: TdnsMessageHeader;
          out Questions: TdnsQuestionInfoArray): Integer;



{                                                                              }
{ Response                                                                     }
{                                                                              }
procedure DNS_DecodeResponse_Header(const Buf; const BufSize: Integer;
          out ID: Word;
          out Info: TdnsHeaderAttrInfo;
          out ResponseRecordsBuf: Pointer;
          out ResponseRecordsBufSize: Integer);



{                                                                              }
{ Test cases                                                                   }
{                                                                              }
{$IFDEF DNS_SELFTEST}
procedure SelfTest;
{$ENDIF}



implementation

uses
  { Fundamentals }
  cStrings;



{                                                                              }
{ Error codes                                                                  }
{                                                                              }
function DNS_ErrorString(const ErrorCode: Integer): String;
var S : String;
begin
  if ErrorCode = DNSE_None then
    Result := '' else
  if (ErrorCode < DNSE_Base) or (ErrorCode > DNSE_Top) then
    Result := 'Error ' + IntToStr(ErrorCode) else
  case ErrorCode of
    DNSE_InvalidParameter        : Result := 'Invalid parameter';
    DNSE_InvalidBuffer           : Result := 'Invalid buffer';
    DNSE_BufferOverflow          : Result := 'Buffer overflow';
    DNSE_DomainNameTooLong       : Result := 'Domain name too long';
    DNSE_DomainLabelTooLong      : Result := 'Domain label too long';
    DNSE_StringTooLong           : Result := 'String too long';
    DNSE_InvalidOpCode           : Result := 'Invalid opcode';
    DNSE_InternalError           : Result := 'Internal error';
    DNSE_ServerErrorResponse     : Result := 'Server error response';
    DNSE_Response_FormatError    : Result := 'Format error';
    DNSE_Response_ServerFailure  : Result := 'Server failure';
    DNSE_Response_NameError      : Result := 'Name error';
    DNSE_Response_NotImplemented : Result := 'Not implemented';
    DNSE_Response_Refused        : Result := 'Refused';
    DNSE_Response_NameExists     : Result := 'Name exists';
    DNSE_Response_RRSetExists    : Result := 'RR set exists';
    DNSE_Response_RRSetNotExist  : Result := 'RR set does not exist';
    DNSE_Response_NotAuthorised  : Result := 'Not authorised';
    DNSE_Response_NotZone        : Result := 'Not a zone';
    DNSE_LookupError             : Result := 'Lookup error';
    DNSE_LookupTimeOut           : Result := 'Lookup timed out';
  else
    begin
      S := ' (' + IntToStr(ErrorCode - DNSE_Base) + ')';
      case (ErrorCode div 100) * 100 of
        DNSE_InvalidParameter    : Result := 'Invalid parameter' + S;
        DNSE_InternalError       : Result := 'Internal error' + S;
        DNSE_ServerErrorResponse : Result := 'Server error response' + S;
        DNSE_LookupError         : Result := 'Lookup error' + S;
      else
        Result := 'DNS error' + S;
      end;
    end;
  end;
end;



{                                                                              }
{ Exception                                                                    }
{                                                                              }
constructor EdnsError.Create(const ErrorCode: Integer; const Msg: String);
var S : String;
begin
  if Msg = '' then
    S := DNS_ErrorString(ErrorCode)
  else
    S := Msg;
  inherited Create(S);
  FErrorCode := ErrorCode;
end;



{                                                                              }
{ Header OPCODE field                                                          }
{                                                                              }
{    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+                         }
{    |  |   Opcode  |                                |                         }
{    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+                         }
{                                                                              }
function DNS_EncodeOpCode(const Operation: TdnsOperation): Byte;
begin
  case Operation of
    dopQuery        : Result := DNS_OPCODE_QUERY;
    dopInverseQuery : Result := DNS_OPCODE_IQUERY;
    dopServerStatus : Result := DNS_OPCODE_STATUS;
  else
    raise EdnsError.Create(DNSE_InvalidParameter);
  end;
end;

function DNS_DecodeOpCode(const OpCode: Byte): TdnsOperation;
begin
  case OpCode of
    DNS_OPCODE_QUERY  : Result := dopQuery;
    DNS_OPCODE_IQUERY : Result := dopInverseQuery;
    DNS_OPCODE_STATUS : Result := dopServerStatus;
  else
    raise EdnsError.Create(DNSE_InvalidOpCode);
  end;
end;



{                                                                              }
{ Header ATTR field                                                            }
{                                                                              }
{    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+                         }
{    |QR|   Opcode  |AA|TC|RD|RA|   Z    |   RCODE   |                         }
{    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+                         }
{                                                                              }
function DNS_EncodeHeaderAttr(const Query: Boolean; const Operation: TdnsOperation;
         const Authoritative, Truncated, RecursionDesired, RecursionAvailable: Boolean;
         const ResponseCode: Byte): Word;
begin
  Result := 0;
  if not Query then
    Result := Result or $8000;
  Result := Result or ((DNS_EncodeOpCode(Operation) and $F) shl 11);
  if Authoritative then
    Result := Result or $0400;
  if Truncated then
    Result := Result or $0200;
  if RecursionDesired then
    Result := Result or $0100;
  if RecursionAvailable then
    Result := Result or $0080;
  Result := Result or (ResponseCode and $F);
end;

function DNS_EncodeHeaderAttr_Query(const Operation: TdnsOperation;
         const RecursionDesired: Boolean): Word;
begin
  Result := DNS_EncodeHeaderAttr(True, Operation, False, False,
      RecursionDesired, False, DNS_RCODE_NoError);
end;

procedure DNS_DecodeHeaderAttr(const Attr: Word; out Info: TdnsHeaderAttrInfo);
begin
  Info.Query              := Attr and $8000 = 0;
  Info.Operation          := DNS_DecodeOpCode((Attr and $7800) shr 11);
  Info.Authorative        := Attr and $0400 <> 0;
  Info.Truncated          := Attr and $0200 <> 0;
  Info.RecursionDesired   := Attr and $0100 <> 0;
  Info.RecursionAvailable := Attr and $0080 <> 0;
  Info.ResponseCode       := Byte(Attr and $F);
end;

function DNS_EncodeHeaderAttr_Response(const Attr: Word;
         const ResponseCode: Byte;
         const Authorative, RecursionAvailable: Boolean): Word;
begin
  Result := (Attr and $FFF0) or (ResponseCode and $F)
                             or $8000;
  if Authorative then
    Result := Result or $0400
  else
    Result := Result and (not $0400);

  if RecursionAvailable then
    Result := Result or $0080
  else
    Result := Result and (not $0080);
end;



{                                                                              }
{ Message Header                                                               }
{                                                                              }
{    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+                         }
{    |                      ID                       |                         }
{    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+                         }
{    |QR|   Opcode  |AA|TC|RD|RA|   Z    |   RCODE   |                         }
{    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+                         }
{    |                    QDCOUNT                    |                         }
{    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+                         }
{    |                    ANCOUNT                    |                         }
{    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+                         }
{    |                    NSCOUNT                    |                         }
{    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+                         }
{    |                    ARCOUNT                    |                         }
{    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+                         }
{                                                                              }
function DNS_EncodeHeader_Query(var Buf; const BufSize: Integer;
         const ID: Word; const Operation: TdnsOperation;
         const RecursionDesired: Boolean;
         const QuestionCount: Word): Integer;
var P : PdnsMessageHeader;
begin
  if BufSize < DNS_MessageHeaderSize then
    raise EdnsError.Create(DNSE_BufferOverflow);
  Result := DNS_MessageHeaderSize;
  P := PdnsMessageHeader(@Buf);
  ZeroMem(P^, DNS_MessageHeaderSize);
  P^.ID      := htons(ID);
  P^.Attr    := htons(DNS_EncodeHeaderAttr_Query(Operation, RecursionDesired));
  P^.QDCount := htons(QuestionCount);
end;

function DNS_EncodeHeader_Response(var Buf; const BufSize: Integer;
         const Header: TdnsMessageHeader): Integer;
var P : PdnsMessageHeader;
begin
  if BufSize < DNS_MessageHeaderSize then
    raise EdnsError.Create(DNSE_BufferOverflow);
  Result := DNS_MessageHeaderSize;
  P := PdnsMessageHeader(@Buf);
  ZeroMem(P^, DNS_MessageHeaderSize);
  P^.ID      := htons(Header.ID);
  P^.Attr    := htons(Header.Attr or $8000);
  P^.ANCount := htons(Header.ANCount);
  P^.NSCount := htons(Header.NSCount);
  P^.ARCount := htons(Header.ARCount);
end;

function DNS_DecodeHeader_Query(
         const Buf; const BufSize: Integer;
         out Header: TdnsMessageHeader): Integer;
var
  P : PdnsMessageHeader;
begin
  if BufSize < DNS_MessageHeaderSize then
    raise EdnsError.Create(DNSE_InvalidBuffer);
  Result := DNS_MessageHeaderSize;
  P := PdnsMessageHeader(@Buf);
  ZeroMem(Header, DNS_MessageHeaderSize);
  Header.ID := ntohs(P^.ID);
  Header.Attr := ntohs(P^.Attr);
  Header.QDCount := ntohs(P^.QDCount);
  Header.ANCount := ntohs(P^.ANCount);
  Header.NSCount := ntohs(P^.NSCount);
  Header.ARCount := ntohs(P^.ARCount);
end;



{                                                                              }
{ TYPE field                                                                   }
{                                                                              }
function DNS_RecordTypeStr(const RecordType: Word): RawByteString;
begin
  case RecordType of
    0                : Result := '';
    DNS_TYPE_A       : Result := 'A';
    DNS_TYPE_NS      : Result := 'NS';
    DNS_TYPE_MD      : Result := 'MD';
    DNS_TYPE_MF      : Result := 'MF';
    DNS_TYPE_CNAME   : Result := 'CNAME';
    DNS_TYPE_SOA     : Result := 'SOA';
    DNS_TYPE_MB      : Result := 'MB';
    DNS_TYPE_MG      : Result := 'MG';
    DNS_TYPE_MR      : Result := 'MR';
    DNS_TYPE_NULL    : Result := 'NULL';
    DNS_TYPE_WKS     : Result := 'WKS';
    DNS_TYPE_PTR     : Result := 'PTR';
    DNS_TYPE_HINFO   : Result := 'HINFO';
    DNS_TYPE_MINFO   : Result := 'MINFO';
    DNS_TYPE_MX      : Result := 'MX';
    DNS_TYPE_TXT     : Result := 'TXT';
    DNS_TYPE_RP      : Result := 'RP';
    DNS_TYPE_AFSDB   : Result := 'AFSDB';
    DNS_TYPE_X25     : Result := 'X25';
    DNS_TYPE_ISDN    : Result := 'ISDN';
    DNS_TYPE_RT      : Result := 'RT';
    DNS_TYPE_NSAP    : Result := 'NSAP';
    DNS_TYPE_NSAPPTR : Result := 'NSAPPTR';
    DNS_TYPE_SIG     : Result := 'SIG';
    DNS_TYPE_KEY     : Result := 'KEY';
    DNS_TYPE_NXT     : Result := 'NXT';
    DNS_TYPE_PX      : Result := 'PX';
    DNS_TYPE_GPOS    : Result := 'GPOS';
    DNS_TYPE_AAAA    : Result := 'AAAA';
    DNS_TYPE_LOC     : Result := 'LOC';
    DNS_TYPE_SRV     : Result := 'SRV';
    DNS_TYPE_NAPTR   : Result := 'NAPTR';
    DNS_TYPE_KX      : Result := 'KX';
    DNS_QTYPE_AXFR   : Result := 'AXFR';
    DNS_QTYPE_MAILB  : Result := 'MAILB';
    DNS_QTYPE_MAILA  : Result := 'MAILA';
    DNS_QTYPE_ALL    : Result := 'ALL';
  else
    Result := 'R' + LongWordToHexA(RecordType, 4);
  end;
end;

function DNS_EncodeQueryType(const QueryRecordType: TdnsQueryType): Word;
begin
  case QueryRecordType of
    dqtA     : Result := DNS_TYPE_A;
    dqtNS    : Result := DNS_TYPE_NS;
    dqtCNAME : Result := DNS_TYPE_CNAME;
    dqtWKS   : Result := DNS_TYPE_WKS;
    dqtPTR   : Result := DNS_TYPE_PTR;
    dqtHINFO : Result := DNS_TYPE_HINFO;
    dqtMX    : Result := DNS_TYPE_MX;
    dqtTXT   : Result := DNS_TYPE_TXT;
    dqtAXFR  : Result := DNS_QTYPE_AXFR;
    dqtAll   : Result := DNS_QTYPE_ALL;
  else
    raise EdnsError.Create(DNSE_InvalidParameter);
  end;
end;

function DNS_DecodeQueryType(const QueryRecordType: Word): TdnsQueryType;
begin
  case QueryRecordType of
    DNS_TYPE_A     : Result := dqtA;
    DNS_TYPE_NS    : Result := dqtNS;
    DNS_TYPE_CNAME : Result := dqtCNAME;
    DNS_TYPE_WKS   : Result := dqtWKS;
    DNS_TYPE_PTR   : Result := dqtPTR;
    DNS_TYPE_HINFO : Result := dqtHINFO;
    DNS_TYPE_MX    : Result := dqtMX;
    DNS_TYPE_TXT   : Result := dqtTXT;
    DNS_QTYPE_AXFR : Result := dqtAXFR;
    DNS_QTYPE_All  : Result := dqtAll;
  else
    raise EdnsError.Create(DNSE_InvalidParameter);
  end;
end;



{                                                                              }
{ Character string field                                                       }
{                                                                              }
function DNS_DecodeString(const Buf; const BufSize: Integer; var Str: RawByteString): Integer;
var P : PAnsiChar;
    L : Byte;
begin
  Str := '';
  if BufSize <= 0 then
    raise EdnsError.Create(DNSE_InvalidBuffer);
  P := @Buf;
  L := Byte(P^);
  Result := L + 1;
  if L = 0 then
    exit;
  if BufSize < L + 1 then
    raise EdnsError.Create(DNSE_InvalidBuffer);
  SetLength(Str, L);
  Inc(P);
  MoveMem(P^, Pointer(Str)^, L);
end;

function DNS_EncodeString(const Buf; const BufSize: Integer; const S: RawByteString): Integer;
var L : Integer;
    N : Byte;
    P : PAnsiChar;
begin
  L := Length(S);
  if L > 255 then
    raise EdnsError.Create(DNSE_StringTooLong);
  Result := L + 1;
  if Result > BufSize then
    raise EdnsError.Create(DNSE_BufferOverflow);
  P := @Buf;
  N := L;
  P^ := AnsiChar(N);
  if L = 0 then
    exit;
  Inc(P);
  MoveMem(Pointer(S)^, P^, L);
end;



{                                                                              }
{ NAME field                                                                   }
{                                                                              }
function DNS_EncodeName(var Buf; const BufSize: Integer; const Name: TdnsNameString): Integer;
var L       : Integer;
    N       : Byte;
    P, Q, R : PAnsiChar;
begin
  L := Length(Name);
  if L > DNS_MaxNameSize then
    raise EdnsError.Create(DNSE_DomainNameTooLong);
  Result := 0;
  P := @Buf;
  Q := Pointer(Name);
  while L > 0 do
    begin
      N := 0;
      R := Q;
      while (N < L) and (Q^ <> '.') do
        begin
          Inc(Q);
          Inc(N);
        end;
      if N > DNS_MaxLabelSize then
        raise EdnsError.Create(DNSE_DomainLabelTooLong);
      Dec(L, N);
      Inc(Result, N + 1);
      if Result > BufSize then
        raise EdnsError.Create(DNSE_BufferOverflow);
      P^ := AnsiChar(N);
      Inc(P);
      MoveMem(R^, P^, N);
      Inc(P, N);
      if (L > 0) and (Q^ = '.') then
        begin
          Inc(Q);
          Dec(L);
        end;
    end;
  Inc(Result);
  if Result > BufSize then
    raise EdnsError.Create(DNSE_BufferOverflow);
  P^ := #0;
end;

function DNS_DecodeName(const MsgBuf; const MsgBufSize: Integer;
         const Buf; const BufSize: Integer; var Name: TdnsNameString): Integer;
var P : PAnsiChar;
    C : Byte;
    F : Word;
    S : RawByteString;
begin
  P := @Buf;
  Name := '';
  Result := 0;
  repeat
    Inc(Result);
    if Result > BufSize then
      raise EdnsError.Create(DNSE_InvalidBuffer);
    C := Byte(P^);
    if C = 0 then
      exit;
    if C and $C0 = $C0 then
      begin
        Inc(Result);
        if Result > BufSize then
          raise EdnsError.Create(DNSE_InvalidBuffer);
        Inc(P);
        F := ((C and $3F) shl 8) + Ord(P^);
        if F > MsgBufSize then
          raise EdnsError.Create(DNSE_InvalidBuffer);
        P := @MsgBuf;
        Inc(P, F);
        DNS_DecodeName(MsgBuf, MsgBufSize, P^, MsgBufSize - F, S);
        if Name = '' then
          Name := S
        else
          Name := Name + '.' + S;
        exit;
      end;
    Inc(Result, C);
    if Result > BufSize then
      raise EdnsError.Create(DNSE_InvalidBuffer);
    Inc(P);
    SetLength(S, C);
    MoveMem(P^, Pointer(S)^, C);
    Inc(P, C);
    if Name = '' then
      Name := S
    else
      Name := Name + '.' + S;
  until False;
end;

function DNS_SkipName(const Buf; const BufSize: Integer): Integer;
var P : PAnsiChar;
    C : Byte;
begin
  P := @Buf;
  Result := 0;
  repeat
    Inc(Result);
    if Result > BufSize then
      raise EdnsError.Create(DNSE_InvalidBuffer);
    C := Byte(P^);
    if C = 0 then
      exit;
    if C and $C0 = $C0 then
      begin
        Inc(Result);
        if Result > BufSize then
          raise EdnsError.Create(DNSE_InvalidBuffer);
        exit;
      end;
    Inc(Result, C);
    if Result > BufSize then
      raise EdnsError.Create(DNSE_InvalidBuffer);
    Inc(P, C + 1);
  until False;
end;

function DNS_MatchNameLabels(const Name1, Name2: TdnsNameString): Integer;
var P, Q : PAnsiChar;
    L, M : Integer;
begin
  Result := 0;
  L := Length(Name1);
  M := Length(Name2);
  if (L = 0) or (M = 0) then
    exit;
  P := Pointer(Name1);
  Inc(P, L - 1);
  Q := Pointer(Name2);
  Inc(Q, M - 1);
  while (L > 0) and (M > 0) do
    begin
      if (P^ = '.') or (Q^ = '.') then
        begin
          if P^ <> Q^ then
            break;
          Inc(Result);
        end
      else
      if not CharMatchNoAsciiCaseA(P^, Q^) then
        break;
      Dec(P);
      Dec(Q);
      Dec(L);
      Dec(M);
    end;
  if (L = 0) or (M = 0) then
    if (L = 0) and (M = 0) then
      Inc(Result) else
    if (L > 0) and (P^ = '.') then
      Inc(Result) else
    if (M > 0) and (Q^ = '.') then
      Inc(Result);
end;

function DNS_GetNameLabels(const Name: TdnsNameString): RawByteStringArray;
begin
  Result := StrSplitCharB(Name, '.');
end;



{                                                                              }
{ Questions                                                                    }
{                                                                              }
{   +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+                          }
{   |                                               |                          }
{   /                     QNAME                     /                          }
{   /                                               /                          }
{   +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+                          }
{   |                     QTYPE                     |                          }
{   +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+                          }
{   |                     QCLASS                    |                          }
{   +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+                          }
{                                                                              }
function DNS_EncodeQuestion(var Buf; const BufSize: Integer;
         const Name: TdnsNameString; const QueryType: TdnsQueryType;
         const QueryClass: Word): Integer;
var P : PAnsiChar;
begin
  P := @Buf;
  Result := DNS_EncodeName(P^, BufSize, Name);
  Inc(P, Result);
  Inc(Result, 4);
  if Result > BufSize then
    raise EdnsError.Create(DNSE_BufferOverflow);
  PWord(P)^ := htons(DNS_EncodeQueryType(QueryType));
  Inc(P, 2);
  PWord(P)^ := htons(QueryClass);
end;

function DNS_SkipQuestion(const Buf; const BufSize: Integer): Integer;
begin
  Result := DNS_SkipName(Buf, BufSize);
  Inc(Result, 4);
  if Result > BufSize then
    raise EdnsError.Create(DNSE_InvalidBuffer);
end;

function DNS_DecodeQuestion(
         const MsgBuf; const MsgBufSize: Integer;
         const Buf; const BufSize: Integer;
         out Question: TdnsQuestionInfo): Integer;
var
  P : PAnsiChar;
begin
  P := @Buf;
  Result := DNS_DecodeName(MsgBuf, MsgBufSize, P^, BufSize, Question.Name);
  Inc(P, Result);
  Inc(Result, 4);
  if Result > BufSize then
    raise EdnsError.Create(DNSE_InvalidBuffer);
  Question.QueryType := DNS_DecodeQueryType(ntohs(PWord(P)^));
  Inc(P, 2);
  Question.QueryClass := ntohs(PWord(P)^);
end;



{                                                                              }
{ Resource Record (RR)                                                         }
{                                                                              }
{    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+                         }
{    |                                               |                         }
{    /                                               /                         }
{    /                      NAME                     /                         }
{    |                                               |                         }
{    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+                         }
{    |                      TYPE                     |                         }
{    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+                         }
{    |                     CLASS                     |                         }
{    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+                         }
{    |                      TTL                      |                         }
{    |                                               |                         }
{    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+                         }
{    |                   RDLENGTH                    |                         }
{    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--|                         }
{    /                     RDATA                     /                         }
{    /                                               /                         }
{    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+                         }
{                                                                              }
procedure DNS_InitRRInfo(out RRInfo: TdnsRRInfo; const Name: TdnsNameString;
          const RecordType: Word; const TTL: LongWord);
begin
  ZeroMem(RRInfo, Sizeof(TdnsRRInfo));
  RRInfo.Name := Name;
  RRInfo.RecordType := RecordType;
  RRInfo.RecordClass := DNS_CLASS_IN;
  RRInfo.TTL := TTL;
end;

function DNS_DecodeRR(const MsgBuf; const MsgBufSize: Integer;
         const Buf; const BufSize: Integer;
         out Info: TdnsRRInfo): Integer;
var I, L : Integer;
    P    : PAnsiChar;
begin
  P := @Buf;
  L := BufSize;
  Result := 0;
  I := DNS_DecodeName(MsgBuf, MsgBufSize, P^, L, Info.Name);
  Inc(P, I);
  Dec(L, I);
  Inc(Result, I);
  if L < 10 then
    raise EdnsError.Create(DNSE_InvalidBuffer);
  Info.RecordType := ntohs(PWord(P)^);
  Inc(P, 2);
  Info.RecordClass := ntohs(PWord(P)^);
  Inc(P, 2);
  Info.TTL := ntohl(PLongWord(P)^);
  Inc(P, 4);
  Info.RecDataSize := ntohs(PWord(P)^);
  Inc(P, 2);
  Dec(L, 10);
  Inc(Result, 10);
  Info.RecDataPtr := P;
  if L < Info.RecDataSize then
    raise EdnsError.Create(DNSE_InvalidBuffer);
  Inc(Result, Info.RecDataSize);
end;

function DNS_EncodeRR_Header(var Buf; const BufSize: Integer;
         const Info: TdnsRRInfo; var RecDataSizeP: PWord): Integer;
var I, L : Integer;
    P    : PAnsiChar;
begin
  P := @Buf;
  L := BufSize;
  Result := 0;
  I := DNS_EncodeName(P^, L, Info.Name);
  Inc(P, I);
  Dec(L, I);
  Inc(Result, I);
  if L < 10 then
    raise EdnsError.Create(DNSE_BufferOverflow);
  PWord(P)^ := htons(Info.RecordType);
  Inc(P, 2);
  PWord(P)^ := htons(Info.RecordClass);
  Inc(P, 2);
  PLongWord(P)^ := htonl(Info.TTL);
  Inc(P, 4);
  RecDataSizeP := PWord(P);
  PWord(P)^ := htons(Info.RecDataSize);
  Inc(Result, 10);
end;

procedure DNS_DecodeRecData_A(const Buf; const BufSize: Integer; out IP: TIP4Addr);
begin
  if BufSize < 4 then
    raise EdnsError.Create(DNSE_InvalidBuffer);
  IP.Addr32 := PLongWord(@Buf)^;
end;

function DNS_EncodeRecData_A(var Buf; const BufSize: Integer; const IP: TIP4Addr): Integer;
begin
  if BufSize < 4 then
    raise EdnsError.Create(DNSE_BufferOverflow);
  PLongWord(@Buf)^ := IP.Addr32;
  Result := 4;
end;

function DNS_EncodeRR_A(var Buf; const BufSize: Integer;
         const Name: RawByteString; const TTL: LongWord; const IP: TIP4Addr): Integer;
var P : PAnsiChar;
    L : Integer;
    R : TdnsRRInfo;
    S : PWord;
begin
  DNS_InitRRInfo(R, Name, DNS_TYPE_A, TTL);
  R.RecDataSize := 4;
  P := @Buf;
  L := BufSize;
  Result := DNS_EncodeRR_Header(P^, L, R, S);
  Inc(P, Result);
  Dec(L, Result);
  Inc(Result, DNS_EncodeRecData_A(P^, L, IP));
end;

procedure DNS_DecodeRecData_NS(const MsgBuf; const MsgBufSize: Integer;
          const Buf; const BufSize: Integer;
          out NSName: TdnsNameString);
begin
  DNS_DecodeName(MsgBuf, MsgBufSize, Buf, BufSize, NSName);
end;

function DNS_EncodeRecData_NS(var Buf; const BufSize: Integer;
         const NSName: TdnsNameString): Integer;
begin
  Result := DNS_EncodeName(Buf, BufSize, NSName);
end;

function DNS_EncodeRR_NS(var Buf; const BufSize: Integer;
         const Name: TdnsNameString; const TTL: LongWord;
         const NSName: TdnsNameString): Integer;
var P    : PAnsiChar;
    L, I : Integer;
    R    : TdnsRRInfo;
    S    : PWord;
begin
  DNS_InitRRInfo(R, Name, DNS_TYPE_NS, TTL);
  P := @Buf;
  L := BufSize;
  Result := DNS_EncodeRR_Header(P^, L, R, S);
  Inc(P, Result);
  Dec(L, Result);
  I := DNS_EncodeRecData_NS(P^, L, NSName);
  S^ := htons(Word(I));
  Inc(Result, I);
end;

procedure DNS_DecodeRecData_CNAME(const MsgBuf; const MsgBufSize: Integer;
          const Buf; const BufSize: Integer;
          out CName: TdnsNameString);
begin
  DNS_DecodeName(MsgBuf, MsgBufSize, Buf, BufSize, CName);
end;

function DNS_EncodeRecData_CNAME(var Buf; const BufSize: Integer;
         const CName: TdnsNameString): Integer;
begin
  Result := DNS_EncodeName(Buf, BufSize, CName);
end;

function DNS_EncodeRR_CNAME(var Buf; const BufSize: Integer;
         const Name: TdnsNameString; const TTL: LongWord;
         const CName: TdnsNameString): Integer;
var P    : PAnsiChar;
    L, I : Integer;
    R    : TdnsRRInfo;
    S    : PWord;
begin
  DNS_InitRRInfo(R, Name, DNS_TYPE_CNAME, TTL);
  P := @Buf;
  L := BufSize;
  Result := DNS_EncodeRR_Header(P^, L, R, S);
  Inc(P, Result);
  Dec(L, Result);
  I := DNS_EncodeRecData_CNAME(P^, L, CName);
  S^ := htons(Word(I));
  Inc(Result, I);
end;


procedure DNS_DecodeRecData_PTR(const MsgBuf; const MsgBufSize: Integer;
          const Buf; const BufSize: Integer;
          out Name: TdnsNameString);
begin
  DNS_DecodeName(MsgBuf, MsgBufSize, Buf, BufSize, Name);
end;

procedure DNS_DecodeRecData_HINFO(const Buf; const BufSize: Integer;
          out CPU, OS: RawByteString);
var
  P : PAnsiChar;
  I : Integer;
begin
  P := @Buf;
  I := DNS_DecodeString(Buf, BufSize, CPU);
  Inc(P, I);
  DNS_DecodeString(P^, BufSize - I, OS);
end;

procedure DNS_DecodeRecData_MX(const MsgBuf; const MsgBufSize: Integer;
          const Buf; const BufSize: Integer;
          out Preference: Word; out Name: TdnsNameString);
var P : PAnsiChar;
begin
  if BufSize < 2 then
    raise EdnsError.Create(DNSE_InvalidBuffer);
  P := @Buf;
  Preference := ntohs(PWord(P)^);
  Inc(P, 2);
  DNS_DecodeName(MsgBuf, MsgBufSize, P^, BufSize - 2, Name);
end;

function DNS_EncodeRecData_MX(var Buf; const BufSize: Integer;
         const Preference: Word; const MXName: TdnsNameString): Integer;
var P : PAnsiChar;
begin
  if BufSize < 2 then
    raise EdnsError.Create(DNSE_BufferOverflow);
  P := @Buf;
  PWord(P)^ := htons(Preference);
  Inc(P, 2);
  Result := 2 + DNS_EncodeName(P^, BufSize - 2, MXName);
end;

function DNS_EncodeRR_MX(var Buf; const BufSize: Integer;
         const Name: TdnsNameString; const TTL: LongWord;
         const Preference: Word; const MXName: TdnsNameString): Integer;
var P    : PAnsiChar;
    L, I : Integer;
    R    : TdnsRRInfo;
    S    : PWord;
begin
  DNS_InitRRInfo(R, Name, DNS_TYPE_MX, TTL);
  P := @Buf;
  L := BufSize;
  Result := DNS_EncodeRR_Header(P^, L, R, S);
  Inc(P, Result);
  Dec(L, Result);
  I := DNS_EncodeRecData_MX(P^, L, Preference, MXName);
  S^ := htons(Word(I));
  Inc(Result, I);
end;

procedure DNS_DecodeRecData_SOA(const MsgBuf; const MsgBufSize: Integer;
          const Buf; const BufSize: Integer;
          out Domain, ResponsiblePerson: RawByteString;
          out Serial, Refresh, Retry, Expire: LongWord);
var P    : PAnsiChar;
    I, L : Integer;
begin
  P := @Buf;
  L := BufSize;
  I := DNS_DecodeName(MsgBuf, MsgBufSize, P^, L, Domain);
  Inc(P, I);
  Dec(L, I);
  I := DNS_DecodeName(MsgBuf, MsgBufSize, P^, L, ResponsiblePerson);
  Inc(P, I);
  Serial := LongWord(ntohl(PLongWord(P)^));
  Inc(P, 4);
  Refresh := LongWord(ntohl(PLongWord(P)^));
  Inc(P, 4);
  Retry := LongWord(ntohl(PLongWord(P)^));
  Inc(P, 4);
  Expire := LongWord(ntohl(PLongWord(P)^));
end;



{                                                                              }
{ Query message                                                                }
{                                                                              }
function DNS_EncodeQuery(var Buf; const BufSize: Integer;
         const Name: TdnsNameString; const ID: Word;
         const Operation: TdnsOperation; const RecordType: TdnsQueryType;
         const RecursionDesired: Boolean): Integer;
var P : PAnsiChar;
begin
  P := @Buf;
  Result := DNS_EncodeHeader_Query(P^, BufSize, ID, Operation, RecursionDesired, 1);
  Inc(P, Result);
  Inc(Result, DNS_EncodeQuestion(P^, BufSize - Result, Name, RecordType, DNS_CLASS_IN));
end;

function DNS_EncodeQuery_Str(const Name: TdnsNameString; const ID: Word;
         const Operation: TdnsOperation; const RecordType: TdnsQueryType;
         const RecursionDesired: Boolean): RawByteString;
var Buf : array[0..DNS_MaxRawRequestSize - 1] of Byte;
    Len : Integer;
begin
  Len := DNS_EncodeQuery(Buf, DNS_MaxRawRequestSize, Name, ID, Operation,
      RecordType, RecursionDesired);
  SetLength(Result, Len);
  Move(Buf, Pointer(Result)^, Len);
end;

function DNS_DecodeQuery(const Buf; const BufSize: Integer;
         out Header: TdnsMessageHeader;
         out Questions: TdnsQuestionInfoArray): Integer;
var P : PAnsiChar;
    I, J, L : Integer;
begin
  P := @Buf;
  L := BufSize;
  Result := DNS_DecodeHeader_Query(P^, L, Header);
  Inc(P, Result);
  Dec(L, Result);
  SetLength(Questions, Header.QDCount);
  for I := 0 to Header.QDCount - 1 do
    begin
      J := DNS_DecodeQuestion(Buf, BufSize, P^, L, Questions[I]);
      Inc(P, J);
      Dec(L, J);
      Inc(Result, J);
    end;
end;



{                                                                              }
{ DNS response                                                                 }
{                                                                              }
procedure DNS_DecodeResponse_Header(const Buf; const BufSize: Integer;
          out ID: Word; out Info: TdnsHeaderAttrInfo;
          out ResponseRecordsBuf: Pointer;
          out ResponseRecordsBufSize: Integer);
var P       : PAnsiChar;
    Hdr     : PdnsMessageHeader;
    L, I, J : Integer;
begin
  P := @Buf;
  L := BufSize;
  // Header
  if L < DNS_MessageHeaderSize then
    raise EdnsError.Create(DNSE_InvalidBuffer);
  Hdr := Pointer(P);
  ID := ntohs(Hdr^.ID);
  DNS_DecodeHeaderAttr(ntohs(Hdr^.Attr), Info);
  Inc(P, DNS_MessageHeaderSize);
  Dec(L, DNS_MessageHeaderSize);
  // Skip questions
  for I := 1 to ntohs(Hdr^.QDCount) do
    begin
      J := DNS_SkipQuestion(P^, L);
      Inc(P, J);
      Dec(L, J);
    end;
  // Response records
  ResponseRecordsBuf := P;
  ResponseRecordsBufSize := L;
end;



{                                                                              }
{ Test cases                                                                   }
{                                                                              }
{$IFDEF DNS_SELFTEST}
{$ASSERTIONS ON}
procedure SelfTest;
begin
  { DNS_MatchLabels }
  Assert(DNS_MatchNameLabels('', '') = 0);
  Assert(DNS_MatchNameLabels('a', '') = 0);
  Assert(DNS_MatchNameLabels('', 'a') = 0);
  Assert(DNS_MatchNameLabels('a', 'a') = 1);
  Assert(DNS_MatchNameLabels('ab', 'a') = 0);
  Assert(DNS_MatchNameLabels('a.b', 'a.B') = 2);
  Assert(DNS_MatchNameLabels('z.B', 'a.b') = 1);
  Assert(DNS_MatchNameLabels('a.b.c.d', 'x.y.z.b.c.d') = 3);
  Assert(DNS_MatchNameLabels('a.bc.cde.defg', 'xyz.yz.zyx.Bc.cDe.deFG') = 3);
  { Other }
  Assert(DNS_TYPE_A = 1);
  Assert(DNS_TYPE_MX = 15);
  Assert(DNS_RecordTypeStr(DNS_TYPE_A) = 'A');
  Assert(DNS_RecordTypeStr(DNS_TYPE_MX) = 'MX');
end;
{$ENDIF}



end.

