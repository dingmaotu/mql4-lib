//+------------------------------------------------------------------+
//|                                                   RenkoChart.mqh |
//|                                          Copyright 2015, Li Ding |
//|                                                dingmaotu@126.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, Li Ding"
#property link      "dingmaotu@126.com"
#property strict

#include "Renko.mqh"
#include <LiDing/Utils/ChartFile.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class RenkoChart: public Renko
  {
private:
   ChartFile         m_file;
   datetime          currentTime;
public:
                     RenkoChart(string symbol,int period,int barSize,bool std=false);
                    ~RenkoChart() {}
   string            getSymbol() const {return m_file.getSymbol();}
   int               getPeriod() const {return m_file.getPeriod();}

   MqlRates          getRate(int shift);

   void              loadHistory(MqlRates &rs[]);
   void              onNewBar(int total,int newBars,double const &open[],double const &high[],
                              double const &low[],double const &close[],long const &volume[]);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
RenkoChart::RenkoChart(string symbol,int period,int barSize,bool std)
   :Renko(barSize*Point,std),m_file(symbol,period)
  {
   if(m_file.getNumberOfRecords()==0)
     {
      m_file.writeHeader();
     }
   else
     {
      m_file.skipHeader();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
MqlRates RenkoChart::getRate(int shift)
  {
   MqlRates r;
   r.open = getOpen(shift);
   r.high = getHigh(shift);
   r.close= getClose(shift);
   r.low=getLow(shift);
   r.tick_volume = getVolume(shift);
   r.real_volume = 0;
   r.spread=0;
   r.time=currentTime;
   return r;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void RenkoChart::loadHistory(MqlRates &rs[])
  {
   int size=ArraySize(rs);
   if(!m_file.isClosed() && size>0)
     {
      int newBars=0;
      for(int i=0; i<size; i++)
        {
         currentTime=rs[i].time;
         newBars=moveByRate(rs[i]);

         if(newBars>0)
           {
            for(int j=newBars; j>0; j--)
              {
               MqlRates r = getRate(j);
               m_file.writeRecord(getRate(j));
               currentTime++;
              }
           }

        }

      m_file.writeRecord(getRate(0));
      m_file.flush();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void RenkoChart::onNewBar(int total,int newBars,const double &open[],const double &high[],const double &low[],const double &close[],const long &volume[])
  {
   if(!m_file.isClosed())
     {
      if(Time[0]>currentTime)
        {
         currentTime=Time[0];
        }

      m_file.updateRecord(getRate(newBars));

      if(newBars>0)
        {
         for(int j=newBars-1; j>=0; j--)
           {
            m_file.writeRecord(getRate(j));
            currentTime++;
           }
        }
      m_file.flush();
     }
  }
//+------------------------------------------------------------------+
