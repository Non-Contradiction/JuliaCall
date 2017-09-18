separate_arguments <- function(arglist){
    if (is.null(names(arglist))) {
        return(list(unamed = arglist, named = list()))
    }
    idx <- names(arglist) != ""
    return(list(unamed = arglist[!idx], named = arglist[idx]))
}
