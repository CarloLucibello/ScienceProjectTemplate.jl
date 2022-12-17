
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

    @testset "reduce" begin
        data = [(a = i, b = 2*i) for i in 1:10];
        s = reduce(Stats(), data)

        @test OnlineStats.nobs(s) == 10
        @test s.a ≈ 5.5
        @test s.a.err ≈ 0.9574271077563381
    end

    @testset "measurement" begin
        data = [(a = i, b = 2*i) for i in 1:10];
        s = reduce(Stats(), data)
        @test s.a isa Measurements.Measurement
        m = measurement(s)
        @test m isa NamedTuple
        @test m.a isa Measurements.Measurement
        @test m.a == 5.5 ± 0.9574271077563381
        @test m.b == 11.0 ± 1.9148542155126762
    end

end