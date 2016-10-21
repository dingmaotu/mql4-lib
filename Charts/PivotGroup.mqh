//+------------------------------------------------------------------+
//|                                            Charts/PivotGroup.mqh |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015-2016 Li Ding"
#property link      "dingmaotu@hotmail.com"
#property strict

#include "LabeledLine.mqh"
#include "Pivot.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class PivotGroup
  {
private:
   LabeledLine       PLine,R1Line,R2Line,R3Line,S1Line,S2Line,S3Line;
   bool              m_srLevelsEnabled;

public:
                     PivotGroup(string pivotIdPrefix,string linesIdPrefix,string labelPrefix,color pColor,color rColor,color sColor);
                    ~PivotGroup();

   void              draw(const Pivot &pivot,datetime labelTime);
   void              draw(datetime startDate,ENUM_TIMEFRAMES period,datetime labelPos,bool useSundayData);

   void              remove();

   void              enableSRLevels() {m_srLevelsEnabled=true;}
   void              disableSRLevels() {m_srLevelsEnabled=false;}
   bool              isSRLevelsEnabled() {return m_srLevelsEnabled;}
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
PivotGroup::PivotGroup(string pivotIdPrefix,string linesIdPrefix,string labelPrefix,color pColor,color rColor,color sColor)
   :PLine(pivotIdPrefix+"PivotLine",pivotIdPrefix+"PivotLabel",labelPrefix+"Pivot",STYLE_DASH,pColor),
     R1Line(linesIdPrefix+"R1_Line",linesIdPrefix+"R1_Label",labelPrefix+"R1",STYLE_DASHDOTDOT,rColor),
     R2Line(linesIdPrefix+"R2_Line",linesIdPrefix+"R2_Label",labelPrefix+"R2",STYLE_DASHDOTDOT,rColor),
     R3Line(linesIdPrefix+"R3_Line",linesIdPrefix+"R3_Label",labelPrefix+"R3",STYLE_DASHDOTDOT,rColor),
     S1Line(linesIdPrefix+"S1_Line",linesIdPrefix+"S1_Label",labelPrefix+"S1",STYLE_DASHDOTDOT,sColor),
     S2Line(linesIdPrefix+"S2_Line",linesIdPrefix+"S2_Label",labelPrefix+"S2",STYLE_DASHDOTDOT,sColor),
     S3Line(linesIdPrefix+"S3_Line",linesIdPrefix+"S3_Label",labelPrefix+"S3",STYLE_DASHDOTDOT,sColor),
     m_srLevelsEnabled(false)
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
PivotGroup::~PivotGroup(void)
  {
   remove();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
PivotGroup::draw(const Pivot &pivot,datetime labelTime)
  {
   PLine.draw(pivot.getPivot(),labelTime);
   if(m_srLevelsEnabled)
     {
      R1Line.draw(pivot.getR1(), labelTime);
      R2Line.draw(pivot.getR2(), labelTime);
      R3Line.draw(pivot.getR3(), labelTime);

      S1Line.draw(pivot.getS1(), labelTime);
      S2Line.draw(pivot.getS2(), labelTime);
      S3Line.draw(pivot.getS3(), labelTime);
     }
   ObjectsRedraw();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PivotGroup::draw(datetime startDate,ENUM_TIMEFRAMES period,datetime labelPos,bool useSundayData=true)
  {
   int idx=1;
   MqlRates rates[3];
   Pivot pivot;

   if(period < PERIOD_D1) return;

   ArraySetAsSeries(rates,true);

   if(period==PERIOD_D1 && !useSundayData && TimeDayOfWeek(startDate)==1)
      idx=2;

   CopyRates(Symbol(),period,startDate,3,rates);
   pivot.calc(rates[idx].high,rates[idx].low,rates[idx].close);
   draw(pivot,labelPos);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
PivotGroup::remove(void)
  {
   PLine.remove();
   if(m_srLevelsEnabled)
     {
      R1Line.remove();
      R2Line.remove();
      R3Line.remove();

      S1Line.remove();
      S2Line.remove();
      S3Line.remove();
     }
  }
//+------------------------------------------------------------------+
