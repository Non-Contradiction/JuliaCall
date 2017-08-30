context("Example test")

check_julia <- function() {
    if (!julia_check()) {
        skip("Julia not available")
    }
}

test_that("test of the basic functionality", {
    skip_on_cran()
    check_julia()
    julia <- julia_setup()

    ## Different ways for calculating `sqrt(2)`
    # julia$command("a = sqrt(2)"); julia$eval_string("a")
    julia_command("a = sqrt(2)"); julia_eval_string("a")
    # julia$eval_string("sqrt(2)")
    julia_eval_string("sqrt(2)")
    # julia$call("sqrt", 2)
    julia_call("sqrt", 2)
    # julia$eval_string("sqrt")(2)
    julia_eval_string("sqrt")(2)
    ## You can use `julia_exists` as `exists` in R to test
    ## whether a function or name exists in Julia or not
    # julia$exists("sqrt")
    julia_exists("sqrt")
    ## You can use `julia$help` to get help for Julia functions
    # julia$help("sqrt")
    julia_help("sqrt")
    julia_library("RCall")
    ## You can install and use Julia packages through JuliaCall
    # julia$install_package("Optim")
    # julia_install_package("Optim")
    # julia$install_package_if_needed("Optim")
    # julia_install_package_if_needed("Optim")
    # julia$installed_package("Optim")
    # julia_installed_package("Optim")
    # julia$library("Optim")
    # julia_library("Optim")
})
