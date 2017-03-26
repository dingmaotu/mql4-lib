//+------------------------------------------------------------------+
//|                                        Collection/Collection.mqh |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Li Ding"
#property link      "dingmaotu@hotmail.com"
#property strict

#define foreach(Type,Iterable) for(Iter<Type>it(Iterable); !it.end(); it.next())
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
//| Wraps the iterator of a collection for RAII                      |
//+------------------------------------------------------------------+
template<typename T>
class Iter: public Iterator<T>
  {
private:
   Iterator<T>*m_iterator;
public:
                     Iter(const Iterable<T>&t):m_iterator(t.iterator()){}
   virtual          ~Iter() {SafeDelete(m_iterator);}
   bool              end() const {return m_iterator.end();}
   void              next() {m_iterator.next();}
   T                 current() const {return m_iterator.current();}
   bool              set(T value) {return m_iterator.set(value);}
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
   for(Iter<T>iter(this);!iter.end();iter.next())
     {
      if(iter.current()==value) return true;
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
   for(Iter<T>iter(collection); !iter.end(); iter.next())
     {
      bool tmp=add(iter.current());
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
