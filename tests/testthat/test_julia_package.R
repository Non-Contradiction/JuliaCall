context("julia_package test")

check_julia <- function() {
    if (!julia_check()) {
        skip("Julia not available")
    }
}

test_that("test of functionality related to julia_package", {
    skip_on_cran()
    check_julia()
    julia <- julia_setup()

    expect_null(julia_install_package("Optim"))
    expect_null(julia_install_package_if_needed("Optim"))
    expect_gte(utils::compareVersion(julia_installed_package("Optim"), "0.7.8"), 0)
    expect_null(julia_library("Optim"))
})
