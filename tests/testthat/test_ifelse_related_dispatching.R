context("ifelse-related dispatching test")

test_that("test of rep", {
    skip_on_cran()
    julia <- julia_setup()

    expect_equal(rep(1, 3), c(rep(JuliaObject(1), 3)))
    expect_equal(rep(1:2, 3), c(rep(JuliaObject(1:2), 3)))
    expect_equal(rep(1:2, length.out = 5), c(rep(JuliaObject(1:2), length.out = 5)))

    expect_true(all(julia_eval("[1//1;1//1;1//1]") == rep(julia_eval("1//1"), 3)))
    expect_true(all(julia_eval("[1//1;2//1;1//1;2//1;1//1;2//1]") == rep(julia_eval("[1//1;2//1]"), 3)))
    expect_true(all(julia_eval("[1//1;2//1;1//1;2//1;1//1]") == rep(julia_eval("[1//1;2//1]"), length.out = 5)))

})

test_that("test of logical index", {
    skip_on_cran()
    julia <- julia_setup()

    x1 <- JuliaObject(1:3)
    expect_equal(x1[2], x1[c(FALSE, TRUE, FALSE)])
    expect_equal(x1[2:3], x1[c(FALSE, TRUE, TRUE)])
    expect_equal(x1[1:3], x1[c(TRUE, TRUE, TRUE)])

    x2 <- julia_eval("[1//1;2//1;3//1]")
    expect_true(all(x2[2] == x2[c(FALSE, TRUE, FALSE)]))
    expect_true(all(x2[2:3] == x2[c(FALSE, TRUE, TRUE)]))
    expect_true(all(x2[1:3] == x2[c(TRUE, TRUE, TRUE)]))

})

test_that("test of assign", {
    skip_on_cran()
    julia <- julia_setup()

    x <- julia_eval("[1//1;2//1;3//1]")

    x1 <- julia_eval("[1//1;2//1;3//1]")
    x1[2] <- 2

    expect_true(all(x1 == x))

    x2 <- JuliaObject(c(TRUE, FALSE, FALSE))
    x2[2:3] <- julia_eval("[2//1;3//1]")

    expect_true(all(x2 == x))

    x3 <- JuliaObject(c(1, 2, 3))
    x3[c(FALSE, TRUE, TRUE)] <- julia_eval("[2//1;3//1]")

    expect_true(all(x3 == x))

})

test_that("test of ifelse", {
    skip_on_cran()
    julia <- julia_setup()

    x <- julia_eval("[1//1;2//1;3//1]")
    y <- julia_eval("[0//1;2//1;3//1]")

    expect_true(all(ifelse(x >= 2, x, 0) == y))

    expect_true(all(ifelse(x >= 2, 2, 0) == c(0, 2, 2)))
})
