const julia07 = VERSION > v"0.6.5"

if julia07
    using Libdl
end

dlls = Libdl.dllist()

libjulia = (filter(dlls) do dl
    if julia07
        occursin(Regex("^libjulia(?:.*)\\.$(Libdl.dlext)(?:\\..+)?\$"), basename(dl))
    else
        ismatch(Regex("^libjulia(?:.*)\\.$(Libdl.dlext)(?:\\..+)?\$"), basename(dl))
    end
end)[1]

print(libjulia)
