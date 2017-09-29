//+------------------------------------------------------------------+
//|                                     Collection/OrderedIntMap.mqh |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Li Ding"
#property link      "dingmaotu@hotmail.com"
#property strict

#include "../Lang/Array.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class OrderedIntMap
  {
protected:
   int               keys[];
   int               values[];
public:
                     OrderedIntMap() {resize(0);}
                    ~OrderedIntMap() {resize(0);}

   void              resize(int size) {ArrayResize(keys,size,10); ArrayResize(values,size,10);}
   int               size() const {return ArraySize(keys);}

   int               key(int i) const {return keys[i];}
   void              key(int i,int v) {keys[i]=v;}
   int               value(int i) const {return values[i];}
   void              value(int i,int v) {values[i]=v;}

   void              insert(int i,int key,int value) {ArrayInsert(keys,i,key);ArrayInsert(values,i,value);}

   bool              hasKey(int key,int &i) const {i=BinarySearch(keys,key);return size()>0 && i<size() && keys[i]==key;}

   void              zero();
   void              increment(int key);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OrderedIntMap::increment(int key)
  {
   int i;
   if(!hasKey(key,i))
     {
      insert(i,key,1);
     }
   else
     {
      value(i,value(i)+1);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OrderedIntMap::zero(void)
  {
   int s=size();
   for(int i=0; i<s; i++)
     {
      values[i]=0;
     }
  }
//+------------------------------------------------------------------+
