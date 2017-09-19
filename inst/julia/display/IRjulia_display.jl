import Base.Multimedia.display

type IRjuliaDisplay <: Display
    mime_dict:: Dict
end

dict = Dict()

dict["application/json"] = "IRdisplay::display_json"
dict["application/javascript"] = "IRdisplay::display_javascript"
dict["text/html"] = "IRdisplay::display_html"
dict["text/markdown"] =  "IRdisplay::display_markdown"
dict["text/latex"] = "IRdisplay::display_latex"
dict["image/png"] = "IRdisplay::display_png"
dict["image/jpeg"] = "IRdisplay::display_jpeg"
dict["application/pdf"] = "IRdisplay::display_pdf"
dict["image/svg+xml"] = "IRdisplay::display_svg"

irjulia_display = IRjuliaDisplay(dict)

function display(display::IRjuliaDisplay, m::MIME, x)
    a = IOBuffer()
    show(a, m, x)
    s = readstring(seek(a, 0))
    display_method = RCall.reval(display.mime_dict[string(m)])
    display_method(s)
end

function display(d::IRjuliaDisplay, p)
    for m in ["text/html", "image/png", "application/pdf", "image/svg+xml"]
        try
            display(d,m, p)
            return
        end
    end
    throw(MethodError)
end

# Base.pushdisplay(irjulia_display)
