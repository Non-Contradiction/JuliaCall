context("JuliaTuple test")

test_that("test of JuliaTuple", {
    skip_on_cran()
    julia <- julia_setup()

    julia_command("r1 = (1, 2);")
    r2 <- julia_eval("r1")

    expect_length(r2, 2)
    expect_is(r2, "JuliaTuple")

    julia_assign("r3", r2)
    expect_true(julia_eval("r1 == r3"))
})
