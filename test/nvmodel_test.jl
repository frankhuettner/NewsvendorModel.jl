## Defining and showing some examples
cheers_1 = NVModel(truncated(Normal(90, 30), 0, 180), 1, 5, 0)   
@test_nowarn show(cheers_1)

cheers_2 = NVModel(Uniform(0, 60), 4.0, 5.5)
@test_nowarn show(cheers_2)

cheers_4 = NVModel(cost=10, price=42, demand=DiscreteNonParametric([0,1,2],[.3,.5,.2]))
@test_nowarn show(cheers_4)

bagel = NVModel(Normal(150, 50), 1, 4)
@test_nowarn show(bagel)

xs = vec([5_000	10_000	15_000	20_000	25_000	30_000	35_000	40_000	45_000	50_000	55_000	60_000	65_000	70_000	75_000])
ps = vec([0.0181	0.0733	0.1467	0.1954	0.1954	0.1563	0.1042	0.0595	0.0298	0.0132	0.0053	0.0019	0.0006	0.0002	0.0001])
elvis = NVModel(DiscreteNonParametric(xs,ps), 6, 12, 2.5)
@test_nowarn show(elvis)

ksweet = NVModel(Binomial(2000, 0.02), 28, 45, 27)
@test_nowarn show(ksweet)

beer = NVModel(Uniform(0, 300), cost = 0, price = 0, holding = 0.5, backorder = 1)
@test_nowarn show(beer)

maxtest = NVModel(Normal(90, 30), 0, 3, fixcost = 100, q_min=90, q_max = 120)
@test_nowarn show(maxtest) 

mintest = NVModel(Normal(90, 30), 1, 0, q_min=90, q_max = 120)
@test_nowarn show(mintest) 

unboundtest = NVModel(Normal(90, 30), 0, 3, q_min=90)
@test_nowarn show(unboundtest) 

thesaurus_nvm = NVModel(cost = 1.15, price = 2.75, demand = Normal(18, 6), 
                        substitute = 2.75-1.15, backorder = 0.5, salvage = 1.15, 
                        holding = 1.15 * 0.2 / 12)
@test_nowarn show(thesaurus_nvm) 

## Testing solve and showing result
res = solve(cheers_1) 
@test_nowarn show(res)
nvm = NewsvendorModel.nvmodel(res)
@test_nowarn show(nvm)

res = solve(cheers_1, rounded=false)
@test q_opt(res) == q_opt(solve(cheers_1, rounded=false))


@test_nowarn show(solve(cheers_1) )
@test_nowarn show(solve(cheers_2) )
@test_nowarn show(solve(cheers_4) )
@test_nowarn show(solve(bagel) )
@test_nowarn show(solve(elvis) )
@test_nowarn show(solve(elvis, rounded=false) )
@test_nowarn show(solve(ksweet) )
@test_nowarn show(solve(beer) )
@test_nowarn show(solve(maxtest) )
@test_nowarn show(solve(mintest) )
@test_nowarn show(solve(unboundtest) )



