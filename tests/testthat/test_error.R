context("Error handling test")

test_that("test of the error handling functionality", {
    skip_on_cran()
    julia <- julia_setup()

    expect_error(julia_eval("abc"))
    expect_error(julia_command("abc"))
    expect_error(julia_call("sqrt", -1))
    expect_error(julia_call("sqrt", 1, 2))
    expect_error(julia_library("A"))
})
