//+------------------------------------------------------------------+
//|                                                      Fractal.mqh |
//|                                          Copyright 2015, Li Ding |
//|                                                dingmaotu@126.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, Li Ding"
#property link      "dingmaotu@126.com"
#property strict

#include <LiDing/Collection/IntVector.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int leftHigh(const double &price[],int shift)
  {
// left fractal
   int n=0;
   double v=price[shift];
   for(int i=shift-1; i>=0; i--)
     {
      if(price[i]<v) n++;
      else break;
     }
   return n;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int leftLow(const double &price[],int shift)
  {
// left fractal
   int n=0;
   double v=price[shift];
   for(int i=shift-1; i>=0; i--)
     {
      if(price[i]>v) n++;
      else break;
     }
   return n;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int rightHigh(const double &price[],int shift)
  {
   int size=ArraySize(price);
   int n=0;
   double v=price[shift];
// right fractal
   for(int i=shift+1; i<size; i++)
     {
      if(price[i]<v) n++;
      else break;
     }
   return n;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int rightLow(const double &price[],int shift)
  {
   int size=ArraySize(price);
   int n=0;
   double v=price[shift];
// right fractal
   for(int i=shift+1; i<size; i++)
     {
      if(price[i]>v) n++;
      else break;
     }
   return n;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool inRange(int i,int begin,int end)
  {
   return i >=begin && i < end;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool checkHighFractal(const MqlRates &rates[],int shift,int order)
  {
   int size=ArraySize(rates);
   for(int i=1; i<=order;i++)
     {
      if(inRange(shift+i,0,size) && inRange(shift-i,0,size) && !(rates[shift+i].high<rates[shift].high && rates[shift-i].high<rates[shift].high))
         return false;
     }
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool checkLowFractal(const MqlRates &rates[],int shift,int order)
  {
   int size = ArraySize(rates);
   for(int i=1; i<=order;i++)
     {
      if(inRange(shift+i,0,size) && inRange(shift-i,0,size) && !(rates[shift+i].low>rates[shift].low && rates[shift-i].low>rates[shift].low))
         return false;
     }
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void fractal(const MqlRates &rates[],int order,IntVector &high,IntVector &low)
  {
   high.clear();
   low.clear();
   int numRates=ArraySize(rates);

   if(order<1 || numRates<(2*order+1))
     {
      return;
     }

   for(int i=1; i<numRates-order; i++)
     {
      if(checkHighFractal(rates,i,order))
        {
         high.push(i);
        }
      if(checkLowFractal(rates,i,order))
        {
         low.push(i);
        }
     }
  }
//+------------------------------------------------------------------+
