//+------------------------------------------------------------------+
//|                                                     CHedgeEA.mqh |
//|                                          Copyright 2014, Li Ding |
//|                                             http://dingmaotu.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, Li Ding"
#property link      "http://dingmaotu.com"
#property strict

#include <LiDing/CBaseEA.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CHedgeEA: public CBaseEA
  {
protected:
   int               BARS_PER_DAY;
   //--- trailing stop
   double            TSTP;
   int               m_triger_bar[];
   int               m_current_bar;

   int               m_day;

   bool              IS_SPREAD_FLOAT;
   double            m_atr;
   double            m_atr_p;
   double            m_spread;
   int               m_stoploss;
   int               m_takeprofit;

public:
                     CHedgeEA();
                    ~CHedgeEA();

   bool              IsNewDay() const {return m_day!=DayOfYear();}

   bool              CanBuy();
   bool              CanSell();
   bool              CanCloseBuy();
   bool              CanCloseSell();

   void              UpdateIndicators();

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
CHedgeEA::CHedgeEA()
  {
   TSTP=NormalizeDouble(TrailingStop*Point,Digits);
   BARS_PER_DAY=24*60*60/PeriodSeconds(PERIOD_CURRENT);
   MathSrand(GetTickCount());
   ArrayResize(m_triger_bar,OrdersPerDay);
   m_day=0;

   IS_SPREAD_FLOAT=SymbolInfoInteger(Symbol(),SYMBOL_SPREAD_FLOAT);
   m_spread=SymbolInfoInteger(Symbol(),SYMBOL_SPREAD);
   Print(StringFormat("Spread %s = %I64d points\r\n",
         IS_SPREAD_FLOAT?"floating":"fixed",m_spread));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CHedgeEA::~CHedgeEA()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CHedgeEA::UpdateIndicators(void)
  {
   if(IsNewDay())
     {
      for(int i=0; i<OrdersPerDay; i++)
        {
         m_triger_bar[i]=BARS_PER_DAY*MathRand()/32767;
        }
      m_current_bar=0;
     }
   if(IsNewBar())
     {
      m_current_bar++;
     }

   if(UseATR)
     {
      m_atr=iATR(Symbol(),0,7,1);
      m_stoploss=ATRMultiplier*MathRound(m_atr/Point);
      m_takeprofit=TakeProfitMultiplier*m_stoploss+m_spread+ExtraProfit;
      TSTP=m_stoploss;
        } else {
      m_stoploss=StopLoss;
      m_takeprofit=StopProfit;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CHedgeEA::CanBuy()
  {
   for(int i=0; i<OrdersPerDay; i++)
     {
      if(m_current_bar == m_triger_bar[i]) return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CHedgeEA::CanSell()
  {
   return CanBuy();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CHedgeEA::CanCloseBuy()
  {
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CHedgeEA::CanCloseSell()
  {
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CHedgeEA::UpdateOrdersBuyHook(void)
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
CHedgeEA::UpdateOrdersSellHook(void)
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
void CHedgeEA::TickHook(void)
  {
   CheckForSellOpen();
   CheckForBuyOpen();

   if(IsNewDay())
     {
      m_day=DayOfYear();
     }
  }
//+------------------------------------------------------------------+
//| Check for open order conditions                                  |
//+------------------------------------------------------------------+
void CHedgeEA::CheckForSellOpen(void)
  {
//--- sell conditions
   if(IsNewBar() && CanSell())
     {
      Sell(m_stoploss,m_takeprofit);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CHedgeEA::CheckForBuyOpen(void)
  {
//--- buy conditions
   if(IsNewBar() && CanBuy())
     {
      Buy(m_stoploss,m_takeprofit);
     }
  }
//+------------------------------------------------------------------+
