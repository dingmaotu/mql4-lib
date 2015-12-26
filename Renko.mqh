//+------------------------------------------------------------------+
//|                                                        Renko.mqh |
//|                                          Copyright 2015, Li Ding |
//|                                             http://dingmaotu.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, Li Ding"
#property link      "http://dingmaotu.com"
#property strict

#define RENKO_DEFAULT_BUFFER_SIZE 1000
//+------------------------------------------------------------------+
//| Interface for classes who need to operate on Renko charts        |
//| Those who need to operate on renko charts must inherit this class|
//+------------------------------------------------------------------+
class RenkoOperator
  {
   virtual void      onNewBar(int total,int newBars,double const &open[],double const &high[],double const &low[],double const &close[]);
  };
//+------------------------------------------------------------------+
//| Base class used to generate renko charts                         |
//+------------------------------------------------------------------+
class Renko
  {
private:
   int               bars;
   int               arraySize;

   void              resizeBuffer(double &a[],int size);
   void              resizeBuffer(long &a[],int size);
   void              resizeIfNeeded(int size);

   void              makeNewBars(double p,double &base[],double &target[],double step,int newBars,long vol);
   int               newBar(double p,long vol);
   int               move(double p,long vol);

protected:
   double            open[];
   double            high[];
   double            low[];
   double            close[];
   long              volume[];

public:
   double const      BarSize;
                     Renko(double barSize);
   virtual          ~Renko();

   int               getBars() const {return bars;}

   virtual void      onNewBar(int total,int pBars,double const &pOpen[],double const &pHigh[],
                              double const &pLow[],double const &pClose[],long const &pVolume[]);

   //--- Experts, Scripts, Indicators alike call following 2 methods to feed price data

   //--- Feed data by normal candle bars
   int               loadRate(MqlRates &r);
   void              loadRates(MqlRates &r[],int shift,int size);
   //--- Feed data by last price
   void              moveTo(double price,long vol);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Renko::Renko(double barSize)
   :BarSize(barSize)
  {
   bars=1;
   arraySize=0;
   resizeIfNeeded(bars);
   open[0]=-1;
   high[0]=-1;
   low[0]=-1;
   close[0]=-1;
   volume[0]=-1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Renko::~Renko()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Renko::resizeBuffer(double &a[],int size)
  {
   ArrayResize(a,size,RENKO_DEFAULT_BUFFER_SIZE);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Renko::resizeBuffer(long &a[],int size)
  {
   ArrayResize(a,size,RENKO_DEFAULT_BUFFER_SIZE);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Renko::resizeIfNeeded(int size)
  {
   if(arraySize<size)
     {
      while(arraySize<size)
        {
         arraySize+=RENKO_DEFAULT_BUFFER_SIZE;
        }
      resizeBuffer(open,arraySize);
      resizeBuffer(high,arraySize);
      resizeBuffer(low,arraySize);
      resizeBuffer(close,arraySize);
      resizeBuffer(volume,arraySize);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Renko::makeNewBars(double p,double &base[],double &target[],double step,int newBars,long vol)
  {
   long v=vol;
   long volPerBar=vol/newBars;
   close[bars-1]=target[bars-1]=base[bars-1]+step;
   for(int i=bars; i<bars+newBars; i++)
     {
      open[i]=base[i]=close[i-1];
      close[i]=target[i]=base[i]+step;
      volume[i]=volPerBar;
      v-=volPerBar;
     }
   volume[bars-1]+=v;
   bars+=newBars;
   close[bars-1]=target[bars-1]=p;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Renko::newBar(double p,long vol)
  {
   int newBars=(int)((high[bars-1]-low[bars-1])/BarSize);
   resizeIfNeeded(bars+newBars);

   if(p-low[bars-1]>BarSize)
     {
      makeNewBars(p,low,high,BarSize,newBars,vol);
     }
   else if(high[bars-1]-p>BarSize)
     {
      makeNewBars(p,high,low,-BarSize,newBars,vol);
     }
   return newBars;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Renko::move(double p,long vol)
  {
   if(open[bars-1]<0)
     {
      open[bars-1]=p;
      high[bars-1]=p;
      low[bars-1]=p;
      close[bars-1]=p;
      volume[bars-1]=vol;
      return 0;
     }
   if(p > high[bars-1]) high[bars-1] = p;
   if(p < low[bars-1] ) low[bars-1]  = p;
   if(high[bars-1]-low[bars-1]>BarSize)
     {
      return newBar(p, vol);
     }
   else
     {
      close[bars-1]=p;
      volume[bars-1]+=vol;
      return 0;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Renko::loadRate(MqlRates &r)
  {
   int newBars=0;
   long v=r.tick_volume/3;
   newBars+=move(r.open,0);
   if(r.open>r.close)
     {
      newBars += move(r.high,v);
      newBars += move(r.low,v);
     }
   else
     {
      newBars += move(r.low,v);
      newBars += move(r.high,v);
     }
   newBars+=move(r.close,v);
   return newBars;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Renko::loadRates(MqlRates &rs[],int shift,int size)
  {
   int newBars=0;
   if(ArraySize(rs)>=size && size>0)
     {
      for(int i=shift; i<shift+size; i++)
        {
         newBars+=loadRate(rs[i]);
        }
      onNewBar(bars,newBars,open,high,low,close,volume);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Renko::moveTo(double price,long vol=0)
  {
   int newBars=move(price,vol);
   onNewBar(bars,newBars,open,high,low,close,volume);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Renko::onNewBar(int total,int pBars,double const &pOpen[],double const &pHigh[],
                     double const &pLow[],double const &pClose[],long const &pVolume[])
  {
  }
//+------------------------------------------------------------------+
