orig_unlist <- function (x, recursive = TRUE, use.names = TRUE){
    if (.Internal(islistfactor(x, recursive))) {
        lv <- unique(.Internal(unlist(lapply(x, levels), recursive,
                                      FALSE)))
        nm <- if (use.names)
            names(.Internal(unlist(x, recursive, use.names)))
        res <- .Internal(unlist(lapply(x, as.character), recursive,
                                FALSE))
        res <- match(res, lv)
        structure(res, levels = lv, names = nm, class = "factor")
    }
    else .Internal(unlist(x, recursive, use.names))
}

#' @export
unlist <- function(x, recursive = TRUE, use.names = TRUE)
    UseMethod("unlist", x)

unlist.default <- function(x, recursive = TRUE, use.names = TRUE)
    orig_unlist(x, recursive = recursive, use.names = use.names)

unlist.list <- function(x, recursive = TRUE, use.names = TRUE){
    if (length(x) > 0 && inherits(x[[1]], "JuliaObject")) {
        return(JuliaCall::julia_do.call("vcat", x))
    }
    orig_unlist(x, recursive, use.names)
}
