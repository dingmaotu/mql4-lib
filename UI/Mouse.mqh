//+------------------------------------------------------------------+
//| Module: UI/Mouse.mqh                                             |
//| This file is part of the mql4-lib project:                       |
//|     https://github.com/dingmaotu/mql4-lib                        |
//|                                                                  |
//| Copyright 2015-2017 Li Ding <dingmaotu@126.com>                  |
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

#include "../Lang/Win32.mqh"
//+------------------------------------------------------------------+
//| Detecting Mouse input                                            |
//+------------------------------------------------------------------+
class Mouse
  {
public:
   static bool       hasMouse() {return GetSystemMetrics(SM_MOUSEPRESENT)>0;}
   static bool       isLeftDown()
     {
      if(GetSystemMetrics(SM_SWAPBUTTON)>0)
         return GetAsyncKeyState(VK_RBUTTON) < 0;
      else
         return GetAsyncKeyState(VK_LBUTTON) < 0;
     }
   static bool       isRightDown()
     {
      if(GetSystemMetrics(SM_SWAPBUTTON)>0)
         return GetAsyncKeyState(VK_LBUTTON) < 0;
      else
         return GetAsyncKeyState(VK_RBUTTON) < 0;
     }
  };
//+------------------------------------------------------------------+
