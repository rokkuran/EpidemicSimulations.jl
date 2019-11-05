abstract type AbstractModel end


rate_infectious(m::AbstractModel) = get(m.parameters, :rate_infectious, nothing)
rate_recovered(m::AbstractModel) = get(m.parameters, :rate_recovered, nothing)


function node_state(m::AbstractModel, state_type::Symbol, node::T, n_step::T) where {T <: Int} 
    m.states[state_type][node, n_step]
end


function get_node_state(m::AbstractModel, node::T, n_step::T) where {T <: Int} 
    for state_type in keys(m.states)
        if node_state(m, state_type, node, n_step) >= 1
            return state_type
        end
    end
end

function get_state_colours(m::AbstractModel, cmap::Dict{Symbol, RGB}, n_step::Int)
    [cmap[get_node_state(m, node, n_step)] for node in 1:nv(m.G)]
end


function simulate!(m::AbstractModel)
    
    for i in 2:m.n_steps
        
        for state_type in m.state_types
            m.states[state_type][:, i] = deepcopy(m.states[state_type][:, i - 1])
        end
        
        for node in vertices(m.G)
            update!(m, node, i)
        end
        
    end
    
    nothing
end
