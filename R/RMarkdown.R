rmd_capture <- function(jcall){
    tmp <- tempfile()
    sink(tmp)
    r <- .julia$do.call_(jcall)
    if (inherits(r, "error")) stop(r)
    sink()
    output <- paste0("<div class = 'JuliaDisplay'>",
                     do.call(paste0, as.list(readLines(tmp))),
                     "</div>")
    knitr::asis_output(output)
}
