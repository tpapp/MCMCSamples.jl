# MCMCSamples

[![Project Status: WIP - Initial development is in progress, but there has not yet been a stable, usable release suitable for the public.](http://www.repostatus.org/badges/latest/wip.svg)](http://www.repostatus.org/#wip)
[![Build Status](https://travis-ci.org/tpapp/MCMCSamples.jl.svg?branch=master)](https://travis-ci.org/tpapp/MCMCSamples.jl)
[![Coverage Status](https://coveralls.io/repos/tpapp/MCMCSamples.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/tpapp/MCMCSamples.jl?branch=master)
[![codecov.io](http://codecov.io/github/tpapp/MCMCSamples.jl/coverage.svg?branch=master)](http://codecov.io/github/tpapp/MCMCSamples.jl?branch=master)

A Julia package that defines a container format for Markov Chain Monte Carlo samples.

## Concept

The purpose of this package is to facilitate cooperation between Markov Chain Monte Carlo statistics packages in the Julia ecosystem by providing common data structures.

Packages which produce MCMC chains can make them available as an object of type `MCMCChain`, which is a collection of `AbstractVector`s, indexed by `Symbol`s, and some extra information, such as draw indices (eg `1001:10:2000` means that the first `1000` draws are not included, and the rest is thinned by a factor of `10`), information on what part of the chain should end up in the pooled sample for inference, and arbitrary metadata, eg information on adaptation, sampling, or even continuing the chain.

Other packages can implement convergence diagnostics, on single `MCMCChain`s or collections of them.

Once the user is satisfied with convergence and wants to perform inference or posterior predictive checks, `pool` can merge the chains, discarding the draws as indicated. This results in a `MCMCDraws` object, which is just a wrapper around a `Dict` to enforce uniform length and consistent order of `keys`.

```
+-------+                              +--------------------------+
| Stan  |----+                         | convergence diagnostics: |
+-------+    |                         |  - Rhat                  |
             |     +-------------+     |  - plots                 |
+-------+    |     |             |==>==|  - effective sample size |
| Klara |----+     | MCMCChain 1 |     |  - ...                   |
+-------+    |     | MCMCChain 2 |     +--------------------------+
             +==>==| MCMCChain 3 |
+-------+    |     | ...         |     +-------------------+
| Mamba |----+     |             |==>==| discard and pool: |
+-------+    |     +-------------+     |     MCMCDraws     |
             |                         +-------------------+
+-------+    |                                   ||
|  ...  |----+                                   \/
+-------+                         +-----------------------------+
                                  | posterior inference         |
                                  |  - plots                    |
                                  |  - quantiles/HPD intervals  |
                                  |                             |
                                  | posterior predictive checks |
                                  |                             |
                                  | ...                         |
                                  +-----------------------------+
```

## Key design points

1. Draws of variables are "reconstituted" from a tabular format. For example, an matrix is not stored elementwise as vectors of elements, but as a vector of `Matrix`es.

2. Chains of a single variable are vectors. This is not the most efficient storage format, as `Vector{Array}` could be repacked as an `Array`, however, for compact storage a `Vector` of [static arrays](https://github.com/JuliaArrays/StaticArrays.jl) is recommended, which can be packed and stored compactly. This package should work fine with any `AbstractVector`.

3. Posterior predictive checks and other simulations can be implemented very simply using `broadcast`.

4. This package should accommodate various storage formats, [JLD](https://github.com/JuliaIO/JLD.jl) is recommended.
