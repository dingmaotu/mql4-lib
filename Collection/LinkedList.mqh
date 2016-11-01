//+------------------------------------------------------------------+
//|                                        Collection/LinkedList.mqh |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015-2016, Li Ding"
#property link      "dingmaotu@hotmail.com"
#property strict

#include "../Lang/Pointer.mqh"
#include "LinkedNode.mqh"
//+------------------------------------------------------------------+
//| LinkedList implementation as a base class for specific           |
//| collections.                                                     |
//+------------------------------------------------------------------+
class LinkedList
  {
private:
   LinkedNode       *m_head;
   int               m_size;
protected:
                     LinkedList():m_size(0),m_head(NULL) {}
   virtual          ~LinkedList();

   void              detach(LinkedNode *node);
   void              attach(LinkedNode *prev,LinkedNode *node);
   LinkedNode       *last() const;
   LinkedNode       *at(int i) const;
   bool              inRange(int i) const {return i>=0 && i<m_size;}

public:
   // For iterating purpose. Should be protected but there are
   // no `friend` like C++, so we have to use this to implement an iterator
   LinkedNode       *getHead() const {return m_head;}

   int               size() const {return m_size;}
  };
//+------------------------------------------------------------------+
//| release all memory used by the list                              |
//+------------------------------------------------------------------+
LinkedList::~LinkedList()
  {
   LinkedNode*n=m_head;
   while(n!=NULL)
     {
      LinkedNode *tempNode=n.next();
      delete n;
      n=tempNode;
     }
  }
//+------------------------------------------------------------------+
//| detach node from list                                            |
//+------------------------------------------------------------------+
void LinkedList::detach(LinkedNode *node)
  {
   if(CheckPointer(node) != POINTER_DYNAMIC) return;
   if(node.prev()!=NULL) {node.prev().next(node.next());}
   if(node.next()!=NULL) {node.next().prev(node.prev());}

   if(node==m_head)
     {
      m_head=node.next();
     }

   delete node;
   m_size--;
  }
//+------------------------------------------------------------------+
//| attach a node after prev                                         |
//+------------------------------------------------------------------+
void LinkedList::attach(LinkedNode *prev,LinkedNode *node)
  {
   if(CheckPointer(node) != POINTER_DYNAMIC) return;
   if(prev==NULL)
     {
      //--- insert before head
      node.next(m_head);
      if(m_head!=NULL)
        {
         m_head.prev(node);
        }
      m_head=node;
     }
   else
     {
      node.prev(prev);
      node.next(prev.next());

      prev.next(node);

      if(node.next()!=NULL)
        {
         node.next().prev(node);
        }
     }
   m_size++;
  }
//+------------------------------------------------------------------+
//| last node of the list                                            |
//+------------------------------------------------------------------+
LinkedNode *LinkedList::last() const
  {
   LinkedNode *node=m_head;
   while(node!=NULL && node.next()!=NULL) {node=node.next();}
   return node;
  }
//+------------------------------------------------------------------+
//| ith node of the list                                             |
//+------------------------------------------------------------------+
LinkedNode *LinkedList::at(int i) const
  {
   if(i<0 || i>m_size-1)
     {
      return NULL;
     }
   else
     {
      int j=0;
      LinkedNode *node=m_head;
      while(node!=NULL && node.next()!=NULL && j!=i) {node=node.next(); j++;}
      return node;
     }
  }
//| -----------------------------------------------------------------|
//| This macro creates a version of LinkedList for a specific type   |
//| -----------------------------------------------------------------|
#define LINKED_LIST(TypeName) \
class TypeName##Node: public LinkedNode\
  {\
private:\
   TypeName          *m_data;\
public:\
                     TypeName##Node(TypeName *o):m_data(o){}\
   virtual          ~TypeName##Node(){SafeDelete(m_data);}\
   TypeName         *getData() {return m_data;}\
   void              setData(TypeName *o) {m_data=o;}\
  };\
class TypeName##List: public LinkedList\
  {\
protected:\
   TypeName         *getAndDetach(TypeName##Node *n){TypeName *o=n.getData();n.setData(NULL);detach(n);return o;}\
public:\
   TypeName         *get(int i) const {if(inRange(i)) {TypeName##Node *on=at(i);return on.getData();} else {return NULL;}}\
   void              set(int i,Object *o) {if(inRange(i)) {TypeName##Node *on=at(i);on.setData(o);}}\
   void              insert(int i,Object *o) {if(inRange(i)) {attach(at(i),new TypeName##Node(o));}}\
   void              remove(int i) {if(inRange(i)) {detach(at(i));}}\
   void              push(TypeName *o) {attach(last(),new TypeName##Node(o));}\
   TypeName         *pop() {TypeName##Node *n=last(); return getAndDetach(n);}\
   void              unshift(TypeName *o) {attach(NULL,new TypeName##Node(o));}\
   TypeName         *shift() {TypeName##Node *n=getHead(); return getAndDetach(n);}\
  };\
class TypeName##Iterator\
  {\
private:\
   TypeName##Node    *m_p;\
public:\
                     TypeName##Iterator(const TypeName##List &list):m_p(list.getHead()){}\
   bool              end() {return m_p==NULL;}\
   void              next() {if(!end()){m_p=m_p.next();}}\
   TypeName         *get() {return m_p.getData();}\
  }
//+------------------------------------------------------------------+
