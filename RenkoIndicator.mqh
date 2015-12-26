//+------------------------------------------------------------------+
//|                                               RenkoIndicator.mqh |
//|                                          Copyright 2015, Li Ding |
//|                                                dingmaotu@126.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, Li Ding"
#property link      "dingmaotu@126.com"
#property strict

#include <LiDing/Renko.mqh>
#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class RenkoIndicator: public Renko
  {
private:
   int               periodShort;
   int               periodLong;
   int               bars;
   double            maShort[];
   double            maLong[];
   double            median[];
   int               longMANum;
   int               shortMANum;

   int               direction;
public:
                     RenkoIndicator(int pShort,int pLong,int barSize);
                    ~RenkoIndicator() {}
   void              onNewBar(int total,int pBars,double const &pOpen[],double const &pHigh[],
                              double const &pLow[],double const &pClose[],long const &pVolumne[]);

   double            getShortMA(int shift);
   double            getLongMA(int shift);

   bool              isLong() {return direction==1;}
   bool              isShort() {return direction==-1;}
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
RenkoIndicator::RenkoIndicator(int pShort,int pLong,int barSize)
   :Renko(barSize*Point)
  {
   periodShort= pShort;
   periodLong = pLong;
   bars=1;
   direction=0;
   longMANum=0;
   shortMANum=0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void RenkoIndicator::onNewBar(int total,int pBars,const double &pOpen[],const double &pHigh[],
                              const double &pLow[],const double &pClose[],const long &pVolume[])
  {
   direction=0;
   if(bars==1 || bars!=total)
     {
      bars=total;

      ArrayResize(median,total,1000);
      ArrayResize(maShort,total,1000);
      ArrayResize(maLong,total,1000);
     }

   if(pBars>0)
     {
      for(int i=total-pBars-1;i<total;i++)
        {
         median[i]=(pOpen[i]+pLow[i])/2.0;
        }
      longMANum=SimpleMAOnBuffer(total,longMANum,0,periodLong,pClose,maLong);

      shortMANum=SmoothedMAOnBuffer(total,shortMANum,0,periodShort,median,maShort);

      bool hasCross=false;
      for(int i=total-2;i>=total-pBars-1;i--)
        {
         if(maLong[i]>maShort[i] && maLong[i-1]<maShort[i-1])
           {
            direction=-1;
            hasCross = true;
            break;
           }
         if(maLong[i]<maShort[i] && maLong[i-1]>maShort[i-1])
           {
            direction=1;
            hasCross = true;
            break;
           }
        }
      if(!hasCross)
        {
         direction=0;
        }
     }
   else
     {
      median[bars-1]=(pOpen[total-1]+pLow[total-1])/2.0;
      longMANum=SimpleMAOnBuffer(bars,longMANum,0,periodLong,pClose,maLong);
      shortMANum=SmoothedMAOnBuffer(bars,shortMANum,0,periodShort,median,maShort);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double RenkoIndicator::getShortMA(int shift)
  {
   if(bars>periodLong && shift<bars)
     {
      return maShort[bars-shift-1];
     }
   return -1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double RenkoIndicator::getLongMA(int shift)
  {
   if(bars>periodLong && shift<bars)
     {
      return maLong[bars-shift-1];
     }
   return -1;
  }
//+------------------------------------------------------------------+
