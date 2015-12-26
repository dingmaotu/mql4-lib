//+------------------------------------------------------------------+
//|                                          CTrailingStopOnce.mqh |
//|                                          Copyright 2014, Li Ding |
//|                                             http://dingmaotu.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, Li Ding"
#property link      "http://dingmaotu.com"
#property strict

#include <LiDing/Order.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CTrailingStopOnce
  {
private:
   double            m_active_limit;
public:
                     CTrailingStopOnce():m_active_limit(10000){}
   void              SetActiveLimit(double limit) {m_active_limit=limit;}
   //--- Do trailing stop for current order;
   void              DoTrailingStop();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CTrailingStopOnce::DoTrailingStop(void)
  {
   if(OrderType()==OP_BUY)
     {
      double aboveRange=Bid-OrderOpenPrice();
      //double maxRange=OrderTakeProfit()-OrderStopLoss();
      //double tsReal = Bid - aboveRange*(1.0-aboveRange/maxRange);
      double ts_real=NormalizeDouble(OrderOpenPrice()+m_active_limit*0.5,Digits);

      if(OrderProfit()>0 && (aboveRange>m_active_limit) && OrderStopLoss()<ts_real)
        {
         if(!OrderModify(OrderTicket(),OrderOpenPrice(),ts_real,OrderTakeProfit(),Red))
            Print("Error setting Buy trailing stop: ",GetLastError());
        }
     }
   else if(OrderType()==OP_SELL)
     {
      double belowRange=OrderOpenPrice()-Ask;
      //double maxRange=OrderStopLoss()-OrderTakeProfit();
      //double tsLimit=ATR_FACTOR_TS*m_atr;
      //double tsReal=Ask+belowRange*(1.0-belowRange/maxRange);
      double ts_real=NormalizeDouble(OrderOpenPrice()-m_active_limit*0.5,Digits);

      if(OrderProfit()>0 && (belowRange>m_active_limit) && OrderStopLoss()>ts_real)
        {
         //Print("Sell tsReal is ", tsReal, "; Stop Loss is ", OrderStopLoss());
         if(!OrderModify(OrderTicket(),OrderOpenPrice(),ts_real,OrderTakeProfit(),Red))
            Print("Error setting Sell trailing stop: ",GetLastError());
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CTrailingStopDynamicATR
  {
private:
   double            m_active_limit;
public:
                     CTrailingStopDynamicATR():m_active_limit(10000){}
   void              SetActiveLimit(double limit) {m_active_limit=limit;}
   //--- Do trailing stop for current order;
   void              DoTrailingStop();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CTrailingStopDynamicATR::DoTrailingStop(void)
  {
   double m_atr=iATR(Symbol(),0,7,0);
   double m_atr_p=iATR(Symbol(),0,7,2);

   double m_atr_r= 2*(2*m_atr-m_atr_p);
   if(OrderType()==OP_BUY)
     {
      double aboveRange=Bid-OrderOpenPrice();
      //double maxRange=OrderTakeProfit()-OrderStopLoss();
      //double tsReal = Bid - aboveRange*(1.0-aboveRange/maxRange);
      double ts_real=NormalizeDouble(Bid-m_atr_r,Digits);

      if(OrderProfit()>0 && (aboveRange>m_active_limit) && OrderStopLoss()<ts_real)
        {
         if(!OrderModify(OrderTicket(),OrderOpenPrice(),ts_real,OrderTakeProfit(),Red))
            Print("Error setting Buy trailing stop: ",GetLastError());
        }
     }
   else if(OrderType()==OP_SELL)
     {
      double belowRange=OrderOpenPrice()-Ask;
      //double maxRange=OrderStopLoss()-OrderTakeProfit();
      //double tsLimit=ATR_FACTOR_TS*m_atr;
      //double tsReal=Ask+belowRange*(1.0-belowRange/maxRange);
      double ts_real=NormalizeDouble(Ask+m_atr_r,Digits);

      if(OrderProfit()>0 && (belowRange>m_active_limit) && OrderStopLoss()>ts_real)
        {
         //Print("Sell tsReal is ", tsReal, "; Stop Loss is ", OrderStopLoss());
         if(!OrderModify(OrderTicket(),OrderOpenPrice(),ts_real,OrderTakeProfit(),Red))
            Print("Error setting Sell trailing stop: ",GetLastError());
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CTrailingStopATRRatchet
  {
private:
   double            m_active_limit;
   bool              m_breakeven;
public:
                     CTrailingStopATRRatchet():m_active_limit(10000){}
   void              SetActiveLimit(double limit) {m_active_limit=limit;}
   void              SetBreakEven(bool be) {m_breakeven=be;}
   //--- Do trailing stop for current order;
   void              DoTrailingStop();
   double            GetATR(int i) {return iATR(Symbol(),0,7,i);}
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CTrailingStopATRRatchet::DoTrailingStop(void)
  {
   double atr=0;
   int i=1;
   for(; Time[i]>OrderOpenTime(); i++)
     {
      atr+=0.05*GetATR(i);
     }

   SetActiveLimit(GetATR(i));

   if(OrderType()==OP_BUY)
     {
      if(m_breakeven && OrderStopLoss()>OrderOpenPrice())
        {
         return;
        }
      double startPrice= Low[iLowest(Symbol(),0,MODE_LOW,10)];
      double aboveRange=Bid-OrderOpenPrice();
      double ts_real=NormalizeDouble(startPrice+atr,Digits);

      if(OrderProfit()>0 && (aboveRange>m_active_limit) && OrderStopLoss()<ts_real && ts_real<Bid)
        {
         if(!OrderModify(OrderTicket(),OrderOpenPrice(),ts_real,OrderTakeProfit(),Red))
            Print("Error setting Buy trailing stop: ",GetLastError());
        }
     }
   else if(OrderType()==OP_SELL)
     {
      if(m_breakeven && OrderStopLoss()<OrderOpenPrice())
        {
         return;
        }
      double startPrice= High[iHighest(Symbol(),0,MODE_LOW,10)];
      double belowRange=OrderOpenPrice()-Ask;
      double ts_real=NormalizeDouble(startPrice-atr,Digits);

      if(OrderProfit()>0 && (belowRange>m_active_limit) && OrderStopLoss()>ts_real && ts_real>Ask)
        {
         //Print("Sell tsReal is ", tsReal, "; Stop Loss is ", OrderStopLoss());
         if(!OrderModify(OrderTicket(),OrderOpenPrice(),ts_real,OrderTakeProfit(),Red))
            Print("Error setting Sell trailing stop: ",GetLastError());
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CTSPercentage
  {
private:
   double            m_active_limit;
public:
                     CTSPercentage():m_active_limit(10000){}
   void              SetActiveLimit(double limit) {m_active_limit=limit;}
   //--- Do trailing stop for current order;
   void              DoTrailingStop(double,double);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CTSPercentage::DoTrailingStop(double initStopLoss,double initTakeProfit)
  {
   double m_atr=iATR(Symbol(),0,7,0);
   double m_atr_p=iATR(Symbol(),0,7,2);
   double m_atr_r= (2*m_atr-m_atr_p);

   if(OrderType()==OP_BUY)
     {
      double range=Bid-OrderOpenPrice();
      double maxRange=initTakeProfit-OrderOpenPrice();
      double stopLoss= initStopLoss+range/maxRange*(initTakeProfit-initStopLoss);
      double tsReal;
      if(range>maxRange)
        {
         tsReal=NormalizeDouble(Bid-m_atr_r,Digits);
        }
      else
        {
         tsReal=NormalizeDouble(stopLoss-m_atr_r,Digits);
        }

      if(OrderProfit()>0 && OrderStopLoss()<tsReal)
        {
         if(!OrderModify(OrderTicket(),OrderOpenPrice(),tsReal,OrderTakeProfit(),Red))
            Print("Error setting Buy trailing stop: ",GetLastError());
        }
     }
   else if(OrderType()==OP_SELL)
     {
      double range=OrderOpenPrice()-Ask;
      double maxRange=OrderOpenPrice()-initTakeProfit;
      double stopLoss= initStopLoss-range/maxRange*(initStopLoss-initTakeProfit);
      double tsReal;
      if(range>maxRange)
        {
         tsReal=NormalizeDouble(Ask+m_atr_r,Digits);
        }
      else
        {
         tsReal=NormalizeDouble(stopLoss+m_atr_r,Digits);
        }
      if(OrderProfit()>0 && OrderStopLoss()>tsReal)
        {
         //Print("Sell tsReal is ", tsReal, "; Stop Loss is ", OrderStopLoss());
         if(!OrderModify(OrderTicket(),OrderOpenPrice(),tsReal,OrderTakeProfit(),Red))
            Print("Error setting Sell trailing stop: ",GetLastError());
        }
     }
  }
//+------------------------------------------------------------------+
