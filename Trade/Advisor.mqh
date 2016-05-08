//+------------------------------------------------------------------+
//|                                                      Advisor.mqh |
//|                                          Copyright 2016, Li Ding |
//|                                                dingmaotu@126.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Li Ding"
#property link      "dingmaotu@126.com"
#property strict

#include <LiDing/Lang/Object.mqh>
//+------------------------------------------------------------------+
//| Advisor interface.                                               |
//| return a value of double indicating its market preference.       |
//+------------------------------------------------------------------+
class Advisor: public Object
  {
public:
   virtual void update() {}
   virtual double getValue() const {return 0.0;}
  };
//+------------------------------------------------------------------+
