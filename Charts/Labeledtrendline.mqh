//+------------------------------------------------------------------+
//|                                           Charts/LabeledTrendLine.mqh |
//+------------------------------------------------------------------+


#property strict
#include <sts/Porting/Legacy/mql/lang/mql.mqh>
#include <sts/Porting/Legacy/mql/graphicalobjects/anchoredgraphicalobject.mqh>
//+------------------------------------------------------------------+
//| Class that represents a single line with its label               |
//+------------------------------------------------------------------+
class LabeledTrendLine : public AnchoredGraphicalObject
{
private:
                     ObjectAttr(string, lineId, LineId);
                     ObjectAttr(color, lineColor, LineColor);
                     ObjectAttr(int, lineStyle, LineStyle);
                     ObjectAttr(int, lineWidth, LineWidth);
                     ObjectAttrBool(LineRayEnabled);

                     ObjectAttr(string, labelId, LabelId);

   string            m_labelText;

public:
   void              LabeledTrendLine(const string lineId, const string labelId, const string labelText, const int lineStyle, const color lineColor, const int lineWidth);
   void             ~LabeledTrendLine();

   virtual bool      realize()
   {
      return false;
   };

   void              draw() const {};
   void              draw(const datetime fromDateTime, const double fromePrice, const datetime toDateTime, const double toPrice, datetime labelTime);
   void              remove();

   datetime          getTimeByPrice(double price, int lineId = 0);
   double            getPriceByTime(datetime time, int lineId = 0)
   {
      return AnchoredGraphicalObject::getPriceByTime(time, lineId);
   };

   void              setLabelText(const string pText)
   {
      m_labelText = pText;
      if (ObjectFind(m_labelId) >= 0)
         {
            ObjectSetText(m_labelId, pText, 8, "Arial", m_lineColor);
         }
   }

   string            getLabelText()
   {
      if (ObjectFind(m_labelId) >= 0)
         {
            m_labelText = ObjectGetString(0, m_labelId, OBJPROP_TEXT);
         }
      return m_labelText;
   }

   void              setLabelPrice(const double pPrice)
   {
      if (ObjectFind(m_labelId) >= 0)
         {
            ObjectSetDouble(0, m_labelId, OBJPROP_PRICE1, pPrice);
         }
   }

   double            getLabelPrice()
   {
      if (ObjectFind(m_labelId) >= 0)
         {
            return ObjectGetDouble(0, m_labelId, OBJPROP_PRICE1);
         }
      return 0.0;
   }
   /*
      void setLineWidth(const long pWidth)
        {
         if(ObjectFind(m_lineId)>=0)
           {
            ObjectSetInteger(0,m_lineId,OBJPROP_WIDTH,pWidth);
           }
        }

      long getLineWidth() const
        {
         if(ObjectFind(m_lineId)>=0)
           {
            return ObjectGetInteger(0, m_lineId,OBJPROP_WIDTH);
           }
         return 0.0;
        }
    */
};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
LabeledTrendLine::LabeledTrendLine(string lineId, string labelId, string labelText, int lineStyle, color lineColor, const int lineWidth)
   : AnchoredGraphicalObject(OBJ_TREND, lineId), m_lineId(lineId), m_lineColor(lineColor), m_lineStyle(lineStyle), m_lineWidth(lineWidth), m_labelId(labelId), m_labelText(labelText), m_isLineRayEnabled(true)
{
   remove();
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
LabeledTrendLine::~LabeledTrendLine(void)
{
   remove();
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void LabeledTrendLine::draw(const datetime fromDateTime, const double fromePrice, const datetime toDateTime, const double toPrice, datetime labelTime)
{
   if (ObjectFind(m_lineId) != 0)
      {
         ObjectCreate(m_lineId, OBJ_TREND, 0, fromDateTime, fromePrice, toDateTime, toPrice, labelTime);
         ObjectSetInteger(0, m_lineId, OBJPROP_RAY_RIGHT, m_isLineRayEnabled);
         ObjectSet(m_lineId, OBJPROP_COLOR, m_lineColor);
         ObjectSet(m_lineId, OBJPROP_STYLE, m_lineStyle);
         ObjectSet(m_lineId, OBJPROP_WIDTH, m_lineWidth);
         ObjectSet(m_lineId, OBJPROP_HIDDEN, true);
      }
   else
      {
         ObjectMove(m_lineId, 0, fromDateTime, fromePrice);
         ObjectMove(m_lineId, 1, toDateTime, toPrice);
      }

   if (ObjectFind(m_labelId) != 0)
      {
         ObjectCreate(m_labelId, OBJ_TEXT, 0, labelTime, toPrice);
         ObjectSetText(m_labelId, m_labelText, 8, "Arial", m_lineColor);
         ObjectSet(m_labelId, OBJPROP_HIDDEN, true);
      }
   else
      {
         ObjectMove(m_labelId, 0, labelTime, toPrice);
      }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void LabeledTrendLine::remove(void)
{
   ObjectDelete(m_lineId);
   ObjectDelete(m_labelId);
}
//+------------------------------------------------------------------+
