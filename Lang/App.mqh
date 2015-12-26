//+------------------------------------------------------------------+
//|                                                          App.mqh |
//|                                          Copyright 2015, Li Ding |
//|                                             http://dingmaotu.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, Li Ding"
#property link      "http://dingmaotu.com"
#property strict

#include <LiDing/Lang/Object.mqh>

#define PARAM(ParamName, ParamValue) app.set##ParamName((ParamValue));

#define DECLARE_APP(AppClass,PARAM_SECTION) \
AppClass app;\
int OnInit(){\
PARAM_SECTION\
return app.onInit();}\
void OnDeinit(const int reason) {app.onDeinit(reason);}

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
