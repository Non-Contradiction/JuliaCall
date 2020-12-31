#include <stdlib.h>
#include <Rcpp.h>
#include "libjulia.h"

using namespace libjulia;
using namespace Rcpp;


// [[Rcpp::export]]
bool juliacall_initialize(const std::string& libpath,
                          const std::string& julia_bindir,
                          const std::string& image_relative_path) {
    if (jl_main_module != NULL) {
        return true;
    }

    bool is_custom_image = image_relative_path == "default" ? false : true;
    bool is_custom_bindir;
    const char *julia_bindir_extra = getenv("JULIA_BINDIR");
    if (julia_bindir_extra)
        is_custom_bindir = true;
    else
        is_custom_bindir = false;

    if (!load_libjulia(libpath)) {
        stop(libpath + " - " + get_last_dl_error_message());
    }
    if (!load_libjulia_symbols()) {
        stop(get_last_loaded_symbol() + " - " + get_last_dl_error_message());
    }
    if(!load_libjulia_init_symbol(is_custom_image || is_custom_bindir)){
        stop(get_last_loaded_symbol() + " - " + get_last_dl_error_message());
    }

    if(is_custom_image){
        jl_init_with_image(julia_bindir.c_str(), image_relative_path.c_str());
    } else {
        if (is_custom_bindir){
            jl_init_with_image(julia_bindir_extra, NULL);
        } else {
            jl_init();
        }
    }


    if (!load_libjulia_modules()) {
        stop(get_last_dl_error_message());
    }

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
    // jl_function_t *docall = (jl_function_t*)(jl_eval_string("JuliaCall.docall"));
    jl_module_t *JuliaCall = (jl_module_t*)jl_get_global(jl_main_module, jl_symbol("JuliaCall"));
    jl_function_t *docall = jl_get_global(JuliaCall, jl_symbol("docall"));
    jl_value_t *call = jl_box_voidpointer(jcall);
    SEXP out = (SEXP) jl_unbox_voidpointer(jl_call1(docall, call));
    return out;
}


// [[Rcpp::export]]
void juliacall_atexit_hook(int status) {
    jl_atexit_hook(status);
}
