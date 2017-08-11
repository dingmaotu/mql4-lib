//+------------------------------------------------------------------+
//| Module: Lang/EventApp.mqh                                        |
//| This file is part of the mql4-lib project:                       |
//|     https://github.com/dingmaotu/mql4-lib                        |
//|                                                                  |
//| Copyright 2015-2016 Li Ding <dingmaotu@126.com>                  |
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

#include "App.mqh"
#include "Event.mqh"
#include "../UI/Chart.mqh"

#define DECLARE_EVENT_APP(AppClass,Boolean) \
DECLARE_APP(AppClass,Boolean)\
void OnTimer() {dynamic_cast<EventApp*>(App::Global).onTimer();}\
void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)\
  {dynamic_cast<EventApp*>(App::Global).onChartEvent(id,lparam,dparam,sparam);}
//+------------------------------------------------------------------+
//| Abstract base class for a MQL Application that can receive events|
//+------------------------------------------------------------------+
class EventApp: public App
  {
private:
   bool              m_hasTimer;
protected:
   void              setupTimer(int seconds) {if(EventSetTimer(seconds))m_hasTimer=true;}
   void              setupMillisTimer(int millis) {if(EventSetMillisecondTimer(millis))m_hasTimer=true;}
   bool              hasTimer() const {return m_hasTimer;}
   //--- broadcast a custom chart event to all opened charts
   void              broadcast(const ushort id,const long lparam,const double dparam,const string sparam)
     {
      foreachchart(c)
        {
         c.sendCustomEvent(id,lparam,dparam,sparam);
        }
     }
public:
                    ~EventApp() {if(m_hasTimer)EventKillTimer();}

   void              onChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
   //--- Timer events
   virtual void      onTimer() {}
   //--- External events
   virtual void      onAppEvent(const ushort event,const uint param) {}
   //--- custom events sent by EventChartCustom (id is the SAME as sencond parameter of EventChartCustom)
   virtual void      onCustom(ushort id,long lparam,double dparam,string sparam) {}

   //--- UI events
   virtual void      onKeyDown(int keyCode,int repeatCount,uint bitmask) {}
   virtual void      onMouseMove(int x,int y,uint bitmask) {}
   virtual void      onClick(int x,int y) {}
   virtual void      onChartChange() {}

   //--- Object events
   virtual void      onObjectCreate(string id) {}
   virtual void      onObjectDelete(string id) {}
   virtual void      onObjectChange(string id) {}
   virtual void      onObjectClick(string id,int x,int y) {}
   virtual void      onObjectDrag(string id) {}
   virtual void      onObjectEndEdit(string id) {}
  };
//+------------------------------------------------------------------+
//| Parse chart event parameters and distribute the event            |
//+------------------------------------------------------------------+
void EventApp::onChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   switch(id)
     {
      case CHARTEVENT_KEYDOWN:
        {
         if(IsKeydownMessage(lparam))
           {
            ushort event;
            uint param;
            DecodeKeydownMessage(lparam,dparam,event,param);
            onAppEvent(event,param);
           }
         else
           {
            onKeyDown(int(lparam),int(dparam),uint(sparam));
           }
         break;
        }
      case CHARTEVENT_CLICK:
         onClick(int(lparam),int(dparam));
         break;
      case CHARTEVENT_MOUSE_MOVE:
         onMouseMove(int(lparam),int(dparam),uint(sparam));
         break;
      case CHARTEVENT_CHART_CHANGE:
         onChartChange();
         break;
      case CHARTEVENT_OBJECT_CREATE:
         onObjectCreate(sparam);
         break;
      case CHARTEVENT_OBJECT_DELETE:
         onObjectDelete(sparam);
         break;
      case CHARTEVENT_OBJECT_CHANGE:
         onObjectChange(sparam);
         break;
      case CHARTEVENT_OBJECT_CLICK:
         onObjectClick(sparam,int(lparam),int(dparam));
         break;
      case CHARTEVENT_OBJECT_DRAG:
         onObjectDrag(sparam);
         break;
      case CHARTEVENT_OBJECT_ENDEDIT:
         onObjectChange(sparam);
         break;
      default:
        {
         if(id>=CHARTEVENT_CUSTOM && id<=CHARTEVENT_CUSTOM_LAST)
           {
            onCustom(ushort(id-CHARTEVENT_CUSTOM),lparam,dparam,sparam);
           }
        }
     }
  }
//+------------------------------------------------------------------+
