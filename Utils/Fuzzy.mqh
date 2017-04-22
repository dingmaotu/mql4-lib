//+------------------------------------------------------------------+
//|                                                        Fuzzy.mqh |
//|                  Copyright 2017, Bear Two Technologies Co., Ltd. |
//+------------------------------------------------------------------+
#property strict
#include "../Lang/Mql.mqh"
#include "../Lang/Array.mqh"
#include "../Collection/Collection.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct Interval
  {
public:
   const double      L;
   const double      R;
                     Interval(double x1,double x2):L(x1),R(x2){}
                     Interval(const Interval &rhs):L(rhs.L),R(rhs.R){}
   bool              operator==(const Interval &rhs) const {return Mql::isEqual(L,rhs.L) && Mql::isEqual(R,rhs.R);}
   bool              operator!=(const Interval &rhs) const {return !this.operator==(rhs);}
   Interval          operator+(const Interval &rhs) const {Interval i(L+rhs.L,R+rhs.R);return i;}
   Interval          operator-(const Interval &rhs) const {Interval i(L-rhs.R,R-rhs.L);return i;}
   Interval          operator*(const Interval &rhs) const
     {
      double r1=L*rhs.L,r2=L*rhs.R,r3=R*rhs.L,r4=R*rhs.R;
      double min=r1,max=r1;
      if(r2>max) max = r2; if(r2<min) min=r2;
      if(r3>max) max = r3; if(r3<min) min=r3;
      if(r4>max) max = r4; if(r4<min) min=r4;
      Interval i(min,max);
      return i;
     }
   Interval          operator/(const Interval &rhs) const
     {
      double r1=L/rhs.L,r2=L/rhs.R,r3=R/rhs.L,r4=R/rhs.R;
      double min=r1,max=r1;
      if(r2>max) max = r2; if(r2<min) min=r2;
      if(r3>max) max = r3; if(r3<min) min=r3;
      if(r4>max) max = r4; if(r4<min) min=r4;
      Interval i(min,max);
      return i;
     }
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
template<typename T>
class FuzzySet
  {
public:
   virtual bool      belongs(T x) const=0;
   virtual double    membership(T x) const=0;
   virtual string    toString(string name="") const=0;

   // fuzzy hegde very and fairly
   double            very(T x) const {double a=membership(x); return a*a;}
   double            fairly(T x) const {return MathSqrt(membership(x));}

   // fuzzy negation
   double            complement(T x) const {return 1.0-membership(x);}
   // fuzzy disjunction
   double            union(const FuzzySet<T>&set,T x) const {return MathMax(membership(x),set.membership(x));}
   // fuzzy conjunction
   double            intersect(const FuzzySet<T>&set,T x) const {return MathMin(membership(x),set.membership(x));}
   // fuzzy implication
   double            include(const FuzzySet<T>&set,T x) consot {return MathMin(1.0,1.0+set.membership(x)-membership(x));}
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class FuzzySSR: public FuzzySet<double>
  {
private:
   double            x1,x2,x3,x4;
protected:
   void              set(double xa1,double xa2,double xa3,double xa4)
     {
      x1=xa1;x2=xa2;x3=xa3;x4=xa4;
     }
   void              setByCut(const Interval &it1,double a1,const Interval &it2,double a2)
     {
      double p1=it1.L,p4=it1.R,p2=it2.L,p3=it2.R;
      if(a1>=0 && a1<a2 && a2<=1)
        {
         double ar=a1/a2,ad=a2-a1;
         x1=(p1-ar*p2)/(1.0-ar);
         x4=(p4-ar*p3)/(1.0-ar);
         x2=x1+(p2-p1)/ad;
         x3=x4-(p4-p3)/ad;
        }
     }
public:
                     FuzzySSR(double xa1,double xa2,double xa3,double xa4)
   :x1(xa1),x2(xa2),x3(xa3),x4(xa4)
     {}
                     FuzzySSR(const Interval &it1,double a1,const Interval &it2,double a2)
     {
      setByCut(it1,a1,it2,a2);
     }
                     FuzzySSR(const FuzzySSR &fset)
   :x1(fset.x1),x2(fset.x2),x3(fset.x3),x4(fset.x4)
     {}

   string            toString(string name="") const
     {
      return StringFormat("#[%s]{SSR|%g,%g,%g,%g}",name,x1,x2,x3,x4);
     }

   double            x(int i) const {switch(i){case 1: return x1; case 2: return x2; case 3: return x3; case 4: return x4; default: return Double::NaN;}}

   bool              belongs(double x) const {return(x>=x1) && (x<=x4);}
   double            membership(double x) const;
   Interval          alphacut(double alpha) const;

   double            center() const {return(x2+x3)/2.0;}

   FuzzySSR          operator+(const FuzzySSR &rhs) const
     {
      Interval cut1a = alphacut(0.25), cut1b = rhs.alphacut(0.25);
      Interval cut2a = alphacut(0.75), cut2b = rhs.alphacut(0.75);
      FuzzySSR res(cut1a+cut1b, 0.25, cut2a+cut2b, 0.75);
      return res;
     }
   void              operator+=(const FuzzySSR &rhs)
     {
      Interval cut1a = alphacut(0.25), cut1b = rhs.alphacut(0.25);
      Interval cut2a = alphacut(0.75), cut2b = rhs.alphacut(0.75);
      setByCut(cut1a+cut1b,0.25,cut2a+cut2b,0.75);
     }
   FuzzySSR          operator-(const FuzzySSR &rhs) const
     {
      Interval cut1a = alphacut(0.25), cut1b = rhs.alphacut(0.25);
      Interval cut2a = alphacut(0.75), cut2b = rhs.alphacut(0.75);
      FuzzySSR res(cut1a-cut1b, 0.25, cut2a-cut2b, 0.75);
      return res;
     }
   void              operator-=(const FuzzySSR &rhs)
     {
      Interval cut1a = alphacut(0.25), cut1b = rhs.alphacut(0.25);
      Interval cut2a = alphacut(0.75), cut2b = rhs.alphacut(0.75);
      setByCut(cut1a-cut1b,0.25,cut2a-cut2b,0.75);
     }
   // fuzzy shift
   FuzzySSR          operator+(double k) const
     {
      FuzzySSR res(x1+k,x2+k,x3+k,x4+k);
      return res;
     }
   FuzzySSR          operator-(double k) const
     {
      return operator+(-k);
     }
   // fuzzy shift
   void              operator+=(double k)
     {
      set(x1+k,x2+k,x3+k,x4+k);
     }
   void              operator-=(double k)
     {
      operator+=(-k);
     }
   // fuzzy factor
   FuzzySSR          operator*(double k) const
     {
      double nx1=k*x1,nx2=k*x2,nx3=k*x3,nx4=k*x4;
      if(nx1<=nx4)
        {
         FuzzySSR res(nx1,nx2,nx3,nx4);
         return res;
        }
      else
        {
         FuzzySSR res(nx4,nx3,nx2,nx1);
         return res;
        }
     }
   FuzzySSR          operator/(double k) const
     {
      return operator*(1.0/k);
     }
   // fuzzy factor
   void              operator*=(double k)
     {
      double nx1=k*x1,nx2=k*x2,nx3=k*x3,nx4=k*x4;
      if(nx1<=nx4)
         set(nx1,nx2,nx3,nx4);
      else
         set(nx4,nx3,nx2,nx1);
     }
   void              operator/=(double k)
     {
      operator*=(1.0/k);
     }
   // fuzzy scale
   FuzzySSR          operator^(double k) const
     {
      FuzzySSR factored=this.operator*(k);
      return factored+(this.center()-factored.center());
     }
   void              operator^=(double k)
     {
      double center = center();
      this.operator*=(k);
      double centerAfter=center();
      this.operator+=(center-centerAfter);
     }
   bool              operator==(const FuzzySSR &rhs) const
     {
      return
      Mql::isEqual(x1,rhs.x1) &&
      Mql::isEqual(x2,rhs.x2) &&
      Mql::isEqual(x3,rhs.x3) &&
      Mql::isEqual(x4,rhs.x4);
     }
   bool              operator!=(const FuzzySSR &rhs) const
     {
      return !this.operator==(rhs);
     }
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double FuzzySSR::membership(double x) const
  {
   if(x<=x1 || x>=x4) return 0.0;
   else if(x>x1 && x<x2) return (x-x1)/(x2-x1);
   else if(x>=x2 && x<=x3) return 1.0;
   else return (x4-x)/(x4-x3);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Interval FuzzySSR::alphacut(double alpha) const
  {
   double left=x1+alpha*(x2-x1);
   double right=x4-alpha*(x4-x3);
   Interval i(left,right);
   return i;
  }
typedef double(*NumericFunction)(double x);
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void NumericDiscretize(double &x[],double &y[],int begin,NumericFunction func,double from,double to,int steps)
  {
   double incr=(to-from)/steps;
   for(int i=begin; i<steps; i++)
     {
      x[i]=from+i*incr;
      y[i]=func(x[i]);
     }
   x[begin+steps]=to;
   y[begin+steps]=func(to);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double LinearInterpolate(double x1,double x2,double y1,double y2,double x)
  {
   if(Mql::isEqual(x1,x2)) return Double::NaN;
   return y1 + (y1-y2)*(x-x1)/(x1-x2);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class FuzzyDSR: public FuzzySet<double>
  {
private:
   double            m_x[];
   double            m_y[];
protected:
   int               size() const {return ArraySize(m_x);}
   double            x(int i) const {return m_x[i];}
   double            y(int i) const {return m_y[i];}

   void              discretize(const FuzzySSR &ssr,int steps);
   void              discretize(NumericFunction func,double from,double to,int steps);
public:
                     FuzzyDSR(NumericFunction func,double from,double to,int steps) {discretize(func,from,to,steps);}
                     FuzzyDSR(const FuzzySSR &fset,int steps) {discretize(fset,steps);}
                     FuzzyDSR(const double &x[],const double &y[])
     {
      int size=ArraySize(x);
      if(size>0 && size==ArraySize(y))
        {
         ArrayResize(m_x,size);
         ArrayResize(m_y,size);
         for(int i=0; i<size; i++)
           {
            m_x[i]=x[i];
            m_y[i]=y[i];
           }
        }
     }

   bool              belongs(double x) const {return x>=m_x[0] && x<=m_x[ArraySize(m_x)-1];}
   double            membership(double x) const;

   string            toString(string name="") const
     {
      string res="#["+name+"]{DSR|";
      int size=ArraySize(m_x);
      for(int i=0; i<size; i++)
        {
         res+=StringFormat("(%g,%g),",m_x[i],m_y[i]);
        }
      StringSetCharacter(res,StringLen(res)-1,'}');
      return res;
     }
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void FuzzyDSR::discretize(NumericFunction func,double from,double to,int steps)
  {
   ArrayResize(m_x,steps+1);
   ArrayResize(m_y,steps+1);
   NumericDiscretize(m_x,m_y,0,func,from,to,steps);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void FuzzyDSR::discretize(const FuzzySSR &ssr,int steps)
  {
   ArrayResize(m_x,3*steps+1);
   ArrayResize(m_y,3*steps+1);

   for(int i=1; i<4;i++)
     {
      int begin=(i-1)*steps;
      double incr=(ssr.x(i+1)-ssr.x(i))/steps;
      for(int j=begin; j<begin+steps; j++)
        {
         m_x[j]=ssr.x(i)+j*incr;
         m_y[j]=ssr.membership(m_x[j]);
        }
     }
   m_x[3*steps]=ssr.x(4);
   m_y[3*steps]=ssr.membership(ssr.x(4));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double FuzzyDSR::membership(double x) const
  {
   int i=BinarySearch(m_x,x);
   if(i==ArraySize(m_x) || (i==0 && (!Mql::isEqual(m_x[i],x))))
     {
      return 0.0;
     }
   else if(Mql::isEqual(m_x[i],x))
     {
      return m_y[i];
     }
   else
     {
      return LinearInterpolate(m_x[i-1], m_x[i], m_y[i-1],m_y[i],x);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
FuzzySSR *FuzzySum(const Collection<FuzzySSR*>&sets)
  {
   FuzzySSR *sum=NULL;
   foreach(FuzzySSR*,sets)
     {
      FuzzySSR *s=it.current();
      if(sum==NULL)
         sum=new FuzzySSR(s);
      else
         sum+=s;
     }
   return sum;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
FuzzySSR *FuzzyAverage(const Collection<FuzzySSR*>&sets)
  {
   FuzzySSR *res=FuzzySum(sets);
   if(res!=NULL)
     {
      res/=sets.size();
     }
   return res;
  }

#define __FUZZY_OP__(op) \
   FuzzyDSR *res=NULL;\
   if(steps>0)\
     {\
      double x[];\
      double y[];\
      int size=2*steps+2;\
      ArrayResize(x,size);\
      ArrayResize(y,size);\
      double incr=1.0/steps;\
      for(int i=0; i<steps; i++)\
        {\
         double a=i*incr;\
         Interval intv=set1.alphacut(a) op set2.alphacut(a);\
         x[i]=intv.L;\
         x[size-i-1]=intv.R;\
         y[i]=a;\
         y[size-i-1]=a;\
        }\
      Interval intv=set1.alphacut(1.0) op set2.alphacut(1.0);\
      x[steps]=intv.L;\
      y[steps+1]=intv.R;\
      bool compact=false;\
      for(int i=1; i<size; i++)\
        {\
         if(Mql::isEqual(x[i-1],x[i]))\
           {\
            x[i]=NULL;\
            y[i]=NULL;\
            compact=true;\
           }\
        }\
      if(compact)\
        {\
         ArrayCompact(x);\
         ArrayCompact(y);\
        }\
      res=new FuzzyDSR(x,y);\
     }\
return res;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
FuzzyDSR *FuzzyMult(const FuzzySSR &set1,const FuzzySSR &set2,int steps)
  {
   FuzzyDSR *res=NULL;
   if(steps>0)
     {
      double x[];
      double y[];
      int size=2*steps+2;
      ArrayResize(x,size);
      ArrayResize(y,size);
      double incr=1.0/steps;
      for(int i=0; i<steps; i++)
        {
         double a=i*incr;
         Interval intv=set1.alphacut(a)*set2.alphacut(a);
         x[i]=intv.L;
         x[size-i-1]=intv.R;
         y[i]=a;
         y[size-i-1]=a;
        }
      Interval intv=set1.alphacut(1.0)*set2.alphacut(1.0);
      x[steps]=intv.L;
      y[steps+1]=intv.R;
      bool compact=false;
      for(int i=1; i<size; i++)
        {
         if(Mql::isEqual(x[i-1],x[i]))
           {
            x[i]=Double::NaN;
            y[i]=Double::NaN;
            compact=true;
           }
        }
      if(compact)
        {
         ArrayCompact(x);
         ArrayCompact(y);
        }
      res=new FuzzyDSR(x,y);
     }
   return res;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
FuzzyDSR *FuzzyDiv(const FuzzySSR &set1,const FuzzySSR &set2,int steps)
  {
   __FUZZY_OP__(/)
  }
//+------------------------------------------------------------------+
