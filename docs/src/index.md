# Quick start

This is a lightweight and simple Julia package for modeling and solving [newsvendor problems](https://en.wikipedia.org/wiki/Newsvendor_model).

## Setup

NewsvendorModel.jl requires an installation of Julia (can be downloaded from the [official website](https://julialang.org/)). You can install NewsvendorModel.jl like any other Julia package using the REPL as follows:


```julia
julia> import Pkg
julia> Pkg.add(url="https://github.com/frankhuettner/NewsvendorModel.jl")
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
2. Find the optimal quanitity and obtain key metrics: 
    - `q_opt(nvm)` returns the quantity that maximizes the expected profit
    - `profit(nvm, q)` to get the expected profit if `q` is stocked
    - `profit(nvm)` is short for the maximal expected profit `profit(nvm, q_opt(nvm))` 
    - `solve(nvm)` gives a list of further important metrics (critical fractile as well as expected sales, lost sales, and leftover).

Additional keyword arguments specifying salvage value, backlog, fixcost, q_min, and q_max can be passed in *Step 1*. To obtain the unrounded optimal quantity, pass `rounded=false` in *Step 2*.



## Example

Consider an [example](https://en.wikipedia.org/wiki/Newsvendor_model#Numerical_examples) with 
  - unit `cost` = 5  
  - unit `price` = 7
  - `demand` that draws from a normal distribution with 
     - mean = 50 
     - standard deviation = 20

Define the model and store it in the variable `nvm` as follows:

```julia
julia> nvm = NVModel(5, 7, Normal(50, 20))
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
 * Expected profit: 52.41
=====================================
This is a consequence of
 * Cost of underage: 2.00
 * Cost of overage: 5.00
 * The critical fractile: 0.29
 * Rounded to closest integer: true
-------------------------------------
Ordering the optimal quantity yields
 * Expected sales: 35.34 units
 * Expected lost sales: 14.66 units
 * Expected leftover: 3.66 units
-------------------------------------
```
Moreover, you have stored the result in the variable `res`. Reading the data from the stored result is straight-forward:
```julia
julia> q_opt(res)
39
```

```julia
julia> profit(res)
52.40715617998893
```

Analogously, `underage_cost(res)`, `overage_cost(res)`, `critical_fractile(res)`, `sales(res)`, `lost_sales(res)`, `leftover(res)` read. 

Applying the above functions directly to the model (instead of to the result) is also possible, with the ability to pass a quantity. For instance,  

```julia
julia> leftover(nvm, 39)
3.656120545715868
```

An advantage of using the `solve` function and then reading the data from the result lies in the fact that the model that was solved can be retrieved with `nvmodel(res)`.