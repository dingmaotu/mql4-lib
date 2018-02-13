//+------------------------------------------------------------------+
//| Module: Utils/File.mqh                                           |
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

#include "../Lang/Mql.mqh"
#include "../Lang/String.mqh"
//+------------------------------------------------------------------+
//| File IO inside the sandbox                                       |
//+------------------------------------------------------------------+
class File
  {
protected:
   int               m_handle;

                     File(string name,int flags,int delimiter=0,int codepage=CP_ACP):m_handle(INVALID_HANDLE)
     {
      m_handle=FileOpen(name,flags,delimiter,codepage);
     }
   void              reopen(string name,int flags,int delimiter=0,int codepage=CP_ACP)
     {
      close();
      m_handle=FileOpen(name,flags,delimiter,codepage);
     }
   void              close() {if(m_handle!=INVALID_HANDLE)FileClose(m_handle);}
public:
                    ~File() {close();}

   // check if file or directory existed
   static bool       exist(string name,bool common=false) {return FileIsExist(name,common?FILE_COMMON:0) || GetLastError()==ERR_FILE_IS_DIRECTORY;}
   static bool       isDirectory(string name,bool common=false) {return !FileIsExist(name,common?FILE_COMMON:0) && GetLastError()==ERR_FILE_IS_DIRECTORY;}
   static bool       remove(string name,bool common=false) {return FileDelete(name,common?FILE_COMMON:0);}
   static bool       copy(string src,string dst,bool rewrite=false, bool common=false) {return FileCopy(src,common?FILE_COMMON:0,dst,rewrite?FILE_REWRITE:0);}
   static bool       move(string src,string dst,bool rewrite=false, bool common=false) {return FileMove(src,common?FILE_COMMON:0,dst,rewrite?FILE_REWRITE:0);}

   static bool       createFolder(string name, bool common=false) {return FolderCreate(name,common?FILE_COMMON:0);}
   static bool       removeFolder(string name, bool common=false) {return FolderDelete(name,common?FILE_COMMON:0);}
   static bool       cleanFolder(string name,bool common=false) {return FolderClean(name,common?FILE_COMMON:0);}

   static datetime   getCreateDate(string name, bool common=false) {return (datetime)FileGetInteger(name,FILE_CREATE_DATE,common);}
   static datetime   getModifyDate(string name, bool common=false) {return (datetime)FileGetInteger(name,FILE_MODIFY_DATE,common);}
   static datetime   getAccessDate(string name, bool common=false) {return (datetime)FileGetInteger(name,FILE_ACCESS_DATE,common);}
   static long       size(string name,bool common=false) {return FileGetInteger(name,FILE_SIZE,common);}

   bool              valid() const {return m_handle!=INVALID_HANDLE;}

   datetime          getCreateDate() {return (datetime)FileGetInteger(m_handle,FILE_CREATE_DATE);}
   datetime          getModifyDate() {return (datetime)FileGetInteger(m_handle,FILE_MODIFY_DATE);}
   datetime          getAccessDate() {return (datetime)FileGetInteger(m_handle,FILE_ACCESS_DATE);}

   bool              end() const {return FileIsEnding(m_handle);}
   ulong             size() const {return FileSize(m_handle);}
   ulong             tell() const {return FileTell(m_handle);}

   bool              seek(long offset,ENUM_FILE_POSITION origin=SEEK_CUR) {return FileSeek(m_handle,offset,origin);}
   void              flush() {FileFlush(m_handle);}

   template<typename T>
   uint              read(T &array[],int start=0,int count=WHOLE_ARRAY) {return FileReadArray(m_handle,array,start,count);}
   template<typename T>
   uint              write(const T &array[],int start=0,int count=WHOLE_ARRAY) {return FileWriteArray(m_handle,array,start,count);}
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class BinaryFile: public File
  {
public:
   //--- flags: FILE_READ | FILE_WRITE | FILE_SHARED_READ | FILE_SHARED_WRITE | FILE_COMMON
                     BinaryFile(string name,int flags):File(name,flags|FILE_BIN){}
   void              reopen(string name,int flags) {reopen(name,flags|FILE_BIN);}

   double            readDouble(int size=DOUBLE_VALUE) const {return FileReadDouble(m_handle,size);}
   float             readFloat() const {return FileReadFloat(m_handle);}
   long              readLong() const {return FileReadLong(m_handle);}
   int               readInteger(int size=INT_VALUE) const {return FileReadInteger(m_handle,size);}
   string            readString(int length) const {return FileReadString(m_handle,length);}

   template<typename T>
   uint              readStruct(T &value,int size=-1) const {return FileReadStruct(m_handle,value,size);}

   uint              writeDouble(double value,int size=DOUBLE_VALUE) {return FileWriteDouble(m_handle,value,size);}
   uint              writeFloat(float value) {return FileWriteFloat(m_handle,value);}
   uint              writeInteger(int value,int size=INT_VALUE) {return FileWriteInteger(m_handle,value,size);}
   uint              writeLong(long value) {return FileWriteLong(m_handle,value);}
   uint              writeString(string value,int length) {return FileWriteString(m_handle,value,length);}

   template<typename T>
   uint              writeStruct(const T &value,int size=-1) const {return FileWriteStruct(m_handle,value,size);}
  };
//+------------------------------------------------------------------+
//| By default text is encoded by the specified codepage             |
//| For raw UTF-16, specify FILE_UNICODE in flags                    |
//+------------------------------------------------------------------+
class TextFile: public File
  {
public:
   //--- flags: FILE_READ | FILE_WRITE | FILE_SHARED_READ | FILE_SHARED_WRITE | FILE_COMMON | FILE_UNICODE
                     TextFile(string name,int flags,int codepage=CP_ACP):File(name,flags|FILE_TXT|FILE_ANSI,0,codepage) {}
   void              reopen(string name,int flags,int codepage=CP_ACP) {File::reopen(name,flags|FILE_TXT|FILE_ANSI,0,codepage);}

   string            readLine() const {return FileReadString(m_handle);}
   uint              write(string value) const {return FileWriteString(m_handle,value);}
   uint              writeLine(string value) const {return FileWriteString(m_handle,value+"\n");}
  };
//+------------------------------------------------------------------+
//| By default text is encoded by the specified codepage             |
//| For raw UTF-16, specify FILE_UNICODE in flags                    |
//+------------------------------------------------------------------+
class CsvFile: public File
  {
private:
   string            m_delimiter;
public:
   //--- flags: FILE_READ | FILE_WRITE | FILE_SHARED_READ | FILE_SHARED_WRITE | FILE_COMMON | FILE_UNICODE
                     CsvFile(string name,int flags,ushort delimiter=',',int codepage=CP_ACP):File(name,flags|FILE_CSV|FILE_ANSI,delimiter,codepage)
     {
      StringSetCharacter(m_delimiter,0,delimiter);
     }

   void              reopen(string name,int flags,ushort delimiter=',',int codepage=CP_ACP)
     {
      File::reopen(name,flags|FILE_CSV|FILE_ANSI,delimiter,codepage);
      StringSetCharacter(m_delimiter,0,delimiter);
     }

   bool              isLineEnding() const {return FileIsLineEnding(m_handle);}

   string            readString() const {return FileReadString(m_handle);}
   double            readNumber() const {return FileReadNumber(m_handle);}
   datetime          readDateTime() const {return FileReadDatetime(m_handle);}
   bool              readBool() const {return FileReadBool(m_handle);}

   uint              writeString(string value) {return FileWriteString(m_handle,value);}
   uint              writeDateTime(datetime value) {return FileWriteString(m_handle,TimeToString(value));}
   uint              writeNumber(double value) {return FileWriteString(m_handle,DoubleToString(value,8));}
   uint              writeInteger(int value) {return FileWriteString(m_handle,IntegerToString(value));}
   uint              writeBool(bool value) {return FileWriteString(m_handle,value?"true":"false");}

   uint              writeLine(string value) {return FileWriteString(m_handle,value+"\n");}

   uint              writeDelimiter() {return FileWriteString(m_handle,m_delimiter);}
   uint              writeNewline() {return FileWriteString(m_handle,"\n");}

   uint              writeFields(const string &fields[])
     {
      return FileWrite(m_handle,StringJoin(fields,m_delimiter));
     }
  };
//+------------------------------------------------------------------+
//| Iterator for a file search pattern. For example:                 |
//| for(FileIterator it("*.txt"); !it.end(); it.next())              |
//| {                                                                |
//|   string filename = it.current();                                |
//| }                                                                |
//+------------------------------------------------------------------+
class FileIterator
  {
protected:
   string            m_filter;
   long              m_handle;

   bool              m_found;
   string            m_current;

   int               m_condition;
public:
                     FileIterator(string filter,bool common=false):m_filter(filter),m_condition(0)
     {
      m_handle=FileFindFirst(m_filter,m_current,common?FILE_COMMON:0);
      m_found=m_handle!=INVALID_HANDLE;
     }
                    ~FileIterator() {FileFindClose(m_handle);}
   void              next() { m_found=FileFindNext(m_handle,m_current); }
   string            current() const {return m_current;}
   bool              end() const {return !m_found;}

   bool              trueForOnce() {return m_condition++==0;}
   bool              assign(string &var) {if(!m_found) return false; else {var=m_current;return true;}}
  };

#define foreachfile(fnvar,filter) for(FileIterator __it__(filter);__it__.trueForOnce();) for(string fnvar;__it__.assign(fnvar);__it__.next())
//+------------------------------------------------------------------+
