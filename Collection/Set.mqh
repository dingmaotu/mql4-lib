//+------------------------------------------------------------------+
//| Module: Collection/Set.mqh                                       |
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
//| Simple Set implementation using an array                         |
//+------------------------------------------------------------------+
template<typename T>
class Set: public Collection<T>
  {
private:
   Array<T>m_array;
public:
   // Iterator interface
   Iterator<T>*iterator() const {return new SetIterator<T>(m_array);}
   // for Set initial buffer set to zero
                     Set(int buffer=0):m_array(buffer){}
   // Collection interface
   void              clear() {m_array.clear();}
   int               size() const {return m_array.size();}
   bool              add(T value);
   bool              remove(const T value);

   bool              contains(const T value) {return m_array.index(value)>=0;}
  };
//+------------------------------------------------------------------+
//| Add the element if the element is not in this set                |
//+------------------------------------------------------------------+
template<typename T>
bool Set::add(T value)
  {
   int index=m_array.index(value);
   if(index>=0)
      return false;
   else
     {
      m_array.insertAt(size(),value);
      return true;
     }
  }
//+------------------------------------------------------------------+
//| Remove the element that is equal to value                        |
//+------------------------------------------------------------------+
template<typename T>
bool Set::remove(const T value)
  {
   int index=m_array.index(value);
   if(index>=0)
     {
      m_array.removeAt(index);
      return true;
     }
   else
      return false;
  }
//+------------------------------------------------------------------+
//| Iterator implementation for Set                                  |
//+------------------------------------------------------------------+
template<typename T>
class SetIterator: public Iterator<T>
  {
private:
   int               m_index;
   const int         m_size;
   Array<T>*m_a;
public:
                     SetIterator(const Array<T>&v):m_index(0),m_size(v.size()),m_a((Array<T>*)GetPointer(v)) {}
   bool              end() const {return m_index>=m_size;}
   void              next() {if(!end()){m_index++;}}
   T                 current() const {return m_a[m_index];}
   bool              set(T value) {m_a.set(m_index,value);return true;}
  };
//+------------------------------------------------------------------+
