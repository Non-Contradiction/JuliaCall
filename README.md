
<!-- README.md is generated from README.Rmd. Please edit that file -->
JuliaCall for Seamless Integration of R and Julia
=================================================

Package JuliaCall is an R interface to 'Julia', which is a high-level, high-performance dynamic programming language for numerical computing, see <https://julialang.org/> for more information.

[![Travis-CI Build Status](https://travis-ci.org/Non-Contradiction/JuliaCall.svg?branch=master)](https://travis-ci.org/Non-Contradiction/JuliaCall)

Installation
------------

You can get `JuliaCall` by

``` r
devtools::install_github("Non-Contradiction/JuliaCall")
```

Basic Usage
-----------

``` r
library(JuliaCall)

## Do initial setup

julia <- julia_setup()
#> Julia version 0.6.0 found.
#> Julia initiation...

## Different ways for using Julia to calculate sqrt(2)

julia$command("a = sqrt(2)"); julia$eval_string("a")
#> [1] 1.414214

julia$eval_string("sqrt(2)")
#> [1] 1.414214

julia$call("sqrt", 2)
#> [1] 1.414214

julia$eval_string("sqrt")(2)
#> [1] 1.414214

2 %>J% sqrt
#> [1] 1.414214

## You can use `julia$exists` as `exists` in R to test
## whether a function or name exists in Julia or not

julia$exists("sqrt")
#> [1] TRUE
julia$exists("c")
#> [1] FALSE

## You can use `julia$help` to get help for Julia functions

julia$help("sqrt")
#> ```
#> sqrt(x)
#> ```
#> 
#> Return $\sqrt{x}$. Throws [`DomainError`](@ref) for negative [`Real`](@ref) arguments. Use complex negative arguments instead. The prefix operator `√` is equivalent to `sqrt`.

## Functions related to installing and using Julia packages

julia$install_package("Optim")
julia$install_package_if_needed("Optim")
julia$installed_package("Optim")
#> [1] "0.9.3"
julia$using("Optim") ## Same as julia$library("Optim")
#> Second try succeed.
julia$library("Optim")
#> Second try succeed.
```

How to Get Help?
----------------

One way to get help is just using `julia$help` like the following example:

``` r
julia$help("sqrt")
#> ```
#> sqrt(x)
#> ```
#> 
#> Return $\sqrt{x}$. Throws [`DomainError`](@ref) for negative [`Real`](@ref) arguments. Use complex negative arguments instead. The prefix operator `√` is equivalent to `sqrt`.

julia$help("sqrtm")
#> ```
#> sqrtm(A)
#> ```
#> 
#> If `A` has no negative real eigenvalues, compute the principal matrix square root of `A`, that is the unique matrix $X$ with eigenvalues having positive real part such that $X^2 = A$. Otherwise, a nonprincipal square root is returned.
#> 
#> If `A` is symmetric or Hermitian, its eigendecomposition ([`eigfact`](@ref)) is used to compute the square root. Otherwise, the square root is determined by means of the Björck-Hammarling method [^BH83], which computes the complex Schur form ([`schur`](@ref)) and then the complex square root of the triangular factor.
#> 
#> [^BH83]: Åke Björck and Sven Hammarling, "A Schur method for the square root of a matrix", Linear Algebra and its Applications, 52-53, 1983, 127-140. [doi:10.1016/0024-3795(83)80010-X](http://dx.doi.org/10.1016/0024-3795(83)80010-X)
#> 
#> # Example
#> 
#> ```jldoctest
#> julia> A = [4 0; 0 4]
#> 2×2 Array{Int64,2}:
#>  4  0
#>  0  4
#> 
#> julia> sqrtm(A)
#> 2×2 Array{Float64,2}:
#>  2.0  0.0
#>  0.0  2.0
#> ```
```

And you are more than welcome to contact me about `JuliaCall` at <lch34677@gmail.com> or <cxl508@psu.edu>.

JuliaCall for R Package Developers
----------------------------------

If you are interested in developing an R package which is an interface for a Julia package, `JuliaCall` is an ideal choice for that!

Basically you only need to find the Julia function or Julia module you want to have in `R` and then just `using` the module and `call` the function. An example is `ipoptjlr`, which can be found at <https://github.com/Non-Contradiction/ipoptjlr>.

If you have any issues in developing an `R` package using `JuliaCall`, you may report it using the link: <https://github.com/Non-Contradiction/JuliaCall/issues/new>. Or email me at <lch34677@gmail.com> or <cxl508@psu.edu>.

Suggestion and Issue Reporting
------------------------------

`JuliaCall` is under active development now. Any suggestion or issue reporting is welcome! You may report it using the link: <https://github.com/Non-Contradiction/JuliaCall/issues/new>. Or email me at <lch34677@gmail.com> or <cxl508@psu.edu>.

And if you encounter some issues which crash `R` or `RStudio`, then you may have met segfault errors. I am very sorry. And I am trying my best to remove errors like that. It will be much appreciated if you can

-   download the source of `JuliaCall` from Github,
-   open `JuliaCall.Rproj` in your RStudio or open `R` from the directory where you download the source of `JuliaCall`,
-   run `devtools::check()` to see the result of `R CMD check` for `JuliaCall` on your machine,
-   and paste the result to the issue report.
