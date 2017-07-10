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

#include "EqualityComparer.mqh"
#include "Collection.mqh"
//+------------------------------------------------------------------+
//| storage for actual entries                                       |
//+------------------------------------------------------------------+
template<typename Key>
class HashEntries
  {
private:
   // `m_removed` and `m_keys` array are of same length
   // to reuse existing storage units, a removed entry will
   // keep its index in `slots`, but mark removed in `m_removed`
   bool              m_removed[];
   Key               m_keys[];
   int               m_realSize;
   const int         m_buffer;
public:
                     HashEntries(int buffer=8):m_realSize(0),m_buffer(buffer)
     {
      ArrayResize(m_removed,0,m_buffer);
      ArrayResize(m_removed,0,m_buffer);
     }
   int               size() const {return ArraySize(m_keys);}
   Key               get(int i) const {return m_keys[i];}
   void              set(int i,Key value) {m_keys[i]=value;}
   bool              isRemoved(int i) const {return m_removed[i];}

   bool              isCompacted() const {return m_realSize==ArraySize(m_keys);}
   bool              shouldCompact() const
     {
      int size=ArraySize(m_keys);
      return size > 8 && m_realSize <= (size>>1);
     }

   void              clear()
     {
      m_realSize=0;
      ArrayResize(m_removed,0,m_buffer);
      ArrayResize(m_removed,0,m_buffer);
     }

   int               getRealSize() const {return m_realSize;}

   int               append(Key key)
     {
      int ni=ArraySize(m_keys);
      ArrayResize(m_keys,ni+1);
      ArrayResize(m_removed,ni+1);
      m_keys[ni]=key;
      m_removed[ni]=false;
      m_realSize++;
      return ni;
     }
   void              remove(int i)
     {
      m_removed[i]=true;
      m_keys[i]=NULL;
      m_realSize--;
     }
   void              unremove(int i,Key key)
     {
      m_removed[i]=false;
      m_keys[i]=key;
      m_realSize++;
     }
   void              compact()
     {
      //--- assert ArraySize(array) == ArraySize(removed)
      int s=ArraySize(m_keys);
      int i=0,j=1;
      for(; i<s; i++,j++)
        {
         if(!m_removed[i]) continue;
         //--- seek next valid item
         while(j<s && m_removed[j]) {j++;}
         if(j==s) break;
         m_keys[i]=m_keys[j];
         m_removed[i]=false;
         m_removed[j]=true;
        }
      ArrayResize(m_keys,i,m_buffer);
      ArrayResize(m_removed,i,m_buffer);
     }
  };
//+------------------------------------------------------------------+
//| Set based on open addressing hash table                          |
//+------------------------------------------------------------------+
template<typename Key>
class HashSet: public Collection<Key>
  {
private:
   EqualityComparer<Key>*m_comparer;
   bool              m_owned;
   // `m_slots` store the indexes of `m_keys` array
   //   1. -1 not used;
   //   2. >=0 normal entries (need check `m_removed` if it is still in use).
   int               m_slots[];

   HashEntries<Key>m_entries;

   // this is number of slots (hash table size)
   int               m_htsize;
   // this is used (including removed, thus non -1) number of slots
   int               m_htused;

   void              initState();
   int               lookup(Key key) const;
   void              rehash();
   void              upsize();
public:
   //--- `owned` parameter determines if this collection owns its elements 
   //--- (i.e. release their resources in destructor or on removal)
   //--- by default the HashSet do not own its elements
   //--- if the hash elements are pointers and the real owner wants to
   //--- transfer the ownership to this collection, then she need to explicitly `new HashSet(NULL,true)`
                     HashSet(EqualityComparer<Key>*comparer=NULL,bool owned=false)
     {
      m_comparer=(comparer==NULL)?(new GenericEqualityComparer<Key>()):comparer;
      initState();
     }
                    ~HashSet()
     {
      if(m_owned)
        {
         int s=m_entries.size();
         for(int i=0; i<s; i++)
           {
            // delete possble pointers
            if(!m_entries.isRemoved(i))
               SafeDelete(m_entries.get(i));
           }
        }
      SafeDelete(m_comparer);
     }

   // Iterator interface
   Iterator<Key>*iterator() const {return new HashSetIterator<Key>(m_entries);}

   // Collection interface
   int               size() const {return m_entries.getRealSize();}
   bool              contains(const Key key) const {int ix=m_slots[lookup(key)];return ix>=0 && !m_entries.isRemoved(ix);}

   bool              add(Key key);
   bool              remove(const Key key);
   void              clear();
  };
//+------------------------------------------------------------------+
//| restore internal state to initial                                |
//+------------------------------------------------------------------+
template<typename Key>
void HashSet::initState()
  {
   m_htsize=8;
   m_htused=0;
   ArrayResize(m_slots,m_htsize);
   ArrayInitialize(m_slots,-1);
  }
