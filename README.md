# WhatIsHappening.jl &nbsp; [![](https://img.shields.io/badge/📕_Documentation-blue)](link_to_docs)

A tiny Julia package with a single export: [`@withfeedback`](docs_deeplink).

Print what is happening during slow operations, like package imports.


## Example

If this was your `startup.jl`:
```julia
using WhatIsHappening

@withfeedback begin
    using Revise
    using PyPlot
end
```
then starting Julia would look like:

`[gif]`

The `@withfeedback` macro can also be used in your packages, to provide better UX to users who might otherwise be wondering why their REPL or notebook cell is hanging.


<br>

## Jupyter Notebooks
<!-- to be moved to docs -->

For nicer logging, run the following (e.g. in your [`startup_ijulia.jl`](https://julialang.github.io/IJulia.jl/stable/manual/usage/#Customizing-your-IJulia-environment)):
```julia
using Logging
global_logger(ConsoleLogger(stdout))
```

`[side-by-side before and after screenshots]`

(The default logger in IJulia prints to `stderr` – hence the red background – and is a `SimpleLogger` – hence the module/file/line output, even though the message level is only `Info`).
