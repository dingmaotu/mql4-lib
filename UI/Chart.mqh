//+------------------------------------------------------------------+
//|                                                     UI/Chart.mqh |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Li Ding"
#property link      "dingmaotu@hotmail.com"
#property strict

#include "../Lang/Win32.mqh"
//+------------------------------------------------------------------+
//| Records the show status of a chart                               |
//+------------------------------------------------------------------+
struct ChartShowStatus
  {
public:
   bool              ShowOHLC;
   bool              ShowBidLine;
   bool              ShowAskLine;
   bool              ShowLastLine;
   bool              ShowPeriodSeparator;
   bool              ShowGrid;
   bool              ShowObjectDescription;
   bool              ShowDateScale;
   bool              ShowPriceScale;
   bool              ShowOneClick;
   bool              ShowTradeLevels;
   bool              ShowVolume;
  };
//+------------------------------------------------------------------+
//| Wraps most chart operations                                      |
//+------------------------------------------------------------------+
class Chart
  {
private:
   long              m_chartId;
public:
                     Chart(long chartId=0);

   bool              isValid() const {return m_chartId>0;}

   void              setId(long chartId) {m_chartId=chartId;}
   long              getId() const {return m_chartId;}

   string            getSymbol() const {return ChartSymbol(m_chartId);}
   ENUM_TIMEFRAMES   getPeriod() const {return ChartPeriod(m_chartId);}

   bool              setSymbolPeriod(string symbol,ENUM_TIMEFRAMES period) {return ChartSetSymbolPeriod(m_chartId,symbol,period);}

   bool              open(string symbol,int period)
     {
      long id=ChartOpen(symbol,period);
      if(id>0) {m_chartId=id;return true;}
      else return false;
     }
   bool              close() {return ChartClose(m_chartId);}
   bool              isOpen() const {return ChartPeriod(m_chartId)!=0;}

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

   intptr_t          getNativeHandle() const
     {
#ifdef __X64__
      return ChartGetInteger(m_chartId,CHART_WINDOW_HANDLE);
#else
      return (intptr_t)ChartGetInteger(m_chartId,CHART_WINDOW_HANDLE);
#endif
     }
   int               getNumberSubwindows() const {return(int)ChartGetInteger(m_chartId,CHART_WINDOWS_TOTAL);}
   bool              isSubwindowVisible(int index=0) const {return ChartGetInteger(m_chartId,CHART_WINDOW_IS_VISIBLE,index)!=0;}
   int               getSubwindowY(int index=0) const {return(int)ChartGetInteger(m_chartId,CHART_WINDOW_YDISTANCE,index);}
   int               getSubwindowHeight(int index=0) const {return(int)ChartGetInteger(m_chartId,CHART_HEIGHT_IN_PIXELS,index);}
   bool              setSubwindowHeight(int index,int height) {return ChartSetInteger(m_chartId,CHART_HEIGHT_IN_PIXELS,index,height);}

   bool              isOffline() const {return ChartGetInteger(m_chartId,CHART_IS_OFFLINE);}

#define BOOL_PROP(PropName,OptionName) \
   bool              is##PropName() const {return ChartGetInteger(m_chartId,OptionName);}\
   bool              set##PropName(bool value) {return ChartSetInteger(m_chartId,OptionName,value);}

   BOOL_PROP(ShowOHLC,CHART_SHOW_OHLC)
   BOOL_PROP(ShowBidLine,CHART_SHOW_BID_LINE)
   BOOL_PROP(ShowAskLine,CHART_SHOW_ASK_LINE)
   BOOL_PROP(ShowLastLine,CHART_SHOW_LAST_LINE)
   BOOL_PROP(ShowPeriodSeparator,CHART_SHOW_PERIOD_SEP)
   BOOL_PROP(ShowGrid,CHART_SHOW_GRID)
   BOOL_PROP(ShowObjectDescription,CHART_SHOW_OBJECT_DESCR)
   BOOL_PROP(ShowDateScale,CHART_SHOW_DATE_SCALE)
   BOOL_PROP(ShowOneClick,CHART_SHOW_ONE_CLICK)
   BOOL_PROP(ShowPriceScale,CHART_SHOW_PRICE_SCALE)
   BOOL_PROP(ShowTradeLevels,CHART_SHOW_TRADE_LEVELS)

   bool              isShowVolume() const {return ChartGetInteger(m_chartId,CHART_SHOW_VOLUMES)!=CHART_VOLUME_HIDE;}
   bool              setShowVolume(bool value) const {return ChartSetInteger(m_chartId,CHART_SHOW_VOLUMES,value?CHART_VOLUME_TICK:CHART_VOLUME_HIDE);}

   void              setShow(bool value)
     {
      setShowOHLC(value);
      setShowBidLine(value);
      setShowAskLine(value);
      setShowLastLine(value);
      setShowOneClick(value);
      setShowPeriodSeparator(value);
      setShowGrid(value);
      setShowObjectDescription(value);
      setShowPriceScale(value);
      setShowDateScale(value);
      setShowOneClick(value);
      setShowVolume(value);
     }

   void              saveShow(ChartShowStatus &show) const
     {
      show.ShowOHLC=isShowOHLC();
      show.ShowBidLine=isShowBidLine();
      show.ShowAskLine=isShowAskLine();
      show.ShowLastLine=isShowLastLine();
      show.ShowOneClick=isShowOneClick();
      show.ShowPeriodSeparator=isShowPeriodSeparator();
      show.ShowGrid=isShowGrid();
      show.ShowObjectDescription=isShowObjectDescription();
      show.ShowPriceScale=isShowPriceScale();
      show.ShowDateScale=isShowDateScale();
      show.ShowOneClick=isShowOneClick();
      show.ShowVolume=isShowVolume();
     }

   void              restoreShow(const ChartShowStatus &show)
     {
      setShowOHLC(show.ShowOHLC);
      setShowBidLine(show.ShowBidLine);
      setShowAskLine(show.ShowAskLine);
      setShowLastLine(show.ShowLastLine);
      setShowOneClick(show.ShowOneClick);
      setShowPeriodSeparator(show.ShowPeriodSeparator);
      setShowGrid(show.ShowGrid);
      setShowObjectDescription(show.ShowObjectDescription);
      setShowPriceScale(show.ShowPriceScale);
      setShowDateScale(show.ShowDateScale);
      setShowOneClick(show.ShowOneClick);
      setShowVolume(show.ShowVolume);
     }

   //--- Well known trick to force price update for an offline chart
   void              forcePriceUpdate() { PostMessageW(getNativeHandle(),WM_COMMAND,33324,0); }

   bool              sendCustomEvent(ushort eventId,long lparam,double dparam,string sparam) {return EventChartCustom(m_chartId,eventId,lparam,dparam,sparam);}
  };
//+------------------------------------------------------------------+
//| Create from opened chart                                         |
//+------------------------------------------------------------------+
Chart::Chart(long chartId)
   :m_chartId(chartId==0?ChartID():chartId)
  {}
//+------------------------------------------------------------------+
//| Macro to iterate every chart in the Terminal                     |
//+------------------------------------------------------------------+
#define foreachchart(VarChart) for(Chart VarChart(Chart::first());VarChart.getId()!=-1;VarChart.setId(VarChart.next()))
//+------------------------------------------------------------------+
