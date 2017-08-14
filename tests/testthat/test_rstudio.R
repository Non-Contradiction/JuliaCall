context("RStudio Test")

system("rstudio", wait = FALSE)
Sys.sleep(20)
if (require(rstudioapi) && rstudioapi::isAvailable()) {
    test_that("test whether the package works in RStudio or not", {
        rstudioapi::sendToConsole("library('JuliaCall'); julia <- julia_setup()")
        Sys.sleep(40)
        expect_true(rstudioapi::isAvailable())
    })
}
