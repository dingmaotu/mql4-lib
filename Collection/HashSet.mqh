//+------------------------------------------------------------------+
//| Module: Collection/HashSet.mqh                                   |
//| This file is part of the mql4-lib project:                       |
//|     https://github.com/dingmaotu/mql4-lib                        |
//|                                                                  |
//| Copyright 2017 Li Ding <dingmaotu@126.com>                       |
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

#include "HashEntries.mqh"
#include "HashSlots.mqh"
#include "Collection.mqh"
//+------------------------------------------------------------------+
//| storage for actual entries                                       |
//+------------------------------------------------------------------+
template<typename Key>
class HashSetEntries: public HashEntriesBase<Key>
  {
private:
   Key               m_keys[];
public:
                     HashSetEntries(int buffer=8):HashEntriesBase<Key>(buffer)
     {
      ArrayResize(m_keys,0,m_buffer);
     }

   Key               getKey(int i) const {return m_keys[i];}

   //--- implmentation needed
   void              onResize(int size,int buffer) { ArrayResize(m_keys,size,buffer); }
   void              onCompactMove(int i,int j) { m_keys[i]=m_keys[j]; }
   void              onRemove(int i) { m_keys[i]=NULL; }

   int               append(Key key)
     {
      int ni=append();
      m_keys[ni]=key;
      return ni;
     }

   void              unremove(int i,Key key)
     {
      unremove(i);
      m_keys[i]=key;
     }
  };
//+------------------------------------------------------------------+
//| Set based on open addressing hash table                          |
//+------------------------------------------------------------------+
template<typename T>
class HashSet: public Collection<T>
  {
private:
   HashSetEntries<T>m_entries;
   HashSlots<T>m_slots;
public:
   //--- `owned` parameter determines if this collection owns its elements 
   //--- (i.e. release their resources in destructor or on removal)
   //--- by default the HashSet do not own its elements
   //--- if the hash elements are pointers and the real owner wants to
   //--- transfer the ownership to this collection, then she need to explicitly `new HashSet(NULL,true)`
                     HashSet(EqualityComparer<T>*comparer=NULL,bool owned=false):Collection<T>(owned,comparer),m_slots(m_comparer,GetPointer(m_entries)) {}
                    ~HashSet()
     {
      if(m_owned)
        {
         int s=m_entries.size();
         for(int i=0; i<s; i++)
           {
            // delete possble pointers
            if(!m_entries.isRemoved(i))
               SafeDelete(m_entries.getKey(i));
           }
        }
     }

   // CosntIterator interface
   ConstIterator<T>*constIterator() const {return new ConstHashSetIterator<T>(GetPointer(m_entries));}

   // Iterator interface
   Iterator<T>*iterator() {return new HashSetIterator<T>(GetPointer(m_entries),GetPointer(m_slots),m_owned);}

   // Collection interface
   int               size() const {return m_entries.getRealSize();}
   bool              contains(const T key) const {return m_slots.contains(key);}

   bool              add(T key);
   bool              remove(const T key);
   void              clear();
  };
//+------------------------------------------------------------------+
//| If the key does not exist and get added, return true             |
//+------------------------------------------------------------------+
template<typename T>
bool HashSet::add(T key)
  {
// we need to make sure that used slots is always smaller than
// certain percentage of total slots (m_htused <= (m_htsize*2)/3)
   m_slots.upsize();
   int i=m_slots.lookup(key);
   int ix=m_slots[i];
   if(ix==-1) m_slots.addSlot(i,m_entries.append(key));
   else if(m_entries.isRemoved(ix)) m_entries.unremove(ix,key);
   else return false;
   return true;
  }
//+------------------------------------------------------------------+
//| If key actually removed returns true                             |
//+------------------------------------------------------------------+
template<typename T>
bool HashSet::remove(const T key)
  {
   int ix=m_slots.lookupIndex(key);
   if(ix==-1) return false;
// empty slot
   if(m_entries.isRemoved(ix)) return false;
   if(m_owned)
     {
      // delete possble pointers
      SafeDelete(m_entries.getKey(ix));
     }
   m_entries.remove(ix);
// if half of the keys is empty, then compact the storage
   if(m_entries.shouldCompact())
     {
      Debug(StringFormat("should compact: real: %d, buffer: %d",m_entries.getRealSize(),m_entries.size()));
      m_entries.compact();
      m_slots.rehash();
     }
   return true;
  }
//+------------------------------------------------------------------+
//| clear all entries and return to initial state                    |
//+------------------------------------------------------------------+
template<typename T>
void HashSet::clear()
  {
   if(m_owned)
     {
      int s=m_entries.size();
      for(int i=0; i<s; i++)
        {
         // delete possble pointers
         if(!m_entries.isRemoved(i))
           {
            SafeDelete(m_entries.getKey(i));
           }
        }
     }
   m_entries.clear();
   m_slots.initState();
  }
//+------------------------------------------------------------------+
//| ConstIterator implementation for HashSet                         |
//+------------------------------------------------------------------+
template<typename T>
class ConstHashSetIterator: public ConstIterator<T>
  {
private:
   // ref to hash set entries
   const             HashSetEntries<T>*m_entries;
   int               m_index;
public:
                     ConstHashSetIterator(const HashSetEntries<T>*entries)
   :m_index(0),m_entries(entries)
     {
      // seek to first non removed entry
      while(!end() && m_entries.isRemoved(m_index)) m_index++;
     }

   bool              end() const {return m_index>=m_entries.size();}
   void              next() {if(!end()) {do{m_index++;}while(!end() && m_entries.isRemoved(m_index));}}
   T                 current() const {return m_entries.getKey(m_index);}
  };
//+------------------------------------------------------------------+
//| Iterator implementation for HashSet                              |
//+------------------------------------------------------------------+
template<typename T>
class HashSetIterator: public Iterator<T>
  {
private:
   // ref to hash set entries
   HashSetEntries<T>*m_entries;
   HashSlots<T>*m_slots;
   int               m_index;
   const bool        m_owned;
public:
                     HashSetIterator(HashSetEntries<T>*entries,HashSlots<T>*slots,bool owned)
   :m_index(0),m_entries(entries),m_slots(slots),m_owned(owned)
     {
      // seek to first non removed entry
      while(!end() && m_entries.isRemoved(m_index)) m_index++;
     }
                    ~HashSetIterator()
     {
      // if half of the keys is empty, then compact the storage
      if(m_entries.shouldCompact())
        {
         Debug(StringFormat("should compact: real: %d, buffer: %d",m_entries.getRealSize(),m_entries.size()));
         m_entries.compact();
         m_slots.rehash();
        }
     }

   bool              end() const {return m_index>=m_entries.size();}
   void              next() {if(!end()) {do{m_index++;}while(!end() && m_entries.isRemoved(m_index));}}
   T                 current() const {return m_entries.getKey(m_index);}

   // you can not set something to a hash entry
   bool              set(T value) {return false;}

   bool              remove()
     {
      // this line is needed in case of repeated call of remove
      if(m_entries.isRemoved(m_index)) return false;
      if(m_owned) SafeDelete(m_entries.getKey(m_index));
      m_entries.remove(m_index);
      return true;
     }
  };
//+------------------------------------------------------------------+
