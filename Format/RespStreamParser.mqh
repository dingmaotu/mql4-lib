//+------------------------------------------------------------------+
//| Module: Format/RespStreamParser.mqh                              |
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
//| State for a RESP parse task                                      |
//+------------------------------------------------------------------+
enum RespParseState
  {
   RespParseInit,                 // begin to parse
   RespParseTypeDetermined,       // type prefix has been read
   RespParseLengthDetermined,     // for array and bytes (bulk string), length has been read
   RespParseDone                  // a value has been read
  };
//+------------------------------------------------------------------+
//| Parse task to keep states                                        |
//| Since we use a linked list to grow and shrink the stack, there is|
//| no depth limit for nesting arrays. In hiredis, you are restricted|
//| to 7 levels, but hiredis would have a better performance.        |
//+------------------------------------------------------------------+
class RespParseTask
  {
private:
   RespParseState    m_state;  // default RespParseInit
   RespType          m_type;   // in and after state RespParseTypeDetermined
   int               m_length; // in and after state RespParseLengthDetermined (length of array or bytes)
   RespValue        *m_value;  // in and after state RespParseDone

   RespParseTask    *m_parent; // parent == NULL means top level state and if parent != NULL means that this is a sub task for arrays
   int               m_element;// current element index if this is sub task for arrays
public:
                     RespParseTask(RespParseTask *parent)
   :m_state(RespParseInit),m_type(RespTypeNil),m_length(-1),m_value(NULL),m_parent(parent),m_element(0)
     {}

   //--- destructor not needed. m_value and m_parent are only references

   void              reset()
     {
      m_state=RespParseInit;
      m_type=RespTypeNil;
      m_length=-1;
      m_value=NULL;
      m_element=0;
     }

   // getters and setters
   RespParseState    getState() const {return m_state;}
   void              setState(RespParseState value) {m_state=value;}

   RespType          getType() const {return m_type;}
   void              setType(RespType value) {m_type=value;}

   int               getLength() const {return m_length;}
   void              setLength(int value) {m_length=value;}

   RespValue        *getValue() const {return m_value;}
   void              setValue(RespValue *value) {m_value=value;}

   bool              isTop() const {return m_parent==NULL;}
   RespParseTask    *getParent() const {return m_parent;}

   int               getElement() const {return m_element;}
   //--- we only increase the element index
   void              nextElement() {m_element++;}
  };
//+------------------------------------------------------------------+
//| A state machine based parser for the RESP protocol               |
//| Inspired by the hiredis replyReader implementation               |
//| This parser can handle incomplete input and resume from parsing  |
//| if more input is available. It keeps states by using its own     |
//| stack.                                                           |
//| If you are reading from a TCP stream, then it is best to use this|
//| parser.                                                          |
//+------------------------------------------------------------------+
class RespStreamParser: public RespParser
  {
private:
   RespParseError    m_error;  // error status
   RespParseTask    *m_task;   // parse task stack
   int               m_pos;    // current buffer position

   //--- buffer management
   const int         RESERVE_SIZE;
   int               m_size;
   char              m_buf[];
protected:
   bool              determineType();
   bool              seekNewline(int &len);
   bool              parseInteger(int len,long &value);
   bool              parseLineItem(int len);
   bool              parseLength(int len);
   bool              parseBytes();
   void              discardProcessed();

   void              clearStack()
     {
      // delete stack
      while(m_task.getParent()!=NULL)
        {
         RespParseTask *p=m_task.getParent();
         SafeDelete(m_task);
         m_task=p;
        }
      SafeDelete(m_task.getValue());
      m_task.reset();
     }
public:
                     RespStreamParser()
   :m_error(RespParseErrorNone),m_pos(0),m_size(0),RESERVE_SIZE(3*1024)
     {
      m_task=new RespParseTask(NULL);
     }

                    ~RespStreamParser()
     {
      clearStack();
      SafeDelete(m_task);
     }

   RespParseError    getError() const {return m_error;}

   //--- feed input to the parser
   int               feed(char &buf[],int start=0,int count=WHOLE_ARRAY)
     {
      if(count==WHOLE_ARRAY) count=ArraySize(buf)-start;
      ArrayResize(m_buf,m_size+count,RESERVE_SIZE);
      int res=ArrayCopy(m_buf,buf,m_size,start,count);
      m_size=ArraySize(m_buf);
      return res;
     }

   void              reset()
     {
      clearStack();
      // reset buffer
      ArrayResize(m_buf,0,RESERVE_SIZE);
      m_pos=0;
      m_size=0;
     }

   RespValue        *parse();
  };
