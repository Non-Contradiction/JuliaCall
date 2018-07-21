context("julia_package test")

test_that("test of functionality related to julia_package", {
    skip_on_cran()
    julia <- julia_setup()

    expect_null(julia_install_package("RCall"))
    expect_null(julia_install_package_if_needed("RCall"))
    # expect_gte(utils::compareVersion(julia_installed_package("RCall"), "0.7.4"), 0)
    expect_null(julia_library("RCall"))
})
