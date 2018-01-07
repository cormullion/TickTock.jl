using TickTock

if VERSION > v"0.7.0-"
    using Test
else
    using Base.Test
end

tick()

sleep(1)

@test typeof(peek()) == Float64

if VERSION > v"0.7.0-"
    @test typeof(lap()) == Nothing
else
    @test typeof(lap()) == Void
end


@test tok() > 1.0

tick()

if VERSION > v"0.7.0-"
    @test typeof(tock()) == Nothing
else
    @test typeof(tock()) == Void
end

# with no current timer, these should error

@test_throws ErrorException peek()
@test_throws ErrorException lap()
@test_throws ErrorException tok()
