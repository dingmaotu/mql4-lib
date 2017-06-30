//+------------------------------------------------------------------+
//| Module: Trade/OrderPool.mqh                                      |
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

#include "Order.mqh"
#include "../Collection/Vector.mqh"
//+------------------------------------------------------------------+
//| This module wraps OrdersHistoryTotal, OrdersTotal,               |
//| and OrderSelect functions                                        |
//+------------------------------------------------------------------+
class OrderPool
  {
public:
   static bool       selectByTicket(int ticket) {return OrderSelect(ticket,SELECT_BY_TICKET);}

   virtual int       total() const=0;
   virtual bool      select(int i) const=0;

   int               filter(OrderMatcher &matcher,Vector<int>&group) const;
  };
//+------------------------------------------------------------------+
//| Put matched order tickets to group                               |
//+------------------------------------------------------------------+
int OrderPool::filter(OrderMatcher &matcher,Vector<int>&group) const
  {
   int t=total();
   int matched=0;
   for(int i=0; i<t; i++)
     {
      if(select(i) && matcher.matches())
        {
         group.add(Order::Ticket());
         matched++;
        }
     }
   return matched;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class HistoryPool: public OrderPool
  {
public:
   int        total() const {return OrdersHistoryTotal();}
   bool       select(int i) const {return OrderSelect(i,SELECT_BY_POS,MODE_HISTORY);}
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class TradingPool: public OrderPool
  {
public:
   int        total() const {return OrdersTotal();}
   bool       select(int i) const {return OrderSelect(i,SELECT_BY_POS,MODE_TRADES);}
  };
//+------------------------------------------------------------------+
