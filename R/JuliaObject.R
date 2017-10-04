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

#' Print Julia Object.
#'
#' \code{print.JuliaObject} is the method of the generic print function
#' for JuliaObject.
#'
#' @param x the Julia object you want to print.
#' @param ... further arguments to be passed to or from other methods.
#'   They are ignored in this function.
#'
#' @export
print.JuliaObject <- function(x, ...){
    cat(paste0("Julia Object of type ", julia_call("JuliaCall.str_typeof", x), ".\n"))
    julia_call("show", x, need_return = FALSE)
    invisible(x)
}
