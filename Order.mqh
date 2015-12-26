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
   int const         magic;
   string const      symbol;

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
                     Order(int magic,string symbol);
                    ~Order();

   bool              pendBuy(double price,double lots,int stopLoss,int takeProfit);
   bool              pendSell(double price,double lots,int stopLoss,int takeProfit);

   bool              buy(double lots,int stopLoss,int takeProfit);
   bool              sell(double lots,int stopLoss,int takeProfit);

   bool              select();

   int               getTicket() const {return ticket;}
   int               getMagic() const {return magic;}

   double            getInitialStopLoss() const {return initialStopLoss;}
   double            getInitialTakeProfit() const {return initialTakeProfit;}
   double            getStopLoss() const {return stopLoss;}
   double            getTakeProfit() const {return takeProfit;}

   int               getType() const {return type;}
   string            getTypeAsString();

   bool              isBuy() const {return type==OP_BUY;}
   bool              isSell() const {return type==OP_SELL;}

   double            getLots() const {return lots;}

   double            getProfit() const {return profit;}
   double            getSwap() const {return swap;}
   double            getCommission() const {return commission;}

   void              setStopLoss(double price) {stopLoss=price;}
   void              setTakeProfit(double price) {takeProfit=price;}

   bool              doTakeProfit();
   bool              doStopLoss();

   bool              close(bool show);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Order::Order(int pMagic=0,string pSymbol="") :magic(pMagic),symbol(pSymbol==""?Symbol():pSymbol)
  {
   ticket=-1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Order::~Order()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Order::pendBuy(double pPrice,double pLots,int pStopLoss=0,int pTakeProfit=0)
  {
   double stopLevel=MarketInfo(symbol,MODE_STOPLEVEL);
   double minLot=MarketInfo(symbol,MODE_MINLOT);
//double lotStep=MarketInfo(Symbol(),MODE_LOTSTEP);

   lots=pLots>minLot ? pLots : minLot;

   double realPrice=NormalizeDouble(pPrice,Digits);
   double correctPrice=Ask;

   double minPrice = NormalizeDouble(correctPrice - stopLevel*Point, Digits);
   double maxPrice = NormalizeDouble(correctPrice + stopLevel*Point, Digits);

   if(realPrice<minPrice)
     {
      type=OP_BUYLIMIT;
        } else if(realPrice>maxPrice) {
      type=OP_BUYSTOP;
        } else {
      type=OP_BUY;
      realPrice=correctPrice;
     }

   if(pStopLoss>0)
     {
      stopLoss=NormalizeDouble(realPrice-pStopLoss*Point,Digits);
      initialStopLoss=stopLoss;
     }
   if(pTakeProfit>0)
     {
      takeProfit=NormalizeDouble(realPrice+pTakeProfit*Point,Digits);
      initialTakeProfit=takeProfit;
     }

   ticket=OrderSend(Symbol(),type,lots,realPrice,3,stopLoss,takeProfit,"",magic,0,Blue);
   if(ticket<0)
     {
      Print("Send buy order error: ",GetLastError());
      return false;
     }
   else
     {
      return true;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Order::pendSell(double pPrice,double pLots,int pStopLoss=0,int pTakeProfit=0)
  {
   double minLot=MarketInfo(Symbol(),MODE_MINLOT);
//double lotStep=MarketInfo(Symbol(),MODE_LOTSTEP);
   lots=pLots>minLot ? pLots : minLot;

   double correctPrice=Bid;
   double stopLevel=MarketInfo(Symbol(),MODE_STOPLEVEL);
   double minPrice = NormalizeDouble(correctPrice - stopLevel*Point, Digits);
   double maxPrice = NormalizeDouble(correctPrice + stopLevel*Point, Digits);

   double realPrice=NormalizeDouble(pPrice,Digits);

   if(realPrice<minPrice)
     {
      type=OP_SELLSTOP;
        } else if(realPrice>maxPrice) {
      type=OP_SELLLIMIT;
        } else {
      type=OP_SELL;
      realPrice=correctPrice;
     }

   if(pStopLoss>0)
     {
      stopLoss=NormalizeDouble(realPrice+pStopLoss*Point,Digits);
      initialStopLoss=stopLoss;
     }
   if(pTakeProfit>0)
     {
      takeProfit=NormalizeDouble(realPrice-pTakeProfit*Point,Digits);
      initialTakeProfit=takeProfit;
     }

   ticket=OrderSend(Symbol(),type,lots,realPrice,3,stopLoss,takeProfit,"",magic,0,Red);
   if(ticket<0)
     {
      Print("Send sell order error: ",GetLastError());
      return false;
     }
   else
     {
      return true;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Order::buy(double pLots,int pStopLoss=0,int pTakeProfit=0)
  {
   return pendBuy(Ask,pLots,pStopLoss,pTakeProfit);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Order::sell(double pLots,int pStopLoss=0,int pTakeProfit=0)
  {
   return pendSell(Bid,pLots,pStopLoss,pTakeProfit);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Order::select(void)
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
string Order::getTypeAsString()
  {
   if(type == OP_SELL) return "SELL";
   if(type == OP_BUY) return "BUY";
   if(type == OP_BUYLIMIT) return "BUY LIMIT";
   if(type == OP_BUYSTOP) return "BUY STOP";
   if(type == OP_SELLLIMIT) return "SELL LIMIT";
   if(type == OP_SELLSTOP) return "SELL STOP";
   return "";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Order::doTakeProfit(void)
  {
   if(isBuy())
     {
      if(!(Bid<takeProfit))
        {
         return close();
        }
     }
   if(isSell())
     {
      if(!(Ask>takeProfit))
        {
         return close();
        }
     }
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Order::doStopLoss(void)
  {
   if(isBuy())
     {
      if(!(Bid>stopLoss))
        {
         return close();
        }
     }
   if(isSell())
     {
      if(!(Ask<stopLoss))
        {
         return close();
        }
     }
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Order::close(bool show=true)
  {
   if(ticket < 0) return false;
   double p;
   if(isBuy()) p=Ask;
   else if(isSell()) p=Bid;
   else p=-1;

   color chartColor=show ? White : CLR_NONE;

   if(p>0)
     {
      if(!OrderClose(ticket,lots,p,3,chartColor))
        {
         Print("OrderClose error ",GetLastError()," with #",ticket," of type ",getTypeAsString());
         return false;
        }
     }
   else
     {
      if(!OrderDelete(ticket,chartColor))
        {
         Print("OrderDelete error ",GetLastError()," with #",ticket," of type ",getTypeAsString());
         return false;
        }
     }
   return true;
  }
//+------------------------------------------------------------------+
