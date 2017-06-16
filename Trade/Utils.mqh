//+------------------------------------------------------------------+
//|                                                  Trade/Utils.mqh |
//|                                          Copyright 2017, Li Ding |
//|                                            dingmaotu@hotmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Li Ding"
#property link      "dingmaotu@hotmail.com"
#property strict

#include "../Lang/Mql.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double NormalizeLots(double lots,double minLot)
  {
   double r=MathMod(lots,minLot);
   return Mql::isEqual(r,0.0) ? lots : (lots -r + minLot);
  }
//+------------------------------------------------------------------+
