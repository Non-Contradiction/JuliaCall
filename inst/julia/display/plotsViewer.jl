struct ViewerDisplay <: Display
end

function pngwrite(x, filename)
    b64 = open(filename, "w")
    show(IOContext(b64, :limit=>true), MIME"image/png"(), x)
    close(b64)
end

function svgwrite(x, filename)
    content = limitstringmime(MIME("image/svg+xml"), x)
    js = joinpath(".", "library", "plotly-latest.min.js")
    script = "<script src=\"" * js * "\"></script>"
    content = replace(content, r"<script.*plotly.*</script>", script)
    write(filename, content)
end

plotwrite(::MIME"image/png", x, filename) = pngwrite(x, filename)
plotwrite(::MIME"image/svg+xml", x, filename) = svgwrite(x, filename)

tempplot(::MIME"image/png") = String(RCall.rcopy(RCall.reval("tempfile(fileext = '.png')")))
tempplot(::MIME"image/svg+xml") = String(RCall.rcopy(RCall.reval("tempfile(fileext = '.html')")))

function display(d::ViewerDisplay, m::MIME, p)
    fname = tempplot(m)
    plotwrite(m, p, fname)
    RCall.reval("viewer = getOption('viewer', utils::browseURL)")
    RCall.rcall(:viewer, fname)
end

function display(d::ViewerDisplay, p)
    try
        display(d, MIME("image/svg+xml"), p)
        return 
    catch e;
    end;
    try
        display(d, MIME("image/png"), p)
        return
    catch e;
    end
    throw(MethodError(display, [d, p]))
end

const viewer_display = ViewerDisplay()