//+------------------------------------------------------------------+
//| relocate entries in slots                                        |
//+------------------------------------------------------------------+
template<typename Key>
void HashSet::rehash()
  {
   ArrayInitialize(m_slots,-1);
   for(int i=0; i<m_entries.size() && !IsStopped(); i++)
     {
      int si=lookup(m_entries.get(i));
      m_slots[si]=i;
     }
  }
//+------------------------------------------------------------------+
//| if used slot is larger than 2/3 of the total slots, then upsize  |
//| to keep performance high                                         |
//+------------------------------------------------------------------+
template<typename Key>
void HashSet::upsize()
  {
   if(m_htused>((m_htsize<<1)/3))
     {
#ifdef _DEBUG
      PrintFormat(">>>DEBUG[%s,%d,%s]: Trigger upsize for hash table size: %d",__FILE__,__LINE__,__FUNCTION__,m_htused);
#endif
      // since we need to relocate entries after slot resize, empty slot must be reclaimed
      if(!m_entries.isCompacted()) m_entries.compact();
      // double slots
      m_htsize<<=1;
      ArrayResize(m_slots,m_htsize);
      rehash();
     }
  }
//+------------------------------------------------------------------+
//| Lookup the slot index for the key                                |
//| Uses the Python dictobject probing algorithm                     |
//+------------------------------------------------------------------+
template<typename Key>
int HashSet::lookup(Key key) const
  {
   int hash=m_comparer.hash(key);
   int mask=ArraySize(m_slots)-1;
   int freeslot=-1;
   uint perturb=(uint)hash;

#ifdef _DEBUG
   int seekLength=0;
#endif
   uint i=hash&mask;
// assert m_used < m_htsize so that we can exit this loop
   for(;;)
     {
      int ix=m_slots[i];
      // slot is not used: lucky!
      if(ix==-1) break;
      // slot is used but deleted
      else if(m_entries.isRemoved(ix)) freeslot=(int)i;
      else if(m_comparer.equals(m_entries.get(ix),key))
        {
         freeslot=-1; break;
        }
      // no valid slot found, probe next entry
      i=((i<<2)+i+perturb+1)&mask;
      perturb>>=5;
#ifdef _DEBUG
      seekLength++;
#endif
     }
#ifdef _DEBUG
   PrintFormat(">>>DEBUG[%s,%d,%s]: seek length: %d",__FILE__,__LINE__,__FUNCTION__,seekLength);
#endif
   return freeslot==-1 ? (int)i : freeslot;
  }
//+------------------------------------------------------------------+
//| If key actually removed returns true                             |
//+------------------------------------------------------------------+
template<typename Key>
bool HashSet::remove(Key key)
  {
   int i=lookup(key);
   int ix=m_slots[i];
   if(ix==-1) return false;
// empty slot
   if(m_entries.isRemoved(ix)) return false;
   if(m_owned)
     {
      // delete possble pointers
      SafeDelete(m_entries.get(ix));
     }
   m_entries.remove(ix);
// if half of the keys is empty, then compact the storage
   if(m_entries.shouldCompact())
     {
#ifdef _DEBUG
      PrintFormat(">>>DEBUG[%s,%d,%s]: should compact: real: %d, buffer: %d",__FILE__,__LINE__,__FUNCTION__,m_entries.getRealSize(),m_entries.size());
#endif
      m_entries.compact();
      rehash();
     }
   return true;
  }
//+------------------------------------------------------------------+
//| clear all entries and return to initial state                    |
//+------------------------------------------------------------------+
template<typename Key>
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
            SafeDelete(m_entries.get(i));
           }
        }
     }
   m_entries.clear();
   initState();
  }
//+------------------------------------------------------------------+
//| If the key does not exist and get added, return true             |
//+------------------------------------------------------------------+
template<typename Key>
bool HashSet::add(Key key)
  {
// we need to make sure that used slots is always smaller than
// certain percentage of total slots (m_htused <= (m_htsize*2)/3)
   upsize();
   int i=lookup(key);
   int ix=m_slots[i];
   if(ix==-1)
     {
      m_slots[i]=m_entries.append(key);
      m_htused++;
     }
   else if(m_entries.isRemoved(ix)) m_entries.unremove(ix,key);
   else return false;
   return true;
  }
//+------------------------------------------------------------------+
//| Iterator implementation for HashSet                              |
//+------------------------------------------------------------------+
template<typename T>
class HashSetIterator: public Iterator<T>
  {
private:
   // ref to hash set entries
   const             HashEntries<T>*m_entries;
   int               m_index;
public:
                     HashSetIterator(const HashEntries<T>&entries)
   :m_index(0),m_entries(GetPointer(entries)) {}
   bool              end() const {return m_index>=m_entries.size();}
   void              next() {if(!end()) {do{m_index++;}while(!end() && m_entries.isRemoved(m_index));}}
   T                 current() const {return m_entries.get(m_index);}

   // you can not set something to a hash entry
   bool              set(T value) {return false;}
  };
//+------------------------------------------------------------------+
