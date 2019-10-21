function simple_call(fname, args...; kwargs...)
    try
        if endswith(fname, ".")
            fname = chop(fname);
            # f = eval(Main, parse(fname));
            f = funcfind(fname);
            r = broadcast(f, args...);
        else
            # f = eval(Main, parse(fname));
            f = funcfind(fname);
            r = f(args...; kwargs...);
        end
        sexp(r)
    catch e
        Rerror(e, stacktrace(catch_backtrace())).p;
    end;
end

# function simple_call(fname, arg1, arg2)
#     try
#         if endswith(fname, ".")
#             fname = chop(fname);
#             # f = eval(Main, parse(fname));
#             f = funcfind(fname);
#             r = broadcast(f, arg1, arg2);
#         else
#             # f = eval(Main, parse(fname));
#             f = funcfind(fname);
#             r = f(arg1, arg2);
#         end
#         RObject(r).p
#     catch e
#         Rerror(e, stacktrace(catch_backtrace())).p;
#     end;
# end
