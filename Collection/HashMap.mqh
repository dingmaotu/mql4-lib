//+------------------------------------------------------------------+
//| Module: Collection/HashMap.mqh                                   |
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

#include "Map.mqh"
#include "EqualityComparer.mqh" // contains Hash.mqh, which contains Pointer.mqh
#include "Collection.mqh"
//+------------------------------------------------------------------+
//| storage for actual entries                                       |
//+------------------------------------------------------------------+
template<typename Key,typename Value>
class HashMapEntries
  {
private:
   // `m_removed`, `m_keys`, and `m_values` array are of same length
   // to reuse existing storage units, a removed entry will
   // keep its index in `slots`, but mark removed in `m_removed`
   bool              m_removed[];
   Key               m_keys[];
   Value             m_values[];
   int               m_realSize;
   const int         m_buffer;
public:
                     HashMapEntries(int buffer=8):m_realSize(0),m_buffer(buffer)
     {
      ArrayResize(m_removed,0,m_buffer);
      ArrayResize(m_keys,0,m_buffer);
      ArrayResize(m_values,0,m_buffer);
     }
   int               size() const {return ArraySize(m_keys);}

   Key               getKey(int i) const {return m_keys[i];}
   void              setKey(int i,Key key) {m_keys[i]=key;}

   Value             getValue(int i) const {return m_values[i];}
   void              setValue(int i,Value value) {m_values[i]=value;}

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
      ArrayResize(m_keys,0,m_buffer);
      ArrayResize(m_values,0,m_buffer);
     }

   int               getRealSize() const {return m_realSize;}

   int               append(Key key,Value value)
     {
      int ni=ArraySize(m_keys);
      ArrayResize(m_keys,ni+1);
      ArrayResize(m_values,ni+1);
      ArrayResize(m_removed,ni+1);
      m_keys[ni]=key;
      m_values[ni]=value;
      m_removed[ni]=false;
      m_realSize++;
      return ni;
     }
   void              remove(int i)
     {
      m_removed[i]=true;
      m_keys[i]=NULL;
      m_values[i]=NULL;
      m_realSize--;
     }
   void              unremove(int i,Key key,Value value)
     {
      m_removed[i]=false;
      m_keys[i]=key;
      m_values[i]=value;
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
         m_values[i]=m_values[j];
         m_removed[i]=false;
         m_removed[j]=true;
        }
      ArrayResize(m_keys,i,m_buffer);
      ArrayResize(m_values,i,m_buffer);
      ArrayResize(m_removed,i,m_buffer);
     }
  };

template<typename Key,typename Value>
class HashMapIterator;
//+------------------------------------------------------------------+
//| Map implementation based on Python dict (open addressing         |
//| hash table)                                                      |
//+------------------------------------------------------------------+
template<typename Key,typename Value>
class HashMap: public Map<Key,Value>
  {
private:
   EqualityComparer<Key>*m_comparer;
   bool              m_owned;
   // `m_slots` store the indexes of `m_keys` array
   //   1. -1 not used;
   //   2. >=0 normal entries (need check `m_removed` if it is still in use).
   int               m_slots[];

   HashMapEntries<Key,Value>m_entries;

   // this is number of slots (hash table size)
   int               m_htsize;
   // this is used (including removed, thus non -1) number of slots
   int               m_htused;
protected:
   void              initState();
   int               lookup(Key key) const;
   void              rehash();
   void              upsize();
public:
                     HashMap(EqualityComparer<Key>*comparer=NULL,bool owned=false):m_comparer((comparer==NULL)?(new GenericEqualityComparer<Key>()):comparer),m_owned(owned)
     {
      initState();
     }
                    ~HashMap()
     {
      int s=m_entries.size();
      for(int i=0; i<s; i++)
        {
         // delete possble pointers
         if(!m_entries.isRemoved(i))
           {
            SafeDelete(m_entries.getKey(i));
            if(m_owned)
              {
               SafeDelete(m_entries.getValue(i));
              }
           }
        }
      SafeDelete(m_comparer);
     }

   int               size() const {return m_entries.getRealSize();}
   bool              isEmpty() const {return size()==0;}
   bool              remove(Key key);
   void              clear();
   bool              contains(Key key) const {int ix=m_slots[lookup(key)];return ix>=0 && !m_entries.isRemoved(ix);}

   MapIterator<Key,Value>*iterator() const {return new HashMapIterator<Key,Value>(m_entries);}

   bool              keys(Collection<Key>&col) const;
   bool              values(Collection<Value>&col) const;

   Value             operator[](Key key) const
     {
      int ix=m_slots[lookup(key)];
      if(ix>=0 && !m_entries.isRemoved(ix)) return m_entries.getValue(ix);
      else return NULL;
     }

   void              set(Key key,Value value);
   bool              setIfExist(Key key,Value value);
   bool              setIfNotExist(Key key,Value value);

   Value             pop(Key key);
  };
