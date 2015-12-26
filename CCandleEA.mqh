//+------------------------------------------------------------------+
//|                                                    CCandleEA.mqh |
//|                                          Copyright 2014, Li Ding |
//|                                             http://dingmaotu.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, Li Ding"
#property link      "http://dingmaotu.com"
#property strict

#include <LiDing/CBaseEA.mqh>
#include <LiDing/Matcher.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class LargeUpperShadowMatcher: public CandleShapeMatcher
  {
public:
                     LargeUpperShadowMatcher(double min,double max,double entityPer,double longPer)
     {
      setMinLen(min);
      setMaxLen(max);
      setEntityPercent(entityPer);
      setUpperPercent(longPer);
      setLowerPercent(1.0-entityPer-longPer);
     }

   bool match(int shift)
     {
      candle.setShift(shift);

      return (YinYangEnabled ? candle.isYin() : true)
      && (candle.getEntity() < entityPercent*candle.getCandle())
      && (candle.getLower()<lowerPercent*candle.getCandle())
      && (candle.getUpper()>upperPercent*candle.getCandle());
     }
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class LargeLowerShadowMatcher: public CandleShapeMatcher
  {
public:
                     LargeLowerShadowMatcher(double min,double max,double entityPer,double longPer)
     {
      setMinLen(min);
      setMaxLen(max);
      setEntityPercent(entityPer);
      setUpperPercent(1.0-entityPer-longPer);
      setLowerPercent(longPer);
     }

   bool match(int shift)
     {
      candle.setShift(shift);

      return (YinYangEnabled ? candle.isYang() : true)
      && (candle.getEntity() < entityPercent*candle.getCandle())
      && (candle.getLower()>lowerPercent*candle.getCandle())
      && (candle.getUpper()<upperPercent*candle.getCandle());
     }
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CCandleEA: public CBaseEA
  {
protected:
   LargeUpperShadowMatcher *m_upper;
   LargeLowerShadowMatcher *m_lower;

   //--- trailing stop
   double            PointValue;
   double            TSTP;

public:
                     CCandleEA();
                    ~CCandleEA();

   void              UpdateOrdersBuyHook();
   void              UpdateOrdersSellHook();
   void              TickHook();

   virtual bool      CanBuy();
   virtual bool      CanSell();
   virtual bool      CanCloseBuy();
   virtual bool      CanCloseSell();

   virtual void      CheckForSellOpen(void);
   virtual void      CheckForBuyOpen(void);
   virtual void      CheckForClose(void);

   bool              IsUpTrendShape(int shift);
   bool              IsDownTrendShape(int shift);
   bool              IsRecentDown(int shift,int bars=5);
   bool              IsRecentUp(int shift,int bars=5);
  };
//+------------------------------------------------------------------+
//| Initialize all internal vars to zero                             |
//+------------------------------------------------------------------+
CCandleEA::CCandleEA()
  {
   m_upper = new LargeUpperShadowMatcher(0, 9999, EntityPercent, LongPercent);
   m_lower = new LargeLowerShadowMatcher(0, 9999, EntityPercent, LongPercent);
/*
   if(MarketInfo(OrderSymbol(),MODE_POINT)==0.00001) PointValue=0.0001;
   else if(MarketInfo(OrderSymbol(),MODE_POINT)==0.001) PointValue=0.01;
   else PointValue=MarketInfo(OrderSymbol(),MODE_POINT);
   */
   TSTP=NormalizeDouble(TrailingStop*Point,Digits);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CCandleEA::~CCandleEA()
  {
   if(CheckPointer(m_upper)==POINTER_DYNAMIC)
     {
      delete m_upper;
     }
   if(CheckPointer(m_lower)==POINTER_DYNAMIC)
     {
      delete m_lower;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CCandleEA::UpdateOrdersBuyHook(void)
  {
   if(TrailingStop>0 && OrderProfit()>0)
     {
      //      if(Bid-OrderOpenPrice()>TSTP)
      //        {
      if(OrderStopLoss()<Bid-TSTP)
        {
         if(!OrderModify(OrderTicket(),OrderOpenPrice(),Bid-TSTP,OrderTakeProfit(),Red))
            Print("Error setting Buy trailing stop: ",GetLastError());
        }
      //        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CCandleEA::UpdateOrdersSellHook(void)
  {
   if(TrailingStop>0 && OrderProfit()>0)
     {
      //      if(OrderOpenPrice()-Ask>TSTP)
      //        {
      if((OrderStopLoss()>Ask+TSTP) || (OrderStopLoss()==0))
        {
         if(!OrderModify(OrderTicket(),OrderOpenPrice(),Ask+TSTP,OrderTakeProfit(),Red))
            Print("Error setting Sell trailing stop: ",GetLastError());
        }
      //        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CCandleEA::IsRecentDown(int shift,int bars=5)
  {
   if(LookBackUsingEntity)
     {
      for(int i=shift+1; i<=(shift+bars); i++)
        {
         if(MathMax(Close[i], Open[i]) > MathMax(Close[i+1],Open[i+1])) return false;
        }
        } else {
      for(int i=shift+1; i<=(shift+bars); i++)
        {
         if(High[i] > High[i+1]) return false;
        }
     }
   return (High[shift] - Low[shift]) > KeyCandleLength*Point;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CCandleEA::IsRecentUp(int shift,int bars=5)
  {
   if(LookBackUsingEntity)
     {
      for(int i=shift+1; i<=(shift+bars); i++)
        {
         if(MathMin(Close[i],Open[i]) < MathMin(Close[i+1],Open[i+1])) return false;
        }
        } else {
      for(int i=shift+1; i<=(shift+bars); i++)
        {
         if(Low[i] < Low[i+1]) return false;
        }
     }
   return (High[shift] - Low[shift]) > KeyCandleLength*Point;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CCandleEA::IsUpTrendShape(int shift)
  {
   if(m_lower.match(shift))
     {
      if(IsRecentDown(shift, LookBackBars)) return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CCandleEA::IsDownTrendShape(int shift)
  {
   if(LargeLowerShadowAtTopEnabled && m_lower.match(shift))
     {
      if(IsRecentUp(shift, LookBackBars)) return true;
     }

   if(m_upper.match(shift))
     {
      if(IsRecentUp(shift, LookBackBars)) return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CCandleEA::CanBuy()
  {
   return IsUpTrendShape(1);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CCandleEA::CanSell()
  {
   return IsDownTrendShape(1);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CCandleEA::CanCloseBuy()
  {
   if(AllowClosing)
     {
      return CanSell();
        } else {
      return false;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CCandleEA::CanCloseSell()
  {
   if(AllowClosing)
     {
      return CanBuy();
        } else {
      return false;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CCandleEA::TickHook(void)
  {
   if(!AllowMultiple)
     {
      if(m_sells==0 && m_buys==0)
        {
         CheckForSellOpen();
         CheckForBuyOpen();
        }
        } else {
      if(m_sells==0)
        {
         CheckForSellOpen();
        }

      if(m_buys==0)
        {
         CheckForBuyOpen();
        }
     }

   if(m_sells || m_buys)
     {
      CheckForClose();
     }
  }
//+------------------------------------------------------------------+
//| Check for open order conditions                                  |
//+------------------------------------------------------------------+
void CCandleEA::CheckForSellOpen(void)
  {
//--- sell conditions
   if(IsNewBar() && CanSell())
     {
      Sell(StopLoss,StopProfit);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CCandleEA::CheckForBuyOpen(void)
  {
//--- buy conditions
   if(IsNewBar() && CanBuy())
     {
      Buy(StopLoss,StopProfit);
     }
  }
//+------------------------------------------------------------------+
//| Check for close order conditions                                 |
//+------------------------------------------------------------------+
void CCandleEA::CheckForClose(void)
  {
   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
      if(OrderMagicNumber()!=m_magic || OrderSymbol()!=Symbol()) continue;

      //--- check order type
      if(OrderType()==OP_SELL && CanCloseSell())
        {
         if(!OrderClose(OrderTicket(),OrderLots(),Ask,3,White))
           {
            Print("OrderClose error ",GetLastError()," when trying to close sell order #",OrderTicket());
           }
         continue;
        }
      if(OrderType()==OP_BUY && CanCloseBuy())
        {
         if(!OrderClose(OrderTicket(),OrderLots(),Bid,3,White))
           {
            Print("OrderClose error ",GetLastError()," when trying to close buy order #",OrderTicket());
           }
         continue;
        }
     }
  }
//+------------------------------------------------------------------+
