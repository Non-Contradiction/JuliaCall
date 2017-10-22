context("JuliaObject test")

test_that("test of the JuliaObject", {
    skip_on_cran()
    julia <- julia_setup()

    expect_equal(julia_eval("1//2") ^ 2, 0.25)
})
