//+------------------------------------------------------------------+
//| Module: Collection/SortComparer.mqh                              |
//| This file is part of the mql4-lib project:                       |
//|     https://github.com/dingmaotu/mql4-lib                        |
//|                                                                  |
//| Copyright 2017 Li Ding <dingmaotu@126.com>                       |
//| Copyright 2017 Yerden Zhumabekov <yerden.zhumabekov@gmail.com>   |
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
#include "../Lang/Hash.mqh"
#include "EqualityComparer.mqh"
#property strict
//+------------------------------------------------------------------+
//| Sort comparer is useful for sorted sets, arrays etc.       |
//+------------------------------------------------------------------+
template<typename T>
class SortComparer: public EqualityComparer<T>
  {
   // Sort comparison:
   //    >0 if left>right
   //    <0 if left<right
   //   ==0 if left==right
public:
   virtual int       compare(const T left,const T right) const=0;
   virtual bool      equals(const T left,const T right) const override {return compare(left,right)==0;}
  };
//+------------------------------------------------------------------+
//| Generic sort comparer for conventional comparable types          |
//+------------------------------------------------------------------+
template<typename T>
class GenericSortComparer: public SortComparer<T>
  {
public:
   virtual int       compare(const T left,const T right) const override {return left<right?-1:left>right;}
   virtual int       hash(const T value) const override {return Hash(value);}
  };
//+------------------------------------------------------------------+
