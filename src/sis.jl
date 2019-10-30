"""
```
SIR <: AbstractModel
```

here are some words...
"""
mutable struct SIS <: AbstractModel
    G::AbstractGraph
    n_steps::Int
    state_types::AbstractArray{Symbol}
    states::Dict{Symbol, BitArray{2}}
    parameters::Dict{Symbol, Number}
end

SIS() = SIS(SimpleGraph(), 50, Symbol[], Dict{Symbol, BitArray{2}}(), Dict{Symbol, Number}())


function initialise!(m::SIS, G::AbstractGraph, n_steps::Int)
    
    m.G = G
    m.n_steps = n_steps

    m.parameters[:rate_infected] = 0.33
    m.parameters[:rate_recovered] = 0.20

    m.state_types = [:susceptible, :infected]

    m.states = Dict(k => BitArray(zeros(nv(G), n_steps)) for k in m.state_types)
    for i in 1:n_steps
        m.states[:susceptible][:, i] = BitArray(ones(nv(G)))
        m.states[:infected][:, i] = BitArray(zeros(nv(G)))
        m.states[:susceptible][1, i] = 0
        m.states[:infected][1, i] = 1  
    end

    nothing
end


function update!(m::SIS, node::Int, n_step::Int)

    if node_state(m, :infected, node, n_step - 1)
        if rand() <= rate_recovered(m)  # replace with susceptible rate instead
            m.states[:infected][node, n_step] = 0
            m.states[:susceptible][node, n_step] = 1
        end
    end
    
    if node_state(m, :susceptible, node, n_step - 1)
        for neighbour in neighbors(m.G, node)
            if node_state(m, :infected, neighbour, n_step - 1)
                if rand() <= rate_infected(m)
                    m.states[:susceptible][node, n_step] = 0
                    m.states[:infected][node, n_step] = 1
                    break
                end
            end
        end
    end

    nothing
end
