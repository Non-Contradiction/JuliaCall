context("julia_source test")

test_that("test julia_source", {
    skip_on_cran()

    fname <- test_path("simplesource.jl")

    julia_source(fname)

    expect_equal(julia_eval("a"), 1)
})
