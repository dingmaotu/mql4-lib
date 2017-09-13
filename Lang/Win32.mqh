//+------------------------------------------------------------------+
//| Module: Lang/Win32.mqh                                           |
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
#include "Native.mqh"

//+------------------------------------------------------------------+
//| Win32 specific                                                   |
//+------------------------------------------------------------------+

//--- _WIN32_WINNT version constants
#define _WIN32_WINNT_NT4                    0x0400 // Windows NT 4.0
#define _WIN32_WINNT_WIN2K                  0x0500 // Windows 2000
#define _WIN32_WINNT_WINXP                  0x0501 // Windows XP
#define _WIN32_WINNT_WS03                   0x0502 // Windows Server 2003
#define _WIN32_WINNT_WIN6                   0x0600 // Windows Vista
#define _WIN32_WINNT_VISTA                  0x0600 // Windows Vista
#define _WIN32_WINNT_WS08                   0x0600 // Windows Server 2008
#define _WIN32_WINNT_LONGHORN               0x0600 // Windows Vista
#define _WIN32_WINNT_WIN7                   0x0601 // Windows 7
#define _WIN32_WINNT_WIN8                   0x0602 // Windows 8
#define _WIN32_WINNT_WINBLUE                0x0603 // Windows 8.1
#define _WIN32_WINNT_WINTHRESHOLD           0x0A00 // Windows 10
#define _WIN32_WINNT_WIN10                  0x0A00 // Windows 10

//--- define you own for your target platform
#define WINVER 0x0A00
#define _WIN32_WINNT 0x0A00

#define FORMAT_MESSAGE_FROM_SYSTEM 0x00001000
#define FORMAT_MESSAGE_IGNORE_INSERTS 0x00000200

#import "kernel32.dll"
// close any kernel object handle
bool CloseHandle(intptr_t hObject);
uint FormatMessageW(uint dwFlags,
                    intptr_t lpSource,
                    uint dwMessageId,
                    uint dwLanguageId,
                    ushort &buffer[],
                    uint nSize,
                    intptr_t Arguments
                    );
#import

//--- Instead of including <WinUser32.mqh> which is a standard header of the official MetaTrader4 distribution
//--- we directly include the content here as MetaTrader5 does not come with the header
#import "user32.dll"
//---- messages
int      SendMessageA(int hWnd,int Msg,int wParam,int lParam);
int      SendMessageW(int hWnd,int Msg,int wParam,int lParam);
int      SendNotifyMessageA(int hWnd,int Msg,int wParam,int lParam);
int      SendNotifyMessageW(int hWnd,int Msg,int wParam,int lParam);
int      PostMessageA(int hWnd,int Msg,int wParam,int lParam);
int      PostMessageW(int hWnd,int Msg,int wParam,int lParam);
void     keybd_event(int bVk,int bScan,int dwFlags,int dwExtraInfo);
void     mouse_event(int dwFlags,int dx,int dy,int dwData,int dwExtraInfo);
//---- windows
int      FindWindowA(char &lpClassName[],char &lpWindowName[]);
int      FindWindowW(string lpClassName,string lpWindowName);
int      SetWindowTextA(int hWnd,char &lpString[]);
int      SetWindowTextW(int hWnd,string lpString);
int      GetWindowTextA(int hWnd,char &lpString[],int nMaxCount);
int      GetWindowTextW(int hWnd,string lpString,int nMaxCount);
int      GetWindowTextLengthA(int hWnd);
int      GetWindowTextLengthW(int hWnd);
int      GetWindow(int hWnd,int uCmd);
int      GetParent(int hWnd);

int      UpdateWindow(int hWnd);
int      EnableWindow(int hWnd,int bEnable);
int      DestroyWindow(int hWnd);
int      ShowWindow(int hWnd,int nCmdShow);
int      SetActiveWindow(int hWnd);
int      AnimateWindow(int hWnd,int dwTime,int dwFlags);
int      FlashWindow(int hWnd,int dwFlags /*bInvert*/);
int      CloseWindow(int hWnd);
int      MoveWindow(int hWnd,int X,int Y,int nWidth,int nHeight,int bRepaint);
int      SetWindowPos(int hWnd,int hWndInsertAfter,int X,int Y,int cx,int cy,int uFlags);
int      IsWindowVisible(int hWnd);
int      IsIconic(int hWnd);
int      IsZoomed(int hWnd);
int      SetFocus(int hWnd);
int      GetFocus();
int      GetActiveWindow();
int      IsWindowEnabled(int hWnd);
//---- miscelaneouse
int      MessageBoxA(int hWnd,char &lpText[],char &lpCaption[],int uType);
int      MessageBoxW(int hWnd,string lpText,string lpCaption,int uType);
int      MessageBoxExA(int hWnd,char &lpText[],char &lpCaption[],int uType,int wLanguageId);
int      MessageBoxExW(int hWnd,string lpText,string lpCaption,int uType,int wLanguageId);
int      MessageBeep(int uType);
int      GetSystemMetrics(int nIndex);
int      ExitWindowsEx(int uFlags,int dwReserved);
int      SwapMouseButton(int fSwap);
//--- added by mql4-lib
short    GetAsyncKeyState(int nVirtKey);
#import

