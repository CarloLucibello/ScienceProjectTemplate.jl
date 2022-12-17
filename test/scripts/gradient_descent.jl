@testset "f_single_run" begin
    res = f_single_run()
    @test res isa NamedTuple
    @test f_single_run(; N=50, α=0.2, η=0.5, λ=0.1, maxsteps=1000, nsamples=10) isa NamedTuple
    
end

@testset "parallel_run" begin
    df = parallel_run(resfile=nothing)
    @test df isa DataFrame
end
