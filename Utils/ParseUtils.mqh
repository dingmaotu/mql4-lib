//+------------------------------------------------------------------+
//| Module: Utils/ParseUtils.mqh                                     |
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
//| Parse a time range description like 20M,24H,13D,14W              |
//| REGEX: /\d+[MHDW]?/                                              |
//+------------------------------------------------------------------+
bool ParseTimeRange(string s,long &time)
  {
   static const ushort TimeUnits[5]={'M','H','D','W'};
   static const long   TimeValues[5]={60,3600,3600*24,3600*24*7};
   int size=StringLen(s);
   if(size==0) return false; // empty string is not accepted
   time=0;
   for(int i=0; i<size; i++)
     {
      ushort c=StringGetCharacter(s,i);
      if(c>='0' && c<='9')
        {
         time=time*10+c-'0';
        }
      else if(i>0)
        {
         for(int j=0;j<4;j++)
           {
            if(TimeUnits[j]==c) {time*=TimeValues[j];return true;}
           }
         return false; // non first char is neither digit nor valid time units
        }
      else
        {
         return false; // first char is not digit
        }
     }
   return true;        // accept: all digits
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ParseToPositiveIntegers(string s,int &target[])
  {
   string t[];
   StringSplit(s,StringGetCharacter(",",0),t);
   int size=ArraySize(t);
   if(ArraySize(t)<=0)
     {
      Print(s+" is not a list (comma separated) of integers!");
      return false;
     }
   bool isSeries=ArrayGetAsSeries(target);
   ArraySetAsSeries(target,false);

   ArrayResize(target,size);
   for(int i=0; i<size; i++)
     {
      target[i]=(int)StringToInteger(t[i]);
      if(target[i]<=0)
        {
         Print(t[i]+" is not positive!");
         return false;
        }
     }
   ArraySetAsSeries(target,isSeries);
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ParseToPositiveDoubles(string s,double &target[])
  {
   string t[];
   StringSplit(s,StringGetCharacter(",",0),t);
   int size=ArraySize(t);
   if(ArraySize(t)<=0)
     {
      Print(s+" is not a list (comma separated) of doubles!");
      return false;
     }
   bool isSeries=ArrayGetAsSeries(target);
   ArraySetAsSeries(target,false);

   ArrayResize(target,size);
   for(int i=0; i<size; i++)
     {
      target[i]=NormalizeDouble(StringToDouble(t[i]),2);
      if(target[i]<=0)
        {
         Print(t[i]+" is not positive!");
         return false;
        }
     }
   ArraySetAsSeries(target,isSeries);
   return true;
  }
//+------------------------------------------------------------------+
