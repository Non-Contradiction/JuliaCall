# the way devtools deal with unlist has bugs, so temporarily commented out
#
# unlist.JuliaObject <- function(x, recursive = TRUE, use.names = TRUE){
#     tryCatch(julia_call("JuliaCall.vcat", x),
#              warn = function(e){},
#              error = function(e) x
#     )
# }

#' @export
rep.JuliaObject <- function(x, times = 1, length.out = NA, each = 1, ...){
    if (!is.na(length.out)) {
        times <- ceiling(length.out / length(x))
        return(julia_call("JuliaCall.rep", x, as.integer(times))[1:length.out])
    }
    julia_call("JuliaCall.rep", x, as.integer(times))
}
