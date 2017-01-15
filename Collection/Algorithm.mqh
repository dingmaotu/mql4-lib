//+------------------------------------------------------------------+
//|                                         Collection/Algorithm.mqh |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Li Ding"
#property link      "dingmaotu@hotmail.com"
#property strict
//+------------------------------------------------------------------+
//| Generic array insert                                             |
//+------------------------------------------------------------------+
template<typename T>
void ArrayInsert(T &array[],int index,T value,int extraBuffer=10)
  {
   int size=ArraySize(array);
   ArrayResize(array,size+1,extraBuffer);
   for(int i=size; i>index; i--)
     {
      array[i]=array[i-1];
     }
   array[index]=value;
  }
//+------------------------------------------------------------------+
//| Generic array delete                                             |
//+------------------------------------------------------------------+
template<typename T>
void ArrayDelete(T &array[],int index)
  {
   int size=ArraySize(array);

   for(int i=index; i<size-1; i++)
     {
      array[i]=array[i+1];
     }
   ArrayResize(array,size-1);
  }
//+------------------------------------------------------------------+
//| Generic binary search                                            |
//+------------------------------------------------------------------+
template<typename T>
int BinarySearch(const T &array[],T value)
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
