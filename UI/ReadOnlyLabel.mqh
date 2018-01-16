//+------------------------------------------------------------------+
//|                                             UI/ReadOnlyLabel.mqh |
//|                  Copyright 2017, Bear Two Technologies Co., Ltd. |
//+------------------------------------------------------------------+
#property strict
//+------------------------------------------------------------------+
//| A label representing read only content                           |
//+------------------------------------------------------------------+
class ReadOnlyLabel
  {
private:
   const long        m_chart;
   const string      m_id;
   const int         m_ox,m_oy;
   const int         m_color;
protected:
   void              ensureCreated();
public:
                     ReadOnlyLabel(string id,int x,int y,color c,long chart=0):m_chart(chart==0?ChartID():chart),m_id(id),m_ox(x),m_oy(y),m_color(c)
     {
      ensureCreated();
     }
                    ~ReadOnlyLabel() {ObjectDelete(m_chart,m_id);}
   void              render(string content,string tooltip="");
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ReadOnlyLabel::ensureCreated(void)
  {
   if(ObjectFind(m_chart,m_id)>=0) return;
   ObjectCreate(m_chart,m_id,OBJ_LABEL,0,0,0);

   ObjectSetInteger(m_chart,m_id,OBJPROP_CORNER,CORNER_RIGHT_LOWER);
   ObjectSetInteger(m_chart,m_id,OBJPROP_ANCHOR,ANCHOR_RIGHT_LOWER);
   ObjectSetInteger(m_chart,m_id,OBJPROP_XDISTANCE,m_ox);
   ObjectSetInteger(m_chart,m_id,OBJPROP_YDISTANCE,m_oy);

   ObjectSetInteger(m_chart,m_id,OBJPROP_COLOR,m_color);
   ObjectSetInteger(m_chart,m_id,OBJPROP_FONTSIZE,12);
   ObjectSetString(m_chart,m_id,OBJPROP_FONT,"Monospace");

   ObjectSetInteger(m_chart,m_id,OBJPROP_SELECTABLE,0);
   ObjectSetInteger(m_chart,m_id,OBJPROP_SELECTED,0);
   ObjectSetInteger(m_chart,m_id,OBJPROP_HIDDEN,1);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ReadOnlyLabel::render(string content,string tooltip)
  {
   ensureCreated();
   ObjectSetString(m_chart,m_id,OBJPROP_TEXT,content);
   if(tooltip!="")
      ObjectSetString(m_chart,m_id,OBJPROP_TOOLTIP,tooltip);
//--- no need to force redraw as the chart will redraw itself on next tick
//--- ChartRedraw(m_chart);
  }
//+------------------------------------------------------------------+
