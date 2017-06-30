//+------------------------------------------------------------------+
//|                                                 Lang/Pointer.mqh |
//|                                          Copyright 2016, Li Ding |
//+------------------------------------------------------------------+
#property strict
//+------------------------------------------------------------------+
//| Generic pointer check                                            |
//+------------------------------------------------------------------+
template<typename T>
bool IsValid(T *pointer)
  {
   return CheckPointer(pointer)!=POINTER_INVALID;
  }
//+------------------------------------------------------------------+
//| Generic safe pointer delete                                      |
//+------------------------------------------------------------------+
template<typename T>
void SafeDelete(T *pointer)
  {
//--- only dynamically created value with `new` should be deleted
//--- automatic pointers from GetPointer (POINTER_AUTOMATIC) should not be deleted
   if(CheckPointer(pointer)==POINTER_DYNAMIC) delete pointer;
  }
//+------------------------------------------------------------------+
//| If pointer is actually a value type                              |
//+------------------------------------------------------------------+
template<typename T>
void SafeDelete(T pointer) {}
//+------------------------------------------------------------------+
//| Ensure dynamic global pointers be deleted after program exit     |
//| In global context, declare the following (p is some pointer):    |
//|     EnsureDelete ensureDeleteSomething(p);                       |
//+------------------------------------------------------------------+
class EnsureDelete
  {
private:
   const void       *m_pointer;
public:
                     EnsureDelete(const void *p):m_pointer(p){}
                    ~EnsureDelete() {if(CheckPointer(m_pointer)==POINTER_DYNAMIC) delete m_pointer;}
  };
//+------------------------------------------------------------------+
//| Get numerical value of a pointer                                 |
//| Mainly used by the Hash function on pointers                     |
//| According to official documentation, MQL4 pointer is a 8 byte    |
//| value, not the actual pointer address of objects.                |
//| But numeric values of different pointers have to be distinct.    |
//+------------------------------------------------------------------+
long GetAddress(void *pointer)
  {
   return long(StringFormat("%I64d",pointer));
  }
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
