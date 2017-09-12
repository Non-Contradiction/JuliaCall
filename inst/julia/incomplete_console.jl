function completion(string)
    Base.REPLCompletions.completions(string, length(string))[1]
end

function incomplete(string)
    e = Base.parse_input_line(string)
    isa(e,Expr) && e.head === :incomplete
end

function eval_and_print(x)
    value = eval(Main, parse(x))
    if !(value == nothing || Base.REPL.ends_with_semicolon(x))
        print(value)
        print("  \n")
    end
end
