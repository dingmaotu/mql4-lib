//+------------------------------------------------------------------+
//|                                          History/HistoryData.mqh |
//|                  Copyright 2017, Bear Two Technologies Co., Ltd. |
//+------------------------------------------------------------------+
#property strict
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
interface HistoryData
  {
   int               getBars() const;

   double            getHigh(int shift) const;
   double            getLow(int shift) const;
   double            getOpen(int shift) const;
   double            getClose(int shift) const;
   long              getVolume(int shift) const;
  };
//+------------------------------------------------------------------+
