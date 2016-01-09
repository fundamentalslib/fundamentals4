{******************************************************************************}
{                                                                              }
{   Library:          Fundamentals 4.00                                        }
{   File name:        cTCP.inc                                                 }
{   Description:      TCP library conditional defines.                         }
{                                                                              }
{******************************************************************************}

{$INCLUDE ..\cFundamentals.inc}

{$IFDEF DEBUG}
  {$DEFINE TCP_DEBUG}
  {$DEFINE TCP_DEBUG_DATA}
  {$DEFINE TCP_DEBUG_TLS}
  {$DEFINE TCP_DEBUG_SOCKET}
  {$DEFINE TCP_DEBUG_CONNECTION}
  {$DEFINE TCP_DEBUG_THREAD}
{$ENDIF}

{.DEFINE TCPCLIENT_SOCKS}

{.DEFINE TCPCLIENT_TLS}
{.DEFINE TCPSERVER_TLS}

{$IFDEF DELPHI5_DOWN}
  {$UNDEF TCPCLIENT_TLS}
  {$UNDEF TCPSERVER_TLS}
{$ENDIF}

