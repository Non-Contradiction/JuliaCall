library(convexjlr)
context("Semidefinite Programming with JuliaCall")

## The original Julia version

# y = Semidefinite(2)
# p = maximize(lambdamin(y), trace(y)<=6)
# solve!(p, SCSSolver(verbose=0))
# p.optval

test_that("Results for example of semidefinite programming with JuliaCall", {
    skip_on_cran()
    convex_setup(backend = "JuliaCall")

    ## The R version with convexjl.R

    y <- Semidefinite(2)
    p <- maximize(lambdamin(y), trace(y) <= 6)
    cvx_optim(p)

    ## The R version with XRJulia directly

    # ev <- XRJulia::RJulia()

    ## The R version with JuliaCall directly

    ev <- JuliaCall::julia_setup()
    ev$command("using Convex")
    ev$command("y = Semidefinite(2)")
    ev$command("p = maximize(lambdamin(y), trace(y)<=6)")
    ev$command("solve!(p, SCSSolver())")

    ## Compare the results


    expect_equal(optval(p), ev$eval("p.optval"))
})
