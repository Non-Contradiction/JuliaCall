## This function is used at the beginning of the julia_call interface
## to eraze the previous outputs
output_reset <- function(){
    julia$current_text <- NULL
    julia$current_plot <- NULL
}

## This function is used at the end of the julia_call interface
## to wrap the current output and return it
output_wrap <- function(){
    if (!is.null(julia$current_plot)) return(julia$current_plot)
    if (!is.null(julia$current_text)) return(julia$current_text)
}

## This function is used by Julia plot_display function
begin_plot <- function(){
    options <- knitr::opts_current$get()
    if (is.null(options$Jfig.cur)) {
        number <- 1L
    }
    else {
        number <- options$Jfig.cur
    }
    path <- knitr::fig_chunk(label = paste0(options$label, "J"),
                             ext = options$dev, number = number)
    .julia$pending_plot <- knitr::include_graphics(path)
    .julia$pending_plot_number <- number
    path
}

## This function is used by Julia plot_display function
finish_plot <- function(){
    knitr::opts_current$set(Jfig.cur = .julia$pending_plot_number + 1L)
    julia$current_plot <- .julia$pending_plot
}

## This function is used by Julia text_display function
text_display <- function(x, options = knitr::opts_current$get()){
    julia$current_text <- knitr::knit_hooks$get('output')(x, options)
}

check_rmd <- function(){
    if (!isTRUE(getOption("knitr.in.progress"))) {
        return(FALSE)
    }
    TRUE
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
