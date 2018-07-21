#' @export
length.JuliaObject <- function(x){
    tryCatch(julia$simple_call("length", x),
             warn = function(e){},
             error = function(e) 1
    )
}

as_index <- function(i){
    if (is.logical(i)) return(i)
    as.integer(i)
}

as_indexes <- function(ii){
    lapply(ii, as_index)
}

#' @export
`[.JuliaObject` <- function(x, ...){
    julia_do.call("getindex", c(list(x), as_indexes(list(...))))
}
#' @export
`[[.JuliaObject` <- function(x, i, exact = TRUE){
    if (length(i) > 1) {
        stop("Attempt to select more than one element.")
    }
    julia$simple_call("getindex", x, as.integer(i))
}
#' @export
`[<-.JuliaObject` <- function(x, ..., value){
    julia_do.call("JuliaCall.assign!", c(list(x, value), as_indexes(list(...))))
}
#' @export
`[[<-.JuliaObject` <- function(x, i, value)
    julia_call("JuliaCall.assign!", x, value, as.integer(i))

#' @export
as.character.JuliaObject <- function(x, ...)
    tryCatch(julia$simple_call("JuliaCall.asCharacter", x),
             warning = function(w){},
             error = function(e){warning("as.character(x) failed; return(x) instead."); x}
    )

#' @export
as.list.JuliaObject <- function(x, ...)
    tryCatch(julia_call("RCall.sexp", julia_eval("RCall.VecSxp"), x),
             warning = function(w){},
             error = function(e){list(x)})

#' @export
as.double.JuliaObject <- function(x, ...)
    tryCatch(julia$simple_call("JuliaCall.asDouble", x),
             warning = function(w){},
             error = function(e){warning("as.double(x) failed; return(x) instead."); x}
    )

#' @export
as.integer.JuliaObject <- function(x, ...)
    as.integer(as.double(x))
#' @export
as.logical.JuliaObject <- function(x, ...)
    tryCatch(julia$simple_call("JuliaCall.asLogical", x),
             warning = function(w){},
             error = function(e){warning("as.logical(x) failed; return(x) instead."); x}
    )

fdot <- function(x) paste0(as.character(x), ".")

## Ops Group

#' @export
Ops.JuliaObject <- function(e1, e2 = NULL){
    if (is.null(e2)) {
        return(JuliaPlain(julia$simple_call(fdot(.Generic), e1)))
    }
    JuliaPlain(julia$simple_call(fdot(.Generic), e1, e2))
}
#' @export
`%%.JuliaObject` <- function(e1, e2) julia$simple_call("mod.", e1, e2)
#' @export
`%/%.JuliaObject` <- function(e1, e2) julia$simple_call("div.", e1, e2)
#' @export
`&.JuliaObject` <- function(e1, e2) as.logical(e1) & as.logical(e2)
#' @export
`|.JuliaObject` <- function(e1, e2) as.logical(e1) | as.logical(e2)

## Math Group

#' @export
Math.JuliaObject <- function(x, ...) julia$simple_call(fdot(.Generic), x)
#' @export
ceiling.JuliaObject <- function(x) julia$simple_call("ceil.", x)
#' @export
cummax.JuliaObject <- function(x) julia$simple_call("JuliaCall.cummax1", x)
#' @export
cummin.JuliaObject <- function(x) julia$simple_call("JuliaCall.cummin1", x)
#' @export
cumsum.JuliaObject <- function(x) julia$simple_call("JuliaCall.cumsum1", x)
#' @export
cumprod.JuliaObject <- function(x) julia$simple_call("JuliaCall.cumprod1", x)

## Math2 Group

#' @export
round.JuliaObject <-
    function(x, digits = 0) julia$simple_call("round.", x, as.integer(digits))

#' @export
signif.JuliaObject <-
    function(x, digits = 6) julia$simple_call("signif.", x, as.integer(digits))

## Summary Group Unfinished

#' @export
Summary.JuliaObject <-
    function(x, ..., na.rm = FALSE) julia$simple_call(as.character(.Generic), x)

#' @export
max.JuliaObject <-
    function(..., na.rm = FALSE) julia_call("JuliaCall.Rmax", ...)

## Array related

#' @export
as.vector.JuliaObject <- function(x, mode = "any"){
    if (length(x) == 1) x
    else tryCatch(julia$simple_call("vec", x), warning = function(w){}, error = function(e){x})
}

#' @export
dim.JuliaObject <- function(x) julia$simple_call("JuliaCall.dim", x)

#' @export
`dim<-.JuliaObject` <- function(x, value)
    julia_do.call("reshape", c(list(x), as.integer(value)))

#' @export
aperm.JuliaObject <- function(a, perm, ...)
    julia$simple_call("permutedims", a, as.integer(perm))

#' @export
is.array.JuliaObject <- function(x) julia$simple_call("JuliaCall.isArray", x)

#' @export
is.matrix.JuliaObject <- function(x) julia$simple_call("JuliaCall.isMatrix", x)

## Mean

#' @export
mean.JuliaObject <- function(x, ...) julia$simple_call("mean", x)

#' @export
determinant.JuliaObject <- function(x, logarithm = TRUE, ...){
    r <- julia$simple_call("logabsdet", x)
    names(r) <- c("modulus", "sign")
    r$sign <- r$sign + 0.0
    r
}

#' @export
solve.JuliaObject <- function(a, b, ...){
    if (missing(b)) {
        return(julia$simple_call("inv", a))
    }
    julia$simple_call("\\", a, b)
}

#' @export
c.JuliaObject <- function(...){
    dots <- list(...)
    if (length(dots) == 1) return(dots[[1]])
    dots
}

#' @export
t.JuliaObject <- function(x){
    julia$simple_call("transpose", x)
}
