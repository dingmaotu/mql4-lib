//+------------------------------------------------------------------+
//|                                           FlyingBuddaAdvisor.mqh |
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
class FlyingBuddaAdvisor: public EntryAdvisor
  {
private:
   double            m_ema5,m_ema10;

public:
                     FlyingBuddaAdvisor(string symbol,int period);
   bool              canBuy();
   bool              canSell();
   double            getRisk();
   void              update();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
FlyingBuddaAdvisor::FlyingBuddaAdvisor(string symbol,int period)
   :EntryAdvisor(symbol,period),m_ema5(0),m_ema10(0)
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool FlyingBuddaAdvisor::canBuy(void)
  {
   return getHigh(1) < m_ema5 && m_ema5<m_ema10;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool FlyingBuddaAdvisor::canSell(void)
  {
   return getLow(1) > m_ema5 && m_ema5 > m_ema10;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double FlyingBuddaAdvisor::getRisk(void)
  {
   return 0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void FlyingBuddaAdvisor::update(void)
  {
   if(hasNewBar())
     {
      m_ema5=iMA(m_symbol,m_period,5,0,MODE_EMA,PRICE_CLOSE,1);
      m_ema10=iMA(m_symbol,m_period,10,0,MODE_EMA,PRICE_CLOSE,1);
      if(isRanging())
        {
         if(canBuy())
           {
            m_mode=TrendLong;
           }
         else if(canSell())
           {
            m_mode=TrendShort;
           }
        }
      else
        {
         if(isLong())
           {
            // find last up open;
            int i=2;
            while(!isUp(i)) i++;
            if(getOpen(i)>getClose(1))
              {
               m_mode=Ranging;
              }
           }
         else if(isShort())
           {
            // find last down open;
            int i=2;
            while(!isDown(i)) i++;
            if(getOpen(i)<getClose(1))
              {
               m_mode=Ranging;
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
