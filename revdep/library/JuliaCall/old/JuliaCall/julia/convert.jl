import RCall.sexp
import RCall.rcopy
import RCall: RClass, rcopytype

## Julia Tuple will be convert to S3 class JuliaTuple based on R list

function sexp(x ::Tuple)
    r = sexp(Array{Any}([x...]))
    setattrib!(r, :class, sexp("JuliaTuple"))
    r
end

function rcopy(::Type{Tuple}, x::Ptr{VecSxp})
    Tuple(rcopy(Array, x))
end

rcopytype(::Type{RClass{:JuliaTuple}}, x::Ptr{VecSxp}) = Tuple
