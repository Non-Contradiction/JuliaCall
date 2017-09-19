import Base.Multimedia.display

type IRjuliaDisplay <: Display
    mime_dict:: Dict
end

dict = Dict()

dict["application/json"] = "IRdisplay::display_json"
dict["application/javascript"] = "IRdisplay::display_javascript"
dict["text/html"] = "IRdisplay::display_html"
dict["text/plain"] = "IRdisplay::display_html"
dict["text/markdown"] =  "IRdisplay::display_markdown"
dict["text/latex"] = "IRdisplay::display_latex"
dict["image/png"] = "function(x) IRdisplay::display_png(charToRaw(x))"
dict["image/jpeg"] = "function(x) IRdisplay::display_jpeg(charToRaw(x))"
dict["application/pdf"] = "function(x) IRdisplay::display_pdf(charToRaw(x))"
dict["image/svg+xml"] = "IRdisplay::display_svg"

irjulia_display = IRjuliaDisplay(dict)

## This function taken from IJulia
israwtext(::MIME, x::AbstractString) = true
israwtext(::MIME"text/plain", x::AbstractString) = false
israwtext(::MIME, x) = false

## This function taken from IJulia
# convert x to a string of type mime, making sure to use an
# IOContext that tells the underlying show function to limit output
function limitstringmime(mime::MIME, x)
    buf = IOBuffer()
    if istextmime(mime)
        if israwtext(mime, x)
            return String(x)
        else
            show(IOContext(buf, :limit=>true), mime, x)
        end
    else
        b64 = Base64EncodePipe(buf)
        if isa(x, Vector{UInt8})
            write(b64, x) # x assumed to be raw binary data
        else
            show(IOContext(b64, :limit=>true), mime, x)
        end
        close(b64)
    end
    return String(take!(buf))
end

function display(display::IRjuliaDisplay, m::MIME, x)
    s = limitstringmime(m, x)
    display_method = RCall.reval(display.mime_dict[string(m)])
    display_method(s)
end

function display(d::IRjuliaDisplay, p)
    for m in ["text/html", "image/png", "image/jpeg", "application/pdf", "image/svg+xml",
        "text/markdown", "text/latex", "application/javascript", "text/plain"]
        try
            display(d,m, p)
            return
        end
    end
    throw(MethodError)
end

# Base.pushdisplay(irjulia_display)
