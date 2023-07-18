"""
This module provides `tick()`, `tock()`, and `tok()` functions.

- `tick()`        start a new timer and start counting
- `tock()`        stop counting, show total elapsed time in canonical form
- `tok()`         stop counting, show and return total elapsed time in seconds
- `peektimer()    continue counting, show and return elapsed seconds so far
- `peektimers()   continue counting, show and return elapsed seconds so far
- `laptimer()     continue counting, show elapsed time so far in canonical form
- `alarm(h, m, s) set an alarm in h/m/s from now
- `alarm(dt)      set an alarm for the date and time `dt`
- `alarmlist()    list alarms

Don't use these for timing code execution! Julia provides
much better facilities for measuring performance, ranging
from the `@time` and `@elapsed` macros to packages such as
[BenchmarkTools.jl](https://github.com/JuliaCI/BenchmarkTools.jl).
"""
module TickTock

export tick, tock, tok, peektimer, peektimers, laptimer, alarm, alarmlist

using Dates

const alarm_list = Tuple[]

function __init__()
    if ! haskey(ENV, "TICKTOCK_MESSAGES")
         ENV["TICKTOCK_MESSAGES"] = true
    end
end

"""
    tick()

Start a timer.

Other functions:

- `tock()` (stop counting and show canonical)

- `tok()` (stop counting and return seconds)

- `peektimer()` (continue counting, return elapsed seconds)

- `laptimer()` (continue counting, show canonical)

If `ENV["TICKTOCK_MESSAGES"]` = `false`, `tick()` will not display messages.
"""
function tick()
    t0 = time_ns()
    task_local_storage(:TIMERS, (t0, get(task_local_storage(), :TIMERS, ())))
    if ENV["TICKTOCK_MESSAGES"] == "true"
        @info " started timer at: $(now())"
    end
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
        @warn "Use `tick()` to start a timer."
    else
        while timers[2] != ()
            push!(result, timers[1]::UInt64)
            timers = timers[2]
        end
        push!(result, timers[1]::UInt64)
        return result
    end
end

"""
    peektimer()

Return the elapsed seconds counted by the most recent timer, without stopping it.
"""
function peektimer()
    t1 = time_ns()
    timers = get(task_local_storage(), :TIMERS, ())
    if timers === ()
        @warn "Use `tick()` to start a timer."
    else
        t0 = timers[1]::UInt64
        return (t1 - t0)/1e9
    end
end

"""
    peektimers()

Return the elapsed seconds counted by all timers, without
stopping them, as an array.

## Example
```
julia> laptimer()
3         [ Info:         16.380142899s: 16 seconds, 380 milliseconds
2         [ Info:         21.480662472s: 21 seconds, 480 milliseconds
1         [ Info:         23.888862411s: 23 seconds, 888 milliseconds

julia> peektimers()
3-element Vector{Float64}:
 18.56985403
 23.670373603
 26.078573542
```
"""
function peektimers()
    t1 = time_ns()
    timers = gettimers()
    result = Float64[]
    if isnothing(timers)
        @warn "Use `tick()` to start a timer."
    else
        timernumber = length(timers)
        for t0 in timers
            tnow = (t1 - t0)/1e9
            push!(result, (t1 - t0)/1e9)
        end
    end
    if length(TickTock.alarm_list) > 1
        @info "show current alarms with `alarmlist()`"
    end
    if !isempty(result)
        return result
    end
end

"""
    tok()

Return the elapsed seconds counted by the most recent timer,
then stop counting.
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

Print the elapsed time, in canonical form, of the most
recent timer, then stop counting.
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

Print the elapsed time, in canonical form, of all active
timers, and continue counting.
"""
laptimer() = showtimes(canonical=true)


## alarums

"""
    alarm(hours, minutes, seconds;
        action = () -> @info("TickTock: time's up"))

Set an alarm, with the option of providing a anonymous
function that executes when alarm fires.

!!! warning

    Use @async to avoid tying up your terminal!

```
@async alarm(0, 5, 0, action = ()-> println("TickTock.jl: 5 minutes is up!"))

@async alarm(0, 0, 5, action = () -> run(`say "Your Earl Grey is ready; sir"`), alarmname="tea's up") # uses macOS speech
```
"""
function alarm(hours, minutes, seconds;
        action=() -> @info("TickTock: alarm"),
        alarmname="TickTock alarm")
    atime = DateTime(now() + Dates.Hour(hours) + Dates.Minute(minutes) + Dates.Second(seconds))
    t = now()
    if atime < t
        @info "that time has already passed"
        return false
    end
    tick()
    push!(TickTock.alarm_list, (
        "$(lpad(hour(t), 2, '0')):$(lpad(minute(t), 2, '0')):$(lpad(second(t), 2, '0'))",
        "$(lpad(hours, 2, '0')):$(lpad(minutes, 2, '0')):$(lpad(seconds, 2, '0'))",
        alarmname))
    while true
        sleep(1)
        if now() >= atime
            @info alarmname
            action()
            tock()
            break
        end
    end
end

"""
    alarm(dt::DateTime;
        action = () -> @info("TickTock: time's up"))

Run an alarm that fires at time `dt`, with the option of
providing a function that executes when alarm fires.

# Examples

```
using Dates

dt = now() + Dates.Minute(1)

@async alarm(dt, action = () -> println("TickTock.jl: Ready!"))
```

```
@async alarm(now() + Dates.Minute(10) + Dates.Second(0), action = () -> run(`say "wake up, 10 minutes is up"`)) # macOS speech command
```

"""
function alarm(dt::DateTime;
        action = () -> @info("TickTock: alarm"),
        alarmname = "TickTock alarm")
    p = Dates.Period(dt - now())
    secs = round(p, Dates.Second).value
    if secs < 0
        @info "that time has already passed"
        return false
    end 
    m, s = divrem(secs, 60)
    h, m = divrem(m, 60)
    alarm(h, m, s, action=action, alarmname=alarmname)
    @info "TickTock: \"$(alarmname)\" alarm for $h hours, $m minutes, $s seconds"
end

"""
    alarmnotify(subtitle="TickTock alarm")

Show on-screen notification.

@async alarm(now() + Dates.Second(5), action = () ->  TickTock.alarmnotify("time's up"))

TODO Add Linux and Windows - MacOS only at the moment.
"""
function alarmnotify(subtitle="TickTock alarm")
    !Sys.isapple() && exit()
    command = """
    display notification with title "TickTock.jl" subtitle \"$(subtitle)\" sound name "frog"
    """
    chomp(read(`osascript -e $command`, String))
end

function alarmlist()
    if length(TickTock.alarm_list) > 0
        println("\nstart    | duration | finish     | name")
        for alarm in TickTock.alarm_list
            sh, sm, ss = parse.(Int, split(alarm[1], ":"))
            eh, em, es = parse.(Int, split(alarm[2], ":"))
            st = Time(sh, sm, ss)
            et = st + Hour(eh) + Minute(em) + Second(es)
            (Time(now()) > et) ? f = "✓" : f = " "
            println("$(alarm[1]) | $(alarm[2]) | $(Dates.format(et, "HH:MM:SS")) $f | $(alarm[3])" )
        end
    end
end

end # module
