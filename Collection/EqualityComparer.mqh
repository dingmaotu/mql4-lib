//+------------------------------------------------------------------+
//|                                             EqualityComparer.mqh |
//|                                          Copyright 2017, Li Ding |
//|                                            dingmaotu@hotmail.com |
//+------------------------------------------------------------------+

#include "../Lang/Hash.mqh"
#property strict
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
template<typename T>
interface EqualityComparer
  {
   bool      equals(T left,T right) const;
   int       hash(T value) const;
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
template<typename T>
class GenericEqualityComparer: public EqualityComparer<T>
  {
public:
   virtual bool       equals(T left,T right) const override {return left==right;}
   virtual int        hash(T value) const override {return Hash(value);}
  };
//+------------------------------------------------------------------+
