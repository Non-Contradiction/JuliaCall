context("Argument test")

test_that("test of passing arguments", {
    skip_on_cran()
    julia <- julia_setup()

    julia_command("function test(a, b; c= 1, d = 2) a+b+c+d end")
    expect_equal(julia_call("test", 1, 2), 6)
    expect_equal(julia_call("test", 1, 2, c = 3), 8)
    expect_equal(julia_call("test", 1, 2, d = 3), 7)
    expect_equal(julia_call("test", 1, 2, c = 3, d = 3), 9)
    expect_equal(julia_call("test", 1, 2, d = 3, c = 3), 9)
    expect_equal(julia_call("test", d = 3, c = 3, 1, 2), 9)
})
