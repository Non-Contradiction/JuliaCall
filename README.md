
<!-- README.md is generated from README.Rmd. Please edit that file -->
JuliaCall for Seamless Integration of R and Julia
=================================================

Package JuliaCall is an R interface to 'Julia', which is a high-level, high-performance dynamic programming language for numerical computing, see <https://julialang.org/> for more information.

[![Travis-CI Build Status](https://travis-ci.org/Non-Contradiction/JuliaCall.svg?branch=master)](https://travis-ci.org/Non-Contradiction/JuliaCall)

``` r
library(JuliaCall)

julia <- julia_setup()
#> Julia version 0.6.0 found.
#> Julia initiation...

julia$command("println(sqrt(2))")
#> NULL

julia$eval_string("sqrt(2)")
#> [1] 1.414214

julia$call("sqrt", 2)
#> [1] 1.414214

julia$eval_string("sqrt")(2)
#> [1] 1.414214

2 %>J% sqrt
#> [1] 1.414214
```
