//+------------------------------------------------------------------+
//| Module: Format/Resp.mqh                                          |
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
//| This is an implementation of the RESP serilization protocol used |
//| in Redis. Following is from official protocol description:       |
//|                                                                  |
//| The RESP protocol was introduced in Redis 1.2, but it became the |
//| standard way for talking with the Redis server in Redis 2.0. This|
//| is the protocol you should implement in your Redis client.       |
//|                                                                  |
//| RESP is actually a serialization protocol that supports the      |
//| following data types: Simple Strings, Errors, Integers,          |
//| Bulk Strings and Arrays.                                         |
//|                                                                  |
//| The way RESP is used in Redis as a request-response protocol is  |
//| the following:                                                   |
//| Clients send commands to a Redis server as a RESP Array of       |
//| Bulk Strings.                                                    |
//| The server replies with one of the RESP types according to the   |
//| command implementation.                                          |
//|                                                                  |
//| In RESP, the type of some data depends on the first byte:        |
//| For Simple Strings the first byte of the reply is "+"            |
//| For Errors the first byte of the reply is "-"                    |
//| For Integers the first byte of the reply is ":"                  |
//| For Bulk Strings the first byte of the reply is "$"              |
//| For Arrays the first byte of the reply is "*"                    |
//|                                                                  |
//| Additionally RESP is able to represent a Null value using a      |
//| special variation of Bulk Strings or Array as specified later.   |
//| In RESP different parts of the protocol are always terminated    |
//| with "\r\n" (CRLF).                                              |
//+------------------------------------------------------------------+
#include "RespValue.mqh"
#include "RespArray.mqh"
#include "RespInteger.mqh"
#include "RespString.mqh"
#include "RespBytes.mqh"
//+------------------------------------------------------------------+
//| Parser for the RESP protocol                                     |
//+------------------------------------------------------------------+
class RespParser
  {
public:
   //--- parse a RESP protocol buffer and return a RespValue
   //--- returns NULL if the buf contains invalid content
   //--- returns start index of next RespValue if successful
   static RespValue *parse(const char &buf[],int &pos)
     {
      Ref<RespValue>res;
      parseRespValue(buf,pos,ArraySize(buf),res);
      return res.r;
     }
   //--- skip '\r\n'
   static bool       skipNewLine(const char &buf[],int &index,int size);
   //--- parse a long integer
   static bool       parseInteger(const char &buf[],int &index,int size,long &value);
   //--- parse a simple string
   static bool       parseSimpleString(const char &buf[],int &index,int size,char prefix,string &value);

   //--- top level parse
   static bool       parseRespValue(const char &buf[],int &index,int size,Ref<RespValue>&res);
   //--- parse a RespInteger
   static bool       parseRespInteger(const char &buf[],int &index,int size,Ref<RespValue>&res);
   //--- parse a RespString
   static bool       parseRespString(const char &buf[],int &index,int size,Ref<RespValue>&res);
   //--- parse a RespNil
   static bool       parseRespNil(const char &buf[],int &index,int size,Ref<RespValue>&res);
   //--- parse a RespError
   static bool       parseRespError(const char &buf[],int &index,int size,Ref<RespValue>&res);
   //--- parse a RespBytes
   static bool       parseRespBytes(const char &buf[],int &index,int size,Ref<RespValue>&res);
   //--- parse a RespArray
   static bool       parseRespArray(const char &buf[],int &index,int size,Ref<RespValue>&res);
  };
//--- skip '\r\n'
bool RespParser::skipNewLine(const char &buf[],int &index,int size)
  {
   if((index+1)<size && buf[index]=='\r' && buf[index+1]=='\n')
     {
      index+=2;
      return true;
     }
   return false;
  }
//--- parse a long integer
bool RespParser::parseInteger(const char &buf[],int &index,int size,long &value)
  {
   int i=index;
   long sign=1;
   if(i<size && buf[i]=='-') {sign=-1;i++;}
   for(value=0;i<size && buf[i]>='0' && buf[i]<='9';i++)
     {
      value=value*10+(buf[i]-'0');
     }
   if(i!=index && ((i!=(index+1)) || sign!=-1))
     {
      value*=sign;
      if(skipNewLine(buf,i,size))
        {
         index=i;
         return true;
        }
     }
   return false;
  }
