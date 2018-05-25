context("Array-related dispatching test")

test_that("test of is.matrix", {
    skip_on_cran()
    julia <- julia_setup()

    expect_true(is.matrix(JuliaObject(matrix(1,3,3))))
    expect_false(is.matrix(JuliaObject(1:3)))
    expect_true(is.matrix(julia_eval("[1//1 2//2; 3//3 4//4]")))
    expect_false(is.matrix(julia_eval("[1//1; 2//2]")))
})

test_that("test of is.array", {
    skip_on_cran()
    julia <- julia_setup()

    expect_true(is.array(JuliaObject(matrix(1,3,3))))
    expect_true(is.array(JuliaObject(1:3)))
    expect_true(is.array(julia_eval("[1//1 2//2; 3//3 4//4]")))
    expect_true(is.array(julia_eval("[1//1; 2//2]")))
})

test_that("test of dim", {
    skip_on_cran()
    julia <- julia_setup()

    expect_equal(dim(JuliaObject(matrix(1,3,3))), c(3, 3))
    expect_equal(dim(JuliaObject(1:3)), 3)
    expect_equal(dim(julia_eval("[1//1 2//2; 3//3 4//4]")), c(2, 2))
    expect_equal(dim(julia_eval("[1//1; 2//2]")), 2)
})

test_that("test of diag", {
    skip_on_cran()
    julia <- julia_setup()

    expect_equal(diag(JuliaObject(matrix(1,3,3))), rep(1, 3))
    expect_error(diag(JuliaObject(1:3)))
    expect_true(all(diag(julia_eval("[1//1 2//2; 3//3 4//4]")) == julia_eval("[1//1; 3//3]")))
    expect_error(diag(julia_eval("[1//1; 2//2]")))
})
