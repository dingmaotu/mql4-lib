//+------------------------------------------------------------------+
//| Module: Format/Json.mqh                                          |
//| This file is part of the mql4-lib project:                       |
//|     https://github.com/dingmaotu/mql4-lib                        |
//|                                                                  |
//| Copyright 2018 Li Ding <dingmaotu@126.com>                       |
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
//| This is an implementation of the JSON serilization format, both  |
//| Parsing and Encoding.                                            |
//| It references `https://www.json.org/`                            |
//+------------------------------------------------------------------+

#include "../Lang/Pointer.mqh"
#include "../Lang/String.mqh"
#include "../Collection/Vector.mqh"
#include "../Collection/HashMap.mqh"

#define EOF ((unichar)-1)
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class JsonValue
  {
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
JsonValue *null=new JsonValue;
EnsureDelete ensureDeleteNull(null);
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class JsonBoolean: public JsonValue
  {
public:
   bool              value;
                     JsonBoolean(bool v):value(v) {}
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class JsonString: public JsonValue
  {
public:
   string            value;
                     JsonString(string v):value(v) {}
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class JsonNumber: public JsonValue
  {
public:
   double            value;
                     JsonNumber(double v):value(v) {}
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class JsonArray: public JsonValue
  {
public:
   JsonValue        *value[];
                     JsonArray() {}
                    ~JsonArray()
     {
      int len=ArraySize(value);
      for(int i=0; i<len; i++)
        {
         if(value[i]!=null)
           {
            SafeDelete(value[i]);
           }
        }
     }

   JsonValue        *operator[](int i) const {return value[i];}
   int               length() const {return ArraySize(value);}
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class JsonObject: public JsonValue
  {
public:
   HashMap<string,JsonValue*>value;

                     JsonObject() {}
                    ~JsonObject()
     {
      foreachm(string,k,JsonValue*,v,value)
        {
         if(v!=null) SafeDelete(v);
        }
     }
   JsonValue        *operator[](const string key) const {return value.get(key,NULL);}
   void              set(const string key,JsonValue *v)
     {
      if(v!=NULL && CheckPointer(v)!=POINTER_INVALID)
        {
         JsonValue *item=value.get(key,null);
         if(item!=null)
           {
            SafeDelete(item);
           }
         value.set(key,v);
        }
     }

   bool              getBoolean(const string key) const {return dynamic_cast<JsonBoolean*>(value.get(key,NULL)).value;}
   double            getNumber(const string key) const {return dynamic_cast<JsonNumber*>(value.get(key,NULL)).value;}
   string            getString(const string key) const {return dynamic_cast<JsonString*>(value.get(key,NULL)).value;}
   JsonArray        *getArray(const string key) const {return dynamic_cast<JsonArray*>(value.get(key,NULL));}
   JsonObject       *getObject(const string key) const {return dynamic_cast<JsonObject*>(value.get(key,NULL));}

   void              setBoolean(const string key,const bool v)
     {
      JsonValue *item=value.get(key,null);
      if(item!=null)
        {
         SafeDelete(item);
        }
      value.set(key,new JsonBoolean(v));
     }
   void              setNumber(const string key,const double v)
     {
      JsonValue *item=value.get(key,null);
      if(item!=null)
        {
         SafeDelete(item);
        }
      value.set(key,new JsonNumber(v));
     }
   void              setString(const string key,const string v)
     {
      JsonValue *item=value.get(key,null);
      if(item!=null)
        {
         SafeDelete(item);
        }
      value.set(key,new JsonString(v));
     }
   void              setArray(const string key,JsonArray *v)
     {
      if(v!=NULL && CheckPointer(v)!=POINTER_INVALID)
        {
         JsonValue *item=value.get(key,null);
         if(item!=null)
           {
            SafeDelete(item);
           }
         value.set(key,v);
        }
     }
   void              setObject(const string key,JsonObject *v)
     {
      if(v!=NULL && CheckPointer(v)!=POINTER_INVALID)
        {
         JsonValue *item=value.get(key,null);
         if(item!=null)
           {
            SafeDelete(item);
           }
         value.set(key,v);
        }
     }

   int               size() const {return value.size();}
   bool              isEmpty() const {return value.size()==0;}
   bool              remove(string key) {return value.remove(key);}
   void              clear() {value.clear();}
   bool              contains(const string key) const {return value.contains(key);}

   JsonArray        *keys() const
     {
      JsonArray *a=new JsonArray;
      if(value.size()==0) return a;
      Vector<string>v;
      value.keys(v);
      int len=v.size();
      ArrayResize(a.value,len);
      for(int i=0; i<len; i++)
        {
         a.value[i]=new JsonString(v[i]);
        }
      return a;
     }
   JsonArray        *values() const
     {
      JsonArray *a=new JsonArray;
      if(value.size()==0) return a;
      Vector<JsonValue*>v;
      value.values(v);
      v.toArray(a.value);
      return a;
     }
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CharStream
  {
private:
   int               m_line;
   int               m_col;
   unichar           m_buf[];
protected:
   bool              hasBufferedChar() const {return ArraySize(m_buf)>0;}
   unichar           popBufferedChar()
     {
      int len=ArraySize(m_buf);
      if(len>0)
        {
         unichar c=m_buf[len-1];
         ArrayResize(m_buf,len-1);
         return c;
        }
      else
        {
         return EOF;
        }
     }
   virtual unichar   realNextChar()=0;

                     CharStream():m_line(1),m_col(0) {}
public:
   unichar           nextChar()
     {
      unichar c;
      if(hasBufferedChar())
         c=popBufferedChar();
      else
        {
         c=realNextChar();
         if(c=='\n')
           {
            m_line+=1;
            m_col=0;
           }
         else
           {
            m_col++;
           }
        }
      return c;
     }
   void              pushChar(unichar c)
     {
      int len=ArraySize(m_buf);
      ArrayResize(m_buf,len+1,10);
      m_buf[len]=c;
     }

   string            getPos() const {return StringFormat("%d:%d",m_line,m_col);}

   virtual bool      hasError() const;
   virtual string    getError() const;
   virtual bool      isEnd() const;
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class StringCharStream: public CharStream
  {
private:
   int               m_index;
   string            m_value;

   bool              m_hasError;
protected:
   unichar           realNextChar()
     {
      if(m_index>=StringLen(m_value))
        {
         return EOF;
        }
      unichar c=NextChar(m_value,m_index);
      if(c==EOF)
        {
         m_hasError=true;
        }
      return c;
     }
public:
                     StringCharStream(const string s=""):m_index(0),m_value(s),m_hasError(false) {}

   void              reset() {m_index=0; m_hasError=false;}
   void              setSource(const string s) {reset(); m_value=s;}

   bool              isEnd() const {return m_index>=StringLen(m_value);}
   bool              hasError() const {return m_hasError;}
   string            getError() const {return m_hasError?"Invalid UTF16 character sequence":"";}
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Json
  {
private:
   CharStream       *m_stream;
   string            m_error;
public:
   static string     LIT_NULL;
   static string     LIT_TRUE;
   static string     LIT_FALSE;

                     Json():m_stream(NULL),m_error("") {}

   // Json does not own the CharStream
                     Json(CharStream *stream):m_stream(stream),m_error("") {}
                     Json(CharStream &stream):m_stream(GetPointer(stream)),m_error("") {}

   bool              skipLiteral(const string &literal)
     {
      for(int i=0; i<StringLen(literal);)
        {
         unichar c=NextChar(literal,i);
         unichar c2=m_stream.nextChar();
         if(c!=c2) return false;
        }
      return true;
     }

   bool              skipWS()
     {
      unichar c=-1;
      do
        {
         c=m_stream.nextChar();
        }
      while(c==0x0009 || c==0x000a || c==0x000d || c==0x0020);
      m_stream.pushChar(c);
      return true;
     }

   JsonString       *parseString()
     {
      string value;
      unichar c=m_stream.nextChar();
      if(c!='"')
        {
         m_error="string start expecting '\"'";
         return NULL;
        }
      // characters
      ushort carray[];
      do
        {
         unichar cc=(unichar)-1;
         c=m_stream.nextChar();

         if(c=='"') // end of string
           {
            value=ShortArrayToString(carray);
            return new JsonString(value);
           }
         if(c=='\\') // escape
           {
            if(!parseEscape(cc))
              {
               return NULL;
              }
           }
         else if(c>=0x0020 && c<=0x10ffff) // normal character
           {
            cc=c;
           }
         else // !!!
           {
            m_error="Invaid character encountered";
            return NULL;
           }
         // encode cc to string value
         int len=ArraySize(carray);
         if(cc<0x10000)
           {
            ArrayResize(carray,len+1,10);
            carray[len]=(ushort)cc;
           }
         else
           {
            ArrayResize(carray,len+2,10);
            cc-=0x10000;
            carray[len+1]=(ushort)(0xDC00|(cc&0x3FF));
            cc>>=10;
            carray[len]=(ushort)(0xD800|(cc&0x3FF));
           }
        }
      while(true);
     }

   bool              parseEscape(unichar &value)
     {
      unichar c=m_stream.nextChar();
      switch(c)
        {
         case '"':
         case '\\':
         case '/':
            value=c;
            return true;
         case 'b':
            value=0x08;
            return true;
         case 'n':
            value='\n';
            return true;
         case 'r':
            value='\r';
            return true;
         case 't':
            value='\t';
            return true;
         case 'u':  // four hex digits
           {
            value=0;
            for(int i=0; i<4; i++)
              {
               c=m_stream.nextChar();
               if(c>='0' && c<='9')
                 {
                  value*=16;
                  value+=c-'0';
                 }
               else if(c>='a' && c<='f')
                 {
                  value*=16;
                  value+=(c-'a')+10;
                 }
               else if(c>='A' && c<='F')
                 {
                  value*=16;
                  value+=(c-'A')+10;
                 }
               else
                 {
                  m_error="error parsing escaped hex character!";
                  return false;
                 }
              }
            return true;
           }
         default:
            m_error="not a valid escape character!";
            return false;
        }
     }

   JsonNumber       *parseNumber()
     {
      double value;
      int sign,intValue;
      bool r=parseInt(sign,intValue);
      if(!r)
        {
         m_error="error parsing number: invalid integer part";
         return NULL;
        }
      double fracValue;
      r=parseFrac(fracValue);
      if(!r)
        {
         m_error="error parsing number: invalid fractional part";
         return NULL;
        }
      int expValue;
      r=parseExp(expValue);
      if(!r)
        {
         m_error="error parsing number: invalid exponential part";
         return NULL;
        }
      value=sign*(intValue+fracValue)*MathPow(10,expValue);
      return new JsonNumber(value);
     }

   bool              parseInt(int &sign,int &value)
     {
      sign=1;
      unichar c=m_stream.nextChar();
      if(c=='-')
        {
         sign=-1;
         c=m_stream.nextChar();
        }
      value=0;
      if(c=='0') // 0
        {
         sign=1;
         return true;
        }
      else if(c<='9' && c>='1') // onenine 0..9
        {
         do
           {
            value*=10;
            value+=(int)(c-'0');
            c=m_stream.nextChar();
           }
         while(c<='9' && c>='0');
         m_stream.pushChar(c);
         return true;
        }
      else
        {
         return false;
        }
     }

   bool              parseFrac(double &value)
     {
      unichar c=m_stream.nextChar();
      value=0.0;
      if(c=='.')
        {
         double n=1.0;
         c=m_stream.nextChar();
         while(c<='9' && c>='0')
           {
            n*=0.1;
            value+=(c-'0')*n;
            c=m_stream.nextChar();
           }
        }
      m_stream.pushChar(c);
      return true;
     }

   bool              parseExp(int &value)
     {
      int sign=1;
      value=0;
      unichar c=m_stream.nextChar();

      if(c!='E' && c!='e')
        {
         m_stream.pushChar(c);  // match ""
         return true;
        }
      c=m_stream.nextChar();
      if(c=='+' || c=='-') // match + -
        {
         sign=(c=='-')?-1:1;
         c=m_stream.nextChar();
        }
      if(c<'0' || c>'9')
        {
         return false;
        }
      do
        {
         value*=10;
         value+=(int)(c-'0');
         c=m_stream.nextChar();
        }
      while(c<='9' && c>='0');
      m_stream.pushChar(c);
      value*=sign;
      return true;
     }

   JsonArray        *parseArray()
     {
      unichar c=m_stream.nextChar();
      if(c!='[')
        {
         m_error="array start expecting '['";
         return NULL;
        }
      skipWS();
      JsonArray *res=new JsonArray();
      c=m_stream.nextChar();
      if(c==']')
        {
         return res;
        }
      m_stream.pushChar(c);
      do
        {
         skipWS();
         JsonValue *v=parseValue();
         if(v!=NULL)
           {
            ArrayResize(res.value,res.length()+1,10);
            res.value[res.length()-1]=v;
           }
         else
           {
            delete res;
            return NULL;
           }
         skipWS();
         c=m_stream.nextChar();
        }
      while(c==',');
      if(c==']')
        {
         return res;
        }
      else
        {
         m_error="array end expecting ']'";
         delete res;
         return NULL;
        }
     }

   JsonObject       *parseObject()
     {
      unichar c=m_stream.nextChar();
      if(c!='{')
        {
         m_error="obejct start expecting '{'";
         return NULL;
        }
      skipWS();
      JsonObject *res=new JsonObject();
      c=m_stream.nextChar();
      if(c=='}')
        {
         return res;
        }
      m_stream.pushChar(c);
      do
        {
         skipWS();
         JsonString *s=parseString();
         if(s==NULL)
           {
            delete res;
            return NULL;
           }
         skipWS();
         c=m_stream.nextChar();
         if(c!=':')
           {
            m_error="object member expecting ':'";
            delete res;
            return NULL;
           }
         skipWS();
         JsonValue *v=parseValue();
         if(v!=NULL)
           {
            res.set(s.value,v);
            delete s;
           }
         else
           {
            delete s;
            delete res;
            return NULL;
           }
         skipWS();
         c=m_stream.nextChar();
        }
      while(c==',');

      if(c=='}')
        {
         return res;
        }
      else
        {
         m_error="object end expecting '}'";
         delete res;
         return NULL;
        }
     }

   JsonValue        *parseValue()
     {
      unichar c=m_stream.nextChar();
      m_stream.pushChar(c);
      switch(c)
        {
         case '"': // string
            return parseString();
         case '[': // array
            return parseArray();
         case '{': // object
            return parseObject();
         case 't': // true
           {
            if(skipLiteral(LIT_TRUE))
               return new JsonBoolean(true);
            else
              {
               m_error="error parsing true";
               return NULL;
              }
           }
         case 'f': // false
           {
            if(skipLiteral(LIT_FALSE))
               return new JsonBoolean(false);
            else
              {
               m_error="error parsing false";
               return NULL;
              }
           }
         case 'n': // null
           {
            if(skipLiteral(LIT_NULL))
               return null;
            else
              {
               m_error="error parsing null";
               return NULL;
              }
           }
         default:
            if((c>='0' && c<='9') || c=='-')
              {
               return parseNumber();
              }
            else
              {
               m_error="expect one of six types of values";
               return NULL;
              }
        }
     }

   JsonValue        *parse(string json)
     {
      CharStream *org=m_stream;
      m_stream=new StringCharStream(json);
      JsonValue *res=parseValue();
      SafeDelete(m_stream);
      m_stream=org;
      return res;
     }

   bool              hasError() const {return m_error!="";}
   string            getError() const {return m_error;}
   void              reset() {m_error="";}

   string            dumps(const JsonValue &j);
  };
static string Json::LIT_NULL="null";
static string Json::LIT_TRUE="true";
static string Json::LIT_FALSE="false";
//+------------------------------------------------------------------+
