//+------------------------------------------------------------------+
//|                                                Lang/EventApp.mqh |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015-2016, Li Ding"
#property link      "dingmaotu@hotmail.com"
#property strict

#include "App.mqh"
#include "Event.mqh"

#define DECLARE_EVENT_APP(AppClass,Boolean) \
DECLARE_APP(AppClass,Boolean)\
void OnTimer() {dynamic_cast<EventApp*>(App::Global).onTimer();}\
void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)\
{\
  if(IsKeydownMessage(lparam)){\
   ushort event;uint param;\
   DecodeKeydownMessage(lparam,dparam,event,param);\
   dynamic_cast<EventApp*>(App::Global).onAppEvent(event,param);\
  }else{\
   dynamic_cast<EventApp*>(App::Global).onChartEvent(id,lparam,dparam,sparam);\
  }\
}
//+------------------------------------------------------------------+
//| Abstract base class for a MQL Application that can receive events|
//+------------------------------------------------------------------+
class EventApp: public App
  {
public:
   virtual void      onTimer()=0;
   virtual void      onChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)=0;
   virtual void      onAppEvent(const ushort event,const uint param)=0;
  };
//+------------------------------------------------------------------+
