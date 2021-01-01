library(testthat)
library(JuliaCall)

test_that("Automatic installation of Julia", {
    skip_on_cran()
    julia <- julia_setup(installJulia = TRUE)
})

test_check("JuliaCall")
