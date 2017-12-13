//+------------------------------------------------------------------+
//| Module: History/HistoryData.mqh                                  |
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

#include "IndicatorDriver.mqh"

int STANDARD_TIMEFRAMES[]={1,5,15,30,60,240,1440,10080,43200};
//+------------------------------------------------------------------+
//| Check if the given timeframe is a standard one                   |
//+------------------------------------------------------------------+
bool IsStandardTimeframe(int period)
  {
   switch(period)
     {
      case 1:
      case 5:
      case 15:
      case 30:
      case 60:
      case 240:
      case 1440:
      case 10080:
      case 43200:
         return true;
      default:
         return false;
     }
  }
//+------------------------------------------------------------------+
//| virtual base class for all kinds of OHLC based history data      |
//+------------------------------------------------------------------+
class HistoryData
  {
public:
   virtual string    getSymbol() const=0;

   virtual int       getBars() const=0;
   virtual bool      isNewBar() const=0;
   virtual int       getNewBars() const=0;

   virtual double    getHigh(int shift) const=0;
   virtual double    getLow(int shift) const=0;
   virtual double    getOpen(int shift) const=0;
   virtual double    getClose(int shift) const=0;
   virtual long      getVolume(int shift) const=0;

   //--- update event
   //--- indicators can subscribe to this event can receive OnCalculate events
   IndicatorDriver   OnUpdate;
  };
//+------------------------------------------------------------------+
