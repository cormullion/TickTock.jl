using TickTock
using Base.Test

tick()
sleep(1)
@test tok() > 1.0
