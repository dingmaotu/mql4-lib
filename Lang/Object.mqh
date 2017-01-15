//+------------------------------------------------------------------+
//|                                                  Lang/Object.mqh |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015-2016, Li Ding"
#property link      "dingmaotu@hotmail.com"
#property strict

#define ObjectAttr(Type, Private, Public) \
public:\
   Type              get##Public() const {return m_##Private;}\
   void              set##Public(Type value) {m_##Private=value;}\
private:\
   Type              m_##Private\

#include "Integer.mqh"
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
struct ObjectPointer
  {
   Object           *pointer;
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Object::hash(void) const
  {
   ObjectPointer p;
   p.pointer=(Object*)GetPointer(this);
   return ((LargeInt)p).lowPart;
  }
//+------------------------------------------------------------------+
//| For pointers, if it is Object inherited,  use equals method      |
//+------------------------------------------------------------------+
template<typename T>
bool IsEqual(const Object *left,const T *right)
  {
   if(left==NULL || right==NULL) {return left==right;}
   else return left.equals(right);
  }
//+------------------------------------------------------------------+
//| Compare for other values                                         |
//+------------------------------------------------------------------+
template<typename T>
bool IsEqual(const T left,const T right)
  {
   return left == right;
  }
//+------------------------------------------------------------------+
