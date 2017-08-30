//+------------------------------------------------------------------+
//| Module: Format/RespMsgParser.mqh                                 |
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
#include "RespArray.mqh"
#include "RespInteger.mqh"
#include "RespString.mqh"
#include "RespBytes.mqh"
#include "RespParseError.mqh"
#include "RespParser.mqh"
//+------------------------------------------------------------------+
//| A recursive descent parser for the RESP protocol                 |
//| This parser take a complete buffer as input. For example, if you |
//| receive a buffer using UDP sockets, as a ZeroMQ message, or from |
//| a file, and you are sure the input is complete and you can parse |
//| the buffer for a RESP value.                                     |
//| This parser generally has low overhead and do not keep any state.|
//| If the parse failed, it returns NULL and delete any intermediate |
//| objects.                                                         |
//+------------------------------------------------------------------+
class RespMsgParser: public RespParser
  {
private:
   RespParseError    m_error;  // parse error
   int               m_size;   // buffer size
   int               m_pos;    // the buffer m_pos used by all parse methods
protected:
   //--- skip '\r\n'
   bool              skipNewLine(const char &buf[]);
   //--- parse a long integer
   bool              parseInteger(const char &buf[],long &value);
   //--- parse a simple string
   bool              parseSimpleString(const char &buf[],string &value);

   bool              isRespValue(const char &buf[]);
   bool              isSimpleString(const char &buf[]);
   bool              isRespBytes(const char &buf[]);
   bool              isRespArray(const char &buf[]);

   //--- top level parse
   bool              parseRespValue(const char &buf[],Ref<RespValue>&res);
   //--- parse a RespInteger
   bool              parseRespInteger(const char &buf[],Ref<RespValue>&res);
   //--- parse a RespString
   bool              parseRespString(const char &buf[],Ref<RespValue>&res);
   //--- parse a RespNil
   bool              parseRespNil(const char &buf[],Ref<RespValue>&res);
   //--- parse a RespError
   bool              parseRespError(const char &buf[],Ref<RespValue>&res);
   //--- parse a RespBytes
   bool              parseRespBytes(const char &buf[],Ref<RespValue>&res);
   //--- parse a RespArray
   bool              parseRespArray(const char &buf[],Ref<RespValue>&res);
public:
                     RespMsgParser():m_error(RespParseErrorNone),m_size(0),m_pos(0) {}

   RespParseError    getError() const {return m_error;}
   int               getPosition() const {return m_pos;}

   //--- check if buffer contains a complete RespValue without actually create the value, starting from pos
   bool              check(const char &buf[],int pos=0)
     {
      m_error=RespParseErrorNone;
      m_pos=pos;
      m_size=ArraySize(buf);
      bool isSeries=ArrayIsSeries(buf);
      ArraySetAsSeries(buf,false);
      bool res=isRespValue(buf);
      ArraySetAsSeries(buf,isSeries);
      return res;
     }

   //--- parse a RESP protocol buffer and return a RespValue, start from pos
   //--- returns NULL if the buf contains invalid content
   RespValue        *parse(const char &buf[],int pos=0)
     {
      m_error=RespParseErrorNone;
      m_pos=pos;
      m_size=ArraySize(buf);
      bool isSeries=ArrayIsSeries(buf);
      ArraySetAsSeries(buf,false);
      Ref<RespValue>res;
      parseRespValue(buf,res);
      ArraySetAsSeries(buf,isSeries);
      return res.r;
     }
  };
//--- skip '\r\n'
bool RespMsgParser::skipNewLine(const char &buf[])
  {
   char newline[2]={'\r','\n'};
   int len=ArraySize(newline);
   for(int i=0; i<len; i++)
     {
      if((m_pos+i)>=m_size)
        {
         m_error=RespParseErrorNeedMoreInput;
         return false;
        }
      else if(buf[m_pos+i]!=newline[i])
        {
         m_error=RespParseErrorNewlineMalformed;
         return false;
        }
     }
   m_pos+=len;
   return true;
  }
//--- parse a long integer
bool RespMsgParser::parseInteger(const char &buf[],long &value)
  {
   long sign=1;
   int original=m_pos;
   if(m_pos>=m_size)
     {
      m_error=RespParseErrorNeedMoreInput;
      return false;
     }
   else
     {
      if(buf[m_pos]=='-') {sign=-1;m_pos++;}
     }
   for(value=0;m_pos<m_size && buf[m_pos]>='0' && buf[m_pos]<='9';m_pos++)
     {
      value=value*10+(buf[m_pos]-'0');
     }
   if(m_pos==m_size)
     {
      m_error=RespParseErrorNeedMoreInput;
      return false;
     }
   if(((m_pos!=(original+1)) || sign!=-1))
     {
      value*=sign;
      return true;
     }
   m_error=RespParseErrorInvalidInteger;
   return false;
  }
//--- is a valid simple string/error
bool RespMsgParser::isSimpleString(const char &buf[])
  {
   while(m_pos<m_size && buf[m_pos]!='\r')
      m_pos++;
   if(m_pos==m_size)
     {
      m_error=RespParseErrorNeedMoreInput;
      return false;
     }
   return skipNewLine(buf);
  }
