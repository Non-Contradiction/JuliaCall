Base.load_juliarc()
module JuliaCall

# gc_enable(false)

# Pkg.update()

# if Pkg.installed("RCall") == nothing Pkg.add("RCall") end

using Suppressor

@suppress_err begin
    using RCall
end

include("./display/basic.jl")
include("./display/Rjulia.jl")
include("./display/IRjulia.jl")
include("./display/RmdJulia.jl")
include("./display/plotsViewer.jl")
include("REPLhook.jl")
include("incomplete_console.jl")
include("convert.jl")
include("JuliaObject.jl")
include("asR.jl")
include("dispatch.jl")

function transfer_list(x)
    rcopy(RObject(Ptr{RCall.VecSxp}(x)))
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

function Rerror(e, bt)
    s1 = join(["Error happens in Julia.\n"])
    s2 = error_msg(e, bt)
    s = join([s1 s2])
    rcall(:simpleError, s)
end

function docall(call1)
    try
        call = transfer_list(call1)
        fname = call[:fname];
        named_args = call[:named_args]
        unamed_args = call[:unamed_args]
        need_return = call[:need_return];
        show_value = call[:show_value];
        if endswith(fname, ".")
            fname = chop(fname);
            f = eval(Main, parse(fname));
            r = f.(unamed_args...);
        else
            f = eval(Main, parse(fname));
            r = f(unamed_args...; named_args...);
        end
        if show_value && r != nothing
            display(r)
        end
        proceed(basic_display_manager)
        if need_return == "R"
            RObject(r).p;
        elseif need_return == "Julia"
            RObject(JuliaObject(r)).p
        else
            RObject(nothing).p;
        end;
    catch e
        Rerror(e, catch_stacktrace()).p;
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

function str_typeof(x)
    string(typeof(x))
end

end
