using TickTock
using Base.Test

tick()
sleep(1)
@test typeof(peek()) == Float64
@test typeof(lap()) == Void
@test tok() > 1.0
tick()
@test typeof(tock()) == Void

# with no current timer, these should error

@test_throws ErrorException peek()
@test_throws ErrorException lap()
@test_throws ErrorException tok()
