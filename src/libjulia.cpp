#define LIBJULIA_CPP
#include "libjulia.h"

#ifndef _WIN32
#include <dlfcn.h>
#else
#define WIN32_LEAN_AND_MEAN 1
#include <windows.h>
#endif

#include <string>

namespace libjulia {

std::string lastSymbol;

std::string getLastSymbol() {
    return lastSymbol;
}

std::string getLastDLErrorMessage() {
    std::string Error;
#ifdef _WIN32
    LPVOID lpMsgBuf;
    DWORD dw = ::GetLastError();

    DWORD length = ::FormatMessage(
        FORMAT_MESSAGE_ALLOCATE_BUFFER |
        FORMAT_MESSAGE_FROM_SYSTEM |
        FORMAT_MESSAGE_IGNORE_INSERTS,
        NULL,
        dw,
        MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
        (LPTSTR) &lpMsgBuf,
        0, NULL );

    if (length != 0) {
        std::string msg((LPTSTR)lpMsgBuf);
        LocalFree(lpMsgBuf);
        Error.assign(msg);
    } else {
        Error.assign("(Unknown error)");
    }
#else
    const char* msg = ::dlerror();
    if (msg != NULL)
        Error.assign(msg);
    else
        Error.assign("(Unknown error)");
#endif
    return Error;
}

bool loadSymbol(void* plib, const std::string& name, void** ppSymbol) {

    lastSymbol = name;
    *ppSymbol = NULL;
#ifdef _WIN32
    *ppSymbol = (void*)::GetProcAddress((HINSTANCE)plib, name.c_str());
#else
    *ppSymbol = ::dlsym(plib, name.c_str());
#endif
    if (*ppSymbol == NULL) {
        return false;
    } else {
        return true;
    }
}

bool SharedLibrary::load(const std::string& libpath) {
    plib = NULL;
#ifdef _WIN32
    plib = (void*)::LoadLibraryEx(libpath.c_str(), NULL, 0);
#else
    plib = ::dlopen(libpath.c_str(), RTLD_NOW|RTLD_GLOBAL);
#endif
    if (plib == NULL) {
        return false;
    } else {
        return true;
    }
}

bool SharedLibrary::unload() {
  if (plib != NULL) {
#ifdef _WIN32
    if (!::FreeLibrary((HMODULE)plib)) {
#else
    if (::dlclose(plib) != 0) {
#endif
      return false;
    } else {
      return true;
    }
  }
  else
    return true;
}

#define LOAD_JULIA_SYMBOL_AS(name, as) \
if (!loadSymbol(plib, #name, (void**) &as)) \
    return false;

#define LOAD_JULIA_SYMBOL(name) \
if (!loadSymbol(plib, #name, (void**) &name)) \
    return false;

bool SharedLibrary::loadSymbols() {
    LOAD_JULIA_SYMBOL(jl_symbol);
    LOAD_JULIA_SYMBOL(jl_box_voidpointer);
    LOAD_JULIA_SYMBOL(jl_unbox_voidpointer);

    LOAD_JULIA_SYMBOL(jl_get_global);

    LOAD_JULIA_SYMBOL(jl_init);
    LOAD_JULIA_SYMBOL(jl_is_initialized);
    LOAD_JULIA_SYMBOL(jl_atexit_hook);
    LOAD_JULIA_SYMBOL(jl_eval_string);

    LOAD_JULIA_SYMBOL(jl_exception_occurred);

    LOAD_JULIA_SYMBOL(jl_call);
    LOAD_JULIA_SYMBOL(jl_call0);
    LOAD_JULIA_SYMBOL(jl_call1);
    LOAD_JULIA_SYMBOL(jl_call2);
    LOAD_JULIA_SYMBOL(jl_call3);

    LOAD_JULIA_SYMBOL(jl_stderr_stream);
    LOAD_JULIA_SYMBOL(jl_printf);
    LOAD_JULIA_SYMBOL(jl_flush_cstdio);
    LOAD_JULIA_SYMBOL(jl_stdout_obj);
    LOAD_JULIA_SYMBOL(jl_stderr_obj);

    return true;
}

bool SharedLibrary::loadModules() {
    jl_main_module = (jl_module_t*) jl_eval_string("Main");
    jl_core_module = (jl_module_t*) jl_eval_string("Core");
    jl_base_module = (jl_module_t*) jl_eval_string("Base");
    return true;
}

} // namespace libjulia
