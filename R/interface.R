#' Call julia functions.
#'
#' \code{julia_do.call} is the \code{do.call} for julia.
#' And \code{julia_call} calls julia functions.
#' For usage of these functions, see documentation of arguments and examples.
#'
#' @param func_name the name of julia function you want to call.
#'   If you add "." after `func_name`,
#'   the julia function call will be broadcasted.
#' @param arg_list the list of the arguments you want to pass to the julia function.
#' @param ... the arguments you want to pass to the julia function.
#' @param need_return whether you want julia to return value as an R object,
#'   a wrapper for julia object or no return.
#'   The value of need_return could be TRUE (equal to option "R") or FALSE (equal to option "None"),
#'   or one of the options "R", "Julia" and "None".
#' @param show_value whether to invoke the julia display system or not.
#'
#' @details Note that named arguments will be discarded if the call uses dot notation,
#'   for example, "sqrt.".
#'
#' @examples
#'
#' if (interactive()) { ## julia_setup is quite time consuming
#'   ## doing initialization and automatic installation of Julia if necessary
#'   julia_setup(installJulia = TRUE)
#'   julia_do.call("sqrt", list(2))
#'   julia_call("sqrt", 2)
#'   julia_call("sqrt.", 1:10)
#' }
#'
#' @name call
NULL

#' @rdname call
#' @export
julia_do.call <- julia$do.call <- function(func_name, arg_list, need_return = c("R", "Julia", "None"), show_value = FALSE){
    ## stopifnot is quite slow, use multiple if
    # stopifnot(length(func_name) == 1, is.character(func_name), is.list(arg_list),
    #           length(show_value) == 1, is.logical(show_value))
    if (!length(func_name) == 1 || !is.character(func_name)) stop("func_name must be a character scalar.")
    # if (!is.list(arg_list)) stop("arg_list must be a list of arguments.")
    if (!length(show_value) == 1 || !is.logical(show_value)) stop("show_value must be a logical scalar.")
    if (is.character(need_return)) {
        need_return <- match.arg(need_return, c("R", "Julia", "None"))
    }
    else {
        if (identical(need_return, TRUE)) {
            need_return <- "R"
        }
        else {
            need_return <- "None"
        }
    }

    ## julia_setup() is not necessary,
    ## unless you want to pass some arguments to it.
    if (!.julia$initialized) {
        julia_setup()
    }

    ## This function is used to reset the RMarkdown output,
    ## see RMarkdown.R for more details.
    output_reset()

    # args <- separate_arguments(arglist = arg_list)
    # jcall <- list(fname = func_name,
    #               named_args = as.pairlist(args$named),
    #               unamed_args = args$unamed,
    #               need_return = need_return,
    #               show_value = show_value)
    jcall <- list(fname = func_name,
                  ##args = as.pairlist(arg_list),
                  args = arg_list,
                  need_return = need_return,
                  show_value = show_value)
    r <- .julia$do.call_(jcall)

    if (inherits(r, "error")) stop(r)

    rmd <- identical(need_return, "None") && show_value && .julia$rmd
    if (rmd) return(output_return())

    if (!identical(need_return, "None")) return(r)
    invisible(r)
}

#' @rdname call
#' @export
julia_call <- julia$call <- function(func_name, ..., need_return = c("R", "Julia", "None"), show_value = FALSE)
    julia$do.call(func_name, list(...), need_return, show_value)

#' Check whether a julia object with the given name exists or not.
#'
#' \code{julia_exists} returns whether a julia object with the given name exists or not.
#'
#' @param name the name of julia object you want to check.
#'
#' @examples
#'
#' if (interactive()) { ## julia_setup is quite time consuming
#'   ## doing initialization and automatic installation of Julia if necessary
#'   julia_setup(installJulia = TRUE)
#'   julia_exists("sqrt")
#' }
#'
#' @export
julia_exists <- julia$exists <- function(name) julia$call("JuliaCall.exists", name)

