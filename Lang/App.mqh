//+------------------------------------------------------------------+
//|                                                     Lang/App.mqh |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015-2016, Li Ding"
#property link      "dingmaotu@hotmail.com"
#property strict

#include "Mql.mqh"
#include "Pointer.mqh"

#define BEGIN_INPUT(AppParamClass) \
AppParamClass *__param__=new AppParamClass;

#define INPUT(Type, Name, Default) \
BEGIN_EXECUTE(Set##Name)\
   __param__.set##Name(Inp##Name);\
END_EXECUTE(Set##Name)\
input Type Inp##Name=Default\

#define END_INPUT

#define __APP_NEW(AppClass,Boolean) __APP_NEW_##Boolean(AppClass)

#define __APP_NEW_true(AppClass) \
if(!__param__.check()) return INIT_PARAMETERS_INCORRECT;\
App::Global=new AppClass(__param__);

#define __APP_NEW_false(AppClass) \
App::Global=new AppClass();

#define __DEINIT(Boolean) __DEINIT_##Boolean
#define __DEINIT_true SafeDelete(__param__);
#define __DEINIT_false

#define DECLARE_APP(AppClass,Boolean) \
App *App::Global=NULL;\
int OnInit()\
{\
   __APP_NEW(AppClass,Boolean)\
   App::Global.__setRuntimeControlled(true);\
   return App::Global.__init();\
 }\
void OnDeinit(const int reason) {SafeDelete(App::Global);__DEINIT(Boolean)}
//+------------------------------------------------------------------+
//| (Optional) parameters for the App                                |
//+------------------------------------------------------------------+
class AppParam
  {
public:
   virtual bool      check(void) const {return true;}
  };
//+------------------------------------------------------------------+
//| Abstract base class for a MQL Application                        |
//+------------------------------------------------------------------+
class App
  {
private:
   bool              m_runtimeControlled;
   ENUM_INIT_RETCODE m_ret;
protected:
   bool              isRuntimeControlled() const {return m_runtimeControlled;}
   int               getDeinitReason() const {return UninitializeReason();}
   void              fail(string message="",ENUM_INIT_RETCODE ret=INIT_FAILED)
     {
      if(message!="") Alert(message);
      m_ret=ret;
     }
public:
   //--- Methods for internal use
   void              __setRuntimeControlled(bool value) {m_runtimeControlled=value;}
   int               __init() const {return m_ret;}

                     App():m_runtimeControlled(false),m_ret(INIT_SUCCEEDED){}
   static App       *Global;
  };
//+------------------------------------------------------------------+
