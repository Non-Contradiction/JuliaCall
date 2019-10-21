import RCall.sexp

struct JuliaObject
    id :: Ptr{RCall.ExtPtrSxp}
    typ :: String
    JuliaObject(id :: Ptr{RCall.ExtPtrSxp}, typ = "Regular") = new(id, typ)
end

function getID(x :: JuliaObject)
    x.id
end

function getType(x :: JuliaObject)
    x.typ
end

function new_obj(obj, typ = "Regular")
    # wrap in a `Ref`
    refj = Ref(obj)
    jptr = pointer_from_objref(refj)
    s = RCall.makeExternalPtr(jptr)
    RCall.jtypExtPtrs[s] = refj
    RCall.registerCFinalizerEx(s)

    JuliaObject(s, typ)
end


## debugging for freeing
# function rm_obj(id)
#     RCall.decref_extptr(RCall.sexp(x))
# end

JuliaObject(x :: JuliaObject, typ = "Regular") = x
JuliaObject(x :: RObject, typ = "Regular") = new_obj(rcopy(x), typ)
JuliaObject(x :: RCall.Sxp, typ = "Regular") = new_obj(rcopy(x), typ)
JuliaObject(x, typ = "Regular") = new_obj(x, typ)

## Conversion related to JuliaObject

const makeJuliaObjectInR = reval("JuliaCall:::juliaobjectnew")

function sexp(x :: JuliaObject)
    RCall.rcall_p(makeJuliaObjectInR, getID(x), getType(x))
end

import RCall.rcopy

function rcopy(::Type{JuliaObject}, x::Ptr{EnvSxp})
    try
        # get(julia_object_stack, rcopy(Int32, RObject(x)[:getID]()))
        # get(julia_object_stack, rcopy(Int32, RObject(x)[:id]))
        RCall.jtypExtPtrs[RCall.sexp(x[:id])].x
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
