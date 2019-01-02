Test
================
Changcheng Li
2017/9/23

## Use JuliaCall as Julia Engine in R Markdown

To use `JuliaCall` package for julia engine in R Markdown document. Just
set the engine for julia to `JuliaCall::eng_juliacall` like this:

``` r
knitr::knit_engines$set(julia = JuliaCall::eng_juliacall)
```

``` julia
## This is a julia language chunk.
## In julia, the command without ending semicolon will trigger the display
## so is JuliaCall package. 
## The julia display will follow immediately after the corresponding command
## just as the R code in R Markdown.
a = sqrt(2)
```

    ## 1.4142135623730951

``` julia
a = sqrt(2);

b = begin println(sqrt(2)); sqrt(2) end
```

    ## 1.4142135623730951

    ## 1.4142135623730951

``` julia
```

## Get Access to Julia in R Chunk

And you can also get access to julia variables in R code chunk quite
easily using `JuliaCall`, for example:

``` r
## This is a R language chunk.
## In the previous julia chunk, we define variable a, 
## we can use functions in JuliaCall to get access to it.
JuliaCall::julia_eval("a") + JuliaCall::julia_eval("b")
```

    ## [1] 2.828427
