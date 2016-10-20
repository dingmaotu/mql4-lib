//+------------------------------------------------------------------+
//|                                                      Matcher.mqh |
//|                                          Copyright 2014, Li Ding |
//|                                             http://dingmaotu.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, Li Ding"
#property link      "http://dingmaotu.com"
#property strict

#include <LiDing/Candle.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Matcher
  {
public:
   virtual bool      match(int shift);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CandleMatcher: public Matcher
  {
protected:
   Candle           *candle;
public:
                     CandleMatcher()
     {
      candle=new Candle();
     }
                    ~CandleMatcher()
     {
      if(CheckPointer(candle)==POINTER_DYNAMIC)
        {
         delete candle;
        }
     }
   virtual bool      match(int shift);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CandleShapeMatcher: public CandleMatcher
  {
protected:
   double            minLen;
   double            maxLen;
   double            entityPercent;
   double            lowerPercent;
   double            upperPercent;
   bool              yinYangEnabled;
public:
   virtual bool      match(int shift);

   void setMinLen(double v) {minLen = v;}
   void setMaxLen(double v) {maxLen = v;}
   void setEntityPercent(double p) {entityPercent=p;}
   void setUpperPercent(double p) {upperPercent=p;}
   void setLowerPercent(double p) {lowerPercent=p;}
   void setYinYangEnabled(bool p) {yinYangEnabled=p;}
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class LargeUpperShadowMatcher: public CandleShapeMatcher
  {
public:
                     LargeUpperShadowMatcher(double min,double max,double entityPer,double longPer,bool yinYang=false)
     {
      setMinLen(min);
      setMaxLen(max);
      setEntityPercent(entityPer);
      setUpperPercent(longPer);
      setLowerPercent(1.0-entityPer-longPer);
      setYinYangEnabled(yinYang);
     }

   bool match(int shift)
     {
      candle.setShift(shift);

      return (yinYangEnabled ? candle.isYin() : true)
      && (candle.getEntity() < entityPercent*candle.getCandle())
      && (candle.getLower()<lowerPercent*candle.getCandle())
      && (candle.getUpper()>upperPercent*candle.getCandle());
     }
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class LargeLowerShadowMatcher: public CandleShapeMatcher
  {
public:
                     LargeLowerShadowMatcher(double min,double max,double entityPer,double longPer,bool yinYang=false)
     {
      setMinLen(min);
      setMaxLen(max);
      setEntityPercent(entityPer);
      setUpperPercent(1.0-entityPer-longPer);
      setLowerPercent(longPer);
      setYinYangEnabled(yinYang);
     }

   bool match(int shift)
     {
      candle.setShift(shift);

      return (yinYangEnabled ? candle.isYang() : true)
      && (candle.getEntity() < entityPercent*candle.getCandle())
      && (candle.getLower()>lowerPercent*candle.getCandle())
      && (candle.getUpper()<upperPercent*candle.getCandle());
     }
  };
//+------------------------------------------------------------------+
