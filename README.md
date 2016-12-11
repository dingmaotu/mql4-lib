# mql4-lib

MQL4 Foundation Library For Professional Developers

* [1. Introduction](#introduction)
* [2. Installation](#installation)
* [3. Usage](#usage)
  * [3.1 Basic Programs](#basic-programs)
  * [3.2 Collections](#collections)
  * [3.3 Asynchronous Events](#asynchronous-events)

## Introduction

MQL4 programming language provided by MetaQuotes is a very limited
version of C++, and its standard library is a clone of the (ugly) MFC,
both of which I am very uncomfortable with. Most MQL4 programs have not
adapted to the MQL5 (Object Oriented) style yet, let alone reuable and
elegant component based design and programming.

mql4-lib is a simple library that tries to make MQL4 programming
pleasant with a more object oriented approach and a coding style like
Java, and encourages writing reusable components. This library has the
ambition to become the de facto Foundation Library for MQL4.

## Installation

Just copy the library to your MQL4 Data Folder's `Include` directory,
with the root directory name of your choice, for example:
`<MQL4Data>\Include\MQL4\<mql4-lib content>`.

## Usage

The library is in its early stage. However, most components are pretty
stable and can be used in production. Here are the main components:

1. `Lang` directory contains modules that enhance the MQL4 language
2. `Collection` directory contains useful collection types
3. `Charts` directory contains several chart types and common chart tools
4. `Trade` directory contains useful abstractions for trading
5. `Utils` directory contains various utilities

### Basic Programs

In `Lang`, I abstract three Program types (Script, Indicator, and
 Expert Advisor) to three base classes that you can inherit.

The general usage is as below:

```
input string InpEaName = "My EA";
input double InpBaseLot = 0.1;

#include <MQL4/Lang/ExpertAdvisor.mqh>

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

You noticed that in the DECLARE_EA macro, the second part is not
separated by comma, as MQL4 preprocessor does not support variable
arguments for macros.

The `PARAM` macro injects parameters to the EA by its setters. Just
follow the Java Beans(TM) convention.

For Indicators and Scripts you can find their usage by reading the
source code. I used some macro tricks to work around limits of MQL4. I
will document the library in detail when I have the time.

With this approach, you can write reusable EAs, Scripts, or
Indicators.  You do not need to worry about the OnInit, OnDeinit,
OnStart, OnTick, etc.  You never use a input parameter directly in
your EA. You can write a base EA, and extend it easily.

### Collections

In advanced MQL4 programs, you have to use more sophisticated
collection types for your order management.

It is planned to add common collection types to the lib, including
lists, hash maps, trees, and others.

Currently there are two list types:

1. Collection/LinkedList is a Linked List implementation
2. Collection/Vector is an array based implementation

Since there is no `class template` in MQL4, I provide a macro for each
collection types. These macros can generate a collection class for any
type, be it elementary types or object pointers (types that can be
`new`ed).

The general usage is as follows:

```
LINKED_LIST(Order*, Order, true); // defines OrderList and OrderListIterator
LINKED_LIST(int, Int, false); // defines IntList and IntListIterator
VECTOR(Order*, Order, true); // defines OrderVector and OrderVectorIterator
VECTOR(int, Int, false); // defines IntVector and IntVectorIterator
```

The last parameter is a boolean value, true for object pointer types
(it means when the collection class is destructed, whether its
elements should be destructed, too), and false for elementary
(integer) types.

Here is a simple example:

```
//+------------------------------------------------------------------+
//|                                                TestOrderPool.mq4 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Li Ding"
#property link      "dingmaotu@hotmail.com"
#property version   "1.00"
#property strict

#include <MQL4/Trade/Order.mqh>
#include <MQL4/Trade/OrderPool.mqh>
#include <MQL4/Collection/LinkedList.mqh>

//+------------------------------------------------------------------+
//| define OrderList (as you can not use LinkedList directly)        |
//| the name of the generated list type will be TypeName##List       |
//| this macro also generates underlying OrderNode (which you are    |
//| not supposed to care) and OrderListIterator to iterate through a |
//| OrderList                                                        |
//| Notice the ending semicolon: it is needed.                       |
//+------------------------------------------------------------------+
LINKED_LIST(Order*, Order, true);

// for simplicity, I will not use the Lang/Script class
void OnStart()
  {
   OrderList list;
   int total= TradingPool::total();
   for(int i=0; i<total; i++)
     {
      if(TradingPool::select(i))
        {
         OrderPrint(); // to compare with Order.toString
         list.push(new Order());
        }
     }

   PrintFormat("There are %d orders. ",list.size());

   for(OrderListIterator iter(list); !iter.end(); iter.next())
     {
      Order*o=iter.get();
      Print(o.toString());
     }
  }
//+------------------------------------------------------------------+
```
  
### Asynchronous Events

The `Lang/Event` module provides a way to send custom events from
outside the MetaTrader terminal runtime, like from a DLL.

You need to call the `PostMessage/PostThreadMessage` funtion, and pass
parameters as encoded in the same algorithm with
`EncodeKeydownMessage`.  Then any program that derives from EventApp
can process this message from its `onAppEvent` event handler:

```
   #include <WinUser32.mqh>
   #include <MQL4/Lang/Event.mqh>
   bool SendAppEvent(int hwnd,ushort event,uint param)
     {
      int wparam, lparam;
      EncodeKeydownMessage(event, param, wparam, lparam);
      return PostMessageW(hwnd,WM_KEYDOWN,wparam, lparam) != 0;
     }
```

The mechanism uses a custom WM_KEYDOWN message to trigger the
OnChartEvent.  In `OnChartEvent` handler, `EventApp` checks if KeyDown
event is actually a custom app event from another source (not a real
key down). If it is, then `EventApp` calls its `onAppEvent` method.

This mechnism has certain limitations: the parameter is only an integer
(32bit), due to how WM_KEYDOWN is processed in MetaTrader
terminal. And this solution may not work in 64bit MetaTrader5.

Despite the limitations, this literally liberates you from the
MetaTrader jail: you can send in events any time and let mt4 program
process it, without polling in OnTimer, or creating pipe/sockets in
OnTick, which is the way most API wrappers work.

Using OnTimer is not a good idea. First it can not receive any
parameters from the MQL side. You at least needs an idenfier for the
event. Second, WM_TIMER events are very crowded in the main
thread. Even on weekends where there are no data coming in, WM_TIMER
is constantly sent to the main thread. This makes more instructions
executed to decide if it is a valid event for the program.

*WARNING*:

    This is a temporary solution. The best way to handle asynchronous
    events is to find out how ChartEventCustom is implemented and
    implement that in C/C++, which is extremely hard as it is not
    implemented by win32 messages, and you can not look into it
    because of very strong anti-debugging measures.

Inside MetaTrader terminal, you better use ChartEventCustom to
send custom events.

