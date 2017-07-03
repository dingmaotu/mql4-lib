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
#include "../Lang/Array.mqh"

template<typename Key,typename Value>
class HashMapIterator;
//+------------------------------------------------------------------+
//| Hash map implementation                                          |
//| reference Python dict implementation with probing and open       |
//| addressing                                                       |
//+------------------------------------------------------------------+
template<typename Key,typename Value>
class HashMap: public Map<Key,Value>
  {
private:
   EqualityComparer<Key>*m_comparer;
   // following array store the indexes
   int               m_slots[];
   // following three arrays store the actual entries
   int               m_hashes[];
   Key               m_keys[];
   Value             m_values[];
   // removal mark
   bool              m_removed[];
   // this is the current capacity (m_slots)
   int               m_cap;
   // this is the current used storage units (m_hashes, m_keys, m_values)
   int               m_storage;
   // this is the valid entries (non-NULL entries)
   int               m_size;
protected:
   void              initState();
   void              clearEntry(int i);
   int               compactStorage(); // return storage size after compact
   int               lookup(int hash) const;
   int               lookupKey(Key key) const {return lookup(m_comparer.hash(key));}
   void              upsize();
public:
                     HashMap(EqualityComparer<Key>*comparer=NULL);
                    ~HashMap();

   //--- for iteration purpose: internal use only
   int               __storage__() const {return m_storage;}
   Key               __key__(int i) const {return m_keys[i];}
   Value             __value__(int i) const {return m_values[i];}
   bool              __removed__(int i) const {return m_removed[i];}

   int               size() const {return m_size;}
   bool              isEmpty() const {return m_size==0;}
   bool              remove(Key key);
   void              clear();
   bool              contains(Key key) const {int i=lookupKey(key);return m_slots[i]!=-1 && !m_removed[m_slots[i]];}

   MapIterator<Key,Value>*iterator() const {return new HashMapIterator<Key,Value>(GetPointer(this));}

   bool              keys(Collection<Key>&col) const;
   bool              values(Collection<Value>&col) const;

   Value             operator[](Key key) const {int i=m_slots[lookupKey(key)]; return i!=-1?m_values[i]:NULL;}
   void              set(Key key,Value value);
   bool              setDefault(Key key,Value value);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
template<typename Key,typename Value>
void HashMap::initState()
  {
   m_cap=8;
   m_storage=0;
   m_size=0;
   ArrayResize(m_slots,m_cap);
   ArrayInitialize(m_slots,-1);
   ArrayResize(m_hashes,0,m_cap);
   ArrayResize(m_keys,0,m_cap);
   ArrayResize(m_values,0,m_cap);
   ArrayResize(m_removed,0,m_cap);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
template<typename Key,typename Value>
void HashMap::clearEntry(int i)
  {
   if(!m_removed[i])
     {
      // delete possble pointers
      SafeDelete(m_keys[i]);
      SafeDelete(m_values[i]);

      // mark entry as removed
      m_removed[i]=true;

      // update size
      --m_size;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
template<typename Key,typename Value>
int HashMap::compactStorage()
  {
   int i=0;
   for(; i<m_storage; i++)
     {
      if(!m_removed[i]) continue;
      int j=i+1;
      while(j<m_storage && m_removed[j]) j++;
      if(j==m_storage) break;
      m_hashes[i]=m_hashes[j];
      m_keys[i]=m_keys[j];
      m_values[i]=m_values[j];
      m_removed[i]=m_removed[j];
      m_removed[j]=true;
     }
   ArrayResize(m_hashes,i);
   ArrayResize(m_keys,i);
   ArrayResize(m_values,i);
   ArrayResize(m_removed,i);
   return i;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
template<typename Key,typename Value>
void HashMap::upsize()
  {
   if(m_storage<m_cap) return;

// first attempt to compact current storage
   if(m_size<m_storage)
     {
      m_size=m_storage=compactStorage();
     }
   else
     {
      // increase capacity
      m_cap<<=1;
      ArrayResize(m_slots,m_cap);
     }
// relocate entries
   ArrayInitialize(m_slots,-1);
   for(int i=0; i<m_storage && !IsStopped(); i++)
     {
      int si=lookup(m_hashes[i]);
      m_slots[si]=i;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
template<typename Key,typename Value>
HashMap::HashMap(EqualityComparer<Key>*comparer)
  {
   m_comparer=(comparer==NULL)?(new GenericEqualityComparer<Key>()):comparer;
   initState();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
template<typename Key,typename Value>
HashMap::~HashMap()
  {
   for(int i=0; i<m_storage; i++)
     {
      clearEntry(i);
     }
   SafeDelete(m_comparer);
  }
//+------------------------------------------------------------------+
//| Lookup the index in entries for the key                          |
//| If found, return the index, or return the next empty slot        |
//+------------------------------------------------------------------+
template<typename Key,typename Value>
int HashMap::lookup(int hash) const
  {
   int i=hash&(m_cap-1);
   if(m_slots[i]==-1 || m_hashes[m_slots[i]]==hash)
      return i;
   else
     {
      // probe next entry
      // ensure m_size < m_cap
      for(uint perturb=(uint)hash;;perturb>>=5)
        {
         i=(int)((i<<2)+i+perturb+1);
         i&=(m_cap-1);
         if(m_slots[i]==-1 || m_hashes[m_slots[i]]==hash)
            return i;
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
template<typename Key,typename Value>
bool HashMap::remove(Key key)
  {
   int si=lookupKey(key);
   int i=m_slots[si];
   if(i==-1) return false;
   clearEntry(i);
   return true;
  }
//+------------------------------------------------------------------+
//| clear all entries and return to initial state                    |
//+------------------------------------------------------------------+
template<typename Key,typename Value>
void HashMap::clear()
  {
   for(int i=0; i<m_storage; i++)
     {
      clearEntry(i);
     }
   initState();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
template<typename Key,typename Value>
bool HashMap::keys(Collection<Key>&col) const
  {
   bool added=false;
   for(int i=0; i<m_storage; i++)
     {
      if(!m_removed[i])
        {
         col.add(m_keys[i]);
         added=true;
        }
     }
   return added;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
template<typename Key,typename Value>
bool HashMap::values(Collection<Value>&col) const
  {
   bool added=false;
   for(int i=0; i<m_storage; i++)
     {
      if(!m_removed[i])
        {
         col.add(m_values[i]);
         added=true;
        }
     }
   return added;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
template<typename Key,typename Value>
void HashMap::set(Key key,Value value)
  {
   int hash=m_comparer.hash(key);
   int si=lookup(hash);
   int ri=m_slots[si];
   if(ri==-1)
     {
      m_slots[si]=m_storage;
      ArrayResize(m_hashes,m_storage+1);
      ArrayResize(m_keys,m_storage+1);
      ArrayResize(m_values,m_storage+1);
      ArrayResize(m_removed,m_storage+1);
      m_hashes[m_storage]=hash;
      m_keys[m_storage]=key;
      m_values[m_storage]=value;
      m_removed[m_storage]=false;
      m_storage++;
      m_size++;
      // we need to ensure that m_storage is always smaller than capacity
      upsize();
     }
   else if(m_removed[ri])
     {
      m_removed[ri]=false;
      m_keys[ri]=key;
      m_values[ri]=value;
      m_size++;
     }
   else
     {
      m_values[m_slots[si]]=value;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
template<typename Key,typename Value>
bool HashMap::setDefault(Key key,Value value)
  {
   int hash=m_comparer.hash(key);
   int si=lookup(hash);
   int ri=m_slots[si];
   if(ri==-1)
     {
      m_slots[si]=m_storage;
      ArrayResize(m_hashes,m_storage+1);
      ArrayResize(m_keys,m_storage+1);
      ArrayResize(m_values,m_storage+1);
      ArrayResize(m_removed,m_storage+1);
      m_hashes[m_storage]=hash;
      m_keys[m_storage]=key;
      m_values[m_storage]=value;
      m_removed[m_storage]=false;
      m_storage++;
      m_size++;
      // we need to ensure that m_storage is always smaller than capacity
      upsize();
      return true;
     }
   else if(m_removed[ri])
     {
      m_removed[ri]=false;
      m_keys[ri]=key;
      m_values[ri]=value;
      m_size++;
      return true;
     }
   else
     {
      return false;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
template<typename Key,typename Value>
class HashMapIterator: public MapIterator<Key,Value>
  {
private:
   const             HashMap<Key,Value>*m_map;
   int               m_current;
   int               m_total;
public:
                     HashMapIterator(const HashMap<Key,Value>*map):m_map(map),m_current(0),m_total(map.__storage__())
     {
      while((m_current<m_total) && m_map.__removed__(m_current))
        {
         m_current++;
        }
     }

   Key               key() const {return m_map.__key__(m_current);}
   Value             value() const {return m_map.__value__(m_current);}
   void              next()
     {
      do
        {
         m_current++;
        }
      while((m_current<m_total) && (m_map.__removed__(m_current)));
     }
   bool              end() const {return m_current==m_total;}
  };
//+------------------------------------------------------------------+
