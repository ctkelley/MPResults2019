"""
MPResults2019

This module has the code you need for the mixed precision example.
"""
module MPResults2019

export knl
export heqtest
export plotknl
export frpintTeX
export data_populate
export data_harvest

using PyPlot
using LinearAlgebra
using JLD2
using Printf
using .Heq4knl

include("knlv01.jl")
include("heqtest.jl")
include("plotknl.jl")
include("fprintTeX.jl")
include("data_populate.jl")
include("data_harvest.jl")

end
