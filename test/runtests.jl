using MCMCSamples
using Base.Test

@testset "MCMCDraws constructor and methods" begin
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

@testset "MCMCChains pooling" begin
    va1 = randn(10)
    vb1 = randn(length(va1))
    draws1 = MCMCDraws(:b => vb1, :a => va1)
    drawsc = MCMCDraws(:c => randn(length(va1)))
    @test MCMCSamples.all_same_keys([draws1, draws1])
    @test !MCMCSamples.all_same_keys([draws1, drawsc])
    va2 = randn(20)
    vb2 = randn(length(va2))
    draws2 = MCMCDraws(:a => va2, :b => vb2)
    chain1 = MCMCChain(draws1; discard = 5)
    chain2 = MCMCChain(draws2; discard = 2)
    drawsp = pool(chain1, chain2)
    @test length(drawsp) == length(draws1) - 5 + length(draws2) - 2
    @test keys(drawsp) == [:a, :b]
    @test drawsp[:a] == vcat(va1[6:end], va2[3:end])
    @test drawsp[:b] == vcat(vb1[6:end], vb2[3:end])
end
