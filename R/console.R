#' Open julia console.
#'
#' @description Open julia console.
#'
#' @examples
#' \dontrun{ ## julia_setup is quite time consuming
#'   julia <- julia_setup()
#'   julia_console()
#' }
#'
#' @export
julia_console <- julia$console <- function(){
    if (is_terminal()) {
        julia_complete_console()
    }
    else {
        julia_incomplete_console()
    }
}

is_terminal <- function(){
    julia_eval_string("isa(STDIN, Base.TTY)")
}

julia_complete_console <- function(){
    message("Preparing julia REPL, press Ctrl + D to quit julia REPL.")
    message("You could get more information in how to use julia REPL at <https://docs.julialang.org/en/stable/manual/interacting-with-julia/>")
    julia_command("Base._start()")
}

julia_incomplete_console <- function(){
    message("It seems that you are not in the terminal. A simple julia console will be started.")
    message("The simple julia console is not finished yet.")
}
