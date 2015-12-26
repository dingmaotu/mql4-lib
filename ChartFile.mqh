//+------------------------------------------------------------------+
//|                                                    ChartFile.mqh |
//|                                          Copyright 2015, Li Ding |
//|                                                dingmaotu@126.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, Li Ding"
#property link      "dingmaotu@126.com"
#property strict
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class ChartFile
  {
private:
   string            m_symbol;
   int               m_period;

   int               m_file_handle;
public:
                     ChartFile(string symbol,int period);
                    ~ChartFile();
   string            GetSymbol() const {return m_symbol;}
   int               GetPeriod() const {return m_period;}


   void              OpenChart();
   void              CloseChart();
   bool              IsClosed();

   void              WriteHeader();
   void              SkipHeader();

   long              GetNumberOfRecords();

   void              GotoRecord(int shift);
   void              ReadRecord(MqlRates &rs);

   void              Flush();
   void              WriteRecord(const MqlRates &r);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ChartFile::ChartFile(string symbol,int period)
  {
   m_symbol=symbol;
   m_period=period;
   m_file_handle=-1;
   OpenChart();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ChartFile::~ChartFile()
  {
   CloseChart();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ChartFile::OpenChart()
  {
   if(m_file_handle<0)
     {
      m_file_handle=FileOpenHistory(m_symbol+(string)m_period+".hst",FILE_BIN|FILE_READ|FILE_WRITE|FILE_SHARE_WRITE|FILE_SHARE_READ|FILE_ANSI);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ChartFile::CloseChart()
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
bool ChartFile::IsClosed()
  {
   return m_file_handle<0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ChartFile::WriteHeader(void)
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
void ChartFile::SkipHeader(void)
  {
   if(m_file_handle>0)
     {
      FileSeek(m_file_handle,148,SEEK_SET);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ChartFile::Flush(void)
  {
   if(m_file_handle>0)
     {
      FileFlush(m_file_handle);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
long ChartFile::GetNumberOfRecords()
  {
   if(m_file_handle>0)
     {
      ulong size=FileSize(m_file_handle);
      long number=(size-148)/sizeof(MqlRates);
      return number<0?0:number;
     }
   else
     {
      return 0;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ChartFile::GotoRecord(int shift)
  {
   if(m_file_handle>0)
     {
      FileSeek(m_file_handle,148+sizeof(MqlRates)*shift,SEEK_SET);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ChartFile::ReadRecord(MqlRates &r)
  {
   if(m_file_handle>0)
     {
      FileReadStruct(m_file_handle,r);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ChartFile::WriteRecord(const MqlRates &r)
  {
   if(m_file_handle>0)
     {
      FileWriteStruct(m_file_handle,r);
     }
  }
//+------------------------------------------------------------------+
