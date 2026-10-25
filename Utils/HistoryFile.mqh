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

#ifdef __MQL5__
// STS native MT5 custom-rates output, copyright 2013-2026 Swiss Trading Society.
// Legacy HistoryFile API retained. No HST files or offline MT4 chart messages.
// Time-based bars retain their real minute timestamps. Repeated/nonchronological
// generated-bar times are assigned successive M1 slots, preserving bar ordering.
class HistoryFile
{
private:
 string m_symbol,m_output,m_owner;
 int m_period,m_digits,m_lock,m_cursor,m_dirty;
 bool m_replace;
 MqlRates m_rates[];
 uint hash(const string value) const
 {
  uint h=2166136261;
  for(int i=0;i<StringLen(value);i++){h^=(uint)StringGetCharacter(value,i);h*=16777619;}
  return h;
 }
 bool owned() const {return SymbolInfoInteger(m_output,SYMBOL_CUSTOM)!=0 && SymbolInfoString(m_output,SYMBOL_DESCRIPTION)==m_owner;}
public:
 HistoryFile(string symbol,int period):m_symbol(symbol),m_period(period),m_lock(INVALID_HANDLE),m_cursor(0),m_dirty(-1),m_replace(false)
 {
  m_digits=(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS);
  m_owner="STS HistoryFile v1|"+MQLInfoString(MQL_PROGRAM_NAME)+"|"+symbol+"|"+IntegerToString(period);
  // 12 source characters + separator + STS marker + 8 hash = 26 characters.
  m_output=StringSubstr(symbol,0,12)+"_STS_"+StringFormat("%08X",hash(m_owner));
 }
 ~HistoryFile(){close();}
 string getSymbol() const {return m_symbol;}
 string getOutputSymbol() const {return m_output;}
 int getPeriod() const {return m_period;}
 long getDigits() const {return m_digits;}
 bool truncate()
 {
  // Prepare a complete reconstruction in memory before replacing existing data.
  ArrayResize(m_rates,0);m_cursor=0;m_dirty=-1;m_replace=true;return true;
 }
 bool open()
 {
  if(m_lock!=INVALID_HANDLE)return true;
  m_lock=FileOpen("STS_History_"+StringFormat("%08X",hash(m_owner))+".lock",FILE_READ|FILE_WRITE|FILE_BIN|FILE_COMMON);
  if(m_lock==INVALID_HANDLE){Print("STS: output has another writer: ",m_output);return false;}
  bool isCustom=false;
  if(SymbolExist(m_output,isCustom))
  {
   if(!isCustom || !owned()){Print("STS: refusing unrelated output symbol ",m_output);close();return false;}
  }
  else
  {
   if(!CustomSymbolCreate(m_output,"STS\\Converted",m_symbol) || !CustomSymbolSetString(m_output,SYMBOL_DESCRIPTION,m_owner))
   {Print("STS: cannot create output ",m_output," error ",GetLastError());close();return false;}
  }
  if(!CustomSymbolSetInteger(m_output,SYMBOL_TRADE_MODE,SYMBOL_TRADE_MODE_DISABLED) || !SymbolSelect(m_output,true))
  {Print("STS: cannot configure output ",m_output," error ",GetLastError());close();return false;}
  if(!m_replace)
  {
   CopyRates(m_output,PERIOD_M1,(datetime)0,D'3000.12.31',m_rates);
   m_cursor=ArraySize(m_rates);
  }
  return true;
 }
 void close(){if(m_lock!=INVALID_HANDLE){FileClose(m_lock);m_lock=INVALID_HANDLE;}}
 bool isClosed() const {return m_lock==INVALID_HANDLE;}
 ulong size() const {return (ulong)ArraySize(m_rates)*sizeof(MqlRates);}
 long getNumberOfRecords() const {return ArraySize(m_rates);}
 void writeHeader(){m_cursor=0;}
 void skipHeader(){m_cursor=0;}
 void gotoRecord(int shift){if(shift>=0 && shift<ArraySize(m_rates))m_cursor=shift;}
 void readRecord(MqlRates &r){if(m_cursor>=0 && m_cursor<ArraySize(m_rates))r=m_rates[m_cursor++];}
 void writeRecord(const MqlRates &r)
 {
  if(isClosed() || r.time<=0 || !MathIsValidNumber(r.close))return;
  int n=ArraySize(m_rates),at=m_cursor;
  if(at<0 || at>n)at=n;
  if(at==n && ArrayResize(m_rates,n+1,n+256)!=n+1)return;
  m_rates[at]=r;
  m_rates[at].time=(datetime)((long)r.time/60*60);
  if(at>0 && m_rates[at].time<=m_rates[at-1].time)m_rates[at].time=m_rates[at-1].time+60;
  if(m_dirty<0 || at<m_dirty)m_dirty=at;
  m_cursor=at+1;
 }
 void updateRecord(const MqlRates &r)
 {
  int at=m_cursor-1;
  if(isClosed() || at<0 || at>=ArraySize(m_rates))return;
  datetime stamp=m_rates[at].time;m_rates[at]=r;m_rates[at].time=stamp;
  if(m_dirty<0 || at<m_dirty)m_dirty=at;
 }
 void flush()
 {
  if(isClosed() || m_dirty<0 || ArraySize(m_rates)==0)return;
  if(!owned()){Print("STS: output ownership changed; writes stopped: ",m_output);close();return;}
  int written=-1;
  if(m_replace)written=CustomRatesReplace(m_output,(datetime)0,D'3000.12.31',m_rates);
  else
  {
   MqlRates changed[];
   int count=ArraySize(m_rates)-m_dirty;
   ArrayCopy(changed,m_rates,0,m_dirty,count);
   written=CustomRatesUpdate(m_output,changed);
  }
  if(written>=0){m_replace=false;m_dirty=-1;}
  else Print("STS: custom rates write failed for ",m_output," error ",GetLastError());
 }
};
#else
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
#endif
