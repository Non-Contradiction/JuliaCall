#' \code{do.call} for julia.
#'
#' \code{julia_do.call} is the \code{do.call} for julia.
#'
#' @param func_name the name of julia function you want to call.
#' @param arg_list the unnamed list of the arguments you want to pass to the julia function.
#' @param need_return whether you want the julia to return value or not.
#'
#' @examples
#'
#' if (julia_check()) {
#'   julia <- julia_setup()
#'
#'   julia_do.call("sqrt", list(2))
#' }
#'
#' @export
julia_do.call <- julia$do.call <- function(func_name, arg_list, need_return = TRUE){
    if (!(length(func_name) == 1 && is.character(func_name))) {
        stop("func_name should be a character scalar.")
    }
    if (!(is.list(arg_list))) {
        stop("arg_list should be the list of arguments.")
    }
    if (!(is.null(names(arg_list)))) {
        stop("JuliaCall currently doesn't accept named arguments, we are working on that.")
    }
    if (!(length(need_return) == 1 && is.logical(need_return))) {
        stop("need_return should be a logical scalar.")
    }
    r <- .julia$do.call_(func_name, arg_list, need_return)
    if (inherits(r, "error")) stop(r)
    if (need_return) return(r)
    invisible(r)
}

#' Call julia functions.
#'
#' \code{julia_call} calls julia functions.
#'
#' @param func_name the name of julia function you want to call.
#' @param ... the unnamed arguments you want to pass to the julia function.
#' @param need_return whether you want the julia return value or not.
#'
#' @examples
#'
#' if (julia_check()) {
#'   julia <- julia_setup()
#'
#'   julia_call("sqrt", 2)
#' }
#'
#' @export
julia_call <- julia$call <- function(func_name, ..., need_return = TRUE)
    julia$do.call(func_name, list(...), need_return)

#' Check whether a julia object with the given name exists or not.
#'
#' \code{julia_exists} returns whether a julia object with the given name exists or not.
#'
#' @param name the name of julia object you want to check.
#'
#' @examples
#'
#' if (julia_check()) {
#'   julia <- julia_setup()
#'
#'   julia_exists("sqrt")
#' }
#'
#' @export
julia_exists <- julia$exists <- function(name) julia$call("JuliaCall.exists", name)

#' Evaluate string commands in julia and get the result.
#'
#' \code{julia_eval_string} evaluates string commands in julia and
#' returns the result (automatically converted to an R object).
#' If you don't need the result, maybe you could
#' try \code{julia_command}.
#'
#' @param cmd the command string you want to evaluate in julia.
#'
#' @return the R object automatically converted from julia object.
#'
#' @examples
#'
#' if (julia_check()) {
#'   julia <- julia_setup()
#'
#'   julia_eval_string("sqrt(2)")
#' }
#'
#' @export
julia_eval_string <- julia$eval_string <-
    function(cmd) julia$call("JuliaCall.eval_string", cmd)

#' Evaluate string commands in julia.
#'
#' \code{julia_command} evaluates string commands in julia
#' without returning the result.
#' If you need the result, maybe you could
#' try \code{julia_eval_string}.
#'
#' @param cmd the command string you want to evaluate in julia.
#'
#' @examples
#'
#' if (julia_check()) {
#'   julia <- julia_setup()
#'
#'   julia_command("a = sqrt(2)")
#' }
#'
#' @export
julia_command <- julia$command <-
    function(cmd) julia$call("JuliaCall.eval_string", cmd, need_return = FALSE)

#' Source a julia source file.
#'
#' \code{julia_source} sources a julia source file.
#'
#' @param file_name the name of julia source file.
#'
#' @export
julia_source <- julia$source <-
    function(file_name) julia$call("include", file_name, need_return = FALSE)

#' Get help for a julia function.
#'
#' \code{julia_help} outputs the documentation of a julia function.
#'
#' @param fname the name of julia function you want to get help with.
#'
#' @examples
#'
#' if (julia_check()) {
#'   julia <- julia_setup()
#'
#'   julia_help("sqrt")
#' }
#'
#' @export
julia_help <- julia$help <- function(fname){
    cat(julia$call("JuliaCall.help", fname))
}
