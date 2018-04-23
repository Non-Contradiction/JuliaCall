#' @export
length.JuliaObject <- function(x){
    tryCatch(julia_call("length", x),
             warn = function(e){},
             error = function(e) 1
    )
}
#' @export
`[.JuliaObject` <- function(x, i) julia_call("getindex", x, as.integer(i))
#' @export
`[[.JuliaObject` <- function(x, i, exact = TRUE){
    if (length(i) > 1) {
        stop("Attempt to select more than one element.")
    }
    julia_call("getindex", x, as.integer(i))
}
#' @export
`[<-.JuliaObject` <- function(x, i, value)
    julia_call("setindex!", x, value, as.integer(i))
#' @export
`[[<-.JuliaObject` <- function(x, i, value)
    julia_call("setindex!", x, value, as.integer(i))

#' @export
as.character.JuliaObject <- function(x, ...)
    julia_call("JuliaCall.asCharacter", x)
#' @export
as.list.JuliaObject <- function(x, ...)
    julia_call("RCall.sexp", julia_eval("RCall.VecSxp"), x)
#' @export
as.double.JuliaObject <- function(x, ...)
    julia_call("JuliaCall.asDouble", x)
#' @export
as.integer.JuliaObject <- function(x, ...)
    as.integer(as.double(x))
#' @export
as.logical.JuliaObject <- function(x, ...)
    julia_call("JuliaCall.asLogical", x)

fdot <- function(x) paste0(as.character(x), ".")

## Ops Group

#' @export
Ops.JuliaObject <- function(e1, e2) julia_call(fdot(.Generic), e1, e2)
#' @export
`%%.JuliaObject` <- function(e1, e2) julia_call("mod.", e1, e2)
#' @export
`%/%.JuliaObject` <- function(e1, e2) julia_call("div.", e1, e2)
#' @export
`&.JuliaObject` <- function(e1, e2) as.logical(e1) & as.logical(e2)
#' @export
`|.JuliaObject` <- function(e1, e2) as.logical(e1) | as.logical(e2)

## Math Group

#' @export
Math.JuliaObject <- function(x, ...) julia_call(fdot(.Generic), x)
#' @export
ceiling.JuliaObject <- function(x) julia_call("ceil.", x)
#' @export
cummax.JuliaObject <- function(x) julia_call("JuliaCall.cummax1", x)
#' @export
cummin.JuliaObject <- function(x) julia_call("JuliaCall.cummin1", x)
#' @export
cumsum.JuliaObject <- function(x) julia_call("JuliaCall.cumsum1", x)
#' @export
cumprod.JuliaObject <- function(x) julia_call("JuliaCall.cumprod1", x)

## Math2 Group

#' @export
round.JuliaObject <-
    function(x, digits = 0) julia_call("round.", x, as.integer(digits))

#' @export
signif.JuliaObject <-
    function(x, digits = 6) julia_call("signif.", x, as.integer(digits))

## Summary Group Unfinished

#' @export
Summary.JuliaObject <-
    function(x, ..., na.rm = FALSE) julia_call(as.character(.Generic), x)
