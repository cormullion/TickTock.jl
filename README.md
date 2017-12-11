# TickTock

This module provides `tick()`, `tock()`, and `tok()` functions.

They're similar to the `tic()`, `toc()`, and `toq()` functions that you might find in MATLAB and
similar software.

**Don't use these for timing code execution!** Julia provides much better facilities for
measuring performance, ranging from the `@time` and `@elapsed` macros to packages such as [BenchmarkTools.jl](https://github.com/JuliaCI/BenchmarkTools.jl). (And remember, don't
time Julia code running in global scope!)

This code used to live in Julia Base in the `tic()`, `toc()`, and `toq()` functions (in base/util.jl). They were deprecated in GitHub issue [17046](https://github.com/JuliaLang/julia/issues/17046).

## Example

```julia
julia-0.6> using TickTock

julia-0.6> tick()
0x0000146b7dcc5c23

julia-0.6> tock()
2 seconds
```

[![Build Status](https://travis-ci.org/cormullion/TickTock.jl.svg?branch=master)](https://travis-ci.org/cormullion/TickTock.jl)

[![Coverage Status](https://coveralls.io/repos/cormullion/TickTock.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/cormullion/TickTock.jl?branch=master)

[![codecov.io](http://codecov.io/github/cormullion/TickTock.jl/coverage.svg?branch=master)](http://codecov.io/github/cormullion/TickTock.jl?branch=master)
