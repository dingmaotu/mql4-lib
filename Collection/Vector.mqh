//+------------------------------------------------------------------+
//|                                            Collection/Vector.mqh |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015-2016, Li Ding"
#property link      "dingmaotu@hotmail.com"
#property strict

#include "../Lang/Array.mqh"
#include "Collection.mqh"
//+------------------------------------------------------------------+
//| Generic Vector                                                   |
//+------------------------------------------------------------------+
template<typename T>
class Vector: public Collection<T>
  {
private:
   Array<T>m_array;
public:
                     Vector(int extraBuffer=50):m_array(extraBuffer) {}

   // Iterator interface
   Iterator<T>*iterator() const {return new VectorIterator<T>(this);}

   // Collection interface
   void              clear() {m_array.clear();}
   int               size() const {return m_array.size();}
   bool              add(T value) {push(value); return true;}
   bool              remove(const T value);

   // Sequence interface
   void              insertAt(int i,T val) {m_array.insertAt(i,val);}
   T                 removeAt(int i) {T val=m_array[i];m_array.removeAt(i);return val;}
   T                 get(int i) const {return m_array[i];}
   void              set(int i,T val) {m_array.set(i,val);}
   void              compact() {m_array.compact();}

   // Stack and Queue interface: alias for Sequence interface
   void              push(T val) {insertAt(size(),val);}
   T                 pop() {return removeAt(size()-1);}
   T                 peek() const {return get(size()-1);}
   void              unshift(T val) {insertAt(0,val);}
   T                 shift() {return removeAt(0);}
  };
//+------------------------------------------------------------------+
//| Remove the first element that is equal to value                  |
//+------------------------------------------------------------------+
template<typename T>
bool Vector::remove(const T value)
  {
   int index=m_array.index(value);
   if(index>=0)
     {
      SafeDelete(m_array[index]);
      m_array.removeAt(index);
      return true;
     }
   else
      return false;
  }
//+------------------------------------------------------------------+
//| Iterator implementation for Vector                               |
//+------------------------------------------------------------------+
template<typename T>
class VectorIterator: public Iterator<T>
  {
private:
   int               m_index;
   const int         m_size;
   Vector<T>*m_vector;
public:
                     VectorIterator(const Vector<T>&v):m_index(0),m_size(v.size()),m_vector((Vector<T>*)GetPointer(v)) {}
   bool              end() const {return m_index>=m_size;}
   void              next() {if(!end()){m_index++;}}
   T                 current() const {return m_vector.get(m_index);}
   bool              set(T value) {m_vector.set(m_index,value);return true;}
  };
//+------------------------------------------------------------------+
