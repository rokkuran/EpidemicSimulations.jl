using EpiSim
using Test, LightGraphs


n_nodes = 200
n_steps = 50

G = watts_strogatz(n_nodes, 4, 0.2)
m = SIR()
initialise!(m, G, n_steps)
simulate!(m)

@test 1 == 1