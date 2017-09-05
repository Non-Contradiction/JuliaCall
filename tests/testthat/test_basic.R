context("Basic test")

test_that("test of the basic functionality", {
    skip_on_cran()
    julia <- julia_setup()

    expect_equal(julia_eval_string("sqrt(2)"), sqrt(2))
    expect_equal(julia_call("sqrt", 2), sqrt(2))
    expect_equal(julia_eval_string("sqrt")(2), sqrt(2))
    expect_equal({julia_command("a = sqrt(2)"); julia_eval_string("a")}, sqrt(2))
    expect_true(julia_exists("sqrt"))
    expect_output(julia_help("sqrt"))

    expect_equal({julia_assign("x", sqrt(2)); julia_eval_string("x")}, sqrt(2))
    expect_equal({julia_assign("rsqrt", sqrt); julia_eval_string("rsqrt(2)")}, sqrt(2))
})
