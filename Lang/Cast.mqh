//+------------------------------------------------------------------+
//| Module: Lang/Case.mqh                                            |
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
//+------------------------------------------------------------------+
//| In the official MQL4 language reference                          |
//| (Language Basics -> Data Types -> Integer Types -> Typecasting): |
//|                                                                  |
//| Typecasting of Simple Structure Types                            |
//| -------------------------------------                            |
//| Data of the simple structures type can be assigned to each other |
//| only if all the members of both structures are of numeric types. |
//| In this case both operands of the assignment operation (left and |
//| right) must be of the structures type. The member-wise casting is|
//| not performed, a simple copying is done. If the structures are of|
//| different sizes, the number of bytes of the smaller size is      |
//| copied.Thus the absence of union in MQL4 is compensated.         |
//|                                                                  |
//| But this is not true in new versions (Maybe build 1080 or later) |
//| of MQL4: union is indeed supported, and struct casting may become|
//| an unsupported feature.                                          |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Cast any value type to another value type                        |
//+------------------------------------------------------------------+
template<typename From,typename To>
void reinterpret_cast(const From &f,To &t)
  {
   union _u
     {
      From              from;
      const To          to;
     }
   u;
   u.from=f;
   t=u.to;
  }
//+------------------------------------------------------------------+
//| Convert any value type to byte array                             |
//+------------------------------------------------------------------+
template<typename T>
void byte_cast(const T &value,uchar &a[],int start=0)
  {
   union _u
     {
      T                 from;
      const uchar       to[sizeof(T)];
     }
   u;
   u.from=value;
   ArrayCopy(a,u.to,start);
  }
//+------------------------------------------------------------------+
