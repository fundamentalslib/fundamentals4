{******************************************************************************}
{                                                                              }
{   Library:          Fundamentals 4.00                                        }
{   File name:        cCipher.inc                                              }
{   Description:      Cipher library defines                                   }
{                                                                              }
{******************************************************************************}

{.DEFINE DEBUG}
{.DEFINE SELFTEST}

{$INCLUDE ..\cFundamentals.inc}

{$IFDEF DEBUG}
{$IFDEF SELFTEST}
  {$DEFINE CIPHER_SELFTEST}
{$ENDIF}
{$IFDEF PROFILE}
  {$DEFINE CIPHER_PROFILE}
{$ENDIF}
{$ENDIF}

