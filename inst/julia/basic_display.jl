output = IOBuffer()

out_terminal = Base.Terminals.TerminalBuffer(output)

basic_repl = Base.REPL.BasicREPL(out_terminal)

basic_display = Base.REPL.REPLDisplay(basic_repl)

Base.pushdisplay(basic_display)
