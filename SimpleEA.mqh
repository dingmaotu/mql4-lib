//+------------------------------------------------------------------+
//|                                                     SimpleEA.mqh |
//|                                          Copyright 2015, Li Ding |
//|                                                dingmaotu@126.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, Li Ding"
#property link      "dingmaotu@126.com"
#property strict

#include <LiDing/Lang/ExpertAdvisor.mqh>
#include <LiDing/CBaseEA.mqh>
#include <LiDing/CEADriver.mqh>
#include <LiDing/MoneyManager.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class SimpleEA: public ExpertAdvisor
  {
private:
   CEADriver        *driver;
   MoneyManager     *mm;
   bool              notrade=false;

public:
                     SimpleEA(double lossPercent);
                    ~SimpleEA();
   int               onInit(void);
   void              onDeinit(const int reason);
   void              onTick(void);
  };
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
     {
      //--- check parameters
      double lossp=LossPercent/100.;
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      if(lossp>=1 || lossp<=0)
        {
         Print("LossPercent must be between 0 to 100");
         return INIT_PARAMETERS_INCORRECT;
        }

      mm=new MoneyManager(1-lossp);

      driver=new CEADriver;
      driver.Add(new EmaCrossEA());

      return INIT_SUCCEEDED;
     }
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(CheckPointer(driver)==POINTER_DYNAMIC)
     {
      delete driver;
     }

   if(CheckPointer(mm)==POINTER_DYNAMIC)
     {
      delete mm;
     }
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//--- check for history and trading
   if(Bars<100 || !IsTradeAllowed())
      return;

   if(notrade) return;

   if(!mm.HasEnoughMoney())
     {
      driver.CloseAllOrders();
      notrade=true;
     }

   driver.Tick();
  }
//+------------------------------------------------------------------+
