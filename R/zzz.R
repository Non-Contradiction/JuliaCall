.julia <- new.env(parent = emptyenv())

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

    .julia$cmd <- inline::cfunction(
        sig = c(cmd = "character"),
        body = "jl_eval_string(CHAR(STRING_ELT(cmd, 0))); return R_NilValue;",
        includes = "#include <julia.h>",
        cppargs = .julia$cppargs
    )

    .julia$source <- function(file_name) {
        .julia$cmd(readr::read_file(file_name))
    }

    .julia$install_package <- function(pkg_name) {
        .julia$cmd(paste0('Pkg.add("', pkg_name, '")'))
    }

    .julia$install_package_if_needed <- function(pkg_name) {
        .julia$cmd(paste0('if Pkg.installed("', pkg_name, '") == nothing Pkg.add("', pkg_name, '") end'))
    }

    .julia$using <- function(pkg) {
        .julia$cmd(paste0("using ", pkg))
    }

    .julia$using1 <- function(pkg) {
        .julia$install_package_if_needed(pkg)
        .julia$using(pkg)
    }

    reg.finalizer(.julia, function(e){message("Julia exit."); .julia$cmd("exit()")}, onexit = TRUE)

    # .julia$cmd("gc_enable(false)")

    # .julia$cmd("Pkg.update()")

    .julia$cmd(paste0('ENV["R_HOME"] = "', R.home(), '"'))

    .julia$using1("RCall")

    .julia$cmd("function transfer_list(x) rcopy(RObject(Ptr{RCall.VecSxp}(x))) end")
    # .julia$cmd("function wrap(f, x) xx = transfer_list(x); f(xx...) end")
    .julia$cmd("function wrap_all(f, x) xx = transfer_list(x); Int64(RObject(f(xx...)).p) end")

    # .julia$wrap <- inline::cfunction(
    #     sig = c(func_name = "character", arg = "SEXP"),
    #     body = '
    #     jl_function_t *wrap = (jl_function_t*)(jl_eval_string("wrap"));
    #     jl_value_t *func = jl_eval_string(CHAR(STRING_ELT(func_name, 0)));
    #     jl_value_t *arg1 = jl_box_int64((uintptr_t)(arg));
    #     jl_call2(wrap, func, arg1);
    #     return R_NilValue;',
    #     includes = "#include <julia.h>",
    #     cppargs = .julia$cppargs
    #     )

    .julia$wrap_all <- inline::cfunction(
        sig = c(func_name = "character", arg = "SEXP"),
        body = '
        jl_function_t *wrap = (jl_function_t*)(jl_eval_string("wrap_all"));
        jl_value_t *func = jl_eval_string(CHAR(STRING_ELT(func_name, 0)));
        jl_value_t *arg1 = jl_box_int64((uintptr_t)(arg));
        SEXP out = PROTECT((SEXP)jl_unbox_int64(jl_call2(wrap, func, arg1)));
        UNPROTECT(1);
        return out;',
        includes = "#include <julia.h>",
        cppargs = .julia$cppargs
        )
}
