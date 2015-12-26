//+------------------------------------------------------------------+
//|                                                      Matcher.mqh |
//|                                          Copyright 2014, Li Ding |
//|                                             http://dingmaotu.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, Li Ding"
#property link      "http://dingmaotu.com"
#property strict

#include <LiDing/Candle.mqh>

class Matcher
{
public:
   virtual bool match(int shift);
};

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
public:
   virtual bool      match(int shift);

   void setMinLen(double v) {minLen = v;}
   void setMaxLen(double v) {maxLen = v;}
   void setEntityPercent(double p) {entityPercent=p;}
   void setUpperPercent(double p) {upperPercent=p;}
   void setLowerPercent(double p) {lowerPercent=p;}
  };