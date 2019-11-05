module EpidemicSimulations

using LightGraphs
using GraphPlot
using Colors
using Plots


export 
    # abstractmodel.jl
    AbstractModel, rate_infectious, rate_recovered, node_state, get_node_state, get_state_colours, simulate!,

    # sir.jl
    SIR, initialise!, update!,

    # sis.jl
    SIS, initialise!, update!,

    # seir.jl
    SEIR, initialise!, update!,

    # sirc.jl
    SIRC, initialise!, update!


include("abstractmodel.jl")
include("sir.jl")
include("sis.jl")
include("seir.jl")
include("sirc.jl")

end # module
