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

    if (julia$useRCall) {
        ## in the hook RCall.rgui_start() will be executed,
        ## then when we quit the console,
        ## RCall.rgui_stop() needs to be executed.
        julia_command("RCall.rgui_stop()")
    }
}

julia_incomplete_console <- function(){
    message("It seems that you are not in the terminal. A simple julia console will be started.")
    message("Press ESC or CTRL+C to exit.")
    on.exit(message("Exiting julia console."))
    buffer <- character()

    utils::rc.options(custom.completer = function(env) {
        env$comps <- julia_call("JuliaCall.completion", env$token)
    })
    on.exit({
        utils::rc.options(custom.completer = NULL)
    }, add = TRUE)

    repeat {
        prompt <- ifelse(length(buffer), "       ", "julia> ")
        if (nchar(line <- readline(prompt))) {
            buffer <- paste(buffer, line)
        }
        if (identical(buffer, "exit"))
            break
        if (length(buffer) && (!julia_call("JuliaCall.incomplete", buffer) || !nchar(line))) {
            tryCatch(julia_call("JuliaCall.eval_and_print", buffer, need_return = FALSE),
                     error = function(e) {
                         message(e$message)
                     })
            buffer <- character()
        }
    }
}
