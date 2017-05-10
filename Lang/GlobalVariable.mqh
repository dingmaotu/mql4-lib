//+------------------------------------------------------------------+
//|                                          Lang/GlobalVariable.mqh |
//|                                          Copyright 2017, Li Ding |
//|                                            dingmaotu@hotmail.com |
//+------------------------------------------------------------------+
#property strict
//+------------------------------------------------------------------+
//| Encapsulates global variable functions                           |
//+------------------------------------------------------------------+
class GlobalVariable
  {
public:
   static int        total() {return GlobalVariablesTotal();}
   static string     name(int index) {return GlobalVariableName(index);}
   static void       flush() {GlobalVariablesFlush();}

   static bool       exists(string name) {return GlobalVariableCheck(name);}
   static datetime   lastAccess(string name) {return GlobalVariableTime(name);}

   static bool       makeTemp(string name) {return GlobalVariableTemp(name);}
   static double     get(string name) {return GlobalVariableGet(name);}
   static bool       get(string name,double &value) {return GlobalVariableGet(name,value);}
   static bool       set(string name,double value) {return GlobalVariableSet(name,value);}
   static bool       setOn(string name,double value,double check) {return GlobalVariableSetOnCondition(name,value,check);}

   static bool       remove(string name) {return GlobalVariableDel(name);}
   static bool       removeAll(string prefix=NULL,datetime before=0) {return GlobalVariablesDeleteAll(prefix,before);}
  };
//+------------------------------------------------------------------+
//| TempVar is a variable whose life time is the same as the program |
//+------------------------------------------------------------------+
class TempVar
  {
private:
   string            m_name;
   bool              m_owned;
public:
                     TempVar(string name,bool create=false):m_name(name),m_owned(create)
     {
      if(create)
        {
         GlobalVariable::makeTemp(name);
        }
     }
                    ~TempVar() {if(m_owned && isValid()) {GlobalVariable::remove(m_name);}}

   bool              isValid() const {return GlobalVariable::exists(m_name);}
   string            getName() const {return m_name;}
   bool              set(double value) {return GlobalVariable::set(m_name,value);}
   double            get() const {return GlobalVariable::get(m_name);}
   bool              setOn(double value,double check) {return GlobalVariable::setOn(m_name,value,check);}
   datetime          lastAccess() const {return GlobalVariable::lastAccess(m_name);}
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class AtomicVar: public TempVar
  {
public:
                     AtomicVar(string name,long initial,bool create=false):TempVar(name,create)
     {
      set(initial);
     }
   long              increment(long by=1);
   long              decrement(long by=1) {return increment(-by);}
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
long AtomicVar::increment(long by)
  {
   bool success=false;
   long value;
   do
     {
      value=(long)get();
      success=setOn(value+by,value);
     }
   while(!success);
   return (value+by);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Semaphore
  {
private:
   TempVar           m_var;
public:
                     Semaphore(string name,long initial=0);
   bool              isValid() const {return m_var.isValid();}
   bool              acquire();
   void              release();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Semaphore::Semaphore(string name,long initial)
   :m_var(name,initial!=0)
  {
   if(initial!=0)
     {
      m_var.set(initial);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Semaphore::acquire(void)
  {
   long value=(long)m_var.get();
   if(value == 0) return false;
   return m_var.setOn(value-1,value);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Semaphore::release(void)
  {
   bool success=false;
   do
     {
      long value=(long)m_var.get();
      success=m_var.setOn(value+1,value);
     }
   while(!success && !IsStopped());
  }
//+------------------------------------------------------------------+
