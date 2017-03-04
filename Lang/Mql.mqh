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
  };

#define ObjectAttr(Type, Private, Public) \
public:\
   Type              get##Public() const {return m_##Private;}\
   void              set##Public(Type value) {m_##Private=value;}\
private:\
   Type              m_##Private\

#ifdef _DEBUG
#define Debug(msg) Print(">>> DEBUG: In ",__FUNCTION__,"(",__FILE__,":",__LINE__,") [", msg, "]")
#else
#define Debug(msg)
#endif
//+------------------------------------------------------------------+
