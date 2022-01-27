module WhatIsHappening

using MacroTools  # (This is fast).

export @withfeedback

"""
    @withfeedback [message] [message_after] expression

Print what is happening during `expression`, then execute the expression. If no `message` is
specified, the expression itself is used as message.

If `message_after` is specified, print a second message after the operation has completed.
This second message is either the specified string, or, if set to `true`, the original
message plus a check mark. By default, no message is printed after the operation.
"""
macro withfeedback(message::String, message_after, expr)
    quote
        @info $message
        $(esc(expr))
        if !isnothing($message_after)
            if $message_after == true
                @info $message * " ✓"
            else
                @info $message_after
            end
        end
    end
end

macro withfeedback(message, expr)
    :( @withfeedback $message nothing $(esc(expr)))
end

macro withfeedback(::Val{true}, expr)
    :( @withfeedback $(_content_as_string(expr)) true $(esc(expr)) )
end

macro withfeedback(expr)
    :( @withfeedback $(_content_as_string(expr)) nothing $(esc(expr)))
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


end # module
