//+------------------------------------------------------------------+
//| Module:      Lang/Hash.mqh                                       |
//| Description: Hash functions for builtin types                    |
//| Copyright:   Copyright 2017, Bear Two Technologies Co., Ltd.     |
//+------------------------------------------------------------------+
#property strict

#include "Integer.mqh"
#include "Pointer.mqh"

// uint32_t rotl32(uint32_t x,int8_t r)
#define	ROTL32(x,r)	((x << r) | (x >> (32 - r)))
//--- adapted from https://github.com/PeterScott/murmur3
//--- directly process utf-16 characters instead of bytes
uint MurmurHash3_x86_32(const ushort &data[],uint seed)
  {
   const int len=ArraySize(data);
   const int nblocks=len/2;
   uint h1=seed;

   uint c1 = 0xcc9e2d51;
   uint c2 = 0x1b873593;

// body
   for(int i=0; i<nblocks; i++)
     {
      // getblock
      uint k1=data[(i<<1)|1];
      k1<<=16;
      k1|=data[i<<1];

      k1*=c1;
      k1=ROTL32(k1,15);
      k1*=c2;

      h1^= k1;
      h1 = ROTL32(h1,13);
      h1 = h1*5+0xe6546b64;
     }

// tail
   if((len&1)==1)
     {
      uint k1=data[len-1];
      k1*=c1; k1=ROTL32(k1,15); k1*=c2; h1^=k1;
     }

// finalization
   h1^=(len<<1);

// fmix32
   h1 ^= h1 >> 16;
   h1 *= 0x85ebca6b;
   h1 ^= h1 >> 13;
   h1 *= 0xc2b2ae35;
   h1 ^= h1 >> 16;

   return h1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
uint MurmurHash3_x86_32_String(const string data,uint seed)
  {
   const int len=StringLen(data);
   const int nblocks=len/2;
   uint h1=seed;

   uint c1 = 0xcc9e2d51;
   uint c2 = 0x1b873593;

// body
   for(int i=0; i<nblocks; i++)
     {
      // getblock
      uint k1=StringGetCharacter(data,(i<<1)|1);
      k1<<=16;
      k1|=StringGetCharacter(data,i<<1);

      k1*=c1;
      k1=ROTL32(k1,15);
      k1*=c2;

      h1^= k1;
      h1 = ROTL32(h1,13);
      h1 = h1*5+0xe6546b64;
     }

// tail
   if((len&1)==1)
     {
      uint k1=StringGetCharacter(data,len-1);
      k1*=c1; k1=ROTL32(k1,15); k1*=c2; h1^=k1;
     }

// finalization
   h1^=(len<<1);

// fmix32
   h1 ^= h1 >> 16;
   h1 *= 0x85ebca6b;
   h1 ^= h1 >> 13;
   h1 *= 0xc2b2ae35;
   h1 ^= h1 >> 16;

   return h1;
  }
//+------------------------------------------------------------------+
//| Convert string to ushort array or directly use StringGetCharacter|
//| The performance is roughly the same, while the StringGetCharacter|
//| version is slightly better, it also reduces memory allaction     |
//+------------------------------------------------------------------+
int Hash(const string value)
  {
// ushort a[];
// StringToShortArray(value,a,0,StringLen(value));
   return (int)MurmurHash3_x86_32_String(value,0x7e34a273);
  }
//+------------------------------------------------------------------+
//| expand to int                                                    |
//+------------------------------------------------------------------+
int Hash(const char value)
  {
   return value;
  }
//+------------------------------------------------------------------+
//| expand to int                                                    |
//+------------------------------------------------------------------+
int Hash(const uchar value)
  {
   return value;
  }
//+------------------------------------------------------------------+
//| expand to int                                                    |
//+------------------------------------------------------------------+
int Hash(const short value)
  {
   return value;
  }
//+------------------------------------------------------------------+
//| expand to int                                                    |
//+------------------------------------------------------------------+
int Hash(const ushort value)
  {
   return value;
  }
//+------------------------------------------------------------------+
//| identity                                                         |
//+------------------------------------------------------------------+
int Hash(const int value)
  {
   return value;
  }
//+------------------------------------------------------------------+
//| same as int                                                      |
//+------------------------------------------------------------------+
int Hash(const uint value)
  {
   return (int)value;
  }
//+------------------------------------------------------------------+
//| long value compacted to int                                      |
//+------------------------------------------------------------------+
int Hash(const long value)
  {
   Print("Long hash");
   if(value==0 || value==-0)
     {
      return (0);
     }
   return (((int)((long)value)) ^ (int)(value >> 32));
  }
//+------------------------------------------------------------------+
//| long value compacted to int                                      |
//+------------------------------------------------------------------+
int Hash(const ulong value)
  {
   return (((int)((ulong)value)) ^ (int)(value >> 32));
  }
//+------------------------------------------------------------------+
//| float converted to int                                           |
//+------------------------------------------------------------------+
int Hash(const float value)
  {
   if(value==0.0f || value==-0.0f)
     {
      return (0);
     }
   Single s;
   s.value=value;
   return ((Int32)s).value;
  }
//+------------------------------------------------------------------+
//| double converted to long                                         |
//+------------------------------------------------------------------+
int Hash(const double value)
  {
   Print("Double hash");
   if(value==0.0 || value==-0.0f)
     {
      return (0);
     }
   Double s;
   s.value=value;
   return Hash(((Int64)s).value);
  }
//+------------------------------------------------------------------+
//| datetime is of same size with long                               |
//+------------------------------------------------------------------+
int Hash(const datetime value)
  {
   return Hash((long)value);
  }
//+------------------------------------------------------------------+
//| color is of same size with int                                   |
//+------------------------------------------------------------------+
int Hash(const color value)
  {
   return value;
  }
//+------------------------------------------------------------------+
//| Generic pointer hash                                             |
//+------------------------------------------------------------------+
template<typename T>
int Hash(T *value)
  {
   return GetAddress(value);
  }
//+------------------------------------------------------------------+
