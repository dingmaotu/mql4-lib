//+------------------------------------------------------------------+
//|                                              UI/ActionMarker.mqh |
//|                  Copyright 2017, Bear Two Technologies Co., Ltd. |
//+------------------------------------------------------------------+
#property strict

#include "Mouse.mqh"
#include "../Collection/Set.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
interface ActionEventHandler
  {
   void onAction(string id,string label);
  };
//+------------------------------------------------------------------+
//| A label on chart and signal an action when moved                 |
//| This approach to trigger an action can be used in testing, where |
//| events are not processed                                         |
//+------------------------------------------------------------------+
class ActionMarker
  {
private:
   const long        m_chart;
   const string      m_id;
   const string      m_label;
   const int         m_ox,m_oy;
   bool              m_actived;
protected:
   void              ensureCreated();
   double            calcDistance() const;

   Set<ActionEventHandler*>ActionEvent;
public:
                     ActionMarker(string id,string label,int x,int y,long chart=0):m_chart(chart==0?ChartID():chart),m_id(id),m_label(label),m_ox(x),m_oy(y),m_actived(false)
     {
      ensureCreated();
     }
                    ~ActionMarker() {ObjectDelete(m_chart,m_id);}
   void              check();
   void              operator+=(ActionEventHandler *handler) {ActionEvent.add(handler);}
   void              operator-=(ActionEventHandler *handler) {ActionEvent.remove(handler);}
  };
//+------------------------------------------------------------------+
//| ensure the marker is created                                     |
//+------------------------------------------------------------------+
void ActionMarker::ensureCreated(void)
  {
   if(ObjectFind(m_chart,m_id)>=0) return;
   ObjectCreate(m_chart,m_id,OBJ_LABEL,0,0,0);
   ObjectSetString(m_chart,m_id,OBJPROP_TEXT,m_label);
   ObjectSetString(m_chart,m_id,OBJPROP_TOOLTIP,"拖出当前位置之外一定距离，变色后松开");

   ObjectSetInteger(m_chart,m_id,OBJPROP_CORNER,CORNER_RIGHT_LOWER);
   ObjectSetInteger(m_chart,m_id,OBJPROP_ANCHOR,ANCHOR_RIGHT_LOWER);
   ObjectSetInteger(m_chart,m_id,OBJPROP_SELECTABLE,1);
   ObjectSetInteger(m_chart,m_id,OBJPROP_SELECTED,0);
   ObjectSetInteger(m_chart,m_id,OBJPROP_XDISTANCE,m_ox);
   ObjectSetInteger(m_chart,m_id,OBJPROP_YDISTANCE,m_oy);
   ObjectSetInteger(m_chart,m_id,OBJPROP_COLOR,clrYellow);
   ObjectSetInteger(m_chart,m_id,OBJPROP_FONTSIZE,12);
   ObjectSetString(m_chart,m_id,OBJPROP_FONT,"Arial");
   ObjectSetInteger(m_chart,m_id,OBJPROP_HIDDEN,1);
  }
//+------------------------------------------------------------------+
//| calculate distance from the origin                               |
//+------------------------------------------------------------------+
double ActionMarker::calcDistance() const
  {
   int x = (int)ObjectGetInteger(m_chart, m_id, OBJPROP_XDISTANCE);
   int y = (int)ObjectGetInteger(m_chart, m_id, OBJPROP_YDISTANCE);
   double xd = x-m_ox;
   double yd = y-m_oy;
   return MathSqrt(xd*xd+yd*yd);
  }
//+------------------------------------------------------------------+
//| update and render                                                |
//+------------------------------------------------------------------+
void ActionMarker::check(void)
  {
   ensureCreated();
   double distance=calcDistance();
   m_actived=distance>50.0;
   ObjectSetInteger(m_chart,m_id,OBJPROP_COLOR,m_actived?clrRed:clrYellow);

   if(distance>0.0 && !Mouse::isLeftDown())
     {
      ObjectSetInteger(m_chart,m_id,OBJPROP_XDISTANCE,m_ox);
      ObjectSetInteger(m_chart,m_id,OBJPROP_YDISTANCE,m_oy);
      ObjectSetInteger(m_chart,m_id,OBJPROP_COLOR,clrYellow);
      ObjectSetInteger(m_chart,m_id,OBJPROP_SELECTED,0);
      ChartRedraw(m_chart);

      if(m_actived)
        {
         if(ActionEvent.size()>0)
           {
            foreach(ActionEventHandler*,ActionEvent)
              {
               ActionEventHandler *handler=it.current();
               handler.onAction(m_id,m_label);
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
