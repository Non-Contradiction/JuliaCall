library(convexjlr)
context("Second Order Cone Programming with JuliaCall in ECOS solver")

## The original Julia version

# X = Variable(2, 2)
# y = Variable()
# # X is a 2 x 2 variable, and y is scalar. X' + y promotes y to a 2 x 2 variable before adding them
# p = minimize(vecnorm(X) + y, 2 * X <= 1, X' + y >= 1, X >= 0, y >= 0)
# solve!(p)
# println(round(X.value, 2))
# println(y.value)
# p.optval

test_that("Results for example of second order cone programming in ECOS", {
    skip_on_cran()
    convex_setup(backend = "JuliaCall")

    ## The R version with convexjl.R

    X <- Variable(c(2, 2))
    y <- Variable()
    p <- minimize(norm(vec(X)) + y, 2 * X <= 1, t(X) + y >= 1, X >= 0, y >= 0)
    cvx_optim(p, solver = "ECOS")

    ## The R version with XRJulia directly

    # ev <- XRJulia::RJulia()

    ## The R version with JuliaCall directly

    ev <- JuliaCall::julia_setup()
    ev$command("using Convex")
    ev$command("X = Variable(2, 2)")
    ev$command("y = Variable()")
    ev$command("p = minimize(norm(vec(X)) + y, 2 * X <= 1, X' + y >= 1, X >= 0, y >= 0)")
    ev$command("solve!(p, ECOSSolver())")

    ## Compare the results

    expect_equal(optval(p), ev$eval("p.optval"), tolerance = 1e-3)
    expect_equal(value(X), ev$eval("X.value"), tolerance = 1e-3)
    expect_equal(value(y), ev$eval("evaluate(y)"), tolerance = 1e-3)
})
