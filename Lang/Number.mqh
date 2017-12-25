//+------------------------------------------------------------------+
//| Module: Lang/Number.mqh                                          |
//| This file is part of the mql4-lib project:                       |
//|     https://github.com/dingmaotu/mql4-lib                        |
//|                                                                  |
//| Copyright 2016-2017 Li Ding <dingmaotu@126.com>                  |
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
#include "Cast.mqh"

//--- define number of bits for common number types
#define CHAR_BITS 8
#define SHORT_BITS 16
#define INT_BITS 32
#define LONG_BITS 64
#define DBL_BITS 64
#define FLT_BITS 32
//+------------------------------------------------------------------+
//| Wraps a float value                                              |
//+------------------------------------------------------------------+
struct Single
  {
   float             value;
   static const float NaN;
   static const float NegativeInfinity;
   static const float PositiveInfinity;

   static bool IsNaN(const float value)
     {
      return value==0xFFFF000000000000;
     }
   //+------------------------------------------------------------------+
   //| Returns a value indicating whether the specified number evaluates|
   //| to positive infinity.                                            |
   //+------------------------------------------------------------------+      
   static bool IsPositiveInfinity(const float value)
     {
      return value==0x7FF0000000000000;
     }
   //+------------------------------------------------------------------+
   //| Returns a value indicating whether the specified number evaluates|
   //| to negative infinity.                                            |
   //+------------------------------------------------------------------+       
   static bool IsNegativeInfinity(const float value)
     {
      return value==0xFFF0000000000000;
     }
   //+------------------------------------------------------------------+
   //| Returns a value indicating whether the specified number evaluates|
   //| to negative or positive infinity.                                |
   //+------------------------------------------------------------------+     
   static bool IsInfinity(const float value)
     {
      return (Single::IsNegativeInfinity(value) || Single::IsPositiveInfinity(value));
     }
   //+------------------------------------------------------------------+
   //| Whether the 2 floats are equal                                   |
   //+------------------------------------------------------------------+
   static bool IsEqual(const float left,const float right)
     {
      return NormalizeDouble(left-right,8)==0;
     }
  };
const float Single::NegativeInfinity=(float)-MathExp(DBL_MAX);
const float Single::PositiveInfinity=(float)MathExp(DBL_MAX);
const float Single::NaN=(float)Single::PositiveInfinity/Single::NegativeInfinity;
//+------------------------------------------------------------------+
//| Wraps a double type                                              |
//+------------------------------------------------------------------+
struct Double
  {
   double            value;
   static const double NaN;
   static const double NegativeInfinity;
   static const double PositiveInfinity;
   //+------------------------------------------------------------------+
   //| Returns a value indicating whether the specified number evaluates|
   //| to positive infinity.                                            |
   //+------------------------------------------------------------------+
   static bool IsPositiveInfinity(const double value)
     {
      const long n=0x7FF0000000000000;
      double d;
      reinterpret_cast(n,d);
      return value==d;
     }
   //+------------------------------------------------------------------+
   //| Returns a value indicating whether the specified number evaluates|
   //| to negative infinity.                                            |
   //+------------------------------------------------------------------+      
   static bool IsNegativeInfinity(const double value)
     {
      const long n=0xFFF0000000000000;
      double d;
      reinterpret_cast(n,d);
      return value==d;
     }
   //+------------------------------------------------------------------+
   //| Returns a value indicating whether the specified number evaluates|
   //| to negative or positive infinity.                                |
   //+------------------------------------------------------------------+      
   static bool IsInfinity(const double value)
     {
      return (Double::IsNegativeInfinity(value) || Double::IsPositiveInfinity(value));
     }
   //+------------------------------------------------------------------+
   //| Returns a value that indicates whether the specified value is not|
   //| a number (NaN).                                                  |
   //+------------------------------------------------------------------+ 
   static bool IsNaN(const double value)
     {
      return (!MathIsValidNumber(value) && !IsInfinity(value));
     }
   //+------------------------------------------------------------------+
   //| Whether the 2 doubles are equal                                  |
   //+------------------------------------------------------------------+
   static bool IsEqual(const double left,const double right)
     {
      return NormalizeDouble(left-right,8)==0;
     }
  };
const double Double::NegativeInfinity=-MathExp(DBL_MAX);
const double Double::PositiveInfinity=MathExp(DBL_MAX);
const double Double::NaN=Double::PositiveInfinity/Double::NegativeInfinity;
//+------------------------------------------------------------------+
