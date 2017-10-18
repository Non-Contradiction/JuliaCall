import RCall.sexp

type JuliaArray
    x :: AbstractArray
end

function JuliaArrayWrapper(x, T)
    rcall(:structure, x, class = "JuliaArray", data = string(T))
end

sexp{T}(x :: Array{T}) = JuliaArrayWrapper(sexp(VecSxp, x), T)

import RCall.rcopy

function get_type(x)
    try
        eval(Main, parse(rcopy(getattrib(x, :data))))::Type
    catch e
        Any
    end
end

function rcopy(::Type{JuliaArray}, s::Ptr{VecSxp})
    Array{get_type(s)}(rcopy(Array{Any}, s))
end

import RCall: RClass, rcopytype

rcopytype(::Type{RClass{:JuliaArray}}, s::Ptr{VecSxp}) = JuliaArray
