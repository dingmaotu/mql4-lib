//+------------------------------------------------------------------+
//| Module: Trade/OrderManager.mqh                                   |
//| This file is part of the mql4-lib project:                       |
//|     https://github.com/dingmaotu/mql4-lib                        |
//|                                                                  |
//| Copyright 2015-2016 Li Ding <dingmaotu@126.com>                  |
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

#include "../Lang/Mql.mqh"
#include "../Utils/Math.mqh"
#include "Order.mqh"
#include "Terminal.mqh"
#include "Account.mqh"
//+------------------------------------------------------------------+
//| OrderManager wraps order sending/modification/closing functions  |
//+------------------------------------------------------------------+
class OrderManager
  {
   ObjectAttr(int,magic,Magic);
   ObjectAttr(int,slippage,Slippage);
   ObjectAttr(color,closeColor,CloseColor);

   // last error implementation
private:
   int               m_lastError;
public:
   int               getLastError() {int err=m_lastError;m_lastError=0;return err;}

   // custom implementation of BuyColor/SellColor properties
private:
   color             m_color[2];
public:
   color             getBuyColor() const {return m_color[0];}
   color             getSellColor() const {return m_color[1];}
   void              setBuyColor(color value) {m_color[0]=value;}
   void              setSellColor(color value) {m_color[1]=value;}

private:
   //current symbol
   const string      s;
   const double      MINLOT;
   const double      POINT;
   const int         STOPLEVEL;
protected:
   int               deducePendType(int op,double price);

   int               send(int cmd,double lots,double price,double stoploss,double takeprofit,string comment=NULL);
   int               send(int cmd,double lots,double price,int stoploss,int takeprofit,string comment=NULL)
     {
      double sl=stoploss>0 ? OrderBase::PP(s,cmd,price,-stoploss):0.0;
      double tp=takeprofit>0 ? OrderBase::PP(s,cmd,price,takeprofit):0.0;
      return send(cmd,lots,price,sl,tp,comment);
     }
public:
                     OrderManager(string symbol)
   :s(symbol),
        MINLOT(SymbolInfoDouble(symbol,SYMBOL_VOLUME_MIN)),
        POINT(SymbolInfoDouble(symbol,SYMBOL_POINT)),
        STOPLEVEL((int)SymbolInfoInteger(symbol,SYMBOL_TRADE_STOPS_LEVEL)),
        m_magic(0),
        m_slippage(3),
        m_lastError(0),
        m_closeColor(clrWhite)
     {
      m_color[0]=clrBlue;
      m_color[1]=clrRed;
     }

   static bool       IsTradeAllowed(void)
     {
      if(!Terminal::isTradeAllowed())
        {
         Alert(">>> Error: please allow EA trading in Terminal settings!");
         return false;
        }

      if(!Mql::isTradeAllowed())
        {
         Alert(">>> Error: please allow trading in EA settings!");
         return false;
        }

      if(!Mql::isTesting())
        {
         if(!Account::allowsExpertTrade())
           {
            Alert(StringFormat(">>> Error: your server %s does not allow EA trading!",Account::getServerName()));
            return false;
           }
         if(!Account::allowsTrade())
           {
            Alert(StringFormat(">>> Error：your account %s does not allow EA trading!",Account::getLogin()));
            return false;
           }
        }
      return true;
     }

   //--- Order opening

   // market order T=double|int op=OP_BUY|OP_SELL
   template<typename T>
   int               market(int op,double lots,T stoploss,T takeprofit,string comment=NULL)
     {
      return send(op,lots,OrderBase::S(s,op),stoploss,takeprofit,comment);
     }
   // pending order T=double|int op=OP_BUY|OP_SELL
   template<typename T>
   int               pend(int op,double price,double lots,T stoploss,T takeprofit,string comment=NULL)
     {
      double p=OrderBase::N(s,price);
      return send(deducePendType(op,p),lots,p,stoploss,takeprofit,comment);
     }

   // aliases for easier using
   int               buy(double lots,double stoploss,double takeprofit,string comment=NULL) {return market(OP_BUY,lots,stoploss,takeprofit,comment);}
   int               sell(double lots,double stoploss,double takeprofit,string comment=NULL) {return market(OP_SELL,lots,stoploss,takeprofit,comment);}
   int               pendBuy(double price,double lots,double stoploss,double takeprofit,string comment=NULL) {return pend(OP_BUY,price,lots,stoploss,takeprofit,comment);}
   int               pendSell(double price,double lots,double stoploss,double takeprofit,string comment=NULL) {return pend(OP_SELL,price,lots,stoploss,takeprofit,comment);}

   int               buy(double lots,int stoploss=0,int takeprofit=0,string comment=NULL) {return market(OP_BUY,lots,stoploss,takeprofit,comment);}
   int               sell(double lots,int stoploss=0,int takeprofit=0,string comment=NULL) {return market(OP_SELL,lots,stoploss,takeprofit,comment);}
   int               pendBuy(double price,double lots,int stoploss=0,int takeprofit=0,string comment=NULL) {return pend(OP_BUY,price,lots,stoploss,takeprofit,comment);}
   int               pendSell(double price,double lots,int stoploss=0,int takeprofit=0,string comment=NULL) {return pend(OP_SELL,price,lots,stoploss,takeprofit,comment);}

   //--- Order modification
   bool              modify(int ticket,double stoploss,double takeprofit);
   bool              modify(int ticket,int stoploss,int takeprofit);
   bool              modifyPending(int ticket,double price,datetime expiration=0);

   //--- Order closing
   bool              closeCurrent();
   bool              closeCurrent(double lots);
   bool              close(int ticket);
   bool              close(int ticket,double lots);
   bool              closeBy(int ticket,int other)
     {
      bool res=OrderCloseBy(ticket,other,m_closeColor);
      m_lastError=Mql::getLastError();
      return res;
     }
  };
