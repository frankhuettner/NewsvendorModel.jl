# Rounded

Let us assume that we do not want the integer quantity but the exact real number. To this end, we need to call the `solve` function with the additional argument `rounded = false`

## Example

```julia
julia> nvm = NVModel(2, 7, Normal(50, 20))
Data of the Newsvendor Model
 * Unit cost: 2.00
 * Unit selling price: 7.00
 * Demand distribution: Normal{Float64}(μ=50.0, σ=20.0)

julia> res_real = solve(nvm, rounded = false)
=====================================
Results of maximizing expected profit
 * Optimal quantity: 61.32
 * Expected profit: 202.41
=====================================
This is a consequence of
 * Cost of underage: 5.00
 * Cost of overage: 2.00
 * The critical fractile: 0.71
 * Rounded to closest integer: false
-------------------------------------
Ordering the optimal quantity yields
 * Expected sales: 46.44 units
 * Expected lost sales: 3.56 units
 * Expected leftover: 14.88 units
-------------------------------------
```

This reveals a slighlty higher profit than with the standard (rounded up) integer result:

```julia
julia> q_opt(nvm)
61

julia> profit(res_real)
202.41322650461186

julia> profit(nvm)
202.40715617998893
```

`rounded(res_real)` applied to a result tells whether the integer result was looked for is.

```julia
julia> rounded(res_real)
false
```