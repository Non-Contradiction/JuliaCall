type PngDisplay <: Display
end

## This function modified from IJulia
# convert x to a string of type mime, making sure to use an
# IOContext that tells the underlying show function to limit output
function pngwrite(x)
    filename = tempname()
    b64 = open(filename, "w")
    if isa(x, Vector{UInt8})
        write(b64, x) # x assumed to be raw binary data
    else
        show(IOContext(b64, :limit=>true), MIME"image/png"(), x)
    end
    close(b64)
    return(filename)
end

function display(d::PngDisplay, p)
    try
        filename = pngwrite(p)
        RCall.reval("grid::grid.newpage()")
        RCall.reval("pngshow <- function(fname) grid::grid.raster(png::readPNG(fname))")
        RCall.rcall(:pngshow, filename)
        return
    end
    throw(MethodError)
end

png_display = PngDisplay()
