Sys.setenv("R_TESTS" = "")
library(JuliaCall)
## Need to do julia_setup() before loading the testthat library.
## Because dyn.load libjulia after library(testthat) is problematic.
## And do this only when not on CRAN,
## otherwise it will be problematic for win32 and things like that.
if (identical(Sys.getenv("NOT_CRAN"), "true")) {
    julia_setup()
}
library(testthat)

test_check("JuliaCall")
