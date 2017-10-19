library(JuliaCall)
julia_setup()
julia_library("ForwardDiff")
f <- function(x) sum(x^2L)
julia_assign("ff", f)
julia_command("g = x -> ForwardDiff.gradient(ff, x);")
julia_command("g([2.0])")

lambertW <- function(x) {
    ## add the first line so the function could be accepted by ForwardDiff
    x <- x[1L]
    w0 <- 1
    w1 <- w0 - (w0*exp(w0)-x)/((w0+1)*exp(w0)-(w0+2)*(w0*exp(w0)-x)/(2*w0+2))
    while(w0 != w1) {
        w0 <- w1
        w1 <- w0 -
            (w0*exp(w0)-x)/((w0+1)*exp(w0)-(w0+2)*(w0*exp(w0)-x)/(2*w0+2))
    }
    return(w1)
}

julia_assign("lambertW", lambertW)
julia_command("gL = x -> ForwardDiff.gradient(lambertW, x);")
julia_command("gL([1.0])")

options(digits = 15)
julia_eval("gL([1.0])")

julia_command("ForwardDiff.hessian(lambertW, [1.0])")

library(adagio)
julia_assign("rosen", fnRosenbrock)
julia_command("gR = x -> ForwardDiff.gradient(rosen, x);")
## currently only support n >=3 is supported,
## because in the definition of fnRosenbrock, there is
## x1 <- x[2:n]
## x2 <- x[1:(n - 1)]
## if n==2, then x1 and x2 will be scalar, since R doesn't distinguish between
## scalar and atomic vector of length 1, the type conversion between R and julia
## in this case will be problematic.
julia_command("gR([1.0, 2.0, 1.0])")
julia_command("ForwardDiff.hessian(rosen, [1.0, 2.0, 1.0])")

## We could test the result by writing rosenbrock function directly in julia
## and calculate the derivative by ForwardDiff
julia_eval("function rosenjl(x) n = length(x);
    x1 = x[2:n]; x2 = x[1:(n - 1)]; sum(100 * (x1 - x2.^2).^2 + (1 - x2).^2) end")
julia_command("gRjl = x -> ForwardDiff.gradient(rosenjl, x);")
julia_command("gRjl([1.0, 2.0, 1.0])")
julia_command("ForwardDiff.hessian(rosenjl, [1.0, 2.0, 1.0])")
