"""
This module provides `tick()`, `tock()`, and `tok()` functions.

They're similar to the `tic()`, `toc()`, and `toq()` functions that you might find in MATLAB and
similar software.
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
    return t0
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
    (t1-t0)/1e9 # seconds
end

"""
    tock()

Print the elapsed time, in suitably canonical form, since the previous `tick()`,
and then stop counting.
"""
function tock()
    t = tok()
    canondc = Dates.canonicalize(Dates.CompoundPeriod(Dates.Second(floor(t))))
    println(canondc)
end

end # module
