#' Do initial setup for the JuliaCall package.
#'
#' \code{julia_setup} does the initial setup for the JuliaCall package.
#'
#' @param verbose whether to print out detailed information
#'     about \code{julia_setup}.
#' @param force whether to force julia_setup to execute again.
#'
#' @return The julia interface, which is an environment with the necessary methods
#'   like command, source and things like that to communicate with julia.
#'
#' @examples
#'
#' if (julia_check()) {
#'   \dontrun{ ## julia_setup is quite time consuming
#'   julia <- julia_setup()
#'   }
#' }
#'
#' @export
julia_setup <- function(verbose = TRUE, force = FALSE) {
    ## libR <- paste0(R.home(), '/lib')
    ## system(paste0('export LD_LIBRARY_PATH=', libR, ':$LD_LIBRARY_PATH'))

    if (!force && .julia$initialized) {
        return(julia)
    }

    system("julia -e \"pkg = string(:RCall); if Pkg.installed(pkg) == nothing Pkg.add(pkg) end; using RCall\"",
           ignore.stderr = TRUE)

    system("julia -e \"pkg = string(:Suppressor); if Pkg.installed(pkg) == nothing Pkg.add(pkg) end; using Suppressor\"",
           ignore.stderr = TRUE)

    .julia$bin_dir <- system("julia -E \"println(JULIA_HOME)\"", intern = TRUE)[1]
    .julia$config <- file.path(dirname(.julia$bin_dir), "share", "julia", "julia-config.jl")
    .julia$cppargs <- system(paste0("julia ", .julia$config, " --cflags"), intern = TRUE)
    .julia$cppargs <- paste0(.julia$cppargs, " -fpermissive")
    .julia$cppargs <- sub("-std=gnu99", "", .julia$cppargs)
    .julia$libargs <- system(paste0("julia ", .julia$config, " --ldflags"), intern = TRUE)
    .julia$libargs <- paste(.julia$libargs,
                            system(paste0("julia ", .julia$config, " --ldlibs"), intern = TRUE))

    .julia$dll_file <- system("julia -E \"println(Libdl.dllist()[1])\"", intern = TRUE)[1]

    .julia$dll <- withCallingHandlers(dyn.load(.julia$dll_file, FALSE, TRUE),
                                      error = function(e){
                                          message("Error in loading libjulia.
                                                  Maybe you should include $JULIA_DIR/lib/julia in LD_LIBRAY_PATH.")
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
        inline::cfunction(sig = sig, body = body, includes = .julia$inc,
                          cppargs = .julia$cppargs,
                          libargs = .julia$libargs)
    }

    .julia$VERSION <- system("julia -E \"println(VERSION)\"", intern = TRUE)[1]

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
        sig = c(func_name = "character", arg = "list", need_return = "logical"),
        body = '
        jl_function_t *docall = (jl_function_t*)(jl_eval_string("JuliaCall.docall"));
        jl_value_t *func = jl_box_voidpointer(func_name);
        jl_value_t *arg1 = jl_box_voidpointer(arg);
        jl_value_t *need_return1 = jl_box_voidpointer(need_return);
        SEXP out = PROTECT((SEXP)jl_unbox_voidpointer(jl_call3(docall, func, arg1, need_return1)));
        UNPROTECT(1);
        return out;'
        )

    julia$VERSION <- .julia$VERSION

    .julia$initialized <- TRUE

    julia
}

