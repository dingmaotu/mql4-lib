//+------------------------------------------------------------------+
//| Module: Utils/Math.mqh                                           |
//| This file is part of the mql4-lib project:                       |
//|     https://github.com/dingmaotu/mql4-lib                        |
//|                                                                  |
//| Copyright 2016 Li Ding <dingmaotu@126.com>                       |
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
#include "../Lang/Number.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Math
  {
public:
   template<typename T>
   static T max(T value1,T value2)
     {
      return value1 > value2 ? value1 : value2;
     }
   template<typename T>
   static T min(T value1,T value2)
     {
      return value1 < value2 ? value1 : value2;
     }
   template<typename T>
   static T abs(T value)
     {
      return value < 0 ? -value : value;
     }
   template<typename T>
   static int sign(T value)
     {
      return value < 0 ? -1 : 1;
     }

   //--- round value up to a multiple of min
   static double roundUpToMultiple(double value,double min)
     {
      double r=MathMod(value,min);
      return Mql::isEqual(r,0.0) ? value : (value-r+min);
     }
   //--- round value down to a multiple of min
   static double roundDownToMultiple(double value,double min)
     {
      double r=MathMod(value,min);
      return Mql::isEqual(r,0.0) ? value : (value-r);
     }

   static double linearInterpolate(double x1,double x2,double y1,double y2,double x)
     {
      if(Mql::isEqual(x1,x2)) return Double::NaN;
      return y1 + (y1-y2)*(x-x1)/(x1-x2);
     }
  };
//+------------------------------------------------------------------+
