//+------------------------------------------------------------------+
//|                                                  Lang/Script.mqh |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015-2016, Li Ding"
#property link      "dingmaotu@hotmail.com"
#property strict

#include "App.mqh"

#define DECLARE_SCRIPT(AppClass,PARAM_SECTION) \
DECLARE_APP(AppClass,PARAM_SECTION)\
void OnStart() {__app__.main();}
//+------------------------------------------------------------------+
//| Base class for a MQL Script                                      |
//+------------------------------------------------------------------+
class Script: public App
  {
public:
   virtual void      main(void) {}
  };
//+------------------------------------------------------------------+
