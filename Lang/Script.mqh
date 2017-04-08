//+------------------------------------------------------------------+
//|                                                  Lang/Script.mqh |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015-2016, Li Ding"
#property link      "dingmaotu@hotmail.com"
#property strict

#include "App.mqh"

#define DECLARE_SCRIPT(AppClass,Boolean) \
DECLARE_APP(AppClass,Boolean)\
void OnStart() {dynamic_cast<Script*>(App::Global).main();}
//+------------------------------------------------------------------+
//| Base class for a MQL Script                                      |
//+------------------------------------------------------------------+
class Script: public App
  {
public:
   virtual void      main(void)=0;
  };
//+------------------------------------------------------------------+
