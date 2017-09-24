context("rmd test")

test_that("test juliacall in rmd", {
    skip_on_cran()

    tmp <- tempfile()
    rmarkdown::render("./tests/testthat/Rmd_test.Rmd", output_file = tmp)
    r <- paste(readLines(tmp), collapse = "")
    r1 <- paste(readLines("./tests/testthat/Rmd_test.html"), collapse = "")
    expect_equal(r, r1)
})
