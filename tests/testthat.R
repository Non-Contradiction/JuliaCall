Sys.setenv("R_TESTS" = "")
library(testthat)
library(JuliaCall)

test_check("JuliaCall")
