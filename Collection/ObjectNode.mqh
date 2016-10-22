//+------------------------------------------------------------------+
//|                                        Collection/ObjectNode.mqh |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015-2016, Li Ding"
#property link      "dingmaotu@hotmail.com"
#property strict

#include "../Lang/Object.mqh"
#include "LinkedNode.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class ObjectNode: public LinkedNode
  {
private:
   Object           *m_data;

public:
                     ObjectNode(Object *o):m_data(o){}
   virtual          ~ObjectNode();

   Object           *getData() {return m_data;}
   void              setData(Object *o) {m_data=o;}
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ObjectNode::~ObjectNode(void)
  {
   if(CheckPointer(m_data)==POINTER_DYNAMIC)
     {
      delete m_data;
     }
  }
//+------------------------------------------------------------------+
