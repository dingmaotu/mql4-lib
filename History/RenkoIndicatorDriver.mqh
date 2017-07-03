//+------------------------------------------------------------------+
//| Module: History/RenkoIndicatorDriver.mqh                         |
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

#include "Renko.mqh"
#include "IndicatorDriver.mqh"
//+------------------------------------------------------------------+
//| drives indicators for renko charts                               |
//+------------------------------------------------------------------+
class RenkoIndicatorDriver: public Renko
  {
private:
   IndicatorDriver *m_driver;

public:
                     RenkoIndicatorDriver(int barSize,IndicatorDriver &driver)
   :Renko(barSize*_Point),m_driver(GetPointer(driver)){}
   void              onNewBar(int total,int pBars,double const &pOpen[],double const &pHigh[],
                              double const &pLow[],double const &pClose[],long const &pVolume[])
     {
      datetime time[];
      long volume[];
      int spread[];
      m_driver.calculate(total,time,pOpen,pHigh,pLow,pClose,pVolume,volume,spread);
     }
  };
//+------------------------------------------------------------------+
