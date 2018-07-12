Base.load_juliarc()
module JuliaCall

# gc_enable(false)

# Pkg.update()

# if Pkg.installed("RCall") == nothing Pkg.add("RCall") end

using Suppressor

if !is_windows()
    @suppress_err begin
        @eval Base JULIA_HOME = joinpath(dirname(JULIA_HOME), "bin")
        @eval Base julia_cmd() = julia_cmd(joinpath(JULIA_HOME, julia_exename()))
    end
end

using RCall

const need_display = length(Base.Multimedia.displays) < 2

if need_display
    include("./display/basic.jl")
    include("./display/Rjulia.jl")
    include("./display/IRjulia.jl")
    include("./display/RmdJulia.jl")
    include("./display/plotsViewer.jl")
end
include("REPLhook.jl")
include("incomplete_console.jl")
include("convert.jl")
include("JuliaObject.jl")
include("asR.jl")
include("dispatch.jl")

function transfer_list(x)
    rcopy(RObject(Ptr{RCall.VecSxp}(x)))
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

# function _funcfind(n)
#     getfield(Main, Symbol(n))
# end
#
# function _funcfind(n1, n2)
#     getfield(getfield(Main, Symbol(n1)), Symbol(n2))
# end
#
# function _funcfind(n1, n2, n3)
#     getfield((getfield(Main, Symbol(n1)), Symbol(n2)), Symbol(n3))
# end
#
# function funcfind(name)
#     # r = Main
#     ns = split(name, ".")
#     _funcfind(ns...)
#     # for n in ns
#     #     r = getfield(r, Symbol(n))
#     # end
#     # r
# end

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
            # f = funcfind(fname);
            r = f.(unamed_args...);
        else
            f = eval(Main, parse(fname));
            # f = funcfind(fname);
            r = f(unamed_args...; named_args...);
        end
        if show_value && r != nothing
            display(r)
        end
        if need_display
            proceed(basic_display_manager)
        end
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

function show_string(x)
    buf = IOBuffer()
    show(IOContext(buf, :limit=>true), x)
    return String(take!(buf))
end

end
