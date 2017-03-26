//+------------------------------------------------------------------+
//|                                              Trade/OrderPool.mqh |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Li Ding"
#property link      "dingmaotu@hotmail.com"
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
      if(select(i) && matcher.match())
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
