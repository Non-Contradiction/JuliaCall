context("Automatic Differentiation Test")

## The basic example of AD here should work if the JuliaObject S4 system and
## method dispatching system work correctly.

test_that("test of AD on basic functions", {
    skip_on_cran()
    julia <- julia_setup()

    julia_install_package_if_needed("ForwardDiff")
    julia_library("ForwardDiff")
    f <- function(x) sum(x^2L)
    julia_assign("ff", f)
    julia_command("g = x -> ForwardDiff.gradient(ff, x);")
    expect_equal(julia_eval("g([2.0])"), 4)
    expect_equal(julia_eval("g([2.0, 3.0])"), c(4, 6))
})

test_that("test of AD of lambertW function", {
    skip_on_cran()
    julia <- julia_setup()

    julia_install_package_if_needed("ForwardDiff")
    julia_library("ForwardDiff")

    lambertW <- function(x) {
        ## add the first line so the function could be accepted by ForwardDiff
        x <- x[1L]
        w0 <- 1
        w1 <- w0 - (w0*exp(w0)-x)/((w0+1)*exp(w0)-(w0+2)*(w0*exp(w0)-x)/(2*w0+2))
        while (w0 != w1) {
            w0 <- w1
            w1 <- w0 -
                (w0*exp(w0)-x)/((w0+1)*exp(w0)-(w0+2)*(w0*exp(w0)-x)/(2*w0+2))
        }
        return(w1)
    }

    julia_assign("lambertW", lambertW)
    julia_command("gL = x -> ForwardDiff.gradient(lambertW, x);")
    expect_equal(julia_eval("gL([1.0])"), 0.361896256634889)
})

test_that("test of AD of Rosenbrock function", {
    skip_on_cran()
    julia <- julia_setup()

    julia_install_package_if_needed("ForwardDiff")
    julia_library("ForwardDiff")

    fnRosenbrock <- function(x){
        n <- length(x)
        x1 <- x[2:n]
        x2 <- x[1:(n - 1)]
        sum(100 * (x1 - x2^2)^2 + (1 - x2)^2)
    }

    julia_assign("rosen", fnRosenbrock)
    julia_command("gR = x -> ForwardDiff.gradient(rosen, x);")
    julia_command("hR = x -> ForwardDiff.hessian(rosen, x);")
    ## currently only support n >=3 is supported,
    ## because in the definition of fnRosenbrock, there is
    ## x1 <- x[2:n]
    ## x2 <- x[1:(n - 1)]
    ## if n==2, then x1 and x2 will be scalar, since R doesn't distinguish between
    ## scalar and atomic vector of length 1, the type conversion between R and julia
    ## in this case will be problematic.

    ## We could test the result by writing rosenbrock function directly in julia
    ## and calculate the derivative by ForwardDiff
    julia_eval("function rosenjl(x) n = length(x);
               x1 = x[2:n]; x2 = x[1:(n - 1)]; sum(100 * (x1 .- x2.^2).^2 + (1 .- x2).^2) end")
    julia_command("gRjl = x -> ForwardDiff.gradient(rosenjl, x);")
    julia_command("hRjl = x -> ForwardDiff.hessian(rosenjl, x);")

    pt <- c(1, 2, 1)
    expect_is(julia_call("gR", pt), "numeric")
    expect_length(julia_call("gR", pt), length(pt))
    expect_equal(julia_call("gR", pt), julia_call("gRjl", pt))

    expect_is(julia_call("hR", pt), "matrix")
    expect_length(julia_call("hR", pt), length(pt) ^ 2)
    expect_equal(julia_call("hR", pt), julia_call("hRjl", pt))
})
