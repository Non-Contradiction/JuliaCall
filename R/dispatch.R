#' @export
`^.JuliaObject` <- function(x, n) julia_call("^", x, n)
#' @export
`+.JuliaObject` <- function(x, n) julia_call("+", x, n)
#' @export
`-.JuliaObject` <- function(x, n) julia_call("-", x, n)
#' @export
`*.JuliaObject` <- function(x, n) julia_call("*", x, n)
#' @export
`/.JuliaObject` <- function(x, n) julia_call("/", x, n)
#' @export
`==.JuliaObject` <- function(x, n) julia_call("==", x, n)
#' @export
`!=.JuliaObject` <- function(x, n) julia_call("!=", x, n)
#' @export
length.JuliaObject <- function(x) julia_call("length", x)
#' @export
exp.JuliaObject <- function(x) julia_call("exp", x)
#' @export
sum.JuliaObject <- function(x, ...) julia_call("sum", x)

#' @export
`^.JuliaArray` <- function(x, n) julia_call("^.", x, n)
#' @export
`+.JuliaArray` <- function(x, n) julia_call("+.", x, n)
#' @export
`-.JuliaArray` <- function(x, n) julia_call("-.", x, n)
#' @export
`*.JuliaArray` <- function(x, n) julia_call("*.", x, n)
#' @export
`/.JuliaArray` <- function(x, n) julia_call("/.", x, n)
#' @export
`==.JuliaArray` <- function(x, n) julia_call("==", x, n)
#' @export
`!=.JuliaArray` <- function(x, n) julia_call("!=", x, n)
#' @export
length.JuliaArray <- function(x) julia_call("length", x)
#' @export
exp.JuliaArray <- function(x) julia_call("exp.", x)
#' @export
`[.JuliaArray` <- function(x, i) julia_call("getindex", x, i)
#' @export
sum.JuliaArray <- function(x, ...) julia_call("sum", x)
