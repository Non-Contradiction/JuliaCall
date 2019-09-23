# #' @import R6
# juliaobject <- R6::R6Class("JuliaObject",
#                            public = list(
#                                initialize = function(id = 0L, type = "Regular"){
#                                    if (private$locked) return(invisible(self))
#                                    private$id <- id
#                                    private$locked <- TRUE
#                                    if (!identical(type, "Regular")) {
#                                        extendJuliaObj(self, type)
#                                    }
#                                },
#                                getID = function(){
#                                    private$id
#                                },
#                                print = function(...){
#                                    cat(paste0("Julia Object of type ",
#                                               julia_call("JuliaCall.str_typeof", self),
#                                               ".\n",
#                                               julia_call("JuliaCall.show_string", self)))
#                                    #julia_call("show", self, need_return = FALSE)
#
#                                    invisible(self)
#                                }
#                                # finalize = function() {
#                                #     julia_call("JuliaCall.rm_obj", private$id)
#                                #     invisible(NULL)
#                                # }
#                            ),
#                            private = list(id = 0L, locked = FALSE),
#                            lock_objects = FALSE,
#                            lock_class = TRUE,
#                            cloneable = FALSE)

rmobj <- function(e){
    print("HI")
}

# juliaobject <- new.env()
juliaobjectnew <- function(id, type = "Regular"){
    self <- new.env(parent = emptyenv())
    self$id <- id
    if (!identical(type, "Regular")) {
        extendJuliaObj(self, type)
    }
    # self$getID <- function() self$id
    class(self) <- "JuliaObject"
    self$. <- function(...) julia_call("JuliaCall.apply", self, ...)

    # debugging for freeing
    # reg.finalizer(self, rmobj)

    self
}

#' @export
print.JuliaObject <- function(x, ...){
    cat(paste0("Julia Object of type ",
               julia$simple_call("JuliaCall.str_typeof", x),
               ".\n",
               julia$simple_call("JuliaCall.show_string", x)))
    #julia_call("show", self, need_return = FALSE)

    invisible(x)
}

#' Convert an R Object to Julia Object.
#'
#' \code{JuliaObject} converts an R object to julia object
#'   and returns a reference of the corresponding julia object.
#'
#' @param x the R object you want to convert to julia object.
#'
#' @return an environment of class JuliaObject,
#' which contains an id corresponding to the actual julia object.
#'
#' @examples
#'
#' \donttest{ ## julia_setup is quite time consuming
#'   a <- JuliaObject(1)
#' }
#'
#' @export
JuliaObject <- function(x){
    julia$simple_call("JuliaCall.JuliaObject", x)
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
    as.character(
        tryCatch(julia$simple_call("string.",
                            julia$simple_call("fieldnames", julia$simple_call("typeof", object))),
                 warn = function(w){},
                 error = function(e) NULL)
    )
}

#' @rdname JuliaObjectFields
#' @export
field <- function(object, name){
    UseMethod("field", object)
}

#' @rdname JuliaObjectFields
#' @export
field.JuliaObject <- function(object, name){
    tryCatch(julia$simple_call("getfield", object, as.symbol(name)),
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
    julia$simple_call("JuliaCall.setfield1!", object, as.symbol(name), value)
    object
}

#' @export
`$.JuliaObject` <- function(x, name){
    if (as.character(substitute(name)) %in% names(x))
        NextMethod(x, name)
    else field(x, name)
}
