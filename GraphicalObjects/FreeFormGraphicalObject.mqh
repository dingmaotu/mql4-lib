//+------------------------------------------------------------------+
//| Module: GraphicalObjects/FreeFormGraphicalObject.mqh             |
//| This file is part of the mql4-lib project:                       |
//|     https://github.com/dingmaotu/mql4-lib                        |
//|                                                                  |
//| Copyright 2017 Li Ding <dingmaotu@126.com>                       |
//|                                                                  |
//| Licensed under the Apache License, Version 2.0 (the "License");  |
//| you may not use this file except in compliance with the License. |
//| You may obtain a copy of the License at                          |
//|                                                                  |
//|     http://www.apache.org/licenses/LICENSE-2.0                   |
//|                                                                  |
//| Unless required by applicable law or agreed to in writing,       |
//| software distributed under the License is distributed on an      |
//| "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,     |
//| either express or implied.                                       |
//| See the License for the specific language governing permissions  |
//| and limitations under the License.                               |
//+------------------------------------------------------------------+
#property strict
#include "GraphicalObject.mqh"
//+------------------------------------------------------------------+
//| Base class for all free form graphical objects                   |
//| The following elements are not anchored to price/time:           |
//|   OBJ_LABEL                                                      |
//|   OBJ_BUTTON                                                     |
//|   OBJ_BITMAP_LABEL                                               |
//|   OBJ_EDIT                                                       |
//|   OBJ_RECTANGLE_LABEL                                            |
//+------------------------------------------------------------------+
class FreeFormGraphicalObject: public GraphicalObject
  {
public:
                     FreeFormGraphicalObject(ENUM_OBJECT type,string id,long chartId=0,int subwindow=0):GraphicalObject(type,id,chartId,subwindow)
     {
      create();
     }

   //--- Position and Shape
   bool              setCorner(ENUM_BASE_CORNER value) {return setInteger(OBJPROP_CORNER,value);}
   ENUM_BASE_CORNER  getCorner() const {return(ENUM_BASE_CORNER)getInteger(OBJPROP_CORNER);}

   int               getX() const {return(int)getInteger(OBJPROP_XDISTANCE);}
   bool              setX(int value) {return setInteger(OBJPROP_XDISTANCE,value);}
   int               getY() const {return(int)getInteger(OBJPROP_YDISTANCE);}
   bool              setY(int value) {return setInteger(OBJPROP_YDISTANCE,value);}

   bool              setPosition(int x,int y) {return setX(x) && setY(y);}
   bool              move(int dx,int dy) {return setX(getX()+dx) && setY(getY()+dy);}

   int               getWidth() const {return(int)getInteger(OBJPROP_XSIZE);}
   virtual bool      setWidth(int value) {return setInteger(OBJPROP_XSIZE,value);}
   int               getHeight() const {return(int)getInteger(OBJPROP_YSIZE);}
   virtual bool      setHeight(int value) {return setInteger(OBJPROP_YSIZE,value);}

   bool              setSize(int width,int height) {return setWidth(width) && setHeight(height);}
  };
//+------------------------------------------------------------------+
//| OBJ_RECTANGLE_LABEL                                              |
//+------------------------------------------------------------------+
class Rectangle: public FreeFormGraphicalObject
  {
public:
                     Rectangle(string id,long chartId=0,int subwindow=0):FreeFormGraphicalObject(OBJ_RECTANGLE_LABEL,id,chartId,subwindow) {}

   bool              setBackgroundColor(color value) {return setInteger(OBJPROP_BGCOLOR,value);}
   color             getBackgroundColor() const {return color(getInteger(OBJPROP_BGCOLOR));}

   bool              setBorderType(ENUM_BORDER_TYPE value) {return setInteger(OBJPROP_BORDER_TYPE,value);}
   ENUM_BORDER_TYPE  getBorderType() const {return(ENUM_BORDER_TYPE)getInteger(OBJPROP_BORDER_TYPE);}
  };
