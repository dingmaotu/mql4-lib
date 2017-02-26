//+------------------------------------------------------------------+
//|                                                       System.mqh |
//|                                          Copyright 2016, Li Ding |
//|                                            dingmaotu@hotmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Li Ding"
#property link      "dingmaotu@hotmail.com"
#property strict

// Assume MT5 is 64bit, which is the default.
// Even though MT5 can be 32bit, there is no way to detect this
// by using preprocessor macros. Instead, MetaQuotes provides a
// function called IsX64 to detect this dynamically

// This is just absurd. Why do you want to know the bitness of
// the runtime? To define pointer related entities at compile time!
// All integer types in MQL is uniform on both 32bit or 64bit
// architectures, so it is almost useless to have a runtime function IsX64.

// So why not a __X64__?
#ifdef __MQL5__
#define __X64__
#endif


#ifdef __X64__
#define intptr_t long
#define uintptr_t ulong
#define size_t long
#else
#define intptr_t int
#define uintptr_t uint
#define size_t int
#endif

#define CODEPAGE_UTF8 65001

#import "kernel32.dll"
int lstrlen(intptr_t psz);
int MultiByteToWideChar(uint   CodePage,
                        uint  dwFlags,
                        const intptr_t lpMultiByteStr,
                        int    cbMultiByte,
                        string &str,
                        int    cchWideChar
                        );
#import
//+------------------------------------------------------------------+
//| Read a null terminated string to the MQL environment             |
//| With this function, there is no need to copy the string to char  |
//| array, and convert with CharArrayToString                        |
//+------------------------------------------------------------------+
string StringFromUtf8Pointer(intptr_t psz)
  {
   if(psz == 0) return NULL;
   int len=lstrlen(psz);
   if(len <= 0) return NULL;
   string res;
   int required=MultiByteToWideChar(CODEPAGE_UTF8,0,psz,len,res,0);
   StringInit(res,required);
   int resLength = MultiByteToWideChar(CODEPAGE_UTF8,0,psz,len,res,required);
   if(resLength != required)
     {
      return NULL;
     }
   else
     {
      return res;
     }
  }
//+------------------------------------------------------------------+
