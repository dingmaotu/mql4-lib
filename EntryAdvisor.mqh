//+------------------------------------------------------------------+
//|                                                 EntryAdvisor.mqh |
//|                                          Copyright 2015, Li Ding |
//|                                             http://dingmaotu.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, Li Ding"
#property link      "http://dingmaotu.com"
#property strict
//+------------------------------------------------------------------+
//| EntryAdvisor interface
//| This interface defines what an advisor can do:
//| 1. It can advise if we can buy or sell
//| 2. and give the risk of the buy or sell (advisor specific)
//+------------------------------------------------------------------+
class EntryAdvisor
  {
public:
   virtual bool      CanBuy() {return false;}
   virtual bool      CanSell() {return false;}
   virtual double    GetRisk() {return 0;}
   virtual void      Update() {}
  };
//+------------------------------------------------------------------+
