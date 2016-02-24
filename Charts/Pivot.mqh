//+------------------------------------------------------------------+
//|                                                        Pivot.mqh |
//|                                          Copyright 2015, Li Ding |
//|                                                dingmaotu@126.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, Li Ding"
#property link      "dingmaotu@126.com"
#property strict
//+------------------------------------------------------------------+
//| Class that represents a single pivot line with its label         |
//+------------------------------------------------------------------+
class LabeledLine
  {
private:
   string            m_lineId;
   color             m_lineColor;
   int               m_lineStyle;

   string            m_labelId;
   string            m_labelName;

public:
                     LabeledLine(string lineId,string labelId,string lableName,int lineStyle,color lineColor);
                    ~LabeledLine();

   void              draw(double value,datetime labelTime);
   void              remove();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
LabeledLine::LabeledLine(string lineId,string labelId,string labelName,int lineStyle,color lineColor)
   :m_lineId(lineId),m_lineColor(lineColor),m_lineStyle(lineStyle),m_labelId(labelId),m_labelName(labelName)
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
LabeledLine::~LabeledLine(void)
  {
   remove();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void LabeledLine::draw(double value,datetime labelTime)
  {
   if(ObjectFind(m_lineId)!=0)
     {
      ObjectCreate(m_lineId,OBJ_HLINE,0,0,value);
      ObjectSet(m_lineId,OBJPROP_COLOR,m_lineColor);
      ObjectSet(m_lineId,OBJPROP_STYLE,m_lineStyle);
     }
   else
     {
      ObjectMove(m_lineId,0,0,value);
     }

   if(ObjectFind(m_labelId)!=0)
     {
      ObjectCreate(m_labelId,OBJ_TEXT,0,labelTime,value);
      ObjectSetText(m_labelId,m_labelName,8,"Arial",m_lineColor);
     }
   else
     {
      ObjectMove(m_labelId,0,labelTime,value);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void LabeledLine::remove(void)
  {
   ObjectDelete(m_lineId);
   ObjectDelete(m_labelId);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Pivot
  {
private:
   double            pivot,r1,r2,r3,s1,s2,s3;
public:
                     Pivot(){}
                    ~Pivot(){}
   void              calc(double high,double low,double close);

   double getR3() const {return r3;}
   double getR2() const {return r2;}
   double getR1() const {return r1;}
   double getPivot() const {return pivot;}
   double getS1() const {return s1;}
   double getS2() const {return s2;}
   double getS3() const {return s3;}
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Pivot::calc(double high,double low,double close)
  {
   pivot=((high+low+close)/3);

   r1 = (2*pivot)-low;
   s1 = (2*pivot)-high;

   r2 = pivot+(r1-s1);
   s2 = pivot-(r1-s1);

   r3 = high + (2*(pivot-low));
   s3 = low - (2*(high-pivot));
  }
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
