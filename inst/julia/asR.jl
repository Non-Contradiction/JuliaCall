asDouble(x :: Real) = Float64(x)
asDouble(x :: AbstractString) = parse(Float64, x)
asDouble{T<:Real}(x :: AbstractArray{T}) = AbstractArray{Float64}(x)
asDouble{T<:AbstractString}(x :: AbstractArray{T}) = [asDouble(xx) for xx in x]

asCharacter(x) = string(x)
