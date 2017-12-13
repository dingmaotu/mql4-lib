//+------------------------------------------------------------------+
//| Module: History/Renko.mqh                                        |
//| This file is part of the mql4-lib project:                       |
//|     https://github.com/dingmaotu/mql4-lib                        |
//|                                                                  |
//| Copyright 2015-2017 Li Ding <dingmaotu@126.com>                  |
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

#include "HistoryData.mqh"
#include "../Trade/FxSymbol.mqh"

#define RENKO_DEFAULT_BUFFER_SIZE 1000
//+------------------------------------------------------------------+
//| Base class used to generate renko charts                         |
//+------------------------------------------------------------------+
class Renko: public HistoryData
  {
private:
   string            m_symbol;
   int               m_bars;
   int               m_newBars;
   bool              m_std;

   double            m_open[];
   double            m_high[];
   double            m_low[];
   double            m_close[];
   long              m_volume[];

   //--- dummy arrays for OnUpdate event
   datetime          m_time[];
   long              m_realVolume[];
   int               m_spread[];

   void              resize(int size);

   void              makeNewBars(double p,double &base[],double &target[],double step,int newBars,long vol);
   int               newBar(double p,long vol);
protected:
   int               move(double p,long vol);
   int               moveByRate(MqlRates &r);
public:
   double const      BAR_SIZE;
                     Renko(string symbol,int barSize,bool std=false);

   string            getSymbol() const {return m_symbol;}

   int               getBars() const {return m_bars;}
   bool              isNewBar() const {return m_newBars>0;}
   int               getNewBars() const {return m_newBars;}

   double            getHigh(int shift) const {return m_high[m_bars-1-shift];}
   double            getLow(int shift) const {return m_low[m_bars-1-shift];}
   double            getOpen(int shift) const {return m_open[m_bars-1-shift];}
   double            getClose(int shift) const {return m_close[m_bars-1-shift];}
   long              getVolume(int shift) const {return m_volume[m_bars-1-shift];}

   virtual void      onNewBar(int total,int bars,double const &open[],double const &high[],
                              double const &low[],double const &close[],long const &volume[]);

   //--- Feed data by normal candle bars
   void              updateByRates(MqlRates &r[],int shift,int size);

   //--- update with latest price and vol
   void              update(double price,long vol);
  };
//+------------------------------------------------------------------+
//| Initialize Renko                                                 |
//| Renko Bar size is given in number of ticks (points)              |
//+------------------------------------------------------------------+
Renko::Renko(string symbol,int barSize,bool std)
   :m_symbol(symbol==""?_Symbol:symbol),
     BAR_SIZE(FxSymbol::getPoint(m_symbol)*barSize),
     m_bars(0),
     m_std(std)
  {
  }
//+------------------------------------------------------------------+
//| Resize all buffers                                               |
//+------------------------------------------------------------------+
void Renko::resize(int size)
  {
   ArrayResize(m_open,size,RENKO_DEFAULT_BUFFER_SIZE);
   ArrayResize(m_high,size,RENKO_DEFAULT_BUFFER_SIZE);
   ArrayResize(m_low,size,RENKO_DEFAULT_BUFFER_SIZE);
   ArrayResize(m_close,size,RENKO_DEFAULT_BUFFER_SIZE);
   ArrayResize(m_volume,size,RENKO_DEFAULT_BUFFER_SIZE);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Renko::makeNewBars(double p,double &base[],double &target[],double step,int newBars,long vol)
  {
   long v=vol;
   long volPerBar=vol/newBars;
   m_close[m_bars-1]=target[m_bars-1]=base[m_bars-1]+step;
   for(int i=m_bars; i<m_bars+newBars; i++)
     {
      m_open[i]=base[i]=m_close[i-1];
      m_close[i]=target[i]=base[i]+step;
      m_volume[i]=volPerBar;
      v-=volPerBar;
     }
   m_volume[m_bars-1]+=v;
   m_bars+=newBars;
   m_close[m_bars-1]=target[m_bars-1]=p;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Renko::newBar(double p,long vol)
  {
   int newBars=(int)((m_high[m_bars-1]-m_low[m_bars-1])/BAR_SIZE);
   resize(m_bars+newBars);

   if(p-m_low[m_bars-1]>BAR_SIZE)
     {
      makeNewBars(p,m_low,m_high,BAR_SIZE,newBars,vol);
     }
   else if(m_high[m_bars-1]-p>BAR_SIZE)
     {
      makeNewBars(p,m_high,m_low,-BAR_SIZE,newBars,vol);
     }
   return newBars;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Renko::move(double p,long vol)
  {
   if(m_bars==0)
     {
      m_bars=1;
      resize(m_bars);
      m_open[0]=m_high[0]=m_low[0]=m_close[0]=p;
      m_volume[0]=vol;
      return 0;
     }

   if(m_std)
     {
      if(p>m_open[m_bars-1])
        {
         m_high[m_bars-1]= p;
         m_low[m_bars-1] = m_open[m_bars-1];
        }

      if(p<m_open[m_bars-1])
        {
         m_low[m_bars-1]=p;
         m_high[m_bars-1]=m_open[m_bars-1];
        }
     }
   else
     {
      if(p>m_high[m_bars-1]) m_high[m_bars-1]=p;
      if(p<m_low[m_bars-1]) m_low[m_bars-1]=p;
     }

   if(m_high[m_bars-1]-m_low[m_bars-1]>BAR_SIZE)
     {
      return newBar(p, vol);
     }
   else
     {
      m_close[m_bars-1]=p;
      m_volume[m_bars-1]+=vol;
      return 0;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Renko::moveByRate(MqlRates &r)
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
void Renko::updateByRates(MqlRates &rs[],int shift,int size)
  {
   m_newBars=0;
   if(ArraySize(rs)>=size && size>0)
     {
      for(int i=shift; i<shift+size; i++)
        {
         m_newBars+=moveByRate(rs[i]);
        }
      OnUpdate.calculate(m_bars,m_time,m_open,m_high,m_low,m_close,m_volume,m_realVolume,m_spread);
      onNewBar(m_bars,m_newBars,m_open,m_high,m_low,m_close,m_volume);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Renko::update(double price,long vol=0)
  {
   m_newBars=move(price,vol);
   OnUpdate.calculate(m_bars,m_time,m_open,m_high,m_low,m_close,m_volume,m_realVolume,m_spread);
   onNewBar(m_bars,m_newBars,m_open,m_high,m_low,m_close,m_volume);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Renko::onNewBar(int total,int bars,double const &open[],double const &high[],
                     double const &low[],double const &close[],long const &volume[])
  {
  }
//+------------------------------------------------------------------+
