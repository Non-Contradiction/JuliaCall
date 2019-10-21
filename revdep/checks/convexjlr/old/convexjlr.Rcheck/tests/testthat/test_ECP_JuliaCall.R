library(convexjlr)
context("Exponential Cone Programming with JuliaCall")

## The original Julia version

# x = Variable(4)
# p = satisfy(norm(x) <= 100, exp(x[1]) <= 5, x[2] >= 7, geomean(x[3], x[4]) >= x[2])
# solve!(p, SCSSolver(verbose=0))
# println(p.status)
# x.value

test_that("Results for example of exponential cone programming with JuliaCall", {
    skip_on_cran()
    convex_setup(backend = "JuliaCall")

    ## The R version with convexjl.R

    x <- Variable(4)
    p <- satisfy(norm(x) <= 100, exp(x[1]) <= 5, x[2] >= 7, geomean(x[3], x[4]) >= x[2])
    cvx_optim(p, solver = "SCS")

    ## The R version with XRJulia directly

    # ev <- XRJulia::RJulia()

    ## The R version with JuliaCall directly
    ev <- JuliaCall::julia_setup()
    ev$command("using Convex")
    ev$command("x = Variable(4)")
    ev$command("p = satisfy(norm(x) <= 100, exp(x[1]) <= 5, x[2] >= 7, geomean(x[3], x[4]) >= x[2])")
    ev$command("solve!(p, SCSSolver())")

    ## Compare the results

    expect_equal(value(x), ev$eval("x.value")) ## , .get = TRUE))
})
