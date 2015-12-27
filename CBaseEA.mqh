//+------------------------------------------------------------------+
//|                                                      CBaseEA.mqh |
//|                                          Copyright 2014, Li Ding |
//|                                             http://dingmaotu.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, Li Ding"
#property link      "http://dingmaotu.com"
#property strict

#define MAGIC_START 10000
#include <Object.mqh>
#include <LiDing/Collection/IntVector.mqh>

//+------------------------------------------------------------------+
//| Base class of all EAs by Li Ding                                 |
//+------------------------------------------------------------------+
class CBaseEA: public CObject
  {
private:
   static int        GetNextMagic() {static int m=MAGIC_START; return m++; }
protected:
   int               m_bars;
   int               m_magic;

   //--- order management
   int               m_buys;
   int               m_sells;
   int               m_pendbuys;
   int               m_pendsells;

   IntVector         m_orders;

public:
                     CBaseEA(){m_bars=0;m_magic=GetNextMagic();}
                    ~CBaseEA(){}

   int               GetMagic()const {return m_magic;}

   void              Buy(int stopless,int takeprofit);
   void              Sell(int stopless,int takeprofit);
   void              Buy(double stopless,double takeprofit);
   void              Sell(double stopless,double takeprofit);
   void              PendBuy(double price,double lots,int stoploss,int takeprofit=0);
   void              PendSell(double price,double lots,int stoploss,int takeprofit=0);
   void              PendBuy(double price,double lots,double stoploss,double takeprofit);
   void              PendSell(double price,double lots,double stoploss,double takeprofit);

   bool              IsNewBar() {return m_bars!=Bars;}

   bool              GetAllOrders(IntVector &vec);

   void              CloseCurrentOrder();
   void              CloseAllOrders(int);
   void              CloseAllOrders();

   void              UpdateOrders();

   virtual void      UpdateOrdersBuyHook() {}
   virtual void      UpdateOrdersSellHook() {}
   virtual void      UpdateOrdersPendBuyHook() {}
   virtual void      UpdateOrdersPendSellHook() {}
   virtual void      UpdateOrdersNewBarHook() {}

   //--- money management
   virtual double    GetLots() {return 1.0;}

   //--- event handler
   void              Tick(void);
   virtual void      TickHook(void) {}
   virtual void      BeforeTick(void) {}

   //--- indicators
   virtual void      UpdateIndicators(void) {}
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CBaseEA::Tick(void)
  {
   BeforeTick();
   UpdateIndicators();
   UpdateOrders();

// in this method, use IsNewBar()
   TickHook();

   if(m_bars!=Bars)
     {
      m_bars=Bars;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CBaseEA::GetAllOrders(IntVector &vec)
  {
   int total=OrdersTotal();
   for(int i=0;i<total;i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false)
        {
         return false;
        }
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==m_magic)
        {
         vec.push(OrderTicket());
        }
     }
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CBaseEA::UpdateOrders(void)
  {
   m_buys=0;
   m_sells=0;
   m_pendbuys=0;
   m_pendsells=0;

   m_orders.clear();

   GetAllOrders(m_orders);

   int total=m_orders.size();

   for(int i=0;i<total;i++)
     {
      if(OrderSelect(m_orders.get(i),SELECT_BY_TICKET))
        {
         if(IsNewBar())
           {
            UpdateOrdersNewBarHook();
           }
         if(OrderType()==OP_BUY)
           {
            m_buys++;
            UpdateOrdersBuyHook();
           }
         else if(OrderType()==OP_SELL)
           {
            m_sells++;
            UpdateOrdersSellHook();
           }
         else if(OrderType()==OP_BUYLIMIT || OrderType()==OP_BUYSTOP)
           {
            m_pendbuys++;
            UpdateOrdersPendBuyHook();
           }
         else if(OrderType()==OP_SELLLIMIT || OrderType()==OP_SELLSTOP)
           {
            m_pendsells++;
            UpdateOrdersPendBuyHook();
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CBaseEA::PendBuy(double price,double lots,double stoploss,double takeprofit)
  {
   double stopLevel=MarketInfo(Symbol(),MODE_STOPLEVEL);
   double minLot=MarketInfo(Symbol(),MODE_MINLOT);
//double lotStep=MarketInfo(Symbol(),MODE_LOTSTEP);

   double realLots = lots > minLot ? lots : minLot;
   double realPrice= NormalizeDouble(price,Digits);
   double correctPrice=Ask;

   double minPrice = NormalizeDouble(correctPrice - stopLevel*Point, Digits);
   double maxPrice = NormalizeDouble(correctPrice + stopLevel*Point, Digits);

   int cmd;
   if(realPrice<minPrice)
     {
      cmd=OP_BUYLIMIT;
        } else if(realPrice>maxPrice) {
      cmd=OP_BUYSTOP;
        } else {
      cmd=OP_BUY;
      realPrice=correctPrice;
     }

   double r_stoploss=NormalizeDouble(stoploss,Digits);
   double r_takeprofit=NormalizeDouble(takeprofit,Digits);

//   Print("About to place buy order: at price ", Ask, ", stoploss = ", r_stoploss, " with magic ", m_magic);
   int ticket=OrderSend(Symbol(),cmd,realLots,realPrice,3,r_stoploss,r_takeprofit,"",m_magic,0,Blue);
   if(ticket<0)
     {
      Print("Buy OrderSend error ",GetLastError());
      return;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CBaseEA::PendBuy(double price,double lots,int stoploss=0,int takeprofit=0)
  {
   double stopLevel=MarketInfo(Symbol(),MODE_STOPLEVEL);
   double minLot=MarketInfo(Symbol(),MODE_MINLOT);
//double lotStep=MarketInfo(Symbol(),MODE_LOTSTEP);

   double realLots = lots > minLot ? lots : minLot;
   double realPrice= NormalizeDouble(price,Digits);
   double correctPrice=Ask;

   double minPrice = NormalizeDouble(correctPrice - stopLevel*Point, Digits);
   double maxPrice = NormalizeDouble(correctPrice + stopLevel*Point, Digits);

   int cmd;
   if(realPrice<minPrice)
     {
      cmd=OP_BUYLIMIT;
        } else if(realPrice>maxPrice) {
      cmd=OP_BUYSTOP;
        } else {
      cmd=OP_BUY;
      realPrice=correctPrice;
     }

   double r_stoploss=0;
   double r_takeprofit=0;
   if(stoploss>0)
     {
      r_stoploss=NormalizeDouble(realPrice-stoploss*Point,Digits);
     }
   if(takeprofit>0)
     {
      r_takeprofit=NormalizeDouble(realPrice+takeprofit*Point,Digits);
     }

//   Print("About to place buy order: at price ", Ask, ", stoploss = ", r_stoploss, " with magic ", m_magic);
   int ticket=OrderSend(Symbol(),cmd,realLots,realPrice,3,r_stoploss,r_takeprofit,"",m_magic,0,Blue);
   if(ticket<0)
     {
      Print("Buy OrderSend error ",GetLastError());
      return;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CBaseEA::PendSell(double price,double lots,double stoploss,double takeprofit)
  {
   double stopLevel=MarketInfo(Symbol(),MODE_STOPLEVEL);
   double minLot=MarketInfo(Symbol(),MODE_MINLOT);
//double lotStep=MarketInfo(Symbol(),MODE_LOTSTEP);

   double realLots = lots > minLot ? lots : minLot;
   double realPrice= NormalizeDouble(price,Digits);
   double correctPrice=Bid;

   double minPrice = NormalizeDouble(correctPrice - stopLevel*Point, Digits);
   double maxPrice = NormalizeDouble(correctPrice + stopLevel*Point, Digits);

   int cmd;
   if(realPrice<minPrice)
     {
      cmd=OP_SELLSTOP;
        } else if(realPrice>maxPrice) {
      cmd=OP_SELLLIMIT;
        } else {
      cmd=OP_SELL;
      realPrice=correctPrice;
     }

   double r_stoploss=NormalizeDouble(stoploss,Digits);
   double r_takeprofit=NormalizeDouble(takeprofit,Digits);

//   Print("About to place sell order: at price ", Bid, ", stoploss = ", r_stoploss, " with magic ", m_magic);
   int ticket=OrderSend(Symbol(),cmd,realLots,realPrice,3,r_stoploss,r_takeprofit,"",m_magic,0,Red);
   if(ticket<0)
     {
      Print("Sell OrderSend error ",GetLastError());
      return;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CBaseEA::PendSell(double price,double lots,int stoploss=0,int takeprofit=0)
  {
   double stopLevel=MarketInfo(Symbol(),MODE_STOPLEVEL);
   double minLot=MarketInfo(Symbol(),MODE_MINLOT);
//double lotStep=MarketInfo(Symbol(),MODE_LOTSTEP);

   double realLots = lots > minLot ? lots : minLot;
   double realPrice= NormalizeDouble(price,Digits);
   double correctPrice=Bid;

   double minPrice = NormalizeDouble(correctPrice - stopLevel*Point, Digits);
   double maxPrice = NormalizeDouble(correctPrice + stopLevel*Point, Digits);

   int cmd;
   if(realPrice<minPrice)
     {
      cmd=OP_SELLSTOP;
        } else if(realPrice>maxPrice) {
      cmd=OP_SELLLIMIT;
        } else {
      cmd=OP_SELL;
      realPrice=correctPrice;
     }

   double r_stoploss=0;
   double r_takeprofit=0;
   if(stoploss>0)
     {
      r_stoploss=NormalizeDouble(realPrice+stoploss*Point,Digits);
     }
   if(takeprofit>0)
     {
      r_takeprofit=NormalizeDouble(realPrice-takeprofit*Point,Digits);
     }

//   Print("About to place sell order: at price ", Bid, ", stoploss = ", r_stoploss, " with magic ", m_magic);
   int ticket=OrderSend(Symbol(),cmd,realLots,realPrice,3,r_stoploss,r_takeprofit,"",m_magic,0,Red);
   if(ticket<0)
     {
      Print("Sell OrderSend error ",GetLastError());
      return;
     }
  }
//+------------------------------------------------------------------+
//| General Buy: stoploss and takeprotfit specified with points      |
//+------------------------------------------------------------------+
void CBaseEA::Buy(int stoploss=0,int takeprofit=0)
  {
   PendBuy(Ask,GetLots(),stoploss,takeprofit);
  }
//+------------------------------------------------------------------+
//| General Sell: stoploss and takeprotfit specified with points     |
//+------------------------------------------------------------------+
void CBaseEA::Sell(int stoploss=0,int takeprofit=0)
  {
   PendSell(Bid,GetLots(),stoploss,takeprofit);
  }
//+------------------------------------------------------------------+
//| General Buy: stoploss and takeprotfit specified with points      |
//+------------------------------------------------------------------+
void CBaseEA::Buy(double stoploss,double takeprofit)
  {
   PendBuy(Ask,GetLots(),stoploss,takeprofit);
  }
//+------------------------------------------------------------------+
//| General Sell: stoploss and takeprotfit specified with points     |
//+------------------------------------------------------------------+
void CBaseEA::Sell(double stoploss,double takeprofit)
  {
   PendSell(Bid,GetLots(),stoploss,takeprofit);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CBaseEA::CloseAllOrders(int type)
  {
   IntVector v;
   if(!GetAllOrders(v))
     {
      Print("Getting orders failed");
      return;
     }

   int total=v.size();
   for(int i=0;i<total;i++)
     {
      if(OrderSelect(v.get(i),SELECT_BY_TICKET) && OrderType()==type)
        {
         CloseCurrentOrder();
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CBaseEA::CloseAllOrders()
  {
   IntVector v;
   if(!GetAllOrders(v))
     {
      Print("Getting orders failed");
      return;
     }

   int total=v.size();
   for(int i=0;i<total;i++)
     {
      if(OrderSelect(v.get(i),SELECT_BY_TICKET))
        {
         CloseCurrentOrder();
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CBaseEA::CloseCurrentOrder(void)
  {
   double p;
   if(OrderType()==OP_SELL) p=Ask;
   else if(OrderType()==OP_BUY) p=Bid;
   else p=-1;
   if(p>0)
     {
      if(!OrderClose(OrderTicket(),OrderLots(),p,3,White))
        {
         Print("OrderClose error ",GetLastError()," with #",OrderTicket(),"of type ",OrderType());
        }
     }
   else
     {
      if(!OrderDelete(OrderTicket(),White))
        {
         Print("OrderDelete error ",GetLastError()," with #",OrderTicket(),"of type ",OrderType());
        }
     }
  }
//+------------------------------------------------------------------+
