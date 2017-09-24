import RCall.sexp

julia_object_count = 0
julia_object_dict = Dict()

type JuliaObject
    name :: String
    JuliaObject(name :: String) = new(name)
end

function sexp(x :: JuliaObject)
    r = sexp(x.name)
    setclass!(r, sexp("JuliaObject"))
    r
end

function new_obj(obj)
    global julia_object_count
    julia_object_count += 1
    name = String(Symbol(:J_, julia_object_count))
    julia_object_dict[name] = obj
    JuliaObject(name)
end

JuliaObject(x :: JuliaObject) = x
JuliaObject(x :: RObject) = new_obj(rcopy(x))
JuliaObject(x :: RCall.Sxp) = new_obj(RObject(x))
JuliaObject(x) = new_obj(x)

sexp(x) = sexp(JuliaObject(x))

import RCall.rcopy

function rcopy(::Type{JuliaObject}, s::Ptr{StrSxp})
    julia_object_dict[rcopy(String, s)]
end

import RCall: RClass, rcopytype

rcopytype(::Type{RClass{:JuliaObject}}, s::Ptr{StrSxp}) = JuliaObject
