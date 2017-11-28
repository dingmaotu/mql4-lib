//+------------------------------------------------------------------+
//| Module: Collection/HashEntries.mqh                               |
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
//+------------------------------------------------------------------+
//| Generic storage interface for hash containers' storage           |
//| A removed entry will keep its index in HashSlots, but be marked  |
//| removed here                                                     |
//+------------------------------------------------------------------+
template<typename Key>
interface HashEntries
  {
   int               size() const;
   Key               getKey(int i) const;
   bool              isRemoved(int i) const;

   bool              isCompacted() const;
   bool              shouldCompact() const;
   void              compact();
  };
//+------------------------------------------------------------------+
//| A base class for implementations                                 |
//+------------------------------------------------------------------+
template<typename Key>
class HashEntriesBase: public HashEntries<Key>
  {
protected:
   bool              m_removed[];
   int               m_realSize;
   const int         m_buffer;
public:
                     HashEntriesBase(int buffer=8):m_realSize(0),m_buffer(buffer)
     {
      ArrayResize(m_removed,0,m_buffer);
      //--- you need to initialize your buffer in child class constructor
      // onResize(0,m_buffer);
     }
   int               size() const {return ArraySize(m_removed);}
   bool              isRemoved(int i) const {return m_removed[i];}

   bool              isCompacted() const {return m_realSize==ArraySize(m_removed);}
   bool              shouldCompact() const
     {
      int size=ArraySize(m_removed);
      return size > 8 && m_realSize <= (size>>1);
     }

   void              clear()
     {
      m_realSize=0;
      ArrayResize(m_removed,0,m_buffer);
      onResize(0,m_buffer);
     }

   int               getRealSize() const {return m_realSize;}

   void              remove(int i)
     {
      m_removed[i]=true;
      onRemove(i);
      m_realSize--;
     }

   void              compact()
     {
      int s=ArraySize(m_removed);
      int i=0;
      for(int j=0; j<s; j++)
        {
         if(!m_removed[j])
           {
            if(i!=j)
              {
               m_removed[i]=false;
               onCompactMove(i,j);
              }
            i++;
           }
        }
      if(i<s)
        {
         ArrayResize(m_removed,i,m_buffer);
         onResize(i,m_buffer);
        }
     }

   //--- for adding values to the container, implement your own methods
   //--- the following 2 methods will help the implementation
   int               append()
     {
      int ni=ArraySize(m_removed);
      ArrayResize(m_removed,ni+1,m_buffer);
      onResize(ni+1,m_buffer);
      m_removed[ni]=false;
      m_realSize++;
      return ni;
     }

   void              unremove(int i)
     {
      m_removed[i]=false;
      m_realSize++;
     }

   //--- interface method for HashEntries
   virtual Key       getKey(int i) const=0;

   //--- implmentation needed
   virtual void      onResize(int size,int buffer)=0;
   virtual void      onCompactMove(int i,int j)=0;
   virtual void      onRemove(int i)=0;
  };
//+------------------------------------------------------------------+
