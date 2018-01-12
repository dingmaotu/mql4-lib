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
//+------------------------------------------------------------------+
//| This module wraps OrdersHistoryTotal, OrdersTotal,               |
//| and OrderSelect functions                                        |
//| The OrderPool is an unordered collection of Orders, so you can   |
//| not random access it. It is recommended that you use the class   |
//| OrderPoolIter or the macro foreachorder to iterate through an    |
//| order pool.                                                      |
//+------------------------------------------------------------------+
class OrderPool: public OrderMatcher
  {
public:
   virtual int       total() const=0;
   virtual bool      select(int i) const=0;
   virtual bool      matches() const=0;
  };
//+------------------------------------------------------------------+
//| The pool of orders from the Terminal order history tab           |
//+------------------------------------------------------------------+
class HistoryPool: public OrderPool
  {
public:
   int               total() const final {return OrdersHistoryTotal();}
   bool              select(int i) const final {return OrderSelect(i,SELECT_BY_POS,MODE_HISTORY);}
   virtual bool      matches() const {return true;}
  };
//+------------------------------------------------------------------+
//| Currently active orders                                          |
//+------------------------------------------------------------------+
class TradingPool: public OrderPool
  {
public:
   int               total() const final {return OrdersTotal();}
   bool              select(int i) const final {return OrderSelect(i,SELECT_BY_POS,MODE_TRADES);}
   virtual bool      matches() const {return true;}
  };
//+------------------------------------------------------------------+
//| For internal use: iterate through an OrderPool                   |
//+------------------------------------------------------------------+
class OrderPoolIter final
  {
private:
   const OrderPool *m_pool;
   int               m_total;
   int               m_i;
protected:
   void              searchNext() {while(m_i<m_total && !(m_pool.select(m_i) && m_pool.matches())) m_i++;}
public:
                     OrderPoolIter(const OrderPool *pool):m_pool(pool),m_total(m_pool.total()),m_i(0) {searchNext();}
                     OrderPoolIter(const OrderPool &pool):m_pool(GetPointer(pool)),m_total(m_pool.total()),m_i(0) {searchNext();}

   bool              end() const {return m_i>=m_total;}
   void              next() { m_i++; searchNext(); }
  };
#define foreachorder(OrderPoolVar) for(OrderPoolIter __it__(OrderPoolVar); !__it__.end(); __it__.next())
//+------------------------------------------------------------------+
