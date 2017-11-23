//+------------------------------------------------------------------+
//| Module: Format/RespString.mqh                                    |
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
#include "RespValue.mqh"
//+------------------------------------------------------------------+
//| Common simple string encoding for Error and String               |
//+------------------------------------------------------------------+
int EncodeRespString(const string &s,char prefix,uchar &a[],int index)
  {
   char u8[];
   StringToUtf8(s,u8,false);
   int size=ArraySize(u8);
// prefix + content + "\r\n"
   int totalSize=size+3;
   int currentIndex=index;
   if(ArraySize(a)<currentIndex+totalSize)
     {
      ArrayResize(a,currentIndex+totalSize,100);
     }

   a[currentIndex++]=prefix;
   currentIndex+=ArrayCopy(a,u8,currentIndex);
   a[currentIndex++]='\r';
   a[currentIndex++]='\n';
   return currentIndex-index;
  }
//+------------------------------------------------------------------+
//| RespString                                                       |
//+------------------------------------------------------------------+
class RespString: public RespValue
  {
private:
   string            m_value;
public:
   RespType          getType() const {return RespTypeString;}
   string            toString() const {return StringFormat("\"%s\"",m_value);}

   int               encode(uchar &a[],int index) const
     {
      return EncodeRespString(m_value,'+',a,index);
     }

   //--- value semantics for RespString
                     RespString(const string value=""):m_value(value){}
                     RespString(const RespString &value):m_value(value.m_value) {}
   string            operator=(const string rhs) {m_value=rhs; return m_value;}
   string            operator=(const RespString &rhs) {m_value=rhs.m_value; return m_value;}
   bool              operator==(const string rhs) const {return m_value==rhs;}
   bool              operator==(const RespString &rhs) const {return m_value==rhs.m_value;}

   string            operator+=(const string rhs) {m_value+=rhs; return m_value;}
   string            operator+=(const RespString &rhs) {m_value+=rhs.m_value; return m_value;}

   string            operator+(const string rhs) const {return m_value+rhs;}
   string            operator+(const RespString &rhs) const {return m_value+rhs.m_value;}
   ushort            operator[](int index) const {return m_value[index]; }

   //--- RespString specific
   string            getValue() const {return m_value;}

   int               getLength() const {return StringLen(m_value);}
   int               getBufferLength() const {return StringBufferLen(m_value);}

   bool              reinit(int size=0,ushort wchar=0) {return StringInit(m_value,size,wchar);}
   bool              fill(ushort wchar) { return StringFill(m_value,wchar);}
   bool              set(int pos,ushort wchar) {return StringSetCharacter(m_value,pos,wchar);}

   bool              add(const string value) {return StringAdd(m_value,value);}
   bool              add(const RespString &value) {return StringAdd(m_value,value.m_value);}

   int               compare(const string value,bool caseSensitive=true) {return StringCompare(m_value,value,caseSensitive);}
   int               compare(const RespString &value,bool caseSensitive=true) {return StringCompare(m_value,value.m_value,caseSensitive);}

   int               find(string match,int startPos=0) const {return StringFind(m_value,match,startPos);}
   bool              contains(string match) const {return StringFind(m_value,match,0)!=-1;}
   bool              startsWith(string match) const {return StringFind(m_value,match,0)==0;}
   bool              endsWith(string match) const {return StringFind(m_value,match,0)==(StringLen(m_value)-StringLen(match));}

   int               find(const RespString &match,int startPos=0) const {return StringFind(m_value,match.m_value,startPos);}
   bool              contains(const RespString &match) const {return StringFind(m_value,match.m_value,0)!=-1;}
   bool              startsWith(const RespString &match) const {return StringFind(m_value,match.m_value,0)==0;}
   bool              endsWith(const RespString &match) const {return StringFind(m_value,match.m_value,0)==(StringLen(m_value)-StringLen(match.m_value));}

   RespString       *trimLeft() { StringTrimLeft(m_value); return GetPointer(this); }
   RespString       *trimRight() { StringTrimRight(m_value); return GetPointer(this); }

   bool              toLower() {return StringToLower(m_value);}
   bool              toUpper() {return StringToUpper(m_value);}

   string            substr(int pos,int length=0) const {return StringSubstr(m_value,pos,length);}
   int               replace(const string match,const string replacement) {return StringReplace(m_value,match,replacement);}
   int               replace(const RespString &match,const RespString &replacement) {return StringReplace(m_value,match.m_value,replacement.m_value);}
   int               replace(const string match,const RespString &replacement) {return StringReplace(m_value,match,replacement.m_value);}
   int               replace(const RespString &match,const string replacement) {return StringReplace(m_value,match.m_value,replacement);}

   int               split(const ushort separator,string &res[]) const {return StringSplit(m_value,separator,res);}
  };
//+------------------------------------------------------------------+
//| RespError                                                        |
//+------------------------------------------------------------------+
class RespError: public RespValue
  {
private:
   const string      m_value;
public:
   RespType          getType() const {return RespTypeError;}
   string            toString() const {return StringFormat("{Error: %s}",m_value);}

   int               encode(uchar &a[],int index) const
     {
      return EncodeRespString(m_value,'-',a,index);
     }
                     RespError(const string value):m_value(value){}

   //--- RespError sepcific
   string            getValue() const {return m_value;}
  };
//+------------------------------------------------------------------+
