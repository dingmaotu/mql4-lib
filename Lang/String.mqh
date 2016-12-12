//+------------------------------------------------------------------+
//|                                                  Lang/String.mqh |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Li Ding"
#property link      "dingmaotu@hotmail.com"
#property strict
//+------------------------------------------------------------------+
//| Note: if both strings are empty, this function returns true      |
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
//| Note: if both strings are empty, this function returns true      |
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
//| Join a string array                                              |
//+------------------------------------------------------------------+
string StringJoin(const string &a[],const string sep=" ")
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
                      const string sep=" ",const string psep=" ")
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
