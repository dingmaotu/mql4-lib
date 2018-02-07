//+------------------------------------------------------------------+
//| Module: GraphicalObjects/GraphicalObject.mqh                     |
//| This file is part of the mql4-lib project:                       |
//|     https://github.com/dingmaotu/mql4-lib                        |
//|                                                                  |
//| Copyright 2017 Li Ding <dingmaotu@126.com>                       |
//|                                                                  |
//| Licensed under the Apache License, Version 2.0 (the "License");  |
//| you may not use this file except in compliance with the License. |
//| You may obtain a copy of the License at                          |
//|                                                                  |
//|     http://www.apache.org/licenses/LICENSE-2.0                   |
//|                                                                  |
//| Unless required by applicable law or agreed to in writing,       |
//| software distributed under the License is distributed on an      |
//| "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,     |
//| either express or implied.                                       |
//| See the License for the specific language governing permissions  |
//| and limitations under the License.                               |
//+------------------------------------------------------------------+
#property strict
//+------------------------------------------------------------------+
//| Base class for all graphical objects                             |
//| This class is abstract. You have to inherit this class to create |
//| a concrete graphical object.                                     |
//+------------------------------------------------------------------+
class GraphicalObject
  {
protected:
   const ENUM_OBJECT m_type;
   const long        m_chartId;
   const int         m_subwindow;
   const string      m_id;

   long              getInteger(int propId,int propModifier=0) const
     {
      return ObjectGetInteger(m_chartId,m_id,propId,propModifier);
     }
   bool              setInteger(int propId,long value)
     {
      return ObjectSetInteger(m_chartId,m_id,propId,value);
     }
   bool              setInteger(int propId,int propModifier,long value)
     {
      return ObjectSetInteger(m_chartId,m_id,propId,propModifier,value);
     }
   double            getDouble(int propId,int propModifier=0) const
     {
      return ObjectGetDouble(m_chartId,m_id,propId,propModifier);
     }
   bool              setDouble(int propId,double value)
     {
      return ObjectSetDouble(m_chartId,m_id,propId,value);
     }
   bool              setDouble(int propId,int propModifier,double value)
     {
      return ObjectSetDouble(m_chartId,m_id,propId,propModifier,value);
     }
   string            getString(int propId,int propModifier=0) const
     {
      return ObjectGetString(m_chartId,m_id,propId,propModifier);
     }
   bool              setString(int propId,string value)
     {
      return ObjectSetString(m_chartId,m_id,propId,value);
     }
   bool              setString(int propId,int propModifier,string value)
     {
      return ObjectSetString(m_chartId,m_id,propId,propModifier,value);
     }
   bool              create(datetime time=0,double price=0)
     {
      return ObjectCreate(m_chartId,m_id,m_type,m_subwindow,time,price);
     }
   bool              create(datetime time1,double price1,datetime time2,double price2)
     {
      return ObjectCreate(m_chartId,m_id,m_type,m_subwindow,time1,price1,time2,price2);
     }
   bool              create(datetime time1,double price1,datetime time2,double price2,datetime time3,double price3)
     {
      return ObjectCreate(m_chartId,m_id,m_type,m_subwindow,time1,price1,time2,price2,time3, price3);
     }

                     GraphicalObject(ENUM_OBJECT type,string id,long chartId=0,int subwindow=0):m_type(type),m_id(id),m_chartId(chartId==0?ChartID():chartId),m_subwindow(subwindow) {}
public:
                    ~GraphicalObject() {ObjectDelete(m_chartId,m_id);}

   ENUM_OBJECT       getUnderlyingObjectType() const {return(ENUM_OBJECT)getInteger(OBJPROP_TYPE);}
   datetime          getCreateTime() const {return(datetime)getInteger(OBJPROP_CREATETIME);}

   string            getText() const {return getString(OBJPROP_TEXT);}
   bool              setText(string value) {return setString(OBJPROP_TEXT,value);}

   string            getTooltip() const {return getString(OBJPROP_TOOLTIP);}
   bool              setTooltip(string value) {return setString(OBJPROP_TOOLTIP,value);}

   //--- visibility
   long              getVisibility() const {return getInteger(OBJPROP_TIMEFRAMES);}
   bool              setVisibility(long value) {return setInteger(OBJPROP_TIMEFRAMES,value);}

   bool              isVisible() const {return getVisibility()>OBJ_NO_PERIODS;}
   bool              setVisible(bool value) {return setVisibility(value?OBJ_ALL_PERIODS:OBJ_NO_PERIODS);}

   bool              isVisibleOn(long flag) const {return(getVisibility()&flag)==flag;}
   bool              setVisibleOn(long flag) {return setVisibility(getVisibility()|flag);}
   bool              setInvisibleOn(long flag) {return setVisibility(getVisibility()&(~flag));}

   //--- color
   bool              setColor(int value){return setInteger(OBJPROP_COLOR,value);}
  };
//+------------------------------------------------------------------+
