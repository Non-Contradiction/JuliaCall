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

rep(x, times) = repmat(vcat(x), times)

function assign!(x :: AbstractArray, value :: AbstractArray, i)
    try
        setindex!(x, value, i)
    catch e
        commontype = promote_type(eltype(x), eltype(value))
        x = AbstractArray{commontype}(x)
        setindex!(x, value, i)
    end
end

function assign!(x :: AbstractArray, value, i)
    try
        setindex!(x, value, i)
    catch e
        commontype = promote_type(eltype(x), typeof(value))
        x = AbstractArray{commontype}(x)
        setindex!(x, value, i)
    end
end

## Array related dispatching methods

isMatrix(x :: AbstractArray) = length(size(x)) == 2
isMatrix(x) = false

isArray(x :: AbstractArray) = true
isArray(x) = false

dim(x) = vcat(size(x)...)
