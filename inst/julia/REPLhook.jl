## Not sure whether this function is defined in the RCall version installed
function repl_inited(repl)
    mirepl = isdefined(repl,:mi) ? repl.mi : repl
    any(:prompt in fieldnames(m) && m.prompt == "R> " for m in mirepl.interface.modes)
end

function setup_repl(repl)
    ## RCall.RPrompt.repl_init requires repl.interface has been setup.
    if !isdefined(repl,:interface)
        repl.interface = Base.REPL.setup_interface(repl)
    end

    !repl_inited(repl) && RCall.RPrompt.repl_init(repl)

    ## We also need to do rgui_start
    RCall.rgui_start()
end

# We will use this to register hook for Julia REPL: Base.atreplinit(setup_repl)
