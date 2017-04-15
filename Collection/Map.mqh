//+------------------------------------------------------------------+
//|                                                          Map.mqh |
//|                  Copyright 2017, Bear Two Technologies Co., Ltd. |
//+------------------------------------------------------------------+
#property strict

#include "../Lang/Mql.mqh"
#include "Collection.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
template<typename Key,typename Value>
interface MapIterator
  {
   Key       key() const;
   Value     value() const;
   void      next();
   bool      end() const;
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
template<typename Key,typename Value>
interface Map
  {
   int               size() const;
   bool              isEmpty() const;
   bool              contains(Key key) const;
   bool              remove(Key key);
   void              clear();

   MapIterator<Key,Value>*iterator() const;
   bool              keys(Collection<Key>&col) const;
   bool              values(Collection<Value>&col) const;

   Value             operator[](Key key) const;
   void              set(Key key,Value value);
  };

#define BEGIN_MAP_FOR(KeyType,KeyName,ValueType,ValueName,Map) \
for(MapIterator<KeyType,ValueType>*__it__=Map.iterator(); !__it__.end() || SafeDelete(__it__); __it__.next())\
  {\
   KeyType KeyName=__it__.key();\
   ValueType ValueName=__it__.value();
#define END_MAP_FOR \
  }
//+------------------------------------------------------------------+
