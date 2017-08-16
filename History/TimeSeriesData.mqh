//+------------------------------------------------------------------+
//| Module: History/TimeSeriesData.mqh                               |
//| This file is part of the mql4-lib project:                       |
//|     https://github.com/dingmaotu/mql4-lib                        |
//|                                                                  |
//| Copyright 2017 Li Ding <dingmaotu@126.com>                       |
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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class TimeSeriesData: public HistoryData
  {
private:
   string            m_symbol;
   int               m_period;
   // new bars between updates; larger than 0 if has new bar
   long              m_newBars;
   datetime          m_lastBarDate;
protected:
   void              updateNewBar(datetime date);
public:
                     TimeSeriesData(string symbol,int period):m_symbol(symbol==""?_Symbol:symbol),m_period(period==0?_Period:period){}

   string            getSymbol() const {return m_symbol;}
   int               getPeriod() const {return m_period;}

   static bool       refresh() {return RefreshRates();}

   long              getBars() const {return SeriesInfoInteger(m_symbol,m_period,SERIES_BARS_COUNT);}
   long              getBars(datetime startDate,datetime stopDate) const {return Bars(m_symbol,m_period,startDate,stopDate);}
   datetime          getFirstDate() const {return(datetime)SeriesInfoInteger(m_symbol,m_period,SERIES_FIRSTDATE); }
   datetime          getLastBarDate() const {return(datetime)SeriesInfoInteger(m_symbol,m_period,SERIES_LASTBAR_DATE); }
   datetime          getServerFirstDate() const {return(datetime)SeriesInfoInteger(m_symbol,m_period,SERIES_SERVER_FIRSTDATE); }
   datetime          getCurrentBarDate() const {int ps=PeriodSeconds(m_period);return TimeCurrent()/ps*ps;}

   void              update() {updateNewBar(getLastBarDate());}
   void              updateCurrent() {updateNewBar(getCurrentBarDate());}

   bool              isNewBar() const {return m_newBars>0;}
   long              getNewBars() const {return m_newBars;}

   double            getHigh(int shift) const {return iHigh(m_symbol,m_period,shift);}
   double            getLow(int shift) const {return iLow(m_symbol,m_period,shift);}
   double            getOpen(int shift) const {return iOpen(m_symbol,m_period,shift);}
   double            getClose(int shift) const {return iClose(m_symbol,m_period,shift);}
   long              getVolume(int shift) const {return iVolume(m_symbol,m_period,shift);}

#define COPY_POS_COUNT(WHAT,TYPE) \
   int               copy##WHAT(int pos,int count,TYPE &array[]) const {return Copy##WHAT(m_symbol,m_period,pos,count,array);}
#define COPY_STARTTIME_COUNT(WHAT,TYPE) \
   int               copy##WHAT(datetime startTime,int count,TYPE &array[]) const {return Copy##WHAT(m_symbol,m_period,startTime,count,array);}
#define COPY_STARTTIME_ENDTIME(WHAT,TYPE) \
   int               copy##WHAT(datetime startTime,datetime stopTime,TYPE &array[]) const {return Copy##WHAT(m_symbol,m_period,startTime,stopTime,array);}

   COPY_POS_COUNT(Open,double)
   COPY_POS_COUNT(Close,double)
   COPY_POS_COUNT(High,double)
   COPY_POS_COUNT(Low,double)
   COPY_POS_COUNT(Time,datetime)
   COPY_POS_COUNT(TickVolume,long)
   COPY_POS_COUNT(RealVolume,long)
   COPY_POS_COUNT(Spread,int)
   COPY_POS_COUNT(Rates,MqlRates)

   COPY_STARTTIME_COUNT(Open,double)
   COPY_STARTTIME_COUNT(Close,double)
   COPY_STARTTIME_COUNT(High,double)
   COPY_STARTTIME_COUNT(Low,double)
   COPY_STARTTIME_COUNT(Time,datetime)
   COPY_STARTTIME_COUNT(TickVolume,long)
   COPY_STARTTIME_COUNT(RealVolume,long)
   COPY_STARTTIME_COUNT(Spread,int)
   COPY_STARTTIME_COUNT(Rates,MqlRates)

   COPY_STARTTIME_ENDTIME(Open,double)
   COPY_STARTTIME_ENDTIME(Close,double)
   COPY_STARTTIME_ENDTIME(High,double)
   COPY_STARTTIME_ENDTIME(Low,double)
   COPY_STARTTIME_ENDTIME(Time,datetime)
   COPY_STARTTIME_ENDTIME(RealVolume,long)
   COPY_STARTTIME_ENDTIME(TickVolume,long)
   COPY_STARTTIME_ENDTIME(Spread,int)
   COPY_STARTTIME_ENDTIME(Rates,MqlRates)
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void TimeSeriesData::updateNewBar(datetime current)
  {
   if(m_lastBarDate==0)
     {
      m_newBars=getBars();
      m_lastBarDate=current;
      return;
     }

   if(m_lastBarDate<current)
     {
      m_newBars=getBars(m_lastBarDate,current)-1;
      m_lastBarDate=current;
     }
   else
     {
      m_newBars=0;
     }
  }
//+------------------------------------------------------------------+
