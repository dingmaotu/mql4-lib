//+------------------------------------------------------------------+
//|                                                 Trade/Filter.mqh |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Li Ding"
#property link      "dingmaotu@hotmail.com"
#property strict
//+------------------------------------------------------------------+
//| Filter interface                                                 |
//| A filter divides the continuous time series data into            |
//| non-overlapped ranges of three types: trending long, trending    |
//| short or ranging                                                 |
//+------------------------------------------------------------------+
interface Filter
  {
   bool isLong();
   bool isShort();
   bool isRanging();
   bool isTrending();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class FilterAdapter: public Filter
  {
public:
   virtual bool isLong() {return false;}
   virtual bool isShort() {return false;}
   virtual bool isTrending() {return isLong() || isShort();}
   virtual bool isRanging() {return !isTrending();}
  };
//+------------------------------------------------------------------+
