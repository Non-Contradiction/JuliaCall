library(JuliaCall)
julia_setup()

mandelbrot <- function(c, iterate_max = 500){
    z <- 0.0
    for (i in 1:iterate_max) {
        z <- z ^ 2 + c
        if (abs(z) > 2) {
            return(i)
        }
    }
    iterate_max
}

mandelbrotImage <- function(xs, ys, iterate_max = 500){
    sapply(ys, function(y) sapply(xs, function(x) mandelbrot(x + y * 1i, iterate_max = iterate_max))) / iterate_max
}

iterate_max <- 1000L
centerx <- 0.37522 #0.3750001200618655
centery <- -0.22 #-0.2166393884377127
step <- 0.0000005
size <- 500
xs <- seq(-step * size, step * size, step) + centerx
ys <- seq(-step * size, step * size, step) + centery

# R code is so slow, I'd rather not run it on my laptop repetitively.
# invisible(mandelbrotImage(xs, ys, 2L))
# system.time(zR <- mandelbrotImage(xs, ys, iterate_max))
# image(xs, ys, zR, col = topo.colors(12))

## Use Julia implementation through JuliaCall

if (!julia_exists("mandelbrot")) {
    julia_source("./example/mandelbrot/mandebrot.jl")
}
# warm up for julia function
invisible(julia_call("mandelbrotImage", xs, ys, 2L))
system.time(zJL <- julia_call("mandelbrotImage", xs, ys, iterate_max))
image(xs, ys, zJL, col = topo.colors(12))