//+------------------------------------------------------------------+
//| Determine the pending order command based on the price           |
//| Internal use only. `price` parameter should always be normalized |
//+------------------------------------------------------------------+
int OrderManager::deducePendType(int op,double price)
  {
   static int PriceBelowMarket[2] = {OP_BUYLIMIT,OP_SELLSTOP};
   static int PriceAboveMarket[2] = {OP_BUYSTOP,OP_SELLLIMIT};

   double marketPrice=OrderBase::S(s,op);

   double minPrice = marketPrice-STOPLEVEL*POINT;
   double maxPrice = marketPrice+STOPLEVEL*POINT;

   if(price<minPrice)
     {
      return PriceBelowMarket[op&1];
     }
   else if(price>maxPrice)
     {
      return PriceAboveMarket[op&1];
     }
   else
     {
      return op;
     }
  }
//+------------------------------------------------------------------+
//| Raw send command for both pending and market orders              |
//| Takes care of normaling lots and prices                          |
//| Internal use only. `price` parameter should always be normalized |
//+------------------------------------------------------------------+
int OrderManager::send(int cmd,double lots,double price,double stoploss,double takeprofit,string comment=NULL)
  {
   int ticket=OrderSend(s,cmd,Math::roundUpToMultiple(lots,MINLOT),
                        price,m_slippage,
                        OrderBase::N(s,stoploss),
                        OrderBase::N(s,takeprofit),
                        comment,m_magic,0,m_color[cmd&1]);

   if(ticket<0)
     {
      int err=Mql::getLastError();
      m_lastError=err;
      Alert(StringFormat(">>> Error OrderSend[%d]: %s",err,Mql::getErrorMessage(err)));
     }

   return ticket;
  }
//+------------------------------------------------------------------+
//| Raw modify command for all orders                                |
//+------------------------------------------------------------------+
bool OrderManager::modify(int ticket,double stoploss,double takeprofit)
  {
   bool success=OrderModify(ticket,0,OrderBase::N(s,stoploss),OrderBase::N(s,takeprofit),0);
   if(!success)
     {
      int err=Mql::getLastError();
      m_lastError=err;
      Alert(">>> Error modifying #",ticket,": ",Mql::getErrorMessage(err));
     }
   return success;
  }
