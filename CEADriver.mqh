//+------------------------------------------------------------------+
//|                                                    CEADriver.mqh |
//|                                          Copyright 2014, Li Ding |
//|                                             http://dingmaotu.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, Li Ding"
#property link      "http://dingmaotu.com"
#property strict

#include <LiDing/CBaseEA.mqh>
//+------------------------------------------------------------------+
//| A collection of EAs                                              |
//+------------------------------------------------------------------+
class CEADriver
  {
private:
   int               m_num;
   CBaseEA          *m_first;

protected:
   CBaseEA          *Detach(CBaseEA*);
public:
                     CEADriver(void);
                    ~CEADriver(void);

   void              Add(CBaseEA*);
   void              Remove(CBaseEA*);

   int               Count(void) const {return m_num;}

   void              CloseAllOrders();
   void              Tick(void);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CEADriver::CEADriver(void)
   :m_num(0)
  {
   m_first=NULL;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CEADriver::~CEADriver(void)
  {
   CBaseEA *t;
   while((t=Detach(m_first))!=NULL)
     {
      delete t;
     }
  }
//+------------------------------------------------------------------+
//| Add an EA to the driver                                          |
//+------------------------------------------------------------------+
void CEADriver::Add(CBaseEA *e)
  {
   if(CheckPointer(e) == POINTER_INVALID) return;
   CBaseEA *t=m_first;

   if(m_first==NULL)
     {
      m_first=e;
      m_first.Prev(NULL);
      m_first.Next(NULL);
      m_num=1;
      return;
        } else {
      while(t.Next()!=NULL) {t=t.Next();}
      t.Next(e);
      e.Prev(t);
      e.Next(NULL);
      m_num++;
     }
  }
//+------------------------------------------------------------------+
//| Remove an EA from the driver                                     |
//+------------------------------------------------------------------+
void CEADriver::Remove(CBaseEA *e)
  {
   if(CheckPointer(e) == POINTER_INVALID) return;
   for(CBaseEA *t=m_first; t!=NULL; t=t.Next())
     {
      if(t==e)
        {
         Detach(e);
         break;
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CBaseEA *CEADriver::Detach(CBaseEA *e)
  {
   if(CheckPointer(e) == POINTER_INVALID) return NULL;
   if(e.Prev()!=NULL) {e.Prev().Next(e.Next());}
   if(e.Next()!=NULL) {e.Next().Prev(e.Prev());}
   if(e==m_first)
     {
      m_first=e.Next();
     }
   e.Prev(NULL);
   e.Next(NULL);
   return e;
   m_num--;
  }
//+------------------------------------------------------------------+
//| Invoke Tick of all EA                                            |
//+------------------------------------------------------------------+
void CEADriver::Tick(void)
  {
   for(CBaseEA *t=m_first; t!=NULL; t=t.Next())
     {
      t.Tick();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CEADriver::CloseAllOrders(void)
  {
   for(CBaseEA *t=m_first; t!=NULL; t=t.Next())
     {
      t.CloseAllOrders();
     }
  }
//+------------------------------------------------------------------+
