[![](https://img.shields.io/badge/docs-dev-blue.svg)](https://frankhuettner.github.io/NewsvendorModel.jl/dev/)
[![CI](https://github.com/frankhuettner/NewsvendorModel.jl/actions/workflows/ci.yml/badge.svg)](https://github.com/frankhuettner/NewsvendorModel.jl/actions/workflows/ci.yml)
[![Coverage](https://codecov.io/gh/FrankHuettner/NewsvendorModel.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/FrankHuettner/NewsvendorModel.jl)


# NewsvendorModel.jl


This is a lightweight and simple Julia package for modeling and solving [newsvendor problems](https://en.wikipedia.org/wiki/Newsvendor_model).

## Setup

NewsvendorModel.jl requires an installation of Julia (can be downloaded from the [official website](https://julialang.org/)). You can install NewsvendorModel.jl like any other Julia package using the REPL as follows:


```julia
julia> import Pkg
julia> Pkg.add("NewsvendorModel")
```
After installation, it can be loaded with the usual command.
```julia
julia> using NewsvendorModel
```

Moreover, you need to load the Distributions.jl package.
```julia
julia> using Distributions
```

## Usage

1. Define a model with the function `nvm = NVModel(cost, price, demand)` using the following required arguments:
    - unit production `cost`
    - unit selling `price`
    - `demand` distribution, which can be any choosen from the [Distributions.jl](https://juliastats.org/Distributions.jl/latest/univariate/) package
2. Solve for optimal quanitity and obtain key metrics with the `solve(nvm)` function.

Note that additional keyword arguments can be passed in *Step 1*: `salvage` value, `holding` cost of inventory, `substitute` value obtained from a lost customer,  
`backlog` penalty of a unit, `fixcost` of the operations, a lower quantity bound `q_min`, and an upper quantity bound `q_max`. Moreover, it is possible to obtain the unrounded optimal quantity by passing `rounded=false` in *Step 2*. For more details go to [the documentation](https://frankhuettner.github.io/NewsvendorModel.jl/dev/x2_options/).  


## Example

Consider an [example](https://en.wikipedia.org/wiki/Newsvendor_model#Numerical_examples) with 
  - unit `cost` = 5  
  - unit `price` = 7
  - `demand` that draws from a normal distribution with 
     - mean = 50 
     - standard deviation = 20

Define the model and store it in the variable `nvm` as follows:

```julia
julia> nvm = NVModel(demand = Normal(50, 20), cost = 5, price = 7)
```

Julia shows the model data:
```julia
Data of the Newsvendor Model
 * Unit cost: 5.00
 * Unit selling price: 7.00
 * Demand distribution: Normal{Float64}(μ=50.0, σ=20.0)
```

Next, you can solve the model and store the result in the variable `res` like so:
```julia
julia> res = solve(nvm)
```
This gives the following output:
```julia
=====================================
Results of maximizing expected profit
 * Optimal quantity: 39 units
 * Expected profit: 52.69
=====================================
This is a consequence of
 * Cost of underage: 2.00
 * Cost of ovderage: 5.00
 * The critical fractile: 0.29
 * Rounded to closest integer: true
-------------------------------------
Ordering the optimal quantity yields
 * Expected sales: 35.38 units
 * Expected lost sales: 14.62 units
 * Expected leftover: 3.62 units
 * Expected backlog penalty: 0.00
-------------------------------------
```
Moreover, you have stored the result in the varial `res`. Reading the data from the stored result is straight-forward:
```julia
julia> q_opt(res)
39
```

```julia
julia> profit(res)
52.687735385066865
```

Analogously, `underage_cost(res)`, `overage_cost(res)`, `critical_fractile(res)`, 
`rounded(res)`, `sales(res)`, `lost_sales(res)`, `leftover(res)`, `penalty(res)`, 
read the other information the stored in `res`. The model that was solved can be retrieved with `nvmodel(res)`.
