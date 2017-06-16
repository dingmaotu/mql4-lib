//+------------------------------------------------------------------+
//|                                 History/RenkoIndicatorDriver.mqh |
//|                  Copyright 2017, Bear Two Technologies Co., Ltd. |
//+------------------------------------------------------------------+
#property strict

#include "Renko.mqh"
#include "IndicatorDriver.mqh"
//+------------------------------------------------------------------+
//| drives indicators for renko charts                               |
//+------------------------------------------------------------------+
class RenkoIndicatorDriver: public Renko
  {
private:
   IndicatorDriver *m_driver;

public:
                     RenkoIndicatorDriver(int barSize,IndicatorDriver &driver)
   :Renko(barSize*_Point),m_driver(GetPointer(driver)){}
   void              onNewBar(int total,int pBars,double const &pOpen[],double const &pHigh[],
                              double const &pLow[],double const &pClose[],long const &pVolume[])
     {
      datetime time[];
      long volume[];
      int spread[];
      m_driver.calculate(total,time,pOpen,pHigh,pLow,pClose,pVolume,volume,spread);
     }
  };
//+------------------------------------------------------------------+
