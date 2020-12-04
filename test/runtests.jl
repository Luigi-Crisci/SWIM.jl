using SWIM
using Test

@testset "SWIM.jl" begin
   c = Canvas(100,100,5)
   initialize(c)
   nodes = generate_nodes(c,10)
   println(nodes)

   
end
