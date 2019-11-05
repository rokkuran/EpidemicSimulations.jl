"""
```
SEIR <: AbstractModel
```
"""
mutable struct SEIR <: AbstractModel
    G::AbstractGraph
    n_steps::Int
    state_types::AbstractArray{Symbol}
    states::Dict{Symbol, AbstractArray}
    parameters::Dict{Symbol, Number}
end

SEIR() = SEIR(SimpleGraph(), 50, Symbol[], Dict{Symbol, AbstractArray}(), Dict{Symbol, Number}())

incubation_period(m::SEIR) = get(m.parameters, :incubation_period, nothing)


function initialise!(m::SEIR, G::AbstractGraph, n_steps::Int)
    
    m.G = G
    m.n_steps = n_steps

    # m.parameters[:rate_exposed] = 0.33
    m.parameters[:rate_infectious] = 0.33
    m.parameters[:rate_recovered] = 0.20
    m.parameters[:incubation_period] = 3

    m.state_types = [:susceptible, :exposed, :infectious, :recovered]

    m.states = Dict(k => zeros(Int8, nv(G), n_steps) for k in m.state_types)
    for i in 1:n_steps
        m.states[:susceptible][:, i] = ones(Int8, nv(G))
        m.states[:infectious][:, i] = zeros(Int8, nv(G))

        m.states[:susceptible][1, i] = 0
        m.states[:susceptible][2, i] = 0
        m.states[:exposed][1, i] = incubation_period(m)
        m.states[:exposed][2, i] = incubation_period(m)
    end

    nothing
end


function update!(m::SEIR, node::Int, n_step::Int)
    
    if node_state(m, :susceptible, node, n_step - 1) == 1
        for neighbour in neighbors(m.G, node)
            if node_state(m, :infectious, neighbour, n_step - 1) == 1
                if rand() <= rate_infectious(m)
                    m.states[:susceptible][node, n_step] = 0
                    m.states[:exposed][node, n_step] = incubation_period(m)
                    break
                end
            end
        end
    end

    exposed_node_state = node_state(m, :exposed, node, n_step - 1)
    if exposed_node_state > 1
        m.states[:exposed][node, n_step] -= 1
    elseif exposed_node_state == 1
        m.states[:exposed][node, n_step] = 0
        m.states[:infectious][node, n_step] = 1
    end

    if node_state(m, :infectious, node, n_step - 1) == 1
        if rand() <= rate_recovered(m)
            m.states[:infectious][node, n_step] = 0
            m.states[:recovered][node, n_step] = 1
        end
    end

    nothing
end
