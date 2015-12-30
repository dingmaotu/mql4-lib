# mql4-lib
MQL4 Foundation Library For Professional Developers

## Introduction
MQL4 programming language provided by MetaQuotes is a very limited version of C++,
and its standard library is a clone of the (ugly) MFC, both of which I am very uncomfortable of.
Most MQL4 programs have not adapted to the MQL5 (Object Oriented) style yet,
let alone reuable and elegant component based design and programming.

mql4-lib is a simple library that tries to make MQL4 programming pleasant with a more object oriented 
approach and a coding style like Java, and encourages writing reusable components. This library has the
 ambition to become the de facto Foundation Library for MQL4.

## Installation
Just copy the library to your MQL4 Data Folder's `Include` directory, with the root directory name of `LiDing`,
like <MQL4Data>\Include\LiDing\<mql4-lib content>.

## Usage
This library is in its early stage. Currently, only the `Lang` and `Collection` component is usable.
 I am still working on other components. In `Lang`, I abstract three Program types
 to three base classes that you can inherit.

The general usage is as below:

```
input string InpEaName = "My EA";
input double InpBaseLot = 0.1;

#include <LiDing/Lang/ExpertAdvisor.mqh>

class MyEa: public ExpertAdvisor
{
private:
  string m_name;
  double m_baseLot;
public:
  void setName(string name) {m_name = name;}
  void setBaseLot(double lot) {m_baseLot = lot;}

  void main() {Print(m_name);}
};

DECLARE_EA(MyEa,
           PARAM(Name, InpEaName)
           PARAM(BaseLot, InpBaseLot))
```

You noticed that in the DECLARE_EA macro, the second part is not separated by comma,
as MQL4 preprocessor does not support variable arguments for macros.

The `PARAM` macro injects parameters to the EA by its setters. Just follow the Java Beans(TM) convention.

For Indicators and Scripts you can just check the source code.
I used some tricky macro hacks to work around limits of MQL4.

With this approach, you can write reusable EAs, Scripts, or Indicators.
You do not need to worry about the OnInit, OnDeinit, OnStart, OnTick, etc.
You never use a input parameter directly in your EA. You can write a
base EA, and extend on that easily.