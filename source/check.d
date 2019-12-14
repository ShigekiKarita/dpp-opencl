module check;

import opencl : CL_SUCCESS, cl_int;


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
