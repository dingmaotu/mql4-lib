//+------------------------------------------------------------------+
//| Module: History/PriceBreak.mqh                                   |
//| This file is part of the mql4-lib project:                       |
//|     https://github.com/dingmaotu/mql4-lib                        |
//|                                                                  |
//| Copyright 2015-2016 Li Ding <dingmaotu@126.com>                  |
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

#include "../Lang/Mql.mqh"
#include "../Utils/Math.mqh"

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
//| Base class used to generate PriceBreak charts                    |
//+------------------------------------------------------------------+
class PriceBreak
  {
private:
   int               m_bars;

   double            m_reversalHigh;
   double            m_reversalLow;
   long              m_accumulatedVolume;

   void              grow(int size);
   double            calcReversalHigh();
   double            calcReversalLow();

protected:
   double            m_open[];
   double            m_high[];
   double            m_low[];
   double            m_close[];
   long              m_volume[];
   int               move(double p,long vol);

public:
   const int         DISTANCE;

                     PriceBreak(int);
   virtual          ~PriceBreak(){}

   int               getBars() const {return m_bars;}

   //--- Feed data by normal candle bars
   int               loadRate(const MqlRates &r);
   //--- Feed data by last price
   int               moveTo(double price,long volume);

   virtual void      onNewBar(int bars,int new_bars,double const &open[],double const &high[],
                              double const &low[],double const &close[],long const &volume[])
     {}
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
PriceBreak::PriceBreak(int distance=3):DISTANCE(distance)
  {
   m_bars=0;
   m_reversalHigh=m_reversalLow=0;
   m_accumulatedVolume=0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double PriceBreak::calcReversalHigh(void)
  {
   double p=m_high[m_bars-1];
   for(int i=m_bars-DISTANCE; i>=0 && i<m_bars-1; i++)
     {
      if(m_high[i]>p) p=m_high[i];
     }
   return p;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double PriceBreak::calcReversalLow(void)
  {
   double p=m_low[m_bars-1];
   for(int i=m_bars-DISTANCE; i>=0 && i<m_bars-1; i++)
     {
      if(m_low[i]<p) p=m_low[i];
     }
   return p;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PriceBreak::grow(int size)
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
int PriceBreak::move(double price,long volume)
  {
   if(m_bars==0)
     {
      grow(1);

      m_open[m_bars-1]=price;
      m_high[m_bars-1]=price;
      m_low[m_bars-1]=price;
      m_close[m_bars-1]=price;
      m_volume[m_bars-1]=volume;

      m_reversalHigh=calcReversalHigh();
      m_reversalLow=calcReversalLow();
      return 1;
     }

   m_accumulatedVolume+=volume;

   if(price>m_reversalHigh)
     {
      grow(1);
      m_close[m_bars-1]=m_high[m_bars-1]=price;
      m_open[m_bars-1]=m_low[m_bars-1]=m_high[m_bars-2];
      m_volume[m_bars-1]=m_accumulatedVolume;
      m_reversalHigh=calcReversalHigh();
      m_reversalLow=calcReversalLow();
      m_accumulatedVolume=0;
      return 1;
     }
   if(price<m_reversalLow)
     {
      grow(1);
      m_close[m_bars-1]=m_low[m_bars-1]=price;
      m_open[m_bars-1]=m_high[m_bars-1]=m_low[m_bars-2];
      m_volume[m_bars-1]=m_accumulatedVolume;
      m_reversalHigh=calcReversalHigh();
      m_reversalLow=calcReversalLow();
      m_accumulatedVolume=0;
      return 1;
     }

   return 0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int PriceBreak::loadRate(const MqlRates &r)
  {
   return moveTo(r.close,r.tick_volume);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int PriceBreak::moveTo(double price,long volume=0)
  {
   int newBars=move(price,volume);
   onNewBar(m_bars,newBars,m_open,m_high,m_low,m_close,m_volume);
   return newBars;
  }
//+------------------------------------------------------------------+
//| Provides standard 3 line break signal                            |
//+------------------------------------------------------------------+
class PriceBreakSignal: public PriceBreak
  {
   ObjectAttrRead(int,lastBarDir,LastBarDir);
   ObjectAttrRead(int,newBarDir,NewBarDir);
public:
                     PriceBreakSignal():PriceBreak(3),m_newBarDir(0),m_lastBarDir(0){}
   void              onNewBar(int bars,int newBars,double const &open[],double const &high[],
                              double const &low[],double const &close[],long const &volume[]) override
     {
      if(newBars>0)
        {
         m_newBarDir=Math::sign(close[bars-1]-open[bars-1]);
         m_lastBarDir=m_newBarDir;
        }
      else
        {
         m_newBarDir=0;
        }
     }
  };
//+------------------------------------------------------------------+
