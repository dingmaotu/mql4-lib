//+------------------------------------------------------------------+
//|                                                  Lang/Object.mqh |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015-2016, Li Ding"
#property link      "dingmaotu@hotmail.com"
#property strict

#include "Integer.mqh"
#include "Pointer.mqh"
//+------------------------------------------------------------------+
//| Base class for all complicated objects in this library           |
//+------------------------------------------------------------------+
class Object
  {
public:
                     Object() {}
   virtual          ~Object() {}
   virtual string    toString() const {return StringFormat("[Object #%d]",hash());}
   virtual int       hash() const;
   virtual bool      equals(const Object *o) const {return GetPointer(this)==o;}
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Object::hash(void) const
  {
   Pointer p;
   p.value=(void*)GetPointer(this);
   return ((LargeInt)p).lowPart;
  }
//+------------------------------------------------------------------+
