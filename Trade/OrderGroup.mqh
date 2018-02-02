//+------------------------------------------------------------------+
//| Module: Trade/OrderGroup.mqh                                     |
//| This file is part of the mql4-lib project:                       |
//|     https://github.com/dingmaotu/mql4-lib                        |
//|                                                                  |
//| Copyright 2016 Li Ding <dingmaotu@126.com>                       |
//|                                                                  |
//| Licensed under the Apache License, Version 2.0 (the "License");  |
//| you may not use this file except in compliance with the License. |
//| You may obtain a copy of the License at                          |
//|                                                                  |
//|     http://www.apache.org/licenses/LICENSE-2.0                   |
//|                                                                  |
//| Unless required by applicable law or agreed to in writing,       |
//| software distributed under the License is distributed on an      |
//| "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,     |
//| either express or implied.                                       |
//| See the License for the specific language governing permissions  |
//| and limitations under the License.                               |
//+------------------------------------------------------------------+
#property strict

#include "../Collection/Vector.mqh"
#include "Order.mqh"
#include "FxSymbol.mqh"

typedef double(*OrderDoubleProperty)(void);
typedef void(*OrderOperation)(int);
typedef bool(*OrderSelector)(void);
//+------------------------------------------------------------------+
//| A group of orders for a symbol                                   |
//+------------------------------------------------------------------+
class OrderGroup: public Vector<int>
  {
private:
   FxSymbol         *m_symbol;
   bool              m_ownsSymbol;
public:

                     OrderGroup(string symbol=""):Vector<int>(10),m_symbol(new FxSymbol(symbol)),m_ownsSymbol(true){}
                     OrderGroup(FxSymbol *symbol):Vector<int>(10),m_symbol(symbol),m_ownsSymbol(false) {}
                    ~OrderGroup() {if(m_ownsSymbol && CheckPointer(m_symbol)!=POINTER_INVALID) {delete m_symbol;}}

   void              groupTakeProfit(double price);
   void              groupStopLoss(double price);

   double            groupDoubleProperty(OrderDoubleProperty func);

   double            groupAvg();
   double            groupProfit() {return groupDoubleProperty(Order::Profit);}
   double            groupLots() {return groupDoubleProperty(Order::Lots);}

   void              clearClosed();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double OrderGroup::groupDoubleProperty(OrderDoubleProperty func)
  {
   double total=0.0;
   int s=size();
   for(int i=0; i<s; i++)
     {
      Order::Select(get(i));
      total+=func();
     }
   return total;
  }
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
      Order::Select(get(i));
      lotSum+=OrderLots();
      lotPriceSum+=OrderLots()*OrderOpenPrice();
     }
   return NormalizeDouble(lotPriceSum/lotSum, m_symbol.getDigits());
  }
//+------------------------------------------------------------------+
//| Set a takeprofit for the entire group                            |
//+------------------------------------------------------------------+
void OrderGroup::groupTakeProfit(double price)
  {
   int s=size();
   for(int i=0; i<s; i++)
     {
      if(!OrderModify(get(i),0,0,NormalizeDouble(price,m_symbol.getDigits()),0,clrNONE))
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
      if(!OrderModify(get(i),0,NormalizeDouble(price,m_symbol.getDigits()),0,0,clrNONE))
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
      Order::Select(get(i));
      if(Order::CloseTime()!=0)
        {
         set(i,0);
        }
     }
   removeAll(0);
  }
//+------------------------------------------------------------------+
