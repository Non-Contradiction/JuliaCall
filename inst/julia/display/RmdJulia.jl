# import Base.Multimedia.display

struct RmdDisplay <: Display
end

const begin_plot_in_R = R"JuliaCall:::begin_plot"
const finish_plot_in_R = R"JuliaCall:::finish_plot"

function plot_display(display::RmdDisplay, x)
    path = rcopy(begin_plot_in_R())
    mkpath(dirname(path))
    Main.Plots.savefig(x, path)
    finish_plot_in_R()
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
    catch e;
    end
    try
        text_display(display, x)
        return
    catch e;
    end
    throw(MethodError)
end

const rmd_display = RmdDisplay()
