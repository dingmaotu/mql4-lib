//+------------------------------------------------------------------+
//|                                           Trade/EntryAdvisor.mqh |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015-2016, Li Ding"
#property link      "dingmaotu@hotmail.com"
#property strict

#include "DataProvider.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum MarketMode
  {
   TrendLong,
   TrendShort,
   Ranging
  };
//+------------------------------------------------------------------+
//| EntryAdvisor interface
//| This interface defines what an advisor can do:
//| 1. It can advise if we can buy or sell
//| 2. and give the risk of the buy or sell (advisor specific)
//+------------------------------------------------------------------+
class EntryAdvisor: public DataProvider
  {
protected:
   MarketMode        m_mode;

public:
                     EntryAdvisor(string symbol,int period):DataProvider(symbol,period){m_mode=Ranging;}
   virtual bool      canBuy() {return false;}
   virtual bool      canSell() {return false;}
   virtual double    getRisk() {return 0;}

   bool              isLong() { return m_mode==TrendLong;}
   bool              isShort() {return m_mode==TrendShort;}
   bool              isRanging() {return m_mode==Ranging;}
   MarketMode        getMode() {return m_mode;}

   bool              isUp(int shift) {return getOpen(shift)<getClose(shift); }
   bool              isDown(int shift) {return getOpen(shift)>getClose(shift); }
  };
//+------------------------------------------------------------------+
