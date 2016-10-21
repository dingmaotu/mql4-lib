//+------------------------------------------------------------------+
//|                                                 Charts/Pivot.mqh |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015-2016, Li Ding"
#property link      "dingmaotu@hotmail.com"
#property strict
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Pivot
  {
private:
   double            pivot,r1,r2,r3,s1,s2,s3;
public:
                     Pivot(){}
                    ~Pivot(){}
   void              calc(double high,double low,double close);

   double getR3() const {return r3;}
   double getR2() const {return r2;}
   double getR1() const {return r1;}
   double getPivot() const {return pivot;}
   double getS1() const {return s1;}
   double getS2() const {return s2;}
   double getS3() const {return s3;}
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Pivot::calc(double high,double low,double close)
  {
   pivot=((high+low+close)/3);

   r1 = (2*pivot)-low;
   s1 = (2*pivot)-high;

   r2 = pivot+(r1-s1);
   s2 = pivot-(r1-s1);

   r3 = high + (2*(pivot-low));
   s3 = low - (2*(high-pivot));
  }
//+------------------------------------------------------------------+
