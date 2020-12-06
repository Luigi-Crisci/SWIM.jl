module SWIM

using DataStructures
using Distances
using Rectangle
using Distributions
using Dates
using Base

export Canvas
export initialize
export generate_nodes
export Cell
export Node
export move
export update_seen
export simulate
export close_writer

include("Canvas.jl")
include("EventWriter.jl")
include("Node.jl")
include("Simulation.jl")

end
