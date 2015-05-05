{******************************************************************************}
{                                                                              }
{   Library:          Fundamentals 4.00                                        }
{   File name:        cVariant.pas                                             }
{   File version:     4.06                                                     }
{   Description:      Variant                                                  }
{                                                                              }
{   Copyright:        Copyright (c) 2009-2015, David J Butler                  }
{                     All rights reserved.                                     }
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
{   Github:           https://github.com/fundamentalslib                       }
{   E-mail:           fundamentalslib at gmail.com                             }
{                                                                              }
{ Revision history:                                                            }
{                                                                              }
{   2009/02/14  0.01  Initial development.                                     }
{   2009/10/17  0.02  Development.                                             }
{   2013/10/24  0.03  Additional types.                                        }
{   2015/04/01  0.04  RawByteString.                                           }
{   2015/04/25  0.05  Variant array and dictionary types.                      }
{   2015/04/25  4.06  Revised for Fundamentals 4.                              }
{                                                                              }
{ Supported compilers:                                                         }
{                                                                              }
{   Delphi XE7 Win32                    4.06  2015/04/25                       }
{   Delphi XE7 Win64                    4.06  2015/04/25                       }
{                                                                              }
{ Todo:                                                                        }
{ - Decimal types                                                              }
{******************************************************************************}

{$INCLUDE ..\cFundamentals.inc}

unit cVariant;

interface

uses
  { System }
  SysUtils,

  { Fundamentals }
  cHash,
  cUtils,
  cStrings,
  cInteger,
  cHugeInt;



{                                                                              }
{ Variant errors                                                               }
{                                                                              }

type
  EVariantError = class(Exception);
  EVariantConvertError = class(EVariantError)
  public
    constructor Create;
  end;



{                                                                              }
{ Variant structures                                                           }
{                                                                              }

type
  TVariantType = (
    vtNone,

    vtWord8,
    vtWord16,
    vtWord32,
    vtWord64,
    vtWord128,
    vtWord256,
    vtHugeWord,

    vtInt8,
    vtInt16,
    vtInt32,
    vtInt64,
    vtInt128,
    vtInt256,
    vtHugeInt,

    vtSingle,
    vtDouble,
    vtExtended,
    vtCurrency,

    vtBoolean,
    vtAnsiChar,
    vtUCS2Char,
    vtUCS4Char,

    vtDateTime,
    vtDate,
    vtTime,

    vtShortString,
    vtRawByteString,
    vtAnsiString,
    vtWideString,
    vtUnicodeString,

    vtPAnsiChar,
    vtPWideChar,

    vtPointer,
    vtObject,
    vtIntfObject,
    vtInterface,
    vtClass,

    vtVariant,

    vtVariantArray,
    vtVariantDictionary
    );
  TVariantTypeSet = set of TVariantType;

  TVariantValueType = (
    vvtUnassigned,
    vvtAssignedValue,
    vvtAssignedNull,
    vvtAssignedDefault
    );

  PVariant = ^TVariant;
  PVariantArrayRec = ^TVariantArrayRec;
  PVariantDictionaryRec = ^TVariantDictionaryRec;

  TVariant = packed record
    ValueType : TVariantValueType;
    case VariantType : TVariantType of
      vtNone              : (ValueNone              : array[0..9] of Byte);
      vtWord8             : (ValueWord8             : Byte);
      vtWord16            : (ValueWord16            : Word);
      vtWord32            : (ValueWord32            : LongWord);
      vtWord64            : (ValueWord64            : Word64);
      vtWord128           : (ValueWord128           : PWord128);
      vtWord256           : (ValueWord256           : PWord256);
      vtHugeWord          : (ValueHugeWord          : PHugeWord);
      vtInt8              : (ValueInt8              : ShortInt);
      vtInt16             : (ValueInt16             : SmallInt);
      vtInt32             : (ValueInt32             : LongInt);
      vtInt64             : (ValueInt64             : Int64);
      vtInt128            : (ValueInt128            : PInt128);
      vtInt256            : (ValueInt256            : PInt256);
      vtHugeInt           : (ValueHugeInt           : PHugeInt);
      vtSingle            : (ValueSingle            : Single);
      vtDouble            : (ValueDouble            : Double);
      vtExtended          : (ValueExtended          : Extended);
      vtCurrency          : (ValueCurrency          : Currency);
      vtBoolean           : (ValueBoolean           : Boolean);
      vtAnsiChar          : (ValueAnsiChar          : AnsiChar);
      vtUCS2Char          : (ValueUCS2Char          : WideChar);
      vtUCS4Char          : (ValueUCS4Char          : LongWord);
      vtDateTime          : (ValueDateTime          : TDateTime);
      vtDate              : (ValueDate              : Double);
      vtTime              : (ValueTime              : Double);
      vtShortString       : (ValueShortString       : Pointer);
      vtRawByteString     : (ValueRawByteString     : Pointer);
      vtAnsiString        : (ValueAnsiString        : Pointer);
      vtWideString        : (ValueWideString        : Pointer);
      vtUnicodeString     : (ValueUnicodeString     : Pointer);
      vtPAnsiChar         : (ValuePAnsiChar         : PAnsiChar);
      vtPWideChar         : (ValuePWideChar         : PWideChar);
      vtPointer           : (ValuePointer           : Pointer);
      vtObject            : (ValueObject            : Pointer);
      vtIntfObject        : (ValueIntfObject        : Pointer);
      vtInterface         : (ValueInterface         : Pointer);
      vtClass             : (ValueClass             : TClass);
      vtVariant           : (ValueVariant           : PVariant);
      vtVariantArray      : (ValueVariantArray      : PVariantArrayRec);
      vtVariantDictionary : (ValueVariantDictionary : PVariantDictionaryRec);
  end;

  { Variant array structure  }

  TVariantArrayRec = record
    List : array of TVariant;
    Used : Integer;
  end;

  { Variant dictionary structure }

  TVariantDictionaryItem = record
    Name  : TVariant;
    Value : TVariant;
  end;
  PVariantDictionaryItem = ^TVariantDictionaryItem;

  TVariantDictionaryRec = record
    List : array of TVariantDictionaryItem;
    Used : Integer;
    Hash : array of array of Integer;
  end;

const
  VARIANT_STRUCTURE_SIZE = SizeOf(TVariant); // 12 bytes



{                                                                              }
{ Variant functions                                                            }
{                                                                              }

{ Variant Init / Variant Finalise }
{ VariantInit must be the first call on a variant to setup instance }
{ Every instantiated variant must be finalised with call to VariantFinalise }

procedure VariantInit(var V: TVariant);                                         {$IFDEF UseInline}inline;{$ENDIF}
procedure VariantInitType(var V: TVariant; const T: TVariantType);              {$IFDEF UseInline}inline;{$ENDIF}
procedure VariantInitNull(var V: TVariant);                                     {$IFDEF UseInline}inline;{$ENDIF}
procedure VariantInitNullType(var V: TVariant; const T: TVariantType);          {$IFDEF UseInline}inline;{$ENDIF}
procedure VariantInitDefault(var V: TVariant);                                  {$IFDEF UseInline}inline;{$ENDIF}
procedure VariantInitDefaultType(var V: TVariant; const T: TVariantType);       {$IFDEF UseInline}inline;{$ENDIF}
procedure VariantInitWord8(var V: TVariant; const A: Byte);                     {$IFDEF UseInline}inline;{$ENDIF}
procedure VariantInitWord16(var V: TVariant; const A: Word);                    {$IFDEF UseInline}inline;{$ENDIF}
procedure VariantInitWord32(var V: TVariant; const A: LongWord);                {$IFDEF UseInline}inline;{$ENDIF}
procedure VariantInitWord64(var V: TVariant; const A: Word64);                  {$IFDEF UseInline}inline;{$ENDIF}
procedure VariantInitWord128(var V: TVariant; const A: Word128);                {$IFDEF UseInline}inline;{$ENDIF}
procedure VariantInitWord256(var V: TVariant; const A: Word256);                {$IFDEF UseInline}inline;{$ENDIF}
procedure VariantInitHugeWord(var V: TVariant; const A: HugeWord);              {$IFDEF UseInline}inline;{$ENDIF}
procedure VariantInitInt8(var V: TVariant; const A: ShortInt);                  {$IFDEF UseInline}inline;{$ENDIF}
procedure VariantInitInt16(var V: TVariant; const A: SmallInt);                 {$IFDEF UseInline}inline;{$ENDIF}
procedure VariantInitInt32(var V: TVariant; const A: LongInt);                  {$IFDEF UseInline}inline;{$ENDIF}
procedure VariantInitInt64(var V: TVariant; const A: Int64);                    {$IFDEF UseInline}inline;{$ENDIF}
procedure VariantInitInt128(var V: TVariant; const A: Int128);                  {$IFDEF UseInline}inline;{$ENDIF}
procedure VariantInitInt256(var V: TVariant; const A: Int256);                  {$IFDEF UseInline}inline;{$ENDIF}
procedure VariantInitHugeInt(var V: TVariant; const A: HugeInt);                {$IFDEF UseInline}inline;{$ENDIF}
procedure VariantInitSingle(var V: TVariant; const A: Single);                  {$IFDEF UseInline}inline;{$ENDIF}
procedure VariantInitDouble(var V: TVariant; const A: Double);                  {$IFDEF UseInline}inline;{$ENDIF}
procedure VariantInitExtended(var V: TVariant; const A: Extended);              {$IFDEF UseInline}inline;{$ENDIF}
procedure VariantInitCurrency(var V: TVariant; const A: Currency);              {$IFDEF UseInline}inline;{$ENDIF}
procedure VariantInitBoolean(var V: TVariant; const A: Boolean);                {$IFDEF UseInline}inline;{$ENDIF}
procedure VariantInitAnsiChar(var V: TVariant; const A: AnsiChar);              {$IFDEF UseInline}inline;{$ENDIF}
procedure VariantInitUCS2Char(var V: TVariant; const A: UCS2Char);              {$IFDEF UseInline}inline;{$ENDIF}
procedure VariantInitUCS4Char(var V: TVariant; const A: LongWord);              {$IFDEF UseInline}inline;{$ENDIF}
procedure VariantInitDateTime(var V: TVariant; const A: TDateTime);             {$IFDEF UseInline}inline;{$ENDIF}
procedure VariantInitDate(var V: TVariant; const A: TDateTime);                 {$IFDEF UseInline}inline;{$ENDIF}
procedure VariantInitTime(var V: TVariant; const A: TDateTime);                 {$IFDEF UseInline}inline;{$ENDIF}
procedure VariantInitShortString(var V: TVariant; const A: ShortString);        {$IFDEF UseInline}inline;{$ENDIF}
procedure VariantInitRawByteString(var V: TVariant; const A: RawByteString);    {$IFDEF UseInline}inline;{$ENDIF}
procedure VariantInitAnsiString(var V: TVariant; const A: AnsiString);          {$IFDEF UseInline}inline;{$ENDIF}
procedure VariantInitWideString(var V: TVariant; const A: WideString);          {$IFDEF UseInline}inline;{$ENDIF}
procedure VariantInitUnicodeString(var V: TVariant; const A: UnicodeString);    {$IFDEF UseInline}inline;{$ENDIF}
procedure VariantInitString(var V: TVariant; const A: String);                  {$IFDEF UseInline}inline;{$ENDIF}
procedure VariantInitPAnsiChar(var V: TVariant; const A: PAnsiChar);            {$IFDEF UseInline}inline;{$ENDIF}
procedure VariantInitPWideChar(var V: TVariant; const A: PWideChar);            {$IFDEF UseInline}inline;{$ENDIF}
procedure VariantInitPointer(var V: TVariant; const A: Pointer);                {$IFDEF UseInline}inline;{$ENDIF}
procedure VariantInitObject(var V: TVariant; const A: TObject);                 {$IFDEF UseInline}inline;{$ENDIF}
procedure VariantInitIntfObject(var V: TVariant; const A: TInterfacedObject);   {$IFDEF UseInline}inline;{$ENDIF}
procedure VariantInitInterface(var V: TVariant; const A: IInterface);           {$IFDEF UseInline}inline;{$ENDIF}
procedure VariantInitClass(var V: TVariant; const A: TClass);                   {$IFDEF UseInline}inline;{$ENDIF}
procedure VariantInitVariant(var V: TVariant; const A: TVariant);
procedure VariantInitVariantUnassiged(var V: TVariant);
procedure VariantInitVariantArray(var V: TVariant; const A: TVariantArrayRec);
procedure VariantInitVariantDictionary(var V: TVariant; const A: TVariantDictionaryRec);
procedure VariantInitValue(var V: TVariant; const A: TVariant);
procedure VariantInitVarRec(var V: TVariant; const A: TVarRec);

procedure VariantFinalise(var V: TVariant);

{ Variant Copy }

function  VariantCopy(const V: TVariant): TVariant;                             {$IFDEF UseInline}inline;{$ENDIF}

{ Variant Clear }

procedure VariantClear(var V: TVariant);                                        {$IFDEF UseInline}inline;{$ENDIF}
procedure VariantClearValue(var V: TVariant);                                   {$IFDEF UseInline}inline;{$ENDIF}

{ Variant Value Tests }

function  VariantIsUnassigned(const V: TVariant): Boolean;                      {$IFDEF UseInline}inline;{$ENDIF}
function  VariantIsAssigned(const V: TVariant): Boolean;                        {$IFDEF UseInline}inline;{$ENDIF}
function  VariantIsAssignedValue(const V: TVariant): Boolean;                   {$IFDEF UseInline}inline;{$ENDIF}
function  VariantIsAssignedNull(const V: TVariant): Boolean;                    {$IFDEF UseInline}inline;{$ENDIF}
function  VariantIsAssignedDefault(const V: TVariant): Boolean;                 {$IFDEF UseInline}inline;{$ENDIF}

{ Variant Type Tests }

function  VariantTypeIs(const V: TVariant; const T: TVariantType): Boolean;     {$IFDEF UseInline}inline;{$ENDIF}
function  VariantTypeIsDefined(const V: TVariant): Boolean;                     {$IFDEF UseInline}inline;{$ENDIF}
function  VariantTypeIsInteger(const V: TVariant): Boolean;                     {$IFDEF UseInline}inline;{$ENDIF}
function  VariantTypeIsReal(const V: TVariant): Boolean;                        {$IFDEF UseInline}inline;{$ENDIF}
function  VariantTypeIsNumber(const V: TVariant): Boolean;                      {$IFDEF UseInline}inline;{$ENDIF}
function  VariantTypeIsString(const V: TVariant): Boolean;                      {$IFDEF UseInline}inline;{$ENDIF}
function  VariantTypeIsPointer(const V: TVariant): Boolean;                     {$IFDEF UseInline}inline;{$ENDIF}
function  VariantTypeIsObject(const V: TVariant): Boolean;                      {$IFDEF UseInline}inline;{$ENDIF}
function  VariantTypeIsArray(const V: TVariant): Boolean;                       {$IFDEF UseInline}inline;{$ENDIF}
function  VariantTypeIsDictionary(const V: TVariant): Boolean;                  {$IFDEF UseInline}inline;{$ENDIF}

{ Variant Assigned Value and Type Tests }

function  VariantIsAssignedValueInteger(const V: TVariant): Boolean;            {$IFDEF UseInline}inline;{$ENDIF}
function  VariantIsAssignedValueReal(const V: TVariant): Boolean;               {$IFDEF UseInline}inline;{$ENDIF}
function  VariantIsAssignedValueNumber(const V: TVariant): Boolean;             {$IFDEF UseInline}inline;{$ENDIF}
function  VariantIsAssignedValueString(const V: TVariant): Boolean;             {$IFDEF UseInline}inline;{$ENDIF}
function  VariantIsAssignedValuePointer(const V: TVariant): Boolean;            {$IFDEF UseInline}inline;{$ENDIF}
function  VariantIsAssignedValueObject(const V: TVariant): Boolean;             {$IFDEF UseInline}inline;{$ENDIF}
function  VariantIsAssignedValueArray(const V: TVariant): Boolean;              {$IFDEF UseInline}inline;{$ENDIF}
function  VariantIsAssignedValueDictionary(const V: TVariant): Boolean;         {$IFDEF UseInline}inline;{$ENDIF}

{ Variant Set }
{ Changes variant type to parameter type, no conversions }

procedure VariantSetUnassigned(var V: TVariant);                                {$IFDEF UseInline}inline;{$ENDIF}
procedure VariantSetNull(var V: TVariant);                                      {$IFDEF UseInline}inline;{$ENDIF}
procedure VariantSetDefault(var V: TVariant);                                   {$IFDEF UseInline}inline;{$ENDIF}
procedure VariantSetWord8(var V: TVariant; const A: Byte);                      {$IFDEF UseInline}inline;{$ENDIF}
procedure VariantSetWord16(var V: TVariant; const A: Word);                     {$IFDEF UseInline}inline;{$ENDIF}
procedure VariantSetWord32(var V: TVariant; const A: LongWord);                 {$IFDEF UseInline}inline;{$ENDIF}
procedure VariantSetWord64(var V: TVariant; const A: Word64);                   {$IFDEF UseInline}inline;{$ENDIF}
procedure VariantSetWord128(var V: TVariant; const A: Word128);
procedure VariantSetWord256(var V: TVariant; const A: Word256);
procedure VariantSetHugeWord(var V: TVariant; const A: HugeWord);
procedure VariantSetInt8(var V: TVariant; const A: ShortInt);                   {$IFDEF UseInline}inline;{$ENDIF}
procedure VariantSetInt16(var V: TVariant; const A: SmallInt);                  {$IFDEF UseInline}inline;{$ENDIF}
procedure VariantSetInt32(var V: TVariant; const A: LongInt);                   {$IFDEF UseInline}inline;{$ENDIF}
procedure VariantSetInt64(var V: TVariant; const A: Int64);                     {$IFDEF UseInline}inline;{$ENDIF}
procedure VariantSetInt128(var V: TVariant; const A: Int128);
procedure VariantSetInt256(var V: TVariant; const A: Int256);
procedure VariantSetHugeInt(var V: TVariant; const A: HugeInt);
procedure VariantSetSingle(var V: TVariant; const A: Single);                   {$IFDEF UseInline}inline;{$ENDIF}
procedure VariantSetDouble(var V: TVariant; const A: Double);                   {$IFDEF UseInline}inline;{$ENDIF}
procedure VariantSetExtended(var V: TVariant; const A: Extended);               {$IFDEF UseInline}inline;{$ENDIF}
procedure VariantSetCurrency(var V: TVariant; const A: Currency);               {$IFDEF UseInline}inline;{$ENDIF}
procedure VariantSetBoolean(var V: TVariant; const A: Boolean);                 {$IFDEF UseInline}inline;{$ENDIF}
procedure VariantSetAnsiChar(var V: TVariant; const A: AnsiChar);               {$IFDEF UseInline}inline;{$ENDIF}
procedure VariantSetUCS2Char(var V: TVariant; const A: WideChar);               {$IFDEF UseInline}inline;{$ENDIF}
procedure VariantSetUCS4Char(var V: TVariant; const A: LongWord);               {$IFDEF UseInline}inline;{$ENDIF}
procedure VariantSetDateTime(var V: TVariant; const A: TDateTime);              {$IFDEF UseInline}inline;{$ENDIF}
procedure VariantSetDate(var V: TVariant; const A: TDateTime);                  {$IFDEF UseInline}inline;{$ENDIF}
procedure VariantSetTime(var V: TVariant; const A: TDateTime);                  {$IFDEF UseInline}inline;{$ENDIF}
procedure VariantSetShortString(var V: TVariant; const A: ShortString);
procedure VariantSetRawByteString(var V: TVariant; const A: RawByteString);
procedure VariantSetAnsiString(var V: TVariant; const A: AnsiString);
procedure VariantSetWideString(var V: TVariant; const A: WideString);
procedure VariantSetUnicodeString(var V: TVariant; const A: UnicodeString);
procedure VariantSetString(var V: TVariant; const A: String);                   {$IFDEF UseInline}inline;{$ENDIF}
procedure VariantSetPointer(var V: TVariant; const A: Pointer);                 {$IFDEF UseInline}inline;{$ENDIF}
procedure VariantSetObject(var V: TVariant; const A: TObject);                  {$IFDEF UseInline}inline;{$ENDIF}
procedure VariantSetIntfObject(var V: TVariant; const A: TInterfacedObject);    {$IFDEF UseInline}inline;{$ENDIF}
procedure VariantSetInterface(var V: TVariant; const A: IInterface);            {$IFDEF UseInline}inline;{$ENDIF}
procedure VariantSetVariant(var V: TVariant; const A: TVariant);                {$IFDEF UseInline}inline;{$ENDIF}
procedure VariantSetVariantArray(var V: TVariant; const A: TVariantArrayRec);           {$IFDEF UseInline}inline;{$ENDIF}
procedure VariantSetVariantDictionary(var V: TVariant; const A: TVariantDictionaryRec); {$IFDEF UseInline}inline;{$ENDIF}
procedure VariantSetValue(var V: TVariant; const A: TVariant);                  {$IFDEF UseInline}inline;{$ENDIF}

{ Variant Assign }
{ Leaves variant type unchanged, converts parameter type to variant type }

procedure VariantAssignUnassigned(var V: TVariant);                             {$IFDEF UseInline}inline;{$ENDIF}
procedure VariantAssignNull(var V: TVariant);                                   {$IFDEF UseInline}inline;{$ENDIF}
procedure VariantAssignDefault(var V: TVariant);                                {$IFDEF UseInline}inline;{$ENDIF}
procedure VariantAssignWord8(var V: TVariant; const A: Byte);
procedure VariantAssignWord16(var V: TVariant; const A: Word);
procedure VariantAssignWord32(var V: TVariant; const A: LongWord);
procedure VariantAssignWord64(var V: TVariant; const A: Word64);
procedure VariantAssignWord128(var V: TVariant; const A: Word128);
procedure VariantAssignWord256(var V: TVariant; const A: Word256);
procedure VariantAssignHugeWord(var V: TVariant; const A: HugeWord);
procedure VariantAssignInt8(var V: TVariant; const A: ShortInt);
procedure VariantAssignInt16(var V: TVariant; const A: SmallInt);
procedure VariantAssignInt32(var V: TVariant; const A: LongInt);
procedure VariantAssignInt64(var V: TVariant; const A: Int64);
procedure VariantAssignInt128(var V: TVariant; const A: Int128);
procedure VariantAssignInt256(var V: TVariant; const A: Int256);
procedure VariantAssignHugeInt(var V: TVariant; const A: HugeInt);
procedure VariantAssignSingle(var V: TVariant; const A: Single);
procedure VariantAssignDouble(var V: TVariant; const A: Double);
procedure VariantAssignExtended(var V: TVariant; const A: Extended);
procedure VariantAssignCurrency(var V: TVariant; const A: Currency);
procedure VariantAssignBoolean(var V: TVariant; const A: Boolean);
procedure VariantAssignAnsiChar(var V: TVariant; const A: AnsiChar);
procedure VariantAssignUCS2Char(var V: TVariant; const A: WideChar);
procedure VariantAssignUCS4Char(var V: TVariant; const A: LongWord);
procedure VariantAssignDateTime(var V: TVariant; const A: TDateTime);
procedure VariantAssignDate(var V: TVariant; const A: TDateTime);
procedure VariantAssignTime(var V: TVariant; const A: TDateTime);
procedure VariantAssignShortString(var V: TVariant; const A: ShortString);
procedure VariantAssignAnsiString(var V: TVariant; const A: AnsiString);
procedure VariantAssignWideString(var V: TVariant; const A: WideString);
procedure VariantAssignUnicodeString(var V: TVariant; const A: UnicodeString);
procedure VariantAssignString(var V: TVariant; const A: String);                {$IFDEF UseInline}inline;{$ENDIF}
procedure VariantAssignPAnsiChar(var V: TVariant; const A: PAnsiChar);
procedure VariantAssignPointer(var V: TVariant; const A: Pointer);
procedure VariantAssignObject(var V: TVariant; const A: TObject);
procedure VariantAssignIntfObject(var V: TVariant; const A: TInterfacedObject);
procedure VariantAssignInterface(var V: TVariant; const A: IInterface);
procedure VariantAssignVariantArray(var V: TVariant; const A: TVariantArrayRec);
procedure VariantAssignVariantDictionary(var V: TVariant; const A: TVariantDictionaryRec);
procedure VariantAssignVariantValue(var V: TVariant; const A: TVariant);

{ Variant Conversion }

function  VariantToWord8(const V: TVariant): Byte;
function  VariantToWord16(const V: TVariant): Word;
function  VariantToWord32(const V: TVariant): LongWord;
function  VariantToWord64(const V: TVariant): Word64;
function  VariantToWord128(const V: TVariant): Word128;
function  VariantToWord256(const V: TVariant): Word256;
function  VariantToHugeWord(const V: TVariant): HugeWord;
function  VariantToInt8(const V: TVariant): ShortInt;
function  VariantToInt16(const V: TVariant): SmallInt;
function  VariantToInt32(const V: TVariant): LongInt;
function  VariantToInt64(const V: TVariant): Int64;
function  VariantToInt128(const V: TVariant): Int128;
function  VariantToInt256(const V: TVariant): Int256;
function  VariantToHugeInt(const V: TVariant): HugeInt;
function  VariantToSingle(const V: TVariant): Single;
function  VariantToDouble(const V: TVariant): Double;
function  VariantToExtended(const V: TVariant): Extended;
function  VariantToCurrency(const V: TVariant): Currency;
function  VariantToBoolean(const V: TVariant): Boolean;
function  VariantToAnsiChar(const V: TVariant): AnsiChar;
function  VariantToUCS2Char(const V: TVariant): WideChar;
function  VariantToUCS4Char(const V: TVariant): LongWord;
function  VariantToDateTime(const V: TVariant): TDateTime;
function  VariantToDate(const V: TVariant): TDateTime;
function  VariantToTime(const V: TVariant): TDateTime;
function  VariantToShortString(const V: TVariant): ShortString;
function  VariantToRawByteString(const V: TVariant): RawByteString;
function  VariantToAnsiString(const V: TVariant): AnsiString;
function  VariantToWideString(const V: TVariant): WideString;
function  VariantToUnicodeString(const V: TVariant): UnicodeString;
function  VariantToString(const V: TVariant): String;                           {$IFDEF UseInline}inline;{$ENDIF}
function  VariantToPAnsiChar(const V: TVariant): PAnsiChar;
function  VariantToPWideChar(const V: TVariant): PWideChar;
function  VariantToPointer(const V: TVariant): Pointer;
function  VariantToObject(const V: TVariant): TObject;
function  VariantToIntfObject(const V: TVariant): TInterfacedObject;
function  VariantToInterface(const V: TVariant): IInterface;
function  VariantToVariant(const V: TVariant): TVariant;
function  VariantToVariantArray(const V: TVariant): TVariantArrayRec;
function  VariantToVariantDictionary(const V: TVariant): TVariantDictionaryRec;

{ Variant Convert Type }

procedure VariantConvertToType(var V: TVariant; const T: TVariantType);

{ Variant Operations }

function  VariantsCompare(const A, B : TVariant): Integer;
function  VariantsEqual(const A, B : TVariant): Boolean;
function  VariantHash32(const A: TVariant): LongWord;




{                                                                              }
{ Variant array functions                                                      }
{                                                                              }

procedure VariantArrayInit(out A: TVariantArrayRec);                            {$IFDEF UseInline}inline;{$ENDIF}
procedure VariantArrayFinalise(var A: TVariantArrayRec);
function  VariantArrayGetLength(const A: TVariantArrayRec): Integer;            {$IFDEF UseInline}inline;{$ENDIF}
procedure VariantArraySetLength(var A: TVariantArrayRec; const L: Integer);
procedure VariantArrayClear(var A: TVariantArrayRec);
procedure VariantArrayAppendItem(var A: TVariantArrayRec; const B: TVariant);
procedure VariantArraySetItem(const A: TVariantArrayRec; const Idx: Integer; const B: TVariant);
procedure VariantArrayGetItem(const A: TVariantArrayRec; const Idx: Integer; out B: TVariant);
function  VariantArrayGetItemIndex(const A: TVariantArrayRec; const B: TVariant): Integer;
procedure VariantArrayRemove(var A: TVariantArrayRec; const Idx: Integer; const Count: Integer);
procedure VariantArrayDuplicate(const A: TVariantArrayRec; out B: TVariantArrayRec);
procedure VariantArrayInitOpenArray(out A: TVariantArrayRec; const B: array of const);
function  VariantArrayCompare(const A, B: TVariantArrayRec): Integer;
function  VariantArrayHash32(const A: TVariantArrayRec): LongWord;



{                                                                              }
{ Variant dictionary functions                                                 }
{                                                                              }

procedure VariantDictionaryInit(out A: TVariantDictionaryRec);
procedure VariantDictionaryFinalise(var A: TVariantDictionaryRec);
procedure VariantDictionaryAdd(var A: TVariantDictionaryRec; const Name, Value: TVariant);
function  VariantDictionaryGet(const A: TVariantDictionaryRec; const Name: TVariant; out Value: TVariant): Boolean;
procedure VariantDictionarySet(var A: TVariantDictionaryRec; const Name, Value: TVariant);
procedure VariantDictionaryRemove(var A: TVariantDictionaryRec; const Name: TVariant);
procedure VariantDictionaryDuplicate(const A: TVariantDictionaryRec; out B: TVariantDictionaryRec);
function  VariantDictionaryItemCount(const A: TVariantDictionaryRec): Integer;
procedure VariantDictionaryGetItemByIndex(const A: TVariantDictionaryRec; const Idx: Integer; out Name, Value: TVariant);
procedure VariantDictionaryInitOpenArray(out A: TVariantDictionaryRec; const B: array of const);
function  VariantDictionaryHash32(const A: TVariantDictionaryRec): LongWord;



{                                                                              }
{ Test cases                                                                   }
{                                                                              }
{$IFDEF DEBUG}
procedure SelfTest;
{$ENDIF}



implementation



{ Variant errors }

const
  SVariantConversionError = 'Variant conversion error';

constructor EVariantConvertError.Create;
begin
  inherited Create(SVariantConversionError);
end;



{ Variant Init }

procedure VariantZeroMem(var V: TVariant); {$IFDEF UseInline}inline;{$ENDIF}
var
  P : PInt64;
begin
  Assert(SizeOf(TVariant) = SizeOf(UInt64) + SizeOf(LongWord));
  P := @V;
  P^ := 0;
  Inc(P);
  PLongWord(P)^ := 0;
end;

procedure VariantInit(var V: TVariant);
begin
  V.ValueType := vvtUnassigned;
  V.VariantType := vtNone;
end;

procedure VariantInitType(var V: TVariant; const T: TVariantType);
begin
  V.ValueType := vvtUnassigned;
  V.VariantType := T;
end;

procedure VariantInitNull(var V: TVariant);
begin
  V.ValueType := vvtAssignedNull;
  V.VariantType := vtNone;
end;

procedure VariantInitNullType(var V: TVariant; const T: TVariantType);
begin
  V.ValueType := vvtAssignedNull;
  V.VariantType := T;
end;

procedure VariantInitDefault(var V: TVariant);
begin
  V.ValueType := vvtAssignedDefault;
  V.VariantType := vtNone;
end;

procedure VariantInitDefaultType(var V: TVariant; const T: TVariantType);
begin
  V.ValueType := vvtAssignedDefault;
  V.VariantType := T;
end;

procedure VariantInitWord8(var V: TVariant; const A: Byte);
begin
  V.ValueType := vvtAssignedValue;
  V.VariantType := vtWord8;
  V.ValueWord8 := A;
end;

procedure VariantInitWord16(var V: TVariant; const A: Word);
begin
  V.ValueType := vvtAssignedValue;
  V.VariantType := vtWord16;
  V.ValueWord16 := A;
end;

procedure VariantInitWord32(var V: TVariant; const A: LongWord);
begin
  V.ValueType := vvtAssignedValue;
  V.VariantType := vtWord32;
  V.ValueWord32 := A;
end;

procedure VariantInitWord64(var V: TVariant; const A: Word64);
begin
  V.ValueType := vvtAssignedValue;
  V.VariantType := vtWord64;
  V.ValueWord64 := A;
end;

procedure VariantInitWord128(var V: TVariant; const A: Word128);
begin
  VariantZeroMem(V);
  V.ValueType := vvtAssignedValue;
  V.VariantType := vtWord128;
  New(V.ValueWord128);
  V.ValueWord128^ := A;
end;

procedure VariantInitWord256(var V: TVariant; const A: Word256);
begin
  VariantZeroMem(V);
  V.ValueType := vvtAssignedValue;
  V.VariantType := vtWord256;
  New(V.ValueWord256);
  V.ValueWord256^ := A;
end;

procedure VariantInitHugeWord(var V: TVariant; const A: HugeWord);
begin
  VariantZeroMem(V);
  V.ValueType := vvtAssignedValue;
  V.VariantType := vtHugeWord;
  New(V.ValueHugeWord);
  HugeWordInitHugeWord(V.ValueHugeWord^, A);
end;

procedure VariantInitInt8(var V: TVariant; const A: ShortInt);
begin
  V.ValueType := vvtAssignedValue;
  V.VariantType := vtInt8;
  V.ValueInt8 := A;
end;

procedure VariantInitInt16(var V: TVariant; const A: SmallInt);
begin
  V.ValueType := vvtAssignedValue;
  V.VariantType := vtInt16;
  V.ValueInt16 := A;
end;

procedure VariantInitInt32(var V: TVariant; const A: LongInt);
begin
  V.ValueType := vvtAssignedValue;
  V.VariantType := vtInt32;
  V.ValueInt32 := A;
end;

procedure VariantInitInt64(var V: TVariant; const A: Int64);
begin
  V.ValueType := vvtAssignedValue;
  V.VariantType := vtInt64;
  V.ValueInt64 := A;
end;

procedure VariantInitInt128(var V: TVariant; const A: Int128);
begin
  VariantZeroMem(V);
  V.ValueType := vvtAssignedValue;
  V.VariantType := vtInt128;
  New(V.ValueInt128);
  V.ValueInt128^ := A;
end;

procedure VariantInitInt256(var V: TVariant; const A: Int256);
begin
  VariantZeroMem(V);
  V.ValueType := vvtAssignedValue;
  V.VariantType := vtInt256;
  New(V.ValueInt256);
  V.ValueInt256^ := A;
end;

procedure VariantInitHugeInt(var V: TVariant; const A: HugeInt);
begin
  VariantZeroMem(V);
  V.ValueType := vvtAssignedValue;
  V.VariantType := vtHugeInt;
  New(V.ValueHugeInt);
  HugeIntInitHugeInt(V.ValueHugeInt^, A);
end;

procedure VariantInitSingle(var V: TVariant; const A: Single);
begin
  V.ValueType := vvtAssignedValue;
  V.VariantType := vtSingle;
  V.ValueSingle := A;
end;

procedure VariantInitDouble(var V: TVariant; const A: Double);
begin
  V.ValueType := vvtAssignedValue;
  V.VariantType := vtDouble;
  V.ValueDouble := A;
end;

procedure VariantInitExtended(var V: TVariant; const A: Extended);
begin
  V.ValueType := vvtAssignedValue;
  V.VariantType := vtExtended;
  V.ValueExtended := A;
end;

procedure VariantInitCurrency(var V: TVariant; const A: Currency);
begin
  V.ValueType := vvtAssignedValue;
  V.VariantType := vtCurrency;
  V.ValueCurrency := A;
end;

procedure VariantInitBoolean(var V: TVariant; const A: Boolean);
begin
  V.ValueType := vvtAssignedValue;
  V.VariantType := vtBoolean;
  V.ValueBoolean := A;
end;

procedure VariantInitAnsiChar(var V: TVariant; const A: AnsiChar);
begin
  V.ValueType := vvtAssignedValue;
  V.VariantType := vtAnsiChar;
  V.ValueAnsiChar := A;
end;

procedure VariantInitUCS2Char(var V: TVariant; const A: UCS2Char);
begin
  V.ValueType := vvtAssignedValue;
  V.VariantType := vtUCS2Char;
  V.ValueUCS2Char := A;
end;

procedure VariantInitUCS4Char(var V: TVariant; const A: LongWord);
begin
  V.ValueType := vvtAssignedValue;
  V.VariantType := vtUCS4Char;
  V.ValueUCS4Char := A;
end;

procedure VariantInitDateTime(var V: TVariant; const A: TDateTime);
begin
  V.ValueType := vvtAssignedValue;
  V.VariantType := vtDateTime;
  V.ValueDateTime := A;
end;

procedure VariantInitDate(var V: TVariant; const A: TDateTime);
begin
  V.ValueType := vvtAssignedValue;
  V.VariantType := vtDate;
  V.ValueDate := Trunc(A);
end;

procedure VariantInitTime(var V: TVariant; const A: TDateTime);
begin
  V.ValueType := vvtAssignedValue;
  V.VariantType := vtTime;
  V.ValueTime := Frac(A);
end;

procedure VariantInitShortString(var V: TVariant; const A: ShortString);
begin
  VariantZeroMem(V);
  V.ValueType := vvtAssignedValue;
  V.VariantType := vtShortString;
  GetMem(V.ValueShortString, Length(A) + 1);
  PShortString(V.ValueShortString)^ := A;
end;

procedure VariantInitRawByteString(var V: TVariant; const A: RawByteString);
begin
  VariantZeroMem(V);
  V.ValueType := vvtAssignedValue;
  V.VariantType := vtRawByteString;
  V.ValueRawByteString := nil;
  RawByteString(V.ValueRawByteString) := A;
end;

procedure VariantInitAnsiString(var V: TVariant; const A: AnsiString);
begin
  VariantZeroMem(V);
  V.ValueType := vvtAssignedValue;
  V.VariantType := vtAnsiString;
  V.ValueAnsiString := nil;
  AnsiString(V.ValueAnsiString) := A;
end;

procedure VariantInitWideString(var V: TVariant; const A: WideString);
begin
  VariantZeroMem(V);
  V.ValueType := vvtAssignedValue;
  V.VariantType := vtWideString;
  V.ValueWideString := nil;
  WideString(V.ValueWideString) := A;
end;

procedure VariantInitUnicodeString(var V: TVariant; const A: UnicodeString);
begin
  VariantZeroMem(V);
  V.ValueType := vvtAssignedValue;
  V.VariantType := vtUnicodeString;
  V.ValueUnicodeString := nil;
  UnicodeString(V.ValueUnicodeString) := A;
end;

procedure VariantInitString(var V: TVariant; const A: String);
begin
  {$IFDEF StringIsUnicode}
  VariantInitUnicodeString(V, A);
  {$ELSE}
  VariantInitAnsiString(V, A);
  {$ENDIF}
end;

procedure VariantInitPAnsiChar(var V: TVariant; const A: PAnsiChar);
begin
  V.ValueType := vvtAssignedValue;
  V.VariantType := vtPAnsiChar;
  V.ValuePAnsiChar := A;
end;

procedure VariantInitPWideChar(var V: TVariant; const A: PWideChar);
begin
  V.ValueType := vvtAssignedValue;
  V.VariantType := vtPWideChar;
  V.ValuePWideChar := A;
end;

procedure VariantInitPointer(var V: TVariant; const A: Pointer);
begin
  VariantZeroMem(V);
  V.ValueType := vvtAssignedValue;
  V.VariantType := vtPointer;
  V.ValuePointer := A;
end;

procedure VariantInitObject(var V: TVariant; const A: TObject);
begin
  VariantZeroMem(V);
  V.ValueType := vvtAssignedValue;
  V.VariantType := vtObject;
  V.ValueObject := nil;
  TObject(V.ValueObject) := A;
end;

procedure VariantInitIntfObject(var V: TVariant; const A: TInterfacedObject);
begin
  VariantZeroMem(V);
  V.ValueType := vvtAssignedValue;
  V.VariantType := vtIntfObject;
  V.ValueIntfObject := nil;
  TInterfacedObject(V.ValueIntfObject) := A;
end;

procedure VariantInitInterface(var V: TVariant; const A: IInterface);
begin
  VariantZeroMem(V);
  V.ValueType := vvtAssignedValue;
  V.VariantType := vtInterface;
  V.ValueInterface := nil;
  IInterface(V.ValueInterface) := A;
end;

procedure VariantInitClass(var V: TVariant; const A: TClass);
begin
  VariantZeroMem(V);
  V.ValueType := vvtAssignedValue;
  V.VariantType := vtClass;
  V.ValueClass := A;
end;

procedure VariantInitVariant(var V: TVariant; const A: TVariant);
begin
  VariantZeroMem(V);
  V.ValueType := vvtAssignedValue;
  V.VariantType := vtVariant;
  New(V.ValueVariant);
  try
    VariantInitValue(V.ValueVariant^, A);
  except
    Dispose(V.ValueVariant);
    raise;
  end;
end;

procedure VariantInitVariantUnassiged(var V: TVariant);
begin
  VariantZeroMem(V);
  V.ValueType := vvtAssignedValue;
  V.VariantType := vtVariant;
  New(V.ValueVariant);
  VariantInit(V.ValueVariant^);
end;

procedure VariantInitVariantArray(var V: TVariant; const A: TVariantArrayRec);
begin
  VariantZeroMem(V);
  V.ValueType := vvtAssignedValue;
  V.VariantType := vtVariantArray;
  New(V.ValueVariantArray);
  try
    VariantArrayDuplicate(A, V.ValueVariantArray^);
  except
    Dispose(V.ValueVariantArray);
    raise;
  end;
end;

procedure VariantInitVariantDictionary(var V: TVariant; const A: TVariantDictionaryRec);
begin
  VariantZeroMem(V);
  V.ValueType := vvtUnassigned;
  V.VariantType := vtVariantDictionary;
  New(V.ValueVariantDictionary);
  try
    VariantDictionaryDuplicate(A, V.ValueVariantDictionary^);
  except
    Dispose(V.ValueVariantDictionary);
    raise;
  end;
end;

// Sets V to the value of variant A (i.e. copy value)
procedure VariantInitValue(var V: TVariant; const A: TVariant);
begin
  if A.ValueType = vvtAssignedValue then
    case A.VariantType of
      vtNone              : VariantInit(V);
      vtWord8             : VariantInitWord8(V, A.ValueWord8);
      vtWord16            : VariantInitWord16(V, A.ValueWord16);
      vtWord32            : VariantInitWord32(V, A.ValueWord32);
      vtWord64            : VariantInitWord64(V, A.ValueWord64);
      vtWord128           : VariantInitWord128(V, A.ValueWord128^);
      vtWord256           : VariantInitWord256(V, A.ValueWord256^);
      vtHugeWord          : VariantInitHugeWord(V, A.ValueHugeWord^);
      vtInt8              : VariantInitInt8(V, A.ValueInt8);
      vtInt16             : VariantInitInt16(V, A.ValueInt16);
      vtInt32             : VariantInitInt32(V, A.ValueInt32);
      vtInt64             : VariantInitInt64(V, A.ValueInt64);
      vtInt128            : VariantInitInt128(V, A.ValueInt128^);
      vtInt256            : VariantInitInt256(V, A.ValueInt256^);
      vtHugeInt           : VariantInitHugeInt(V, A.ValueHugeInt^);
      vtSingle            : VariantInitSingle(V, A.ValueSingle);
      vtDouble            : VariantInitDouble(V, A.ValueDouble);
      vtExtended          : VariantInitExtended(V, A.ValueExtended);
      vtCurrency          : VariantInitCurrency(V, A.ValueCurrency);
      vtBoolean           : VariantInitBoolean(V, A.ValueBoolean);
      vtAnsiChar          : VariantInitAnsiChar(V, A.ValueAnsiChar);
      vtUCS2Char          : VariantInitUCS2Char(V, A.ValueUCS2Char);
      vtUCS4Char          : VariantInitUCS4Char(V, A.ValueUCS4Char);
      vtDateTime          : VariantInitDateTime(V, A.ValueDateTime);
      vtDate              : VariantInitDate(V, A.ValueDate);
      vtTime              : VariantInitTime(V, A.ValueTime);
      vtShortString       : VariantInitShortString(V, PShortString(A.ValueShortString)^);
      vtRawByteString     : VariantInitRawByteString(V, RawByteString(A.ValueRawByteString));
      vtAnsiString        : VariantInitAnsiString(V, AnsiString(A.ValueAnsiString));
      vtWideString        : VariantInitWideString(V, WideString(A.ValueWideString));
      vtUnicodeString     : VariantInitUnicodeString(V, UnicodeString(A.ValueUnicodeString));
      vtPAnsiChar         : VariantInitPAnsiChar(V, A.ValuePAnsiChar);
      vtPWideChar         : VariantInitPWideChar(V, A.ValuePWideChar);
      vtPointer           : VariantInitPointer(V, A.ValuePointer);
      vtObject            : VariantInitObject(V, TObject(A.ValueObject));
      vtIntfObject        : VariantInitIntfObject(V, TInterfacedObject(A.ValueIntfObject));
      vtInterface         : VariantInitInterface(V, IInterface(A.ValueInterface));
      vtVariant           : VariantInitVariant(V, A.ValueVariant^);
      vtVariantArray      : VariantInitVariantArray(V, A.ValueVariantArray^);
      vtVariantDictionary : VariantInitVariantDictionary(V, A.ValueVariantDictionary^);
    else
      raise EVariantConvertError.Create;
    end
  else
    begin
      V.ValueType := A.ValueType;
      V.VariantType := A.VariantType;
    end;
end;

// TVarRec is an open array parameter value
procedure VariantInitVarRec(var V: TVariant; const A: TVarRec);
begin
  case A.VType of
    System.vtInteger       : VariantInitInt32(V, A.VInteger);
    System.vtBoolean       : VariantInitBoolean(V, A.VBoolean);
    System.vtChar          : VariantInitAnsiChar(V, A.VChar);
    System.vtExtended      : VariantInitExtended(V, A.VExtended^);
    System.vtString        : VariantInitRawByteString(V, A.VString^);
    System.vtPointer       : VariantInitPointer(V, A.VPointer);
    System.vtPChar         : VariantInitPAnsiChar(V, A.VPChar);
    System.vtObject        : VariantInitObject(V, A.VObject);
    System.vtClass         : VariantInitClass(V, A.VClass);
    System.vtWideChar      : VariantInitUCS2Char(V, A.VWideChar);
    System.vtPWideChar     : VariantInitPWideChar(V, A.VPWideChar);
    System.vtAnsiString    : VariantInitAnsiString(V, AnsiString(A.VAnsiString));
    System.vtCurrency      : VariantInitCurrency(V, A.VCurrency^);
    System.vtVariant       : raise EVariantError.Create('VarRec Variant not supported');
    System.vtInterface     : VariantInitInterface(V, IInterface(A.VInterface));
    System.vtWideString    : VariantInitWideString(V, WideString(A.VWideString));
    System.vtInt64         : VariantInitInt64(V, A.VInt64^);
    System.vtUnicodeString : VariantInitUnicodeString(V, UnicodeString(A.VUnicodeString));
  else
    raise EVariantError.CreateFmt('VarRec value type (%d) not supported', [Ord(A.VType)]);
  end;
end;

{ Variant Finalise }

procedure VariantFinaliseWord128(var V: PWord128);
begin
  Dispose(V);
  V := nil;
end;

procedure VariantFinaliseWord256(var V: PWord256);
begin
  Dispose(V);
  V := nil;
end;

procedure VariantFinaliseHugeWord(var V: PHugeWord);
begin
  if not Assigned(V) then
    exit;
  HugeWordFinalise(V^);
  Dispose(V);
  V := nil;
end;

procedure VariantFinaliseInt128(var V: PInt128);
begin
  Dispose(V);
  V := nil;
end;

procedure VariantFinaliseInt256(var V: PInt256);
begin
  Dispose(V);
  V := nil;
end;

procedure VariantFinaliseHugeInt(var V: PHugeInt);
begin
  if not Assigned(V) then
    exit;
  HugeIntFinalise(V^);
  Dispose(V);
  V := nil;
end;

procedure VariantFinaliseShortString(var V: Pointer);
begin
  FreeMem(V);
  V := nil;
end;

procedure VariantFinaliseVariantArray(var V: PVariantArrayRec);
begin
  VariantArrayFinalise(V^);
  V := nil;
end;

procedure VariantFinaliseVariantDictionary(var V: PVariantDictionaryRec);
var
  I : Integer;
  D : PVariantDictionaryItem;
begin
  for I := Length(V.List) - 1 downto 0 do
    begin
      D := @V.List[I];
      VariantFinalise(D^.Name);
      VariantFinalise(D^.Value);
    end;
  V.List := nil;
end;

procedure VariantFinaliseVariant(var V: PVariant);
begin
  if not Assigned(V) then
    exit;
  VariantFinalise(V^);
  Dispose(V);
  V := nil;
end;

// Frees memory
// does not change ValueType or VariantType
// may set Value to zero
procedure VariantFinalise(var V: TVariant);
begin
  if V.ValueType = vvtAssignedValue then
    case V.VariantType of
      vtInt128            : VariantFinaliseInt128(V.ValueInt128);
      vtInt256            : VariantFinaliseInt256(V.ValueInt256);
      vtHugeInt           : VariantFinaliseHugeInt(V.ValueHugeInt);
      vtWord128           : VariantFinaliseWord128(V.ValueWord128);
      vtWord256           : VariantFinaliseWord256(V.ValueWord256);
      vtHugeWord          : VariantFinaliseHugeWord(V.ValueHugeWord);
      vtShortString       : VariantFinaliseShortString(V.ValueShortString);
      vtRawByteString     : RawByteString(V.ValueRawByteString) := '';
      vtAnsiString        : AnsiString(V.ValueAnsiString) := '';
      vtWideString        : WideString(V.ValueWideString) := '';
      vtUnicodeString     : UnicodeString(V.ValueUnicodeString) := '';
      vtObject            : TObject(V.ValueObject) := nil;
      vtIntfObject        : TInterfacedObject(V.ValueIntfObject) := nil;
      vtInterface         : IInterface(V.ValueInterface) := nil;
      vtVariant           : VariantFinaliseVariant(V.ValueVariant);
      vtVariantArray      : VariantFinaliseVariantArray(V.ValueVariantArray);
      vtVariantDictionary : VariantFinaliseVariantDictionary(V.ValueVariantDictionary);
    end;
end;



{ Variant Copy }

function VariantCopy(const V: TVariant): TVariant;
begin
  VariantInitValue(Result, V);
end;



{ Variant Clear }

procedure VariantClear(var V: TVariant);
begin
  VariantFinalise(V);
  V.ValueType := vvtUnassigned;
  V.VariantType := vtNone;
end;

procedure VariantClearValue(var V: TVariant);
begin
  VariantFinalise(V);
  V.ValueType := vvtUnassigned;
end;





{ Variant type and value checking }

function VariantIsUnassigned(const V: TVariant): Boolean;
begin
  Result := V.ValueType = vvtUnassigned;
end;

function VariantIsAssigned(const V: TVariant): Boolean;
begin
  Result := V.ValueType <> vvtUnassigned;
end;

function VariantIsAssignedValue(const V: TVariant): Boolean;
begin
  Result := V.ValueType = vvtAssignedValue;
end;

function VariantIsAssignedNull(const V: TVariant): Boolean;
begin
  Result := V.ValueType = vvtAssignedNull;
end;

function VariantIsAssignedDefault(const V: TVariant): Boolean;
begin
  Result := V.ValueType = vvtAssignedDefault;
end;

function VariantTypeIs(const V: TVariant; const T: TVariantType): Boolean;
begin
  Result := V.VariantType = T;
end;

function VariantTypeIsDefined(const V: TVariant): Boolean;
begin
  Result := V.VariantType <> vtNone;
end;

function VariantTypeIsInteger(const V: TVariant): Boolean;
begin
  Result := V.VariantType in [
      vtWord8, vtWord16, vtWord32, vtWord64, vtWord128, vtWord256, vtHugeWord,
      vtInt8,  vtInt16,  vtInt32,  vtInt64,  vtInt128,  vtInt256,  vtHugeInt];
end;

function VariantTypeIsReal(const V: TVariant): Boolean;
begin
  Result := V.VariantType in [
      vtSingle, vtDouble, vtExtended,
      vtCurrency];
end;

function VariantTypeIsNumber(const V: TVariant): Boolean;
begin
  Result := V.VariantType in [
      vtWord8, vtWord16, vtWord32, vtWord64, vtWord128, vtWord256, vtHugeWord,
      vtInt8,  vtInt16,  vtInt32,  vtInt64,  vtInt128,  vtInt256,  vtHugeInt,
      vtSingle, vtDouble, vtExtended,
      vtCurrency];
end;

function VariantTypeIsString(const V: TVariant): Boolean;
begin
  Result := V.VariantType in [
      vtShortString, vtRawByteString, vtAnsiString, vtWideString, vtUnicodeString,
      vtPAnsiChar, vtPWideChar];
end;

function VariantTypeIsPointer(const V: TVariant): Boolean;
begin
  Result := V.VariantType in [vtPointer, vtObject, vtIntfObject, vtInterface];
end;

function VariantTypeIsObject(const V: TVariant): Boolean;
begin
  Result := V.VariantType in [vtObject, vtIntfObject];
end;

function VariantTypeIsArray(const V: TVariant): Boolean;
begin
  Result := V.VariantType = vtVariantArray;
end;

function VariantTypeIsDictionary(const V: TVariant): Boolean;
begin
  Result := V.VariantType = vtVariantDictionary;
end;

function VariantIsAssignedValueInteger(const V: TVariant): Boolean;
begin
  Result :=
      VariantIsAssignedValue(V) and
      VariantTypeIsInteger(V);
end;

function VariantIsAssignedValueReal(const V: TVariant): Boolean;
begin
  Result :=
      VariantIsAssignedValue(V) and
      VariantTypeIsReal(V);
end;

function VariantIsAssignedValueNumber(const V: TVariant): Boolean;
begin
  Result :=
      VariantIsAssignedValue(V) and
      VariantTypeIsNumber(V);
end;

function VariantIsAssignedValueString(const V: TVariant): Boolean;
begin
  Result :=
      VariantIsAssignedValue(V) and
      VariantTypeIsString(V);
end;

function VariantIsAssignedValuePointer(const V: TVariant): Boolean;
begin
  Result :=
      VariantIsAssignedValue(V) and
      VariantTypeIsPointer(V);
end;

function VariantIsAssignedValueObject(const V: TVariant): Boolean;
begin
  Result :=
      VariantIsAssignedValue(V) and
      VariantTypeIsObject(V);
end;

function VariantIsAssignedValueArray(const V: TVariant): Boolean;
begin
  Result :=
      VariantIsAssignedValue(V) and
      VariantTypeIsArray(V);
end;

function VariantIsAssignedValueDictionary(const V: TVariant): Boolean;
begin
  Result :=
      VariantIsAssignedValue(V) and
      VariantTypeIsDictionary(V);
end;



{ Variant Set }

procedure VariantSetUnassigned(var V: TVariant);
begin
  VariantFinalise(V);
  V.ValueType := vvtUnassigned;
end;

procedure VariantSetNull(var V: TVariant);
begin
  VariantFinalise(V);
  V.ValueType := vvtAssignedNull;
end;

procedure VariantSetDefault(var V: TVariant);
begin
  VariantFinalise(V);
  V.ValueType := vvtAssignedDefault;
end;

procedure VariantSetWord8(var V: TVariant; const A: Byte);
begin
  VariantFinalise(V);
  VariantInitWord8(V, A);
end;

procedure VariantSetWord16(var V: TVariant; const A: Word);
begin
  VariantFinalise(V);
  VariantInitWord16(V, A);
end;

procedure VariantSetWord32(var V: TVariant; const A: LongWord);
begin
  VariantFinalise(V);
  VariantInitWord32(V, A);
end;

procedure VariantSetWord64(var V: TVariant; const A: Word64);
begin
  VariantFinalise(V);
  VariantInitWord64(V, A);
end;

procedure VariantSetWord128(var V: TVariant; const A: Word128);
begin
  if (V.ValueType = vvtAssignedValue) and (V.VariantType = vtWord128) then
    V.ValueWord128^ := A
  else
    begin
      VariantFinalise(V);
      VariantInitWord128(V, A);
    end;
end;

procedure VariantSetWord256(var V: TVariant; const A: Word256);
begin
  if (V.ValueType = vvtAssignedValue) and (V.VariantType = vtWord256) then
    V.ValueWord256^ := A
  else
    begin
      VariantFinalise(V);
      VariantInitWord256(V, A);
    end;
end;

procedure VariantSetHugeWord(var V: TVariant; const A: HugeWord);
begin
  if (V.ValueType = vvtAssignedValue) and (V.VariantType = vtHugeWord) then
    HugeWordAssign(V.ValueHugeWord^, A)
  else
    begin
      VariantFinalise(V);
      VariantInitHugeWord(V, A);
    end;
end;

procedure VariantSetInt8(var V: TVariant; const A: ShortInt);
begin
  VariantFinalise(V);
  VariantInitInt8(V, A);
end;

procedure VariantSetInt16(var V: TVariant; const A: SmallInt);
begin
  VariantFinalise(V);
  VariantInitInt16(V, A);
end;

procedure VariantSetInt32(var V: TVariant; const A: LongInt);
begin
  VariantFinalise(V);
  VariantInitInt32(V, A);
end;

procedure VariantSetInt64(var V: TVariant; const A: Int64);
begin
  VariantFinalise(V);
  VariantInitInt64(V, A);
end;

procedure VariantSetInt128(var V: TVariant; const A: Int128);
begin
  if (V.ValueType = vvtAssignedValue) and (V.VariantType = vtInt128) then
    V.ValueInt128^ := A
  else
    begin
      VariantFinalise(V);
      VariantInitInt128(V, A);
    end;
end;

procedure VariantSetInt256(var V: TVariant; const A: Int256);
begin
  if (V.ValueType = vvtAssignedValue) and (V.VariantType = vtInt256) then
    V.ValueInt256^ := A
  else
    begin
      VariantFinalise(V);
      VariantInitInt256(V, A);
    end;
end;

procedure VariantSetHugeInt(var V: TVariant; const A: HugeInt);
begin
  if (V.ValueType = vvtAssignedValue) and (V.VariantType = vtHugeInt) then
    HugeIntAssign(V.ValueHugeInt^, A)
  else
    begin
      VariantFinalise(V);
      VariantInitHugeInt(V, A);
    end;
end;

procedure VariantSetSingle(var V: TVariant; const A: Single);
begin
  VariantFinalise(V);
  VariantInitSingle(V, A);
end;

procedure VariantSetDouble(var V: TVariant; const A: Double);
begin
  VariantFinalise(V);
  VariantInitDouble(V, A);
end;

procedure VariantSetExtended(var V: TVariant; const A: Extended);
begin
  VariantFinalise(V);
  VariantInitExtended(V, A);
end;

procedure VariantSetCurrency(var V: TVariant; const A: Currency);
begin
  VariantFinalise(V);
  VariantInitCurrency(V, A);
end;

procedure VariantSetBoolean(var V: TVariant; const A: Boolean);
begin
  VariantFinalise(V);
  VariantInitBoolean(V, A);
end;

procedure VariantSetAnsiChar(var V: TVariant; const A: AnsiChar);
begin
  VariantFinalise(V);
  VariantInitAnsiChar(V, A);
end;

procedure VariantSetUCS2Char(var V: TVariant; const A: WideChar);
begin
  VariantFinalise(V);
  VariantInitUCS2Char(V, A);
end;

procedure VariantSetUCS4Char(var V: TVariant; const A: LongWord);
begin
  VariantFinalise(V);
  VariantInitUCS4Char(V, A);
end;

procedure VariantSetDateTime(var V: TVariant; const A: TDateTime);
begin
  VariantFinalise(V);
  VariantInitDateTime(V, A);
end;

procedure VariantSetDate(var V: TVariant; const A: TDateTime);
begin
  VariantFinalise(V);
  VariantInitDate(V, A);
end;

procedure VariantSetTime(var V: TVariant; const A: TDateTime);
begin
  VariantFinalise(V);
  VariantInitTime(V, A);
end;

procedure VariantSetShortString(var V: TVariant; const A: ShortString);
begin
  if (V.ValueType = vvtAssignedValue) and (V.VariantType = vtShortString) then
    begin
      ReallocMem(V.ValueShortString, Length(A) + 1);
      PShortString(V.ValueShortString)^ := A
    end
  else
    begin
      VariantFinalise(V);
      VariantInitShortString(V, A);
    end;
end;

procedure VariantSetRawByteString(var V: TVariant; const A: RawByteString);
begin
  if (V.ValueType = vvtAssignedValue) and (V.VariantType = vtRawByteString) then
    RawByteString(V.ValueRawByteString) := A
  else
    begin
      VariantFinalise(V);
      VariantInitRawByteString(V, A);
    end;
end;

procedure VariantSetAnsiString(var V: TVariant; const A: AnsiString);
begin
  if (V.ValueType = vvtAssignedValue) and (V.VariantType = vtAnsiString) then
    AnsiString(V.ValueAnsiString) := A
  else
    begin
      VariantFinalise(V);
      VariantInitAnsiString(V, A);
    end;
end;

procedure VariantSetWideString(var V: TVariant; const A: WideString);
begin
  if (V.ValueType = vvtAssignedValue) and (V.VariantType = vtWideString) then
    WideString(V.ValueWideString) := A
  else
    begin
      VariantFinalise(V);
      VariantInitWideString(V, A);
    end;
end;

procedure VariantSetUnicodeString(var V: TVariant; const A: UnicodeString);
begin
  if (V.ValueType = vvtAssignedValue) and (V.VariantType = vtUnicodeString) then
    UnicodeString(V.ValueUnicodeString) := A
  else
    begin
      VariantFinalise(V);
      VariantInitUnicodeString(V, A);
    end;
end;

procedure VariantSetString(var V: TVariant; const A: String);
begin
  {$IFDEF StringIsUnicode}
  VariantSetUnicodeString(V, A);
  {$ELSE}
  VariantSetAnsiString(V, A);
  {$ENDIF}
end;

procedure VariantSetPointer(var V: TVariant; const A: Pointer);
begin
  VariantFinalise(V);
  VariantInitPointer(V, A);
end;

procedure VariantSetObject(var V: TVariant; const A: TObject);
begin
  VariantFinalise(V);
  VariantInitObject(V, A);
end;

procedure VariantSetIntfObject(var V: TVariant; const A: TInterfacedObject);
begin
  VariantFinalise(V);
  VariantInitIntfObject(V, A);
end;

procedure VariantSetInterface(var V: TVariant; const A: IInterface);
begin
  VariantFinalise(V);
  VariantInitInterface(V, A);
end;

procedure VariantSetVariant(var V: TVariant; const A: TVariant);
begin
  VariantFinalise(V);
  VariantInitVariant(V, A);
end;

procedure VariantSetVariantArray(var V: TVariant; const A: TVariantArrayRec);
begin
  VariantFinalise(V);
  VariantInitVariantArray(V, A);
end;

procedure VariantSetVariantDictionary(var V: TVariant; const A: TVariantDictionaryRec);
begin
  VariantFinalise(V);
  VariantInitVariantDictionary(V, A);
end;

procedure VariantSetValue(var V: TVariant; const A: TVariant);
begin
  VariantFinalise(V);
  VariantInitValue(V, A);
end;



{ Variant Assign }

procedure VariantAssignUnassigned(var V: TVariant);
begin
  VariantFinalise(V);
  V.ValueType := vvtUnassigned;
end;

procedure VariantAssignNull(var V: TVariant);
begin
  VariantFinalise(V);
  V.ValueType := vvtAssignedNull;
end;

procedure VariantAssignDefault(var V: TVariant);
begin
  VariantFinalise(V);
  V.ValueType := vvtAssignedDefault;
end;

// assign helper
// ensures variant has assigned value
procedure VariantEnsureAssignedValue(var V: TVariant);
begin
  if V.ValueType = vvtAssignedValue then
    exit;
  case V.VariantType of
    vtWord128           : New(V.ValueWord128);
    vtWord256           : New(V.ValueWord256);
    vtHugeWord          : New(V.ValueHugeWord);
    vtInt128            : New(V.ValueInt128);
    vtInt256            : New(V.ValueInt256);
    vtHugeInt           : New(V.ValueHugeInt);
    vtShortString       : VariantInitShortString(V, '');
    vtRawByteString     : V.ValueRawByteString := nil;
    vtAnsiString        : V.ValueAnsiString := nil;
    vtWideString        : V.ValueWideString := nil;
    vtUnicodeString     : V.ValueUnicodeString := nil;
    vtObject            : V.ValueObject := nil;
    vtIntfObject        : V.ValueIntfObject := nil;
    vtInterface         : V.ValueInterface := nil;
    vtVariant           : VariantInitVariantUnassiged(V.ValueVariant^);
    vtVariantArray      : New(V.ValueVariantArray);
    vtVariantDictionary : New(V.ValueVariantDictionary);
  end;
  V.ValueType := vvtAssignedValue;
end;

procedure VariantAssignWord8(var V: TVariant; const A: Byte);
begin
  VariantEnsureAssignedValue(V);
  case V.VariantType of
    vtWord8         : V.ValueWord8 := A;
    vtWord16        : V.ValueWord16 := A;
    vtWord32        : V.ValueWord32 := A;
    vtWord64        : Word64InitWord32(V.ValueWord64, A);
    vtWord128       : Word128InitWord32(V.ValueWord128^, A);
    vtWord256       : Word256InitWord32(V.ValueWord256^, A);
    vtHugeWord      : HugeWordAssignWord32(V.ValueHugeWord^, A);
    vtInt8          : if not Word8IsInt8Range(A) then
                        raise EVariantConvertError.Create
                      else
                        V.ValueInt8 := Int8(A);
    vtInt16         : V.ValueInt16 := A;
    vtInt32         : V.ValueInt32 := A;
    vtInt64         : V.ValueInt64 := A;
    vtInt128        : Int128InitWord32(V.ValueInt128^, A);
    vtInt256        : Int256InitWord32(V.ValueInt256^, A);
    vtHugeInt       : HugeIntAssignWord32(V.ValueHugeInt^, A);
    vtAnsiChar      : V.ValueAnsiChar := AnsiChar(A);
    vtUCS2Char      : V.ValueUCS2Char := WideChar(A);
    vtUCS4Char      : V.ValueUCS4Char := A;
    vtShortString   : VariantSetShortString(V, IntToStringA(A));
    vtRawByteString : VariantSetRawByteString(V, IntToStringB(A));
    vtAnsiString    : VariantSetAnsiString(V, IntToStringA(A));
    vtWideString    : VariantSetWideString(V, IntToStringW(A));
    vtUnicodeString : VariantSetUnicodeString(V, IntToStringU(A));
  else
    raise EVariantConvertError.Create;
  end;
end;

procedure VariantAssignWord16(var V: TVariant; const A: Word);
begin
  VariantEnsureAssignedValue(V);
  case V.VariantType of
    vtWord8         : if not Word16IsWord8Range(A) then
                        raise EVariantConvertError.Create
                      else
                        V.ValueWord8 := A;
    vtWord16        : V.ValueWord16 := A;
    vtWord32        : V.ValueWord32 := A;
    vtWord64        : Word64InitWord32(V.ValueWord64, A);
    vtWord128       : Word128InitWord32(V.ValueWord128^, A);
    vtWord256       : Word256InitWord32(V.ValueWord256^, A);
    vtHugeWord      : HugeWordAssignWord32(V.ValueHugeWord^, A);
    vtInt8          : if not Word16IsInt8Range(A) then
                        raise EVariantConvertError.Create
                      else
                        V.ValueInt8 := Int8(A);
    vtInt16         : if not Word16IsInt16Range(A) then
                        raise EVariantConvertError.Create
                      else
                        V.ValueInt16 := Int16(A);
    vtInt32         : V.ValueInt32 := A;
    vtInt64         : V.ValueInt64 := A;
    vtInt128        : Int128InitWord32(V.ValueInt128^, A);
    vtInt256        : Int256InitWord32(V.ValueInt256^, A);
    vtHugeInt       : HugeIntAssignWord32(V.ValueHugeInt^, A);
    vtAnsiChar      : if not Word16IsWord8Range(A) then
                        raise EVariantConvertError.Create
                      else
                        V.ValueAnsiChar := AnsiChar(Byte(A));
    vtUCS2Char      : V.ValueUCS2Char := WideChar(A);
    vtUCS4Char      : V.ValueUCS4Char := A;
    vtShortString   : VariantSetShortString(V, IntToStringA(A));
    vtRawByteString : VariantSetRawByteString(V, IntToStringB(A));
    vtAnsiString    : VariantSetAnsiString(V, IntToStringA(A));
    vtWideString    : VariantSetWideString(V, IntToStringW(A));
    vtUnicodeString : VariantSetUnicodeString(V, IntToStringU(A));
  else
    raise EVariantConvertError.Create;
  end;
end;

procedure VariantAssignWord32(var V: TVariant; const A: LongWord);
begin
  VariantEnsureAssignedValue(V);
  case V.VariantType of
    vtWord8         : if not Word32IsWord8Range(A) then
                        raise EVariantConvertError.Create
                      else
                        V.ValueWord8 := A;
    vtWord16        : if not Word32IsWord16Range(A) then
                        raise EVariantConvertError.Create
                      else
                        V.ValueWord8 := A;
    vtWord32        : V.ValueWord32 := A;
    vtWord64        : Word64InitWord32(V.ValueWord64, A);
    vtWord128       : Word128InitWord32(V.ValueWord128^, A);
    vtWord256       : Word256InitWord32(V.ValueWord256^, A);
    vtHugeWord      : HugeWordAssignWord32(V.ValueHugeWord^, A);
    vtInt8          : if not Word16IsInt8Range(A) then
                        raise EVariantConvertError.Create
                      else
                        V.ValueInt8 := Int8(A);
    vtInt16         : if not Word16IsInt16Range(A) then
                        raise EVariantConvertError.Create
                      else
                        V.ValueInt16 := Int16(A);
    vtInt32         : if not Word32IsInt32Range(A) then
                        raise EVariantConvertError.Create
                      else
                        V.ValueInt32 := Int32(A);
    vtInt64         : V.ValueInt64 := A;
    vtInt128        : Int128InitWord32(V.ValueInt128^, A);
    vtInt256        : Int256InitWord32(V.ValueInt256^, A);
    vtHugeInt       : HugeIntAssignWord32(V.ValueHugeInt^, A);
    vtAnsiChar      : if not Word32IsWord8Range(A) then
                        raise EVariantConvertError.Create
                      else
                        V.ValueAnsiChar := AnsiChar(Byte(A));
    vtUCS2Char      : if not Word32IsWord16Range(A) then
                        raise EVariantConvertError.Create
                      else
                        V.ValueUCS2Char := WideChar(A);
    vtUCS4Char      : V.ValueUCS4Char := A;
    vtShortString   : VariantSetShortString(V, IntToStringA(A));
    vtRawByteString : VariantSetRawByteString(V, IntToStringB(A));
    vtAnsiString    : VariantSetAnsiString(V, IntToStringA(A));
    vtWideString    : VariantSetWideString(V, IntToStringW(A));
    vtUnicodeString : VariantSetUnicodeString(V, IntToStringU(A));
  else
    raise EVariantConvertError.Create;
  end;
end;

procedure VariantAssignWord64(var V: TVariant; const A: Word64);
begin
  VariantEnsureAssignedValue(V);
  case V.VariantType of
    vtWord8         : if not Word64IsWord8Range(A) then
                        raise EVariantConvertError.Create
                      else
                        V.ValueWord8 := Word8(Word64ToWord32(A));
    vtWord16        : if not Word64IsWord16Range(A) then
                        raise EVariantConvertError.Create
                      else
                        V.ValueWord16 := Word16(Word64ToWord32(A));
    vtWord32        : if not Word64IsWord32Range(A) then
                        raise EVariantConvertError.Create
                      else
                        V.ValueWord32 := Word64ToWord32(A);
    vtWord64        : V.ValueWord64 := A;
    vtWord128       : Word128InitWord64(V.ValueWord128^, A);
    vtWord256       : Word256InitWord64(V.ValueWord256^, A);
    // vtHugeWord      : HugeWordAssignWord64(V.ValueHugeWord^, A);
    vtInt8          : if not Word64IsInt8Range(A) then
                        raise EVariantConvertError.Create
                      else
                        V.ValueInt8 := Int8(Word64ToInt32(A));
    vtInt16         : if not Word64IsInt16Range(A) then
                        raise EVariantConvertError.Create
                      else
                        V.ValueInt16 := Int16(Word64ToInt32(A));
    vtInt32         : if not Word64IsInt32Range(A) then
                        raise EVariantConvertError.Create
                      else
                        V.ValueInt8 := Word64ToInt32(A);
    vtInt64         : if not Word64IsInt64Range(A) then
                        raise EVariantConvertError.Create
                      else
                        V.ValueInt64 := Word64ToInt64(A);
    vtInt128        : Int128InitWord64(V.ValueInt128^, A);
    vtInt256        : Int256InitWord64(V.ValueInt256^, A);
    // vtHugeInt       : HugeIntAssignWord64(V.ValueHugeInt^, A);
    vtAnsiChar      : if not Word64IsWord8Range(A) then
                        raise EVariantConvertError.Create
                      else
                        V.ValueAnsiChar := AnsiChar(Word64ToWord32(A));
    vtUCS2Char      : if not Word64IsWord16Range(A) then
                        raise EVariantConvertError.Create
                      else
                        V.ValueUCS2Char := WideChar(Word64ToWord32(A));
    vtUCS4Char      : if not Word64IsWord32Range(A) then
                        raise EVariantConvertError.Create
                      else
                        V.ValueUCS4Char := Word64ToWord32(A);
    vtShortString   : VariantSetShortString(V, Word64ToStrA(A));
    // vtRawByteString : VariantSetRawByteString(V, Word64ToStrB(A));
    vtAnsiString    : VariantSetAnsiString(V, Word64ToStrA(A));
    vtWideString    : VariantSetWideString(V, Word64ToStrW(A));
    vtUnicodeString : VariantSetUnicodeString(V, Word64ToStrU(A));
  else
    raise EVariantConvertError.Create;
  end;
end;

procedure VariantAssignWord128(var V: TVariant; const A: Word128);
begin
  VariantEnsureAssignedValue(V);
  case V.VariantType of
    vtWord8         : if not Word128IsWord8Range(A) then
                        raise EVariantConvertError.Create
                      else
                        V.ValueWord8 := Word8(Word128ToWord32(A));
    vtWord16        : if not Word128IsWord16Range(A) then
                        raise EVariantConvertError.Create
                      else
                        V.ValueWord16 := Word16(Word128ToWord32(A));
    vtWord32        : if not Word128IsWord32Range(A) then
                        raise EVariantConvertError.Create
                      else
                        V.ValueWord32 := Word128ToWord32(A);
    vtWord64        : if not Word128IsWord64Range(A) then
                        raise EVariantConvertError.Create
                      else
                        V.ValueWord64 := Word128ToWord64(A);
    vtWord128       : V.ValueWord128^ := A;
    vtWord256       : Word256InitWord128(V.ValueWord256^, A);
    // vtHugeWord      : HugeWordAssignWord128(V.ValueHugeWord^, A);
    vtInt8          : if not Word128IsInt8Range(A) then
                        raise EVariantConvertError.Create
                      else
                        V.ValueInt8 := Int8(Word128ToInt32(A));
    vtInt16         : if not Word128IsInt16Range(A) then
                        raise EVariantConvertError.Create
                      else
                        V.ValueInt16 := Int16(Word128ToInt32(A));
    vtInt32         : if not Word128IsInt32Range(A) then
                        raise EVariantConvertError.Create
                      else
                        V.ValueInt8 := Word128ToInt32(A);
    vtInt64         : if not Word128IsInt64Range(A) then
                        raise EVariantConvertError.Create
                      else
                        V.ValueInt64 := Word128ToInt64(A);
//    vtInt128        : if not Word128IsInt128Range(A) then
//                        raise EVariantConvertError.Create
//                      else
//                        V.ValueInt128^ := Word128ToInt128(A);
//    vtInt256        : Int256InitWord128(V.ValueInt256^, A);
//    vtHugeInt       : HugeIntAssignWord128(V.ValueHugeInt^, A);
    vtAnsiChar      : if not Word128IsWord8Range(A) then
                        raise EVariantConvertError.Create
                      else
                        V.ValueAnsiChar := AnsiChar(Word128ToWord32(A));
    vtUCS2Char      : if not Word128IsWord16Range(A) then
                        raise EVariantConvertError.Create
                      else
                        V.ValueUCS2Char := WideChar(Word128ToWord32(A));
    vtUCS4Char      : if not Word128IsWord32Range(A) then
                        raise EVariantConvertError.Create
                      else
                        V.ValueUCS4Char := Word128ToWord32(A);
    vtShortString   : VariantSetShortString(V, Word128ToStrA(A));
    // vtRawByteString : VariantSetRawByteString(V, Word128ToStrB(A));
    vtAnsiString    : VariantSetAnsiString(V, Word128ToStrA(A));
    vtWideString    : VariantSetWideString(V, Word128ToStrW(A));
    vtUnicodeString : VariantSetUnicodeString(V, Word128ToStrU(A));
  else
    raise EVariantConvertError.Create;
  end;
end;

procedure VariantAssignWord256(var V: TVariant; const A: Word256);
begin
  VariantEnsureAssignedValue(V);
  case V.VariantType of
//    vtWord8         : if not Word256IsWord8Range(A) then
//                        raise EVariantConvertError.Create
//                      else
//                        V.ValueWord8 := Word8(Word256ToWord32(A));
//    vtWord16        : if not Word256IsWord16Range(A) then
//                        raise EVariantConvertError.Create
//                      else
//                        V.ValueWord16 := Word16(Word256ToWord32(A));
    vtWord32        : if not Word256IsWord32Range(A) then
                        raise EVariantConvertError.Create
                      else
                        V.ValueWord32 := Word256ToWord32(A);
    vtWord64        : if not Word256IsWord64Range(A) then
                        raise EVariantConvertError.Create
                      else
                        V.ValueWord64 := Word256ToWord64(A);
    vtWord128       : if not Word256IsWord64Range(A) then
                        raise EVariantConvertError.Create
                      else
                        V.ValueWord128^ := Word256ToWord128(A);
    vtWord256       : V.ValueWord256^ := A;
//    vtHugeWord      : HugeWordAssignWord256(V.ValueHugeWord^, A);
//    vtInt8          : if not Word256IsInt8Range(A) then
//                        raise EVariantConvertError.Create
//                      else
//                        V.ValueInt8 := Int8(Word256ToInt32(A));
//    vtInt16         : if not Word256IsInt16Range(A) then
//                        raise EVariantConvertError.Create
//                      else
//                        V.ValueInt16 := Int16(Word256ToInt32(A));
    vtInt32         : if not Word256IsInt32Range(A) then
                        raise EVariantConvertError.Create
                      else
                        V.ValueInt8 := Word256ToInt32(A);
    vtInt64         : if not Word256IsInt64Range(A) then
                        raise EVariantConvertError.Create
                      else
                        V.ValueInt64 := Word256ToInt64(A);
    vtInt128        : if not Word256IsInt128Range(A) then
                        raise EVariantConvertError.Create
                      else
                        V.ValueInt128^ := Word256ToInt128(A);
//    vtInt256        : if not Word256IsInt256Range(A) then
//                        raise EVariantConvertError.Create
//                      else
//                        V.ValueInt128^ := Word256ToInt128(A);
//    vtHugeInt       : HugeIntAssignWord256(V.ValueHugeInt^, A);
//    vtAnsiChar      : if not Word256IsWord8Range(A) then
//                        raise EVariantConvertError.Create
//                      else
//                        V.ValueAnsiChar := AnsiChar(Word256ToWord32(A));
//    vtUCS2Char      : if not Word256IsWord16Range(A) then
//                        raise EVariantConvertError.Create
//                      else
//                        V.ValueUCS2Char := WideChar(Word256ToWord32(A));
    vtUCS4Char      : if not Word256IsWord32Range(A) then
                        raise EVariantConvertError.Create
                      else
                        V.ValueUCS4Char := Word256ToWord32(A);
    // vtShortString   : VariantSetShortString(V, Word256ToStrA(A));
    // vtAnsiString    : VariantSetAnsiString(V, Word256ToStrA(A));
    // vtWideString    : VariantSetWideString(V, Word256ToStrW(A));
    // vtUnicodeString : VariantSetUnicodeString(V, Word256ToStrU(A));
  else
    raise EVariantConvertError.Create;
  end;
end;

procedure VariantAssignHugeWord(var V: TVariant; const A: HugeWord);
begin
  VariantEnsureAssignedValue(V);
  case V.VariantType of
    vtWord32        : if not HugeWordIsWord32Range(A) then
                        raise EVariantConvertError.Create
                      else
                        V.ValueWord32 := HugeWordToWord32(A);
    vtHugeWord      : HugeWordAssign(V.ValueHugeWord^, A);
    vtInt32         : if not HugeWordIsInt32Range(A) then
                        raise EVariantConvertError.Create
                      else
                        V.ValueInt32 := HugeWordToInt32(A);
    vtInt64         : if not HugeWordIsInt64Range(A) then
                        raise EVariantConvertError.Create
                      else
                        V.ValueInt64 := HugeWordToInt64(A);
  else
    raise EVariantConvertError.Create;
  end;
end;

procedure VariantAssignInt8(var V: TVariant; const A: ShortInt);
begin
  VariantEnsureAssignedValue(V);
  case V.VariantType of
    vtWord8,
    vtWord16,
    vtWord32,
    vtWord64,
    vtWord128,
    vtWord256,
    vtHugeWord      : begin
                        if A < 0 then
                          raise EVariantConvertError.Create;
                        case V.VariantType of
                          vtWord8    : V.ValueWord8 := Byte(A);
                          vtWord16   : V.ValueWord16 := Word(A);
                          vtWord32   : V.ValueWord32 := LongWord(A);
                          vtWord64   : Word64InitInt32(V.ValueWord64, A);
                          vtWord128  : Word128InitInt32(V.ValueWord128^, A);
                          vtWord256  : Word256InitInt32(V.ValueWord256^, A);
                          vtHugeWord : HugeWordInitInt32(V.ValueHugeWord^, A);
                        end;
                      end;
    vtInt8          : V.ValueInt8 := A;
    vtInt16         : V.ValueInt16 := A;
    vtInt32         : V.ValueInt32 := A;
    vtInt64         : V.ValueInt64 := A;
    vtInt128        : Int128InitInt32(V.ValueInt128^, A);
    vtInt256        : Int256InitInt32(V.ValueInt256^, A);
    vtHugeInt       : HugeIntInitInt32(V.ValueHugeInt^, A);
    vtAnsiChar      : if not Int8IsWord8Range(A) then
                        raise EVariantConvertError.Create
                      else
                        V.ValueAnsiChar := AnsiChar(Byte(A));
    vtUCS2Char      : if not Int8IsWord8Range(A) then
                        raise EVariantConvertError.Create
                      else
                        V.ValueUCS2Char := WideChar(Byte(A));
    vtUCS4Char      : if not Int8IsWord8Range(A) then
                        raise EVariantConvertError.Create
                      else
                        V.ValueUCS4Char := Byte(A);
    vtSingle        : V.ValueSingle := A;
    vtDouble        : V.ValueDouble := A;
    vtExtended      : V.ValueExtended := A;
    vtCurrency      : V.ValueCurrency := A;
    vtShortString   : VariantSetShortString(V, IntToStringA(A));
    vtRawByteString : VariantSetRawByteString(V, IntToStringB(A));
    vtAnsiString    : VariantSetAnsiString(V, IntToStringA(A));
    vtWideString    : VariantSetWideString(V, IntToStringW(A));
    vtUnicodeString : VariantSetUnicodeString(V, IntToStringU(A));
  else
    raise EVariantConvertError.Create;
  end;
end;

procedure VariantAssignInt16(var V: TVariant; const A: SmallInt);
begin
  VariantEnsureAssignedValue(V);
  case V.VariantType of
    vtWord8         : if not Int16IsWord8Range(A) then
                        raise EVariantConvertError.Create
                      else
                        V.ValueWord8 := Byte(A);
    vtWord16        : if not Int16IsWord16Range(A) then
                        raise EVariantConvertError.Create
                      else
                        V.ValueWord16 := Word(A);
    vtWord32,
    vtWord64,
    vtWord128,
    vtWord256,
    vtHugeWord      : begin
                        if A < 0 then
                          raise EVariantConvertError.Create;
                        case V.VariantType of
                          vtWord32   : V.ValueWord32 := LongWord(A);
                          vtWord64   : Word64InitInt32(V.ValueWord64, A);
                          vtWord128  : Word128InitInt32(V.ValueWord128^, A);
                          vtWord256  : Word256InitInt32(V.ValueWord256^, A);
                          vtHugeWord : HugeWordInitInt32(V.ValueHugeWord^, A);
                        end;
                      end;
    vtInt8          : if not Int16IsInt8Range(A) then
                        raise EVariantConvertError.Create
                      else
                        V.ValueInt8 := ShortInt(A);
    vtInt16         : V.ValueInt16 := A;
    vtInt32         : V.ValueInt32 := A;
    vtInt64         : V.ValueInt64 := A;
    vtInt128        : Int128InitInt32(V.ValueInt128^, A);
    vtInt256        : Int256InitInt32(V.ValueInt256^, A);
    vtHugeInt       : HugeIntInitInt32(V.ValueHugeInt^, A);
    vtAnsiChar      : if not Int16IsWord8Range(A) then
                        raise EVariantConvertError.Create
                      else
                        V.ValueAnsiChar := AnsiChar(Byte(A));
    vtUCS2Char      : if not Int16IsWord16Range(A) then
                        raise EVariantConvertError.Create
                      else
                        V.ValueUCS2Char := WideChar(Word(A));
    vtUCS4Char      : if not Int16IsWord16Range(A) then
                        raise EVariantConvertError.Create
                      else
                        V.ValueUCS4Char := Word(A);
    vtSingle        : V.ValueSingle := A;
    vtDouble        : V.ValueDouble := A;
    vtExtended      : V.ValueExtended := A;
    vtCurrency      : V.ValueCurrency := A;
    vtShortString   : VariantSetShortString(V, IntToStringA(A));
    vtRawByteString : VariantSetRawByteString(V, IntToStringB(A));
    vtAnsiString    : VariantSetAnsiString(V, IntToStringA(A));
    vtWideString    : VariantSetWideString(V, IntToStringW(A));
    vtUnicodeString : VariantSetUnicodeString(V, IntToStringU(A));
  else
    raise EVariantConvertError.Create;
  end;
end;

procedure VariantAssignInt32(var V: TVariant; const A: LongInt);
begin
  VariantEnsureAssignedValue(V);
  case V.VariantType of
    vtWord8         : if not Int32IsWord8Range(A) then
                        raise EVariantConvertError.Create
                      else
                        V.ValueWord8 := Byte(A);
    vtWord16        : if not Int32IsWord16Range(A) then
                        raise EVariantConvertError.Create
                      else
                        V.ValueWord16 := Word(A);
    vtWord32        : if not Int32IsWord32Range(A) then
                        raise EVariantConvertError.Create
                      else
                        V.ValueWord32 := LongWord(A);
    vtWord64,
    vtWord128,
    vtWord256,
    vtHugeWord      : begin
                        if A < 0 then
                          raise EVariantConvertError.Create;
                        case V.VariantType of
                          vtWord64   : Word64InitInt32(V.ValueWord64, A);
                          vtWord128  : Word128InitInt32(V.ValueWord128^, A);
                          vtWord256  : Word256InitInt32(V.ValueWord256^, A);
                          vtHugeWord : HugeWordInitInt32(V.ValueHugeWord^, A);
                        end;
                      end;
    vtInt8          : if not Int32IsInt8Range(A) then
                        raise EVariantConvertError.Create
                      else
                        V.ValueInt8 := ShortInt(A);
    vtInt16         : if not Int32IsInt16Range(A) then
                        raise EVariantConvertError.Create
                      else
                        V.ValueInt16 := SmallInt(A);
    vtInt32         : V.ValueInt32 := A;
    vtInt64         : V.ValueInt64 := A;
    vtInt128        : Int128InitInt32(V.ValueInt128^, A);
    vtInt256        : Int256InitInt32(V.ValueInt256^, A);
    vtHugeInt       : HugeIntInitInt32(V.ValueHugeInt^, A);
    vtAnsiChar      : if not Int32IsWord8Range(A) then
                        raise EVariantConvertError.Create
                      else
                        V.ValueAnsiChar := AnsiChar(Byte(A));
    vtUCS2Char      : if not Int32IsWord16Range(A) then
                        raise EVariantConvertError.Create
                      else
                        V.ValueUCS2Char := WideChar(Word(A));
    vtUCS4Char      : if not Int32IsWord32Range(A) then
                        raise EVariantConvertError.Create
                      else
                        V.ValueUCS4Char := LongWord(A);
    vtSingle        : V.ValueSingle := A;
    vtDouble        : V.ValueDouble := A;
    vtExtended      : V.ValueExtended := A;
    vtCurrency      : V.ValueCurrency := A;
    vtShortString   : VariantSetShortString(V, IntToStringA(A));
    vtRawByteString : VariantSetRawByteString(V, IntToStringB(A));
    vtAnsiString    : VariantSetAnsiString(V, IntToStringA(A));
    vtWideString    : VariantSetWideString(V, IntToStringW(A));
    vtUnicodeString : VariantSetUnicodeString(V, IntToStringU(A));
  else
    raise EVariantConvertError.Create;
  end;
end;

procedure VariantAssignInt64(var V: TVariant; const A: Int64);
begin
  VariantEnsureAssignedValue(V);
  case V.VariantType of
    vtWord8         : if not Int64IsWord8Range(A) then
                        raise EVariantConvertError.Create
                      else
                        V.ValueWord8 := Byte(A);
    vtWord16        : if not Int64IsWord16Range(A) then
                        raise EVariantConvertError.Create
                      else
                        V.ValueWord16 := Word(A);
    vtWord32        : if not Int64IsWord32Range(A) then
                        raise EVariantConvertError.Create
                      else
                        V.ValueWord32 := LongWord(A);
    vtWord64        : if not Int64IsWord64Range(A) then
                        raise EVariantConvertError.Create
                      else
                        Word64InitInt64(V.ValueWord64, A);
    vtWord128,
    vtWord256,
    vtHugeWord      : begin
                        if A < 0 then
                          raise EVariantConvertError.Create;
                        case V.VariantType of
                          vtWord128  : Word128InitInt64(V.ValueWord128^, A);
                          vtWord256  : Word256InitInt64(V.ValueWord256^, A);
                          vtHugeWord : HugeWordInitInt64(V.ValueHugeWord^, A);
                        end;
                      end;
    vtInt8          : if not Int64IsInt8Range(A) then
                        raise EVariantConvertError.Create
                      else
                        V.ValueInt8 := ShortInt(A);
    vtInt16         : if not Int64IsInt16Range(A) then
                        raise EVariantConvertError.Create
                      else
                        V.ValueInt16 := SmallInt(A);
    vtInt32         : if not Int64IsInt32Range(A) then
                        raise EVariantConvertError.Create
                      else
                        V.ValueInt32 := LongInt(A);
    vtInt64         : V.ValueInt64 := A;
    vtInt128        : Int128InitInt64(V.ValueInt128^, A);
    vtInt256        : Int256InitInt64(V.ValueInt256^, A);
    vtHugeInt       : HugeIntInitInt64(V.ValueHugeInt^, A);
    vtAnsiChar      : if not Int64IsWord8Range(A) then
                        raise EVariantConvertError.Create
                      else
                        V.ValueAnsiChar := AnsiChar(Byte(A));
    vtUCS2Char      : if not Int64IsWord16Range(A) then
                        raise EVariantConvertError.Create
                      else
                        V.ValueUCS2Char := WideChar(Word(A));
    vtUCS4Char      : if not Int64IsWord32Range(A) then
                        raise EVariantConvertError.Create
                      else
                        V.ValueUCS4Char := LongWord(A);
    vtSingle        : V.ValueSingle := A;
    vtDouble        : V.ValueDouble := A;
    vtExtended      : V.ValueExtended := A;
    vtCurrency      : V.ValueCurrency := A;
    vtShortString   : VariantSetShortString(V, IntToStringA(A));
    vtRawByteString : VariantSetRawByteString(V, IntToStringB(A));
    vtAnsiString    : VariantSetAnsiString(V, IntToStringA(A));
    vtWideString    : VariantSetWideString(V, IntToStringW(A));
    vtUnicodeString : VariantSetUnicodeString(V, IntToStringU(A));
  else
    raise EVariantConvertError.Create;
  end;
end;

procedure VariantAssignInt128(var V: TVariant; const A: Int128);
begin
  VariantEnsureAssignedValue(V);
  case V.VariantType of
    vtWord8         : if not Int128IsWord8Range(A) then
                        raise EVariantConvertError.Create
                      else
                        V.ValueWord8 := Byte(Int128ToWord32(A));
    vtWord16        : if not Int128IsWord16Range(A) then
                        raise EVariantConvertError.Create
                      else
                        V.ValueWord16 := Word(Int128ToWord32(A));
    vtWord32        : if not Int128IsWord32Range(A) then
                        raise EVariantConvertError.Create
                      else
                        V.ValueWord32 := Int128ToWord32(A);
    vtWord64        : if not Int128IsWord64Range(A) then
                        raise EVariantConvertError.Create
                      else
                        V.ValueWord64 := Int128ToWord64(A);
    vtWord128       : if not Int128IsWord128Range(A) then
                        raise EVariantConvertError.Create
                      else
                        V.ValueWord128^ := Int128ToWord128(A);
    vtWord256       : if Int128IsNegative(A) then
                        raise EVariantConvertError.Create
                      else
                        Word256InitInt128(V.ValueWord256^, A);
//    vtHugeWord      : begin
//                        if Int128IsNegative(A) then
//                          raise EVariantConvertError.Create;
//                        case V.VariantType of
//                          vtWord128  : Word128InitInt128(V.ValueWord128^, A);
//                          vtHugeWord : HugeWordInitInt128(V.ValueHugeWord^, A);
//                        end;
//                      end;
    vtInt8          : if not Int128IsInt8Range(A) then
                        raise EVariantConvertError.Create
                      else
                        V.ValueInt8 := ShortInt(Int128ToInt32(A));
    vtInt16         : if not Int128IsInt16Range(A) then
                        raise EVariantConvertError.Create
                      else
                        V.ValueInt16 := SmallInt(Int128ToInt32(A));
    vtInt32         : if not Int128IsInt32Range(A) then
                        raise EVariantConvertError.Create
                      else
                        V.ValueInt32 := Int128ToInt32(A);
    vtInt64         : if not Int128IsInt64Range(A) then
                        raise EVariantConvertError.Create
                      else
                        V.ValueInt64 := Int128ToInt64(A);
    vtInt128        : V.ValueInt128^ := A;
    vtInt256        : Int256InitInt128(V.ValueInt256^, A);
//    vtHugeInt       : HugeIntInitInt128(V.ValueHugeInt^, A);
    vtAnsiChar      : if not Int128IsWord8Range(A) then
                        raise EVariantConvertError.Create
                      else
                        V.ValueAnsiChar := AnsiChar(Byte(Int128ToWord32(A)));
    vtUCS2Char      : if not Int128IsWord16Range(A) then
                        raise EVariantConvertError.Create
                      else
                        V.ValueUCS2Char := WideChar(Word(Int128ToWord32(A)));
    vtUCS4Char      : if not Int128IsWord32Range(A) then
                        raise EVariantConvertError.Create
                      else
                        V.ValueUCS4Char := Int128ToWord32(A);
    vtSingle        : V.ValueSingle := Int128ToFloat(A);
    vtDouble        : V.ValueDouble := Int128ToFloat(A);
    vtExtended      : V.ValueExtended := Int128ToFloat(A);
    vtCurrency      : V.ValueCurrency := Int128ToFloat(A);
    vtShortString   : VariantSetShortString(V, Int128ToStrA(A));
    // vtRawByteString : VariantSetRawByteString(V, Int128ToStrB(A));
    vtAnsiString    : VariantSetAnsiString(V, Int128ToStrA(A));
    // vtWideString    : VariantSetWideString(V, Int128ToStrW(A));
    vtUnicodeString : VariantSetUnicodeString(V, Int128ToStrU(A));
  else
    raise EVariantConvertError.Create;
  end;
end;

procedure VariantAssignInt256(var V: TVariant; const A: Int256);
begin
  VariantEnsureAssignedValue(V);
  case V.VariantType of
    vtWord8         : if not Int256IsWord8Range(A) then
                        raise EVariantConvertError.Create
                      else
                        V.ValueWord8 := Byte(Int256ToWord32(A));
    vtWord16        : if not Int256IsWord16Range(A) then
                        raise EVariantConvertError.Create
                      else
                        V.ValueWord16 := Word(Int256ToWord32(A));
    vtWord32        : if not Int256IsWord32Range(A) then
                        raise EVariantConvertError.Create
                      else
                        V.ValueWord32 := Int256ToWord32(A);
//    vtWord64        : if not Int256IsWord64Range(A) then
//                        raise EVariantConvertError.Create
//                      else
//                        V.ValueWord64 := Int256ToWord64(A);
//    vtWord128,
//    vtHugeWord      : begin
//                        if Int128IsNegative(A) then
//                          raise EVariantConvertError.Create;
//                        case V.VariantType of
//                          vtWord128  : Word128InitInt128(V.ValueWord128^, A);
//                          vtHugeWord : HugeWordInitInt128(V.ValueHugeWord^, A);
//                        end;
//                      end;
    vtInt8          : if not Int256IsInt8Range(A) then
                        raise EVariantConvertError.Create
                      else
                        V.ValueInt8 := ShortInt(Int256ToInt32(A));
    vtInt16         : if not Int256IsInt16Range(A) then
                        raise EVariantConvertError.Create
                      else
                        V.ValueInt16 := SmallInt(Int256ToInt32(A));
    vtInt32         : if not Int256IsInt32Range(A) then
                        raise EVariantConvertError.Create
                      else
                        V.ValueInt32 := Int256ToInt32(A);
    vtInt64         : if not Int256IsInt64Range(A) then
                        raise EVariantConvertError.Create
                      else
                        V.ValueInt64 := Int256ToInt64(A);
    vtInt128        : if not Int256IsInt128Range(A) then
                        raise EVariantConvertError.Create
                      else
                        V.ValueInt128^ := Int256ToInt128(A);
    vtInt256        : V.ValueInt256^ := A;
    // vtHugeInt       : HugeIntInitInt128(V.ValueHugeInt^, A);
    vtAnsiChar      : if not Int256IsWord8Range(A) then
                        raise EVariantConvertError.Create
                      else
                        V.ValueAnsiChar := AnsiChar(Byte(Int256ToWord32(A)));
    vtUCS2Char      : if not Int256IsWord16Range(A) then
                        raise EVariantConvertError.Create
                      else
                        V.ValueUCS2Char := WideChar(Word(Int256ToWord32(A)));
    vtUCS4Char      : if not Int256IsWord32Range(A) then
                        raise EVariantConvertError.Create
                      else
                        V.ValueUCS4Char := Int256ToWord32(A);
    // vtSingle        : V.ValueSingle := Int256ToFloat(A);
    // vtDouble        : V.ValueDouble := Int256ToFloat(A);
    // vtExtended      : V.ValueExtended := Int256ToFloat(A);
    // vtCurrency      : V.ValueCurrency := Int256ToFloat(A);
    // vtShortString   : VariantSetShortString(V, Int256ToStrA(A));
    // vtAnsiString    : VariantSetAnsiString(V, Int256ToStrA(A));
    // vtWideString    : VariantSetWideString(V, Int256ToStrW(A));
    // vtUnicodeString : VariantSetUnicodeString(V, Int256ToStrU(A));
  else
    raise EVariantConvertError.Create;
  end;
end;

procedure VariantAssignHugeInt(var V: TVariant; const A: HugeInt);
begin
  VariantEnsureAssignedValue(V);
  case V.VariantType of
    vtWord32        : if not HugeIntIsWord32Range(A) then
                        raise EVariantConvertError.Create
                      else
                        V.ValueWord32 := HugeIntToWord32(A);
    vtInt32         : if not HugeIntIsInt32Range(A) then
                        raise EVariantConvertError.Create
                      else
                        V.ValueInt32 := HugeIntToInt32(A);
    vtInt64         : if not HugeIntIsInt64Range(A) then
                        raise EVariantConvertError.Create
                      else
                        V.ValueInt64 := HugeIntToInt64(A);
    vtHugeInt       : HugeIntAssign(V.ValueHugeInt^, A);
  else
    raise EVariantConvertError.Create;
  end;
end;

procedure VariantAssignSingle(var V: TVariant; const A: Single);
begin
  VariantEnsureAssignedValue(V);
  case V.VariantType of
    vtSingle   : V.ValueSingle := A;
    vtDouble   : V.ValueDouble := A;
    vtExtended : V.ValueExtended := A;
    vtCurrency : V.ValueCurrency := A;
  else
    raise EVariantConvertError.Create;
  end;
end;

procedure VariantAssignDouble(var V: TVariant; const A: Double);
begin
  VariantEnsureAssignedValue(V);
  case V.VariantType of
    vtDouble   : V.ValueDouble := A;
    vtExtended : V.ValueExtended := A;
    vtCurrency : V.ValueCurrency := A;
  else
    raise EVariantConvertError.Create;
  end;
end;

procedure VariantAssignExtended(var V: TVariant; const A: Extended);
begin
  VariantEnsureAssignedValue(V);
  case V.VariantType of
    vtExtended : V.ValueExtended := A;
    vtCurrency : V.ValueCurrency := A;
  else
    raise EVariantConvertError.Create;
  end;
end;

procedure VariantAssignCurrency(var V: TVariant; const A: Currency);
begin
  VariantEnsureAssignedValue(V);
  case V.VariantType of
    vtExtended : V.ValueExtended := A;
    vtCurrency : V.ValueCurrency := A;
  else
    raise EVariantConvertError.Create;
  end;
end;

procedure VariantAssignBoolean(var V: TVariant; const A: Boolean);
begin
  VariantEnsureAssignedValue(V);
  case V.VariantType of
    vtWord8         : V.ValueWord8 := Ord(A);
    vtWord16        : V.ValueWord16 := Ord(A);
    vtWord32        : V.ValueWord32 := Ord(A);
    vtWord64        : Word64InitWord32(V.ValueWord64, Ord(A));
    vtWord128       : Word128InitWord32(V.ValueWord128^, Ord(A));
    vtWord256       : Word256InitWord32(V.ValueWord256^, Ord(A));
    vtHugeWord      : HugeWordAssignWord32(V.ValueHugeWord^, Ord(A));
    vtInt8          : V.ValueInt8 := Ord(A);
    vtInt16         : V.ValueInt16 := Ord(A);
    vtInt32         : V.ValueInt32 := Ord(A);
    vtInt64         : V.ValueInt64 := Ord(A);
    vtInt128        : Int128InitWord32(V.ValueInt128^, Ord(A));
    vtInt256        : Int256InitWord32(V.ValueInt256^, Ord(A));
    vtHugeInt       : HugeIntAssignWord32(V.ValueHugeInt^, Ord(A));
    vtBoolean       : V.ValueBoolean := A;
    vtAnsiChar      : if A then V.ValueAnsiChar := '1' else V.ValueAnsiChar := '0';
    vtUCS2Char      : if A then V.ValueUCS2Char := '1' else V.ValueUCS2Char := '0';
    vtUCS4Char      : if A then V.ValueUCS4Char := Ord('1') else V.ValueUCS4Char := Ord('0');
    vtShortString   : VariantSetShortString(V, iifA(A, '1', '0'));
    vtRawByteString : VariantSetRawByteString(V, iifB(A, '1', '0'));
    vtAnsiString    : VariantSetAnsiString(V, iifA(A, '1', '0'));
    vtWideString    : VariantSetWideString(V, iifW(A, '1', '0'));
    vtUnicodeString : VariantSetUnicodeString(V, iifU(A, '1', '0'));
  else
    raise EVariantConvertError.Create;
  end;
end;

procedure VariantAssignAnsiChar(var V: TVariant; const A: AnsiChar);
begin
  VariantEnsureAssignedValue(V);
  case V.VariantType of
    vtWord8         : V.ValueWord8 := Ord(A);
    vtWord16        : V.ValueWord16 := Ord(A);
    vtWord32        : V.ValueWord32 := Ord(A);
    vtWord64        : Word64InitWord32(V.ValueWord64, Ord(A));
    vtWord128       : Word128InitWord32(V.ValueWord128^, Ord(A));
    vtWord256       : Word256InitWord32(V.ValueWord256^, Ord(A));
    vtHugeWord      : HugeWordAssignWord32(V.ValueHugeWord^, Ord(A));
    vtInt16         : V.ValueInt16 := Ord(A);
    vtInt32         : V.ValueInt32 := Ord(A);
    vtInt64         : V.ValueInt64 := Ord(A);
    vtInt128        : Int128InitWord32(V.ValueInt128^, Ord(A));
    vtInt256        : Int256InitWord32(V.ValueInt256^, Ord(A));
    vtHugeInt       : HugeIntAssignWord32(V.ValueHugeInt^, Ord(A));
    vtAnsiChar      : V.ValueAnsiChar := A;
    vtUCS2Char      : V.ValueUCS2Char := WideChar(A);
    vtUCS4Char      : V.ValueUCS4Char := Ord(A);
    vtShortString   : VariantSetShortString(V, A);
    vtRawByteString : VariantSetRawByteString(V, A);
    vtAnsiString    : VariantSetAnsiString(V, A);
    vtWideString    : VariantSetWideString(V, WideChar(A));
    vtUnicodeString : VariantSetUnicodeString(V, WideChar(A));
  else
    raise EVariantConvertError.Create;
  end;
end;

procedure VariantAssignUCS2Char(var V: TVariant; const A: WideChar);
begin
  VariantEnsureAssignedValue(V);
  case V.VariantType of
    vtWord8         : if not Word16IsWord8Range(Ord(A)) then
                        raise EVariantConvertError.Create
                      else
                        V.ValueWord8 := Word8(Ord(A));
    vtWord16        : V.ValueWord16 := Ord(A);
    vtWord32        : V.ValueWord32 := Ord(A);
    vtWord64        : Word64InitWord32(V.ValueWord64, Ord(A));
    vtWord128       : Word128InitWord32(V.ValueWord128^, Ord(A));
    vtWord256       : Word256InitWord32(V.ValueWord256^, Ord(A));
    vtHugeWord      : HugeWordAssignWord32(V.ValueHugeWord^, Ord(A));
    vtInt8          : if not Word16IsInt8Range(Ord(A)) then
                        raise EVariantConvertError.Create
                      else
                        V.ValueInt8 := Int8(Ord(A));
    vtInt16         : if not Word16IsInt16Range(Ord(A)) then
                        raise EVariantConvertError.Create
                      else
                        V.ValueInt16 := Int16(Ord(A));
    vtInt32         : V.ValueInt32 := Ord(A);
    vtInt64         : V.ValueInt64 := Ord(A);
    vtInt128        : Int128InitWord32(V.ValueInt128^, Ord(A));
    vtInt256        : Int256InitWord32(V.ValueInt256^, Ord(A));
    vtHugeInt       : HugeIntAssignWord32(V.ValueHugeInt^, Ord(A));
    vtUCS2Char      : V.ValueUCS2Char := A;
    vtUCS4Char      : V.ValueUCS4Char := Ord(A);
    vtWideString    : VariantSetWideString(V, A);
    vtUnicodeString : VariantSetUnicodeString(V, A);
  else
    raise EVariantConvertError.Create;
  end;
end;

procedure VariantAssignUCS4Char(var V: TVariant; const A: LongWord);
begin
  VariantEnsureAssignedValue(V);
  case V.VariantType of
    vtWord8         : if not Word32IsWord8Range(Ord(A)) then
                        raise EVariantConvertError.Create
                      else
                        V.ValueWord8 := Word8(Ord(A));
    vtWord16        : if not Word32IsWord16Range(Ord(A)) then
                        raise EVariantConvertError.Create
                      else
                        V.ValueWord16 := Word16(Ord(A));
    vtWord32        : V.ValueWord32 := A;
    vtWord64        : Word64InitWord32(V.ValueWord64, A);
    vtWord128       : Word128InitWord32(V.ValueWord128^, A);
    vtWord256       : Word256InitWord32(V.ValueWord256^, A);
    vtHugeWord      : HugeWordAssignWord32(V.ValueHugeWord^, Ord(A));
    vtInt64         : V.ValueInt64 := A;
    vtInt128        : Int128InitWord32(V.ValueInt128^, A);
    vtInt256        : Int256InitWord32(V.ValueInt256^, A);
    vtHugeInt       : HugeIntAssignWord32(V.ValueHugeInt^, Ord(A));
    vtUCS4Char      : V.ValueUCS4Char := A;
  else
    raise EVariantConvertError.Create;
  end;
end;

procedure VariantAssignDateTime(var V: TVariant; const A: TDateTime);
begin
  VariantEnsureAssignedValue(V);
  case V.VariantType of
    vtDouble   : V.ValueDouble := Double(A);
    vtExtended : V.ValueExtended := Double(A);
    vtDateTime : V.ValueDateTime := A;
    vtDate     : V.ValueDate := Trunc(A);
    vtTime     : V.ValueTime := Frac(A);
  else
    raise EVariantConvertError.Create;
  end;
end;

procedure VariantAssignDate(var V: TVariant; const A: TDateTime);
begin
  VariantEnsureAssignedValue(V);
  case V.VariantType of
    vtDouble   : V.ValueDouble := Double(A);
    vtExtended : V.ValueExtended := Double(A);
    vtDateTime : V.ValueDateTime := Trunc(A);
    vtDate     : V.ValueDate := Trunc(A);
  else
    raise EVariantConvertError.Create;
  end;
end;

procedure VariantAssignTime(var V: TVariant; const A: TDateTime);
begin
  VariantEnsureAssignedValue(V);
  case V.VariantType of
    vtDouble   : V.ValueDouble := Double(A);
    vtExtended : V.ValueExtended := Double(A);
    vtTime     : V.ValueTime := Frac(A);
  else
    raise EVariantConvertError.Create;
  end;
end;

procedure VariantAssignShortString(var V: TVariant; const A: ShortString);
begin
  VariantEnsureAssignedValue(V);
  case V.VariantType of
    vtShortString   : VariantSetShortString(V, A);
    vtRawByteString : VariantSetRawByteString(V, A);
    vtAnsiString    : VariantSetAnsiString(V, A);
  else
    raise EVariantConvertError.Create;
  end;
end;

procedure VariantAssignAnsiString(var V: TVariant; const A: AnsiString);
begin
  VariantEnsureAssignedValue(V);
  case V.VariantType of
    vtRawByteString : VariantSetRawByteString(V, A);
    vtAnsiString    : VariantSetAnsiString(V, A);
  else
    raise EVariantConvertError.Create;
  end;
end;

procedure VariantAssignWideString(var V: TVariant; const A: WideString);
begin
  VariantEnsureAssignedValue(V);
  case V.VariantType of
    vtWideString    : VariantSetWideString(V, A);
    vtUnicodeString : VariantSetUnicodeString(V, A);
  else
    raise EVariantConvertError.Create;
  end;
end;

procedure VariantAssignUnicodeString(var V: TVariant; const A: UnicodeString);
begin
  VariantEnsureAssignedValue(V);
  case V.VariantType of
    vtWideString    : VariantSetWideString(V, A);
    vtUnicodeString : VariantSetUnicodeString(V, A);
  else
    raise EVariantConvertError.Create;
  end;
end;

procedure VariantAssignString(var V: TVariant; const A: String);
begin
  {$IFDEF StringIsUnicode}
  VariantAssignUnicodeString(V, A);
  {$ELSE}
  VariantAssignAnsiString(V, A);
  {$ENDIF}
end;

procedure VariantAssignPAnsiChar(var V: TVariant; const A: PAnsiChar);
begin
  VariantEnsureAssignedValue(V);
  case V.VariantType of
    vtPAnsiChar : V.ValuePAnsiChar := A;
  else
    raise EVariantConvertError.Create;
  end;
end;

procedure VariantAssignPWideChar(var V: TVariant; const A: PWideChar);
begin
  VariantEnsureAssignedValue(V);
  case V.VariantType of
    vtPWideChar : V.ValuePWideChar := A;
  else
    raise EVariantConvertError.Create;
  end;
end;

procedure VariantAssignPointer(var V: TVariant; const A: Pointer);
begin
  VariantEnsureAssignedValue(V);
  case V.VariantType of
    vtPointer : V.ValuePointer := A;
  else
    raise EVariantConvertError.Create;
  end;
end;

procedure VariantAssignObject(var V: TVariant; const A: TObject);
begin
  VariantEnsureAssignedValue(V);
  case V.VariantType of
    vtObject : V.ValueObject := A;
  else
    raise EVariantConvertError.Create;
  end;
end;

procedure VariantAssignIntfObject(var V: TVariant; const A: TInterfacedObject);
begin
  VariantEnsureAssignedValue(V);
  case V.VariantType of
    vtIntfObject : TInterfacedObject(V.ValueIntfObject) := A;
  else
    raise EVariantConvertError.Create;
  end;
end;

procedure VariantAssignInterface(var V: TVariant; const A: IInterface);
begin
  VariantEnsureAssignedValue(V);
  case V.VariantType of
    vtInterface : IInterface(V.ValueInterface) := A;
  else
    raise EVariantConvertError.Create;
  end;
end;

procedure VariantAssignVariantArray(var V: TVariant; const A: TVariantArrayRec);
begin
  VariantEnsureAssignedValue(V);
  case V.VariantType of
    vtVariantArray : VariantArrayDuplicate(A, V.ValueVariantArray^);
  else
    raise EVariantConvertError.Create;
  end;
end;

procedure VariantAssignVariantDictionary(var V: TVariant; const A: TVariantDictionaryRec);
begin
  VariantEnsureAssignedValue(V);
  case V.VariantType of
    vtVariantDictionary : VariantDictionaryDuplicate(A, V.ValueVariantDictionary^);
  else
    raise EVariantConvertError.Create;
  end;
end;

procedure VariantAssignVariantValue(var V: TVariant; const A: TVariant);
begin
  VariantEnsureAssignedValue(V);
  case V.VariantType of
    vtWord8             : V.ValueWord8 := VariantToWord8(A);
    vtWord16            : V.ValueWord16 := VariantToWord16(A);
    vtWord32            : V.ValueWord32 := VariantToWord32(A);
    vtWord64            : V.ValueWord64 := VariantToWord64(A);
    vtWord128           : V.ValueWord128^ := VariantToWord128(A);
    vtWord256           : V.ValueWord256^ := VariantToWord256(A);
    // vtHugeWord          : V.ValueHugeWord^ := VariantToHugeWord(A);// re-init/finalise problem
    vtInt8              : V.ValueInt8 := VariantToInt8(A);
    vtInt16             : V.ValueInt16 := VariantToInt16(A);
    vtInt32             : V.ValueInt32 := VariantToInt32(A);
    vtInt64             : V.ValueInt64 := VariantToInt64(A);
    vtInt128            : V.ValueInt128^ := VariantToInt128(A);
    vtInt256            : V.ValueInt256^ := VariantToInt256(A);
    // vtHugeInt           : V.ValueHugeInt^ := VariantToHugeInt(A);// re-init/finalise problem
    vtSingle            : V.ValueSingle := VariantToSingle(A);
    vtDouble            : V.ValueDouble := VariantToDouble(A);
    vtExtended          : V.ValueExtended := VariantToExtended(A);
    vtCurrency          : V.ValueCurrency := VariantToCurrency(A);
    vtBoolean           : V.ValueBoolean := VariantToBoolean(A);
    vtAnsiChar          : V.ValueAnsiChar := VariantToAnsiChar(A);
    vtUCS2Char          : V.ValueUCS2Char := VariantToUCS2Char(A);
    vtUCS4Char          : V.ValueUCS4Char := VariantToUCS4Char(A);
    vtDateTime          : V.ValueDateTime := VariantToDateTime(A);
    vtDate              : V.ValueDate := VariantToDate(A);
    vtTime              : V.ValueTime := VariantToTime(A);
    vtShortString       : PShortString(V.ValueShortString)^ := VariantToShortString(A);
    vtRawByteString     : RawByteString(V.ValueRawByteString) := VariantToRawByteString(A);
    vtAnsiString        : AnsiString(V.ValueAnsiString) := VariantToAnsiString(A);
    vtWideString        : WideString(V.ValueWideString) := VariantToWideString(A);
    vtPAnsiChar         : V.ValuePAnsiChar := VariantToPAnsiChar(A);
    vtPWideChar         : V.ValuePWideChar := VariantToPWideChar(A);
    vtPointer           : V.ValuePointer := VariantToPointer(A);
    vtObject            : TObject(V.ValueObject) := VariantToObject(A);
    vtIntfObject        : TInterfacedObject(V.ValueIntfObject) := VariantToIntfObject(A);
    vtInterface         : IInterface(V.ValueInterface) := VariantToInterface(A);
    vtVariant           : V.ValueVariant^ := A;
    vtVariantArray      : VariantArrayDuplicate(VariantToVariantArray(A), V.ValueVariantArray^);
    vtVariantDictionary : VariantDictionaryDuplicate(VariantToVariantDictionary(A), V.ValueVariantDictionary^);
  else
    raise EVariantConvertError.Create;
  end;
  V.ValueType := vvtAssignedValue;
end;



{ Variant conversion }

function VariantToWord8(const V: TVariant): Byte;
begin
  if V.ValueType <> vvtAssignedValue then
    raise EVariantConvertError.Create;
  case V.VariantType of
    vtWord8    : Result := V.ValueWord8;
    vtWord16   : if not Word16IsWord8Range(V.ValueWord16) then
                   raise EVariantConvertError.Create
                 else
                   Result := Word8(V.ValueWord16);
    vtWord32   : if not Word32IsWord8Range(V.ValueWord32) then
                   raise EVariantConvertError.Create
                 else
                   Result := Word8(V.ValueWord32);
    vtWord64   : if not Word64IsWord8Range(V.ValueWord64) then
                   raise EVariantConvertError.Create
                 else
                   Result := Word8(Word64ToWord32(V.ValueWord64));
    vtWord128  : if not Word128IsWord8Range(V.ValueWord128^) then
                   raise EVariantConvertError.Create
                 else
                   Result := Word8(Word128ToWord32(V.ValueWord128^));
    vtInt8     : if not Int8IsWord8Range(V.ValueInt8) then
                   raise EVariantConvertError.Create
                 else
                   Result := Word8(V.ValueInt8);
    vtInt16    : if not Int16IsWord8Range(V.ValueInt16) then
                   raise EVariantConvertError.Create
                 else
                   Result := Word8(V.ValueInt16);
    vtInt32    : if not Int32IsWord8Range(V.ValueInt32) then
                   raise EVariantConvertError.Create
                 else
                   Result := Word8(V.ValueInt32);
    vtInt64    : if not Int64IsWord8Range(V.ValueInt64) then
                   raise EVariantConvertError.Create
                 else
                   Result := Word8(V.ValueInt64);
    vtInt128   : if not Int128IsWord8Range(V.ValueInt128^) then
                   raise EVariantConvertError.Create
                 else
                   Result := Word8(Int128ToWord32(V.ValueInt128^));
    vtInt256   : if not Int256IsWord8Range(V.ValueInt256^) then
                   raise EVariantConvertError.Create
                 else
                   Result := Word8(Int256ToWord32(V.ValueInt256^));
    vtBoolean  : Result := Ord(V.ValueBoolean);
  else
    raise EVariantConvertError.Create;
  end;
end;

function VariantToWord16(const V: TVariant): Word;
begin
  if V.ValueType <> vvtAssignedValue then
    raise EVariantConvertError.Create;
  case V.VariantType of
    vtWord8    : Result := V.ValueWord8;
    vtWord16   : Result := V.ValueWord16;
    vtWord32   : if not Word32IsWord16Range(V.ValueWord32) then
                   raise EVariantConvertError.Create
                 else
                   Result := Word16(V.ValueWord32);
    vtWord64   : if not Word64IsWord16Range(V.ValueWord64) then
                   raise EVariantConvertError.Create
                 else
                   Result := Word16(Word64ToWord32(V.ValueWord64));
    vtWord128  : if not Word128IsWord16Range(V.ValueWord128^) then
                   raise EVariantConvertError.Create
                 else
                   Result := Word16(Word128ToWord32(V.ValueWord128^));
    vtInt8     : if V.ValueInt8 < 0 then
                   raise EVariantConvertError.Create
                 else
                   Result := Word16(V.ValueInt8);
    vtInt16    : if V.ValueInt16 < 0 then
                   raise EVariantConvertError.Create
                 else
                   Result := Word16(V.ValueInt16);
    vtInt32    : if not Int32IsWord16Range(V.ValueInt32) then
                   raise EVariantConvertError.Create
                 else
                   Result := Word16(V.ValueInt32);
    vtInt64    : if not Int64IsWord16Range(V.ValueInt64) then
                   raise EVariantConvertError.Create
                 else
                   Result := Word16(V.ValueInt64);
    vtInt128   : if not Int128IsWord16Range(V.ValueInt128^) then
                   raise EVariantConvertError.Create
                 else
                   Result := Word16(Int128ToWord32(V.ValueInt128^));
    vtInt256   : if not Int256IsWord16Range(V.ValueInt256^) then
                   raise EVariantConvertError.Create
                 else
                   Result := Word16(Int256ToWord32(V.ValueInt256^));
    vtBoolean  : Result := Ord(V.ValueBoolean);
  else
    raise EVariantConvertError.Create;
  end;
end;

function VariantToWord32(const V: TVariant): LongWord;
begin
  if V.ValueType <> vvtAssignedValue then
    raise EVariantConvertError.Create;
  case V.VariantType of
    vtWord8    : Result := V.ValueWord8;
    vtWord16   : Result := V.ValueWord16;
    vtWord32   : Result := V.ValueWord32;
    vtWord64   : if not Word64IsWord32Range(V.ValueWord64) then
                   raise EVariantConvertError.Create
                 else
                   Result := Word64ToWord32(V.ValueWord64);
    vtWord128  : if not Word128IsWord32Range(V.ValueWord128^) then
                   raise EVariantConvertError.Create
                 else
                   Result := Word128ToWord32(V.ValueWord128^);
    vtHugeWord : if not HugeWordIsWord32Range(V.ValueHugeWord^) then
                   raise EVariantConvertError.Create
                 else
                   Result := HugeWordToWord32(V.ValueHugeWord^);
    vtInt8     : if V.ValueInt8 < 0 then
                   raise EVariantConvertError.Create
                 else
                   Result := Word16(V.ValueInt8);
    vtInt16    : if V.ValueInt16 < 0 then
                   raise EVariantConvertError.Create
                 else
                   Result := Word16(V.ValueInt16);
    vtInt32    : if not Int32IsWord32Range(V.ValueInt32) then
                   raise EVariantConvertError.Create
                 else
                   Result := Word32(V.ValueInt32);
    vtInt64    : if not Int64IsWord32Range(V.ValueInt64) then
                   raise EVariantConvertError.Create
                 else
                   Result := Word32(V.ValueInt64);
    vtInt128   : if not Int128IsWord32Range(V.ValueInt128^) then
                   raise EVariantConvertError.Create
                 else
                   Result := Word32(Int128ToWord32(V.ValueInt128^));
    vtInt256   : if not Int256IsWord32Range(V.ValueInt256^) then
                   raise EVariantConvertError.Create
                 else
                   Result := Int256ToWord32(V.ValueInt256^);
    vtHugeInt  : if not HugeIntIsWord32Range(V.ValueHugeInt^) then
                   raise EVariantConvertError.Create
                 else
                   Result := HugeIntToWord32(V.ValueHugeInt^);
    vtBoolean  : Result := Ord(V.ValueBoolean);
  else
    raise EVariantConvertError.Create;
  end;
end;

function VariantToWord64(const V: TVariant): Word64;
begin
  if V.ValueType <> vvtAssignedValue then
    raise EVariantConvertError.Create;
  case V.VariantType of
    vtWord8    : Word64InitWord32(Result, V.ValueWord8);
    vtWord16   : Word64InitWord32(Result, V.ValueWord16);
    vtWord32   : Word64InitWord32(Result, V.ValueWord32);
    vtWord64   : Result := V.ValueWord64;
    vtWord128  : if not Word128IsWord64Range(V.ValueWord128^) then
                   raise EVariantConvertError.Create
                 else
                   Result := Word128ToWord64(V.ValueWord128^);
//    vtHugeWord : if not HugeWordIsWord64Range(V.ValueHugeWord^) then
//                   raise EVariantConvertError.Create
//                 else
//                   Result := HugeWordToWord64(V.ValueHugeWord^);
    vtInt8     : if V.ValueInt8 < 0 then
                   raise EVariantConvertError.Create
                 else
                   Word64InitInt32(Result, V.ValueInt8);
    vtInt16    : if V.ValueInt16 < 0 then
                   raise EVariantConvertError.Create
                 else
                   Word64InitInt32(Result, V.ValueInt16);
    vtInt32    : if V.ValueInt32 < 0 then
                   raise EVariantConvertError.Create
                 else
                   Word64InitInt32(Result, V.ValueInt32);
    vtInt64    : if not Int64IsWord64Range(V.ValueInt64) then
                   raise EVariantConvertError.Create
                 else
                   Word64InitInt64(Result, V.ValueInt64);
    vtInt128   : if not Int128IsWord64Range(V.ValueInt128^) then
                   raise EVariantConvertError.Create
                 else
                   Result := Int128ToWord64(V.ValueInt128^);
//    vtInt256   : if not Int256IsWord64Range(V.ValueInt256^) then
//                   raise EVariantConvertError.Create
//                 else
//                   Result := Int256ToWord64(V.ValueInt256^);
//    vtHugeInt  : if not HugeIntIsWord64Range(V.ValueHugeInt^) then
//                   raise EVariantConvertError.Create
//                 else
//                   Result := HugeIntToWord32(V.ValueHugeInt^);
    vtBoolean  : Word64InitWord32(Result, Ord(V.ValueBoolean));
  else
    raise EVariantConvertError.Create;
  end;
end;

function VariantToWord128(const V: TVariant): Word128;
begin
  if V.ValueType <> vvtAssignedValue then
    raise EVariantConvertError.Create;
  case V.VariantType of
    vtWord8    : Word128InitWord32(Result, V.ValueWord8);
    vtWord16   : Word128InitWord32(Result, V.ValueWord16);
    vtWord32   : Word128InitWord32(Result, V.ValueWord32);
    vtWord64   : Word128InitWord64(Result, V.ValueWord64);
    vtWord128  : Result := V.ValueWord128^;
//    vtHugeWord : if not HugeWordIsWord64Range(V.ValueHugeWord^) then
//                   raise EVariantConvertError.Create
//                 else
//                   Result := HugeWordToWord64(V.ValueHugeWord^);
    vtInt8     : if V.ValueInt8 < 0 then
                   raise EVariantConvertError.Create
                 else
                   Word128InitInt32(Result, V.ValueInt8);
    vtInt16    : if V.ValueInt16 < 0 then
                   raise EVariantConvertError.Create
                 else
                   Word128InitInt32(Result, V.ValueInt16);
    vtInt32    : if V.ValueInt32 < 0 then
                   raise EVariantConvertError.Create
                 else
                   Word128InitInt32(Result, V.ValueInt32);
    vtInt64    : if V.ValueInt64 < 0 then
                   raise EVariantConvertError.Create
                 else
                   Word128InitInt64(Result, V.ValueInt64);
    vtInt128   : if not Int128IsWord128Range(V.ValueInt128^) then
                   raise EVariantConvertError.Create
                 else
                   Result := Int128ToWord128(V.ValueInt128^);
//    vtInt256   : if not Int256IsWord64Range(V.ValueInt256^) then
//                   raise EVariantConvertError.Create
//                 else
//                   Result := Int256ToWord64(V.ValueInt256^);
//    vtHugeInt  : if not HugeIntIsWord64Range(V.ValueHugeInt^) then
//                   raise EVariantConvertError.Create
//                 else
//                   Result := HugeIntToWord32(V.ValueHugeInt^);
    vtBoolean  : Word128InitWord32(Result, Ord(V.ValueBoolean));
  else
    raise EVariantConvertError.Create;
  end;
end;

function VariantToWord256(const V: TVariant): Word256;
begin
  if V.ValueType <> vvtAssignedValue then
    raise EVariantConvertError.Create;
  case V.VariantType of
    vtWord8    : Word256InitWord32(Result, V.ValueWord8);
    vtWord16   : Word256InitWord32(Result, V.ValueWord16);
    vtWord32   : Word256InitWord32(Result, V.ValueWord32);
    vtWord64   : Word256InitWord64(Result, V.ValueWord64);
    vtWord128  : Word256InitWord128(Result, V.ValueWord128^);
    vtWord256  : Result := V.ValueWord256^;
    vtInt8     : if V.ValueInt8 < 0 then
                   raise EVariantConvertError.Create
                 else
                   Word256InitInt32(Result, V.ValueInt8);
    vtInt16    : if V.ValueInt16 < 0 then
                   raise EVariantConvertError.Create
                 else
                   Word256InitInt32(Result, V.ValueInt16);
    vtInt32    : if V.ValueInt32 < 0 then
                   raise EVariantConvertError.Create
                 else
                   Word256InitInt32(Result, V.ValueInt32);
    vtInt64    : if V.ValueInt64 < 0 then
                   raise EVariantConvertError.Create
                 else
                   Word256InitInt64(Result, V.ValueInt64);
    vtInt128   : if not Int128IsWord128Range(V.ValueInt128^) then
                   raise EVariantConvertError.Create
                 else
                   Word256InitInt128(Result, V.ValueInt128^);
  else
    raise EVariantConvertError.Create;
  end;
end;

function VariantToHugeWord(const V: TVariant): HugeWord;
begin
  if V.ValueType <> vvtAssignedValue then
    raise EVariantConvertError.Create;
  case V.VariantType of
    vtWord8    : HugeWordInitWord32(Result, V.ValueWord8);
    vtWord16   : HugeWordInitWord32(Result, V.ValueWord16);
    vtWord32   : HugeWordInitWord32(Result, V.ValueWord32);
    vtHugeWord : HugeWordInitHugeWord(Result, V.ValueHugeWord^);
    vtInt8     : HugeWordInitInt32(Result, V.ValueInt8);
    vtInt16    : HugeWordInitInt32(Result, V.ValueInt16);
    vtInt32    : HugeWordInitInt32(Result, V.ValueInt32);
    vtInt64    : HugeWordInitInt64(Result, V.ValueInt64);
    vtHugeInt  : if HugeIntIsNegative(V.ValueHugeInt^) then
                   raise EVariantConvertError.Create
                 else
                   begin
                     HugeWordInit(Result);
                     HugeIntAbs(V.ValueHugeInt^, Result);
                   end;
  else
    raise EVariantConvertError.Create;
  end;
end;

function VariantToInt8(const V: TVariant): ShortInt;
begin
  if V.ValueType <> vvtAssignedValue then
    raise EVariantConvertError.Create;
  case V.VariantType of
    vtWord8   : if not Word8IsInt8Range(V.ValueWord8) then
                  raise EVariantConvertError.Create
                else
                  Result := Int8(V.ValueWord8);
    vtWord16  : if not Word16IsInt8Range(V.ValueWord16) then
                  raise EVariantConvertError.Create
                else
                  Result := Int8(V.ValueWord16);
    vtWord32  : if not Word32IsInt8Range(V.ValueWord32) then
                  raise EVariantConvertError.Create
                else
                  Result := Int8(V.ValueWord32);
    vtWord64  : if not Word64IsInt8Range(V.ValueWord64) then
                  raise EVariantConvertError.Create
                else
                  Result := Int8(Word64ToInt32(V.ValueWord64));
    vtWord128 : if not Word128IsInt8Range(V.ValueWord128^) then
                  raise EVariantConvertError.Create
                else
                  Result := Int8(Word128ToInt32(V.ValueWord128^));
//    vtWord256 : if not Word256IsInt8Range(V.ValueWord256^) then
//                  raise EVariantConvertError.Create
//                else
//                  Result := Int8(Word256ToInt32(V.ValueWord256^));
    vtInt8    : Result := V.ValueInt8;
    vtInt16   : if not Int16IsInt8Range(V.ValueInt16) then
                  raise EVariantConvertError.Create
                else
                  Result := Int8(V.ValueInt16);
    vtInt32   : if not Int32IsInt8Range(V.ValueInt32) then
                  raise EVariantConvertError.Create
                else
                  Result := Int8(V.ValueInt32);
    vtInt64   : if not Int64IsInt8Range(V.ValueInt64) then
                  raise EVariantConvertError.Create
                else
                  Result := Int8(V.ValueInt64);
    vtInt128  : if not Int128IsInt8Range(V.ValueInt128^) then
                  raise EVariantConvertError.Create
                else
                  Result := Int8(Int128ToInt32(V.ValueInt128^));
    vtInt256  : if not Int256IsInt8Range(V.ValueInt256^) then
                  raise EVariantConvertError.Create
                else
                  Result := Int8(Int256ToInt32(V.ValueInt256^));
    vtBoolean : Result := Ord(V.ValueBoolean);
  else
    raise EVariantConvertError.Create;
  end;
end;

function VariantToInt16(const V: TVariant): SmallInt;
begin
  if V.ValueType <> vvtAssignedValue then
    raise EVariantConvertError.Create;
  case V.VariantType of
    vtWord8   : Result := Int16(V.ValueWord8);
    vtWord16  : if not Word16IsInt16Range(V.ValueWord16) then
                  raise EVariantConvertError.Create
                else
                  Result := Int16(V.ValueWord16);
    vtWord32  : if not Word32IsInt16Range(V.ValueWord32) then
                  raise EVariantConvertError.Create
                else
                  Result := Int16(V.ValueWord32);
    vtWord64  : if not Word64IsInt16Range(V.ValueWord64) then
                  raise EVariantConvertError.Create
                else
                  Result := Int16(Word64ToInt32(V.ValueWord64));
    vtWord128 : if not Word128IsInt16Range(V.ValueWord128^) then
                  raise EVariantConvertError.Create
                else
                  Result := Int16(Word128ToInt32(V.ValueWord128^));
    vtInt8    : Result := V.ValueInt8;
    vtInt16   : Result := V.ValueInt16;
    vtInt32   : if not Int32IsInt16Range(V.ValueInt32) then
                  raise EVariantConvertError.Create
                else
                  Result := Int16(V.ValueInt32);
    vtInt64   : if not Int64IsInt16Range(V.ValueInt64) then
                  raise EVariantConvertError.Create
                else
                  Result := Int16(V.ValueInt64);
    vtInt128  : if not Int128IsInt16Range(V.ValueInt128^) then
                  raise EVariantConvertError.Create
                else
                  Result := Int16(Int128ToInt32(V.ValueInt128^));
    vtInt256  : if not Int256IsInt16Range(V.ValueInt256^) then
                  raise EVariantConvertError.Create
                else
                  Result := Int16(Int256ToInt32(V.ValueInt256^));
    vtBoolean : Result := Ord(V.ValueBoolean);
  else
    raise EVariantConvertError.Create;
  end;
end;

function VariantToInt32(const V: TVariant): LongInt;
begin
  if V.ValueType <> vvtAssignedValue then
    raise EVariantConvertError.Create;
  case V.VariantType of
    vtWord8    : Result := Int32(V.ValueWord8);
    vtWord16   : Result := Int32(V.ValueWord16);
    vtWord32   : if not Word32IsInt32Range(V.ValueWord32) then
                   raise EVariantConvertError.Create
                 else
                   Result := Int32(V.ValueWord32);
    vtWord64   : if not Word64IsInt32Range(V.ValueWord64) then
                   raise EVariantConvertError.Create
                 else
                   Result := Word64ToInt32(V.ValueWord64);
    vtWord128  : if not Word128IsInt32Range(V.ValueWord128^) then
                   raise EVariantConvertError.Create
                 else
                   Result := Word128ToInt32(V.ValueWord128^);
    vtHugeWord : if not HugeWordIsInt32Range(V.ValueHugeWord^) then
                   raise EVariantConvertError.Create
                 else
                   Result := HugeWordToInt32(V.ValueHugeWord^);
    vtInt8     : Result := V.ValueInt8;
    vtInt16    : Result := V.ValueInt16;
    vtInt32    : Result := V.ValueInt32;
    vtInt64    : if not Int64IsInt32Range(V.ValueInt64) then
                   raise EVariantConvertError.Create
                 else
                   Result := Int32(V.ValueInt64);
    vtInt128   : if not Int128IsInt32Range(V.ValueInt128^) then
                   raise EVariantConvertError.Create
                 else
                   Result := Int128ToInt32(V.ValueInt128^);
    vtInt256   : if not Int256IsInt32Range(V.ValueInt256^) then
                   raise EVariantConvertError.Create
                 else
                   Result := Int256ToInt32(V.ValueInt256^);
    vtHugeInt  : if not HugeIntIsInt32Range(V.ValueHugeInt^) then
                   raise EVariantConvertError.Create
                 else
                   Result := HugeIntToInt32(V.ValueHugeInt^);
    vtBoolean  : Result := Ord(V.ValueBoolean);
  else
    raise EVariantConvertError.Create;
  end;
end;

function VariantToInt64(const V: TVariant): Int64;
begin
  if V.ValueType <> vvtAssignedValue then
    raise EVariantConvertError.Create;
  case V.VariantType of
    vtWord8    : Result := V.ValueWord8;
    vtWord16   : Result := V.ValueWord16;
    vtWord32   : Result := V.ValueWord32;
    vtWord64   : if not Word64IsInt64Range(V.ValueWord64) then
                   raise EVariantConvertError.Create
                 else
                   Result := Word64ToInt64(V.ValueWord64);
    vtWord128  : if not Word128IsInt64Range(V.ValueWord128^) then
                   raise EVariantConvertError.Create
                 else
                   Result := Word128ToInt64(V.ValueWord128^);
    vtHugeWord : if not HugeWordIsInt64Range(V.ValueHugeWord^) then
                   raise EVariantConvertError.Create
                 else
                   Result := HugeWordToInt64(V.ValueHugeWord^);
    vtInt8     : Result := V.ValueInt8;
    vtInt16    : Result := V.ValueInt16;
    vtInt32    : Result := V.ValueInt32;
    vtInt64    : Result := V.ValueInt64;
    vtInt128   : if not Int128IsInt64Range(V.ValueInt128^) then
                   raise EVariantConvertError.Create
                 else
                   Result := Int128ToInt64(V.ValueInt128^);
    vtInt256   : if not Int256IsInt64Range(V.ValueInt256^) then
                   raise EVariantConvertError.Create
                 else
                   Result := Int256ToInt64(V.ValueInt256^);
    vtHugeInt  : if not HugeIntIsInt64Range(V.ValueHugeInt^) then
                   raise EVariantConvertError.Create
                 else
                   Result := HugeIntToInt64(V.ValueHugeInt^);
    vtBoolean  : Result := Ord(V.ValueBoolean);
  else
    raise EVariantConvertError.Create;
  end;
end;

function VariantToInt128(const V: TVariant): Int128;
begin
  if V.ValueType <> vvtAssignedValue then
    raise EVariantConvertError.Create;
  case V.VariantType of
    vtWord8   : Int128InitWord32(Result, V.ValueWord8);
    vtWord16  : Int128InitWord32(Result, V.ValueWord16);
    vtWord32  : Int128InitWord32(Result, V.ValueWord32);
    vtWord64  : Int128InitWord64(Result, V.ValueWord64);
    // vtWord128 : Int128InitWord128(Result, V.ValueWord128^);
    vtInt8    : Int128InitInt32(Result, V.ValueInt8);
    vtInt16   : Int128InitInt32(Result, V.ValueInt16);
    vtInt32   : Int128InitInt32(Result, V.ValueInt32);
    vtInt64   : Int128InitInt64(Result, V.ValueInt64);
    vtInt128  : Result := V.ValueInt128^;
    vtBoolean : Int128InitWord32(Result, Ord(V.ValueBoolean));
  else
    raise EVariantConvertError.Create;
  end;
end;

function VariantToInt256(const V: TVariant): Int256;
begin
  if V.ValueType <> vvtAssignedValue then
    raise EVariantConvertError.Create;
  case V.VariantType of
    vtWord8   : Int256InitWord32(Result, V.ValueWord8);
    vtWord16  : Int256InitWord32(Result, V.ValueWord16);
    vtWord32  : Int256InitWord32(Result, V.ValueWord32);
    vtWord64  : Int256InitWord64(Result, V.ValueWord64);
    vtWord128 : Int256InitWord128(Result, V.ValueWord128^);
    // vtWord256 : Int256InitWord256(Result, V.ValueWord128);
    vtInt8    : Int256InitInt32(Result, V.ValueInt8);
    vtInt16   : Int256InitInt32(Result, V.ValueInt16);
    vtInt32   : Int256InitInt32(Result, V.ValueInt32);
    vtInt64   : Int256InitInt64(Result, V.ValueInt64);
    vtInt128  : Int256InitInt128(Result, V.ValueInt128^);
    vtInt256  : Result := V.ValueInt256^;
    vtBoolean : Int256InitWord32(Result, Ord(V.ValueBoolean));
  else
    raise EVariantConvertError.Create;
  end;
end;

function VariantToHugeInt(const V: TVariant): HugeInt;
begin
  if V.ValueType <> vvtAssignedValue then
    raise EVariantConvertError.Create;
  case V.VariantType of
    vtWord8    : HugeIntInitWord32(Result, V.ValueWord8);
    vtWord16   : HugeIntInitWord32(Result, V.ValueWord16);
    vtWord32   : HugeIntInitWord32(Result, V.ValueWord32);
    // vtWord64  : Int256InitWord64(Result, V.ValueWord64);
    // vtWord128 : Int256InitWord128(Result, V.ValueWord128);
    // vtWord256 : Int256InitWord256(Result, V.ValueWord128);
    vtHugeWord : HugeIntInitHugeWord(Result, V.ValueHugeWord^);
    vtInt8     : HugeIntInitInt32(Result, V.ValueInt8);
    vtInt16    : HugeIntInitInt32(Result, V.ValueInt16);
    vtInt32    : HugeIntInitInt32(Result, V.ValueInt32);
    vtInt64    : HugeIntInitInt64(Result, V.ValueInt64);
    // vtInt128  : HugeIntInitInt128(Result, V.ValueInt128);
    // vtInt256  : Result := V.ValueInt256^;
    vtHugeInt  : HugeIntInitHugeInt(Result, V.ValueHugeInt^);
    vtBoolean  : HugeIntInitWord32(Result, Ord(V.ValueBoolean));
  else
    raise EVariantConvertError.Create;
  end;
end;

function VariantToSingle(const V: TVariant): Single;
begin
  if V.ValueType <> vvtAssignedValue then
    raise EVariantConvertError.Create;
  case V.VariantType of
    vtWord8    : Result := V.ValueWord8;
    vtWord16   : Result := V.ValueWord16;
    vtWord32   : Result := V.ValueWord32;
    vtWord64   : Result := Word64ToFloat(V.ValueWord64);
    vtWord128  : Result := Word128ToFloat(V.ValueWord128^);
    vtWord256  : Result := Word256ToFloat(V.ValueWord256^);
    vtInt8     : Result := V.ValueInt8;
    vtInt16    : Result := V.ValueInt16;
    vtInt32    : Result := V.ValueInt32;
    vtInt64	   : Result := V.ValueInt64;
    vtInt128   : Result := Int128ToFloat(V.ValueInt128^);
    vtSingle   : Result := V.ValueSingle;
    vtCurrency : Result := V.ValueCurrency;
  else
    raise EVariantConvertError.Create;
  end;
end;

function VariantToDouble(const V: TVariant): Double;
begin
  if V.ValueType <> vvtAssignedValue then
    raise EVariantConvertError.Create;
  case V.VariantType of
    vtWord8    : Result := V.ValueWord8;
    vtWord16   : Result := V.ValueWord16;
    vtWord32   : Result := V.ValueWord32;
    vtWord64   : Result := Word64ToFloat(V.ValueWord64);
    vtWord128  : Result := Word128ToFloat(V.ValueWord128^);
    vtHugeWord : Result := HugeWordToDouble(V.ValueHugeWord^);
    vtInt8     : Result := V.ValueInt8;
    vtInt16    : Result := V.ValueInt16;
    vtInt32    : Result := V.ValueInt32;
    vtInt64	   : Result := V.ValueInt64;
    vtInt128   : Result := Int128ToFloat(V.ValueInt128^);
    vtHugeInt  : Result := HugeIntToDouble(V.ValueHugeInt^);
    vtSingle   : Result := V.ValueSingle;
    vtDouble   : Result := V.ValueDouble;
    vtCurrency : Result := V.ValueCurrency;
  else
    raise EVariantConvertError.Create;
  end;
end;

function VariantToExtended(const V: TVariant): Extended;
begin
  if V.ValueType <> vvtAssignedValue then
    raise EVariantConvertError.Create;
  case V.VariantType of
    vtWord8    : Result := V.ValueWord8;
    vtWord16   : Result := V.ValueWord16;
    vtWord32   : Result := V.ValueWord32;
    vtWord64   : Result := Word64ToFloat(V.ValueWord64);
    vtWord128  : Result := Word128ToFloat(V.ValueWord128^);
    vtHugeWord : Result := HugeWordToDouble(V.ValueHugeWord^);
    vtInt8     : Result := V.ValueInt8;
    vtInt16    : Result := V.ValueInt16;
    vtInt32    : Result := V.ValueInt32;
    vtInt64	   : Result := V.ValueInt64;
    vtInt128   : Result := Int128ToFloat(V.ValueInt128^);
    vtHugeInt  : Result := HugeIntToDouble(V.ValueHugeInt^);
    vtSingle   : Result := V.ValueSingle;
    vtDouble   : Result := V.ValueDouble;
    vtExtended : Result := V.ValueExtended;
    vtCurrency : Result := V.ValueCurrency;
  else
    raise EVariantConvertError.Create;
  end;
end;

function VariantToCurrency(const V: TVariant): Currency;
begin
  if V.ValueType <> vvtAssignedValue then
    raise EVariantConvertError.Create;
  case V.VariantType of
    vtWord8    : Result := V.ValueWord8;
    vtWord16   : Result := V.ValueWord16;
    vtWord32   : Result := V.ValueWord32;
    vtWord64   : Result := Word64ToFloat(V.ValueWord64);
    vtWord128  : Result := Word128ToFloat(V.ValueWord128^);
    vtInt8     : Result := V.ValueInt8;
    vtInt16    : Result := V.ValueInt16;
    vtInt32    : Result := V.ValueInt32;
    vtInt64	   : Result := V.ValueInt64;
    vtInt128   : Result := Int128ToFloat(V.ValueInt128^);
    vtSingle   : Result := V.ValueSingle;
    vtDouble   : Result := V.ValueDouble;
    vtExtended : Result := V.ValueExtended;
    vtCurrency : Result := V.ValueCurrency;
  else
    raise EVariantConvertError.Create;
  end;
end;

function VariantToBoolean(const V: TVariant): Boolean;
begin
  if V.ValueType <> vvtAssignedValue then
    raise EVariantConvertError.Create;
  case V.VariantType of
    vtBoolean : Result := V.ValueBoolean;
  else
    raise EVariantConvertError.Create;
  end;
end;

function VariantToAnsiChar(const V: TVariant): AnsiChar;
begin
  if V.ValueType <> vvtAssignedValue then
    raise EVariantConvertError.Create;
  case V.VariantType of
    vtAnsiChar : Result := V.ValueAnsiChar;
  else
    raise EVariantConvertError.Create;
  end;
end;

function VariantToUCS2Char(const V: TVariant): WideChar;
begin
  if V.ValueType <> vvtAssignedValue then
    raise EVariantConvertError.Create;
  case V.VariantType of
    vtUCS2Char : Result := V.ValueUCS2Char;
  else
    raise EVariantConvertError.Create;
  end;
end;

function VariantToUCS4Char(const V: TVariant): LongWord;
begin
  if V.ValueType <> vvtAssignedValue then
    raise EVariantConvertError.Create;
  case V.VariantType of
    vtAnsiChar : Result := Ord(V.ValueAnsiChar);
    vtUCS2Char : Result := Ord(V.ValueUCS2Char);
    vtUCS4Char : Result := V.ValueUCS4Char;
  else
    raise EVariantConvertError.Create;
  end;
end;

function VariantToDateTime(const V: TVariant): TDateTime;
begin
  if V.ValueType <> vvtAssignedValue then
    raise EVariantConvertError.Create;
  case V.VariantType of
    vtDateTime : Result := V.ValueDateTime;
    vtDate     : Result := V.ValueDate;
    vtTime     : Result := V.ValueTime;
  else
    raise EVariantConvertError.Create;
  end;
end;

function VariantToDate(const V: TVariant): TDateTime;
begin
  if V.ValueType <> vvtAssignedValue then
    raise EVariantConvertError.Create;
  case V.VariantType of
    vtDateTime : Result := Trunc(V.ValueDateTime);
    vtDate     : Result := V.ValueDate;
  else
    raise EVariantConvertError.Create;
  end;
end;

function VariantToTime(const V: TVariant): TDateTime;
begin
  if V.ValueType <> vvtAssignedValue then
    raise EVariantConvertError.Create;
  case V.VariantType of
    vtDateTime : Result := Frac(V.ValueDateTime);
    vtDate     : Result := 0.0;
    vtTime     : Result := V.ValueTime;
  else
    raise EVariantConvertError.Create;
  end;
end;

function VariantToShortString(const V: TVariant): ShortString;
begin
  if V.ValueType <> vvtAssignedValue then
    raise EVariantConvertError.Create;
  case V.VariantType of
    vtShortString : Result := PShortString(V.ValueShortString)^;
  else
    raise EVariantConvertError.Create;
  end;
end;

function VariantToRawByteString(const V: TVariant): RawByteString;
begin
  if V.ValueType <> vvtAssignedValue then
    raise EVariantConvertError.Create;
  case V.VariantType of
    vtWord8         : Result := IntToStringB(V.ValueWord8);
    vtWord16        : Result := IntToStringB(V.ValueWord16);
    vtWord32        : Result := IntToStringB(V.ValueWord32);
    // vtWord64        : Result := Word64ToStrB(V.ValueWord64);
    // vtWord128       : Result := Word128ToStrB(V.ValueWord128^);
    // vtWord256       : Result := Word256ToStrB(V.ValueWord256^);
    // vtHugeWord      : Result := HugeWordToStrB(V.ValueHugeWord^);
    vtInt8          : Result := IntToStringB(V.ValueInt8);
    vtInt16         : Result := IntToStringB(V.ValueInt16);
    vtInt32         : Result := IntToStringB(V.ValueInt32);
    vtInt64         : Result := IntToStringB(V.ValueInt64);
    // vtInt128        : Result := Int128ToStrB(V.ValueInt128^);
    // vtInt256        : Result := Int256ToStrB(V.ValueInt256^);
    // vtHugeInt       : Result := HugeIntToStrB(V.ValueHugeInt^);
    vtShortString   : Result := PShortString(V.ValueShortString)^;
    vtRawByteString : Result := RawByteString(V.ValueRawByteString);
    vtAnsiString    : Result := AnsiString(V.ValueAnsiString);
    vtPAnsiChar     : Result := StrPasB(V.ValuePAnsiChar);
    vtBoolean       : Result := iifB(V.ValueBoolean, '1', '0');
  else
    raise EVariantConvertError.Create;
  end;
end;

function VariantToAnsiString(const V: TVariant): AnsiString;
begin
  if V.ValueType <> vvtAssignedValue then
    raise EVariantConvertError.Create;
  case V.VariantType of
    vtWord8         : Result := IntToStringA(V.ValueWord8);
    vtWord16        : Result := IntToStringA(V.ValueWord16);
    vtWord32        : Result := IntToStringA(V.ValueWord32);
    vtWord64        : Result := Word64ToStrA(V.ValueWord64);
    vtWord128       : Result := Word128ToStrA(V.ValueWord128^);
    // vtWord256       : Result := Word256ToStrA(V.ValueWord256^);
    vtHugeWord      : Result := HugeWordToStrA(V.ValueHugeWord^);
    vtInt8          : Result := IntToStringA(V.ValueInt8);
    vtInt16         : Result := IntToStringA(V.ValueInt16);
    vtInt32         : Result := IntToStringA(V.ValueInt32);
    vtInt64         : Result := IntToStringA(V.ValueInt64);
    vtInt128        : Result := Int128ToStrA(V.ValueInt128^);
    // vtInt256        : Result := Int256ToStrA(V.ValueInt256^);
    vtHugeInt       : Result := HugeIntToStrA(V.ValueHugeInt^);
    vtShortString   : Result := PShortString(V.ValueShortString)^;
    vtRawByteString : Result := RawByteString(V.ValueRawByteString);
    vtAnsiString    : Result := AnsiString(V.ValueAnsiString);
    vtPAnsiChar     : Result := StrPasA(V.ValuePAnsiChar);
    vtBoolean       : Result := iifA(V.ValueBoolean, '1', '0');
  else
    raise EVariantConvertError.Create;
  end;
end;

function VariantToWideString(const V: TVariant): WideString;
begin
  if V.ValueType <> vvtAssignedValue then
    raise EVariantConvertError.Create;
  case V.VariantType of
    vtWord8       : Result := IntToStringW(V.ValueWord8);
    vtWord16      : Result := IntToStringW(V.ValueWord16);
    vtWord32      : Result := IntToStringW(V.ValueWord32);
    // vtWord64      : Result := Word64ToStrW(V.ValueWord64);
    // vtWord128     : Result := Word128ToStrW(V.ValueWord128^);
    vtHugeWord    : Result := HugeWordToStrW(V.ValueHugeWord^);
    vtInt8        : Result := IntToStringW(V.ValueInt8);
    vtInt16       : Result := IntToStringW(V.ValueInt16);
    vtInt32       : Result := IntToStringW(V.ValueInt32);
    vtInt64       : Result := IntToStringW(V.ValueInt64);
    // vtInt128      : Result := Int128ToStrW(V.ValueInt128^);
    vtHugeInt     : Result := HugeIntToStrW(V.ValueHugeInt^);
    vtWideString  : Result := WideString(V.ValueWideString);
    vtPWideChar   : Result := V.ValuePWideChar^;
  else
    raise EVariantConvertError.Create;
  end;
end;

function VariantToUnicodeString(const V: TVariant): UnicodeString;
begin
  if V.ValueType <> vvtAssignedValue then
    raise EVariantConvertError.Create;
  case V.VariantType of
    vtWord8         : Result := IntToStringU(V.ValueWord8);
    vtWord16        : Result := IntToStringU(V.ValueWord16);
    vtWord32        : Result := IntToStringU(V.ValueWord32);
    vtHugeWord      : Result := HugeWordToStrU(V.ValueHugeWord^);
    vtInt8          : Result := IntToStringU(V.ValueInt8);
    vtInt16         : Result := IntToStringU(V.ValueInt16);
    vtInt32         : Result := IntToStringU(V.ValueInt32);
    vtInt64         : Result := IntToStringU(V.ValueInt64);
    vtHugeInt       : Result := HugeIntToStrU(V.ValueHugeInt^);
    vtUnicodeString : Result := UnicodeString(V.ValueUnicodeString);
    vtPWideChar     : Result := V.ValuePWideChar^;
  else
    raise EVariantConvertError.Create;
  end;
end;

function VariantToString(const V: TVariant): String;
begin
  {$IFDEF StringIsUnicode}
  Result := VariantToUnicodeString(V);
  {$ELSE}
  Result := VariantToAnsiString(V);
  {$ENDIF}
end;

function VariantToPAnsiChar(const V: TVariant): PAnsiChar;
begin
  if V.ValueType <> vvtAssignedValue then
    raise EVariantConvertError.Create;
  case V.VariantType of
    vtRawByteString : Result := PAnsiChar(RawByteString(V.ValueRawByteString));
    vtAnsiString    : Result := PAnsiChar(AnsiString(V.ValueAnsiString));
    vtPAnsiChar     : Result := V.ValuePAnsiChar;
  else
    raise EVariantConvertError.Create;
  end;
end;

function VariantToPWideChar(const V: TVariant): PWideChar;
begin
  if V.ValueType <> vvtAssignedValue then
    raise EVariantConvertError.Create;
  case V.VariantType of
    vtWideString : Result := PWideChar(WideString(V.ValueWideString));
    vtPWideChar  : Result := V.ValuePWideChar;
  else
    raise EVariantConvertError.Create;
  end;
end;

function VariantToPointer(const V: TVariant): Pointer;
begin
  if V.ValueType <> vvtAssignedValue then
    raise EVariantConvertError.Create;
  case V.VariantType of
    vtRawByteString : Result := PRawByteChar(RawByteString(V.ValueRawByteString));
    vtAnsiString    : Result := PAnsiChar(AnsiString(V.ValueAnsiString));
    vtWideString    : Result := PWideChar(WideString(V.ValueWideString));
    vtPAnsiChar     : Result := V.ValuePAnsiChar;
    vtPWideChar     : Result := V.ValuePWideChar;
    vtPointer       : Result := V.ValuePointer;
    vtObject        : Result := V.ValueObject;
    vtIntfObject    : Result := V.ValueIntfObject;
    vtInterface     : Result := V.ValueInterface;
  else
    raise EVariantConvertError.Create;
  end;
end;

function VariantToObject(const V: TVariant): TObject;
begin
  if V.ValueType <> vvtAssignedValue then
    raise EVariantConvertError.Create;
  case V.VariantType of
    vtObject     : Result := TObject(V.ValueObject);
    vtIntfObject : Result := TObject(V.ValueIntfObject);
  else
    raise EVariantConvertError.Create;
  end;
end;

function VariantToIntfObject(const V: TVariant): TInterfacedObject;
begin
  if V.ValueType <> vvtAssignedValue then
    raise EVariantConvertError.Create;
  case V.VariantType of
    vtIntfObject : Result := TInterfacedObject(V.ValueIntfObject);
  else
    raise EVariantConvertError.Create;
  end;
end;

function VariantToInterface(const V: TVariant): IInterface;
begin
  if V.ValueType <> vvtAssignedValue then
    raise EVariantConvertError.Create;
  case V.VariantType of
    vtIntfObject : Result := IInterface(V.ValueIntfObject);
    vtInterface  : Result := IInterface(V.ValueInterface);
  else
    raise EVariantConvertError.Create;
  end;
end;

function VariantToVariant(const V: TVariant): TVariant;
begin
  if V.ValueType <> vvtAssignedValue then
    raise EVariantConvertError.Create;
  case V.VariantType of
    vtVariant : Result := V.ValueVariant^;
  else
    raise EVariantConvertError.Create;
  end;
end;

function VariantToVariantArray(const V: TVariant): TVariantArrayRec;
begin
  if V.ValueType <> vvtAssignedValue then
    raise EVariantConvertError.Create;
  case V.VariantType of
    vtVariantArray : Result := V.ValueVariantArray^;
  else
    raise EVariantConvertError.Create;
  end;
end;

function VariantToVariantDictionary(const V: TVariant): TVariantDictionaryRec;
begin
  if V.ValueType <> vvtAssignedValue then
    raise EVariantConvertError.Create;
  case V.VariantType of
    vtVariantDictionary : Result := V.ValueVariantDictionary^;
  else
    raise EVariantConvertError.Create;
  end;
end;



{ Variant Convert Type }

procedure VariantConvertToType(var V: TVariant; const T: TVariantType);
begin
  if V.VariantType = T then
    exit;
  if V.ValueType in [vvtUnassigned, vvtAssignedNull, vvtAssignedDefault] then
    begin
      V.VariantType := T;
      exit;
    end;
  Assert(V.ValueType = vvtAssignedValue);
  case T of
    vtWord8             : VariantSetWord8(V, VariantToWord8(V));
    vtWord16            : VariantSetWord16(V, VariantToWord16(V));
    vtWord32            : VariantSetWord32(V, VariantToWord32(V));
    vtWord64            : VariantSetWord64(V, VariantToWord64(V));
    vtWord128           : VariantSetWord128(V, VariantToWord128(V));
    vtWord256           : VariantSetWord256(V, VariantToWord256(V));
    vtHugeWord          : VariantSetHugeWord(V, VariantToHugeWord(V));
    vtInt8              : VariantSetInt8(V, VariantToInt8(V));
    vtInt16             : VariantSetInt16(V, VariantToInt16(V));
    vtInt32             : VariantSetInt32(V, VariantToInt32(V));
    vtInt64             : VariantSetInt64(V, VariantToInt64(V));
    vtInt128            : VariantSetInt128(V, VariantToInt128(V));
    vtInt256            : VariantSetInt256(V, VariantToInt256(V));
    vtHugeInt           : VariantSetHugeInt(V, VariantToHugeInt(V));
    vtSingle            : VariantSetSingle(V, VariantToSingle(V));
    vtDouble            : VariantSetDouble(V, VariantToDouble(V));
    vtExtended          : VariantSetExtended(V, VariantToExtended(V));
    vtCurrency          : VariantSetCurrency(V, VariantToCurrency(V));
    vtBoolean           : VariantSetBoolean(V, VariantToBoolean(V));
    vtAnsiChar          : VariantSetAnsiChar(V, VariantToAnsiChar(V));
    vtUCS2Char          : VariantSetUCS2Char(V, VariantToUCS2Char(V));
    vtUCS4Char          : VariantSetUCS4Char(V, VariantToUCS4Char(V));
    vtDateTime          : VariantSetDateTime(V, VariantToDateTime(V));
    vtDate              : VariantSetDate(V, VariantToDate(V));
    vtTime              : VariantSetTime(V, VariantToTime(V));
    vtShortString       : VariantSetShortString(V, VariantToShortString(V));
    vtRawByteString     : VariantSetRawByteString(V, VariantToRawByteString(V));
    vtAnsiString        : VariantSetAnsiString(V, VariantToAnsiString(V));
    vtWideString        : VariantSetWideString(V, VariantToWideString(V));
    vtPointer           : VariantSetPointer(V, VariantToPointer(V));
    vtObject            : VariantSetObject(V, VariantToObject(V));
    vtIntfObject        : VariantSetIntfObject(V, VariantToIntfObject(V));
    vtInterface         : VariantSetInterface(V, VariantToInterface(V));
    vtVariant           : VariantSetVariant(V, VariantToVariant(V));
    vtVariantArray      : VariantSetVariantArray(V, VariantToVariantArray(V));
    vtVariantDictionary : VariantSetVariantDictionary(V, VariantToVariantDictionary(V));
  else
    raise EVariantConvertError.Create;
  end;
end;

{ Variant Operations }

function ExtendedCompare(const A, B: Extended): Integer;
begin
  if A < B then
    Result := -1
  else
  if A > B then
    Result := 1
  else
    Result := 0;
end;

function BooleanCompare(const A, B: Boolean): Integer;
begin
  if A < B then
    Result := -1
  else
  if A > B then
    Result := 1
  else
    Result := 0;
end;

function DateTimeCompare(const A, B: TDateTime): Integer;
begin
  if A < B then
    Result := -1
  else
  if A > B then
    Result := 1
  else
    Result := 0;
end;

function VariantsCompareAssignedValues(const A, B: TVariant): Integer;
begin
  Assert(A.ValueType = vvtAssignedValue);
  Assert(B.ValueType = vvtAssignedValue);

  if (A.VariantType in [vtShortString, vtRawByteString, vtAnsiString]) or
     (B.VariantType in [vtShortString, vtRawByteString, vtAnsiString]) then
    Result := StrCompareB(VariantToRawByteString(A), VariantToRawByteString(B))
  else
  if (A.VariantType in [vtSingle, vtDouble, vtExtended]) or
     (B.VariantType in [vtSingle, vtDouble, vtExtended]) then
    Result := ExtendedCompare(VariantToExtended(A), VariantToExtended(B))
  else
  if (A.VariantType = vtBoolean) or
     (B.VariantType = vtBoolean) then
    Result := BooleanCompare(VariantToBoolean(A), VariantToBoolean(B))
  else
  if (A.VariantType in [vtInt8, vtInt16, vtInt32, vtInt64, vtWord8, vtWord16, vtWord32]) and
     (B.VariantType in [vtInt8, vtInt16, vtInt32, vtInt64, vtWord8, vtWord16, vtWord32]) then
    Result := Int64Compare(VariantToInt64(A), VariantToInt64(B))
  else
  if (A.VariantType in [vtAnsiChar, vtUCS2Char, vtUCS4Char]) and
     (B.VariantType in [vtAnsiChar, vtUCS2Char, vtUCS4Char]) then
    Result := Int32Compare(VariantToInt32(A), VariantToInt32(B))
  else
  if (A.VariantType in [vtDateTime, vtDate, vtTime]) and
     (B.VariantType in [vtDateTime, vtDate, vtTime]) then
    Result := DateTimeCompare(VariantToDateTime(A), VariantToDateTime(B))
  else
  if (A.VariantType = vtVariantArray) and (B.VariantType = vtVariantArray) then
    Result := VariantArrayCompare(VariantToVariantArray(A), VariantToVariantArray(B))
  else
  if (A.VariantType = vtVariantDictionary) or (B.VariantType = vtVariantDictionary) then
    raise EVariantConvertError.Create
  else
    raise EVariantConvertError.Create;
end;

// Comparison precedence (from lowest to highest)
//   1. Unassigned
//   2. Null value
//   3. Default value
//   4. Assigned value
function VariantsCompare(const A, B: TVariant): Integer;
begin
  case A.ValueType of
    vvtUnassigned :
      if B.ValueType = vvtUnassigned then
        Result := 0
      else
        Result := -1;
    vvtAssignedNull :
      case B.ValueType of
        vvtUnassigned   : Result := 1;
        vvtAssignedNull : Result := 0;
      else
        Result := -1;
      end;
    vvtAssignedDefault :
      case B.ValueType of
        vvtUnassigned,
        vvtAssignedNull    : Result := 1;
        vvtAssignedDefault : Result := 0;
      else
        Result := -1;
      end;
    vvtAssignedValue :
      case B.ValueType of
        vvtUnassigned,
        vvtAssignedNull,
        vvtAssignedDefault : Result := 1;
        vvtAssignedValue   : Result := VariantsCompareAssignedValues(A, B);
      else
        raise EVariantError.Create('Invalid value type');
      end;
  else
    raise EVariantError.Create('Invalid value type');
  end;
end;

function VariantsEqual(const A, B : TVariant): Boolean;
begin
  Result := VariantsCompare(A, B) = 0;
end;

function VariantHash32(const A: TVariant): LongWord;
begin
  case A.ValueType of
    vvtUnassigned      : Result := 0 + Ord(A.VariantType);
    vvtAssignedNull    : Result := 1 + Ord(A.VariantType);
    vvtAssignedDefault : Result := 2 + Ord(A.VariantType);
    vvtAssignedValue   :
      case A.VariantType of
        vtNone              : Result := 0;
        vtWord8             : Result := CalcXOR32(A.ValueWord8, 1);
        vtWord16            : Result := CalcXOR32(A.ValueWord16, 2);
        vtWord32            : Result := CalcXOR32(A.ValueWord32, 4);
        vtWord64            : Result := CalcXOR32(A.ValueWord64, 8);
        vtWord128           : Result := CalcXOR32(A.ValueWord128^, 16);
        vtWord256           : Result := CalcXOR32(A.ValueWord256^, 32);
        vtHugeWord          : Result := CalcXOR32(A.ValueHugeWord^.Data^, A.ValueHugeWord^.Used);
        vtInt8              : Result := CalcXOR32(A.ValueInt8, 1);
        vtInt16             : Result := CalcXOR32(A.ValueInt16, 2);
        vtInt32             : Result := CalcXOR32(A.ValueInt32, 4);
        vtInt64             : Result := CalcXOR32(A.ValueInt64, 8);
        vtInt128            : Result := CalcXOR32(A.ValueInt128^, 16);
        vtInt256            : Result := CalcXOR32(A.ValueInt256^, 32);
        vtHugeInt           : Result := CalcXOR32(A.ValueHugeInt^.Value.Data^, A.ValueHugeInt^.Value.Used);
        vtSingle            : Result := CalcAdler32(A.ValueSingle, SizeOf(Single));
        vtDouble            : Result := CalcAdler32(A.ValueDouble, SizeOf(Double));
        vtExtended          : Result := CalcAdler32(A.ValueExtended, SizeOf(Extended));
        vtCurrency          : Result := CalcAdler32(A.ValueCurrency, SizeOf(Currency));
        vtBoolean           : Result := Ord(A.ValueBoolean);
        vtAnsiChar          : Result := Ord(A.ValueAnsiChar);
        vtUCS2Char          : Result := Ord(A.ValueUCS2Char);
        vtUCS4Char          : Result := Ord(A.ValueUCS4Char);
        vtDateTime          : Result := CalcAdler32(A.ValueDateTime, SizeOf(TDateTime));
        vtDate              : Result := CalcAdler32(A.ValueDate, SizeOf(Double));
        vtTime              : Result := CalcAdler32(A.ValueTime, SizeOf(Double));
        vtShortString       : Result := CalcAdler32(PShortString(A.ValueShortString)^, Length(PShortString(A.ValueShortString)^));
        vtRawByteString     : Result := CalcAdler32(RawByteString(A.ValueRawByteString));
        vtAnsiString        : Result := CalcAdler32(AnsiString(A.ValueAnsiString));
        vtWideString        : Result := CalcAdler32(PWideChar(WideString(A.ValueWideString))^, Length(WideString(A.ValueWideString)));
        vtUnicodeString     : Result := CalcAdler32(PWideChar(UnicodeString(A.ValueUnicodeString))^, Length(UnicodeString(A.ValueUnicodeString)));
        vtPAnsiChar         : Result := CalcAdler32(A.ValuePAnsiChar^, StrLenA(A.ValuePAnsiChar));
        vtPWideChar         : Result := CalcAdler32(A.ValuePWideChar^, StrLenW(A.ValuePWideChar));
        vtPointer           : Result := CalcXOR32(A.ValuePointer, SizeOf(Pointer));
        vtObject            : Result := CalcXOR32(A.ValueObject, SizeOf(Pointer));
        vtIntfObject        : Result := CalcXOR32(A.ValueIntfObject, SizeOf(Pointer));
        vtInterface         : Result := CalcXOR32(A.ValueInterface, SizeOf(Pointer));
        vtClass             : Result := CalcXOR32(A.ValueClass, SizeOf(Pointer));
        vtVariant           : Result := VariantHash32(A.ValueVariant^);
        vtVariantArray      : Result := VariantArrayHash32(A.ValueVariantArray^);
        vtVariantDictionary : Result := VariantDictionaryHash32(A.ValueVariantDictionary^);
      else
        Result := 0;
      end;
  else
    Result := 0;
  end;
end;




{                                                                              }
{ Variant array functions                                                      }
{                                                                              }

procedure VariantArrayInit(out A: TVariantArrayRec);
begin
  FillChar(A, SizeOf(A), 0);
  A.List := nil;
  A.Used := 0;
end;

procedure VariantArrayFinalise(var A: TVariantArrayRec);
var
  I : Integer;
begin
  for I := A.Used - 1 downto 0 do
    VariantFinalise(A.List[I]);
  A.Used := 0;
  A.List := nil;
end;

function VariantArrayGetLength(const A: TVariantArrayRec): Integer;
begin
  Result := A.Used;
end;

procedure VariantArraySetLength(var A: TVariantArrayRec; const L: Integer);
var
  Len, N, M : Integer;
  I : Integer;
begin
  Len := A.Used;
  if L = Len then
    exit;
  if L < Len then
    for I := Len - 1 downto L do
      VariantFinalise(A.List[I])
  else
    begin
      N := Length(A.List);
      if L > N then
        begin
          if N = 0 then
            M := L
          else
            begin
              M := N * 2;
              if M < L then
                M := L;
            end;
          SetLength(A.List, M);
        end;
      for I := Len to L - 1 do
        VariantInit(A.List[I]);
    end;
  A.Used := L;
end;

procedure VariantArrayClear(var A: TVariantArrayRec);
var
  I : Integer;
begin
  for I := A.Used - 1 downto 0 do
    VariantFinalise(A.List[I]);
  A.Used := 0;
  A.List := nil;
end;

procedure VariantArrayAppendItem(var A: TVariantArrayRec; const B: TVariant);
var
  I : Integer;
begin
  I := A.Used;
  VariantArraySetLength(A, I + 1);
  VariantInitValue(A.List[I], B);
end;

procedure VariantArraySetItem(const A: TVariantArrayRec; const Idx: Integer; const B: TVariant);
begin
  if (Idx < 0) or (Idx >= A.Used) then
    raise EVariantError.Create('Index out of range');
  VariantSetValue(A.List[Idx], B);
end;

procedure VariantArrayGetItem(const A: TVariantArrayRec; const Idx: Integer; out B: TVariant);
begin
  if (Idx < 0) or (Idx >= A.Used) then
    raise EVariantError.Create('Index out of range');
  VariantInitValue(B, A.List[Idx]);
end;

function VariantArrayGetItemIndex(const A: TVariantArrayRec; const B: TVariant): Integer;
var
  I : Integer;
begin
  for I := 0 to A.Used - 1 do
    if VariantsEqual(A.List[I], B) then
      begin
        Result := I;
        exit;
      end;
  Result := -1;
end;

procedure VariantArrayRemove(var A: TVariantArrayRec; const Idx: Integer; const Count: Integer);
var
  L, J, M, I : Integer;
begin
  if Count <= 0 then
    exit;
  L := A.Used;
  if (L = 0) or (Idx >= L) then
    exit;
  if Idx < 0 then
    raise EVariantError.Create('Index out of range');
  J := L - Idx;
  if Count < J then
    J := Count;
  M := L - J - Idx;
  for I := 0 to J - 1 do
    VariantFinalise(A.List[Idx + I]);
  for I := 0 to M - 1 do
    Move(A.List[Idx + J + I], A.List[Idx + I], SizeOf(TVariant));
  A.Used := L - J;
end;

procedure VariantArrayDuplicate(const A: TVariantArrayRec; out B: TVariantArrayRec);
var
  L, I : Integer;
begin
  VariantArrayInit(B);
  try
    L := A.Used;
    if L = 0 then
      exit;
    VariantArraySetLength(B, L);
    for I := 0 to L - 1 do
      VariantInitValue(B.List[I], A.List[I]);
  except
    VariantArrayFinalise(B);
    raise;
  end;
end;

procedure VariantArrayInitOpenArray(out A: TVariantArrayRec; const B: array of const);
var
  L, I : Integer;
begin
  VariantArrayInit(A);
  L := Length(B);
  VariantArraySetLength(A, L);
  try
    for I := 0 to L - 1 do
      VariantInitVarRec(A.List[I], B[I]);
  except
    VariantArrayFinalise(A);
    raise;
  end;
end;

function VariantArrayCompare(const A, B: TVariantArrayRec): Integer;
var
  L, N, I, C : Integer;
begin
  L := A.Used;
  N := B.Used;
  if L < N then
    Result := -1
  else
  if L > N then
    Result := 1
  else
    begin
      for I := 0 to L - 1 do
        begin
          C := VariantsCompare(A.List[I], B.List[I]);
          if C <> 0 then
            begin
              Result := C;
              exit;
            end;
        end;
      Result := 0;
    end;
end;

function VariantArrayHash32(const A: TVariantArrayRec): LongWord;
var
  I : Integer;
  H : LongWord;
begin
  H := 0;
  for I := 0 to A.Used - 1 do
    H := H xor VariantHash32(A.List[I]);
  Result := H;
end;



{                                                                              }
{ Variant dictionary functions                                                 }
{                                                                              }

procedure VariantDictionaryInit(out A: TVariantDictionaryRec);
begin
  FillChar(A, SizeOf(A), 0);
  A.List := nil;
  A.Used := 0;
  A.Hash := nil;
end;

procedure VariantDictionaryItemFinalise(var A: TVariantDictionaryItem);
begin
  VariantFinalise(A.Name);
  VariantFinalise(A.Value);
end;

procedure VariantDictionaryFinalise(var A: TVariantDictionaryRec);
var
  I : Integer;
begin
  A.Hash := nil;
  for I := A.Used - 1 downto 0 do
    VariantDictionaryItemFinalise(A.List[I]);
  A.Used := 0;
  A.List := nil;
end;

function VariantDictionaryHashTableSize(const ItemCount: Integer): Integer;
begin
  if ItemCount <= $1000 then
    Result := $3F else
  if ItemCount <= $10000 then
    Result := $3FF
  else
  if ItemCount <= $1000000 then
    Result := $3FFF
  else
    Result := $3FFFF;
end;

procedure VariantDictionaryRehash(var A: TVariantDictionaryRec; const HashTableSize: Integer);
var
  I, N : Integer;
  H : LongWord;
begin
  A.Hash := nil;
  SetLength(A.Hash, HashTableSize);
  for I := 0 to A.Used - 1 do
    begin
      H := VariantHash32(A.List[I].Name) mod LongWord(HashTableSize);
      N := Length(A.Hash[H]);
      SetLength(A.Hash[H], N + 1);
      A.Hash[H][N] := I;
    end;
end;

procedure VariantDictionaryAdd(var A: TVariantDictionaryRec; const Name, Value: TVariant);
var
  G, L, F, T, N, C : Integer;
  H : LongWord;
  P : PVariantDictionaryItem;
begin
  L := A.Used;
  G := VariantDictionaryHashTableSize(L + 1);
  F := Length(A.Hash);
  if G <> F then
    VariantDictionaryRehash(A, G);
  C := Length(A.List);
  if L >= C then
    begin
      if C < 16 then
        C := 16
      else
        C := C * 2;
      SetLength(A.List, C);
    end;
  A.Used := L + 1;
  P := @A.List[L];
  VariantInitValue(P^.Name, Name);
  VariantInitValue(P^.Value, Value);
  T := Length(A.Hash);
  H := VariantHash32(Name) mod LongWord(T);
  N := Length(A.Hash[H]);
  SetLength(A.Hash[H], N + 1);
  A.Hash[H][N] := L;
end;

function VariantDictionaryLocate(const A: TVariantDictionaryRec; const Name: TVariant;
         out ItemIdx, HashIdx, HashSubIdx: Integer): Boolean; overload;
var
  T, I, J : Integer;
  H : LongWord;
begin
  T := Length(A.Hash);
  H := VariantHash32(Name) mod LongWord(T);
  for I := 0 to Length(A.Hash[H]) - 1 do
    begin
      J := A.Hash[H][I];
      if VariantsEqual(A.List[J].Name, Name) then
        begin
          ItemIdx := J;
          HashIdx := H;
          HashSubIdx := I;
          Result := True;
          exit;
        end;
    end;
  ItemIdx := -1;
  Result := False;
end;

function VariantDictionaryLocate(const A: TVariantDictionaryRec; const Name: TVariant;
         out ItemIdx: Integer): Boolean; overload;
var
  HashIdx, HashSubIdx : Integer;
begin
  Result := VariantDictionaryLocate(A, Name, ItemIdx, HashIdx, HashSubIdx);
end;

function VariantDictionaryGet(const A: TVariantDictionaryRec; const Name: TVariant; out Value: TVariant): Boolean;
var
  I : Integer;
begin
  if VariantDictionaryLocate(A, Name, I) then
    begin
      VariantInitValue(Value, A.List[I].Value);
      Result := True;
    end
  else
    Result := False;
end;

procedure VariantDictionarySet(var A: TVariantDictionaryRec; const Name, Value: TVariant);
var
  I : Integer;
begin
  if VariantDictionaryLocate(A, Name, I) then
    VariantSetValue(A.List[I].Value, Value)
  else
    VariantDictionaryAdd(A, Name, Value);
end;

procedure VariantDictionaryRemove(var A: TVariantDictionaryRec; const Name: TVariant);
var
  I, H, F : Integer;
  P : PVariantDictionaryItem;
  L, J, N : Integer;
begin
  if not VariantDictionaryLocate(A, Name, I, H, F) then
    exit;

  N := Length(A.Hash[H]);
  for J := F to N - 2 do
    A.Hash[H][J] := A.Hash[H][J + 1];
  SetLength(A.Hash[H], N - 1);

  P := @A.List[I];
  L := A.Used;
  for J := I to L - 2 do
    Move(A.List[J + 1], A.List[J], SizeOf(TVariantDictionaryItem));
  A.Used := L - 1;

  VariantFinalise(P^.Name);
  VariantFinalise(P^.Value);
end;

procedure VariantDictionaryDuplicate(const A: TVariantDictionaryRec; out B: TVariantDictionaryRec);
var
  I : Integer;
  P : PVariantDictionaryItem;
begin
  VariantDictionaryInit(B);
  try
    for I := 0 to Length(A.List) - 1 do
      begin
        P := @A.List[I];
        VariantDictionaryAdd(B, P^.Name, P^.Value);
      end;
  except
    VariantDictionaryFinalise(B);
    raise;
  end;
end;

function VariantDictionaryItemCount(const A: TVariantDictionaryRec): Integer;
begin
  Result := A.Used;
end;

procedure VariantDictionaryGetItemByIndex(const A: TVariantDictionaryRec;
         const Idx: Integer; out Name, Value: TVariant);
var
  P : PVariantDictionaryItem;
begin
  if (Idx < 0) or (Idx >= A.Used) then
    raise EVariantError.Create('Index out of range');
  P := @A.List[Idx];
  VariantInitValue(Name, P^.Name);
  VariantInitValue(Value, P^.Value);
end;

procedure VariantDictionaryInitOpenArray(out A: TVariantDictionaryRec; const B: array of const);
var
  L, I : Integer;
  N, V : TVariant;
begin
  VariantDictionaryInit(A);
  try
    L := Length(B) div 2;
    for I := 0 to L - 1 do
      begin
        VariantInitVarRec(N, B[I * 2]);
        VariantInitVarRec(V, B[I * 2 + 1]);
        VariantDictionaryAdd(A, N, V);
        VariantFinalise(V);
        VariantFinalise(N);
      end;
  except
    VariantDictionaryFinalise(A);
    raise;
  end;
end;

function VariantDictionaryHash32(const A: TVariantDictionaryRec): LongWord;
var
  H : LongWord;
  I : Integer;
  P : PVariantDictionaryItem;
begin
  H := 0;
  for I := 0 to A.Used - 1 do
    begin
      P := @A.List[I];
      H := H xor VariantHash32(P^.Name)
             xor VariantHash32(P^.Value);
    end;
  Result := H;
end;



{                                                                              }
{ Test cases                                                                   }
{                                                                              }
{$IFDEF DEBUG}
{$ASSERTIONS ON}
procedure SelfTest_VariantArray;
var
  A : TVariantArrayRec;
  B, C : TVariant;
begin
  VariantInit(B);

  VariantArrayInit(A);
  Assert(VariantArrayGetLength(A) = 0);

  VariantSetInt32(B, 10);
  VariantArrayAppendItem(A, B);
  Assert(VariantArrayGetLength(A) = 1);

  VariantArrayGetItem(A, 0, C);
  Assert(VariantToInt32(C) = 10);
  VariantFinalise(C);

  VariantSetRawByteString(B, 'abc');
  VariantArrayAppendItem(A, B);
  Assert(VariantArrayGetLength(A) = 2);

  VariantArrayGetItem(A, 1, C);
  Assert(VariantToRawByteString(C) = 'abc');
  VariantFinalise(C);

  VariantArrayFinalise(A);

  VariantFinalise(B);
  VariantFinalise(C);
end;

procedure SelfTest_VariantDictionary;
var
  A : TVariantDictionaryRec;
  N, V, F : TVariant;
begin
  VariantInit(N);
  VariantInit(V);

  VariantDictionaryInit(A);
  Assert(VariantDictionaryItemCount(A) = 0);

  VariantSetRawByteString(N, 'Name');
  VariantSetInt32(V, 32);
  VariantDictionaryAdd(A, N, V);
  Assert(VariantDictionaryItemCount(A) = 1);

  VariantSetRawByteString(N, 'Name2');
  Assert(not VariantDictionaryGet(A, N, F));

  VariantSetRawByteString(N, 'Name');
  Assert(VariantDictionaryGet(A, N, F));
  Assert(VariantToInt32(F) = 32);
  VariantFinalise(F);

  VariantSetRawByteString(N, 'Name2');
  VariantSetRawByteString(V, '123');
  VariantDictionaryAdd(A, N, V);
  Assert(VariantDictionaryItemCount(A) = 2);

  VariantSetRawByteString(N, 'Name2');
  Assert(VariantDictionaryGet(A, N, F));
  Assert(VariantToRawByteString(F) = '123');
  VariantFinalise(F);

  VariantSetRawByteString(N, 'Name2');
  VariantSetInt32(V, 99);
  VariantDictionarySet(A, N, V);
  Assert(VariantDictionaryItemCount(A) = 2);

  Assert(VariantDictionaryGet(A, N, F));
  Assert(VariantToInt32(F) = 99);
  VariantFinalise(F);

  VariantDictionaryRemove(A, N);
  Assert(VariantDictionaryItemCount(A) = 1);

  Assert(not VariantDictionaryGet(A, N, F));

  VariantDictionaryFinalise(A);
end;

procedure SelfTest_Variant;
var A, B, C : TVariant;
begin
  // variant structure
  Assert(VARIANT_STRUCTURE_SIZE = 12);

  // variant state
  VariantInit(A);
  Assert(VariantIsUnassigned(A));
  Assert(not VariantIsAssigned(A));
  Assert(not VariantTypeIsDefined(A));
  Assert(VariantTypeIs(A, vtNone));
  VariantFinalise(A);

  // variant state
  VariantInitInt32(B, $12345678);
  Assert(not VariantIsUnassigned(B));
  Assert(VariantIsAssigned(B));
  Assert(VariantTypeIsDefined(B));
  Assert(VariantTypeIs(B, vtInt32));
  VariantFinalise(B);

  // basic type rules
  VariantInitInt32(A, $12345678);
  Assert(VariantTypeIs(A, vtInt32));
  Assert(VariantToInt32(A) = $12345678);
  VariantInitValue(B, A);
  Assert(VariantTypeIs(B, vtInt32));
  Assert(VariantToInt32(B) = $12345678);
  VariantInitVariant(C, A);
  Assert(VariantTypeIs(C, vtVariant));
  VariantSetInt32(C, $11223344);
  Assert(VariantTypeIs(C, vtInt32));
  Assert(VariantToInt32(C) = $11223344);
  VariantFinalise(C);
  VariantFinalise(B);
  VariantFinalise(A);

  // string types
  VariantInitAnsiString(A, '12345');
  VariantInitShortString(B, '12345');
  VariantInitUnicodeString(C, '12345');
  Assert(VariantToAnsiString(A) = '12345');
  Assert(VariantToShortString(B) = '12345');
  Assert(VariantToUnicodeString(C) = '12345');
  VariantFinalise(C);
  VariantFinalise(B);
  VariantFinalise(A);

  // string types
  VariantInit(A);
  VariantInit(B);
  VariantInit(C);

  VariantSetInt32(A, 5);
  Assert(VariantToInt32(A) = 5);

  VariantSetAnsiString(A, 'Test');
  Assert(VariantToAnsiString(A) = 'Test');

  VariantSetShortString(A, 'Abc');
  Assert(VariantToShortString(A) = 'Abc');
  Assert(VariantToAnsiString(A) = 'Abc');

  VariantSetAnsiString(B, '123');
  Assert(VariantIsAssignedValue(B));
  Assert(VariantTypeIs(B, vtAnsiString));
  VariantSetVariant(A, B);
  Assert(VariantIsAssignedValue(A));
  Assert(VariantTypeIs(A, vtVariant));
  C := VariantToVariant(A);
  Assert(VariantTypeIs(C, vtAnsiString));
  Assert(VariantToAnsiString(C) = '123');

  VariantFinalise(C);
  VariantFinalise(B);
  VariantFinalise(A);

  // integer types
  VariantInitInt32(A, 123);
  VariantInitInt64(B, 100);

  Assert(VariantToInt32(A) = 123);
  Assert(VariantToInt64(B) = 100);
  Assert(VariantsCompare(A, B) = 1);
  Assert(VariantsCompare(B, A) = -1);
  Assert(VariantsCompare(A, A) = 0);

  VariantFinalise(B);
  VariantFinalise(A);
end;

procedure SelfTest;
begin
  SelfTest_Variant;
  SelfTest_VariantArray;
  SelfTest_VariantDictionary;
end;
{$ENDIF}



end.

