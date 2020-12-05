module SWIM

using DataStructures
using Distances
using Rectangle
using Distributions
using Dates

export Canvas
export initialize
export generate_nodes
export Cell
export Node
export move

include("Canvas.jl")
include("Node.jl")

end