//---- Window Messages
#define WM_NULL                        0x0000
#define WM_CREATE                      0x0001
#define WM_DESTROY                     0x0002
#define WM_MOVE                        0x0003
#define WM_SIZE                        0x0005
#define WM_ACTIVATE                    0x0006
#define WM_SETFOCUS                    0x0007
#define WM_KILLFOCUS                   0x0008
#define WM_ENABLE                      0x000A
#define WM_SETREDRAW                   0x000B
#define WM_SETTEXT                     0x000C
#define WM_GETTEXT                     0x000D
#define WM_GETTEXTLENGTH               0x000E
#define WM_PAINT                       0x000F
#define WM_CLOSE                       0x0010
#define WM_QUERYENDSESSION             0x0011
#define WM_QUIT                        0x0012
#define WM_QUERYOPEN                   0x0013
#define WM_ERASEBKGND                  0x0014
#define WM_SYSCOLORCHANGE              0x0015
#define WM_ENDSESSION                  0x0016
#define WM_SHOWWINDOW                  0x0018
#define WM_WININICHANGE                0x001A
#define WM_SETTINGCHANGE               0x001A // WM_WININICHANGE
#define WM_DEVMODECHANGE               0x001B
#define WM_ACTIVATEAPP                 0x001C
#define WM_FONTCHANGE                  0x001D
#define WM_TIMECHANGE                  0x001E
#define WM_CANCELMODE                  0x001F
#define WM_SETCURSOR                   0x0020
#define WM_MOUSEACTIVATE               0x0021
#define WM_CHILDACTIVATE               0x0022
#define WM_QUEUESYNC                   0x0023
#define WM_GETMINMAXINFO               0x0024
#define WM_PAINTICON                   0x0026
#define WM_ICONERASEBKGND              0x0027
#define WM_NEXTDLGCTL                  0x0028
#define WM_SPOOLERSTATUS               0x002A
#define WM_DRAWITEM                    0x002B
#define WM_MEASUREITEM                 0x002C
#define WM_DELETEITEM                  0x002D
#define WM_VKEYTOITEM                  0x002E
#define WM_CHARTOITEM                  0x002F
#define WM_SETFONT                     0x0030
#define WM_GETFONT                     0x0031
#define WM_SETHOTKEY                   0x0032
#define WM_GETHOTKEY                   0x0033
#define WM_QUERYDRAGICON               0x0037
#define WM_COMPAREITEM                 0x0039
#define WM_GETOBJECT                   0x003D
#define WM_COMPACTING                  0x0041
#define WM_WINDOWPOSCHANGING           0x0046
#define WM_WINDOWPOSCHANGED            0x0047
#define WM_COPYDATA                    0x004A
#define WM_CANCELJOURNAL               0x004B
#define WM_NOTIFY                      0x004E
#define WM_INPUTLANGCHANGEREQUEST      0x0050
#define WM_INPUTLANGCHANGE             0x0051
#define WM_TCARD                       0x0052
#define WM_HELP                        0x0053
#define WM_USERCHANGED                 0x0054
#define WM_NOTIFYFORMAT                0x0055
#define WM_CONTEXTMENU                 0x007B
#define WM_STYLECHANGING               0x007C
#define WM_STYLECHANGED                0x007D
#define WM_DISPLAYCHANGE               0x007E
#define WM_GETICON                     0x007F
#define WM_SETICON                     0x0080
#define WM_NCCREATE                    0x0081
#define WM_NCDESTROY                   0x0082
#define WM_NCCALCSIZE                  0x0083
#define WM_NCHITTEST                   0x0084
#define WM_NCPAINT                     0x0085
#define WM_NCACTIVATE                  0x0086
#define WM_GETDLGCODE                  0x0087
#define WM_SYNCPAINT                   0x0088
#define WM_NCMOUSEMOVE                 0x00A0
#define WM_NCLBUTTONDOWN               0x00A1
#define WM_NCLBUTTONUP                 0x00A2
#define WM_NCLBUTTONDBLCLK             0x00A3
#define WM_NCRBUTTONDOWN               0x00A4
#define WM_NCRBUTTONUP                 0x00A5
#define WM_NCRBUTTONDBLCLK             0x00A6
#define WM_NCMBUTTONDOWN               0x00A7
#define WM_NCMBUTTONUP                 0x00A8
#define WM_NCMBUTTONDBLCLK             0x00A9
#define WM_KEYFIRST                    0x0100
#define WM_KEYDOWN                     0x0100
#define WM_KEYUP                       0x0101
#define WM_CHAR                        0x0102
#define WM_DEADCHAR                    0x0103
#define WM_SYSKEYDOWN                  0x0104
#define WM_SYSKEYUP                    0x0105
#define WM_SYSCHAR                     0x0106
#define WM_SYSDEADCHAR                 0x0107
#define WM_KEYLAST                     0x0108
#define WM_INITDIALOG                  0x0110
#define WM_COMMAND                     0x0111
#define WM_SYSCOMMAND                  0x0112
#define WM_TIMER                       0x0113
#define WM_HSCROLL                     0x0114
#define WM_VSCROLL                     0x0115
#define WM_INITMENU                    0x0116
#define WM_INITMENUPOPUP               0x0117
#define WM_MENUSELECT                  0x011F
#define WM_MENUCHAR                    0x0120
#define WM_ENTERIDLE                   0x0121
#define WM_MENURBUTTONUP               0x0122
#define WM_MENUDRAG                    0x0123
#define WM_MENUGETOBJECT               0x0124
#define WM_UNINITMENUPOPUP             0x0125
#define WM_MENUCOMMAND                 0x0126
#define WM_CTLCOLORMSGBOX              0x0132
#define WM_CTLCOLOREDIT                0x0133
#define WM_CTLCOLORLISTBOX             0x0134
#define WM_CTLCOLORBTN                 0x0135
#define WM_CTLCOLORDLG                 0x0136
#define WM_CTLCOLORSCROLLBAR           0x0137
#define WM_CTLCOLORSTATIC              0x0138
#define WM_MOUSEFIRST                  0x0200
#define WM_MOUSEMOVE                   0x0200
#define WM_LBUTTONDOWN                 0x0201
#define WM_LBUTTONUP                   0x0202
#define WM_LBUTTONDBLCLK               0x0203
#define WM_RBUTTONDOWN                 0x0204
#define WM_RBUTTONUP                   0x0205
#define WM_RBUTTONDBLCLK               0x0206
#define WM_MBUTTONDOWN                 0x0207
#define WM_MBUTTONUP                   0x0208
#define WM_MBUTTONDBLCLK               0x0209
#define WM_PARENTNOTIFY                0x0210
#define WM_ENTERMENULOOP               0x0211
#define WM_EXITMENULOOP                0x0212
#define WM_NEXTMENU                    0x0213
#define WM_SIZING                      0x0214
#define WM_CAPTURECHANGED              0x0215
#define WM_MOVING                      0x0216
#define WM_DEVICECHANGE                0x0219
#define WM_MDICREATE                   0x0220
#define WM_MDIDESTROY                  0x0221
#define WM_MDIACTIVATE                 0x0222
#define WM_MDIRESTORE                  0x0223
#define WM_MDINEXT                     0x0224
#define WM_MDIMAXIMIZE                 0x0225
#define WM_MDITILE                     0x0226
#define WM_MDICASCADE                  0x0227
#define WM_MDIICONARRANGE              0x0228
#define WM_MDIGETACTIVE                0x0229
#define WM_MDISETMENU                  0x0230
#define WM_ENTERSIZEMOVE               0x0231
#define WM_EXITSIZEMOVE                0x0232
#define WM_DROPFILES                   0x0233
#define WM_MDIREFRESHMENU              0x0234
#define WM_MOUSEHOVER                  0x02A1
#define WM_MOUSELEAVE                  0x02A3
#define WM_CUT                         0x0300
#define WM_COPY                        0x0301
#define WM_PASTE                       0x0302
#define WM_CLEAR                       0x0303
#define WM_UNDO                        0x0304
#define WM_RENDERFORMAT                0x0305
#define WM_RENDERALLFORMATS            0x0306
#define WM_DESTROYCLIPBOARD            0x0307
#define WM_DRAWCLIPBOARD               0x0308
#define WM_PAINTCLIPBOARD              0x0309
#define WM_VSCROLLCLIPBOARD            0x030A
#define WM_SIZECLIPBOARD               0x030B
#define WM_ASKCBFORMATNAME             0x030C
#define WM_CHANGECBCHAIN               0x030D
#define WM_HSCROLLCLIPBOARD            0x030E
#define WM_QUERYNEWPALETTE             0x030F
#define WM_PALETTEISCHANGING           0x0310
#define WM_PALETTECHANGED              0x0311
#define WM_HOTKEY                      0x0312
#define WM_PRINT                       0x0317
#define WM_PRINTCLIENT                 0x0318
#define WM_HANDHELDFIRST               0x0358
#define WM_HANDHELDLAST                0x035F
#define WM_AFXFIRST                    0x0360
#define WM_AFXLAST                     0x037F
#define WM_PENWINFIRST                 0x0380
#define WM_PENWINLAST                  0x038F
#define WM_APP                         0x8000

