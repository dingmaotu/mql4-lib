//+------------------------------------------------------------------+
//|                                               Lang/Indicator.mqh |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015-2016, Li Ding"
#property link      "dingmaotu@hotmail.com"
#property strict

#include "EventApp.mqh"

#define DECLARE_INDICATOR(AppClass,PARAM_SECTION) \
DECLARE_EVENT_APP(AppClass,PARAM_SCECTION)\
int OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],const double &open[],const double &high[],const double &low[],const double &close[],const long &tickVolume[],const long &volume[],const int &spread[])\
  {return __app__.main(rates_total,prev_calculated,time,open,high,low,close,tickVolume,volume,spread);}
//+------------------------------------------------------------------+
//| Base class for a MQL Indicator                                   |
//+------------------------------------------------------------------+
class Indicator: public EventApp
  {
public:
   virtual int       main(const int total,
                          const int prev,
                          const datetime &time[],
                          const double &open[],
                          const double &high[],
                          const double &low[],
                          const double &close[],
                          const long &tickVolume[],
                          const long &volume[],
                          const int &spread[])=0;
   //--- default for App
   virtual int       onInit() {return INIT_SUCCEEDED;}
//--- default for EventApp
   virtual void      onTimer() {}
   virtual void      onChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam) {}
  };
//+------------------------------------------------------------------+
