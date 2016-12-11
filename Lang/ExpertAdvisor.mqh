//+------------------------------------------------------------------+
//|                                           Lang/ExpertAdvisor.mqh |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Li Ding"
#property link      "dingmaotu@hotmail.com"
#property strict

#include "EventApp.mqh"

#define DECLARE_EA(AppClass,PARAM_SECTION) \
DECLARE_EVENT_APP(AppClass,PARAM_SECTION)\
double OnTester() {return __app__.onTester();}\
void OnTick() {__app__.main();}
//+------------------------------------------------------------------+
//| Abstract base class for a MQL Expert Advisor                     |
//+------------------------------------------------------------------+
class ExpertAdvisor: public EventApp
  {
public:
   virtual void      main()=0;

//--- default for App
   virtual int       onInit() {return INIT_SUCCEEDED;}
//--- default for EventApp
   virtual void      onTimer() {}
   virtual void      onAppEvent(const ushort event, const uint param) {} 
   virtual void      onChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam) {}
//--- default for EA Tester
   virtual double    onTester() {return 0.0;}
  };
//+------------------------------------------------------------------+
