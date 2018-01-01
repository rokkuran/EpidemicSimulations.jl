module EpidemicSimulations


using LightGraphs
using GraphPlot
using Compose
using Colors
using RecipesBase
# using Plots

# pyplot()


import Base: copy
import RecipesBase: plot


include("common.jl")
include("SIR.jl")
include("plots.jl")


export 

# common.jl
test_add,

# SIR.jl
State, get_totals,
System,
propagate!, simulate!, main, get_colour_state, export_plots, run,

# plots.jl
plot_simulation
# plot


end # module
