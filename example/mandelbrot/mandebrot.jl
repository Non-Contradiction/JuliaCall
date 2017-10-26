function mandelbrot(c, iterate_max = 500)
    z = 0.0im
    for i in 1:iterate_max
        z = z ^ 2 + c
        if abs2(z) > 4.0
            return(i)
        end
    end
    iterate_max
end

function mandelbrotImage(xs, ys, iterate_max = 500)
    n = length(xs)
    p = length(ys)
    z = zeros(Float64, n, p)
    for i in 1:n
        for j in 1:p
            z[i, j] = mandelbrot(xs[i] + ys[j] * im, iterate_max) / iterate_max
        end
    end
    z
end
