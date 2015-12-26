//+------------------------------------------------------------------+
//|                                                     CATREA.mqh |
//|                                          Copyright 2014, Li Ding |
//|                                             http://dingmaotu.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, Li Ding"
#property link      "http://dingmaotu.com"
#property strict

#include <LiDing/CBaseEA.mqh>
#include <LiDing/Candle.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CATREA: public CBaseEA
  {
protected:
   //--- trailing stop
   double            TSTP;

   bool              IS_SPREAD_FLOAT;
   double            m_atr;
   double            m_atr_p;
   bool              m_is_atr_cross_up;
   bool              m_is_atr_cross_down;
   double            m_ao;
   double            m_spread;
   int               m_stoploss;
   int               m_takeprofit;

   LargeUpperShadowMatcher *m_upper;
   LargeLowerShadowMatcher *m_lower;

public:
                     CATREA();
                    ~CATREA();

   bool              CanBuy();
   bool              CanSell();
   bool              CanCloseBuy();
   bool              CanCloseSell();

   void              UpdateIndicators();

   bool              IsYin(int shift) {return Close[shift]-Open[shift]<0;}
   bool              IsYang(int shift) {return Close[shift]-Open[shift]>0;}

   void              UpdateOrdersBuyHook();
   void              UpdateOrdersSellHook();
   void              TickHook();
   void              CheckForSellOpen(void);
   void              CheckForBuyOpen(void);
   void              CheckForClose(void);
  };
//+------------------------------------------------------------------+
//| Initialize all internal vars to zero                             |
//+------------------------------------------------------------------+
CATREA::CATREA()
  {
   TSTP=NormalizeDouble(TrailingStop*Point,Digits);

   IS_SPREAD_FLOAT=SymbolInfoInteger(Symbol(),SYMBOL_SPREAD_FLOAT);
   m_spread=(int)SymbolInfoInteger(Symbol(),SYMBOL_SPREAD);
   m_is_atr_cross_down=false;
   m_is_atr_cross_up=false;
   Print(StringFormat("Spread %s = %d points\r\n",
         IS_SPREAD_FLOAT?"floating":"fixed",m_spread));
   m_upper = new LargeUpperShadowMatcher(0, 9999, EntityPercent, LongPercent);
   m_lower = new LargeLowerShadowMatcher(0, 9999, EntityPercent, LongPercent);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CATREA::~CATREA()
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
CATREA::UpdateIndicators(void)
  {
   if(IsNewBar())
     {
      m_atr=iATR(Symbol(),0,7,1);
      m_atr_p=iATR(Symbol(),0,7,2);

      if(!m_is_atr_cross_up && m_atr_p<RealSpread && m_atr>RealSpread)
        {
         m_is_atr_cross_up=true;
         m_ao=iAO(Symbol(),0,1);
           } else if(!m_is_atr_cross_down && m_atr_p>RealSpread && m_atr<RealSpread) {
         m_is_atr_cross_down=true;
        }

      if(UseATR)
        {
         int atr=(int)MathRound(m_atr/Point);
         m_stoploss=(int)MathRound(StopLossFactor*atr);
         m_takeprofit=(int)MathRound(TakeProfitFactor*atr+m_spread+ExtraProfit);
         TSTP=NormalizeDouble(TrailingStopFactor*m_atr,Digits);
           } else {
         m_stoploss=StopLoss;
         m_takeprofit=StopProfit;
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CATREA::CanBuy()
  {
   if(m_is_atr_cross_up && m_atr_p>RealSpread && (iAO(Symbol(),0,1)>m_ao))
     {
      m_is_atr_cross_up=false;
      m_is_atr_cross_down=false;
      if(MathAbs(Close[1]-Open[1])+MathAbs(Close[2]-Open[2])<2*m_atr && (m_lower.match(1)||m_upper.match(1)))
        {
         return true;
           } else {
         return false;
        }

        } else {
      return false;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CATREA::CanSell()
  {
   if(m_is_atr_cross_up && m_atr_p>RealSpread && (iAO(Symbol(),0,1)<m_ao))
     {
      m_is_atr_cross_up=false;
      m_is_atr_cross_down=false;
      if((MathAbs(Close[1]-Open[1])+MathAbs(Close[2]-Open[2])<2*m_atr) && (m_lower.match(1)||m_upper.match(1)))
        {
         return true;
           } else {
         return false;
        }
        } else {
      return false;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CATREA::CanCloseBuy()
  {
   if((TimeCurrent()-OrderOpenTime())/(3600*24)>7 && OrderProfit()<0)
     {
      return true;
        } else {
      return false;
     }
/*
   if(m_is_atr_cross_down)
     {
      m_is_atr_cross_down=false;
      return OrderProfit() > 0;
        } else {
      return false;
     }
     */
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CATREA::CanCloseSell()
  {
   if((TimeCurrent()-OrderOpenTime())/(3600*24)>NumberOfDaysHold && OrderProfit()<0)
     {
      return true;
        } else {
      return false;
     }
/*
   if(m_is_atr_cross_down)
     {
      m_is_atr_cross_down=false;
      return OrderProfit() > 0;
        } else {
      return false;
     }
     */
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CATREA::UpdateOrdersBuyHook(void)
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
CATREA::UpdateOrdersSellHook(void)
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
void CATREA::TickHook(void)
  {
   CheckForBuyOpen();
   CheckForSellOpen();
   if(m_buys>0 || m_sells>0)
     {
      CheckForClose();
     }
  }
//+------------------------------------------------------------------+
//| Check for open order conditions                                  |
//+------------------------------------------------------------------+
void CATREA::CheckForSellOpen(void)
  {
//--- sell conditions
   if(IsNewBar() && CanSell())
     {
      Print("Check for sell completed");
      Sell(m_stoploss,m_takeprofit);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CATREA::CheckForBuyOpen(void)
  {
//--- buy conditions
   if(IsNewBar() && CanBuy())
     {
      Buy(m_stoploss,m_takeprofit);
     }
  }
//+------------------------------------------------------------------+
//| Check for close order conditions                                 |
//+------------------------------------------------------------------+
void CATREA::CheckForClose(void)
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
