//+------------------------------------------------------------------+
//|                                                    Lang/Cast.mqh |
//|                  Copyright 2017, Bear Two Technologies Co., Ltd. |
//+------------------------------------------------------------------+
#property strict
//+------------------------------------------------------------------+
//| In the official MQL4 language reference                          |
//| (Language Basics -> Data Types -> Integer Types -> Typecasting): |
//|                                                                  |
//| Typecasting of Simple Structure Types                            |
//| -------------------------------------                            |
//| Data of the simple structures type can be assigned to each other |
//| only if all the members of both structures are of numeric types. |
//| In this case both operands of the assignment operation (left and |
//| right) must be of the structures type. The member-wise casting is|
//| not performed, a simple copying is done. If the structures are of|
//| different sizes, the number of bytes of the smaller size is      |
//| copied.Thus the absence of union in MQL4 is compensated.         |
//|                                                                  |
//| But this is not true in new versions (Maybe build 1080 or later) |
//| of MQL4: union is indeed supported, and struct casting may become|
//| an unsupported feature.                                          |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Cast any value type to another value type                        |
//+------------------------------------------------------------------+
template<typename From,typename To>
void reinterpret_cast(const From &f,To &t)
  {
   union _u
     {
      From              from;
      const To          to;
     }
   u;
   u.from=f;
   t=u.to;
  }
//+------------------------------------------------------------------+
//| Convert any value type to byte array                             |
//+------------------------------------------------------------------+
template<typename T>
void byte_cast(const T &value,uchar &a[],int start=0)
  {
   union _u
     {
      T                 from;
      const uchar       to[sizeof(T)];
     }
   u;
   u.from=value;
   ArrayCopy(a,u.to,start);
  }
//+------------------------------------------------------------------+
