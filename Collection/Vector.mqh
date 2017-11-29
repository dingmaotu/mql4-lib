//+------------------------------------------------------------------+
//| Module: Collection/Vector.mqh                                    |
//| This file is part of the mql4-lib project:                       |
//|     https://github.com/dingmaotu/mql4-lib                        |
//|                                                                  |
//| Copyright 2015-2016 Li Ding <dingmaotu@126.com>                  |
//|                                                                  |
//| Licensed under the Apache License, Version 2.0 (the "License");  |
//| you may not use this file except in compliance with the License. |
//| You may obtain a copy of the License at                          |
//|                                                                  |
//|     http://www.apache.org/licenses/LICENSE-2.0                   |
//|                                                                  |
//| Unless required by applicable law or agreed to in writing,       |
//| software distributed under the License is distributed on an      |
//| "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,     |
//| either express or implied.                                       |
//| See the License for the specific language governing permissions  |
//| and limitations under the License.                               |
//+------------------------------------------------------------------+
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
   int               removeAll(const T value) {return m_array.removeAll(value);}

   // Sequence interface
   void              insertAt(int i,T val) {m_array.insertAt(i,val);}
   T                 removeAt(int i) {T val=m_array[i];m_array.removeAt(i);return val;}
   T                 get(int i) const {return m_array[i];}
   void              set(int i,T val) {m_array.set(i,val);}

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
