.julia <- new.env(parent = emptyenv())

#' Do initial setup for the JuliaCall package.
#'
#' \code{julia_setup} does the initial setup for the JuliaCall package.
#'
#' @return The julia interface, which is an environment with the necessary methods
#'   like cmd, source and things like that to communicate with julia.
#'
#' @examples
#' julia <- julia_setup()
#' julia$command("println(sqrt(2))")
#' julia$eval_string("sqrt(2)")
#' julia$call("sqrt", 2)
#' julia$eval_string("sqrt")(2)
#' julia$exists("sqrt")
#' julia$exists("c")
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

    if (.julia$VERSION < "0.6.0") {
        .julia$init <- inline::cfunction(
            sig = c(dir = "character"),
            body = "jl_init(CHAR(STRING_ELT(dir, 0))); return R_NilValue;",
            includes = "#include <julia.h>",
            cppargs = .julia$cppargs
        )

        message("Julia initiation...")

        .julia$init(.julia$bin_dir)
    }
    if (.julia$VERSION >= "0.6.0") {
        .julia$init <- inline::cfunction(
            sig = c(),
            body = "jl_init(); return R_NilValue;",
            includes = "#include <julia.h>",
            cppargs = .julia$cppargs
        )

        message("Julia initiation...")

        .julia$init()
    }

    .julia$.cmd <- inline::cfunction(
        sig = c(cmd = "character"),
        body = "jl_eval_string(CHAR(STRING_ELT(cmd, 0)));
        if (jl_exception_occurred()) printf(\"%s \", jl_typeof_str(jl_exception_occurred()));
        return R_NilValue;",
        includes = "#include <julia.h>",
        cppargs = .julia$cppargs
    )

    .julia$using <- function(pkg) {
        .julia$.cmd(paste0("using ", pkg))
    }

    .julia$using1 <- function(pkg) {
        .julia$.cmd(paste0('if Pkg.installed("', pkg, '") == nothing Pkg.add("', pkg, '") end'))
        .julia$using(pkg)
    }

    reg.finalizer(.julia, function(e){message("Julia exit."); .julia$.cmd("exit()")}, onexit = TRUE)

    # .julia$.cmd("gc_enable(false)")

    # .julia$.cmd("Pkg.update()")

    .julia$.cmd(paste0('ENV["R_HOME"] = "', R.home(), '"'))

    .julia$using1("RCall")

    .julia$.cmd("function transfer_list(x) rcopy(RObject(Ptr{RCall.VecSxp}(x))) end")

    .julia$.cmd("function transfer_string(x) rcopy(RObject(Ptr{RCall.StrSxp}(x))) end")

    .julia$.cmd('function wrap(name, x)
                    fname = transfer_string(name);
                    try
                        f = eval(parse(fname))
                        xx = transfer_list(x);
                        RObject(f(xx...)).p;
                    catch e
                        println(join(["Error happens when you try to call function " fname " in Julia."]));
                        showerror(STDOUT, e, catch_stacktrace());
                        println();
                        RObject(nothing).p;
                    end;
               end')

    .julia$wrap <- inline::cfunction(
        sig = c(func_name = "character", arg = "SEXP"),
        body = '
        jl_function_t *wrap = (jl_function_t*)(jl_eval_string("wrap"));
        jl_value_t *func = jl_box_voidpointer(func_name);
        jl_value_t *arg1 = jl_box_voidpointer(arg);
        SEXP out = PROTECT((SEXP)jl_unbox_voidpointer(jl_call2(wrap, func, arg1)));
        UNPROTECT(1);
        return out;',
        includes = "#include <julia.h>",
        cppargs = .julia$cppargs
        )

    .julia$wrap_no_ret <- inline::cfunction(
        sig = c(func_name = "character", arg = "SEXP"),
        body = '
        jl_function_t *wrap = (jl_function_t*)(jl_eval_string("wrap"));
        jl_value_t *func = jl_box_voidpointer(func_name);
        jl_value_t *arg1 = jl_box_voidpointer(arg);
        jl_call2(wrap, func, arg1);
        return R_NilValue;',
        includes = "#include <julia.h>",
        cppargs = .julia$cppargs
    )

    .julia$call <- function(func_name, ...) .julia$wrap(func_name, list(...))

    .julia$call_no_ret <- function(func_name, ...) .julia$wrap_no_ret(func_name, list(...))

    .julia$.cmd("function exists(x) isdefined(Symbol(x)) end")

    .julia$exists <- function(name) .julia$call("exists", name)

    .julia$.cmd("function eval_string(x) eval(parse(x)) end")

    .julia$eval_string <- function(cmd) .julia$call("eval_string", cmd)

    .julia$command <- function(cmd) .julia$call_no_ret("eval_string", cmd)

    .julia$include <- function(file_name) .julia$call("include", file_name)

    .julia$source <- function(file_name) .julia$call_no_ret("include", file_name)

    .julia$install_package <- function(pkg_name) .julia$call_no_ret("Pkg.add", pkg_name)

    .julia$.cmd("function installed_package(pkg_name) string(Pkg.installed(pkg_name)) end")

    .julia$installed_package <- function(pkg_name) .julia$call("installed_package", pkg_name)

    .julia$install_package_if_needed <- function(pkg_name){
        if (.julia$installed_package(pkg_name) == "nothing") {
            .julia$install_package(pkg_name)
        }
    }

    .julia
}
