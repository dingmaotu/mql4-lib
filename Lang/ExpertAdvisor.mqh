//+------------------------------------------------------------------+
//|                                           Lang/ExpertAdvisor.mqh |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Li Ding"
#property link      "dingmaotu@hotmail.com"
#property strict

#include "EventApp.mqh"

#define DECLARE_EA(AppClass,Boolean) \
DECLARE_EVENT_APP(AppClass,Boolean)\
double OnTester() {return dynamic_cast<ExpertAdvisor*>(App::Global).onTester();}\
void OnTick() {dynamic_cast<ExpertAdvisor*>(App::Global).main();}
//+------------------------------------------------------------------+
//| Abstract base class for a MQL Expert Advisor                     |
//+------------------------------------------------------------------+
class ExpertAdvisor: public EventApp
  {
public:
   virtual void      main()=0;

   //--- default for EventApp
   virtual void      onTimer() {}
   virtual void      onAppEvent(const ushort event,const uint param) {}
   virtual void      onChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam) {}
   //--- default for EA Tester
   virtual double    onTester() {return 0.0;}
  };
//+------------------------------------------------------------------+
