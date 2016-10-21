//+------------------------------------------------------------------+
//|                                              Charts/FibGroup.mqh |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Li Ding"
#property link      "dingmaotu@hotmail.com"
#property strict

#include "LabeledLine.mqh"
#include "Fib.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class FibGroup
  {
private:
   LabeledLine       L0Line,L50Line,L38_2Line,L61_8Line,L100Line;
   bool              m_fractionalLevelsEnabled;

public:
                     FibGroup(string idPrefix,string labelPrefix,color fColor);
                    ~FibGroup();

   void              draw(const Fib &fib,datetime labelTime);
   void              draw(datetime startDate,ENUM_TIMEFRAMES period,datetime labelPos,bool useSundayData);

   void              remove();

   void              enableFractionalLevels() {m_fractionalLevelsEnabled=true;}
   void              disableFractionalLevels() {m_fractionalLevelsEnabled=false;}
   bool              isSRLevelsEnabled() {return m_fractionalLevelsEnabled;}
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
FibGroup::FibGroup(string idPrefix,string labelPrefix,color fColor)
   :L0Line(idPrefix+"Fib_0",idPrefix+"Fib_0_Label",labelPrefix+" Fib 0%",STYLE_SOLID,fColor),
     L50Line(idPrefix+"Fib_50",idPrefix+"Fib_50_Label",labelPrefix+" Fib 50%",STYLE_SOLID,fColor),
     L38_2Line(idPrefix+"Fib_38_2",idPrefix+"Fib_38_2_Label",labelPrefix+" Fib 38.2%",STYLE_SOLID,fColor),
     L61_8Line(idPrefix+"Fib_61_8",idPrefix+"Fib_61_8_Label",labelPrefix+" Fib 61.8%",STYLE_SOLID,fColor),
     L100Line(idPrefix+"Fib_100",idPrefix+"Fib_100_Label",labelPrefix+"Fib 100%",STYLE_SOLID,fColor),
     m_fractionalLevelsEnabled(false)
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
FibGroup::~FibGroup(void)
  {
   remove();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
FibGroup::draw(const Fib &fib,datetime labelTime)
  {
   L0Line.draw(fib.getL0(),labelTime);
   L50Line.draw(fib.getL50(),labelTime);
   L100Line.draw(fib.getL100(),labelTime);
   if(m_fractionalLevelsEnabled)
     {
      L38_2Line.draw(fib.getL38_2(), labelTime);
      L61_8Line.draw(fib.getL61_8(), labelTime);
     }
   ObjectsRedraw();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void FibGroup::draw(datetime startDate,ENUM_TIMEFRAMES period,datetime labelPos,bool useSundayData=true)
  {
   int idx=1;
   MqlRates rates[3];
   Fib fib;

   if(period < PERIOD_D1) return;

   ArraySetAsSeries(rates,true);

   if(period==PERIOD_D1 && !useSundayData && TimeDayOfWeek(startDate)==1)
      idx=2;

   CopyRates(Symbol(),period,startDate,3,rates);
   fib.calc(rates[idx].high,rates[idx].low);
   draw(fib,labelPos);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
FibGroup::remove(void)
  {
   L0Line.remove();
   L50Line.remove();
   L100Line.remove();
   if(m_fractionalLevelsEnabled)
     {
      L38_2Line.remove();
      L61_8Line.remove();
     }
  }
//+------------------------------------------------------------------+
