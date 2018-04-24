#' @import R6
juliaobject <- R6::R6Class("JuliaObject",
                           public = list(
                               initialize = function(id = 0L){
                                   if (private$locked) return(invisible(self))
                                   private$id <- id
                                   private$locked <- TRUE
                               },
                               getID = function(){
                                   private$id
                               },
                               print = function(...){
                                   cat(paste0("Julia Object of type ",
                                              julia_call("JuliaCall.str_typeof", self),
                                              ".\n",
                                              julia_call("JuliaCall.show_string", self)))
                                   #julia_call("show", self, need_return = FALSE)

                                   invisible(self)
                               }
                               # finalize = function() {
                               #     julia_call("JuliaCall.rm_obj", private$id)
                               #     invisible(NULL)
                               # }
                           ),
                           private = list(id = 0L, locked = FALSE),
                           lock_class = TRUE,
                           cloneable = FALSE)

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
#' \donttest{ ## julia_setup is quite time consuming
#'   a <- JuliaObject(1)
#' }
#'
#' @export
JuliaObject <- function(x){
    julia_call("JuliaCall.JuliaObject", x)
}

#' JuliaObject Fields.
#'
#' Get the field names, get or set certain fields of an JuliaObject.
#'
#' @param object  the JuliaObject.
#' @param name  a character string specifying the fields to be accessed or set.
#' @param value the new value of the field of the JuliaObject.
#'
#' @name JuliaObjectFields
NULL

#' @rdname JuliaObjectFields
#' @export
fields <- function(object){
    UseMethod("fields", object)
}

#' @rdname JuliaObjectFields
#' @export
fields.JuliaObject <- function(object){
    tryCatch(julia_call("string.",
                        julia_call("fieldnames", julia_call("typeof", object))),
             warn = function(w){},
             error = function(e) NULL)
}

#' @rdname JuliaObjectFields
#' @export
field <- function(object, name){
    UseMethod("field", object)
}

#' @rdname JuliaObjectFields
#' @export
field.JuliaObject <- function(object, name){
    tryCatch(julia_call("getfield", object, as.symbol(name)),
             warn = function(w){},
             error = function(e) NULL)
}

#' @rdname JuliaObjectFields
#' @export
`field<-` <- function(object, name, value){
    UseMethod("field<-", object)
}

#' @rdname JuliaObjectFields
#' @export
`field<-.JuliaObject` <- function(object, name, value){
    julia_call("JuliaCall.setfield1!", object, as.symbol(name), value)
    object
}

#' @export
`$.JuliaObject` <- function(x, name){
    if (as.character(substitute(name)) %in% names(x))
        NextMethod(x, name)
    else field(x, name)
}
