context("Basic test")

julia <- julia_setup()
#' julia$cmd("println(sqrt(2))")
#' julia$eval_string("sqrt(2)")
#' julia$call("sqrt", 2)
#' julia$eval_string("sqrt")(2)
#' julia$exists("sqrt")
#' julia$exists("c")
#'

test_that("str_length is number of characters", {
    expect_equal(julia$eval_string("sqrt(2)"), sqrt(2))
    expect_equal(julia$call("sqrt", 2), sqrt(2))
    expect_equal(julia$eval_string("sqrt")(2), sqrt(2))
})
