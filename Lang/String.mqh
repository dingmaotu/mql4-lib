//+------------------------------------------------------------------+
//| Module: Lang/String.mqh                                          |
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

#define unichar uint

#define StringContains(str, substr) (StringFind(str, substr, 0)!=-1)
//+------------------------------------------------------------------+
//| Note: if both strings are empty, this function returns true      |
//+------------------------------------------------------------------+
bool StringStartsWith(string str,string strStart)
  {
   int len=StringLen(str);
   int lenStart=StringLen(strStart);

   if(len<lenStart)
     {
      return false;
     }

   for(int i=0; i<lenStart; i++)
     {
      if(StringGetCharacter(str,i)!=StringGetCharacter(strStart,i))
        {
         return false;
        }
     }
   return true;
  }
//+------------------------------------------------------------------+
//| Note: if both strings are empty, this function returns true      |
//+------------------------------------------------------------------+
bool StringEndsWith(string str,string strEnd)
  {
   int len=StringLen(str);
   int lenEnd=StringLen(strEnd);

   if(len<lenEnd)
     {
      return false;
     }

   for(int i=1; i<=lenEnd; i++)
     {
      if(StringGetCharacter(str,len-i)!=StringGetCharacter(strEnd,lenEnd-i))
        {
         return false;
        }
     }
   return true;
  }
//+------------------------------------------------------------------+
//| Join a string array                                              |
//+------------------------------------------------------------------+
string StringJoin(const string &a[],string sep=" ")
  {
   int size=ArraySize(a);
   string res="";
   if(size>0)
     {
      res+=a[0];
      for(int i=1; i<size; i++)
        {
         res+=sep+a[i];
        }
     }
   return res;
  }
//+------------------------------------------------------------------+
//| Join keys and values as pairs                                    |
//| Example:                                                         |
//|   keys = ["a", "b", "c"]                                         |
//|   values = ["1", "2", "3"]                                       |
//|   sep = ":"                                                      |
//|   psep = ", "                                                    |
//|   result = "a:1, b:2, c:3"                                       |
//+------------------------------------------------------------------+
string StringPairJoin(const string &keys[],const string &values[],
                      string sep=" ",string psep=" ")
  {
   int keySize=ArraySize(keys);
   int valueSize=ArraySize(values);
   int size=keySize>valueSize?keySize:valueSize;
   string res="";
   if(size>0)
     {
      res+=keys[0]+sep+values[0];
     }
   for(int i=1; i<size; i++)
     {
      res+=psep+keys[i]+sep+values[i];
     }
   return res;
  }
//+------------------------------------------------------------------+
//| Get the next Unicode character: string is UTF-16 encoded         |
//+------------------------------------------------------------------+
unichar NextChar(const string &s,int &index)
  {
   if(index>StringLen(s)-1)
     {
      return -1;
     }
   ushort c1=s[index];
   if(c1>0xDFFF || c1<0xD800)
     {
      index++;
      return c1;
     }

   if(index>StringLen(s)-2)
     {
      return -1;
     }
   ushort c2=s[index+1];
   if(c2<0xDC00 || c2>0xDFFF)
     {
      return -1;
     }
   index+=2;
   return 0x10000 + ((c1&0x03FF) << 10) + (c2&0x03FF);
  }
//+------------------------------------------------------------------+
