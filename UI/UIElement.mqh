//+------------------------------------------------------------------+
//|                                                 UI/UIElement.mqh |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Li Ding"
#property link      "dingmaotu@hotmail.com"
#property strict

#include "../Lang/String.mqh"
#include "../Collection/Array.mqh"
//+------------------------------------------------------------------+
//| Form a heirarchy for elements                                    |
//+------------------------------------------------------------------+
class UIElement
  {
private:
   UIElement        *m_parent;
   string            m_name;
   Array<UIElement*>m_children;
public:
                     UIElement(UIElement *parent,string name)
   :m_parent(parent),m_name(m_parent==NULL?name:m_parent.getName()+"."+name){}

   string            getName() const {return m_name;}
   UIElement        *getParent() const {return m_parent;}

   virtual void      addChild(UIElement *element) {m_children.insertAt(size(),element);}
   virtual void      removeChild(UIElement *element) {int i=m_children.index(element); if(i>=0){m_children.removeAt(i);}}
   virtual void      deleteChild(UIElement *element) {int i=m_children.index(element); if(i>=0){m_children.removeAt(i);SafeDelete(element);}}

   bool              exists(UIElement *element) const {return m_children.index(element);}

   //--- deconstruct children
   virtual void      deleteAll() {m_children.clear();}

   int               size() const {return m_children.size();}

   virtual UIElement *findByName(string name,bool recursive=false,bool prefix=true);

   //--- dimension
   virtual int       getX() const=0;
   virtual int       getY() const=0;
   virtual int       getWidth() const=0;
   virtual int       getHeight() const=0;

   //--- event
   virtual void      onEvent(const int id,// Event ID
                             const long& lparam,   // Parameter of type long event
                             const double& dparam, // Parameter of type double event
                             const string& sparam  // Parameter of type string events
                             )
     {}
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
UIElement *UIElement::findByName(string name,bool recursive,bool prefix)
  {
   UIElement *result=NULL;
   int size=m_children.size();
   string search=prefix?(getName()+"."+name):name;
   for(int i=0; i<size; i++)
     {
      if(m_children[i].getName()==search)
        {
         result=m_children[i];
         break;
        }
      else if(recursive)
        {
         UIElement *r=m_children[i].findByName(name,true,false);
         if(CheckPointer(r)!=NULL)
           {
            result=r;
            break;
           }
        }
     }
   return result;
  }
//+------------------------------------------------------------------+
