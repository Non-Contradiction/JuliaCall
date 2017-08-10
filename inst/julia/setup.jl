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

function wrap(name, x)
    fname = transfer_string(name);
    try
        f = eval(parse(fname));
        xx = transfer_list(x);
        RObject(f(xx...)).p;
    catch e
        println(join(["Error happens when you try to call function " fname " in Julia."]));
        showerror(STDOUT, e, catch_stacktrace());
        println();
        RObject(nothing).p;
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
        println(join(["Error happens when you try to call function " fname " in Julia."]));
        showerror(STDOUT, e, catch_stacktrace());
        println();
        RObject(nothing).p;
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
