//+------------------------------------------------------------------+
//| Module: Trade/FxSymbol.mqh                                       |
//| This file is part of the mql4-lib project:                       |
//|     https://github.com/dingmaotu/mql4-lib                        |
//|                                                                  |
//| Copyright 2014-2016 Li Ding <dingmaotu@126.com>                  |
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
#include "../Utils/Math.mqh"
#include "../Collection/Vector.mqh"
#include "../Collection/HashMap.mqh"
#include "Account.mqh"
//+------------------------------------------------------------------+
//| FxSymbol wraps most functions for getting symbol info            |
//+------------------------------------------------------------------+
class FxSymbol
  {
private:
   const string      m_symbol;

public:
   //--- SymbolWatch
   static int        getTotal() {return SymbolsTotal(false);}
   static string     getName(int i) {return SymbolName(i,false);}

   static int        getTotalSelected() {return SymbolsTotal(true);}
   static string     getNameSelected(int i) {return SymbolName(i,true);}

   static bool       select(string symbol) {return SymbolSelect(symbol, true);}
   static bool       remove(string symbol) {return SymbolSelect(symbol, false);}

   static bool       isSelected(string symbol) {return SymbolInfoInteger(symbol,SYMBOL_SELECT)!=0;}
   static bool       isVisible(string symbol) {return SymbolInfoInteger(symbol,SYMBOL_VISIBLE)!=0;}

   //-- symbol info
   static string     getDescription(string symbol) {return SymbolInfoString(symbol,SYMBOL_DESCRIPTION);}
   static string     getPath(string symbol) {return SymbolInfoString(symbol,SYMBOL_PATH);}
   static string     getBaseCurrency(string symbol) {return SymbolInfoString(symbol,SYMBOL_CURRENCY_BASE);}
   static string     getProfitCurrency(string symbol) {return SymbolInfoString(symbol,SYMBOL_CURRENCY_PROFIT);}
   static string     getMarginCurrency(string symbol) {return SymbolInfoString(symbol,SYMBOL_CURRENCY_MARGIN);}

   //-- trade mode
   static ENUM_SYMBOL_TRADE_MODE getTradeMode(string symbol) {return(ENUM_SYMBOL_TRADE_MODE)SymbolInfoInteger(symbol,SYMBOL_TRADE_MODE);}
   static bool       isTradeDisabled(string symbol) {return getTradeMode(symbol)==SYMBOL_TRADE_MODE_DISABLED;}
   static bool       isTradeFully(string symbol) {return getTradeMode(symbol)==SYMBOL_TRADE_MODE_FULL;}
   static bool       isTradeShortOnly(string symbol) {return getTradeMode(symbol)==SYMBOL_TRADE_MODE_SHORTONLY;}
   static bool       isTradeLongOnly(string symbol) {return getTradeMode(symbol)==SYMBOL_TRADE_MODE_LONGONLY;}
   static bool       isTradeCloseOnly(string symbol) {return getTradeMode(symbol)==SYMBOL_TRADE_MODE_CLOSEONLY;}

   static double     getInitialMargin(string symbol) {return SymbolInfoDouble(symbol,SYMBOL_MARGIN_INITIAL);}
   static double     getMaintenanceMargin(string symbol) {return SymbolInfoDouble(symbol,SYMBOL_MARGIN_MAINTENANCE);}

   static double     getLongSwap(string symbol) {return SymbolInfoDouble(symbol,SYMBOL_SWAP_LONG);}
   static double     getShortSwap(string symbol) {return SymbolInfoDouble(symbol,SYMBOL_SWAP_SHORT);}

   static double     getHedgedMargin(string symbol) {return MarketInfo(symbol,MODE_MARGINHEDGED);}
   static double     getRequiredMargin(string symbol) {return MarketInfo(symbol,MODE_MARGINREQUIRED);}

   //-- Profit calculation mode. 0 - Forex; 1 - CFD; 2 - Futures
   static int        getProfitCalcMode(string symbol) {return(int)MarketInfo(symbol,MODE_PROFITCALCMODE);}
   //-- Margin calculation mode. 0 - Forex; 1 - CFD; 2 - Futures; 3 - CFD for indices
   static int        getMarginCalcMode(string symbol) {return(int)MarketInfo(symbol,MODE_MARGINCALCMODE);}

   static bool       isCloseByAllowed(string symbol) {return(int)MarketInfo(symbol,MODE_CLOSEBY_ALLOWED)!=0;}

   //-- latest market info
   static double     getBid(string symbol) {return SymbolInfoDouble(symbol,SYMBOL_BID);}
   static double     getAsk(string symbol) {return SymbolInfoDouble(symbol,SYMBOL_ASK);}
   static double     getMid(string symbol) {return (getAsk(symbol)+getBid(symbol))/2;}
   static bool       getTick(string symbol,MqlTick &tick) {return SymbolInfoTick(symbol,tick);}

   static double     getTickSize(string symbol) {return SymbolInfoDouble(symbol,SYMBOL_TRADE_TICK_SIZE);}
   static double     getTickValue(string symbol) {return SymbolInfoDouble(symbol,SYMBOL_TRADE_TICK_VALUE);}

   static double     getContractSize(string symbol) {return SymbolInfoDouble(symbol,SYMBOL_TRADE_CONTRACT_SIZE);}

   //-- basic trade info
   static double     getPoint(string symbol) {return SymbolInfoDouble(symbol,SYMBOL_POINT);}
   static int        getDigits(string symbol) {return (int)SymbolInfoInteger(symbol,SYMBOL_DIGITS);}
   static int        getSpread(string symbol) {return (int)SymbolInfoInteger(symbol,SYMBOL_SPREAD);}
   static bool       isSpreadFloat(string symbol) {return SymbolInfoInteger(symbol,SYMBOL_SPREAD_FLOAT)!=0;};
   static int        getStopLevel(string symbol) {return(int)SymbolInfoInteger(symbol,SYMBOL_TRADE_STOPS_LEVEL);}
   static int        getFreezeLevel(string symbol) {return(int)SymbolInfoInteger(symbol,SYMBOL_TRADE_FREEZE_LEVEL);}

   //-- lot info
   static double     getMinLot(string symbol) {return SymbolInfoDouble(symbol,SYMBOL_VOLUME_MIN);}
   static double     getLotStep(string symbol) {return SymbolInfoDouble(symbol,SYMBOL_VOLUME_STEP);}
   static double     getMaxLot(string symbol) {return SymbolInfoDouble(symbol,SYMBOL_VOLUME_MAX);}

   //-- utility methods
   static double     normalizeLots(string symbol,double lots) {return Math::roundUpToMultiple(lots,getMinLot(symbol));}
   static double     normalizePrice(string symbol,double price) {return NormalizeDouble(price,getDigits(symbol));}

   static double     addPoints(string symbol,double price,int points) {return NormalizeDouble(price+points*getPoint(symbol),getDigits(symbol));}
   static double     subPoints(string symbol,double price,int points) {return NormalizeDouble(price-points*getPoint(symbol),getDigits(symbol));}

   //--- op%2==0 means a buy operation: OP_BUY OP_BUYLIMIT OP_BUYSTOP
   // OP_BUY       0 Buy operation
   // OP_SELL      1 Sell operation
   // OP_BUYLIMIT  2 Buy limit pending order
   // OP_SELLLIMIT 3 Sell limit pending order
   // OP_BUYSTOP   4 Buy stop pending order
   // OP_SELLSTOP  5 Sell stop pending order
   static double     priceForOpen(string symbol,int op) {return bdir(op)?getAsk(symbol):getBid(symbol);}
   static double     priceForClose(string symbol,int op) {return bdir(op)?getBid(symbol):getAsk(symbol);}
   static int        dir(int op) {return((op&1)==0)?1:-1;}
   static bool       bdir(int op) {return(op&1)==0;}

   //-- Constructor
                     FxSymbol(string symbol=""):m_symbol(symbol==""?_Symbol:symbol){}

   //-- basic properties
   string            getName() const {return m_symbol;}

   //--- SymbolWatch
   bool              select() {return select(m_symbol);}
   bool              remove() {return remove(m_symbol);}

   bool              isSelected() {return isSelected(m_symbol);}
   bool              isVisible() {return isVisible(m_symbol);}

   //-- symbol info
   string            getDescription() const {return getDescription(m_symbol);}
   string            getPath() const {return getPath(m_symbol);}
   string            getBaseCurrency() const {return getBaseCurrency(m_symbol);}
   string            getProfitCurrency() const {return getProfitCurrency(m_symbol);}
   string            getMarginCurrency() const {return getMarginCurrency(m_symbol);}

   //-- trade mode
   ENUM_SYMBOL_TRADE_MODE getTradeMode() const {return getTradeMode(m_symbol);}
   bool              isTradeDisabled() const {return isTradeDisabled(m_symbol);}
   bool              isTradeFully() const {return isTradeFully(m_symbol);}
   bool              isTradeShortOnly() const {return isTradeShortOnly(m_symbol);}
   bool              isTradeLongOnly() const {return isTradeLongOnly(m_symbol);}
   bool              isTradeCloseOnly() const {return isTradeCloseOnly(m_symbol);}

   double            getInitialMargin() const {return getInitialMargin(m_symbol);}
   double            getMaintenanceMargin() const {return getMaintenanceMargin(m_symbol);}
   double            getHedgedMargin() {return getHedgedMargin(m_symbol);}
   double            getRequiredMargin() {return getRequiredMargin(m_symbol);}
   int               getProfitCalcMode() {return getProfitCalcMode(m_symbol);}
   int               getMarginCalcMode() {return getMarginCalcMode(m_symbol);}
   bool              isCloseByAllowed() {return isCloseByAllowed(m_symbol);}

   double            getLongSwap() const {return getLongSwap(m_symbol);}
   double            getShortSwap() const {return getShortSwap(m_symbol);}

   //-- latest market info
   double            getBid() const {return getBid(m_symbol);}
   double            getAsk() const {return getAsk(m_symbol);}
   double            getMid() const {return getMid(m_symbol);}
   bool              getTick(MqlTick &tick) const {return getTick(m_symbol,tick);}

   double            getTickSize() const {return getTickSize(m_symbol);}
   double            getTickValue() const {return getTickValue(m_symbol);}

   double            getContractSize() const {return getContractSize(m_symbol);}

   //-- basic trade info
   double            getPoint() const {return getPoint(m_symbol);}
   int               getDigits() const {return getDigits(m_symbol);}
   int               getSpread() const {return getSpread(m_symbol);}
   bool              isSpreadFloat() const {return isSpreadFloat(m_symbol);};
   int               getStopLevel() const {return getStopLevel(m_symbol);}
   int               getFreezeLevel() const {return getFreezeLevel(m_symbol);}

   //-- lot info
   double            getMinLot() const {return getMinLot(m_symbol);}
   double            getLotStep() const {return getLotStep(m_symbol);}
   double            getMaxLot() const {return getMaxLot(m_symbol);}

   //-- utility methods
   double            normalizeLots(double lots) const {return normalizeLots(m_symbol,lots);}
   double            normalizePrice(double price) const {return normalizePrice(m_symbol,price);}

   double            addPoints(double price,int points) const {return addPoints(m_symbol,price,points);}
   double            subPoints(double price,int points) const {return subPoints(m_symbol,price,points);}

   double            priceForOpen(int op) const {return priceForOpen(m_symbol,op);}
   double            priceForClose(int op) const {return priceForClose(m_symbol,op);}
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CurrencyIndexEntry
  {
public:
   int               base[];
   int               profit[];

                     CurrencyIndexEntry()
     {
      ArrayResize(base,0,4);
      ArrayResize(profit,0,4);
     }

   void              addBase(int i) {ArrayInsert(base,ArraySize(base),i,4);}
   void              addProfit(int i) {ArrayInsert(profit,ArraySize(profit),i,4);}
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum SymbolType
  {
   Forex,
   CFD,
   Future,
   CFD_Index
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct SymbolDescriptor
  {
   string            symbol;
   string            base;       // base currency
   string            profit;     // profit currency
   string            margin;     // margin currency
   SymbolType        type;
   int               leverage;
   bool              isCross;       // cross pair or main pair
   string            marginConvert; // conversion symbol to convert margin to account currency
   string            profitConvert; // conversion symbol to convert profit to account currency
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class SymbolAnalyzer
  {
private:
   string            m_accountCurrency;
   Vector<string>m_symbols;
   Vector<string>m_specials;
   HashMap<string,CurrencyIndexEntry*>m_index;
   HashMap<string,string>m_convert;
protected:
   void              buildCurrencyIndex(void);
public:
                     SymbolAnalyzer():m_index(NULL,true) {buildCurrencyIndex();}

   const Vector<string>*getSymbols() const { return GetPointer(m_symbols); }
   const Vector<string>*getSpecials() const { return GetPointer(m_specials); }
   string            getAccountCurrency() const {return m_accountCurrency;}
   string            getConversionSymbol(string cur1,string cur2) const;
   int               getLeverage(string symbol) const;

   double            getRequiredMargin(string symbol,int op,double price=0.0,double lots=1.0) const;
   double            getMaxLots(double free,double used,string symbol,int op,int predictedLossInPoints=0) const;
   double            getProfit(string symbol,int op,double openPrice,double closePrice=0.0) const;
   double            convertToAccount(string currency,double money,int op,string conversionSymbol="") const;
   double            convertToAccountWithMid(string currency,double money,string conversionSymbol="") const;
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SymbolAnalyzer::buildCurrencyIndex(void)
  {
   int total=FxSymbol::getTotal();
   string account=Account::getCurrency();
   m_accountCurrency=account;
   for(int i=0; i<total; i++)
     {
      string symbol=FxSymbol::getName(i);
      m_symbols.add(symbol);
      string base=FxSymbol::getBaseCurrency(symbol);
      string counter=FxSymbol::getProfitCurrency(symbol);
      if(base==counter)
        {
         m_specials.add(symbol);
         continue;
        }
      CurrencyIndexEntry *entry=NULL;
      if(!m_index.contains(base))
        {
         entry=new CurrencyIndexEntry();
         m_index.set(base,entry);
        }
      else
        {
         entry=m_index[base];
        }
      entry.addBase(i);

      if(!m_index.contains(counter))
        {
         entry=new CurrencyIndexEntry();
         m_index.set(counter,entry);
        }
      else
        {
         entry=m_index[counter];
        }
      entry.addProfit(i);
     }
  }
//+------------------------------------------------------------------+
//| Get symbol for given currency pair                               |
//+------------------------------------------------------------------+
string SymbolAnalyzer::getConversionSymbol(string cur1,string cur2) const
  {
   int res;
   CurrencyIndexEntry *e1 = m_index[cur1];
   CurrencyIndexEntry *e2 = m_index[cur2];

   if(ArrayFindMatch(e1.base,e2.profit,res))
     {
      return m_symbols.get(res);
     }
   else if(ArrayFindMatch(e1.profit,e2.base,res))
     {
      return m_symbols.get(res);
     }
   else
     {
      return "";
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double SymbolAnalyzer::convertToAccount(string currency,double money,int op,string conversionSymbol) const
  {
   string account=Account::getCurrency();
   if(account == currency) return money;
   string cs=(conversionSymbol!="")?conversionSymbol:getConversionSymbol(currency,getAccountCurrency());
   if(cs=="") return -0.1;
   if(FxSymbol::getBaseCurrency(cs)==account)
     {
      return money/FxSymbol::priceForOpen(cs,op);
     }
   else
     {
      return money*FxSymbol::priceForOpen(cs,op);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double SymbolAnalyzer::convertToAccountWithMid(string currency,double money,string conversionSymbol) const
  {
   string account=Account::getCurrency();
   if(account == currency) return money;
   string cs=(conversionSymbol!="")?conversionSymbol:getConversionSymbol(currency,getAccountCurrency());
   if(cs=="") return -0.1;
   if(FxSymbol::getBaseCurrency(cs)==account)
     {
      return money/FxSymbol::getMid(cs);
     }
   else
     {
      return money*FxSymbol::getMid(cs);
     }
  }
//+------------------------------------------------------------------+
//| Calculate the real leverage used by a symbol                     |
//+------------------------------------------------------------------+
int SymbolAnalyzer::getLeverage(string symbol) const
  {
   double leverage=0.0;
   FxSymbol fs(symbol);
   int mode=fs.getMarginCalcMode();
   string base=fs.getBaseCurrency();
   string profit=fs.getProfitCurrency();

   double contractSize=FxSymbol::getContractSize(symbol);
   double requiredMargin=FxSymbol::getRequiredMargin(symbol);
   if(mode==0)
     {
      // forex
      leverage=contractSize/requiredMargin;
      if(base!=getAccountCurrency())
        {
         if(profit==getAccountCurrency())
           {
            leverage=convertToAccount(base,leverage,OP_BUY,symbol);
           }
         else
           {
            leverage=convertToAccountWithMid(base,leverage);
           }
        }
     }
   else if(mode==1)
     {
      // cfd
      leverage=contractSize*FxSymbol::getAsk(symbol)/requiredMargin;
      string marginCurrency=FxSymbol::getMarginCurrency(symbol);
      if(marginCurrency!=getAccountCurrency())
        {
         leverage=convertToAccount(marginCurrency,leverage,OP_BUY);
        }
     }
   else if(mode==3)
     {
      // cfd indices
      leverage=contractSize*FxSymbol::getAsk(symbol)*FxSymbol::getTickValue(symbol)/(FxSymbol::getTickSize(symbol)*requiredMargin);
      string marginCurrency=FxSymbol::getMarginCurrency(symbol);
      if(marginCurrency!=getAccountCurrency())
        {
         leverage=convertToAccount(marginCurrency,leverage,OP_BUY);
        }
     }
   else
     {
      // futures - 2
      // no leverage type for futures
      leverage=1;
     }
   return (int)MathRound(leverage);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double SymbolAnalyzer::getRequiredMargin(string symbol,int op,double price,double lots) const
  {
   double margin=0.0;
   if(Mql::isEqual(price,0.0))
     {
      price=FxSymbol::priceForOpen(symbol,op);
     }
   FxSymbol fs(symbol);
   int mode=fs.getMarginCalcMode();
   string base=fs.getBaseCurrency();
   string profit=fs.getProfitCurrency();

   double contractSize=FxSymbol::getContractSize(symbol);
   double leverage=getLeverage(symbol);
   if(mode==0)
     {
      // forex
      margin=lots*contractSize/leverage;
      if(base!=getAccountCurrency())
        {
         if(profit==getAccountCurrency())
           {
            margin=convertToAccount(base,margin,op,symbol);
           }
         else
           {
            margin=convertToAccountWithMid(base,margin);
           }
        }
     }
   else if(mode==1)
     {
      // cfd
      margin=lots*contractSize*price/leverage;
      string marginCurrency=FxSymbol::getMarginCurrency(symbol);
      if(marginCurrency!=getAccountCurrency())
        {
         margin=convertToAccount(marginCurrency,margin,op);
        }
     }
   else if(mode==3)
     {
      // cfd indices
      margin=contractSize*price*FxSymbol::getTickValue(symbol)/(FxSymbol::getTickSize(symbol)*leverage);
      string marginCurrency=FxSymbol::getMarginCurrency(symbol);
      if(marginCurrency!=getAccountCurrency())
        {
         margin=convertToAccount(marginCurrency,margin,op);
        }
     }
   else
     {
      // futures - 2
      // no leverage type for futures
      margin = FxSymbol::getInitialMargin(symbol)*lots;
      margin+= FxSymbol::getMaintenanceMargin(symbol)*lots;
     }
   return NormalizeDouble(margin,2);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double SymbolAnalyzer::getProfit(string symbol,int op,double openPrice,double closePrice) const
  {
   double target=Mql::isEqual(closePrice,0.0)?FxSymbol::priceForClose(symbol,op):closePrice;
   int dir=(op%2==0)?1:-1;
   double profit=dir*(target-openPrice)*FxSymbol::getContractSize(symbol);
   string profitCurrency=FxSymbol::getProfitCurrency(symbol);
   string baseCurrency=FxSymbol::getBaseCurrency(symbol);
   if(profitCurrency==getAccountCurrency())
     {
      return profit;
     }
   else if(baseCurrency==getAccountCurrency())
     {
      double avgPrice=Mql::isEqual(closePrice,0.0)?FxSymbol::getMid(symbol):target;
      return profit/avgPrice;
     }
   else
     {
      string cs=getConversionSymbol(getAccountCurrency(),profitCurrency);
      if(cs=="") {return -1.0;}
      else if(FxSymbol::getBaseCurrency(cs)==getAccountCurrency())
        {
         return profit/FxSymbol::getMid(cs);
        }
      else
        {
         return profit*FxSymbol::getMid(cs);
        }
     }
  }
//+------------------------------------------------------------------+
//| (free_margin - x*per_lot_spreadloss - x*per_lot_margin)          |
//| ------------------------------------------------------- = level  |
//|           (margin_used + x*per_lot_margin)                       |
//|                                                                  |
//|                 (free_margin-margin_used*level)                  |
//| x = -------------------------------------------------------      |
//|       (pre_lot_spread+per_lot_margin*level+per_lot_margin)       |
//+------------------------------------------------------------------+
double SymbolAnalyzer::getMaxLots(double free,double used,string symbol,int op,int predictedLossInPoints) const
  {
   double required=getRequiredMargin(symbol,op);
   Print("Required Margin: ",required);
   double level=Account::getMarginCallLevel()/100.0;
   double priceOpen=FxSymbol::priceForOpen(symbol,op);
   double closePrice=FxSymbol::priceForClose(symbol,op);
   double lossPrice = FxSymbol::getPoint(symbol)*predictedLossInPoints;
   if(op%2==0)
     {
      closePrice-=lossPrice;
     }
   else
     {
      closePrice+=lossPrice;
     }
   double profit=getProfit(symbol,op,priceOpen,closePrice);
   Print("Loss: ",profit);
   double lots=(free-used*level)/(required+required*level-profit);
   for(double l=1.0; l<11.0; l+=1.0)
     {
      PrintFormat(">>> Level %.2f%%: max %.2f lots.",l*100.0,(free-used*l)/(required+required*l-profit));
     }
   return FxSymbol::normalizeLots(symbol,lots);
  }
//+------------------------------------------------------------------+
