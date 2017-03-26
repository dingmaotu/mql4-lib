//+------------------------------------------------------------------+
//|                                                     Lang/App.mqh |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015-2016, Li Ding"
#property link      "dingmaotu@hotmail.com"
#property strict

#include "Mql.mqh"
#include "Pointer.mqh"

#define PARAM(ParamName, ParamValue) __app__.set##ParamName((ParamValue));

#define DECLARE_APP(AppClass,PARAM_SECTION) \
AppClass *__app__;\
int OnInit(){\
__app__=new AppClass();\
__app__.setRuntimeControlled(true);\
PARAM_SECTION\
return __app__.onInit();}\
void OnDeinit(const int reason) {SafeDelete(__app__);}
//+------------------------------------------------------------------+
//| Abstract base class for a MQL Application                        |
//+------------------------------------------------------------------+
class App
  {
private:
   bool              mRuntimeControlled;
protected:
   bool              isRuntimeControlled() const {return mRuntimeControlled;}
   int               getDeinitReason() const {return UninitializeReason();}
public:
   //--- This method is not intended for public use
   void              setRuntimeControlled(bool value) {mRuntimeControlled=value;}
                     App():mRuntimeControlled(false){}

   virtual int       onInit(void)=0;
  };
//+------------------------------------------------------------------+
