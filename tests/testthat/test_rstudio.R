context("RStudio Test")

system("rstudio", wait = FALSE)
sleep(30)
if (require(rstudioapi) && rstudioapi::isAvailable()) {
    test_that("test whether the package works in RStudio or not", {
        rstudioapi::sendToConsole("library('JuliaCall'); julia <- julia_setup()")
        sleep(60)
        expect_true(rstudioapi::isAvailable())
    })
}
