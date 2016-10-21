//+------------------------------------------------------------------+
//|                                                     Lang/App.mqh |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015-2016, Li Ding"
#property link      "dingmaotu@hotmail.com"
#property strict

#include "Object.mqh"

#define PARAM(ParamName, ParamValue) __app__.set##ParamName((ParamValue));

#define DECLARE_APP(AppClass,PARAM_SECTION) \
AppClass __app__;\
int OnInit(){\
PARAM_SECTION\
return __app__.onInit();}\
void OnDeinit(const int reason) {__app__.onDeinit(reason);}
//+------------------------------------------------------------------+
//| Base class for a MQL Application                                 |
//+------------------------------------------------------------------+
class App: public Object
  {
public:
                     App(){}
   virtual          ~App(){}
   virtual int       onInit(void) {return INIT_SUCCEEDED;}
   virtual void      onDeinit(const int reason) {}
  };
//+------------------------------------------------------------------+
