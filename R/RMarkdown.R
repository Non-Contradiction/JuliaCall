check_rmd <- function(){
    if (!isTRUE(getOption("knitr.in.progress"))) {
        return(FALSE)
    }
    r <- rmarkdown::all_output_formats(knitr::current_input())
    if (!length(r) == 1) {
        return(FALSE)
    }
    ## Currently we only fully support html output
    !is.null(grep("html", as.character(r)))
}

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
