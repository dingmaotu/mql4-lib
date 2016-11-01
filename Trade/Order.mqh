//+------------------------------------------------------------------+
//|                                                  Trade/Order.mqh |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Li Ding"
#property link      "dingmaotu@hotmail.com"
#property strict

#include "../Lang/Object.mqh"

const string OrderTypeString[]={"buy","sell","buy limit","sell simit","buy stop","sell stop"};
//+------------------------------------------------------------------+
//| Order (immutable)                                                |
//| Creating a new Order captures all properties of a current        |
//| selected order                                                   |
//+------------------------------------------------------------------+
class Order: public Object
  {
private:
   int               ticket;

   string            symbol;
   int               type;
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
   int               hash() const;

   int               getTicket() const { return ticket;}

   string            getSymbol() const { return symbol;}
   int               getType() const { return type;}
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
//|                                                                  |
//+------------------------------------------------------------------+
Order::Order(void)
  {
   ticket=OrderTicket();

   symbol=OrderSymbol();
   type=OrderType();
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
   int digits=(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS);
   string res= StringFormat("#%d %s %s %.2f %s "
                            "%s %s %s",
                            ticket,TimeToString(openTime,TIME_DATE|TIME_SECONDS),OrderTypeString[type],lots,symbol,
                            DoubleToString(openPrice,digits),DoubleToString(stopLoss,digits),DoubleToString(takeProfit,digits));

   if(closeTime!=0)
     {
      res+=" "+TimeToString(closeTime);
     }

   res+=StringFormat(" %s %.2f %.2f %.2f",
                     DoubleToString(closePrice,digits),
                     commission,swap,profit);

   if(comment!="")
     {
      res+=" "+comment;
     }

   res+=" "+IntegerToString(magicNumber);

   if(expiration!=0)
     {
      res+=" expiration "+TimeToString(expiration);
     }

   return res;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Order::hash(void) const
  {
   return ticket;
  }
//+------------------------------------------------------------------+
