module check;

import opencl : CL_SUCCESS, cl_int;

/// print opencl device info
void printDeviceInfo(cl_device_id device)
{
    cl_ulong len;

    // print str info
    static foreach (s; ["CL_DEVICE_NAME", "CL_DEVICE_VERSION", "CL_DRIVER_VERSION", "CL_DEVICE_OPENCL_C_VERSION"])
    {
        {
            mixin("enum d = " ~ s ~ ";");
            // print device name
            clGetDeviceInfo(device, d, 0, null, &len);
            auto cs = new char[len];
            clGetDeviceInfo(device, d, len, cs.ptr, null);
            writeln(s, ": ", cs);
        }
    }

    // print size info
    static foreach (s; ["CL_DEVICE_MAX_CLOCK_FREQUENCY", "CL_DEVICE_MAX_COMPUTE_UNITS", "CL_DEVICE_MAX_WORK_ITEM_DIMENSIONS", "CL_DEVICE_GLOBAL_MEM_SIZE", "CL_DEVICE_LOCAL_MEM_SIZE", "CL_DEVICE_MAX_CONSTANT_BUFFER_SIZE", "CL_DEVICE_MAX_MEM_ALLOC_SIZE"])
    {
        {
            mixin("enum d = " ~ s ~ ";");
            clGetDeviceInfo(device, d, len.sizeof, &len, null);
            writeln(s, ": ", len);
        }
    }
}

/// assert opencl error and print where it was raised
auto checkCl(
    alias f,
    string file = __FILE__,
    size_t line = __LINE__,
    Args ...
)(auto return ref Args args)
{
    import std.format : format;
    import std.functional : forward;
    enum msg = format!"error at line: %d, file: %s"(line, file);
    static if (__traits(compiles, f(args)))
    {
        auto err = f(forward!args);
        assert(err == CL_SUCCESS, msg);
    }
    else
    {
        cl_int err;
        scope (exit) assert(err == CL_SUCCESS, msg);
        return f(forward!args, &err);
    }
}
