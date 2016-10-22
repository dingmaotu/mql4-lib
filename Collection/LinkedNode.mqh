//+------------------------------------------------------------------+
//|                                        Collection/LinkedNode.mqh |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015-2016, Li Ding"
#property link      "dingmaotu@hotmail.com"
#property strict

#include "../Lang/Object.mqh"
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

   LinkedNode       *prev() {return m_prev;}
   void              prev(LinkedNode *node) {m_prev=node;}
   LinkedNode       *next() {return m_next;}
   void              next(LinkedNode *node) {m_next=node;}
  };
//+------------------------------------------------------------------+
