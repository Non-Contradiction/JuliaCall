context("Basic test")

julia <- julia_setup()
#' julia$cmd("println(sqrt(2))")
#' julia$eval_string("sqrt(2)")
#' julia$call("sqrt", 2)
#' julia$eval_string("sqrt")(2)
#' julia$exists("sqrt")
#' julia$exists("c")
#'

test_that("test of the basic functionality", {
    expect_equal(julia$eval_string("sqrt(2)"), sqrt(2))
    expect_equal(julia$call("sqrt", 2), sqrt(2))
    expect_equal(julia$eval_string("sqrt")(2), sqrt(2))
    expect_equal({julia$command("a = sqrt(2)"); julia$eval_string("a")}, sqrt(2))
    expect_null(julia$using("RCall"))
    expect_output(julia$help("sqrt"))
})
