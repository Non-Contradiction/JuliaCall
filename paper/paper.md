---
title: 'JuliaCall: an R package for seamless integration between R and Julia'
tags:
  - R
  - Julia
authors:
 - name: Changcheng Li
   orcid: 0000-0001-7022-0947
   affiliation: 1
affiliations:
 - name: Department of Statistics, Pennsylvania State University at University Park
   index: 1
date: 19 February 2019
bibliography: paper.bib
---

# Summary

`R` is a widely used software and computing environment for statistics,
which provides a variety of statistical techniques and packages [@R].
There are many `R` packages which are interfaces to other computer languages
to bring new functionalities to `R` or to accelerate computations,
such as  `Rcpp` [@Rcpp] and `V8` [@V8].
The package `JuliaCall` provides an `R` interface to `Julia`,
which is a computer language for high-performance technique computing [@bezanson2017julia].
`JuliaCall` embeds `Julia` in `R`,
and provides functions to evaluate `Julia` commands, to call `Julia` functions,
to transmit data objects between `R` and `Julia`, and so on.
It also provides many utilities for user convenience.
For example, `JuliaCall` gives detailed error messages for the embedded `Julia`.
It also provides `Julia` package management functions such as installation and loading,
and utility functions to get the documentation of `Julia` functions.
`JuliaCall` can also be used in R Markdown document as the engine of `Julia` language, see Section 2.77 in [@xie2018r].

There are `R` packages which wraps `Julia` packages based on `JuliaCall` to provide new functionalities
or performance improvements to some existing packages in `R`.
[`autodiffr`](https://github.com/Non-Contradiction/autodiffr) [@autodiffr] provides automatic differentiation to `R` functions by wrapping
[`ForwardDiff.jl`](https://github.com/JuliaDiff/ForwardDiff.jl) and
[`ReverseDiff.jl`](https://github.com/JuliaDiff/ReverseDiff.jl).
[`convexjlr`](https://github.com/Non-Contradiction/convexjlr) [@convexjlr] is an `R` package for Disciplined Convex Programming (DCP) by providing a high level wrapper for [`Convex.jl`](https://github.com/JuliaOpt/Convex.jl).
[`diffeqr`](https://github.com/JuliaDiffEq/diffeqr) [@diffeqr] solves differential equations in `R` which utilizes [`DifferentialEquations.jl`](http://docs.juliadiffeq.org/latest/).
[`FixedEffectjlr`](https://github.com/eloualiche/FixedEffectjlr) [@fixedeffectjlr] estimates large fixed effects models in `R` by providing an interface to [`FixedEffectModels.jl`](https://github.com/matthieugomez/FixedEffectModels.jl).

Besides `JuliaCall`, there are also some other interfaces between `R` and `Julia`:
`R` packages [`XRJulia`](https://github.com/johnmchambers/XRJulia),
[`rjulia`](https://github.com/armgong/rjulia),
and `Julia` package [`RCall.jl`](https://github.com/JuliaInterop/RCall.jl).
Package `XRJulia` follows the extending `R` interface implemented by the `XR` package, which connects to `Julia` from `R` [@chambers2017extending].
It uses JavaScript Object Notation (JSON) format to transmit data, while `JuliaCall` copies objects in memory between `R` and `Julia`.
It has performance disadvantages compared to `JuliaCall`.
Table 1 depicts the times needed to transmit a $500\times 500$ matrix full of ones from `R` v3.5.2 to `Julia` v1.0.3 using `JuliaCall` v0.16.4 and `XRJulia` Github master b6224fa at the time of writing (there is no released version of `XRJulia` to support `Julia` v1.0 yet).
The times are measured by `R` package `microbenchmark` with 1000 evaluation times.
The script with the benchmark code and setup instructions can be found in the `paper` directory in [`JuliaCall` Github repository](https://github.com/Non-Contradiction/JuliaCall).
In the header of the table, "lq" means lower quantile and "uq" means upper quantile.
From Table 1, it can be seen that `JuliaCall` has a significant speed advantage of transmitting data between `R` and `Julia`.
Package `RJulia` [@rjulia] also embeds `Julia` in `R`, but its functionality is quite limited,
has not been updated for more than one year,
and does not support `Julia` v1.0 and v1.1 at the time of writing.
`RCall.jl` is a `Julia` package which embeds `R` in `Julia`.
It is a dependency for `JuliaCall`, and `JuliaCall` utilizes `RCall.jl`'s type conversion between `R` and `Julia`.
`JuliaCall` integrates well with `RCall.jl`, and it is the default for `JuliaCall` to load `RCall.jl` in the embedded `Julia` automatically at starting.
With `JuliaCall` and `RCall.jl`, it is easy to use `R` from `Julia` and `Julia` from `R`.

|Time in ms                |       min|       lq|     mean|   median|       uq|      max|
|:-------------------------|---------:|--------:|--------:|--------:|--------:|--------:|
|XRJulia                   | 24.680699| 30.65626| 39.29180| 33.98684| 38.83510| 454.6484|
|JuliaCall                 |  9.790442| 11.79500| 16.39797| 12.55267| 13.90892| 406.0156|

Table: Time measurements for `XRJulia` and `JuliaCall` to transmit a $500 \times 500$ matrix from `R` to `Julia`.

Users can get stable releases of `JuliaCall` from [CRAN](https://CRAN.R-project.org/package=JuliaCall), and the latest development version from [`JuliaCall` Github repository](https://github.com/Non-Contradiction/JuliaCall).
Documentation can be found in the package as well as on [CRAN](https://cran.r-project.org/web/packages/JuliaCall/JuliaCall.pdf).
Bug reports and other feedback can be submitted to [GitHub issue page](https://github.com/Non-Contradiction/JuliaCall/issues).

# References
