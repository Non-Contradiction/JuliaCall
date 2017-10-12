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

* `julia.do_call` and `julia_call` now accept keyword arguments.
* `JuliaCall` works in Jupyter R notebook.
* `JuliaCall` works in R Markdown.
  The display system currently **only work for html document**.
  When there is no return from julia function and there is a need to display,
  a div with class=‘JuliaDisplay’ will be inserted into the html document
  with the corresponding content.
* Julia engine in R Markdown through `JuliaCall`.

# JuliaCall 0.9.0.9000

* Try to convert julia tuple.
* Add `JuliaObject`, which serves as a proxy in R for julia object,
  which is the automatic conversion target when other choices are not possible.
* `julia_setup()` doesn't need to be called first unless you want to force
  julia to restart or you need to set the julia path.

# JuliaCall 0.9.1.9000

* Improve `JuliaObject`, same Julia object could enter julia_object_dict only once.
  And the display of `JuliaObject` becomes better.
  Also every common types of Julia Object could be wrapped by `JuliaObject`.
* The users could now choose to have `JuliaObject` type return value instead of
  R Object.
* Dot notation in julia is now accepted through the `julia_call` interface.
* `julia_eval_string` is deprecated in favor of `julia_eval`.

# JuliaCall 0.9.2.9000

* New Julia display system `plotsViewer()`, which integrates better into R.
* Fits several bugs in `JuliaCall`, like removing using of depreated function.
* Improve display systems of RMarkdown and Jupyter R Notebook.

# JuliaCall 0.9.3

* Second release on CRAN.
