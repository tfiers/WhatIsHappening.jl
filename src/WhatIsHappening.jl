module WhatIsHappening

using Logging
using MacroTools  # (This is fast).

export @withfeedback, prettify_logging_in_notebook!, get_pretty_notebook_logger

"""
    @withfeedback [message] expression

Print what is happening during `expression`, then execute the expression. If no `message` is
specified, the expression itself is used as message.
"""
macro withfeedback(message::String, expr)
    quote
        @info $message
        _flush_logging_stream()
        $(esc(expr))
    end
end

macro withfeedback(expr)
    :( @withfeedback $(_content_as_string(rmlines(expr))) $(esc(expr)))
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

function _flush_logging_stream()
    logger = current_logger()
    # Handle the wrapping loggers of LoggingExtras.jl.
    if hasproperty(logger, :logger)
        logger = logger.logger
    end
    #   [Not done: deeper unwrapping (`while`); and flushing multiple for teed/multiplexed]
    if hasproperty(logger, :stream)
        io = logger.stream
        # Emulate what the default loggers do both in IJulia and in the REPL (one is a
        # SimpleLogger, the other a ConsoleLogger). They both check `isopen` and otherwise
        # use `stderr`.
        if isopen(io)
            flush(io)
        else
            flush(stderr)
        end
    else
        # This is the case in vscode. We could check whether `logger isa VSCodeLogger`, but
        # that adds a dependency; and the defining package is not registered anyway. In any
        # case: no action needed, VSCodeLogger flushes after every message:
        # https://github.com/julia-vscode/julia-vscode/blob/master/scripts/packages/VSCodeServer/src/progress.jl#L7
    end
end

"""Prettier @info display in IJulia than the default (which is noisy, and on a red bg)."""
prettify_logging_in_notebook!() = global_logger(get_pretty_notebook_logger())

get_pretty_notebook_logger() = ConsoleLogger(stdout)
#   A function, as `stdout` is modified, e.g. by IJulia.

end # module
