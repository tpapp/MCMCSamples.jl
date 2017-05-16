module MCMCSamples

using ArgCheck
using Lazy

export
    MCMCDraws,
    MCMCChain,
    pool

const MCMCDrawsVector = AbstractVector

const MCMCDrawsDict = Dict{Symbol, MCMCDrawsVector}

"""
Structure for storing MCMC draws.

# Interface

Draws are `AbstractVector`s, indexed by `Symbol`s. Uniform length is
enforced. `keys` are ordered, allowing determnistic traversal, but
this is not guaranteed in the internals.

# Usage

Use this structure as a collection of vectors which are ordered so
that corresponding elements match, but the contents are not
necessarily contiguous or come from the same chain — ie a pooled
sample. Useful for posterior inference and predictive checks.

For convergence analysis, use `MCMCChains`.
"""
struct MCMCDraws
    dict::MCMCDrawsDict
    function MCMCDraws(dict::MCMCDrawsDict)
        @argcheck !isempty(dict) "Need at least one vector of draws."
        N = length(first(values(dict)))
        @argcheck all(length(x) == N for x in values(dict)) "Inconsistent vector length."
        new(dict)
    end
end

MCMCDraws(pairs::Pair{Symbol, <:AbstractArray}...) = MCMCDraws(MCMCDrawsDict(pairs))

MCMCDraws(itr) = MCMCDraws(MCMCDrawsDict(itr))

Base.length(draws::MCMCDraws) = length(first(values(draws.dict)))

Base.keys(draws::MCMCDraws) = sort!(collect(keys(draws.dict)))

Base.getindex(draws::MCMCDraws, var::Symbol) = draws.dict[var]

"""
Test if all keys of `itr` are the same.
"""
function all_same_keys(itr)
    @argcheck !isempty(itr)
    keys1 = keys(first(itr))
    all(keys(draws) == keys1 for draws in drop(itr, 1))
end

const MCMCIndex = AbstractVector{Int}

"Test if `index` is valid for MCMC (nonempty, positive, increasing)."
function is_valid_index(index::MCMCIndex)
    !isempty(index) && first(index) > 0 && issorted(index)
end

const MCMCChainMeta = Dict{Symbol, Any}

"""
Markov Chain Monte Carlo draws with additional information.

# Fields

- `index` is an `AbstractVector` of integers, for indexing
  draws. Usually a `UnitRange` like `1000:2000`, or a `StepRange`
  `5000:10:10000` for a thinned sample.

- first `discard` elements of `index` are not meant to be used for
  posterior inference (because they are part of the adaptation, or
  burn-in, etc). These are discarded when pooled.

- `draws`: vectors and variable names, see `MCMCDraws`.

- `meta`: a dictionary indexed by symbols, for other metadata, related
  to sampling (eg mass matrix, adaptation information, information for
  useful continuation of sampling, etc).

# Usage

Use this structure (or a collection of them) for convergence analysis.

Pool a collection of these structures for posterior inference (and
predictive checks, etc).
"""
struct MCMCChain
    index::MCMCIndex
    discard::Int
    draws::MCMCDraws
    meta::MCMCChainMeta
    function MCMCChain(index, discard, draws, meta)
        @argcheck is_valid_index(index) "Invalid index."
        @argcheck length(index) == length(draws) "Inconsistent lengths."
        @argcheck 0 ≤ discard ≤ length(index)
        new(index, discard, draws, meta)
    end
end

@forward MCMCChain.draws Base.keys, Base.length, Base.getindex

# this is the preferred interface
MCMCChain(draws::MCMCDraws; discard = 0, index = (1:length(draws))+discard,
          meta = MCMCChainMeta()) = MCMCChain(index, discard, draws, meta)

"""
Pool MCMC draws into a single `MCMCDraws` structure. 
"""
function pool(itr)
    @argcheck all_same_keys(itr) "Incompatible variable names."
    MCMCDraws(key => vcat((@view(c[key][(c.discard+1):end]) for c in itr)...)
              for key in keys(first(itr)))
end

pool(chains::MCMCChain...) = pool(chains)

end # module
