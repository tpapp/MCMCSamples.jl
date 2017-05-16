module MCMCSamples

using ArgCheck

export
    MCMCDraws,
    pool

######################################################################
# collections of draws
######################################################################

const MCMCDrawsVector = AbstractVector

const MCMCDrawsDict = Dict{Symbol, MCMCDrawsVector}

struct MCMCDraws
    dict::MCMCDrawsDict
    function MCMCDraws(dict)
        @argcheck !isempty(dict) "Need at least one vector of draws."
        N = length(first(values(dict)))
        @argcheck all(length(x) == N for x in values(dict)) "Inconsistent vector length."
        new(dict)
    end
end

MCMCDraws(pairs::Pair{Symbol, <:AbstractArray}...) = MCMCDraws(MCMCDrawsDict(pairs...))

Base.length(draws::MCMCDraws) = length(first(values(draws.dict)))

Base.keys(draws::MCMCDraws) = sort!(collect(keys(draws.dict)))

Base.getindex(draws::MCMCDraws, var::Symbol) = draws.dict[var]

function is_same_keys(draws1::MCMCDraws, draws_rest::MCMCDraws...)
    keys1 = keys(draws1)
    all(keys(draws) == keys1 for draws in draws_rest)
end

"""
Pool MCMC draws into a single structure.
"""
function pool(draws::MCMCDraws...)
    @argcheck is_same_keys(draws...) "Incompatible variable names."
    pooled(key) = key => vcat((draw[key] for draw in draws)...)
    MCMCDraws((pooled(key) for key in keys(first(draws)))...)
end

end # module
