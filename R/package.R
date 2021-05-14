#' Using julia packages.
#'
#' @param pkg_name the julia package name.
#' @param pkg_name_or_url the julia package name or url.
#' @param ... you can provide none or one or multiple julia package names here.
#' @return julia_installed_package will return the version number of the julia package,
#'     "nothing" if the package is not installed.
#' @examples
#' if (interactive()) { ## julia_setup is quite time consuming
#'   ## doing initialization and automatic installation of Julia if necessary
#'   julia_setup(installJulia = TRUE)
#'   julia_install_package("DataFrames")
#'   julia_installed_package("DataFrames")
#'   julia_install_package_if_needed("DataFrames")
#'   julia_update_package("DataFrames")
#'   julia_library("DataFrames")
#' }
#'
#' @name julia_package
NULL

#' @rdname julia_package
#' @export
julia_install_package <- julia$install_package <- function(pkg_name_or_url){
    if (newer(.julia$VERSION, "0.6.5")) {
        julia$command(paste0('pkg"add ', pkg_name_or_url, '"'))
    }
    else {
        julia$call("Pkg.add", pkg_name_or_url)
    }
}

#' @rdname julia_package
#' @export
julia_installed_package <- julia$installed_package <- function(pkg_name){
    julia$call("JuliaCall.installed_package", pkg_name)
}

#' @rdname julia_package
#' @export
julia_install_package_if_needed <- julia$install_package_if_needed <-
    function(pkg_name){
    if (julia$installed_package(pkg_name) == "nothing") {
        julia$install_package(pkg_name)
    }
}

#' @rdname julia_package
#' @export
julia_update_package <- julia$update_package <-
    function(...) julia$do.call("Pkg.update", list(...))

#' @rdname julia_package
#' @export
julia_library <- julia$library <- function(pkg_name){
    julia$command(paste0("using ", pkg_name))
}
