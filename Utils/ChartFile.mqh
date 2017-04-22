//+------------------------------------------------------------------+
//|                                              Utils/ChartFile.mqh |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015-2016, Li Ding"
#property link      "dingmaotu@hotmail.com"
#property strict
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class ChartFile
  {
private:
   const int         HEADER_SIZE;
   const int         RECORD_SIZE;

   string            m_symbol;
   int               m_period;

   long              m_numRecords;

   int               m_file_handle;

   long              hardGetNumberOfRecords();
public:
                     ChartFile(string symbol,int period);
                    ~ChartFile();
   string            getSymbol() const {return m_symbol;}
   int               getPeriod() const {return m_period;}


   void              openChart();
   void              closeChart();
   bool              isClosed();

   void              writeHeader();
   void              skipHeader();

   long              getNumberOfRecords() {return m_numRecords;}

   void              gotoRecord(int shift);
   void              readRecord(MqlRates &rs);

   void              flush();
   void              writeRecord(const MqlRates &r);
   void              updateRecord(const MqlRates &r);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ChartFile::ChartFile(string symbol,int period)
   :HEADER_SIZE(148),RECORD_SIZE(sizeof(MqlRates))
  {
   m_symbol=symbol;
   m_period=period;
   m_file_handle=-1;
   openChart();
   m_numRecords=hardGetNumberOfRecords();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ChartFile::~ChartFile()
  {
   closeChart();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ChartFile::openChart()
  {
   if(m_file_handle<0)
     {
      m_file_handle=FileOpenHistory(m_symbol+(string)m_period+".hst",FILE_BIN|FILE_READ|FILE_WRITE|FILE_SHARE_WRITE|FILE_SHARE_READ|FILE_ANSI);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ChartFile::closeChart()
  {
   if(m_file_handle>0)
     {
      FileClose(m_file_handle);
      m_file_handle=-1;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ChartFile::isClosed()
  {
   return m_file_handle<0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ChartFile::writeHeader(void)
  {
   if(m_file_handle>0)
     {
      int      file_version=401;
      string   file_copyright="(C)opyright 2003, MetaQuotes Software Corp.";
      int      unused[13];
      ArrayInitialize(unused,0);
      FileSeek(m_file_handle,0,SEEK_SET);
      FileWriteInteger(m_file_handle,file_version,LONG_VALUE);
      FileWriteString(m_file_handle,file_copyright,64);
      FileWriteString(m_file_handle,m_symbol,12);
      FileWriteInteger(m_file_handle,m_period,LONG_VALUE);
      FileWriteInteger(m_file_handle,Digits,LONG_VALUE);
      FileWriteInteger(m_file_handle,0,LONG_VALUE);
      FileWriteInteger(m_file_handle,0,LONG_VALUE);
      FileWriteArray(m_file_handle,unused,0,13);
      FileFlush(m_file_handle);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ChartFile::skipHeader(void)
  {
   if(m_file_handle>0)
     {
      FileSeek(m_file_handle,HEADER_SIZE,SEEK_SET);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ChartFile::flush(void)
  {
   if(m_file_handle>0)
     {
      FileFlush(m_file_handle);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
long ChartFile::hardGetNumberOfRecords()
  {
   if(m_file_handle>0)
     {
      ulong size=FileSize(m_file_handle);
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
   else
     {
      return 0;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ChartFile::gotoRecord(int shift)
  {
   if(m_file_handle>0 && shift>=0 && shift<m_numRecords)
     {
      FileSeek(m_file_handle,HEADER_SIZE+RECORD_SIZE*shift,SEEK_SET);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ChartFile::readRecord(MqlRates &r)
  {
   if(m_file_handle>0)
     {
      FileReadStruct(m_file_handle,r);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ChartFile::writeRecord(const MqlRates &r)
  {
   if(m_file_handle>0)
     {
      FileWriteStruct(m_file_handle,r);
      m_numRecords++;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ChartFile::updateRecord(const MqlRates &r)
  {
   if(m_file_handle>0 && m_numRecords>0)
     {
      FileSeek(m_file_handle,-RECORD_SIZE,SEEK_CUR);
      FileWriteStruct(m_file_handle,r);
     }
  }
//+------------------------------------------------------------------+
