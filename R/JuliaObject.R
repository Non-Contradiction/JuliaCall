setClass("JuliaObject",
         slots = list(id = "integer"))

## This function will be used by JuliaObject.jl to create new JuliaObject.
JuliaObjectFromId <- function(id) methods::new("JuliaObject", id = id)

#' Convert an R Object to Julia Object.
#'
#' \code{JuliaObject} converts an R object to julia object
#'   and returns a reference of the corresponding julia object.
#'
#' @param x the R object you want to convert to julia object.
#'
#' @return an S4 object of class JuliaObject
#' which contains an id correspond to the julia object.
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

#' Show JuliaObject.
#'
#' S4 method to show JuliaObject.
#'
#' @param object the JuliaObject you want to show.
#'
#' @export
setMethod("show", "JuliaObject",
          function(object){
              cat(paste0("Julia Object of type ", julia_call("JuliaCall.str_typeof", object), ".\n"))
              julia_call("show", object, need_return = FALSE)
              invisible(NULL)
          })
