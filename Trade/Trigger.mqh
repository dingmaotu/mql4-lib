//+------------------------------------------------------------------+
//|                                                Trade/Trigger.mqh |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Li Ding"
#property link      "dingmaotu@hotmail.com"
#property strict
//+------------------------------------------------------------------+
//| Trigger interface                                                |
//| A trigger is activated at a certain time point in the continuous |
//| time series data, and it indicates the intended position type    |
//+------------------------------------------------------------------+
interface Trigger
  {
   bool isActivated() const;
   bool isLong() const;
   bool isShort() const;
  };
//+------------------------------------------------------------------+
//| Implements the default methods                                   |
//+------------------------------------------------------------------+
class TriggerAdapter: public Trigger
  {
public:
   virtual bool isActivated() const {return isLong() || isShort(); }
   virtual bool isLong() const {return false;}
   virtual bool isShort() const {return false;}
  };
//+------------------------------------------------------------------+
