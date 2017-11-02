import RCall.sexp
import Base.get!

type JuliaObjectID
    i :: Int32
end

function nextid(id :: JuliaObjectID)
    JuliaObjectID(id.i + 1)
end

type JuliaObjectContainer
    object_dict :: Dict{JuliaObjectID, Any}
    ind :: JuliaObjectID
end

function add!(container :: JuliaObjectContainer, x)
    container.ind = nextid(container.ind)
    container.object_dict[container.ind] = x
end

function get!(container :: JuliaObjectContainer, id :: JuliaObjectID)
    container.object_dict[id]
end

function get!(container :: JuliaObjectContainer, id)
    container.object_dict[JuliaObjectID(id)]
end

julia_object_stack = JuliaObjectContainer(Dict(), JuliaObjectID(0))

type JuliaObject
    id :: JuliaObjectID
    JuliaObject(id :: JuliaObjectID) = new(id)
end

function sexp(x :: JuliaObject)
    reval("JuliaCall:::JuliaObjectFromId")(x.id.i)
end

function new_obj(obj)
    add!(julia_object_stack, obj)
    JuliaObject(julia_object_stack.ind)
end

JuliaObject(x :: JuliaObject) = x
JuliaObject(x :: RObject) = new_obj(rcopy(x))
JuliaObject(x :: RCall.Sxp) = new_obj(RObject(x))
JuliaObject(x) = new_obj(x)

sexp(x) = sexp(JuliaObject(x))

import RCall.rcopy

function rcopy(::Type{JuliaObject}, x::Ptr{S4Sxp})
    try
        get!(julia_object_stack, rcopy(x[:id]))
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

function setfield1!(object, name, value1)
    value = fieldtype(typeof(object), name)(value1)
    setfield!(object, name, value)
end
