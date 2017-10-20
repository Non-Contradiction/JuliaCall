import RCall.sexp

julia_object_stack = []

type JuliaObjectID
    i :: Int32
end

type JuliaObject
    id :: JuliaObjectID
    JuliaObject(id :: JuliaObjectID) = new(id)
end

function sexp(x :: JuliaObject)
    r = sexp(x.id.i)
    setclass!(r, sexp("JuliaObject"))
    r
end

function new_obj(obj)
    push!(julia_object_stack, obj)
    JuliaObject(JuliaObjectID(Int32(length(julia_object_stack))))
end

JuliaObject(x :: JuliaObject) = x
JuliaObject(x :: RObject) = new_obj(rcopy(x))
JuliaObject(x :: RCall.Sxp) = new_obj(RObject(x))
JuliaObject(x) = new_obj(x)

sexp(x) = sexp(JuliaObject(x))

import RCall.rcopy

function rcopy(::Type{JuliaObject}, i::Ptr{IntSxp})
    julia_object_stack[rcopy(Int32, i)]
end

import RCall: RClass, rcopytype

rcopytype(::Type{RClass{:JuliaObject}}, s::Ptr{IntSxp}) = JuliaObject

## Regarding to issue #12, #13 and #16,
## we should use JuliaObject for general AbstractArray
@suppress begin
    sexp{T}(x :: AbstractArray{T}) = sexp(JuliaObject(x))
end

## Preserve BigFloat precision,
## as the design decision in issue #16
sexp(x::AbstractArray{BigFloat}) = sexp(JuliaObject(x))
sexp(x::BigFloat) = sexp(JuliaObject(x))
