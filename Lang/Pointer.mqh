//+------------------------------------------------------------------+
//|                                                 Lang/Pointer.mqh |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Li Ding"
#property link      "dingmaotu@hotmail.com"
#property strict

#include "Integer.mqh"
//+------------------------------------------------------------------+
//| Generic pointer check                                            |
//+------------------------------------------------------------------+
template<typename T>
bool IsValid(T *pointer)
  {
   return CheckPointer(pointer)!=POINTER_INVALID;
  }
//+------------------------------------------------------------------+
//| Dynamically check if the value is a pointer type                 |
//+------------------------------------------------------------------+
template<typename T>
bool IsPointer(const T &value)
  {
   string tn=typename(value);
// Note that a typename is at least of length > 0
   return StringGetCharacter(tn, StringLen(tn) - 1) == '*';
  }
//+------------------------------------------------------------------+
//| Generic safe pointer delete                                      |
//| Note that this funtion always return false: it is used in for    |
//| loop to delete the pointer when loop ends                        |
//| Generally you should use it as if it returns void                |
//+------------------------------------------------------------------+
template<typename T>
bool SafeDelete(T *pointer)
  {
   if(IsValid(pointer)) delete pointer;
   return false;
  }
//+------------------------------------------------------------------+
//| If pointer is actually a value type                              |
//+------------------------------------------------------------------+
template<typename T>
bool SafeDelete(T pointer) {return false;}
//+------------------------------------------------------------------+
//| Wraps a pointer that does not own the underlying resource        |
//+------------------------------------------------------------------+
template<typename T>
class Ref
  {
public:
   T                *r;
                     Ref(T *raw=NULL):r(raw) {}
                     Ref(const Ref<T>&other):r(other.r) {}
   virtual          ~Ref() {}

   bool              operator==(const Ref &other) const {return other.r==r;}
   bool              operator==(const T *other) const {return r==other;}
   bool              operator!=(const Ref &other) const {return other.r!=r;}
   bool              operator!=(const T *other) const {return r!=other;}

   virtual T        *operator=(Ref &other) {r=other.r;return r;}
   T                *operator=(T *other){ r=other;return r;}
  };
//+------------------------------------------------------------------+
//| Wraps a pointer that owns the underlying resource                |
//+------------------------------------------------------------------+
template<typename T>
class Ptr: public Ref<T>
  {
public:
                     Ptr(T *raw=NULL):Ref(raw) {}
                     Ptr(const Ptr<T>&other):Ref(other) {}

   //--- responsible for delete the resource
                    ~Ptr() {SafeDelete(r);}
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
template<typename T>
struct PointerWrapper
  {
public:
                     PointerWrapper(T *v):r(v) {}
   T                *r;
  };
//+------------------------------------------------------------------+
//| Numeric address for a pointer: different pointers returns a      |
//| distinct value                                                   |
//+------------------------------------------------------------------+
template<typename T>
int GetAddress(T *pointer)
  {
   PointerWrapper<T>p(pointer);
   return ((LargeInt)p).lowPart;
  }
//+------------------------------------------------------------------+
