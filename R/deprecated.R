#' Evaluate string commands in julia and get the result.
#'
#' Deprecated in favor of julia_eval.
#'
#' @param cmd the command string you want to evaluate in julia.
#'
#' @export
julia_eval_string <- julia$eval_string <-
    function(cmd){
        .Deprecated("julia_eval")
        julia$call("JuliaCall.eval_string", cmd)
    }
