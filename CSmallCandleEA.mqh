//+------------------------------------------------------------------+
//|                                               CSmallCandleEA.mqh |
//|                                          Copyright 2014, Li Ding |
//|                                             http://dingmaotu.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, Li Ding"
#property link      "http://dingmaotu.com"
#property strict

#include <LiDing/CBaseEA.mqh>
#include <LiDing/Matcher.mqh>
#include <LiDing/CTrailingStop.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class ContinuousSmallCandleMatcher: public CandleMatcher
  {
private:
   double            m_high;
   double            m_low;
public:
   bool              match(int shift);
   double            getHigh() {return m_high;}
   double            getLow() {return m_low;}
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ContinuousSmallCandleMatcher::match(int shift)
  {
   double min,max;
   double i_min,i_max;
   for(int i=shift; i<shift+LookBackBars; i++)
     {
      i_min = MathMin(Close[i], Open[i]);
      i_max = MathMax(Close[i], Open[i]);
      if(i==shift) {min=i_min; max=i_max; m_high=High[i]; m_low=Low[i];continue;}

      if(i_min < min) {min = i_min;}
      if(i_max > max) {max = i_max;}
      if(High[i] > m_high) {m_high = High[i];}
      if(Low[i] < m_low) {m_low = Low[i];}
/*
      candle.setShift(i);
      if(candle.getEntity()>CandleEntityLength*Point)
        {
         return false;
        }
        */
     }
   return (max - min) < CandleEntityLength*Point;

//return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CSmallCandleEA: public CBaseEA
  {
protected:
   ContinuousSmallCandleMatcher m;
   CTSPercentage     m_ts;
   double            m_atr;
   bool              m_match;
   double            initStopLoss;
   double            initTakeProfit;
public:
                     CSmallCandleEA() {}
                    ~CSmallCandleEA() {}

   bool              CanPendBuy() {return m_match;}
   bool              CanPendSell() {return m_match;}

   void              UpdateOrdersBuyHook();
   void              UpdateOrdersSellHook();
   void              UpdateIndicators();
   void              TickHook();
   void              CheckForSellOpen(void);
   void              CheckForBuyOpen(void);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CSmallCandleEA::UpdateOrdersBuyHook(void)
  {
   m_ts.DoTrailingStop(initStopLoss,initTakeProfit);
/*
   double aboveRange=Bid-OrderOpenPrice();
   double maxRange=OrderTakeProfit() - OrderStopLoss();
   double tsLimit=ATR_FACTOR_TS*m_atr;
   double tsReal = Bid - aboveRange*(1.0-aboveRange/maxRange);
   
   if(OrderProfit()>0 && (aboveRange>tsLimit) && tsReal > OrderStopLoss())
     {
      //Print("Buy percent is ", (1.0-aboveRange/maxRange);
      if(!OrderModify(OrderTicket(),OrderOpenPrice(),tsReal,OrderTakeProfit(),Red))
         Print("Error setting Buy trailing stop: ",GetLastError());
     }
     */
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CSmallCandleEA::UpdateOrdersSellHook(void)
  {
   m_ts.DoTrailingStop(initStopLoss,initTakeProfit);
/*
   double belowRange=OrderOpenPrice() - Ask;
   double maxRange=OrderStopLoss() - OrderTakeProfit();
   double tsLimit=ATR_FACTOR_TS*m_atr;
   double tsReal=Ask+belowRange*(1.0-belowRange/maxRange);

   if(OrderProfit()>0 && belowRange>tsLimit && tsReal < OrderStopLoss())
     {
      //Print("Sell tsReal is ", tsReal, "; Stop Loss is ", OrderStopLoss());
      if(!OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(tsReal, Digits),OrderTakeProfit(),Red))
         Print("Error setting Sell trailing stop: ",GetLastError());
     }
     */
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CSmallCandleEA::UpdateIndicators(void)
  {
   m_atr=iATR(Symbol(),0,7,0);
   m_match=m.match(1);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CSmallCandleEA::TickHook(void)
  {
/*
   if(IsNewBar()) 
     {
      Print("Sells: "+m_sells+"; Buys: "+m_buys+"; PendSells: "+m_pendsells+"; PendBuys: "+m_pendbuys);
     }
     */

   if(m_sells==0 && m_buys==0 && m_pendbuys==0 && m_pendsells==0)
     {
      if(IsNewBar())
        {
         m_ts.SetActiveLimit(ATR_FACTOR_TS*m_atr);
         CheckForSellOpen();
         CheckForBuyOpen();
        }
        } else {

      if(m_sells>0 && (m_buys>0 || m_pendbuys>0))
        {
         CloseAllOrders(OP_BUYLIMIT);
         CloseAllOrders(OP_BUYSTOP);
         CloseAllOrders(OP_BUY);
        }
      if(m_buys>0 && (m_sells>0 || m_pendsells>0))
        {
         CloseAllOrders(OP_SELLLIMIT);
         CloseAllOrders(OP_SELLSTOP);
         CloseAllOrders(OP_SELL);
        }
     }
  }
//+------------------------------------------------------------------+
//| Check for open order conditions                                  |
//+------------------------------------------------------------------+
void CSmallCandleEA::CheckForSellOpen(void)
  {
   if(CanPendSell())
     {
      PendSell(m.getLow()-CandleEntityLength*Point,GetLots(),(m_atr*ATR_FACTOR)/Point,0);
      initStopLoss=m.getLow()-CandleEntityLength*Point + m_atr*ATR_FACTOR;
      initTakeProfit=m.getLow()-CandleEntityLength*Point-(ATR_FACTOR_TP*m_atr);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CSmallCandleEA::CheckForBuyOpen(void)
  {
   if(CanPendBuy())
     {
      //PendBuy(Ask+m_atr*ATR_FACTOR,GetLots(),(m_atr*ATR_FACTOR)/Point,0);
      PendBuy(m.getHigh()+CandleEntityLength*Point,GetLots(),(m_atr*ATR_FACTOR)/Point,0);
      initStopLoss=m.getHigh()+CandleEntityLength*Point-m_atr*ATR_FACTOR;
      initTakeProfit=m.getHigh()+CandleEntityLength*Point+(ATR_FACTOR_TP*m_atr);
     }
  }
//+------------------------------------------------------------------+
