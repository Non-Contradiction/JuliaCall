julia_default_install_dir <- function(){
    dir <- if (require("rappdirs")) {
        file.path(user_data_dir("JuliaCall"), "julia")
    } else {
        NULL
    }
    return(dir)
}

julia_tgz_url <- function(){
    version <- "v1.5.0"
    arch <- if (.Machine$sizeof.pointer == 8) {
        "x86_64"
    } else {
        "i686"
    }
    sysname <- Sys.info()["sysname"]
    os <- if (sysname == "Linux") {
        "linux-gnu"
    } else if (sysname == "Darwin") {
        "apple-darwin14"
    } else if (sysname == "Windows") {
        "w64-mingw32"
    } else {
        stop("Unknown or unsupported OS")
    }
    url <- sprintf(
        "https://github.com/JuliaBinaryWrappers/Julia_jll.jl/releases/download/Julia-%s%%2B0/Julia.%s.%s-%s-libgfortran4-cxx11.tar.gz",
        version, version, arch, os
    )
    return(url)
}

julia_save_install_dir <- function(prefix){
    depot <- Sys.getenv("JULIA_DEPOT_PATH", unset = path.expand("~/.julia"))
    prefs <- file.path(depot, "prefs")
    dir.create(prefs, recursive = TRUE, showWarnings = FALSE)
    cat(file.path(prefix, "bin"), file = file.path(prefs, "JuliaCall"))
}

install_julia <- function(prefix = julia_default_install_dir()){
    if (is.null(prefix)) {
        stop("rappdirs is not installed and prefix was not provided")
    }
    url <- julia_tgz_url()
    file <- tempfile()
    download.file(url, file)
    untar(file, exdir=prefix)
    julia_save_install_dir(prefix)
    Sys.setenv(JULIA_HOME = file.path(prefix, "bin"))
}
