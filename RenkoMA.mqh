//+------------------------------------------------------------------+
//|                                               CSmallCandleEA.mqh |
//|                                          Copyright 2014, Li Ding |
//|                                             http://dingmaotu.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, Li Ding"
#property link      "http://dingmaotu.com"
#property strict

#include <LiDing/RenkoIndicator.mqh>
#include <LiDing/CBaseEA.mqh>
#include <LiDing/CTrailingStop.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class RenkoMA: public CBaseEA
  {
protected:
   RenkoIndicator    renkoIndicator;
   int               type;

   int               currentOrderNum;
   double            currentBuyLot;
   double            currentSellLot;
   double            currentBuyProfit;
   double            currentSellProfit;

public:
                     RenkoMA(int,int);
                    ~RenkoMA() {}

   double            GetLots();

   void              UpdateOrdersBuyHook();
   void              UpdateOrdersSellHook();
   void              UpdateIndicators();
   void              TickHook();
   void              BeforeTick();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
RenkoMA::RenkoMA(int barSize, int eaType)
   :renkoIndicator(7,25,barSize)
  {
   type = eaType;
   currentOrderNum=0;
   currentBuyLot=0;
   currentSellLot=0;
   currentBuyProfit=0;
   currentSellProfit=0;

   MqlRates rs[];
   int barsToCopy=Bars;
   CopyRates(Symbol(),1,0,barsToCopy,rs);
   renkoIndicator.loadRates(rs,0,barsToCopy);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double RenkoMA::GetLots()
  {

   return DefaultLots;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void RenkoMA::BeforeTick(void)
  {
   currentBuyProfit=0;
   currentSellProfit=0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void RenkoMA::UpdateOrdersBuyHook(void)
  {
   if(MaxHours>0 && (TimeCurrent()-OrderOpenTime())>3600*MaxHours)
     {
      CloseCurrentOrder();
     }
   currentBuyProfit+=OrderProfit();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void RenkoMA::UpdateOrdersSellHook(void)
  {
   if(MaxHours>0 && (TimeCurrent()-OrderOpenTime())>3600*MaxHours)
     {
      CloseCurrentOrder();
     }
   currentSellProfit+=OrderProfit();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
RenkoMA::UpdateIndicators(void)
  {
   renkoIndicator.moveTo(Close[0]);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void RenkoMA::TickHook(void)
  {
   if(renkoIndicator.isLong())
     {
      if(type==1)
        {
         Buy(StopLoss,TakeProfit);
        }
      else if(type==2)
        {
         Buy(StopLoss,TakeProfit);
         if(currentSellProfit<0)
           {
            CloseAllOrders(OP_SELL);
           }
        }
      else if(type==3)
        {
         if(currentSellProfit<0)
           {
            Buy(StopLoss,TakeProfit);
            CloseAllOrders(OP_SELL);
           }
        }
      else if(type==4)
        {
         if(currentSellProfit<0)
           {
            CloseAllOrders(OP_SELL);
            Buy(StopLoss,TakeProfit);
              } else {
            Sell(StopLoss,TakeProfit/2);
           }
        }
     }

   if(renkoIndicator.isShort())
     {
      if(type==1)
        {
         Sell(StopLoss,TakeProfit);
        }
      else if(type==2)
        {
         Sell(StopLoss,TakeProfit);
         if(currentBuyProfit<0)
           {
            CloseAllOrders(OP_BUY);
           }
        }
      else if(type==3)
        {
         if(currentBuyProfit<0)
           {
            Sell(StopLoss,TakeProfit);
            CloseAllOrders(OP_BUY);
           }
        }
      else if(type==4)
        {
         if(currentBuyProfit<0)
           {
            CloseAllOrders(OP_BUY);
            Sell(StopLoss,TakeProfit);
              } else {
            Buy(StopLoss,TakeProfit/2);
           }
        }
     }
  }
//+------------------------------------------------------------------+
