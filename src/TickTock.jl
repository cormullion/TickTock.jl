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

export tick, tock, tok, peektimer, laptimer

if VERSION > v"0.7.0-"
    using Dates # for now() :(
end

"""
    tick()

Start counting. The other functions are:

- `tock()`       ` stop counting, show total elapsed time in canonical form
- `tok()`        ` stop counting, return seconds
- `peektimer()   ` continue counting, return elapsed seconds
- `laptimer()    ` continue counting, show total elapsed time in canonical form
"""
function tick()
    t0 = time_ns()
    task_local_storage(:TIMERS, (t0, get(task_local_storage(), :TIMERS, ())))
    println(" started timer at: $(now())")
end

function printcanonical(tnow)
    canondc = Dates.canonicalize(
        Dates.CompoundPeriod(Dates.Second(floor(tnow)),
        Dates.Millisecond(floor( (tnow - floor(tnow)) * 1000))))
    println("$(lpad(tnow, 20))s: $canondc")
end

function gettimers()
    result = UInt64[]
    timers = get(task_local_storage(), :TIMERS, ())
    if timers === ()
        error("Use `tick()` to start a timer.")
    end
    while timers[2] != ()
        push!(result, timers[1]::UInt64)
        timers = timers[2]
    end
    push!(result, timers[1]::UInt64)
    return result
end

"""
    peektimer()

Return the current elapsed seconds counted by the most recent timer, without stopping it.
"""
function peektimer()
    t1 = time_ns()
    timers = get(task_local_storage(), :TIMERS, ())
    if timers === ()
        error("Use `tick()` to start a timer.")
    end
    t0 = timers[1]::UInt64
    return (t1 - t0)/1e9
end

"""
    tok()

Return the current elapsed seconds counted by the most recent timer, then stop counting.
"""
function tok()
    timers = get(task_local_storage(), :TIMERS, ())
    if timers === ()
        error("Use `tick()` to start a timer.")
    end
    t = peektimer()
    task_local_storage(:TIMERS, timers[2])
    return t
end

"""
    tock()

Print the elapsed time, in canonical form, of the most recent timer, then stop counting.
"""
function tock()
    t = tok()
    printcanonical(t)
end

function showtimes(;canonical=true)
    t1 = time_ns()
    timers = gettimers()
    if timers === ()
        error("Use `tick()` to start a timer.")
    end
    timernumber = length(timers)
    for t0 in timers
        tnow = (t1 - t0)/1e9
        print(rpad(timernumber, 10))
        canonical ? printcanonical(tnow) : println(tnow)
        timernumber -= 1
    end
end

"""
laptimer()

Print the current elapsed time, in canonical form, since the previous `tick()`,
and continue counting.
"""
laptimer() = showtimes(canonical=true)

end # module
