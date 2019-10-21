pkgname <- "diffeqr"
source(file.path(R.home("share"), "R", "examples-header.R"))
options(warn = 1)
options(pager = "console")
library('diffeqr')

base::assign(".oldSearch", base::search(), pos = 'CheckExEnv')
base::assign(".old_wd", base::getwd(), pos = 'CheckExEnv')
cleanEx()
nameEx("dae.solve")
### * dae.solve

flush(stderr()); flush(stdout())

### Name: dae.solve
### Title: Solve Differential-Algebraic Equations (DAE)
### Aliases: dae.solve

### ** Examples






cleanEx()
nameEx("dde.solve")
### * dde.solve

flush(stderr()); flush(stdout())

### Name: dde.solve
### Title: Solve Delay Differential Equations (DDE)
### Aliases: dde.solve

### ** Examples






cleanEx()
nameEx("diffeq_setup")
### * diffeq_setup

flush(stderr()); flush(stdout())

### Name: diffeq_setup
### Title: Setup diffeqr
### Aliases: diffeq_setup

### ** Examples






cleanEx()
nameEx("ode.solve")
### * ode.solve

flush(stderr()); flush(stdout())

### Name: ode.solve
### Title: Solve Ordinary Differential Equations (ODE)
### Aliases: ode.solve

### ** Examples






cleanEx()
nameEx("sde.solve")
### * sde.solve

flush(stderr()); flush(stdout())

### Name: sde.solve
### Title: Solve Stochastic Differential Equations (SDE)
### Aliases: sde.solve

### ** Examples






### * <FOOTER>
###
cleanEx()
options(digits = 7L)
base::cat("Time elapsed: ", proc.time() - base::get("ptime", pos = 'CheckExEnv'),"\n")
grDevices::dev.off()
###
### Local variables: ***
### mode: outline-minor ***
### outline-regexp: "\\(> \\)?### [*]+" ***
### End: ***
quit('no')
