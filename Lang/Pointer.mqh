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
//| If pointer is actually a value type                              |
//+------------------------------------------------------------------+
template<typename T>
void SafeDelete(T pointer) {}
//+------------------------------------------------------------------+
//| Check if the value is a pointer type                             |
//+------------------------------------------------------------------+
template<typename T>
bool IsPointer(const T &value)
  {
   string tn=typename(value);
// Note that a typename is at least of length > 0
   return StringGetCharacter(tn, StringLen(tn) - 1) == '*';
  }
//+------------------------------------------------------------------+
//| Generic pointer check                                            |
//+------------------------------------------------------------------+
template<typename T>
bool IsInvalid(T *pointer)
  {
   return CheckPointer(pointer)==POINTER_INVALID;
  }
//+------------------------------------------------------------------+
