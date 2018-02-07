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
#include "List.mqh"
//+------------------------------------------------------------------+
//| Generic Vector                                                   |
//+------------------------------------------------------------------+
template<typename T>
class Vector: public List<T>
  {
private:
   int               m_extraBuffer;
   T                 m_array[];
protected:
   void              resize(int size)
     {
      ArrayResize(m_array,size,m_extraBuffer);
     }
   void              clearArray()
     {
      int s=ArraySize(m_array);
      if(m_owned && s>0)
        {
         for(int i=0;i<s;i++){SafeDelete(m_array[i]);}
        }
     }
public:
                     Vector(bool owned=true,int extraBuffer=10,EqualityComparer<T>*comparer=NULL):List<T>(owned,comparer),m_extraBuffer(extraBuffer)
     {
      resize(0);
     }
                    ~Vector()
     {
      clearArray();
     }

   // ConstIterator interface
   ConstIterator<T>*constIterator() const {return new ConstVectorIterator<T>(GetPointer(this));}
   // Iterator interface
   Iterator<T>*iterator() {return new VectorIterator<T>(GetPointer(this),m_owned);}

   // Vector specific
   void              setExtraBuffer(int value) {m_extraBuffer=value;resize(size());}
   int               getExtraBuffer() const {return m_extraBuffer;}
   int               removeByAscendingIndex(int &removed[])
     {
      if(m_owned)
        {
         for(int i=0; i<ArraySize(removed); i++)
           {
            SafeDelete(m_array[removed[i]]);
           }
        }
      int s=ArraySize(m_array);
      int i=0;
      int k=0;
      for(int j=0; j<s; j++)
        {
         if(k>=ArraySize(removed) || j!=removed[k])
           {
            if(i!=j)
              {
               m_array[i]=m_array[j];
              }
            i++;
           }
         else k++;
        }
      if(i<s)
        {
         ArrayResize(m_array,i,m_extraBuffer);
         return s-i;
        }
      else return 0;
     }

   // Collection interface
   void              clear() {clearArray(); resize(0);}
   int               size() const {return ArraySize(m_array);}
   bool              add(T value) {push(value); return true;}
   bool              remove(const T value)
     {
      int s=ArraySize(m_array);
      int i=0;
      for(int j=0; j<s; j++)
        {
         if(!m_comparer.equals(m_array[j],value))
           {
            if(i!=j) { m_array[i]=m_array[j]; }
            i++;
           }
         // in this case, it is no point to check m_owned and SafeDelete value
        }
      if(i<s) ArrayResize(m_array,i);
      return ((s-i)> 0);
     }

   // Sequence interface
   void              insertAt(int i,T val)
     {
      ArrayInsert(m_array,i,val,m_extraBuffer);
     }
   T                 removeAt(int i)
     {
      T val=m_array[i];
      ArrayDelete(m_array,i);
      return val;
     }
   T                 operator[](int i) const {return m_array[i];}
   T                 get(int i) const {return m_array[i];}
   void              set(int i,T val) {m_array[i]=val;}

   // Stack and Queue interface: alias for Sequence interface
   void              push(T val) {insertAt(size(),val);}
   T                 pop() {return removeAt(size()-1);}
   T                 peek() const {return m_array[size()-1];}
   void              unshift(T val) {insertAt(0,val);}
   T                 shift() {return removeAt(0);}
  };
//+------------------------------------------------------------------+
//| ConstIterator implementation for Vector                          |
//+------------------------------------------------------------------+
template<typename T>
class ConstVectorIterator: public ConstIterator<T>
  {
private:
   int               m_index;
   const int         m_size;
   const             Vector<T>*m_vector;
public:
                     ConstVectorIterator(const Vector<T>*v):m_index(0),m_size(v.size()),m_vector(v) {}
   bool              end() const {return m_index>=m_size;}
   void              next() {if(!end()){m_index++;}}
   T                 current() const {return m_vector[m_index];}
  };
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
   int               m_removed[];
protected:
   bool              removed() const
     {
      int s=ArraySize(m_removed);
      return (s>0 && m_removed[s-1]==m_index);
     }
public:
                     VectorIterator(Vector<T>*v,bool owned):m_index(0),m_size(v.size()),m_vector(v){}
                    ~VectorIterator()
     {
      if(ArraySize(m_removed)>0)
        {
         m_vector.removeByAscendingIndex(m_removed);
        }
     }
   bool              end() const {return m_index>=m_size;}
   void              next() {if(!end()){m_index++;}}
   T                 current() const {if(removed()) return NULL; else return m_vector[m_index];}

   bool              set(T value) {if(removed()) return false; m_vector.set(m_index,value);return true;}
   bool              remove()
     {
      if(end()) return false;
      if(removed()) return false;
      int s=ArraySize(m_removed);
      ArrayResize(m_removed,s+1,5);
      m_removed[s]=m_index;
      return true;
     }
  };
//+------------------------------------------------------------------+
