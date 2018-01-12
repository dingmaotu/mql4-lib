//+------------------------------------------------------------------+
//| Module: Trade/OrderTracker.mqh                                   |
//| This file is part of the mql4-lib project:                       |
//|     https://github.com/dingmaotu/mql4-lib                        |
//|                                                                  |
//| Copyright 2015-2017 Li Ding <dingmaotu@126.com>                  |
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
//+------------------------------------------------------------------+
//| 2017.09.28: Created by Li Ding                                   |
//+------------------------------------------------------------------+
#property strict

#include "../Lang/Mql.mqh"
#include "../Lang/String.mqh"
#include "../Collection/Vector.mqh"
#include "../Collection/HashMap.mqh"
#include "OrderPool.mqh"
//+------------------------------------------------------------------+
//| Given a string and a prefix string, extract the remaining part.  |
//| The remaining part is expected to be an integer.                 |
//+------------------------------------------------------------------+
int ExtractIntegerPostfix(string comment,const string &prefix)
  {
   return (int)StringToInteger(StringSubstr(comment,StringLen(prefix)));
  }
//+------------------------------------------------------------------+
//| Basic units for tracking                                         |
//+------------------------------------------------------------------+
class TrackedOrder: public Order
  {
private:
   bool              m_tracked;
public:
                     TrackedOrder(bool tracked=true):m_tracked(tracked) {}
   bool              isTracked() const {return m_tracked;}
   void              setTracked(bool value) {m_tracked=value;}
  };
//+------------------------------------------------------------------+
//| Track the changes of an order pool                               |
//| This class does not support tracking partial closeby orders      |
//| For normal closeby, it is treated as if it is normal close       |
//+------------------------------------------------------------------+
class OrderTracker
  {
private:
   TradingPool      *m_pool;
   HashMap<int,TrackedOrder*>m_orders;
public:
                     OrderTracker(TradingPool *pool);

   void              track();

   int               getOrders(Vector<Order*>&orders)
     {
      foreachm(int,ticket,TrackedOrder*,order,m_orders)
        {
         orders.add(order);
        }
      return orders.size();
     }

   virtual void      onStart() {}
   //--- order stoploss or takeprofit change or pending order open price or expiring date change
   virtual void      onChange(const Order *oldOrder,const Order *newOrder) {}
   //--- new opened order: market or pending
   virtual void      onNew(const Order *order) {}
   //--- pending order activation
   virtual void      onActivation(const Order *pendingOrder,const Order *marketOrder) {}
   //--- market order close or pending order delete
   virtual void      onClose(const Order *order) {}
   //--- market order partial close
   virtual void      onPartialClose(const Order *oldOrder,const Order *newOrder) {}
   virtual void      onEnd() {}
  };
//+------------------------------------------------------------------+
//| Sender initialization:                                           |
//| 1. m_orders owns the orders that it trackes                      |
//| 2. Populate existing orders                                      |
//+------------------------------------------------------------------+
OrderTracker::OrderTracker(TradingPool *pool)
   :m_orders(NULL,true),m_pool(pool)
  {
   foreachorder(m_pool)
     {
      TrackedOrder *o=new TrackedOrder();
      m_orders.set(o.getTicket(),o);
     }
  }
//+------------------------------------------------------------------+
//| check for order changes                                          |
//+------------------------------------------------------------------+
void OrderTracker::track(void)
  {
   onStart();

   foreachm(int,ticket,TrackedOrder*,order,m_orders) {order.setTracked(false);}

   foreachorder(m_pool)
     {
      TrackedOrder *no=new TrackedOrder();

      if(m_orders.contains(no.getTicket()))
        {
         TrackedOrder *oo=m_orders[no.getTicket()];

         // pending order activation
         if(oo.isPending() && !no.isPending())
           {
            onActivation(oo,no);
            m_orders.set(no.getTicket(),no);
            SafeDelete(oo);
           }
         else
           {
            // see if there are changes
            bool takeProfitChanges=!Mql::isEqual(no.getTakeProfit(),oo.getTakeProfit());
            bool stopLossChanges=!Mql::isEqual(no.getStopLoss(),oo.getStopLoss());
            bool openPriceChanges=no.isPending() && !Mql::isEqual(no.getOpenPrice(),oo.getOpenPrice());
            bool expirationChanges=no.isPending() && no.getExpiration()!=oo.getExpiration();

            if(takeProfitChanges || stopLossChanges || openPriceChanges || expirationChanges)
              {
               onChange(oo,no);
               m_orders.set(no.getTicket(),no);
               SafeDelete(oo);
              }
            else
              {
               oo.setTracked(true);
               SafeDelete(no);
              }
           }
        }
      else if(no.isPartialClose())
        {
         int originalTicket=ExtractIntegerPostfix(no.getComment(),ORDER_FROM_STR);
         TrackedOrder *oo=m_orders[originalTicket];
         m_orders.set(no.getTicket(),no);
         if(oo!=NULL)
           {
            onPartialClose(oo,no);
            m_orders.remove(oo.getTicket());
           }
         else
           {
            Print(">>> Critical error: Original order is not tracked while it is closed!");
           }
        }
      else
        {
         m_orders.set(no.getTicket(),no);
         onNew(no);
        }
     }

   foreachm(int,ticket,TrackedOrder*,order,m_orders)
     {
      if(!order.isTracked())
        {
         onClose(order);
         it.remove();
        }
     }

   onEnd();
  }
//+------------------------------------------------------------------+
