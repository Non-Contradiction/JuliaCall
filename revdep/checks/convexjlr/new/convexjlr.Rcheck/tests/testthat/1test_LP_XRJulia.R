library(convexjlr)
context("Linear Programming with XRJulia backend")

## The original Julia version

# x = Variable(4)
# c = [1; 2; 3; 4]
# A = eye(4)
# b = [10; 10; 10; 10]
# p = minimize(dot(c, x)) # or c' * x
# p.constraints += A * x <= b
# p.constraints += [x >= 1; x <= 10; x[2] <= 5; x[1] + x[4] - x[2] <= 10]
# solve!(p)
# println(round(p.optval, 2))
# println(round(x.value, 2))
# println(evaluate(x[1] + x[4] - x[2]))

test_that("Results for example of linear programming with XRJulia", {
    skip_on_cran()
    convex_setup(backend = "XRJulia")

    ## The R version with convexjl.R

    x <- Variable(4)
    c <- J(c(1:4))
    A <- J(diag(4))
    b <- J(rep(10, 4))
    p <- minimize(sum(c * x))
    p <- addConstraint(p, A %*% x <= b)
    p <- addConstraint(p, x >= 1, x <= 10, x[2] <= 5, x[1] + x[4] - x[2] <= 10)
    cvx_optim(p)

    ## The R verion through XRJulia directly

    ## ev <- XRJulia::RJulia()
    ev$Command("using Convex")
    ev$Command("x = Variable(4)")
    ev$Command("c = [1; 2; 3; 4]")
    ev$Command("A = eye(4)")
    ev$Command("b = [10; 10; 10; 10]")
    ev$Command("p = minimize(dot(c, x)) # or c' * x")
    ev$Command("p.constraints += A * x <= b")
    ev$Command("p.constraints += [x >= 1; x <= 10; x[2] <= 5; x[1] + x[4] - x[2] <= 10]")
    ev$Command("solve!(p)")

    ## Compare the results

    expect_equal(optval(p), ev$Eval("p.optval"))
    expect_equal(value(x), ev$Eval("x.value", .get = TRUE))
    expect_equal(value(x[1] + x[4] - x[2]),
                 ev$Eval("evaluate(x[1] + x[4] - x[2])", .get = TRUE))
})
