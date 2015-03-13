{******************************************************************************}
{                                                                              }
{   Library:          Fundamentals 4.00                                        }
{   File name:        cUtils.pas                                               }
{   File version:     4.55                                                     }
{   Description:      Utility functions for simple data types                  }
{                                                                              }
{   Copyright:        Copyright (c) 2000-2015, David J Butler                  }
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
{   Home page:        http://fundementals.sourceforge.net                      }
{   Forum:            http://sourceforge.net/forum/forum.php?forum_id=2117     }
{   E-mail:           fundamentalslib at gmail.com                             }
{                                                                              }
{ Revision history:                                                            }
{                                                                              }
{   2000/02/02  0.01  Initial version.                                         }
{   2000/03/08  1.02  Added array functions.                                   }
{   2000/04/10  1.03  Added Append, Renamed Delete to Remove and added         }
{                     StringArrays.                                            }
{   2000/05/03  1.04  Added Path functions.                                    }
{   2000/05/08  1.05  Revision.                                                }
{   2000/06/01  1.06  Added Range and Dup constructors for dynamic arrays.     }
{   2000/06/03  1.07  Added ArrayInsert functions.                             }
{   2000/06/06  1.08  Added bit functions from cMaths.                         }
{   2000/06/08  1.09  Removed data structure classes.                          }
{   2000/06/10  1.10  Added linked lists for Integer, Int64, Extended and      }
{                     String.                                                  }
{   2000/06/14  1.11  cUtils now generated from a template using a source      }
{                     pre-processor.                                           }
{   2000/07/04  1.12  Revision for first Fundamentals release.                 }
{   2000/07/24  1.13  Added TrimArray functions.                               }
{   2000/07/26  1.14  Added Difference functions.                              }
{   2000/09/02  1.15  Added RemoveDuplicates functions.                        }
{                     Added Count functions.                                   }
{   2000/09/27  1.16  Fixed bug in ArrayInsert.                                }
{   2000/11/29  1.17  Moved SetFPUPrecision to cSysUtils.                      }
{   2001/05/03  1.18  Improved bit functions. Added Pascal versions of         }
{                     assembly routines.                                       }
{   2001/05/13  1.19  Added CharCount.                                         }
{   2001/05/15  1.20  Added PosNext (ClassType, ObjectArray).                  }
{   2001/05/18  1.21  Added hashing functions from cMaths.                     }
{   2001/07/07  1.22  Added TBinaryTreeNode.                                   }
{   2001/11/11  2.23  Revision.                                                }
{   2002/01/03  2.24  Added EncodeBase64, DecodeBase64 from cMaths and         }
{                     optimized. Added LongWordToHex, HexToLongWord.           }
{   2002/03/30  2.25  Fixed bug in DecodeBase64.                               }
{   2002/04/02  2.26  Removed dependencies on all other units to remove        }
{                     initialization code associated with SysUtils. This       }
{                     allows usage of cUtils in projects and still have        }
{                     very small binaries.                                     }
{                     Fixed bug in LongWordToHex.                              }
{   2002/05/31  3.27  Refactored for Fundamentals 3.                           }
{                     Moved linked lists to cLinkedLists.                      }
{   2002/08/09  3.28  Added HashInteger.                                       }
{   2002/10/06  3.29  Renamed Cond to iif.                                     }
{   2002/12/12  3.30  Small revisions.                                         }
{   2003/03/14  3.31  Removed ApproxZero. Added FloatZero, FloatsEqual and     }
{                     FloatsCompare. Added documentation and test cases for    }
{                     comparison functions.                                    }
{                     Added support for Currency type.                         }
{   2003/07/27  3.32  Added fast ZeroMem and FillMem routines.                 }
{   2003/09/11  3.33  Added InterfaceArray functions.                          }
{   2004/01/18  3.34  Added WideStringArray functions.                         }
{   2004/07/24  3.35  Optimizations of Sort functions.                         }
{   2004/08/01  3.36  Improved validation in base conversion routines.         }
{   2004/08/22  3.37  Compilable with Delphi 8.                                }
{   2005/06/10  4.38  Compilable with FreePascal 2 Win32 i386.                 }
{   2005/08/19  4.39  Compilable with FreePascal 2 Linux i386.                 }
{   2005/09/21  4.40  Revised for Fundamentals 4.                              }
{   2006/03/04  4.41  Compilable with Delphi 2006 Win32/.NET.                  }
{   2007/06/08  4.42  Compilable with FreePascal 2.04 Win32 i386               }
{   2007/08/08  4.43  Changes to memory functions for Delphi 2006/2007.        }
{   2008/06/06  4.44  Fixed bug in case insensitive hashing functions.         }
{   2009/10/09  4.45  Compilable with Delphi 2009 Win32/.NET.                  }
{   2010/06/27  4.46  Compilable with FreePascal 2.4.0 OSX x86-64.             }
{   2012/04/03  4.47  Support for Delphi XE string and integer types.          }
{   2012/04/04  4.48  Moved dynamic arrays functions to cDynArrays.            }
{   2012/04/11  4.49  StringToFloat/FloatToStr functions.                      }
{   2012/08/26  4.50  UnicodeString versions of functions.                     }
{   2013/01/29  4.51  Compilable with Delphi XE3 x86-64.                       }
{   2013/03/22  4.52  Minor fixes.                                             }
{   2013/05/12  4.53  Added string type definitions.                           }
{   2013/11/15  4.54  Revision.                                                }
{   2015/03/13  4.55  RawByteString functions.                                 }
{                                                                              }
{ Supported compilers:                                                         }
{                                                                              }
{   Delphi 5 Win32                                                             }
{   Delphi 6 Win32                                                             }
{   Delphi 7 Win32                      4.50  2012/08/30                       }
{   Delphi 8 .NET                                                              }
{   Delphi 2005 Win32                                                          }
{   Delphi 2006 Win32                                                          }
{   Delphi 2007 Win32                   4.50  2012/08/26                       }
{   Delphi 2009 Win32                   4.46  2011/09/27                       }
{   Delphi 2009 .NET                    4.45  2009/10/09                       }
{   Delphi XE                           4.52  2013/03/22                       }
{   Delphi XE2 Win32                    4.54  2014/01/31                       }
{   Delphi XE2 Win64                    4.54  2014/01/31                       }
{   Delphi XE3 Win64                    4.51  2013/01/29                       }
{   Delphi XE6 Win32                    4.54  2014/12/28                       }
{   Delphi XE7 Win64                    4.55  2015/03/13                       }
{   FreePascal 2.0.4 Linux i386                                                }
{   FreePascal 2.4.0 OSX x86-64         4.46  2010/06/27                       }
{   FreePascal 2.6.0 Win32              4.50  2012/08/30                       }
{                                                                              }
{******************************************************************************}

{$INCLUDE ..\cFundamentals.inc}

{$IFDEF FREEPASCAL}
  {$WARNINGS OFF}
  {$HINTS OFF}
{$ENDIF}

{$IFDEF DEBUG}
{$IFDEF SELFTEST}
  {$DEFINE UTILS_SELFTEST}
{$ENDIF}
{$ENDIF}

unit cUtils;

interface



{                                                                              }
{ Fundamentals Library constants                                               }
{                                                                              }
const
  LibraryVersion      = '4.00';
  LibraryMajorVersion = 4;
  LibraryMinorVersion = 0;
  LibraryName         = 'Fundamentals ' + LibraryVersion;
  LibraryCopyright    = 'Copyright (c) 1998-2015 David J Butler';



{                                                                              }
{ Integer types                                                                }
{                                                                              }
{   Unsigned integers                     Signed integers                      }
{   --------------------------------      --------------------------------     }
{   Byte        unsigned 8 bits           ShortInt   signed 8 bits             }
{   Word        unsigned 16 bits          SmallInt   signed 16 bits            }
{   LongWord    unsigned 32 bits          LongInt    signed 32 bits            }
{   -                                     Int64      signed 64 bits            }
{   Cardinal    unsigned 32 bits          Integer    signed 32 bits            }
{   NativeUInt  unsigned system word      NativeInt  signed system word        }
{                                                                              }
type
  Int8      = ShortInt;
  Int16     = SmallInt;
  Int32     = LongInt;

  UInt8     = Byte;
  UInt16    = Word;
  UInt32    = LongWord;
  {$IFNDEF SupportUInt64}
  UInt64    = type Int64;
  {$ENDIF}

  Word8     = UInt8;
  Word16    = UInt16;
  Word32    = UInt32;
  Word64    = UInt64;

  LargeInt  = Int64;

  {$IFNDEF SupportNativeInt}
  {$IFDEF CPU_X86_64}
  NativeInt   = type Int64;
  {$ELSE}
  NativeInt   = type Integer;
  {$ENDIF}
  PNativeInt  = ^NativeInt;
  {$ENDIF}

  {$IFNDEF SupportNativeUInt}
  {$IFDEF CPU_X86_64}
  NativeUInt  = type Word64;
  {$ELSE}
  NativeUInt  = type Cardinal;
  {$ENDIF}
  PNativeUInt = ^NativeUInt;
  {$ENDIF}

  {$IFDEF DELPHI5_DOWN}
  PByte       = ^Byte;
  PWord       = ^Word;
  PLongWord   = ^LongWord;
  PShortInt   = ^ShortInt;
  PSmallInt   = ^SmallInt;
  PLongInt    = ^LongInt;
  PInteger    = ^Integer;
  PInt64      = ^Int64;
  {$ENDIF}

  PInt8     = ^Int8;
  PInt16    = ^Int16;
  PInt32    = ^Int32;

  PLargeInt = ^LargeInt;

  PWord8    = ^Word8;
  PWord16   = ^Word16;
  PWord32   = ^Word32;

  PUInt8    = ^UInt8;
  PUInt16   = ^UInt16;
  PUInt32   = ^UInt32;
  PUInt64   = ^UInt64;

  {$IFNDEF ManagedCode}
  SmallIntRec = packed record
    case Integer of
      0 : (Lo, Hi : Byte);
      1 : (Bytes  : array[0..1] of Byte);
  end;

  LongIntRec = packed record
    case Integer of
      0 : (Lo, Hi : Word);
      1 : (Words  : array[0..1] of Word);
      2 : (Bytes  : array[0..3] of Byte);
  end;
  PLongIntRec = ^LongIntRec;
  {$ENDIF}

const
  MinByte       = Low(Byte);
  MaxByte       = High(Byte);
  MinWord       = Low(Word);
  MaxWord       = High(Word);
  MinShortInt   = Low(ShortInt);
  MaxShortInt   = High(ShortInt);
  MinSmallInt   = Low(SmallInt);
  MaxSmallInt   = High(SmallInt);
  MinLongWord   = LongWord(Low(LongWord));
  MaxLongWord   = LongWord(High(LongWord));
  MinLongInt    = LongInt(Low(LongInt));
  MaxLongInt    = LongInt(High(LongInt));
  MinInt64      = Int64(Low(Int64));
  MaxInt64      = Int64(High(Int64));
  MinInteger    = Integer(Low(Integer));
  MaxInteger    = Integer(High(Integer));
  MinCardinal   = Cardinal(Low(Cardinal));
  MaxCardinal   = Cardinal(High(Cardinal));
  MinNativeUInt = NativeUInt(Low(NativeUInt));
  MaxNativeUInt = NativeUInt(High(NativeUInt));
  MinNativeInt  = NativeInt(Low(NativeInt));
  MaxNativeInt  = NativeInt(High(NativeInt));

const
  BitsPerByte       = 8;
  BitsPerWord       = 16;
  BitsPerLongWord   = 32;
  NativeWordSize    = SizeOf(NativeInt);
  BitsPerNativeWord = NativeWordSize * 8;

{ Min returns smallest of A and B                                              }
{ Max returns greatest of A and B                                              }
function  MinI(const A, B: Integer): Integer;   {$IFDEF UseInline}inline;{$ENDIF}
function  MaxI(const A, B: Integer): Integer;   {$IFDEF UseInline}inline;{$ENDIF}
function  MinC(const A, B: Cardinal): Cardinal; {$IFDEF UseInline}inline;{$ENDIF}
function  MaxC(const A, B: Cardinal): Cardinal; {$IFDEF UseInline}inline;{$ENDIF}

{ Clip returns Value if in Low..High range, otherwise Low or High              }
function  Clip(const Value: LongInt; const Low, High: LongInt): LongInt; overload; {$IFDEF UseInline}inline;{$ENDIF}
function  Clip(const Value: Int64; const Low, High: Int64): Int64; overload;       {$IFDEF UseInline}inline;{$ENDIF}
function  ClipByte(const Value: LongInt): LongInt; overload;                       {$IFDEF UseInline}inline;{$ENDIF}
function  ClipByte(const Value: Int64): Int64; overload;                           {$IFDEF UseInline}inline;{$ENDIF}
function  ClipWord(const Value: LongInt): LongInt; overload;                       {$IFDEF UseInline}inline;{$ENDIF}
function  ClipWord(const Value: Int64): Int64; overload;                           {$IFDEF UseInline}inline;{$ENDIF}
function  ClipLongWord(const Value: Int64): LongWord;                              {$IFDEF UseInline}inline;{$ENDIF}
function  SumClipI(const A, I: Integer): Integer;
function  SumClipC(const A: Cardinal; const I: Integer): Cardinal;



{                                                                              }
{ Boolean types                                                                }
{                                                                              }
{   Boolean    -        -                                                      }
{   ByteBool   Bool8    8 bits                                                 }
{   WordBool   Bool16   16 bits                                                }
{   LongBool   Bool32   32 bits                                                }
{                                                                              }
type
  Bool8     = ByteBool;
  Bool16    = WordBool;
  Bool32    = LongBool;

  {$IFDEF DELPHI5_DOWN}
  PBoolean  = ^Boolean;
  PByteBool = ^ByteBool;
  PWordBool = ^WordBool;
  {$ENDIF}
  {$IFNDEF FREEPASCAL}
  PLongBool = ^LongBool;
  {$ENDIF}

  PBool8    = ^Bool8;
  PBool16   = ^Bool16;
  PBool32   = ^Bool32;



{                                                                              }
{ String types                                                                 }
{                                                                              }

{                                                                              }
{ AnsiString                                                                   }
{   AnsiChar is a byte character.                                              }
{   AnsiString is a reference counted, code page aware, byte string.           }
{                                                                              }
{$IFNDEF SupportAnsiChar}
type
  AnsiChar = type Byte;
  PAnsiChar = ^AnsiChar;
{$ENDIF}

{$IFNDEF SupportAnsiString}
type
  AnsiString = array of AnsiChar;
{$ENDIF}

{$IFNDEF SupportAnsiString}
const
  StrEmptyA = AnsiString(nil);
{$ELSE}
const
  StrEmptyA = '';
{$ENDIF}



{                                                                              }
{ WideString                                                                   }
{   WideChar is a 16-bit character.                                            }
{   WideString is not reference counted.                                       }
{                                                                              }
{$IFNDEF SupportWideChar}
type
  WideChar = type Word;
  PWideChar = ^WideChar;
{$ENDIF}

{$IFNDEF SupportWideString}
type
  WideString = array of WideChar;
{$ENDIF}

type
  TWideCharMatchFunction = function (const Ch: WideChar): Boolean;

{$IFNDEF SupportWideString}
const
  StrEmptyW = WideString(nil);
{$ELSE}
const
  StrEmptyW = '';
{$ENDIF}



{                                                                              }
{ UnicodeString                                                                }
{   UnicodeString in Delphi 2009 is reference counted, code page aware,        }
{   variable character length unicode string. Defaults to UTF-16 encoding.     }
{   WideString is not reference counted.                                       }
{                                                                              }
type
  UnicodeChar = WideChar;
  PUnicodeChar = ^UnicodeChar;
  {$IFNDEF SupportUnicodeString}
  UnicodeString = WideString;
  PUnicodeString = ^UnicodeString;
  {$ENDIF}



{                                                                              }
{ RawByteString                                                                }
{   RawByteString is an alias for AnsiString where all bytes are raw bytes     }
{   that do not undergo any character set translation.                         }
{   Under Delphi 2009 RawByteString is defined as "type AnsiString($FFFF)".    }
{                                                                              }
type
  RawByteChar = AnsiChar;
  PRawByteChar = ^RawByteChar;
  {$IFNDEF SupportRawByteString}
  RawByteString = AnsiString;
  {$ENDIF}
  RawByteCharSet = set of RawByteChar;

const
  StrEmptyB = '';



{                                                                              }
{ UTF8String                                                                   }
{   UTF8String is a variable character length encoding for Unicode strings.    }
{   For Ascii values, a UTF8String is the same as a AsciiString.               }
{   Under Delphi 2009 UTF8String is defined as "type AnsiString($FDE9)"        }
{                                                                              }
type
  {$IFNDEF SupportUTF8String}
  UTF8Char = AnsiChar;
  PUTF8Char = ^UTF8Char;
  UTF8String = AnsiString;
  {$ENDIF}
  UTF8StringArray = array of UTF8String;



{                                                                              }
{ AsciiString                                                                  }
{   AsciiString is an alias for AnsiString where all bytes are from Ascii.     }
{                                                                              }
type
  AsciiChar = AnsiChar;
  PAsciiChar = ^AsciiChar;
  AsciiString = AnsiString;
  AsciiCharSet = set of AsciiChar;
  AsciiStringArray = array of AsciiString;



{                                                                              }
{ UCS4String                                                                   }
{   UCS4Char is a 32-bit character from the Unicode character set.             }
{   UCS4String is a reference counted string of UCS4Char characters.           }
{                                                                              }
type
  {$IFNDEF SupportUCS4String}
  UCS4Char = type LongWord;
  PUCS4Char = ^UCS4Char;
  UCS4String = array of UCS4Char;
  {$ENDIF}
  UCS4StringArray = array of UCS4String;



{                                                                              }
{ Comparison                                                                   }
{                                                                              }
type
  TCompareResult = (
      crLess,
      crEqual,
      crGreater,
      crUndefined);
  TCompareResultSet = set of TCompareResult;

function  ReverseCompareResult(const C: TCompareResult): TCompareResult;



{                                                                              }
{ Real types                                                                   }
{                                                                              }
{   Floating point                                                             }
{     Single    32 bits  7-8 significant digits                                }
{     Double    64 bits  15-16 significant digits                              }
{     Extended  80 bits  19-20 significant digits (mapped to Double in .NET)   }
{                                                                              }
{   Fixed point                                                                }
{     Currency  64 bits  19-20 significant digits, 4 after the decimal point.  }
{                                                                              }
const
  MinSingle   : Single   = 1.5E-45;
  MaxSingle   : Single   = 3.4E+38;
  MinDouble   : Double   = 5.0E-324;
  MaxDouble   : Double   = 1.7E+308;
  {$IFDEF ExtendedIsDouble}
  MinExtended : Extended = 5.0E-324;
  MaxExtended : Extended = 1.7E+308;
  {$ELSE}
  MinExtended : Extended = 3.4E-4932;
  MaxExtended : Extended = 1.1E+4932;
  {$ENDIF}
  {$IFNDEF CLR}
  MinCurrency : Currency = -922337203685477.5807;
  MaxCurrency : Currency = 922337203685477.5807;
  {$ENDIF}

type
  {$IFDEF DELPHI5_DOWN}
  PSingle   = ^Single;
  PDouble   = ^Double;
  PExtended = ^Extended;
  PCurrency = ^Currency;
  {$ENDIF}

  {$IFNDEF ManagedCode}
  {$IFNDEF ExtendedIsDouble}
  ExtendedRec = packed record
    case Boolean of
      True: (
        Mantissa : packed array[0..1] of LongWord; { MSB of [1] is the normalized 1 bit }
        Exponent : Word;                           { MSB is the sign bit                }
      );
      False: (Value: Extended);
  end;
  {$ENDIF}
  {$ENDIF}

  {$IFDEF ExtendedIsDouble}
  Float  = Double;
  {$ELSE}
  Float  = Extended;
  {$ENDIF}
  PFloat = ^Float;

{$IFNDEF ManagedCode}
{$IFNDEF ExtendedIsDouble}
const
  ExtendedNan      : ExtendedRec = (Mantissa:($FFFFFFFF, $FFFFFFFF); Exponent:$7FFF);
  ExtendedInfinity : ExtendedRec = (Mantissa:($00000000, $80000000); Exponent:$7FFF);
{$ENDIF}
{$ENDIF}

{ Min returns smallest of A and B                                              }
{ Max returns greatest of A and B                                              }
{ Clip returns Value if in Low..High range, otherwise Low or High              }
function  DoubleMin(const A, B: Double): Double; {$IFDEF UseInline}inline;{$ENDIF}
function  DoubleMax(const A, B: Double): Double; {$IFDEF UseInline}inline;{$ENDIF}

function  ExtendedMin(const A, B: Extended): Extended; {$IFDEF UseInline}inline;{$ENDIF}
function  ExtendedMax(const A, B: Extended): Extended; {$IFDEF UseInline}inline;{$ENDIF}

function  FloatMin(const A, B: Float): Float; {$IFDEF UseInline}inline;{$ENDIF}
function  FloatMax(const A, B: Float): Float; {$IFDEF UseInline}inline;{$ENDIF}
function  FloatClip(const Value: Float; const Low, High: Float): Float;

{ InXXXRange returns True if A in range of type XXX                            }
function  InSingleRange(const A: Float): Boolean; {$IFDEF UseInline}inline;{$ENDIF}
function  InDoubleRange(const A: Float): Boolean; {$IFDEF UseInline}inline;{$ENDIF}
{$IFNDEF CLR}
function  InCurrencyRange(const A: Float): Boolean; overload;
function  InCurrencyRange(const A: Int64): Boolean; overload;
{$ENDIF}

{ ExtendedExponent returns the exponent component of an Extended value         }
{$IFNDEF ExtendedIsDouble}
function  ExtendedExponentBase2(const A: Extended; var Exponent: Integer): Boolean;
function  ExtendedExponentBase10(const A: Extended; var Exponent: Integer): Boolean;
{$ENDIF}

{ ExtendedIsInfinity is True if A is a positive or negative infinity.          }
{ ExtendedIsNaN is True if A is Not-a-Number.                                  }
{$IFNDEF ExtendedIsDouble}
function  ExtendedIsInfinity(const A: Extended): Boolean;
function  ExtendedIsNaN(const A: Extended): Boolean;
{$ENDIF}



{                                                                              }
{ Approximate comparison of floating point values                              }
{                                                                              }
{   FloatZero, FloatOne, FloatsEqual and FloatsCompare are functions for       }
{   comparing floating point numbers based on a fixed CompareDelta difference  }
{   between the values. This means that values are considered equal if the     }
{   unsigned difference between the values are less than CompareDelta.         }
{                                                                              }
const
  // Minimum CompareDelta values for the different floating point types:
  // The values were chosen to be slightly higher than the minimum value that
  // the floating-point type can store.
  SingleCompareDelta   = 1.0E-34;
  DoubleCompareDelta   = 1.0E-280;
  {$IFDEF ExtendedIsDouble}
  ExtendedCompareDelta = DoubleCompareDelta;
  {$ELSE}
  ExtendedCompareDelta = 1.0E-4400;
  {$ENDIF}

  // Default CompareDelta is set to SingleCompareDelta. This allows any type
  // of floating-point value to be compared with any other.
  DefaultCompareDelta = SingleCompareDelta;

function  FloatZero(const A: Float;
          const CompareDelta: Float = DefaultCompareDelta): Boolean;
function  FloatOne(const A: Float;
          const CompareDelta: Float = DefaultCompareDelta): Boolean;

function  FloatsEqual(const A, B: Float;
          const CompareDelta: Float = DefaultCompareDelta): Boolean;
function  FloatsCompare(const A, B: Float;
          const CompareDelta: Float = DefaultCompareDelta): TCompareResult;



{                                                                              }
{ Scaled approximate comparison of floating point values                       }
{                                                                              }
{   ApproxEqual and ApproxCompare are functions for comparing floating point   }
{   numbers based on a scaled order of magnitude difference between the        }
{   values. CompareEpsilon is the ratio applied to the largest of the two      }
{   exponents to give the maximum difference (CompareDelta) for comparison.    }
{                                                                              }
{   For example:                                                               }
{                                                                              }
{   When the CompareEpsilon is 1.0E-9, the result of                           }
{                                                                              }
{   ApproxEqual(1.0E+20, 1.000000001E+20) = False, but the result of           }
{   ApproxEqual(1.0E+20, 1.0000000001E+20) = True, ie the first 9 digits of    }
{   the mantissas of the values must be the same.                              }
{                                                                              }
{   Note that for A <> 0.0, the value of ApproxEqual(A, 0.0) will always be    }
{   False. Rather use the unscaled FloatZero, FloatsEqual and FloatsCompare    }
{   functions when specifically testing for zero.                              }
{                                                                              }
const
  // Smallest (most sensitive) CompareEpsilon values allowed for the different
  // floating point types:
  SingleCompareEpsilon   = 1.0E-5;
  DoubleCompareEpsilon   = 1.0E-13;
  ExtendedCompareEpsilon = 1.0E-17;

  // Default CompareEpsilon is set for half the significant digits of the
  // Extended type.
  DefaultCompareEpsilon  = 1.0E-10;

{$IFNDEF ExtendedIsDouble}
function  ExtendedApproxEqual(const A, B: Extended;
          const CompareEpsilon: Double = DefaultCompareEpsilon): Boolean;
function  ExtendedApproxCompare(const A, B: Extended;
          const CompareEpsilon: Double = DefaultCompareEpsilon): TCompareResult;
{$ENDIF}

function  DoubleApproxEqual(const A, B: Double;
          const CompareEpsilon: Double = DefaultCompareEpsilon): Boolean;
function  DoubleApproxCompare(const A, B: Double;
          const CompareEpsilon: Double = DefaultCompareEpsilon): TCompareResult;

function  FloatApproxEqual(const A, B: Float;
          const CompareEpsilon: Float = DefaultCompareEpsilon): Boolean;
function  FloatApproxCompare(const A, B: Float;
          const CompareEpsilon: Float = DefaultCompareEpsilon): TCompareResult;




{                                                                              }
{ Bit functions                                                                }
{                                                                              }
function  ClearBit(const Value, BitIndex: LongWord): LongWord;
function  SetBit(const Value, BitIndex: LongWord): LongWord;
function  IsBitSet(const Value, BitIndex: LongWord): Boolean;
function  ToggleBit(const Value, BitIndex: LongWord): LongWord;
function  IsHighBitSet(const Value: LongWord): Boolean;

function  SetBitScanForward(const Value: LongWord): Integer; overload;
function  SetBitScanForward(const Value, BitIndex: LongWord): Integer; overload;
function  SetBitScanReverse(const Value: LongWord): Integer; overload;
function  SetBitScanReverse(const Value, BitIndex: LongWord): Integer; overload;
function  ClearBitScanForward(const Value: LongWord): Integer; overload;
function  ClearBitScanForward(const Value, BitIndex: LongWord): Integer; overload;
function  ClearBitScanReverse(const Value: LongWord): Integer; overload;
function  ClearBitScanReverse(const Value, BitIndex: LongWord): Integer; overload;

function  ReverseBits(const Value: LongWord): LongWord; overload;
function  ReverseBits(const Value: LongWord; const BitCount: Integer): LongWord; overload;
function  SwapEndian(const Value: LongWord): LongWord;
{$IFDEF ManagedCode}
procedure SwapEndianBuf(var Buf: array of LongWord);
{$ELSE}
procedure SwapEndianBuf(var Buf; const Count: Integer);
{$ENDIF}
function  TwosComplement(const Value: LongWord): LongWord;

function  RotateLeftBits16(const Value: Word; const Bits: Byte): Word;
function  RotateLeftBits32(const Value: LongWord; const Bits: Byte): LongWord;
function  RotateRightBits16(const Value: Word; const Bits: Byte): Word;
function  RotateRightBits32(const Value: LongWord; const Bits: Byte): LongWord;

function  BitCount(const Value: LongWord): LongWord;
function  IsPowerOfTwo(const Value: LongWord): Boolean;

function  LowBitMask(const HighBitIndex: LongWord): LongWord;
function  HighBitMask(const LowBitIndex: LongWord): LongWord;
function  RangeBitMask(const LowBitIndex, HighBitIndex: LongWord): LongWord;

function  SetBitRange(const Value: LongWord;
          const LowBitIndex, HighBitIndex: LongWord): LongWord;
function  ClearBitRange(const Value: LongWord;
          const LowBitIndex, HighBitIndex: LongWord): LongWord;
function  ToggleBitRange(const Value: LongWord;
          const LowBitIndex, HighBitIndex: LongWord): LongWord;
function  IsBitRangeSet(const Value: LongWord;
          const LowBitIndex, HighBitIndex: LongWord): Boolean;
function  IsBitRangeClear(const Value: LongWord;
          const LowBitIndex, HighBitIndex: LongWord): Boolean;

const
  BitMaskTable: array[0..31] of LongWord =
    ($00000001, $00000002, $00000004, $00000008,
     $00000010, $00000020, $00000040, $00000080,
     $00000100, $00000200, $00000400, $00000800,
     $00001000, $00002000, $00004000, $00008000,
     $00010000, $00020000, $00040000, $00080000,
     $00100000, $00200000, $00400000, $00800000,
     $01000000, $02000000, $04000000, $08000000,
     $10000000, $20000000, $40000000, $80000000);



{                                                                              }
{ Sets                                                                         }
{   Operations on byte and character sets.                                     }
{                                                                              }
type
  CharSet = set of AnsiChar;
  AnsiCharSet = CharSet;
  ByteSet = set of Byte;
  PCharSet = ^CharSet;
  PByteSet = ^ByteSet;

const
  CompleteCharSet = [AnsiChar(#0)..AnsiChar(#255)];
  CompleteByteSet = [0..255];

function  AsCharSet(const C: array of AnsiChar): CharSet;
function  AsByteSet(const C: array of Byte): ByteSet;
procedure ComplementChar(var C: CharSet; const Ch: AnsiChar);
procedure ClearCharSet(var C: CharSet);
procedure FillCharSet(var C: CharSet);
procedure ComplementCharSet(var C: CharSet);
procedure AssignCharSet(var DestSet: CharSet; const SourceSet: CharSet); overload;
procedure Union(var DestSet: CharSet; const SourceSet: CharSet); overload;
procedure Difference(var DestSet: CharSet; const SourceSet: CharSet); overload;
procedure Intersection(var DestSet: CharSet; const SourceSet: CharSet); overload;
procedure XORCharSet(var DestSet: CharSet; const SourceSet: CharSet);
function  IsSubSet(const A, B: CharSet): Boolean;
function  IsEqual(const A, B: CharSet): Boolean; overload;
function  IsEmpty(const C: CharSet): Boolean;
function  IsComplete(const C: CharSet): Boolean;
function  CharCount(const C: CharSet): Integer; overload;
procedure ConvertCaseInsensitive(var C: CharSet);
function  CaseInsensitiveCharSet(const C: CharSet): CharSet;



{                                                                              }
{ Range functions                                                              }
{                                                                              }
{   RangeLength      Length of a range                                         }
{   RangeAdjacent    True if ranges are adjacent                               }
{   RangeOverlap     True if ranges overlap                                    }
{   RangeHasElement  True if element is in range                               }
{                                                                              }
function  IntRangeLength(const Low, High: Integer): Int64;
function  IntRangeAdjacent(const Low1, High1, Low2, High2: Integer): Boolean;
function  IntRangeOverlap(const Low1, High1, Low2, High2: Integer): Boolean;
function  IntRangeHasElement(const Low, High, Element: Integer): Boolean;

function  IntRangeIncludeElement(var Low, High: Integer;
          const Element: Integer): Boolean;
function  IntRangeIncludeElementRange(var Low, High: Integer;
          const LowElement, HighElement: Integer): Boolean;

function  CardRangeLength(const Low, High: Cardinal): Int64;
function  CardRangeAdjacent(const Low1, High1, Low2, High2: Cardinal): Boolean;
function  CardRangeOverlap(const Low1, High1, Low2, High2: Cardinal): Boolean;
function  CardRangeHasElement(const Low, High, Element: Cardinal): Boolean;

function  CardRangeIncludeElement(var Low, High: Cardinal;
          const Element: Cardinal): Boolean;
function  CardRangeIncludeElementRange(var Low, High: Cardinal;
          const LowElement, HighElement: Cardinal): Boolean;



{                                                                              }
{ Swap                                                                         }
{                                                                              }
procedure Swap(var X, Y: Boolean); overload;
procedure Swap(var X, Y: Byte); overload;
procedure Swap(var X, Y: Word); overload;
procedure Swap(var X, Y: LongWord); overload;
procedure Swap(var X, Y: NativeUInt); overload;
procedure Swap(var X, Y: ShortInt); overload;
procedure Swap(var X, Y: SmallInt); overload;
procedure Swap(var X, Y: LongInt); overload;
procedure Swap(var X, Y: Int64); overload;
procedure Swap(var X, Y: NativeInt); overload;
procedure Swap(var X, Y: Single); overload;
procedure Swap(var X, Y: Double); overload;
procedure Swap(var X, Y: Extended); overload;
procedure Swap(var X, Y: Currency); overload;
procedure SwapA(var X, Y: AnsiString); overload;
procedure SwapB(var X, Y: RawByteString);
procedure SwapW(var X, Y: WideString); overload;
procedure SwapU(var X, Y: UnicodeString); overload;
procedure Swap(var X, Y: String); overload;
procedure Swap(var X, Y: TObject); overload;
{$IFDEF ManagedCode}
procedure SwapObjects(var X, Y: TObject);
{$ELSE}
procedure SwapObjects(var X, Y);
{$ENDIF}
{$IFNDEF ManagedCode}
procedure Swap(var X, Y: Pointer); overload;
{$ENDIF}



{                                                                              }
{ Inline if                                                                    }
{                                                                              }
{   iif returns TrueValue if Expr is True, otherwise it returns FalseValue.    }
{                                                                              }
function  iif(const Expr: Boolean; const TrueValue: Integer;
          const FalseValue: Integer = 0): Integer; overload;              {$IFDEF UseInline}inline;{$ENDIF}
function  iif(const Expr: Boolean; const TrueValue: Int64;
          const FalseValue: Int64 = 0): Int64; overload;                  {$IFDEF UseInline}inline;{$ENDIF}
function  iif(const Expr: Boolean; const TrueValue: Extended;
          const FalseValue: Extended = 0.0): Extended; overload;          {$IFDEF UseInline}inline;{$ENDIF}
function  iifA(const Expr: Boolean; const TrueValue: AnsiString;
          const FalseValue: AnsiString = StrEmptyA): AnsiString; overload;{$IFDEF UseInline}inline;{$ENDIF}
function  iifB(const Expr: Boolean; const TrueValue: RawByteString;
          const FalseValue: RawByteString = StrEmptyB): RawByteString; overload; {$IFDEF UseInline}inline;{$ENDIF}
function  iifW(const Expr: Boolean; const TrueValue: WideString;
          const FalseValue: WideString = StrEmptyW): WideString; overload;       {$IFDEF UseInline}inline;{$ENDIF}
function  iifU(const Expr: Boolean; const TrueValue: UnicodeString;
          const FalseValue: UnicodeString = ''): UnicodeString; overload; {$IFDEF UseInline}inline;{$ENDIF}
function  iif(const Expr: Boolean; const TrueValue: String;
          const FalseValue: String = ''): String; overload;               {$IFDEF UseInline}inline;{$ENDIF}
function  iif(const Expr: Boolean; const TrueValue: TObject;
          const FalseValue: TObject = nil): TObject; overload;            {$IFDEF UseInline}inline;{$ENDIF}



{                                                                              }
{ Direct comparison                                                            }
{                                                                              }
{   Compare(I1, I2) returns crLess if I1 < I2, crEqual if I1 = I2 or           }
{   crGreater if I1 > I2.                                                      }
{                                                                              }
function  Compare(const I1, I2: Boolean): TCompareResult; overload;
function  Compare(const I1, I2: Integer): TCompareResult; overload;
function  Compare(const I1, I2: Int64): TCompareResult; overload;
function  Compare(const I1, I2: Extended): TCompareResult; overload;
function  CompareA(const I1, I2: AnsiString): TCompareResult;
function  CompareB(const I1, I2: RawByteString): TCompareResult;
function  CompareW(const I1, I2: WideString): TCompareResult;
function  CompareU(const I1, I2: UnicodeString): TCompareResult;
function  CompareChA(const I1, I2: AnsiChar): TCompareResult;
function  CompareChW(const I1, I2: WideChar): TCompareResult;

function  Sgn(const A: LongInt): Integer; overload;
function  Sgn(const A: Int64): Integer; overload;
function  Sgn(const A: Extended): Integer; overload;



{                                                                              }
{ Convert result                                                               }
{                                                                              }
type
  TConvertResult = (
      convertOK,
      convertFormatError,
      convertOverflow
      );



{                                                                              }
{ Integer-String conversions                                                   }
{                                                                              }
const
  StrHexDigitsUpper: String[16] = '0123456789ABCDEF';
  StrHexDigitsLower: String[16] = '0123456789abcdef';

function  AnsiCharToInt(const A: AnsiChar): Integer;                            {$IFDEF UseInline}inline;{$ENDIF}
function  WideCharToInt(const A: WideChar): Integer;                            {$IFDEF UseInline}inline;{$ENDIF}
function  CharToInt(const A: Char): Integer;                                    {$IFDEF UseInline}inline;{$ENDIF}

function  IntToAnsiChar(const A: Integer): AnsiChar;                            {$IFDEF UseInline}inline;{$ENDIF}
function  IntToWideChar(const A: Integer): WideChar;                            {$IFDEF UseInline}inline;{$ENDIF}
function  IntToChar(const A: Integer): Char;                                    {$IFDEF UseInline}inline;{$ENDIF}

function  IsHexAnsiChar(const Ch: AnsiChar): Boolean;
function  IsHexWideChar(const Ch: WideChar): Boolean;
function  IsHexChar(const Ch: Char): Boolean;                                   {$IFDEF UseInline}inline;{$ENDIF}

function  HexAnsiCharToInt(const A: AnsiChar): Integer;
function  HexWideCharToInt(const A: WideChar): Integer;
function  HexCharToInt(const A: Char): Integer;                                 {$IFDEF UseInline}inline;{$ENDIF}

function  IntToUpperHexAnsiChar(const A: Integer): AnsiChar;
function  IntToUpperHexWideChar(const A: Integer): WideChar;
function  IntToUpperHexChar(const A: Integer): Char;                            {$IFDEF UseInline}inline;{$ENDIF}

function  IntToLowerHexAnsiChar(const A: Integer): AnsiChar;
function  IntToLowerHexWideChar(const A: Integer): WideChar;
function  IntToLowerHexChar(const A: Integer): Char;                            {$IFDEF UseInline}inline;{$ENDIF}

function  IntToStringA(const A: Int64): AnsiString;
function  IntToStringB(const A: Int64): RawByteString;
function  IntToStringW(const A: Int64): WideString;
function  IntToStringU(const A: Int64): UnicodeString;
function  IntToString(const A: Int64): String;

function  UIntToStringA(const A: NativeUInt): AnsiString;
function  UIntToStringB(const A: NativeUInt): RawByteString;
function  UIntToStringW(const A: NativeUInt): WideString;
function  UIntToStringU(const A: NativeUInt): UnicodeString;
function  UIntToString(const A: NativeUInt): String;

function  LongWordToStrA(const A: LongWord; const Digits: Integer = 0): AnsiString;
function  LongWordToStrB(const A: LongWord; const Digits: Integer = 0): RawByteString;
function  LongWordToStrW(const A: LongWord; const Digits: Integer = 0): WideString;
function  LongWordToStrU(const A: LongWord; const Digits: Integer = 0): UnicodeString;
function  LongWordToStr(const A: LongWord; const Digits: Integer = 0): String;

function  LongWordToHexA(const A: LongWord; const Digits: Integer = 0; const UpperCase: Boolean = True): AnsiString;
function  LongWordToHexB(const A: LongWord; const Digits: Integer = 0; const UpperCase: Boolean = True): RawByteString;
function  LongWordToHexW(const A: LongWord; const Digits: Integer = 0; const UpperCase: Boolean = True): WideString;
function  LongWordToHexU(const A: LongWord; const Digits: Integer = 0; const UpperCase: Boolean = True): UnicodeString;
function  LongWordToHex(const A: LongWord; const Digits: Integer = 0; const UpperCase: Boolean = True): String;

function  LongWordToOctA(const A: LongWord; const Digits: Integer = 0): AnsiString;
function  LongWordToOctB(const A: LongWord; const Digits: Integer = 0): RawByteString;
function  LongWordToOctW(const A: LongWord; const Digits: Integer = 0): WideString;
function  LongWordToOctU(const A: LongWord; const Digits: Integer = 0): UnicodeString;
function  LongWordToOct(const A: LongWord; const Digits: Integer = 0): String;

function  LongWordToBinA(const A: LongWord; const Digits: Integer = 0): AnsiString;
function  LongWordToBinB(const A: LongWord; const Digits: Integer = 0): RawByteString;
function  LongWordToBinW(const A: LongWord; const Digits: Integer = 0): WideString;
function  LongWordToBinU(const A: LongWord; const Digits: Integer = 0): UnicodeString;
function  LongWordToBin(const A: LongWord; const Digits: Integer = 0): String;

function  TryStringToInt64PA(const BufP: Pointer; const BufLen: Integer; out Value: Int64; out StrLen: Integer): TConvertResult;
function  TryStringToInt64PW(const BufP: Pointer; const BufLen: Integer; out Value: Int64; out StrLen: Integer): TConvertResult;
function  TryStringToInt64P(const BufP: Pointer; const BufLen: Integer; out Value: Int64; out StrLen: Integer): TConvertResult;

function  TryStringToInt64A(const S: AnsiString; out A: Int64): Boolean;
function  TryStringToInt64B(const S: RawByteString; out A: Int64): Boolean;
function  TryStringToInt64W(const S: WideString; out A: Int64): Boolean;
function  TryStringToInt64U(const S: UnicodeString; out A: Int64): Boolean;
function  TryStringToInt64(const S: String; out A: Int64): Boolean;

function  StringToInt64DefA(const S: AnsiString; const Default: Int64): Int64;
function  StringToInt64DefB(const S: RawByteString; const Default: Int64): Int64;
function  StringToInt64DefW(const S: WideString; const Default: Int64): Int64;
function  StringToInt64DefU(const S: UnicodeString; const Default: Int64): Int64;
function  StringToInt64Def(const S: String; const Default: Int64): Int64;

function  StringToInt64A(const S: AnsiString): Int64;
function  StringToInt64B(const S: RawByteString): Int64;
function  StringToInt64W(const S: WideString): Int64;
function  StringToInt64U(const S: UnicodeString): Int64;
function  StringToInt64(const S: String): Int64;

function  TryStringToIntA(const S: AnsiString; out A: Integer): Boolean;
function  TryStringToIntB(const S: RawByteString; out A: Integer): Boolean;
function  TryStringToIntW(const S: WideString; out A: Integer): Boolean;
function  TryStringToIntU(const S: UnicodeString; out A: Integer): Boolean;
function  TryStringToInt(const S: String; out A: Integer): Boolean;

function  StringToIntDefA(const S: AnsiString; const Default: Integer): Integer;
function  StringToIntDefB(const S: RawByteString; const Default: Integer): Integer;
function  StringToIntDefW(const S: WideString; const Default: Integer): Integer;
function  StringToIntDefU(const S: UnicodeString; const Default: Integer): Integer;
function  StringToIntDef(const S: String; const Default: Integer): Integer;

function  StringToIntA(const S: AnsiString): Integer;
function  StringToIntB(const S: RawByteString): Integer;
function  StringToIntW(const S: WideString): Integer;
function  StringToIntU(const S: UnicodeString): Integer;
function  StringToInt(const S: String): Integer;

function  TryStringToLongWordA(const S: AnsiString; out A: LongWord): Boolean;
function  TryStringToLongWordB(const S: RawByteString; out A: LongWord): Boolean;
function  TryStringToLongWordW(const S: WideString; out A: LongWord): Boolean;
function  TryStringToLongWordU(const S: UnicodeString; out A: LongWord): Boolean;
function  TryStringToLongWord(const S: String; out A: LongWord): Boolean;

function  StringToLongWordA(const S: AnsiString): LongWord;
function  StringToLongWordB(const S: RawByteString): LongWord;
function  StringToLongWordW(const S: WideString): LongWord;
function  StringToLongWordU(const S: UnicodeString): LongWord;
function  StringToLongWord(const S: String): LongWord;

function  HexToUIntA(const S: AnsiString): NativeUInt;
function  HexToUIntB(const S: RawByteString): NativeUInt;
function  HexToUIntW(const S: WideString): NativeUInt;
function  HexToUIntU(const S: UnicodeString): NativeUInt;
function  HexToUInt(const S: String): NativeUInt;

function  TryHexToLongWordA(const S: AnsiString; out A: LongWord): Boolean;
function  TryHexToLongWordB(const S: RawByteString; out A: LongWord): Boolean;
function  TryHexToLongWordW(const S: WideString; out A: LongWord): Boolean;
function  TryHexToLongWordU(const S: UnicodeString; out A: LongWord): Boolean;
function  TryHexToLongWord(const S: String; out A: LongWord): Boolean;

function  HexToLongWordA(const S: AnsiString): LongWord;
function  HexToLongWordB(const S: RawByteString): LongWord;
function  HexToLongWordW(const S: WideString): LongWord;
function  HexToLongWordU(const S: UnicodeString): LongWord;
function  HexToLongWord(const S: String): LongWord;

function  TryOctToLongWordA(const S: AnsiString; out A: LongWord): Boolean;
function  TryOctToLongWordB(const S: RawByteString; out A: LongWord): Boolean;
function  TryOctToLongWordW(const S: WideString; out A: LongWord): Boolean;
function  TryOctToLongWordU(const S: UnicodeString; out A: LongWord): Boolean;
function  TryOctToLongWord(const S: String; out A: LongWord): Boolean;

function  OctToLongWordA(const S: AnsiString): LongWord;
function  OctToLongWordB(const S: RawByteString): LongWord;
function  OctToLongWordW(const S: WideString): LongWord;
function  OctToLongWordU(const S: UnicodeString): LongWord;
function  OctToLongWord(const S: String): LongWord;

function  TryBinToLongWordA(const S: AnsiString; out A: LongWord): Boolean;
function  TryBinToLongWordB(const S: RawByteString; out A: LongWord): Boolean;
function  TryBinToLongWordW(const S: WideString; out A: LongWord): Boolean;
function  TryBinToLongWordU(const S: UnicodeString; out A: LongWord): Boolean;
function  TryBinToLongWord(const S: String; out A: LongWord): Boolean;

function  BinToLongWordA(const S: AnsiString): LongWord;
function  BinToLongWordB(const S: RawByteString): LongWord;
function  BinToLongWordW(const S: WideString): LongWord;
function  BinToLongWordU(const S: UnicodeString): LongWord;
function  BinToLongWord(const S: String): LongWord;



{                                                                              }
{ Float-String conversions                                                     }
{                                                                              }
function  FloatToStringA(const A: Extended): AnsiString;
function  FloatToStringB(const A: Extended): RawByteString;
function  FloatToStringW(const A: Extended): WideString;
function  FloatToStringU(const A: Extended): UnicodeString;
function  FloatToString(const A: Extended): String;

function  TryStringToFloatPA(const BufP: Pointer; const BufLen: Integer; out Value: Extended; out StrLen: Integer): TConvertResult;
function  TryStringToFloatPW(const BufP: Pointer; const BufLen: Integer; out Value: Extended; out StrLen: Integer): TConvertResult;
function  TryStringToFloatP(const BufP: Pointer; const BufLen: Integer; out Value: Extended; out StrLen: Integer): TConvertResult;

function  TryStringToFloatA(const A: AnsiString; out B: Extended): Boolean;
function  TryStringToFloatB(const A: RawByteString; out B: Extended): Boolean;
function  TryStringToFloatW(const A: WideString; out B: Extended): Boolean;
function  TryStringToFloatU(const A: UnicodeString; out B: Extended): Boolean;
function  TryStringToFloat(const A: String; out B: Extended): Boolean;

function  StringToFloatA(const A: AnsiString): Extended;
function  StringToFloatB(const A: RawByteString): Extended;
function  StringToFloatW(const A: WideString): Extended;
function  StringToFloatU(const A: UnicodeString): Extended;
function  StringToFloat(const A: String): Extended;

function  StringToFloatDefA(const A: AnsiString; const Default: Extended): Extended;
function  StringToFloatDefB(const A: RawByteString; const Default: Extended): Extended;
function  StringToFloatDefW(const A: WideString; const Default: Extended): Extended;
function  StringToFloatDefU(const A: UnicodeString; const Default: Extended): Extended;
function  StringToFloatDef(const A: String; const Default: Extended): Extended;



{                                                                              }
{ Base64                                                                       }
{                                                                              }
{   EncodeBase64 converts a binary string (S) to a base 64 string using        }
{   Alphabet. if Pad is True, the result will be padded with PadChar to be a   }
{   multiple of PadMultiple.                                                   }
{                                                                              }
{   DecodeBase64 converts a base 64 string using Alphabet (64 characters for   }
{   values 0-63) to a binary string.                                           }
{                                                                              }
function  EncodeBase64(const S, Alphabet: AnsiString;
          const Pad: Boolean = False;
          const PadMultiple: Integer = 4;
          const PadChar: AnsiChar = '='): AnsiString;

function  DecodeBase64(const S, Alphabet: AnsiString;
          const PadSet: CharSet{$IFNDEF CLR} = []{$ENDIF}): AnsiString;

const
  b64_MIMEBase64 = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
  b64_UUEncode   = ' !"#$%&''()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_';
  b64_XXEncode   = '+-0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';

function  MIMEBase64Decode(const S: AnsiString): AnsiString;
function  MIMEBase64Encode(const S: AnsiString): AnsiString;
function  UUDecode(const S: AnsiString): AnsiString;
function  XXDecode(const S: AnsiString): AnsiString;

function  BytesToHex(
          {$IFDEF ManagedCode}const P: array of Byte;
          {$ELSE}             const P: Pointer; const Count: Integer;{$ENDIF}
          const UpperCase: Boolean = True): AnsiString;



{                                                                              }
{ Network byte order                                                           }
{                                                                              }
function  hton16(const A: Word): Word;
function  ntoh16(const A: Word): Word;
function  hton32(const A: LongWord): LongWord;
function  ntoh32(const A: LongWord): LongWord;
function  hton64(const A: Int64): Int64;
function  ntoh64(const A: Int64): Int64;



{                                                                              }
{ Type conversion                                                              }
{                                                                              }
{$IFNDEF ManagedCode}
function  PointerToStrA(const P: Pointer): AnsiString;
function  PointerToStrB(const P: Pointer): RawByteString;
function  PointerToStrW(const P: Pointer): WideString;
function  PointerToStr(const P: Pointer): String;

function  StrToPointerA(const S: AnsiString): Pointer;
function  StrToPointerB(const S: RawByteString): Pointer;
function  StrToPointerW(const S: WideString): Pointer;
function  StrToPointer(const S: String): Pointer;

function  InterfaceToStrA(const I: IInterface): AnsiString;
function  InterfaceToStrW(const I: IInterface): WideString;
function  InterfaceToStr(const I: IInterface): String;
{$ENDIF}

function  ObjectClassName(const O: TObject): String;
function  ClassClassName(const C: TClass): String;
function  ObjectToStr(const O: TObject): String;
function  CharSetToStr(const C: CharSet): AnsiString;
function  StrToCharSet(const S: AnsiString): CharSet;



{                                                                              }
{ Hashing functions                                                            }
{                                                                              }
{   HashBuf uses a every byte in the buffer to calculate a hash.               }
{                                                                              }
{   HashStr is a general purpose string hashing function.                      }
{                                                                              }
{   If Slots = 0 the hash value is in the LongWord range (0-$FFFFFFFF),        }
{   otherwise the value is in the range from 0 to Slots-1. Note that the       }
{   'mod' operation, which is used when Slots <> 0, is comparitively slow.     }
{                                                                              }
function  HashBuf(const Hash: LongWord; const Buf; const BufSize: Integer): LongWord;

function  HashStrA(const S: AnsiString;
          const Index: Integer = 1; const Count: Integer = -1;
          const AsciiCaseSensitive: Boolean = True;
          const Slots: LongWord = 0): LongWord;
function  HashStrB(const S: RawByteString;
          const Index: Integer = 1; const Count: Integer = -1;
          const AsciiCaseSensitive: Boolean = True;
          const Slots: LongWord = 0): LongWord;
function  HashStrW(const S: WideString;
          const Index: Integer = 1; const Count: Integer = -1;
          const AsciiCaseSensitive: Boolean = True;
          const Slots: LongWord = 0): LongWord;
function  HashStrU(const S: UnicodeString;
          const Index: Integer = 1; const Count: Integer = -1;
          const AsciiCaseSensitive: Boolean = True;
          const Slots: LongWord = 0): LongWord;
function  HashStr(const S: String;
          const Index: Integer = 1; const Count: Integer = -1;
          const AsciiCaseSensitive: Boolean = True;
          const Slots: LongWord = 0): LongWord;

function  HashInteger(const I: Integer; const Slots: LongWord = 0): LongWord;
function  HashLongWord(const I: LongWord; const Slots: LongWord = 0): LongWord;



{                                                                              }
{ Memory operations                                                            }
{                                                                              }
{$IFDEF DELPHI5_DOWN}
type
  PPointer = ^Pointer;
{$ENDIF}

const
  Bytes1KB  = 1024;
  Bytes1MB  = 1024 * Bytes1KB;
  Bytes1GB  = 1024 * Bytes1MB;
  Bytes64KB = 64 * Bytes1KB;
  Bytes64MB = 64 * Bytes1MB;
  Bytes2GB  = 2 * LongWord(Bytes1GB);

{$IFNDEF ManagedCode}
{$IFDEF ASM386_DELPHI}{$IFNDEF DELPHI2006_UP}
  {$DEFINE UseAsmMemFunction}
{$ENDIF}{$ENDIF}
{$IFDEF UseInline}{$IFNDEF UseAsmMemFunction}
  {$DEFINE InlineMemFunction}
{$ENDIF}{$ENDIF}

procedure FillMem(var Buf; const Count: Integer; const Value: Byte); {$IFDEF InlineMemFunction}inline;{$ENDIF}
procedure ZeroMem(var Buf; const Count: Integer);                    {$IFDEF InlineMemFunction}inline;{$ENDIF}
procedure GetZeroMem(var P: Pointer; const Size: Integer);           {$IFDEF InlineMemFunction}inline;{$ENDIF}
procedure MoveMem(const Source; var Dest; const Count: Integer);     {$IFDEF InlineMemFunction}inline;{$ENDIF}
function  CompareMem(const Buf1; const Buf2; const Count: Integer): Boolean;
function  CompareMemNoCase(const Buf1; const Buf2; const Count: Integer): TCompareResult;
function  LocateMem(const Buf1; const Size1: Integer; const Buf2; const Size2: Integer): Integer;
procedure ReverseMem(var Buf; const Size: Integer);
{$ENDIF}



{                                                                              }
{ IInterface                                                                   }
{                                                                              }
{$IFDEF DELPHI5_DOWN}
type
  IInterface = interface
    ['{00000000-0000-0000-C000-000000000046}']
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
  end;
{$ENDIF}



{                                                                              }
{ Array pointers                                                               }
{                                                                              }

{ Maximum array elements                                                       }
const
  MaxArraySize = $7FFFFFFF; // 2 Gigabytes
  MaxByteArrayElements = MaxArraySize div Sizeof(Byte);
  MaxWordArrayElements = MaxArraySize div Sizeof(Word);
  MaxLongWordArrayElements = MaxArraySize div Sizeof(LongWord);
  MaxCardinalArrayElements = MaxArraySize div Sizeof(Cardinal);
  MaxNativeUIntArrayElements = MaxArraySize div Sizeof(NativeUInt);
  MaxShortIntArrayElements = MaxArraySize div Sizeof(ShortInt);
  MaxSmallIntArrayElements = MaxArraySize div Sizeof(SmallInt);
  MaxLongIntArrayElements = MaxArraySize div Sizeof(LongInt);
  MaxIntegerArrayElements = MaxArraySize div Sizeof(Integer);
  MaxInt64ArrayElements = MaxArraySize div Sizeof(Int64);
  MaxNativeIntArrayElements = MaxArraySize div Sizeof(NativeInt);
  MaxSingleArrayElements = MaxArraySize div Sizeof(Single);
  MaxDoubleArrayElements = MaxArraySize div Sizeof(Double);
  MaxExtendedArrayElements = MaxArraySize div Sizeof(Extended);
  MaxBooleanArrayElements = MaxArraySize div Sizeof(Boolean);
  {$IFNDEF CLR}
  MaxCurrencyArrayElements = MaxArraySize div Sizeof(Currency);
  MaxAnsiStringArrayElements = MaxArraySize div Sizeof(AnsiString);
  MaxRawByteStringArrayElements = MaxArraySize div Sizeof(RawByteString);
  MaxWideStringArrayElements = MaxArraySize div Sizeof(WideString);
  MaxUnicodeStringArrayElements = MaxArraySize div Sizeof(UnicodeString);
  {$IFDEF StringIsUnicode}
  MaxStringArrayElements = MaxArraySize div Sizeof(UnicodeString);
  {$ELSE}
  MaxStringArrayElements = MaxArraySize div Sizeof(AnsiString);
  {$ENDIF}
  MaxPointerArrayElements = MaxArraySize div Sizeof(Pointer);
  MaxObjectArrayElements = MaxArraySize div Sizeof(TObject);
  MaxInterfaceArrayElements = MaxArraySize div Sizeof(IInterface);
  MaxCharSetArrayElements = MaxArraySize div Sizeof(CharSet);
  MaxByteSetArrayElements = MaxArraySize div Sizeof(ByteSet);
  {$ENDIF}

{ Static array types                                                           }
type
  TStaticByteArray = array[0..MaxByteArrayElements - 1] of Byte;
  TStaticWordArray = array[0..MaxWordArrayElements - 1] of Word;
  TStaticLongWordArray = array[0..MaxLongWordArrayElements - 1] of LongWord;
  TStaticNativeUIntArray = array[0..MaxNativeUIntArrayElements - 1] of NativeUInt;
  TStaticShortIntArray = array[0..MaxShortIntArrayElements - 1] of ShortInt;
  TStaticSmallIntArray = array[0..MaxSmallIntArrayElements - 1] of SmallInt;
  TStaticLongIntArray = array[0..MaxLongIntArrayElements - 1] of LongInt;
  TStaticInt64Array = array[0..MaxInt64ArrayElements - 1] of Int64;
  TStaticNativeIntArray = array[0..MaxNativeIntArrayElements - 1] of NativeInt;
  TStaticSingleArray = array[0..MaxSingleArrayElements - 1] of Single;
  TStaticDoubleArray = array[0..MaxDoubleArrayElements - 1] of Double;
  TStaticExtendedArray = array[0..MaxExtendedArrayElements - 1] of Extended;
  TStaticBooleanArray = array[0..MaxBooleanArrayElements - 1] of Boolean;
  {$IFNDEF CLR}
  TStaticCurrencyArray = array[0..MaxCurrencyArrayElements - 1] of Currency;
  TStaticAnsiStringArray = array[0..MaxAnsiStringArrayElements - 1] of AnsiString;
  TStaticRawByteStringArray = array[0..MaxRawByteStringArrayElements - 1] of RawByteString;
  TStaticWideStringArray = array[0..MaxWideStringArrayElements - 1] of WideString;
  TStaticUnicodeStringArray = array[0..MaxUnicodeStringArrayElements - 1] of UnicodeString;
  {$IFDEF StringIsUnicode}
  TStaticStringArray = TStaticUnicodeStringArray;
  {$ELSE}
  TStaticStringArray = TStaticAnsiStringArray;
  {$ENDIF}
  TStaticPointerArray = array[0..MaxPointerArrayElements - 1] of Pointer;
  TStaticObjectArray = array[0..MaxObjectArrayElements - 1] of TObject;
  TStaticInterfaceArray = array[0..MaxInterfaceArrayElements - 1] of IInterface;
  TStaticCharSetArray = array[0..MaxCharSetArrayElements - 1] of CharSet;
  TStaticByteSetArray = array[0..MaxByteSetArrayElements - 1] of ByteSet;
  {$ENDIF}
  TStaticCardinalArray = TStaticLongWordArray;
  TStaticIntegerArray = TStaticLongIntArray;

{ Static array pointers                                                        }
type
  PStaticByteArray = ^TStaticByteArray;
  PStaticWordArray = ^TStaticWordArray;
  PStaticLongWordArray = ^TStaticLongWordArray;
  PStaticCardinalArray = ^TStaticCardinalArray;
  PStaticNativeUIntArray = ^TStaticNativeUIntArray;
  PStaticShortIntArray = ^TStaticShortIntArray;
  PStaticSmallIntArray = ^TStaticSmallIntArray;
  PStaticLongIntArray = ^TStaticLongIntArray;
  PStaticIntegerArray = ^TStaticIntegerArray;
  PStaticInt64Array = ^TStaticInt64Array;
  PStaticNativeIntArray = ^TStaticNativeIntArray;
  PStaticSingleArray = ^TStaticSingleArray;
  PStaticDoubleArray = ^TStaticDoubleArray;
  PStaticExtendedArray = ^TStaticExtendedArray;
  PStaticBooleanArray = ^TStaticBooleanArray;
  {$IFNDEF CLR}
  PStaticCurrencyArray = ^TStaticCurrencyArray;
  PStaticAnsiStringArray = ^TStaticAnsiStringArray;
  PStaticRawByteStringArray = ^TStaticRawByteStringArray;
  PStaticWideStringArray = ^TStaticWideStringArray;
  PStaticUnicodeStringArray = ^TStaticUnicodeStringArray;
  PStaticStringArray = ^TStaticStringArray;
  PStaticPointerArray = ^TStaticPointerArray;
  PStaticObjectArray = ^TStaticObjectArray;
  PStaticInterfaceArray = ^TStaticInterfaceArray;
  PStaticCharSetArray = ^TStaticCharSetArray;
  PStaticByteSetArray = ^TStaticByteSetArray;
  {$ENDIF}



{                                                                              }
{ Dynamic arrays                                                               }
{                                                                              }
type
  ByteArray = array of Byte;
  WordArray = array of Word;
  LongWordArray = array of LongWord;
  CardinalArray = LongWordArray;
  NativeUIntArray = array of NativeUInt;
  ShortIntArray = array of ShortInt;
  SmallIntArray = array of SmallInt;
  LongIntArray = array of LongInt;
  IntegerArray = LongIntArray;
  NativeIntArray = array of NativeInt;
  Int64Array = array of Int64;
  SingleArray = array of Single;
  DoubleArray = array of Double;
  ExtendedArray = array of Extended;
  CurrencyArray = array of Currency;
  BooleanArray = array of Boolean;
  AnsiStringArray = array of AnsiString;
  RawByteStringArray = array of RawByteString;
  WideStringArray = array of WideString;
  UnicodeStringArray = array of UnicodeString;
  StringArray = array of String;
  {$IFNDEF ManagedCode}
  PointerArray = array of Pointer;
  {$ENDIF}
  ObjectArray = array of TObject;
  InterfaceArray = array of IInterface;
  CharSetArray = array of CharSet;
  ByteSetArray = array of ByteSet;


{$IFDEF ManagedCode}
procedure FreeObjectArray(var V: ObjectArray); overload;
procedure FreeObjectArray(var V: ObjectArray; const LoIdx, HiIdx: Integer); overload;
{$ELSE}
procedure FreeObjectArray(var V); overload;
procedure FreeObjectArray(var V; const LoIdx, HiIdx: Integer); overload;
{$ENDIF}
procedure FreeAndNilObjectArray(var V: ObjectArray);



{                                                                              }
{ Test cases                                                                   }
{                                                                              }
{$IFDEF UTILS_SELFTEST}
procedure SelfTest;
{$ENDIF}



implementation

uses
  { System }
  SysUtils,
  Math;



{                                                                              }
{ CPU identification                                                           }
{                                                                              }
{$IFDEF ASM386_DELPHI}
var
  CPUIDInitialised : Boolean = False;
  CPUIDSupport     : Boolean = False;
  MMXSupport       : Boolean = False;

procedure InitialiseCPUID; assembler;
asm
      // Set CPUID flag
      PUSHFD
      POP     EAX
      OR      EAX, $200000
      PUSH    EAX
      POPFD

      // Check if CPUID flag is still set
      PUSHFD
      POP     EAX
      AND     EAX, $200000
      JNZ     @CPUIDSupported

      // CPUID not supported
      MOV     BYTE PTR [CPUIDSupport], 0
      MOV     BYTE PTR [MMXSupport], 0
      JMP     @CPUIDFin

      // CPUID supported
  @CPUIDSupported:
      MOV     BYTE PTR [CPUIDSupport], 1

      PUSH    EBX

      // Perform CPUID function 1
      MOV     EAX, 1
      {$IFDEF DELPHI5_DOWN}
      DW      0FA2h
      {$ELSE}
      CPUID
      {$ENDIF}

      // Check if MMX feature flag is set
      AND     EDX, $800000
      SETNZ   AL
      MOV     BYTE PTR [MMXSupport], AL

      POP     EBX

  @CPUIDFin:
      MOV     BYTE PTR [CPUIDInitialised], 1
end;
{$ENDIF}



{                                                                              }
{ Range check error                                                            }
{                                                                              }
resourcestring
  SRangeCheckError = 'Range check error';

procedure RaiseRangeCheckError; {$IFDEF UseInline}inline;{$ENDIF}
begin
  raise ERangeError.Create(SRangeCheckError);
end;



{                                                                              }
{ Integer                                                                      }
{                                                                              }
function MinI(const A, B: Integer): Integer;
begin
  if A < B then
    Result := A
  else
    Result := B;
end;

function MaxI(const A, B: Integer): Integer;
begin
  if A > B then
    Result := A
  else
    Result := B;
end;

function MinC(const A, B: Cardinal): Cardinal;
begin
  if A < B then
    Result := A
  else
    Result := B;
end;

function MaxC(const A, B: Cardinal): Cardinal;
begin
  if A > B then
    Result := A
  else
    Result := B;
end;

function Clip(const Value: LongInt; const Low, High: LongInt): LongInt;
begin
  if Value < Low then
    Result := Low else
  if Value > High then
    Result := High
  else
    Result := Value;
end;

function Clip(const Value: Int64; const Low, High: Int64): Int64;
begin
  if Value < Low then
    Result := Low else
  if Value > High then
    Result := High
  else
    Result := Value;
end;

function ClipByte(const Value: LongInt): LongInt;
begin
  if Value < MinByte then
    Result := MinByte else
  if Value > MaxByte then
    Result := MaxByte
  else
    Result := Value;
end;

function ClipByte(const Value: Int64): Int64;
begin
  if Value < MinByte then
    Result := MinByte else
  if Value > MaxByte then
    Result := MaxByte
  else
    Result := Value;
end;

function ClipWord(const Value: LongInt): LongInt;
begin
  if Value < MinWord then
    Result := MinWord else
  if Value > MaxWord then
    Result := MaxWord
  else
    Result := Value;
end;

function ClipWord(const Value: Int64): Int64;
begin
  if Value < MinWord then
    Result := MinWord else
  if Value > MaxWord then
    Result := MaxWord
  else
    Result := Value;
end;

function ClipLongWord(const Value: Int64): LongWord;
begin
  if Value < MinLongWord then
    Result := MinLongWord else
  if Value > MaxLongWord then
    Result := MaxLongWord
  else
    Result := LongWord(Value);
end;

function SumClipI(const A, I: Integer): Integer;
begin
  if I >= 0 then
    if A >= MaxInteger - I then
      Result := MaxInteger
    else
      Result := A + I
  else
    if A <= MinInteger - I then
      Result := MinInteger
    else
      Result := A + I;
end;

function SumClipC(const A: Cardinal; const I: Integer): Cardinal;
var B : Cardinal;
begin
  if I >= 0 then
    if A >= MaxCardinal - Cardinal(I) then
      Result := MaxCardinal
    else
      Result := A + Cardinal(I)
  else
    begin
      B := Cardinal(-I);
      if A <= B then
        Result := 0
      else
        Result := A - B;
    end;
end;



{                                                                              }
{ Real                                                                         }
{                                                                              }
function DoubleMin(const A, B: Double): Double;
begin
  if A < B then
    Result := A
  else
    Result := B;
end;

function DoubleMax(const A, B: Double): Double;
begin
  if A > B then
    Result := A
  else
    Result := B;
end;

function ExtendedMin(const A, B: Extended): Extended;
begin
  if A < B then
    Result := A
  else
    Result := B;
end;

function ExtendedMax(const A, B: Extended): Extended;
begin
  if A > B then
    Result := A
  else
    Result := B;
end;

function FloatMin(const A, B: Float): Float;
begin
  if A < B then
    Result := A
  else
    Result := B;
end;

function FloatMax(const A, B: Float): Float;
begin
  if A > B then
    Result := A
  else
    Result := B;
end;

function FloatClip(const Value: Float; const Low, High: Float): Float;
begin
  if Value < Low then
    Result := Low else
  if Value > High then
    Result := High
  else
    Result := Value;
end;

function InSingleRange(const A: Float): Boolean;
var B : Float;
begin
  B := Abs(A);
  Result := (B >= MinSingle) and (B <= MaxSingle);
end;

{$IFDEF CLR}
function InDoubleRange(const A: Float): Boolean;
begin
  Result := True;
end;
{$ELSE}
function InDoubleRange(const A: Float): Boolean;
var B : Float;
begin
  B := Abs(A);
  Result := (B >= MinDouble) and (B <= MaxDouble);
end;
{$ENDIF}

{$IFNDEF CLR}
function InCurrencyRange(const A: Float): Boolean;
begin
  Result := (A >= MinCurrency) and (A <= MaxCurrency);
end;

function InCurrencyRange(const A: Int64): Boolean;
begin
  Result := (A >= MinCurrency) and (A <= MaxCurrency);
end;
{$ENDIF}

{$IFNDEF ExtendedIsDouble}
function ExtendedExponentBase2(const A: Extended; var Exponent: Integer): Boolean;
var RecA : ExtendedRec absolute A;
    ExpA : Word;
begin
  ExpA := RecA.Exponent and $7FFF;
  if ExpA = $7FFF then // A is NaN, Infinity, ...
    begin
      Exponent := 0;
      Result := False;
    end
  else
    begin
      Exponent := Integer(ExpA) - 16383;
      Result := True;
    end;
end;

function ExtendedExponentBase10(const A: Extended; var Exponent: Integer): Boolean;
const Log2_10 = 3.32192809488736; // Log2(10)
begin
  Result := ExtendedExponentBase2(A, Exponent);
  if Result then
    Exponent := Round(Exponent / Log2_10);
end;
{$ENDIF}

{$IFNDEF ExtendedIsDouble}
function ExtendedIsInfinity(const A: Extended): Boolean;
var Ext : ExtendedRec absolute A;
begin
  if Ext.Exponent and $7FFF <> $7FFF then
    Result := False
  else
    Result := (Ext.Mantissa[1] = $80000000) and (Ext.Mantissa[0] = 0);
end;

function ExtendedIsNaN(const A: Extended): Boolean;
var Ext : ExtendedRec absolute A;
begin
  if Ext.Exponent and $7FFF <> $7FFF then
    Result := False
  else
    Result := (Ext.Mantissa[1] <> $80000000) or (Ext.Mantissa[0] <> 0)
end;
{$ENDIF}



{                                                                              }
{ Approximate comparison                                                       }
{                                                                              }
function FloatZero(const A: Float; const CompareDelta: Float): Boolean;
begin
  Assert(CompareDelta >= 0.0);
  Result := Abs(A) <= CompareDelta;
end;

function FloatOne(const A: Float; const CompareDelta: Float): Boolean;
begin
  Assert(CompareDelta >= 0.0);
  Result := Abs(A - 1.0) <= CompareDelta;
end;

function FloatsEqual(const A, B: Float; const CompareDelta: Float): Boolean;
begin
  Assert(CompareDelta >= 0.0);
  Result := Abs(A - B) <= CompareDelta;
end;

function FloatsCompare(const A, B: Float; const CompareDelta: Float): TCompareResult;
var D : Float;
begin
  Assert(CompareDelta >= 0.0);
  D := A - B;
  if Abs(D) <= CompareDelta then
    Result := crEqual else
  if D >= CompareDelta then
    Result := crGreater
  else
    Result := crLess;
end;



{$IFNDEF ExtendedIsDouble}
{                                                                              }
{ Scaled approximate comparison                                                }
{                                                                              }
{   The ApproxEqual and ApproxCompare functions were taken from the freeware   }
{   FltMath unit by Tempest Software, as taken from Knuth, Seminumerical       }
{   Algorithms, 2nd ed., Addison-Wesley, 1981, pp. 217-220.                    }
{                                                                              }
function ExtendedApproxEqual(const A, B: Extended; const CompareEpsilon: Double): Boolean;
var ExtA : ExtendedRec absolute A;
    ExtB : ExtendedRec absolute B;
    ExpA : Word;
    ExpB : Word;
    Exp  : ExtendedRec;
begin
  ExpA := ExtA.Exponent and $7FFF;
  ExpB := ExtB.Exponent and $7FFF;
  if (ExpA = $7FFF) and
     ((ExtA.Mantissa[1] <> $80000000) or (ExtA.Mantissa[0] <> 0)) then
    { A is NaN }
    Result := False else
  if (ExpB = $7FFF) and
     ((ExtB.Mantissa[1] <> $80000000) or (ExtB.Mantissa[0] <> 0)) then
    { B is NaN }
    Result := False else
  if (ExpA = $7FFF) or (ExpB = $7FFF) then
    { A or B is infinity. Use the builtin comparison, which will       }
    { properly account for signed infinities, comparing infinity with  }
    { infinity, or comparing infinity with a finite value.             }
    Result := A = B else
  begin
    { We are comparing two finite values, so take the difference and   }
    { compare that against the scaled Epsilon.                         }
    Exp.Value := 1.0;
    if ExpA < ExpB then
      Exp.Exponent := ExpB
    else
      Exp.Exponent := ExpA;
    Result := Abs(A - B) <= (CompareEpsilon * Exp.Value);
  end;
end;

function ExtendedApproxCompare(const A, B: Extended; const CompareEpsilon: Double): TCompareResult;
var ExtA : ExtendedRec absolute A;
    ExtB : ExtendedRec absolute B;
    ExpA : Word;
    ExpB : Word;
    Exp  : ExtendedRec;
    D, E : Extended;
begin
  ExpA := ExtA.Exponent and $7FFF;
  ExpB := ExtB.Exponent and $7FFF;
  if (ExpA = $7FFF) and
     ((ExtA.Mantissa[1] <> $80000000) or (ExtA.Mantissa[0] <> 0)) then
    { A is NaN }
    Result := crUndefined else
  if (ExpB = $7FFF) and
     ((ExtB.Mantissa[1] <> $80000000) or (ExtB.Mantissa[0] <> 0)) then
    { B is NaN }
    Result := crUndefined else
  if (ExpA = $7FFF) or (ExpB = $7FFF) then
    { A or B is infinity. Use the builtin comparison, which will       }
    { properly account for signed infinities, comparing infinity with  }
    { infinity, or comparing infinity with a finite value.             }
    Result := Compare(A, B) else
  begin
    { We are comparing two finite values, so take the difference and   }
    { compare that against the scaled Epsilon.                         }
    Exp.Value := 1.0;
    if ExpA < ExpB then
      Exp.Exponent := ExpB
    else
      Exp.Exponent := ExpA;
    E := CompareEpsilon * Exp.Value;
    D := A - B;
    if Abs(D) <= E then
      Result := crEqual else
    if D >= E then
      Result := crGreater
    else
      Result := crLess;
  end;
end;
{$ENDIF}

// Knuth: approximatelyEqual
// return fabs(a - b) <= ( (fabs(a) < fabs(b) ? fabs(b) : fabs(a)) * epsilon);
function DoubleApproxEqual(const A, B: Double; const CompareEpsilon: Double): Boolean;
var AbsA, AbsB, R : Float;
begin
  AbsA := Abs(A);
  AbsB := Abs(B);
  if AbsA < AbsB then
    R := AbsB
  else
    R := AbsA;
  R := R * CompareEpsilon;
  Result := Abs(A - B) <= R;
end;

function DoubleApproxCompare(const A, B: Double; const CompareEpsilon: Double): TCompareResult;
var AbsA, AbsB, R, D : Float;
begin
  AbsA := Abs(A);
  AbsB := Abs(B);
  if AbsA < AbsB then
    R := AbsB
  else
    R := AbsA;
  R := R * CompareEpsilon;
  D := A - B;
  if Abs(D) <= R then
    Result := crEqual
  else
  if D < 0 then
    Result := crLess
  else
    Result := crGreater;
end;

function FloatApproxEqual(const A, B: Float; const CompareEpsilon: Float): Boolean;
var AbsA, AbsB, R : Float;
begin
  AbsA := Abs(A);
  AbsB := Abs(B);
  if AbsA < AbsB then
    R := AbsB
  else
    R := AbsA;
  R := R * CompareEpsilon;
  Result := Abs(A - B) <= R;
end;

function FloatApproxCompare(const A, B: Float; const CompareEpsilon: Float): TCompareResult;
var AbsA, AbsB, R, D : Float;
begin
  AbsA := Abs(A);
  AbsB := Abs(B);
  if AbsA < AbsB then
    R := AbsB
  else
    R := AbsA;
  R := R * CompareEpsilon;
  D := A - B;
  if Abs(D) <= R then
    Result := crEqual
  else
  if D < 0 then
    Result := crLess
  else
    Result := crGreater;
end;



{                                                                              }
{ Bit functions                                                                }
{                                                                              }
{$IFDEF ASM386_DELPHI}
function ReverseBits(const Value: LongWord): LongWord; register; assembler;
asm
      BSWAP   EAX
      MOV     EDX, EAX
      AND     EAX, 0AAAAAAAAh
      SHR     EAX, 1
      AND     EDX, 055555555h
      SHL     EDX, 1
      OR      EAX, EDX
      MOV     EDX, EAX
      AND     EAX, 0CCCCCCCCh
      SHR     EAX, 2
      AND     EDX, 033333333h
      SHL     EDX, 2
      OR      EAX, EDX
      MOV     EDX, EAX
      AND     EAX, 0F0F0F0F0h
      SHR     EAX, 4
      AND     EDX, 00F0F0F0Fh
      SHL     EDX, 4
      OR      EAX, EDX
end;
{$ELSE}
function ReverseBits(const Value: LongWord): LongWord;
var I : Byte;
begin
  Result := 0;
  for I := 0 to 31 do
    if Value and BitMaskTable[I] <> 0 then
      Result := Result or BitMaskTable[31 - I];
end;
{$ENDIF}

function ReverseBits(const Value: LongWord; const BitCount: Integer): LongWord;
var I : Integer;
  V : LongWord;
begin
  V := Value;
  Result := 0;
  for I := 0 to MinI(BitCount, BitsPerLongWord) - 1 do
    begin
      Result := (Result shl 1) or (V and 1);
      V := V shr 1;
    end;
end;

{$IFDEF ASM386_DELPHI}
function SwapEndian(const Value: LongWord): LongWord; register; assembler;
asm
      XCHG    AH, AL
      ROL     EAX, 16
      XCHG    AH, AL
end;
{$ELSE}
function SwapEndian(const Value: LongWord): LongWord;
begin
  Result := ((Value and $000000FF) shl 24)  or
            ((Value and $0000FF00) shl 8)   or
            ((Value and $00FF0000) shr 8)   or
            ((Value and $FF000000) shr 24);
end;
{$ENDIF}

{$IFDEF ManagedCode}
procedure SwapEndianBuf(var Buf: array of LongWord);
var I : Integer;
begin
  for I := 0 to Length(Buf) - 1 do
    Buf[I] := SwapEndian(Buf[I]);
end;
{$ELSE}
procedure SwapEndianBuf(var Buf; const Count: Integer);
var P : PLongWord;
    I : Integer;
begin
  P := @Buf;
  for I := 1 to Count do
    begin
      P^ := SwapEndian(P^);
      Inc(P);
    end;
end;
{$ENDIF}

{$IFDEF ASM386_DELPHI}
function TwosComplement(const Value: LongWord): LongWord; register; assembler;
asm
      NEG     EAX
end;
{$ELSE}
function TwosComplement(const Value: LongWord): LongWord;
begin
  Result := LongWord(not Value + 1);
end;
{$ENDIF}

{$IFDEF ASM386_DELPHI}
function RotateLeftBits16(const Value: Word; const Bits: Byte): Word;
asm
      MOV     CL, DL
      ROL     AX, CL
end;
{$ELSE}
function RotateLeftBits16(const Value: Word; const Bits: Byte): Word;
var I, B : Integer;
    R : Word;
begin
  R := Value;
  if Bits >= 16 then
    B := Bits mod 16
  else
    B := Bits;
  for I := 1 to B do
    if R and $8000 = 0 then
      R := Word(R shl 1)
    else
      R := Word(R shl 1) or 1;
  Result := R;
end;
{$ENDIF}

{$IFDEF ASM386_DELPHI}
function RotateLeftBits32(const Value: LongWord; const Bits: Byte): LongWord;
asm
      MOV     CL, DL
      ROL     EAX, CL
end;
{$ELSE}
function RotateLeftBits32(const Value: LongWord; const Bits: Byte): LongWord;
var I, B : Integer;
    R : LongWord;
begin
  R := Value;
  if Bits >= 32 then
    B := Bits mod 32
  else
    B := Bits;
  for I := 1 to B do
    if R and $80000000 = 0 then
      R := LongWord(R shl 1)
    else
      R := LongWord(R shl 1) or 1;
  Result := R;
end;
{$ENDIF}

{$IFDEF ASM386_DELPHI}
function RotateRightBits16(const Value: Word; const Bits: Byte): Word;
asm
      MOV     CL, DL
      ROR     AX, CL
end;
{$ELSE}
function RotateRightBits16(const Value: Word; const Bits: Byte): Word;
var I, B : Integer;
    R : Word;
begin
  R := Value;
  if Bits >= 16 then
    B := Bits mod 16
  else
    B := Bits;
  for I := 1 to B do
    if R and 1 = 0 then
      R := Word(R shr 1)
    else
      R := Word(R shr 1) or $8000;
  Result := R;
end;
{$ENDIF}

{$IFDEF ASM386_DELPHI}
function RotateRightBits32(const Value: LongWord; const Bits: Byte): LongWord;
asm
      MOV     CL, DL
      ROR     EAX, CL
end;
{$ELSE}
function RotateRightBits32(const Value: LongWord; const Bits: Byte): LongWord;
var I, B : Integer;
    R : LongWord;
begin
  R := Value;
  if Bits >= 32 then
    B := Bits mod 32
  else
    B := Bits;
  for I := 1 to B do
    if R and 1 = 0 then
      R := LongWord(R shr 1)
    else
      R := LongWord(R shr 1) or $80000000;
  Result := R;
end;
{$ENDIF}

{$IFDEF ASM386_DELPHI}
function SetBit(const Value, BitIndex: LongWord): LongWord;
asm
      {$IFOPT R+}
      CMP     BitIndex, BitsPerLongWord
      JB      @RangeOk
      JMP     RaiseRangeCheckError
  @RangeOk:
      {$ENDIF}
      OR      EAX, DWORD PTR [BitIndex * 4 + BitMaskTable]
end;
{$ELSE}
function SetBit(const Value, BitIndex: LongWord): LongWord;
begin
  Result := Value or BitMaskTable[BitIndex];
end;
{$ENDIF}

{$IFDEF ASM386_DELPHI}
function ClearBit(const Value, BitIndex: LongWord): LongWord;
asm
      {$IFOPT R+}
      CMP     BitIndex, BitsPerLongWord
      JB      @RangeOk
      JMP     RaiseRangeCheckError
  @RangeOk:
      {$ENDIF}
      MOV     ECX, DWORD PTR [BitIndex * 4 + BitMaskTable]
      NOT     ECX
      AND     EAX, ECX
  @Fin:
end;
{$ELSE}
function ClearBit(const Value, BitIndex: LongWord): LongWord;
begin
  Result := Value and not BitMaskTable[BitIndex];
end;
{$ENDIF}

{$IFDEF ASM386_DELPHI}
function ToggleBit(const Value, BitIndex: LongWord): LongWord;
asm
      {$IFOPT R+}
      CMP     BitIndex, BitsPerLongWord
      JB      @RangeOk
      JMP     RaiseRangeCheckError
  @RangeOk:
      {$ENDIF}
      XOR     EAX, DWORD PTR [BitIndex * 4 + BitMaskTable]
end;
{$ELSE}
function ToggleBit(const Value, BitIndex: LongWord): LongWord;
begin
  Result := Value xor BitMaskTable[BitIndex];
end;
{$ENDIF}

{$IFDEF ASM386_DELPHI}
function IsHighBitSet(const Value: LongWord): Boolean; register; assembler;
asm
      TEST    Value, $80000000
      SETNZ   AL
end;
{$ELSE}
function IsHighBitSet(const Value: LongWord): Boolean;
begin
  Result := Value and $80000000 <> 0;
end;
{$ENDIF}

{$IFDEF ASM386_DELPHI}
function IsBitSet(const Value, BitIndex: LongWord): Boolean;
asm
      {$IFOPT R+}
      CMP     BitIndex, BitsPerLongWord
      JB      @RangeOk
      JMP     RaiseRangeCheckError
  @RangeOk:
      {$ENDIF}
      MOV     ECX, DWORD PTR BitMaskTable [BitIndex * 4]
      TEST    Value, ECX
      SETNZ   AL
end;
{$ELSE}
function IsBitSet(const Value, BitIndex: LongWord): Boolean;
begin
  Result := Value and BitMaskTable[BitIndex] <> 0;
end;
{$ENDIF}

{$IFDEF ASM386_DELPHI}
function SetBitScanForward(const Value: LongWord): Integer;
asm
      OR      EAX, EAX
      JZ      @NoBits
      BSF     EAX, EAX
      RET
  @NoBits:
      MOV     EAX, -1
end;

function SetBitScanForward(const Value, BitIndex: LongWord): Integer;
asm
      CMP     BitIndex, BitsPerLongWord
      JAE     @NotFound
      MOV     ECX, BitIndex
      MOV     EDX, $FFFFFFFF
      SHL     EDX, CL
      AND     EDX, EAX
      JE      @NotFound
      BSF     EAX, EDX
      RET
  @NotFound:
      MOV     EAX, -1
end;
{$ELSE}
function SetBitScanForward(const Value, BitIndex: LongWord): Integer;
var I : Integer;
begin
  if BitIndex < BitsPerLongWord then
    for I := Integer(BitIndex) to 31 do
      if Value and BitMaskTable[I] <> 0 then
        begin
          Result := I;
          exit;
        end;
  Result := -1;
end;

function SetBitScanForward(const Value: LongWord): Integer;
begin
  Result := SetBitScanForward(Value, 0);
end;
{$ENDIF}

{$IFDEF ASM386_DELPHI}
function SetBitScanReverse(const Value: LongWord): Integer;
asm
      OR      EAX, EAX
      JZ      @NoBits
      BSR     EAX, EAX
      RET
  @NoBits:
      MOV     EAX, -1
end;

function SetBitScanReverse(const Value, BitIndex: LongWord): Integer;
asm
      CMP     EDX, BitsPerLongWord
      JAE     @NotFound
      LEA     ECX, [EDX - 31]
      MOV     EDX, $FFFFFFFF
      NEG     ECX
      SHR     EDX, CL
      AND     EDX, EAX
      JE      @NotFound
      BSR     EAX, EDX
      RET
  @NotFound:
      MOV     EAX, -1
end;
{$ELSE}
function SetBitScanReverse(const Value, BitIndex: LongWord): Integer;
var I : Integer;
begin
  if BitIndex < BitsPerLongWord then
    for I := Integer(BitIndex) downto 0 do
      if Value and BitMaskTable[I] <> 0 then
        begin
          Result := I;
          exit;
        end;
  Result := -1;
end;

function SetBitScanReverse(const Value: LongWord): Integer;
begin
  Result := SetBitScanReverse(Value, 31);
end;
{$ENDIF}

{$IFDEF ASM386_DELPHI}
function ClearBitScanForward(const Value: LongWord): Integer;
asm
      NOT     EAX
      OR      EAX, EAX
      JZ      @NoBits
      BSF     EAX, EAX
      RET
  @NoBits:
      MOV     EAX, -1
end;

function ClearBitScanForward(const Value, BitIndex: LongWord): Integer;
asm
      CMP     EDX, BitsPerLongWord
      JAE     @NotFound
      MOV     ECX, EDX
      MOV     EDX, $FFFFFFFF
      NOT     EAX
      SHL     EDX, CL
      AND     EDX, EAX
      JE      @NotFound
      BSF     EAX, EDX
      RET
  @NotFound:
      MOV     EAX, -1
end;
{$ELSE}
function ClearBitScanForward(const Value, BitIndex: LongWord): Integer;
var I : Integer;
begin
  if BitIndex < BitsPerLongWord then
    for I := Integer(BitIndex) to 31 do
      if Value and BitMaskTable[I] = 0 then
        begin
          Result := I;
          exit;
        end;
  Result := -1;
end;

function ClearBitScanForward(const Value: LongWord): Integer;
begin
  Result := ClearBitScanForward(Value, 0);
end;
{$ENDIF}

{$IFDEF ASM386_DELPHI}
function ClearBitScanReverse(const Value: LongWord): Integer;
asm
      NOT     EAX
      OR      EAX, EAX
      JZ      @NoBits
      BSR     EAX, EAX
      RET
  @NoBits:
      MOV     EAX, -1
end;

function ClearBitScanReverse(const Value, BitIndex: LongWord): Integer;
asm
      CMP     EDX, BitsPerLongWord
      JAE     @NotFound
      LEA     ECX, [EDX - 31]
      MOV     EDX, $FFFFFFFF
      NEG     ECX
      NOT     EAX
      SHR     EDX, CL
      AND     EDX, EAX
      JE      @NotFound
      BSR     EAX, EDX
      RET
  @NotFound:
      MOV     EAX, -1
end;
{$ELSE}
function ClearBitScanReverse(const Value, BitIndex: LongWord): Integer;
var I : Integer;
begin
  if BitIndex < BitsPerLongWord then
    for I := Integer(BitIndex) downto 0 do
      if Value and BitMaskTable[I] = 0 then
        begin
          Result := I;
          exit;
        end;
  Result := -1;
end;

function ClearBitScanReverse(const Value: LongWord): Integer;
begin
  Result := ClearBitScanReverse(Value, 31);
end;
{$ENDIF}

const
  BitCountTable : array[Byte] of Byte =
    (0, 1, 1, 2, 1, 2, 2, 3, 1, 2, 2, 3, 2, 3, 3, 4,
     1, 2, 2, 3, 2, 3, 3, 4, 2, 3, 3, 4, 3, 4, 4, 5,
     1, 2, 2, 3, 2, 3, 3, 4, 2, 3, 3, 4, 3, 4, 4, 5,
     2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6,
     1, 2, 2, 3, 2, 3, 3, 4, 2, 3, 3, 4, 3, 4, 4, 5,
     2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6,
     2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6,
     3, 4, 4, 5, 4, 5, 5, 6, 4, 5, 5, 6, 5, 6, 6, 7,
     1, 2, 2, 3, 2, 3, 3, 4, 2, 3, 3, 4, 3, 4, 4, 5,
     2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6,
     2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6,
     3, 4, 4, 5, 4, 5, 5, 6, 4, 5, 5, 6, 5, 6, 6, 7,
     2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6,
     3, 4, 4, 5, 4, 5, 5, 6, 4, 5, 5, 6, 5, 6, 6, 7,
     3, 4, 4, 5, 4, 5, 5, 6, 4, 5, 5, 6, 5, 6, 6, 7,
     4, 5, 5, 6, 5, 6, 6, 7, 5, 6, 6, 7, 6, 7, 7, 8);

{$IFDEF ASM386_DELPHI}
function BitCount(const Value: LongWord): LongWord; register; assembler;
asm
      MOVZX   EDX, AL
      MOVZX   EDX, BYTE PTR [EDX + BitCountTable]
      MOVZX   ECX, AH
      ADD     DL, BYTE PTR [ECX + BitCountTable]
      SHR     EAX, 16
      MOVZX   ECX, AH
      ADD     DL, BYTE PTR [ECX + BitCountTable]
      AND     EAX, $FF
      ADD     DL, BYTE PTR [EAX + BitCountTable]
      MOV     AL, DL
end;
{$ELSE}
function BitCount(const Value: LongWord): LongWord;
begin
  Result := BitCountTable[(Value and $000000FF)       ] +
            BitCountTable[(Value and $0000FF00) shr 8 ] +
            BitCountTable[(Value and $00FF0000) shr 16] +
            BitCountTable[(Value and $FF000000) shr 24];
end;
{$ENDIF}

function IsPowerOfTwo(const Value: LongWord): Boolean;
begin
  Result := BitCount(Value) = 1;
end;

function LowBitMask(const HighBitIndex: LongWord): LongWord;
begin
  if HighBitIndex >= BitsPerLongWord then
    Result := 0
  else
    Result := BitMaskTable[HighBitIndex] - 1;
end;

function HighBitMask(const LowBitIndex: LongWord): LongWord;
begin
  if LowBitIndex >= BitsPerLongWord then
    Result := 0
  else
    Result := not BitMaskTable[LowBitIndex] + 1;
end;

function RangeBitMask(const LowBitIndex, HighBitIndex: LongWord): LongWord;
begin
  if (LowBitIndex >= BitsPerLongWord) and (HighBitIndex >= BitsPerLongWord) then
    begin
      Result := 0;
      exit;
    end;
  Result := $FFFFFFFF;
  if LowBitIndex > 0 then
    Result := Result xor (BitMaskTable[LowBitIndex] - 1);
  if HighBitIndex < 31 then
    Result := Result xor (not BitMaskTable[HighBitIndex + 1] + 1);
end;

function SetBitRange(const Value: LongWord; const LowBitIndex, HighBitIndex: LongWord): LongWord;
begin
  Result := Value or RangeBitMask(LowBitIndex, HighBitIndex);
end;

function ClearBitRange(const Value: LongWord; const LowBitIndex, HighBitIndex: LongWord): LongWord;
begin
  Result := Value and not RangeBitMask(LowBitIndex, HighBitIndex);
end;

function ToggleBitRange(const Value: LongWord; const LowBitIndex, HighBitIndex: LongWord): LongWord;
begin
  Result := Value xor RangeBitMask(LowBitIndex, HighBitIndex);
end;

function IsBitRangeSet(const Value: LongWord; const LowBitIndex, HighBitIndex: LongWord): Boolean;
var M: LongWord;
begin
  M := RangeBitMask(LowBitIndex, HighBitIndex);
  Result := Value and M = M;
end;

function IsBitRangeClear(const Value: LongWord; const LowBitIndex, HighBitIndex: LongWord): Boolean;
begin
  Result := Value and RangeBitMask(LowBitIndex, HighBitIndex) = 0;
end;



{                                                                              }
{ Sets                                                                         }
{                                                                              }
function AsCharSet(const C: array of AnsiChar): CharSet;
var I: Integer;
begin
  Result := [];
  for I := 0 to High(C) do
    Include(Result, C[I]);
end;

function AsByteSet(const C: array of Byte): ByteSet;
var I: Integer;
begin
  Result := [];
  for I := 0 to High(C) do
    Include(Result, C[I]);
end;

{$IFDEF ASM386_DELPHI}
procedure ComplementChar(var C: CharSet; const Ch: AnsiChar);
asm
      MOVZX   ECX, DL
      BTC     [EAX], ECX
end;
{$ELSE}
procedure ComplementChar(var C: CharSet; const Ch: AnsiChar);
begin
  if Ch in C then
    Exclude(C, Ch)
  else
    Include(C, Ch);
end;
{$ENDIF}

{$IFDEF ASM386_DELPHI}
procedure ClearCharSet(var C: CharSet);
asm
      XOR     EDX, EDX
      MOV     [EAX], EDX
      MOV     [EAX + 4], EDX
      MOV     [EAX + 8], EDX
      MOV     [EAX + 12], EDX
      MOV     [EAX + 16], EDX
      MOV     [EAX + 20], EDX
      MOV     [EAX + 24], EDX
      MOV     [EAX + 28], EDX
end;
{$ELSE}
procedure ClearCharSet(var C: CharSet);
begin
  C := [];
end;
{$ENDIF}

{$IFDEF ASM386_DELPHI}
procedure FillCharSet(var C: CharSet);
asm
      MOV     EDX, $FFFFFFFF
      MOV     [EAX], EDX
      MOV     [EAX + 4], EDX
      MOV     [EAX + 8], EDX
      MOV     [EAX + 12], EDX
      MOV     [EAX + 16], EDX
      MOV     [EAX + 20], EDX
      MOV     [EAX + 24], EDX
      MOV     [EAX + 28], EDX
end;
{$ELSE}
procedure FillCharSet(var C: CharSet);
begin
  C := [#0..#255];
end;
{$ENDIF}

{$IFDEF ASM386_DELPHI}
procedure ComplementCharSet(var C: CharSet);
asm
      NOT     DWORD PTR [EAX]
      NOT     DWORD PTR [EAX + 4]
      NOT     DWORD PTR [EAX + 8]
      NOT     DWORD PTR [EAX + 12]
      NOT     DWORD PTR [EAX + 16]
      NOT     DWORD PTR [EAX + 20]
      NOT     DWORD PTR [EAX + 24]
      NOT     DWORD PTR [EAX + 28]
end;
{$ELSE}
procedure ComplementCharSet(var C: CharSet);
begin
  C := [#0..#255] - C;
end;
{$ENDIF}

{$IFDEF ASM386_DELPHI}
procedure AssignCharSet(var DestSet: CharSet; const SourceSet: CharSet);
asm
      MOV     ECX, [EDX]
      MOV     [EAX], ECX
      MOV     ECX, [EDX + 4]
      MOV     [EAX + 4], ECX
      MOV     ECX, [EDX + 8]
      MOV     [EAX + 8], ECX
      MOV     ECX, [EDX + 12]
      MOV     [EAX + 12], ECX
      MOV     ECX, [EDX + 16]
      MOV     [EAX + 16], ECX
      MOV     ECX, [EDX + 20]
      MOV     [EAX + 20], ECX
      MOV     ECX, [EDX + 24]
      MOV     [EAX + 24], ECX
      MOV     ECX, [EDX + 28]
      MOV     [EAX + 28], ECX
end;
{$ELSE}
procedure AssignCharSet(var DestSet: CharSet; const SourceSet: CharSet);
begin
  DestSet := SourceSet;
end;
{$ENDIF}

{$IFDEF ASM386_DELPHI}
procedure Union(var DestSet: CharSet; const SourceSet: CharSet);
asm
      MOV     ECX, [EDX]
      OR      [EAX], ECX
      MOV     ECX, [EDX + 4]
      OR      [EAX + 4], ECX
      MOV     ECX, [EDX + 8]
      OR      [EAX + 8], ECX
      MOV     ECX, [EDX + 12]
      OR      [EAX + 12], ECX
      MOV     ECX, [EDX + 16]
      OR      [EAX + 16], ECX
      MOV     ECX, [EDX + 20]
      OR      [EAX + 20], ECX
      MOV     ECX, [EDX + 24]
      OR      [EAX + 24], ECX
      MOV     ECX, [EDX + 28]
      OR      [EAX + 28], ECX
end;
{$ELSE}
procedure Union(var DestSet: CharSet; const SourceSet: CharSet);
begin
  DestSet := DestSet + SourceSet;
end;
{$ENDIF}

{$IFDEF ASM386_DELPHI}
procedure Difference(var DestSet: CharSet; const SourceSet: CharSet);
asm
      MOV     ECX, [EDX]
      NOT     ECX
      AND     [EAX], ECX
      MOV     ECX, [EDX + 4]
      NOT     ECX
      AND     [EAX + 4], ECX
      MOV     ECX, [EDX + 8]
      NOT     ECX
      AND     [EAX + 8],ECX
      MOV     ECX, [EDX + 12]
      NOT     ECX
      AND     [EAX + 12], ECX
      MOV     ECX, [EDX + 16]
      NOT     ECX
      AND     [EAX + 16], ECX
      MOV     ECX, [EDX + 20]
      NOT     ECX
      AND     [EAX + 20], ECX
      MOV     ECX, [EDX + 24]
      NOT     ECX
      AND     [EAX + 24], ECX
      MOV     ECX, [EDX + 28]
      NOT     ECX
      AND     [EAX + 28], ECX
end;
{$ELSE}
procedure Difference(var DestSet: CharSet; const SourceSet: CharSet);
begin
  DestSet := DestSet - SourceSet;
end;
{$ENDIF}

{$IFDEF ASM386_DELPHI}
procedure Intersection(var DestSet: CharSet; const SourceSet: CharSet);
asm
      MOV     ECX, [EDX]
      AND     [EAX], ECX
      MOV     ECX, [EDX + 4]
      AND     [EAX + 4], ECX
      MOV     ECX, [EDX + 8]
      AND     [EAX + 8], ECX
      MOV     ECX, [EDX + 12]
      AND     [EAX + 12], ECX
      MOV     ECX, [EDX + 16]
      AND     [EAX + 16], ECX
      MOV     ECX, [EDX + 20]
      AND     [EAX + 20], ECX
      MOV     ECX, [EDX + 24]
      AND     [EAX + 24], ECX
      MOV     ECX, [EDX + 28]
      AND     [EAX + 28], ECX
end;
{$ELSE}
procedure Intersection(var DestSet: CharSet; const SourceSet: CharSet);
begin
  DestSet := DestSet * SourceSet;
end;
{$ENDIF}

{$IFDEF ASM386_DELPHI}
procedure XORCharSet(var DestSet: CharSet; const SourceSet: CharSet);
asm
      MOV     ECX, [EDX]
      XOR     [EAX], ECX
      MOV     ECX, [EDX + 4]
      XOR     [EAX + 4], ECX
      MOV     ECX, [EDX + 8]
      XOR     [EAX + 8], ECX
      MOV     ECX, [EDX + 12]
      XOR     [EAX + 12], ECX
      MOV     ECX, [EDX + 16]
      XOR     [EAX + 16], ECX
      MOV     ECX, [EDX + 20]
      XOR     [EAX + 20], ECX
      MOV     ECX, [EDX + 24]
      XOR     [EAX + 24], ECX
      MOV     ECX, [EDX + 28]
      XOR     [EAX + 28], ECX
end;
{$ELSE}
procedure XORCharSet(var DestSet: CharSet; const SourceSet: CharSet);
var Ch: AnsiChar;
begin
  for Ch := #0 to #255 do
    if Ch in DestSet then
      begin
        if Ch in SourceSet then
          Exclude(DestSet, Ch);
      end else
      if Ch in SourceSet then
        Include(DestSet, Ch);
end;
{$ENDIF}

{$IFDEF ASM386_DELPHI}
function IsSubSet(const A, B: CharSet): Boolean;
asm
      MOV     ECX, [EDX]
      NOT     ECX
      AND     ECX, [EAX]
      JNE     @Fin0
      MOV     ECX, [EDX + 4]
      NOT     ECX
      AND     ECX, [EAX + 4]
      JNE     @Fin0
      MOV     ECX, [EDX + 8]
      NOT     ECX
      AND     ECX, [EAX + 8]
      JNE     @Fin0
      MOV     ECX, [EDX + 12]
      NOT     ECX
      AND     ECX, [EAX + 12]
      JNE     @Fin0
      MOV     ECX, [EDX + 16]
      NOT     ECX
      AND     ECX, [EAX + 16]
      JNE     @Fin0
      MOV     ECX, [EDX + 20]
      NOT     ECX
      AND     ECX, [EAX + 20]
      JNE     @Fin0
      MOV     ECX, [EDX + 24]
      NOT     ECX
      AND     ECX, [EAX + 24]
      JNE     @Fin0
      MOV     ECX, [EDX + 28]
      NOT     ECX
      AND     ECX, [EAX + 28]
      JNE     @Fin0
      MOV     EAX, 1
      RET
@Fin0:
      XOR     EAX, EAX
end;
{$ELSE}
function IsSubSet(const A, B: CharSet): Boolean;
begin
  Result := A <= B;
end;
{$ENDIF}

{$IFDEF ASM386_DELPHI}
function IsEqual(const A, B: CharSet): Boolean;
asm
      MOV     ECX, [EDX]
      XOR     ECX, [EAX]
      JNE     @Fin0
      MOV     ECX, [EDX + 4]
      XOR     ECX, [EAX + 4]
      JNE     @Fin0
      MOV     ECX, [EDX + 8]
      XOR     ECX, [EAX + 8]
      JNE     @Fin0
      MOV     ECX, [EDX + 12]
      XOR     ECX, [EAX + 12]
      JNE     @Fin0
      MOV     ECX, [EDX + 16]
      XOR     ECX, [EAX + 16]
      JNE     @Fin0
      MOV     ECX, [EDX + 20]
      XOR     ECX, [EAX + 20]
      JNE     @Fin0
      MOV     ECX, [EDX + 24]
      XOR     ECX, [EAX + 24]
      JNE     @Fin0
      MOV     ECX, [EDX + 28]
      XOR     ECX, [EAX + 28]
      JNE     @Fin0
      MOV     EAX, 1
      RET
@Fin0:
      XOR     EAX, EAX
end;
{$ELSE}
function IsEqual(const A, B: CharSet): Boolean;
begin
  Result := A = B;
end;
{$ENDIF}

{$IFDEF ASM386_DELPHI}
function IsEmpty(const C: CharSet): Boolean;
asm
      MOV     EDX, [EAX]
      OR      EDX, [EAX + 4]
      OR      EDX, [EAX + 8]
      OR      EDX, [EAX + 12]
      OR      EDX, [EAX + 16]
      OR      EDX, [EAX + 20]
      OR      EDX, [EAX + 24]
      OR      EDX, [EAX + 28]
      JNE     @Fin0
      MOV     EAX, 1
      RET
@Fin0:
      XOR     EAX,EAX
end;
{$ELSE}
function IsEmpty(const C: CharSet): Boolean;
begin
  Result := C = [];
end;
{$ENDIF}

{$IFDEF ASM386_DELPHI}
function IsComplete(const C: CharSet): Boolean;
asm
      MOV     EDX, [EAX]
      AND     EDX, [EAX + 4]
      AND     EDX, [EAX + 8]
      AND     EDX, [EAX + 12]
      AND     EDX, [EAX + 16]
      AND     EDX, [EAX + 20]
      AND     EDX, [EAX + 24]
      AND     EDX, [EAX + 28]
      CMP     EDX, $FFFFFFFF
      JNE     @Fin0
      MOV     EAX, 1
      RET
@Fin0:
      XOR     EAX, EAX
end;
{$ELSE}
function IsComplete(const C: CharSet): Boolean;
begin
  Result := C = CompleteCharSet;
end;
{$ENDIF}

{$IFDEF ASM386_DELPHI}
function CharCount(const C: CharSet): Integer;
asm
      PUSH    EBX
      PUSH    ESI
      MOV     EBX, EAX
      XOR     ESI, ESI
      MOV     EAX, [EBX]
      CALL    BitCount
      ADD     ESI, EAX
      MOV     EAX, [EBX + 4]
      CALL    BitCount
      ADD     ESI, EAX
      MOV     EAX, [EBX + 8]
      CALL    BitCount
      ADD     ESI, EAX
      MOV     EAX, [EBX + 12]
      CALL    BitCount
      ADD     ESI, EAX
      MOV     EAX, [EBX + 16]
      CALL    BitCount
      ADD     ESI, EAX
      MOV     EAX, [EBX + 20]
      CALL    BitCount
      ADD     ESI, EAX
      MOV     EAX, [EBX + 24]
      CALL    BitCount
      ADD     ESI, EAX
      MOV     EAX, [EBX + 28]
      CALL    BitCount
      ADD     EAX, ESI
      POP     ESI
      POP     EBX
end;
{$ELSE}
function CharCount(const C: CharSet): Integer;
var I : AnsiChar;
begin
  Result := 0;
  for I := #0 to #255 do
    if I in C then
      Inc(Result);
end;
{$ENDIF}

{$IFDEF ASM386_DELPHI}
procedure ConvertCaseInsensitive(var C: CharSet);
asm
      MOV     ECX, [EAX + 12]
      AND     ECX, $3FFFFFF
      OR      [EAX + 8], ECX
      MOV     ECX, [EAX + 8]
      AND     ECX, $3FFFFFF
      OR      [EAX + 12], ECX
end;
{$ELSE}
procedure ConvertCaseInsensitive(var C: CharSet);
var Ch : AnsiChar;
begin
  for Ch := 'A' to 'Z' do
    if Ch in C then
      Include(C, AnsiChar(Ord(Ch) + 32));
  for Ch := 'a' to 'z' do
    if Ch in C then
      Include(C, AnsiChar(Ord(Ch) - 32));
end;
{$ENDIF}

function CaseInsensitiveCharSet(const C: CharSet): CharSet;
begin
  AssignCharSet(Result, C);
  ConvertCaseInsensitive(Result);
end;



{                                                                              }
{ Range functions                                                              }
{                                                                              }
function IntRangeLength(const Low, High: Integer): Int64;
begin
  if Low > High then
    Result := 0
  else
    Result := Int64(High - Low) + 1;
end;

function IntRangeAdjacent(const Low1, High1, Low2, High2: Integer): Boolean;
begin
  Result := ((Low2 > MinInteger)  and (High1 = Low2 - 1)) or
            ((High2 < MaxInteger) and (Low1 = High2 + 1));
end;

function IntRangeOverlap(const Low1, High1, Low2, High2: Integer): Boolean;
begin
  Result := ((Low1 >= Low2) and (Low1 <= High2)) or
            ((Low2 >= Low1) and (Low2 <= High1));
end;

function IntRangeHasElement(const Low, High, Element: Integer): Boolean;
begin
  Result := (Element >= Low) and (Element <= High);
end;

function IntRangeIncludeElement(var Low, High: Integer;
    const Element: Integer): Boolean;
begin
  Result := (Element >= Low) and (Element <= High);
  if Result then
    exit;
  if (Element < Low) and (Element + 1 = Low) then
    begin
      Low := Element;
      Result := True;
    end else
  if (Element > High) and (Element - 1 = High) then
    begin
      High := Element;
      Result := True;
    end;
end;

function IntRangeIncludeElementRange(var Low, High: Integer;
    const LowElement, HighElement: Integer): Boolean;
begin
  Result := (LowElement >= Low) and (HighElement <= High);
  if Result then
    exit;
  if ((Low >= LowElement) and (Low <= HighElement)) or
     ((Low > MinInteger) and (Low - 1 = HighElement)) then
    begin
      Low := LowElement;
      Result := True;
    end;
  if ((High >= LowElement) and (High <= HighElement)) or
     ((High < MaxInteger) and (High + 1 = LowElement)) then
    begin
      High := HighElement;
      Result := True;
    end;
end;

function CardRangeLength(const Low, High: Cardinal): Int64;
begin
  if Low > High then
    Result := 0
  else
    Result := Int64(High - Low) + 1;
end;

function CardRangeAdjacent(const Low1, High1, Low2, High2: Cardinal): Boolean;
begin
  Result := ((Low2 > MinCardinal)  and (High1 = Low2 - 1)) or
            ((High2 < MaxCardinal) and (Low1 = High2 + 1));
end;

function CardRangeOverlap(const Low1, High1, Low2, High2: Cardinal): Boolean;
begin
  Result := ((Low1 >= Low2) and (Low1 <= High2)) or
            ((Low2 >= Low1) and (Low2 <= High1));
end;

function CardRangeHasElement(const Low, High, Element: Cardinal): Boolean;
begin
  Result := (Element >= Low) and (Element <= High);
end;

function CardRangeIncludeElement(var Low, High: Cardinal;
    const Element: Cardinal): Boolean;
begin
  Result := (Element >= Low) and (Element <= High);
  if Result then
    exit;
  if (Element < Low) and (Element + 1 = Low) then
    begin
      Low := Element;
      Result := True;
    end else
  if (Element > High) and (Element - 1 = High) then
    begin
      High := Element;
      Result := True;
    end;
end;

function CardRangeIncludeElementRange(var Low, High: Cardinal;
    const LowElement, HighElement: Cardinal): Boolean;
begin
  Result := (LowElement >= Low) and (HighElement <= High);
  if Result then
    exit;
  if ((Low >= LowElement) and (Low <= HighElement)) or
     ((Low > MinCardinal) and (Low - 1 = HighElement)) then
    begin
      Low := LowElement;
      Result := True;
    end;
  if ((High >= LowElement) and (High <= HighElement)) or
     ((High < MaxCardinal) and (High + 1 = LowElement)) then
    begin
      High := HighElement;
      Result := True;
    end;
end;



{                                                                              }
{ Swap                                                                         }
{                                                                              }
{$IFDEF ASM386_DELPHI}
procedure Swap(var X, Y: Boolean); register; assembler;
asm
      MOV     CL, [EDX]
      XCHG    BYTE PTR [EAX], CL
      MOV     [EDX], CL
end;
{$ELSE}
procedure Swap(var X, Y: Boolean);
var F : Boolean;
begin
  F := X;
  X := Y;
  Y := F;
end;
{$ENDIF}

{$IFDEF ASM386_DELPHI}
procedure Swap(var X, Y: Byte); register; assembler;
asm
      MOV     CL, [EDX]
      XCHG    BYTE PTR [EAX], CL
      MOV     [EDX], CL
end;
{$ELSE}
procedure Swap(var X, Y: Byte);
var F : Byte;
begin
  F := X;
  X := Y;
  Y := F;
end;
{$ENDIF}

{$IFDEF ASM386_DELPHI}
procedure Swap(var X, Y: ShortInt); register; assembler;
asm
      MOV     CL, [EDX]
      XCHG    BYTE PTR [EAX], CL
      MOV     [EDX], CL
end;
{$ELSE}
procedure Swap(var X, Y: ShortInt);
var F : ShortInt;
begin
  F := X;
  X := Y;
  Y := F;
end;
{$ENDIF}

{$IFDEF ASM386_DELPHI}
procedure Swap(var X, Y: Word); register; assembler;
asm
      MOV     CX, [EDX]
      XCHG    WORD PTR [EAX], CX
      MOV     [EDX], CX
end;
{$ELSE}
procedure Swap(var X, Y: Word);
var F : Word;
begin
  F := X;
  X := Y;
  Y := F;
end;
{$ENDIF}

{$IFDEF ASM386_DELPHI}
procedure Swap(var X, Y: SmallInt); register; assembler;
asm
      MOV     CX, [EDX]
      XCHG    WORD PTR [EAX], CX
      MOV     [EDX], CX
end;
{$ELSE}
procedure Swap(var X, Y: SmallInt);
var F : SmallInt;
begin
  F := X;
  X := Y;
  Y := F;
end;
{$ENDIF}

{$IFDEF ASM386_DELPHI}
procedure Swap(var X, Y: LongInt); register; assembler;
asm
      MOV     ECX, [EDX]
      XCHG    [EAX], ECX
      MOV     [EDX], ECX
end;
{$ELSE}
procedure Swap(var X, Y: LongInt);
var F : LongInt;
begin
  F := X;
  X := Y;
  Y := F;
end;
{$ENDIF}

{$IFDEF ASM386_DELPHI}
procedure Swap(var X, Y: LongWord); register; assembler;
asm
      MOV     ECX, [EDX]
      XCHG    [EAX], ECX
      MOV     [EDX], ECX
end;
{$ELSE}
procedure Swap(var X, Y: LongWord);
var F : LongWord;
begin
  F := X;
  X := Y;
  Y := F;
end;
{$ENDIF}

procedure Swap(var X, Y: NativeUInt);
var F : NativeUInt;
begin
  F := X;
  X := Y;
  Y := F;
end;

procedure Swap(var X, Y: NativeInt);
var F : NativeInt;
begin
  F := X;
  X := Y;
  Y := F;
end;

{$IFNDEF ManagedCode}
{$IFDEF ASM386_DELPHI}
procedure Swap(var X, Y: Pointer); register; assembler;
asm
      MOV     ECX, [EDX]
      XCHG    [EAX], ECX
      MOV     [EDX], ECX
end;
{$ELSE}
procedure Swap(var X, Y: Pointer);
var F : Pointer;
begin
  F := X;
  X := Y;
  Y := F;
end;
{$ENDIF}

{$ENDIF}
{$IFDEF ASM386_DELPHI}
procedure Swap(var X, Y: TObject); register; assembler;
asm
      MOV     ECX, [EDX]
      XCHG    [EAX], ECX
      MOV     [EDX], ECX
end;
{$ELSE}
procedure Swap(var X, Y: TObject);
var F : TObject;
begin
  F := X;
  X := Y;
  Y := F;
end;
{$ENDIF}

procedure Swap(var X, Y: Int64);
var F : Int64;
begin
  F := X;
  X := Y;
  Y := F;
end;

procedure Swap(var X, Y: Single);
var F : Single;
begin
  F := X;
  X := Y;
  Y := F;
end;

procedure Swap(var X, Y: Double);
var F : Double;
begin
  F := X;
  X := Y;
  Y := F;
end;

procedure Swap(var X, Y: Extended);
var F : Extended;
begin
  F := X;
  X := Y;
  Y := F;
end;

procedure Swap(var X, Y: Currency);
var F : Currency;
begin
  F := X;
  X := Y;
  Y := F;
end;

procedure SwapA(var X, Y: AnsiString);
var F : AnsiString;
begin
  F := X;
  X := Y;
  Y := F;
end;

procedure SwapB(var X, Y: RawByteString);
var F : RawByteString;
begin
  F := X;
  X := Y;
  Y := F;
end;

procedure SwapW(var X, Y: WideString);
var F : WideString;
begin
  F := X;
  X := Y;
  Y := F;
end;

procedure SwapU(var X, Y: UnicodeString);
var F : UnicodeString;
begin
  F := X;
  X := Y;
  Y := F;
end;

procedure Swap(var X, Y: String);
var F : String;
begin
  F := X;
  X := Y;
  Y := F;
end;

{$IFDEF ManagedCode}
procedure SwapObjects(var X, Y: TObject);
var F: TObject;
begin
  F := X;
  X := Y;
  Y := F;
end;
{$ELSE}
{$IFDEF ASM386_DELPHI}
procedure SwapObjects(var X, Y); register; assembler;
asm
      MOV     ECX, [EDX]
      XCHG    [EAX], ECX
      MOV     [EDX], ECX
end;
{$ELSE}
procedure SwapObjects(var X, Y);
var F: TObject;
begin
  F := TObject(X);
  TObject(X) := TObject(Y);
  TObject(Y) := F;
end;
{$ENDIF}{$ENDIF}



{                                                                              }
{ iif                                                                          }
{                                                                              }
function iif(const Expr: Boolean; const TrueValue, FalseValue: Integer): Integer;
begin
  if Expr then
    Result := TrueValue
  else
    Result := FalseValue;
end;

function iif(const Expr: Boolean; const TrueValue, FalseValue: Int64): Int64;
begin
  if Expr then
    Result := TrueValue
  else
    Result := FalseValue;
end;

function iif(const Expr: Boolean; const TrueValue, FalseValue: Extended): Extended;
begin
  if Expr then
    Result := TrueValue
  else
    Result := FalseValue;
end;

function iif(const Expr: Boolean; const TrueValue, FalseValue: String): String;
begin
  if Expr then
    Result := TrueValue
  else
    Result := FalseValue;
end;

function iifA(const Expr: Boolean; const TrueValue, FalseValue: AnsiString): AnsiString;
begin
  if Expr then
    Result := TrueValue
  else
    Result := FalseValue;
end;

function iifB(const Expr: Boolean; const TrueValue, FalseValue: RawByteString): RawByteString;
begin
  if Expr then
    Result := TrueValue
  else
    Result := FalseValue;
end;

function iifW(const Expr: Boolean; const TrueValue, FalseValue: WideString): WideString;
begin
  if Expr then
    Result := TrueValue
  else
    Result := FalseValue;
end;

function iifU(const Expr: Boolean; const TrueValue, FalseValue: UnicodeString): UnicodeString;
begin
  if Expr then
    Result := TrueValue
  else
    Result := FalseValue;
end;

function iif(const Expr: Boolean; const TrueValue, FalseValue: TObject): TObject;
begin
  if Expr then
    Result := TrueValue
  else
    Result := FalseValue;
end;




{                                                                              }
{ Compare                                                                      }
{                                                                              }
function ReverseCompareResult(const C: TCompareResult): TCompareResult;
begin
  if C = crLess then
    Result := crGreater else
  if C = crGreater then
    Result := crLess
  else
    Result := C;
end;

function Compare(const I1, I2: Integer): TCompareResult;
begin
  if I1 < I2 then
    Result := crLess else
  if I1 > I2 then
    Result := crGreater
  else
    Result := crEqual;
end;

function Compare(const I1, I2: Int64): TCompareResult;
begin
  if I1 < I2 then
    Result := crLess else
  if I1 > I2 then
    Result := crGreater
  else
    Result := crEqual;
end;

function Compare(const I1, I2: Extended): TCompareResult;
begin
  if I1 < I2 then
    Result := crLess else
  if I1 > I2 then
    Result := crGreater
  else
    Result := crEqual;
end;

function Compare(const I1, I2: Boolean): TCompareResult;
begin
  if I1 = I2 then
    Result := crEqual else
  if I1 then
    Result := crGreater
  else
    Result := crLess;
end;

function CompareA(const I1, I2: AnsiString): TCompareResult;
begin
  if I1 = I2 then
    Result := crEqual else
  if I1 > I2 then
    Result := crGreater
  else
    Result := crLess;
end;

function CompareB(const I1, I2: RawByteString): TCompareResult;
begin
  if I1 = I2 then
    Result := crEqual else
  if I1 > I2 then
    Result := crGreater
  else
    Result := crLess;
end;

function CompareW(const I1, I2: WideString): TCompareResult;
begin
  if I1 = I2 then
    Result := crEqual else
  if I1 > I2 then
    Result := crGreater
  else
    Result := crLess;
end;

function CompareU(const I1, I2: UnicodeString): TCompareResult;
begin
  if I1 = I2 then
    Result := crEqual else
  if I1 > I2 then
    Result := crGreater
  else
    Result := crLess;
end;

function CompareChA(const I1, I2: AnsiChar): TCompareResult;
begin
  if I1 = I2 then
    Result := crEqual else
  if I1 > I2 then
    Result := crGreater
  else
    Result := crLess;
end;

function CompareChW(const I1, I2: WideChar): TCompareResult;
begin
  if I1 = I2 then
    Result := crEqual else
  if I1 > I2 then
    Result := crGreater
  else
    Result := crLess;
end;

function Sgn(const A: LongInt): Integer;
begin
  if A < 0 then
    Result := -1 else
  if A > 0 then
    Result := 1
  else
    Result := 0;
end;

function Sgn(const A: Int64): Integer;
begin
  if A < 0 then
    Result := -1 else
  if A > 0 then
    Result := 1
  else
    Result := 0;
end;

function Sgn(const A: Extended): Integer;
begin
  if A < 0 then
    Result := -1 else
  if A > 0 then
    Result := 1
  else
    Result := 0;
end;



{                                                                              }
{ Ascii char conversion lookup                                                 }
{                                                                              }
const
  HexLookup: array[AnsiChar] of Byte = (
      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF,
      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF,
      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF,
      0,   1,   2,   3,   4,   5,   6,   7,   8,   9,   $FF, $FF, $FF, $FF, $FF, $FF,
      $FF, 10,  11,  12,  13,  14,  15,  $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF,
      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF,
      $FF, 10,  11,  12,  13,  14,  15,  $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF,
      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF,
      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF,
      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF,
      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF,
      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF,
      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF,
      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF,
      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF,
      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF);



{                                                                              }
{ Integer-String conversions                                                   }
{                                                                              }
function AnsiCharToInt(const A: AnsiChar): Integer;
begin
  if A in ['0'..'9'] then
    Result := Ord(A) - Ord('0')
  else
    Result := -1;
end;

function WideCharToInt(const A: WideChar): Integer;
begin
  if (Ord(A) >= Ord('0')) and (Ord(A) <= Ord('9')) then
    Result := Ord(A) - Ord('0')
  else
    Result := -1;
end;

function CharToInt(const A: Char): Integer;
begin
  {$IFDEF CharIsWide}
  Result := WideCharToInt(A);
  {$ELSE}
  Result := AnsiCharToInt(A);
  {$ENDIF}
end;

function IntToAnsiChar(const A: Integer): AnsiChar;
begin
  if (A < 0) or (A > 9) then
    Result := #$00
  else
    Result := AnsiChar(48 + A);
end;

function IntToWideChar(const A: Integer): WideChar;
begin
  if (A < 0) or (A > 9) then
    Result := #$00
  else
    Result := WideChar(48 + A);
end;

function IntToChar(const A: Integer): Char;
begin
  {$IFDEF CharIsWide}
  Result := IntToWideChar(A);
  {$ELSE}
  Result := IntToAnsiChar(A);
  {$ENDIF}
end;

function IsHexAnsiChar(const Ch: AnsiChar): Boolean;
begin
  Result := HexLookup[Ch] <= 15;
end;

function IsHexWideChar(const Ch: WideChar): Boolean;
begin
  if Ord(Ch) <= $FF then
    Result := HexLookup[AnsiChar(Ch)] <= 15
  else
    Result := False;
end;

function IsHexChar(const Ch: Char): Boolean;
begin
  {$IFDEF CharIsWide}
  Result := IsHexWideChar(Ch);
  {$ELSE}
  Result := IsHexAnsiChar(Ch);
  {$ENDIF}
end;

function HexAnsiCharToInt(const A: AnsiChar): Integer;
var B : Byte;
begin
  B := HexLookup[A];
  if B = $FF then
    Result := -1
  else
    Result := B;
end;

function HexWideCharToInt(const A: WideChar): Integer;
var B : Byte;
begin
  if Ord(A) > $FF then
    Result := -1
  else
    begin
      B := HexLookup[AnsiChar(Ord(A))];
      if B = $FF then
        Result := -1
      else
        Result := B;
    end;
end;

function HexCharToInt(const A: Char): Integer;
begin
  {$IFDEF CharIsWide}
  Result := HexWideCharToInt(A);
  {$ELSE}
  Result := HexAnsiCharToInt(A);
  {$ENDIF}
end;

function IntToUpperHexAnsiChar(const A: Integer): AnsiChar;
begin
  if (A < 0) or (A > 15) then
    Result := #$00
  else
  if A <= 9 then
    Result := AnsiChar(48 + A)
  else
    Result := AnsiChar(55 + A);
end;

function IntToUpperHexWideChar(const A: Integer): WideChar;
begin
  if (A < 0) or (A > 15) then
    Result := #$00
  else
  if A <= 9 then
    Result := WideChar(48 + A)
  else
    Result := WideChar(55 + A);
end;

function IntToUpperHexChar(const A: Integer): Char;
begin
  {$IFDEF CharIsWide}
  Result := IntToUpperHexWideChar(A);
  {$ELSE}
  Result := IntToUpperHexAnsiChar(A);
  {$ENDIF}
end;

function IntToLowerHexAnsiChar(const A: Integer): AnsiChar;
begin
  if (A < 0) or (A > 15) then
    Result := #$00
  else
  if A <= 9 then
    Result := AnsiChar(48 + A)
  else
    Result := AnsiChar(87 + A);
end;

function IntToLowerHexWideChar(const A: Integer): WideChar;
begin
  if (A < 0) or (A > 15) then
    Result := #$00
  else
  if A <= 9 then
    Result := WideChar(48 + A)
  else
    Result := WideChar(87 + A);
end;

function IntToLowerHexChar(const A: Integer): Char;
begin
  {$IFDEF CharIsWide}
  Result := IntToLowerHexWideChar(A);
  {$ELSE}
  Result := IntToLowerHexAnsiChar(A);
  {$ENDIF}
end;

function IntToStringA(const A: Int64): AnsiString;
var T : Int64;
    L, I : Integer;
begin
  // special cases
  if A = 0 then
    begin
      Result := '0';
      exit;
    end;
  if A = MinInt64 then
    begin
      Result := '-9223372036854775808';
      exit;
    end;
  // calculate string length
  if A < 0 then
    L := 1
  else
    L := 0;
  T := A;
  while T <> 0 do
    begin
      T := T div 10;
      Inc(L);
    end;
  // convert
  SetLength(Result, L);
  I := 0;
  T := A;
  if T < 0 then
    begin
      Result[1] := '-';
      T := -T;
    end;
  while T > 0 do
    begin
      Result[L - I] := IntToAnsiChar(T mod 10);
      T := T div 10;
      Inc(I);
    end;
end;

function IntToStringB(const A: Int64): RawByteString;
var T : Int64;
    L, I : Integer;
begin
  // special cases
  if A = 0 then
    begin
      Result := '0';
      exit;
    end;
  if A = MinInt64 then
    begin
      Result := '-9223372036854775808';
      exit;
    end;
  // calculate string length
  if A < 0 then
    L := 1
  else
    L := 0;
  T := A;
  while T <> 0 do
    begin
      T := T div 10;
      Inc(L);
    end;
  // convert
  SetLength(Result, L);
  I := 0;
  T := A;
  if T < 0 then
    begin
      Result[1] := '-';
      T := -T;
    end;
  while T > 0 do
    begin
      Result[L - I] := IntToAnsiChar(T mod 10);
      T := T div 10;
      Inc(I);
    end;
end;

function IntToStringW(const A: Int64): WideString;
var T : Int64;
    L, I : Integer;
begin
  // special cases
  if A = 0 then
    begin
      Result := '0';
      exit;
    end;
  if A = MinInt64 then
    begin
      Result := '-9223372036854775808';
      exit;
    end;
  // calculate string length
  if A < 0 then
    L := 1
  else
    L := 0;
  T := A;
  while T <> 0 do
    begin
      T := T div 10;
      Inc(L);
    end;
  // convert
  SetLength(Result, L);
  I := 0;
  T := A;
  if T < 0 then
    begin
      Result[1] := '-';
      T := -T;
    end;
  while T > 0 do
    begin
      Result[L - I] := IntToWideChar(T mod 10);
      T := T div 10;
      Inc(I);
    end;
end;

function IntToStringU(const A: Int64): UnicodeString;
var L, T, I : Integer;
begin
  // special cases
  if A = 0 then
    begin
      Result := '0';
      exit;
    end;
  if A = MinInt64 then
    begin
      Result := '-9223372036854775808';
      exit;
    end;
  // calculate string length
  if A < 0 then
    L := 1
  else
    L := 0;
  T := A;
  while T <> 0 do
    begin
      T := T div 10;
      Inc(L);
    end;
  // convert
  SetLength(Result, L);
  I := 0;
  T := A;
  if T < 0 then
    begin
      Result[1] := '-';
      T := -T;
    end;
  while T > 0 do
    begin
      Result[L - I] := IntToWideChar(T mod 10);
      T := T div 10;
      Inc(I);
    end;
end;

function IntToString(const A: Int64): String;
var T : Int64;
    L, I : Integer;
begin
  // special cases
  if A = 0 then
    begin
      Result := '0';
      exit;
    end;
  if A = MinInt64 then
    begin
      Result := '-9223372036854775808';
      exit;
    end;
  // calculate string length
  if A < 0 then
    L := 1
  else
    L := 0;
  T := A;
  while T <> 0 do
    begin
      T := T div 10;
      Inc(L);
    end;
  // convert
  SetLength(Result, L);
  I := 0;
  T := A;
  if T < 0 then
    begin
      Result[1] := '-';
      T := -T;
    end;
  while T > 0 do
    begin
      Result[L - I] := IntToChar(T mod 10);
      T := T div 10;
      Inc(I);
    end;
end;

function NativeUIntToBaseA(
         const Value: NativeUInt;
         const Digits: Integer;
         const Base: Byte;
         const UpperCase: Boolean = True): AnsiString;
var D : NativeUInt;
    L : Integer;
    V : Byte;
begin
  Assert((Base >= 2) and (Base <= 16));
  if Value = 0 then // handle zero value
    begin
      if Digits = 0 then
        L := 1
      else
        L := Digits;
      SetLength(Result, L);
      for V := 1 to L do
        Result[V] := '0';
      exit;
    end;
  // determine number of digits in result
  L := 0;
  D := Value;
  while D > 0 do
    begin
      Inc(L);
      D := D div Base;
    end;
  if L < Digits then
    L := Digits;
  // do conversion
  SetLength(Result, L);
  D := Value;
  while D > 0 do
    begin
      V := D mod Base + 1;
      if UpperCase then
        Result[L] := AnsiChar(StrHexDigitsUpper[V])
      else
        Result[L] := AnsiChar(StrHexDigitsLower[V]);
      Dec(L);
      D := D div Base;
    end;
  while L > 0 do
    begin
      Result[L] := '0';
      Dec(L);
    end;
end;

function NativeUIntToBaseB(
         const Value: NativeUInt;
         const Digits: Integer;
         const Base: Byte;
         const UpperCase: Boolean = True): RawByteString;
var D : NativeUInt;
    L : Integer;
    V : Byte;
begin
  Assert((Base >= 2) and (Base <= 16));
  if Value = 0 then // handle zero value
    begin
      if Digits = 0 then
        L := 1
      else
        L := Digits;
      SetLength(Result, L);
      for V := 1 to L do
        Result[V] := '0';
      exit;
    end;
  // determine number of digits in result
  L := 0;
  D := Value;
  while D > 0 do
    begin
      Inc(L);
      D := D div Base;
    end;
  if L < Digits then
    L := Digits;
  // do conversion
  SetLength(Result, L);
  D := Value;
  while D > 0 do
    begin
      V := D mod Base + 1;
      if UpperCase then
        Result[L] := AnsiChar(StrHexDigitsUpper[V])
      else
        Result[L] := AnsiChar(StrHexDigitsLower[V]);
      Dec(L);
      D := D div Base;
    end;
  while L > 0 do
    begin
      Result[L] := '0';
      Dec(L);
    end;
end;

function NativeUIntToBaseW(
         const Value: NativeUInt;
         const Digits: Integer;
         const Base: Byte;
         const UpperCase: Boolean = True): WideString;
var D : NativeUInt;
    L : Integer;
    V : Byte;
begin
  Assert((Base >= 2) and (Base <= 16));
  if Value = 0 then // handle zero value
    begin
      if Digits = 0 then
        L := 1
      else
        L := Digits;
      SetLength(Result, L);
      for V := 1 to L do
        Result[V] := '0';
      exit;
    end;
  // determine number of digits in result
  L := 0;
  D := Value;
  while D > 0 do
    begin
      Inc(L);
      D := D div Base;
    end;
  if L < Digits then
    L := Digits;
  // do conversion
  SetLength(Result, L);
  D := Value;
  while D > 0 do
    begin
      V := D mod Base + 1;
      if UpperCase then
        Result[L] := WideChar(StrHexDigitsUpper[V])
      else
        Result[L] := WideChar(StrHexDigitsLower[V]);
      Dec(L);
      D := D div Base;
    end;
  while L > 0 do
    begin
      Result[L] := '0';
      Dec(L);
    end;
end;

function NativeUIntToBaseU(
         const Value: NativeUInt;
         const Digits: Integer;
         const Base: Byte;
         const UpperCase: Boolean = True): UnicodeString;
var D : NativeUInt;
    L : Integer;
    V : Byte;
begin
  Assert((Base >= 2) and (Base <= 16));
  if Value = 0 then // handle zero value
    begin
      if Digits = 0 then
        L := 1
      else
        L := Digits;
      SetLength(Result, L);
      for V := 1 to L do
        Result[V] := '0';
      exit;
    end;
  // determine number of digits in result
  L := 0;
  D := Value;
  while D > 0 do
    begin
      Inc(L);
      D := D div Base;
    end;
  if L < Digits then
    L := Digits;
  // do conversion
  SetLength(Result, L);
  D := Value;
  while D > 0 do
    begin
      V := D mod Base + 1;
      if UpperCase then
        Result[L] := WideChar(StrHexDigitsUpper[V])
      else
        Result[L] := WideChar(StrHexDigitsLower[V]);
      Dec(L);
      D := D div Base;
    end;
  while L > 0 do
    begin
      Result[L] := '0';
      Dec(L);
    end;
end;

function NativeUIntToBase(
         const Value: NativeUInt;
         const Digits: Integer;
         const Base: Byte;
         const UpperCase: Boolean = True): String;
var D : NativeUInt;
    L : Integer;
    V : Byte;
begin
  Assert((Base >= 2) and (Base <= 16));
  if Value = 0 then // handle zero value
    begin
      if Digits = 0 then
        L := 1
      else
        L := Digits;
      SetLength(Result, L);
      for V := 1 to L do
        Result[V] := '0';
      exit;
    end;
  // determine number of digits in result
  L := 0;
  D := Value;
  while D > 0 do
    begin
      Inc(L);
      D := D div Base;
    end;
  if L < Digits then
    L := Digits;
  // do conversion
  SetLength(Result, L);
  D := Value;
  while D > 0 do
    begin
      V := D mod Base + 1;
      if UpperCase then
        Result[L] := Char(StrHexDigitsUpper[V])
      else
        Result[L] := Char(StrHexDigitsLower[V]);
      Dec(L);
      D := D div Base;
    end;
  while L > 0 do
    begin
      Result[L] := '0';
      Dec(L);
    end;
end;

function UIntToStringA(const A: NativeUInt): AnsiString;
begin
  Result := NativeUIntToBaseA(A, 0, 10);
end;

function UIntToStringB(const A: NativeUInt): RawByteString;
begin
  Result := NativeUIntToBaseB(A, 0, 10);
end;

function UIntToStringW(const A: NativeUInt): WideString;
begin
  Result := NativeUIntToBaseW(A, 0, 10);
end;

function UIntToStringU(const A: NativeUInt): UnicodeString;
begin
  Result := NativeUIntToBaseU(A, 0, 10);
end;

function UIntToString(const A: NativeUInt): String;
begin
  Result := NativeUIntToBase(A, 0, 10);
end;

function LongWordToStrA(const A: LongWord; const Digits: Integer): AnsiString;
begin
  Result := NativeUIntToBaseA(A, Digits, 10);
end;

function LongWordToStrB(const A: LongWord; const Digits: Integer): RawByteString;
begin
  Result := NativeUIntToBaseB(A, Digits, 10);
end;

function LongWordToStrW(const A: LongWord; const Digits: Integer): WideString;
begin
  Result := NativeUIntToBaseW(A, Digits, 10);
end;

function LongWordToStrU(const A: LongWord; const Digits: Integer): UnicodeString;
begin
  Result := NativeUIntToBaseU(A, Digits, 10);
end;

function LongWordToStr(const A: LongWord; const Digits: Integer): String;
begin
  Result := NativeUIntToBase(A, Digits, 10);
end;

function LongWordToHexA(const A: LongWord; const Digits: Integer; const UpperCase: Boolean): AnsiString;
begin
  Result := NativeUIntToBaseA(A, Digits, 16, UpperCase);
end;

function LongWordToHexB(const A: LongWord; const Digits: Integer; const UpperCase: Boolean): RawByteString;
begin
  Result := NativeUIntToBaseB(A, Digits, 16, UpperCase);
end;

function LongWordToHexW(const A: LongWord; const Digits: Integer; const UpperCase: Boolean): WideString;
begin
  Result := NativeUIntToBaseW(A, Digits, 16, UpperCase);
end;

function LongWordToHexU(const A: LongWord; const Digits: Integer; const UpperCase: Boolean): UnicodeString;
begin
  Result := NativeUIntToBaseU(A, Digits, 16, UpperCase);
end;

function LongWordToHex(const A: LongWord; const Digits: Integer; const UpperCase: Boolean): String;
begin
  Result := NativeUIntToBase(A, Digits, 16, UpperCase);
end;

function LongWordToOctA(const A: LongWord; const Digits: Integer): AnsiString;
begin
  Result := NativeUIntToBaseA(A, Digits, 8);
end;

function LongWordToOctB(const A: LongWord; const Digits: Integer): RawByteString;
begin
  Result := NativeUIntToBaseB(A, Digits, 8);
end;

function LongWordToOctW(const A: LongWord; const Digits: Integer): WideString;
begin
  Result := NativeUIntToBaseW(A, Digits, 8);
end;

function LongWordToOctU(const A: LongWord; const Digits: Integer): UnicodeString;
begin
  Result := NativeUIntToBaseU(A, Digits, 8);
end;

function LongWordToOct(const A: LongWord; const Digits: Integer): String;
begin
  Result := NativeUIntToBase(A, Digits, 8);
end;

function LongWordToBinA(const A: LongWord; const Digits: Integer): AnsiString;
begin
  Result := NativeUIntToBaseA(A, Digits, 2);
end;

function LongWordToBinB(const A: LongWord; const Digits: Integer): RawByteString;
begin
  Result := NativeUIntToBaseB(A, Digits, 2);
end;

function LongWordToBinW(const A: LongWord; const Digits: Integer): WideString;
begin
  Result := NativeUIntToBaseW(A, Digits, 2);
end;

function LongWordToBinU(const A: LongWord; const Digits: Integer): UnicodeString;
begin
  Result := NativeUIntToBaseU(A, Digits, 2);
end;

function LongWordToBin(const A: LongWord; const Digits: Integer): String;
begin
  Result := NativeUIntToBase(A, Digits, 2);
end;

function TryStringToInt64PA(const BufP: Pointer; const BufLen: Integer; out Value: Int64; out StrLen: Integer): TConvertResult;
var Len : Integer;
    DigVal : Integer;
    P : PAnsiChar;
    Ch : AnsiChar;
    HasDig : Boolean;
    Neg : Boolean;
    Res : Int64;
begin
  if BufLen <= 0 then
    begin
      Value := 0;
      StrLen := 0;
      Result := convertFormatError;
      exit;
    end;
  P := BufP;
  Len := 0;
  // check sign
  Ch := P^;
  if Ch in ['+', '-'] then
    begin
      Inc(Len);
      Inc(P);
      Neg := Ch = '-';
    end
  else
    Neg := False;
  // skip leading zeros
  HasDig := False;
  while (Len < BufLen) and (P^ = '0') do
    begin
      Inc(Len);
      Inc(P);
      HasDig := True;
    end;
  // convert digits
  Res := 0;
  while Len < BufLen do
    begin
      Ch := P^;
      if Ch in ['0'..'9'] then
        begin
          HasDig := True;
          if (Res > 922337203685477580) or
             (Res < -922337203685477580) then
            begin
              Value := 0;
              StrLen := Len;
              Result := convertOverflow;
              exit;
            end;
          {$IFOPT Q+}{$DEFINE QOn}{$Q-}{$ELSE}{$UNDEF QOn}{$ENDIF} // overflowing for -922337203685477580 * 10 ?
          Res := Res * 10;
          {$IFDEF QOn}{$Q+}{$ENDIF}
          DigVal := AnsiCharToInt(Ch);
          if ((Res = 9223372036854775800) and (DigVal > 7)) or
             ((Res = -9223372036854775800) and (DigVal > 8)) then
            begin
              Value := 0;
              StrLen := Len;
              Result := convertOverflow;
              exit;
            end;
          if Neg then
            Dec(Res, DigVal)
          else
            Inc(Res, DigVal);
          Inc(Len);
          Inc(P);
        end
      else
        break;
    end;
  StrLen := Len;
  if not HasDig then
    begin
      Value := 0;
      Result := convertFormatError;
    end
  else
    begin
      Value := Res;
      Result := convertOK;
    end;
end;

function TryStringToInt64PW(const BufP: Pointer; const BufLen: Integer; out Value: Int64; out StrLen: Integer): TConvertResult;
var Len : Integer;
    DigVal : Integer;
    P : PWideChar;
    Ch : WideChar;
    HasDig : Boolean;
    Neg : Boolean;
    Res : Int64;
begin
  if BufLen <= 0 then
    begin
      Value := 0;
      StrLen := 0;
      Result := convertFormatError;
      exit;
    end;
  P := BufP;
  Len := 0;
  // check sign
  Ch := P^;
  if (Ch = '+') or (Ch = '-') then
    begin
      Inc(Len);
      Inc(P);
      Neg := Ch = '-';
    end
  else
    Neg := False;
  // skip leading zeros
  HasDig := False;
  while (Len < BufLen) and (P^ = '0') do
    begin
      Inc(Len);
      Inc(P);
      HasDig := True;
    end;
  // convert digits
  Res := 0;
  while Len < BufLen do
    begin
      Ch := P^;
      if (Ch >= '0') and (Ch <= '9') then
        begin
          HasDig := True;
          if (Res > 922337203685477580) or
             (Res < -922337203685477580) then
            begin
              Value := 0;
              StrLen := Len;
              Result := convertOverflow;
              exit;
            end;
          {$IFOPT Q+}{$DEFINE QOn}{$Q-}{$ELSE}{$UNDEF QOn}{$ENDIF} // overflowing for -922337203685477580 * 10 ?
          Res := Res * 10;
          {$IFDEF QOn}{$Q+}{$ENDIF}
          DigVal := WideCharToInt(Ch);
          if ((Res = 9223372036854775800) and (DigVal > 7)) or
             ((Res = -9223372036854775800) and (DigVal > 8)) then
            begin
              Value := 0;
              StrLen := Len;
              Result := convertOverflow;
              exit;
            end;
          if Neg then
            Dec(Res, DigVal)
          else
            Inc(Res, DigVal);
          Inc(Len);
          Inc(P);
        end
      else
        break;
    end;
  StrLen := Len;
  if not HasDig then
    begin
      Value := 0;
      Result := convertFormatError;
    end
  else
    begin
      Value := Res;
      Result := convertOK;
    end;
end;

function TryStringToInt64P(const BufP: Pointer; const BufLen: Integer; out Value: Int64; out StrLen: Integer): TConvertResult;
var Len : Integer;
    DigVal : Integer;
    P : PChar;
    Ch : Char;
    HasDig : Boolean;
    Neg : Boolean;
    Res : Int64;
begin
  if BufLen <= 0 then
    begin
      Value := 0;
      StrLen := 0;
      Result := convertFormatError;
      exit;
    end;
  P := BufP;
  Len := 0;
  // check sign
  Ch := P^;
  if (Ch = '+') or (Ch = '-') then
    begin
      Inc(Len);
      Inc(P);
      Neg := Ch = '-';
    end
  else
    Neg := False;
  // skip leading zeros
  HasDig := False;
  while (Len < BufLen) and (P^ = '0') do
    begin
      Inc(Len);
      Inc(P);
      HasDig := True;
    end;
  // convert digits
  Res := 0;
  while Len < BufLen do
    begin
      Ch := P^;
      if (Ch >= '0') and (Ch <= '9') then
        begin
          HasDig := True;
          if (Res > 922337203685477580) or
             (Res < -922337203685477580) then
            begin
              Value := 0;
              StrLen := Len;
              Result := convertOverflow;
              exit;
            end;
          {$IFOPT Q+}{$DEFINE QOn}{$Q-}{$ELSE}{$UNDEF QOn}{$ENDIF} // overflowing for -922337203685477580 * 10 ?
          Res := Res * 10;
          {$IFDEF QOn}{$Q+}{$ENDIF}
          DigVal := CharToInt(Ch);
          if ((Res = 9223372036854775800) and (DigVal > 7)) or
             ((Res = -9223372036854775800) and (DigVal > 8)) then
            begin
              Value := 0;
              StrLen := Len;
              Result := convertOverflow;
              exit;
            end;
          if Neg then
            Dec(Res, DigVal)
          else
            Inc(Res, DigVal);
          Inc(Len);
          Inc(P);
        end
      else
        break;
    end;
  StrLen := Len;
  if not HasDig then
    begin
      Value := 0;
      Result := convertFormatError;
    end
  else
    begin
      Value := Res;
      Result := convertOK;
    end;
end;

function TryStringToInt64A(const S: AnsiString; out A: Int64): Boolean;
var L, N : Integer;
begin
  L := Length(S);
  Result := TryStringToInt64PA(PAnsiChar(S), L, A, N) = convertOK;
  if Result then
    if N < L then
      Result := False;
end;

function TryStringToInt64B(const S: RawByteString; out A: Int64): Boolean;
var L, N : Integer;
begin
  L := Length(S);
  Result := TryStringToInt64PA(PAnsiChar(S), L, A, N) = convertOK;
  if Result then
    if N < L then
      Result := False;
end;

function TryStringToInt64W(const S: WideString; out A: Int64): Boolean;
var L, N : Integer;
begin
  L := Length(S);
  Result := TryStringToInt64PW(PWideChar(S), L, A, N) = convertOK;
  if Result then
    if N < L then
      Result := False;
end;

function TryStringToInt64U(const S: UnicodeString; out A: Int64): Boolean;
var L, N : Integer;
begin
  L := Length(S);
  Result := TryStringToInt64PW(PWideChar(S), L, A, N) = convertOK;
  if Result then
    if N < L then
      Result := False;
end;

function TryStringToInt64(const S: String; out A: Int64): Boolean;
var L, N : Integer;
begin
  L := Length(S);
  Result := TryStringToInt64P(PChar(S), L, A, N) = convertOK;
  if Result then
    if N < L then
      Result := False;
end;

function StringToInt64DefA(const S: AnsiString; const Default: Int64): Int64;
begin
  if not TryStringToInt64A(S, Result) then
    Result := Default;
end;

function StringToInt64DefB(const S: RawByteString; const Default: Int64): Int64;
begin
  if not TryStringToInt64B(S, Result) then
    Result := Default;
end;

function StringToInt64DefW(const S: WideString; const Default: Int64): Int64;
begin
  if not TryStringToInt64W(S, Result) then
    Result := Default;
end;

function StringToInt64DefU(const S: UnicodeString; const Default: Int64): Int64;
begin
  if not TryStringToInt64U(S, Result) then
    Result := Default;
end;

function StringToInt64Def(const S: String; const Default: Int64): Int64;
begin
  if not TryStringToInt64(S, Result) then
    Result := Default;
end;

function StringToInt64A(const S: AnsiString): Int64;
begin
  if not TryStringToInt64A(S, Result) then
    RaiseRangeCheckError;
end;

function StringToInt64B(const S: RawByteString): Int64;
begin
  if not TryStringToInt64B(S, Result) then
    RaiseRangeCheckError;
end;

function StringToInt64W(const S: WideString): Int64;
begin
  if not TryStringToInt64W(S, Result) then
    RaiseRangeCheckError;
end;

function StringToInt64U(const S: UnicodeString): Int64;
begin
  if not TryStringToInt64U(S, Result) then
    RaiseRangeCheckError;
end;

function StringToInt64(const S: String): Int64;
begin
  if not TryStringToInt64(S, Result) then
    RaiseRangeCheckError;
end;

function TryStringToIntA(const S: AnsiString; out A: Integer): Boolean;
var B : Int64;
begin
  Result := TryStringToInt64A(S, B);
  if not Result then
    begin
      A := 0;
      exit;
    end;
  if (B < MinInteger) or (B > MaxInteger) then
    begin
      A := 0;
      Result := False;
      exit;
    end;
  A := Integer(B);
  Result := True;
end;

function TryStringToIntB(const S: RawByteString; out A: Integer): Boolean;
var B : Int64;
begin
  Result := TryStringToInt64B(S, B);
  if not Result then
    begin
      A := 0;
      exit;
    end;
  if (B < MinInteger) or (B > MaxInteger) then
    begin
      A := 0;
      Result := False;
      exit;
    end;
  A := Integer(B);
  Result := True;
end;

function TryStringToIntW(const S: WideString; out A: Integer): Boolean;
var B : Int64;
begin
  Result := TryStringToInt64W(S, B);
  if not Result then
    begin
      A := 0;
      exit;
    end;
  if (B < MinInteger) or (B > MaxInteger) then
    begin
      A := 0;
      Result := False;
      exit;
    end;
  A := Integer(B);
  Result := True;
end;

function TryStringToIntU(const S: UnicodeString; out A: Integer): Boolean;
var B : Int64;
begin
  Result := TryStringToInt64U(S, B);
  if not Result then
    begin
      A := 0;
      exit;
    end;
  if (B < MinInteger) or (B > MaxInteger) then
    begin
      A := 0;
      Result := False;
      exit;
    end;
  A := Integer(B);
  Result := True;
end;

function TryStringToInt(const S: String; out A: Integer): Boolean;
var B : Int64;
begin
  Result := TryStringToInt64(S, B);
  if not Result then
    begin
      A := 0;
      exit;
    end;
  if (B < MinInteger) or (B > MaxInteger) then
    begin
      A := 0;
      Result := False;
      exit;
    end;
  A := Integer(B);
  Result := True;
end;

function StringToIntDefA(const S: AnsiString; const Default: Integer): Integer;
begin
  if not TryStringToIntA(S, Result) then
    Result := Default;
end;

function StringToIntDefB(const S: RawByteString; const Default: Integer): Integer;
begin
  if not TryStringToIntB(S, Result) then
    Result := Default;
end;

function StringToIntDefW(const S: WideString; const Default: Integer): Integer;
begin
  if not TryStringToIntW(S, Result) then
    Result := Default;
end;

function StringToIntDefU(const S: UnicodeString; const Default: Integer): Integer;
begin
  if not TryStringToIntU(S, Result) then
    Result := Default;
end;

function StringToIntDef(const S: String; const Default: Integer): Integer;
begin
  if not TryStringToInt(S, Result) then
    Result := Default;
end;

function StringToIntA(const S: AnsiString): Integer;
begin
  if not TryStringToIntA(S, Result) then
    RaiseRangeCheckError;
end;

function StringToIntB(const S: RawByteString): Integer;
begin
  if not TryStringToIntB(S, Result) then
    RaiseRangeCheckError;
end;

function StringToIntW(const S: WideString): Integer;
begin
  if not TryStringToIntW(S, Result) then
    RaiseRangeCheckError;
end;

function StringToIntU(const S: UnicodeString): Integer;
begin
  if not TryStringToIntU(S, Result) then
    RaiseRangeCheckError;
end;

function StringToInt(const S: String): Integer;
begin
  if not TryStringToInt(S, Result) then
    RaiseRangeCheckError;
end;

function TryStringToLongWordA(const S: AnsiString; out A: LongWord): Boolean;
var B : Int64;
begin
  Result := TryStringToInt64A(S, B);
  if not Result then
    begin
      A := 0;
      exit;
    end;
  if (B < MinLongWord) or (B > MaxLongWord) then
    begin
      A := 0;
      Result := False;
      exit;
    end;
  A := LongWord(B);
  Result := True;
end;

function TryStringToLongWordB(const S: RawByteString; out A: LongWord): Boolean;
var B : Int64;
begin
  Result := TryStringToInt64B(S, B);
  if not Result then
    begin
      A := 0;
      exit;
    end;
  if (B < MinLongWord) or (B > MaxLongWord) then
    begin
      A := 0;
      Result := False;
      exit;
    end;
  A := LongWord(B);
  Result := True;
end;

function TryStringToLongWordW(const S: WideString; out A: LongWord): Boolean;
var B : Int64;
begin
  Result := TryStringToInt64W(S, B);
  if not Result then
    begin
      A := 0;
      exit;
    end;
  if (B < MinLongWord) or (B > MaxLongWord) then
    begin
      A := 0;
      Result := False;
      exit;
    end;
  A := LongWord(B);
  Result := True;
end;

function TryStringToLongWordU(const S: UnicodeString; out A: LongWord): Boolean;
var B : Int64;
begin
  Result := TryStringToInt64U(S, B);
  if not Result then
    begin
      A := 0;
      exit;
    end;
  if (B < MinLongWord) or (B > MaxLongWord) then
    begin
      A := 0;
      Result := False;
      exit;
    end;
  A := LongWord(B);
  Result := True;
end;

function TryStringToLongWord(const S: String; out A: LongWord): Boolean;
var B : Int64;
begin
  Result := TryStringToInt64(S, B);
  if not Result then
    begin
      A := 0;
      exit;
    end;
  if (B < MinLongWord) or (B > MaxLongWord) then
    begin
      A := 0;
      Result := False;
      exit;
    end;
  A := LongWord(B);
  Result := True;
end;

function StringToLongWordA(const S: AnsiString): LongWord;
begin
  if not TryStringToLongWordA(S, Result) then
    RaiseRangeCheckError;
end;

function StringToLongWordB(const S: RawByteString): LongWord;
begin
  if not TryStringToLongWordB(S, Result) then
    RaiseRangeCheckError;
end;

function StringToLongWordW(const S: WideString): LongWord;
begin
  if not TryStringToLongWordW(S, Result) then
    RaiseRangeCheckError;
end;

function StringToLongWordU(const S: UnicodeString): LongWord;
begin
  if not TryStringToLongWordU(S, Result) then
    RaiseRangeCheckError;
end;

function StringToLongWord(const S: String): LongWord;
begin
  if not TryStringToLongWord(S, Result) then
    RaiseRangeCheckError;
end;

function BaseStrToNativeUIntA(const S: AnsiString; const BaseLog2: Byte;
    var Valid: Boolean): NativeUInt;
var N : Byte;
    L : Integer;
    M : Byte;
    C : Byte;
begin
  Assert(BaseLog2 <= 4); // maximum base 16
  L := Length(S);
  if L = 0 then // empty string is invalid
    begin
      Valid := False;
      Result := 0;
      exit;
    end;
  M := (1 shl BaseLog2) - 1; // maximum digit value
  N := 0;
  Result := 0;
  repeat
    C := HexLookup[S[L]];
    if C > M then // invalid digit
      begin
        Valid := False;
        Result := 0;
        exit;
      end;
    {$IFDEF FPC}
    Result := Result + NativeUInt(C) shl N;
    {$ELSE}
    Inc(Result, NativeUInt(C) shl N);
    {$ENDIF}
    Inc(N, BaseLog2);
    if N > BitsPerNativeWord then // overflow
      begin
        Valid := False;
        Result := 0;
        exit;
      end;
    Dec(L);
  until L = 0;
  Valid := True;
end;

function BaseStrToNativeUIntB(const S: RawByteString; const BaseLog2: Byte;
    var Valid: Boolean): NativeUInt;
var N : Byte;
    L : Integer;
    M : Byte;
    C : Byte;
begin
  Assert(BaseLog2 <= 4); // maximum base 16
  L := Length(S);
  if L = 0 then // empty string is invalid
    begin
      Valid := False;
      Result := 0;
      exit;
    end;
  M := (1 shl BaseLog2) - 1; // maximum digit value
  N := 0;
  Result := 0;
  repeat
    C := HexLookup[S[L]];
    if C > M then // invalid digit
      begin
        Valid := False;
        Result := 0;
        exit;
      end;
    {$IFDEF FPC}
    Result := Result + NativeUInt(C) shl N;
    {$ELSE}
    Inc(Result, NativeUInt(C) shl N);
    {$ENDIF}
    Inc(N, BaseLog2);
    if N > BitsPerNativeWord then // overflow
      begin
        Valid := False;
        Result := 0;
        exit;
      end;
    Dec(L);
  until L = 0;
  Valid := True;
end;

function BaseStrToNativeUIntW(const S: WideString; const BaseLog2: Byte;
    var Valid: Boolean): NativeUInt;
var N : Byte;
    L : Integer;
    M : Byte;
    C : Byte;
    D : WideChar;
begin
  Assert(BaseLog2 <= 4); // maximum base 16
  L := Length(S);
  if L = 0 then // empty string is invalid
    begin
      Valid := False;
      Result := 0;
      exit;
    end;
  M := (1 shl BaseLog2) - 1; // maximum digit value
  N := 0;
  Result := 0;
  repeat
    D := S[L];
    if Ord(D) > $FF then
      C := $FF
    else
      C := HexLookup[AnsiChar(Ord(D))];
    if C > M then // invalid digit
      begin
        Valid := False;
        Result := 0;
        exit;
      end;
    {$IFDEF FPC}
    Result := Result + NativeUInt(C) shl N;
    {$ELSE}
    Inc(Result, NativeUInt(C) shl N);
    {$ENDIF}
    Inc(N, BaseLog2);
    if N > BitsPerNativeWord then // overflow
      begin
        Valid := False;
        Result := 0;
        exit;
      end;
    Dec(L);
  until L = 0;
  Valid := True;
end;

function BaseStrToNativeUIntU(const S: UnicodeString; const BaseLog2: Byte;
    var Valid: Boolean): NativeUInt;
var N : Byte;
    L : Integer;
    M : Byte;
    C : Byte;
    D : WideChar;
begin
  Assert(BaseLog2 <= 4); // maximum base 16
  L := Length(S);
  if L = 0 then // empty string is invalid
    begin
      Valid := False;
      Result := 0;
      exit;
    end;
  M := (1 shl BaseLog2) - 1; // maximum digit value
  N := 0;
  Result := 0;
  repeat
    D := S[L];
    if Ord(D) > $FF then
      C := $FF
    else
      C := HexLookup[AnsiChar(Ord(D))];
    if C > M then // invalid digit
      begin
        Valid := False;
        Result := 0;
        exit;
      end;
    {$IFDEF FPC}
    Result := Result + NativeUInt(C) shl N;
    {$ELSE}
    Inc(Result, NativeUInt(C) shl N);
    {$ENDIF}
    Inc(N, BaseLog2);
    if N > BitsPerNativeWord then // overflow
      begin
        Valid := False;
        Result := 0;
        exit;
      end;
    Dec(L);
  until L = 0;
  Valid := True;
end;

function BaseStrToNativeUInt(const S: String; const BaseLog2: Byte;
    var Valid: Boolean): NativeUInt;
var N : Byte;
    L : Integer;
    M : Byte;
    C : Byte;
    D : Char;
begin
  Assert(BaseLog2 <= 4); // maximum base 16
  L := Length(S);
  if L = 0 then // empty string is invalid
    begin
      Valid := False;
      Result := 0;
      exit;
    end;
  M := (1 shl BaseLog2) - 1; // maximum digit value
  N := 0;
  Result := 0;
  repeat
    D := S[L];
    {$IFDEF CharIsWide}
    if Ord(D) > $FF then
      C := $FF
    else
      C := HexLookup[AnsiChar(Ord(D))];
    {$ELSE}
    C := HexLookup[D];
    {$ENDIF}
    if C > M then // invalid digit
      begin
        Valid := False;
        Result := 0;
        exit;
      end;
    {$IFDEF FPC}
    Result := Result + NativeUInt(C) shl N;
    {$ELSE}
    Inc(Result, NativeUInt(C) shl N);
    {$ENDIF}
    Inc(N, BaseLog2);
    if N > BitsPerNativeWord then // overflow
      begin
        Valid := False;
        Result := 0;
        exit;
      end;
    Dec(L);
  until L = 0;
  Valid := True;
end;

function HexToUIntA(const S: AnsiString): NativeUInt;
var R : Boolean;
begin
  Result := BaseStrToNativeUIntA(S, 4, R);
  if not R then
    RaiseRangeCheckError;
end;

function HexToUIntB(const S: RawByteString): NativeUInt;
var R : Boolean;
begin
  Result := BaseStrToNativeUIntB(S, 4, R);
  if not R then
    RaiseRangeCheckError;
end;

function HexToUIntW(const S: WideString): NativeUInt;
var R : Boolean;
begin
  Result := BaseStrToNativeUIntW(S, 4, R);
  if not R then
    RaiseRangeCheckError;
end;

function HexToUIntU(const S: UnicodeString): NativeUInt;
var R : Boolean;
begin
  Result := BaseStrToNativeUIntU(S, 4, R);
  if not R then
    RaiseRangeCheckError;
end;

function HexToUInt(const S: String): NativeUInt;
var R : Boolean;
begin
  Result := BaseStrToNativeUInt(S, 4, R);
  if not R then
    RaiseRangeCheckError;
end;

function TryHexToLongWordA(const S: AnsiString; out A: LongWord): Boolean;
begin
  A := BaseStrToNativeUIntA(S, 4, Result);
end;

function TryHexToLongWordB(const S: RawByteString; out A: LongWord): Boolean;
begin
  A := BaseStrToNativeUIntB(S, 4, Result);
end;

function TryHexToLongWordW(const S: WideString; out A: LongWord): Boolean;
begin
  A := BaseStrToNativeUIntW(S, 4, Result);
end;

function TryHexToLongWordU(const S: UnicodeString; out A: LongWord): Boolean;
begin
  A := BaseStrToNativeUIntU(S, 4, Result);
end;

function TryHexToLongWord(const S: String; out A: LongWord): Boolean;
begin
  A := BaseStrToNativeUInt(S, 4, Result);
end;

function HexToLongWordA(const S: AnsiString): LongWord;
var R : Boolean;
begin
  Result := BaseStrToNativeUIntA(S, 4, R);
  if not R then
    RaiseRangeCheckError;
end;

function HexToLongWordB(const S: RawByteString): LongWord;
var R : Boolean;
begin
  Result := BaseStrToNativeUIntB(S, 4, R);
  if not R then
    RaiseRangeCheckError;
end;

function HexToLongWordW(const S: WideString): LongWord;
var R : Boolean;
begin
  Result := BaseStrToNativeUIntW(S, 4, R);
  if not R then
    RaiseRangeCheckError;
end;

function HexToLongWordU(const S: UnicodeString): LongWord;
var R : Boolean;
begin
  Result := BaseStrToNativeUIntU(S, 4, R);
  if not R then
    RaiseRangeCheckError;
end;

function HexToLongWord(const S: String): LongWord;
var R : Boolean;
begin
  Result := BaseStrToNativeUInt(S, 4, R);
  if not R then
    RaiseRangeCheckError;
end;

function TryOctToLongWordA(const S: AnsiString; out A: LongWord): Boolean;
begin
  A := BaseStrToNativeUIntA(S, 3, Result);
end;

function TryOctToLongWordB(const S: RawByteString; out A: LongWord): Boolean;
begin
  A := BaseStrToNativeUIntB(S, 3, Result);
end;

function TryOctToLongWordW(const S: WideString; out A: LongWord): Boolean;
begin
  A := BaseStrToNativeUIntW(S, 3, Result);
end;

function TryOctToLongWordU(const S: UnicodeString; out A: LongWord): Boolean;
begin
  A := BaseStrToNativeUIntU(S, 3, Result);
end;

function TryOctToLongWord(const S: String; out A: LongWord): Boolean;
begin
  A := BaseStrToNativeUInt(S, 3, Result);
end;

function OctToLongWordA(const S: AnsiString): LongWord;
var R : Boolean;
begin
  Result := BaseStrToNativeUIntA(S, 3, R);
  if not R then
    RaiseRangeCheckError;
end;

function OctToLongWordB(const S: RawByteString): LongWord;
var R : Boolean;
begin
  Result := BaseStrToNativeUIntB(S, 3, R);
  if not R then
    RaiseRangeCheckError;
end;

function OctToLongWordW(const S: WideString): LongWord;
var R : Boolean;
begin
  Result := BaseStrToNativeUIntW(S, 3, R);
  if not R then
    RaiseRangeCheckError;
end;

function OctToLongWordU(const S: UnicodeString): LongWord;
var R : Boolean;
begin
  Result := BaseStrToNativeUIntU(S, 3, R);
  if not R then
    RaiseRangeCheckError;
end;

function OctToLongWord(const S: String): LongWord;
var R : Boolean;
begin
  Result := BaseStrToNativeUIntW(S, 3, R);
  if not R then
    RaiseRangeCheckError;
end;

function TryBinToLongWordA(const S: AnsiString; out A: LongWord): Boolean;
begin
  A := BaseStrToNativeUIntA(S, 1, Result);
end;

function TryBinToLongWordB(const S: RawByteString; out A: LongWord): Boolean;
begin
  A := BaseStrToNativeUIntB(S, 1, Result);
end;

function TryBinToLongWordW(const S: WideString; out A: LongWord): Boolean;
begin
  A := BaseStrToNativeUIntW(S, 1, Result);
end;

function TryBinToLongWordU(const S: UnicodeString; out A: LongWord): Boolean;
begin
  A := BaseStrToNativeUIntU(S, 1, Result);
end;

function TryBinToLongWord(const S: String; out A: LongWord): Boolean;
begin
  A := BaseStrToNativeUInt(S, 1, Result);
end;

function BinToLongWordA(const S: AnsiString): LongWord;
var R : Boolean;
begin
  Result := BaseStrToNativeUIntA(S, 1, R);
  if not R then
    RaiseRangeCheckError;
end;

function BinToLongWordB(const S: RawByteString): LongWord;
var R : Boolean;
begin
  Result := BaseStrToNativeUIntB(S, 1, R);
  if not R then
    RaiseRangeCheckError;
end;

function BinToLongWordW(const S: WideString): LongWord;
var R : Boolean;
begin
  Result := BaseStrToNativeUIntW(S, 1, R);
  if not R then
    RaiseRangeCheckError;
end;

function BinToLongWordU(const S: UnicodeString): LongWord;
var R : Boolean;
begin
  Result := BaseStrToNativeUIntU(S, 1, R);
  if not R then
    RaiseRangeCheckError;
end;

function BinToLongWord(const S: String): LongWord;
var R : Boolean;
begin
  Result := BaseStrToNativeUInt(S, 1, R);
  if not R then
    RaiseRangeCheckError;
end;



{                                                                              }
{ Float-String conversions                                                     }
{                                                                              }
function FloatToStringS(const A: Extended): ShortString;
var B : Extended;
    S : ShortString;
    L, I : Integer;
    E : Integer;
begin
  // handle special floating point values
  {$IFNDEF ExtendedIsDouble}
  if ExtendedIsInfinity(A) or ExtendedIsNaN(A) then
    begin
      Result := '';
      exit;
    end;
  {$ENDIF}
  B := Abs(A);
  // very small numbers (Double precision) are zero
  if B < 1e-300 then
    begin
      Result := '0';
      exit;
    end;
  // up to 15 digits (around Double precsion) before or after decimal use non-scientific notation
  if (B < 1e-15) or (B >= 1e+15) then
    Str(A, S)
  else
    Str(A:0:15, S);
  // trim preceding spaces
  I := 1;
  while S[I] = ' ' do
    Inc(I);
  if I > 1 then
    S := Copy(S, I, Length(S) - I + 1);
  // find exponent
  L := Length(S);
  E := 0;
  for I := 1 to L do
    if S[I] = 'E' then
      begin
        E := I;
        break;
      end;
  if E = 0 then
    begin
      // trim trailing zeros
      I := L;
      while S[I] = '0' do
        Dec(I);
      if S[I] = '.' then
        Dec(I);
      if I < L then
        SetLength(S, I);
    end
  else
    begin
      // trim trailing zeros in mantissa
      I := E - 1;
      while S[I] = '0' do
        Dec(I);
      if S[I] = '.' then
        Dec(I);
      if I < E - 1 then
        S := Copy(S, 1, I) + Copy(S, E, L - E + 1);
    end;
  // return formatted float string
  Result := S;
end;

function FloatToStringA(const A: Extended): AnsiString;
begin
  Result := AnsiString(FloatToStringS(A));
end;

function FloatToStringB(const A: Extended): RawByteString;
begin
  Result := RawByteString(FloatToStringS(A));
end;

function FloatToStringW(const A: Extended): WideString;
begin
  Result := WideString(FloatToStringS(A));
end;

function FloatToStringU(const A: Extended): UnicodeString;
begin
  Result := UnicodeString(FloatToStringS(A));
end;

function FloatToString(const A: Extended): String;
begin
  Result := String(FloatToStringS(A));
end;

function TryStringToFloatPA(const BufP: Pointer; const BufLen: Integer; out Value: Extended; out StrLen: Integer): TConvertResult;
var Len : Integer;
    DigVal : Integer;
    DigValF : Extended;
    P : PAnsiChar;
    Ch : AnsiChar;
    HasDig : Boolean;
    Neg : Boolean;
    Res : Extended;
    Ex : Extended;
    ExI : Int64;
    L : Integer;
begin
  if BufLen <= 0 then
    begin
      Value := 0;
      StrLen := 0;
      Result := convertFormatError;
      exit;
    end;
  P := BufP;
  Len := 0;
  // check sign
  Ch := P^;
  if (Ch = '+') or (Ch = '-') then
    begin
      Inc(Len);
      Inc(P);
      Neg := Ch = '-';
    end
  else
    Neg := False;
  // skip leading zeros
  HasDig := False;
  while (Len < BufLen) and (P^ = '0') do
    begin
      Inc(Len);
      Inc(P);
      HasDig := True;
    end;
  // convert integer digits
  Res := 0.0;
  while Len < BufLen do
    begin
      Ch := P^;
      if (Ch >= '0') and (Ch <= '9') then
        begin
          HasDig := True;
          // maximum Extended is roughly 1.1e4932, maximum Double is roughly 1.7e308
          if Abs(Res) >= 1.0e+290 then
            begin
              Value := 0;
              StrLen := Len;
              Result := convertOverflow;
              exit;
            end;
          Res := Res * 10.0;
          DigVal := AnsiCharToInt(Ch);
          if Neg then
            Res := Res - DigVal
          else
            Res := Res + DigVal;
          Inc(Len);
          Inc(P);
        end
      else
        break;
    end;
  // convert decimal digits
  if (Len < BufLen) and (P^ = '.') then
    begin
      Inc(Len);
      Inc(P);
      ExI := 0;
      while Len < BufLen do
        begin
          Ch := P^;
          if (Ch >= '0') and (Ch <= '9') then
            begin
              HasDig := True;
              // minimum Extended is roughly 3.6e-4951, minimum Double is roughly 5e-324
              if ExI >= 1000 then
                begin
                  Value := 0;
                  StrLen := Len;
                  Result := convertOverflow;
                  exit;
                end;
              DigVal := AnsiCharToInt(Ch);
              Inc(ExI);
              DigValF := DigVal;
              DigValF := DigValF / Power(10.0, ExI);
              if Neg then
                Res := Res - DigValF
              else
                Res := Res + DigValF;
              Inc(Len);
              Inc(P);
            end
          else
            break;
        end;
    end;
  // check valid digit
  if not HasDig then
    begin
      Value := 0;
      StrLen := Len;
      Result := convertFormatError;
      exit;
    end;
  // convert exponent
  if Len < BufLen then
    begin
      Ch := P^;
      if (Ch = 'e') or (Ch = 'E') then
        begin
          Inc(Len);
          Inc(P);
          Result := TryStringToInt64PA(P, BufLen - Len, ExI, L);
          Inc(Len, L);
          if Result <> convertOK then
            begin
              Value := 0;
              StrLen := Len;
              exit;
            end;
          if ExI <> 0 then
            begin
              if (ExI > 1000) or (ExI < -1000) then
                begin
                  Value := 0;
                  StrLen := Len;
                  Result := convertOverflow;
                  exit;
                end;
              Ex := ExI;
              Ex := Power(10.0, Ex);
              Res := Res * Ex;
            end;
        end;
    end;
  // success
  Value := Res;
  StrLen := Len;
  Result := convertOK;
end;

function TryStringToFloatPW(const BufP: Pointer; const BufLen: Integer; out Value: Extended; out StrLen: Integer): TConvertResult;
var Len : Integer;
    DigVal : Integer;
    DigValF : Extended;
    P : PWideChar;
    Ch : WideChar;
    HasDig : Boolean;
    Neg : Boolean;
    Res : Extended;
    Ex : Extended;
    ExI : Int64;
    L : Integer;
begin
  if BufLen <= 0 then
    begin
      Value := 0;
      StrLen := 0;
      Result := convertFormatError;
      exit;
    end;
  P := BufP;
  Len := 0;
  // check sign
  Ch := P^;
  if (Ch = '+') or (Ch = '-') then
    begin
      Inc(Len);
      Inc(P);
      Neg := Ch = '-';
    end
  else
    Neg := False;
  // skip leading zeros
  HasDig := False;
  while (Len < BufLen) and (P^ = '0') do
    begin
      Inc(Len);
      Inc(P);
      HasDig := True;
    end;
  // convert integer digits
  Res := 0.0;
  while Len < BufLen do
    begin
      Ch := P^;
      if (Ch >= '0') and (Ch <= '9') then
        begin
          HasDig := True;
          // maximum Extended is roughly 1.1e4932, maximum Double is roughly 1.7e308
          if Abs(Res) >= 1.0e+1000 then
            begin
              Value := 0;
              StrLen := Len;
              Result := convertOverflow;
              exit;
            end;
          Res := Res * 10.0;
          DigVal := WideCharToInt(Ch);
          if Neg then
            Res := Res - DigVal
          else
            Res := Res + DigVal;
          Inc(Len);
          Inc(P);
        end
      else
        break;
    end;
  // convert decimal digits
  if (Len < BufLen) and (P^ = '.') then
    begin
      Inc(Len);
      Inc(P);
      ExI := 0;
      while Len < BufLen do
        begin
          Ch := P^;
          if (Ch >= '0') and (Ch <= '9') then
            begin
              HasDig := True;
              // minimum Extended is roughly 3.6e-4951, minimum Double is roughly 5e-324
              if ExI >= 1000 then
                begin
                  Value := 0;
                  StrLen := Len;
                  Result := convertOverflow;
                  exit;
                end;
              DigVal := WideCharToInt(Ch);
              Inc(ExI);
              DigValF := DigVal;
              DigValF := DigValF / Power(10.0, ExI);
              if Neg then
                Res := Res - DigValF
              else
                Res := Res + DigValF;
              Inc(Len);
              Inc(P);
            end
          else
            break;
        end;
    end;
  // check valid digit
  if not HasDig then
    begin
      Value := 0;
      StrLen := Len;
      Result := convertFormatError;
      exit;
    end;
  // convert exponent
  if Len < BufLen then
    begin
      Ch := P^;
      if (Ch = 'e') or (Ch = 'E') then
        begin
          Inc(Len);
          Inc(P);
          Result := TryStringToInt64PW(P, BufLen - Len, ExI, L);
          Inc(Len, L);
          if Result <> convertOK then
            begin
              Value := 0;
              StrLen := Len;
              exit;
            end;
          if ExI <> 0 then
            begin
              if (ExI > 1000) or (ExI < -1000) then
                begin
                  Value := 0;
                  StrLen := Len;
                  Result := convertOverflow;
                  exit;
                end;
              Ex := ExI;
              Ex := Power(10.0, Ex);
              Res := Res * Ex;
            end;
        end;
    end;
  // success
  Value := Res;
  StrLen := Len;
  Result := convertOK;
end;

function TryStringToFloatP(const BufP: Pointer; const BufLen: Integer; out Value: Extended; out StrLen: Integer): TConvertResult;
var Len : Integer;
    DigVal : Integer;
    DigValF : Extended;
    P : PChar;
    Ch : Char;
    HasDig : Boolean;
    Neg : Boolean;
    Res : Extended;
    Ex : Extended;
    ExI : Int64;
    L : Integer;
begin
  if BufLen <= 0 then
    begin
      Value := 0;
      StrLen := 0;
      Result := convertFormatError;
      exit;
    end;
  P := BufP;
  Len := 0;
  // check sign
  Ch := P^;
  if (Ch = '+') or (Ch = '-') then
    begin
      Inc(Len);
      Inc(P);
      Neg := Ch = '-';
    end
  else
    Neg := False;
  // skip leading zeros
  HasDig := False;
  while (Len < BufLen) and (P^ = '0') do
    begin
      Inc(Len);
      Inc(P);
      HasDig := True;
    end;
  // convert integer digits
  Res := 0.0;
  while Len < BufLen do
    begin
      Ch := P^;
      if (Ch >= '0') and (Ch <= '9') then
        begin
          HasDig := True;
          // maximum Extended is roughly 1.1e4932, maximum Double is roughly 1.7e308
          if Abs(Res) >= 1.0e+1000 then
            begin
              Value := 0;
              StrLen := Len;
              Result := convertOverflow;
              exit;
            end;
          Res := Res * 10.0;
          DigVal := CharToInt(Ch);
          if Neg then
            Res := Res - DigVal
          else
            Res := Res + DigVal;
          Inc(Len);
          Inc(P);
        end
      else
        break;
    end;
  // convert decimal digits
  if (Len < BufLen) and (P^ = '.') then
    begin
      Inc(Len);
      Inc(P);
      ExI := 0;
      while Len < BufLen do
        begin
          Ch := P^;
          if (Ch >= '0') and (Ch <= '9') then
            begin
              HasDig := True;
              // minimum Extended is roughly 3.6e-4951, minimum Double is roughly 5e-324
              if ExI >= 1000 then
                begin
                  Value := 0;
                  StrLen := Len;
                  Result := convertOverflow;
                  exit;
                end;
              DigVal := CharToInt(Ch);
              Inc(ExI);
              DigValF := DigVal;
              DigValF := DigValF / Power(10.0, ExI);
              if Neg then
                Res := Res - DigValF
              else
                Res := Res + DigValF;
              Inc(Len);
              Inc(P);
            end
          else
            break;
        end;
    end;
  // check valid digit
  if not HasDig then
    begin
      Value := 0;
      StrLen := Len;
      Result := convertFormatError;
      exit;
    end;
  // convert exponent
  if Len < BufLen then
    begin
      Ch := P^;
      if (Ch = 'e') or (Ch = 'E') then
        begin
          Inc(Len);
          Inc(P);
          Result := TryStringToInt64P(P, BufLen - Len, ExI, L);
          Inc(Len, L);
          if Result <> convertOK then
            begin
              Value := 0;
              StrLen := Len;
              exit;
            end;
          if ExI <> 0 then
            begin
              if (ExI > 1000) or (ExI < -1000) then
                begin
                  Value := 0;
                  StrLen := Len;
                  Result := convertOverflow;
                  exit;
                end;
              Ex := ExI;
              Ex := Power(10.0, Ex);
              Res := Res * Ex;
            end;
        end;
    end;
  // success
  Value := Res;
  StrLen := Len;
  Result := convertOK;
end;

function TryStringToFloatA(const A: AnsiString; out B: Extended): Boolean;
var L, N : Integer;
begin
  L := Length(A);
  Result := TryStringToFloatPA(PAnsiChar(A), L, B, N) = convertOK;
  if Result then
    if N < L then
      Result := False;
end;

function TryStringToFloatB(const A: RawByteString; out B: Extended): Boolean;
var L, N : Integer;
begin
  L := Length(A);
  Result := TryStringToFloatPA(PAnsiChar(A), L, B, N) = convertOK;
  if Result then
    if N < L then
      Result := False;
end;

function TryStringToFloatW(const A: WideString; out B: Extended): Boolean;
var L, N : Integer;
begin
  L := Length(A);
  Result := TryStringToFloatPW(PWideChar(A), L, B, N) = convertOK;
  if Result then
    if N < L then
      Result := False;
end;

function TryStringToFloatU(const A: UnicodeString; out B: Extended): Boolean;
var L, N : Integer;
begin
  L := Length(A);
  Result := TryStringToFloatPW(PWideChar(A), L, B, N) = convertOK;
  if Result then
    if N < L then
      Result := False;
end;

function TryStringToFloat(const A: String; out B: Extended): Boolean;
var L, N : Integer;
begin
  L := Length(A);
  Result := TryStringToFloatP(PChar(A), L, B, N) = convertOK;
  if Result then
    if N < L then
      Result := False;
end;

function StringToFloatA(const A: AnsiString): Extended;
begin
  if not TryStringToFloatA(A, Result) then
    RaiseRangeCheckError;
end;

function StringToFloatB(const A: RawByteString): Extended;
begin
  if not TryStringToFloatB(A, Result) then
    RaiseRangeCheckError;
end;

function StringToFloatW(const A: WideString): Extended;
begin
  if not TryStringToFloatW(A, Result) then
    RaiseRangeCheckError;
end;

function StringToFloatU(const A: UnicodeString): Extended;
begin
  if not TryStringToFloatU(A, Result) then
    RaiseRangeCheckError;
end;

function StringToFloat(const A: String): Extended;
begin
  if not TryStringToFloat(A, Result) then
    RaiseRangeCheckError;
end;

function StringToFloatDefA(const A: AnsiString; const Default: Extended): Extended;
begin
  if not TryStringToFloatA(A, Result) then
    Result := Default;
end;

function StringToFloatDefB(const A: RawByteString; const Default: Extended): Extended;
begin
  if not TryStringToFloatB(A, Result) then
    Result := Default;
end;

function StringToFloatDefW(const A: WideString; const Default: Extended): Extended;
begin
  if not TryStringToFloatW(A, Result) then
    Result := Default;
end;

function StringToFloatDefU(const A: UnicodeString; const Default: Extended): Extended;
begin
  if not TryStringToFloatU(A, Result) then
    Result := Default;
end;

function StringToFloatDef(const A: String; const Default: Extended): Extended;
begin
  if not TryStringToFloat(A, Result) then
    Result := Default;
end;



{                                                                              }
{ Base64                                                                       }
{                                                                              }
{$IFDEF CLR}
function EncodeBase64(const S, Alphabet: AnsiString; const Pad: Boolean;
    const PadMultiple: Integer; const PadChar: AnsiChar): AnsiString;
var R, C : Byte;
    I, F, L, M, N, U : Integer;
    T : Boolean;
begin
  Assert(Length(Alphabet) = 64);
  {$IFOPT R+}
  if Length(Alphabet) <> 64 then
    begin
      Result := '';
      exit;
    end;
  {$ENDIF}
  L := Length(S);
  if L = 0 then
    begin
      Result := '';
      exit;
    end;
  M := L mod 3;
  N := (L div 3) * 4 + M;
  if M > 0 then
    Inc(N);
  T := Pad and (PadMultiple > 1);
  if T then
    begin
      U := N mod PadMultiple;
      if U > 0 then
        begin
          U := PadMultiple - U;
          Inc(N, U);
        end;
    end else
    U := 0;
  SetLength(Result, N);
  I := 1;
  R := 0;
  for F := 0 to L - 1 do
    begin
      C := Byte(S [F + 1]);
      case F mod 3 of
        0 : begin
              Result[I] := Alphabet[C shr 2 + 1];
              Inc(I);
              R := (C and 3) shl 4;
            end;
        1 : begin
              Result[I] := Alphabet[C shr 4 + R + 1];
              Inc(I);
              R := (C and $0F) shl 2;
            end;
        2 : begin
              Result[I] := Alphabet[C shr 6 + R + 1];
              Inc(I);
              Result[I] := Alphabet[C and $3F + 1];
              Inc(I);
            end;
      end;
    end;
  if M > 0 then
    begin
      Result[I] := Alphabet[R + 1];
      Inc(I);
    end;
  for F := 1 to U do
    begin
      Result[I] := PadChar;
      Inc(I);
    end;
end;
{$ELSE}
function EncodeBase64(const S, Alphabet: AnsiString; const Pad: Boolean;
    const PadMultiple: Integer; const PadChar: AnsiChar): AnsiString;
var R, C : Byte;
    F, L, M, N, U : Integer;
    P : PAnsiChar;
    T : Boolean;
begin
  Assert(Length(Alphabet) = 64);
  {$IFOPT R+}
  if Length(Alphabet) <> 64 then
    begin
      Result := '';
      exit;
    end;
  {$ENDIF}
  L := Length(S);
  if L = 0 then
    begin
      Result := '';
      exit;
    end;
  M := L mod 3;
  N := (L div 3) * 4 + M;
  if M > 0 then
    Inc(N);
  T := Pad and (PadMultiple > 1);
  if T then
    begin
      U := N mod PadMultiple;
      if U > 0 then
        begin
          U := PadMultiple - U;
          Inc(N, U);
        end;
    end else
    U := 0;
  SetLength(Result, N);
  P := Pointer(Result);
  R := 0;
  for F := 0 to L - 1 do
    begin
      C := Byte(S [F + 1]);
      case F mod 3 of
        0 : begin
              P^ := Alphabet[C shr 2 + 1];
              Inc(P);
              R := (C and 3) shl 4;
            end;
        1 : begin
              P^ := Alphabet[C shr 4 + R + 1];
              Inc(P);
              R := (C and $0F) shl 2;
            end;
        2 : begin
              P^ := Alphabet[C shr 6 + R + 1];
              Inc(P);
              P^ := Alphabet[C and $3F + 1];
              Inc(P);
            end;
      end;
    end;
  if M > 0 then
    begin
      P^ := Alphabet[R + 1];
      Inc(P);
    end;
  for F := 1 to U do
    begin
      P^ := PadChar;
      Inc(P);
    end;
end;
{$ENDIF}

{$IFDEF CLR}
function DecodeBase64(const S, Alphabet: AnsiString; const PadSet: CharSet): AnsiString;
var F, L, M, P : Integer;
    B, OutPos  : Byte;
    C          : AnsiChar;
    OutB       : array[1..3] of Byte;
    Lookup     : array[AnsiChar] of Byte;
    R          : Integer;
begin
  Assert(Length(Alphabet) = 64);
  {$IFOPT R+}
  if Length(Alphabet) <> 64 then
    begin
      Result := '';
      exit;
    end;
  {$ENDIF}
  L := Length(S);
  P := 0;
  if PadSet <> [] then
    while (L - P > 0) and (S[L - P] in PadSet) do
      Inc(P);
  M := L - P;
  if M = 0 then
    begin
      Result := '';
      exit;
    end;
  SetLength(Result, (M * 3) div 4);
  for C := #0 to #255 do
    Lookup[C] := 0;
  for F := 0 to 63 do
    Lookup[Alphabet[F + 1]] := Byte(F);
  R := 1;
  OutPos := 0;
  for F := 1 to L - P do
    begin
      B := Lookup[S[F]];
      case OutPos of
          0 : OutB[1] := B shl 2;
          1 : begin
                OutB[1] := OutB[1] or (B shr 4);
                Result[R] := AnsiChar(OutB[1]);
                Inc(R);
                OutB[2] := (B shl 4) and $FF;
              end;
          2 : begin
                OutB[2] := OutB[2] or (B shr 2);
                Result[R] := AnsiChar(OutB[2]);
                Inc(R);
                OutB[3] := (B shl 6) and $FF;
              end;
          3 : begin
                OutB[3] := OutB[3] or B;
                Result[R] := AnsiChar(OutB[3]);
                Inc(R);
              end;
        end;
      OutPos := (OutPos + 1) mod 4;
    end;
  if (OutPos > 0) and (P = 0) then // incomplete encoding, add the partial byte if not 0
    if OutB[OutPos] <> 0 then
      Result := Result + AnsiChar(OutB[OutPos]);
end;
{$ELSE}
function DecodeBase64(const S, Alphabet: AnsiString; const PadSet: CharSet): AnsiString;
var F, L, M, P : Integer;
    B, OutPos  : Byte;
    OutB       : array[1..3] of Byte;
    Lookup     : array[AnsiChar] of Byte;
    R          : PAnsiChar;
begin
  Assert(Length(Alphabet) = 64);
  {$IFOPT R+}
  if Length(Alphabet) <> 64 then
    begin
      Result := '';
      exit;
    end;
  {$ENDIF}
  L := Length(S);
  P := 0;
  if PadSet <> [] then
    while (L - P > 0) and (S[L - P] in PadSet) do
      Inc(P);
  M := L - P;
  if M = 0 then
    begin
      Result := '';
      exit;
    end;
  SetLength(Result, (M * 3) div 4);
  FillChar(Lookup, Sizeof(Lookup), #0);
  for F := 0 to 63 do
    Lookup[Alphabet[F + 1]] := Byte(F);
  R := Pointer(Result);
  OutPos := 0;
  for F := 1 to L - P do
    begin
      B := Lookup[S[F]];
      case OutPos of
          0 : OutB[1] := B shl 2;
          1 : begin
                OutB[1] := OutB[1] or (B shr 4);
                R^ := AnsiChar(OutB[1]);
                Inc(R);
                OutB[2] := (B shl 4) and $FF;
              end;
          2 : begin
                OutB[2] := OutB[2] or (B shr 2);
                R^ := AnsiChar(OutB[2]);
                Inc(R);
                OutB[3] := (B shl 6) and $FF;
              end;
          3 : begin
                OutB[3] := OutB[3] or B;
                R^ := AnsiChar(OutB[3]);
                Inc(R);
              end;
        end;
      OutPos := (OutPos + 1) mod 4;
    end;
  if (OutPos > 0) and (P = 0) then // incomplete encoding, add the partial byte if not 0
    if OutB[OutPos] <> 0 then
      Result := Result + AnsiChar(OutB[OutPos]);
end;
{$ENDIF}

function MIMEBase64Encode(const S: AnsiString): AnsiString;
begin
  Result := EncodeBase64(S, b64_MIMEBase64, True, 4, '=');
end;

function UUDecode(const S: AnsiString): AnsiString;
begin
  // Line without size indicator (first byte = length + 32)
  Result := DecodeBase64(S, b64_UUEncode, ['`']);
end;

function MIMEBase64Decode(const S: AnsiString): AnsiString;
begin
  Result := DecodeBase64(S, b64_MIMEBase64, ['=']);
end;

function XXDecode(const S: AnsiString): AnsiString;
begin
  Result := DecodeBase64(S, b64_XXEncode, []);
end;

{$IFDEF ManagedCode}
function BytesToHex(const P: array of Byte; const UpperCase: Boolean): AnsiString;
var D : Integer;
    E : Integer;
    L : Integer;
    V : Byte;
    W : Byte;
begin
  L := Length(P);
  if L = 0 then
    begin
      Result := '';
      exit;
    end;
  SetLength(Result, L * 2);
  D := 1;
  E := 1;
  while L > 0 do
    begin
      W := P[E];
      V := W shr 4 + 1;
      Inc(E);
      if UpperCase then
        Result[D] := AnsiChar(StrHexDigitsUpper[V])
      else
        Result[D] := AnsiChar(StrHexDigitsLower[V]);
      Inc(D);
      V := W and $F + 1;
      if UpperCase then
        Result[D] := AnsiChar(StrHexDigitsUpper[V])
      else
        Result[D] := AnsiChar(StrHexDigitsLower[V]);
      Inc(D);
      Dec(L);
    end;
end;
{$ELSE}
function BytesToHex(const P: Pointer; const Count: Integer;
         const UpperCase: Boolean): AnsiString;
var Q : PByte;
    D : PAnsiChar;
    L : Integer;
    V : Byte;
begin
  Q := P;
  L := Count;
  if (L <= 0) or not Assigned(Q) then
    begin
      Result := '';
      exit;
    end;
  SetLength(Result, Count * 2);
  D := Pointer(Result);
  while L > 0 do
    begin
      V := Q^ shr 4 + 1;
      if UpperCase then
        D^ := StrHexDigitsUpper[V]
      else
        D^ := StrHexDigitsLower[V];
      Inc(D);
      V := Q^ and $F + 1;
      if UpperCase then
        D^ := StrHexDigitsUpper[V]
      else
        D^ := StrHexDigitsLower[V];
      Inc(D);
      Inc(Q);
      Dec(L);
    end;
end;
{$ENDIF}



{                                                                              }
{ Network byte order                                                           }
{                                                                              }
function hton16(const A: Word): Word;
begin
  Result := Word(A shr 8) or Word(A shl 8);
end;

function ntoh16(const A: Word): Word;
begin
  Result := Word(A shr 8) or Word(A shl 8);
end;

function hton32(const A: LongWord): LongWord;
var BufH : array[0..3] of Byte;
    BufN : array[0..3] of Byte;
begin
  PLongWord(@BufH)^ := A;
  BufN[0] := BufH[3];
  BufN[1] := BufH[2];
  BufN[2] := BufH[1];
  BufN[3] := BufH[0];
  Result := PLongWord(@BufN)^;
end;

function ntoh32(const A: LongWord): LongWord;
var BufH : array[0..3] of Byte;
    BufN : array[0..3] of Byte;
begin
  PLongWord(@BufH)^ := A;
  BufN[0] := BufH[3];
  BufN[1] := BufH[2];
  BufN[2] := BufH[1];
  BufN[3] := BufH[0];
  Result := PLongWord(@BufN)^;
end;

function hton64(const A: Int64): Int64;
var BufH : array[0..7] of Byte;
    BufN : array[0..7] of Byte;
begin
  PInt64(@BufH)^ := A;
  BufN[0] := BufH[7];
  BufN[1] := BufH[6];
  BufN[2] := BufH[5];
  BufN[3] := BufH[4];
  BufN[4] := BufH[3];
  BufN[5] := BufH[2];
  BufN[6] := BufH[1];
  BufN[7] := BufH[0];
  Result := PInt64(@BufN)^;
end;

function ntoh64(const A: Int64): Int64;
var BufH : array[0..7] of Byte;
    BufN : array[0..7] of Byte;
begin
  PInt64(@BufH)^ := A;
  BufN[0] := BufH[7];
  BufN[1] := BufH[6];
  BufN[2] := BufH[5];
  BufN[3] := BufH[4];
  BufN[4] := BufH[3];
  BufN[5] := BufH[2];
  BufN[6] := BufH[1];
  BufN[7] := BufH[0];
  Result := PInt64(@BufN)^;
end;



{                                                                              }
{ Type conversion                                                              }
{                                                                              }
{$IFNDEF ManagedCode}
function PointerToStrA(const P: Pointer): AnsiString;
begin
  Result := NativeUIntToBaseA(NativeUInt(P), NativeWordSize * 2, 16, True);
end;

function PointerToStrB(const P: Pointer): RawByteString;
begin
  Result := NativeUIntToBaseB(NativeUInt(P), NativeWordSize * 2, 16, True);
end;

function PointerToStrW(const P: Pointer): WideString;
begin
  Result := NativeUIntToBaseW(NativeUInt(P), NativeWordSize * 2, 16, True);
end;

function PointerToStr(const P: Pointer): String;
begin
  Result := NativeUIntToBase(NativeUInt(P), NativeWordSize * 2, 16, True);
end;

function StrToPointerA(const S: AnsiString): Pointer;
var V : Boolean;
begin
  Result := Pointer(BaseStrToNativeUIntA(S, 4, V));
end;

function StrToPointerB(const S: RawByteString): Pointer;
var V : Boolean;
begin
  Result := Pointer(BaseStrToNativeUIntB(S, 4, V));
end;

function StrToPointerW(const S: WideString): Pointer;
var V : Boolean;
begin
  Result := Pointer(BaseStrToNativeUIntW(S, 4, V));
end;

function StrToPointer(const S: String): Pointer;
var V : Boolean;
begin
  Result := Pointer(BaseStrToNativeUInt(S, 4, V));
end;

function InterfaceToStrA(const I: IInterface): AnsiString;
begin
  Result := NativeUIntToBaseA(NativeUInt(I), NativeWordSize * 2, 16, True);
end;

function InterfaceToStrW(const I: IInterface): WideString;
begin
  Result := NativeUIntToBaseW(NativeUInt(I), NativeWordSize * 2, 16, True);
end;

function InterfaceToStr(const I: IInterface): String;
begin
  Result := NativeUIntToBase(NativeUInt(I), NativeWordSize * 2, 16, True);
end;
{$ENDIF}

function ObjectClassName(const O: TObject): String;
begin
  if not Assigned(O) then
    Result := 'nil'
  else
    Result := O.ClassName;
end;

function ClassClassName(const C: TClass): String;
begin
  if not Assigned(C) then
    Result := 'nil'
  else
    Result := C.ClassName;
end;

function ObjectToStr(const O: TObject): String;
begin
  if not Assigned(O) then
    Result := 'nil'
  else
    Result := O.ClassName{$IFNDEF CLR} + '@' + LongWordToHex(LongWord(O), 8){$ENDIF};
end;

{$IFDEF ASM386_DELPHI}
function CharSetToStr(const C: CharSet): AnsiString; // Andrew N. Driazgov
asm
      PUSH    EBX
      MOV     ECX, $100
      MOV     EBX, EAX
      PUSH    ESI
      MOV     EAX, EDX
      SUB     ESP, ECX
      XOR     ESI, ESI
      XOR     EDX, EDX
@@lp: BT      [EBX], EDX
      JC      @@mm
@@nx: INC     EDX
      DEC     ECX
      JNE     @@lp
      MOV     ECX, ESI
      MOV     EDX, ESP
      CALL    System.@LStrFromPCharLen
      ADD     ESP, $100
      POP     ESI
      POP     EBX
      RET
@@mm: MOV     [ESP + ESI], DL
      INC     ESI
      JMP     @@nx
end;
{$ELSE}
function CharSetToStr(const C: CharSet): AnsiString;
// Implemented recursively to avoid multiple memory allocations
  procedure CharMatch(const Start: AnsiChar; const Count: Integer);
  var Ch : AnsiChar;
  begin
    for Ch := Start to #255 do
      if Ch in C then
        begin
          if Ch = #255 then
            SetLength(Result, Count + 1)
          else
            CharMatch(AnsiChar(Byte(Ch) + 1), Count + 1);
          Result[Count + 1] := Ch;
          exit;
        end;
    SetLength(Result, Count);
  end;
begin
  CharMatch(#0, 0);
end;
{$ENDIF}

{$IFDEF ASM386_DELPHI}
function StrToCharSet(const S: AnsiString): CharSet; // Andrew N. Driazgov
asm
      XOR     ECX, ECX
      MOV     [EDX], ECX
      MOV     [EDX + 4], ECX
      MOV     [EDX + 8], ECX
      MOV     [EDX + 12], ECX
      MOV     [EDX + 16], ECX
      MOV     [EDX + 20], ECX
      MOV     [EDX + 24], ECX
      MOV     [EDX + 28], ECX
      TEST    EAX, EAX
      JE      @@qt
      MOV     ECX, [EAX - 4]
      PUSH    EBX
      SUB     ECX, 8
      JS      @@nx
@@lp: MOVZX   EBX, BYTE PTR [EAX]
      BTS     [EDX], EBX
      MOVZX   EBX, BYTE PTR [EAX + 1]
      BTS     [EDX], EBX
      MOVZX   EBX, BYTE PTR [EAX + 2]
      BTS     [EDX], EBX
      MOVZX   EBX, BYTE PTR [EAX + 3]
      BTS     [EDX], EBX
      MOVZX   EBX, BYTE PTR [EAX + 4]
      BTS     [EDX], EBX
      MOVZX   EBX, BYTE PTR [EAX + 5]
      BTS     [EDX], EBX
      MOVZX   EBX, BYTE PTR [EAX + 6]
      BTS     [EDX], EBX
      MOVZX   EBX, BYTE PTR [EAX + 7]
      BTS     [EDX], EBX
      ADD     EAX, 8
      SUB     ECX, 8
      JNS     @@lp
@@nx: JMP     DWORD PTR @@tV[ECX * 4 + 32]
@@tV: DD      @@ex, @@t1, @@t2, @@t3
      DD      @@t4, @@t5, @@t6, @@t7
@@t7: MOVZX   EBX, BYTE PTR [EAX + 6]
      BTS     [EDX], EBX
@@t6: MOVZX   EBX, BYTE PTR [EAX + 5]
      BTS     [EDX], EBX
@@t5: MOVZX   EBX, BYTE PTR [EAX + 4]
      BTS     [EDX], EBX
@@t4: MOVZX   EBX, BYTE PTR [EAX + 3]
      BTS     [EDX], EBX
@@t3: MOVZX   EBX, BYTE PTR [EAX + 2]
      BTS     [EDX], EBX
@@t2: MOVZX   EBX, BYTE PTR [EAX + 1]
      BTS     [EDX], EBX
@@t1: MOVZX   EBX, BYTE PTR [EAX]
      BTS     [EDX], EBX
@@ex: POP     EBX
@@qt:
end;
{$ELSE}
function StrToCharSet(const S: AnsiString): CharSet;
var I : Integer;
begin
  ClearCharSet(Result);
  for I := 1 to Length(S) do
    Include(Result, S[I]);
end;
{$ENDIF}



{                                                                              }
{ Hash functions                                                               }
{   Derived from a CRC32 algorithm.                                            }
{                                                                              }
var
  HashTableInit : Boolean = False;
  HashTable     : array[Byte] of LongWord;
  HashPoly      : LongWord = $EDB88320;

procedure InitHashTable;
var I, J : Byte;
    R    : LongWord;
begin
  for I := $00 to $FF do
    begin
      R := I;
      for J := 8 downto 1 do
        if R and 1 <> 0 then
          R := (R shr 1) xor HashPoly
        else
          R := R shr 1;
      HashTable[I] := R;
    end;
  HashTableInit := True;
end;

function HashByte(const Hash: LongWord; const C: Byte): LongWord; {$IFDEF UseInline}inline;{$ENDIF}
begin
  Result := HashTable[Byte(Hash) xor C] xor (Hash shr 8);
end;

function HashCharA(const Hash: LongWord; const Ch: AnsiChar): LongWord; {$IFDEF UseInline}inline;{$ENDIF}
begin
  Result := HashByte(Hash, Byte(Ch));
end;

function HashCharW(const Hash: LongWord; const Ch: WideChar): LongWord; {$IFDEF UseInline}inline;{$ENDIF}
var C1, C2 : Byte;
begin
  C1 := Byte(Ord(Ch) and $FF);
  C2 := Byte(Ord(Ch) shr 8);
  Result := Hash;
  Result := HashByte(Result, C1);
  Result := HashByte(Result, C2);
end;

function HashChar(const Hash: LongWord; const Ch: Char): LongWord; {$IFDEF UseInline}inline;{$ENDIF}
begin
  {$IFDEF CharIsWide}
  Result := HashCharW(Hash, Ch);
  {$ELSE}
  Result := HashCharA(Hash, Ch);
  {$ENDIF}
end;

function HashCharNoAsciiCaseA(const Hash: LongWord; const Ch: AnsiChar): LongWord; {$IFDEF UseInline}inline;{$ENDIF}
var C : Byte;
begin
  C := Byte(Ch);
  if C in [Ord('A')..Ord('Z')] then
    C := C or 32;
  Result := HashCharA(Hash, AnsiChar(C));
end;

function HashCharNoAsciiCaseW(const Hash: LongWord; const Ch: WideChar): LongWord; {$IFDEF UseInline}inline;{$ENDIF}
var C : Word;
begin
  C := Word(Ch);
  if C <= $FF then
    if Byte(C) in [Ord('A')..Ord('Z')] then
      C := C or 32;
  Result := HashCharW(Hash, WideChar(C));
end;

function HashCharNoAsciiCase(const Hash: LongWord; const Ch: Char): LongWord; {$IFDEF UseInline}inline;{$ENDIF}
begin
  {$IFDEF CharIsWide}
  Result := HashCharNoAsciiCaseW(Hash, Ch);
  {$ELSE}
  Result := HashCharNoAsciiCaseA(Hash, Ch);
  {$ENDIF}
end;

function HashBuf(const Hash: LongWord; const Buf; const BufSize: Integer): LongWord;
var P : PByte;
    I : Integer;
begin
  if not HashTableInit then
    InitHashTable;
  Result := Hash;
  P := @Buf;
  for I := 0 to BufSize - 1 do
    begin
      Result := HashByte(Result, P^);
      Inc(P);
    end;
end;

function HashStrA(const S: AnsiString;
         const Index: Integer; const Count: Integer;
         const AsciiCaseSensitive: Boolean;
         const Slots: LongWord): LongWord;
var I, L, A, B : Integer;
begin
  if not HashTableInit then
    InitHashTable;
  A := Index;
  if A < 1 then
    A := 1;
  L := Length(S);
  B := Count;
  if B < 0 then
    B := L
  else
    begin
      B := A + B - 1;
      if B > L then
        B := L;
    end;
  Result := $FFFFFFFF;
  if AsciiCaseSensitive then
    for I := A to B do
      Result := HashCharA(Result, S[I])
  else
    for I := A to B do
      Result := HashCharNoAsciiCaseA(Result, S[I]);
  if Slots > 0 then
    Result := Result mod Slots;
end;

function HashStrB(const S: RawByteString;
         const Index: Integer; const Count: Integer;
         const AsciiCaseSensitive: Boolean;
         const Slots: LongWord): LongWord;
var I, L, A, B : Integer;
begin
  if not HashTableInit then
    InitHashTable;
  A := Index;
  if A < 1 then
    A := 1;
  L := Length(S);
  B := Count;
  if B < 0 then
    B := L
  else
    begin
      B := A + B - 1;
      if B > L then
        B := L;
    end;
  Result := $FFFFFFFF;
  if AsciiCaseSensitive then
    for I := A to B do
      Result := HashCharA(Result, S[I])
  else
    for I := A to B do
      Result := HashCharNoAsciiCaseA(Result, S[I]);
  if Slots > 0 then
    Result := Result mod Slots;
end;

function HashStrW(const S: WideString;
         const Index: Integer; const Count: Integer;
         const AsciiCaseSensitive: Boolean;
         const Slots: LongWord): LongWord;
var I, L, A, B : Integer;
begin
  if not HashTableInit then
    InitHashTable;
  A := Index;
  if A < 1 then
    A := 1;
  L := Length(S);
  B := Count;
  if B < 0 then
    B := L
  else
    begin
      B := A + B - 1;
      if B > L then
        B := L;
    end;
  Result := $FFFFFFFF;
  if AsciiCaseSensitive then
    for I := A to B do
      Result := HashCharW(Result, S[I])
  else
    for I := A to B do
      Result := HashCharNoAsciiCaseW(Result, S[I]);
  if Slots > 0 then
    Result := Result mod Slots;
end;

function HashStrU(const S: UnicodeString;
         const Index: Integer; const Count: Integer;
         const AsciiCaseSensitive: Boolean;
         const Slots: LongWord): LongWord;
var I, L, A, B : Integer;
begin
  if not HashTableInit then
    InitHashTable;
  A := Index;
  if A < 1 then
    A := 1;
  L := Length(S);
  B := Count;
  if B < 0 then
    B := L
  else
    begin
      B := A + B - 1;
      if B > L then
        B := L;
    end;
  Result := $FFFFFFFF;
  if AsciiCaseSensitive then
    for I := A to B do
      Result := HashCharW(Result, S[I])
  else
    for I := A to B do
      Result := HashCharNoAsciiCaseW(Result, S[I]);
  if Slots > 0 then
    Result := Result mod Slots;
end;

function HashStr(const S: String;
         const Index: Integer; const Count: Integer;
         const AsciiCaseSensitive: Boolean;
         const Slots: LongWord): LongWord;
var I, L, A, B : Integer;
begin
  if not HashTableInit then
    InitHashTable;
  A := Index;
  if A < 1 then
    A := 1;
  L := Length(S);
  B := Count;
  if B < 0 then
    B := L
  else
    begin
      B := A + B - 1;
      if B > L then
        B := L;
    end;
  Result := $FFFFFFFF;
  if AsciiCaseSensitive then
    for I := A to B do
      Result := HashChar(Result, S[I])
  else
    for I := A to B do
      Result := HashCharNoAsciiCase(Result, S[I]);
  if Slots > 0 then
    Result := Result mod Slots;
end;

{ HashInteger based on the CRC32 algorithm. It is a very good all purpose hash }
{ with a highly uniform distribution of results.                               }
{$IFDEF ManagedCode}
function HashInteger(const I: Integer; const Slots: LongWord): LongWord;
begin
  if not HashTableInit then
    InitHashTable;
  Result := $FFFFFFFF;
  Result := HashTable[Byte(Result) xor  (I and $000000FF)]         xor (Result shr 8);
  Result := HashTable[Byte(Result) xor ((I and $0000FF00) shr 8)]  xor (Result shr 8);
  Result := HashTable[Byte(Result) xor ((I and $00FF0000) shr 16)] xor (Result shr 8);
  Result := HashTable[Byte(Result) xor ((I and $FF000000) shr 24)] xor (Result shr 8);
  if Slots <> 0 then
    Result := Result mod Slots;
end;
{$ELSE}
function HashInteger(const I: Integer; const Slots: LongWord): LongWord;
var P : PByte;
begin
  if not HashTableInit then
    InitHashTable;
  Result := $FFFFFFFF;
  P := @I;
  Result := HashTable[Byte(Result) xor P^] xor (Result shr 8);
  Inc(P);
  Result := HashTable[Byte(Result) xor P^] xor (Result shr 8);
  Inc(P);
  Result := HashTable[Byte(Result) xor P^] xor (Result shr 8);
  Inc(P);
  Result := HashTable[Byte(Result) xor P^] xor (Result shr 8);
  if Slots <> 0 then
    Result := Result mod Slots;
end;
{$ENDIF}

{$IFDEF ManagedCode}
function HashLongWord(const I: LongWord; const Slots: LongWord): LongWord;
begin
  if not HashTableInit then
    InitHashTable;
  Result := $FFFFFFFF;
  Result := HashTable[Byte(Result) xor  (I and $000000FF)]         xor (Result shr 8);
  Result := HashTable[Byte(Result) xor ((I and $0000FF00) shr 8)]  xor (Result shr 8);
  Result := HashTable[Byte(Result) xor ((I and $00FF0000) shr 16)] xor (Result shr 8);
  Result := HashTable[Byte(Result) xor ((I and $FF000000) shr 24)] xor (Result shr 8);
  if Slots <> 0 then
    Result := Result mod Slots;
end;
{$ELSE}
function HashLongWord(const I: LongWord; const Slots: LongWord): LongWord;
var P : PByte;
begin
  if not HashTableInit then
    InitHashTable;
  Result := $FFFFFFFF;
  P := @I;
  Result := HashTable[Byte(Result) xor P^] xor (Result shr 8);
  Inc(P);
  Result := HashTable[Byte(Result) xor P^] xor (Result shr 8);
  Inc(P);
  Result := HashTable[Byte(Result) xor P^] xor (Result shr 8);
  Inc(P);
  Result := HashTable[Byte(Result) xor P^] xor (Result shr 8);
  if Slots <> 0 then
    Result := Result mod Slots;
end;
{$ENDIF}



{$IFNDEF ManagedCode}
{                                                                              }
{ Memory                                                                       }
{                                                                              }
{$IFDEF UseAsmMemFunction}
procedure FillMem(var Buf; const Count: Integer; const Value: Byte);
asm
      // EAX = Buf, EDX = Count, CL = Value
      OR      EDX, EDX
      JLE     @Fin
      // Set 4 bytes of ECX to Value byte
      MOV     CH, CL
      SHL     ECX, 8
      MOV     CL, CH
      SHL     ECX, 8
      MOV     CL, CH
      CMP     EDX, 16
      JBE     @SmallFillMem
      // General purpose FillMem
    @GeneralFillMem:
      PUSH    EDI
      MOV     EDI, EAX
      MOV     EAX, ECX
      MOV     ECX, EDX
      SHR     ECX, 2
      REP     STOSD
      AND     EDX, 3
      MOV     ECX, EDX
      REP     STOSB
      POP     EDI
      RET
      // FillMem for small blocks
    @SmallFillMem:
      JMP     DWORD PTR @JumpTable[EDX * 4]
    @JumpTable:
      DD      @Fill0,  @Fill1,  @Fill2,  @Fill3
      DD      @Fill4,  @Fill5,  @Fill6,  @Fill7
      DD      @Fill8,  @Fill9,  @Fill10, @Fill11
      DD      @Fill12, @Fill13, @Fill14, @Fill15
      DD      @Fill16
    @Fill16:
      MOV     DWORD PTR [EAX], ECX
      MOV     DWORD PTR [EAX + 4], ECX
      MOV     DWORD PTR [EAX + 8], ECX
      MOV     DWORD PTR [EAX + 12], ECX
      RET
    @Fill15:
      MOV     BYTE PTR [EAX + 14], CL
    @Fill14:
      MOV     DWORD PTR [EAX], ECX
      MOV     DWORD PTR [EAX + 4], ECX
      MOV     DWORD PTR [EAX + 8], ECX
      MOV     WORD PTR [EAX + 12], CX
      RET
    @Fill13:
      MOV     BYTE PTR [EAX + 12], CL
    @Fill12:
      MOV     DWORD PTR [EAX], ECX
      MOV     DWORD PTR [EAX + 4], ECX
      MOV     DWORD PTR [EAX + 8], ECX
      RET
    @Fill11:
      MOV     BYTE PTR [EAX + 10], CL
    @Fill10:
      MOV     DWORD PTR [EAX], ECX
      MOV     DWORD PTR [EAX + 4], ECX
      MOV     WORD PTR [EAX + 8], CX
      RET
    @Fill9:
      MOV     BYTE PTR [EAX + 8], CL
    @Fill8:
      MOV     DWORD PTR [EAX], ECX
      MOV     DWORD PTR [EAX + 4], ECX
      RET
    @Fill7:
      MOV     BYTE PTR [EAX + 6], CL
    @Fill6:
      MOV     DWORD PTR [EAX], ECX
      MOV     WORD PTR [EAX + 4], CX
      RET
    @Fill5:
      MOV     BYTE PTR [EAX + 4], CL
    @Fill4:
      MOV     DWORD PTR [EAX], ECX
      RET
    @Fill3:
      MOV     BYTE PTR [EAX + 2], CL
    @Fill2:
      MOV     WORD PTR [EAX], CX
      RET
    @Fill1:
      MOV     BYTE PTR [EAX], CL
    @Fill0:
    @Fin:
end;
{$ELSE}
procedure FillMem(var Buf; const Count: Integer; const Value: Byte);
begin
  FillChar(Buf, Count, Value);
end;
{$ENDIF}

{$IFDEF UseAsmMemFunction}
procedure ZeroMem(var Buf; const Count: Integer);
asm
    // EAX = Buf, EDX = Count
    OR     EDX, EDX
    JLE    @Zero0
    CMP    EDX, 16
    JA     @GeneralZeroMem
    XOR    ECX, ECX
    JMP    DWORD PTR @SmallZeroJumpTable[EDX * 4]
  @SmallZeroJumpTable:
    DD     @Zero0,  @Zero1,  @Zero2,  @Zero3
    DD     @Zero4,  @Zero5,  @Zero6,  @Zero7
    DD     @Zero8,  @Zero9,  @Zero10, @Zero11
    DD     @Zero12, @Zero13, @Zero14, @Zero15
    DD     @Zero16
  @Zero16:
    MOV    DWORD PTR [EAX], ECX
    MOV    DWORD PTR [EAX + 4], ECX
    MOV    DWORD PTR [EAX + 8], ECX
    MOV    DWORD PTR [EAX + 12], ECX
    RET
  @Zero15:
    MOV    BYTE PTR [EAX + 14], CL
  @Zero14:
    MOV    DWORD PTR [EAX], ECX
    MOV    DWORD PTR [EAX + 4], ECX
    MOV    DWORD PTR [EAX + 8], ECX
    MOV    WORD PTR [EAX + 12], CX
    RET
  @Zero13:
    MOV    BYTE PTR [EAX + 12], CL
  @Zero12:
    MOV    DWORD PTR [EAX], ECX
    MOV    DWORD PTR [EAX + 4], ECX
    MOV    DWORD PTR [EAX + 8], ECX
    RET
  @Zero11:
    MOV    BYTE PTR [EAX + 10], CL
  @Zero10:
    MOV    DWORD PTR [EAX], ECX
    MOV    DWORD PTR [EAX + 4], ECX
    MOV    WORD PTR [EAX + 8], CX
    RET
  @Zero9:
    MOV    BYTE PTR [EAX + 8], CL
  @Zero8:
    MOV    DWORD PTR [EAX], ECX
    MOV    DWORD PTR [EAX + 4], ECX
    RET
  @Zero7:
    MOV    BYTE PTR [EAX + 6], CL
  @Zero6:
    MOV    DWORD PTR [EAX], ECX
    MOV    WORD PTR [EAX + 4], CX
    RET
  @Zero5:
    MOV    BYTE PTR [EAX + 4], CL
  @Zero4:
    MOV    DWORD PTR [EAX], ECX
    RET
  @Zero3:
    MOV    BYTE PTR [EAX + 2], CL
  @Zero2:
    MOV    WORD PTR [EAX], CX
    RET
  @Zero1:
    MOV    BYTE PTR [EAX], CL
  @Zero0:
    RET
  @GeneralZeroMem:
    PUSH   EDI
    MOV    EDI, EAX
    XOR    EAX, EAX
    MOV    ECX, EDX
    SHR    ECX, 2
    REP    STOSD
    MOV    ECX, EDX
    AND    ECX, 3
    REP    STOSB
    POP    EDI
end;
{$ELSE}
procedure ZeroMem(var Buf; const Count: Integer);
begin
  FillChar(Buf, Count, #0);
end;
{$ENDIF}

procedure GetZeroMem(var P: Pointer; const Size: Integer);
begin
  GetMem(P, Size);
  ZeroMem(P^, Size);
end;

{$IFDEF UseAsmMemFunction}
{ Note: MoveMem implements a "safe move", that is, the Source and Dest memory  }
{ blocks are allowed to overlap.                                               }
procedure MoveMem(const Source; var Dest; const Count: Integer);
asm
    // EAX = Source, EDX = Dest, ECX = Count
    OR     ECX, ECX
    JLE    @Move0
    CMP    EAX, EDX
    JE     @Move0
    JB     @CheckSafe
  @GeneralMove:
    CMP    ECX, 16
    JA     @LargeMove
    JMP    DWORD PTR @SmallMoveJumpTable[ECX * 4]
  @CheckSafe:
    ADD    EAX, ECX
    CMP    EAX, EDX
    JBE    @IsSafe
  @NotSafe:
    SUB    EAX, ECX
    CMP    ECX, 10
    JA     @LargeMoveReverse
    JMP    DWORD PTR @SmallMoveJumpTable[ECX * 4]
  @IsSafe:
    SUB    EAX, ECX
    CMP    ECX, 16
    JA     @LargeMove
    JMP    DWORD PTR @SmallMoveJumpTable[ECX * 4]
  @SmallMoveJumpTable:
    DD     @Move0,  @Move1,  @Move2,  @Move3
    DD     @Move4,  @Move5,  @Move6,  @Move7
    DD     @Move8,  @Move9,  @Move10, @Move11
    DD     @Move12, @Move13, @Move14, @Move15
    DD     @Move16
  @Move16:
    PUSH   EBX
    MOV    ECX, [EAX]
    MOV    EBX, [EAX + 4]
    MOV    [EDX],      ECX
    MOV    [EDX + 4],  EBX
    MOV    ECX, [EAX + 8]
    MOV    EBX, [EAX + 12]
    MOV    [EDX + 8],  ECX
    MOV    [EDX + 12], EBX
    POP    EBX
    RET
  @Move15:
    PUSH   EBX
    MOV    ECX, [EAX]
    MOV    EBX, [EAX + 4]
    MOV    [EDX],      ECX
    MOV    [EDX + 4],  EBX
    MOV    ECX, [EAX + 8]
    MOV    BX,  [EAX + 12]
    MOV    AL,  [EAX + 14]
    MOV    [EDX + 8],  ECX
    MOV    [EDX + 12], BX
    MOV    [EDX + 14], AL
    POP    EBX
    RET
  @Move14:
    PUSH   EBX
    MOV    ECX, [EAX]
    MOV    EBX, [EAX + 4]
    MOV    [EDX],      ECX
    MOV    [EDX + 4],  EBX
    MOV    ECX, [EAX + 8]
    MOV    BX,  [EAX + 12]
    MOV    [EDX + 8],  ECX
    MOV    [EDX + 12], BX
    POP    EBX
    RET
  @Move13:
    PUSH   EBX
    MOV    ECX, [EAX]
    MOV    EBX, [EAX + 4]
    MOV    [EDX],      ECX
    MOV    [EDX + 4],  EBX
    MOV    ECX, [EAX + 8]
    MOV    BL,  [EAX + 12]
    MOV    [EDX + 8],  ECX
    MOV    [EDX + 12], BL
    POP    EBX
    RET
  @Move12:
    PUSH   EBX
    MOV    ECX, [EAX]
    MOV    EBX, [EAX + 4]
    MOV    EAX, [EAX + 8]
    MOV    [EDX],     ECX
    MOV    [EDX + 4], EBX
    MOV    [EDX + 8], EAX
    POP    EBX
    RET
  @Move11:
    PUSH   EBX
    MOV    ECX, [EAX]
    MOV    EBX, [EAX + 4]
    MOV    [EDX],      ECX
    MOV    [EDX + 4],  EBX
    MOV    CX,  [EAX + 8]
    MOV    BL,  [EAX + 10]
    MOV    [EDX + 8],  CX
    MOV    [EDX + 10], BL
    POP    EBX
    RET
  @Move10:
    PUSH   EBX
    MOV    ECX, [EAX]
    MOV    EBX, [EAX + 4]
    MOV    AX,  [EAX + 8]
    MOV    [EDX],     ECX
    MOV    [EDX + 4], EBX
    MOV    [EDX + 8], AX
    POP    EBX
    RET
  @Move9:
    PUSH   EBX
    MOV    ECX, [EAX]
    MOV    EBX, [EAX + 4]
    MOV    AL,  [EAX + 8]
    MOV    [EDX],     ECX
    MOV    [EDX + 4], EBX
    MOV    [EDX + 8], AL
    POP    EBX
    RET
  @Move8:
    MOV    ECX, [EAX]
    MOV    EAX, [EAX + 4]
    MOV    [EDX],     ECX
    MOV    [EDX + 4], EAX
    RET
  @Move7:
    PUSH   EBX
    MOV    ECX, [EAX]
    MOV    BX,  [EAX + 4]
    MOV    AL,  [EAX + 6]
    MOV    [EDX],     ECX
    MOV    [EDX + 4], BX
    MOV    [EDX + 6], AL
    POP    EBX
    RET
  @Move6:
    MOV    ECX, [EAX]
    MOV    AX,  [EAX + 4]
    MOV    [EDX],     ECX
    MOV    [EDX + 4], AX
    RET
  @Move5:
    MOV    ECX, [EAX]
    MOV    AL,  [EAX + 4]
    MOV    [EDX],     ECX
    MOV    [EDX + 4], AL
    RET
  @Move4:
    MOV    ECX, [EAX]
    MOV    [EDX], ECX
    RET
  @Move3:
    MOV    CX, [EAX]
    MOV    AL, [EAX + 2]
    MOV    [EDX],     CX
    MOV    [EDX + 2], AL
    RET
  @Move2:
    MOV    CX, [EAX]
    MOV    [EDX], CX
    RET
  @Move1:
    MOV    CL, [EAX]
    MOV    [EDX], CL
  @Move0:
    RET
  @LargeMove:
    PUSH   ESI
    PUSH   EDI
    MOV    ESI, EAX
    MOV    EDI, EDX
    MOV    EDX, ECX
    SHR    ECX, 2
    REP    MOVSD
    MOV    ECX, EDX
    AND    ECX, 3
    REP    MOVSB
    POP    EDI
    POP    ESI
    RET
  @LargeMoveReverse:
    PUSH   ESI
    PUSH   EDI
    MOV    ESI, EAX
    MOV    EDI, EDX
    LEA    ESI, [ESI + ECX - 4]
    LEA    EDI, [EDI + ECX - 4]
    MOV    EDX, ECX
    SHR    ECX, 2
    STD
    REP    MOVSD
    ADD    ESI, 3
    ADD    EDI, 3
    MOV    ECX, EDX
    AND    ECX, 3
    REP    MOVSB
    CLD
    POP    EDI
    POP    ESI
end;
{$ELSE}
procedure MoveMem(const Source; var Dest; const Count: Integer);
begin
  Move(Source, Dest, Count);
end;
{$ENDIF}

{$IFDEF ASM386_DELPHI}
function CompareMem(const Buf1; const Buf2; const Count: Integer): Boolean;
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
function CompareMem(const Buf1; const Buf2; const Count: Integer): Boolean;
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

function CompareMemNoCase(const Buf1; const Buf2; const Count: Integer): TCompareResult;
var P, Q : Pointer;
    I    : Integer;
    C, D : Byte;
begin
  if Count <= 0 then
    begin
      Result := crEqual;
      exit;
    end;
  P := @Buf1;
  Q := @Buf2;
  for I := 1 to Count do
    begin
      C := PByte(P)^;
      D := PByte(Q)^;
      if C in [Ord('A')..Ord('Z')] then
        C := C or 32;
      if D in [Ord('A')..Ord('Z')] then
        D := D or 32;
      if C = D then
        begin
          Inc(PByte(P));
          Inc(PByte(Q));
        end
      else
        begin
          if C < D then
            Result := crLess
          else
            Result := crGreater;
          exit;
        end;
    end;
  Result := crEqual;
end;

function LocateMem(const Buf1; const Size1: Integer; const Buf2; const Size2: Integer): Integer;
var P, Q : PByte;
    I    : Integer;
begin
  if (Size1 <= 0) or (Size2 <= 0) or (Size2 > Size1) then
    begin
      Result := -1;
      exit;
    end;
  for I := 0 to Size1 - Size2 do
    begin
      P := @Buf1;
      Inc(P, I);
      Q := @Buf2;
      if P = Q then
        begin
          Result := I;
          exit;
        end;
      if CompareMem(P^, Q^, Size2) then
        begin
          Result := I;
          exit;
        end;
    end;
  Result := -1;
end;

procedure ReverseMem(var Buf; const Size: Integer);
var I : Integer;
    P : PByte;
    Q : PByte;
    T : Byte;
begin
  P := @Buf;
  Q := P;
  Inc(Q, Size - 1);
  for I := 1 to Size div 2 do
    begin
      T := P^;
      P^ := Q^;
      Q^ := T;
      Inc(P);
      Dec(Q);
    end;
end;
{$ENDIF}



{                                                                              }
{ FreeAndNil                                                                   }
{                                                                              }
{$IFDEF ManagedCode}
procedure FreeAndNil(var Obj: TObject);
var Temp : TObject;
begin
  Temp := Obj;
  Obj := nil;
  Temp.Free;
end;
{$ELSE}
procedure FreeAndNil(var Obj);
var Temp : TObject;
begin
  Temp := TObject(Obj);
  Pointer(Obj) := nil;
  Temp.Free;
end;
{$ENDIF}

{$IFDEF ManagedCode}
procedure FreeObjectArray(var V: ObjectArray);
var I : Integer;
begin
  for I := Length(V) - 1 downto 0 do
    FreeAndNil(V[I]);
end;

procedure FreeObjectArray(var V: ObjectArray; const LoIdx, HiIdx: Integer);
var I : Integer;
begin
  for I := HiIdx downto LoIdx do
    FreeAndNil(V[I]);
end;
{$ELSE}
procedure FreeObjectArray(var V);
var I : Integer;
    A : ObjectArray absolute V;
begin
  for I := Length(A) - 1 downto 0 do
    FreeAndNil(A[I]);
end;

procedure FreeObjectArray(var V; const LoIdx, HiIdx: Integer);
var I : Integer;
    A : ObjectArray absolute V;
begin
  for I := HiIdx downto LoIdx do
    FreeAndNil(A[I]);
end;
{$ENDIF}

// Note: The parameter can not be changed to be untyped and then typecasted
// using an absolute variable, as in FreeObjectArray. The reference counting
// will be done incorrectly.
procedure FreeAndNilObjectArray(var V: ObjectArray);
var W : ObjectArray;
begin
  W := V;
  V := nil;
  FreeObjectArray(W);
end;



{                                                                              }
{ Test cases                                                                   }
{                                                                              }
{$IFDEF UTILS_SELFTEST}
{$ASSERTIONS ON}
procedure Test_Misc;
var L, H : Cardinal;
    A, B : Byte;
    C, D : LongWord;
    P, Q : TObject;
begin
  // Integer types
  {$IFNDEF ManagedCode}
  Assert(Sizeof(SmallIntRec) = Sizeof(SmallInt), 'SmallIntRec');
  Assert(Sizeof(LongIntRec) = Sizeof(LongInt),   'LongIntRec');
  {$ENDIF}

  // Min / Max
  Assert(MinI(-1, 1) = -1, 'MinI');
  Assert(MaxI(-1, 1) = 1, 'MaxI');
  Assert(MinC(1, 2) = 1, 'MinC');
  Assert(MaxC(1, 2) = 2, 'MaxC');
  Assert(MaxC($FFFFFFFF, 0) = $FFFFFFFF, 'MaxC');
  Assert(MinC($FFFFFFFF, 0) = 0, 'MinC');
  Assert(FloatMin(-1.0, 1.0) = -1.0, 'FloatMin');
  Assert(FloatMax(-1.0, 1.0) = 1.0, 'FloatMax');

  // Clip
  Assert(Clip(10, 5, 12) = 10,                            'Clip');
  Assert(Clip(3, 5, 12) = 5,                              'Clip');
  Assert(Clip(15, 5, 12) = 12,                            'Clip');
  Assert(ClipByte(256) = 255,                             'ClipByte');
  Assert(ClipWord(-5) = 0,                                'ClipWord');
  Assert(ClipLongWord($100000000) = $FFFFFFFF,            'ClipWord');
  Assert(SumClipI(1, 2) = 3,                              'SumClipI');
  Assert(SumClipI(1, -2) = -1,                            'SumClipI');
  Assert(SumClipI(MaxInteger - 1, 0) = MaxInteger - 1,    'SumClipI');
  Assert(SumClipI(MaxInteger - 1, 1) = MaxInteger,        'SumClipI');
  Assert(SumClipI(MaxInteger - 1, 2) = MaxInteger,        'SumClipI');
  Assert(SumClipI(MinInteger + 1, 0) = MinInteger + 1,    'SumClipI');
  Assert(SumClipI(MinInteger + 1, -1) = MinInteger,       'SumClipI');
  Assert(SumClipI(MinInteger + 1, -2) = MinInteger,       'SumClipI');
  Assert(SumClipC(1, 2) = 3,                              'SumClipC');
  Assert(SumClipC(3, -2) = 1,                             'SumClipC');
  Assert(SumClipC(MaxCardinal - 1, 0) = MaxCardinal - 1,  'SumClipC');
  Assert(SumClipC(MaxCardinal - 1, 1) = MaxCardinal,      'SumClipC');
  Assert(SumClipC(MaxCardinal - 1, 2) = MaxCardinal,      'SumClipC');
  Assert(SumClipC(1, 0) = 1,                              'SumClipC');
  Assert(SumClipC(1, -1) = 0,                             'SumClipC');
  Assert(SumClipC(1, -2) = 0,                             'SumClipC');

  // Swap
  A := $11; B := $22;
  Swap(A, B);
  Assert((A = $22) and (B = $11),              'Swap');
  C := $11111111; D := $22222222;
  Swap(C, D);
  Assert((C = $22222222) and (D = $11111111),  'Swap');
  P := TObject.Create;
  Q := nil;
  SwapObjects(P, Q);
  Assert(Assigned(Q) and not Assigned(P),      'SwapObjects');
  Q.Free;

  // Ranges
  L := 10;
  H := 20;
  Assert(CardRangeIncludeElementRange(L, H, 10, 20),     'RangeInclude');
  Assert((L = 10) and (H = 20),                          'RangeInclude');
  Assert(CardRangeIncludeElementRange(L, H, 9, 21),      'RangeInclude');
  Assert((L = 9) and (H = 21),                           'RangeInclude');
  Assert(CardRangeIncludeElementRange(L, H, 7, 10),      'RangeInclude');
  Assert((L = 7) and (H = 21),                           'RangeInclude');
  Assert(CardRangeIncludeElementRange(L, H, 5, 6),       'RangeInclude');
  Assert((L = 5) and (H = 21),                           'RangeInclude');
  Assert(not CardRangeIncludeElementRange(L, H, 1, 3),   'RangeInclude');
  Assert((L = 5) and (H = 21),                           'RangeInclude');
  Assert(CardRangeIncludeElementRange(L, H, 20, 22),     'RangeInclude');
  Assert((L = 5) and (H = 22),                           'RangeInclude');
  Assert(CardRangeIncludeElementRange(L, H, 23, 24),     'RangeInclude');
  Assert((L = 5) and (H = 24),                           'RangeInclude');
  Assert(not CardRangeIncludeElementRange(L, H, 26, 27), 'RangeInclude');
  Assert((L = 5) and (H = 24),                               'RangeInclude');

  // iif
  Assert(iif(True, 1, 2) = 1,         'iif');
  Assert(iif(False, 1, 2) = 2,        'iif');
  Assert(iif(True, -1, -2) = -1,      'iif');
  Assert(iif(False, -1, -2) = -2,     'iif');
  Assert(iif(True, '1', '2') = '1',   'iif');
  Assert(iif(False, '1', '2') = '2',  'iif');
  Assert(iifW(True, '1', '2') = '1',  'iif');
  Assert(iifW(False, '1', '2') = '2', 'iif');
  Assert(iifU(True, '1', '2') = '1',  'iif');
  Assert(iifU(False, '1', '2') = '2', 'iif');
  Assert(iif(True, 1.1, 2.2) = 1.1,   'iif');
  Assert(iif(False, 1.1, 2.2) = 2.2,  'iif');

  // CharSet
  Assert(CharCount([]) = 0,           'CharCount');
  Assert(CharCount(['a'..'z']) = 26,  'CharCount');
  Assert(CharCount([#0, #255]) = 2,   'CharCount');

  // Compare
  Assert(Compare(1, 1) = crEqual,          'Compare');
  Assert(Compare(1, 2) = crLess,           'Compare');
  Assert(Compare(1, 0) = crGreater,        'Compare');

  Assert(Compare(1.0, 1.0) = crEqual,      'Compare');
  Assert(Compare(1.0, 1.1) = crLess,       'Compare');
  Assert(Compare(1.0, 0.9) = crGreater,    'Compare');

  Assert(Compare(False, False) = crEqual,  'Compare');
  Assert(Compare(True, True) = crEqual,    'Compare');
  Assert(Compare(False, True) = crLess,    'Compare');
  Assert(Compare(True, False) = crGreater, 'Compare');

  Assert(CompareA('', '') = crEqual,        'Compare');
  Assert(CompareA('a', 'a') = crEqual,      'Compare');
  Assert(CompareA('a', 'b') = crLess,       'Compare');
  Assert(CompareA('b', 'a') = crGreater,    'Compare');
  Assert(CompareA('', 'a') = crLess,        'Compare');
  Assert(CompareA('a', '') = crGreater,     'Compare');
  Assert(CompareA('aa', 'a') = crGreater,   'Compare');

  Assert(CompareB('', '') = crEqual,        'Compare');
  Assert(CompareB('a', 'a') = crEqual,      'Compare');
  Assert(CompareB('a', 'b') = crLess,       'Compare');
  Assert(CompareB('b', 'a') = crGreater,    'Compare');
  Assert(CompareB('', 'a') = crLess,        'Compare');
  Assert(CompareB('a', '') = crGreater,     'Compare');
  Assert(CompareB('aa', 'a') = crGreater,   'Compare');

  Assert(CompareW('', '') = crEqual,        'Compare');
  Assert(CompareW('a', 'a') = crEqual,      'Compare');
  Assert(CompareW('a', 'b') = crLess,       'Compare');
  Assert(CompareW('b', 'a') = crGreater,    'Compare');
  Assert(CompareW('', 'a') = crLess,        'Compare');
  Assert(CompareW('a', '') = crGreater,     'Compare');
  Assert(CompareW('aa', 'a') = crGreater,   'Compare');

  Assert(Sgn(1) = 1,     'Sign');
  Assert(Sgn(0) = 0,     'Sign');
  Assert(Sgn(-1) = -1,   'Sign');
  Assert(Sgn(2) = 1,     'Sign');
  Assert(Sgn(-2) = -1,   'Sign');
  Assert(Sgn(-1.5) = -1, 'Sign');
  Assert(Sgn(1.5) = 1,   'Sign');
  Assert(Sgn(0.0) = 0,   'Sign');

  Assert(ReverseCompareResult(crLess) = crGreater, 'ReverseCompareResult');
  Assert(ReverseCompareResult(crGreater) = crLess, 'ReverseCompareResult');
end;

procedure Test_BitFunctions;
begin
  Assert(SetBit($100F, 5) = $102F,            'SetBit');
  Assert(ClearBit($102F, 5) = $100F,          'ClearBit');
  Assert(ToggleBit($102F, 5) = $100F,         'ToggleBit');
  Assert(ToggleBit($100F, 5) = $102F,         'ToggleBit');
  Assert(IsBitSet($102F, 5),                  'IsBitSet');
  Assert(not IsBitSet($100F, 5),              'IsBitSet');
  Assert(IsHighBitSet($80000000),             'IsHighBitSet');
  Assert(not IsHighBitSet($00000001),         'IsHighBitSet');
  Assert(not IsHighBitSet($7FFFFFFF),         'IsHighBitSet');

  Assert(SetBitScanForward(0) = -1,           'SetBitScanForward');
  Assert(SetBitScanForward($1020) = 5,        'SetBitScanForward');
  Assert(SetBitScanReverse($1020) = 12,       'SetBitScanForward');
  Assert(SetBitScanForward($1020, 6) = 12,    'SetBitScanForward');
  Assert(SetBitScanReverse($1020, 11) = 5,    'SetBitScanForward');
  Assert(ClearBitScanForward($FFFFFFFF) = -1, 'ClearBitScanForward');
  Assert(ClearBitScanForward($1020) = 0,      'ClearBitScanForward');
  Assert(ClearBitScanReverse($1020) = 31,     'ClearBitScanForward');
  Assert(ClearBitScanForward($1020, 5) = 6,   'ClearBitScanForward');
  Assert(ClearBitScanReverse($1020, 12) = 11, 'ClearBitScanForward');

  Assert(ReverseBits($12345678) = $1E6A2C48,  'ReverseBits');
  Assert(ReverseBits($1) = $80000000,         'ReverseBits');
  Assert(ReverseBits($80000000) = $1,         'ReverseBits');
  Assert(SwapEndian($12345678) = $78563412,   'SwapEndian');

  Assert(BitCount($12341234) = 10,            'BitCount');
  Assert(IsPowerOfTwo(1),                     'IsPowerOfTwo');
  Assert(IsPowerOfTwo(2),                     'IsPowerOfTwo');
  Assert(not IsPowerOfTwo(3),                 'IsPowerOfTwo');

  Assert(RotateLeftBits32(0, 1) = 0,          'RotateLeftBits32');
  Assert(RotateLeftBits32(1, 0) = 1,          'RotateLeftBits32');
  Assert(RotateLeftBits32(1, 1) = 2,          'RotateLeftBits32');
  Assert(RotateLeftBits32($80000000, 1) = 1,  'RotateLeftBits32');
  Assert(RotateLeftBits32($80000001, 1) = 3,  'RotateLeftBits32');
  Assert(RotateLeftBits32(1, 2) = 4,          'RotateLeftBits32');
  Assert(RotateLeftBits32(1, 31) = $80000000, 'RotateLeftBits32');
  Assert(RotateLeftBits32(5, 2) = 20,         'RotateLeftBits32');
  Assert(RotateRightBits32(0, 1) = 0,         'RotateRightBits32');
  Assert(RotateRightBits32(1, 0) = 1,         'RotateRightBits32');
  Assert(RotateRightBits32(1, 1) = $80000000, 'RotateRightBits32');
  Assert(RotateRightBits32(2, 1) = 1,         'RotateRightBits32');
  Assert(RotateRightBits32(4, 2) = 1,         'RotateRightBits32');

  Assert(LowBitMask(10) = $3FF,               'LowBitMask');
  Assert(HighBitMask(28) = $F0000000,         'HighBitMask');
  Assert(RangeBitMask(2, 6) = $7C,            'RangeBitMask');

  Assert(SetBitRange($101, 2, 6) = $17D,      'SetBitRange');
  Assert(ClearBitRange($17D, 2, 6) = $101,    'ClearBitRange');
  Assert(ToggleBitRange($17D, 2, 6) = $101,   'ToggleBitRange');
  Assert(IsBitRangeSet($17D, 2, 6),           'IsBitRangeSet');
  Assert(not IsBitRangeSet($101, 2, 6),       'IsBitRangeSet');
  Assert(not IsBitRangeClear($17D, 2, 6),     'IsBitRangeClear');
  Assert(IsBitRangeClear($101, 2, 6),         'IsBitRangeClear');
end;

procedure Test_Float;
{$IFNDEF ExtendedIsDouble}
var E : Integer;
{$ENDIF}
begin
  Assert(not FloatZero(1e-1, 1e-2),   'FloatZero');
  Assert(FloatZero(1e-2, 1e-2),       'FloatZero');
  Assert(not FloatZero(1e-1, 1e-9),   'FloatZero');
  Assert(not FloatZero(1e-8, 1e-9),   'FloatZero');
  Assert(FloatZero(1e-9, 1e-9),       'FloatZero');
  Assert(FloatZero(1e-10, 1e-9),      'FloatZero');
  Assert(not FloatZero(0.2, 1e-1),    'FloatZero');
  Assert(FloatZero(0.09, 1e-1),       'FloatZero');

  Assert(FloatOne(1.0, 1e-1),         'FloatOne');
  Assert(FloatOne(1.09999, 1e-1),     'FloatOne');
  Assert(FloatOne(0.90001, 1e-1),     'FloatOne');
  Assert(not FloatOne(1.10001, 1e-1), 'FloatOne');
  Assert(not FloatOne(1.2, 1e-1),     'FloatOne');
  Assert(not FloatOne(0.89999, 1e-1), 'FloatOne');

  Assert(not FloatsEqual(2.0, -2.0, 1e-1),             'FloatsEqual');
  Assert(not FloatsEqual(1.0, 0.0, 1e-1),              'FloatsEqual');
  Assert(FloatsEqual(2.0, 2.0, 1e-1),                  'FloatsEqual');
  Assert(FloatsEqual(2.0, 2.09, 1e-1),                 'FloatsEqual');
  Assert(FloatsEqual(2.0, 1.90000001, 1e-1),           'FloatsEqual');
  Assert(not FloatsEqual(2.0, 2.10001, 1e-1),          'FloatsEqual');
  Assert(not FloatsEqual(2.0, 2.2, 1e-1),              'FloatsEqual');
  Assert(not FloatsEqual(2.0, 1.8999999, 1e-1),        'FloatsEqual');
  Assert(FloatsEqual(2.00000000011, 2.0, 1e-2),        'FloatsEqual');
  Assert(FloatsEqual(2.00000000011, 2.0, 1e-9),        'FloatsEqual');
  Assert(not FloatsEqual(2.00000000011, 2.0, 1e-10),   'FloatsEqual');
  Assert(not FloatsEqual(2.00000000011, 2.0, 1e-11),   'FloatsEqual');

  {$IFNDEF ExtendedIsDouble}
  Assert(FloatsCompare(0.0, 0.0, MinExtended) = crEqual,  'FloatsCompare');
  Assert(FloatsCompare(1.2, 1.2, MinExtended) = crEqual,  'FloatsCompare');
  Assert(FloatsCompare(1.23456789e-300, 1.23456789e-300, MinExtended) = crEqual, 'FloatsCompare');
  Assert(FloatsCompare(1.23456780e-300, 1.23456789e-300, MinExtended) = crLess,  'FloatsCompare');
  {$ENDIF}
  Assert(FloatsCompare(1.4e-5, 1.5e-5, 1e-4) = crEqual,   'FloatsCompare');
  Assert(FloatsCompare(1.4e-5, 1.5e-5, 1e-5) = crEqual,   'FloatsCompare');
  Assert(FloatsCompare(1.4e-5, 1.5e-5, 1e-6) = crLess,    'FloatsCompare');
  Assert(FloatsCompare(1.4e-5, 1.5e-5, 1e-7) = crLess,    'FloatsCompare');
  Assert(FloatsCompare(0.5003, 0.5001, 1e-1) = crEqual,   'FloatsCompare');
  Assert(FloatsCompare(0.5003, 0.5001, 1e-2) = crEqual,   'FloatsCompare');
  Assert(FloatsCompare(0.5003, 0.5001, 1e-3) = crEqual,   'FloatsCompare');
  Assert(FloatsCompare(0.5003, 0.5001, 1e-4) = crGreater, 'FloatsCompare');
  Assert(FloatsCompare(0.5003, 0.5001, 1e-5) = crGreater, 'FloatsCompare');

  {$IFNDEF ExtendedIsDouble}
  Assert(ExtendedApproxEqual(0.0, 0.0),                                'ExtendedApproxEqual');
  Assert(not ExtendedApproxEqual(0.0, 1e-100, 1e-10),                  'ExtendedApproxEqual');
  Assert(not ExtendedApproxEqual(1.0, 1e-100, 1e-10),                  'ExtendedApproxEqual');
  Assert(ExtendedApproxEqual(1.0, 1.0),                                'ExtendedApproxEqual');
  Assert(ExtendedApproxEqual(-1.0, -1.0),                              'ExtendedApproxEqual');
  Assert(not ExtendedApproxEqual(1.0, -1.0),                           'ExtendedApproxEqual');
  Assert(ExtendedApproxEqual(1e-100, 1e-100, 1e-10),                   'ExtendedApproxEqual');
  Assert(not ExtendedApproxEqual(0.0, 1.0, 1e-9),                      'ExtendedApproxEqual');
  Assert(not ExtendedApproxEqual(-1.0, 1.0, 1e-9),                     'ExtendedApproxEqual');
  Assert(ExtendedApproxEqual(0.12345, 0.12349, 1e-3),                  'ExtendedApproxEqual');
  Assert(not ExtendedApproxEqual(0.12345, 0.12349, 1e-4),              'ExtendedApproxEqual');
  Assert(not ExtendedApproxEqual(0.12345, 0.12349, 1e-5),              'ExtendedApproxEqual');
  Assert(ExtendedApproxEqual(1.2345e+100, 1.2349e+100, 1e-3),          'ExtendedApproxEqual');
  Assert(not ExtendedApproxEqual(1.2345e+100, 1.2349e+100, 1e-4),      'ExtendedApproxEqual');
  Assert(not ExtendedApproxEqual(1.2345e+100, 1.2349e+100, 1e-5),      'ExtendedApproxEqual');
  Assert(ExtendedApproxEqual(1.2345e-100, 1.2349e-100, 1e-3),          'ExtendedApproxEqual');
  Assert(not ExtendedApproxEqual(1.2345e-100, 1.2349e-100, 1e-4),      'ExtendedApproxEqual');
  Assert(not ExtendedApproxEqual(1.2345e-100, 1.2349e-100, 1e-5),      'ExtendedApproxEqual');
  Assert(not ExtendedApproxEqual(1.0e+20, 1.00000001E+20, 1e-8),       'ExtendedApproxEqual');
  Assert(ExtendedApproxEqual(1.0e+20, 1.000000001E+20, 1e-8),          'ExtendedApproxEqual');
  Assert(not ExtendedApproxEqual(1.0e+20, 1.000000001E+20, 1e-9),      'ExtendedApproxEqual');
  Assert(ExtendedApproxEqual(1.0e+20, 1.0000000001E+20, 1e-9),         'ExtendedApproxEqual');
  Assert(not ExtendedApproxEqual(1.0e+20, 1.0000000001E+20, 1e-10),    'ExtendedApproxEqual');

  Assert(ExtendedApproxCompare(0.0, 0.0) = crEqual,                         'ExtendedApproxCompare');
  Assert(ExtendedApproxCompare(0.0, 1.0) = crLess,                          'ExtendedApproxCompare');
  Assert(ExtendedApproxCompare(1.0, 0.0) = crGreater,                       'ExtendedApproxCompare');
  Assert(ExtendedApproxCompare(-1.0, 1.0) = crLess,                         'ExtendedApproxCompare');
  Assert(ExtendedApproxCompare(1.2345e+10, 1.2349e+10, 1e-3) = crEqual,     'ExtendedApproxCompare');
  Assert(ExtendedApproxCompare(1.2345e+10, 1.2349e+10, 1e-4) = crLess,      'ExtendedApproxCompare');
  Assert(ExtendedApproxCompare(-1.2345e-10, -1.2349e-10, 1e-3) = crEqual,   'ExtendedApproxCompare');
  Assert(ExtendedApproxCompare(-1.2345e-10, -1.2349e-10, 1e-4) = crGreater, 'ExtendedApproxCompare');
  {$ENDIF}

  Assert(FloatApproxEqual(0.0, 0.0),                                'FloatApproxEqual');
  Assert(not FloatApproxEqual(0.0, 1e-100, 1e-10),                  'FloatApproxEqual');
  Assert(not FloatApproxEqual(1.0, 1e-100, 1e-10),                  'FloatApproxEqual');
  Assert(FloatApproxEqual(1.0, 1.0),                                'FloatApproxEqual');
  Assert(FloatApproxEqual(-1.0, -1.0),                              'FloatApproxEqual');
  Assert(not FloatApproxEqual(1.0, -1.0),                           'FloatApproxEqual');
  Assert(FloatApproxEqual(1e-100, 1e-100, 1e-10),                   'FloatApproxEqual');
  Assert(not FloatApproxEqual(0.0, 1.0, 1e-9),                      'FloatApproxEqual');
  Assert(not FloatApproxEqual(-1.0, 1.0, 1e-9),                     'FloatApproxEqual');
  Assert(FloatApproxEqual(0.12345, 0.12349, 1e-3),                  'FloatApproxEqual');
  Assert(not FloatApproxEqual(0.12345, 0.12349, 1e-4),              'FloatApproxEqual');
  Assert(not FloatApproxEqual(0.12345, 0.12349, 1e-5),              'FloatApproxEqual');
  Assert(FloatApproxEqual(1.2345e+100, 1.2349e+100, 1e-3),          'FloatApproxEqual');
  Assert(not FloatApproxEqual(1.2345e+100, 1.2349e+100, 1e-4),      'FloatApproxEqual');
  Assert(not FloatApproxEqual(1.2345e+100, 1.2349e+100, 1e-5),      'FloatApproxEqual');
  Assert(FloatApproxEqual(1.2345e-100, 1.2349e-100, 1e-3),          'FloatApproxEqual');
  Assert(not FloatApproxEqual(1.2345e-100, 1.2349e-100, 1e-4),      'FloatApproxEqual');
  Assert(not FloatApproxEqual(1.2345e-100, 1.2349e-100, 1e-5),      'FloatApproxEqual');
  // Assert(not FloatApproxEqual(1.0e+20, 1.00000001E+20, 1e-8),       'FloatApproxEqual');
  Assert(FloatApproxEqual(1.0e+20, 1.000000001E+20, 1e-8),          'FloatApproxEqual');
  // Assert(not FloatApproxEqual(1.0e+20, 1.000000001E+20, 1e-9),      'FloatApproxEqual');
  Assert(FloatApproxEqual(1.0e+20, 1.0000000001E+20, 1e-9),         'FloatApproxEqual');
  // Assert(not FloatApproxEqual(1.0e+20, 1.0000000001E+20, 1e-10),    'FloatApproxEqual');

  Assert(FloatApproxCompare(0.0, 0.0) = crEqual,                         'FloatApproxCompare');
  Assert(FloatApproxCompare(0.0, 1.0) = crLess,                          'FloatApproxCompare');
  Assert(FloatApproxCompare(1.0, 0.0) = crGreater,                       'FloatApproxCompare');
  Assert(FloatApproxCompare(-1.0, 1.0) = crLess,                         'FloatApproxCompare');
  Assert(FloatApproxCompare(1.2345e+10, 1.2349e+10, 1e-3) = crEqual,     'FloatApproxCompare');
  Assert(FloatApproxCompare(1.2345e+10, 1.2349e+10, 1e-4) = crLess,      'FloatApproxCompare');
  Assert(FloatApproxCompare(-1.2345e-10, -1.2349e-10, 1e-3) = crEqual,   'FloatApproxCompare');
  Assert(FloatApproxCompare(-1.2345e-10, -1.2349e-10, 1e-4) = crGreater, 'FloatApproxCompare');

  {$IFNDEF ExtendedIsDouble}
  Assert(ExtendedExponentBase10(1.0, E),    'ExtendedExponent');
  Assert(E = 0,                          'ExtendedExponent');
  Assert(ExtendedExponentBase10(10.0, E),   'ExtendedExponent');
  Assert(E = 1,                          'ExtendedExponent');
  Assert(ExtendedExponentBase10(0.1, E),    'ExtendedExponent');
  Assert(E = -1,                         'ExtendedExponent');
  Assert(ExtendedExponentBase10(1e100, E),  'ExtendedExponent');
  Assert(E = 100,                        'ExtendedExponent');
  Assert(ExtendedExponentBase10(1e-100, E), 'ExtendedExponent');
  Assert(E = -100,                       'ExtendedExponent');
  Assert(ExtendedExponentBase10(0.999, E),  'ExtendedExponent');
  Assert(E = 0,                          'ExtendedExponent');
  Assert(ExtendedExponentBase10(-0.999, E), 'ExtendedExponent');
  Assert(E = 0,                          'ExtendedExponent');
  {$ENDIF}
end;

procedure Test_IntStr;
var I : Int64;
    W : LongWord;
    L : Integer;
    A : AnsiString;
begin
  Assert(HexCharToInt('A') = 10,   'HexCharToInt');
  Assert(HexCharToInt('a') = 10,   'HexCharToInt');
  Assert(HexCharToInt('1') = 1,    'HexCharToInt');
  Assert(HexCharToInt('0') = 0,    'HexCharToInt');
  Assert(HexCharToInt('F') = 15,   'HexCharToInt');
  Assert(HexCharToInt('G') = -1,   'HexCharToInt');

  Assert(IntToStringA(0) = '0',                           'IntToStringA');
  Assert(IntToStringA(1) = '1',                           'IntToStringA');
  Assert(IntToStringA(-1) = '-1',                         'IntToStringA');
  Assert(IntToStringA(10) = '10',                         'IntToStringA');
  Assert(IntToStringA(-10) = '-10',                       'IntToStringA');
  Assert(IntToStringA(123) = '123',                       'IntToStringA');
  Assert(IntToStringA(-123) = '-123',                     'IntToStringA');
  Assert(IntToStringA(MinLongInt) = '-2147483648',        'IntToStringA');
  Assert(IntToStringA(-2147483649) = '-2147483649',       'IntToStringA');
  Assert(IntToStringA(MaxLongInt) = '2147483647',         'IntToStringA');
  Assert(IntToStringA(2147483648) = '2147483648',         'IntToStringA');
  Assert(IntToStringA(MinInt64) = '-9223372036854775808', 'IntToStringA');
  Assert(IntToStringA(MaxInt64) = '9223372036854775807',  'IntToStringA');

  Assert(IntToStringB(0) = '0',                           'IntToStringB');
  Assert(IntToStringB(1) = '1',                           'IntToStringB');
  Assert(IntToStringB(-1) = '-1',                         'IntToStringB');
  Assert(IntToStringB(10) = '10',                         'IntToStringB');
  Assert(IntToStringB(-10) = '-10',                       'IntToStringB');
  Assert(IntToStringB(123) = '123',                       'IntToStringB');
  Assert(IntToStringB(-123) = '-123',                     'IntToStringB');
  Assert(IntToStringB(MinLongInt) = '-2147483648',        'IntToStringB');
  Assert(IntToStringB(-2147483649) = '-2147483649',       'IntToStringB');
  Assert(IntToStringB(MaxLongInt) = '2147483647',         'IntToStringB');
  Assert(IntToStringB(2147483648) = '2147483648',         'IntToStringB');
  Assert(IntToStringB(MinInt64) = '-9223372036854775808', 'IntToStringB');
  Assert(IntToStringB(MaxInt64) = '9223372036854775807',  'IntToStringB');

  Assert(IntToStringW(0) = '0',                     'IntToWideString');
  Assert(IntToStringW(1) = '1',                     'IntToWideString');
  Assert(IntToStringW(-1) = '-1',                   'IntToWideString');
  Assert(IntToStringW(1234567890) = '1234567890',   'IntToWideString');
  Assert(IntToStringW(-1234567890) = '-1234567890', 'IntToWideString');

  Assert(IntToStringU(0) = '0',                     'IntToString');
  Assert(IntToStringU(1) = '1',                     'IntToString');
  Assert(IntToStringU(-1) = '-1',                   'IntToString');
  Assert(IntToStringU(1234567890) = '1234567890',   'IntToString');
  Assert(IntToStringU(-1234567890) = '-1234567890', 'IntToString');

  Assert(IntToString(0) = '0',                     'IntToString');
  Assert(IntToString(1) = '1',                     'IntToString');
  Assert(IntToString(-1) = '-1',                   'IntToString');
  Assert(IntToString(1234567890) = '1234567890',   'IntToString');
  Assert(IntToString(-1234567890) = '-1234567890', 'IntToString');

  Assert(UIntToStringA(0) = '0',                  'UIntToString');
  Assert(UIntToStringA($FFFFFFFF) = '4294967295', 'UIntToString');
  Assert(UIntToStringW(0) = '0',                  'UIntToString');
  Assert(UIntToStringW($FFFFFFFF) = '4294967295', 'UIntToString');
  Assert(UIntToStringU(0) = '0',                  'UIntToString');
  Assert(UIntToStringU($FFFFFFFF) = '4294967295', 'UIntToString');
  Assert(UIntToString(0) = '0',                   'UIntToString');
  Assert(UIntToString($FFFFFFFF) = '4294967295',  'UIntToString');

  Assert(LongWordToStrA(0, 8) = '00000000',           'LongWordToStr');
  Assert(LongWordToStrA($FFFFFFFF, 0) = '4294967295', 'LongWordToStr');
  Assert(LongWordToStrB(0, 8) = '00000000',           'LongWordToStr');
  Assert(LongWordToStrB($FFFFFFFF, 0) = '4294967295', 'LongWordToStr');
  Assert(LongWordToStrW(0, 8) = '00000000',           'LongWordToStr');
  Assert(LongWordToStrW($FFFFFFFF, 0) = '4294967295', 'LongWordToStr');
  Assert(LongWordToStrU(0, 8) = '00000000',           'LongWordToStr');
  Assert(LongWordToStrU($FFFFFFFF, 0) = '4294967295', 'LongWordToStr');
  Assert(LongWordToStr(0, 8) = '00000000',            'LongWordToStr');
  Assert(LongWordToStr($FFFFFFFF, 0) = '4294967295',  'LongWordToStr');
  Assert(LongWordToStr(123) = '123',                  'LongWordToStr');
  Assert(LongWordToStr(10000) = '10000',              'LongWordToStr');
  Assert(LongWordToStr(99999) = '99999',              'LongWordToStr');
  Assert(LongWordToStr(1, 1) = '1',                   'LongWordToStr');
  Assert(LongWordToStr(1, 3) = '001',                 'LongWordToStr');
  Assert(LongWordToStr(1234, 3) = '1234',             'LongWordToStr');

  Assert(LongWordToHexA(0, 8) = '00000000',         'LongWordToHex');
  Assert(LongWordToHexA($FFFFFFFF, 0) = 'FFFFFFFF', 'LongWordToHex');
  Assert(LongWordToHexA($10000) = '10000',          'LongWordToHex');
  Assert(LongWordToHexA($12345678) = '12345678',    'LongWordToHex');
  Assert(LongWordToHexA($AB, 4) = '00AB',           'LongWordToHex');
  Assert(LongWordToHexA($ABCD, 8) = '0000ABCD',     'LongWordToHex');
  Assert(LongWordToHexA($CDEF, 2) = 'CDEF',         'LongWordToHex');
  Assert(LongWordToHexA($ABC3, 0, False) = 'abc3',  'LongWordToHex');

  Assert(LongWordToHexW(0, 8) = '00000000',         'LongWordToHex');
  Assert(LongWordToHexW(0) = '0',                   'LongWordToHex');
  Assert(LongWordToHexW($FFFFFFFF, 0) = 'FFFFFFFF', 'LongWordToHex');
  Assert(LongWordToHexW($AB, 4) = '00AB',           'LongWordToHex');
  Assert(LongWordToHexW($ABC3, 0, False) = 'abc3',  'LongWordToHex');

  Assert(LongWordToHexU(0, 8) = '00000000',         'LongWordToHex');
  Assert(LongWordToHexU(0) = '0',                   'LongWordToHex');
  Assert(LongWordToHexU($FFFFFFFF, 0) = 'FFFFFFFF', 'LongWordToHex');
  Assert(LongWordToHexU($AB, 4) = '00AB',           'LongWordToHex');
  Assert(LongWordToHexU($ABC3, 0, False) = 'abc3',  'LongWordToHex');

  Assert(LongWordToHex(0, 8) = '00000000',          'LongWordToHex');
  Assert(LongWordToHex($FFFFFFFF, 0) = 'FFFFFFFF',  'LongWordToHex');
  Assert(LongWordToHex(0) = '0',                    'LongWordToHex');
  Assert(LongWordToHex($ABCD, 8) = '0000ABCD',      'LongWordToHex');
  Assert(LongWordToHex($ABC3, 0, False) = 'abc3',   'LongWordToHex');

  Assert(StringToIntA('0') = 0,       'StringToInt');
  Assert(StringToIntA('1') = 1,       'StringToInt');
  Assert(StringToIntA('-1') = -1,     'StringToInt');
  Assert(StringToIntA('10') = 10,     'StringToInt');
  Assert(StringToIntA('01') = 1,      'StringToInt');
  Assert(StringToIntA('-10') = -10,   'StringToInt');
  Assert(StringToIntA('-01') = -1,    'StringToInt');
  Assert(StringToIntA('123') = 123,   'StringToInt');
  Assert(StringToIntA('-123') = -123, 'StringToInt');

  Assert(StringToIntB('321') = 321,   'StringToInt');
  Assert(StringToIntB('-321') = -321, 'StringToInt');

  Assert(StringToIntW('321') = 321,   'StringToInt');
  Assert(StringToIntW('-321') = -321, 'StringToInt');

  Assert(StringToIntU('321') = 321,   'StringToInt');
  Assert(StringToIntU('-321') = -321, 'StringToInt');

  A := '-012A';
  Assert(TryStringToInt64PA(PAnsiChar(A), Length(A), I, L) = convertOK,          'StringToInt');
  Assert((I = -12) and (L = 4),                                                  'StringToInt');
  A := '-A012';
  Assert(TryStringToInt64PA(PAnsiChar(A), Length(A), I, L) = convertFormatError, 'StringToInt');
  Assert((I = 0) and (L = 1),                                                    'StringToInt');

  Assert(TryStringToInt64A('0', I),                        'StringToInt');
  Assert(I = 0,                                            'StringToInt');
  Assert(TryStringToInt64A('-0', I),                       'StringToInt');
  Assert(I = 0,                                            'StringToInt');
  Assert(TryStringToInt64A('+0', I),                       'StringToInt');
  Assert(I = 0,                                            'StringToInt');
  Assert(TryStringToInt64A('1234', I),                     'StringToInt');
  Assert(I = 1234,                                         'StringToInt');
  Assert(TryStringToInt64A('-1234', I),                    'StringToInt');
  Assert(I = -1234,                                        'StringToInt');
  Assert(TryStringToInt64A('000099999', I),                'StringToInt');
  Assert(I = 99999,                                        'StringToInt');
  Assert(TryStringToInt64A('999999999999999999', I),       'StringToInt');
  Assert(I = 999999999999999999,                           'StringToInt');
  Assert(TryStringToInt64A('-999999999999999999', I),      'StringToInt');
  Assert(I = -999999999999999999,                          'StringToInt');
  Assert(TryStringToInt64A('4294967295', I),               'StringToInt');
  Assert(I = $FFFFFFFF,                                    'StringToInt');
  Assert(TryStringToInt64A('4294967296', I),               'StringToInt');
  Assert(I = $100000000,                                   'StringToInt');
  Assert(TryStringToInt64A('9223372036854775807', I),      'StringToInt');
  Assert(I = 9223372036854775807,                          'StringToInt');
  {$IFNDEF DELPHI7_DOWN}
  Assert(TryStringToInt64A('-9223372036854775808', I),     'StringToInt');
  Assert(I = -9223372036854775808,                         'StringToInt');
  {$ENDIF}
  Assert(not TryStringToInt64A('', I),                     'StringToInt');
  Assert(not TryStringToInt64A('-', I),                    'StringToInt');
  Assert(not TryStringToInt64A('+', I),                    'StringToInt');
  Assert(not TryStringToInt64A('+-0', I),                  'StringToInt');
  Assert(not TryStringToInt64A('0A', I),                   'StringToInt');
  Assert(not TryStringToInt64A('1A', I),                   'StringToInt');
  Assert(not TryStringToInt64A(' 0', I),                   'StringToInt');
  Assert(not TryStringToInt64A('0 ', I),                   'StringToInt');
  Assert(not TryStringToInt64A('9223372036854775808', I),  'StringToInt');
  {$IFNDEF DELPHI7_DOWN}
  Assert(not TryStringToInt64A('-9223372036854775809', I), 'StringToInt');
  {$ENDIF}

  Assert(TryStringToInt64W('9223372036854775807', I),      'StringToInt');
  Assert(I = 9223372036854775807,                          'StringToInt');
  {$IFNDEF DELPHI7_DOWN}
  Assert(TryStringToInt64W('-9223372036854775808', I),     'StringToInt');
  Assert(I = -9223372036854775808,                         'StringToInt');
  {$ENDIF}
  Assert(not TryStringToInt64W('', I),                     'StringToInt');
  Assert(not TryStringToInt64W('-', I),                    'StringToInt');
  Assert(not TryStringToInt64W('0A', I),                   'StringToInt');
  Assert(not TryStringToInt64W('9223372036854775808', I),  'StringToInt');
  {$IFNDEF DELPHI7_DOWN}
  Assert(not TryStringToInt64W('-9223372036854775809', I), 'StringToInt');
  {$ENDIF}

  Assert(TryStringToInt64U('9223372036854775807', I),      'StringToInt');
  Assert(I = 9223372036854775807,                          'StringToInt');
  {$IFNDEF DELPHI7_DOWN}
  Assert(TryStringToInt64U('-9223372036854775808', I),     'StringToInt');
  Assert(I = -9223372036854775808,                         'StringToInt');
  {$ENDIF}
  Assert(not TryStringToInt64U('', I),                     'StringToInt');
  Assert(not TryStringToInt64U('-', I),                    'StringToInt');
  Assert(not TryStringToInt64U('0A', I),                   'StringToInt');
  Assert(not TryStringToInt64U('9223372036854775808', I),  'StringToInt');
  {$IFNDEF DELPHI7_DOWN}
  Assert(not TryStringToInt64U('-9223372036854775809', I), 'StringToInt');
  {$ENDIF}

  Assert(TryStringToInt64('9223372036854775807', I),       'StringToInt');
  Assert(I = 9223372036854775807,                          'StringToInt');
  {$IFNDEF DELPHI7_DOWN}
  Assert(TryStringToInt64('-9223372036854775808', I),      'StringToInt');
  Assert(I = -9223372036854775808,                         'StringToInt');
  {$ENDIF}
  Assert(not TryStringToInt64('', I),                      'StringToInt');
  Assert(not TryStringToInt64('-', I),                     'StringToInt');
  Assert(not TryStringToInt64('9223372036854775808', I),   'StringToInt');
  {$IFNDEF DELPHI7_DOWN}
  Assert(not TryStringToInt64('-9223372036854775809', I),  'StringToInt');
  {$ENDIF}

  Assert(StringToInt64A('0') = 0,                                       'StringToInt64');
  Assert(StringToInt64A('1') = 1,                                       'StringToInt64');
  Assert(StringToInt64A('-123') = -123,                                 'StringToInt64');
  Assert(StringToInt64A('-0001') = -1,                                  'StringToInt64');
  Assert(StringToInt64A('-9223372036854775807') = -9223372036854775807, 'StringToInt64');
  Assert(StringToInt64A('-9223372036854775808') = -9223372036854775808, 'StringToInt64');
  Assert(StringToInt64A('9223372036854775807') = 9223372036854775807,   'StringToInt64');

  Assert(HexToUIntA('FFFFFFFF') = $FFFFFFFF, 'HexStringToUInt');
  Assert(HexToUIntA('FFFFFFFF') = $FFFFFFFF, 'HexStringToUInt');
  Assert(HexToUInt('FFFFFFFF') = $FFFFFFFF,  'HexStringToUInt');

  Assert(HexToLongWord('FFFFFFFF') = $FFFFFFFF,  'HexToLongWord');
  Assert(HexToLongWord('0') = 0,                 'HexToLongWord');
  Assert(HexToLongWord('123456') = $123456,      'HexToLongWord');
  Assert(HexToLongWord('ABC') = $ABC,            'HexToLongWord');
  Assert(HexToLongWord('abc') = $ABC,            'HexToLongWord');
  Assert(not TryHexToLongWord('', W),            'HexToLongWord');
  Assert(not TryHexToLongWord('x', W),           'HexToLongWord');

  Assert(HexToLongWordA('FFFFFFFF') = $FFFFFFFF, 'HexToLongWord');
  Assert(HexToLongWordA('0') = 0,                'HexToLongWord');
  Assert(HexToLongWordA('ABC') = $ABC,           'HexToLongWord');
  Assert(HexToLongWordA('abc') = $ABC,           'HexToLongWord');
  Assert(not TryHexToLongWordA('', W),           'HexToLongWord');
  Assert(not TryHexToLongWordA('x', W),          'HexToLongWord');

  Assert(HexToLongWordB('FFFFFFFF') = $FFFFFFFF, 'HexToLongWord');
  Assert(HexToLongWordB('0') = 0,                'HexToLongWord');
  Assert(HexToLongWordB('ABC') = $ABC,           'HexToLongWord');
  Assert(HexToLongWordB('abc') = $ABC,           'HexToLongWord');
  Assert(not TryHexToLongWordB('', W),           'HexToLongWord');
  Assert(not TryHexToLongWordB('x', W),          'HexToLongWord');

  Assert(HexToLongWordW('FFFFFFFF') = $FFFFFFFF, 'HexToLongWord');
  Assert(HexToLongWordW('0') = 0,                'HexToLongWord');
  Assert(HexToLongWordW('123456') = $123456,     'HexToLongWord');
  Assert(HexToLongWordW('ABC') = $ABC,           'HexToLongWord');
  Assert(HexToLongWordW('abc') = $ABC,           'HexToLongWord');
  Assert(not TryHexToLongWordW('', W),           'HexToLongWord');
  Assert(not TryHexToLongWordW('x', W),          'HexToLongWord');

  Assert(HexToLongWordU('FFFFFFFF') = $FFFFFFFF, 'HexToLongWord');
  Assert(HexToLongWordU('0') = 0,                'HexToLongWord');
  Assert(HexToLongWordU('123456') = $123456,     'HexToLongWord');
  Assert(HexToLongWordU('ABC') = $ABC,           'HexToLongWord');
  Assert(HexToLongWordU('abc') = $ABC,           'HexToLongWord');
  Assert(not TryHexToLongWordU('', W),           'HexToLongWord');
  Assert(not TryHexToLongWordU('x', W),          'HexToLongWord');

  Assert(not TryStringToLongWordA('', W),             'StringToLongWord');
  Assert(StringToLongWordA('123') = 123,              'StringToLongWord');
  Assert(StringToLongWordA('4294967295') = $FFFFFFFF, 'StringToLongWord');
  Assert(StringToLongWordA('999999999') = 999999999,  'StringToLongWord');

  Assert(StringToLongWordB('0') = 0,                  'StringToLongWord');
  Assert(StringToLongWordB('4294967295') = $FFFFFFFF, 'StringToLongWord');

  Assert(StringToLongWordW('0') = 0,                  'StringToLongWord');
  Assert(StringToLongWordW('4294967295') = $FFFFFFFF, 'StringToLongWord');

  Assert(StringToLongWordU('0') = 0,                  'StringToLongWord');
  Assert(StringToLongWordU('4294967295') = $FFFFFFFF, 'StringToLongWord');

  Assert(StringToLongWord('0') = 0,                   'StringToLongWord');
  Assert(StringToLongWord('4294967295') = $FFFFFFFF,  'StringToLongWord');
end;

procedure Test_FloatStr;
var A : AnsiString;
    E : Extended;
    L : Integer;
begin
  // FloatToStr
  {$IFNDEF FREEPASCAL}
  Assert(FloatToStringA(0.0) = '0');
  Assert(FloatToStringA(-1.5) = '-1.5');
  Assert(FloatToStringA(1.5) = '1.5');
  Assert(FloatToStringA(1.1) = '1.1');
  Assert(FloatToStringA(123) = '123');
  Assert(FloatToStringA(0.00000000000001) = '0.00000000000001');
  Assert(FloatToStringA(0.000000000000001) = '0.000000000000001');
  Assert(FloatToStringA(0.0000000000000001) = '1E-0016');
  Assert(FloatToStringA(0.0000000000000012345) = '0.000000000000001');
  Assert(FloatToStringA(0.00000000000000012345) = '1.2345E-0016');
  {$IFNDEF ExtendedIsDouble}
  Assert(FloatToStringA(123456789.123456789) = '123456789.123456789');
  {$IFDEF DELPHIXE2_UP}
  Assert(FloatToStringA(123456789012345.1234567890123456789) = '123456789012345.123');
  {$ELSE}
  Assert(FloatToStringA(123456789012345.1234567890123456789) = '123456789012345.1234');
  {$ENDIF}
  Assert(FloatToStringA(1234567890123456.1234567890123456789) = '1.23456789012346E+0015');
  {$ENDIF}
  Assert(FloatToStringA(0.12345) = '0.12345');
  Assert(FloatToStringA(1e100) = '1E+0100');
  Assert(FloatToStringA(1.234e+100) = '1.234E+0100');
  Assert(FloatToStringA(-1.5e-100) = '-1.5E-0100');
  {$IFNDEF ExtendedIsDouble}
  Assert(FloatToStringA(1.234e+1000) = '1.234E+1000');
  Assert(FloatToStringA(-1e-4000) = '0');
  {$ENDIF}

  Assert(FloatToStringB(0.0) = '0');
  Assert(FloatToStringB(-1.5) = '-1.5');
  Assert(FloatToStringB(1.5) = '1.5');
  Assert(FloatToStringB(1.1) = '1.1');

  Assert(FloatToStringW(0.0) = '0');
  Assert(FloatToStringW(-1.5) = '-1.5');
  Assert(FloatToStringW(1.5) = '1.5');
  Assert(FloatToStringW(1.1) = '1.1');
  {$IFNDEF ExtendedIsDouble}
  Assert(FloatToStringW(123456789.123456789) = '123456789.123456789');
  {$IFDEF DELPHIXE2_UP}
  Assert(FloatToStringW(123456789012345.1234567890123456789) = '123456789012345.123');
  {$ELSE}
  Assert(FloatToStringW(123456789012345.1234567890123456789) = '123456789012345.1234');
  {$ENDIF}
  Assert(FloatToStringW(1234567890123456.1234567890123456789) = '1.23456789012346E+0015');
  {$ENDIF}
  Assert(FloatToStringW(0.12345) = '0.12345');
  Assert(FloatToStringW(1e100) = '1E+0100');
  Assert(FloatToStringW(1.234e+100) = '1.234E+0100');
  Assert(FloatToStringW(1.5e-100) = '1.5E-0100');

  Assert(FloatToStringU(0.0) = '0');
  Assert(FloatToStringU(-1.5) = '-1.5');
  Assert(FloatToStringU(1.5) = '1.5');
  Assert(FloatToStringU(1.1) = '1.1');
  {$IFNDEF ExtendedIsDouble}
  Assert(FloatToStringU(123456789.123456789) = '123456789.123456789');
  {$IFDEF DELPHIXE2_UP}
  Assert(FloatToStringU(123456789012345.1234567890123456789) = '123456789012345.123');
  {$ELSE}
  Assert(FloatToStringU(123456789012345.1234567890123456789) = '123456789012345.1234');
  {$ENDIF}
  Assert(FloatToStringU(1234567890123456.1234567890123456789) = '1.23456789012346E+0015');
  {$ENDIF}
  Assert(FloatToStringU(0.12345) = '0.12345');
  Assert(FloatToStringU(1e100) = '1E+0100');
  Assert(FloatToStringU(1.234e+100) = '1.234E+0100');
  Assert(FloatToStringU(1.5e-100) = '1.5E-0100');

  Assert(FloatToString(0.0) = '0');
  Assert(FloatToString(-1.5) = '-1.5');
  Assert(FloatToString(1.5) = '1.5');
  Assert(FloatToString(1.1) = '1.1');
  {$IFNDEF ExtendedIsDouble}
  Assert(FloatToString(123456789.123456789) = '123456789.123456789');
  {$IFDEF DELPHIXE2_UP}
  Assert(FloatToString(123456789012345.1234567890123456789) = '123456789012345.123');
  {$ELSE}
  Assert(FloatToString(123456789012345.1234567890123456789) = '123456789012345.1234');
  {$ENDIF}
  Assert(FloatToString(1234567890123456.1234567890123456789) = '1.23456789012346E+0015');
  {$ENDIF}
  Assert(FloatToString(0.12345) = '0.12345');
  Assert(FloatToString(1e100) = '1E+0100');
  Assert(FloatToString(1.234e+100) = '1.234E+0100');
  Assert(FloatToString(1.5e-100) = '1.5E-0100');
  {$ENDIF}

  // StrToFloat
  A := '123.456';
  Assert(TryStringToFloatPA(PAnsiChar(A), Length(A), E, L) = convertOK);
  Assert((E = 123.456) and (L = 7));
  A := '-000.500A';
  Assert(TryStringToFloatPA(PAnsiChar(A), Length(A), E, L) = convertOK);
  Assert((E = -0.5) and (L = 8));
  A := '1.234e+002X';
  Assert(TryStringToFloatPA(PAnsiChar(A), Length(A), E, L) = convertOK);
  Assert((E = 123.4) and (L = 10));
  A := '1.2e300x';
  Assert(TryStringToFloatPA(PAnsiChar(A), Length(A), E, L) = convertOK);
  {$IFNDEF ExtendedIsDouble}
  Assert(ExtendedApproxEqual(E, 1.2e300, 1e-2) and (L = 7));
  {$ENDIF}
  A := '1.2e-300e';
  Assert(TryStringToFloatPA(PAnsiChar(A), Length(A), E, L) = convertOK);
  {$IFNDEF ExtendedIsDouble}
  Assert(ExtendedApproxEqual(E, 1.2e-300, 1e-2) and (L = 8));
  {$ENDIF}

  // 9999..9999 overflow
  {$IFNDEF ExtendedIsDouble}
  A := '';
  for L := 1 to 5000 do
    A := A + '9';
  Assert(TryStringToFloatPA(PAnsiChar(A), Length(A), E, L) = convertOverflow);
  Assert((E = 0.0) and (L >= 200));
  {$ENDIF}

  // 1200..0000
  {$IFNDEF ExtendedIsDouble}
  A := '12';
  for L := 1 to 100 do
    A := A + '0';
  Assert(TryStringToFloatPA(PAnsiChar(A), Length(A), E, L) = convertOK);
  Assert(ExtendedApproxEqual(E, 1.2e+101, 1e-2) and (L = 102));
  {$ENDIF}

  // 0.0000..0001 overflow
  {$IFNDEF ExtendedIsDouble}
  A := '0.';
  for L := 1 to 5000 do
    A := A + '0';
  A := A + '1';
  Assert(TryStringToFloatPA(PAnsiChar(A), Length(A), E, L) = convertOverflow);
  Assert((E = 0.0) and (L >= 500));
  {$ENDIF}

  // 0.0000..000123
  {$IFNDEF ExtendedIsDouble}
  A := '0.';
  for L := 1 to 100 do
    A := A + '0';
  A := A + '123';
  Assert(TryStringToFloatPA(PAnsiChar(A), Length(A), E, L) = convertOK);
  Assert(ExtendedApproxEqual(E, 1.23e-101, 1e-3) and (L = 105));
  {$ENDIF}

  // 1200..0000e100
  {$IFNDEF ExtendedIsDouble}
  A := '12';
  for L := 1 to 100 do
    A := A + '0';
  A := A + 'e100';
  Assert(TryStringToFloatPA(PAnsiChar(A), Length(A), E, L) = convertOK);
  Assert(ExtendedApproxEqual(E, 1.2e+201, 1e-1) and (L = 106));
  {$ENDIF}

  Assert(StringToFloatA('0') = 0.0);
  Assert(StringToFloatA('1') = 1.0);
  Assert(StringToFloatA('1.5') = 1.5);
  Assert(StringToFloatA('+1.5') = 1.5);
  Assert(StringToFloatA('-1.5') = -1.5);
  Assert(StringToFloatA('1.1') = 1.1);
  Assert(StringToFloatA('-00.00') = 0.0);
  Assert(StringToFloatA('+00.00') = 0.0);
  Assert(StringToFloatA('0000000000000000000000001.1000000000000000000000000') = 1.1);
  Assert(StringToFloatA('.5') = 0.5);
  Assert(StringToFloatA('-.5') = -0.5);
  {$IFNDEF ExtendedIsDouble}
  Assert(ExtendedApproxEqual(StringToFloatA('1.123456789'), 1.123456789, 1e-10));
  Assert(ExtendedApproxEqual(StringToFloatA('123456789.123456789'), 123456789.123456789, 1e-10));
  Assert(ExtendedApproxEqual(StringToFloatA('1.5e500'), 1.5e500, 1e-2));
  Assert(ExtendedApproxEqual(StringToFloatA('+1.5e+500'), 1.5e500, 1e-2));
  Assert(ExtendedApproxEqual(StringToFloatA('1.2E-500'), 1.2e-500, 1e-2));
  Assert(ExtendedApproxEqual(StringToFloatA('-1.2E-500'), -1.2e-500, 1e-2));
  Assert(ExtendedApproxEqual(StringToFloatA('-1.23456789E-500'), -1.23456789e-500, 1e-9));
  {$ENDIF}

  Assert(not TryStringToFloatA('', E));
  Assert(not TryStringToFloatA('+', E));
  Assert(not TryStringToFloatA('-', E));
  Assert(not TryStringToFloatA('.', E));
  Assert(not TryStringToFloatA(' ', E));
  Assert(not TryStringToFloatA(' 0', E));
  Assert(not TryStringToFloatA('0 ', E));
  Assert(not TryStringToFloatA('--0', E));
  Assert(not TryStringToFloatA('0X', E));
end;

procedure Test_Hash;
begin
  // HashStr
  Assert(HashStrA('Fundamentals') = $3FB7796E, 'HashStr');
  Assert(HashStrA('0') = $B2420DE,             'HashStr');
  Assert(HashStrA('Fundamentals', 1, -1, False) = HashStrA('FUNdamentals', 1, -1, False), 'HashStr');
  Assert(HashStrA('Fundamentals', 1, -1, True) <> HashStrA('FUNdamentals', 1, -1, True),  'HashStr');

  Assert(HashStrB('Fundamentals') = $3FB7796E, 'HashStr');
  Assert(HashStrB('0') = $B2420DE,             'HashStr');
  Assert(HashStrB('Fundamentals', 1, -1, False) = HashStrB('FUNdamentals', 1, -1, False), 'HashStr');
  Assert(HashStrB('Fundamentals', 1, -1, True) <> HashStrB('FUNdamentals', 1, -1, True),  'HashStr');

  Assert(HashStrW('Fundamentals') = $FD6ED837, 'HashStr');
  Assert(HashStrW('0') = $6160DBF3,            'HashStr');
  Assert(HashStrW('Fundamentals', 1, -1, False) = HashStrW('FUNdamentals', 1, -1, False), 'HashStr');
  Assert(HashStrW('Fundamentals', 1, -1, True) <> HashStrW('FUNdamentals', 1, -1, True),  'HashStr');

  {$IFDEF StringIsUnicode}
  Assert(HashStr('Fundamentals') = $FD6ED837, 'HashStr');
  Assert(HashStr('0') = $6160DBF3,            'HashStr');
  {$ELSE}
  Assert(HashStr('Fundamentals') = $3FB7796E, 'HashStr');
  Assert(HashStr('0') = $B2420DE,             'HashStr');
  {$ENDIF}
  Assert(HashStr('Fundamentals', 1, -1, False) = HashStr('FUNdamentals', 1, -1, False), 'HashStr');
  Assert(HashStr('Fundamentals', 1, -1, True) <> HashStr('FUNdamentals', 1, -1, True),  'HashStr');
end;

{$IFNDEF ManagedCode}
procedure Test_Memory;
var I, J : Integer;
    A, B : AnsiString;
begin
  for I := -1 to 33 do
    begin
      A := '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
      B := '                                    ';
      MoveMem(A[1], B[1], I);
      for J := 1 to MinI(I, 10) do
        Assert(B[J] = AnsiChar(48 + J - 1),     'MoveMem');
      for J := 11 to MinI(I, 36) do
        Assert(B[J] = AnsiChar(65 + J - 11),    'MoveMem');
      for J := MaxI(I + 1, 1) to 36 do
        Assert(B[J] = ' ',                  'MoveMem');
      Assert(CompareMem(A[1], B[1], I),     'CompareMem');
    end;

  for J := 1000 to 1500 do
    begin
      SetLength(A, 4096);
      for I := 1 to 4096 do
        A[I] := 'A';
      SetLength(B, 4096);
      for I := 1 to 4096 do
        B[I] := 'B';
      MoveMem(A[1], B[1], J);
      for I := 1 to J do
        Assert(B[I] = 'A', 'MoveMem');
      for I := J + 1 to 4096 do
        Assert(B[I] = 'B', 'MoveMem');
      Assert(CompareMem(A[1], B[1], J),     'CompareMem');
    end;

  B := '1234567890';
  MoveMem(B[1], B[3], 4);
  Assert(B = '1212347890', 'MoveMem');
  MoveMem(B[3], B[2], 4);
  Assert(B = '1123447890', 'MoveMem');
  MoveMem(B[1], B[3], 2);
  Assert(B = '1111447890', 'MoveMem');
  MoveMem(B[5], B[7], 3);
  Assert(B = '1111444470', 'MoveMem');
  MoveMem(B[9], B[10], 1);
  Assert(B = '1111444477', 'MoveMem');

  for I := -1 to 33 do
    begin
      A := '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
      ZeroMem(A[1], I);
      for J := 1 to I do
        Assert(A[J] = #0,                       'ZeroMem');
      for J := MaxI(I + 1, 1) to 10 do
        Assert(A[J] = AnsiChar(48 + J - 1),     'ZeroMem');
      for J := MaxI(I + 1, 11) to 36 do
        Assert(A[J] = AnsiChar(65 + J - 11),    'ZeroMem');
    end;

  for I := -1 to 33 do
    begin
      A := '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
      FillMem(A[1], I, Ord('!'));
      for J := 1 to I do
        Assert(A[J] = '!',                      'FillMem');
      for J := MaxI(I + 1, 1) to 10 do
        Assert(A[J] = AnsiChar(48 + J - 1),     'FillMem');
      for J := MaxI(I + 1, 11) to 36 do
        Assert(A[J] = AnsiChar(65 + J - 11),    'FillMem');
    end;
end;
{$ENDIF}

procedure SelfTest;
begin
  {$IFDEF CPU_INTEL386}
  Set8087CW(Default8087CW);
  {$ENDIF}
  Test_Misc;
  Test_BitFunctions;
  Test_Float;
  Test_IntStr;
  Test_FloatStr;
  Test_Hash;
  {$IFNDEF ManagedCode}
  Test_Memory;
  {$ENDIF}
end;
{$ENDIF}



end.

