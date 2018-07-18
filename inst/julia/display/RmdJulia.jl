import Base.Multimedia.display

type RmdDisplay <: Display
end

function plot_display(display::RmdDisplay, x)
    path = rcopy(R"JuliaCall:::begin_plot()")
    mkpath(dirname(path))
    Main.Plots.savefig(x, path)
    R"JuliaCall:::finish_plot()"
end

const text_display_in_R = R"JuliaCall:::text_display"

function text_display(display::RmdDisplay, x)
    s = limitstringmime(MIME("text/plain"), x)
    text_display_in_R(s)
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

const rmd_display = RmdDisplay()
