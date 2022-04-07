sd = SimData()
@test_nowarn NewsvendorModel.update_sim_data!(sd)

@test_nowarn NewsvendorModel.update_plot_panel_1(sd::SimData)
@test_nowarn NewsvendorModel.update_plot_panel_2(sd::SimData)



append!(sd.qs, [0, 111, 155, 115])
NewsvendorModel.update_sim_data!(sd)



@test_nowarn NewsvendorModel.update_plot_panel_1(sd::SimData)
@test_nowarn NewsvendorModel.update_plot_panel_2(sd::SimData)
@test_nowarn NewsvendorModel.update_result_figures_panel(sd::SimData)

@test_nowarn NewsvendorModel.history_table(sd::SimData)

@test_nowarn NewsvendorModel.visualize_demand_and_stock(sd::SimData)	

@test_nowarn NewsvendorModel.visualize_profit_revenue_and_cost(sd::SimData)	

@test_nowarn NewsvendorModel.update_submission_and_result_panel(sd::SimData)
@test_nowarn NewsvendorModel.update_demand_realization_panel(sd::SimData)
@test_nowarn NewsvendorModel.update_history_table(sd::SimData)



append!(sd.qs, round.(Int, rand(sd.nvm.demand, 26)))
@test_nowarn NewsvendorModel.update_sim_data!(sd)





@test_nowarn NewsvendorModel.update_plot_panel_1(sd::SimData)
@test_nowarn NewsvendorModel.update_plot_panel_2(sd::SimData)
@test_nowarn NewsvendorModel.result_figures(sd::SimData)

@test_nowarn NewsvendorModel.update_result_figures_panel(sd::SimData)


@test_nowarn NewsvendorModel.update_submission_and_result_panel(sd::SimData)
@test_nowarn NewsvendorModel.update_demand_realization_panel(sd::SimData)

@test_nowarn NewsvendorModel.describe_demand(sd.nvm)
@test_nowarn NewsvendorModel.visualize_demand(sd.nvm)
@test_nowarn NewsvendorModel.describe_cost(sd.nvm)
@test_nowarn NewsvendorModel.visualize_cost(sd.nvm)
@test_nowarn NewsvendorModel.describe(sd.nvm)


cheers4 = NVModel(cost=10, price=42, demand=DiscreteNonParametric([0,1,2],[.3,.5,.2]))

@test_nowarn NewsvendorModel.describe_demand(cheers4)
@test_nowarn NewsvendorModel.visualize_demand(cheers4)
@test_nowarn NewsvendorModel.describe_cost(cheers4)
@test_nowarn NewsvendorModel.visualize_cost(cheers4)
@test_nowarn NewsvendorModel.describe(cheers4)


@test_nowarn NewsvendorModel.update_plot_panel_1(sd::SimData)
@test_nowarn NewsvendorModel.update_plot_panel_2(sd::SimData)