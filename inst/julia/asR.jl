asDouble(x :: Real) = Float64(x)
asDouble(x :: AbstractString) = parse(Float64, x)
asDouble(true) = 1.0
asDouble(false) = 0.0
asDouble{T<:Real}(x :: AbstractArray{T}) = AbstractArray{Float64}(x)
asDouble{T<:AbstractString}(x :: AbstractArray{T}) = [asDouble(xx) for xx in x]
asDouble(x :: AbstractArray{Bool}) = [asDouble(xx) for xx in x]

asCharacter(x) = string(x)

asLogical(x :: Bool) = x
asLogical(x :: Number) = x != 0
asLogical("T") = true
asLogical("true") = true
asLogical("TRUE") = true
asLogical("True") = true
asLogical("F") = false
asLogical("false") = false
asLogical("FALSE") = false
asLogical("False") = false
asLogical(x :: AbstractArray{Bool}) = x
asLogical{T<:Number}(x :: AbstractArray{T}) = [asLogical(xx) for xx in x]
asLogical{T<:AbstractString}(x :: AbstractArray{T}) = [asLogical(xx) for xx in x]
