//+------------------------------------------------------------------+
//|                                                          Mql.mqh |
//|                                          Copyright 2017, Li Ding |
//|                                            dingmaotu@hotmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Li Ding"
#property link      "dingmaotu@hotmail.com"
#property strict

#import "stdlib.ex4"
string ErrorDescription(int error_code);
int    RGB(int red_value,int green_value,int blue_value);
bool   CompareDoubles(double number1,double number2);
string DoubleToStrMorePrecision(double number,int precision);
string IntegerToHexString(int integer_number);
#import

#include "Pointer.mqh"
#include "Hash.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
interface Callable
  {
   void call();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
template<typename T>
interface EqualityComparer
  {
   bool      equals(T left,T right) const;
   int       hash(T value) const;
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
template<typename T>
class GenericEqualityComparer: public EqualityComparer<T>
  {
public:
   virtual bool       equals(T left,T right) const {return left==right;}
   virtual int        hash(T value) const {return Hash(value);}
  };
//+------------------------------------------------------------------+
//| Mql language specific methods                                    |
//+------------------------------------------------------------------+
class Mql
  {
public:
   static int        getLastError() {return GetLastError();}
   static string     getErrorMessage(int errorCode) {return ErrorDescription(errorCode);}

   static string     doubleToString(double value,int precision) {return DoubleToStrMorePrecision(value,precision);}
   static string     integerToHexString(int value) {return IntegerToHexString(value);}
   static int        rgb(int red,int green,int blue) {return RGB(red,green,blue);}

   static bool       isEqual(double a,double b) {return CompareDoubles(a,b);}

   static bool       isStopped() {return IsStopped();}

   static int        getCodePage() {return MQLInfoInteger(MQL_CODEPAGE);}
   static ENUM_PROGRAM_TYPE getProgramType() {return(ENUM_PROGRAM_TYPE)MQLInfoInteger(MQL_PROGRAM_TYPE);}
   static bool       isScript() {return Mql::getProgramType()==PROGRAM_SCRIPT;}
   static bool       isExpert() {return Mql::getProgramType()==PROGRAM_EXPERT;}
   static bool       isIndicator() {return Mql::getProgramType()==PROGRAM_INDICATOR;}
   static bool       isDllAllowed() {return MQLInfoInteger(MQL_DLLS_ALLOWED)!=0;}
   static bool       isTradeAllowed() {return MQLInfoInteger(MQL_TRADE_ALLOWED)!=0;}
   static bool       isSignalsAllowed() {return MQLInfoInteger(MQL_SIGNALS_ALLOWED)!=0;}
   static bool       isDebug() {return MQLInfoInteger(MQL_DEBUG)!=0;}
   static bool       isProfiling() {return MQLInfoInteger(MQL_PROFILER)!=0;}
   static bool       isTesting() {return MQLInfoInteger(MQL_TESTER)!=0;}
   static bool       isOptimizing() {return MQLInfoInteger(MQL_OPTIMIZATION)!=0;}
   static bool       isVisual() {return MQLInfoInteger(MQL_VISUAL_MODE)!=0;}
   static bool       isFrameMode() {return MQLInfoInteger(MQL_FRAME_MODE)!=0;}
   static ENUM_LICENSE_TYPE getLicenseType() {return(ENUM_LICENSE_TYPE)MQLInfoInteger(MQL_LICENSE_TYPE);}
   static bool       isFreeLicense() {return Mql::getLicenseType()==LICENSE_FREE;}
   static bool       isDemoLicense() {return Mql::getLicenseType()==LICENSE_DEMO;}
   static bool       isFullLicense() {return Mql::getLicenseType()==LICENSE_FULL;}
   static bool       isTimeLicense() {return Mql::getLicenseType()==LICENSE_TIME;}

   static string     getProgramName() {return MQLInfoString(MQL_PROGRAM_NAME);}
   static string     getProgramPath() {return MQLInfoString(MQL_PROGRAM_PATH);}
  };

#define ObjectAttr(Type, Private, Public) \
public:\
   Type              get##Public() const {return m_##Private;}\
   void              set##Public(Type value) {m_##Private=value;}\
private:\
   Type              m_##Private\

#define ObjectAttrRead(Type, Private, Public) \
public:\
   Type              get##Public() const {return m_##Private;}\
private:\
   Type              m_##Private\

#define ObjectAttrWrite(Type, Private, Public) \
public:\
   void              set##Public(Type value) {m_##Private=value;}\
private:\
   Type              m_##Private\

#ifdef _DEBUG
#define Debug(msg) Print(">>> DEBUG: In ",__FUNCTION__,"(",__FILE__,":",__LINE__,") [", msg, "]")
#else
#define Debug(msg)
#endif

#define BEGIN_EXECUTE(Name) class __Execute##Name\
  {\
   public:__Execute##Name()\
     {
#define END_EXECUTE(Name) \
     }\
  }\
__execute##Name;
//+------------------------------------------------------------------+
