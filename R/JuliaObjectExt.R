.juliaobjtable <- new.env(parent = emptyenv())

#' Use automatic wrapper for julia type.
#'
#' \code{autowrap} tells `JuliaCall` to use automatic wrapper for julia type.
#'
#' @param type the julia type to wrap.
#' @param fields names of fields to be included in the wrapper.
#'   If the value is NULL, then every julia fields will be included in the wrapper.
#' @param methods names of methods to be overloaded for the wrapper.
#'
#' @export
autowrap <- function(type, fields = NULL, methods = c()){
    addExt(type, fields, methods)
    cmd <- paste0('@eval JuliaCall @suppress_err begin sexp(x :: Main.',
                  type,
                  ') = sexp(JuliaObject(x, "',
                  type,
                  '")) end;')
    # print(cmd)
    julia_command(cmd)
}

addExt <- function(type, fields = NULL, methods = c()){
    if (is.null(fields)) {
        fields <- julia_call("string.", julia_eval(paste0("fieldnames(", type, ")")))
    }
    .juliaobjtable[[type]] <- list(fields = fields, methods = methods)
}

extendJuliaObj <- function(env, type){
    r <- .juliaobjtable[[type]]
    if (!is.null(r)) {
        for (field in r$fields) makeAttr(env, field)
        for (method in r$methods) makeMethod(env, method)
    }
}

makeAttr <- function(env, name){
    force(name)
    force(env)
    makeActiveBinding(name, function() field(env, name), env)
}

makeMethod <- function(env, name){
    force(name)
    force(env)
    assign(name, function(...) julia_call(name, env, ...), env)
}
