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
    reval("JuliaCall:::JuliaObjectFromId")(x.id.i)
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

function rcopy(::Type{JuliaObject}, x::Ptr{S4Sxp})
    try
        julia_object_stack[rcopy(Int32, x[:id])]
    catch e
        nothing
    end
end

import RCall: RClass, rcopytype

rcopytype(::Type{RClass{:JuliaObject}}, x::Ptr{S4Sxp}) = JuliaObject

## Regarding to issue #12, #13 and #16,
## we should use JuliaObject for general AbstractArray
@suppress begin
    sexp{T}(x :: AbstractArray{T}) = sexp(JuliaObject(x))
end

## AbstractArray{Any} should be converted to R List
sexp(x :: AbstractArray{Any}) = sexp(VecSxp, x)

## Preserve BigFloat precision,
## as the design decision in issue #16
# sexp(x::AbstractArray{BigFloat}) = sexp(JuliaObject(x))
# sexp(x::BigFloat) = sexp(JuliaObject(x))
