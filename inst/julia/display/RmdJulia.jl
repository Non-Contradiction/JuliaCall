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

if julia07
    using Requires
else
    macro require_str() end
end

@require Plots="91a5bcdd-55d7-5caf-9e0b-520d859cae80" @eval begin

    function display(display::RmdDisplay, x::Plots.Plot)
        try
            plot_display(display, x)
            return
        catch e;
        end
        try
            text_display(display, x)
            return
        catch e;
        end
        throw(MethodError)
    end

    function plot_display(display::RmdDisplay, x::Plots.Plot)
        path = rcopy(begin_plot_in_R())
        mkpath(dirname(path))
        Plots.savefig(x, path)
        finish_plot_in_R()
    end

end


function display(display::RmdDisplay, x)
    try
        text_display(display, x)
        return
    catch e;
    end
    throw(MethodError)
end

const rmd_display = RmdDisplay()
