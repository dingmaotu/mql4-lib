//+------------------------------------------------------------------+
//| Module: Collection/Collection.mqh                                |
//| This file is part of the mql4-lib project:                       |
//|     https://github.com/dingmaotu/mql4-lib                        |
//|                                                                  |
//| Copyright 2016 Li Ding <dingmaotu@126.com>                       |
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

#include "../Lang/Pointer.mqh"
//+------------------------------------------------------------------+
//| Standard Iterator for all collections                            |
//+------------------------------------------------------------------+
template<typename T>
interface Iterator
  {
   void      next();
   T         current() const;
   bool      end() const;
   bool      set(T value);  // replace current value in target collection
  };
//+------------------------------------------------------------------+
//| Do something on each elements of an iterable                     |
//| Returns true if it is needed to delete this element              |
//+------------------------------------------------------------------+
template<typename T>
class ElementOperator
  {
public:
   virtual void      begin() {}
   virtual void      end() {}
   virtual bool      operate(T value)=0;
  };
//+------------------------------------------------------------------+
//| A collection must be iterable                                    |
//+------------------------------------------------------------------+
template<typename T>
interface Iterable
  {
   Iterator<T>*iterator() const;
  };
//+------------------------------------------------------------------+
//| This is the utility class for implementing iterator RAII         |
//| assign and trueForOnce is for implementing foreach               |
//+------------------------------------------------------------------+
template<typename T>
class Iter:public Iterator<T>
  {
private:
   Iterator<T>*m_it;
   int               m_condition;
public:
                     Iter(const Iterable<T>&it):m_it(it.iterator()),m_condition(1) {}
                    ~Iter() {SafeDelete(m_it);}
   void              next() {m_it.next();}
   T                 current() const {return m_it.current();}
   bool              end() const {return m_it.end();}
   bool              set(T value) {return m_it.set(value);}

   bool              testTrue() {if(m_condition==0)return false;else {m_condition--;return true;}}
   bool              assign(T &var) {if(m_it.end()) return false; else {var=m_it.current();return true;}}
  };
#define foreach(Type,Iterable) for(Iter<Type> it(Iterable);!it.end();it.next())
#define foreachv(Type,Var,Iterable) for(Iter<Type> it(Iterable);it.testTrue();) for(Type Var;it.assign(Var);it.next())
//+------------------------------------------------------------------+
//| Base class for collections                                       |
//+------------------------------------------------------------------+
template<typename T>
class Collection: public Iterable<T>
  {
public:
   // remove all elements of the collection
   virtual void      clear()=0;
   // returns true if the collection changed because of adding the value
   virtual bool      add(T value)=0;
   // returns true if the collection changed because of removing the value
   virtual bool      remove(const T value)=0;
   virtual int       size() const=0;

   virtual bool      addAll(T &array[]);
   virtual bool      addAll(const Collection<T>&collection);

   virtual bool      contains(const T value) const;

   virtual bool      isEmpty() const {return size()==0;}

   virtual void      toArray(T &array[]) const;
  };
//+------------------------------------------------------------------+
//| Standard implementation using iterators                          |
//+------------------------------------------------------------------+
template<typename T>
bool Collection::contains(const T value) const
  {
   foreach(T,this)
     {
      if(it.current()==value) return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
//| Standard implementation using add                                |
//+------------------------------------------------------------------+
template<typename T>
bool Collection::addAll(T &array[])
  {
   int s=ArraySize(array);
   bool added=false;
   for(int i=0; i<s; i++)
     {
      bool tmp=add(array[i]);
      if(!added) added=tmp;
     }
   return added;
  }
//+------------------------------------------------------------------+
//| Standard implementation using add                                |
//+------------------------------------------------------------------+
template<typename T>
bool Collection::addAll(const Collection<T>&collection)
  {
   bool added=false;
   foreach(T,collection)
     {
      bool tmp=add(it.current());
      if(!added) added=tmp;
     }
   return added;
  }
//+------------------------------------------------------------------+
//| Standard implementation using iterators                          |
//+------------------------------------------------------------------+
template<typename T>
void Collection::toArray(T &array[]) const
  {
   int s=size();
   if(s>0)
     {
      ArrayResize(array,s);
      Iterator<T>*iter=this.iterator();
      int i=0;
      while(!iter.end())
        {
         array[i]=iter.current();
         iter.next();
         i++;
        }
      delete iter;
     }
  }
//+------------------------------------------------------------------+
