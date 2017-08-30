#' Language piper for julia language.
#'
#' @description The experimental language piper for julia language.
#'
#' @param obj the object to pass to the piper.
#' @param func_call the impartial julia function call.
#'
#' @examples
#' if (julia_check()) {
#'   \dontrun{ ## julia_setup is quite time consuming
#'   julia <- julia_setup()
#'   2 %>J% sqrt
#'   3 %>J% log(2)
#'   }
#' }
#'
#' @export
`%>J%` <- function(obj, func_call){
    r <- substitute(func_call)
    if (inherits(r, "name")) {
        return(julia$call(deparse(r), obj))
    }
    if (inherits(r, "call")) {
        return(julia$do.call(deparse(r[[1]]), append(obj, as.list(r[-1]))))
    }
    return(NULL)
}
