# Further options for specifiying the model

You can pass the following optional keyword arguments in the *definition* of a newsvendor model `NVModel(cost, price, demand [; kwargs])`:

- `salvage` value obtained from scraping a leftover unit; might be negative, e.g., due to disposal cost, extra captial cost, or warehousing cost; defaults to 0
- `backlog` penalty for being short a unit, e.g., contractual penalty for missing delivery targets or missed future profit of an unserved customer; defaults to 0
- `fixcost` fixed cost of operations; defaults to 0
- `q_min` minimal feasible quantity, e.g., due to production limits; must be nonnegative; defaults to 0
- `q_max` maximal feasible quantity, e.g., due to production limits; must be greater than or equal to `q_min`; defaults to `Inf`inity



## Example

Define a newsvendor problem with unit cost 5, unit price 7, normal demand
around 50 with standard deviation 20, where a unit salvages for 0.5, and back order incurs at a penalty of 2 per unit, as follows:

```julia
julia> nvm2 = NVModel(cost = 5, price = 7, demand = Normal(50, 20), salvage = 0.5, backlog = 2)
Data of the Newsvendor Model
 * Unit cost: 5.00
 * Unit selling price: 7.00
 * Demand distribution: Normal{Float64}(μ=50.0, σ=20.0)
 * Unit salvage value: 0.50
 * Unit backlog penalty: 2.00
```

Note that cost, price, and demand are necessary arguments that can be passed without keyword. Moreover, only values that differ from the default value will be shown in the REPL. For instance, adding `q_min=0.0` does not have an impact.

```julia
julia> nvm3 = NVModel(5, 7, Normal(50, 20), salvage = 0.5, backlog = 2, q_min=0.0)
Data of the Newsvendor Model
 * Unit cost: 5.00
 * Unit selling price: 7.00
 * Demand distribution: Normal{Float64}(μ=50.0, σ=20.0)
 * Unit salvage value: 0.50
 * Unit backlog penalty: 2.00
julia> nvm3 == nvm2
true
```