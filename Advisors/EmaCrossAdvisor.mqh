//+------------------------------------------------------------------+
//|                                              EmaCrossAdvisor.mqh |
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
class EmaCrossAdvisor: public EntryAdvisor
  {
private:
   double            m_ema1,m_ema2,m_ema1_p,m_ema2_p;
   int               m_p1,m_p2;

public:
                     EmaCrossAdvisor(string symbol,int period,int p1,int p2);
   bool              canBuy();
   bool              canSell();
   double            getRisk();
   void              update();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EmaCrossAdvisor::EmaCrossAdvisor(string symbol,int period,int p1,int p2)
   :EntryAdvisor(symbol,period),m_ema1(0),m_ema2(0),m_ema1_p(0),m_ema2_p(0),m_p1(p1),m_p2(p2)
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool EmaCrossAdvisor::canBuy(void)
  {
   return m_ema2_p>m_ema1_p && m_ema1>m_ema2;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool EmaCrossAdvisor::canSell(void)
  {
   return m_ema2_p<m_ema1_p && m_ema1<m_ema2;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double EmaCrossAdvisor::getRisk(void)
  {
   return 0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EmaCrossAdvisor::update(void)
  {
   if(hasNewBar())
     {
      m_ema1=iMA(m_symbol,m_period,m_p1,0,MODE_EMA,PRICE_CLOSE,1);
      m_ema2=iMA(m_symbol,m_period,m_p2,0,MODE_EMA,PRICE_CLOSE,1);
      m_ema1_p=iMA(m_symbol,m_period,m_p1,0,MODE_EMA,PRICE_CLOSE,2);
      m_ema2_p=iMA(m_symbol,m_period,m_p2,0,MODE_EMA,PRICE_CLOSE,2);

      if(canBuy())
        {
         m_mode=TrendLong;
        }
      else if(canSell())
        {
         m_mode=TrendShort;
        }
     }
  }
//+------------------------------------------------------------------+
