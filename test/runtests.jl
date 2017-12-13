using TickTock
using Base.Test

tick()
sleep(1)
@test typeof(peek()) == Float64
@test typeof(lap()) == Void
@test tok() > 1.0
tick()
@test typeof(tock()) == Void
