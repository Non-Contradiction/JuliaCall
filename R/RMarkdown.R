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
    output <- do.call(paste0, as.list(readLines(tmp)))
    if (length(output) > 0) {
        output <- paste0("<div class = 'JuliaDisplay'>",
                         output,
                         "</div>")
        return(knitr::asis_output(output))
    }
    invisible()
}


#' Julia language engine in R Markdown
#'
#' Julia language engine in R Markdown
#'
#' @param options a list of chunk options
#'
#' @examples
#'
#' knitr::knit_engines$set(julia = JuliaCall::eng_juliacall)
#'
#' @export
eng_juliacall <- function(options) {
    code <- options$code

    if (!options$eval) {
        knitr::engine_output(options, paste(code, collapse = "\n"), "")
    }

    if (!.julia$initialized) {
        julia_setup()
    }

    doc <- character()
    buffer <- character()
    ss <- character()

    for (line in code) {
        buffer <- paste(c(buffer, line), collapse = "\n")
        ss <- paste(c(ss, line), collapse = "\n")

        if (length(buffer) && (!julia_call("JuliaCall.incomplete", buffer))) {
            out <- tryCatch(julia_command(buffer),
                            error = function(e) {
                                e$message
                                })
            out <- as.character(out)
            if (options$results != 'hide' && length(out) > 0) {
                if (length(options$echo) > 1L || options$echo) {
                    doc <- paste(c(doc,
                                   knitr::knit_hooks$get('source')(ss, options)
                                   ),
                                 collapse = "\n")
                    ss <- character()
                }
                doc <- paste(c(doc, out), collapse = "\n")
            }
            buffer <- character()
        }
    }
    if (length(ss) > 0) {
        if (length(options$echo) > 1L || options$echo) {
            doc <- paste(c(doc,
                           knitr::knit_hooks$get('source')(ss, options)
                           ),
                         collapse = "\n")
            ss <- character()
        }
    }
    doc
}
