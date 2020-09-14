julia_default_install_dir <- function(){
    dir <- if (require("rappdirs")) {
        file.path(user_data_dir("JuliaCall"), "julia")
    } else {
        NULL
    }
    return(dir)
}

julia_latest_version <- function(){
    url <- "https://raw.githubusercontent.com/JuliaBinaryWrappers/Julia_jll.jl/master/Project.toml"
    file <- tempfile()
    download.file(url, file)
    toml <- readChar(file, 1024)
    match <- regexec("version = \"(.*)\\+(.*?)\"", toml)
    captures <- regmatches(toml, match)
    captures[[1]][2] <- paste("v", captures[[1]][2], sep = "")
    return(captures[[1]][2:3])
}

julia_tgz_url <- function(version, build){
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
        "https://github.com/JuliaBinaryWrappers/Julia_jll.jl/releases/download/Julia-%s+%s/Julia.%s.%s-%s-libgfortran4-cxx11.tar.gz",
        version, build, version, arch, os
    )
    return(url)
}

julia_default_depot <- function(){
    key <- if (Sys.info()["sysname"] == "Windows") {
        "USERPROFILE"
    } else {
        "HOME"
    }
    return(file.path(Sys.getenv(key), ".julia"))
}

julia_save_install_dir <- function(dir){
    depot <- Sys.getenv("JULIA_DEPOT_PATH", unset = julia_default_depot())
    prefs <- file.path(depot, "prefs")
    dir.create(prefs, recursive = TRUE, showWarnings = FALSE)
    cat(file.path(dir, "bin"), file = file.path(prefs, "JuliaCall"))
}

#' Install Julia.
#'
#' @param prefix the directory where Julia will be installed.
#'     If not set, a default location will be determined by \code{rappdirs}
#'     if it is installed, otherwise an error will be raised.
#'
#' @export
install_julia <- function(prefix = julia_default_install_dir()){
    if (is.null(prefix)) {
        stop("rappdirs is not installed and prefix was not provided")
    }
    version_build <- julia_latest_version()
    version <- version_build[1]
    build <- version_build[2]
    url <- julia_tgz_url(version, build)
    file <- tempfile()
    download.file(url, file)
    dest <- file.path(prefix, version)
    untar(file, exdir=dest)
    julia_save_install_dir(dest)
}
