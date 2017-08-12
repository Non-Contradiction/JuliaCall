.julia <- new.env(parent = emptyenv())

julia <- new.env(parent = .julia)

#' Do initial setup for the JuliaCall package.
#'
#' \code{julia_setup} does the initial setup for the JuliaCall package.
#'
#' @return The julia interface, which is an environment with the necessary methods
#'   like cmd, source and things like that to communicate with julia.
#'
#' @examples
#' julia <- julia_setup()
#' julia$command("a = sqrt(2)"); julia$eval_string("a")
#' julia$eval_string("sqrt(2)")
#' julia$call("sqrt", 2)
#' julia$eval_string("sqrt")(2)
#' julia$exists("sqrt")
#' julia$exists("c")
#' julia$installed_package("RCall")
#' julia$using("RCall")
#' julia$help("sqrt")
#'
#' @export
julia_setup <- function() {
    libR <- paste0(R.home(), '/lib')
    system(paste0('export LD_LIBRARY_PATH=', libR, ':$LD_LIBRARY_PATH'))

    .julia$bin_dir <-
        system("julia -E 'println(JULIA_HOME)'", intern = TRUE)[1]
    .julia$dll_file <-
        system("julia -E 'println(Libdl.dllist()[1])'", intern = TRUE)[1]
    .julia$dll <- dyn.load(.julia$dll_file, FALSE, TRUE)
    .julia$include_dir <-
        sub("/bin", "/include/julia", .julia$bin_dir)
    .julia$cppargs <- paste0("-I ", .julia$include_dir, " -DJULIA_ENABLE_THREADING=1")

    .julia$VERSION <- system("julia -E 'println(VERSION)'", intern = TRUE)[1]

    message(paste0("Julia version ", .julia$VERSION, " found."))

    system("julia -e 'if Pkg.installed(\"RCall\") == nothing Pkg.add(\"RCall\") end; using RCall'")

    if (.julia$VERSION < "0.6.0") {
        .julia$init_ <- inline::cfunction(
            sig = c(dir = "character"),
            body = "jl_init(CHAR(STRING_ELT(dir, 0))); return R_NilValue;",
            includes = "#include <julia.h>",
            cppargs = .julia$cppargs
        )

        .julia$init <- function() .julia$init_(.julia$bin_dir)
    }
    if (.julia$VERSION >= "0.6.0") {
        .julia$init <- inline::cfunction(
            sig = c(),
            body = "jl_init(); return R_NilValue;",
            includes = "#include <julia.h>",
            cppargs = .julia$cppargs
        )
    }

    message("Julia initiation...")

    .julia$init()

    .julia$cmd_ <- inline::cfunction(
        sig = c(cmd = "character"),
        body = "jl_eval_string(CHAR(STRING_ELT(cmd, 0)));
        if (jl_exception_occurred()) {printf(\"%s \", jl_typeof_str(jl_exception_occurred())); return Rf_ScalarLogical(0);};
        return Rf_ScalarLogical(1);",
        includes = "#include <julia.h>",
        cppargs = .julia$cppargs
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

    .julia$cmd(paste0('include("', system.file("julia/setup.jl", package = "JuliaCall"),'")'))

    .julia$do.call_ <- inline::cfunction(
        sig = c(func_name = "character", arg = "list"),
        body = '
        jl_function_t *docall = (jl_function_t*)(jl_eval_string("JuliaCall.docall"));
        jl_value_t *func = jl_box_voidpointer(func_name);
        jl_value_t *arg1 = jl_box_voidpointer(arg);
        SEXP out = PROTECT((SEXP)jl_unbox_voidpointer(jl_call2(docall, func, arg1)));
        UNPROTECT(1);
        return out;',
        includes = "#include <julia.h>",
        cppargs = .julia$cppargs
        )

    julia$do.call <- function(func_name, arg_list){
        if (!(length(func_name) == 1 && is.character(func_name))) {
            stop("func_name should be a character scalar.")
        }
        if (!(is.list(arg_list))) {
            stop("arg_list should be the list of arguments.")
        }
        r <- .julia$do.call_(func_name, arg_list)
        if (inherits(r, "error")) stop(r)
        r
    }

    julia$call <- function(func_name, ...) julia$do.call(func_name, list(...))

    .julia$do.call_no_ret_ <- inline::cfunction(
        sig = c(func_name = "character", arg = "list"),
        body = '
        jl_function_t *docall = (jl_function_t*)(jl_eval_string("JuliaCall.docall_no_ret"));
        jl_value_t *func = jl_box_voidpointer(func_name);
        jl_value_t *arg1 = jl_box_voidpointer(arg);
        SEXP out = PROTECT((SEXP)jl_unbox_voidpointer(jl_call2(docall, func, arg1)));
        UNPROTECT(1);
        return out;',
        includes = "#include <julia.h>",
        cppargs = .julia$cppargs
    )

    julia$do.call_no_ret <- function(func_name, arg_list){
        if (!(length(func_name) == 1 && is.character(func_name))) {
            stop("func_name should be a character scalar.")
        }
        if (!(is.list(arg_list))) {
            stop("arg_list should be the list of arguments.")
        }
        r <- .julia$do.call_no_ret_(func_name, arg_list)
        if (inherits(r, "error")) stop(r)
        r
    }

    julia$call_no_ret <- function(func_name, ...) julia$do.call_no_ret(func_name, list(...))

    julia$VERSION <- .julia$VERSION

    julia$exists <- function(name) julia$call("JuliaCall.exists", name)

    julia$eval_string <- function(cmd) julia$call("JuliaCall.eval_string", cmd)

    julia$command <- function(cmd) julia$call_no_ret("JuliaCall.eval_string", cmd)

    julia$include <- function(file_name) julia$call("include", file_name)

    julia$source <- function(file_name) julia$call_no_ret("include", file_name)

    julia$install_package <- function(pkg_name) julia$call_no_ret("Pkg.add", pkg_name)

    julia$installed_package <- function(pkg_name) julia$call("JuliaCall.installed_package", pkg_name)

    julia$install_package_if_needed <- function(pkg_name){
        if (julia$installed_package(pkg_name) == "nothing") {
            julia$install_package(pkg_name)
        }
    }

    julia$update_package <- function(...) julia$do.call("Pkg.update", list(...))

    julia$using <- function(pkg){
        tryCatch(julia$command(paste0("using ", pkg)),
                 error = system(paste0("julia -e 'using ", pkg, "'")),
                 finally = julia$command(paste0("using ", pkg)))
    }

    julia$help <- function(fname){
        cat(julia$call("JuliaCall.help", fname))
    }

    julia
}
