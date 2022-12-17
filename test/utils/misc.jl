@testset "cartesian_list" begin
    list = cartesian_list(z = [1,2], a = [3,4], f = 2)
    @test length(list) == 4
    @test list[1] isa NamedTuple
    for l in list
        @test collect(keys(l)) == [:z, :a, :f]
    end
end
