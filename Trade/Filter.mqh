//+------------------------------------------------------------------+
//|                                                 Trade/Filter.mqh |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Li Ding"
#property link      "dingmaotu@hotmail.com"
#property strict
//+------------------------------------------------------------------+
//| Filter interface                                                 |
//| A filter divides the continuous time series data into            |
//| non-overlapped ranges of two types: valid or invalid             |
//+------------------------------------------------------------------+
interface Filter
  {
   bool isValid();
  };
//+------------------------------------------------------------------+
