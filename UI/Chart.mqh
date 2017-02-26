//+------------------------------------------------------------------+
//|                                                     UI/Chart.mqh |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Li Ding"
#property link      "dingmaotu@hotmail.com"
#property strict
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Chart
  {
private:
   long              m_chartId;
public:
                     Chart(long chartId=0);
                     Chart(string symbol,ENUM_TIMEFRAMES period);

   void              setId(long chartId) {m_chartId=chartId;}
   long              getId() const {return m_chartId;}

   string            getSymbol() const {return ChartSymbol(m_chartId);}
   ENUM_TIMEFRAMES   getPeriod() const {return ChartPeriod(m_chartId);}

   bool              setSymbolPeriod(string symbol,ENUM_TIMEFRAMES period) {return ChartSetSymbolPeriod(m_chartId,symbol,period);}

   bool              close() {return ChartClose(m_chartId);}
   void              redraw() {ChartRedraw(m_chartId);}

   static long       first() {return ChartFirst();}
   long              next() const {return ChartNext(m_chartId);}

   string            getComment() {return ChartGetString(m_chartId,CHART_COMMENT);}
   bool              setComment(string value) {return ChartSetString(m_chartId,CHART_COMMENT,value);}

   bool              bringToTop(bool value) {return ChartSetInteger(m_chartId,CHART_BRING_TO_TOP,value);}
   bool              screenShot(string filename,int width,int height,ENUM_ALIGN_MODE alignMode=ALIGN_RIGHT) const {return ChartScreenShot(m_chartId,filename,width,height,alignMode); }
   bool              applyTemplate(string filename) {return ChartApplyTemplate(m_chartId,filename);}
   bool              saveTemplate(string filename) {return ChartSaveTemplate(m_chartId,filename);}

   bool              enableMouseMoveEvent() {return ChartSetInteger(m_chartId,CHART_EVENT_MOUSE_MOVE,1);}
   bool              disableMouseMoveEvent() {return ChartSetInteger(m_chartId,CHART_EVENT_MOUSE_MOVE,0);}
   bool              enableObjectCreateEvent() {return ChartSetInteger(m_chartId,CHART_EVENT_OBJECT_CREATE,1);}
   bool              disableObjectCreateEvent() {return ChartSetInteger(m_chartId,CHART_EVENT_OBJECT_CREATE,0);}
   bool              enableObjectDeleteEvent() {return ChartSetInteger(m_chartId,CHART_EVENT_OBJECT_DELETE,1);}
   bool              disableObjectDeleteEvent() {return ChartSetInteger(m_chartId,CHART_EVENT_OBJECT_DELETE,0);}

   int               getChartWidth() const {return(int)ChartGetInteger(m_chartId,CHART_WIDTH_IN_PIXELS);}

   long              getNativeHandle() const {return ChartGetInteger(m_chartId,CHART_WINDOW_HANDLE);}
   int               getNumberSubwindows() const {return(int)ChartGetInteger(m_chartId,CHART_WINDOWS_TOTAL);}
   bool              isSubwindowVisible(int index=0) const {return ChartGetInteger(m_chartId,CHART_WINDOW_IS_VISIBLE,index)!=0;}
   int               getSubwindowY(int index=0) const {return(int)ChartGetInteger(m_chartId,CHART_WINDOW_YDISTANCE,index);}
   int               getSubwindowHeight(int index=0) const {return(int)ChartGetInteger(m_chartId,CHART_HEIGHT_IN_PIXELS,index);}
   bool              setSubwindowHeight(int index,int height) {return ChartSetInteger(m_chartId,CHART_HEIGHT_IN_PIXELS,index,height);}
  };
//+------------------------------------------------------------------+
//| Create from opened chart                                         |
//+------------------------------------------------------------------+
Chart::Chart(long chartId)
   :m_chartId(chartId==0?ChartID():chartId)
  {}
//+------------------------------------------------------------------+
//| Create by opening a new chart                                    |
//+------------------------------------------------------------------+
Chart::Chart(string symbol,ENUM_TIMEFRAMES period)
   :m_chartId(ChartOpen(symbol,period))
  {}
//+------------------------------------------------------------------+
