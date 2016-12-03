//+------------------------------------------------------------------+
//|                                        Collection/LinkedList.mqh |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015-2016, Li Ding"
#property link      "dingmaotu@hotmail.com"
#property strict

#include "../Lang/Pointer.mqh"
//+------------------------------------------------------------------+
//| LinkedNode implementation as a base class for specific           |
//| node types.                                                      |
//+------------------------------------------------------------------+
class LinkedNode
  {
private:
   LinkedNode       *m_prev;
   LinkedNode       *m_next;

public:
                     LinkedNode():m_prev(NULL),m_next(NULL){}
   virtual          ~LinkedNode(){}

   LinkedNode       *prev() const {return m_prev;}
   void              prev(LinkedNode *node) {m_prev=node;}
   LinkedNode       *next() const {return m_next;}
   void              next(LinkedNode *node) {m_next=node;}
  };
//+------------------------------------------------------------------+
//| LinkedList implementation as a base class for specific           |
//| collections.                                                     |
//+------------------------------------------------------------------+
class LinkedList
  {
protected:
   LinkedNode       *m_head;
   int               m_size;

                     LinkedList():m_size(0),m_head(new LinkedNode()) {}
   virtual          ~LinkedList();

   void              detach(LinkedNode *node);
   void              attach(LinkedNode *prev,LinkedNode *node);
   LinkedNode       *last() const;
   LinkedNode       *at(int i) const;
   bool              inRange(int i) const {return i>=0 && i<m_size;}

public:
   // For iterating purpose. Should be protected but there are
   // no `friend` like C++, so we have to use this to implement an iterator
   const LinkedNode *__head() const {return m_head;}

   int               size() const {return m_size;}
   void              clear();
  };
//+------------------------------------------------------------------+
//| release all memory used by the list                              |
//+------------------------------------------------------------------+
LinkedList::~LinkedList()
  {
   LinkedNode*n=m_head.next();
   while(n!=NULL)
     {
      LinkedNode *tempNode=n.next();
      SafeDelete(n);
      n=tempNode;
     }
   SafeDelete(m_head);
  }
//+------------------------------------------------------------------+
//| detach node from list                                            |
//+------------------------------------------------------------------+
void LinkedList::detach(LinkedNode *node)
  {
   if(CheckPointer(node) != POINTER_DYNAMIC) return;
   if(node.prev()!=NULL) {node.prev().next(node.next());}
   if(node.next()!=NULL) {node.next().prev(node.prev());}
   SafeDelete(node);
   m_size--;
  }
//+------------------------------------------------------------------+
//| attach a node after prev                                         |
//+------------------------------------------------------------------+
void LinkedList::attach(LinkedNode *prev,LinkedNode *node)
  {
   if(CheckPointer(node) != POINTER_DYNAMIC) return;
// prev will always be a valid pointer (not NULL)
   node.prev(prev);
   node.next(prev.next());

   prev.next(node);

   if(node.next()!=NULL)
     {
      node.next().prev(node);
     }
   m_size++;
  }
//+------------------------------------------------------------------+
//| last node of the list                                            |
//+------------------------------------------------------------------+
LinkedNode *LinkedList::last() const
  {
   LinkedNode *node=m_head;
   while(node.next()!=NULL) {node=node.next();}
   return node;
  }
//+------------------------------------------------------------------+
//| ith insersion point of the list                                  |
//| ith node is at(i).next()                                         |
//| always return a valid node for insersion                         |
//| i.e. if i<0, then return m_head; if i>=m_size, return last valid |
//| node                                                             |
//+------------------------------------------------------------------+
LinkedNode *LinkedList::at(int i) const
  {
   int j=0;
   LinkedNode *node=m_head;
   while(node.next()!=NULL && j<i) {node=node.next(); j++;}
   return node;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
LinkedList::clear(void)
  {
   LinkedNode *node=m_head.next();
   while(node!=NULL)
     {
      LinkedNode *tempNode=node.next();
      SafeDelete(node);
      node=tempNode;
     }
   m_head.next(NULL);
   m_size=0;
  }
 
#define _LINKEDLIST_POINTER_DELETE_true SafeDelete(m_data);
#define _LINKEDLIST_POINTER_DELETE_false
//| -----------------------------------------------------------------|
//| This macro creates a version of LinkedList for a specific type   |
//| -----------------------------------------------------------------|
#define LINKED_LIST(TypeName, ClassPrefix, IsPointerElement) \
class ClassPrefix##Node: public LinkedNode\
  {\
private:\
   TypeName          m_data;\
public:\
                     ClassPrefix##Node(TypeName o):m_data(o){}\
   virtual          ~ClassPrefix##Node(){_LINKEDLIST_POINTER_DELETE_##IsPointerElement}\
   TypeName          getData() {return m_data;}\
   void              setData(TypeName o) {m_data=o;}\
  };\
class ClassPrefix##List: public LinkedList\
  {\
protected:\
   TypeName          getAndDetach(ClassPrefix##Node *n){if(n==NULL){return NULL;}TypeName o=n.getData();n.setData(NULL);detach(n);return o;}\
public:\
   TypeName          get(int i) const {ClassPrefix##Node *on=at(i).next();return on==NULL?NULL:on.getData();}\
   void              set(int i,TypeName o) {ClassPrefix##Node *on=at(i).next();if(on!=NULL){on.setData(o);}}\
   void              insert(int i,TypeName o) {attach(at(i),new ClassPrefix##Node(o));}\
   void              remove(int i) {detach(at(i).next());}\
   void              push(TypeName o) {attach(last(),new ClassPrefix##Node(o));}\
   TypeName          pop() {ClassPrefix##Node *n=last(); return n==m_head?NULL:getAndDetach(n);}\
   TypeName          peek() {ClassPrefix##Node *n=last(); return n==m_head?NULL:n.getData();}\
   void              unshift(TypeName o) {attach(m_head,new ClassPrefix##Node(o));}\
   TypeName          shift() {ClassPrefix##Node *n=m_head.next(); return getAndDetach(n);}\
  };\
class ClassPrefix##ListIterator\
  {\
private:\
   ClassPrefix##Node*m_p;\
public:\
                     ClassPrefix##ListIterator(const ClassPrefix##List &list):m_p(list.__head().next()){}\
   bool              end() const {return m_p==NULL;}\
   void              next() {if(!end()){m_p=m_p.next();}}\
   TypeName          get() {return m_p.getData();}\
  }
//+------------------------------------------------------------------+
