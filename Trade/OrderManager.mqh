//+------------------------------------------------------------------+
//|                                           Trade/OrderManager.mqh |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015-2016, Li Ding"
#property link      "dingmaotu@hotmail.com"
#property strict

#include <stdlib.mqh>
#include "FxSymbol.mqh"
#include "../Collection/IntVector.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class OrderManager
  {
private:
   FxSymbol          m_symbol;
   int               m_magic;

   int const         M_DIGITS;
   double const      M_POINT;
   double const      M_MINLOT;

protected:
   int               getOrderType(bool buyOrSell,double requestPrice);

   double            ask() {return m_symbol.getAsk();}
   double            bid() {return m_symbol.getBid();}

   double            normalizeLots(double lots);

   double            normalizePrice(double price) {return NormalizeDouble(price,M_DIGITS);}
   double            addPoints(double price,int points) {return points > 0 ? NormalizeDouble(price+points*M_POINT,M_DIGITS) : 0;}
   double            subPoints(double price,int points) {return points > 0 ? NormalizeDouble(price-points*M_POINT,M_DIGITS) : 0;}

public:
                     OrderManager(string symbol="",int magic=0);

   int               send(int cmd,double lots,double price,double stoploss,double takeprofit);

   int               buy(double lots,double stoploss,double takeprofit);
   int               sell(double lots,double stoploss,double takeprofit);
   int               pendBuy(double price,double lots,double stoploss,double takeprofit);
   int               pendSell(double price,double lots,double stoploss,double takeprofit);

   int               buy(double lots,int stoploss,int takeprofit) {return buy(lots,subPoints(ask(),stoploss),addPoints(ask(),takeprofit));}
   int               sell(double lots,int stoploss,int takeprofit) {return sell(lots,addPoints(bid(),stoploss),subPoints(bid(),takeprofit));}
   int               pendBuy(double price,double lots,int stoploss,int takeprofit) {return pendBuy(price,lots,subPoints(price,stoploss),addPoints(price,takeprofit));}
   int               pendSell(double price,double lots,int stoploss,int takeprofit) {return pendSell(price,lots,addPoints(price,stoploss),subPoints(price,takeprofit));}

   bool              getOrders(IntVector &v,int type=-1);
   bool              select(int ticket);

   bool              closeCurrent();
   bool              close(int ticket);
   void              closeByType(int type);
   void              closeAll();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
OrderManager::OrderManager(string symbol,int magic)
   :m_symbol(symbol),
     m_magic(magic),
     M_POINT(m_symbol.getPoint()),
     M_DIGITS(m_symbol.getDigits()),
     M_MINLOT(m_symbol.getMinLot())
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double OrderManager::normalizeLots(double lots)
  {
   return lots > M_MINLOT ? lots : M_MINLOT;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OrderManager::getOrderType(bool buyOrSell,double normalizedPrice)
  {
   double marketPrice=buyOrSell ? ask() : bid();

   int stopLevel=m_symbol.getStopLevel();

   double minPrice = NormalizeDouble(marketPrice - stopLevel*M_POINT, M_DIGITS);
   double maxPrice = NormalizeDouble(marketPrice + stopLevel*M_POINT, M_DIGITS);

   int cmd;
   if(normalizedPrice<minPrice)
     {
      cmd=buyOrSell ? OP_BUYLIMIT : OP_SELLSTOP;
     }
   else if(normalizedPrice>maxPrice)
     {
      cmd=buyOrSell ? OP_BUYSTOP : OP_SELLLIMIT;
     }
   else
     {
      cmd=buyOrSell ? OP_BUY : OP_SELL;
     }
   return cmd;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OrderManager::send(int cmd,double lots,double price,double stoploss,double takeprofit)
  {
   int ticket=OrderSend(m_symbol.getName(),cmd,lots,price,3,stoploss,takeprofit,"",m_magic,0,cmd%2==0?Blue:Red);

   if(ticket<0)
     {
      Print("OrderSend error: ",ErrorDescription(GetLastError()));
     }

   return ticket;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OrderManager::buy(double lots,double stoploss,double takeprofit)
  {
   return send(OP_BUY, normalizeLots(lots), ask(), normalizePrice(stoploss), normalizePrice(takeprofit));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OrderManager::sell(double lots,double stoploss,double takeprofit)
  {
   return send(OP_SELL, normalizeLots(lots), bid(), normalizePrice(stoploss), normalizePrice(takeprofit));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OrderManager::pendBuy(double price,double lots,double stoploss,double takeprofit)
  {
   double p=normalizePrice(price);
   int cmd=getOrderType(true,p);
   return send(cmd,normalizeLots(lots),p,normalizePrice(stoploss),normalizePrice(takeprofit));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OrderManager::pendSell(double price,double lots,double stoploss,double takeprofit)
  {
   double p=normalizePrice(price);
   int cmd=getOrderType(false,p);
   return send(cmd,normalizeLots(lots),p,normalizePrice(stoploss),normalizePrice(takeprofit));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool OrderManager::getOrders(IntVector &v,int type)
  {
   int total=OrdersTotal();
   for(int i=0;i<total;i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false)
        {
         return false;
        }
      if(OrderSymbol()==m_symbol.getName() && OrderMagicNumber()==m_magic && (type==-1 || OrderType()==type))
        {
         v.push(OrderTicket());
        }
     }
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool OrderManager::select(int ticket)
  {
   return OrderSelect(ticket,SELECT_BY_TICKET);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool OrderManager::closeCurrent(void)
  {
   int type=OrderType();
   int ticket=OrderTicket();
   double lots=OrderLots();
   double p;

   if(type==OP_SELL) p=ask();
   else if(type==OP_BUY) p=bid();
   else p=-1;

   if(p>0)
     {
      if(!OrderClose(ticket,lots,p,3,White))
        {
         Print("OrderClose #",ticket," error: ",ErrorDescription(GetLastError()));
         return false;
        }
     }
   else
     {
      if(!OrderDelete(ticket,White))
        {
         Print("OrderDelete #",ticket," error ",ErrorDescription(GetLastError()));
         return false;
        }
     }
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool OrderManager::close(int ticket)
  {
   if(!select(ticket)) {return false;}
   return closeCurrent();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OrderManager::closeByType(int type)
  {
   IntVector v;
   if(!getOrders(v,type))
     {
      Print(__FUNCTION__,": Getting orders failed");
      return;
     }

   int total=v.size();
   for(int i=0;i<total;i++)
     {
      close(v.get(i));
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OrderManager::closeAll()
  {
   closeByType(-1);
  }
//+------------------------------------------------------------------+
