#' Convert an R Object to Julia Object.
#'
#' \code{JuliaObject} converts an R object to julia object
#'   and returns a reference of the corresponding julia object.
#'
#' @param x the R object you want to convert to julia object.
#'
#' @return a S3 object with class JuliaObject
#' which contains a reference to the corresponding julia object.
#'
#' @examples
#'
#' \dontrun{ ## julia_setup is quite time consuming
#'   a <- JuliaObject(1)
#' }
#'
#' @export
JuliaObject <- function(x){
    julia_call("JuliaCall.JuliaObject", x)
}
