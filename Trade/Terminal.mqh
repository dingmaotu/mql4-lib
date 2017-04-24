//+------------------------------------------------------------------+
//|                                               Trade/Terminal.mqh |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Li Ding"
#property link      "dingmaotu@hotmail.com"
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
