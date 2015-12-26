//+------------------------------------------------------------------+
//|                                                       Candle.mqh |
//|                                          Copyright 2014, Li Ding |
//|                                             http://dingmaotu.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, Li Ding"
#property link      "http://dingmaotu.com"
#property strict
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Candle
  {
private:
   double            entity;
   double            candleLen;
   double            entityLen;
   double            lowerLen;
   double            upperLen;
public:
                     Candle() {setShift(0);}

   void setShift(int shift)
     {
      candleLen=High[shift]-Low[shift];
      entity=Close[shift]-Open[shift];
      entityLen=MathAbs(entity);

      if(entity<0)
        {
         lowerLen = Close[shift] - Low[shift];
         upperLen = High[shift] - Open[shift];
           } else {
         lowerLen = Open[shift] - Low[shift];
         upperLen = High[shift] - Close[shift];
        }
     }

   bool isYin() {return entity<0;}
   bool isYang() {return entity>0;}
   double getEntity() {return entityLen;}
   double getCandle() {return candleLen;}
   double getLower() {return lowerLen;}
   double getUpper() {return upperLen;}
  };
//+------------------------------------------------------------------+
