## Thanks to randy3k for pointing this out,
## `RCall` needs to be precompiled with the current R.
## <https://github.com/Non-Contradiction/JuliaCall/issues/9>
## as well as coming up with the solution

if Pkg.installed("Suppressor") == nothing
    Pkg.add("Suppressor")
end;

using Suppressor

CurrentRhome = ARGS[1]

## println(Rhome)

ENV["R_HOME"] = CurrentRhome

if Pkg.installed("RCall") == nothing
    Pkg.add("RCall")
end;


depsjl = Base.Pkg.dir("RCall", "deps", "deps.jl")
if isfile(depsjl)
    include(depsjl)

    if Rhome != CurrentRhome
        Pkg.build("RCall")
    end
else
    using RCall

    if RCall.Rhome != CurrentRhome
        if Pkg.installed("RCall") >= v"0.10.2"
            Pkg.build("RCall")
        else
            Base.compilecache("RCall")
        end
    end
end
