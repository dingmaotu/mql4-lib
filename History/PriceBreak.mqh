//+------------------------------------------------------------------+
//|                                            Charts/PriceBreak.mqh |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015-2016, Li Ding"
#property link      "dingmaotu@hotmail.com"
#property strict

#define DEFAULT_BUFFER_SIZE 1000
//+------------------------------------------------------------------+
//| General buffer resizing                                          |
//+------------------------------------------------------------------+
template<typename T>
void GrowBuffer(T &a[],int size)
  {
   bool isSeries=ArrayGetAsSeries(a);
   if(ArraySize(a)<size)
     {
      ArraySetAsSeries(a,false);
      ArrayResize(a,size,DEFAULT_BUFFER_SIZE);
      ArraySetAsSeries(a,isSeries);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetPrice(ENUM_APPLIED_PRICE applied,double open,double high,double low,double close)
  {
   switch(applied)
     {
      case PRICE_CLOSE:
         return close;
      case PRICE_HIGH:
         return high;
      case PRICE_LOW:
         return low;
      case PRICE_MEDIAN:
         return (high+low)/2;
      case PRICE_OPEN:
         return open;
      case PRICE_TYPICAL:
         return (high+low+close)/3;
      case PRICE_WEIGHTED:
         return (high+low+close+open)/4;
      default:
         return 0;
     }
  }
//+------------------------------------------------------------------+
//| Base class used to generate PriceBreak charts                    |
//+------------------------------------------------------------------+
class PriceBreak
  {
private:
   int               m_bars;
   int               m_trend;

   double            m_reversal_high;
   double            m_reversal_low;

   void              Grow(int size);
   double            GetHigh();
   double            GetLow();

protected:
   double            m_open[];
   double            m_high[];
   double            m_low[];
   double            m_close[];
   long              m_volume[];
   int               Move(double p,long vol);

public:
   const int         DISTANCE;

                     PriceBreak(int);
   virtual          ~PriceBreak(){}

   int               GetBars() const {return m_bars;}

   //--- Feed data by normal candle bars
   void              LoadRate(MqlRates &r,ENUM_APPLIED_PRICE applied);
   //--- Feed data by last price
   void              MoveTo(double price,long volume);

   virtual void      OnNewBar(int bars,int new_bars,double const &open[],double const &high[],
                              double const &low[],double const &close[],long const &volume[])
     {}
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
PriceBreak::PriceBreak(int distance=3):DISTANCE(distance)
  {
   m_bars=0;
   m_reversal_high=m_reversal_low=0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double PriceBreak::GetHigh(void)
  {
   double p = m_high[m_bars-1];
   for(int i=m_bars-DISTANCE; i>=0&&i<m_bars-1; i++)
     {
      if(m_high[i]>p)
        {
         p=m_high[i];
        }
     }
   return p;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double PriceBreak::GetLow(void)
  {
   double p = m_low[m_bars-1];
   for(int i=m_bars-DISTANCE; i>=0&&i<m_bars-1; i++)
     {
      if(m_low[i]<p)
        {
         p=m_low[i];
        }
     }
   return p;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PriceBreak::Grow(int size)
  {
   m_bars+=size;
   GrowBuffer(m_open,m_bars);
   GrowBuffer(m_high,m_bars);
   GrowBuffer(m_low,m_bars);
   GrowBuffer(m_close,m_bars);
   GrowBuffer(m_volume,m_bars);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int PriceBreak::Move(double price,long volume)
  {
   if(m_bars==0)
     {
      Grow(1);
      m_open[m_bars-1]=m_high[m_bars-1]=
                       m_low[m_bars-1]=m_close[m_bars-1]=price;
      m_volume[m_bars-1]=volume;
      m_reversal_high=GetHigh();
      m_reversal_low=GetLow();
      return 1;
     }

   if(price>m_reversal_high)
     {
      Grow(1);
      m_close[m_bars-1]=m_high[m_bars-1]=price;
      m_open[m_bars-1]=m_low[m_bars-1]=m_high[m_bars-2];
      m_volume[m_bars-1]=volume;
      m_reversal_high=GetHigh();
      m_reversal_low=GetLow();
      return 1;
     }
   if(price<m_reversal_low)
     {
      Grow(1);
      m_close[m_bars-1]=m_low[m_bars-1]=price;
      m_open[m_bars-1]=m_high[m_bars-1]=m_low[m_bars-2];
      m_volume[m_bars-1]=volume;
      m_reversal_high=GetHigh();
      m_reversal_low=GetLow();
      return 1;
     }
   m_volume[m_bars-1]+=volume;
   return 0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PriceBreak::LoadRate(MqlRates &r,ENUM_APPLIED_PRICE applied=PRICE_CLOSE)
  {
   MoveTo(GetPrice(applied,r.open,r.high,r.low,r.close),r.tick_volume);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PriceBreak::MoveTo(double price,long volume=0)
  {
   int new_bars=Move(price,volume);
   OnNewBar(m_bars,new_bars,m_open,m_high,m_low,m_close,m_volume);
  }
//+------------------------------------------------------------------+
