library(convexjlr)
context("Semidefinite Programming with JuliaCall in ECOS solver")

## The original Julia version

# y = Semidefinite(2)
# p = maximize(lambdamin(y), trace(y)<=6)
# solve!(p, SCSSolver(verbose=0))
# p.optval

test_that("Results for example of semidefinite programming in ECOS", {
    skip_on_cran()
    convex_setup(backend = "JuliaCall")

    ## The R version with convexjl.R

    y <- Semidefinite(2)
    p <- maximize(lambdamin(y), trace(y) <= 6)
    cvx_optim(p, solver = "ECOS")

    # ## The R version with XRJulia directly
    #
    # ev <- XRJulia::RJulia()
    # ev$Command("using Convex")
    # ev$Command("y = Semidefinite(2)")
    # ev$Command("p = maximize(lambdamin(y), trace(y)<=6)")
    # ev$Command("solve!(p, ECOSSolver())")

    ## The R version with JuliaCall directly

    ## ev <- JuliaCall::julia_setup()
    ev$Command("using Convex")
    ev$Command("y = Semidefinite(2)")
    ev$Command("p = maximize(lambdamin(y), trace(y)<=6)")
    ev$Command("solve!(p, ECOSSolver())")

    ## Compare the results


    expect_equal(optval(p), ev$Eval("p.optval"))
})
