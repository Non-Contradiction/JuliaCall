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

@time b = sqrt(2)
```

    ##   0.000005 seconds (6 allocations: 224 bytes)

    ## 1.4142135623730951

``` julia

## And lots of different types of display are supported in JuliaCall.
## Like markdown.
@doc sqrt
```

    ##   sqrt(x)
    ## 
    ##   Return \sqrt{x}. Throws DomainError for negative Real arguments. Use complex
    ##   negative arguments instead. The prefix operator √ is equivalent to sqrt.
    ## 
    ##   Examples
    ##   ≡≡≡≡≡≡≡≡≡≡
    ## 
    ##   julia> sqrt(big(81))
    ##   9.0
    ##   
    ##   julia> sqrt(big(-81))
    ##   ERROR: DomainError with -8.1e+01:
    ##   NaN result for non-NaN input.
    ##   Stacktrace:
    ##    [1] sqrt(::BigFloat) at ./mpfr.jl:501
    ##   [...]
    ##   
    ##   julia> sqrt(big(complex(-81)))
    ##   0.0 + 9.0im
    ## 
    ##   sqrt(A::AbstractMatrix)
    ## 
    ##   If A has no negative real eigenvalues, compute the principal matrix square
    ##   root of A, that is the unique matrix X with eigenvalues having positive real
    ##   part such that X^2 = A. Otherwise, a nonprincipal square root is returned.
    ## 
    ##   If A is symmetric or Hermitian, its eigendecomposition (eigen) is used to
    ##   compute the square root. Otherwise, the square root is determined by means
    ##   of the Björck-Hammarling method [^BH83], which computes the complex Schur
    ##   form (schur) and then the complex square root of the triangular factor.
    ## 
    ##   │ [^BH83]
    ##   │
    ##   │  Åke Björck and Sven Hammarling, "A Schur method for the square
    ##   │  root of a matrix", Linear Algebra and its Applications, 52-53,
    ##   │  1983, 127-140. doi:10.1016/0024-3795(83)80010-X
    ##   │  (https://doi.org/10.1016/0024-3795(83)80010-X)
    ## 
    ##   Examples
    ##   ≡≡≡≡≡≡≡≡≡≡
    ## 
    ##   julia> A = [4 0; 0 4]
    ##   2×2 Array{Int64,2}:
    ##    4  0
    ##    0  4
    ##   
    ##   julia> sqrt(A)
    ##   2×2 Array{Float64,2}:
    ##    2.0  0.0
    ##    0.0  2.0

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
