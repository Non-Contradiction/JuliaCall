library(JuliaCall)
julia_setup()
plotsViewer()
julia_library("Plots")

julia_command("plotlyjs()")
julia_command("Plots.plot([1, 2], [3, 4])")

julia_command("plotly()")
julia_command("Plots.plot([1, 2], [3, 6])")

julia_command("gr()")
julia_command("Plots.plot([1, 2], [3, 7])")

## pyplot backend is not stable.
##julia_command("pyplot()")
##julia_command("Plots.plot([1, 2], [3, 5])")

## This currently doesn't work because of Julia issue 14577
## https://github.com/JuliaLang/julia/issues/14577
## julia_command("pgfplots()")
## julia_command("Plots.plot([1 2], [3 7])")
