//+------------------------------------------------------------------+
//|                                             Lang/IdGenerator.mqh |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015-2016, Li Ding"
#property link      "dingmaotu@hotmail.com"
#property strict

#include <stderror.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double AtomicIncrement(string var)
  {
   bool success=false;
   double val=0;
   do
     {
      val=GlobalVariableGet(var);
      success=GlobalVariableSetOnCondition(var,val+1,val);
     }
   while(!success && GetLastError()!=ERR_GLOBAL_VARIABLE_NOT_FOUND);
   return val;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class GlobalIdGenerator
  {
private:
   const string      LOCK_NAME;
public:
                     GlobalIdGenerator(string lockName):LOCK_NAME(lockName)
     {
      GlobalVariableSet(LOCK_NAME,0);
     }
                    ~GlobalIdGenerator()
     {
      GlobalVariableDel(LOCK_NAME);
     }

   long next()
     {
      return ((long)AtomicIncrement(LOCK_NAME)+1);
     }
  };
//+------------------------------------------------------------------+
