macro suppress(block)
    quote
        ORIGINAL_STDERR = STDERR
        err_rd, err_wr = redirect_stderr()

        value = $(esc(block))

        redirect_stderr(ORIGINAL_STDERR)
        close(err_rd)
        close(err_wr)

        value
    end
end