//---- keybd_event routines
#define KEYEVENTF_EXTENDEDKEY          0x0001
#define KEYEVENTF_KEYUP                0x0002
//---- mouse_event routines
#define MOUSEEVENTF_MOVE               0x0001 // mouse move
#define MOUSEEVENTF_LEFTDOWN           0x0002 // left button down
#define MOUSEEVENTF_LEFTUP             0x0004 // left button up
#define MOUSEEVENTF_RIGHTDOWN          0x0008 // right button down
#define MOUSEEVENTF_RIGHTUP            0x0010 // right button up
#define MOUSEEVENTF_MIDDLEDOWN         0x0020 // middle button down
#define MOUSEEVENTF_MIDDLEUP           0x0040 // middle button up
#define MOUSEEVENTF_WHEEL              0x0800 // wheel button rolled
#define MOUSEEVENTF_ABSOLUTE           0x8000 // absolute move

//---- GetSystemMetrics() codes
#define SM_CXSCREEN                    0
#define SM_CYSCREEN                    1
#define SM_CXVSCROLL                   2
#define SM_CYHSCROLL                   3
#define SM_CYCAPTION                   4
#define SM_CXBORDER                    5
#define SM_CYBORDER                    6
#define SM_CXDLGFRAME                  7
#define SM_CYDLGFRAME                  8
#define SM_CYVTHUMB                    9
#define SM_CXHTHUMB                    10
#define SM_CXICON                      11
#define SM_CYICON                      12
#define SM_CXCURSOR                    13
#define SM_CYCURSOR                    14
#define SM_CYMENU                      15
#define SM_CXFULLSCREEN                16
#define SM_CYFULLSCREEN                17
#define SM_CYKANJIWINDOW               18
#define SM_MOUSEPRESENT                19
#define SM_CYVSCROLL                   20
#define SM_CXHSCROLL                   21
#define SM_DEBUG                       22
#define SM_SWAPBUTTON                  23
#define SM_RESERVED1                   24
#define SM_RESERVED2                   25
#define SM_RESERVED3                   26
#define SM_RESERVED4                   27
#define SM_CXMIN                       28
#define SM_CYMIN                       29
#define SM_CXSIZE                      30
#define SM_CYSIZE                      31
#define SM_CXFRAME                     32
#define SM_CYFRAME                     33
#define SM_CXMINTRACK                  34
#define SM_CYMINTRACK                  35
#define SM_CXDOUBLECLK                 36
#define SM_CYDOUBLECLK                 37
#define SM_CXICONSPACING               38
#define SM_CYICONSPACING               39
#define SM_MENUDROPALIGNMENT           40
#define SM_PENWINDOWS                  41
#define SM_DBCSENABLED                 42
#define SM_CMOUSEBUTTONS               43
#define SM_SECURE                      44
#define SM_CXEDGE                      45
#define SM_CYEDGE                      46
#define SM_CXMINSPACING                47
#define SM_CYMINSPACING                48
#define SM_CXSMICON                    49
#define SM_CYSMICON                    50
#define SM_CYSMCAPTION                 51
#define SM_CXSMSIZE                    52
#define SM_CYSMSIZE                    53
#define SM_CXMENUSIZE                  54
#define SM_CYMENUSIZE                  55
#define SM_ARRANGE                     56
#define SM_CXMINIMIZED                 57
#define SM_CYMINIMIZED                 58
#define SM_CXMAXTRACK                  59
#define SM_CYMAXTRACK                  60
#define SM_CXMAXIMIZED                 61
#define SM_CYMAXIMIZED                 62
#define SM_NETWORK                     63
#define SM_CLEANBOOT                   67
#define SM_CXDRAG                      68
#define SM_CYDRAG                      69
#define SM_SHOWSOUNDS                  70
#define SM_CXMENUCHECK                 71 // Use instead of GetMenuCheckMarkDimensions()!
#define SM_CYMENUCHECK                 72
#define SM_SLOWMACHINE                 73
#define SM_MIDEASTENABLED              74
#define SM_MOUSEWHEELPRESENT           75
#define SM_XVIRTUALSCREEN              76
#define SM_YVIRTUALSCREEN              77
#define SM_CXVIRTUALSCREEN             78
#define SM_CYVIRTUALSCREEN             79
#define SM_CMONITORS                   80
#define SM_SAMEDISPLAYFORMAT           81

