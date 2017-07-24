//+------------------------------------------------------------------+
//|                                                         Text.mqh |
//|                                                       hengzhe li |
//|                                           https://www.github.com |
//+------------------------------------------------------------------+
#property copyright "hengzhe li"
#property link      "https://www.github.com"
#property strict
#include "FreeFormElement.mqh"

class Text:public FreeFormElement
{
public:
       bool              setPrice(double price){return setDouble(OBJPROP_PRICE,price);}
       bool              setDatetime(datetime date){return setInteger(OBJPROP_TIME,date);}
Text(Panel *parent,string name,string text)
   :FreeFormElement(parent,name,OBJ_TEXT){
    setText(text);
   }
};