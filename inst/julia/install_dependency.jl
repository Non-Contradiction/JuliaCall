## Thanks to randy3k for pointing this out,
## `RCall` needs to be precompiled with the current R.
## <https://github.com/Non-Contradiction/JuliaCall/issues/9>
## as well as coming up with the solution

CurrentRhome = normpath(ARGS[1])

## println(Rhome)

ENV["R_HOME"] = CurrentRhome

const julia07 = VERSION > v"0.6.5"
const julia14 = VERSION > v"1.3.2"

if julia07
    using Pkg
end

function installed(name)
    @static if julia14
        for p in values(Pkg.dependencies())
            if p.name == name && p.is_direct_dep
                return p.version
            end
        end
        nothing
    elseif julia07
        get(Pkg.installed(), name, nothing)
    else
        Pkg.installed(name)
    end
end

if installed("Suppressor") == nothing
    Pkg.add("Suppressor")
end;

using Suppressor

if installed("RCall") == nothing
    Pkg.add("RCall")
end;
