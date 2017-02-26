//+------------------------------------------------------------------+
//|                                                  OpenCL/MQL5.mqh |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Li Ding"
#property link      "dingmaotu@hotmail.com"
#property strict
#property description "This module provides a compatibility layer for"
#property description "MQL5 OpenCL API"

#ifndef __MQL5BUILD__
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ENUM_OPENCL_PROPERTY_STRING
  {
   CL_PLATFORM_PROFILE,
   CL_PLATFORM_VERSION,
   CL_PLATFORM_VENDOR,
   CL_PLATFORM_EXTENSIONS,
   CL_DEVICE_NAME,
   CL_DEVICE_VENDOR,
   CL_DRIVER_VERSION,
   CL_DEVICE_PROFILE,
   CL_DEVICE_VERSION,
   CL_DEVICE_EXTENSIONS,
   CL_DEVICE_BUILT_IN_KERNELS,
   CL_DEVICE_OPENCL_C_VERSION
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ENUM_OPENCL_HANDLE_TYPE
  {
   OPENCL_INVALID,
   OPENCL_CONTEXT,
   OPENCL_PROGRAM,
   OPENCL_KERNEL,
   OPENCL_BUFFER
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ENUM_OPENCL_PROPERTY_INTEGER
  {
   CL_DEVICE_COUNT,
   CL_DEVICE_TYPE,
   CL_DEVICE_VENDOR_ID,
   CL_DEVICE_MAX_COMPUTE_UNITS,
   CL_DEVICE_MAX_CLOCK_FREQUENCY,
   CL_DEVICE_GLOBAL_MEM_SIZE,
   CL_DEVICE_LOCAL_MEM_SIZE,
   CL_BUFFER_SIZE
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ENUM_CL_DEVICE_TYPE
  {
   CL_DEVICE_ACCELERATOR,
   CL_DEVICE_CPU,
   CL_DEVICE_GPU,
   CL_DEVICE_DEFAULT,
   CL_DEVICE_CUSTOM
  };

#endif
//+------------------------------------------------------------------+
