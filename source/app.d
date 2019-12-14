import std.stdio : writeln;

import opencl;
import check : checkCl;


void main()
{
    // init device
    cl_platform_id platform;
    cl_device_id device;
    checkCl!clGetPlatformIDs(1, &platform, null);
    checkCl!clGetDeviceIDs(platform, CL_DEVICE_TYPE_DEFAULT, 1, &device, null);
    auto context = checkCl!clCreateContext(null, 1, &device, null, null);
    scope (exit) checkCl!clReleaseContext(context);

    // compile
    auto source = q{
        __kernel void vectorAdd(__global float *a, __global float* b, __global float* c) {
            int i = get_global_id(0);
            c[i] = a[i] + b[i];
        }
    };
    const(char)* ptr = source.ptr;
    auto len = source.length;
    auto program = checkCl!clCreateProgramWithSource(context, 1, &ptr, &len);
    checkCl!clBuildProgram(program, 1, &device, null, null, null);
    scope (exit) checkCl!clReleaseProgram(program);
    auto name = "vectorAdd";
    auto kernel = checkCl!clCreateKernel(program, name.ptr);
    scope (exit) checkCl!clReleaseKernel(kernel);

    // setup data
    float[] ha = [1, 2, 3];
    float[] hb = [4, 5, 6];

    auto queue = checkCl!clCreateCommandQueue(context, device, 0);
    scope (exit)
    {
        checkCl!clFlush(queue);
        checkCl!clFinish(queue);
        checkCl!clReleaseCommandQueue(queue);
    }
    auto da = checkCl!clCreateBuffer(context, CL_MEM_READ_WRITE, float.sizeof * ha.length, null);
    scope (exit) checkCl!clReleaseMemObject(da);
    checkCl!clEnqueueWriteBuffer(queue, da, CL_TRUE, 0, float.sizeof * ha.length, ha.ptr, 0, null, null);
    auto db = checkCl!clCreateBuffer(context, CL_MEM_READ_WRITE, float.sizeof * hb.length, null);
    scope (exit) checkCl!clReleaseMemObject(db);
    checkCl!clEnqueueWriteBuffer(queue, db, CL_TRUE, 0, float.sizeof * hb.length, hb.ptr, 0, null, null);
    auto dc = checkCl!clCreateBuffer(context, CL_MEM_READ_WRITE, float.sizeof * hb.length, null);
    scope (exit) checkCl!clReleaseMemObject(dc);

    // launch
    auto globalWorkSize = ha.length;
    checkCl!clSetKernelArg(kernel, 0, cl_mem.sizeof, &da);
    checkCl!clSetKernelArg(kernel, 1, cl_mem.sizeof, &db);
    checkCl!clSetKernelArg(kernel, 2, cl_mem.sizeof, &dc);
    checkCl!clEnqueueNDRangeKernel(
        queue, kernel, 1, null, // this must be null
        &globalWorkSize, null, // auto localWorkSize
        0, null, null // no event config
    );

    // copy memory from device to host
    auto hc = new float[ha.length];
    checkCl!clEnqueueReadBuffer(queue, dc, CL_TRUE, 0, float.sizeof * hc.length, hc.ptr, 0, null, null);
    ha[] += hb[];
    assert(hc == ha);
    writeln("SUCEESS!!");
}
