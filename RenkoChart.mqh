//+------------------------------------------------------------------+
//|                                                   RenkoChart.mqh |
//|                                          Copyright 2015, Li Ding |
//|                                                dingmaotu@126.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, Li Ding"
#property link      "dingmaotu@126.com"
#property strict

#include <LiDing/Renko.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class RenkoChart: public Renko
  {
private:
   string            mSymbol;
   int               mPeriod;
   int               mBarSize;

   int               fileHandle;
   ulong             lastPos;

   MqlRates          currentRate;
   int               writeHstHeader();
   void              writeRecord(double,double,double,double,long);
public:
                     RenkoChart(string symbol,int period,int barSize);
                    ~RenkoChart();
   string            getSymbol() const {return mSymbol;}
   int               getPeriod() const {return mPeriod;}
   int               getBarSize() const {return mBarSize;}
   void              loadHistory(MqlRates &rs[],int size);
   void              onNewBar(int total,int pBars,double const &pOpen[],double const &pHigh[],
                              double const &pLow[],double const &pClose[],long const &pVolume[]);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
RenkoChart::RenkoChart(string symbol,int period,int barSize)
   :Renko(barSize*Point)
  {
   mSymbol=symbol;
   mPeriod=period;
   mBarSize=barSize;
   fileHandle=writeHstHeader();
   currentRate.spread=0;
   currentRate.tick_volume=0;
   currentRate.real_volume=0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
RenkoChart::~RenkoChart()
  {
   if(fileHandle>0)
     {
      FileClose(fileHandle);
      fileHandle=-1;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int RenkoChart::writeHstHeader(void)
  {
   int      fileVersion=401;
   string   fileCopyright="(C)opyright 2003, MetaQuotes Software Corp.";
   int      unused[13];

   int h=FileOpenHistory(mSymbol+(string)mPeriod+".hst",FILE_BIN|FILE_WRITE|FILE_SHARE_WRITE|FILE_SHARE_READ|FILE_ANSI);
   if(h>0)
     {
      ArrayInitialize(unused,0);
      FileWriteInteger(h,fileVersion,LONG_VALUE);
      FileWriteString(h,fileCopyright,64);
      FileWriteString(h,mSymbol,12);
      FileWriteInteger(h,mPeriod,LONG_VALUE);
      FileWriteInteger(h,Digits,LONG_VALUE);
      FileWriteInteger(h,0,LONG_VALUE);
      FileWriteInteger(h,0,LONG_VALUE);
      FileWriteArray(h,unused,0,13);
      FileFlush(h);
      lastPos=FileTell(h);
     }
   return h;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void RenkoChart::writeRecord(double pOpen,double pHigh,double pLow,double pClose,long pVolume)
  {
   currentRate.open=pOpen;
   currentRate.high=pHigh;
   currentRate.low=pLow;
   currentRate.close=pClose;
   currentRate.tick_volume=pVolume;
   FileWriteStruct(fileHandle,currentRate);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void RenkoChart::loadHistory(MqlRates &rs[],int size)
  {
   if(fileHandle>0 && ArraySize(rs)>=size && size>0)
     {
      int newBars=0;
      for(int i=0; i<size; i++)
        {
         currentRate.time=rs[i].time;
         newBars=loadRate(rs[i]);
         if(newBars>0)
           {
            for(int j=getBars()-newBars-1; j<getBars()-1; j++)
              {
               writeRecord(open[j],high[j],low[j],close[j],volume[j]);
               currentRate.time++;
              }
            lastPos=FileTell(fileHandle);
           }
        }
      onNewBar(getBars(),0,open,high,low,close,volume);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void RenkoChart::onNewBar(int total,int pBars,const double &pOpen[],const double &pHigh[],const double &pLow[],const double &pClose[],const long &pVolume[])
  {
   if(fileHandle>0)
     {
      if(Time[0]>currentRate.time)
        {
         currentRate.time=Time[0];
        }
      FileSeek(fileHandle,lastPos,SEEK_SET);
      if(pBars>0)
        {
         for(int i=total-pBars-1; i<total-1; i++)
           {
            writeRecord(pOpen[i],pHigh[i],pLow[i],pClose[i],pVolume[i]);
            currentRate.time++;
           }
         lastPos=FileTell(fileHandle);
        }
      writeRecord(pOpen[total-1],pHigh[total-1],pLow[total-1],pClose[total-1],pVolume[total-1]);
      FileFlush(fileHandle);
     }
  }
//+------------------------------------------------------------------+
