# since as.double is equivalent to as.numeric?
asDouble(x :: Real) = x
asDouble{T<:Real}(x :: AbstractArray{T}) = x
asDouble(x :: Integer) = float(x)
asDouble(x :: Complex) = asDouble(real(x))
asDouble(x :: AbstractString) = parse(Float64, x)
asDouble(x :: Bool) = ifelse(x, 1.0, 0.0)
asDouble(x :: AbstractArray) = [asDouble(xx) for xx in x]

asCharacter(x) = string(x)

asLogical(x :: Bool) = x
asLogical(x :: Number) = x != 0
asLogical(x :: AbstractString) = ifelse(x in ["T", "TRUE", "true", "True"], true, false)
asLogical(x :: AbstractArray{Bool}) = x
asLogical{T<:Number}(x :: AbstractArray{T}) = [asLogical(xx) for xx in x]
asLogical{T<:AbstractString}(x :: AbstractArray{T}) = [asLogical(xx) for xx in x]
