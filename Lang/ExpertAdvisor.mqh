//+------------------------------------------------------------------+
//| Module: Lang/ExpertAdvisor.mqh                                   |
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

#include "EventApp.mqh"

#define DECLARE_EA(AppClass,Boolean) \
DECLARE_EVENT_APP(AppClass,Boolean)\
double OnTester() {return dynamic_cast<ExpertAdvisor*>(App::Global).onTester();}\
void OnTick() {dynamic_cast<ExpertAdvisor*>(App::Global).main();}
//+------------------------------------------------------------------+
//| Abstract base class for a MQL Expert Advisor                     |
//+------------------------------------------------------------------+
class ExpertAdvisor: public EventApp
  {
public:
   virtual void      main() {}
   //--- default for EA Tester
   virtual double    onTester() {return 0.0;}
  };
//+------------------------------------------------------------------+
