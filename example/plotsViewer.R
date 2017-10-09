library(JuliaCall)
julia_setup()
plotsViewer()
julia_library("Plots")
julia_command("pyplot()")
julia_command("Plots.plot([1 2], [3 5])")

julia_command("plotlyjs()")
julia_command("Plots.plot([1 2], [3 4])")

julia_command("plotly()")
julia_command("Plots.plot([1 2], [3 6])")

julia_command("gr()")
julia_command("Plots.plot([1 2], [3 7])")
