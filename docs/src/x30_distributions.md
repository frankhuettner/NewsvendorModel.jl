# Demand distribution

Working with distributions is very convinient in Julia. This package is supposed to work with any [univariate distribution from the Distributions.jl package](https://juliastats.org/Distributions.jl/latest/univariate/). 

For example, consider a slight variation of the introductory example. Suppose we want to avoid demand below zero, i.e., let us truncate the distribution at 0. We can define our distribution of choice as follows: 

```julia
julia> my_distr = truncated(Normal(50, 20), 0, Inf)
Truncated(Normal{Float64}(μ=50.0, σ=20.0), range=(0.0, Inf))
```

The model is now defined and stored in the variable `nvm2` as follows:

```julia
julia> nvm2 = NVModel(5, 7, my_distr)
Data of the Newsvendor Model
 * Unit cost: 5.00
 * Unit selling price: 7.00
 * Demand distribution: Truncated(Normal{Float64}(μ=50.0, σ=20.0), range=(0.0, Inf))
```

Optimization yields a slightly different result:

```julia
julia> profit(solve(nvm2)) - profit(solve(NVModel(5, 7, Normal(50, 20))))
1.8282476501980582
```

Other typical distributions are readily available, e.g.,
- [Beta distribution](https://juliastats.org/Distributions.jl/latest/univariate/#Distributions.Beta) with `Beta(α, β)`
- [Log normal distribution](https://juliastats.org/Distributions.jl/latest/univariate/#Distributions.LogNormal) with `LogNormal(μ, σ)`
- [Nonparametric discrete distribution](https://juliastats.org/Distributions.jl/latest/univariate/#Distributions.DiscreteNonParametric) with `DiscreteNonParametric(xs, ps)`
- [Poisson distribution](https://juliastats.org/Distributions.jl/latest/univariate/#Distributions.Poisson) with `Poisson(λ)`
- [Uniform distribution](https://juliastats.org/Distributions.jl/latest/univariate/#Distributions.Uniform) with `Uniform(a, b)`

Moreover, it is convinient to [fit distributions with Distributions.jl.](https://juliastats.org/Distributions.jl/latest/fit/)