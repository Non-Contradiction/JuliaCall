## The macro is adapated from Suppressor.jl
## https://github.com/JuliaIO/Suppressor.jl/blob/master/src/Suppressor.jl

const stdout_in_R = R"JuliaCall:::stdout_display"

macro capture_out1(block)
    quote
        if ccall(:jl_generating_output, Cint, ()) == 0
            original_stdout = Main.STDOUT
            out_rd, out_wr = redirect_stdout()
            out_reader = @async read(out_rd, String)
        end

        out = try
            Core.eval(Main, Meta.parse($(string(block))))
        finally
            if ccall(:jl_generating_output, Cint, ()) == 0
                redirect_stdout(original_stdout)
                close(out_wr)
            end
        end

        if ccall(:jl_generating_output, Cint, ()) == 0
            stdout_in_R(fetch(out_reader))
        end

        out
    end
end
