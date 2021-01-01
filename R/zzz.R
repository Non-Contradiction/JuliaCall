#' Do initial setup for the JuliaCall package.
#'
#' \code{julia_setup} does the initial setup for the JuliaCall package.
#'     It setups automatic type conversion, Julia display systems, etc,
#'     and is necessary for every new R session to use the package.
#'     If not carried out manually, it will be invoked automatically before other julia_xxx functions.
#'
#' @param JULIA_HOME the file folder which contains julia binary,
#'     if not set, JuliaCall will look at the global option JULIA_HOME,
#'     if the global option is not set,
#'     JuliaCall will then look at the environmental variable JULIA_HOME,
#'     if still not found, JuliaCall will try to use
#'     the julia in path.
#' @param verbose whether to print out detailed information
#'     about \code{julia_setup}.
#' @param install whether to execute installation script for dependent julia packages, whose default value is TRUE;
#'     but can be set to FALSE to save startup time when no installation of dependent julia packages is needed.
#' @param force whether to force julia_setup to execute again.
#' @param useRCall whether or not you want to use RCall.jl in julia,
#'     which is an amazing package to access R in julia.
#' @param rebuild whether to rebuild RCall.jl, whose default value is FALSE to save startup time.
#'     If a new version of R is used, then this parameter needs to be set to TRUE.
#' @param relative_sysimage_path path to the precompiled custom sys image. Path have to be relative to JULIA_HOME directory
#'     e.g. for default image it usually is "../lib/julia/sys.ji".
#'
#' @return The julia interface, which is an environment with the necessary methods
#'   like command, source and things like that to communicate with julia.
#'
#' @examples
#'
#' \donttest{ ## julia_setup is quite time consuming
#'   julia <- julia_setup()
#' }
#'
#' @export
julia_setup <- function(JULIA_HOME = NULL, verbose = TRUE,
                        install = TRUE, force = FALSE, useRCall = TRUE,
                        rebuild = FALSE, relative_sysimage_path = "default") {
    ## libR <- paste0(R.home(), '/lib')
    ## system(paste0('export LD_LIBRARY_PATH=', libR, ':$LD_LIBRARY_PATH'))

    if (!force && .julia$initialized) {
        return(invisible(julia))
    }

    ## for rstudio notebook
    notebook <- check_notebook()
    ## not verbose in notebook
    verbose <- verbose && (!notebook)

    JULIA_HOME <- julia_locate(JULIA_HOME)

    if (is.null(JULIA_HOME)) {
        stop("Julia is not found.")
    }

    img_abs_path <-normalizePath(paste(JULIA_HOME,relative_sysimage_path, sep = "/"), mustWork = F)

    if(!file.exists(img_abs_path) && relative_sysimage_path != "default")
       stop("sysimage at path: ", img_abs_path, " is not found.",
            "you have to specify the path relative to JULA_HOME directory",
            "which is currently: ", JULIA_HOME)

    .julia$bin_dir <- JULIA_HOME

    .julia$VERSION <- julia_line(c("-e", "print(VERSION)"), stdout = TRUE)

    if (newer("0.5.3", .julia$VERSION)) {
        stop(paste0("Julia version ", .julia$VERSION, " at location ", JULIA_HOME, " is found.",
                    " But the version is too old and is not supported. Please install current release julia from https://julialang.org/downloads/ to use JuliaCall"))
    }

    if (verbose) message(paste0("Julia version ",
                                .julia$VERSION,
                                " at location ",
                                JULIA_HOME,
                                " will be used."))

    dll_command <- system.file("julia/libjulia.jl", package = "JuliaCall")
    .julia$dll_file <- julia_line(dll_command, stdout = TRUE)

    if (!is.character(.julia$dll_file)) {
        stop("libjulia cannot be located.")
    }

    if (!isTRUE(file.exists(.julia$dll_file))) {
        stop("libjulia located at ", .julia$dll_file, " is not a valid file.")
    }

    ## if (verbose) message("Julia initiation...")

    if (.Platform$OS.type == "windows") {
        ## libm is needed to load seperately only for Julia version 0.6.x

        if (newer("0.6.5", .julia$VERSION)) {
            libm <- julia_line(c("-e", "print(Libdl.dlpath(Base.libm_name))"), stdout = TRUE)
            dyn.load(libm, DLLpath = .julia$bin_dir)
        }

        # following is required to load dll dependencies from JULIA_HOME
        cur_dir <- getwd()
        setwd(.julia$bin_dir)
        on.exit(setwd(cur_dir))
    }

    ## seems okay to try to load libjulia earlier, except on osx
    if (!identical(get_os(), "osx")) {
        try(dyn.load(.julia$dll_file))
    }

    juliacall_initialize(.julia$dll_file,
                         .julia$bin_dir,
                         relative_sysimage_path)

    ## if (verbose) message("Finish Julia initiation.")

    .julia$cmd <- function(cmd){
        if (!(length(cmd) == 1 && is.character(cmd))) {
            stop("cmd should be a character scalar.")
        }
        if (!juliacall_cmd(cmd)) {
            stop(paste0("Error happens when you try to execute command ", cmd, " in Julia.
                        To have more helpful error messages,
                        you could considering running the command in Julia directly"))
        }
    }

    reg.finalizer(.julia,
                  function(e){
                      message("Julia exit.");
                      juliacall_atexit_hook(0);
                      },
                  onexit = TRUE)

    .julia$cmd(paste0('ENV["R_HOME"] = "', R.home(), '"'))

    if (verbose) message("Loading setup script for JuliaCall...")

    if (isTRUE(install)) {
        install_dependency()
    }

    if (isTRUE(rebuild)) {
        rebuild()
    }

    if (!newer(.julia$VERSION, "0.7.0")) {
        ## message("Before 0.7.0")
        .julia$cmd(paste0('include("', system.file("julia/setup.jl", package = "JuliaCall"), '")'))
    }
    else {
        ## message("After 0.7.0")
        .julia$cmd(paste0('Base.include(Main,"',
                          system.file("julia/setup.jl", package = "JuliaCall"), '")'))
    }

    if (verbose) message("Finish loading setup script for JuliaCall.")

    .julia$do.call_ <- juliacall_docall

    julia$VERSION <- .julia$VERSION

    ## Check whether we need to set up RmdDisplay
    ## Pay attention to rstudio notebook
    .julia$rmd <- check_rmd() || notebook
    .julia$notebook <- notebook

    ## useRCall will be used later in julia_console,
    ## because in the hook RCall.rgui_start() will be executed,
    ## then when we quit the console,
    ## RCall.rgui_stop() needs to be executed.

    julia$useRCall <- useRCall

    .julia$initialized <- TRUE

    # This part of code has all been integrated into setup.jl script
    #
    # display_needed <- julia_eval("length(Base.Multimedia.displays)") < 2
    #
    # # print(display_needed)
    #
    # if (display_needed) {
    #     julia_command("Base.pushdisplay(JuliaCall.basic_display);")
    # }

    if (useRCall) {
        julia$command("using RCall")
        julia$command("Base.atreplinit(JuliaCall.setup_repl);")
    }

    if (interactive()) {
        julia_command("Core.eval(Base, :(is_interactive = true));")
    }

    if (isTRUE(getOption("jupyter.in_kernel"))) {
        julia_command("Base.pushdisplay(JuliaCall.irjulia_display);")
    }

    if (.julia$rmd) {
        julia_command("Base.pushdisplay(JuliaCall.rmd_display);")
    }

    ## a dirty fix for Plots GR backend
    julia_command('ENV["GKSwstype"]="pdf";')
    julia_command('ENV["GKS_FILEPATH"] = tempdir();')

    ## Suppress pyplot gui
    julia_command('ENV["MPLBACKEND"] = "Agg";')

    .julia$simple_call_ <- julia_eval("JuliaCall.simple_call")
  
    Sys.setenv(PATH = paste0(Sys.getenv("PATH"), ";", .julia$bin_dir))

    invisible(julia)
}

install_dependency <- function(){
    ## `RCall` needs to be precompiled with the current R.
    julia_line(c(system.file("julia/install_dependency.jl", package = "JuliaCall"),
                 R.home()),
               stdout = TRUE,
               stderr = TRUE)
}

rebuild <- function(){
    ## `RCall` needs to be precompiled with the current R.
    julia_line(c(system.file("julia/rebuildRCall.jl", package = "JuliaCall"),
                 R.home()),
               stdout = TRUE,
               stderr = TRUE)
}
