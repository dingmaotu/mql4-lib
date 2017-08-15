//+------------------------------------------------------------------+
//| Module: Utils/HistoryFile.mqh                                    |
//| This file is part of the mql4-lib project:                       |
//|     https://github.com/dingmaotu/mql4-lib                        |
//|                                                                  |
//| Copyright 2015-2016 Li Ding <dingmaotu@126.com>                  |
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
//+------------------------------------------------------------------+
//| A special file that stores quotes data                           |
//+------------------------------------------------------------------+
class HistoryFile
  {
   ObjectAttrRead(string,symbol,Symbol);
   ObjectAttrRead(int,period,Period);
private:
   const int         HEADER_SIZE;
   const int         RECORD_SIZE;
   const string      HISTORY_FILENAME;

   long              m_numRecords;
   int               m_handle;
public:
                     HistoryFile(string symbol,int period);
                    ~HistoryFile() { close(); }

   bool              truncate();

   bool              open();
   void              close();
   bool              isClosed();

   ulong             size() const {if(m_handle>0) return FileSize(m_handle); else return -1;}
   long              getNumberOfRecords();
   void              flush();

   void              writeHeader();
   void              skipHeader();

   void              gotoRecord(int shift);
   void              readRecord(MqlRates &rs);
   void              writeRecord(const MqlRates &r);
   void              updateRecord(const MqlRates &r);
  };
//+------------------------------------------------------------------+
//| Only initializes internal members without really opening the file|
//+------------------------------------------------------------------+
HistoryFile::HistoryFile(string symbol,int period)
   :HEADER_SIZE(148),RECORD_SIZE(sizeof(MqlRates)),HISTORY_FILENAME(StringFormat("%s%d.hst",symbol,period))
  {
   m_symbol=symbol;
   m_period=period;
   m_handle=-1;
  }
//+------------------------------------------------------------------+
//| There is no way to resize a file in MQL                          |
//| This is a workaround                                             |
//+------------------------------------------------------------------+
bool HistoryFile::truncate()
  {
   m_handle=FileOpenHistory(HISTORY_FILENAME,FILE_BIN|FILE_WRITE);
   if(m_handle!=-1)
     {
      FileClose(m_handle);
      m_handle=-1;
      return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
//| Open the history file for read/write                             |
//+------------------------------------------------------------------+
bool HistoryFile::open()
  {
   if(m_handle==-1)
     {
      m_handle=FileOpenHistory(HISTORY_FILENAME,FILE_BIN|FILE_READ|FILE_WRITE|FILE_SHARE_WRITE|FILE_SHARE_READ);
      return m_handle!=-1;
     }
//--- m_handle has a valid value
   return true;
  }
//+------------------------------------------------------------------+
//| Close the history file                                           |
//+------------------------------------------------------------------+
void HistoryFile::close()
  {
   if(m_handle!=-1)
     {
      FileClose(m_handle);
      m_handle=-1;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool HistoryFile::isClosed()
  {
   return m_handle==-1;
  }
//+------------------------------------------------------------------+
//| Write standard history data header                               |
//| This is from PeriodConverter example                             |
//+------------------------------------------------------------------+
void HistoryFile::writeHeader(void)
  {
   if(m_handle>0)
     {
      int      file_version=401;
      string   file_copyright="(C)opyright 2003, MetaQuotes Software Corp.";
      int      unused[13];
      ArrayInitialize(unused,0);
      FileSeek(m_handle,0,SEEK_SET);
      FileWriteInteger(m_handle,file_version,LONG_VALUE);
      FileWriteString(m_handle,file_copyright,64);
      FileWriteString(m_handle,m_symbol,12);
      FileWriteInteger(m_handle,m_period,LONG_VALUE);
      FileWriteInteger(m_handle,Digits,LONG_VALUE);
      FileWriteInteger(m_handle,0,LONG_VALUE);
      FileWriteInteger(m_handle,0,LONG_VALUE);
      FileWriteArray(m_handle,unused,0,13);
      FileFlush(m_handle);
     }
  }
//+------------------------------------------------------------------+
//| Skip the standard header and to the start of the first record    |
//+------------------------------------------------------------------+
void HistoryFile::skipHeader(void)
  {
   if(m_handle>0) FileSeek(m_handle,HEADER_SIZE,SEEK_SET);
  }
//+------------------------------------------------------------------+
//| Ensure content be written to the disk                            |
//+------------------------------------------------------------------+
void HistoryFile::flush(void)
  {
   if(m_handle>0) FileFlush(m_handle);
  }
//+------------------------------------------------------------------+
//| Get the number of quote records in this history file             |
//+------------------------------------------------------------------+
long HistoryFile::getNumberOfRecords()
  {
   if(m_handle==-1) return -1;
   ulong size=FileSize(m_handle);
   if(size<148)
     {
      return 0;
     }
   else
     {
      long number=(long)((size-HEADER_SIZE)/RECORD_SIZE);
      return number<0?0:number;
     }
  }
//+------------------------------------------------------------------+
//| Go to the start of the specified record                          |
//+------------------------------------------------------------------+
void HistoryFile::gotoRecord(int shift)
  {
   if(m_handle>0 && shift>=0 && shift<m_numRecords)
     {
      FileSeek(m_handle,HEADER_SIZE+RECORD_SIZE*shift,SEEK_SET);
     }
  }
//+------------------------------------------------------------------+
//| Read the value of current record to the parameter                |
//+------------------------------------------------------------------+
void HistoryFile::readRecord(MqlRates &r)
  {
   if(m_handle>0)
     {
      FileReadStruct(m_handle,r);
     }
  }
//+------------------------------------------------------------------+
//| Write the record to current position                             |
//+------------------------------------------------------------------+
void HistoryFile::writeRecord(const MqlRates &r)
  {
   if(m_handle>0)
     {
      FileWriteStruct(m_handle,r);
      m_numRecords++;
     }
  }
//+------------------------------------------------------------------+
//| Update the record in current position                            |
//+------------------------------------------------------------------+
void HistoryFile::updateRecord(const MqlRates &r)
  {
   if(m_handle>0 && m_numRecords>0)
     {
      FileSeek(m_handle,-RECORD_SIZE,SEEK_CUR);
      FileWriteStruct(m_handle,r);
     }
  }
//+------------------------------------------------------------------+
