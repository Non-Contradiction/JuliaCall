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
sum.JuliaObject <- function(x, ...) julia_call("sum", x)
#' @export
`[.JuliaObject` <- function(x, i) julia_call("getindex", x, i)

