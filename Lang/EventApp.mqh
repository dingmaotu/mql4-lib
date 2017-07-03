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

#define DECLARE_EVENT_APP(AppClass,Boolean) \
DECLARE_APP(AppClass,Boolean)\
void OnTimer() {dynamic_cast<EventApp*>(App::Global).onTimer();}\
void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)\
{\
  if(IsKeydownMessage(lparam)){\
   ushort event;uint param;\
   DecodeKeydownMessage(lparam,dparam,event,param);\
   dynamic_cast<EventApp*>(App::Global).onAppEvent(event,param);\
  }else{\
   dynamic_cast<EventApp*>(App::Global).onChartEvent(id,lparam,dparam,sparam);\
  }\
}
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
public:
                    ~EventApp() {if(m_hasTimer)EventKillTimer();}
   virtual void      onTimer()=0;
   virtual void      onChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)=0;
   virtual void      onAppEvent(const ushort event,const uint param)=0;
  };
//+------------------------------------------------------------------+
