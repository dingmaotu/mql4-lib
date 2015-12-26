//+------------------------------------------------------------------+
//|                                           SingleBarAdvisor.mqh |
//|                                          Copyright 2015, Li Ding |
//|                                                dingmaotu@126.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, Li Ding"
#property link      "dingmaotu@126.com"
#property strict

#include <LiDing/Trade/EntryAdvisor.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class SingleBarAdvisor: public EntryAdvisor
  {
public:
                     SingleBarAdvisor(string symbol,int period);
   bool              canBuy();
   bool              canSell();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
SingleBarAdvisor::SingleBarAdvisor(string symbol,int period)
   :EntryAdvisor(symbol,period)
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool SingleBarAdvisor::canBuy(void)
  {
   return isUp(1);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool SingleBarAdvisor::canSell(void)
  {
   return isDown(1);
  }
//+------------------------------------------------------------------+
