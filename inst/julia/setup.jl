module JuliaCall

# gc_enable(false)

# Pkg.update()

# if Pkg.installed("RCall") == nothing Pkg.add("RCall") end

using Suppressor

@suppress begin
    using RCall
end

include("REPLhook.jl")
include("incomplete_console.jl")

function transfer_list(x)
    rcopy(RObject(Ptr{RCall.VecSxp}(x)))
end

function transfer_string(x)
    rcopy(RObject(Ptr{RCall.StrSxp}(x)))
end

function transfer_logical(x)
    rcopy(RObject(Ptr{RCall.LglSxp}(x)))
end

function error_msg(e)
    m = IOBuffer()
    showerror(m, e)
    seek(m, 0)
    readstring(m)
end

function error_msg(e, bt)
    m = IOBuffer()
    showerror(m, e, bt)
    seek(m, 0)
    readstring(m)
end

function Rerror(fname, e, bt)
    s1 = join(["Error happens when you try to call function " fname " in Julia.\n"])
    if string(VERSION) < "0.6.0"
        s2 = error_msg(e)
    else
        s2 = error_msg(e, bt)
    end
    s = join([s1 s2])
    rcall(:simpleError, s)
end

function docall(name, x, need_return1)
    fname = transfer_string(name);
    need_return = transfer_logical(need_return1);
    try
        f = eval(Main, parse(fname));
        xx = transfer_list(x);
        r = f(xx...);
        if need_return
            RObject(r).p;
        else
            RObject(nothing).p;
        end;
    catch e
        Rerror(fname, e, catch_stacktrace()).p;
    end;
end

function exists(x)
    isdefined(Symbol(x))
end

function eval_string(x)
    eval(Main, parse(x))
end

function installed_package(pkg_name)
    string(Pkg.installed(pkg_name))
end

function help(fname)
    string(eval_string(join(["@doc " fname])))
end

function assign(name, x)
    eval(Main, Expr(:(=), Symbol(name), x))
end

end
