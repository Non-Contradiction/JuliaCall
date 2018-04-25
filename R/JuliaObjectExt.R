.julia$ObjTable <- list()

autowrap <- function(type, fields = NULL, methods = c()){
    addExt(type, fields, methods)
    cmd <- paste0('@eval JuliaCall @suppress_err begin sexp(x :: Main.',
                  type,
                  ') = sexp(JuliaObject(x, "',
                  type,
                  '")) end;')
    julia_command(cmd)
}

addExt <- function(type, fields = NULL, methods = c()){
    if (is.null(fields)) {
        fields <- julia_call("string.", julia_eval(paste0("fieldnames(", type, ")")))
    }
    .julia$ObjTable[[type]] <- list(fields = fields, methods = methods)
}

extendJuliaObj <- function(env, type){
    r <- .julia$ObjTable[[type]]
    if (!is.null(r)) {
        makeAttrs(env, r$fields)
        makeMethods(env, r$methods)
    }
}

makeAttrs <- function(env, names){
  for (name in names) {
    f <- function(){
      force(env); force(name)
      field(env, name)
    }
    makeActiveBinding(name, f, env)
  }
}

makeMethods <- function(env, names){
    for (name in names) {
        f <- function(...){
            force(env); force(name)
            julia_call(name, env, ...)
        }
        env[[name]] <- f
    }
}
