//+------------------------------------------------------------------+
//| Module: Trade/Account.mqh                                        |
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
//| Wraps the AccountInfoInteger/Double/String                       |
//+------------------------------------------------------------------+
class Account
  {
public:
   static long getLogin() {return AccountInfoInteger(ACCOUNT_LOGIN);}

   static ENUM_ACCOUNT_TRADE_MODE getTradeMode() {return(ENUM_ACCOUNT_TRADE_MODE)AccountInfoInteger(ACCOUNT_TRADE_MODE);}
   static bool isReal() {return Account::getTradeMode()==ACCOUNT_TRADE_MODE_REAL;}
   static bool isDemo() {return Account::getTradeMode()==ACCOUNT_TRADE_MODE_DEMO;}
   static bool isContest() {return Account::getTradeMode()==ACCOUNT_TRADE_MODE_CONTEST;}
   static long getLeverage() {return AccountInfoInteger(ACCOUNT_LEVERAGE);}
   static int  getMaximumPendingOrders() {return(int)AccountInfoInteger(ACCOUNT_LIMIT_ORDERS);}
   //--- if account allows trade
   static bool allowsTrade() {return AccountInfoInteger(ACCOUNT_TRADE_ALLOWED)!=0;}
   //--- if account allows trade of expert advisors from the server side
   static bool allowsExpertTrade() {return AccountInfoInteger(ACCOUNT_TRADE_EXPERT)!=0;}

   static ENUM_ACCOUNT_STOPOUT_MODE getStopoutMode() {return(ENUM_ACCOUNT_STOPOUT_MODE)AccountInfoInteger(ACCOUNT_MARGIN_SO_MODE);}
   static bool isPercentStopout() {return Account::getStopoutMode()==ACCOUNT_STOPOUT_MODE_PERCENT;}
   static bool isCurrencyStopout() {return Account::getStopoutMode()==ACCOUNT_STOPOUT_MODE_MONEY;}

   static string getClientName() {return AccountInfoString(ACCOUNT_NAME);}
   static string getServerName() {return AccountInfoString(ACCOUNT_SERVER);}
   static string getCurrency() {return AccountInfoString(ACCOUNT_CURRENCY);}
   static string getCompany() {return AccountInfoString(ACCOUNT_COMPANY);}

   static double getBalance() {return AccountInfoDouble(ACCOUNT_BALANCE);}
   static double getCredit() {return AccountInfoDouble(ACCOUNT_CREDIT);}
   static double getProfit() {return AccountInfoDouble(ACCOUNT_PROFIT);}
   static double getFloatingProfit() {return getEquity()-getBalance();}
   static double getEquity() {return AccountInfoDouble(ACCOUNT_EQUITY);}
   static double getMargin() {return AccountInfoDouble(ACCOUNT_MARGIN);}
   static double getFreeMargin() {return AccountInfoDouble(ACCOUNT_MARGIN_FREE);}
   static int    getFreeMarginCalcMode() {return AccountFreeMarginMode();}
   static double getMarginLevel() {return AccountInfoDouble(ACCOUNT_MARGIN_LEVEL);}
   static double getMarginCallLevel() {return AccountInfoDouble(ACCOUNT_MARGIN_SO_CALL);}
   static double getMarginStopoutLevel() {return AccountInfoDouble(ACCOUNT_MARGIN_SO_SO);}
  };
//+------------------------------------------------------------------+
