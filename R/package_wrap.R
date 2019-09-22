function_wrap <- function(env, pkgname, fname){
  func_name <- paste0(pkgname, ".", fname)
  force(func_name)
  f <- function(...,
                need_return = c("R", "Julia", "None"),
                show_value = FALSE){
    if (!isTRUE(env$initialized)) {
      env$setup()
    }
    JuliaCall::julia_do.call(func_name = func_name, list(...),
                             need_return = match.arg(need_return),
                             show_value = show_value)
  }
  force(f)
  env[[fname]] <- f
}

pkg_wrap <- function(pkgname, func_list){
  env <- new.env(parent = emptyenv())
  env$setup <- function(...){
    JuliaCall::julia_setup(...)
    JuliaCall::julia_library(pkgname)
    env$initialized <- TRUE
  }
  for (fname in func_list) {
    function_wrap(env, pkgname, fname)
  }
  env
}
