//+------------------------------------------------------------------+
//|                                                  BaseElement.mqh |
//|                                          Copyright 2017, Li Ding |
//|                                            dingmaotu@hotmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Li Ding"
#property link      "dingmaotu@hotmail.com"
#property strict

#include "UIRoot.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class BaseElement: public UIElement
  {
protected:
   UIRoot           *m_root;
#ifdef __MQL5__   
   long              getInteger(ENUM_OBJECT_PROPERTY_INTEGER propId,int propModifier=0) const 
     {return ObjectGetInteger(m_root.getChartId(),getName(),propId,propModifier);}
   bool              setInteger(ENUM_OBJECT_PROPERTY_INTEGER propId,long value)
     {return ObjectSetInteger(m_root.getChartId(),getName(),propId,value);}
   bool              setInteger(ENUM_OBJECT_PROPERTY_INTEGER propId,int propModifier,long value)
     {return ObjectSetInteger(m_root.getChartId(),getName(),propId,propModifier,value);}
   double            getDouble(ENUM_OBJECT_PROPERTY_DOUBLE propId,int propModifier=0) const
     {return ObjectGetDouble(m_root.getChartId(),getName(),propId,propModifier);}
   bool              setDouble(ENUM_OBJECT_PROPERTY_DOUBLE propId,double value)
     {return ObjectSetDouble(m_root.getChartId(),getName(),propId,value);}
   bool              setDouble(ENUM_OBJECT_PROPERTY_DOUBLE propId,int propModifier,double value)
     {return ObjectSetDouble(m_root.getChartId(),getName(),propId,propModifier,value);}
   string            getString(ENUM_OBJECT_PROPERTY_STRING propId,int propModifier=0) const
     {return ObjectGetString(m_root.getChartId(),getName(),propId,propModifier);}
   bool              setString(ENUM_OBJECT_PROPERTY_STRING propId,string value)
     {return ObjectSetString(m_root.getChartId(),getName(),propId,value);}
   bool              setString(ENUM_OBJECT_PROPERTY_STRING propId,int propModifier,string value)
     {return ObjectSetString(m_root.getChartId(),getName(),propId,propModifier,value);}
#else
   long              getInteger(int propId,int propModifier=0) const 
     {return ObjectGetInteger(m_root.getChartId(),getName(),propId,propModifier);}
   bool              setInteger(int propId,long value)
     {return ObjectSetInteger(m_root.getChartId(),getName(),propId,value);}
   bool              setInteger(int propId,int propModifier,long value)
     {return ObjectSetInteger(m_root.getChartId(),getName(),propId,propModifier,value);}
   double            getDouble(int propId,int propModifier=0) const
     {return ObjectGetDouble(m_root.getChartId(),getName(),propId,propModifier);}
   bool              setDouble(int propId,double value)
     {return ObjectSetDouble(m_root.getChartId(),getName(),propId,value);}
   bool              setDouble(int propId,int propModifier,double value)
     {return ObjectSetDouble(m_root.getChartId(),getName(),propId,propModifier,value);}
   string            getString(int propId,int propModifier=0) const
     {return ObjectGetString(m_root.getChartId(),getName(),propId,propModifier);}
   bool              setString(int propId,string value)
     {return ObjectSetString(m_root.getChartId(),getName(),propId,value);}
   bool              setString(int propId,int propModifier,string value)
     {return ObjectSetString(m_root.getChartId(),getName(),propId,propModifier,value);}
#endif     

   bool              deleteSelf()
     {
      return ObjectDelete(m_root.getChartId(),getName());
     }

                     BaseElement(UIElement *parent,string name):UIElement(parent,name)
     {
      if(CheckPointer(dynamic_cast<UIRoot*>(parent))!=POINTER_INVALID)
        {
         m_root=dynamic_cast<UIRoot*>(parent);
        }
      else if(CheckPointer(dynamic_cast<BaseElement*>(parent))!=POINTER_INVALID)
        {
         m_root=dynamic_cast<BaseElement*>(parent).m_root;
        }
      else
        {
         m_root=NULL;
        }
     }
public:
   ENUM_OBJECT       getUnderlyingObjectType() const {return(ENUM_OBJECT)getInteger(OBJPROP_TYPE);}
   datetime          getCreateTime() const {return(datetime)getInteger(OBJPROP_CREATETIME);}

   string            getText() const {return getString(OBJPROP_TEXT);}
   bool              setText(string value) {return setString(OBJPROP_TEXT,value);}

   string            getTooltip() const {return getString(OBJPROP_TOOLTIP);}
   bool              setTooltip(string value) {return setString(OBJPROP_TOOLTIP,value);}

   long              getVisibility() const {return getInteger(OBJPROP_TIMEFRAMES);}
   bool              setVisibility(long value) {return setInteger(OBJPROP_TIMEFRAMES,value);}

   //--- visible at least in one timeframe
   bool              isVisible() const {return getVisibility()>OBJ_NO_PERIODS;}
   bool              setVisible(bool value) {return setVisibility(value?OBJ_ALL_PERIODS:OBJ_NO_PERIODS);}
   bool              setColor(int value){return setInteger(OBJPROP_COLOR,value);}
   bool              setBgColor(int value){return setInteger(OBJPROP_BGCOLOR,value);}
   bool              isVisibleOn(long flag) const {return(getVisibility()&flag)==flag;}
   bool              setVisibleOn(long flag) {return setVisibility(getVisibility()|flag);}
   bool              setInvisibleOn(long flag) {return setVisibility(getVisibility()&(~flag));}

   virtual int       getX() const {return 0;}
   virtual int       getY() const {return 0;}
   virtual int       getWidth() const {return 0;}
   virtual int       getHeight() const {return 0;}
  };
//+------------------------------------------------------------------+
