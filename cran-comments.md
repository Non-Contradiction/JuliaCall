## Test environments
* local OS X 10.13.4, R 3.5.0
* OS X 10.12.6 (on travis-ci), R 3.5.0
* ubuntu 14.04.5 (on travis-ci), R 3.5.0
* windows (on appveyor), R 3.5.0 and r-devel with Rtools35
* win-builder (devel and release)

## R CMD check results

0 errors | 0 warnings | 0 note

## Reverse dependencies
I have also run R CMD check on downstream dependencies of JuliaCall
(https://github.com/Non-Contradiction/JuliaCall/tree/master/revdep).
There are three downstream dependencies currently -- convexjlr, diffeqr and knitr.
The checking result of convexjlr is:
0 errors | 0 warnings | 0 notes
The checking result of diffeqr is:
0 errors | 0 warnings | 1 note
```
checking installed package size ... NOTE
  installed size is  9.4Mb
  sub-directories of 1Mb or more:
    doc   9.3Mb
```
The size of package diffeqr is larger because of its vignettes,
which has nothing to do with JuliaCall.
The checking result of knitr is:
0 errors | 0 warnings | 0 notes
