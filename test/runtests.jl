using MCMCSamples
using Base.Test

@testset "MCMCDraws constructor" begin
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

@testset "MCMCDraws pooling" begin
    va1 = randn(10)
    vb1 = randn(length(va1))
    draws1 = MCMCDraws(:b => vb1, :a => va1)
    drawsc = MCMCDraws(:c => randn(length(va1)))
    @test MCMCSamples.is_same_keys(draws1, draws1)
    @test !MCMCSamples.is_same_keys(draws1, drawsc)
    va2 = randn(20)
    vb2 = randn(length(va2))
    draws2 = MCMCDraws(:a => va2, :b => vb2)
    drawsp = pool(draws1, draws2)
    @test length(drawsp) == length(draws1) + length(draws2)
    @test keys(drawsp) == [:a, :b]
    @test drawsp[:a] == vcat(va1, va2)
    @test drawsp[:b] == vcat(vb1, vb2)
end

