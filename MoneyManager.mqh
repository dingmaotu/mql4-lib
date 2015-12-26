//+------------------------------------------------------------------+
//|                                                 MoneyManager.mqh |
//|                                          Copyright 2014, Li Ding |
//|                                             http://dingmaotu.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, Li Ding"
#property link      "http://dingmaotu.com"
#property strict

class MoneyManager
{
private:
   double m_minimum_limit;
public:
   MoneyManager(double percent);
   bool HasEnoughMoney() {return AccountEquity() > m_minimum_limit;}
};

MoneyManager::MoneyManager(double percent)
{
   m_minimum_limit = NormalizeDouble(AccountEquity()*percent, 2);
}