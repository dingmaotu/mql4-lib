//+------------------------------------------------------------------+
//|                                        Collection/LinkedList.mqh |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015-2016, Li Ding"
#property link      "dingmaotu@hotmail.com"
#property strict

#include "../Lang/Pointer.mqh"
#include "Collection.mqh"
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
class LinkedList: public Collection<T>
  {
protected:
   LinkedNode<T>*m_head;
   LinkedNode<T>*m_tail;
   int               m_size;

   void              detach(LinkedNode<T>*node);
   void              insert(LinkedNode<T>*ref,LinkedNode<T>*node);
   LinkedNode<T>*last() const;
   LinkedNode<T>*at(int i) const;
   bool              inRange(int i) const {return i>=0 && i<m_size;}

   T                 getAndDetach(LinkedNode<T>*n){if(n==m_tail){return NULL;}T o=n.release();detach(n);return o;}

public:

                     LinkedList()
   :m_size(0),m_head(new LinkedNode<T>(NULL)),m_tail(new LinkedNode<T>(NULL))
     {
      m_head.next(m_tail);
      m_tail.prev(m_head);
     }
   virtual          ~LinkedList();

   Iterator<T>*iterator() const {return new ListIterator<T>(m_head,m_tail);}

   int               size() const {return m_size;}
   void              clear();
   // returns true if the collection changed because of adding the value
   bool              add(T value) {push(value); return true;}
   // returns true if the collection changed because of removing the value
   bool              remove(const T value);

   // Sequence interface
   T                 get(int i) const {LinkedNode<T>*on=at(i);return on==m_tail?NULL:on.get();}
   void              set(int i,T o) {LinkedNode<T>*on=at(i);if(on!=m_tail){on.set(o);}}
   void              insertAt(int i,T o) {insert(at(i),new LinkedNode<T>(o));}
   void              removeAt(int i) {detach(at(i));}
   void              compact();

   // Stack and Queue interface
   void              push(T o) {insert(m_tail,new LinkedNode<T>(o));}
   T                 pop() {LinkedNode<T>*n=last(); return n==NULL?NULL:getAndDetach(n);}
   T                 peek() const {LinkedNode<T>*n=last(); return n==NULL?NULL:n.get();}
   void              unshift(T o) {insert(m_head.next(),new LinkedNode<T>(o));}
   T                 shift() {LinkedNode<T>*n=m_head.next(); return getAndDetach(n);}
  };
//+------------------------------------------------------------------+
//| release all memory used by the list                              |
//+------------------------------------------------------------------+
template<typename T>
LinkedList::~LinkedList()
  {
   LinkedNode<T>*n=m_head.next();
   while(n!=m_tail)
     {
      LinkedNode<T>*tempNode=n.next();
      SafeDelete(n);
      n=tempNode;
     }
   SafeDelete(m_head);
   SafeDelete(m_tail);
  }
//+------------------------------------------------------------------+
//| detach node from list                                            |
//+------------------------------------------------------------------+
template<typename T>
void LinkedList::detach(LinkedNode<T>*node)
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
void LinkedList::insert(LinkedNode<T>*ref,LinkedNode<T>*node)
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
LinkedNode<T>*LinkedList::last() const
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
LinkedNode<T>*LinkedList::at(int i) const
  {
   int j=0;
   LinkedNode<T>*node=m_head.next();
   while(node!=m_tail && j<i) {node=node.next(); j++;}
   return node;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
template<typename T>
LinkedList::clear(void)
  {
   LinkedNode<T>*node=m_head.next();
   while(node!=m_tail)
     {
      LinkedNode<T>*tempNode=node.next();
      SafeDelete(node);
      node=tempNode;
     }
   m_head.next(m_tail);
   m_tail.prev(m_head);
   m_size=0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
template<typename T>
bool LinkedList::remove(const T value)
  {
   LinkedNode<T>*toDetach=NULL;
   for(LinkedNode<T>*p=m_head.next(); p!=m_tail; p=p.next())
     {
      if(value==p.get())
        {
         toDetach=p;
         break;
        }
     }
   if(toDetach!=NULL)
     {
      detach(toDetach);
      return true;
     }
   else
      return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
template<typename T>
void LinkedList::compact()
  {
   LinkedNode<T>*p=m_head.next();
   while(p!=m_tail)
     {
      LinkedNode<T>*toTest=p;
      p=p.next();
      if(NULL==toTest.get())
        {
         detach(toTest);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
template<typename T>
class ListIterator: public Iterator<T>
  {
private:
   LinkedNode<T>*m_p;
   const             LinkedNode<T>*m_tail;
public:
                     ListIterator(const LinkedNode<T>*head,const LinkedNode<T>*tail):m_p(head.next()),m_tail(tail){}
   bool              end() const {return m_p==m_tail;}
   void              next() {m_p=m_p.next();}
   T                 current() const {return m_p.get();}
   bool              set(T value) {m_p.set(value); return true;}
  };
//+------------------------------------------------------------------+