//--- is a RespBytes
bool RespMsgParser::isRespBytes(const char &buf[])
  {
   long value;
   if(parseInteger(buf,value))
     {
      if(skipNewLine(buf))
        {
         if(value==-1) return true; // RespNil
         else if(value<=0)
           {
            m_error=RespParseErrorBytesLengthNotValid;
            return false;
           }
         else if((m_pos+value)<m_size)
           {
            m_pos+=(int)value;
            return skipNewLine(buf);
           }
         else
           {
            m_error=RespParseErrorNeedMoreInput;
            return false;
           }
        }
     }
   return false;
  }
//--- is a RespArray
bool RespMsgParser::isRespArray(const char &buf[])
  {
   long value;
   if(parseInteger(buf,value))
     {
      if(skipNewLine(buf))
        {
         int len=(int)value;
         if(len<=0)
           {
            m_error=RespParseErrorArrayLengthNotValid;
            return false;
           }
         for(int i=0; i<len; i++)
            if(!isRespValue(buf))
               return false;
         return true;
        }
     }
   return false;
  }
//--- is a buf contains a valid RESP value
bool RespMsgParser::isRespValue(const char &buf[])
  {
   if(m_pos>=m_size)
     {
      m_error=RespParseErrorNeedMoreInput;
      return false;
     }
   char prefix=buf[m_pos];
   m_pos++;
   switch(prefix)
     {
      case '*':// array
         return isRespArray(buf);
      case '+':// simple string
      case '-':// error
         return isSimpleString(buf);
      case ':':// integer
        {
         long dummy;
         return parseInteger(buf,dummy) && skipNewLine(buf);
        }
      case '$':// bulk string or nil
         return isRespBytes(buf);
      default:
         m_pos--;
         m_error=RespParseErrorInvalidPrefix;
         return false;
     }
  }
//--- parse a simple string
bool RespMsgParser::parseSimpleString(const char &buf[],string &value)
  {
   int copyBegin=m_pos;
   while(m_pos<m_size && buf[m_pos]!='\r')
      m_pos++;
   if(m_pos==m_size)
     {
      m_error=RespParseErrorNeedMoreInput;
      return false;
     }
   int copyEnd=m_pos;
   if(skipNewLine(buf))
     {
      value=CharArrayToString(buf,copyBegin,copyEnd-copyBegin,CP_UTF8);
      return true;
     }
   return false;
  }
//--- top level parse
bool RespMsgParser::parseRespValue(const char &buf[],Ref<RespValue>&res)
  {
   if(m_pos>=m_size)
     {
      m_error=RespParseErrorNeedMoreInput;
      return false;
     }
   char prefix=buf[m_pos];
   m_pos++;
   switch(prefix)
     {
      case '*':// array
         return parseRespArray(buf,res);
      case '+':// simple string
         return parseRespString(buf,res);
      case '-':// error
         return parseRespError(buf,res);
      case ':':// integer
         return parseRespInteger(buf,res);
      case '$':// bulk string or nil
         return parseRespBytes(buf,res);
      default:
         m_pos--;
         m_error=RespParseErrorInvalidPrefix;
         return false;
     }
  }
//--- parse a RespInteger
bool RespMsgParser::parseRespInteger(const char &buf[],Ref<RespValue>&res)
  {
   long value;
   if(parseInteger(buf,value))
     {
      if(skipNewLine(buf))
        {
         res=new RespInteger(value);
         return true;
        }
     }
   return false;
  }
//--- parse a RespString
bool RespMsgParser::parseRespString(const char &buf[],Ref<RespValue>&res)
  {
   string value;
   if(parseSimpleString(buf,value))
     {
      res=new RespString(value);
      return true;
     }
   return false;
  }
//--- parse a RespError
bool RespMsgParser::parseRespError(const char &buf[],Ref<RespValue>&res)
  {
   string value;
   if(parseSimpleString(buf,value))
     {
      res=new RespError(value);
      return true;
     }
   return false;
  }
//--- parse a RespBytes/RespNil
bool RespMsgParser::parseRespBytes(const char &buf[],Ref<RespValue>&res)
  {
   long value;
   if(parseInteger(buf,value))
     {
      if(skipNewLine(buf))
        {
         if(value==-1)
           {
            res=RespNil::getInstance();
            return true;
           }
         else if(value<=0)
           {
            m_error=RespParseErrorBytesLengthNotValid;
            return false;
           }
         else if((m_pos+value)<m_size)
           {
            int copyStart=m_pos;
            m_pos+=(int)value;
            if(skipNewLine(buf))
              {
               res=new RespBytes(buf,copyStart,(int)value);
               return true;
              }
           }
         else
           {
            m_error=RespParseErrorNeedMoreInput;
            return false;
           }
        }
     }
   return false;
  }
//--- parse a RespArray
bool RespMsgParser::parseRespArray(const char &buf[],Ref<RespValue>&res)
  {
   long value;
   if(parseInteger(buf,value))
     {
      if(skipNewLine(buf))
        {
         int len=(int)value;
         if(len<=0)
           {
            m_error=RespParseErrorArrayLengthNotValid;
            return false;
           }
         bool failed=false;
         RespArray *a=new RespArray(len);
         Ref<RespValue>v;
         for(int i=0; i<len; i++)
           {
            if(parseRespValue(buf,v)) a.set(i,v.r);
            else
              {
               failed=true; break;
              }
           }
         if(failed) delete a;
         else
           {
            res=a;
            return true;
           }
        }
     }
   return false;
  }
//+------------------------------------------------------------------+
