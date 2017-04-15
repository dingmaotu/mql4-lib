//+------------------------------------------------------------------+
//|                                        Collection/Collection.mqh |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Li Ding"
#property link      "dingmaotu@hotmail.com"
#property strict

#include "../Lang/Pointer.mqh"

#define foreach(Type,Iterable) for(Iterator<Type>*it=Iterable.iterator(); !it.end() || SafeDelete(it); it.next())
//+------------------------------------------------------------------+
//| Standard Iterator for all collections                            |
//+------------------------------------------------------------------+
template<typename T>
interface Iterator
  {
   void      next();
   T         current() const;
   bool      end() const;
   bool      set(T value);  // replace current value in target collection
  };
//+------------------------------------------------------------------+
//| Do something on each elements of an iterable                     |
//| Returns true if it is needed to delete this element              |
//+------------------------------------------------------------------+
template<typename T>
class ElementOperator
  {
public:
   virtual void      begin() {}
   virtual void      end() {}
   virtual bool      operate(T value)=0;
  };
//+------------------------------------------------------------------+
//| A collection must be iterable                                    |
//+------------------------------------------------------------------+
template<typename T>
interface Iterable
  {
   Iterator<T>*iterator() const;
  };
//+------------------------------------------------------------------+
//| Base class for collections                                       |
//+------------------------------------------------------------------+
template<typename T>
class Collection: public Iterable<T>
  {
public:
   // remove all elements of the collection
   virtual void      clear()=0;
   // returns true if the collection changed because of adding the value
   virtual bool      add(T value)=0;
   // returns true if the collection changed because of removing the value
   virtual bool      remove(const T value)=0;
   virtual int       size() const=0;

   virtual bool      addAll(T &array[]);
   virtual bool      addAll(const Collection<T>&collection);

   virtual bool      contains(const T value) const;

   virtual bool      isEmpty() const {return size()==0;}

   virtual void      toArray(T &array[]) const;
  };
//+------------------------------------------------------------------+
//| Standard implementation using iterators                          |
//+------------------------------------------------------------------+
template<typename T>
bool Collection::contains(const T value) const
  {
   foreach(T,this)
     {
      if(it.current()==value) return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
//| Standard implementation using add                                |
//+------------------------------------------------------------------+
template<typename T>
bool Collection::addAll(T &array[])
  {
   int s=ArraySize(array);
   bool added=false;
   for(int i=0; i<s; i++)
     {
      bool tmp=add(array[i]);
      if(!added) added=tmp;
     }
   return added;
  }
//+------------------------------------------------------------------+
//| Standard implementation using add                                |
//+------------------------------------------------------------------+
template<typename T>
bool Collection::addAll(const Collection<T>&collection)
  {
   bool added=false;
   foreach(T,collection)
     {
      bool tmp=add(it.current());
      if(!added) added=tmp;
     }
   return added;
  }
//+------------------------------------------------------------------+
//| Standard implementation using iterators                          |
//+------------------------------------------------------------------+
template<typename T>
void Collection::toArray(T &array[]) const
  {
   int s=size();
   if(s>0)
     {
      ArrayResize(array,s);
      Iterator<T>*iter=this.iterator();
      int i=0;
      while(!iter.end())
        {
         array[i]=iter.current();
         iter.next();
         i++;
        }
      delete iter;
     }
  }
//+------------------------------------------------------------------+
