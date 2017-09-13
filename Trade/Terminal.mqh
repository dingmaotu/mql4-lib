//+------------------------------------------------------------------+
//| Module: Trade/Terminal.mqh                                       |
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
#property strict

#include "../Lang/Mql.mqh"
//+------------------------------------------------------------------+
//| Wrapper of terminal info functions                               |
//+------------------------------------------------------------------+
class Terminal
  {
public:
   static bool       isStopped() {return IsStopped();}
   static bool       isConnected() {return IsConnected();}

   static bool       hasCommunityAccount() {return TerminalInfoInteger(TERMINAL_COMMUNITY_ACCOUNT);}
   static bool       isCommunityConnected() {return TerminalInfoInteger(TERMINAL_COMMUNITY_CONNECTION);}
   static double     getCommunityBalance() {return TerminalInfoDouble(TERMINAL_COMMUNITY_BALANCE);}

   static string     getPath() {return TerminalInfoString(TERMINAL_PATH);}
   static string     getDataPath() {return TerminalInfoString(TERMINAL_DATA_PATH);}
   static string     getCommonDataPath() {return TerminalInfoString(TERMINAL_COMMONDATA_PATH);}

   static int        getCpuCores() {return TerminalInfoInteger(TERMINAL_CPU_CORES);}
   static int        getDiskSpace() {return TerminalInfoInteger(TERMINAL_DISK_SPACE);}
   static int        getPhysicalMemory() {return TerminalInfoInteger(TERMINAL_MEMORY_PHYSICAL);}

   static int        getTotalMemory() {return TerminalInfoInteger(TERMINAL_MEMORY_TOTAL);}
   static int        getFreeMemory() {return TerminalInfoInteger(TERMINAL_MEMORY_AVAILABLE);}
   static int        getUsedMemory() {return TerminalInfoInteger(TERMINAL_MEMORY_USED);}

   static int        getTerminalBuild() {return TerminalInfoInteger(TERMINAL_BUILD);}
   static string     getTerminalName() {return TerminalInfoString(TERMINAL_NAME);}
   static string     getTerminalCompany() {return TerminalInfoString(TERMINAL_COMPANY);}
   static string     getTerminalLanguage() {return TerminalInfoString(TERMINAL_LANGUAGE);}

   static bool       isDllAllowed() {return TerminalInfoInteger(TERMINAL_DLLS_ALLOWED);}
   static bool       isTradeAllowed() {return TerminalInfoInteger(TERMINAL_TRADE_ALLOWED);}
   static bool       isEmailEnabled() {return TerminalInfoInteger(TERMINAL_EMAIL_ENABLED);}
   static bool       isFtpEnabled() {return TerminalInfoInteger(TERMINAL_FTP_ENABLED);}

   static bool       isNotificationsEnabled() {return TerminalInfoInteger(TERMINAL_NOTIFICATIONS_ENABLED);}
   static bool       hasMetaQuotesId() {return TerminalInfoInteger(TERMINAL_MQID);}
   static bool       notify(string msg);
   static bool       mail(string subject,string content);

   static int        getScreenDpi() {return TerminalInfoInteger(TERMINAL_SCREEN_DPI);}
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Terminal::notify(string msg)
  {
   int len=StringLen(msg);

   if(len==0 || len>255)
     {
      Alert("ERROR: [",__FUNCTION__,"] Notification message is empty or larger than 255 characters.");
      return false;
     }

   if(isNotificationsEnabled() && hasMetaQuotesId())
     {
      bool success=SendNotification(msg);
      if(!success)
        {
         Alert("ERROR: [",__FUNCTION__,"] ",Mql::getErrorMessage(Mql::getLastError()));
        }
      return success;
     }
   else
     {
      Alert("ERROR: [",__FUNCTION__,"] Notification is not enabled or MetaQuotes ID is not set.");
      return false;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Terminal::mail(string subject,string content)
  {
   if(Terminal::isEmailEnabled())
     {
      if(!SendMail(subject,content))
        {
         int code=Mql::getLastError();
         PrintFormat(">>> Sending mail failed with error %d: %s",code,Mql::getErrorMessage(code));
        }
     }
   return false;
  }
//+------------------------------------------------------------------+
