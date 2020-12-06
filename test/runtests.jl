using SWIM
using Test

@testset "SWIM.jl" begin
    c = Canvas(10, 10, 2.83)
    initialize(c)

    nodes = generate_nodes(c, 10, 100)
    simulate(c,nodes,100,2.0)
    
end