//+------------------------------------------------------------------+
//| read one byte and determine the type of next value               |
//| this method advances the m_pos 1 byte                            |
//+------------------------------------------------------------------+
bool RespStreamParser::determineType()
  {
   if(m_pos>=m_size)
     {
      m_error=RespParseErrorNeedMoreInput;
      return false;
     }
   char prefix=m_buf[m_pos];
   switch(prefix)
     {
      case '+':
         m_task.setType(RespTypeString);
         break;
      case '-':
         m_task.setType(RespTypeError);
         break;
      case ':':
         m_task.setType(RespTypeInteger);
         break;
      case '$':
         m_task.setType(RespTypeBytes); // could be Nil
         break;
      case '*':
         m_task.setType(RespTypeArray);
         break;
      default:
         // invalid prefix and abort the whole process
         m_error=RespParseErrorInvalidPrefix;
         return false;
     }
   m_pos++;
   m_task.setState(RespParseTypeDetermined);
   return true;
  }
//+------------------------------------------------------------------+
//| find next '\r\n' and if success, return the length of the content|
//| (before \r\n)                                                    |
//| it sets the global error flag                                    |
//+------------------------------------------------------------------+
bool RespStreamParser::seekNewline(int &len)
  {
   len=0;
   int i=m_pos;
   for(;i<m_size && m_buf[i]!='\r';i++);
   if(i==m_size || (i+1)>=m_size)
     {
      m_error=RespParseErrorNeedMoreInput;
      return false;
     }
   else
     {
      if(m_buf[i+1]!='\n')
        {
         m_error=RespParseErrorNewlineMalformed;
         return false;
        }
      else
        {
         len=i-m_pos;
         return true;
        }
     }
  }
//+------------------------------------------------------------------+
//| parse a long integer                                             |
//| this is used in parsing:                                         |
//|     * RespInteger value                                          |
//|     * RespBytes length                                           |
//|     * RespArray length                                           |
//| if returns false, it is a format error                           |
//| the error flag dependes on current value type and is set outside |
//| of this method                                                   |
//+------------------------------------------------------------------+
bool RespStreamParser::parseInteger(int len,long &value)
  {
   if(len == 0) return false;
   int i=m_pos;
   long sign=1;
   if(m_buf[i]=='-') {sign=-1;i++;}
   int end=m_pos+len;
   for(value=0;i<end;i++)
     {
      if(m_buf[i]>='0' && m_buf[i]<='9')
         value=value*10+(m_buf[i]-'0');
      else
        {
         m_error=RespParseErrorInvalidInteger;
         return false;
        }
     }
// integer is not minus sign only
   if(i!=(m_pos+1) || sign!=-1)
     {
      value*=sign;
      return true;
     }
   else
     {
      m_error=RespParseErrorInvalidInteger;
      return false;
     }
  }
//+------------------------------------------------------------------+
//| parse a line item that ends with "\r\n"                          |
//| returns true if successfull and creates a value for current state|
//| this method advances m_pos to next position                      |
//+------------------------------------------------------------------+
bool RespStreamParser::parseLineItem(int len)
  {
   if(m_task.getType()==RespTypeInteger)
     {
      long value;
      if(parseInteger(len,value))
        {
         m_task.setValue(new RespInteger(value));
         m_pos+=len+2;
         m_task.setState(RespParseDone);
         return true;
        }
      return false;
     }
   else // for RespString or RespError
     {
      string value=CharArrayToString(m_buf,m_pos,len,CP_UTF8);
      if(m_task.getType()==RespTypeError)
         m_task.setValue(new RespError(value));
      else
         m_task.setValue(new RespString(value));
      m_pos+=len+2;
      m_task.setState(RespParseDone);
      return true;
     }
  }
