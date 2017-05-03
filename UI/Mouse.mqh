//+------------------------------------------------------------------+
//|                                                     UI/Mouse.mqh |
//|                  Copyright 2017, Bear Two Technologies Co., Ltd. |
//+------------------------------------------------------------------+
#property strict

#import "user32.dll"
short GetAsyncKeyState(int nVirtKey);
int GetSystemMetrics(int nIndex);
#import

#define VK_LBUTTON 0x01
#define VK_RBUTTON 0x02
#define SM_MOUSEPRESENT 19
#define SM_SWAPBUTTON 23
//+------------------------------------------------------------------+
//|                                                                  |
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
