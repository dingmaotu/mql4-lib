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

#include "../Lang/Indicator.mqh"
#include "../Collection/HashMap.mqh"
//+------------------------------------------------------------------+
//| drives indicator update                                          |
//+------------------------------------------------------------------+
class IndicatorDriver
  {
private:
   HashMap<Indicator*,int>m_callbacks;

public:
   //--- IndicatorDriver owns the indicators
                     IndicatorDriver():m_callbacks(NULL,true) {}

   bool              add(Indicator *callback) {return m_callbacks.setIfNotExist(callback,0);}
   bool              remove(Indicator *callback) {return m_callbacks.remove(callback);}

   bool              operator+=(Indicator *callback) {return m_callbacks.setIfNotExist(callback,0);}
   bool              operator-=(Indicator *callback) {return m_callbacks.remove(callback);}

   bool              contains(Indicator *callback) const {return m_callbacks.contains(callback);}

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
                               const int &spread[])
     {
      if(m_callbacks.size()>0)
        {
         for(MapIter<Indicator*,int>it(m_callbacks); !it.end(); it.next())
           {
            int prev=it.value();
            it.setValue(it.key().main(total,prev,time,open,high,low,close,tickVolume,volume,spread));
           }
        }
     }
  };
//+------------------------------------------------------------------+
