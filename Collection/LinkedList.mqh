//+------------------------------------------------------------------+
//| Module: Collection/LinkedList.mqh                                |
//| This file is part of the mql4-lib project:                       |
//|     https://github.com/dingmaotu/mql4-lib                        |
//|                                                                  |
//| Copyright 2015-2016 Li Ding <dingmaotu@126.com>                  |
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
#include "List.mqh"
//+------------------------------------------------------------------+
//| LinkedNode implementation as a base class for specific           |
//| node types.                                                      |
//+------------------------------------------------------------------+
template<typename T>
class LinkedNode
  {
private:
   LinkedNode       *m_prev;
   LinkedNode       *m_next;
   T                 m_data;

public:
                     LinkedNode(T data):m_prev(NULL),m_next(NULL),m_data(data){}
   virtual          ~LinkedNode(){SafeDelete(m_data);}

   LinkedNode       *prev() const {return m_prev;}
   void              prev(LinkedNode *node) {m_prev=node;}
   LinkedNode       *next() const {return m_next;}
   void              next(LinkedNode *node) {m_next=node;}

   T                 get() {return m_data;}
   void              set(T data) {m_data=data;}

   T                 release() {T tmp=m_data; m_data=NULL; return tmp;}
  };
//+------------------------------------------------------------------+
//| LinkedList implementation as a base class for specific           |
//| collections.                                                     |
//+------------------------------------------------------------------+
template<typename T>
class LinkedListBase
  {
public:
   bool              m_owned;
   LinkedNode<T>*m_head;
   LinkedNode<T>*m_tail;
   int               m_size;

   void              detach(LinkedNode<T>*node);
   void              insert(LinkedNode<T>*ref,LinkedNode<T>*node);
   LinkedNode<T>*last() const;
   LinkedNode<T>*at(int i) const;
   bool              inRange(int i) const {return i>=0 && i<m_size;}

   T                 getAndDetach(LinkedNode<T>*n){if(n==m_tail){return NULL;}T o=n.release();detach(n);return o;}

                     LinkedListBase(bool owned):m_owned(owned),m_size(0),m_head(new LinkedNode<T>(NULL)),m_tail(new LinkedNode<T>(NULL))
     {
      m_head.next(m_tail);
      m_tail.prev(m_head);
     }
                    ~LinkedListBase();
  };
//+------------------------------------------------------------------+
//| release all memory used by the list                              |
//+------------------------------------------------------------------+
template<typename T>
LinkedListBase::~LinkedListBase()
  {
   if(m_owned)
     {
      LinkedNode<T>*n=m_head.next();
      while(n!=m_tail)
        {
         LinkedNode<T>*tempNode=n.next();
         SafeDelete(n);
         n=tempNode;
        }
     }
   SafeDelete(m_head);
   SafeDelete(m_tail);
  }
//+------------------------------------------------------------------+
//| detach node from list                                            |
//+------------------------------------------------------------------+
template<typename T>
void LinkedListBase::detach(LinkedNode<T>*node)
  {
   if(CheckPointer(node) != POINTER_DYNAMIC) return;
   if(node==m_tail) return;
   node.prev().next(node.next());
   node.next().prev(node.prev());
   SafeDelete(node);
   m_size--;
  }
//+------------------------------------------------------------------+
//| insert a node before ref node                                    |
//+------------------------------------------------------------------+
template<typename T>
void LinkedListBase::insert(LinkedNode<T>*ref,LinkedNode<T>*node)
  {
   if(CheckPointer(node) != POINTER_DYNAMIC) return;

   node.next(ref);
   node.prev(ref.prev());

   ref.prev(node);
   node.prev().next(node);

   m_size++;
  }
//+------------------------------------------------------------------+
//| last node of the list                                            |
//+------------------------------------------------------------------+
template<typename T>
LinkedNode<T>*LinkedListBase::last() const
  {
   LinkedNode<T>*node=m_tail.prev();
   return (node == m_head) ? NULL : node;
  }
//+------------------------------------------------------------------+
//| ith node                                                         |
//| always return a valid node for insersion                         |
//| i.e. if i<0, then return m_head.next(); if i>=m_size, return     |
//| m_tail                                                           |
//+------------------------------------------------------------------+
template<typename T>
LinkedNode<T>*LinkedListBase::at(int i) const
  {
   int j=0;
   LinkedNode<T>*node=m_head.next();
   while(node!=m_tail && j<i) {node=node.next(); j++;}
   return node;
  }
