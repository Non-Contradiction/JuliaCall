context("RCall test")

test_that("test of using RCall through JuliaCall", {
    skip_on_cran()
    julia <- julia_setup()

    expect_equal(julia_eval('R"1"'), 1)
    expect_equal(julia_eval('reval("1")'), 1)
    expect_equal(julia_eval('rcall(:sqrt, 2)'), sqrt(2))

    expect_error(julia_eval('R"aaa"'))
    expect_error(julia_eval('reval("aaa")'))
    expect_error(julia_eval('rcall(:sqrt, "aaa")'))
})
