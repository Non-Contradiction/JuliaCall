function simple_call(fname, arg)
    try
        if endswith(fname, ".")
            fname = chop(fname);
            # f = eval(Main, parse(fname));
            f = funcfind(fname);
            r = broadcast(f, arg);
        else
            # f = eval(Main, parse(fname));
            f = funcfind(fname);
            r = f(arg);
        end
        RObject(r).p
    catch e
        Rerror(e, catch_stacktrace()).p;
    end;
end

function simple_call(fname, arg1, arg2)
    try
        if endswith(fname, ".")
            fname = chop(fname);
            # f = eval(Main, parse(fname));
            f = funcfind(fname);
            r = broadcast(f, arg1, arg2);
        else
            # f = eval(Main, parse(fname));
            f = funcfind(fname);
            r = f(arg1, arg2);
        end
        RObject(r).p
    catch e
        Rerror(e, catch_stacktrace()).p;
    end;
end
