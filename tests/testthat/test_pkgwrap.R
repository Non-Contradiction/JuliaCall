context("Pkg wrap Test")

test_that("test of pkg wrap", {
    skip_on_cran()
    julia <- julia_setup()

    julia_install_package_if_needed("Optim")
    opt <- julia_pkg_import("Optim",
                            func_list = c("optimize", "BFGS"))
    rosenbrock <- function(x) (1.0 - x[1])^2 + 100.0 * (x[2] - x[1]^2)^2
    result <- opt$optimize(rosenbrock, rep(0,2), opt$BFGS())
    expect_true(inherits(result, "JuliaObject"))
    expect_equal(result$minimizer, c(1, 1))
    expect_equal(result$minimum, 0)
})
