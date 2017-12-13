//+------------------------------------------------------------------+
//| Module: History/TimeFrame.mqh                                    |
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
#include "../Lang/Number.mqh"
#include "HistoryData.mqh"
#include "TimeSeriesData.mqh"
//+------------------------------------------------------------------+
//| Time Frame display contants                                      |
//+------------------------------------------------------------------+
const int PERIOD_MINUTES[5]={1,60,24*60,7*24*60,30*7*24*60};
const string PERIOD_NAMES[5]={"M","H","D","W","MN"};
//+------------------------------------------------------------------+
//| Convert period in minutes to a more human readable format        |
//+------------------------------------------------------------------+
string GetPeriodDisplayName(int period)
  {
   if(period<1) return NULL;
   int i=ArraySize(PERIOD_MINUTES)-1;
   for(; i>=0 && period<PERIOD_MINUTES[i]; i--);
   return StringFormat("%s%d",PERIOD_NAMES[i],period/PERIOD_MINUTES[i]);
  }
//+------------------------------------------------------------------+
//| Non standard time frame history data                             |
//+------------------------------------------------------------------+
class TimeFrame: public HistoryData
  {
private:
   const string      m_symbol;
   const int         m_period;
   const int         m_periodSeconds;
   const string      m_displayName;

   datetime          m_lastBaseBarTime;
   long              m_lastTickVolume;
   long              m_lastRealVolume;

   int               m_bars;  // current bars in chart
   int               m_newBars;

   datetime          m_time[];
   double            m_open[];
   double            m_high[];
   double            m_low[];
   double            m_close[];
   long              m_tickVolume[];
   long              m_realVolume[];
   int               m_spread[];

protected:
   //--- increase internal buffer by n (default 1)
   void              increase(int n=1)
     {
      int i=m_bars;
      m_bars+=n;
      ArrayResize(m_time,m_bars,100);
      ArrayResize(m_open,m_bars,100);
      ArrayResize(m_high,m_bars,100);
      ArrayResize(m_low,m_bars,100);
      ArrayResize(m_close,m_bars,100);
      ArrayResize(m_tickVolume,m_bars,100);
      ArrayResize(m_realVolume,m_bars,100);
      ArrayResize(m_spread,m_bars,100);

      // We need low to be the largest number
      for(; i<m_bars; i++)
        {
         m_low[i]=Double::PositiveInfinity;
        }
     }

   int               updateOne(const MqlRates &rate);

public:
                     TimeFrame(string symbol,int period);

   string            getTimeFrameName() const {return m_displayName;}
   int               getPeriodSeconds() const {return m_periodSeconds;}

   int               update(const MqlRates &rate)
     {
      m_newBars=updateOne(rate);
      OnUpdate.calculate(m_bars,m_time,m_open,m_high,m_low,m_close,m_tickVolume,m_realVolume,m_spread);
      onNewBar(m_bars,m_newBars,m_time,m_open,m_high,m_low,m_close,m_tickVolume,m_realVolume,m_spread);
      return m_newBars;
     }

   int               updateByRates(const MqlRates &rates[])
     {
      int len=ArraySize(rates);
      for(int i=0; i<len; i++)
        {
         m_newBars+=updateOne(rates[i]);
        }
      OnUpdate.calculate(m_bars,m_time,m_open,m_high,m_low,m_close,m_tickVolume,m_realVolume,m_spread);
      onNewBar(m_bars,m_newBars,m_time,m_open,m_high,m_low,m_close,m_tickVolume,m_realVolume,m_spread);
      return m_newBars;
     }

   //--- event handler
   virtual void      onNewBar(int total,int newBars,const datetime &time[],
                              double const &open[],double const &high[],
                              double const &low[],double const &close[],
                              long const &tickVolume[],const long &realVolume[],
                              const int &spread[])
     {}

   //--- HistoryData interface
   string            getSymbol() const {return m_symbol;}

   int               getBars() const {return m_bars;}
   bool              isNewBar() const {return m_newBars>0;}
   int               getNewBars() const {return m_newBars;}

   double            getHigh(int shift) const {return m_high[m_bars-shift-1];}
   double            getLow(int shift) const {return m_low[m_bars-shift-1];}
   double            getOpen(int shift) const {return m_open[m_bars-shift-1];}
   double            getClose(int shift) const {return m_close[m_bars-shift-1];}
   long              getVolume(int shift) const {return m_tickVolume[m_bars-shift-1];}

   //--- additional methods
   int               getSpread(int shift) const {return m_spread[m_bars-shift-1];}
  };
//+------------------------------------------------------------------+
//| Initialize internal state and constants                          |
//+------------------------------------------------------------------+
TimeFrame::TimeFrame(string symbol,int period)
   :m_symbol(symbol),m_period(period),m_periodSeconds(period*60),m_displayName(GetPeriodDisplayName(period))
  {
   m_lastBaseBarTime=0;
   m_lastTickVolume=0;
   m_lastRealVolume=0;
   m_bars=0;
  }
//+------------------------------------------------------------------+
//| Update TimeFrame data by using a base rate                       |
//| By definition base rate time frame can not be larger than        |
//| current time frame. So the return value can only be 1 for a new  |
//| bar or 0 for current bar update.                                 |
//+------------------------------------------------------------------+
int TimeFrame::updateOne(const MqlRates &rate)
  {
   int bars=m_bars;

   datetime barDate=(rate.time/m_periodSeconds)*m_periodSeconds;
   if(m_bars==0 || m_time[m_bars-1]<barDate)
     {
      //--- new bar
      increase();
      m_time[m_bars-1]=barDate;
      m_open[m_bars-1]=rate.open;
     }

//--- only same or later rate is valid
   if(rate.time>=m_lastBaseBarTime)
     {
      m_close[m_bars-1]=rate.close;
      if(rate.high>m_high[m_bars-1]) m_high[m_bars-1]=rate.high;
      if(rate.low<m_low[m_bars-1]) m_low[m_bars-1]=rate.low;
      m_spread[m_bars-1]=rate.spread;
      m_tickVolume[m_bars-1]+=rate.tick_volume;
      m_realVolume[m_bars-1]+=rate.real_volume;

      if(m_lastBaseBarTime==rate.time)
        {
         m_tickVolume[m_bars-1]-=m_lastTickVolume;
         m_realVolume[m_bars-1]-=m_lastRealVolume;
        }

      m_lastBaseBarTime=rate.time;
      m_lastTickVolume=rate.tick_volume;
      m_lastRealVolume=rate.real_volume;
     }

   return m_bars-bars;
  }
//+------------------------------------------------------------------+
