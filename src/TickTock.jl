"""
This module provides `tick()`, `tock()`, and `tok()` functions.

They're similar to the `tic()`, `toc()`, and `toq()` functions that you might find in MATLAB and
similar software.

Don't use these for timing code execution! Julia provides much better facilities for
measuring performance, ranging from the `@time` and `@elapsed` macros to packages such as [BenchmarkTools.jl](https://github.com/JuliaCI/BenchmarkTools.jl). (And remember, don't
time Julia code running in global scope!)

This code used to live in Julia Base in the `tic()`, `toc()`, and `toq()` functions (in base/util.jl). They were deprecated in GitHub issue [17046](https://github.com/JuliaLang/julia/issues/17046).
"""

module TickTock

export tick, tock, tok

"""
    tick()

Start counting.
"""
function tick()
    t0 = time_ns()
    task_local_storage(:TIMERS, (t0, get(task_local_storage(), :TIMERS, ())))
    info("Started timer at $(now()).")
end

"""
    tok()

Return the time since the previous `tick()`, in seconds, and then stop counting.
"""
function tok()
    t1 = time_ns()
    timers = get(task_local_storage(), :TIMERS, ())
    if timers === ()
        error("You must first use `tick()`.")
    end
    t0 = timers[1]::UInt64
    task_local_storage(:TIMERS, timers[2])
    return (t1-t0)/1e9 # seconds
end

"""
    tock()

Print the elapsed time, in canonical form, since the previous `tick()`,
and then stop counting.
"""
function tock()
    t = tok()
    canondc = Dates.canonicalize(Dates.CompoundPeriod(Dates.Second(floor(t)), Dates.Millisecond(floor((t-floor(t)) * 1000))))
    info("Time taken: $t")
    info("            $canondc")
end

end # module
