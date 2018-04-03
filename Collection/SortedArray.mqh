//+------------------------------------------------------------------+
//| Module: Collection/SortedArray.mqh                               |
//| This file is part of the mql4-lib project:                       |
//|     https://github.com/dingmaotu/mql4-lib                        |
//|                                                                  |
//| Copyright 2015-2016 Li Ding <dingmaotu@126.com>                  |
//| Copyright 2018 Yerden Zhumabekov <yerden.zhumabekov@gmail.com    |
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
#include "SortComparer.mqh"
#include "Collection.mqh"
//+------------------------------------------------------------------+
//| Simple Array-based implementation of sorted sets                 |
//+------------------------------------------------------------------+
template<typename T>
class SortedArray: public Collection<T>
  {
private:
   SortComparer<T>*m_sorter;
   Array<T>m_array;
   bool              m_unique;
   bool              bsearch(const T value,int &id) const;
public:
   // owned: flag restricts destructor to delete array elements
   // unique: flag allows add()-ing of identical elements
   // sorter: array sorting implementation
                     SortedArray(SortComparer<T>*sorter,bool owned=true,bool unique=true):
                                                              Collection(owned,sorter),
   m_unique(unique),
   m_sorter(sorter){}
                    ~SortedArray() {clear();}

   // ConstIterator interface
   ConstIterator<T>*constIterator() const {return new ConstSortedArrayIterator<T>(GetPointer(this));}
   // Iterator interface
   Iterator<T>*iterator() {return new SortedArrayIterator<T>(GetPointer(this),m_owned);}

   // Collection interface
   void              clear() {if(m_owned) m_array.clear(); else m_array.resize(0);}
   bool              add(T value);
   bool              remove(const T value);
   int               size() const {return m_array.size();}
   bool              contains(const T value) const {return index(value)>=0;}

   // SortedArray specific
   T                 operator[](const int index) const {return m_array[index];}
   // return index of a matched element, or <0 if not contained
   int               index(const T value) const {int id=0;return bsearch(value,id)?id:-1;}
   int               removeIndices(const int &removed[])
     {
      if(m_owned)
         for(int i=0; i<ArraySize(removed); i++)
            SafeDelete(m_array[removed[i]]);
      return m_array.removeBatch(removed);
     }
  };
//+------------------------------------------------------------------+
//| Find value in set. Return true if found.                         |
//| Set &id to element index if found or the appropriate             |
//| position for insertion.                                          |
//+------------------------------------------------------------------+
template<typename T>
bool SortedArray::bsearch(const T value,int &id) const
  {
   int cmp=1,l=0,u=m_array.size();

   while(l<u)
     {
      int idx=l+(u-l)/2;
      cmp=m_sorter.compare(value,m_array[idx]);
      if(cmp<0) u=idx;
      else if(cmp>0) l=idx+1;
      else u=l=idx;
     }

   id=u;
   return cmp==0;
  }
//+------------------------------------------------------------------+
//| Add value to sorted array                                        |
//+------------------------------------------------------------------+
template<typename T>
bool SortedArray::add(T value)
  {
   int id;
   bool res=!bsearch(value,id);
   res=res || !m_unique;
   if(res) m_array.insertAt(id,value);
   return res;
  }
//+------------------------------------------------------------------+
//| Remove value from sorted array                                   |
//+------------------------------------------------------------------+
template<typename T>
bool SortedArray::remove(const T value)
  {
   int id;
   if(!bsearch(value,id))
      return false;
   T ovalue=m_array[id];
   m_array.removeAt(id);
   if(m_owned) SafeDelete(ovalue);
   return true;
  }
//+------------------------------------------------------------------+
//| ConstIterator implementation for SortedArray                     |
//+------------------------------------------------------------------+
template<typename T>
class ConstSortedArrayIterator: public ConstIterator<T>
  {
private:
   int               m_index;
   const int         m_size;
   const             SortedArray<T>*m_sortedarray;
public:
                     ConstSortedArrayIterator(const SortedArray<T>*v):m_index(0),m_size(v.size()),m_sortedarray(v) {}
   bool              end() const {return m_index>=m_size;}
   void              next() {if(!end()){m_index++;}}
   T                 current() const {return m_sortedarray[m_index];}
  };
//+------------------------------------------------------------------+
//| Iterator implementation for SortedArray                          |
//+------------------------------------------------------------------+
template<typename T>
class SortedArrayIterator: public Iterator<T>
  {
private:
   int               m_index;
   const int         m_size;
   SortedArray<T>*m_sortedarray;
   int               m_removed[];
protected:
   bool              removed() const
     {
      int s=ArraySize(m_removed);
      return (s>0 && m_removed[s-1]==m_index);
     }
public:
                     SortedArrayIterator(SortedArray<T>*v,bool owned):m_index(0),m_size(v.size()),m_sortedarray(v){}
                    ~SortedArrayIterator() {if(ArraySize(m_removed)>0) m_sortedarray.removeIndices(m_removed);}
   bool              end() const {return m_index>=m_size;}
   void              next() {if(!end()){m_index++;}}
   T                 current() const {if(removed()) return NULL; else return m_sortedarray[m_index];}

   bool              set(T value) {return false;} // unapplicable
   bool              remove()
     {
      if(end()||removed()) return false;
      int s=ArraySize(m_removed);
      ArrayResize(m_removed,s+1,5);
      m_removed[s]=m_index;
      return true;
     }
  };
//+------------------------------------------------------------------+