//+------------------------------------------------------------------+
//| restore internal state to initial                                |
//+------------------------------------------------------------------+
template<typename Key,typename Value>
void HashMap::initState()
  {
   m_htsize=8;
   m_htused=0;
   ArrayResize(m_slots,m_htsize);
   ArrayInitialize(m_slots,-1);
  }
//+------------------------------------------------------------------+
//| relocate entries in slots                                        |
//+------------------------------------------------------------------+
template<typename Key,typename Value>
void HashMap::rehash()
  {
   ArrayInitialize(m_slots,-1);
   int size = m_entries.size();
   for(int i=0; i<size && !IsStopped(); i++)
     {
      int si=lookup(m_entries.getKey(i));
      m_slots[si]=i;
     }
  }
//+------------------------------------------------------------------+
//| if used slot is larger than 2/3 of the total slots, then upsize  |
//| to keep performance high                                         |
//+------------------------------------------------------------------+
template<typename Key,typename Value>
void HashMap::upsize()
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
template<typename Key,typename Value>
int HashMap::lookup(Key key) const
  {
   int hash=m_comparer.hash(key);
   int mask=ArraySize(m_slots)-1;
   int freeslot=-1;
   uint perturb=(uint)hash;

/*
#ifdef _DEBUG
   int seekLength=0;
#endif
*/
   uint i=hash&mask;
// assert m_used < m_htsize so that we can exit this loop
   for(;;)
     {
      int ix=m_slots[i];
      // slot is not used: lucky!
      if(ix==-1) break;
      // slot is used but deleted
      else if(m_entries.isRemoved(ix)) freeslot=(int)i;
      else if(m_comparer.equals(m_entries.getKey(ix),key))
        {
         freeslot=-1; break;
        }
      // no valid slot found, probe next entry
      i=((i<<2)+i+perturb+1)&mask;
      perturb>>=5;
/*
#ifdef _DEBUG
      seekLength++;
#endif
*/
     }
/*
#ifdef _DEBUG
   PrintFormat(">>>DEBUG[%s,%d,%s]: seek length: %d",__FILE__,__LINE__,__FUNCTION__,seekLength);
#endif
*/
   return freeslot==-1 ? (int)i : freeslot;
  }
