#' @export
unlist.JuliaObject <- function(x, recursive = TRUE, use.names = TRUE){
    tryCatch(julia_call("JuliaCall::vcat", x),
             warn = function(e){},
             error = function(e) x
    )
}

#' @export
rep.JuliaObject <- function(x, times, ...){
    julia_call("JuliaCall::rep", x, as.integer(times))
}
