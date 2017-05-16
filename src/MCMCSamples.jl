module MCMCSamples

using ArgCheck

export
    MCMCDraws

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

function is_same_vars(draws1::MCMCDraws, draws_rest::MCMCDraws...)
    vn1 = varnames(draws1)
    all(varnames(draws) == v1 for draws in draws_rest)
end
