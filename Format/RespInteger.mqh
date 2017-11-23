//+------------------------------------------------------------------+
//| Module: Format/RespInteger.mqh                                   |
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
#include "RespValue.mqh"
//+------------------------------------------------------------------+
//| RespInteger                                                      |
//+------------------------------------------------------------------+
class RespInteger: public RespValue
  {
private:
   long              m_value;
public:
   RespType          getType() const {return RespTypeInteger;}
   string            toString() const {return IntegerToString(m_value);}

   int               encode(uchar &a[],int index) const
     {
      char buf[20];
      int length=IntegerToCharArray(m_value,buf);
      if(ArraySize(a)<index+3+length)
        {
         ArrayResize(a,index+3+length);
        }
      int currentIndex=index;
      a[currentIndex++]=':';
      currentIndex+=ArrayCopy(a,buf,currentIndex,20-length);
      a[currentIndex++]='\r';
      a[currentIndex++]='\n';
      return currentIndex-index;
     }
                     RespInteger(const long value):m_value(value){}
   //--- RespInteger specific
   long              getValue() const {return m_value;}
  };
//+------------------------------------------------------------------+
