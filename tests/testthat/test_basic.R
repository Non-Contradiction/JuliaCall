context("Basic test")

check_julia <- function() {
    if (!julia_check()) {
        skip("Julia not available")
    }
}

test_that("test of the basic functionality", {
    skip_on_cran()
    check_julia()
    julia <- julia_setup()

    expect_equal(julia$eval_string("sqrt(2)"), sqrt(2))
    expect_equal(julia$call("sqrt", 2), sqrt(2))
    expect_equal(julia$eval_string("sqrt")(2), sqrt(2))
    expect_equal({julia$command("a = sqrt(2)"); julia$eval_string("a")}, sqrt(2))
    expect_null(julia$using("RCall"))
    expect_output(julia$help("sqrt"))
})
