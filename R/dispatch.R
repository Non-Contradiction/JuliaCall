#' @export
length.JuliaObject <- function(x) julia_call("length", x)
#' @export
`[.JuliaObject` <- function(x, i) julia_call("getindex", x, as.integer(i))
#' @export
`[[.JuliaObject` <- function(x, i){
    if (length(i) > 1) {
        stop("Attempt to select more than one element.")
    }
    julia_call("getindex", x, as.integer(i))
}

#' @export
as.character.JuliaObject <- function(x, ...)
    julia_call("JuliaCall.asCharacter", x)
#' @export
as.list.JuliaObject <- function(x, ...)
    julia_call("RCall.sexp", julia_eval("RCall.VecSxp"), x)
#' @export
as.double.JuliaObject <- function(x, ...)
    julia_call("JuliaCall.asDouble", x)

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

dot_e1_e2 <- function(e1, e2) julia_call(fdot(.Generic), e1, e2)

#' @rdname S4JuliaObjectGeneric
#' @export
setMethod("Compare", "JuliaObject", dot_e1_e2)
#' @rdname S4JuliaObjectGeneric
#' @export
setMethod("Compare", c("ANY", "JuliaObject"), dot_e1_e2)
#' @rdname S4JuliaObjectGeneric
#' @export
setMethod("Compare", c("JuliaObject", "JuliaObject"), dot_e1_e2)

## Arith Group

#' @rdname S4JuliaObjectGeneric
#' @export
setMethod("Arith", "JuliaObject", dot_e1_e2)
#' @rdname S4JuliaObjectGeneric
#' @export
setMethod("Arith", c("ANY", "JuliaObject"), dot_e1_e2)
#' @rdname S4JuliaObjectGeneric
#' @export
setMethod("Arith", c("JuliaObject", "JuliaObject"), dot_e1_e2)

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
          function(x, digits) julia_call(fdot(.Generic), x, as.integer(digits)))

## Summary Group Unfinished

#' @rdname S4JuliaObjectGeneric
#' @export
setMethod("Summary", "JuliaObject",
          function(x, ..., na.rm = FALSE) julia_call(as.character(.Generic), x))
