# mql4-lib

MQL Foundation Library For Professional Developers

* [1. Introduction](#introduction)
* [2. Installation](#installation)
* [3. Usage](#usage)
  * [3.1 Basic Programs](#basic-programs)
  * [3.2 Runtime Controlled Indicators and Indicator Drivers](#runtime-controlled-indicators-and-indicator-drivers)
  * [3.3 Event Handling](#event-handling)
  * [3.4 External Events](#external-events)
  * [3.5 Collections](#collections)
  * [3.6 Maps](#maps)
  * [3.7 File System and IO](#file-system-and-io)
  * [3.8 Serialization Formats](#serialization-formats)
  * [3.9 Order Access](#order-access)
  * [3.10 Symetric Order Semantics](#symetric-order-semantics)
* [4. Contribution Guide](#contribution-guide)
* [5. Changes](#changes)

## Introduction

MQL4/5 programming language provided by MetaQuotes is a very limited version of
C++, and its standard library is a clone of the (ugly) MFC, both of which I am
very uncomfortable with. Most MQL4 programs have not adapted to the MQL5 (Object
Oriented) style yet, let alone reuable and elegant component based design and
programming.

mql4-lib is a simple library that tries to make MQL programming pleasant with
a more object oriented approach and a coding style like Java, and encourages
writing reusable components. This library has the ambition to become the de
facto Foundation Library for MQL.

Though the library was targeting MQL4, most of its components is compatible with
MQL5. Except for trading related classes, you can use the library on
MetaTrader5. It is intended to remove this restriction and make the library a
truly cross version library for both MT4 and MT5 (and x86/x64). Maybe the
library will change its name to mql-lib in the future.

## Installation

Just copy the library to your MetaTrader Data Folder's `Include` directory, with
the root directory name of your choice, for example:

1. For MT4: `<MetaTrader Data>\MQL4\Include\Mql\<mql4-lib content>`.
2. For MT5: `<MetaTrader Data>\MQL5\Include\Mql\<mql4-lib content>`.

  Note that the recommended root directory name is `Mql` (Pascal Case) now.
  Previously it is `MQL4`, which is more MT4 specific. In fact, most of the
  library is also usable on MT5, so I started the process to make this library
  compatible with both. All examples will also use this root name.

It is recommened that you use the lastest version MetaTrader4/5, as many
features are not available in older versions.

## Usage

The library is in its early stage. However, most components are pretty stable
and can be used in production. Here are the main components:

1. `Lang` directory contains modules that enhance the MQL language
2. `Collection` directory contains useful collection types
3. `Format` directory contains serialization formats implementations
4. `Charts` directory contains several chart types and common chart tools
5. `Trade` directory contains useful abstractions for trading
6. `History` directory contains useful abstractions for history data
7. `Utils` directory contains various utilities
8. `UI` chart objects and UI controls (in progress)
9. `OpenCL` brings OpenCL support to MT4 (in progress)

### Basic Programs

In `Lang`, I abstract three Program types (Script, Indicator, and Expert
 Advisor) to three base classes that you can inherit.

Basically, you write your program in a reusable class, and when you want to use
them as standalone executables, you use macros to declare them.

The macro distinguish between programs with and without input parameters. Here
is a simple script without any input parameter:

```c++
#include <Mql/Lang/Script.mqh>
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
#include <Mql/Lang/ExpertAdvisor.mqh>

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

I used some macro tricks to work around limits of MQL. I will document the
library in detail when I have the time.

With this approach, you can write reusable EAs, Scripts, or Indicators. You do
not need to worry about the OnInit, OnDeinit, OnStart, OnTick, OnCalculate, etc.
You never use a input parameter directly in your EA. You can write a base EA,
and extend it easily.

### Runtime Controlled Indicators and Indicator Drivers

When you create an indicator with this lib, it can be used as both standalone
(controlled by the Terminal runtime) or driven by your programs. This is a
powerful concept in that you can write your indicator once, and use it in your
EA and Script, or as a standalone Indicator. You can use the indicator in normal
time series chart, or let it driven by a `HistoryData` derived class
(TimeSeriesData, Renko, or TimeFrame).

Let me show you with an example Indicator `DeMarker`. First we define the common
reusable Indicator module in a header file `DeMarker.mqh`

```MQL5
//+------------------------------------------------------------------+
//|                                                     DeMarker.mqh |
//|                                          Copyright 2017, Li Ding |
//|                                            dingmaotu@hotmail.com |
//+------------------------------------------------------------------+
#property strict

#include <Mql/Lang/Mql.mqh>
#include <Mql/Lang/Indicator.mqh>
#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//| Indicator Input                                                  |
//+------------------------------------------------------------------+
class DeMarkerParam: public AppParam
  {
   ObjectAttr(int,AvgPeriod,AvgPeriod); // SMA Period
  };
//+------------------------------------------------------------------+
//| DeMarker                                                         |
//+------------------------------------------------------------------+
class DeMarker: public Indicator
  {
private:
   int               m_period;
protected:
   double            ExtMainBuffer[];
   double            ExtMaxBuffer[];
   double            ExtMinBuffer[];
public:

   //--- this provides time series like access to the indicator buffer
   double            operator[](const int index) {return ExtMainBuffer[ArraySize(ExtMainBuffer)-index-1];}

                     DeMarker(DeMarkerParam *param)
   :m_period(param.getAvgPeriod())
     {
      //--- runtime controlled means that it is used as a standalone Indicator controlled by the Terminal
      //--- isRuntimeControlled() is a method of common parent class `App`
      if(isRuntimeControlled())
        {
         //--- for standalone indicators we set some options for visual appearance
         string short_name;
         //--- indicator lines
         SetIndexStyle(0,DRAW_LINE);
         SetIndexBuffer(0,ExtMainBuffer);
         //--- name for DataWindow and indicator subwindow label
         short_name="DeM("+IntegerToString(m_period)+")";
         IndicatorShortName(short_name);
         SetIndexLabel(0,short_name);
         //---
         SetIndexDrawBegin(0,m_period);
        }
     }

   int               main(const int total,
                          const int prev,
                          const datetime &time[],
                          const double &open[],
                          const double &high[],
                          const double &low[],
                          const double &close[],
                          const long &tickVolume[],
                          const long &volume[],
                          const int &spread[])
     {
      //--- check for bars count
      if(total<m_period)
         return(0);
      if(isRuntimeControlled())
        {
         //--- runtime controlled buffer is auto extended and is by default time series like
         ArraySetAsSeries(ExtMainBuffer,false);
        }
      else
        {
         //--- driven by yourself and thus the need to resize the main buffer
         if(prev!=total)
           {
            ArrayResize(ExtMainBuffer,total,100);
           }
        }
      if(prev!=total)
        {
         ArrayResize(ExtMaxBuffer,total,100);
         ArrayResize(ExtMinBuffer,total,100);
        }
      ArraySetAsSeries(low,false);
      ArraySetAsSeries(high,false);

      int begin=(prev==total)?prev-1:prev;

      for(int i=begin; i<total; i++)
        {
         if(i==0) {ExtMaxBuffer[i]=0.0;ExtMinBuffer[i]=0.0;continue;}
         if(high[i]>high[i-1]) ExtMaxBuffer[i]=high[i]-high[i-1];
         else ExtMaxBuffer[i]=0.0;

         if(low[i]<low[i-1]) ExtMinBuffer[i]=low[i-1]-low[i];
         else ExtMinBuffer[i]=0.0;
        }
      for(int i=begin; i<total; i++)
        {
         if(i<m_period) {ExtMainBuffer[i]=0.0;continue;}
         double smaMax=SimpleMA(i,m_period,ExtMaxBuffer);
         double smaMin=SimpleMA(i,m_period,ExtMinBuffer);
         ExtMainBuffer[i]=smaMax/(smaMax+smaMin);
        }

      //--- OnCalculate done. Return new prev.
      return(total);
     }
  };
```

If you want to use this as a standalone Indicator, create `DeMarker.mq4`:

```MQL5
//+------------------------------------------------------------------+
//|                                                     DeMarker.mq4 |
//|                                          Copyright 2017, Li Ding |
//|                                            dingmaotu@hotmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Li Ding"
#property link      "dingmaotu@hotmail.com"
#property version   "1.00"
#property strict

#property indicator_separate_window
#property indicator_minimum    0
#property indicator_maximum    1.0
#property indicator_buffers    1
#property indicator_color1     LightSeaGreen
#property indicator_level1     0.3
#property indicator_level2     0.7
#property indicator_levelcolor clrSilver
#property indicator_levelstyle STYLE_DOT

#include <Indicators/DeMarker.mqh>
//--- input parameters
BEGIN_INPUT(DeMarkerParam)
   INPUT(int,AvgPeriod,14); // Averaging Period
END_INPUT

DECLARE_INDICATOR(DeMarker,true);
```

Or if you want to use it in your EA, driven by a Renko chart:
```MQL5
//--- code snippets for using an indicator with Renko

//--- OnInit
//--- create the indicator manually, its runtime controlled flag is false by default
   DeMarkerParam *param=new DeMarkerParam;
   param.setAvgPeriod(14);
   deMarker=new DeMarker(param);

//--- HistoryData::OnUpdate is an event that can be subscribed by Indicators
   renko = new Renko(_Symbol,300);
//--- add indicator to the driver: you can add multiple indicators
//--- the OnUpdate event will delete its subscribers when destructed
   renko.OnUpdate+=deMarker;
//--- create the real driver that provide history data
   
//--- OnTick
   renko.update(Close[0]);
   
//--- after update, all indicators attached to the renko.OnUpdate event will be updated
//--- access DeMarker
   double value = deMarker[0];
   
//--- OnDeinit
//--- need to release resources
   delete renko;
```

### Event Handling

Expert Advisors and Indicators can receive events from the chart they run on,
and they derive from the `EventApp` class, which provides the facility to handle
events easily.

By default `EventApp` handles all events by doing nothing. You can even create
an empty EA or Indicator if you like:

```MQL5
#include <Mql/Lang/ExpertAdvisor.mqh>

class MyEA: public ExpertAdvisor {};

DECLARE_EA(MyEA,false)
```

This can be useful if what you create is a pure UI application, or simply acting
to external events. You do not need a main method. You only need to handle what
interests you.

```MQL5
#include <Mql/Lang/ExpertAdvisor.mqh>
class TestEvent: public ExpertAdvisor
  {
public:
   void              onAppEvent(const ushort event,const uint param)
     {
      PrintFormat(">>> External event from DLL: %u, %u",event,param);
     }
     
   void              onClick(int x, int y)
     {
      PrintFormat(">>> User clicked on chart at position (%d,%d)", x, y);
     }
     
   void              onCustom(int id, long lparam, double dparam, string sparam)
     {
      //--- `id` is the SAME as the second parameter of ChartEventCustom,
      //--- no need to minus CHARTEVENT_CUSTOM, the library does it for you
      PrintFormat(">>> Someone has sent a custom event with id %d", id);
     }
  };
DECLARE_EA(TestEvent,false)
```

### External Events

The `Lang/Event` module provides a way to send custom events from outside the
MetaTrader terminal runtime, like from a DLL.

You need to call the `PostMessage/PostThreadMessage` funtion, and pass
parameters as encoded in the same algorithm with `EncodeKeydownMessage`. Then
any program that derives from EventApp can process this message from its
`onAppEvent` event handler.

Here is a sample implementation in C:

```C
#include <Windows.h>
#include <stdint.h>
#include <limits.h>

static const int WORD_BIT = sizeof(int16_t)*CHAR_BIT;

void EncodeKeydownMessage(const WORD event,const DWORD param,WPARAM &wparam,LPARAM &lparam)
{
    DWORD t=(DWORD)event;
    t<<= WORD_BIT;
    t |= 0x80000000;
    DWORD highPart= param & 0xFFFF0000;
    DWORD lowPart = param & 0x0000FFFF;
    wparam = (WPARAM)(t|(highPart>>WORD_BIT));
    lparam = (LPARAM)lowPart;
}

BOOL MqlSendAppMessage(HWND hwnd, WORD event, DWORD param)
{
    WPARAM wparam;
    LPARAM lparam;
    EncodeKeydownMessage(event, param, wparam, lparam);
    return PostMessageW(hwnd,WM_KEYDOWN,wparam, lparam);
}
```

The mechanism uses a custom WM_KEYDOWN message to trigger the OnChartEvent. In
`OnChartEvent` handler, `EventApp` checks if KeyDown event is actually a custom
app event from another source (not a real key down). If it is, then `EventApp`
calls its `onAppEvent` method.

This mechnism has certain limitations: the parameter is only an integer (32bit),
due to how WM_KEYDOWN is processed in MetaTrader terminal. And this solution may
not work in 64bit MetaTrader5.

Despite the limitations, this literally liberates you from the MetaTrader jail:
you can send in events any time and let mt4 program process it, without polling
in OnTimer, or creating pipe/sockets in OnTick, which is the way most API
wrappers work.

Using OnTimer is not a good idea. First it can not receive any parameters from
the MQL side. You at least needs an identifier for the event. Second, `WM_TIMER`
events are very crowded in the main thread. Even on weekends where there are no
data coming in, `WM_TIMER` is constantly sent to the main thread. This makes
more instructions executed to decide if it is a valid event for the program.

*WARNING*: This is a temporary solution. The best way to handle asynchronous
events is to find out how ChartEventCustom is implemented and implement that in
C/C++, which is extremely hard as it is not implemented by win32 messages, and
you can not look into it because of very strong anti-debugging measures.

Inside MetaTrader terminal, you better use ChartEventCustom to send custom
events.

### Collections

In advanced MQL programs, you have to use more sophisticated collection types
for your order management.

It is planned to add common collection types to the lib, including lists, hash
maps, trees, and others.

Currently there are two list types:

1. Collection/LinkedList is a Linked List implementation
2. Collection/Vector is an array based implementation

And there are two `Set` implementations:
1. Array based `Collection/Set` 
2. Hash based `Collection/HashSet`

With class templates and inheritance, I implemented a hierarchy:

    Iterable -> Collection -> LinkedList
                           -> Vector
                           -> Set
                           -> HashSet
                           
But in the future, the hierarchy might be:

    Iterable -> Collection -> List -> ArrayList
                                   -> LinkedList
                           -> Set  -> ArraySet
                                   -> HashSet
                                   
`List` adds some important methods such as index based access to elements, and
`stack` and `queue` like methods (e.g. `push`, `pop`, `shift`, `unshift`, etc.).
But currently `Set` is basically the same as `Collection`. Maybe some set operations
(union, intersect, etc.) is necesary.

For simple and short collection, even if you perform frequent insertion and
deletion, array based implementation may be faster and has smaller overhead.

    I'd like to point out some extremely useful undocumented MQL4/5 features:

        1. class templates(!)
        2. typedef function pointers(!)
        3. template function overloading
        4. union type

    Though inheriting multiple interfaces is not possible now, I think this will be
    possible in the future.
 
    Among these features, `class template` is the most important because we can
    greatly simplify Collection code. These features are used by MetaQuotes to port
    .Net Regular Expression Library to MQL.

The general usage is as follows:

```c++
LinkedList<Order*> orderList; // linked list based implementation, faster insert/remove
LinkedList<int> intList; //  yes it supports primary types as well
Vector<Order*>; orderVector // array based implementation, faster random access
Vector<int> intVector;
```

To iterate through a collection, use its iterator, as iterators know what is the
most efficient way to iterating.

Threre are alao two macros for iteration: `foreach` and `foreachv`. You can
`break` and `return` in the loop without worrying about resource leaks because
we use `Iter` RAII class to wrap the iterator pointer.

Here is a simple example:

```
//+------------------------------------------------------------------+
//|                                                TestOrderPool.mq4 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016-2017, Li Ding"
#property link      "dingmaotu@hotmail.com"
#property version   "1.00"
#property strict

#include <Mql/Trade/Order.mqh>
#include <Mql/Trade/OrderPool.mqh>
#include <Mql/Collection/LinkedList.mqh>

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

   //--- Iter RAII class
   for(Iter<Order*> it(list); !it.end(); it.next())
     {
      Order*o=it.current();
      Print(o.toString());
     }

   //--- foreach macro: use it as the iterator variable
   foreach(Order*,list)
     {
      Order*o=it.current();
      Print(o.toString());
     }

   //--- foreachv macro: declare element varaible o in the second parameter
   foreachv(Order*,o,list)
     Print(o.toString());

  }
//+------------------------------------------------------------------+
```

### Maps

Map (or dictionary) is extremely important for any non-trivial programs.
Mql4-lib impelements an efficient Hash map using Murmur3 string hash. The
implementation follows the CPython3 hash and it preserves insertion order.

You can use any builtin type as key, including any class pointer. These types
has their hash functions implemented in `Lang/Hash` module.

The HashMap interface is very simple. Below is a simple example counting words
of the famous opera `Hamlet`:

```MQL5
#include <Mql/Lang/Script.mqh>
#include <Mql/Collection/HashMap.mqh>
#include <Mql/Utils/File.mqh>

class CountHamletWords: public Script
  {
public:
   void              main()
     {
      TextFile txt("hamlet.txt", FILE_READ);
      if(txt.valid())
        {
         HashMap<string,int>wordCount;
         while(!txt.end() && !IsStopped())
           {
            string line= txt.readLine();
            string words[];
            StringSplit(line,' ',words);
            int len=ArraySize(words);
            if(len>0)
              {
               for(int i=0; i<len; i++)
                 {
                  int newCount=0;
                  if(!wordCount.contains(words[i]))
                     newCount=1;
                  else
                     newCount=wordCount[words[i]]+1;
                  wordCount.set(words[i],newCount);
                 }
              }
           }
         Print("Total words: ",wordCount.size());
         //--- you can use the foreachm macro to iterate a map
         foreachm(string,word,int,count,wordCount)
         {
            PrintFormat("%s: %d",word,count);
         }
        }
     }
  };
DECLARE_SCRIPT(CountHamletWords,false)
```

After a recent update (2017-11-28), the Map iterator is no longer const and
supports two addtional operations: remove and replace (setValue). So in the
previous version, if you want to remove some elements from a map, you had to
store the keys in a separate place, and remove these keys later. It is neither
elegant nor efficient. The following example shows the difference:

```MQL5
HashMap<int,int> m;
//--- before the update
Vector<int> v;
foreachm(int,key,int,value,m)
{
  if(value%2==0) v.push(key);
}
foreachv(int,key,v)
{
  m.remove(key);
}
//--- after the update
foreachm(int,key,int,value,m)
{
  if(value%2==0) it.remove();
}
```

### File System and IO 

MQL file functions by design directly operate on three types of files: Binary,
Text, and CSV. To me, these types of files are supposed to form a layered
relationship: CSV is a specialized Text, and Text specialized Binary (with
encoding/decoding of text). But the functions are NOT designed this way, rather
as a tangled mess by allowing various functions to operate on different types of
files. For example, `FileReadString` behavior is totally different besed on what
kind of file it's opearting: for Binary the unicode bytes (UTF-16 LE) are read
with specified length, for Text the entire line is read (is FILE_ANSI flag is
set the text is decoded based on codepage), and for CSV only a string field is
read. I don't like this design, neither I have the energy and time to
reimplement text encoding/decoding and type serializing/deserializing.

So I wrote a `Utils/File` module, wrapping all file functions with a much
cleaner interface, but without changing the whole design. There are five
classes: `File` is a base class but you can not instantiate it; `BinaryFile`,
`TextFile`, and `CsvFile` are the subclasses which are what you use in your
code; and there is an interesting class `FileIterator` which impelemented
standard `Iterator` interface, and you can use the same technique to iterate
through directory files.

Here is a example for TextFile and CsvFile:

```MQL5
#include <Mql/Utils/File.mqh>

void OnStart()
  {
   File::createFolder("TestFileApi");

   TextFile txt("TestFileApi\\MyText.txt",FILE_WRITE);
   txt.writeLine("你好，世界。");
   txt.writeLine("Hello world.");

//--- reopen closes the current file handle first
   txt.reopen("TestFileApi\\MyText.txt",FILE_READ);
   while(!txt.end())
     {
      Print(txt.readLine());
     }

   CsvFile csv("TestFileApi\\MyCsv.csv",FILE_WRITE);
//--- write whole line as a text file
   csv.writeLine("This,is one,CSV,file");

//--- write fields one by one
   csv.writeString("这是");
   csv.writeDelimiter();
   csv.writeInteger(1);
   csv.writeDelimiter();
   csv.writeBool(true);
   csv.writeDelimiter();
   csv.writeString("CSV");
   csv.writeNewline();

   csv.reopen("TestFileApi\\MyCsv.csv",FILE_READ);
   for(int i=1; !csv.end(); i++)
     {
      Print("Line ",i);
      //--- notice that you SHALL NOT directly use while(!csv.isLineEnding()) here
      //--- or you will run into a infinite loop
      do
        {
         Print("Field: ",csv.readString());
        }
      while(!csv.isLineEnding());
     }
```

And here is an example for `FileIterator`:

```MQL5
#include <Mql/Utils/File.mqh>

int OnStart()
{
   for(FileIterator it("*"); !it.end(); it.next())
     {
      string name=it.current();
      if(File::isDirectory(name))
        {
         Print("Directory: ",name);
        }
      else
        {
         Print("File: ",name);
        }
     }
}
```

Or you can go fancy with the powerful `foreachfile` macro:

```MQL5
#include <Mql/Utils/File.mqh>

int OnStart()
{
//--- first parameter is the local variable *name* for current file name
//--- second parameter is the filter pattern string
   foreachfile(name,"*")
     {
      if(File::isDirectory(name))
         Print("Directory: ",name);
      else
         Print("File: ",name);
     }
}
```

There is also a special kind of file called history file. They are the files
that backs the MetaTrader chart display. There is a sepcial function for opening
a history file: `HistoryFileOpen` and history files have a fixed structure. I
wrapped operations on history files in a class `Utils/HistoryFile`. This
component is very useful in implementing custom chart types as offline charts.
You can see example usages in `Chart/PriceBreakChart` or `Chart/RenkoChart`.

### Serialization Formats

It is very useful to have some fast and reliable serialization formats to do
persistence, messsaging, etc. There are a lot of options: JSON, ProtoBuf, etc.
However they are somewhat difficult to implement in MQL. Take JSON as an
example, you have to use a Map or Dictionary like data structure to implement
Objects, and even parsing a number is not an easy task (See the JSON
sepcification). And I really don't like a Dictionary to be created every time I
receive a simple JSON. ProtoBuf is a lot harder, because you have to implement a
ProtoBuf compiler to generate code for MQL.

When I decided to rewrite the mql4-redis binding, I had a plan to make a pure
MQL Redis client. So I started to understand and implement the `REdis
Serialization Protocol` (RESP). It is extremely simple yet useful enough. It has
data types like string, integer, array, bulk string (bytes), and nil. So I
implemented these types in MQL and make a full encoder/decoder.

I put it in this general library rather than the mql-redis client because it is
a reusable component. Think about you can serialize values to a buffer and use
ZeroMQ to send them as messages. I will explain the usage of RESP protocol
component in this section.

To use the RESP protocol, you need to include `Mql/Format/Resp.mqh`. The value
types are straight forward:

```MQL5
#include <Mql/Lang/Resp.mqh>
//--- RespValue is the parent of all values
//--- it has some common methods that is implemented by all types
//--- they are: encode, toString, getType
string GetEncodedString(const RespValue &value)
  {
   char res[];
   value.encode(res,0);
   RespBytes bytes(res);
   // RespBytes' toString method prints the byte content as human readable string with proper escapes
   return bytes.toString();
  }
void OnStart()
  {
   //--- create an array preallocated with 7 elements
   RespArray a(7);
   a.set(0, new RespBytes("set"));
   a.set(1,new RespBytes("x"));
   a.set(2, new RespBytes("10"));          // Bulk strings (can contains spaces, newlines, etc. in the string)
   a.set(3, new RespError("ERROR test!")); // Same as RespString but indicate an error
   a.set(4,new RespString("abd akdfa\"")); // RespString is what in hiredis REPLY_STATUS type
   a.set(5,new RespInteger(623));
   a.set(6,RespNil::getInstance());        // RespNil is a singleton type


   Print(a.toString());                    // Print a human readable representation of array
   Print(GetEncodedString(a));

   char res[];
   a.encode(res,0);

   int encodedSize=ArraySize(res);
   RespMsgParser msgParser;                // RespMsgParser parses a buffer with complete input
   RespValue *value=RespParser::parse(res,0);
   Print(parser.getPosition()==encodedSize);
   Print(value.getType()==TypeArray);
   Ptr<RespArray>b(dynamic_cast<RespArray*>(value));
   Print(b.r.size()==7);
  }
```

As shown in above code, you can compose values arbituarily and encode them to a
buffer. You can nest arrays infinitely. The value types provide very useful methods
for various operations. You can find more in corresponding source files.

I wrote TWO parsers for the protocol. The first one is for a message oriented
context, where you receive the buffer in a whole and start parsing. The class is
`RespMsgParser`. The other is `RespStreamParser` for a stream oriented context,
where you may receive a buffer partially and start parsing. It will tell you if
it needs more input, and you can resume parsing when you feed more input to it.
The later parser is inspired by the hiredis `ReplyReader` implementation.

They both have a `getError` method that tells you what is going wrong (check
`Mql/Format/RespParseError.mqh` for all error codes) if the `parse` method
returns a NULL value. `RespMsgParser` has a `check` method that can check if the
giving buffer contains a valid `RespValue` without actaully create it. The
`check` method also sets error flags like the `parse` method does.

Both parsers do not have a nesting limit like the hiredis `ReplyReader`. Only
your computer's memory (or MetaTrader's stack) is the limit. But overall, the
`ReplyReader` will be faster than my parsers. It is C and it keeps a stack with
a static array. And it does not aim to be a general encode/decode library.

### Order Access

In most MQL4 programs, you access orders by `OrdersHistoryTotal`, `OrdersTotal`,
and `OrderSelect`. The code is usually messier as you have to filter certain
orders. The basic logic is like this:

```MQL5
int total = OrdersTotal();

for(int i=0; i<total; i++)
{
  if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) continue;
  if(!MatchesWhateverPredicatesYouSet()) continue;
  DoSomethingYouWantWithTheOrder();
}
```

The point is, order filtering code is usually reusable and you don't want to
rewrite it every time you need to filter orders.

So in the `Trade/Order` and `Trade/OrderPool` modules, I provide an OrderPool
class that can be derived by you and a convenient iterator to encapsulate the
above convention for accessing orders. Here is an example showing the basic
usage:

```MQL5
#include <Mql/Trade/OrderPool.mqh>
//+------------------------------------------------------------------+
//| Only matches the profit orders in the history pool               |
//+------------------------------------------------------------------+
class ProfitHistoryPool: public HistoryPool
  {
public:
   bool              matches() const {return Order::Profit()>0;}
  };

void OnStart()
  {
   ProfitHistoryPool profitPool;
   // the foreachorder macro can iterate order pools for you
   // and take care of order filtering
   // both pointers and references are accepted
   foreachorder(profitPool)
     {
      //--- here you can directly use Order* function like this:
      //--- OrderPrint();
      //--- or create an Order class
      Order o;
      Print(o.toString());
     }
  }
```

### Symetric Order Semantics

What do I mean by *symetric order semantics*? Consider the following code to set
a trailing stoploss step by step until the order is in breakeven state:

```MQL5
// Partial code for illustration purposes; not runnable if you don't have other codes
// M_POINT is a constant (the Point value of current symbol)
void TrailToBreakeven(const Order &order,OrderAttributes &attr)
  {
//--- Check if profitted more than InpBreakevenPoints
   bool isSetStopLoss=false;
   double stopLossLevel=0.0;

   if(order.getStopLoss()>0)
     {
      if(order.getType()==OP_BUY)
        {
         if(order.getStopLoss()<order.getOpenPrice())
           {
            double profitPrice=m_symbol.getBid()-order.getOpenPrice()-InpBreakevenPoints*M_POINT;
            if(profitPrice>0)
              {
               if(InpBreakevenStep>0)
                 {
                  int factor=int(profitPrice/(InpBreakevenStep*M_POINT));
                  if(factor>0)
                    {
                     double sl=attr.getOriginalStoploss()+InpBreakevenPoints*M_POINT*factor;
                     if(sl>order.getStopLoss())
                       {
                        isSetStopLoss=true;
                        if(sl>order.getOpenPrice())
                          {
                           stopLossLevel=NormalizeDouble(order.getOpenPrice()+M_POINT,M_DIGITS);
                          }
                        else
                          {
                           stopLossLevel=NormalizeDouble(sl,M_DIGITS);
                          }
                       }
                    }
                 }
               else
                 {
                  isSetStopLoss=true;
                  stopLossLevel=NormalizeDouble(order.getOpenPrice()+M_POINT,M_DIGITS);
                 }
              }
           }
        }
      else
        {
         if(order.getStopLoss()>order.getOpenPrice())
           {
            double profitPrice=order.getOpenPrice()-InpBreakevenPoints*M_POINT-m_symbol.getAsk();
            if(profitPrice>0)
              {
               if(InpBreakevenStep>0)
                 {
                  int factor=int(profitPrice/(InpBreakevenStep*M_POINT));
                  if(factor>0)
                    {
                     double sl=attr.getOriginalStoploss()-InpBreakevenPoints*M_POINT*factor;
                     if(sl<order.getStopLoss())
                       {
                        isSetStopLoss=true;
                        if(sl<order.getOpenPrice())
                          {
                           stopLossLevel=NormalizeDouble(order.getOpenPrice()-M_POINT,M_DIGITS);
                          }
                        else
                          {
                           stopLossLevel=NormalizeDouble(sl,M_DIGITS);
                          }
                       }
                    }
                 }
               else
                 {
                  isSetStopLoss=true;
                  stopLossLevel=NormalizeDouble(order.getOpenPrice()-M_POINT,M_DIGITS);
                 }
              }
           }
        }
     }
   if(isSetStopLoss)
     {
      if(OrderModify(order.getTicket(),0,stopLossLevel,0,0,clrNONE))
        {
         PrintFormat(">>> Setting order #%d stoploss to %f",order.getTicket(),stopLossLevel);
         if((order.getType()==OP_BUY && stopLossLevel>=order.getOpenPrice())
            || (order.getType()==OP_SELL && stopLossLevel<=order.getOpenPrice()))
            attr.setState(Breakeven);
        }
      else
        {
         Alert(StringFormat(">>> Error setting order #%d stoploss %f",order.getTicket(),stopLossLevel));
        }
     }
  }
```

This is very typical in everyday EA development. You can see for both BUY and
SELL orders the logic is the same. But the code have to be written separately
because they have enough differences. And it is also hard to tell what logic you
are using because they are buried in the calculation detail. It is error prone
to write like this, as you may forget to change some minus or plus signs when
copy the almost same code. Furthur more, we frequently use price formatting,
point value to absolute price difference conversions, and price normalization,
etc. What if we can write the logic clearly only once and automatically deal
with both BUY and SELL orders?

The solution is *symetric order semantics*: it is a set of methods (with both
instance and static versions) in the `Order` class. The method names are pretty
simple (I made them short intentionally), and every method express a general
semantic of an order regardless of its type. I will list the basic operations
below and show how to use them later.

1. Formatting and conversion

There are 3 operations that support the formatting and conversion of a price
value based on the order symbol.

    * f(p) *format* price `p` to string with respect to the symbol digits
    * n(p) *normalize* price `p` to a double with respect to the symbol digits
    * ap(p) get the *absolute price difference* (double type) of point value `p` (int type)
    
2. Current price level

It is very common to get the corresponding ask/bid value based on order type.
For buy order, open with ask, close with bid; and vice versa for sell order. I
provide 2 basic operations to get this value.

    * s() get the correct price to *start* an order
    * e() get the correct price to *end* an order
    
3. Price calculation

There are 2 opertions for price calculation.

    * p(s,e) get the *profit* as the absolute price difference from start price
      `s` to the end price `e`. To get the loss, just use -p(s,e) or p(e,s); the
      former is preferred as it is clearer expressing the opposite of *profit*
    * pp(p,pr) the target *price* if we start from `p` and we want to *profit*
      `pr`. Use pp(p,-pr) if we want to lose `pr`
    
There is a overloading method for `pp` where the `pr` parameter is in point
value. It is just for convenience and not essential for the semantics.

With these basic opperations, we can express most semantics about an order
symetrically. For example, how do we express *breakeven*? It is
`order.p(order.getOpenPrice(),order.getStoploss())>=0`. This evaluates to
`order.getOpenPrice() <= order.getStopLoss()` for BUY order, and
`order.getOpenPrice() >= order.getStoploss()` for SELL order. Literally, we can
understand this by "if we move from open price to stop loss price, we still
profit". This way, you only write a single set of rules and express it clearly.

I will try to rewrite the example in the start of this section with *symetric
order semantics*. Read carefully and compare it with the first example. See how
the code length is greatly reduced and how the intention is made very clear.

```MQL5
// Partial code for illustration purposes; not runnable if you don't have other codes
void TrailToBreakeven(const Order &o,OrderAttributes &attr)
  {
//--- Check if profitted more than InpBreakevenPoints
   bool isSetStopLoss=false;
   double stopLossLevel=0.0;

   if(o.getStopLoss()>0)
     {
      //--- if not breakeven
      if(o.p(o.getOpenPrice(),o.getStopLoss())<0)
        {
         //--- how much do we already profit?
         double pp=o.p(o.getOpenPrice(),o.e());
         //--- if we profit more than those points set in input parameter
         if(pp>o.ap(InpBreakevenPoints))
           {
            //--- if we need to trail step by step
            if(InpBreakevenStep>0)
              {
               int factor=int(pp/o.ap(InpBreakevenStep));
               if(factor>0)
                 {
                  //--- calculate the target price by move stoploss in FAVOR to us
                  //--- NOTE that pp can accept points directly in its second parameter
                  double sl=o.pp(attr.getOriginalStoploss(),InpBreakevenPoints*factor);
                  //--- if target stoploss is better than current one
                  //--- (we will profit if we move from current stop loss to `sl`)
                  if(o.p(o.getStopLoss(),sl)>0)
                    {
                     isSetStopLoss=true;
                     //--- if the target make this order breakeven
                     if(o.p(o.getOpenPrice(),sl)>=0)
                        //--- we set stop loss to be one point better than open price
                        stopLossLevel=o.pp(o.getOpenPrice(),1);
                     else
                        stopLossLevel=sl;
                    }
                 }
              }
            else
              {
               isSetStopLoss=true;
               stopLossLevel=o.pp(o.getOpenPrice(),1);
              }
           }
        }
     }
   if(isSetStopLoss)
     {
      //--- modify stop loss to *NORMALIZED* price
      if(OrderModify(o.getTicket(),0,o.n(stopLossLevel),0,0,clrNONE))
        {
         //--- notice that we use %s for the price because we need to display the price
         //--- to certain digits based on current order symbol
         PrintFormat(">>> Setting order #%d stoploss to %s",o.getTicket(),o.f(stopLossLevel));
         //--- we modify order state if this modification make the order breakeven
         if(o.p(o.getOpenPrice(),stopLossLevel)>=0) attr.setState(Breakeven);
        }
      else
        {
         Alert(StringFormat(">>> Error setting order #%d stoploss %s",o.getTicket(),o.f(stopLossLevel)));
        }
     }
  }
```


## Contribution Guide

I would be very glad if you want to contribute to this library, but there are
some rules that you must follow. I value code quality (and the format) a lot.
This is by no means discouraging contribution. Instead, I welcome contributions
from all levels of developers.

1. Format the code with MetaEditor (`Ctrl-,`) with **DEFAULT** style. MetaEditor
   is not the best editor or IDE out there, but it is THE IDE for MQL, at least
   for now. And the default style is not good at all (I mean 3 spaces for
   indentation?) but again it is the standard used by most MQL developers. We
   need to follow the community standard to share our knowledge and effort even
   if we do not like it. Unless we can create a better IDE and make the
   community accept it.

2. File encoding: UTF-8. If you use CJK or other non-ASCCI characters, please
   save your file as UTF-8. There are no options in MetaEditor, but you can use
   your favorate editor to do it. Do not save to Unicode in MetaEditor! It will
   save your file in UTF16-LE and Git will think the file is binary.
   
3. Spaces and file ending. Do not leave spaces at after line ending. Leave a
   newline at the file ending.
   
4. Code style. Class members like this: `m_myMember`; method name like this:
   `doThis`; constant and macro definitions like this: `SOME_MACRO`; class name
   like this: `MyClass`; global functions like this: `DoThat`; use `ObjAttr` or
   related macros to define getters and setters. There may be other things to
   notice. Try to keep things consistent as much as possible.
   
5. Copyright. This library is Apache2 licensed. Your contribution will be
   Apache2 licensed, too. But you get your credit for the contribution. If you
   modify some lines of an existing file, you can add your name in the copyright
   line and specify what you have changed and when.

6. I will review your code with you. Prepare for some discussion or questions
   from me. We need to make sure at least the code is decent. I will help you as
   much as I can.

## Changes
* 2017-12-13: Deprecate and remove `RenkoIndicatorDriver`; use
  `HistoryData::OnUpdate` event instead

* 2017-11-28: Major refactoring of hash table based containers. The HashMap and
  HashSet now shares the same code base for hashing and entry managements. The
  compacting algorithm is improved. Map iterators support 2 addional operations
  in a loop: remove and replace (setValue).

* 2017-11-24: Improve and stablize OrderManager using *Symetric Order Semantics*

* 2017-11-23: Designed and Implemented *Symetric Order Semantics*

* 2017-09-28: Refined `OrderPool` code. Implemented order tracking module
  `Trade/OrderTracker`

* 2017-08-15: Implemented Price Break Chart. Renamed ChartFile to HistoryFile
  and made HistoryFile part of the File System API. Started the process toward a
  unified library for MT4 and MT5 (top level include directory name is `Mql`
  now).

* 2017-07-14: Added 2 RESP protocol parsers: one for message oriented buffers,
  one for stream buffers; they provide more specific error reporting than
  hiredis parser.

* 2017-07-10: Event handling in `EventApp`; added `HashSet`; reimplemented
  `HashMap`.

* Before 2017-07-10: A lot, and I will not list them. I decided to add a change
  log for future users to see what is going on at first sight.
