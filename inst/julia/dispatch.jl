cummax1(x) = accumulate(max, x)
cummax1(x :: Number) = cummax1([x])

cummin1(x) = accumulate(min, x)
cummin1(x :: Number) = cummin1([x])

cumsum1(x) = cumsum(x)
cumsum1(x :: Number) = cumsum1([x])

cumprod1(x) = cumprod(x)
cumprod1(x :: Number) = cumprod1([x])

tanpi(x) = sinpi(x) / cospi(x)
