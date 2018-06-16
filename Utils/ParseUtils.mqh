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
//| Convert a string representation of boolean to the real value     |
//| Y y 1 T t are true                                               |
//| all other values are false                                       |
//+------------------------------------------------------------------+
bool StringToBoolean(const string s)
  {
   if(StringLen(s)!=1) return false;
   ushort c= s[0];
   return c=='Y' || c=='y' || c=='1' || c=='T' || c=='t';
  }
//+------------------------------------------------------------------+
//| Parse a (default comma separated) list of booleans               |
//+------------------------------------------------------------------+
bool ParseBooleans(const string s,bool &target[],short sep=',')
  {
   string t[];
   StringSplit(s,sep,t);
   int size=ArraySize(t);
   if(ArraySize(t)<=0)
     {
      PrintFormat(">>> Error: %s is not a list of booleans!",s);
      return false;
     }
   bool isSeries=ArrayGetAsSeries(target);
   ArraySetAsSeries(target,false);

   ArrayResize(target,size);
   for(int i=0; i<size; i++)
     {
      target[i]=StringToBoolean(t[i]);
     }
   ArraySetAsSeries(target,isSeries);
   return true;
  }
//+------------------------------------------------------------------+
//| Parse a (default comma separated) list of integers               |
//+------------------------------------------------------------------+
bool ParseIntegers(const string s,int &target[],short sep=',')
  {
   string t[];
   StringSplit(s,sep,t);
   int size=ArraySize(t);
   if(ArraySize(t)<=0)
     {
      Print(s+" is not a list of integers!");
      return false;
     }
   bool isSeries=ArrayGetAsSeries(target);
   ArraySetAsSeries(target,false);

   ArrayResize(target,size);
   for(int i=0; i<size; i++)
     {
      target[i]=(int)StringToInteger(t[i]);
     }
   ArraySetAsSeries(target,isSeries);
   return true;
  }
//+------------------------------------------------------------------+
//| Parse a (default comma separated) list of doubles                |
//+------------------------------------------------------------------+
bool ParseDoubles(string s,double &target[],short sep=',')
  {
   string t[];
   StringSplit(s,sep,t);
   int size=ArraySize(t);
   if(ArraySize(t)<=0)
     {
      Print(s+" is not a list of doubles!");
      return false;
     }
   bool isSeries=ArrayGetAsSeries(target);
   ArraySetAsSeries(target,false);

   ArrayResize(target,size);
   for(int i=0; i<size; i++)
     {
      target[i]=StringToDouble(t[i]);
     }
   ArraySetAsSeries(target,isSeries);
   return true;
  }
//+------------------------------------------------------------------+
//| Parse a list of positive integers                                |
//+------------------------------------------------------------------+
bool ParseToPositiveIntegers(string s,int &target[])
  {
   if(!ParseIntegers(s,target)) return false;

   for(int i=0; i<ArraySize(target); i++)
     {
      if(target[i]<=0)
        {
         PrintFormat("Error: %d is not positive!",target[i]);
         return false;
        }
     }

   return true;
  }
//+------------------------------------------------------------------+
//| Parse a list of negative integers                                |
//+------------------------------------------------------------------+
bool ParseToPositiveDoubles(string s,double &target[])
  {
   if(!ParseDoubles(s,target)) return false;

   for(int i=0; i<ArraySize(target); i++)
     {
      if(target[i]<=0)
        {
         PrintFormat("Error: %d is not positive!",target[i]);
         return false;
        }
     }
   return true;
  }
//+------------------------------------------------------------------+
