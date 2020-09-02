library(testthat)
library(JuliaCall)
if (Sys.getenv("CI") != "") {
    install.packages("rappdirs")
    JuliaCall::install_julia()
}
test_check("JuliaCall")
