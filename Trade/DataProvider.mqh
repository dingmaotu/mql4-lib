//+------------------------------------------------------------------+
//|                                           Trade/DataProvider.mqh |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015-2016, Li Ding"
#property link      "dingmaotu@hotmail.com"
#property strict
//+------------------------------------------------------------------+
//| DataProvider interface
//| This interface defines how market data (bars) is retrieved
//+------------------------------------------------------------------+
class DataProvider
  {
protected:
   string            m_symbol;
   int               m_period;
   long              m_bars;

public:
                     DataProvider(string symbol,int period):m_symbol(symbol),m_period(period){m_bars=getBars();}
   virtual void      update() {}

   bool              hasNewBar() {return m_bars!=getBars();}
   void              updateNewBar() {m_bars=getBars();}

   virtual double    getHigh(int shift) {return iHigh(m_symbol,m_period,shift);}
   virtual double    getLow(int shift) {return iLow(m_symbol,m_period,shift);}
   virtual double    getOpen(int shift) {return iOpen(m_symbol,m_period,shift);}
   virtual double    getClose(int shift) {return iClose(m_symbol,m_period,shift);}
   virtual long      getBars() {return iBars(m_symbol,m_period);}
  };
//+------------------------------------------------------------------+
