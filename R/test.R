# `[.JuliaObject` <- function(x, ...) julia_call("getindex", x, ..., need_return = "J")
# length.JuliaObject <- function(x) julia_call("length", x, need_return = "J")
# sum.JuliaObject <- function(x) julia_call("sum", x, need_return = "J")
`^.JuliaObject` <- function(x, n) julia_call("^.", x, n)
`^.JuliaArray` <- function(x, n) julia_call("^.", x, n)
sum.JuliaObject <- function(x, ...) julia_call("sum", x)
sum.JuliaArray <- function(x, ...) julia_call("sum", x)
# `-.JuliaObject` <- function(x, y) julia_call("-.", x, y, need_return = "J")
# `+.JuliaObject` <- function(x, y) julia_call("+.", x, y, need_return = "J")
# `*.JuliaObject` <- function(x, y) julia_call("*.", x, y, need_return = "J")
# `^` <- function(e1, e2) UseMethod("^", c(e1, e2));
# `^.default` <- function(e1, e2) .Primitive("^")(e1,e2);
# `^.list` <- function(e1, e2) lapply(e1, function(x)x^e2)
#
# f <- function(x){
#     x^2
# }
#
# f <- function(x, y){
#     c(x, y) ^ 2
# }
#
# length.VEC <- function(x) attr(x, "len")
#
# f <- function(x){
#     n <- length(x)
# }
#
# make_name <- function(var, i) as.name(paste0(var, i))
#
# make_vec <- function(names){
#     pryr::make_call("c", .args = as.list(names))
# }
#
# expand_vector <- function(x, var, len, env){
#     vec <- sapply(1:len, make_name, var = var)
#     if (is.call(x) && length(x) >= 3 &&
#         identical(as.character(x[[1]]), "[") && identical(x[[2]], var))
#         return(make_vec(vec[eval(x[[3]], env)]))
#     if (is.name(x) && identical(x, var))
#         return(make_vec(vec[1:len]))
#     x
# }
