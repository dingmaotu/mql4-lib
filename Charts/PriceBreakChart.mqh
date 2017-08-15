//+------------------------------------------------------------------+
//| Module: Charts/PriceBreakChart.mqh                               |
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

#include "../History/PriceBreak.mqh"
#include "../Utils/HistoryFile.mqh"
//+------------------------------------------------------------------+
//| PriceBreak chart for saving to history file (offline charts)     |
//+------------------------------------------------------------------+
class PriceBreakChart: public PriceBreak
  {
private:
   MqlRates          m_rate;
   HistoryFile       m_file;
   bool              m_updateTime;
public:
                     PriceBreakChart(int distance,int period);
   int               loadHistory(const MqlRates &rs[]);
   void              onNewBar(int bars,int new_bars,double const &open[],double const &high[],
                              double const &low[],double const &close[],long const &volume[]);
  };
//+------------------------------------------------------------------+
//| Always truncate and rewrite data                                 |
//+------------------------------------------------------------------+
PriceBreakChart::PriceBreakChart(int distance,int period)
   :PriceBreak(distance),m_file(_Symbol,period),m_updateTime(true)
  {
   if(m_file.truncate() && m_file.open())
      m_file.writeHeader();
   else
      Alert(StringFormat(">>> Error opening the history data for symbol %s and period %d",_Symbol,period));
  }
//+------------------------------------------------------------------+
//| Load history data from rates array                               |
//+------------------------------------------------------------------+
int PriceBreakChart::loadHistory(const MqlRates &rs[])
  {
   int bars=0;
   int size=ArraySize(rs);
   if(!m_file.isClosed())
     {
      int newBars=0;
      for(int i=0; i<size; i++)
        {
         if(m_updateTime) m_rate.time=rs[i].time;
         newBars=loadRate(rs[i]);
         m_updateTime=newBars!=0;
         bars+=newBars;
        }
      m_file.flush();
     }
   return bars;
  }
//+------------------------------------------------------------------+
//| Save data to file when new bar is created                        |
//+------------------------------------------------------------------+
void PriceBreakChart::onNewBar(int bars,int new_bars,double const &open[],double const &high[],
                               double const &low[],double const &close[],long const &volume[])
  {
   if(new_bars>0)
     {
      m_rate.open=open[bars-1];
      m_rate.high=high[bars-1];
      m_rate.low=low[bars-1];
      m_rate.close=close[bars-1];
      m_rate.tick_volume=volume[bars-1];
      m_file.writeRecord(m_rate);
      m_file.flush();
     }
  }
//+------------------------------------------------------------------+
