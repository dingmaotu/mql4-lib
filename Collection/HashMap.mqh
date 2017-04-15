//+------------------------------------------------------------------+
//|                                                      HashMap.mqh |
//|                  Copyright 2017, Bear Two Technologies Co., Ltd. |
//+------------------------------------------------------------------+
#property strict

#include "Map.mqh"
#include "../Lang/Pointer.mqh"
#include "../Lang/Hash.mqh"
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
   // this is the current capacity (m_slots)
   int               m_cap;
   // this is the current used storage units (m_hashes, m_keys, m_values)
   int               m_storage;
   // this is the valid entries (non-NULL entries)
   int               m_size;
protected:
   void              initState();
   void              clearEntry(int i);
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

   int               size() const {return m_size;}
   bool              isEmpty() const {return m_size==0;}
   bool              remove(Key key);
   void              clear();
   bool              contains(Key key) const {return m_slots[lookupKey(key)]!=-1;}

   MapIterator<Key,Value>*iterator() const {return new HashMapIterator<Key,Value>(GetPointer(this));}

   bool              keys(Collection<Key>&col) const;
   bool              values(Collection<Value>&col) const;

   Value             operator[](Key key) const {int i=m_slots[lookupKey(key)]; return i!=-1?m_values[i]:NULL;}
   void              set(Key key,Value value);
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
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
template<typename Key,typename Value>
void HashMap::clearEntry(int i)
  {
   if(m_hashes[i]!=NULL)
     {
      // delete possble pointers
      SafeDelete(m_keys[i]);
      SafeDelete(m_values[i]);

      // mark entry as NULL
      m_hashes[i]=NULL;
      m_keys[i]=NULL;
      m_values[i]=NULL;

      // update size
      --m_size;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
template<typename Key,typename Value>
void HashMap::upsize()
  {
   m_cap<<=1;
   ArrayResize(m_slots,m_cap);
   ArrayInitialize(m_slots,-1);
// possible compact
   if(m_size<m_storage)
     {
      ArrayCompact(m_hashes);
      ArrayCompact(m_keys);
      ArrayCompact(m_values);
      m_size=m_storage=ArraySize(m_hashes);
     }
// relocate entries
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
// empty slot
   m_slots[si]=-1;
// clear entry
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
      if(m_keys[i]!=NULL)
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
      if(m_values[i]!=NULL)
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
   if(m_slots[si]==-1)
     {
      m_slots[si]=m_storage;
      ArrayResize(m_hashes,m_storage+1);
      ArrayResize(m_keys,m_storage+1);
      ArrayResize(m_values,m_storage+1);
      m_hashes[m_storage]=hash;
      m_keys[m_storage]=key;
      m_values[m_storage]=value;
      m_storage++;
      m_size++;
      // we need to ensure that size is always smaller than capacity
      if(m_size==m_cap)
        {
         upsize();
        }
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
class HashMapIterator: public MapIterator<Key,Value>
  {
private:
   const             HashMap<Key,Value>*m_map;
   int               m_current;
   int               m_total;
public:
                     HashMapIterator(const HashMap<Key,Value>*map):m_map(map),m_current(0),m_total(map.__storage__())
     {
      while((m_current<m_total) && (m_map.__key__(m_current)==NULL))
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
      while((m_current<m_total) && (m_map.__key__(m_current)==NULL));
     }
   bool              end() const {return m_current==m_total;}
  };
//+------------------------------------------------------------------+
