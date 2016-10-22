//+------------------------------------------------------------------+
//|                                        Collection/ObjectList.mqh |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015-2016, Li Ding"
#property link      "dingmaotu@hotmail.com"
#property strict

#include "ObjectNode.mqh"
#include "LinkedList.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class ObjectList: public LinkedList
  {
protected:
   Object           *getAndDetach(ObjectNode *n);
public:
   Object           *get(int i) const {if(inRange(i)) {ObjectNode *on=at(i);return on.getData();} else {return NULL;}}
   void              set(int i,Object *o) {if(inRange(i)) {ObjectNode *on=at(i);on.setData(o);}}
   void              insert(int i,Object *o) {if(inRange(i)) {attach(at(i),new ObjectNode(o));}}
   void              remove(int i) {if(inRange(i)) {detach(at(i));}}

   void              push(Object *o) {attach(last(),new ObjectNode(o));}
   Object           *pop() {ObjectNode *n=last(); return getAndDetach(n);}
   void              unshift(Object *o) {attach(NULL,new ObjectNode(o));}
   Object           *shift() {ObjectNode *n=getHead(); return getAndDetach(n);}
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Object *ObjectList::getAndDetach(ObjectNode *n)
  {
   Object *o=n.getData();
   n.setData(NULL);
   detach(n);
   return o;
  }
//+------------------------------------------------------------------+
