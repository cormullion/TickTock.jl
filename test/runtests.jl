using Test, Dates, TickTock

tick()

sleep(1)

@test typeof(peektimer()) == Float64

@async alarm(now() + Dates.Minute(0) + Dates.Second(10),
    action=() ->
        begin
            println("test alarm has fired")
        end)

alarmmessage() = println("This is an alarm. Do not be alarmed.")

@async alarm(now() + Dates.Second(5), action=alarmmessage)

alarmlist()

@test sprint(show, laptimer(), context=:compact => true) == "nothing"

@test tok() > 1.0

tick()

@test sprint(show, tock(), context=:compact => true) == "nothing"

println("Make 10 timers")

for i in 1:10
    tick()
    sleep(1)
end

@test length(TickTock.gettimers()) == 10

println("Check that there are 10 timers")

println("wait a second")

sleep(1)

println("Print all the timers")

laptimer()

for i in 1:10
    peektimer()
end

@show peektimers()

println("Check that the most recent timer is more than 1 second")
println("  ", peektimer())
@test peektimer() > 1.0

println("Finish 10 timers and show canonical")

for i in 1:10
    tock()
end

@test_throws ErrorException tok()
