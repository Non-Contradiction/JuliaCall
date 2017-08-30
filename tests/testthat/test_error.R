context("Error handling test")

check_julia <- function() {
    if (!julia_check()) {
        skip("Julia not available")
    }
}

test_that("test of the error handling functionality", {
    skip_on_cran()
    check_julia()
    julia <- julia_setup()

    expect_error(julia$eval_string("abc"))
    expect_error(julia$command("abc"))
    expect_error(julia$call("sqrt", -1))
    expect_error(julia$call("sqrt", 1, 2))
    expect_error(julia$using("A"))
    expect_error(julia$help("abc"))
})
