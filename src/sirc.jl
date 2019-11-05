"""
```
SIR <: AbstractModel
```

here are some words...
"""
mutable struct SIRC <: AbstractModel
    G::AbstractGraph
    n_steps::Int
    state_types::AbstractArray{Symbol}
    states::Dict{Symbol, BitArray{2}}
    parameters::Dict{Symbol, Number}
end

SIRC() = SIRC(SimpleGraph(), 50, Symbol[], Dict{Symbol, BitArray{2}}(), Dict{Symbol, Number}())


function initialise!(m::SIRC, G::AbstractGraph, n_steps::Int)
    
    m.G = G
    m.n_steps = n_steps

    m.parameters[:rate_infectious] = 0.33
    m.parameters[:rate_carrier] = 0.33
    m.parameters[:rate_infectious_transition] = 0.20
    m.parameters[:rate_recovered] = 0.80

    m.state_types = [:susceptible, :infectious, :recovered, :carrier]

    m.states = Dict(k => BitArray(zeros(nv(G), n_steps)) for k in m.state_types)
    for i in 1:n_steps
        m.states[:susceptible][:, i] = BitArray(ones(nv(G)))
        m.states[:infectious][:, i] = BitArray(zeros(nv(G)))
        m.states[:susceptible][1, i] = 0
        m.states[:infectious][1, i] = 1  
    end

    nothing
end


function update!(m::SIRC, node::Int, n_step::Int)

    if node_state(m, :infectious, node, n_step - 1)
        if rand() <= m.parameters[:rate_infectious_transition]
            if rand() <= rate_recovered(m)
                m.states[:infectious][node, n_step] = 0
                m.states[:recovered][node, n_step] = 1
            else
                m.states[:infectious][node, n_step] = 0
                m.states[:carrier][node, n_step] = 1
            end
        end
    end
    
    if node_state(m, :susceptible, node, n_step - 1)
        for neighbour in neighbors(m.G, node)
            if node_state(m, :infectious, neighbour, n_step - 1)
                if rand() <= rate_infectious(m)
                    m.states[:susceptible][node, n_step] = 0
                    m.states[:infectious][node, n_step] = 1
                    break
                end
            elseif node_state(m, :carrier, neighbour, n_step - 1)
                if rand() <= m.parameters[:rate_carrier]
                    m.states[:susceptible][node, n_step] = 0
                    m.states[:infectious][node, n_step] = 1
                    break
                end
            end
        end
    end

    nothing
end
