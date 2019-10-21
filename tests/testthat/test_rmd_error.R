context("rmd error test")

test_that("test error throwing in rmd", {
    skip_on_cran()
    skip_on_appveyor()

    tmp <- tempfile(fileext = ".md")
    expect_error(rmarkdown::render(test_path("Rmd_error_test.Rmd"),
                                   output_file = tmp))
    expect_error(rmarkdown::render(test_path("Rmd_error_test1.Rmd"),
                                   output_file = tmp))
})
