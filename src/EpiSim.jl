module EpiSim

using LightGraphs
using GraphPlot
using Colors
using Plots


export 
    # abstractmodel.jl
    AbstractModel, rate_infected, rate_recovered, node_state, get_node_state, get_state_colours, simulate!,

    # sir.jl
    SIR, initialise!, update!,

    # sis.jl
    SIS, initialise!, update!


include("abstractmodel.jl")
include("sir.jl")
include("sis.jl")

end # module
