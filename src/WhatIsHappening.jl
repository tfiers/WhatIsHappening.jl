module WhatIsHappening

using MacroTools  # (This is fast).

export @withfeedback

"""
    @withfeedback [message] expression

Print what is happening during `expression`, then execute the expression. If no `message` is
specified, the expression itself is used as message.
"""
macro withfeedback(message::String, expr)
    quote
        println($message)
        flush(stdout)
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


#= manual @withfeedback during dev of this:
print("using Revise … ")
flush(stdout)
using Revise
println("✓")
=#


end # module
