//+------------------------------------------------------------------+
//|                                                 Lang/Pointer.mqh |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Li Ding"
#property link      "dingmaotu@hotmail.com"
#property strict

#include "Integer.mqh"
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
//| Generic pointer check                                            |
//+------------------------------------------------------------------+
template<typename T>
bool IsInvalid(T *pointer)
  {
   return CheckPointer(pointer)==POINTER_INVALID;
  }
//+------------------------------------------------------------------+
//| Generic pointer check                                            |
//+------------------------------------------------------------------+
template<typename T>
bool IsValid(T *pointer)
  {
   return CheckPointer(pointer)!=POINTER_INVALID;
  }
//+------------------------------------------------------------------+
//| Wraps a pointer that owns a resource                             |
//+------------------------------------------------------------------+
template<typename T>
class Ptr
  {
private:
   T                *m_ref;
public:
                     Ptr(T *raw=NULL):m_ref(raw){}
                     Ptr(Ptr &other):m_ref(other.m_ref){other.m_ref=NULL;}
                     Ptr(const Ref<T>&other):m_ref(other.r()){}
                    ~Ptr() {if(IsValid(m_ref)) delete m_ref;}

   T                *operator=(T *other)
     {
      m_ref=other;
      return m_ref;
     }
   T                *operator=(const Ref<T>&other)
     {
      m_ref=other.r();
      return m_ref;
     }
   T                *operator=(Ptr &other)
     {
      m_ref=other.m_ref;
      other.m_ref=NULL;
      return m_ref;
     }

   bool              operator==(const Ptr &other) const {return m_ref==other.m_ref;}
   bool              operator==(const T *other) const {return m_ref==other;}
   bool              operator==(const Ref<T>&other) const {return m_ref==other.r();}
   bool              operator!=(const Ptr &other) const {return m_ref!=other.m_ref;}
   bool              operator!=(const T *other) const {return m_ref!=other;}
   bool              operator!=(const Ref<T>&other) const {return m_ref!=other.r();}

   T                *r() const {return m_ref;}
  };
//+------------------------------------------------------------------+
//| Wraps a pointer that does not own a resource                     |
//+------------------------------------------------------------------+
template<typename T>
class Ref
  {
private:
   T                *m_ref;
public:
                     Ref(T *raw=NULL):m_ref(raw) {}
                     Ref(const Ptr<T>&other):m_ref(other.r()) {}
                     Ref(const Ref &other):m_ref(other.r()) {}
                    ~Ref() {}

   bool              operator==(const Ref &other) const {return other.m_ref==m_ref;}
   bool              operator==(const Ptr<T>&other) const {return other.r()==m_ref;}
   bool              operator==(const T *other) const {return m_ref==other;}
   bool              operator!=(const Ref &other) const {return other.m_ref!=m_ref;}
   bool              operator!=(const Ptr<T>&other) const {return other.r()!=m_ref;}
   bool              operator!=(const T *other) const {return m_ref!=other;}

   T                *operator=(const Ptr<T>&other)
     {
      m_ref=other.r();
      return m_ref;
     }
   T                *operator=(const Ref &other)
     {
      m_ref=other.r();
      return m_ref;
     }
   T                *operator=(T *other)
     {
      m_ref=other;
      return m_ref;
     }

   T                *r() const {return m_ref;}
  };
//+------------------------------------------------------------------+
//| Generic pointer container                                        |
//+------------------------------------------------------------------+
struct Pointer
  {
   void             *value;
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
template<typename T>
int GetAddress(T *pointer)
  {
   Pointer p;
   p.value=(void*)pointer;
   return ((LargeInt)p).lowPart;
  }
//+------------------------------------------------------------------+
