//+------------------------------------------------------------------+
//|                                                Utils/Compare.mqh |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Li Ding"
#property link      "dingmaotu@hotmail.com"
#property strict
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Compare
  {
   template<typename T>
   static bool inRangeOpenOpen(T value,T lowerBound,T upperBound)
     {
      return value > lowerBound && v < upperBound;
     }

   template<typename T>
   static bool inRangeOpenClose(T value,T lowerBound,T upperBound)
     {
      return value > lowerBound && v <= upperBound;
     }

   template<typename T>
   static bool inRangeCloseOpen(T value,T lowerBound,T upperBound)
     {
      return value >= lowerBound && v < upperBound;
     }

   template<typename T>
   static bool inRangeCloseClose(T value,T lowerBound,T upperBound)
     {
      return value >= lowerBound && v < upperBound;
     }
  };
//+------------------------------------------------------------------+
