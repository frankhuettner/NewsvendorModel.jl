## Defining and showing some examples
cheers_1 = NVModel(1, 5, truncated(Normal(90, 30), 0, 180) )   
@test_nowarn show(cheers_1)

cheers_2 = NVModel(4.0, 5.5, Uniform(0, 60))
@test_nowarn show(cheers_2)

cheers_4 = NVModel(cost=10, price=42, demand=DiscreteNonParametric([0,1,2],[.3,.5,.2]))
@test_nowarn show(cheers_4)

bagel = NVModel(1, 4, Normal(150, 50))
@test_nowarn show(bagel)

xs = vec([5_000	10_000	15_000	20_000	25_000	30_000	35_000	40_000	45_000	50_000	55_000	60_000	65_000	70_000	75_000])
ps = vec([0.0181	0.0733	0.1467	0.1954	0.1954	0.1563	0.1042	0.0595	0.0298	0.0132	0.0053	0.0019	0.0006	0.0002	0.0001])
elvis = NVModel(6, 12, DiscreteNonParametric(xs,ps), salvage = 2.5)
@test_nowarn show(elvis)

ksweet = NVModel(28, 45, Binomial(2000, 0.02), salvage = 27)
@test_nowarn show(ksweet)

beer = NVModel(0, 0, Uniform(0, 300), backlog = 1, salvage = -0.5)
@test_nowarn show(beer)

maxtest = NVModel(0, 3, Normal(90, 30), fixcost = 100, q_min=90, q_max = 120)
@test_nowarn show(maxtest) 

mintest = NVModel(1, 0, Normal(90, 30), q_min=90, q_max = 120)
@test_nowarn show(mintest) 

unboundtest = NVModel(0, 3, Normal(90, 30), q_min=90)
@test_nowarn show(unboundtest) 


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



