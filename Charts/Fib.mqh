//+------------------------------------------------------------------+
//|                                                   Charts/Fib.mqh |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015-2016, Li Ding"
#property link      "dingmaotu@hotmail.com"
#property strict
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Fib
  {
private:
   double            p0,p100,p38_2,p50,p61_8;
public:
                     Fib(){}
                    ~Fib(){}
   void              calc(double begin,double end);

   double getL0() const {return p0;}
   double getL100() const {return p100;}
   double getL38_2() const {return p38_2;}
   double getL50() const {return p50;}
   double getL61_8() const {return p61_8;}
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Fib::calc(double begin,double end)
  {
   double r=end-begin;
   p0=begin;
   p100=end;

   p50=begin+0.5*r;
   p38_2 = begin + 0.382 * r;
   p61_8 = begin + 0.618 * r;
  }
//+------------------------------------------------------------------+
