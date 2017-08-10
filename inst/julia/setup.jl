# gc_enable(false)

# Pkg.update()

if Pkg.installed("RCall") == nothing Pkg.add("RCall") end

using RCall

function transfer_list(x)
    rcopy(RObject(Ptr{RCall.VecSxp}(x)))
end

function transfer_string(x)
    rcopy(RObject(Ptr{RCall.StrSxp}(x)))
end

function error_msg(e, bt)
    m = IOBuffer()
    showerror(m, e, bt)
    seek(m, 0)
    readstring(m)
end

function Rerror(fname, e, bt)
    s1 = join(["Error happens when you try to call function " fname " in Julia.\n"])
    s2 = error_msg(e, bt)
    s = join([s1 s2])
    rcall(:simpleError, s)
end

function wrap(name, x)
    fname = transfer_string(name);
    try
        f = eval(parse(fname));
        xx = transfer_list(x);
        RObject(f(xx...)).p;
    catch e
        Rerror(fname, e, catch_stacktrace()).p;
    end;
end

function wrap_no_ret(name, x)
    fname = transfer_string(name);
    try
        f = eval(parse(fname));
        xx = transfer_list(x);
        f(xx...);
        RObject(nothing).p;
    catch e
        Rerror(fname, e, catch_stacktrace()).p;
    end;
end

function exists(x)
    isdefined(Symbol(x))
end

function eval_string(x)
    eval(parse(x))
end

function installed_package(pkg_name)
    string(Pkg.installed(pkg_name))
end
