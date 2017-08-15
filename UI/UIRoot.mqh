//+------------------------------------------------------------------+
//|                                                       UIRoot.mqh |
//|                                          Copyright 2017, Li Ding |
//|                                            dingmaotu@hotmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Li Ding"
#property link      "dingmaotu@hotmail.com"
#property strict

#include "UIElement.mqh"
#include "Chart.mqh"
//+------------------------------------------------------------------+
//| Root container responsible for all ui elements                   |
//+------------------------------------------------------------------+
class UIRoot: public UIElement
  {
private:
   Chart             m_chart;
   int               m_subwindow;
   ChartShowStatus   m_status;
public:
                     UIRoot(long chart=0,int subwindow=0);

   long              getChartId() const {return m_chart.getId();}
   int               getSubwindowIndex() const {return m_subwindow;}

   int               getX() const {return 0;}
   int               getY() const {return m_chart.getSubwindowY(m_subwindow);}
   int               getWidth() const {return m_chart.getChartWidth();}
   int               getHeight() const {return m_chart.getSubwindowHeight(m_subwindow);}

   //--- disable display of price scale, date scale, price lines, OHLC, etc.
   void              hideBackgroundElements()
     {
      m_chart.saveShow(m_status);
      m_chart.setShow(false);
     }

   void              restoreBackgroundElements() {m_chart.restoreShow(m_status);}

   void              redraw() {m_chart.redraw();}
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
UIRoot::UIRoot(long chart,int subwindow)
   :UIElement(NULL,StringFormat(".%d",subwindow)),
     m_chart(chart),
     m_subwindow(subwindow)
  {}
//+------------------------------------------------------------------+
