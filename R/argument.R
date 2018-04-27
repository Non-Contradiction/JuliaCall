separate_arguments <- function(arglist){
    if (is.null(names(arglist))) {
        return(list(unamed = arglist, named = list()))
    }
    idx <- names(arglist) != ""
    unamed <- arglist[!idx]
    names(unamed) <- NULL
    return(list(unamed = unamed, named = arglist[idx]))
}
