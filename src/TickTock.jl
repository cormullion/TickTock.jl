module TickTock

export tick, tock

function tick()
    t0 = time_ns()
    task_local_storage(:TIMERS, (t0, get(task_local_storage(), :TIMERS, ())))
    return t0
end

function toqk()
    t1 = time_ns()
    timers = get(task_local_storage(), :TIMERS, ())
    if timers === ()
        error("You tock()ed before you tick()ed...")
    end
    t0 = timers[1]::UInt64
    task_local_storage(:TIMERS, timers[2])
    (t1-t0)/1e9
end

function tock()
    t = toqk()
    dc = Dates.canonicalize(Dates.CompoundPeriod(now() - t))
    println(dc)
    return dc
end

end # module
