//+------------------------------------------------------------------+
//|                                                        Order.mqh |
//|                                          Copyright 2014, Li Ding |
//|                                                dingmaotu@126.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, Li Ding"
#property link      "dingmaotu@126.com"
#property strict
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Order
  {
private:
   int               magic;
   string            symbol;

   int               ticket;

   double            initialStopLoss;
   double            initialTakeProfit;
   double            stopLoss;
   double            takeProfit;

   int               type;
   double            lots;

   double            profit;
   double            swap;
   double            commission;

   double            openPrice;
   double            closePrice;
   datetime          openTime;
   datetime          closeTime;
   datetime          expiration;

public:
   bool              select(int ticket);

   int               getTicket() const {return ticket;}
   int               getMagic() const {return magic;}

   double            getInitialStopLoss() const {return initialStopLoss;}
   double            getInitialTakeProfit() const {return initialTakeProfit;}
   double            getStopLoss() const {return stopLoss;}
   double            getTakeProfit() const {return takeProfit;}

   int               getType() const {return type;}

   bool              isBuy() const {return type==OP_BUY;}
   bool              isSell() const {return type==OP_SELL;}

   double            getLots() const {return lots;}

   double            getProfit() const {return profit;}
   double            getSwap() const {return swap;}
   double            getCommission() const {return commission;}

   void              setStopLoss(double price) {stopLoss=price;}
   void              setTakeProfit(double price) {takeProfit=price;}

   bool              canTakeProfit();
   bool              canStopLoss();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Order::select(int ticket)
  {
   if(!OrderSelect(ticket,SELECT_BY_TICKET))
     {
      Print("Error select order #",ticket,": ",GetLastError());
      return false;
     }
   else
     {
      type = OrderType();
      swap = OrderSwap();
      commission=OrderCommission();
      profit=OrderProfit();
      openPrice= OrderOpenPrice();
      openTime = OrderOpenTime();
      closeTime= OrderCloseTime();
      return true;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Order::canTakeProfit(void)
  {
   if(isBuy())
     {
      return !(Bid<takeProfit);
     }
   if(isSell())
     {
      return !(Ask>takeProfit);
     }
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Order::canStopLoss(void)
  {
   if(isBuy())
     {
      return !(Bid>stopLoss);
     }
   if(isSell())
     {
      return !(Ask<stopLoss);
     }
   return false;
  }
//+------------------------------------------------------------------+
