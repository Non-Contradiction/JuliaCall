jslib <- function(){
    dir <- tempdir()
    lib <- file.path(dir, "library")
    if (!dir.exists(lib)) {
        dir.create(lib)
    }
    file.copy(system.file(file.path("js", "plotly-latest.min.js"),
                          package = "JuliaCall",
                          mustWork = TRUE),
              file.path(lib, "plotly-latest.min.js"))
}

#' Julia plots viewer in R.
#'
#' \code{plotsViewer} lets you view julia plots in R.
#'
#' @export
plotsViewer <- function(){
    jslib()
    julia_command("pushdisplay(JuliaCall.viewer_display);")
}
