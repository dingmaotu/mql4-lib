//+------------------------------------------------------------------+
//| Module: History/IndicatorDriver.mqh                              |
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

#include "../Lang/Array.mqh"
#include "../Lang/Indicator.mqh"
//+------------------------------------------------------------------+
//| drives indicators                                                |
//+------------------------------------------------------------------+
class IndicatorDriver
  {
private:
   Array<Indicator*>m_callbacks;
   Array<int>m_prev;

public:
   bool              add(Indicator *callback);
   bool              remove(Indicator *callback);
   bool              contains(Indicator *callback) const {return m_callbacks.index(callback)>=0;}
   void              clear() {m_callbacks.clear();}
   int               size() const {return m_callbacks.size();}
   void              calculate(const int total,
                               const datetime &time[],
                               const double &open[],
                               const double &high[],
                               const double &low[],
                               const double &close[],
                               const long &tickVolume[],
                               const long &volume[],
                               const int &spread[]);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IndicatorDriver::add(Indicator *callback)
  {
   int index = m_callbacks.index(callback);
   if(index >= 0)
     {
      return false;
     }
   else
     {
      int s=size();
      m_callbacks.insertAt(s,callback);
      m_prev.insertAt(s,0);
      return true;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IndicatorDriver::remove(Indicator *callback)
  {
   int index = m_callbacks.index(callback);
   if(index >= 0)
     {
      m_callbacks.removeAt(index);
      m_prev.removeAt(index);
      return true;
     }
   else
     {
      return false;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void IndicatorDriver::calculate(const int total,
                                const datetime &time[],
                                const double &open[],
                                const double &high[],
                                const double &low[],
                                const double &close[],
                                const long &tickVolume[],
                                const long &volume[],
                                const int &spread[])
  {
   int size = m_callbacks.size();
   for(int i=0; i<size; i++)
     {
      Indicator *callback=m_callbacks[i];
      m_prev.set(i,callback.main(total,m_prev[i],time,open,high,low,close,tickVolume,volume,spread));
     }
  }
//+------------------------------------------------------------------+
