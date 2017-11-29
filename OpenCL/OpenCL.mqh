//+------------------------------------------------------------------+
//|                                                       OpenCL.mqh |
//|                                          Copyright 2016, Li Ding |
//|                                            dingmaotu@hotmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Li Ding"
#property link      "dingmaotu@hotmail.com"
#property strict

#include "../Lang/Mql.mqh"
#include "Definitions.mqh"

#import "OpenCL.dll"
// Platform API
cl_int
clGetPlatformIDs(cl_uint,
                 cl_platform_id,
                 cl_uint &num_platforms) CL_API_SUFFIX__VERSION_1_0;
cl_int
clGetPlatformIDs(cl_int num_entries,
                 cl_platform_id &p_platform_ids[],
                 cl_uint) CL_API_SUFFIX__VERSION_1_0;
cl_int
clGetPlatformInfo(cl_platform_id   platform,
                  cl_platform_info param_name,
                  size_t           param_value_size,
                  char            &param_value[],
                  intptr_t) CL_API_SUFFIX__VERSION_1_0;
cl_int
clGetPlatformInfo(cl_platform_id   platform,
                  cl_platform_info param_name,
                  size_t           param_value_size,
                  intptr_t,
                  size_t          &param_value_size_ret) CL_API_SUFFIX__VERSION_1_0;
// Device APIs
cl_int
clGetDeviceIDs(cl_platform_id   platform,
               cl_device_type   device_type,
               cl_uint          num_entries,
               intptr_t,
               cl_uint         &num_devices) CL_API_SUFFIX__VERSION_1_0;
cl_int
clGetDeviceIDs(cl_platform_id   platform,
               cl_device_type   device_type,
               cl_uint          num_entries,
               cl_device_id    &devices[],
               intptr_t) CL_API_SUFFIX__VERSION_1_0;

cl_int
clGetDeviceInfo(cl_device_id device,
                cl_device_info  param_name,
                size_t param_value_size,
                char &param_value[],
                size_t &param_value_size_ret) CL_API_SUFFIX__VERSION_1_0;

cl_int
clCreateSubDevices(cl_device_id                          in_device,
                   const cl_device_partition_property   &properties[],
                   cl_uint                               num_devices,
                   cl_device_id                         &out_devices[],
                   cl_uint                              &num_devices_ret) CL_API_SUFFIX__VERSION_1_2;

cl_int
clRetainDevice(cl_device_id device) CL_API_SUFFIX__VERSION_1_2;

cl_int
clReleaseDevice(cl_device_id device) CL_API_SUFFIX__VERSION_1_2;

cl_int
clSetDefaultDeviceCommandQueue(cl_context           context,
                               cl_device_id         device,
                               cl_command_queue     command_queue) CL_API_SUFFIX__VERSION_2_1;

cl_int
clGetDeviceAndHostTimer(cl_device_id    device,
                        cl_ulong       &device_timestamp,
                        cl_ulong       &host_timestamp) CL_API_SUFFIX__VERSION_2_1;

cl_int
clGetHostTimer(cl_device_id device,
               cl_ulong    &host_timestamp) CL_API_SUFFIX__VERSION_2_1;

// Context APIs
cl_context
clCreateContext(intptr_t,
                cl_uint                      num_devices,
                const cl_device_id          &devices[],
                intptr_t,
                intptr_t,
                cl_int                      &errcode_ret) CL_API_SUFFIX__VERSION_1_0;

cl_context
clCreateContext(const cl_context_properties &properties[],
                cl_uint                      num_devices,
                const cl_device_id          &devices[],
                intptr_t,
                intptr_t,
                cl_int                      &errcode_ret) CL_API_SUFFIX__VERSION_1_0;

cl_context
clCreateContextFromType(const cl_context_properties &properties[],
                        cl_device_type               device_type,
                        intptr_t,
                        intptr_t,
                        cl_int                      &errcode_ret) CL_API_SUFFIX__VERSION_1_0;
cl_context
clCreateContextFromType(intptr_t,
                        cl_device_type               device_type,
                        intptr_t,
                        intptr_t,
                        cl_int                      &errcode_ret) CL_API_SUFFIX__VERSION_1_0;
cl_int
clRetainContext(cl_context context) CL_API_SUFFIX__VERSION_1_0;

cl_int
clReleaseContext(cl_context context) CL_API_SUFFIX__VERSION_1_0;

cl_int
clGetContextInfo(cl_context         context,
                 cl_context_info    param_name,
                 size_t             param_value_size,
                 intptr_t,
                 size_t            &param_value_size_ret) CL_API_SUFFIX__VERSION_1_0;
cl_int
clGetContextInfo(cl_context         context,
                 cl_context_info    param_name,
                 size_t             param_value_size,
                 cl_int            &param_value,
                 intptr_t) CL_API_SUFFIX__VERSION_1_0;

cl_int
clGetContextInfo(cl_context         context,
                 cl_context_info    param_name,
                 size_t             param_value_size,
                 cl_device_id      &param_value[],
                 intptr_t) CL_API_SUFFIX__VERSION_1_0;

