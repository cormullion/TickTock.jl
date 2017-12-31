# TickTock

![tick tock](images/ticktock.gif)

This module provides `tick()`, `tock()`, and `tok()` functions. They're similar to the `tic()`, `toc()`, and `toq()` functions that you might find in MATLAB and similar software. There are also `lap()` and `peek()` functions that reveal the state of the current timer without stopping it.

**Don't use these for timing code execution!** Julia provides much better facilities for measuring performance, ranging from the `@time` and `@elapsed` macros to packages such as [BenchmarkTools.jl](https://github.com/JuliaCI/BenchmarkTools.jl). (And remember, don't time Julia code running in global scope!) The [TimerOutputs.jl](https://github.com/KristofferC/TimerOutputs.jl) package provides tools for timing different sections of a program.

## Functions

- `tick()` start counting
- `tock()` stop counting, show total elapsed time
- `tok()`  stop counting, return seconds
- `peek()` continue counting, return elapsed seconds
- `lap()`  continue counting, show total elapsed time

## Suggestions for use

You can:

- time how long a phone call takes without leaving the Julia REPL

```
julia-0.6> using TickTock
julia-0.6> tick()
Started timer: 2017-12-13T22:30:59.632.
julia-0.6> tock()
55.052638936 ms: 55 seconds, 52 milliseconds
```

- see how long your cup of tea's been brewing:

```
julia-0.6> tick()
Started timer: 2017-12-13T22:34:03.78.
julia-0.6> lap()
72.625839832 ms: 1 minute, 12 seconds, 625 milliseconds
julia-0.6> lap()
266.053953749 ms: 4 minutes, 26 seconds, 53 milliseconds
julia-0.6> lap()
285.314459174 ms: 4 minutes, 45 seconds, 314 milliseconds
```

- see how many seconds you held your breath for:

```
julia-0.6> tick()
Started timer at 2017-12-12T09:17:45.504.

julia-0.6> tok()
287.841546621
```

- see how long your computer (and Julia session) has been running for:

```
julia-0.6> tick()
...
julia-0.6> lap()
1.302200135485876e6s: (2 weeks, 1 day, 1 hour, 43 minutes, 20 seconds, 135 milliseconds)
```

You should *not* use this package to:

- measure performance of Julia code

- do benchmarking of Julia code

## History

Some of this code used to live in Julia Base in the `tic()`, `toc()`, and `toq()` functions
(in base/util.jl). They were deprecated in GitHub issue [17046](https://github.com/JuliaLang/julia/issues/17046).

[![Travis](https://travis-ci.org/cormullion/TickTock.jl.svg?branch=master)](https://travis-ci.org/cormullion/TickTock.jl) [![Appveyor](https://ci.appveyor.com/api/projects/status/j4w1iwued4ojsfm6/branch/master?svg=true)](https://ci.appveyor.com/project/cormullion/ticktock-jl/branch/master) [![Coverage Status](https://coveralls.io/repos/github/cormullion/TickTock.jl/badge.svg?branch=master)](https://coveralls.io/github/cormullion/TickTock.jl?branch=master) [![codecov.io](http://codecov.io/github/cormullion/TickTock.jl/coverage.svg?branch=master)](http://codecov.io/github/cormullion/TickTock.jl?branch=master)