//--- parse a simple string
bool RespParser::parseSimpleString(const char &buf[],int &index,int size,char prefix,string &value)
  {
   if(index<size && buf[index]==prefix)
     {
      int i=index+1;
      while(i<size && buf[i]!='\r')
         i++;
      if(skipNewLine(buf,i,size))
        {
         value=CharArrayToString(buf,index+1,i-2-index-1,CP_UTF8);
         index=i;
         return true;
        }
     }
   return false;
  }
//--- top level parse
bool RespParser::parseRespValue(const char &buf[],int &index,int size,Ref<RespValue>&res)
  {
   if(index<size)
     {
      switch(buf[index])
        {
         case '*':// array
            return parseRespArray(buf,index,size,res);
         case '+':// simple string
            return parseRespString(buf,index,size,res);
         case '-':// error
            return parseRespError(buf,index,size,res);
         case ':':// integer
            return parseRespInteger(buf,index,size,res);
         case '$':// bulk string or nil
            if((index+1)<size)
              {
               if(buf[index+1]=='-')
                  return parseRespNil(buf,index,size,res);
               else
                  return parseRespBytes(buf,index,size,res);
              }
            break;
         default:
            break;
        }
     }
   return false;
  }
//--- parse a RespInteger
bool RespParser::parseRespInteger(const char &buf[],int &index,int size,Ref<RespValue>&res)
  {
   int i=index;
   if(i<size && buf[i]==':')
     {
      i++;
      long value;
      if(parseInteger(buf,i,size,value))
        {
         res=new RespInteger(value);
         index=i;
         return true;
        }
     }
   return false;
  }
//--- parse a RespString
bool RespParser::parseRespString(const char &buf[],int &index,int size,Ref<RespValue>&res)
  {
   string value;
   if(parseSimpleString(buf,index,size,'+',value))
     {
      res=new RespString(value);
      return true;
     }
   return false;
  }
//--- parse a RespNil
bool RespParser::parseRespNil(const char &buf[],int &index,int size,Ref<RespValue>&res)
  {
   if(index<size && buf[index]=='$')
     {
      int i=index+1;
      long value;
      if(parseInteger(buf,i,size,value) && value==-1)
        {
         res=RespNil::getInstance();
         index=i;
         return true;
        }
     }
   return false;
  }
//--- parse a RespError
bool RespParser::parseRespError(const char &buf[],int &index,int size,Ref<RespValue>&res)
  {
   string value;
   if(parseSimpleString(buf,index,size,'-',value))
     {
      res=new RespError(value);
      return true;
     }
   return false;
  }
//--- parse a RespBytes
bool RespParser::parseRespBytes(const char &buf[],int &index,int size,Ref<RespValue>&res)
  {
   if(index<size && buf[index]=='$')
     {
      int i=index+1;
      long value;
      if(parseInteger(buf,i,size,value))
        {
         int len=(int)value;
         if((i+len)<size)
           {
            int copyStart=i;
            i+=len;
            if(skipNewLine(buf,i,size))
              {
               res=new RespBytes(buf,copyStart,len);
               index=i;
               return true;
              }
           }
        }
     }
   return false;
  }
//--- parse a RespArray
bool RespParser::parseRespArray(const char &buf[],int &index,int size,Ref<RespValue>&res)
  {
   if(index<size && buf[index]=='*')
     {
      int i=index+1;
      long value;
      if(parseInteger(buf,i,size,value))
        {
         int len=(int)value;
         bool failed=false;
         RespArray *a=new RespArray(len);
         Ref<RespValue>v;
         for(int j=0; j<len; j++)
           {
            if(parseRespValue(buf,i,size,v)) a.set(j,v.r);
            else
              {
               failed=true; break;
              }
           }
         if(failed) delete a;
         else
           {
            res=a;
            index=i;
            return true;
           }
        }
     }
   return false;
  }
//+------------------------------------------------------------------+
