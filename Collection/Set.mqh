//+------------------------------------------------------------------+
//| Module: Collection/Set.mqh                                       |
//| This file is part of the mql4-lib project:                       |
//|     https://github.com/dingmaotu/mql4-lib                        |
//|                                                                  |
//| Copyright 2015-2018 Li Ding <dingmaotu@126.com>                  |
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

#include "Collection.mqh"
//+------------------------------------------------------------------+
//| The Set interface                                                |
//| A set does not allow duplicates                                  |
//+------------------------------------------------------------------+
template<typename T>
class Set: public Collection<T>
  {
public:
                     Set(bool owned,EqualityComparer<T>*comparer):Collection<T>(owned,comparer){}

   virtual bool      setByIntersection(const Collection<T>&left,const Collection<T>&right)
     {
      if(!isEmpty())
        {
         clear();
        }

      for(ConstIter<T>it(left); !it.end(); it.next())
        {
         T value=it.current();
         if(right.contains(value))
            // Notice if elements of left or right are owned by their container and they are pointers
            // and this Set is also owned,
            // you should deal with the owning problem on your own
            add(it.current());
        }
      return size() > 0;
     }

   virtual bool      setByUnion(const Collection<T>&left,const Collection<T>&right)
     {
      if(!isEmpty())
        {
         clear();
        }
      for(ConstIter<T>it(left); !it.end(); it.next())
        {
         add(it.current());
        }

      for(ConstIter<T>it(right); !it.end(); it.next())
        {
         add(it.current());
        }
      return size() > 0;
     }

   virtual bool      setByComplement(const Collection<T>&left,const Collection<T>&right)
     {
      if(!isEmpty())
        {
         clear();
        }

      if(left.isEmpty()) return false;

      for(ConstIter<T>it(left); !it.end(); it.next())
        {
         T value=it.current();
         if(!right.contains(value))
            add(it.current());
        }

      return size() > 0;
     }
  };
//+------------------------------------------------------------------+
