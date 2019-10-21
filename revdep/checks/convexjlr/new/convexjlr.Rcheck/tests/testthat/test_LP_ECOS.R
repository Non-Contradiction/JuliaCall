library(convexjlr)
context("Linear Programming with JuliaCall in ECOS solver")

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

test_that("Results for example of linear programming in ECOS", {
    skip_on_cran()
    convex_setup(backend = "JuliaCall")

    ## The R version with convexjl.R

    x <- Variable(4)
    c <- J(c(1:4))
    A <- J(diag(4))
    b <- J(rep(10, 4))
    p <- minimize(sum(c * x))
    p <- addConstraint(p, A %*% x <= b)
    p <- addConstraint(p, x >= 1, x <= 10, x[2] <= 5, x[1] + x[4] - x[2] <= 10)
    cvx_optim(p, solver = "ECOS")

    ## The R verion through XRJulia directly

    # ev <- XRJulia::RJulia()

    ## The R version through JuliaCall directly

    ev <- JuliaCall::julia_setup()
    ev$command("using Convex")
    ev$command("x = Variable(4)")
    ev$command("c = [1; 2; 3; 4]")
    ev$command("A = Matrix(Diagonal(ones(4)))")
    ev$command("b = [10; 10; 10; 10]")
    ev$command("p = minimize(dot(c, x)) # or c' * x")
    ev$command("p.constraints += A * x <= b")
    ev$command("p.constraints += [x >= 1; x <= 10; x[2] <= 5; x[1] + x[4] - x[2] <= 10]")
    ev$command("solve!(p, ECOSSolver())")

    ## Compare the results

    expect_equal(optval(p), ev$eval("p.optval"), tolerance = 1e-3)
    expect_equal(value(x), ev$eval("x.value"), tolerance = 1e-3)
    expect_equal(value(x[1] + x[4] - x[2]),
                 ev$eval("evaluate(x[1] + x[4] - x[2])"),
                 tolerance = 1e-3)
})
