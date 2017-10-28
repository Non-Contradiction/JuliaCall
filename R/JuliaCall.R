#' JuliaCall: Seamless Integration Between R and Julia.
#'
#' JuliaCall provides you with functions to call Julia functions and
#' to use Julia packages as easy as possible.
#'
#' @examples
#'
#'   ## Do initiation for JuliaCall
#'
#'   julia <- julia_setup()
#'
#'   ## Different ways for calculating `sqrt(2)`
#'
#'   # julia$command("a = sqrt(2)"); julia$eval("a")
#'   julia_command("a = sqrt(2)"); julia_eval("a")
#'
#'   # julia$eval("sqrt(2)")
#'   julia_eval("sqrt(2)")
#'
#'   # julia$call("sqrt", 2)
#'   julia_call("sqrt", 2)
#'
#'   # julia$eval("sqrt")(2)
#'   julia_eval("sqrt")(2)
#'
#'   ## You can use `julia_exists` as `exists` in R to test
#'   ## whether a function or name exists in Julia or not
#'
#'   # julia$exists("sqrt")
#'   julia_exists("sqrt")
#'
#'   ## You can use `julia$help` to get help for Julia functions
#'
#'   # julia$help("sqrt")
#'   julia_help("sqrt")
#'
#'   ## You can install and use Julia packages through JuliaCall
#'
#'   # julia$install_package("Optim")
#'   julia_install_package("Optim")
#'
#'   # julia$install_package_if_needed("Optim")
#'   julia_install_package_if_needed("Optim")
#'
#'   # julia$installed_package("Optim")
#'   julia_installed_package("Optim")
#'
#'   # julia$library("Optim")
#'   julia_library("Optim")
#'
#' @docType package
#' @name JuliaCall
NULL
