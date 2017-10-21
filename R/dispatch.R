#' @export
`^.JuliaObject` <- function(x, n) julia_call("^.", x, n)
#' @export
`+.JuliaObject` <- function(x, n) julia_call("+.", x, n)
#' @export
`-.JuliaObject` <- function(x, n) julia_call("-.", x, n)
#' @export
`*.JuliaObject` <- function(x, n) julia_call("*.", x, n)
#' @export
`/.JuliaObject` <- function(x, n) julia_call("/.", x, n)
#' @export
`==.JuliaObject` <- function(x, n) julia_call("==", x, n)
#' @export
`!=.JuliaObject` <- function(x, n) julia_call("!=", x, n)
#' @export
length.JuliaObject <- function(x) julia_call("length", x)
#' @export
exp.JuliaObject <- function(x) julia_call("exp.", x)
#' @export
sum.JuliaObject <- function(x, ..., na.rm = FALSE){
    stopifnot(length(list(...)) == 0)
    julia_call("sum", x)
}
#' @export
`[.JuliaObject` <- function(x, i) julia_call("getindex", x, i)

#' @export
as.character.JuliaObject <- function(x, ...)
    julia_call("string", x)
#' @export
as.list.JuliaObject <- function(x, ...)
    julia_call("RCall.sexp", julia_eval("RCall.VecSxp"), x)
#' @export
as.double.JuliaObject <- function(x, ...)
    julia_call("RCall.sexp", julia_eval("RCall.RealSxp"), x)
