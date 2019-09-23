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
    JuliaCall::julia_do.call(func_name = fname, list(...),
                             need_return = match.arg(need_return),
                             show_value = show_value)
  }
  force(f)
  env[[func_name]] <- f
  f
}

julia_pkg_import <- function(pkg_name, func_list){
  env <- new.env(parent = emptyenv())
  env$setup <- function(...){
    JuliaCall::julia_setup(...)
    JuliaCall::julia_library(pkg_name)
    env$initialized <- TRUE
  }
  for (fname in func_list) {
    julia_function(func_name = fname,
                   pkg_name = pkg_name,
                   env = env)
  }
  env
}
