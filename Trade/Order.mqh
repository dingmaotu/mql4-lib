//+------------------------------------------------------------------+
//| Module: Trade/Order.mqh                                          |
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

#include "../Lang/String.mqh"
//+------------------------------------------------------------------+
//| if current order matches                                         |
//+------------------------------------------------------------------+
interface OrderMatcher
  {
   bool matches() const;
  };
//+------------------------------------------------------------------+
//| Some contant strings                                             |
//+------------------------------------------------------------------+
const string OrderTypeString[]={"buy","sell","buy limit","sell simit","buy stop","sell stop","balance"};
const string ORDER_FROM_STR="from #";
const string ORDER_PARTIAL_CLOSE_STR="partial close";
const string ORDER_CLOSE_HEDGE_BY_STR="close hedge by #";
//+------------------------------------------------------------------+
//| Implements Order Semantics: needs symbol and type to function    |
//+------------------------------------------------------------------+
class OrderBase
  {
private:
   static ENUM_SYMBOL_INFO_DOUBLE ST[2];
   static ENUM_SYMBOL_INFO_DOUBLE ET[2];
   static int        DT[2];
   int               st,et,d;
protected:
   string            symbol;
   int               type;
public:

                     OrderBase(string s,int t):symbol(s),type(t)
     {
      //--- order semantics
      st=ST[t&1];
      et=ET[t&1];
      d=DT[t&1];
     }

   string            getSymbol() const { return symbol;}
   int               getType() const { return type;}

   // absolute price difference of point value `p`
   double            ap(int p) const {return p*SymbolInfoDouble(symbol,SYMBOL_POINT);}

   // format the price with respect to current order symbol digits
   string            f(double p) const {return DoubleToString(p,(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS));}

   // normalize the price with respect to current order symbol digits
   double            n(double p) const {return NormalizeDouble(p,(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS));}

   // the price to start an order
   double            s() const {return SymbolInfoDouble(symbol,st);}

   // the price to end an order
   double            e() const {return SymbolInfoDouble(symbol,et);}

   // the profit (in absolute price difference) from price `s` to price `e`
   double            p(double s,double e) const {return d*(e-s);}

   // the target price if we start from `p` and we want to profit `pr`
   double            pp(double p,double pr) const {return p+d*pr;}

   // same but use point value as the profit
   double            pp(double p,int pr) const {return p+d*ap(pr);}

public:
   static int        D(int t) {return DT[t&1];}

   static double     AP(string s,int p) {return p*SymbolInfoDouble(s,SYMBOL_POINT);}
   static string     F(string s,double p) {return DoubleToString(p,(int)SymbolInfoInteger(s,SYMBOL_DIGITS));}
   static double     N(string s,double p) {return NormalizeDouble(p,(int)SymbolInfoInteger(s,SYMBOL_DIGITS));}

   static double     S(string s,int t) {return SymbolInfoDouble(s,ST[t&1]);}
   static double     E(string s,int t) {return SymbolInfoDouble(s,ET[t&1]);}

   static double     P(int t,double s,double e) {return D(t)*(e-s);}
   static double     PP(int t,double p,double pr) {return p+D(t)*pr;}
   static double     PP(string s,int t,double p,int pr) {return p+D(t)*AP(s,pr);}
  };
