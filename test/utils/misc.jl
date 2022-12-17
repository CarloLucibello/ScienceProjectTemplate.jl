@testset "cartesian_list" begin
    list = cartesian_list(z = [1,2], a = [3,4], f = 2)
    @test length(list) == 4
    @test list[1] isa NamedTuple
    for l in list
        @test collect(keys(l)) == [:z, :a, :f]
    end
end

@testset "subseteq" begin
    df = DataFrame(a=[1,2,3,1], b=[4,5,6,4], c=[7,8,9,10])
    df2 = subseteq(df, a=1, b=4)
    @test df2 == DataFrame(a=[1,1], b=[4,4], c=[7,10])
end
