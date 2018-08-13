import RCall.sexp
import Base.get

struct JuliaObjectID
    i :: Int32
end

function nextid(id :: JuliaObjectID)
    JuliaObjectID(id.i + 1)
end

JuliaObjectID() = JuliaObjectID(0)

struct JuliaObject
    id :: JuliaObjectID
    typ :: String
    JuliaObject(id :: JuliaObjectID, typ = "Regular") = new(id, typ)
end

function getPlainID(x :: JuliaObject)
    x.id.i
end

function getType(x :: JuliaObject)
    x.typ
end

mutable struct JuliaObjectContainer
    object_dict :: Dict{JuliaObjectID, Any}
    ind :: JuliaObjectID
end

JuliaObjectContainer() = JuliaObjectContainer(Dict(), JuliaObjectID())

function add!(container :: JuliaObjectContainer, x, typ = "Regular")
    container.ind = nextid(container.ind)
    container.object_dict[container.ind] = x
    JuliaObject(container.ind, typ)
end

# function remove!(container :: JuliaObjectContainer, id)
#     delete!(container.object_dict, id)
# end

function get(container :: JuliaObjectContainer, id :: JuliaObjectID)
    container.object_dict[id]
end

function get(container :: JuliaObjectContainer, id)
    container.object_dict[JuliaObjectID(id)]
end

## As long as the interface stays the same, the following code should be fine.
## The global JuliaObjectContainer julia_object_stack

const julia_object_stack = JuliaObjectContainer()

function new_obj(obj, typ = "Regular")
    add!(julia_object_stack, obj, typ)
end

# function rm_obj(id)
#     remove!(julia_object_stack, id)
# end

JuliaObject(x :: JuliaObject, typ = "Regular") = x
JuliaObject(x :: RObject, typ = "Regular") = new_obj(rcopy(x), typ)
JuliaObject(x :: RCall.Sxp, typ = "Regular") = new_obj(RObject(x), typ)
JuliaObject(x, typ = "Regular") = new_obj(x, typ)

## Conversion related to JuliaObject

const makeJuliaObjectInR = reval("JuliaCall:::juliaobject[['new']]")

function sexp(x :: JuliaObject)
    rcall(makeJuliaObjectInR, getPlainID(x), getType(x)).p
end

import RCall.rcopy

function rcopy(::Type{JuliaObject}, x::Ptr{EnvSxp})
    try
        # get(julia_object_stack, rcopy(Int32, RObject(x)[:getID]()))
        get(julia_object_stack, rcopy(Int32, RObject(x)[:id]))
    catch e
        nothing
    end
end

import RCall: RClass, rcopytype

rcopytype(::Type{RClass{:JuliaObject}}, x::Ptr{EnvSxp}) = JuliaObject

## Fallback conversions

@static if julia07
    import RCall.sexpclass
    sexpclass(x) = RClass{:JuliaObject}
    sexp(::Type{RClass{:JuliaObject}}, x) = sexp(JuliaObject(x))
else
    sexp(x) = sexp(JuliaObject(x))
end

## Regarding to issue #12, #13 and #16,
## we should use JuliaObject for general AbstractArray
@static if julia07
    @suppress_err begin
        JuliaCall.sexpclass(x :: AbstractArray{T}) where {T} = RClass{:JuliaObject}
    end

    ## AbstractArray{Any} should be converted to R List
    sexpclass(x :: AbstractArray{Any}) = RClass{:list}
else
    @suppress_err begin
        JuliaCall.sexp(x :: AbstractArray{T}) where {T} = sexp(JuliaObject(x))
    end

    ## AbstractArray{Any} should be converted to R List
    sexp(x :: AbstractArray{Any}) = sexp(VecSxp, x)
end

## Preserve BigFloat precision,
## as the design decision in issue #16
# sexp(x::AbstractArray{BigFloat}) = sexp(JuliaObject(x))
# sexp(x::BigFloat) = sexp(JuliaObject(x))

function setfield1!(object, name, value1)
    value = fieldtype(typeof(object), name)(value1)
    setfield!(object, name, value)
end
