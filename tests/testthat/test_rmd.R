context("rmd test")

test_that("test juliacall in rmd", {
    skip_on_cran()
    skip_on_appveyor()

    tmp <- tempfile()
    rmarkdown::render(test_path("Rmd_test.Rmd"), output_file = tmp)
    expect_true(file.exists(tmp))
    r <- paste(readLines(tmp), collapse = "\n")
    r1 <- paste(readLines(test_path("Rmd_test.md")), collapse = "\n")
    ## expect_equal(r, r1)
})
