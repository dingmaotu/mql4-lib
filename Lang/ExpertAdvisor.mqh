//+------------------------------------------------------------------+
//|                                                ExpertAdvisor.mqh |
//|                                          Copyright 2015, Li Ding |
//|                                             http://dingmaotu.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, Li Ding"
#property link      "http://dingmaotu.com"
#property strict

#include <LiDing/Lang/EventApp.mqh>

#define DECLARE_EA(AppClass,PARAM_SECTION) \
DECLARE_EVENT_APP(AppClass,PARAM_SCECTION)\
double OnTester() {return app.onTester();}\
void OnTick() {app.main();}

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
