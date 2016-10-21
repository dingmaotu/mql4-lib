//+------------------------------------------------------------------+
//|                                        Collection/LinkedNode.mqh |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015-2016, Li Ding"
#property link      "dingmaotu@hotmail.com"
#property strict

#include "../Lang/Object.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class LinkedNode
  {
private:
   Object           *m_data;
   LinkedNode       *m_prev;
   LinkedNode       *m_next;

public:
                     LinkedNode(Object *o):m_data(o),m_prev(NULL),m_next(NULL){}
                    ~LinkedNode(){}

   LinkedNode       *prev() {return m_prev;}
   void              prev(LinkedNode *node) {m_prev=node;}
   LinkedNode       *next() {return m_next;}
   void              next(LinkedNode *node) {m_next=node;}

   Object           *getData() {return m_data;}
   void              setData(Object *o) {m_data=o;}
  };
//+------------------------------------------------------------------+
