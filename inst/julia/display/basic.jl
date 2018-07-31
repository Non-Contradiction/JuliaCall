const output = IOBuffer()

if julia07
    using REPL
else
    const REPL = Base.REPL
end

const out_terminal = REPL.Terminals.TerminalBuffer(output)

const basic_repl = REPL.BasicREPL(out_terminal)

const basic_display = REPL.REPLDisplay(basic_repl)

Base.pushdisplay(basic_display)

mutable struct DisplayManager
    repl_display :: REPL.REPLDisplay
    location :: Int64
end

DisplayManager(repl_display :: REPL.REPLDisplay) = DisplayManager(repl_display, 0)

function Rprint(s) ccall((:Rprintf,RCall.libR),Void,(Ptr{Cchar},), s) end

function proceed(dm :: DisplayManager)
    if dm.location < dm.repl_display.repl.terminal.out_stream.ptr-1
        Rprint(readstring(seek(dm.repl_display.repl.terminal.out_stream, dm.location)))
        dm.location = dm.repl_display.repl.terminal.out_stream.ptr-1
        Rprint("  \n")
    end
end

const basic_display_manager = DisplayManager(basic_display)
