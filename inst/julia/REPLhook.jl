function setup_repl(repl)
    ## RCall.RPrompt.repl_init requires repl.interface has been setup.
    if !isdefined(repl,:interface)
        repl.interface = REPL.setup_interface(repl)
    end

    !RCall.RPrompt.repl_inited(repl) && RCall.RPrompt.repl_init(repl)

    ## We also need to do rgui_start
    RCall.rgui_start()
end

# We will use this to register hook for Julia REPL: Base.atreplinit(setup_repl)
