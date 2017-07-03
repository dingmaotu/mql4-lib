//+------------------------------------------------------------------+
//| Module: Utils/Price.mqh                                          |
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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getPrice(int i,ENUM_APPLIED_PRICE applied,const double &open[],const double &high[],const double &low[],const double &close[])
  {
   switch(applied)
     {
      case PRICE_CLOSE:
         return close[i];
      case PRICE_HIGH:
         return high[i];
      case PRICE_LOW:
         return low[i];
      case PRICE_MEDIAN:
         return (high[i]+low[i])/2;
      case PRICE_OPEN:
         return open[i];
      case PRICE_TYPICAL:
         return (high[i]+low[i]+close[i])/3;
      case PRICE_WEIGHTED:
         return (high[i]+low[i]+close[i]+open[i])/4;
      default:
         return 0;
     }
  }
//+------------------------------------------------------------------+
