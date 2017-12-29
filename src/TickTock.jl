"""
This module provides `tick()`, `tock()`, and `tok()` functions.

They're similar to the `tic()`, `toc()`, and `toq()` functions that you might find in MATLAB
and similar software.

Don't use these for timing code execution! Julia provides much better facilities for
measuring performance, ranging from the `@time` and `@elapsed` macros to packages such as
[BenchmarkTools.jl](https://github.com/JuliaCI/BenchmarkTools.jl). (And remember, don't
time Julia code running in global scope!)

This code used to live in Julia Base as the `tic()`, `toc()`, and `toq()` functions
(in base/util.jl). They were deprecated in GitHub issue [17046](https://github.com/JuliaLang/julia/issues/17046).
"""

module TickTock

export tick, tock, tok, peek, lap

if VERSION > v"0.7.0-"
    using Dates # for now() :(
end

"""
    tick()

Start counting. The other functions are:

- `tock()` stop counting, show total elapsed time in canonical form
- `tok()`  stop counting, return seconds
- `peek()` continue counting, return elapsed seconds
- `lap()`  continue counting, show total elapsed time in canonical form
"""
function tick()
    t0 = time_ns()
    task_local_storage(:TIMERS, (t0, get(task_local_storage(), :TIMERS, ())))
    info("Started timer: $(now()).")
end

"""
    peek()

Return the current elapsed seconds counted by the current timer, without stopping it.
"""
function peek()
    t1 = time_ns()
    timers = get(task_local_storage(), :TIMERS, ())
    if timers === ()
        error("You must first use `tick()`.")
    end
    t0 = timers[1]::UInt64
    return (t1 - t0)/1e9
end

"""
    tok()

Return the seconds since the previous `tick()` then stop counting.
"""
function tok()
    timers = get(task_local_storage(), :TIMERS, ())
    if timers === ()
        error("You must first use `tick()`.")
    end
    t = peek()
    task_local_storage(:TIMERS, timers[2])
    return t
end

"""
    tock()

Print the elapsed time, in canonical form, since the previous `tick()`,
then stop counting.
"""
function tock()
    t = tok()
    canondc = Dates.canonicalize(
        Dates.CompoundPeriod(Dates.Second(floor(t)),
        Dates.Millisecond(floor( (t - floor(t)) * 1000))))
    info("$(t)s: ($canondc)")
end

"""
    lap()

Print the current elapsed time, in canonical form, since the previous `tick()`,
and continue counting.
"""
function lap()
    t = peek()
    canondc = Dates.canonicalize(
        Dates.CompoundPeriod(Dates.Second(floor(t)),
        Dates.Millisecond(floor( (t - floor(t)) * 1000))))
    info("$(t)s: ($canondc)")
end

end # module