//+------------------------------------------------------------------+
//| LinkedList implementation as a base class for specific           |
//| collections.                                                     |
//+------------------------------------------------------------------+
template<typename T>
class LinkedList: public List<T>
  {
private:
   LinkedListBase<T>m_base;
public:
                     LinkedList(bool owned=true,EqualityComparer<T>*comparer=NULL):List<T>(owned,comparer),m_base(owned) {}

   ConstIterator<T>*constIterator() const {return new ConstListIterator<T>(m_base.m_head,m_base.m_tail);}
   Iterator<T>*iterator() {return new ListIterator<T>(GetPointer(m_base));}

   int               size() const {return m_base.m_size;}
   void              clear();
   // returns true if the collection changed because of adding the value
   bool              add(T value) {push(value); return true;}
   // returns true if the collection changed because of removing the value
   bool              remove(const T value);

   // Sequence interface
   T                 get(int i) const {LinkedNode<T>*on=m_base.at(i);return on==m_base.m_tail?NULL:on.get();}
   void              set(int i,T o) {LinkedNode<T>*on=m_base.at(i);if(on!=m_base.m_tail){on.set(o);}}
   void              insertAt(int i,T o) {m_base.insert(m_base.at(i),new LinkedNode<T>(o));}
   T                 removeAt(int i) {return m_base.getAndDetach(m_base.at(i));}

   // Stack and Queue interface
   void              push(T o) {m_base.insert(m_base.m_tail,new LinkedNode<T>(o));}
   T                 pop() {LinkedNode<T>*n=m_base.last(); return n==NULL?NULL:m_base.getAndDetach(n);}
   T                 peek() const {LinkedNode<T>*n=m_base.last(); return n==NULL?NULL:n.get();}
   void              unshift(T o) {m_base.insert(m_base.m_head.next(),new LinkedNode<T>(o));}
   T                 shift() {LinkedNode<T>*n=m_base.m_head.next(); return m_base.getAndDetach(n);}
  };
//+------------------------------------------------------------------+
//| Remove all elements of the LinkedList                            |
//+------------------------------------------------------------------+
template<typename T>
LinkedList::clear(void)
  {
   LinkedNode<T>*node=m_base.m_head.next();
   while(node!=m_base.m_tail)
     {
      LinkedNode<T>*tempNode=node.next();
      SafeDelete(node);
      node=tempNode;
     }
   m_base.m_head.next(m_base.m_tail);
   m_base.m_tail.prev(m_base.m_head);
   m_base.m_size=0;
  }
//+------------------------------------------------------------------+
//| Remove all elements from list that equal `value`                 |
//+------------------------------------------------------------------+
template<typename T>
bool LinkedList::remove(const T value)
  {
   int n=0;
   LinkedNode<T>*p=m_base.m_head.next();
   while(p!=m_base.m_tail)
     {
      LinkedNode<T>*t=p;
      p=p.next();
      if(m_comparer.equals(value,t.get()))
        {
         n++;
         m_base.detach(t);
        }
     }
   return n>0;
  }
//+------------------------------------------------------------------+
//| ConstIterator Implementation                                     |
//+------------------------------------------------------------------+
template<typename T>
class ConstListIterator: public ConstIterator<T>
  {
private:
   LinkedNode<T>*m_tail;
   LinkedNode<T>*m_p;
public:
                     ConstListIterator(LinkedNode<T>*head,LinkedNode<T>*tail)
   :m_tail(tail),m_p(head.next())
     {}
   bool              end() const {return m_p==m_tail;}
   void              next() {m_p=m_p.next();}
   T                 current() const {return m_p.get();}
  };
//+------------------------------------------------------------------+
//| Iterator Implementation                                          |
//+------------------------------------------------------------------+
template<typename T>
class ListIterator: public Iterator<T>
  {
private:
   LinkedListBase<T>*m_base;
   LinkedNode<T>*m_prev;
   LinkedNode<T>*m_p;
public:
                     ListIterator(LinkedListBase<T>*base)
   :m_base(base),m_prev(base.m_head),m_p(m_prev.next())
     {}
   bool              end() const {return m_p==m_base.m_tail;}
   void              next() {if(m_p==NULL){m_p=m_prev.next();} else {m_prev=m_p;m_p=m_p.next();}}
   T                 current() const {return m_p==NULL?NULL:m_p.get();}
   bool              set(T value) {if(m_p==NULL)return false; m_p.set(value); return true;}

   bool              remove()
     {
      int size=m_base.m_size;
      m_base.detach(m_p);
      if(size==m_base.m_size) return false;
      m_p=NULL;
      return true;
     }
  };
//+------------------------------------------------------------------+
