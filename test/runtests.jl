using TickTock
using Base.Test

# write your own tests here
tick()
sleep(1)
@test tok() > 1.0
 
