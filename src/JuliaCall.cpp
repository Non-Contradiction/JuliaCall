#include <Rcpp.h>
#include "libjulia.h"

using namespace libjulia;

SharedLibrary jl_library;

// [[Rcpp::export]]
bool juliacall_initialize(const std::string& libpath) {
    jl_library = SharedLibrary();
    if (!jl_library.load(libpath)) {
        Rcpp::stop(getLastDLErrorMessage());
    }
    if (!jl_library.loadSymbols()) {
        Rcpp::stop(getLastSymbol() + "-" + getLastDLErrorMessage());
    }
    jl_init();
    return true;
}

// [[Rcpp::export]]
bool juliacall_cmd(const char* libpath) {
    jl_eval_string(libpath);
    if (jl_exception_occurred()) {
        jl_call2(jl_get_function(jl_base_module, "show"), jl_stderr_obj(), jl_exception_occurred());
        jl_printf(jl_stderr_stream(), " ");
        return false;
    }
    return true;
}


// [[Rcpp::export]]
SEXP juliacall_docall(SEXP jcall) {
    jl_function_t *docall = (jl_function_t*)(jl_eval_string("JuliaCall.docall"));
    jl_value_t *call = jl_box_voidpointer(jcall);
    SEXP out = (SEXP) jl_unbox_voidpointer(jl_call1(docall, call));
    return out;
}


// [[Rcpp::export]]
void juliacall_atexit_hook(int status) {
    jl_atexit_hook(status);
}
