//+------------------------------------------------------------------+
//|                                                   LinkedList.mqh |
//|                                          Copyright 2015, Li Ding |
//|                                             http://dingmaotu.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, Li Ding"
#property link      "http://dingmaotu.com"
#property strict

#include <LiDing/Collection/LinkedNode.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class LinkedList
  {
private:
   LinkedNode       *m_head;
   int               m_size;
protected:
   void              detach(LinkedNode *node);
   void              attach(LinkedNode *prev,LinkedNode *node);
   LinkedNode       *last() const;
   LinkedNode       *at(int i) const;
   bool              inRange(int i) const {return i>=0 && i<m_size;}
public:
                     LinkedList():m_size(0),m_head(NULL) {}
                    ~LinkedList();
   // for iterating purpose
   LinkedNode *getHead() const {return m_head;}

   int               size() const {return m_size;}

   Object           *get(int i) const {if(inRange(i)) {return at(i).getData();} else {return NULL;}}
   void              set(int i,Object *o) {if(inRange(i)) {at(i).setData(o);}}
   void              insert(int i,Object *o) {if(inRange(i)) {attach(at(i),new LinkedNode(o));}}
   void              remove(int i) {if(inRange(i)) {detach(at(i));}}

   void              push(Object *o) {attach(last(),new LinkedNode(o));}
   Object           *pop() {LinkedNode *n=last(); Object *o=n.getData(); detach(n); return o;}
   void              unshift(Object *o);
   Object           *shift() {Object *o=m_head.getData(); detach(m_head); return o;}
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
      if(n.getData()!=NULL)
        {
         delete n.getData();
        }
      delete n;
      n=tempNode;
     }
  }
//+------------------------------------------------------------------+
//| detach node from list                                            |
//+------------------------------------------------------------------+
void LinkedList::detach(LinkedNode *node)
  {
   if(CheckPointer(node) == POINTER_INVALID || node == NULL) return;
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
   if(CheckPointer(node) == POINTER_INVALID || node == NULL) return;
   if(prev==NULL)
     {
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
//+------------------------------------------------------------------+
