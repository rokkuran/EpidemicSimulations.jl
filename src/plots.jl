# using Plots

# pyplot()

# import RecipesBase.plot



# function plot_simulation(system::System)
# # function RecipesBase.plot(system::System)
#     plot(system.S, line=(:blue, 0.6), label="Susceptible")
#     plot!(system.I, line=(:red, 0.6), label="Infected")
#     plot!(system.R, line=(:green, 0.6), label="Recovered")

#     xlabel!("Time")
#     ylabel!("Population")
# end

@userplot EvolutionPlot

@recipe function f(x::EvolutionPlot)

    legend := true

    @series begin
        linecolor --> :blue
        x.S
    end

    @series begin
        linecolor --> :red
        x.I
    end

    @series begin
        linecolor --> :green
        x.R
    end

end
