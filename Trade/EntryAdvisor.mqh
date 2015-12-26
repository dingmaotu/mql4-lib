//+------------------------------------------------------------------+
//|                                                 EntryAdvisor.mqh |
//|                                          Copyright 2015, Li Ding |
//|                                                dingmaotu@126.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, Li Ding"
#property link      "dingmaotu@126.com"
#property strict
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
class EntryAdvisor
  {
protected:
   string            m_symbol;
   int               m_period;
   long              m_bars;
   MarketMode        m_mode;

public:
                     EntryAdvisor(string symbol,int period):m_symbol(symbol),m_period(period){m_bars=getBars();m_mode=Ranging;}
   virtual bool      canBuy() {return false;}
   virtual bool      canSell() {return false;}
   virtual double    getRisk() {return 0;}
   virtual void      update() {}

   bool              hasNewBar() {return m_bars!=getBars();}
   void              updateNewBar() {m_bars=getBars();}

   bool              isLong() { return m_mode==TrendLong;}
   bool              isShort() {return m_mode==TrendShort;}
   bool              isRanging() {return m_mode==Ranging;}
   MarketMode        getMode() {return m_mode;}

   virtual double    getHigh(int shift) {return iHigh(m_symbol,m_period,shift);}
   virtual double    getLow(int shift) {return iLow(m_symbol,m_period,shift);}
   virtual double    getOpen(int shift) {return iOpen(m_symbol,m_period,shift);}
   virtual double    getClose(int shift) {return iClose(m_symbol,m_period,shift);}
   virtual long      getBars() {return iBars(m_symbol,m_period);}

   bool              isUp(int shift) {return getOpen(shift)<getClose(shift); }
   bool              isDown(int shift) {return getOpen(shift)>getClose(shift); }
  };
//+------------------------------------------------------------------+
