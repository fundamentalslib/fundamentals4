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
{$ENDIF}

{.DEFINE TCPCLIENT_SOCKS}

{.DEFINE TCPCLIENT_TLS}
{.DEFINE TCPSERVER_TLS}

