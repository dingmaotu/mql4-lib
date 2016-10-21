//+------------------------------------------------------------------+
//|                                           Charts/LabeledLine.mqh |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Li Ding"
#property link      "dingmaotu@hotmail.com"
#property strict
//+------------------------------------------------------------------+
//| Class that represents a single line with its label               |
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