//+------------------------------------------------------------------+
//| parse length of bytes (bulk string) ro array                     |
//| length must be -1 (for Nil) or positive integer                  |
//| advances m_pos to next positon                                   |
//+------------------------------------------------------------------+
bool RespStreamParser::parseLength(int len)
  {
   long value;
   if(parseInteger(len,value))
     {
      m_task.setLength((int)value);
      m_pos+=len+2;
      m_task.setState(RespParseLengthDetermined);
      return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
//| parse a RespBytes or a RespNil                                   |
//| return true if a value is created                                |
//+------------------------------------------------------------------+
bool RespStreamParser::parseBytes()
  {
   if(m_task.getLength()==-1)
     {
      m_task.setValue(RespNil::getInstance());
      // Nil is length (-1) only, no subsequent contents
     }
   else
     {
      if(m_task.getLength()<=0)
        {
         m_error=RespParseErrorBytesLengthNotValid;
         return false;
        }
      // check if length exceeds buffer and the value properly ends with "\r\n"
      int end=m_pos+m_task.getLength();
      if(end>=m_size || end+1>=m_size)
        {
         m_error=RespParseErrorNeedMoreInput;
         return false;
        }
      else if(m_buf[end]!='\r' || m_buf[end+1]!='\n')
        {
         m_error=RespParseErrorNewlineMalformed;
         return false;
        }
      else
        {
         // read bytes
         RespBytes *bytes=new RespBytes(m_buf,m_pos,m_task.getLength());
         m_task.setValue(bytes);
         m_pos+=m_task.getLength()+2;
        }
     }
   m_task.setState(RespParseDone);
   return true;
  }
//+------------------------------------------------------------------+
//| discard all contents already parsed                              |
//+------------------------------------------------------------------+
void RespStreamParser::discardProcessed()
  {
   for(int i=0,j=m_pos;j<m_size;i++,j++)
      m_buf[i]=m_buf[j];
   ArrayResize(m_buf,m_size-m_pos,RESERVE_SIZE);
   m_size=ArraySize(m_buf);
  }
//+------------------------------------------------------------------+
//| a giant state machine that do parsing based on current task      |
//+------------------------------------------------------------------+
RespValue *RespStreamParser::parse()
  {
//--- clear previous errors
   m_error=RespParseErrorNone;
//--- begin parsing
   while(m_error==RespParseErrorNone)
     {
      switch(m_task.getState())
        {
         case RespParseInit:
            if(!determineType()) break;
            // if success, we fallthrough to next state
         case RespParseTypeDetermined:
           {
            int len;
            if(!seekNewline(len)) // if can not seek newline, break
               break;
            else
              {
               bool fallthrough=false;
               switch(m_task.getType())
                 {
                  case RespTypeString:
                  case RespTypeError:
                  case RespTypeInteger:
                     parseLineItem(len);
                     // we break always as there is no length determination for above types
                     break;
                  case RespTypeBytes:
                  case RespTypeArray:
                     fallthrough=parseLength(len);
                     break;
                 }
               if(!fallthrough) break;
              }
           }
         case RespParseLengthDetermined:
            if(m_task.getType()==RespTypeBytes)
              {
               if(!parseBytes()) break;
               // fallthrough
              }
            else
              {
               if(m_task.getLength()<0)
                  m_error=RespParseErrorArrayLengthNotValid;
               else
                 {
                  // for array, we need to push a new task to stack
                  RespArray *a=new RespArray(m_task.getLength());
                  m_task.setValue(a);
                  RespParseTask *s=new RespParseTask(m_task);
                  m_task=s;
                 }
               // break to start over
               break;
              }
         case RespParseDone:
            // if we process enough, just discard some previous storage to avoid unnecessary allocation
            if(m_pos>1024)
              {
               discardProcessed();
              }
            if(m_task.isTop())
              {
               RespValue *value=m_task.getValue();
               m_task.reset();
               return value;
              }
            else
              {
               RespParseTask *p=m_task.getParent();
               RespArray *a=dynamic_cast<RespArray*>(p.getValue());
               a.set(m_task.getElement(),m_task.getValue());
               if(a.size()==m_task.getElement()+1)
                 {
                  // pop state from stack
                  p.setState(RespParseDone);
                  SafeDelete(m_task);
                  m_task=p;
                 }
               else
                 {
                  m_task.nextElement();
                  m_task.setState(RespParseInit);
                 }
              }
        }
     }
//--- if there is format error
   if(m_error!=RespParseErrorNeedMoreInput) reset();
   return NULL;
  }
//+------------------------------------------------------------------+
