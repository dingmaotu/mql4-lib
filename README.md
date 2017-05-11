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

Basically, you write your program in a reusable class, and when
you want to use them as standalone executables, you use macros
to declare them.

The macro distinguish between programs with and without input parameters. Here
is a simple script without any input parameter:

```c++
#include <MQL4/Lang/Script.mqh>
class MyScript: public Script
{
public:
  // OnStart is now main
  void main() {Print("Hello");}
};

// declare it: notice second parameter indicates the script has no input
DECLARE_SCRIPT(MyScript,false)
```

Here is another example, this time an Expert Advisor with input parameters:

```c++
#include <MQL4/Lang/ExpertAdvisor.mqh>

class MyEaParam: public AppParam
{
  ObjectAttr(string,eaName,EaName);
  ObjectAttr(double,baseLot,BaseLot);
public:
  // optionally override `check` method to validate paramters
  // this method will be called before initialization of EA
  // if this method returns false, then INIT_INCORRECT_PARAMETERS will
  // be returned
  // bool check(void) {return true;}
};

class MyEa: public ExpertAdvisor
{
private:
  MyEaParam *m_param;
public:
       MyEa(MyEaParam *param)
       :m_param(param)
      {
         // Initialize EA in the constructor instead of OnInit;
         // If failed, you call fail(message, returnCode)
         // both paramters of `fail` is optional, with default return code INIT_FAIL
         // if you don't call `fail`, the default return code is INIT_SUCCESS;
      }
      ~MyEa()
      {
         // Deinitialize EA in the destructor instead of OnDeinit
         // getDeinitReason() to get deinitialization reason
      }
  // OnTick is now main
  void main() {Print("Hello from " + m_param.getEaName());}
};

// The code before this line can be put in a separate mqh header

// We use macros to declare inputs
// Notice the trailing semicolon at the end of each INPUT, it is needed
// support custom display name because of some unknown rules from MetaQuotes
BEGIN_INPUT(MyEaParam)
  INPUT(string,EaName,"My EA"); // EA Name (Custom display name is supported)
  INPUT(double,BaseLot,0.1);    // Base Lot
END_INPUT

DECLARE_EA(MyEa,true)  // true to indicate it has parameters
```

The `ObjectAttr` macro declares standard get/set methods for a class. Just
follow the Java Beans(TM) convention.

I used some macro tricks to work around limits of MQL4. I will document
the library in detail when I have the time.

With this approach, you can write reusable EAs, Scripts, or
Indicators.  You do not need to worry about the OnInit, OnDeinit,
OnStart, OnTick, OnCalculate, etc.  You never use a input parameter directly in
your EA. You can write a base EA, and extend it easily.

### Collections

In advanced MQL4 programs, you have to use more sophisticated
collection types for your order management.

It is planned to add common collection types to the lib, including
lists, hash maps, trees, and others.

Currently there are two list types:

1. Collection/LinkedList is a Linked List implementation
2. Collection/Vector is an array based implementation

First I'd like to point out some extremely useful undocumented MQL4/5
features:

1. class templates(!)
2. typedef function pointers(!)
3. template function overloading

Though inheriting multiple interfaces is not possible now, I think this will be
possible in the future.
 
Among these features, `class template` is the most important because we can
greatly simplify Collection code. These features are used by MetaQuotes
to port .Net Regular Expression Library to MQL.

With class templates and inheritance, I implemented a hierarchy:

    Iterable -> Collection -> LinkeList and Vector

The general usage is as follows:

```c++
LinkedList<Order*> orderList; // linked list based implementation, faster insert/remove
LinkedList<int> intList; //  yes it supports primary types as well
Vector<Order*>; orderVector // array based implementation, faster random access
Vector<int> intVector;
```

To iterate through a collection, use its iterator, as iterators know what is
the most efficient way to iterating.

Here is a simple example:

```
//+------------------------------------------------------------------+
//|                                                TestOrderPool.mq4 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016-2017, Li Ding"
#property link      "dingmaotu@hotmail.com"
#property version   "1.00"
#property strict

#include <MQL4/Trade/Order.mqh>
#include <MQL4/Trade/OrderPool.mqh>
#include <MQL4/Collection/LinkedList.mqh>

// for simplicity, I will not use the Lang/Script class
void OnStart()
  {
   OrderList<Order*> list;
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

   foreach(Order*,list)
     {
      Order*o=it.current();
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
parameters from the MQL side. You at least needs an identifier for the
event. Second, WM_TIMER events are very crowded in the main
thread. Even on weekends where there are no data coming in, WM_TIMER
is constantly sent to the main thread. This makes more instructions
executed to decide if it is a valid event for the program.

*WARNING*: This is a temporary solution. The best way to handle asynchronous
events is to find out how ChartEventCustom is implemented and
implement that in C/C++, which is extremely hard as it is not
implemented by win32 messages, and you can not look into it
because of very strong anti-debugging measures.

Inside MetaTrader terminal, you better use ChartEventCustom to
send custom events.

