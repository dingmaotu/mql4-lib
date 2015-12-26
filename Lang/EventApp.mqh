//+------------------------------------------------------------------+
//|                                                     EventApp.mqh |
//|                                          Copyright 2015, Li Ding |
//|                                             http://dingmaotu.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, Li Ding"
#property link      "http://dingmaotu.com"
#property strict

#include <LiDing/Lang/App.mqh>

#define DECLARE_EVENT_APP(AppClass,PARAM_SECTION) \
DECLARE_APP(AppClass,PARAM_SECTION)\
void OnTimer() {app.onTimer();}\
void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam) {app.onChartEvent(id,lparam,dparam,sparam);}

//+------------------------------------------------------------------+
//| Base class for a MQL Application that can receive events         |
//+------------------------------------------------------------------+
class EventApp: public App
  {
public:
   virtual void      onTimer() {}
   virtual void      onChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam) {}
  };
//+------------------------------------------------------------------+
