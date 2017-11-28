//+------------------------------------------------------------------+
//| Module: Collection/Map.mqh                                       |
//| This file is part of the mql4-lib project:                       |
//|     https://github.com/dingmaotu/mql4-lib                        |
//|                                                                  |
//| Copyright 2017 Li Ding <dingmaotu@126.com>                       |
//|                                                                  |
//| Licensed under the Apache License, Version 2.0 (the "License");  |
//| you may not use this file except in compliance with the License. |
//| You may obtain a copy of the License at                          |
//|                                                                  |
//|     http://www.apache.org/licenses/LICENSE-2.0                   |
//|                                                                  |
//| Unless required by applicable law or agreed to in writing,       |
//| software distributed under the License is distributed on an      |
//| "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,     |
//| either express or implied.                                       |
//| See the License for the specific language governing permissions  |
//| and limitations under the License.                               |
//+------------------------------------------------------------------+
#property strict
//+------------------------------------------------------------------+
//| Iterator for a map                                               |
//+------------------------------------------------------------------+
template<typename Key,typename Value>
interface MapIterator
  {
   Key       key() const;
   Value     value() const;
   void      next();
   bool      end() const;

   void      setValue(Value v);
   bool      remove();
  };
//+------------------------------------------------------------------+
//| Map interface                                                    |
//+------------------------------------------------------------------+
template<typename Key,typename Value>
interface Map
  {
   int               size() const;
   bool              isEmpty() const;
   bool              contains(Key key) const;
   bool              remove(Key key);
   void              clear();

   MapIterator<Key,Value>*iterator();
   bool              keys(Collection<Key>&col) const;
   bool              values(Collection<Value>&col) const;

   Value             operator[](Key key) const;
   Value             get(Key key,Value def) const;

   void              set(Key key,Value value);
   bool              setIfExist(Key key,Value value);
   bool              setIfNotExist(Key key,Value value);

//--- same as remove but does not delete the value
//--- only for pointers, returns NULL if key does not exist. For value types, use remove
   Value             pop(Key key);
  };
//+------------------------------------------------------------------+
//| This is the utility class for implementing iterator RAII         |
//| assign and trueForOnce is for implementing foreach               |
//+------------------------------------------------------------------+
template<typename Key,typename Value>
class MapIter:public MapIterator<Key,Value>
  {
private:
   MapIterator<Key,Value>*m_it;
   int               m_condition;
public:
                     MapIter(Map<Key,Value>&m):m_it(m.iterator()),m_condition(2) {}
                    ~MapIter() {SafeDelete(m_it);}
   void              next() {m_it.next();}
   Key               key() const {return m_it.key();}
   Value             value() const {return m_it.value();}
   bool              end() const {return m_it.end();}

   void              setValue(Value v) {m_it.setValue(v);}
   bool              remove() {return m_it.remove();}

   bool              testTrue() {if(m_condition==0)return false;else {m_condition--;return true;}}
   bool              assignKey(Key &var) {var=m_it.key();return true;}
   bool              assignValue(Value &var) {var=m_it.value();return true;}
  };

#define foreachm(KeyType,KeyName,ValueType,ValueName,Map) \
for(MapIter<KeyType,ValueType>it(Map);it.testTrue();) for(ValueType ValueName;it.testTrue();) for(KeyType KeyName;(!it.end()) && it.assignKey(KeyName) && it.assignValue(ValueName);it.next())
   //+------------------------------------------------------------------+