cl_int
clGetContextInfo(cl_context             context,
                 cl_context_info        param_name,
                 size_t                 param_value_size,
                 cl_context_properties &param_value[],
                 intptr_t) CL_API_SUFFIX__VERSION_1_0;
/*
// Command Queue APIs
cl_command_queue
clCreateCommandQueueWithProperties(cl_context                context ,
                                   cl_device_id              device ,
                                   const cl_queue_properties   * properties ,
                                   cl_int                * errcode_ret ) CL_API_SUFFIX__VERSION_2_0;

cl_int
clRetainCommandQueue(cl_command_queue  command_queue ) CL_API_SUFFIX__VERSION_1_0;

cl_int
clReleaseCommandQueue(cl_command_queue  command_queue ) CL_API_SUFFIX__VERSION_1_0;

cl_int
clGetCommandQueueInfo(cl_command_queue       command_queue ,
                      cl_command_queue_info  param_name ,
                      size_t                 param_value_size ,
                      void               * param_value ,
                      size_t             * param_value_size_ret ) CL_API_SUFFIX__VERSION_1_0;

// Memory Object APIs
cl_mem
clCreateBuffer(cl_context    context ,
               cl_mem_flags  flags ,
               size_t        size ,
               void      * host_ptr ,
               cl_int    * errcode_ret ) CL_API_SUFFIX__VERSION_1_0;

cl_mem
clCreateSubBuffer(cl_mem                    buffer ,
                  cl_mem_flags              flags ,
                  cl_buffer_create_type     buffer_create_type ,
                  const void            * buffer_create_info ,
                  cl_int                * errcode_ret ) CL_API_SUFFIX__VERSION_1_1;

cl_mem
clCreateImage(cl_context               context ,
              cl_mem_flags             flags ,
              const cl_image_format* image_format ,
              const cl_image_desc  * image_desc ,
              void                 * host_ptr ,
              cl_int               * errcode_ret ) CL_API_SUFFIX__VERSION_1_2;

cl_mem
clCreatePipe(cl_context                  context ,
             cl_mem_flags                flags ,
             cl_uint                     pipe_packet_size ,
             cl_uint                     pipe_max_packets ,
             const cl_pipe_properties* properties ,
             cl_int                  * errcode_ret ) CL_API_SUFFIX__VERSION_2_0;

cl_int
clRetainMemObject(cl_mem  memobj ) CL_API_SUFFIX__VERSION_1_0;

cl_int
clReleaseMemObject(cl_mem  memobj ) CL_API_SUFFIX__VERSION_1_0;

cl_int
clGetSupportedImageFormats(cl_context            context ,
                           cl_mem_flags          flags ,
                           cl_mem_object_type    image_type ,
                           cl_uint               num_entries ,
                           cl_image_format   * image_formats ,
                           cl_uint           * num_image_formats ) CL_API_SUFFIX__VERSION_1_0;

cl_int
clGetMemObjectInfo(cl_mem            memobj ,
                   cl_mem_info       param_name ,
                   size_t            param_value_size ,
                   void          * param_value ,
                   size_t        * param_value_size_ret ) CL_API_SUFFIX__VERSION_1_0;

cl_int
clGetImageInfo(cl_mem            image ,
               cl_image_info     param_name ,
               size_t            param_value_size ,
               void          * param_value ,
               size_t        * param_value_size_ret ) CL_API_SUFFIX__VERSION_1_0;

cl_int
clGetPipeInfo(cl_mem            pipe ,
              cl_pipe_info      param_name ,
              size_t            param_value_size ,
              void          * param_value ,
              size_t        * param_value_size_ret ) CL_API_SUFFIX__VERSION_2_0;

cl_int
clSetMemObjectDestructorCallback(cl_mem  memobj ,
                                 void(CL_CALLBACK*pfn_notify)(cl_mem  memobj ,void *user_data),
                                 void*user_data ) CL_API_SUFFIX__VERSION_1_1;

// SVM Allocation APIs
void*
clSVMAlloc(cl_context        context ,
           cl_svm_mem_flags  flags ,
           size_t            size ,
           cl_uint           alignment ) CL_API_SUFFIX__VERSION_2_0;

void
clSVMFree(cl_context         context ,
          void           * svm_pointer ) CL_API_SUFFIX__VERSION_2_0;

// Sampler APIs
cl_sampler
clCreateSamplerWithProperties(cl_context                      context ,
                              const cl_sampler_properties * normalized_coords ,
                              cl_int                      * errcode_ret ) CL_API_SUFFIX__VERSION_2_0;

cl_int
clRetainSampler(cl_sampler  sampler ) CL_API_SUFFIX__VERSION_1_0;

cl_int
clReleaseSampler(cl_sampler  sampler ) CL_API_SUFFIX__VERSION_1_0;

cl_int
clGetSamplerInfo(cl_sampler          sampler ,
                 cl_sampler_info     param_name ,
                 size_t              param_value_size ,
                 void            * param_value ,
                 size_t          * param_value_size_ret ) CL_API_SUFFIX__VERSION_1_0;

// Program Object APIs
cl_program
clCreateProgramWithSource(cl_context         context ,
                          cl_uint            count ,
                          const char **      strings ,
                          const size_t   * lengths ,
                          cl_int         * errcode_ret ) CL_API_SUFFIX__VERSION_1_0;

cl_program
clCreateProgramWithBinary(cl_context                      context ,
                          cl_uint                         num_devices ,
                          const cl_device_id          * device_list ,
                          const size_t                * lengths ,
                          const unsigned char **          binaries ,
                          cl_int                      * binary_status ,
                          cl_int                      * errcode_ret ) CL_API_SUFFIX__VERSION_1_0;

cl_program
clCreateProgramWithBuiltInKernels(cl_context             context ,
                                  cl_uint                num_devices ,
                                  const cl_device_id * device_list ,
                                  const char         * kernel_names ,
                                  cl_int             * errcode_ret ) CL_API_SUFFIX__VERSION_1_2;

cl_program
clCreateProgramWithIL(cl_context     context ,
                      const void    * il ,
                      size_t          length ,
                      cl_int        * errcode_ret ) CL_API_SUFFIX__VERSION_2_1;

cl_int
clRetainProgram(cl_program  program ) CL_API_SUFFIX__VERSION_1_0;

cl_int
clReleaseProgram(cl_program  program ) CL_API_SUFFIX__VERSION_1_0;

cl_int
clBuildProgram(cl_program            program ,
               cl_uint               num_devices ,
               const cl_device_id* device_list ,
               const char        * options ,
               void(CL_CALLBACK * pfn_notify )(cl_program  program ,void* user_data ),
               void              * user_data ) CL_API_SUFFIX__VERSION_1_0;

cl_int
clCompileProgram(cl_program            program ,
                 cl_uint               num_devices ,
                 const cl_device_id* device_list ,
                 const char        * options ,
                 cl_uint               num_input_headers ,
                 const cl_program  * input_headers ,
                 const char **         header_include_names ,
                 void(CL_CALLBACK * pfn_notify )(cl_program  program ,void* user_data ),
                 void              * user_data ) CL_API_SUFFIX__VERSION_1_2;

cl_program
clLinkProgram(cl_context            context ,
              cl_uint               num_devices ,
              const cl_device_id* device_list ,
              const char        * options ,
              cl_uint               num_input_programs ,
              const cl_program  * input_programs ,
              void(CL_CALLBACK * pfn_notify )(cl_program  program ,void* user_data ),
              void              * user_data ,
              cl_int            * errcode_ret ) CL_API_SUFFIX__VERSION_1_2;

cl_int
clUnloadPlatformCompiler(cl_platform_id  platform ) CL_API_SUFFIX__VERSION_1_2;

cl_int
clGetProgramInfo(cl_program          program ,
                 cl_program_info     param_name ,
                 size_t              param_value_size ,
                 void            * param_value ,
                 size_t          * param_value_size_ret ) CL_API_SUFFIX__VERSION_1_0;

cl_int
clGetProgramBuildInfo(cl_program             program ,
                      cl_device_id           device ,
                      cl_program_build_info  param_name ,
                      size_t                 param_value_size ,
                      void               * param_value ,
                      size_t             * param_value_size_ret ) CL_API_SUFFIX__VERSION_1_0;

// Kernel Object APIs
cl_kernel
clCreateKernel(cl_program       program ,
               const char   * kernel_name ,
               cl_int       * errcode_ret ) CL_API_SUFFIX__VERSION_1_0;

cl_int
clCreateKernelsInProgram(cl_program      program ,
                         cl_uint         num_kernels ,
                         cl_kernel   * kernels ,
                         cl_uint     * num_kernels_ret ) CL_API_SUFFIX__VERSION_1_0;

cl_kernel
clCloneKernel(cl_kernel      source_kernel ,
              cl_int       * errcode_ret ) CL_API_SUFFIX__VERSION_2_1;

cl_int
clRetainKernel(cl_kernel     kernel ) CL_API_SUFFIX__VERSION_1_0;

cl_int
clReleaseKernel(cl_kernel    kernel ) CL_API_SUFFIX__VERSION_1_0;

cl_int
clSetKernelArg(cl_kernel     kernel ,
               cl_uint       arg_index ,
               size_t        arg_size ,
               const void* arg_value ) CL_API_SUFFIX__VERSION_1_0;

cl_int
clSetKernelArgSVMPointer(cl_kernel     kernel ,
                         cl_uint       arg_index ,
                         const void* arg_value ) CL_API_SUFFIX__VERSION_2_0;

cl_int
clSetKernelExecInfo(cl_kernel             kernel ,
                    cl_kernel_exec_info   param_name ,
                    size_t                param_value_size ,
                    const void        * param_value ) CL_API_SUFFIX__VERSION_2_0;

cl_int
clGetKernelInfo(cl_kernel        kernel ,
                cl_kernel_info   param_name ,
                size_t           param_value_size ,
                void         * param_value ,
                size_t       * param_value_size_ret ) CL_API_SUFFIX__VERSION_1_0;

cl_int
clGetKernelArgInfo(cl_kernel        kernel ,
                   cl_uint          arg_indx ,
                   cl_kernel_arg_info   param_name ,
                   size_t           param_value_size ,
                   void         * param_value ,
                   size_t       * param_value_size_ret ) CL_API_SUFFIX__VERSION_1_2;

cl_int
clGetKernelWorkGroupInfo(cl_kernel                   kernel ,
                         cl_device_id                device ,
                         cl_kernel_work_group_info   param_name ,
                         size_t                      param_value_size ,
                         void                    * param_value ,
                         size_t                  * param_value_size_ret ) CL_API_SUFFIX__VERSION_1_0;

cl_int
clGetKernelSubGroupInfo(cl_kernel                    kernel ,
                        cl_device_id                 device ,
                        cl_kernel_sub_group_info     param_name ,
                        size_t                       input_value_size ,
                        const void                 *input_value ,
                        size_t                       param_value_size ,
                        void                       * param_value ,
                        size_t                     * param_value_size_ret ) CL_API_SUFFIX__VERSION_2_1;

// Event Object APIs
cl_int
clWaitForEvents(cl_uint              num_events ,
                const cl_event   * event_list ) CL_API_SUFFIX__VERSION_1_0;

cl_int
clGetEventInfo(cl_event          event ,
               cl_event_info     param_name ,
               size_t            param_value_size ,
               void          * param_value ,
               size_t        * param_value_size_ret ) CL_API_SUFFIX__VERSION_1_0;

cl_event
clCreateUserEvent(cl_context     context ,
                  cl_int     * errcode_ret ) CL_API_SUFFIX__VERSION_1_1;

cl_int
clRetainEvent(cl_event  event ) CL_API_SUFFIX__VERSION_1_0;

cl_int
clReleaseEvent(cl_event  event ) CL_API_SUFFIX__VERSION_1_0;

cl_int
clSetUserEventStatus(cl_event    event ,
                     cl_int      execution_status ) CL_API_SUFFIX__VERSION_1_1;

cl_int
clSetEventCallback(cl_event     event ,
                   cl_int       command_exec_callback_type ,
                   void(CL_CALLBACK* pfn_notify )(cl_event,cl_int,void *),
                   void     * user_data ) CL_API_SUFFIX__VERSION_1_1;

// Profiling APIs
cl_int
clGetEventProfilingInfo(cl_event             event ,
                        cl_profiling_info    param_name ,
                        size_t               param_value_size ,
                        void             * param_value ,
                        size_t           * param_value_size_ret ) CL_API_SUFFIX__VERSION_1_0;

// Flush and Finish APIs
cl_int
clFlush(cl_command_queue  command_queue ) CL_API_SUFFIX__VERSION_1_0;

cl_int
clFinish(cl_command_queue  command_queue ) CL_API_SUFFIX__VERSION_1_0;

// Enqueued Commands APIs
cl_int
clEnqueueReadBuffer(cl_command_queue     command_queue ,
                    cl_mem               buffer ,
                    cl_bool              blocking_read ,
                    size_t               offset ,
                    size_t               size ,
                    void             * ptr ,
                    cl_uint              num_events_in_wait_list ,
                    const cl_event   * event_wait_list ,
                    cl_event         * event ) CL_API_SUFFIX__VERSION_1_0;

cl_int
clEnqueueReadBufferRect(cl_command_queue     command_queue ,
                        cl_mem               buffer ,
                        cl_bool              blocking_read ,
                        const size_t     * buffer_offset ,
                        const size_t     * host_offset ,
                        const size_t     * region ,
                        size_t               buffer_row_pitch ,
                        size_t               buffer_slice_pitch ,
                        size_t               host_row_pitch ,
                        size_t               host_slice_pitch ,
                        void             * ptr ,
                        cl_uint              num_events_in_wait_list ,
                        const cl_event   * event_wait_list ,
                        cl_event         * event ) CL_API_SUFFIX__VERSION_1_1;

cl_int
clEnqueueWriteBuffer(cl_command_queue    command_queue ,
                     cl_mem              buffer ,
                     cl_bool             blocking_write ,
                     size_t              offset ,
                     size_t              size ,
                     const void      * ptr ,
                     cl_uint             num_events_in_wait_list ,
                     const cl_event  * event_wait_list ,
                     cl_event        * event ) CL_API_SUFFIX__VERSION_1_0;

cl_int
clEnqueueWriteBufferRect(cl_command_queue     command_queue ,
                         cl_mem               buffer ,
                         cl_bool              blocking_write ,
                         const size_t     * buffer_offset ,
                         const size_t     * host_offset ,
                         const size_t     * region ,
                         size_t               buffer_row_pitch ,
                         size_t               buffer_slice_pitch ,
                         size_t               host_row_pitch ,
                         size_t               host_slice_pitch ,
                         const void       * ptr ,
                         cl_uint              num_events_in_wait_list ,
                         const cl_event   * event_wait_list ,
                         cl_event         * event ) CL_API_SUFFIX__VERSION_1_1;

cl_int
clEnqueueFillBuffer(cl_command_queue    command_queue ,
                    cl_mem              buffer ,
                    const void      * pattern ,
                    size_t              pattern_size ,
                    size_t              offset ,
                    size_t              size ,
                    cl_uint             num_events_in_wait_list ,
                    const cl_event  * event_wait_list ,
                    cl_event        * event ) CL_API_SUFFIX__VERSION_1_2;

cl_int
clEnqueueCopyBuffer(cl_command_queue     command_queue ,
                    cl_mem               src_buffer ,
                    cl_mem               dst_buffer ,
                    size_t               src_offset ,
                    size_t               dst_offset ,
                    size_t               size ,
                    cl_uint              num_events_in_wait_list ,
                    const cl_event   * event_wait_list ,
                    cl_event         * event ) CL_API_SUFFIX__VERSION_1_0;

cl_int
clEnqueueCopyBufferRect(cl_command_queue     command_queue ,
                        cl_mem               src_buffer ,
                        cl_mem               dst_buffer ,
                        const size_t     * src_origin ,
                        const size_t     * dst_origin ,
                        const size_t     * region ,
                        size_t               src_row_pitch ,
                        size_t               src_slice_pitch ,
                        size_t               dst_row_pitch ,
                        size_t               dst_slice_pitch ,
                        cl_uint              num_events_in_wait_list ,
                        const cl_event   * event_wait_list ,
                        cl_event         * event ) CL_API_SUFFIX__VERSION_1_1;

cl_int
clEnqueueReadImage(cl_command_queue      command_queue ,
                   cl_mem                image ,
                   cl_bool               blocking_read ,
                   const size_t      * origin[3] ,
                   const size_t      * region[3] ,
                   size_t                row_pitch ,
                   size_t                slice_pitch ,
                   void              * ptr ,
                   cl_uint               num_events_in_wait_list ,
                   const cl_event    * event_wait_list ,
                   cl_event          * event ) CL_API_SUFFIX__VERSION_1_0;

cl_int
clEnqueueWriteImage(cl_command_queue     command_queue ,
                    cl_mem               image ,
                    cl_bool              blocking_write ,
                    const size_t     * origin[3] ,
                    const size_t     * region[3] ,
                    size_t               input_row_pitch ,
                    size_t               input_slice_pitch ,
                    const void       * ptr ,
                    cl_uint              num_events_in_wait_list ,
                    const cl_event   * event_wait_list ,
                    cl_event         * event ) CL_API_SUFFIX__VERSION_1_0;

cl_int
clEnqueueFillImage(cl_command_queue    command_queue ,
                   cl_mem              image ,
                   const void      * fill_color ,
                   const size_t    * origin[3] ,
                   const size_t    * region[3] ,
                   cl_uint             num_events_in_wait_list ,
                   const cl_event  * event_wait_list ,
                   cl_event        * event ) CL_API_SUFFIX__VERSION_1_2;

cl_int
clEnqueueCopyImage(cl_command_queue      command_queue ,
                   cl_mem                src_image ,
                   cl_mem                dst_image ,
                   const size_t      * src_origin[3] ,
                   const size_t      * dst_origin[3] ,
                   const size_t      * region[3] ,
                   cl_uint               num_events_in_wait_list ,
                   const cl_event    * event_wait_list ,
                   cl_event          * event ) CL_API_SUFFIX__VERSION_1_0;

cl_int
clEnqueueCopyImageToBuffer(cl_command_queue  command_queue ,
                           cl_mem            src_image ,
                           cl_mem            dst_buffer ,
                           const size_t  * src_origin[3] ,
                           const size_t  * region[3] ,
                           size_t            dst_offset ,
                           cl_uint           num_events_in_wait_list ,
                           const cl_event* event_wait_list ,
                           cl_event      * event ) CL_API_SUFFIX__VERSION_1_0;

cl_int
clEnqueueCopyBufferToImage(cl_command_queue  command_queue ,
                           cl_mem            src_buffer ,
                           cl_mem            dst_image ,
                           size_t            src_offset ,
                           const size_t  * dst_origin[3] ,
                           const size_t  * region[3] ,
                           cl_uint           num_events_in_wait_list ,
                           const cl_event* event_wait_list ,
                           cl_event      * event ) CL_API_SUFFIX__VERSION_1_0;

void*
clEnqueueMapBuffer(cl_command_queue  command_queue ,
                   cl_mem            buffer ,
                   cl_bool           blocking_map ,
                   cl_map_flags      map_flags ,
                   size_t            offset ,
                   size_t            size ,
                   cl_uint           num_events_in_wait_list ,
                   const cl_event* event_wait_list ,
                   cl_event      * event ,
                   cl_int        * errcode_ret ) CL_API_SUFFIX__VERSION_1_0;

void*
clEnqueueMapImage(cl_command_queue   command_queue ,
                  cl_mem             image ,
                  cl_bool            blocking_map ,
                  cl_map_flags       map_flags ,
                  const size_t   * origin[3] ,
                  const size_t   * region[3] ,
                  size_t         * image_row_pitch ,
                  size_t         * image_slice_pitch ,
                  cl_uint            num_events_in_wait_list ,
                  const cl_event * event_wait_list ,
                  cl_event       * event ,
                  cl_int         * errcode_ret ) CL_API_SUFFIX__VERSION_1_0;

cl_int
clEnqueueUnmapMemObject(cl_command_queue  command_queue ,
                        cl_mem            memobj ,
                        void          * mapped_ptr ,
                        cl_uint           num_events_in_wait_list ,
                        const cl_event * event_wait_list ,
                        cl_event       * event ) CL_API_SUFFIX__VERSION_1_0;

cl_int
clEnqueueMigrateMemObjects(cl_command_queue        command_queue ,
                           cl_uint                 num_mem_objects ,
                           const cl_mem        * mem_objects ,
                           cl_mem_migration_flags  flags ,
                           cl_uint                 num_events_in_wait_list ,
                           const cl_event      * event_wait_list ,
                           cl_event            * event ) CL_API_SUFFIX__VERSION_1_2;

cl_int
clEnqueueNDRangeKernel(cl_command_queue  command_queue ,
                       cl_kernel         kernel ,
                       cl_uint           work_dim ,
                       const size_t  * global_work_offset ,
                       const size_t  * global_work_size ,
                       const size_t  * local_work_size ,
                       cl_uint           num_events_in_wait_list ,
                       const cl_event* event_wait_list ,
                       cl_event      * event ) CL_API_SUFFIX__VERSION_1_0;

cl_int
clEnqueueNativeKernel(cl_command_queue   command_queue ,
                      void(CL_CALLBACK*user_func)(void *),
                      void           * args ,
                      size_t             cb_args ,
                      cl_uint            num_mem_objects ,
                      const cl_mem   * mem_list ,
                      const void **      args_mem_loc ,
                      cl_uint            num_events_in_wait_list ,
                      const cl_event * event_wait_list ,
                      cl_event       * event ) CL_API_SUFFIX__VERSION_1_0;

cl_int
clEnqueueMarkerWithWaitList(cl_command_queue   command_queue ,
                            cl_uint            num_events_in_wait_list ,
                            const cl_event * event_wait_list ,
                            cl_event       * event ) CL_API_SUFFIX__VERSION_1_2;

cl_int
clEnqueueBarrierWithWaitList(cl_command_queue   command_queue ,
                             cl_uint            num_events_in_wait_list ,
                             const cl_event * event_wait_list ,
                             cl_event       * event ) CL_API_SUFFIX__VERSION_1_2;

cl_int
clEnqueueSVMFree(cl_command_queue   command_queue ,
                 cl_uint            num_svm_pointers ,
                 void *[] svm_pointers[] ,
                 void(CL_CALLBACK*pfn_free_func)(cl_command_queue  queue ,
                 cl_uint           num_svm_pointers ,
                 void *[] svm_pointers[] ,
                 void          * user_data ),
                 void           * user_data ,
                 cl_uint            num_events_in_wait_list ,
                 const cl_event * event_wait_list ,
                 cl_event       * event ) CL_API_SUFFIX__VERSION_2_0;

cl_int
clEnqueueSVMMemcpy(cl_command_queue   command_queue ,
                   cl_bool            blocking_copy ,
                   void           * dst_ptr ,
                   const void     * src_ptr ,
                   size_t             size ,
                   cl_uint            num_events_in_wait_list ,
                   const cl_event * event_wait_list ,
                   cl_event       * event ) CL_API_SUFFIX__VERSION_2_0;

cl_int
clEnqueueSVMMemFill(cl_command_queue   command_queue ,
                    void           * svm_ptr ,
                    const void     * pattern ,
                    size_t             pattern_size ,
                    size_t             size ,
                    cl_uint            num_events_in_wait_list ,
                    const cl_event * event_wait_list ,
                    cl_event       * event ) CL_API_SUFFIX__VERSION_2_0;

cl_int
clEnqueueSVMMap(cl_command_queue   command_queue ,
                cl_bool            blocking_map ,
                cl_map_flags       flags ,
                void           * svm_ptr ,
                size_t             size ,
                cl_uint            num_events_in_wait_list ,
                const cl_event * event_wait_list ,
                cl_event       * event ) CL_API_SUFFIX__VERSION_2_0;

cl_int
clEnqueueSVMUnmap(cl_command_queue   command_queue ,
                  void           * svm_ptr ,
                  cl_uint            num_events_in_wait_list ,
                  const cl_event * event_wait_list ,
                  cl_event       * event ) CL_API_SUFFIX__VERSION_2_0;

cl_int
clEnqueueSVMMigrateMem(cl_command_queue          command_queue ,
                       cl_uint                   num_svm_pointers ,
                       const void **             svm_pointers ,
                       const size_t          * sizes ,
                       cl_mem_migration_flags    flags ,
                       cl_uint                   num_events_in_wait_list ,
                       const cl_event        * event_wait_list ,
                       cl_event              * event ) CL_API_SUFFIX__VERSION_2_1;

// Extension function access
//
// Returns the extension function address for the given function name,
// or NULL if a valid function can not be found.  The client must
// check to make sure the address is not NULL, before using or 
// calling the returned function address.
void*
clGetExtensionFunctionAddressForPlatform(cl_platform_id  platform ,
                                         const char  * func_name ) CL_API_SUFFIX__VERSION_1_2;

// Deprecated OpenCL 1.1 APIs
CL_EXT_PREFIX__VERSION_1_1_DEPRECATED cl_mem
clCreateImage2D(cl_context               context,
                cl_mem_flags             flags,
                const cl_image_format *image_format,
                size_t                   image_width,
                size_t                   image_height,
                size_t                   image_row_pitch,
                void                *host_ptr,
                cl_int              *errcode_ret) CL_EXT_SUFFIX__VERSION_1_1_DEPRECATED;

CL_EXT_PREFIX__VERSION_1_1_DEPRECATED cl_mem
clCreateImage3D(cl_context               context,
                cl_mem_flags             flags,
                const cl_image_format *image_format,
                size_t                   image_width,
                size_t                   image_height,
                size_t                   image_depth,
                size_t                   image_row_pitch,
                size_t                   image_slice_pitch,
                void                *host_ptr,
                cl_int              *errcode_ret) CL_EXT_SUFFIX__VERSION_1_1_DEPRECATED;

CL_EXT_PREFIX__VERSION_1_1_DEPRECATED cl_int
clEnqueueMarker(cl_command_queue     command_queue,
                cl_event        *event) CL_EXT_SUFFIX__VERSION_1_1_DEPRECATED;

CL_EXT_PREFIX__VERSION_1_1_DEPRECATED cl_int
clEnqueueWaitForEvents(cl_command_queue  command_queue,
                       cl_uint           num_events,
                       const cl_event *event_list) CL_EXT_SUFFIX__VERSION_1_1_DEPRECATED;

CL_EXT_PREFIX__VERSION_1_1_DEPRECATED cl_int
clEnqueueBarrier(cl_command_queue  command_queue) CL_EXT_SUFFIX__VERSION_1_1_DEPRECATED;

CL_EXT_PREFIX__VERSION_1_1_DEPRECATED cl_int
clUnloadCompiler(void) CL_EXT_SUFFIX__VERSION_1_1_DEPRECATED;

CL_EXT_PREFIX__VERSION_1_1_DEPRECATED void*
clGetExtensionFunctionAddress(const char *func_name) CL_EXT_SUFFIX__VERSION_1_1_DEPRECATED;

// Deprecated OpenCL 2.0 APIs
CL_EXT_PREFIX__VERSION_1_2_DEPRECATED cl_command_queue
clCreateCommandQueue(cl_context                      context,
                     cl_device_id                    device,
                     cl_command_queue_properties     properties,
                     cl_int                     *errcode_ret) CL_EXT_SUFFIX__VERSION_1_2_DEPRECATED;

CL_EXT_PREFIX__VERSION_1_2_DEPRECATED cl_sampler
clCreateSampler(cl_context           context,
                cl_bool              normalized_coords,
                cl_addressing_mode   addressing_mode,
                cl_filter_mode       filter_mode,
                cl_int          *errcode_ret) CL_EXT_SUFFIX__VERSION_1_2_DEPRECATED;

CL_EXT_PREFIX__VERSION_1_2_DEPRECATED cl_int
clEnqueueTask(cl_command_queue   command_queue,
              cl_kernel          kernel,
              cl_uint            num_events_in_wait_list,
              const cl_event*event_wait_list,
              cl_event      *event) CL_EXT_SUFFIX__VERSION_1_2_DEPRECATED;
*/
#import
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CLPlatform
  {
private:
   cl_platform_id    m_pids[];
   int               m_current;
   bool              m_valid;
public:
                     CLPlatform();
                    ~CLPlatform() {ArrayFree(m_pids);}

   bool              isValid() const {return m_valid;}
   int               count() const {return ArraySize(m_pids);}
   bool              select(int i) {if(i<ArraySize(m_pids) && i>=0) { m_current=i;return true;} else {return false;}}
   cl_platform_id    operator[](int i) const {return m_pids[i];}
   cl_platform_id    current() const {return m_pids[m_current];}

   string            getInfo(cl_platform_info info) const;

   string            getName() const {return getInfo(CL_PLATFORM_NAME);}
   string            getVersion() const {return getInfo(CL_PLATFORM_VERSION);}
   string            getProfile() const {return getInfo(CL_PLATFORM_PROFILE);}
   string            getVendor() const {return getInfo(CL_PLATFORM_VENDOR);}
   string            getExtensions() const {return getInfo(CL_PLATFORM_EXTENSIONS);}

   int               getDeviceCount(cl_device_type type=CL_DEVICE_TYPE_ALL) const;
   bool              getDevices(cl_device_id &devices[],cl_device_type type=CL_DEVICE_TYPE_ALL) const;
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CLPlatform::CLPlatform()
   :m_current(0),m_valid(false)
  {
   int num_platforms;
   if(clGetPlatformIDs(0,0,num_platforms)==CL_SUCCESS)
     {
      if(num_platforms==0) return;
      Debug(StringFormat("There are %d platforms found.",num_platforms));
      ArrayResize(m_pids,num_platforms);
      if(clGetPlatformIDs(num_platforms,m_pids,0)==CL_SUCCESS)
        {
         m_valid=true;
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string CLPlatform::getInfo(cl_platform_info info) const
  {
   size_t ret=-1;
   if(clGetPlatformInfo(current(),info,0,0,ret)!=CL_SUCCESS) {return NULL;}

   char buf[];
   ArrayResize(buf,(int)ret);
   if(clGetPlatformInfo(current(),info,ret,buf,0)!=CL_SUCCESS) {return NULL;}
   string res=StringFromUtf8(buf);
   return res;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CLPlatform::getDeviceCount(cl_device_type type) const
  {
   int ret=-1;
   if(clGetDeviceIDs(m_pids[m_current],type,0,0,ret)!=CL_SUCCESS) return NULL;
   return ret;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CLPlatform::getDevices(cl_device_id &devices[],cl_device_type type) const
  {
   int deviceCount=getDeviceCount(type);
   ArrayResize(devices,deviceCount);
   if(clGetDeviceIDs(current(),type,deviceCount,devices,0)!=CL_SUCCESS) return false;
   else return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CLContext
  {
private:
   bool              m_valid;
   cl_context        m_context;

protected:
   int               getInfoSizeInBytes(cl_context_info name) const;
   void              initContext(CLPlatform &platform,cl_device_type type);
public:
                     CLContext(CLPlatform &platform,const cl_device_id &devices[]);
                     CLContext(CLPlatform &platform,cl_device_type type=CL_DEVICE_TYPE_GPU);
                     CLContext(cl_device_type type=CL_DEVICE_TYPE_GPU);
                    ~CLContext() {release();}

   bool              isValid() const {return m_valid;}
   bool              release() {return clReleaseContext(m_context)==CL_SUCCESS;}
   bool              retain() {return clRetainContext(m_context)==CL_SUCCESS;}

   cl_uint           getReferenceCount() const;
   cl_uint           getDeviceCount() const;
   bool              getDevices(cl_device_id &devices[]) const;
   bool              getProperties(cl_context_properties &properties[]) const;
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CLContext::CLContext(CLPlatform &platform,const cl_device_id &devices[])
   :m_valid(false)
  {
   if(!platform.isValid()) return;
   cl_context_properties properties[3];
   properties[0] = CL_CONTEXT_PLATFORM;
   properties[1] = platform.current();
   properties[2] = 0;
   cl_int ret=-1;
   cl_uint deviceCount=ArraySize(devices);
   m_context=clCreateContext(properties,deviceCount,devices,0,0,ret);

   Debug(StringFormat("Return code of context creation is %d",ret));
   if(ret != CL_SUCCESS) return;
   else m_valid=true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CLContext::initContext(CLPlatform &platform,cl_device_type type)
  {
   if(!platform.isValid()) return;
   cl_context_properties properties[3];
   properties[0] = CL_CONTEXT_PLATFORM;
   properties[1] = platform.current();
   properties[2] = 0;
   cl_int ret=-1;
   m_context = clCreateContextFromType(properties, type, 0,0, ret);
   Debug(StringFormat("Return code of context creation is %d",ret));
   if(ret != CL_SUCCESS) return;
   else m_valid=true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CLContext::CLContext(CLPlatform &platform,cl_device_type type)
   :m_valid(false)
  {
   initContext(platform,type);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CLContext::CLContext(cl_device_type type)
   :m_valid(false)
  {
   CLPlatform platform;
   initContext(platform,type);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CLContext::getInfoSizeInBytes(cl_context_info name) const
  {
   int ret=-1;
   if(clGetContextInfo(m_context,name,0,0,ret)!=CL_SUCCESS) return NULL;
   return ret;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
cl_uint CLContext::getReferenceCount() const
  {
   cl_int res;
   if(clGetContextInfo(m_context,CL_CONTEXT_REFERENCE_COUNT,sizeof(cl_int),res,0)!=CL_SUCCESS) return NULL;
   return res;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
cl_uint CLContext::getDeviceCount() const
  {
   cl_int res;
   if(clGetContextInfo(m_context,CL_CONTEXT_NUM_DEVICES,sizeof(cl_int),res,0)!=CL_SUCCESS) return NULL;
   return res;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CLContext::getDevices(cl_device_id &devices[]) const
  {
   int size=getInfoSizeInBytes(CL_CONTEXT_DEVICES);
   ArrayResize(devices,size/sizeof(cl_device_id));
   if(clGetContextInfo(m_context,CL_CONTEXT_DEVICES,size,devices,0)!=CL_SUCCESS) return false;
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CLContext::getProperties(cl_context_properties &properties[]) const
  {
   int size=getInfoSizeInBytes(CL_CONTEXT_PROPERTIES);
   ArrayResize(properties,size/sizeof(cl_device_id));
   if(clGetContextInfo(m_context,CL_CONTEXT_PROPERTIES,size,properties,0)!=CL_SUCCESS) return false;
   return true;
  }
//+------------------------------------------------------------------+
