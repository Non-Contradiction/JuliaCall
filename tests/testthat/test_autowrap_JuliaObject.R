context("autowrap test")

test_that("test of autowrap", {
    skip_on_cran()
    julia <- julia_setup()

    julia_command("
    struct MyType2{T} <: AbstractArray{T,1}
        num::T
        den::T
        ans::Float64
    end")
    expect_true(julia_eval("MyType2 <: AbstractArray"))
    julia_eval("import Base.size; Base.size(x::MyType2) = 1")
    julia_eval("import Base.getindex; Base.getindex(x::MyType2, i) = 1")
    expect_equal(1, julia_eval("MyType2(1, 12, 1/12)"))
    autowrap("MyType2")
    r <- julia_eval("MyType2(1, 12, 1/12)")
    expect_true(inherits(r, "JuliaObject"))
    expect_equal(length(r), 1)
    expect_equal(julia_call("getfield", r, quote(den)), 12)
    expect_equal(julia_call("getfield", r, quote(num)), 1)
    expect_equal(julia_call("getfield", r, quote(ans)), 1 / 12)
    expect_equal(fields(r), c("num", "den", "ans"))
    expect_equal(field(r, "num"), 1)
    expect_equal(field(r, "den"), 12)
    expect_equal(field(r, "ans"), 1 / 12)
})
