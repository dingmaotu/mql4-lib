//+------------------------------------------------------------------+
//|                                                   Utils/Math.mqh |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Li Ding"
#property link      "dingmaotu@hotmail.com"
#property strict
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Math
  {
public:
   template<typename T>
   static T max(T value1,T value2)
     {
      return value1 > value2 ? value1 : value2;
     }
   template<typename T>
   static T min(T value1,T value2)
     {
      return value1 < value2 ? value1 : value2;
     }
   template<typename T>
   static T abs(T value)
     {
      return value < 0 ? -value : value;
     }
  };
//+------------------------------------------------------------------+
