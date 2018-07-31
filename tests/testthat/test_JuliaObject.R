context("JuliaObject test")

test_that("test of the JuliaObject", {
    skip_on_cran()
    julia <- julia_setup()

    expect_equal(c(julia_eval("1//2") ^ 2), 0.25)

    julia_command("
    mutable struct Mytype
        num::Int
        den::Int
        ans::Float64
    end")
    julia_eval("Mytype(1, 12, 1/12)")
    r <- julia_eval("Mytype(1, 12, 1/12)")
    expect_equal(length(r), 1)
    expect_equal(julia_call("getfield", r, quote(den)), 12)
    expect_equal(julia_call("getfield", r, quote(num)), 1)
    expect_equal(julia_call("getfield", r, quote(ans)), 1 / 12)
    expect_equal(fields(r), c("num", "den", "ans"))
    expect_equal(field(r, "num"), 1)
    expect_equal(field(r, "den"), 12)
    expect_equal(field(r, "ans"), 1 / 12)
    field(r, "num") <- 2; field(r, "ans") <- 2 / 12
    expect_equal(field(r, "num"), 2)
    expect_equal(field(r, "den"), 12)
    expect_equal(field(r, "ans"), 2 / 12)
    remove(r)
})
