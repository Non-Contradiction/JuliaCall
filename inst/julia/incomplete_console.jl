function completion(string)
    REPLCompletions.completions(string, length(string))[1]
end

function incomplete(string)
    e = Base.parse_input_line(string)
    isa(e,Expr) && e.head === :incomplete
end
