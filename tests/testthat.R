library(testthat)
library(JuliaCall)
if (Sys.getenv("CI") != "") {
    JuliaCall::install_julia(tempdir())
}
test_check("JuliaCall")
