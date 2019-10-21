cummax1(x) = accumulate(max, x)
cummax1(x :: Number) = cummax1([x])

cummin1(x) = accumulate(min, x)
cummin1(x :: Number) = cummin1([x])

cumsum1(x) = cumsum(x)
cumsum1(x :: Number) = cumsum1([x])

cumprod1(x) = cumprod(x)
cumprod1(x :: Number) = cumprod1([x])

tanpi(x) = sinpi(x) / cospi(x)

unlist(x) = vcat(x...)

rep(x, times) = @static if julia07 repeat(vcat(x), times) else repmat(vcat(x), times) end

function another_setindex!(x, value :: AbstractArray, i...)
    x[i...] .= value
    x
end

function another_setindex!(x, value, i...)
    if all(isa.([i...], Number))
        setindex!(x, value, i...)
    else
        x[i...] .= value
        x
    end
end

function assign!(x :: AbstractArray{T}, value :: AbstractArray{T}, i) where {T}
    another_setindex!(x, value, i)
end

function assign!(x :: AbstractArray{T}, value :: AbstractArray, i) where {T}
    commontype = promote_type(eltype(x), eltype(value))
    if T == commontype
        another_setindex!(x, value, i)
    else
        x = AbstractArray{commontype}(x)
        another_setindex!(x, value, i)
    end
end

function assign!(x :: AbstractArray{T}, value :: T, i...) where {T}
    another_setindex!(x, value, i...)
end

function assign!(x :: AbstractArray{T}, value, i...) where {T}
    commontype = promote_type(eltype(x), typeof(value))
    if T == commontype
        another_setindex!(x, value, i...)
    else
        x = AbstractArray{commontype}(x)
        another_setindex!(x, value, i...)
    end
end

function assign!(x, value, i)
    if length(x) == 1 && i == 1
        value
    else
        warn("Assignment for JuliaObject fails.")
        x
    end
end

## Array related dispatching methods

isMatrix(x :: AbstractArray) = length(size(x)) == 2
isMatrix(x) = false

isArray(x :: AbstractArray) = true
isArray(x) = false

dim(x) = vcat(size(x)...)

Rmax(xs...) = maximum((maximum(x) for x in xs))

function Jc(xs...)
    if length(xs) > 1
        vcat((_Jc(x) for x in xs)...)
    else
        xs[1]
    end
end

function Jc(x :: AbstractArray)
    vec(x)
end

function _Jc(x :: AbstractArray)
    vec(x)
end

function _Jc(x)
    [x]
end
