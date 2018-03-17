if VERSION > v"0.7.0-"
    using Pkg
    using Test
else
    using Base.Test
end

using TickTock

tick()

sleep(1)

@test typeof(peektimer()) == Float64

if VERSION > v"0.7.0-"
    @test sprint(show, laptimer(), context=:compact => true) == "nothing"
else
    @test typeof(laptimer()) == Void
end

@test tok() > 1.0

tick()

if VERSION > v"0.7.0-"
    @test sprint(show, tock(), context=:compact => true) == "nothing"
else
    @test typeof(tock()) == Void
end

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

println("Check that the most recent timer is more than 1 second")

println(peektimer())

@test peektimer() > 1.0

println("Finish 10 timers and show canonical")

for i in 1:10
    tock()
end

# now, with no current timers, these should all error

@test_throws ErrorException TickTock.gettimers()
@test_throws ErrorException peektimer()
@test_throws ErrorException laptimer()
@test_throws ErrorException tok()
@test_throws ErrorException TickTock.showtimes()
