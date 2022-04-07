sd = SimData()

@test NewsvendorModel.likelihood_of_observed_mean(sd, 80) < 1
@test NewsvendorModel.likelihood_of_observed_mean(sd, 90) == 1.0