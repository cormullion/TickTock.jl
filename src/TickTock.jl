"""
This module provides `tick()`, `tock()`, and `tok()` functions.

- `tick()`        ` start a new timer and start counting
- `tock()`        ` stop counting, show total elapsed time in canonical form
- `tok()`         ` stop counting, show and return total elapsed time in seconds
- `peektimer()    ` continue counting, show and return elapsed seconds so far
- `laptimer()     ` continue counting, show elapsed time so far in canonical form
- `alarm(h, m, s) ` set an alarm in h/m/s from now
- `alarm(dt)      ` set an alarm for `dt`

Don't use these for timing code execution! Julia provides much better facilities for measuring performance, ranging from the `@time` and `@elapsed` macros to packages such as [BenchmarkTools.jl](https://github.com/JuliaCI/BenchmarkTools.jl).
"""
module TickTock

export tick, tock, tok, peektimer, laptimer, alarm

using Dates

"""
    tick()

Start a timer.

Other functions: `tock()` (stop counting and show canonical), `tok()` (stop
counting and return seconds), `peektimer()` (continue counting, return elapsed
seconds), and `laptimer()` (continue counting, show canonical)
"""
function tick()
    t0 = time_ns()
    task_local_storage(:TIMERS, (t0, get(task_local_storage(), :TIMERS, ())))
    @info " started timer at: $(now())"
end

function printcanonical(tnow)
    canondc = Dates.canonicalize(
        Dates.CompoundPeriod(Dates.Second(floor(tnow)),
        Dates.Millisecond(floor((tnow - floor(tnow)) * 1000))))
    @info "$(lpad(tnow, 20))s: $canondc"
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

Return the elapsed seconds counted by the most recent timer, without stopping it.
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

Return the elapsed seconds counted by the most recent timer, then stop counting.
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
    timernumber = length(timers)
    for t0 in timers
        tnow = (t1 - t0)/1e9
        print(rpad(timernumber, 10))
        canonical ? printcanonical(tnow) : @info(tnow)
        timernumber -= 1
    end
end

"""
laptimer()

Print the elapsed time, in canonical form, of the most recent timer, and continue counting.
"""
laptimer() = showtimes(canonical=true)

"""
    alarm(hours, minutes, seconds;
        action = () -> @info("TickTock: time's up"))

Run an alarm, with the option of providing a anonymous function that executes
when alarm fires.

```
using Dates

@async alarm(0, 5, 0, action = ()-> println("TickTock.jl: 5 minutes is up!"))
```
"""
function alarm(hours, minutes, seconds;
        action=() -> @info("TickTock: alarm: time's up"))
    tick()
    while true
        sleep(5)
        if peektimer() > hours * 60 * 60 + minutes * 60 + seconds
            action()
            tock()
            break
        end
    end
end

"""
    alarm(dt::DateTime;
        action = () -> @info("TickTock: time's up"))

Run an alarm that fires at time `dt`, with the option of providing a function
that executes when alarm fires.

# Examples

```
using Dates

dt = now() + Dates.Minute(1)

@async alarm(dt, action=()-> println("TickTock.jl: Ready!"))
```

```
@async alarm(now() + Dates.Minute(10) + Dates.Second(0), action = () -> run(`say "wake up, 10 minutes is up"`)) # macOS speech command
```

TODO alarms don't appear in timer lists...
"""
function alarm(dt::DateTime;
        action = () -> @info("TickTock: alarm: time's up"))
    p = Dates.Period(dt - now())
    secs = round(p, Dates.Second).value
    m, s = divrem(secs, 60)
    h, m = divrem(m, 60)
    @info "TickTock: setting alarm for $h hours, $m minutes, $s seconds"
    alarm(h, m, s, action=action)
end

"""
@async alarm(now() + Dates.Second(5), action = () ->  TickTock.alarmnotify("time's up"))

TODO this is macOS only...
"""
function alarmnotify(subtitle="time's up")
    !Sys.isapple() && exit()
    command = """
    display notification with title "TickTock.jl" subtitle \"$(subtitle)\" sound name "frog"
    """
    chomp(read(`osascript -e $command`, String))
end

end # module
