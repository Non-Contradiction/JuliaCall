context("asR test")

test_that("test of the asR functions", {
    skip_on_cran()
    julia <- julia_setup()

    expect_equal(as.double(julia_eval("1//2")), 0.5)
    expect_equal(as.double(julia_eval("[1//2, 3//4]")), c(0.5, 0.75))
})
