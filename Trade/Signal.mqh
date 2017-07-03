//+------------------------------------------------------------------+
//| Module: Trade/Signal.mqh                                         |
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
#include "../Lang/Mql.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class SignalPool
  {
   static int        total() {return SignalBaseTotal();}
   static bool       select(int index) {return SignalBaseSelect(index);}
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Signal
  {
private:
   ObjectAttrRead(long,id,Id);

   ObjectAttrRead(double,balance,Balance);
   ObjectAttrRead(double,equity,Ealance);
   ObjectAttrRead(double,gain,Gain);
   ObjectAttrRead(double,maxDrawdown,MaxDrawdown);
   ObjectAttrRead(double,price,Price);
   ObjectAttrRead(double,roi,Roi);

   ObjectAttrRead(datetime,publishDate,PublishDate);
   ObjectAttrRead(datetime,startDate,StartDate);
   ObjectAttrRead(int,leverage,Leverage);
   ObjectAttrRead(int,pips,Pips);
   ObjectAttrRead(int,rating,Rating);
   ObjectAttrRead(int,subscribers,Subscribers);
   ObjectAttrRead(int,trades,Trades);
   ObjectAttrRead(int,tradeMode,TradeMode);

   ObjectAttrRead(string,name,Name);
   ObjectAttrRead(string,login,Login);
   ObjectAttrRead(string,broker,Broker);
   ObjectAttrRead(string,server,Server);
   ObjectAttrRead(string,currency,Currency);
public:
                     Signal()
     {
      sync();
     }
   void              sync()
     {
      m_id=SignalBaseGetInteger(SIGNAL_BASE_ID);
      m_name=SignalBaseGetString(SIGNAL_BASE_NAME);

      m_balance=SignalBaseGetDouble(SIGNAL_BASE_BALANCE);
      m_equity=SignalBaseGetDouble(SIGNAL_BASE_EQUITY);
      m_gain=SignalBaseGetDouble(SIGNAL_BASE_GAIN);
      m_maxDrawdown=SignalBaseGetDouble(SIGNAL_BASE_MAX_DRAWDOWN);
      m_price=SignalBaseGetDouble(SIGNAL_BASE_PRICE);
      m_roi=SignalBaseGetDouble(SIGNAL_BASE_ROI);

      m_publishDate=(datetime)SignalBaseGetInteger(SIGNAL_BASE_DATE_PUBLISHED);
      m_startDate=(datetime)SignalBaseGetInteger(SIGNAL_BASE_DATE_STARTED);
      m_leverage=(int)SignalBaseGetInteger(SIGNAL_BASE_LEVERAGE);
      m_pips=(int)SignalBaseGetInteger(SIGNAL_BASE_PIPS);
      m_rating=(int)SignalBaseGetInteger(SIGNAL_BASE_RATING);
      m_subscribers=(int)SignalBaseGetInteger(SIGNAL_BASE_SUBSCRIBERS);
      m_trades=(int)SignalBaseGetInteger(SIGNAL_BASE_TRADES);
      m_tradeMode=(int)SignalBaseGetInteger(SIGNAL_BASE_TRADE_MODE);

      m_login=SignalBaseGetString(SIGNAL_BASE_AUTHOR_LOGIN);
      m_broker=SignalBaseGetString(SIGNAL_BASE_BROKER);
      m_server=SignalBaseGetString(SIGNAL_BASE_BROKER_SERVER);
      m_currency=SignalBaseGetString(SIGNAL_BASE_CURRENCY);
     }

   bool              isReal() const {return m_tradeMode==0;}
   bool              isDemo() const {return m_tradeMode==1;}
   bool              isContest() const {return m_tradeMode==2;}

   bool              subscribe() {return SignalSubscribe(m_id);}
   bool              unsubscribe() {return SignalUnsubscribe();}
  };
//+------------------------------------------------------------------+
//| Signal copy settings in the terminal                             |
//+------------------------------------------------------------------+
class SignalSetting
  {
   static long       getId() {return SignalInfoGetInteger(SIGNAL_INFO_ID);}
   static string     getName() {return SignalInfoGetString(SIGNAL_INFO_NAME);}

   static bool       isTermsAgreed() {return SignalInfoGetInteger(SIGNAL_INFO_TERMS_AGREE)!=0;}

   static bool       isSubscriptionEnabled() {return SignalInfoGetInteger(SIGNAL_INFO_SUBSCRIPTION_ENABLED);}
   static bool       setSubscriptionEnabled(bool value) {return SignalInfoSetInteger(SIGNAL_INFO_SUBSCRIPTION_ENABLED,value);}

   static double     getEquityLimit() {return SignalInfoGetDouble(SIGNAL_INFO_EQUITY_LIMIT);}
   static bool       setEquityLimit(double value) {return SignalInfoSetDouble(SIGNAL_INFO_EQUITY_LIMIT,value);}

   static double     getSlippage() {return SignalInfoGetDouble(SIGNAL_INFO_SLIPPAGE);}
   static bool       setSlippage(double value) {return SignalInfoSetDouble(SIGNAL_INFO_SLIPPAGE,value);}

   static double     getVolumePercent() {return SignalInfoGetDouble(SIGNAL_INFO_VOLUME_PERCENT);}

   static bool       isConfirmationsDisabled() {return SignalInfoGetInteger(SIGNAL_INFO_CONFIRMATIONS_DISABLED)!=0;}
   static bool       setConfirmationsDisabled(bool value) {return SignalInfoSetInteger(SIGNAL_INFO_CONFIRMATIONS_DISABLED,value);}

   static bool       isCopyStopLevels() {return SignalInfoGetInteger(SIGNAL_INFO_COPY_SLTP)!=0;}
   static bool       setCopyStopLevels(bool value) {return SignalInfoSetInteger(SIGNAL_INFO_COPY_SLTP,value);}

   static int        getDepositPercent() {return(int)SignalInfoGetInteger(SIGNAL_INFO_DEPOSIT_PERCENT);}
   static bool       setDepositPercent(int value) {return SignalInfoSetInteger(SIGNAL_INFO_DEPOSIT_PERCENT,value);}
  };
//+------------------------------------------------------------------+
