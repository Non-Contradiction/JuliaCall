context("Rebuild test")

test_that("test the rebuild argument in julia_setup", {
    skip_on_cran()
    julia <- julia_setup(rebuild = TRUE)

    expect_equal(julia_eval("sqrt(2)"), sqrt(2))
    expect_equal(julia_call("sqrt", 2), sqrt(2))
    expect_equal(julia_eval("sqrt")(2), sqrt(2))
    expect_equal({julia_command("a = sqrt(2)"); julia_eval("a")}, sqrt(2))
})
