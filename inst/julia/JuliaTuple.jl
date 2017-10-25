import RCall.sexp

function sexp(x ::Tuple)
    r = sexp(Array{Any}([x...]))
    setattrib!(r, :class, sexp("JuliaTuple"))
    r
end

import RCall.rcopy

function rcopy(::Type{Tuple}, x::Ptr{VecSxp})
    Tuple(rcopy(Array, x))
end

import RCall: RClass, rcopytype

rcopytype(::Type{RClass{:JuliaTuple}}, x::Ptr{VecSxp}) = Tuple
