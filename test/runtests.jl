# using TestEnv; TestEnv.activate()
using Test
using ScienceProjectTemplate
using Random, Statistics, LinearAlgebra
import OnlineStats
using OrderedCollections: OrderedDict


println("Starting tests")
ti = time()

@testset "Utils" begin
    include("utils/misc.jl")
    include("utils/stats.jl")
end

ti = time() - ti
println("\nTest took total time of:")
println(round(ti/60, digits = 3), " minutes")