//+------------------------------------------------------------------+
//| If key actually removed returns true                             |
//+------------------------------------------------------------------+
template<typename Key,typename Value>
bool HashMap::remove(Key key)
  {
   int i=lookup(key);
   int ix=m_slots[i];
   if(ix==-1) return false;
// empty slot
   if(m_entries.isRemoved(ix)) return false;
// delete possble pointers
   SafeDelete(m_entries.getKey(ix));
   if(m_owned)
     {
      SafeDelete(m_entries.getValue(ix));
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
//| only for pointers, returns NULL if key does not exist.           |
//| For value types, use remove                                      |
//+------------------------------------------------------------------+
template<typename Key,typename Value>
Value HashMap::pop(Key key)
  {
   Value res=NULL;
   int i=lookup(key);
   int ix=m_slots[i];
   if(ix==-1) return res;
// empty slot
   if(m_entries.isRemoved(ix)) return res;
// delete possble pointers
   SafeDelete(m_entries.getKey(ix));
   res=m_entries.getValue(ix);
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
   return res;
  }
//+------------------------------------------------------------------+
//| clear all entries and return to initial state                    |
//+------------------------------------------------------------------+
template<typename Key,typename Value>
void HashMap::clear()
  {
   int s=m_entries.size();
   for(int i=0; i<s; i++)
     {
      // delete possble pointers
      if(!m_entries.isRemoved(i))
        {
         SafeDelete(m_entries.getKey(i));
         if(m_owned)
           {
            SafeDelete(m_entries.getValue(i));
           }
        }
     }
   m_entries.clear();
   initState();
  }
//+------------------------------------------------------------------+
//| Get all keys                                                     |
//+------------------------------------------------------------------+
template<typename Key,typename Value>
bool HashMap::keys(Collection<Key>&col) const
  {
   bool added=false;
   int size=m_entries.size();
   for(int i=0; i<size; i++)
     {
      if(!m_entries.isRemoved(i))
        {
         col.add(m_entries.getKey(i));
         added=true;
        }
     }
   return added;
  }
//+------------------------------------------------------------------+
//| Get all values                                                   |
//+------------------------------------------------------------------+
template<typename Key,typename Value>
bool HashMap::values(Collection<Value>&col) const
  {
   bool added=false;
   int size=m_entries.size();
   for(int i=0; i<size; i++)
     {
      if(!m_entries.isRemoved(i))
        {
         col.add(m_entries.getValue(i));
         added=true;
        }
     }
   return added;
  }
//+------------------------------------------------------------------+
//| Set key to value. Add key if it does not exist                   |
//+------------------------------------------------------------------+
template<typename Key,typename Value>
void HashMap::set(Key key,Value value)
  {
// we need to make sure that used slots is always smaller than
// certain percentage of total slots (m_htused <= (m_htsize*2)/3)
   upsize();
   int i=lookup(key);
   int ix=m_slots[i];
   if(ix==-1)
     {
      m_slots[i]=m_entries.append(key,value);
      m_htused++;
     }
   else if(m_entries.isRemoved(ix)) m_entries.unremove(ix,key,value);
   else
     {
      if(m_owned)
        {
         SafeDelete(m_entries.getValue(ix));
        }
      m_entries.setValue(ix,value);
     }
  }
//+------------------------------------------------------------------+
//| Set key to value only if key does not exist                      |
//+------------------------------------------------------------------+
template<typename Key,typename Value>
bool HashMap::setIfNotExist(Key key,Value value)
  {
// we need to make sure that used slots is always smaller than
// certain percentage of total slots (m_htused <= (m_htsize*2)/3)
   upsize();
   int i=lookup(key);
   int ix=m_slots[i];
   if(ix==-1)
     {
      m_slots[i]=m_entries.append(key,value);
      m_htused++;
     }
   else if(m_entries.isRemoved(ix)) m_entries.unremove(ix,key,value);
   else
     {
      return false;
     }
   return true;
  }
//+------------------------------------------------------------------+
//| Set key to value only if key exists                              |
//+------------------------------------------------------------------+
template<typename Key,typename Value>
bool HashMap::setIfExist(Key key,Value value)
  {
// we need to make sure that used slots is always smaller than
// certain percentage of total slots (m_htused <= (m_htsize*2)/3)
   upsize();
   int i=lookup(key);
   int ix=m_slots[i];
   if(ix==-1)
     {
      return false;
     }
   else if(m_entries.isRemoved(ix)) return false;
   else
     {
      if(m_owned)
        {
         SafeDelete(m_entries.getValue(ix));
        }
      m_entries.setValue(ix,value);
      return true;
     }
  }
//+------------------------------------------------------------------+
//| Iterator implementation for HashMap                              |
//+------------------------------------------------------------------+
template<typename Key,typename Value>
class HashMapIterator: public MapIterator<Key,Value>
  {
private:
   // ref to hash set entries
   const             HashMapEntries<Key,Value>*m_entries;
   int               m_index;
public:
                     HashMapIterator(const HashMapEntries<Key,Value>&entries)
   :m_index(0),m_entries(GetPointer(entries))
     {
      // seek to first non removed entry
      while(!end() && m_entries.isRemoved(m_index)) m_index++;
     }
   bool              end() const {return m_index>=m_entries.size();}
   void              next() {if(!end()) {do{m_index++;} while(!end() && m_entries.isRemoved(m_index));}}
   Key               key() const {return m_entries.getKey(m_index);}
   Value             value() const {return m_entries.getValue(m_index);}
  };
//+------------------------------------------------------------------+
