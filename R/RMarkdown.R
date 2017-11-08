begin_plot <- function(){
    options <- knitr::opts_current$get()
    if (is.null(options$fig.cur)) {
        number <- 1L
    }
    else {
        number <- options$fig.cur
    }
    path <- knitr::fig_path(options$dev, options, number)
    .julia$pending_plot <- knitr::include_graphics(path)
    path
}

finish_plot <- function(){
    options <- knitr::opts_current$get()
    if (is.null(options$fig.cur)) {
        number <- 1L
    }
    else {
        number <- options$fig.cur
    }
    knitr::opts_current$set(fig.cur = number + 1L)
    julia$current_plot <- .julia$pending_plot
}

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

# rmd_capture <- function(jcall){
#     tmp <- tempfile()
#     sink(tmp)
#     r <- .julia$do.call_(jcall)
#     if (inherits(r, "error")) stop(r)
#     sink()
#     output <- paste(readLines(tmp, warn = FALSE), collapse = "\n")
#     ## Suppress the output when there is no output
#     if (length(output) > 0 && nchar(trimws(output)) > 0) {
#         # print(output)
#         ## A dirty fix
#         ## use <pre> to prevent markdown code block triggered by
#         ## four white spaces,
#         ## which is crucial for displaying plotly plots,
#         ## but it destroys the formatting of markdown
#         output <- paste0("<pre><div class = 'JuliaDisplay'>", output, "</div></pre>")
#         return(knitr::asis_output(output))
#     }
#     invisible()
# }


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
