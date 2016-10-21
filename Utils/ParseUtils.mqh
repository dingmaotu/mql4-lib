//+------------------------------------------------------------------+
//|                                             Utils/ParseUtils.mqh |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015-2016, Li Ding"
#property link      "dingmaotu@hotmail.com"
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
