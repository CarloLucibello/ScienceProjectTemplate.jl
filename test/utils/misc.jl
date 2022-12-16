@testset "dict_list" begin
    d = OrderedDict(:z => [1,2], :a => [3,4], :f => 2)
    dlist = dict_list(d)
    @test length(dlist) == 4
    @test dlist[1] isa OrderedDict
    for d in dlist
        @test collect(keys(d)) == [:z, :a, :f]
    end
end
