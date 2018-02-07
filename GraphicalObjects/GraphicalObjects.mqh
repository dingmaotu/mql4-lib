//+------------------------------------------------------------------+
//| Module: GraphicalObjects/GraphicalObjects.mqh                    |
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
//+------------------------------------------------------------------+
//| This class defines a scope of graphical objects                  |
//| Mainly used for counting and batch deletion of orders            |
//+------------------------------------------------------------------+
class GraphicalObjects
  {
private:
   const long        m_chartId;
   const int         m_subwindow;
   const int         m_type;
public:
                     GraphicalObjects(long chartId=0,int subwindow=-1,int type=-1):m_chartId(chartId),m_subwindow(subwindow),m_type(type) {}

   int               total() const {return ObjectsTotal(m_chartId,m_subwindow,m_type);}
   string            operator[](int i) const {return ObjectName(m_chartId,i,m_subwindow,m_type);}

   int               deleteByPrefix(string prefix) {return ObjectsDeleteAll(m_chartId,prefix,m_subwindow,m_type);}
   int               deleteAll() {return ObjectsDeleteAll(m_chartId,m_subwindow,m_type);}

   int               find(string id) {return ObjectFind(m_chartId,id);}
  };
//+------------------------------------------------------------------+
