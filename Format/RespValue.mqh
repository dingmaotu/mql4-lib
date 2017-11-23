//+------------------------------------------------------------------+
//| Module: Format/RespValue.mqh                                     |
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
//| Common utility functions and basic definition                    |
//+------------------------------------------------------------------+
#include "../Lang/Native.mqh"
#include "../Lang/Pointer.mqh"
//+------------------------------------------------------------------+
//| Convert long integer to an ASCII character array                 |
//+------------------------------------------------------------------+
int IntegerToCharArray(long value,char &buf[])
  {
//--- max length of long value is under 20 digits
//--- this function will not resize buf, ensure it is large enough
   bool minus=false;
   if(value<0) {minus=true;value=-value;}
   int i=19;
   do
     {
      buf[i--]=(char)(value%10+'0');
      value/=10;
     }
   while(value!=0);
   if(minus) {buf[i--]='-';}
   return 19-i;
  }
//+------------------------------------------------------------------+
//| Human readable string representation of a byte array             |
//+------------------------------------------------------------------+
string StringRepr(const uchar &a[],int pos=0,int count=WHOLE_ARRAY)
  {
   int end=ArraySize(a);
   if(count!=WHOLE_ARRAY) end=pos+count;

   int size=end-pos;
   for(int i=pos; i<end; i++)
     {
      if(a[i]=='\\' || a[i]=='\'' || a[i]=='\"' || a[i]=='\r' || a[i]=='\n' || a[i]=='\r')
        {
         size++;
        }
      else if(a[i]<32)
        {
         size+=3;
        }
     }
   string res;
   StringInit(res,size);
   for(int i=pos,j=0; i<end; i++)
     {
      if(a[i]=='\\' || a[i]=='\'' || a[i]=='\"' || a[i]=='\r' || a[i]=='\n' || a[i]=='\t')
        {
         StringSetCharacter(res,j++,'\\');
         if(a[i]=='\r') StringSetCharacter(res,j++,'r');
         else if(a[i]=='\n') StringSetCharacter(res,j++,'n');
         else if(a[i]=='\t') StringSetCharacter(res,j++,'t');
         else StringSetCharacter(res,j++,a[i]);
        }
      else if(a[i]<32)
        {
         StringSetCharacter(res,j++,'\\');
         StringSetCharacter(res,j++,'x');
         uchar low=a[i]&0xF;
         uchar high=(a[i]>>4)&0xF;
         if(low>9) low+=uchar('A'-10); else low+='0';
         if(high>9) high+=uchar('A'-10); else low+='0';
         StringSetCharacter(res,j++,high);
         StringSetCharacter(res,j++,low);
        }
      else
        {
         StringSetCharacter(res,j++,a[i]);
        }
     }
   return res;
  }
//+------------------------------------------------------------------+
//| Types of the RESP protocol                                       |
//+------------------------------------------------------------------+
enum RespType
  {
   RespTypeNil,// Bulk String of length -1
   RespTypeArray,// Array
   RespTypeString,// Simple String
   RespTypeBytes,// Bulk String
   RespTypeError,// Error
   RespTypeInteger// Integer
  };
//+------------------------------------------------------------------+
//| Parent type for all resp values                                  |
//+------------------------------------------------------------------+
class RespValue
  {
public:
   virtual RespType  getType() const=0;
   //--- return a string representation of this value
   virtual string    toString() const=0;
   //--- encode this value to array `a`, start from index `i`
   virtual int       encode(uchar &a[],int i) const=0;
  };
//+------------------------------------------------------------------+
