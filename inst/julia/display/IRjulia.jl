# import Base.Multimedia.display

struct RjuliaDisplay <: Display
    mime_dict:: Dict
end

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
            Base.invokelatest(show, IOContext(buf, :limit=>true), mime, x)
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

function display(display::RjuliaDisplay, m::MIME, x)
    s = limitstringmime(m, x)
    display_method = RCall.reval(display.mime_dict[string(m)])
    display_method(s)
end

function display(d::RjuliaDisplay, p)
    for m in ["text/html", "image/png", "image/jpeg", "application/pdf", "image/svg+xml",
        "text/markdown", "text/latex", "application/javascript", "text/plain"]
        try
            display(d, m, p)
            return
        catch e;
        end
    end
    throw(MethodError)
end

const irjulia_dict = Dict()

irjulia_dict["application/json"] = "IRdisplay::display_json"
irjulia_dict["application/javascript"] = "IRdisplay::display_javascript"
irjulia_dict["text/html"] = "function(x) IRdisplay::display_html(JuliaCall:::p_ly(JuliaCall:::html_wrap(x)))"
irjulia_dict["text/plain"] = "IRdisplay::display_html"
irjulia_dict["text/markdown"] =  "IRdisplay::display_markdown"
irjulia_dict["text/latex"] = "IRdisplay::display_latex"
irjulia_dict["image/png"] = "function(x) IRdisplay::display_png(charToRaw(x))"
irjulia_dict["image/jpeg"] = "function(x) IRdisplay::display_jpeg(charToRaw(x))"
irjulia_dict["application/pdf"] = "function(x) IRdisplay::display_pdf(charToRaw(x))"
irjulia_dict["image/svg+xml"] = "function(x) IRdisplay::display_svg(JuliaCall:::p_ly(x))"

const irjulia_display = RjuliaDisplay(irjulia_dict)
