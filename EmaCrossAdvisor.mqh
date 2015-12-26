//+------------------------------------------------------------------+
//|                                              EmaCrossAdvisor.mqh |
//|                                          Copyright 2015, Li Ding |
//|                                             http://dingmaotu.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, Li Ding"
#property link      "http://dingmaotu.com"
#property strict

#include <LiDing/EntryAdvisor.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class EmaCrossAdvisor: public EntryAdvisor
  {
private:
   double            m_ema1,m_ema2,m_ema1_p,m_ema2_p;
   int               m_p1,m_p2;
public:
                     EmaCrossAdvisor(int p1,int p2);
   bool              CanBuy();
   bool              CanSell();
   void              Update();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EmaCrossAdvisor::EmaCrossAdvisor(int p1,int p2)
  {
   m_p1 = p1;
   m_p2 = p2;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EmaCrossAdvisor::Update(void)
  {
   m_ema1=iMA(Symbol(),Period(),m_p1,0,MODE_EMA,PRICE_CLOSE,1);
   m_ema2=iMA(Symbol(),Period(),m_p2,0,MODE_EMA,PRICE_CLOSE,1);
   m_ema1_p=iMA(Symbol(),Period(),m_p1,0,MODE_EMA,PRICE_CLOSE,2);
   m_ema2_p=iMA(Symbol(),Period(),m_p2,0,MODE_EMA,PRICE_CLOSE,2);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool EmaCrossAdvisor::CanSell(void)
  {
   return m_ema2_p<m_ema1_p && m_ema1<m_ema2;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool EmaCrossAdvisor::CanBuy(void)
  {
   return m_ema2_p>m_ema1_p && m_ema1>m_ema2;
  }
//+------------------------------------------------------------------+
