# WhatIsHappening.jl

Tiny Julia package with a single export: [`@withfeedback`](link_to_docs).

Print what is happening during slow operations, like package imports.  

### Example

Say this is in your `startup.jl`:
```julia
using WhatIsHappening

@withfeedback begin
    using Revise
    using PyPlot
end
```
Starting Julia will then look like:

[gif]

This macro might also be used in a package, to provide better UX to its users
who might otherwise be wondering why their REPL or notebook cell is hanging.

[docs link]
