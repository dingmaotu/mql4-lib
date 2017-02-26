//+------------------------------------------------------------------+
//|                                                   OrderGroup.mqh |
//|                                          Copyright 2016, Li Ding |
//|                                            dingmaotu@hotmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Li Ding"
#property link      "dingmaotu@hotmail.com"
#property strict

#include "../Collection/Vector.mqh"
#include "FxSymbol.mqh"
#include "OrderPool.mqh"
//+------------------------------------------------------------------+
//| A group of orders for a symbol                                   |
//+------------------------------------------------------------------+
class OrderGroup: public Vector<int>
  {
public:
   const FxSymbol    SYMBOL;
                     OrderGroup(string symbol=""):Vector<int>(10),SYMBOL(symbol) {}

   void              groupTakeProfit(double price);
   void              groupStopLoss(double price);

   double            groupAvg();
   double            groupProfit();

   void              clearClosed();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double OrderGroup::groupAvg(void)
  {
   double lotPriceSum=0.0;
   double lotSum=0.0;
   int s=size();
   if(s==0) return 0.0;
   for(int i=0; i<s; i++)
     {
      OrderPool::selectByTicket(get(i));
      lotSum+=OrderLots();
      lotPriceSum+=OrderLots()*OrderOpenPrice();
     }
   return NormalizeDouble(lotPriceSum/lotSum, SYMBOL.getDigits());
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double OrderGroup::groupProfit(void)
  {
   double profitSum=0.0;
   int s=size();
   if(s==0) return 0.0;
   for(int i=0; i<s; i++)
     {
      OrderPool::selectByTicket(get(i));
      profitSum+=OrderProfit();
     }
   return profitSum;
  }
//+------------------------------------------------------------------+
//| Set a takeprofit for the entire group                            |
//+------------------------------------------------------------------+
void OrderGroup::groupTakeProfit(double price)
  {
   int s=size();
   for(int i=0; i<s; i++)
     {
      if(!OrderModify(get(i),0,0,NormalizeDouble(price,SYMBOL.getDigits()),0,clrNONE))
        {
         Alert(">>> Failed to set takeprofit to order group: %f",price);
        }
     }
  }
//+------------------------------------------------------------------+
//| Set a stoploss for the entire group                              |
//+------------------------------------------------------------------+
void OrderGroup::groupStopLoss(double price)
  {
   int s=size();
   for(int i=0; i<s; i++)
     {
      if(!OrderModify(get(i),0,NormalizeDouble(price,SYMBOL.getDigits()),0,0,clrNONE))
        {
         Alert(">>> Failed to set stoploss to order group: %f",price);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OrderGroup::clearClosed(void)
  {
   int s=size();
   for(int i=0; i<s; i++)
     {
      OrderPool::selectByTicket(get(i));
      if(OrderCloseTime()!=0)
        {
         set(i,NULL);
        }
     }
   compact();
  }
//+------------------------------------------------------------------+
