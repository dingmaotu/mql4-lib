//+------------------------------------------------------------------+
//|                                                    RenkoMa10.mqh |
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
class RenkoMa10: public Renko
  {
private:
   int               periodMa;
   int               bars;
   double            ma[];
   int               maNum;

   int               direction;
public:
                     RenkoMa10(int period,int barSize);
                    ~RenkoMa10() {}
   void              onNewBar(int total,int pBars,double const &pOpen[],double const &pHigh[],
                              double const &pLow[],double const &pClose[],long const &pVolumne[]);

   double            getMaValue(int shift);

   bool              isLong() {return direction==1;}
   bool              isShort() {return direction==-1;}
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
RenkoMa10::RenkoMa10(int period,int barSize)
   :Renko(barSize*Point)
  {
   periodMa=period;
   bars=1;
   direction=0;
   maNum=0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void RenkoMa10::onNewBar(int total,int pBars,const double &pOpen[],const double &pHigh[],
                         const double &pLow[],const double &pClose[],const long &pVolume[])
  {
   direction=0;
   if(bars==1 || bars!=total)
     {
      bars=total;
      ArrayResize(ma,total,1000);
     }

   if(pBars>0)
     {
      Print("new bars is ",pBars);
      Print("total is ",total);

      maNum=SimpleMAOnBuffer(total,maNum,0,periodMa,pLow,ma);

      bool hasCross=false;
      
      int barStart = total-pBars-1;
      
      if(barStart < 1) {
         barStart = 1;
      }
      
      for(int i=total-2;i>=barStart;i--)
        {
         if(ma[i]>pHigh[i] && ma[i-1]<pHigh[i-1])
           {
            direction=-1;
            hasCross = true;
            break;
           }
         if(ma[i]<pLow[i] && ma[i-1]>pLow[i-1])
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
      maNum=SimpleMAOnBuffer(bars,maNum,0,periodMa,pLow,ma);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double RenkoMa10::getMaValue(int shift)
  {
   if(bars>periodMa && shift<bars)
     {
      return ma[bars-shift-1];
     }
   return -1;
  }
//+------------------------------------------------------------------+
