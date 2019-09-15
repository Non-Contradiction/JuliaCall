using .Arrow
import RCall.sexp
import RCall.rcopy
import RCall: RClass, rcopytype

## Julia Tuple will be convert to S3 class JuliaTuple based on R list

function sexp(x ::Primitive)
    sexp(x[:])
end

const Ras_vector = R"function(x) x[['as_vector']]()"

function rcopy(::Type{Primitive}, x::Ptr{EnvSxp})
    rcopy(RCall.rcall_p(Ras_vector, x))
end

rcopytype(::Type{RClass{Symbol("arrow::Array")}}, x::Ptr{EnvSxp}) = Primitive
