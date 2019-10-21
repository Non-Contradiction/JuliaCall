library(convexjlr)
context("Second Order Cone Programming with XRJulia backend")

## The original Julia version

# X = Variable(2, 2)
# y = Variable()
# # X is a 2 x 2 variable, and y is scalar. X' + y promotes y to a 2 x 2 variable before adding them
# p = minimize(vecnorm(X) + y, 2 * X <= 1, X' + y >= 1, X >= 0, y >= 0)
# solve!(p)
# println(round(X.value, 2))
# println(y.value)
# p.optval

test_that("Results for example of second order cone programming with XRJulia", {
    skip_on_cran()
    convex_setup(backend = "XRJulia")

    ## The R version with convexjl.R

    X <- Variable(c(2, 2))
    y <- Variable()
    p <- minimize(vecnorm(X) + y, 2 * X <= 1, t(X) + y >= 1, X >= 0, y >= 0)
    cvx_optim(p)

    ## The R version with XRJulia directly

    ## ev <- XRJulia::RJulia()
    ev$Command("using Convex")
    ev$Command("X = Variable(2, 2)")
    ev$Command("y = Variable()")
    ev$Command("p = minimize(vecnorm(X) + y, 2 * X <= 1, X' + y >= 1, X >= 0, y >= 0)")
    ev$Command("solve!(p)")

    ## Compare the results

    expect_equal(optval(p), ev$Eval("p.optval"))
    expect_equal(value(X), ev$Eval("X.value", .get = TRUE))
    expect_equal(value(y), ev$Eval("evaluate(y)", .get = TRUE))
})
