## Thanks to randy3k for pointing this out,
## `RCall` needs to be precompiled with the current R.
## <https://github.com/Non-Contradiction/JuliaCall/issues/9>
## as well as coming up with the solution

if Pkg.installed("Suppressor") == nothing
    Pkg.add("Suppressor")
end;

using Suppressor

Rhome = ARGS[1]

## println(Rhome)

ENV["R_HOME"] = Rhome

if Pkg.installed("RCall") == nothing
    Pkg.add("RCall")
end;

using RCall

if RCall.Rhome != Rhome
    Base.compilecache("RCall")
end