//+------------------------------------------------------------------+
//| OBJ_LABEL                                                        |
//+------------------------------------------------------------------+
class Text: public FreeFormGraphicalObject
  {
public:
                     Text(string id,long chartId=0,int subwindow=0):FreeFormGraphicalObject(OBJ_LABEL,id,chartId,subwindow) {}

   bool              setWidth(int value) override {return false;}  // read only, thus do nothing
   bool              setHeight(int value) override {return false;}  // read only, thus do nothing

   //--- only to OBJ_LABEL: number of degrees to rotate
   bool              setAngle(double value) {return setDouble(OBJPROP_ANGLE,value);}
   double            getAngle() const {return getDouble(OBJPROP_ANGLE);}

   bool              setAnchor(ENUM_ANCHOR_POINT value) {return setInteger(OBJPROP_ANCHOR,value);}
   ENUM_ANCHOR_POINT getAnchor() const {return(ENUM_ANCHOR_POINT)getInteger(OBJPROP_ANCHOR);}
  };
//+------------------------------------------------------------------+
//| OBJ_BITMAP_LABEL                                                 |
//+------------------------------------------------------------------+
class Bitmap: public FreeFormGraphicalObject
  {
public:
                     Bitmap(string id,long chartId=0,int subwindow=0):FreeFormGraphicalObject(OBJ_BITMAP_LABEL,id,chartId,subwindow) {}

   bool              setAnchor(ENUM_ANCHOR_POINT value) {return setInteger(OBJPROP_ANCHOR,value);}
   ENUM_ANCHOR_POINT getAnchor() const {return(ENUM_ANCHOR_POINT)getInteger(OBJPROP_ANCHOR);}

   bool              setXOffset(int value) {return setInteger(OBJPROP_XOFFSET,value);}
   bool              setYOffset(int value) {return setInteger(OBJPROP_YOFFSET,value);}
   bool              setImageOn(string path) {return setString(OBJPROP_BMPFILE,0,path);}
   bool              setImageOff(string path) {return setString(OBJPROP_BMPFILE,1,path);}
  };
//+------------------------------------------------------------------+
//| OBJ_EDIT                                                         |
//+------------------------------------------------------------------+
class Edit: public FreeFormGraphicalObject
  {
public:
                     Edit(string id,long chartId=0,int subwindow=0):FreeFormGraphicalObject(OBJ_EDIT,id,chartId,subwindow) {}

   bool              setAlign(ENUM_ALIGN_MODE value) {return setInteger(OBJPROP_ALIGN,value);}
   bool              setReadOnly(bool value) {return setInteger(OBJPROP_READONLY,value);}

   bool              setBackgroundColor(color value) {return setInteger(OBJPROP_BGCOLOR,value);}
   color             getBackgroundColor() const {return color(getInteger(OBJPROP_BGCOLOR));}
   bool              setBorderColor(color value) {return setInteger(OBJPROP_BORDER_COLOR,value);}
   color             getBorderColor() const {return color(getInteger(OBJPROP_BORDER_COLOR));}
  };
//+------------------------------------------------------------------+
//| OBJ_BUTTON                                                       |
//+------------------------------------------------------------------+
class Button: public FreeFormGraphicalObject
  {
public:
                     Button(string id,long chartId=0,int subwindow=0):FreeFormGraphicalObject(OBJ_BUTTON,id,chartId,subwindow) {}

   bool              isPressed() const {return bool(getInteger(OBJPROP_STATE));}
   bool              setPressed(bool value) { return setInteger(OBJPROP_STATE,value);}

   bool              setBackgroundColor(color value) {return setInteger(OBJPROP_BGCOLOR,value);}
   color             getBackgroundColor() const {return color(getInteger(OBJPROP_BGCOLOR));}
   bool              setBorderColor(color value) {return setInteger(OBJPROP_BORDER_COLOR,value);}
   color             getBorderColor() const {return color(getInteger(OBJPROP_BORDER_COLOR));}
  };
//+------------------------------------------------------------------+
