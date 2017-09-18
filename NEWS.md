# JuliaCall 0.7.3

* First release on CRAN.
* `julia_setup` for initial setup of `JuliaCall`.
* `julia_eval_string`, `julia_command` for executing commands in julia.
* `julia_do.call` and `julia_call` for calling functions in julia.
* Functions to deal with julia packages.
* Helper functions like `julia_help`.

# JuliaCall 0.7.4.9000

* Added a `NEWS.md` file to track changes to the package.
* Add helpful error messages in libjulia DLL load and compilation.
* Add `julia_assign` which can assign a value to a name in julia with automatic type conversion.
* Give the option to set path for julia.
* Deprecate `julia_check`.
* `julia_console`. Now there is a fully functional julia repl in R terminal,
  and a usable julia console when you use IDE for R.
* In `julia_setup`, there is an option whether or not to use RCall.jl,
  RCall's R REPL mode and rgui will be set correctly.

# JuliaCall 0.7.5.9000

* Have a basic julia display system, now the plot functionality in Julia works (mostly).
* `JuliaCall` is more consistent with julia.

# JuliaCall 0.8.0.9000

* `julia.do_call` and `julia_call` now accept key word arguments.
