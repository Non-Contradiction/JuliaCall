#' Wrap julia functions and packages the easy way.
#'
#' @param pkg_name the julia package name to be wrapped.
#' @param func_name the julia function name to be wrapped.
#' @param func_list the list of julia function names to
#'     be wrapped.
#' @param env the environment where the functions and packages
#'     are wrapped.
#' @param hook the function to be executed
#'     before the execution of wrapped functions.
#' @examples
#' if (identical(Sys.getenv("AUTO_JULIA_INSTALL"), "true")) { ## julia_setup is quite time consuming
#'   ## do initialization and automatic installation of Julia if necessary
#'   julia_setup(installJulia = TRUE)
#'   julia_install_package_if_needed("Optim")
#'   opt <- julia_pkg_import("Optim",
#'                            func_list = c("optimize", "BFGS"))
#' rosenbrock <- function(x) (1.0 - x[1])^2 + 100.0 * (x[2] - x[1]^2)^2
#' result <- opt$optimize(rosenbrock, rep(0,2), opt$BFGS())
#' result
#' }
#'
#' @name julia_pkg_wrap
NULL

#' @rdname julia_pkg_wrap
#' @export
julia_function <- function(func_name, pkg_name = "Main",
                           env = new.env(emptyenv())){
  fname <- paste0(pkg_name, ".", func_name)
  force(fname)
  f <- function(...,
                need_return = c("R", "Julia", "None"),
                show_value = FALSE){
    if (!isTRUE(env$initialized) && is.function(env$setup)) {
      env$setup()
    }
    julia_do.call(func_name = fname, list(...),
                  need_return = match.arg(need_return),
                  show_value = show_value)
  }
  force(f)
  env[[func_name]] <- f
  f
}

#' @rdname julia_pkg_wrap
#' @export
julia_pkg_import <- function(pkg_name, func_list,
                             env = new.env(parent = emptyenv())){
  env$setup <- function(...){
    julia_setup(...)
    julia_library(pkg_name)
    for (hook in env$hooks) {
      if (is.function(hook)) {hook()}
      else {warning("Some hook is not a function.")}
    }
    env$initialized <- TRUE
  }
  for (fname in func_list) {
    julia_function(func_name = fname,
                   pkg_name = pkg_name,
                   env = env)
  }
  reg.finalizer(env,
                function(e) e$initialized <- FALSE,
                onexit = TRUE)
  env
}

#' @rdname julia_pkg_wrap
#' @export
julia_pkg_hook <- function(env, hook){
  if (is.function(hook)) {env$hooks <- c(env$hooks, hook)}
  else {warning("Some hook is not a function.")}
  env
}