//---- GetWindow() Constants
#define GW_HWNDFIRST                   0
#define GW_HWNDLAST                    1
#define GW_HWNDNEXT                    2
#define GW_HWNDPREV                    3
#define GW_OWNER                       4
#define GW_CHILD                       5

//---- AnimateWindow() Commands
#define AW_HOR_POSITIVE                0x00000001
#define AW_HOR_NEGATIVE                0x00000002
#define AW_VER_POSITIVE                0x00000004
#define AW_VER_NEGATIVE                0x00000008
#define AW_CENTER                      0x00000010
#define AW_HIDE                        0x00010000
#define AW_ACTIVATE                    0x00020000
#define AW_SLIDE                       0x00040000
#define AW_BLEND                       0x00080000

//---- MessageBox() Flags
#define MB_OK                       	0x00000000
#define MB_OKCANCEL                 	0x00000001
#define MB_ABORTRETRYIGNORE         	0x00000002
#define MB_YESNOCANCEL              	0x00000003
#define MB_YESNO                    	0x00000004
#define MB_RETRYCANCEL              	0x00000005
#define MB_ICONHAND                 	0x00000010
#define MB_ICONQUESTION             	0x00000020
#define MB_ICONEXCLAMATION          	0x00000030
#define MB_ICONASTERISK             	0x00000040
#define MB_USERICON                 	0x00000080
#define MB_ICONWARNING              	MB_ICONEXCLAMATION
#define MB_ICONERROR                	MB_ICONHAND
#define MB_ICONINFORMATION          	MB_ICONASTERISK
#define MB_ICONSTOP                 	MB_ICONHAND
#define MB_DEFBUTTON1               	0x00000000
#define MB_DEFBUTTON2               	0x00000100
#define MB_DEFBUTTON3               	0x00000200
#define MB_DEFBUTTON4               	0x00000300
#define MB_APPLMODAL                	0x00000000
#define MB_SYSTEMMODAL              	0x00001000
#define MB_TASKMODAL                	0x00002000
#define MB_HELP                     	0x00004000 // Help Button
#define MB_NOFOCUS                  	0x00008000
#define MB_SETFOREGROUND            	0x00010000
#define MB_DEFAULT_DESKTOP_ONLY     	0x00020000
#define MB_TOPMOST                  	0x00040000
#define MB_RIGHT                    	0x00080000
#define MB_RTLREADING               	0x00100000

//---- Dialog Box Command IDs
#define IDOK                           1
#define IDCANCEL                       2
#define IDABORT                        3
#define IDRETRY                        4
#define IDIGNORE                       5
#define IDYES                          6
#define IDNO                           7
#define IDCLOSE                        8
#define IDHELP                         9

//---- added by mql4-lib
//--- virtual key codes for the mouse
#define VK_LBUTTON 0x01
#define VK_RBUTTON 0x02
//+------------------------------------------------------------------+
//| Get system defined error code message                            |
//+------------------------------------------------------------------+
string GetErrorMessage(int errorCode)
  {
   static ushort buffer[64*1024];
   FormatMessageW(FORMAT_MESSAGE_FROM_SYSTEM|FORMAT_MESSAGE_IGNORE_INSERTS,
                  0,errorCode,0,buffer,ArraySize(buffer),0);
   return ShortArrayToString(buffer);
  }
//+------------------------------------------------------------------+
