.julia <- new.env(parent = emptyenv())
.julia$initialized <- FALSE

julia <- new.env(parent = .julia)

#' Check whether julia is available on the path.
#'
#' \code{julia_check} checks if julia is available on the path.
#'
#' @return whether julia is available on the path.
#'
#' @examples
#' julia_check()
#'
#' @export
julia_check <- function(){
    tryCatch(system('julia -e "println(1)"', intern = TRUE) == "1",
             warning = function(war){},
             error = function(err) FALSE)
}
