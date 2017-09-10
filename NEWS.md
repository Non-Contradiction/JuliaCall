# JuliaCall 0.7.3

* First release on CRAN.

# JuliaCall 0.7.4.9000

* Added a `NEWS.md` file to track changes to the package.
* Add helpful error messages in libjulia DLL load and compilation.
* Add `julia_assign` which can assign a value to a name in julia with automatic type conversion.
* Give the option to set path for julia.
* Deprecate `julia_check()`.
* Start working on `julia_console`. Now there is a fully functional julia repl in terminal.
* When `julia_setup()`, there is an option whether or not to use RCall.jl,
  RCall's R REPL mode and rgui will be set correctly.
