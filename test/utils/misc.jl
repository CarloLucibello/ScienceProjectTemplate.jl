@testset "cartesian_list" begin
    list = cartesian_list(z = [1,2], a = [3,4], f = 2)
    @test length(list) == 4
    @test list[1] isa NamedTuple
    for l in list
        @test collect(keys(l)) == [:z, :a, :f]
    end

    @test cartesian_list(a = 3:4, f = 2) == [(a = 3, f = 2), (a = 4, f = 2)]
end

@testset "combine_results" begin
    df = DataFrame(a = [1,1,3], 
                   b = [2,2,4], 
                   n = [2,3,4], 
                   c = [2.,2.,4.], 
                   c_delta = [0.2,0.1,0.2])

    df2 = combine_results(df, by=1:2, cols=4:2:ncol(df), errs=5:2:ncol(df), col_n=:n)

    @test df2 ≈ DataFrame(a = [1,3], 
                    b = [2,4], 
                    n = [5,4], 
                    c = [2.,4.], 
                    c_delta = [0.083666,0.2])

    @testset "1 sample" begin
        df = DataFrame(a=[1,1,3], b=[2,2,4], n=[1,1,1], c=[2.,3.,4.], c_delta=[Inf,Inf,Inf])
        df2 = combine_results(df, by=2, cols=4:2:ncol(df), errs=5:2:ncol(df), col_n=:n)
        @test df2 ≈ DataFrame(b=[2,4], n=[2,1], c=[2.5,4.], c_delta=[0.5,Inf])
    end

    @testset "no error" begin
        df = DataFrame(a=[1,1,3,1], b=[1,2,6,3], c=[7,8,9,10])
        df2 = combine_results(df, by=:a, cols=:b)
        @test df2 ≈ DataFrame(a=[1,3], nsamples=[3,1], b=[2.,6.], b_err=[0.5773502691896,Inf])
    end
end

@testset "round3" begin
    @test round3(1.234) == 1.23
    @test round3(3) isa Int
    @test round3((a=2.1111, b=3.33333)) == (a=2.11, b=3.33)
end
