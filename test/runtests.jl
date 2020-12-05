using SWIM
using Test

@testset "SWIM.jl" begin
   c = Canvas(10,10,2.83)
   initialize(c)

   nodes = generate_nodes(c,1,100)
   println(nodes)
   
   move(nodes[1],c,0.5,0.5,2.0)
   move(nodes[1],c,0.5,0.5,2.0)
   move(nodes[1],c,0.5,0.5,2.0)

   
end