context("RStudio Test")

system("rstudio", wait = FALSE)
sleep(10)
if (require(rstudioapi) && rstudioapi::isAvailable()) {
    test_that("test whether the package works in RStudio or not", {
        rstudioapi::sendToConsole("library('JuliaCall'); julia <- julia_setup()")
        sleep(30)
        expect_true(rstudioapi::isAvailable())
    })
}
