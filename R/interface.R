#' Call julia functions.
#'
#' \code{julia_do.call} is the \code{do.call} for julia.
#' And \code{julia_call} calls julia functions.
#'
#' @param func_name the name of julia function you want to call.
#' @param arg_list the list of the arguments you want to pass to the julia function.
#' @param ... the arguments you want to pass to the julia function.
#' @param need_return whether you want julia to return value as an R object,
#'   a wrapper for julia object or no return.
#'   The value of need_return could be TRUE (equal to option "R") or FALSE (equal to option "None"),
#'   or one of the options "R", "Julia" and "None".
#' @param show_value whether to display julia return value or not.
#'
#' @details Note that named arguments will be discarded if the call uses dot notation,
#'   for example, "sqrt.".
#'
#' @examples
#'
#' \donttest{ ## julia_setup is quite time consuming
#'   julia_do.call("sqrt", list(2))
#'   julia_call("sqrt", 2)
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
                  args = as.pairlist(arg_list),
                  need_return = need_return,
                  show_value = show_value)
    r <- .julia$do.call_(jcall)

    rmd <- identical(need_return, "None") && show_value && .julia$rmd
    if (rmd) return(output_return())

    if (inherits(r, "error")) stop(r)
    if (!identical(need_return, "None")) return(r)
    invisible(r)
}

#' @rdname call
#' @export
julia_call <- julia$call <- function(func_name, ..., need_return = c("R", "Julia", "None"), show_value = FALSE)
    julia$do.call(func_name, pairlist(...), need_return, show_value)

#' Check whether a julia object with the given name exists or not.
#'
#' \code{julia_exists} returns whether a julia object with the given name exists or not.
#'
#' @param name the name of julia object you want to check.
#'
#' @examples
#'
#' \donttest{ ## julia_setup is quite time consuming
#'   julia_exists("sqrt")
#' }
#'
#' @export
julia_exists <- julia$exists <- function(name) julia$call("JuliaCall.exists", name)

#' Evaluate string commands in julia and get the result.
#'
#' \code{julia_eval} evaluates string commands in julia and
#' returns the result (automatically converted to an R object or a JuliaObject wrapper).
#' If you don't need the result, maybe you could
#' try \code{julia_command}.
#'
#' @param cmd the command string you want to evaluate in julia.
#' @param need_return whether you want julia to return value as an R object or
#'   a wrapper for julia object.
#'
#' @return the R object automatically converted from julia object.
#'
#' @examples
#'
#' \donttest{ ## julia_setup is quite time consuming
#'   julia_eval("sqrt(2)")
#' }
#'
#' @export
julia_eval <- julia$eval <- function(cmd, need_return = c("R", "Julia"))
        julia$call("JuliaCall.eval_string", cmd, need_return = match.arg(need_return))

#' Evaluate string commands in julia.
#'
#' \code{julia_command} evaluates string commands in julia
#' without returning the result.
#' If you need the result, maybe you could
#' try \code{julia_eval}.
#'
#' @param cmd the command string you want to evaluate in julia.
#' @param show_value whether to display julia return value or not,
#'   the default value is `FALSE` if the `cmd` ends with semicolon
#'   and `TRUE` otherwise.
#'
#' @examples
#'
#' \donttest{ ## julia_setup is quite time consuming
#'   julia_command("a = sqrt(2);")
#' }
#'
#' @export
julia_command <- julia$command <-
    function(cmd, show_value = !endsWith(cmd, ";"))
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
    function(file_name) julia$call("include", file_name, need_return = FALSE)

#' Get help for a julia function.
#'
#' \code{julia_help} outputs the documentation of a julia function.
#'
#' @param fname the name of julia function you want to get help with.
#'
#' @examples
#'
#' \donttest{ ## julia_setup is quite time consuming
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
#' \donttest{ ## julia_setup is quite time consuming
#'   julia_assign("x", 2)
#'   julia_assign("rsqrt", sqrt)
#' }
#'
#' @export
julia_assign <- julia$assign <-
    function(x, value) julia$call("JuliaCall.assign", x, value, need_return = FALSE)

julia_simple_call <- julia$simple_call <- function(...){
    r <- .julia$simple_call_(...)
    if (inherits(r, "error")) stop(r)
    r
}
