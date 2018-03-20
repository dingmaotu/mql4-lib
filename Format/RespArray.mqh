//+------------------------------------------------------------------+
//| Module: Format/RespArray.mqh                                     |
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
#include "RespBytes.mqh" // for Nil reference
//+------------------------------------------------------------------+
//| RespArray                                                        |
//+------------------------------------------------------------------+
class RespArray: public RespValue
  {
private:
   int               m_extraBuffer;
   RespValue        *m_array[];
public:
   RespType          getType() const {return RespTypeArray;}
   string            toString() const
     {
      string result="[";
      int size=ArraySize(m_array);
      for(int i=0; i<size; i++)
        {
         result+=m_array[i].toString();
         result+=",";
        }
      StringSetCharacter(result,StringLen(result)-1,']');
      return result;
     }

   int               encode(uchar &a[],int index) const
     {
      char buf[20];
      int size=ArraySize(m_array);
      int length=IntegerToCharArray(size,buf);
      if(ArraySize(a)<index+3+length)
        {
         ArrayResize(a,index+3+length,100);
        }
      int currentIndex=index;
      a[currentIndex++]='*';
      currentIndex+=ArrayCopy(a,buf,currentIndex,20-length);
      a[currentIndex++]='\r';
      a[currentIndex++]='\n';
      for(int i=0;i<size;i++)
        {
         currentIndex+=m_array[i].encode(a,currentIndex);
        }
      return currentIndex-index;
     }

   //--- array specific
protected:
   void              clearArray()
     {
      int size=ArraySize(m_array);
      for(int i=0; i<size; i++)
        {
         // check for Nil singleton 
         if(m_array[i]!=Nil) SafeDelete(m_array[i]);
        }
     }
public:
                     RespArray(int size=0,int extraBuffer=10):m_extraBuffer(extraBuffer) {resize(size);}
                    ~RespArray() {clearArray(); ArrayFree(m_array);}

   RespValue        *operator[](int index) const {return m_array[index];}
   int               size() const {return ArraySize(m_array);}

   void              resize(int size) { ArrayResize(m_array,size,m_extraBuffer); }

   void              setExtraBuffer(int value) {m_extraBuffer=value;resize(size());}
   int               getExtraBuffer() const {return m_extraBuffer;}

   void              clear() {clearArray(); resize(0);}

   void              set(int index,RespValue *value) {m_array[index]=value;}
   void              insertAt(int index,RespValue *value)
     {
      int size=ArraySize(m_array);
      if(index<0 || index>size) return;
      ArrayResize(m_array,size+1,m_extraBuffer);
      for(int i=size; i>index; i--)
        {
         m_array[i]=m_array[i-1];
        }
      m_array[index]=value;
     }
   void              removeAt(int index)
     {
      int size=ArraySize(m_array);
      if(index<0 || index>=size) return;

      for(int i=index; i<size-1; i++)
        {
         m_array[i]=m_array[i+1];
        }
      ArrayResize(m_array,size-1);
     }

   int               index(const RespValue *value) const
     {
      int s=ArraySize(m_array);
      int index=-1;
      for(int i=0; i<s; i++)
        {
         if(value==m_array[i])
           {
            index=i;
            break;
           }
        }
      return index;
     }
  };
//+------------------------------------------------------------------+
