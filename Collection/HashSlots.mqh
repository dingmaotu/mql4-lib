//+------------------------------------------------------------------+
//| Module: Collection/HashSlots.mqh                                 |
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

#include "../Lang/Mql.mqh"
#include "EqualityComparer.mqh" // contains Hash.mqh, which contains Pointer.mqh
#include "HashEntries.mqh"
//+------------------------------------------------------------------+
//| Generic hash mapping implementation based on Python dict (open   |
//| addressing hash table)                                           |
//+------------------------------------------------------------------+
template<typename Key>
class HashSlots
  {
private:
   // this is number of slots (hash table size)
   int               m_htsize;
   // this is used (including removed, thus non -1) number of slots
   int               m_htused;
   // `m_slots` store the indexes of target array
   //   1. -1 not used;
   //   2. >=0 normal entries (need check `m_entries.isRemoved(ix)` if it is still in use).
   int               m_slots[];

   EqualityComparer<Key>*m_comparer;
   HashEntries<Key>*m_entries;
public:
                     HashSlots(EqualityComparer<Key>*comparer,HashEntries<Key>*entries)
   :m_comparer(comparer),m_entries(entries)
     {
      initState();
     }
                    ~HashSlots() { SafeDelete(m_comparer); }

   void              initState();
   int               lookup(const Key key) const;
   void              rehash();
   void              upsize();

   void              addSlot(int i,int ix)
     {
      m_slots[i]=ix;
      m_htused++;
     }

   int               operator[](int i) const {return m_slots[i];}

   int               lookupIndex(const Key key) const {return m_slots[lookup(key)];}
   bool              contains(const Key key) const {int ix=lookupIndex(key);return ix>=0 && !m_entries.isRemoved(ix);}
  };
//+------------------------------------------------------------------+
//| restore internal state to initial                                |
//+------------------------------------------------------------------+
template<typename Key>
void HashSlots::initState()
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
void HashSlots::rehash()
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
template<typename Key>
void HashSlots::upsize()
  {
   if(m_htused>((m_htsize<<1)/3))
     {
      Debug(StringFormat("trigger upsize for hash table size: %d",m_htused));
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
int HashSlots::lookup(const Key key) const
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
   PrintFormat(">>> DEBUG[%s,%d,%s]: seek length: %d",__FILE__,__LINE__,__FUNCTION__,seekLength);
#endif
*/
   return freeslot==-1 ? (int)i : freeslot;
  }
//+------------------------------------------------------------------+
