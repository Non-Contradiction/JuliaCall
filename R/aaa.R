.julia <- new.env(parent = emptyenv())
.julia$initialized <- FALSE

julia <- new.env(parent = .julia)

julia_locate <- function(JULIA_HOME = NULL){
    if (is.null(JULIA_HOME)) {
        JULIA_HOME <- getOption("JULIA_HOME")
    }
    if (is.null(JULIA_HOME)) {
        JULIA_HOME <- if (Sys.getenv("JULIA_HOME") == "") {
            NULL
        } else{
            Sys.getenv("JULIA_HOME")
        }
    }

    if (is.null(JULIA_HOME)) {
        ## In macOS, the environment variables, e.g., PATH of a GUI is set by launchctl not the SHELL.
        ## You may need to do bash -l -c "which julia" to determine the path to julia.
        ## This fixes the issue that in macOS, R.app GUI cannot find julia.
        ## Thank @randy3k
        julia_bin <- Sys.which("julia")
        if (julia_bin == "") {
            if (.Platform$OS.type == "unix") {
                julia_bin <- system2("bash", "-l -c 'which julia'", stdout = TRUE)[1]
            } else if (.Platform$OS.type == "windows" ) {
                # look for julia in the most common installation path
                appdata_local_path <- Sys.getenv("LOCALAPPDATA")


                # if the path is not defined, then try to construct it manually
                if(appdata_local_path == "") {
                    windows_login_id <- Sys.info()[["login"]]
                    if(windows_login_id == "unknown") {
                        stop("The Windows login is 'unknown'. Can not find julia executable")
                    }
                    appdata_local_path <- file.path("C:/Users/", windows_login_id, "AppData/Local")
                }


                # get a list of folder names
                ld <- list.dirs(appdata_local_path, recursive = FALSE, full.names = FALSE)

                # which of these folers start with "Julia"
                x = ld[sort(which(substr(ld,1,5) == "Julia"))]

                if(length(x) == 0) {
                    stop(sprintf("Can not find the Julia installation in the default installation path '%s'", appdata_local_path))
                }
                # TODO if interactive() let the user choose a version of Julia
                # keep the lastest version of Julia as that is likeley to be the default
                x = x[length(x)]

                # filter the ld for folders that starts with Julia
                julia_bin <- file.path(appdata_local_path, x, "bin/julia.exe")
            } else {
                julia_bin <- "julia"
            }
        }
        tryCatch({r <- system2(julia_bin, "--startup-file=no -E \"try println(JULIA_HOME) catch e println(Sys.BINDIR) end;\"", stdout = TRUE);
                  r[length(r)-1]},
                 warning = function(war) {},
                 error = function(err) NULL)
    }
    else {
        tryCatch({r <- system2(file.path(JULIA_HOME, "julia"),
                         "--startup-file=no -E \"try println(JULIA_HOME) catch e println(Sys.BINDIR) end;\"", stdout = TRUE);
                  r[length(r)-1]},
                 warning = function(war) {},
                 error = function(err) NULL)
    }
}

## This function exists because of issue # 14577
## <https://github.com/JuliaLang/julia/issues/14577> in julia v0.6.0,
## which is fixed now.
## We need to call julia from the command line to precompile packages.
## It is currently used in julia_setup in zzz.R and julia_library in package.R
julia_line <- function(command, ...){
    command <- c("--startup-file=no", command)
    r <- system2(file.path(.julia$bin_dir, "julia"), shQuote(command), ...)
    r[length(r)]
}

newer <- function(x, y){
    x <- substring(x, 1, 5)
    y <- substring(y, 1, 5)
    utils::compareVersion(x, y) >= 0
}
