//+------------------------------------------------------------------+
//| Module: Lang/Array.mqh                                           |
//| This file is part of the mql4-lib project:                       |
//|     https://github.com/dingmaotu/mql4-lib                        |
//|                                                                  |
//| Copyright 2016 Li Ding <dingmaotu@126.com>                       |
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
//| Generic array insert                                             |
//+------------------------------------------------------------------+
template<typename T>
void ArrayInsert(T &array[],int index,T value,int extraBuffer=10)
  {
   int size=ArraySize(array);
   if(index<0 || index>size) return;
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
   if(index<0 || index>=size) return;

   for(int i=index; i<size-1; i++)
     {
      array[i]=array[i+1];
     }
   ArrayResize(array,size-1);
  }
//+------------------------------------------------------------------+
//| Remove all elements with value `value` and return number removed |
//+------------------------------------------------------------------+
template<typename T>
int ArrayDeleteAll(T &array[],const T value)
  {
   int s=ArraySize(array);
   int i=0;
   for(int j=0; j<s; j++)
     {
      if(array[j]!=value)
        {
         if(i!=j) { array[i]=array[j]; }
         i++;
        }
     }
   if(i<s) ArrayResize(array,i);
   return s-i;
  }
//+------------------------------------------------------------------+
//| Find the index where array[index] == value                       |
//+------------------------------------------------------------------+
template<typename T>
int ArrayFind(const T &array[],const T value)
  {
   int s=ArraySize(array);
   int index=-1;
   for(int i=0; i<s; i++)
     {
      if(value==array[i])
        {
         index=i;
         break;
        }
     }
   return index;
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
//| Find the first matching element                                  |
//+------------------------------------------------------------------+
template<typename T>
bool ArrayFindMatch(const T &a[],const T &b[],T &result)
  {
   int sizeA = ArraySize(a);
   int sizeB = ArraySize(b);
   if(sizeA==0||sizeB==0) return false;

   for(int i=0; i<sizeA; i++)
      for(int j=0; j<sizeB; j++)
         if(a[i]==b[j])
           {
            result=a[i];
            return true;
           }
   return false;
  }
//+------------------------------------------------------------------+
//| Remove array elements based on removed index                     |
//| The removed index array is in ascending order                    |
//+------------------------------------------------------------------+
template<typename T>
int ArrayBatchRemove(T &array[],const int &removed[])
  {
   int s=ArraySize(array);
   int i=0;
   int k=0;
   for(int j=0; j<s; j++)
     {
      if(k>=ArraySize(removed) || j!=removed[k])
        {
         if(i!=j)
           {
            array[i]=array[j];
           }
         i++;
        }
      else k++;
     }
   if(i<s)
     {
      ArrayResize(array,i);
      return s-i;
     }
   else return 0;
  }
//+------------------------------------------------------------------+
//| Wraps array                                                      |
//+------------------------------------------------------------------+
template<typename T>
class Array
  {
private:
   int               m_extraBuffer;
   T                 m_array[];
protected:
   void              clearArray();
public:
                     Array(int extraBuffer=10):m_extraBuffer(extraBuffer) {resize(0);}
                    ~Array() {clearArray(); ArrayFree(m_array);}

   bool              isSeries() const {return ArrayIsSeries(m_array);}
   void              setSeries(bool value) {ArraySetAsSeries(m_array,value);}

   int               size() const {return ArraySize(m_array);}
   void              resize(int size)
     {
      bool s=isSeries();
      setSeries(false);
      ArrayResize(m_array,size,m_extraBuffer);
      setSeries(s);
     }

   void              setExtraBuffer(int value) {m_extraBuffer=value;resize(size());}
   int               getExtraBuffer() const {return m_extraBuffer;}

   void              clear() {clearArray(); resize(0);}

   T                 operator[](const int index) const {return m_array[index];}
   void              set(const int index,T value) {m_array[index]=value;}
   void              insertAt(int index,T value) {ArrayInsert(m_array,index,value,m_extraBuffer);}
   void              removeAt(int index) {ArrayDelete(m_array,index);}
   int               removeAll(const T value) {return ArrayDeleteAll(m_array,value);}

   int               index(const T value) const;
  };
//+------------------------------------------------------------------+
//| Deallocate array elements if necessary                           |
//+------------------------------------------------------------------+
template<typename T>
void Array::clearArray()
  {
   int s=ArraySize(m_array);
   if(s>0)
     {
      for(int i=0;i<s;i++){SafeDelete(m_array[i]);}
     }
  }
//+------------------------------------------------------------------+
//| call ArrayFind will not compile because of template error        |
//+------------------------------------------------------------------+
template<typename T>
int Array::index(const T value) const
  {
   int s=ArraySize(m_array);
   int index=-1;
   for(int i=0; i<s; i++)
     {
      if(value==m_array[i])
        {
         index=i;
         break;
        }
     }
   return index;
  }
//+------------------------------------------------------------------+
