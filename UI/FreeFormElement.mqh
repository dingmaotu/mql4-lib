//+------------------------------------------------------------------+
//|                                           UI/FreeFormElement.mqh |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Li Ding"
#property link      "dingmaotu@hotmail.com"
#property strict

#include "BaseElement.mqh"
//+------------------------------------------------------------------+
//| The following elements are not anchored to price/time            |
//|   OBJ_LABEL                                                      |
//|   OBJ_BUTTON                                                     |
//|   OBJ_BITMAP_LABEL                                               |
//|   OBJ_EDIT                                                       |
//|   OBJ_RECTANGLE_LABEL                                            |
//+------------------------------------------------------------------+
class FreeFormElement: public BaseElement
  {
protected:
   bool              createElement(ENUM_OBJECT type)
     {
      return ObjectCreate(m_root.getChartId(),getName(),type,m_root.getSubwindowIndex(), 0, 0);
     }
                     FreeFormElement(UIElement *parent,string name,ENUM_OBJECT type):BaseElement(parent,name){createElement(type);}
public:
                    ~FreeFormElement() {deleteSelf();}
   //--- Position and Shape
   bool              setCorner(ENUM_BASE_CORNER value) {return setInteger(OBJPROP_CORNER,value);}
   ENUM_BASE_CORNER  getCorner() const {return(ENUM_BASE_CORNER)getInteger(OBJPROP_CORNER);}

   virtual int       getX() const {return(int)getInteger(OBJPROP_XDISTANCE);}
   virtual bool      setX(int value) {return setInteger(OBJPROP_XDISTANCE,value);}
   virtual int       getY() const {return(int)getInteger(OBJPROP_YDISTANCE);}
   virtual bool      setY(int value) {return setInteger(OBJPROP_YDISTANCE,value);}

   int               getRelativeX() const {return getX()-getParent().getX();}
   int               getRelativeY() const {return getY()-getParent().getY();}
   bool              setRelativeX(int value) {return setX(getParent().getX()+value);}
   bool              setRelativeY(int value) {return setY(getParent().getY()+value);}

   bool              setPosition(int x,int y) {return setX(x) && setY(y);}
   bool              setRelativePosition(int x,int y) {return setRelativeX(x) && setRelativeY(y);}
   bool              move(int dx,int dy) {return setX(getX()+dx) && setY(getY()+dy);}

   virtual int       getWidth() const {return(int)getInteger(OBJPROP_XSIZE);}
   virtual bool      setWidth(int value) {return setInteger(OBJPROP_XSIZE,value);}
   virtual int       getHeight() const {return(int)getInteger(OBJPROP_YSIZE);}
   virtual bool      setHeight(int value) {return setInteger(OBJPROP_YSIZE,value);}
   bool              setSize(int width,int height) {return setWidth(width) && setHeight(height);}
  };
//+------------------------------------------------------------------+
//| Parent for free form container elements                          |
//+------------------------------------------------------------------+
class Panel: public FreeFormElement
  {
public:
                     Panel(UIRoot *parent,string name,int x=-1,int y=-1,int w=-1,int h=-1);

                     Panel(Panel *parent,string name)
   :FreeFormElement(parent,name,OBJ_RECTANGLE_LABEL){}

   bool              setBackgroundColor(color value) {return setInteger(OBJPROP_BGCOLOR,value);}
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Panel::Panel(UIRoot *parent,string name,int x,int y,int w,int h)
   :FreeFormElement(parent,name,OBJ_RECTANGLE_LABEL)
  {
   if(x>=0) setX(x);
   if(y>=0) setY(y);
   if(w>=0) setWidth(w);
   if(h>=0) setHeight(h);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Label: public FreeFormElement
  {
public:
                     Label(Panel *parent,string name,string text)
   :FreeFormElement(parent,name,OBJ_LABEL)
     {
      setText(text);
     }
   bool              setWidth(int value) {return false;}  // read only, thus do nothing
   bool              setHeight(int value) {return false;}  // read only, thus do nothing

   //--- only to OBJ_LABEL: number of degrees to rotate
   bool              setAngle(double value) {return setDouble(OBJPROP_ANGLE,value);}
   double            getAngle() const {return getDouble(OBJPROP_ANGLE);}

   bool              setAnchor(ENUM_ANCHOR_POINT value) {return setInteger(OBJPROP_ANCHOR,value);}
   ENUM_ANCHOR_POINT getAnchor() const {return(ENUM_ANCHOR_POINT)getInteger(OBJPROP_ANCHOR);}
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Bitmap: public FreeFormElement
  {
public:
                     Bitmap(Panel *parent,string name)
   :FreeFormElement(parent,name,OBJ_BITMAP_LABEL)
     {}

   bool              setAnchor(ENUM_ANCHOR_POINT value) {return setInteger(OBJPROP_ANCHOR,value);}
   ENUM_ANCHOR_POINT getAnchor() const {return(ENUM_ANCHOR_POINT)getInteger(OBJPROP_ANCHOR);}

   bool              setXOffset(int value) {return setInteger(OBJPROP_XOFFSET,value);}
   bool              setYOffset(int value) {return setInteger(OBJPROP_YOFFSET,value);}
   bool              setImageOn(string path) {return setString(OBJPROP_BMPFILE,0,path);}
   bool              setImageOff(string path) {return setString(OBJPROP_BMPFILE,1,path);}
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Edit: public FreeFormElement
  {
public:
                     Edit(Panel *parent,string name,string text)
   :FreeFormElement(parent,name,OBJ_EDIT)
     {
      setText(text);
     }

   bool              setAlign(ENUM_ALIGN_MODE value) {return setInteger(OBJPROP_ALIGN,value);}
   bool              setReadOnly(bool value) {return setInteger(OBJPROP_READONLY,value?1:0);}

   bool              setBackgroundColor(color value) {return setInteger(OBJPROP_BGCOLOR,value);}
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Button: public FreeFormElement
  {
public:
                     Button(Panel *parent,string name,string text)
   :FreeFormElement(parent,name,OBJ_BUTTON)
     {
      setText(text);
     }

                     Button(Panel *parent,string name,string text,
                                              int x,int y,int high,int width,
                                              int frontColor=clrBlack,
                                              int bgColor=clrWhite)
   :FreeFormElement(parent,name,OBJ_BUTTON)
     {
      setText(text);
      setSize(width,high);
      setX(x);
      setY(y);
      setBackgroundColor(bgColor);
      setColor(frontColor);
      setInteger(OBJPROP_ZORDER,999);
     }

   bool              setBackgroundColor(color value) {return setInteger(OBJPROP_BGCOLOR,value);}
   bool              isClick() const {return getInteger(OBJPROP_STATE)==1;}
   bool              setBtnStatus(bool isPress) { return setInteger(OBJPROP_STATE,isPress);}
   bool              resetBtn() {return setInteger(OBJPROP_STATE,false);}
  };
//+------------------------------------------------------------------+
