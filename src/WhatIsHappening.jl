module WhatIsHappening

using MacroTools  # (This is fast).

export @withfeedback


#=
Possible invocations of @withfeedback (@wf), and what they do.

1) @wf e                               → print(e), ex(e)
2) @wf true e                          → print(e), ex(e), print(e)
3) @wf "msg" e                         → print("msg"), ex(e)
4) @wf "msg" true e                    → print("msg"), ex(e), print("msg")

5) @wf begin; e1; e2; end              → print(e1), ex(e1), print(e2), ex(e2)
6) @wf true begin; e1; e2; end         → print(e1), ex(e1), print(e1), print(e2), ex(e2), print(e2)
7) @wf "msg" begin; e1; e2; end        → [see 3]
8) @wf "msg" true begin; e1; e2; end   → [see 4]

Option 6 only really makes sense with same-line printing (i.e. `print`, not `@info`).
=#

"""
    @withfeedback [message] [message_after] expression

Print what is happening during `expression`, then execute the expression. If no `message` is
specified, the expression itself is used as message.

If `message_after` is specified, print a second message after the operation has completed.
This second message is either the specified string, or, if set to `true`, the original
message plus a check mark. By default, no message is printed after the operation.

If `expression` is a `begin … end` block and no custom `message` is specified, print and
execute the block line by line.
"""
macro withfeedback(
    message,  # nothing | something_showable
    message_after,  # nothing | true | something_showable
    expr
)
    lines = []
    if message == :nothing && _unesc(expr).head == :block
        # We have a `begin … end` block and no custom message.
        for expr_i in rmlines(_unesc(expr)).args
            message = string(_unesc(expr_i))
            push!(lines, :( @info $message ))
            push!(lines, :( $(esc(expr_i)) ))  # execute expression i
            # Note that, if we come from one of the short @withfeedback methods below,
            # expr_i is double-escaped. This is apparently necessary.
            (message_after == true) && push!(lines, :( @info $message * " ✓" ))
        end
    else
        message == :nothing && (message = string(_unesc(expr)))
        push!(lines, :( @info $message ))
        push!(lines, :( $(esc(expr)) ))
        if message_after == :nothing
            # done
        elseif message_after == true
            push!(lines, :( @info $message * " ✓" ))
        else
            push!(lines, :( @info $message_after ))
        end
    end
    e = Expr(:block, lines...)
    @show e
    return e
end

macro withfeedback(message, expr)
    :( @withfeedback $message nothing $(esc(expr)) )
end

macro withfeedback(::Val{true}, expr)
    :( @withfeedback nothing true $(esc(expr)) )
end

macro withfeedback(expr)
    :( @withfeedback nothing nothing $(esc(expr)) )
end

_unesc(x) = (x isa Expr && x.head == :escape) ? only(x.args) : x


end # module
