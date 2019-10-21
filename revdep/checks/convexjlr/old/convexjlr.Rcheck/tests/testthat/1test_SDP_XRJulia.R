library(convexjlr)
context("Semidefinite Programming with XRJulia backend")

## The original Julia version

# y = Semidefinite(2)
# p = maximize(lambdamin(y), trace(y)<=6)
# solve!(p, SCSSolver(verbose=0))
# p.optval

test_that("Results for example of semidefinite programming with XRJulia", {
    skip_on_cran()
    convex_setup(backend = "XRJulia")

    ## The R version with convexjl.R

    y <- Semidefinite(2)
    p <- maximize(lambdamin(y), trace(y) <= 6)
    cvx_optim(p)

    ## The R version with XRJulia directly

    ## ev <- XRJulia::RJulia()
    ev$Command("using Convex")
    ev$Command("y = Semidefinite(2)")
    ev$Command("p = maximize(lambdamin(y), trace(y)<=6)")
    ev$Command("solve!(p)")

    ## Compare the results


    expect_equal(optval(p), ev$Eval("p.optval"))
})
