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
#include "EqualityComparer.mqh"
//+------------------------------------------------------------------+
//| ConstIterator (readonly) for all collections                     |
//+------------------------------------------------------------------+
template<typename T>
interface ConstIterator
  {
   void      next();
   T         current() const;
   bool      end() const;
  };
//+------------------------------------------------------------------+
//| Standard Iterator for all collections                            |
//+------------------------------------------------------------------+
template<typename T>
interface Iterator: public ConstIterator<T>
  {
   bool      set(T value);  // replace current value in target collection
   bool      remove();      // safely remove current element
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
interface ConstIterable
  {
   ConstIterator<T>*constIterator() const;
  };
//+------------------------------------------------------------------+
//| A collection must be iterable                                    |
//+------------------------------------------------------------------+
template<typename T>
interface Iterable: public ConstIterable<T>
  {
   Iterator<T>*iterator();
  };
//+------------------------------------------------------------------+
//| This is the utility class for implementing iterator RAII         |
//| assign and trueForOnce is for implementing foreach               |
//+------------------------------------------------------------------+
template<typename T>
class ConstIter:public ConstIterator<T>
  {
private:
   ConstIterator<T>*m_it;
   int               m_condition;
public:
                     ConstIter(const ConstIterable<T>&it):m_it(it.constIterator()),m_condition(1) {}
                    ~ConstIter() {SafeDelete(m_it);}
   void              next() {m_it.next();}
   T                 current() const {return m_it.current();}
   bool              end() const {return m_it.end();}

   bool              testTrue() {if(m_condition==0)return false;else {m_condition--;return true;}}
   bool              assign(T &var) {if(m_it.end()) return false; else {var=m_it.current();return true;}}
  };
#define cforeach(Type,Iterable) for(ConstIter<Type> it(Iterable);!it.end();it.next())
#define cforeachv(Type,Var,Iterable) for(ConstIter<Type> it(Iterable);it.testTrue();) for(Type Var;it.assign(Var);it.next())
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
                     Iter(Iterable<T>&it):m_it(it.iterator()),m_condition(1) {}
                    ~Iter() {SafeDelete(m_it);}
   void              next() {m_it.next();}
   T                 current() const {return m_it.current();}
   bool              end() const {return m_it.end();}
   bool              set(T value) {return m_it.set(value);}
   bool              remove() {return m_it.remove();}

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
protected:
   EqualityComparer<T>*m_comparer;
   bool              m_owned;
public:
                     Collection(bool owned,EqualityComparer<T>*comparer):m_owned(owned),m_comparer(comparer==NULL?new GenericEqualityComparer<T>:comparer) {}
                    ~Collection() {SafeDelete(m_comparer);}

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
   cforeach(T,this)
     {
      if(m_comparer.equals(it.current(),value)) return true;
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
   cforeach(T,collection)
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
      ConstIterator<T>*iter=constIterator();
      for(int i=0; !iter.end(); i++,iter.next()) array[i]=iter.current();
      delete iter;
     }
  }
//+------------------------------------------------------------------+
