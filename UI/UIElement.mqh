//+------------------------------------------------------------------+
//|                                                 UI/UIElement.mqh |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Li Ding"
#property link      "dingmaotu@hotmail.com"
#property strict

#include "../Lang/String.mqh"
#include "../Collection/Set.mqh"
//+------------------------------------------------------------------+
//| Form a heirarchy for elements                                    |
//+------------------------------------------------------------------+
class UIElement: public Set<UIElement*>
  {
private:
   UIElement        *m_parent;
   string            m_name;
public:
                     UIElement(UIElement *parent,string name)
   :m_parent(parent),m_name(m_parent==NULL?name:m_parent.getName()+"."+name){}
 
   string            getName() const {return m_name;}
   UIElement        *getParent() const {return m_parent;}

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
   string search=prefix?(getName()+"."+name):name;

   for(Iter<UIElement*>it(this); !it.end(); it.next())
     {
      UIElement *e=it.current();
      if(e.getName()==search)
        {
         result=e;
         break;
        }
      else if(recursive && e.size()>0)
        {
         UIElement *r=e.findByName(name,true,false);
         if(CheckPointer(r)!=POINTER_INVALID)
           {
            result=r;
            break;
           }
        }
     }
   return result;
  }
//+------------------------------------------------------------------+
