//+------------------------------------------------------------------+
//|                                                      Advisor.mqh |
//|                                          Copyright 2015, Li Ding |
//|                                             http://dingmaotu.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, Li Ding"
#property link      "http://dingmaotu.com"
#property strict
//+------------------------------------------------------------------+
//| Advisor interface
//| This interface defines what an advisor can do:
//| 1. It can advise if we can buy or sell, and give the risk of the
//|    buy or sell (0-99); 0 is no risk, 99 is highest risk. The risk
//|    is just an estimation, the client may use or not use this
//|    information
//| 2. It can advise if we can close a particular order
//+------------------------------------------------------------------+
class Advisor
  {
public:
   virtual bool      canBuy(int &risk)
   virtual bool      canSell(int &risk);
   virtual bool      canClose(int orderId);
  }
//+------------------------------------------------------------------+
