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

svg <- function(){
    jslib()
    julia_command("pushdisplay(JuliaCall.svg_display);")
}

png <- function(){
    julia_command("pushdisplay(JuliaCall.png_display);")
}


#' Julia plots viewer in R.
#'
#' \code{plotsViewer} lets you view julia plots in R.
#'
#' @export
plotsViewer <- function(){
    png()
    svg()
}
