//+------------------------------------------------------------------+
//|                                                  Utils/Price.mqh |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015-2016, Li Ding"
#property link      "dingmaotu@hotmail.com"
#property strict
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getPrice(int i,ENUM_APPLIED_PRICE applied,const double &open[],const double &high[],const double &low[],const double &close[])
  {
   switch(applied)
     {
      case PRICE_CLOSE:
         return close[i];
      case PRICE_HIGH:
         return high[i];
      case PRICE_LOW:
         return low[i];
      case PRICE_MEDIAN:
         return (high[i]+low[i])/2;
      case PRICE_OPEN:
         return open[i];
      case PRICE_TYPICAL:
         return (high[i]+low[i]+close[i])/3;
      case PRICE_WEIGHTED:
         return (high[i]+low[i]+close[i]+open[i])/4;
      default:
         return 0;
     }
  }
//+------------------------------------------------------------------+
