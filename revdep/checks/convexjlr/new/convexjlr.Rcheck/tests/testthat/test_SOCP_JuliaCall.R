library(convexjlr)
context("Second Order Cone Programming with JuliaCall")

## The original Julia version

# X = Variable(2, 2)
# y = Variable()
# # X is a 2 x 2 variable, and y is scalar. X' + y promotes y to a 2 x 2 variable before adding them
# p = minimize(vecnorm(X) + y, 2 * X <= 1, X' + y >= 1, X >= 0, y >= 0)
# solve!(p)
# println(round(X.value, 2))
# println(y.value)
# p.optval

test_that("Results for example of second order cone programming with JuliaCall", {
    skip_on_cran()
    convex_setup(backend = "JuliaCall")

    ## The R version with convexjl.R

    X <- Variable(c(2, 2))
    y <- Variable()
    p <- minimize(norm(vec(X)) + y, 2 * X <= 1, t(X) + y >= 1, X >= 0, y >= 0)
    cvx_optim(p)

    ## The R version with XRJulia directly

    # ev <- XRJulia::RJulia()

    ## The R version with JuliaCall directly

    ev <- JuliaCall::julia_setup()
    ev$command("using Convex")
    ev$command("X = Variable(2, 2)")
    ev$command("y = Variable()")
    ev$command("p = minimize(norm(vec(X)) + y, 2 * X <= 1, X' + y >= 1, X >= 0, y >= 0)")
    ev$command("solve!(p, SCSSolver())")

    ## Compare the results

    expect_equal(optval(p), ev$eval("p.optval"))
    expect_equal(value(X), ev$eval("X.value")) ##, .get = TRUE))
    expect_equal(value(y), ev$eval("evaluate(y)")) ##, .get = TRUE))
})
