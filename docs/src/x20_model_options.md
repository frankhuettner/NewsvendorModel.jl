# Further options when specifying the model

You can pass the following optional keyword arguments in the *definition* of a newsvendor model `NVModel(demand [; kwargs])`:

- `cost` for a unit; defaults to `0`
- `price` for selling a unit; defaults to `0`
- `salvage` value obtained from scraping a leftover unit; defaults to `0`
- `holding` cost obtained from a leftover unit, e.g., extra captial cost or warehousing cost; essentially a negative salvage value; defaults to `0`
- `backlog` penalty for being short a unit, e.g., contractual penalty for missing delivery targets or missed future profit of an unserved customer; defaults to `0`
- `substitute` benefit received from selling to an unserved customer, e.g., when selling another product or serving in the future; essentially a negative backlog penalty; defaults to `0`
- `fixcost` fixed cost of operations; defaults to `0`
- `q_min` minimal feasible quantity, e.g., due to production limits; must be nonnegative; defaults to `0`
- `q_max` maximal feasible quantity, e.g., due to production limits; must be greater than or equal to `q_min`; defaults to `Inf`




## Example

Define a newsvendor problem with unit cost 5, unit price 7, normal demand
around 50 with standard deviation 20, where a unit salvages for 0.5, and back order incurs at a penalty of 2 per unit, as follows:

```jldoctest mdloptions; setup = :(using Distributions, NewsvendorModel)
julia> nvm2 = NVModel(cost = 5, price = 7, demand = Normal(50, 20), salvage = 0.5, backlog = 2)
Data of the Newsvendor Model
 * Unit cost: 5.00
 * Unit selling price: 7.00
 * Demand distribution: Normal{Float64}(μ=50.0, σ=20.0)
 * Unit salvage value: 0.50
 * Unit backlog penalty: 2.00
```

Note that cost, price, and demand are necessary arguments that can be passed without keyword. Moreover, only values that differ from the default value will be shown in the REPL. For instance, adding `q_min=0` does not have an impact.

```jldoctest mdloptions
julia> nvm3 = NVModel(demand = Normal(50, 20), cost = 5, price = 7, salvage = 0.5, backlog = 2, q_min=0)
Data of the Newsvendor Model
 * Unit cost: 5.00
 * Unit selling price: 7.00
 * Demand distribution: Normal{Float64}(μ=50.0, σ=20.0)
 * Unit salvage value: 0.50
 * Unit backlog penalty: 2.00
```

```jldoctest mdloptions
julia> nvm3 == nvm2
true
```