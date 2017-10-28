context("JuliaObject test")

test_that("test of the JuliaObject", {
    skip_on_cran()
    julia <- julia_setup()

    expect_equal(julia_eval("1//2") ^ 2, 0.25)

    julia_command("
    type Mytype
        num::Int
        den::Int
        ans::Float64
    end")
    julia_eval("Mytype(1, 12, 1/12)")
    r <- julia_eval("Mytype(1, 12, 1/12)")
    expect_length(r, 1)
    expect_equal(julia_call("getfield", r, quote(den)), 12)
    expect_equal(julia_call("getfield", r, quote(num)), 1)
    expect_equal(julia_call("getfield", r, quote(ans)), 1 / 12)
    remove(r)
})
