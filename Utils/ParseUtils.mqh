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
//|                                                                  |
//+------------------------------------------------------------------+
bool parseToPositiveIntegers(string s,int &target[])
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
bool parseToPositiveDoubles(string s,double &target[])
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
