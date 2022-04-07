nvm = NVModel(truncated(Normal(90, 30), lower = 0, upper = 180), cost = 1, price = 5)

@test lost_sales(nvm::NVModel, [111]) == lost_sales(nvm, 111) 
@test lost_sales(nvm::NVModel, [0]) == lost_sales(nvm, 0) 
@test 2 * lost_sales(nvm::NVModel, [111, 0]) == lost_sales(nvm, 111) + lost_sales(nvm, 0) 

@test sales(nvm::NVModel, [111]) == sales(nvm, 111) 
@test sales(nvm::NVModel, [0]) == sales(nvm, 0) 
@test 2 * sales(nvm::NVModel, [111, 0]) == sales(nvm, 111) + sales(nvm, 0) 

@test leftover(nvm::NVModel, [111]) == leftover(nvm, 111) 
@test leftover(nvm::NVModel, [0]) == leftover(nvm, 0) 
@test 2 * leftover(nvm::NVModel, [111, 0]) == leftover(nvm, 111) + leftover(nvm, 0) 

@test profit(nvm::NVModel, [111]) == profit(nvm, 111) 
@test profit(nvm::NVModel, [0]) == profit(nvm, 0) 
@test 2 * profit(nvm::NVModel, [111, 0]) == profit(nvm, 111) + profit(nvm, 0) 
