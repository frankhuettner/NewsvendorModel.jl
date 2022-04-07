
sd = SimData()
@test q_opt(sd.nvm) == 115

@test_nowarn NewsvendorModel.update_sim_data!(sd) 

push!(sd.qs, 0)
NewsvendorModel.update_sim_data!(sd)

@test sd.expected_profits == profit(sd.nvm, 0)

push!(sd.qs, 115)
NewsvendorModel.update_sim_data!(sd)

@test sd.expected_profits ==  profit(sd.nvm) / 2

@test is_running(sd)

sd2 = NewsvendorModel.partialcopy(sd)

@test sd2 != sd

@test sd2.qs == sd.qs