import Base.Multimedia.display

type RmdDisplay <: Display
end

function plot_display(display::RmdDisplay, x)
    path = rcopy(R"JuliaCall:::begin_plot()")
    mkpath(dirname(path))
    Main.Plots.savefig(x, path)
    R"JuliaCall:::finish_plot()"
end

function text_display(display::RmdDisplay, x)
    s = limitstringmime(MIME("text/plain"), x)
    R"JuliaCall:::text_display"(s)
end

function display(display::RmdDisplay, x)
    try
        if isa(x, Main.Plots.Plot)
            plot_display(display, x)
            return
        end
    end
    try
        text_display(display, x)
        return
    end
    throw(MethodError)
end

rmd_display = RmdDisplay()
