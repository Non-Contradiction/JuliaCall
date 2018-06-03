JuliaPlain <- function(x){
    if (!is.object(x)) {
        class(x) <- "JuliaPlain"
    }
    x
}

#' @export
rep.JuliaPlain <- function(x, ...){
    JuliaPlain(NextMethod("rep"))
}

#' @export
as.logical.JuliaPlain <- function(x, ...){
    JuliaPlain(NextMethod("as.logical"))
}

#' @export
`[[<-.JuliaPlain` <- function(x, i, value)
    julia_call("JuliaCall.assign!", x, value, as.integer(i))
#' @export
`[<-.JuliaPlain` <- function(x, ..., value){
    julia_do.call("JuliaCall.assign!", c(x, value, as_indexes(list(...))))
}


