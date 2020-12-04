module SWIM

using DataStructures
using Distances
using Rectangle
using Dates

export Canvas
export initialize
export generate_nodes
export Cell

include("Node.jl")
include("Canvas.jl")

end
