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
#include "HashSlots.mqh"
#include "Collection.mqh"
//+------------------------------------------------------------------+
//| storage for actual entries                                       |
//+------------------------------------------------------------------+
template<typename Key,typename Value>
class HashMapEntries: public HashEntriesBase<Key>
  {
private:
   Key               m_keys[];
   Value             m_values[];
public:
                     HashMapEntries(int buffer=8):HashEntriesBase<Key>(buffer)
     {
      onResize(0,buffer);
     }

   //--- interface method for HashEntries
   Key               getKey(int i) const {return m_keys[i];}

   Value             getValue(int i) const {return m_values[i];}
   void              setValue(int i,Value value) {m_values[i]=value;}

   //--- implmentation needed
   void              onResize(int size,int buffer)
     {
      ArrayResize(m_keys,size,buffer);
      ArrayResize(m_values,size,buffer);
     }
   void              onCompactMove(int i,int j)
     {
      m_keys[i]=m_keys[j];
      m_values[i]=m_values[j];
     }
   void              onRemove(int i)
     {
      m_keys[i]=NULL;
      m_values[i]=NULL;
     }

   int               append(Key key,Value value)
     {
      int ni=append();
      m_keys[ni]=key;
      m_values[ni]=value;
      return ni;
     }

   void              unremove(int i,Key key,Value value)
     {
      unremove(i);
      m_keys[i]=key;
      m_values[i]=value;
     }
  };
template<typename Key,typename Value>
class HashMapIterator;
//+------------------------------------------------------------------+
//| Map implementation based on hash table                           |
//+------------------------------------------------------------------+
template<typename Key,typename Value>
class HashMap: public Map<Key,Value>
  {
private:
   HashMapEntries<Key,Value>m_entries;
   HashSlots<Key>m_slots;
   bool              m_owned;
public:
                     HashMap(EqualityComparer<Key>*comparer=NULL,bool owned=false):m_slots((comparer==NULL)?(new GenericEqualityComparer<Key>()):comparer,GetPointer(m_entries)),m_owned(owned){}
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
     }

   int               size() const {return m_entries.getRealSize();}
   bool              isEmpty() const {return size()==0;}
   bool              remove(Key key);
   void              clear();
   bool              contains(Key key) const {int ix=m_slots.lookupIndex(key);return ix>=0 && !m_entries.isRemoved(ix);}

   MapIterator<Key,Value>*iterator() {return new HashMapIterator<Key,Value>(GetPointer(m_entries),GetPointer(m_slots),m_owned);}

   bool              keys(Collection<Key>&col) const;
   bool              values(Collection<Value>&col) const;

   Value             operator[](Key key) const
     {
      return get(key,NULL);
     }
   Value             get(Key key,Value def) const
     {
      int ix=m_slots.lookupIndex(key);
      if(ix>=0 && !m_entries.isRemoved(ix)) return m_entries.getValue(ix);
      else return def;
     }

   void              set(Key key,Value value);
   bool              setIfExist(Key key,Value value);
   bool              setIfNotExist(Key key,Value value);

   Value             pop(Key key);
  };
//+------------------------------------------------------------------+
//| If key actually removed returns true                             |
//+------------------------------------------------------------------+
template<typename Key,typename Value>
bool HashMap::remove(Key key)
  {
   int ix=m_slots.lookupIndex(key);
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
      Debug(StringFormat("should compact: real: %d, buffer: %d",m_entries.getRealSize(),m_entries.size()));
      m_entries.compact();
      m_slots.rehash();
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
   int ix=m_slots.lookupIndex(key);
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
      Debug(StringFormat("should compact: real: %d, buffer: %d",m_entries.getRealSize(),m_entries.size()));
      m_entries.compact();
      m_slots.rehash();
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
   m_slots.initState();
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
   m_slots.upsize();
   int i=m_slots.lookup(key);
   int ix=m_slots[i];
   if(ix==-1)
     {
      m_slots.addSlot(i,m_entries.append(key,value));
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
   m_slots.upsize();
   int i=m_slots.lookup(key);
   int ix=m_slots[i];
   if(ix==-1)
     {
      m_slots.addSlot(i,m_entries.append(key,value));
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
   m_slots.upsize();
   int ix=m_slots.lookupIndex(key);
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
   HashMapEntries<Key,Value>*m_entries;
   HashSlots<Key>*m_slots;
   bool              m_owned;
   int               m_index;
public:
                     HashMapIterator(HashMapEntries<Key,Value>*entries,HashSlots<Key>*slots,bool owned)
   :m_entries(entries),m_slots(slots),m_owned(owned),m_index(0)
     {
      // seek to first non removed entry
      while(!end() && m_entries.isRemoved(m_index)) m_index++;
     }
                    ~HashMapIterator()
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
   void              next() {if(!end()) {do{m_index++;} while(!end() && m_entries.isRemoved(m_index));}}
   Key               key() const {return m_entries.getKey(m_index);}
   Value             value() const {return m_entries.getValue(m_index);}

   void              setValue(Value v)
     {
      if(m_owned)
        {
         SafeDelete(m_entries.getValue(m_index));
        }
      m_entries.setValue(m_index,v);
     }

   bool              remove()
     {
      // this line is needed in case of repeated call of remove
      if(m_entries.isRemoved(m_index)) return false;
      // delete possble pointers
      SafeDelete(m_entries.getKey(m_index));
      if(m_owned)
        {
         SafeDelete(m_entries.getValue(m_index));
        }
      m_entries.remove(m_index);
      return true;
     }
  };
//+------------------------------------------------------------------+