static ENUM_SYMBOL_INFO_DOUBLE OrderBase::ST[2]={SYMBOL_ASK,SYMBOL_BID};
static ENUM_SYMBOL_INFO_DOUBLE OrderBase::ET[2]={SYMBOL_BID,SYMBOL_ASK};
static int OrderBase::DT[2]={1,-1};
//+------------------------------------------------------------------+
//| Order (immutable)                                                |
//| Creating a new Order captures all properties of a current        |
//| selected order                                                   |
//+------------------------------------------------------------------+
class Order: public OrderBase
  {
protected:
   int               ticket;
   double            lots;

   double            openPrice;
   datetime          openTime;
   double            closePrice;
   datetime          closeTime;

   double            takeProfit;
   double            stopLoss;

   datetime          expiration;

   int               magicNumber;
   string            comment;

   double            commission;

   double            profit;
   double            swap;
public:
                     Order();
   string            toString() const;
   int               hash() const {return ticket;}

   static bool       Select(int ticket) {return OrderSelect(ticket,SELECT_BY_TICKET);}

   //--- static wrappers for getting order properties
   //--- this is necessary if you want to use these functions as function pointers
   static int        Ticket() { return OrderTicket();}

   static string     Symbol() { return OrderSymbol();}
   static int        Type() { return OrderType();}
   static double     Lots() { return OrderLots();}

   static double     OpenPrice() { return OrderOpenPrice();}
   static datetime   OpenTime() { return OrderOpenTime();}
   static double     ClosePrice() { return OrderClosePrice();}
   static datetime   CloseTime() { return OrderCloseTime();}

   static double     TakeProfit() { return OrderTakeProfit();}
   static double     StopLoss() { return OrderStopLoss();}

   static datetime   Expiration() { return OrderExpiration();}

   static int        MagicNumber() { return OrderMagicNumber();}
   static string     Comment() { return OrderComment();}

   static double     Commission() { return OrderCommission();}

   static double     Profit() { return OrderProfit();}
   static double     Swap() { return OrderSwap();}

   //+------------------------------------------------------------------+
   //| The order must be open and there are two situations:             |
   //| 1. If the original order is closed partially                     |
   //| 2. If the original order is closed by hedge and it is larger     |
   //|    than required lots                                            |
   //+------------------------------------------------------------------+
   static bool       IsPartialClose()
     {
      return OrderCloseTime()==0 &&
      StringStartsWith(OrderComment(),ORDER_FROM_STR);
     }
   //+------------------------------------------------------------------+
   //| This order is the result of OrderCloseBy (first argument)        |
   //| This can be used for both closed and open orders                 |
   //+------------------------------------------------------------------+
   static bool       IsCloseBy()
     {
      return StringStartsWith(OrderComment(),ORDER_PARTIAL_CLOSE_STR);
     }
   //+------------------------------------------------------------------+
   //| This closed order is the result of OrderCloseBy (second argument)|
   //| The order must be closed and its lots is 0                       |
   //| If it is a partial close, the resulting new order will have the  |
   //| "from #" comment                                                 |
   //+------------------------------------------------------------------+
   static bool       IsCloseByHedge()
     {
      return OrderCloseTime()>0 && OrderLots() == 0.0;
      // supposedly order lots being zero is enough for determining
      // a hedge close, so the following code might not be necessary
      // StringStartsWith(OrderComment(),ORDER_CLOSE_HEDGE_BY_STR);
     }

   static bool       IsPending() { return OrderType()>1; }

   static double     AP(int p) {return AP(OrderSymbol(),p);}
   static string     F(double p) {return F(OrderSymbol(),p);}
   static double     N(double p) {return N(OrderSymbol(),p);}

   static double     S() {return S(OrderSymbol(),OrderType());}
   static double     E() {return E(OrderSymbol(),OrderType());}

   static double     P(double s,double e) {return P(OrderType(),s,e);}
   static double     PP(double p,double pr) {return PP(OrderType(),p,pr);}
   static double     PP(double p,int pr) {return PP(OrderSymbol(),OrderType(),p,pr);}

   // operations that take order open price as the first parameter
   static double     PPO(double pr) {return PP(OrderType(),OrderOpenPrice(),pr);}
   static double     PPO(int pr) {return PP(OrderSymbol(),OrderType(),OrderOpenPrice(),pr);}
   static bool       IsBreakeven() { return(OrderStopLoss()!=0 && P(OrderOpenPrice(),OrderStopLoss())>=0);}

   //--- instance methods
   double            ppo(double pr) const {return pp(openPrice,pr);}
   double            ppo(int pr) const {return pp(openPrice,pr);}
   bool              isBreakeven() {return(stopLoss!=0 && p(openPrice,stopLoss)>=0);}

   bool              isPartialClose() const {return closeTime==0 && StringStartsWith(comment,ORDER_FROM_STR);}
   bool              isCloseBy() const {return StringStartsWith(comment,ORDER_PARTIAL_CLOSE_STR);}
   bool              isCloseByHedge() const {return closeTime>0 && lots==0.0;}
   bool              isPending() const {return type>1;}

   int               getTicket() const { return ticket;}
   double            getLots() const { return lots;}

   double            getOpenPrice() const { return openPrice;}
   datetime          getOpenTime() const { return openTime;}
   double            getClosePrice() const { return closePrice;}
   datetime          getCloseTime() const { return closeTime;}

   double            getTakeProfit() const { return takeProfit;}
   double            getStopLoss() const { return stopLoss;}

   datetime          getExpiration() const { return expiration;}

   int               getMagicNumber() const { return magicNumber;}
   string            getComment() const { return comment;}

   double            getCommission() const { return commission;}

   double            getProfit() const { return profit;}
   double            getSwap() const { return swap;}
  };
//+------------------------------------------------------------------+
//| Initialize an Order from current order information               |
//+------------------------------------------------------------------+
Order::Order(void)
   :OrderBase(OrderSymbol(),OrderType())
  {
   ticket=OrderTicket();
   lots=OrderLots();

   openPrice=OrderOpenPrice();
   openTime=OrderOpenTime();
   closePrice=OrderClosePrice();
   closeTime=OrderCloseTime();

   takeProfit=OrderTakeProfit();
   stopLoss=OrderStopLoss();

   expiration=OrderExpiration();

   magicNumber=OrderMagicNumber();
   comment=OrderComment();

   commission=OrderCommission();

   profit=OrderProfit();
   swap=OrderSwap();
  }
//+------------------------------------------------------------------+
//| mimic OrderPrint but return a string instead                     |
//+------------------------------------------------------------------+
string Order::toString(void) const
  {
   string res=StringFormat("#%d %s %s %.2f %s "
                           "%s %s %s",
                           ticket,TimeToString(openTime,TIME_DATE|TIME_SECONDS),OrderTypeString[type],lots,symbol,
                           f(openPrice),f(stopLoss),f(takeProfit));
   if(closeTime!=0) res+=" "+TimeToString(closeTime);
   res+=StringFormat(" %s %.2f %.2f %.2f",f(closePrice),commission,swap,profit);
   if(comment!="") res+=" "+comment;
   res+=" "+IntegerToString(magicNumber);
   if(expiration!=0) res+=" expiration "+TimeToString(expiration);
   return res;
  }
//+------------------------------------------------------------------+
