# using TestEnv; TestEnv.activate()
using Test
using ScienceProjectTemplate
using Random, Statistics, LinearAlgebra
import OnlineStats
using OrderedCollections: OrderedDict
using Measurements
using DataFrames

println("Starting tests")
ti = time()

@testset "Library" begin
    @testset "Utils" begin
        include("utils/misc.jl")
        include("utils/stats.jl")
    end
end

@testset "Scripts" begin
    @testset "gradient_descent" begin
        include("../scripts/gradient_descent.jl")
        include("scripts/gradient_descent.jl")
    end
end

ti = time() - ti
println("\nTest took total time of:")
println(round(ti/60, digits = 3), " minutes")
