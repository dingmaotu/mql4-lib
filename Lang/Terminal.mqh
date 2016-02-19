//+------------------------------------------------------------------+
//|                                                     Terminal.mqh |
//|                                          Copyright 2016, Li Ding |
//|                                            dingmaotu@hotmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Li Ding"
#property link      "dingmaotu@hotmail.com"
#property strict
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Terminal
  {
public:
   static string     getPath();
   static string     getDataPath();
   static string     getCommonDataPath();

   static string     getName();
   static string     getCompany();
   static string     getLanguage();
  };
//+------------------------------------------------------------------+
