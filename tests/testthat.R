Sys.setenv("R_TESTS" = "")
library(JuliaCall)
## Need to do julia_setup() before loading the testthat library.
## Because dyn.load libjulia after library(testthat) is problematic.
julia_setup()
library(testthat)

test_check("JuliaCall")
