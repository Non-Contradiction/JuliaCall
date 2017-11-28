#' Do initial setup for the JuliaCall package.
#'
#' \code{julia_setup} does the initial setup for the JuliaCall package.
#'
#' @param JULIA_HOME the path to julia binary,
#'     if not set, JuliaCall will look at the global option JULIA_HOME,
#'     if the global option is not set, JuliaCall will try to use
#'     the julia in path.
#' @param verbose whether to print out detailed information
#'     about \code{julia_setup}.
#' @param force whether to force julia_setup to execute again.
#' @param useRCall whether or not you want to use RCall.jl in julia,
#'     which is an amazing package to access R in julia.
#'
#' @return The julia interface, which is an environment with the necessary methods
#'   like command, source and things like that to communicate with julia.
#'
#' @examples
#'
#' \dontrun{ ## julia_setup is quite time consuming
#'   julia <- julia_setup()
#' }
#'
#' @export
julia_setup <- function(JULIA_HOME = NULL, verbose = TRUE, force = FALSE, useRCall = TRUE) {
    ## libR <- paste0(R.home(), '/lib')
    ## system(paste0('export LD_LIBRARY_PATH=', libR, ':$LD_LIBRARY_PATH'))

    if (!force && .julia$initialized) {
        return(invisible(julia))
    }

    JULIA_HOME <- julia_locate(JULIA_HOME)

    if (is.null(JULIA_HOME)) {
        stop("Julia is not found.")
    }

    .julia$bin_dir <- JULIA_HOME

    .julia$VERSION <- julia_line(c("-e", "print(VERSION)"), stdout = TRUE)

    if (verbose) message(paste0("Julia version ",
                                .julia$VERSION,
                                " at location ",
                                JULIA_HOME,
                                " will be used."))

    .julia$dll_file <- julia_line(c("-e", "print(Libdl.dlpath(\"libjulia\"))"), stdout = TRUE)

    if (verbose) message("Julia initiation...")

    if (.Platform$OS.type == "windows") {
        libopenlibm <- julia_line(c("-e", "print(Libdl.dlpath(\"libopenlibm\"))"), stdout = TRUE)
        dyn.load(libopenlibm)
    }

    juliacall_initialize(.julia$dll_file)

    if (verbose) message("Finish Julia initiation.")

    .julia$cmd <- function(cmd){
        if (!(length(cmd) == 1 && is.character(cmd))) {
            stop("cmd should be a character scalar.")
        }
        if (!juliacall_cmd(cmd)) {
            stop(paste0("Error happens when you try to execute command ", cmd, " in Julia."))
        }
    }

    reg.finalizer(.julia,
                  function(e){
                      message("Julia exit.");
                      juliacall_atexit_hook(0);
                      },
                  onexit = TRUE)

    ##.julia$cmd(paste0('ENV["R_HOME"] = "', R.home(), '"'))

    if (verbose) message("Loading setup script for JuliaCall...")

    install_dependency()

    if (!newer(.julia$VERSION, "0.7.0")) {
        ## message("Before 0.7.0")
        .julia$cmd(paste0('include("', system.file("julia/setup.jl", package = "JuliaCall"), '")'))
    }
    else {
        ## message("After 0.7.0")
        .julia$cmd(paste0('Base.include(Main,"',
                          system.file("julia/setup.jl", package = "JuliaCall"), '")'))
    }

    if (verbose) message("Finish loading setup script for JuliaCall.")

    .julia$do.call_ <- juliacall_docall

    julia$VERSION <- .julia$VERSION

    ## Check whether we need to set up RmdDisplay
    .julia$rmd <- check_rmd()

    ## useRCall will be used later in julia_console,
    ## because in the hook RCall.rgui_start() will be executed,
    ## then when we quit the console,
    ## RCall.rgui_stop() needs to be executed.

    julia$useRCall <- useRCall

    .julia$initialized <- TRUE

    if (useRCall) {
        julia$command("using RCall")
        julia$command("Base.atreplinit(JuliaCall.setup_repl)")
    }

    if (interactive()) {
        julia_command("eval(Base, :(is_interactive = true));")
    }

    if (isTRUE(getOption("jupyter.in_kernel"))) {
        julia_command("Base.pushdisplay(JuliaCall.irjulia_display);")
    }

    if (.julia$rmd) {
        julia_command("Base.pushdisplay(JuliaCall.rmd_display);")
    }

    ## a dirty fix for Plots GR backend
    julia_command('ENV["GKSwstype"]="pdf";')
    julia_command('ENV["GKS_FILEPATH"] = tempdir();')

    ## Suppress pyplot gui
    julia_command('ENV["MPLBACKEND"] = "Agg";')

    invisible(julia)
}

install_dependency <- function(){
    ## `RCall` needs to be precompiled with the current R.
    julia_line(c(system.file("julia/install_dependency.jl", package = "JuliaCall"),
                 R.home(), as.character(getRversion())),
               stderr = FALSE)
}
