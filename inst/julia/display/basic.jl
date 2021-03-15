const output = IOBuffer()

if julia07
    using REPL
    const Void = Nothing
else
    const REPL = Base.REPL
end

const out_terminal = REPL.Terminals.TerminalBuffer(output)

const basic_repl = REPL.BasicREPL(out_terminal)

const basic_display = REPL.REPLDisplay(basic_repl)

## Base.pushdisplay(basic_display)

mutable struct DisplayManager <: Display
    repl_display :: REPL.REPLDisplay
    location :: Int64
end

DisplayManager(repl_display :: REPL.REPLDisplay) = DisplayManager(repl_display, 0)

function Rprint(s) 
    RCall.rcall(:cat, s)
    ## ccall((:Rprintf,RCall.libR),Void,(Ptr{Cchar},), s) 
end

function proceed(dm :: DisplayManager)
    if dm.location < dm.repl_display.repl.terminal.out_stream.ptr-1
        Rprint(readstring(seek(dm.repl_display.repl.terminal.out_stream, dm.location)))
        dm.location = dm.repl_display.repl.terminal.out_stream.ptr-1
        Rprint("  \n")
    end
end

function display(dm :: DisplayManager, mime::MIME"text/plain", x)
    Base.invokelatest(display, dm.repl_display, mime, x)
    proceed(dm)
    nothing
end

display(dm :: DisplayManager, x) = display(dm, MIME("text/plain"), x)

const basic_display_manager = DisplayManager(basic_display)

Base.pushdisplay(basic_display_manager)
