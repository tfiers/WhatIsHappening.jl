module WhatIsHappening

using Logging
using MacroTools  # (This is fast).

"""
    @withfeedback [message] expression

Print what is happening during `expression`, then execute the expression. If no `message` is
specified, the expression itself is used as message.
"""
macro withfeedback(message::String, expr)
    quote
        @info $message
        flush(_get_logging_stream())
        $(esc(expr))
    end
end

macro withfeedback(expr)
    :( @withfeedback $(_content_as_string(expr)) $(esc(expr)))
end

function _content_as_string(expr)
    if expr.head == :block
        # For a `begin` block, only print contents (not "begin … end").
        return "\n" * join(rmlines(expr).args, " jf\n")
        #    Leading newline, so that first code line comes on its own line after "[ Info:".
    else
        return string(expr)
    end
end

function _get_logging_stream()
    io = current_logger().stream
    if isopen(io)
        return io
    else
        # Emulate what the default loggers do both in IJulia (which uses a SimpleLogger)
        # and in the REPL (which uses a ConsoleLogger).
        return stderr
    end
end

export @withfeedback

end # module
