//+------------------------------------------------------------------+
//|                                            Collection/Vector.mqh |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015-2016, Li Ding"
#property link      "dingmaotu@hotmail.com"
#property strict

#include "Algorithm.mqh"
#include "../Lang/Pointer.mqh"

#define _VECTOR_BUFFER 50

#define _VECTOR_POINTER_DELETE_true int s=ArraySize(array);for(int i=0;i<s;i++){SafeDelete(array[i]);}
#define _VECTOR_POINTER_DELETE_false
//+------------------------------------------------------------------+
//| Generic Vector                                                   |
//+------------------------------------------------------------------+
#define VECTOR(TypeName, ClassName, IsPointerElement) \
class ClassName##Vector\
  {\
private:\
   TypeName          array[];\
protected:\
   void              resize(int size) {ArrayResize(array,size,_VECTOR_BUFFER);}\
public:\
                     ClassName##Vector() {resize(0);}\
   virtual          ~ClassName##Vector() {_VECTOR_POINTER_DELETE_##IsPointerElement ArrayFree(array);}\
   void              push(TypeName val) {int size=size();resize(size+1);array[size]=val;}\
   TypeName          pop() {int size=size();TypeName val=array[size-1];resize(size-1);return val;}\
   TypeName          peek() const {int size=size();return array[size()-1];}\
   void              clear() {_VECTOR_POINTER_DELETE_##IsPointerElement resize(0);}\
   void              insert(int i,TypeName val) {ArrayInsert(array,i,val);}\
   TypeName          remove(int i) {TypeName val=array[i];ArrayDelete(array,i);return val;}\
   void              unshift(TypeName val) {insert(0, val);}\
   TypeName          shift() {return remove(0);}\
   TypeName          get(int i) const {return array[i];}\
   void              set(int i,TypeName val) {array[i]=val;}\
   int               size() const {return ArraySize(array);}\
  };\
class ClassName##VectorIterator\
  {\
private:\
   int                      m_index;\
   const int                m_size;\
   const ClassName##Vector *m_vector;\
public:\
                     ClassName##VectorIterator(const ClassName##Vector &v)\
                     :m_index(0),m_size(v.size()),m_vector(GetPointer(v)){}\
   bool              end() const {return m_index>=m_size;}\
   void              next() {if(!end()){m_index++;}}\
   TypeName          get() {return m_vector.get(m_index);}\
  }
//+------------------------------------------------------------------+
