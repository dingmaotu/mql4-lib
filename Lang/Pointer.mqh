//+------------------------------------------------------------------+
//|                                                 Lang/Pointer.mqh |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Li Ding"
#property link      "dingmaotu@hotmail.com"
#property strict
//+------------------------------------------------------------------+
//| Generic safe pointer delete                                      |
//+------------------------------------------------------------------+
template<typename T>
void SafeDelete(T *pointer)
  {
   if(CheckPointer(pointer)==POINTER_DYNAMIC)
     {
      delete pointer;
     }
  }
//+------------------------------------------------------------------+
//| Generic pointer check                                            |
//+------------------------------------------------------------------+
template<typename T>
bool Invalid(T *pointer)
  {
   return CheckPointer(pointer)==POINTER_INVALID;
  }
//+------------------------------------------------------------------+
