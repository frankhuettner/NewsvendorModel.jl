# cheers_1 = NVModel(1, 5, truncated(Normal(90, 30), 0, 180) )   
@test leftover(cheers_1, 86) ≈  9.97386724034834
@test sales(cheers_1, 86) ≈  76.02613275965166
@test lost_sales(cheers_1, 86) ≈  13.97386724034834


@test isapprox(leftover(cheers_1, 200), 110.0)
@test sales(cheers_1, 200) ≈  90.0

@test isapprox(lost_sales(cheers_1, 200),  0.0, atol=1/1_000_000)
@test profit(cheers_1, 86) ≈  294.1306637982583
@test q_opt(cheers_1) ≈ 115
@test q_opt(cheers_1, rounded = false) ≈ 115.16195141374729
@test q_scarf(cheers_1) ≈ 112.19801383255745
@test profit_shift(cheers_1) == 0
@test q_min(cheers_1) == 0
@test q_max(cheers_1) == Inf

# cheers_2 = cheers_2 = NVModel(4.0, 5.5, Uniform(0, 60))
@test q_opt(cheers_2) ≈ 16
@test q_opt(cheers_2, rounded = false) ≈ 16.363636363636363
@test q_scarf(cheers_2) ≈ 21.161165235168156
@test profit_shift(cheers_1) == 0.0

# cheers_4 = NVModel(10, 42, DiscreteNonParametric([0,1,2],[.3,.5,.2]))
@test isapprox(lost_sales(cheers_4, 2),  0.0, atol=1/1_000_000)
@test isapprox(lost_sales(cheers_4, 3),  0.0, atol=1/1_000_000)
@test sales(cheers_4, 2) ≈  0.9
@test leftover(cheers_4, 2) ≈  1.1
@test profit(cheers_4, 2) ≈  17.8                
@test q_opt(cheers_4) ≈ 1
@test q_opt(cheers_4, rounded = false) ≈ 1
@test q_scarf(cheers_4) ≈ 1.3304430856687095

# bagel = bagel = NVModel(1, 4, Normal(150, 50))
@test q_opt(bagel) ≈ 184

# xs = vec([5_000	10_000	15_000	20_000	25_000	30_000	35_000	40_000	45_000	50_000	55_000	60_000	65_000	70_000	75_000])
# ps = vec([0.0181	0.0733	0.1467	0.1954	0.1954	0.1563	0.1042	0.0595	0.0298	0.0132	0.0053	0.0019	0.0006	0.0002	0.0001])
# elvis  = NVModel(cost = 6, price = 12, salvage = 2.5, demand = DiscreteNonParametric(xs,ps))
@test lost_sales(elvis, 50_000) ≈  61.0
@test sales(elvis, 50_000) ≈   24939.0
@test leftover(elvis, 50_000) ≈  25_061.0
@test profit(elvis, 75_000) ≈ -25000.0
@test q_opt(elvis) ≈ 30000
@test q_opt(elvis, rounded = false) ≈ 30_000
@test q_scarf(elvis) ≈ 27726.15473567755

# ksweet = NVModel(d = Binomial(2000, 0.02), c = 28, p = 45, salvage = 27)
@test q_opt(ksweet) == 50
@test q_opt(ksweet, rounded = false)  == 50
@test q_scarf(ksweet) ≈ 52.14810563784474
@test profit(ksweet, 50)  ≈  666.8822263692309


# poisson distribution
m = NVModel(Poisson(90), 0, 3, q_min=90, q_max = 120)
@test q_opt(m) == 120.0
@test leftover(m, 120.0) == 30.003682468511524
@test profit(m, 120.0) == 269.98895259446545

# lognormal distribution
x̄ = 1000
var = 600^2 
σ = log(var/ x̄^2 + 1)
μ = log(x̄) - σ^2 / 2 
flextrola_demand = LogNormal(μ, σ)
flextrola = NVModel(cost = 72, 
                    price = 121,
                    salvage = 50, 
                    demand = flextrola_demand
                    )
@test q_opt(flextrola) == 1111 

solve(flextrola)

## backorder penalty
beer = NVModel(Uniform(0, 300), cost = 0, price = 0, backorder = 1, salvage = -0.5)
@test q_opt(beer) == 200

# holding cost and substitute profit
thesaurus_nvm = NVModel(cost = 1.15, price = 2.75, demand = Normal(18, 6), 
                        substitute = 2.75-1.15, backorder = 0.5, salvage = 1.15, 
                        holding = 1.15 * 0.2 / 12)
solve(thesaurus_nvm)
@test q_opt(thesaurus_nvm) == 29 


## Incpomplete struct
                 
struct IncompleteScenario <: AbstractNewsvendorProblem end
concreteIncompleteScenario = IncompleteScenario()
@test_throws ErrorException underage_cost(concreteIncompleteScenario)
@test_throws ErrorException overage_cost(concreteIncompleteScenario)
@test_throws ErrorException distr(concreteIncompleteScenario)
@test_throws ErrorException profit_shift(concreteIncompleteScenario)
@test_throws ErrorException q_min(concreteIncompleteScenario)
@test q_max(concreteIncompleteScenario) == Inf
@test_throws ErrorException profit(concreteIncompleteScenario)


## Boundary cases 

# If there is no penalty in ordering too much
m = NVModel(Normal(90, 30), 0, 3)
@test q_opt(m) == Inf
@test profit(m, q_opt(m)) == 270.00


# If there is no penalty in ordering too much but a limit
m = NVModel(Normal(90, 30), 0, 3, q_min=90, q_max = 120)
@test q_opt(m) == 120.00


# If there is no point in ordering
m = NVModel(Normal(90, 30), 4, 3, fixcost = 100)
@test q_opt(m) == 0
@test profit(m, q_opt(m)) == -100.0343938885343

# If there is no point in ordering but we are forced to
m = NVModel(Normal(90, 30), 4, 3, q_min = 20, fixcost = 100)
@test q_opt(m) == 20
@test profit(m, q_opt(m)) ≈ -120.29875100641834
@test profit(m) ≈ -120.29875100641834


# If rounding exceeds q_min
m = NVModel(Normal(90, 30), 1, 5, q_min = 115.1)
@test q_opt(m, rounded = false) == 115.24863700718743
@test q_opt(m) == q_min(m)

# If rounding exceeds q_max
m = NVModel(Normal(90, 28), 1, 5, q_min = 20, q_max = 113.9)
@test q_opt(m, rounded = false) == 113.56539454004161
@test q_opt(m) == q_max(m)