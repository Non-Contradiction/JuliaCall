using Compat

dlls = Libdl.dllist()

libjulia = (filter(Libdl.dllist()) do dl
    return occursin(Regex("^libjulia(?:.*)\\.$(Libdl.dlext)(?:\\..+)?\$"), basename(dl))
end)[1]

print(libjulia)
