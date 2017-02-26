//+------------------------------------------------------------------+
//|                                            Trade/OrderFilter.mqh |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Li Ding"
#property link      "dingmaotu@hotmail.com"
#property strict

#include "Order.mqh"
#include "../Collection/LinkedList.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class OrderMatcher
  {
public:
   virtual bool      match(const Order &o)=0;
  };

LINKED_LIST(OrderMatcher);
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class OrderFilter
  {
private:
   OrderMatcherList  matcherList;
public:

   void              addMatcher(const OrderMatcher *matcher);
   void              removeMatcher(const OrderMatcher *matcher);
   void              filter()
  };
//+------------------------------------------------------------------+
