//+------------------------------------------------------------------+
//|                                                     Lang/App.mqh |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015-2016, Li Ding"
#property link      "dingmaotu@hotmail.com"
#property strict

#include "Mql.mqh"
#include "Pointer.mqh"

#define BEGIN_INPUT(ParamType) \
class GlobalAppParamSetter: public AppParamSetter\
  {\
protected:\
                     GlobalAppParamSetter() {if(Global==NULL) Global=new ParamType;}\
public:\
                    ~GlobalAppParamSetter() {SafeDelete(Global);}\
   static ParamType *Global;\
  };\
ParamType *GlobalAppParamSetter::Global=NULL;

//--- normal input parameter with declaration
#define INPUT(Type, Name, Default) \
class __Set##Name: public GlobalAppParamSetter {public: void set() {GlobalAppParamSetter::Global.set##Name(Inp##Name);}} __set##Name;\
input Type Inp##Name=Default\

//--- Fixed input only sets the input parameter as Default
//--- but does not declare the input parameter for user change
#define FIXED_INPUT(Type, Name, Default) \
class __Set##Name: public GlobalAppParamSetter {public: void set() {GlobalAppParamSetter::Global.set##Name(Default);}} __set##Name

//--- Input separator
#define INPUT_SEP(Name) \
input string ____##Name##____=""\

//--- Input separator
#define FIXED_INPUT_SEP(Name)

#define END_INPUT

#define __APP_NEW(AppClass,Boolean) __APP_NEW_##Boolean(AppClass)

#define __APP_NEW_true(AppClass) \
AppParamSetter::setParamters();\
if(!GlobalAppParamSetter::Global.check()) return INIT_PARAMETERS_INCORRECT;\
App::Global=new AppClass(GlobalAppParamSetter::Global);

#define __APP_NEW_false(AppClass) \
App::Global=new AppClass();

#define DECLARE_APP(AppClass,Boolean) \
App *App::Global=NULL;\
int OnInit()\
{\
   __APP_NEW(AppClass,Boolean)\
   App::Global.__setRuntimeControlled(true);\
   return App::Global.__init();\
}\
void OnDeinit(const int reason) {SafeDelete(App::Global);}
//+------------------------------------------------------------------+
//| (Optional) parameters for the App                                |
//+------------------------------------------------------------------+
class AppParam
  {
public:
   virtual bool      check(void) {return true;}
  };
//+------------------------------------------------------------------+
//| The base class for dynamically generated setters for parameters  |
//+------------------------------------------------------------------+
class AppParamSetter
  {
private:
   int               m_index;
protected:
   static AppParamSetter *Setters[];
                     AppParamSetter()
     {
      m_index=ArraySize(Setters);
      ArrayResize(Setters,ArraySize(Setters)+1,10);
      Setters[m_index]=GetPointer(this);
     }
public:
                    ~AppParamSetter() {SafeDelete(Setters[m_index]);}

   static void       setParamters()
     {
      int s=ArraySize(Setters);
      for(int i=0;i<s;i++)Setters[i].set();
     }
   static int        getNumberOfParameters() {return ArraySize(Setters);}

   virtual void      set()=0;
  };
AppParamSetter *AppParamSetter::Setters[];
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
