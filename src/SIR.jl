# using LightGraphs
# using GraphPlot
# using Compose
# using Colors



# import Base.copy



# include("common.jl")



mutable struct State{T<:Bool}
    susceptible::Array{T}
    infected::Array{T}
    recovered::Array{T}
end

Base.copy(x::State) = State(copy(x.susceptible), copy(x.infected), copy(x.recovered))

get_totals(x::State) = [sum(getfield(x, a) * 1) for a in fieldnames(x)]


mutable struct System{T<:Number}
    n::Integer
    p_transmission::Float64
    p_recovery::Float64
    evolution::Array{State}
    S::Array{T}
    I::Array{T}
    R::Array{T}
end

function System(n::Integer, p_transmission, p_recovery)
    System(n, p_transmission, p_recovery, Array{State}(n), 
        [Array{Integer}(n) for _ in 1:3]...)
end



function propagate!(G::AbstractGraph, vertices, state::State, system::System; verbose=false)
    for i in vertices
        verbose && println("i = $i: neighbours = ", neighbors(G, i))
        for n in neighbors(G, i)
            if state.susceptible[n]
                if rand() <= system.p_transmission
                    verbose && println("\tn = $n: newly infected")
                    state.susceptible[n] = false
                    state.infected[n] = true
                else
                    verbose && println("\tn = $n: remained susceptible")
                end
            end
        end
        if rand() <= system.p_recovery
            state.infected[i] = false
            state.recovered[i] = true
            verbose && println("*i = $i: recovered")
        end
    end
end



function simulate!(G::AbstractGraph, state::State, N::Integer, system::System; verbose=false)
    
    vertices = collect(1:nv(G))
    system.evolution[1] = copy(state)
    system.S[1], system.I[1], system.R[1] = get_totals(state)
    
    t = 2
    while t <= N
        verbose && println("\n\nEPOCH $t")
        infected_vertices = vertices[state.infected]

        verbose && println("\nPropagation 1:")
        propagate!(G, infected_vertices, state, system)

        verbose && println("\n[S, I, R] = ", get_totals(state))
        system.S[t], system.I[t], system.R[t] = get_totals(state)
        
        system.evolution[t] = copy(state)

        t += 1
    end
end



function main(G::AbstractGraph)
    is_susceptible = [true for _=1:nv(G)]
    is_infected = [false for _=1:nv(G)]
    is_recovered = [false for _=1:nv(G)]

    is_susceptible[1] = false
    is_infected[1] = true

    state = State(is_susceptible, is_infected, is_recovered)
    println("initial state: [S, I, R] = ", get_totals(state))
    
    
    p_transmission = 0.2
    p_recovery = 0.1
    N = 100
    
    system = System(N, p_transmission, p_recovery)
    simulate!(G, state, N, system)

    println("final state: [S, I, R] = ", get_totals(state))
    
    state, system
end


function get_colour_state(G::AbstractGraph, system::System, n::Integer, cmap::Dict{Symbol, RGB})
    visited = Int64[]
    vertex_colours = Array{RGB}(nv(G))
    
    for a in fieldnames(system.evolution[n])
        for (i, v) in enumerate(getfield(system.evolution[n], a))
            if i ∉ visited
                if v
                    push!(visited, i)
                    vertex_colours[i] = cmap[a]
                    # verbose && println("$a: $i → $v")
                end
            end
        end
    end
    
    vertex_colours
end


function export_plots(output_path::String, G::AbstractGraph, system::System, 
    cmap::Dict{Symbol, RGB})
    
    loc_x, loc_y = spring_layout(G)

    for t in 1:length(system.evolution)
        if system.I[t] != 0
            draw(
                PNG("$output_path/$t.png", 15cm, 15cm),
                gplot(
                    G, 
                    nodefillc=get_colour_state(G, system, t, cmap),
                    loc_x, loc_y
                ),
            )
        end
    end
end


function run()
	srand(777)

	cmap = Dict{Symbol, RGB}(
	    :susceptible => RGB(0.2, 0.4, 1.0), 
	    :infected => RGB(1.0, 0.3, 0.3),
	    :recovered => RGB(0.2, 0.8, 0.2) 
	)

	# G = erdos_renyi(100, 0.3, seed=77)
	# G = barabasi_albert(2000, 1, seed=35)
	# G = watts_strogatz(1000, 4, 0.2)
	G = watts_strogatz(250, 4, 0.2)
    state, system = main(G)
    
    output_path = "/home/rokkuran/workspace/epidemic_models/output/sir"
    export_plots(output_path, G, system, cmap)

end


