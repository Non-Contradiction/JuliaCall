type PngDisplay <: Display
end

## This function modified from IJulia
# convert x to a string of type mime, making sure to use an
# IOContext that tells the underlying show function to limit output
function pngwrite(x, filename)
    b64 = open(filename, "w")
    if isa(x, Vector{UInt8})
        write(b64, x) # x assumed to be raw binary data
    else
        show(IOContext(b64, :limit=>true), MIME"image/png"(), x)
    end
    close(b64)
end

function display(d::PngDisplay, p)
    try
        fname = String(RCall.reval("tempfile(fileext = '.png')"))
        pngwrite(p, fname)
        RCall.reval("viewer = getOption('viewer', utils::browseURL)")
        RCall.rcall(:viewer, fname)
        return
    end
    throw(MethodError(display, [d, p]))
end

png_display = PngDisplay()

type SvgDisplay <: Display
end

## This function modified from IJulia
# convert x to a string of type mime, making sure to use an
# IOContext that tells the underlying show function to limit output
function svgwrite(x, filename)
    content = limitstringmime(MIME("image/svg+xml"), x)
    js = joinpath(".", "library", "plotly-latest.min.js")
    script = "<script src=\"" * js * "\"></script>"
    content = replace(content, r"<script.*plotly.*</script>", script)
    write(filename, content)
end

function display(d::SvgDisplay, p)
    try
        fname = String(RCall.reval("tempfile(fileext = '.html')"))
        svgwrite(p, fname)
        RCall.reval("viewer = getOption('viewer', utils::browseURL)")
        RCall.rcall(:viewer, fname)
        return
    end
    throw(MethodError(display, [d, p]))
end

svg_display = SvgDisplay()
