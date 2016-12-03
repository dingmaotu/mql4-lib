//+------------------------------------------------------------------+
//|                                                  Lang/String.mqh |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Li Ding"
#property link      "dingmaotu@hotmail.com"
#property strict
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool StringStartsWith(const string str,const string strStart)
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
//|                                                                  |
//+------------------------------------------------------------------+
bool StringEndsWith(const string str,const string strEnd)
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
