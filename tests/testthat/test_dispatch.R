context("Method Dispatch Test for JuliaObject")

set.seed(123)

random_vec <- function(n = 1, dim = 5, min = 0, max = 10){
    p <- sample.int(dim, 1)
    matrix(runif(n * p, min = min, max = max), ncol = n)
}

testJuliaObjectGeneric <- function(generic, narg,
                                   times = 5, dim = 5, min = 0, max = 10){
    if (narg == 1) {
        for (i in 1:times) {
            x <- random_vec(dim = dim, min = min, max = max)[, 1]
            expect_equal(c(generic(JuliaObject(x))), generic(x))
        }
    }
    else {
        for (i in 1:times) {
            xy <- random_vec(n = 2, dim = dim, min = min, max = max)
            x <- xy[, 1]
            y <- xy[, 2]
            expect_equal(c(generic(JuliaObject(x), JuliaObject(y))), generic(x, y))
            expect_equal(c(generic(JuliaObject(x), y)), generic(x, y))
            expect_equal(c(generic(x, JuliaObject(y))), generic(x, y))
        }
    }
}

test_that("test of basic generics", {
    skip_on_cran()
    julia <- julia_setup()

    testJuliaObjectGeneric(length, 1)
    testJuliaObjectGeneric(as.double, 1)
    testJuliaObjectGeneric(as.integer, 1)
    testJuliaObjectGeneric(as.logical, 1)

    times <- 5
    for (i in 1:times) {
        x <- random_vec()
        p <- length(x)
        ind <- sample.int(p, sample.int(p, 1))
        expect_equal(JuliaObject(x)[ind], x[ind])
        expect_equal(JuliaObject(x)[[ind[1]]], x[[ind[1]]])
    }
})

test_that("test of Compare group", {
    skip_on_cran()
    julia <- julia_setup()

    testJuliaObjectGeneric(`==`, 2)
    testJuliaObjectGeneric(`>`, 2)
    testJuliaObjectGeneric(`<`, 2)
    testJuliaObjectGeneric(`!=`, 2)
    testJuliaObjectGeneric(`<=`, 2)
    testJuliaObjectGeneric(`>=`, 2)
})

test_that("test of Arith group", {
    skip_on_cran()
    julia <- julia_setup()

    testJuliaObjectGeneric(`+`, 2)
    testJuliaObjectGeneric(`-`, 2)
    testJuliaObjectGeneric(`*`, 2)
    testJuliaObjectGeneric(`^`, 2)
    testJuliaObjectGeneric(`%%`, 2)
    testJuliaObjectGeneric(`%/%`, 2)
    testJuliaObjectGeneric(`/`, 2)

    ## Need to test for + and - as unary operators
    testJuliaObjectGeneric(`+`, 1)
    testJuliaObjectGeneric(`-`, 1)
})

test_that("test of Logic group", {
    skip_on_cran()
    julia <- julia_setup()

    testJuliaObjectGeneric(`&`, 2)
    testJuliaObjectGeneric(`|`, 2)
})

test_that("test of Math and Math2 group", {
    skip_on_cran()
    julia <- julia_setup()

    testJuliaObjectGeneric(abs, 1)
    testJuliaObjectGeneric(sign, 1)
    testJuliaObjectGeneric(sqrt, 1)
    testJuliaObjectGeneric(ceiling, 1)
    testJuliaObjectGeneric(floor, 1)
    testJuliaObjectGeneric(trunc, 1)
    testJuliaObjectGeneric(cummax, 1)
    testJuliaObjectGeneric(cummin, 1)
    testJuliaObjectGeneric(cumprod, 1)
    testJuliaObjectGeneric(cumsum, 1)
    testJuliaObjectGeneric(log, 1)
    testJuliaObjectGeneric(log10, 1)
    testJuliaObjectGeneric(log2, 1)
    testJuliaObjectGeneric(log1p, 1)
    testJuliaObjectGeneric(exp, 1)
    testJuliaObjectGeneric(expm1, 1)
    testJuliaObjectGeneric(cos, 1)
    testJuliaObjectGeneric(cosh, 1)
    testJuliaObjectGeneric(cospi, 1)
    testJuliaObjectGeneric(sin, 1)
    testJuliaObjectGeneric(sinh, 1)
    testJuliaObjectGeneric(sinpi, 1)
    testJuliaObjectGeneric(tan, 1)
    testJuliaObjectGeneric(tanh, 1)
#    testJuliaObjectGeneric(tanpi, 1)
#    testJuliaObjectGeneric(gamma, 1)

    testJuliaObjectGeneric(round, 1)
    testJuliaObjectGeneric(signif, 1)
})
