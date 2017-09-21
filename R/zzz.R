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
        return(julia)
    }

    JULIA_HOME <- julia_locate(JULIA_HOME)

    if (is.null(JULIA_HOME)) {
        stop("Julia is not found.")
    }

    .julia$bin_dir <- JULIA_HOME

    if (verbose) message(paste0("Julia at location ", JULIA_HOME, " will be used."))

    julia_line("-e \"pkg = string(:RCall); if Pkg.installed(pkg) == nothing Pkg.add(pkg) end; using RCall\"",
           ignore.stderr = TRUE)

    julia_line("-e \"pkg = string(:Suppressor); if Pkg.installed(pkg) == nothing Pkg.add(pkg) end; using Suppressor\"",
           ignore.stderr = TRUE)

    .julia$config <- file.path(dirname(.julia$bin_dir), "share", "julia", "julia-config.jl")
    .julia$cppargs <- julia_line(paste0(.julia$config, " --cflags"), intern = TRUE)
    .julia$cppargs <- paste0(.julia$cppargs, " -fpermissive")
    .julia$cppargs <- sub("-std=gnu99", "", .julia$cppargs)
    .julia$libargs <- julia_line(paste0(.julia$config, " --ldflags"), intern = TRUE)
    .julia$libargs <- paste(.julia$libargs,
                            julia_line(paste0(.julia$config, " --ldlibs"), intern = TRUE))

    .julia$dll_file <- julia_line("-E \"println(Libdl.dllist()[1])\"", intern = TRUE)[1]

    .julia$dll <- withCallingHandlers(dyn.load(.julia$dll_file, FALSE, TRUE),
                                      error = function(e){
                                          message("Error in loading libjulia.")
                                          message("Maybe you should include $JULIA_DIR/lib/julia in LD_LIBRAY_PATH.")
                                      })

    ## .julia$include_dir <- file.path(dirname(.julia$bin_dir), "include", "julia")
    ## .julia$cppargs <- paste0("-I ", .julia$include_dir, " -DJULIA_ENABLE_THREADING=1")
    ## .julia$cppargs <- paste0("-I ", .julia$include_dir, " -fpermissive")

    .julia$inc <- "
    // Taken from http://tolstoy.newcastle.edu.au/R/e2/devel/06/11/1242.html
    // Undefine the Realloc macro, which is defined by both R and by Windows stuff
    #undef Realloc
    // Also need to undefine the Free macro
    #undef Free

    #include <julia.h>
    "

    .julia$compile <- function(sig, body){
        withCallingHandlers(
            inline::cfunction(sig = sig, body = body, includes = .julia$inc,
                              cppargs = .julia$cppargs,
                              libargs = .julia$libargs),
            error = function(e){
                message("Error in compilation.")
                message("Maybe this is because the compiler version is too old.")
                message("You should use GCC version 4.7 or later on Linux, or Clang version 3.1 or later on Mac.")
            })
    }

    .julia$VERSION <- julia_line("-E \"println(VERSION)\"", intern = TRUE)[1]

    if (verbose) message(paste0("Julia version ", .julia$VERSION, " found."))

    if (!newer(.julia$VERSION, "0.6.0")) {
        .julia$init_ <- .julia$compile(
            sig = c(dir = "character"),
            body = "jl_init(CHAR(STRING_ELT(dir, 0))); return R_NilValue;"
        )

        .julia$init <- function() .julia$init_(.julia$bin_dir)
    }
    if (newer(.julia$VERSION, "0.6.0")) {
        .julia$init <- .julia$compile(
            sig = c(),
            body = "jl_init(); return R_NilValue;"
        )
    }

    if (verbose) message("Julia initiation...")

    .julia$init()

    if (verbose) message("Finish Julia initiation.")

    .julia$cmd_ <- .julia$compile(
        sig = c(cmd = "character"),
        body = "jl_eval_string(CHAR(STRING_ELT(cmd, 0)));
        if (jl_exception_occurred()) {
            jl_call2(jl_get_function(jl_base_module, \"show\"), jl_stderr_obj(), jl_exception_occurred());
            jl_printf(jl_stderr_stream(), \" \");
            return Rf_ScalarLogical(0);
        }
        return Rf_ScalarLogical(1);"
    )

    .julia$cmd <- function(cmd){
        if (!(length(cmd) == 1 && is.character(cmd))) {
            stop("cmd should be a character scalar.")
        }
        if (!.julia$cmd_(cmd)) {
            stop(paste0("Error happens when you try to execute command ", cmd, " in Julia."))
        }
    }

    reg.finalizer(.julia, function(e){message("Julia exit."); .julia$cmd("exit()")}, onexit = TRUE)

    .julia$cmd(paste0('ENV["R_HOME"] = "', R.home(), '"'))

    if (verbose) message("Loading setup script for JuliaCall...")

    .julia$cmd(paste0('include("', system.file("julia/setup.jl", package = "JuliaCall"),'")'))

    if (verbose) message("Finish loading setup script for JuliaCall.")

    .julia$do.call_ <- .julia$compile(
        sig = c(jcall = "list"),
        body = '
        jl_function_t *docall = (jl_function_t*)(jl_eval_string("JuliaCall.docall"));
        jl_value_t *call = jl_box_voidpointer(jcall);
        SEXP out = PROTECT((SEXP)jl_unbox_voidpointer(jl_call1(docall, call)));
        UNPROTECT(1);
        return out;'
        )

    julia$VERSION <- .julia$VERSION

    ## Check whether we need to set up RmdDisplay
    .julia$rmd <- check_rmd()

    ## useRCall will be used later in julia_console,
    ## because in the hook RCall.rgui_start() will be executed,
    ## then when we quit the console,
    ## RCall.rgui_stop() needs to be executed.

    julia$useRCall <- useRCall

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

    .julia$initialized <- TRUE

    invisible(julia)
}

