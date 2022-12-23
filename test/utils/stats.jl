
@testset "Stats.jl" begin
    s = Stats()
    OnlineStats.fit!(s, (a = 1, b = 2))
    OnlineStats.fit!(s, (a = 2, b = 3))
    @test mean(s) == (a = 1.5, b = 2.5)
    @test var(s) == (a = 0.5, b = 0.5)
    @test mean_with_err(s) == (a = 1.5, a_err = 0.5, b = 2.5, b_err = 0.5)

    @test mean(s) == OnlineStats.value(s)
    OnlineStats.fit!(s, [(a = 2, b = 3), (a = 2, b = 3)])
    @test OnlineStats.nobs(s) == 4
    @test length(s) == 2

    s1 = deepcopy(s)
    s2 = deepcopy(s)
    merge!(s1, s2)
    @test OnlineStats.nobs(s1) == 2 * OnlineStats.nobs(s)

    @testset "error" begin
        s = OnlineStats.fit!(Stats(), [(a=1,), (a=2,), (a=3,)])
        @test s.a.err ≈ √(2 / 6)
    end

    @testset "one observation" begin
        s = OnlineStats.fit!(Stats(), [(a=1,),])
        @test s.a.val == 1 
        @test s.a.err == Inf
    end


    @testset "reduce" begin
        data = [(a = i, b = 2*i) for i in 1:10];
        s = reduce(Stats(), data)

        @test OnlineStats.nobs(s) == 10
        @test s.a ≈ 5.5
        @test s.a.err ≈ 0.957427107756338
    end

    @testset "measurement" begin
        data = [(a = i, b = 2*i) for i in 1:10];
        s = reduce(Stats(), data)
        @test s.a isa Measurements.Measurement
        m = measurement(s)
        @test m isa NamedTuple
        @test m.a isa Measurements.Measurement
        @test m.a.val ≈ 5.5
        @test m.a.err ≈ 0.957427107756338
        @test m.b.val ≈ 11.0
        @test m.b.err ≈ 1.9148542155126762
    end

    @testset "fit named tuple of vectors" begin
        s = OnlineStats.fit!(Stats(), (a = [1, 2, 3], b = [2, 4]))
        @test OnlineStats.nobs(s[:a]) == 3
        @test s.a ≈ 2
        @test OnlineStats.nobs(s[:b]) == 2
        @test s.b ≈ 3
    end
    
    @testset "reduce named tuple of vectors" begin
        s = reduce(Stats(), (a = [1, 2, 3], b = [2, 4]))
        @test OnlineStats.nobs(s[:a]) == 3
        @test s.a ≈ 2
        @test OnlineStats.nobs(s[:b]) == 2
        @test s.b ≈ 3

        s = reduce(s, (a = [1, 2, 3], b = [2, 4]))
        @test OnlineStats.nobs(s[:a]) == 6
        @test OnlineStats.nobs(s[:b]) == 4
    end
end