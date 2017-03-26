//+------------------------------------------------------------------+
//|                                           Trade/OrderManager.mqh |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015-2016, Li Ding"
#property link      "dingmaotu@hotmail.com"
#property strict

#include "FxSymbol.mqh"
#include "OrderPool.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class OrderManager
  {
private:
   FxSymbol         *m_symbol;

   ObjectAttr(int,magic,Magic);
   ObjectAttr(int,slippage,Slippage);
   ObjectAttr(color,buyColor,BuyColor);
   ObjectAttr(color,sellColor,SellColor);
   ObjectAttr(color,closeColor,CloseColor);

protected:
   int               getOrderType(bool buyOrSell,double requestPrice);

   double            ask() {return m_symbol.getAsk();}
   double            bid() {return m_symbol.getBid();}
   double            p(double price) {return m_symbol.normalizePrice(price);}
   double            l(double lots) {return m_symbol.normalizeLots(lots);}
   // order type factor: buy order 1, sell order -1
   int               otf(int cmd) {return cmd%2==0?1:-1;}

   int               send(int cmd,double lots,double price,double stoploss,double takeprofit);

public:
                     OrderManager(FxSymbol *symbol);

   FxSymbol         *getSymbol() const {return m_symbol;}
   // Order opening
   int               buy(double lots,double stoploss=0.0,double takeprofit=0.0);
   int               sell(double lots,double stoploss=0.0,double takeprofit=0.0);
   int               pendBuy(double price,double lots,double stoploss=0.0,double takeprofit=0.0);
   int               pendSell(double price,double lots,double stoploss=0.0,double takeprofit=0.0);

   int               buy(double lots,int stoploss,int takeprofit)
     {return buy(lots,stoploss==0?0.0:m_symbol.subPoints(ask(),stoploss),takeprofit==0?0.0:m_symbol.addPoints(ask(),takeprofit));}
   int               sell(double lots,int stoploss,int takeprofit)
     {return sell(lots,stoploss==0?0.0:m_symbol.addPoints(bid(),stoploss),takeprofit==0?0.0:m_symbol.subPoints(bid(),takeprofit));}
   int               pendBuy(double price,double lots,int stoploss,int takeprofit)
     {return pendBuy(price,lots,stoploss==0?0.0:m_symbol.subPoints(price,stoploss),takeprofit==0?0.0:m_symbol.addPoints(price,takeprofit));}
   int               pendSell(double price,double lots,int stoploss,int takeprofit)
     {return pendSell(price,lots,stoploss==0?0.0:m_symbol.addPoints(price,stoploss),takeprofit==0?0.0:m_symbol.subPoints(price,takeprofit));}

   // isomorphic order sending: positive lots for buy, negative lots for sell, and zero lots for doing nothing
   int               send(double lots,int stoploss,int takeprofit)
     {
      if(lots > 0) return buy(lots, stoploss, takeprofit);
      else if(lots < 0) return sell(-lots, stoploss, takeprofit);
      else return 0;
     }
   // Order modification
   bool              modify(int ticket,double stoploss,double takeprofit);
   bool              modify(int ticket,int stoploss,int takeprofit);
   // Pending order only
   bool              modifyPending(int ticket,double price,datetime expiration=0);

   // Order closing
   bool              closeCurrent();
   bool              close(int ticket);
   bool              closeBy(int ticket,int other);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
OrderManager::OrderManager(FxSymbol *symbol)
   :m_symbol(symbol),
     m_magic(0),
     m_slippage(3),
     m_buyColor(clrBlue),
     m_sellColor(clrRed),
     m_closeColor(clrWhite)
  {}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OrderManager::getOrderType(bool buyOrSell,double normalizedPrice)
  {
   double marketPrice=buyOrSell ? ask() : bid();

   int stopLevel=m_symbol.getStopLevel();

   double minPrice = m_symbol.subPoints(marketPrice, stopLevel);
   double maxPrice = m_symbol.addPoints(marketPrice, stopLevel);

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
   int ticket=OrderSend(m_symbol.getName(),cmd,lots,price,
                        m_slippage,stoploss,takeprofit,"",m_magic,0,
                        cmd%2==0?m_buyColor:m_sellColor);

   if(ticket<0)
     {
      Alert("Error: OrderSend ",ErrorDescription(GetLastError()));
     }

   return ticket;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OrderManager::buy(double lots,double stoploss,double takeprofit)
  {
   return send(OP_BUY, l(lots), ask(), p(stoploss), p(takeprofit));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OrderManager::sell(double lots,double stoploss,double takeprofit)
  {
   return send(OP_SELL, l(lots), bid(), p(stoploss), p(takeprofit));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OrderManager::pendBuy(double price,double lots,double stoploss,double takeprofit)
  {
   double p=p(price);
   int cmd=getOrderType(true,p);
   return send(cmd,l(lots),p,p(stoploss),p(takeprofit));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OrderManager::pendSell(double price,double lots,double stoploss,double takeprofit)
  {
   double p=p(price);
   int cmd=getOrderType(false,p);
   return send(cmd,l(lots),p,p(stoploss),p(takeprofit));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool OrderManager::modify(int ticket,double stoploss,double takeprofit)
  {
   bool success=OrderModify(ticket,0,p(stoploss),p(takeprofit),0);
   if(!success)
     {
      Alert(">>> Error setting stoploss or takeprofit: ",Mql::getErrorMessage(Mql::getLastError()));
     }
   return success;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool OrderManager::modify(int ticket,int stoploss,int takeprofit)
  {
   bool modifyStoploss=stoploss>0;
   bool modifyTakeprofit=takeprofit>0;
   if(!(modifyStoploss || modifyTakeprofit)) return false;

   bool success=OrderPool::selectByTicket(ticket);

   if(success)
     {
      double price=Order::OpenPrice();
      int factor=otf(Order::Type());
      success=modify(ticket,
                     modifyStoploss?m_symbol.subPoints(price,stoploss*factor):0.0,
                     modifyTakeprofit?m_symbol.addPoints(price,takeprofit*factor):0.0);
     }
   return success;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool OrderManager::modifyPending(int ticket,double price,datetime expiration)
  {
   bool success=OrderModify(ticket,p(price),0,0,expiration);
   if(!success)
     {
      Alert(StringFormat(">>> Error modify pending order #%d: %s",ticket,Mql::getErrorMessage(Mql::getLastError())));
     }
   return success;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool OrderManager::closeCurrent(void)
  {
   int type=Order::Type();
   int ticket=Order::Ticket();
   double lots=Order::Lots();
   double p;

   if(type==OP_SELL) p=ask();
   else if(type==OP_BUY) p=bid();
   else p=-1;

   if(p>0)
     {
      if(!OrderClose(ticket,lots,p,m_slippage,m_closeColor))
        {
         Alert(">>> Error OrderClose #",ticket,": ",Mql::getErrorMessage(Mql::getLastError()));
         return false;
        }
     }
   else
     {
      if(!OrderDelete(ticket,m_closeColor))
        {
         Alert(">>> Error OrderDelete #",ticket,": ",Mql::getErrorMessage(Mql::getLastError()));
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
   if(!OrderPool::selectByTicket(ticket)) {return false;}
   return closeCurrent();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool OrderManager::closeBy(int ticket,int other)
  {
   return OrderCloseBy(ticket, other, m_closeColor);
  }
//+------------------------------------------------------------------+
