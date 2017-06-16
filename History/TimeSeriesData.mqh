//+------------------------------------------------------------------+
//|                                         Trade/TimeSeriesData.mqh |
//|                                          Copyright 2017, Li Ding |
//|                                            dingmaotu@hotmail.com |
//+------------------------------------------------------------------+
#property strict
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class TimeSeriesData
  {
private:
   string            m_symbol;
   ENUM_TIMEFRAMES   m_period;
   // new bars between updates; larger than 0 if has new bar
   long              m_newBars;
   datetime          m_lastBarDate;
protected:
   void              updateNewBar(datetime date);
public:
                     TimeSeriesData(string symbol,ENUM_TIMEFRAMES period):m_symbol(symbol),m_period(period){}

   static bool       refresh() {return RefreshRates();}

   long              getBars() const {return SeriesInfoInteger(m_symbol,m_period,SERIES_BARS_COUNT);}
   long              getBars(datetime startDate,datetime stopDate) const {return Bars(m_symbol,m_period,startDate,stopDate);}
   datetime          getFirstDate() const {return(datetime)SeriesInfoInteger(m_symbol,m_period,SERIES_FIRSTDATE); }
   datetime          getLastBarDate() const {return(datetime)SeriesInfoInteger(m_symbol,m_period,SERIES_LASTBAR_DATE); }
   datetime          getServerFirstDate() const {return(datetime)SeriesInfoInteger(m_symbol,m_period,SERIES_SERVER_FIRSTDATE); }
   datetime          getCurrentBarDate() const {int ps=PeriodSeconds(m_period);return TimeCurrent()/ps*ps;}

   void              update() {updateNewBar(getLastBarDate());}
   void              updateCurrent() {updateNewBar(getCurrentBarDate());}

   bool              isNewBar() const {return m_newBars>0;}
   long              getNewBars() const {return m_newBars;}

   double            getHigh(int shift) {return iHigh(m_symbol,m_period,shift);}
   double            getLow(int shift) {return iLow(m_symbol,m_period,shift);}
   double            getOpen(int shift) {return iOpen(m_symbol,m_period,shift);}
   double            getClose(int shift) {return iClose(m_symbol,m_period,shift);}
   long              getVolume(int shift) {return iVolume(m_symbol,m_period,shift);}
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void TimeSeriesData::updateNewBar(datetime current)
  {
   if(m_lastBarDate==0)
     {
      m_newBars=getBars();
      m_lastBarDate=current;
      return;
     }

   if(m_lastBarDate<current)
     {
      m_newBars=getBars(m_lastBarDate,current)-1;
      m_lastBarDate=current;
     }
   else
     {
      m_newBars=0;
     }
  }
//+------------------------------------------------------------------+
