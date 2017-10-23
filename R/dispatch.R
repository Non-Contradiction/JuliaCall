#' @export
length.JuliaObject <- function(x) julia_call("length", x)
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

#' S4 Group Generic Functions for JuliaObject.
#'
#' S4 Group Generic Functions for JuliaObject, which includes common mathematical
#'   functions and operators.
#'
#' @param x,e1,e2  objects.
#' @param digits  number of digits to be used in round or signif.
#' @param ...  further arguments passed to or from methods.
#' @param na.rm	 logical: should missing values be removed?
#'
#' @name S4JuliaObjectGeneric
NULL

fdot <- function(x) paste0(as.character(x), ".")

## Compare Group

#' @rdname S4JuliaObjectGeneric
#' @export
setMethod("Compare", "JuliaObject",
          function(e1, e2) julia_call(fdot(.Generic), e1, e2))
#' @rdname S4JuliaObjectGeneric
#' @export
setMethod("Compare", c("ANY", "JuliaObject"),
          function(e1, e2) julia_call(fdot(.Generic), e1, e2))
#' @rdname S4JuliaObjectGeneric
#' @export
setMethod("Compare", c("JuliaObject", "JuliaObject"),
          function(e1, e2) julia_call(fdot(.Generic), e1, e2))

## Arith Group

#' @rdname S4JuliaObjectGeneric
#' @export
setMethod("Arith", "JuliaObject",
          function(e1, e2) julia_call(fdot(.Generic), e1, e2))
#' @rdname S4JuliaObjectGeneric
#' @export
setMethod("Arith", c("ANY", "JuliaObject"),
          function(e1, e2) julia_call(fdot(.Generic), e1, e2))
#' @rdname S4JuliaObjectGeneric
#' @export
setMethod("Arith", c("JuliaObject", "JuliaObject"),
          function(e1, e2) julia_call(fdot(.Generic), e1, e2))

#' @rdname S4JuliaObjectGeneric
#' @export
setMethod("%%", "JuliaObject",
          function(e1, e2) julia_call(fdot("mod"), e1, e2))
#' @rdname S4JuliaObjectGeneric
#' @export
setMethod("%%", c("ANY", "JuliaObject"),
          function(e1, e2) julia_call(fdot("mod"), e1, e2))
#' @rdname S4JuliaObjectGeneric
#' @export
setMethod("%%", c("JuliaObject", "JuliaObject"),
          function(e1, e2) julia_call(fdot("mod"), e1, e2))
#' @rdname S4JuliaObjectGeneric
#' @export
setMethod("%/%", "JuliaObject",
          function(e1, e2) julia_call(fdot("div"), e1, e2))
#' @rdname S4JuliaObjectGeneric
#' @export
setMethod("%/%", c("ANY", "JuliaObject"),
          function(e1, e2) julia_call(fdot("div"), e1, e2))
#' @rdname S4JuliaObjectGeneric
#' @export
setMethod("%/%", c("JuliaObject", "JuliaObject"),
          function(e1, e2) julia_call(fdot("div"), e1, e2))

## Math Group Unfinished

#' @rdname S4JuliaObjectGeneric
#' @export
setMethod("Math", "JuliaObject",
          function(x) julia_call(fdot(.Generic), x))

## Math2 Group

#' @rdname S4JuliaObjectGeneric
#' @export
setMethod("Math2", "JuliaObject",
          function(x, digits) julia_call(fdot(.Generic), x, digits))

## Summary Group Unfinished

#' @rdname S4JuliaObjectGeneric
#' @export
setMethod("Summary", "JuliaObject",
          function(x, ..., na.rm = FALSE) julia_call(as.character(.Generic), x))
