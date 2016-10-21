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
//| Base class for a MQL Expert Advisor                              |
//+------------------------------------------------------------------+
class ExpertAdvisor: public EventApp
  {
public:
   virtual double    onTester() {return 0.0;}
   virtual void      main() {}
  };
//+------------------------------------------------------------------+
