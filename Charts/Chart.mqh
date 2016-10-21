//+------------------------------------------------------------------+
//|                                                 Charts/Chart.mqh |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015-2016, Li Ding"
#property link      "dingmaotu@hotmail.com"
#property strict

#include "../Lang/Object.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Chart: public Object
  {
private:
   string            m_symbol;
   int               m_period;
public:
                     Chart(string symbol,int period):m_symbol(symbol),m_period(period) {}
                    ~Chart() {}
   string    getSymbol() {return m_symbol;}
   int       getPeriod() {return m_period;}

   virtual string    toString() const {return StringFormat("[Chart #%d]",hash());}

   virtual double    getHigh(int shift) {return iHigh(m_symbol,m_period,shift);}
   virtual double    getLow(int shift) {return iLow(m_symbol,m_period,shift);}
   virtual double    getOpen(int shift) {return iOpen(m_symbol,m_period,shift);}
   virtual double    getClose(int shift) {return iClose(m_symbol,m_period,shift);}
   virtual long      getVolume(int shift) {return iVolume(m_symbol,m_period,shift);}
   virtual int       getBars() {return iBars(m_symbol,m_period);}
  };
//+------------------------------------------------------------------+