#' Evaluate string commands in julia and get the result back in R.
#'
#' \code{julia_eval} evaluates string commands in julia and
#' returns the result to R.
#' The returning julia object will be automatically converted
#' to an R object or a JuliaObject wrapper,
#' see the documentation of the argument `need_return` for more details.
#' `julia_eval` will not invoke julia display system.
#' If you don't need the returning result in R or
#' you want to invoke the julia display system, you can
#' use \code{julia_command}.
#'
#' @param cmd the command string you want to evaluate in julia.
#' @param need_return whether you want julia to return value as an R object or
#'   a wrapper for julia object.
#'
#' @return the R object automatically converted from julia object.
#'
#' @examples
#'
#' if (interactive()) { ## julia_setup is quite time consuming
#'   ## doing initialization and automatic installation of Julia if necessary
#'   julia_setup(installJulia = TRUE)
#'   julia_eval("sqrt(2)")
#' }
#'
#' @export
julia_eval <- julia$eval <- function(cmd, need_return = c("R", "Julia"))
        julia$call("JuliaCall.eval_string", cmd, need_return = match.arg(need_return))

#' Evaluate string commands in julia and (may) invoke the julia display system.
#'
#' \code{julia_command} evaluates string commands in julia
#' without returning the result back to R.
#' However, it may evoke julia display system,
#' see the documentation of the argument `show_value` for more details.
#' If you need to get the evaluation result in R, you can use
#' \code{julia_eval}.
#'
#' @param cmd the command string you want to evaluate in julia.
#' @param show_value whether to display julia returning value or not,
#'   the default value is `FALSE` if the `cmd` ends with semicolon
#'   and `TRUE` otherwise.
#'
#' @examples
#'
#' if (interactive()) { ## julia_setup is quite time consuming
#'   ## doing initialization and automatic installation of Julia if necessary
#'   julia_setup(installJulia = TRUE)
#'   julia_command("a = sqrt(2);")
#' }
#'
#' @export
julia_command <- julia$command <-
    function(cmd, show_value = !endsWith(trimws(cmd, "right"), ";"))
        julia$call("JuliaCall.eval_string", cmd,
                   need_return = FALSE,
                   show_value = show_value)

#' Source a julia source file.
#'
#' \code{julia_source} sources a julia source file.
#'
#' @param file_name the name of julia source file.
#'
#' @export
julia_source <- julia$source <-
    function(file_name) julia$call("JuliaCall.include1", file_name, need_return = FALSE)

#' Get help for a julia function.
#'
#' \code{julia_help} outputs the documentation of a julia function.
#'
#' @param fname the name of julia function you want to get help with.
#'
#' @examples
#'
#' if (interactive()) { ## julia_setup is quite time consuming
#'   ## doing initialization and automatic installation of Julia if necessary
#'   julia_setup(installJulia = TRUE)
#'   julia_help("sqrt")
#' }
#'
#' @export
julia_help <- julia$help <- function(fname){
    cat(julia$call("JuliaCall.help", fname))
}

#' Assign a value to a name in julia.
#'
#' \code{julia_assign} assigns a value to a name in julia with automatic type conversion.
#'
#' @param x a variable name, given as a character string.
#' @param value a value to be assigned to x, note that R value will be converted to
#'   corresponding julia value automatically.
#'
#' @examples
#'
#' if (interactive()) { ## julia_setup is quite time consuming
#'   ## doing initialization and automatic installation of Julia if necessary
#'   julia_setup(installJulia = TRUE)
#'   julia_assign("x", 2)
#'   julia_assign("rsqrt", sqrt)
#' }
#'
#' @export
julia_assign <- julia$assign <-
    function(x, value) julia$call("JuliaCall.assign", x, value, need_return = FALSE)

julia_simple_call <- julia$simple_call <- function(func, ...){
    # if (missing(arg2)) r <- .julia$simple_call_(func, arg1)
    # else r <- .julia$simple_call_(func, arg1, arg2)
    r <- .julia$simple_call_(func, ...)
    if (inherits(r, "error")) stop(r)
    r
}

julia_simple_do.call <- julia$simple_do.call <- function(func, args){
    do.call(julia_simple_call, c(list(func), args))
}
