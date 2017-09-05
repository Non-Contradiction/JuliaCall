.julia <- new.env(parent = emptyenv())
.julia$initialized <- FALSE

julia <- new.env(parent = .julia)

#' Check whether julia is available on the path.
#'
#' \code{julia_check} checks if julia is available on the path. It is defunct.
#'
#' @export
julia_check <- function(){
    warning("julia_check is defunct, the functionality of julia_check is combined into julia_setup.")
    tryCatch(system('julia -e "println(1)"', intern = TRUE) == "1",
             warning = function(war){},
             error = function(err) FALSE)
}

julia_locate <- function(JULIA_HOME = NULL){
    if (is.null(JULIA_HOME)) {
        JULIA_HOME <- getOption("JULIA_HOME")
    }

    if (is.null(JULIA_HOME)) {
        tryCatch(system("julia -E \"println(JULIA_HOME)\"", intern = TRUE)[1],
                 warning = function(war){},
                 error = function(err) NULL)
    }
    else {
        tryCatch(system(paste0(file.path(JULIA_HOME, "julia"), " -E \"println(JULIA_HOME)\""), intern = TRUE)[1],
                 warning = function(war){},
                 error = function(err) NULL)
    }
}

julia_line <- function(command, ...){
    system(paste(file.path(.julia$bin_dir, "julia"), command), ...)
}

newer <- function(x, y) utils::compareVersion(x, y) >= 0
