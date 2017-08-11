context("Error handling test")

julia <- julia_setup()

test_that("test of the error handling functionality", {
    expect_error(julia$eval_string("abc"))
    expect_error(julia$command("abc"))
    expect_error(julia$call("sqrt", -1))
    expect_error(julia$call("sqrt", 1, 2))
    expect_error(julia$using("A"))
})
