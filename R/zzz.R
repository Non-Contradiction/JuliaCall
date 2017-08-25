.julia <- new.env(parent = emptyenv())

julia <- new.env(parent = .julia)

#' Do initial setup for the JuliaCall package.
#'
#' \code{julia_setup} does the initial setup for the JuliaCall package.
#'
#' @param verbose whether print out detailed information about construction of julia interface
#'
#' @return The julia interface, which is an environment with the necessary methods
#'   like cmd, source and things like that to communicate with julia.
#'
#' @examples
#' julia <- julia_setup()
#'
#' ## Different ways for calculating sqrt(2)
#'
#' julia$command("a = sqrt(2)"); julia$eval_string("a")
#' julia$eval_string("sqrt(2)")
#' julia$call("sqrt", 2)
#' julia$eval_string("sqrt")(2)
#'
#' ## You can use `julia$exists` as `exists` in R to test
#' ## whether a function or name exists in Julia or not
#'
#' julia$exists("sqrt")
#' julia$exists("c")
#'
#' ## You can use `julia$help` to get help for Julia functions
#'
#' julia$help("sqrt")
#'
#' ## Functions related to Julia packages
#'
#' julia$install_package("Optim")
#' julia$install_package_if_needed("Optim")
#' julia$installed_package("Optim")
#' julia$using("Optim") ## Same as julia$library("Optim")
#'
#' @export
julia_setup <- function(verbose = FALSE) {
    ## libR <- paste0(R.home(), '/lib')
    ## system(paste0('export LD_LIBRARY_PATH=', libR, ':$LD_LIBRARY_PATH'))

    system("julia -e \"pkg = string(:RCall); if Pkg.installed(pkg) == nothing Pkg.add(pkg) end; using RCall\"")

    .julia$bin_dir <- system("julia -E \"println(JULIA_HOME)\"", intern = TRUE)[1]
    .julia$config <- file.path(dirname(.julia$bin_dir), "share", "julia", "julia-config.jl")
    .julia$cppargs <- system(paste0("julia ", .julia$config, " --cflags"), intern = TRUE)
    .julia$cppargs <- paste0(.julia$cppargs, " -fpermissive")
    .julia$cppargs <- sub("-std=gnu99", "", .julia$cppargs)
    .julia$libargs <- system(paste0("julia ", .julia$config, " --ldflags"), intern = TRUE)
    .julia$libargs <- paste(.julia$libargs,
                            system(paste0("julia ", .julia$config, " --ldlibs"), intern = TRUE))

    ## .julia$dll_file <- system("julia -E \"println(Libdl.dllist()[1])\"", intern = TRUE)[1]
    ## .julia$dll <- dyn.load(.julia$dll_file, FALSE, TRUE)
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

    if (.julia$VERSION < "0.6.0") {
        .julia$init_ <- .julia$compile(
            sig = c(dir = "character"),
            body = "jl_init(CHAR(STRING_ELT(dir, 0))); return R_NilValue;"
        )

        .julia$init <- function() .julia$init_(.julia$bin_dir)
    }
    if (.julia$VERSION >= "0.6.0") {
        .julia$init <- .julia$compile(
            sig = c(),
            body = "jl_init(); return R_NilValue;"
        )
    }

    if (verbose) message("Julia initiation...")

    .julia$init()

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

    if (verbose) message("Load setup script for JuliaCall...")

    .julia$cmd(paste0('include("', system.file("julia/setup.jl", package = "JuliaCall"),'")'))

    if (verbose) message("Defining julia$do.call...")

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

    julia$do.call <- function(func_name, arg_list, need_return = TRUE){
        if (!(length(func_name) == 1 && is.character(func_name))) {
            stop("func_name should be a character scalar.")
        }
        if (!(is.list(arg_list))) {
            stop("arg_list should be the list of arguments.")
        }
        if (!(length(need_return) == 1 && is.logical(need_return))) {
            stop("need_return should be a logical scalar.")
        }
        r <- .julia$do.call_(func_name, arg_list, need_return)
        if (inherits(r, "error")) stop(r)
        if (need_return) return(r)
        invisible(r)
    }

    if (verbose) message("Defining julia$call...")

    julia$call <- function(func_name, ..., need_return = TRUE)
        julia$do.call(func_name, list(...), need_return)

    julia$VERSION <- .julia$VERSION

    if (verbose) message("Defining other utility functions...")

    julia$exists <- function(name) julia$call("JuliaCall.exists", name)

    julia$eval_string <- function(cmd) julia$call("JuliaCall.eval_string", cmd)

    julia$command <- function(cmd) julia$call("JuliaCall.eval_string", cmd, need_return = FALSE)

    julia$include <- function(file_name) julia$call("include", file_name)

    julia$source <- function(file_name) julia$call("include", file_name, need_return = FALSE)

    julia$install_package <- function(pkg_name) julia$call("Pkg.add", pkg_name, need_return = FALSE)

    julia$installed_package <- function(pkg_name) julia$call("JuliaCall.installed_package", pkg_name)

    julia$install_package_if_needed <- function(pkg_name){
        if (julia$installed_package(pkg_name) == "nothing") {
            julia$install_package(pkg_name)
        }
    }

    julia$update_package <- function(...) julia$do.call("Pkg.update", list(...))

    julia$library <- julia$using <- function(pkg){
        tryCatch(julia$command(paste0("using ", pkg)),
        error = {
            if (julia$VERSION >= "0.6.0") {
                system(paste0("julia -e \"using", pkg, "\""))
            }
            julia$command(paste0("using ", pkg))
        })
    }

    julia$help <- function(fname){
        cat(julia$call("JuliaCall.help", fname))
    }

    julia
}
