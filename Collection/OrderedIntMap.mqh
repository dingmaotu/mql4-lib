//+------------------------------------------------------------------+
//|                                     Collection/OrderedIntMap.mqh |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Li Ding"
#property link      "dingmaotu@hotmail.com"
#property strict
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class OrderedIntMap
  {
protected:
   int               keys[];
   int               values[];

   static void       insert(int &array[],int index,int value);
   static int        binarySearch(const int &array[],int value);
public:
                     OrderedIntMap() {resize(0);}
                    ~OrderedIntMap() {resize(0);}

   void              resize(int size) {ArrayResize(keys,size,10); ArrayResize(values,size,10);}
   int               size() const {return ArraySize(keys);}

   int               key(int i) const {return keys[i];}
   void              key(int i,int v) {keys[i]=v;}
   int               value(int i) const {return values[i];}
   void              value(int i,int v) {values[i]=v;}

   void              insert(int i,int key,int value) {OrderedIntMap::insert(keys,i,key);OrderedIntMap::insert(values,i,value);}

   bool              hasKey(int key,int &i) const {i=OrderedIntMap::binarySearch(keys,key);return size()>0 && i<size() && keys[i]==key;}

   void              zero();
   void              increment(int key);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
static int OrderedIntMap::binarySearch(const int &array[],int value)
  {
   int size = ArraySize(array);
   int begin=0,end=size-1,mid=0;
   while(begin<=end)
     {
      mid=(begin+end)/2;
      if(array[mid]<value)
        {
         mid++;
         begin=mid;
         continue;
        }
      else if(array[mid]>value)
        {
         end=mid-1;
         continue;
        }
      else
        {
         break;
        }
     }
   return mid;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OrderedIntMap::insert(int &array[],int index,int value)
  {
   int size=ArraySize(array);
   ArrayResize(array,size+1,10);
   for(int i=size; i>index; i--)
     {
      array[i]=array[i-1];
     }
   array[index]=value;
  }
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
