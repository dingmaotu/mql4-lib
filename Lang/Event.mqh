//+------------------------------------------------------------------+
//| Module: Lang/Event.mqh                                           |
//| This file is part of the mql4-lib project:                       |
//|     https://github.com/dingmaotu/mql4-lib                        |
//|                                                                  |
//| Copyright 2016 Li Ding <dingmaotu@126.com>                       |
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

/*
This module provides a way to send custom events from outside
the MetaTrader terminal runtime, like from a DLL.

You need to call the PostMessage/PostThreadMessage funtion, and pass
parameters as encoded in the same algorithm with EncodeKeydownMessage.
Then any program that derives from EventApp can process this message
from its onAppEvent event handler:

   #include <WinUser32.mqh>
   #include <MQL4/Lang/Event.mqh>
   bool SendAppEvent(int hwnd,ushort event,uint param)
     {
      int wparam, lparam;
      EncodeKeydownMessage(event, param, wparam, lparam);
      return PostMessageW(hwnd,WM_KEYDOWN,wparam, lparam) != 0;
     }

The mechanism uses a custom WM_KEYDOWN message to trigger the OnChartEvent.
In OnChartEvent handler, EventApp checks if KeyDown event is actually
a custom app event from another source (not a real key down). If it is,
then EventApp calls its onAppEvent method.

This mechnism has certain limitations: the parameter is only an integer (32bit),
due to how WM_KEYDOWN is processed in MetaTrader terminal. And this solution
may not work in 64bit MetaTrader5.

Despite the limitations, this literally liberates you from the MetaTrader jail:
you can send in events any time and let mt4 program process it, without polling
in OnTimer, or creating pipe/sockets in OnTick, which is the way most API
wrappers work.

Using OnTimer is not a good idea. First it can not receive any parameters from
the MQL side. You at least needs an idenfier for the event. Second, WM_TIMER
events are very crowded in the main thread. Even on weekends where there are no
data coming in, WM_TIMER is constantly sent to the main thread. This makes
more instructions executed to decide if it is a valid event for the program.

WARNING:
This is a temporary solution. The best way to handle asynchronous events
is to find out how ChartEventCustom is implemented and implement that in C/C++,
which is extremely hard as it is not implemented by win32 messages, and you
can not look into it because of very strong anti-debugging measures.

Inside MetaTrader terminal, you better use ChartEventCustom to
send custom events.
*/

#property strict
#include "Number.mqh" // for SHORT_BITS
//+------------------------------------------------------------------+
//| Encode AppEvent parameters to PostMessage parameters             |
//| This should not be used in mt4 programs, only as reference for   |
//| other languages.                                                 |
//+------------------------------------------------------------------+
void EncodeKeydownMessage(const ushort event,const uint param,int &wparam,int &lparam)
  {
   uint t=(uint)event;
   t<<= SHORT_BITS;
   t |= 0x80000000;
   uint highPart= param & 0xFFFF0000;
   uint lowPart = param & 0x0000FFFF;
   wparam = (int)(t|(highPart>>SHORT_BITS));
   lparam = (int)lowPart;
  }
//+------------------------------------------------------------------+
//| Check if the OnChartEvent parameter lparam is a special keydown  |
//+------------------------------------------------------------------+
bool IsKeydownMessage(const long lparam)
  {
   return (((uint)lparam)&0x80000000) != 0;
  }
//+------------------------------------------------------------------+
//| Decode OnChartEvent paramters to AppEvent parameters             |
//+------------------------------------------------------------------+
void DecodeKeydownMessage(const long lparam,const double dparam,ushort &event,uint &param)
  {
   uint t=((uint)lparam)&(~0x80000000);
   event=(ushort)((t&0xFFFF0000)>>SHORT_BITS);

   uint highPart=(t&0x0000FFFF)<<SHORT_BITS;
   uint lowPart=(uint)dparam;
   param=highPart|lowPart;
  }
//+------------------------------------------------------------------+
