//+------------------------------------------------------------------+
//|                                                 OrderManager.mqh |
//|                                          Copyright 2015, Li Ding |
//|                                                dingmaotu@126.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, Li Ding"
#property link      "dingmaotu@126.com"
#property strict

#include <stdlib.mqh>
#include <LiDing/Collection/IntVector.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class OrderManager
  {
private:
   string            m_symbol;
   int               m_magic;
protected:
   static int        getOrderType(bool buyOrSell,double requestPrice);
   static double     normalizeLots(double lots);
   static double     normalizePrice(double price) {return NormalizeDouble(price,Digits);}
   static double     addPoints(double price,int points) {return points > 0 ? NormalizeDouble(price+points*Point,Digits) : 0;}
   static double     subPoints(double price,int points) {return points > 0 ? NormalizeDouble(price-points*Point,Digits) : 0;}
public:
                     OrderManager(string symbol,int magic):m_symbol(symbol),m_magic(magic) {}

   int               send(int cmd,double lots,double price,double stoploss,double takeprofit);

   int               buy(double lots,double stoploss,double takeprofit);
   int               sell(double lots,double stoploss,double takeprofit);
   int               pendBuy(double price,double lots,double stoploss,double takeprofit);
   int               pendSell(double price,double lots,double stoploss,double takeprofit);

   int               buy(double lots,int stoploss,int takeprofit) {return buy(lots,subPoints(Ask,stoploss),addPoints(Ask,takeprofit));}
   int               sell(double lots,int stoploss,int takeprofit) {return sell(lots,addPoints(Bid,stoploss),subPoints(Bid,takeprofit));}
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
double OrderManager::normalizeLots(double lots)
  {
   double minLot=MarketInfo(Symbol(),MODE_MINLOT);
// double lotStep=MarketInfo(Symbol(),MODE_LOTSTEP);
   return lots > minLot ? lots : minLot;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OrderManager::getOrderType(bool buyOrSell,double normalizedPrice)
  {
   double marketPrice=buyOrSell ? Ask : Bid;

   double stopLevel=MarketInfo(Symbol(),MODE_STOPLEVEL);
   double minPrice = NormalizeDouble(marketPrice - stopLevel*Point, Digits);
   double maxPrice = NormalizeDouble(marketPrice + stopLevel*Point, Digits);

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
   int ticket=OrderSend(m_symbol,cmd,lots,price,3,stoploss,takeprofit,"",m_magic,0,cmd%2==0?Blue:Red);

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
   return send(OP_BUY, normalizeLots(lots), Ask, normalizePrice(stoploss), normalizePrice(takeprofit));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OrderManager::sell(double lots,double stoploss,double takeprofit)
  {
   return send(OP_SELL, normalizeLots(lots), Bid, normalizePrice(stoploss), normalizePrice(takeprofit));
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
      if(OrderSymbol()==m_symbol && OrderMagicNumber()==m_magic && (type==-1 || OrderType()==type))
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

   if(type==OP_SELL) p=Ask;
   else if(type==OP_BUY) p=Bid;
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