//+------------------------------------------------------------------+
//| Modify command that take stoploss and takeprofit in points       |
//+------------------------------------------------------------------+
bool OrderManager::modify(int ticket,int stoploss,int takeprofit)
  {
   bool modifyStoploss=stoploss>0;
   bool modifyTakeprofit=takeprofit>0;
   if(!(modifyStoploss || modifyTakeprofit)) return false;
   if(!Order::Select(ticket))
     {
      int err=Mql::getLastError();
      m_lastError=err;
      Alert(">>> Error modifying order with invalid ticket #",ticket,": ",Mql::getErrorMessage(err));
      return false;
     }
   double sl=modifyStoploss ? Order::PPO(-stoploss) : Order::StopLoss();
   double tp=modifyTakeprofit ? Order::PPO(takeprofit) : Order::TakeProfit();
   return modify(ticket,sl,tp);
  }
//+------------------------------------------------------------------+
//| Modify only pending orders                                       |
//+------------------------------------------------------------------+
bool OrderManager::modifyPending(int ticket,double price,datetime expiration)
  {
   bool success=OrderModify(ticket,OrderBase::N(s,price),0,0,expiration);
   if(!success)
     {
      int err=Mql::getLastError();
      m_lastError=err;
      Alert(StringFormat(">>> Error modify pending order #%d[%s]: %s",
            ticket,err,Mql::getErrorMessage(err)));
     }
   return success;
  }
//+------------------------------------------------------------------+
//| Close current selected order                                     |
//+------------------------------------------------------------------+
bool OrderManager::closeCurrent(void)
  {
   if(Order::IsPending())
     {
      if(!OrderDelete(Order::Ticket(),m_closeColor))
        {
         int err=Mql::getLastError();
         m_lastError=err;
         Alert(">>> Error OrderDelete #",Order::Ticket(),": ",Mql::getErrorMessage(err));
         return false;
        }
     }
   else
     {
      if(!OrderClose(Order::Ticket(),Order::Lots(),Order::E(),m_slippage,m_closeColor))
        {
         int err=Mql::getLastError();
         m_lastError=err;
         Alert(">>> Error OrderClose #",Order::Ticket(),": ",Mql::getErrorMessage(err));
         return false;
        }
     }
   return true;
  }
//+------------------------------------------------------------------+
//| Close the order with specified ticket                            |
//+------------------------------------------------------------------+
bool OrderManager::close(int ticket)
  {
   if(!Order::Select(ticket))
     {
      int err=Mql::getLastError();
      m_lastError=err;
      Alert(">>> Error closing order with invalid ticket #",ticket,": ",Mql::getErrorMessage(err));
      return false;
     }
   return closeCurrent();
  }
//+------------------------------------------------------------------+
//| Partially close current selected market order                    |
//+------------------------------------------------------------------+
bool OrderManager::closeCurrent(double lots)
  {
   if(Order::IsPending())
     {
      Alert(">>> Use close() on pending order #",Order::Ticket());
      m_lastError=ERR_NO_RESULT; // signal the failure
      return false;
     }
   if(!OrderClose(Order::Ticket(),lots,Order::E(),m_slippage,m_closeColor))
     {
      int err=Mql::getLastError();
      m_lastError=err;
      Alert(">>> Error OrderClose #",Order::Ticket(),": ",Mql::getErrorMessage(err));
      return false;
     }
   return true;
  }
//+------------------------------------------------------------------+
//| Partially close the market order with specified ticket           |
//+------------------------------------------------------------------+
bool OrderManager::close(int ticket,double lots)
  {
   if(!Order::Select(ticket))
     {
      int err=Mql::getLastError();
      m_lastError=err;
      Alert(">>> Error closing order with invalid ticket #",ticket,": ",Mql::getErrorMessage(err));
      return false;
     }
   return closeCurrent(lots);
  }
//+------------------------------------------------------------------+
