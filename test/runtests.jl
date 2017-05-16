using MCMCSamples
using Base.Test

@testset "mcmcdraws" begin
    va = 1:10
    vb = randn(length(va))
    draws = MCMCDraws(:b => vb, :a => va)
    @test keys(draws) == [:a, :b] # order important
    @test draws[:a] == va
    @test draws[:b] == vb
    @test length(draws) == length(va)
    @test MCMCDraws(:a => va, :b => vb).dict == draws.dict
    @test_throws ArgumentError MCMCDraws()
    @test_throws ArgumentError MCMCDraws(:a => va, :b => vb, :c => 1:8)
end
