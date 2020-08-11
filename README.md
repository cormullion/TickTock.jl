# TickTock

![tick tock](images/ticktock.gif)

[![Build Status][travis-img]][travis-url] | [![][codecov-img]][codecov-url] | [![Build Status][appvey-img]][appvey-url]
 
This module provides simple timer functions:

- `tick()`  start a timer
- `tock()`  stop a timer, show total elapsed time
- `tok()`   stop a timer, return elapsed seconds
- `laptimer()` continue timing, show total elapsed time of active timers
- `peektimer()` continue timing, return elapsed seconds of most recent timer
- `alarm(h, m, s)` set an alarm timer

`laptimer()` and `peektimer()` functions show your current timing activity without stopping any active timers.

**Don't use these for timing code execution!**

Julia provides much better facilities for measuring performance, ranging from the `@time` and `@elapsed` macros to packages such as [BenchmarkTools.jl](https://github.com/JuliaCI/BenchmarkTools.jl). (And remember, don't time Julia code running in global scope!) The [TimerOutputs.jl](https://github.com/KristofferC/TimerOutputs.jl) package provides tools for timing different sections of a program.

## Suggestions for use

You can:

- time how long a phone call takes without leaving the Julia REPL

```julia
julia> using TickTock
julia> tick()
 Started timer at 2017-12-13T22:30:59.632
julia> tock()
55.052638936 ms: 55 seconds, 52 milliseconds
```

- see how long your cup of tea's been brewing:

```julia
julia> tick()
 Started timer at 2017-12-13T22:34:03.78
julia> laptimer()
 72.625839832 ms: 1 minute, 12 seconds, 625 milliseconds
julia> laptimer()
 266.053953749 ms: 4 minutes, 26 seconds, 53 milliseconds
julia> laptimer()
 285.314459174 ms: 4 minutes, 45 seconds, 314 milliseconds
```

- see how many seconds you held your breath for:

```julia
julia> tick()
 Started timer at 2017-12-12T09:17:45.504

julia> tok()
287.841546621
```

- see how long your computer (and Julia session) has been running for:

```julia
julia> tick()
...go on holiday, then come back
julia> laptimer()
  1.302200135485876e6s: 2 weeks, 1 day, 1 hour, 43 minutes, 20 seconds, 135 milliseconds
```

- time a number of things:

```julia
julia> tick()
 started timer at: 2018-03-17T12:08:43.326
julia> tick()
 started timer at: 2018-03-17T12:14:03.077
julia> laptimer()
2                  7.315769543s: 7 seconds, 315 milliseconds
1                327.074715234s: 5 minutes, 27 seconds, 74 milliseconds
```

- set an alarm to wake up in 1m30s:

```julia
julia> using Dates

julia> @async alarm(now() + Dates.Minute(1) + Dates.Second(30))
```

- execute an anonymous function when the alarm fires:

```julia
julia> @async alarm(now() + Dates.Minute(0) + Dates.Second(5),
           action = () -> run(`say "wake up"`)) # macOS speech command
```

You should *not* use this package to:

- measure performance of Julia code

- do benchmarking of Julia code

## History

Some of this code used to live in Julia Base in the `tic()`, `toc()`, and `toq()` functions (in base/util.jl). They were deprecated in GitHub issue [17046](https://github.com/JuliaLang/julia/issues/17046).

[pkgeval-link]: http://pkg.julialang.org/?pkg=TickTock

[travis-img]: https://travis-ci.org/cormullion/TickTock.jl.svg?branch=master
[travis-url]: https://travis-ci.org/cormullion/TickTock.jl

[appvey-img]: https://ci.appveyor.com/api/projects/status/jfa9e54lv92rqd3m?svg=true
[appvey-url]: https://ci.appveyor.com/project/cormullion/ticktock-jl/branch/master

[codecov-img]: https://codecov.io/gh/cormullion/TickTock.jl/branch/master/graph/badge.svg
[codecov-url]: https://codecov.io/gh/cormullion/TickTock.jl
