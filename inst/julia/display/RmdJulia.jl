import Base.Multimedia.display

type RmdDisplay <: Display
end

function plot_display(display::RmdDisplay, x)
    path = rcopy(R"JuliaCall:::begin_plot()")
    mkpath(path)
    Plots.savefig(x, path)
    R"JuliaCall:::finish_plot()"
end

function text_display(display::RmdDisplay, x)
    s = limitstringmime(MIME("text/plain"), x)
    RCall.rcall(:cat, s)
end

function display(display::RmdDisplay, x)
    try
        plot_display(display, x)
        return
    end
    try
        text_display(display, x)
        return
    end
    throw(MethodError)
end

rmd_display = RmdDisplay()
