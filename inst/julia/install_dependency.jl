## Thanks to randy3k for pointing this out,
## `RCall` needs to be precompiled with the current R.
## <https://github.com/Non-Contradiction/JuliaCall/issues/9>
## as well as coming up with the solution

CurrentRhome = ARGS[1]

## println(Rhome)

ENV["R_HOME"] = CurrentRhome

const julia07 = VERSION > v"0.6.5"

if julia07
    using Pkg
else
    macro pkg_str(x) begin nothing end end
end

function installed(name)
    @static if julia07
        get(Pkg.installed(), name, nothing)
    else
        Pkg.installed(name)
    end
end

if installed("Suppressor") == nothing
    Pkg.add("Suppressor")
end;

using Suppressor

if julia07
    # pkg"add RCall#e59a546"
    # pkg"add RCall#e700cee"
    pkg"add RCall#a60aaaf"
elseif installed("RCall") == nothing
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
        if installed("RCall") >= v"0.10.2"
            Pkg.build("RCall")
        else
            Base.compilecache("RCall")
        end
    end
end
