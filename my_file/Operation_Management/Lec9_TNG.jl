# To run the code, first specify the location of the file with command cd("path")
# then use command include("file name")

# Pkg.add(“DataFrames") # first add this package
using DataFrames
using JuMP, Gurobi

# Define our model
function TNG(Demand1, Demand4, Demand8, Demand16)

# Silence the solver
m = Model(solver=GurobiSolver(OutputFlag=0))

# Define variable - How many leases to accept
@variable(m, 0<= Accept1[t=1:50] <= Demand1[t] )
@variable(m, 0<= Accept4[t=1:50] <= Demand4[t] )
@variable(m, 0<= Accept8[t=1:50] <= Demand8[t] )
@variable(m, 0<= Accept16[t=1:50] <= Demand16[t] )

# Define variable - inventory
@variable(m, Inventory[1:50] >= 0 )

# Define variables - trailer returns
@variable(m, Return1[1:50] >= 0 )
@constraint(m, Return1[1] == OldReturn1[1] )
for t=2:50
  @constraint(m, Return1[t] == Accept1[t-1] )
end

# Similarly for the others
@variable(m, Return4[1:50] >= 0 )
for t=1:4
  @constraint(m, Return4[t] == OldReturn4[t] )
end
for t=5:50
  @constraint(m, Return4[t] == Accept4[t-4] )
end

@variable(m, Return8[1:50] >= 0 )
for t=1:8
  @constraint(m, Return8[t] == OldReturn8[t] )
end
for t=9:50
  @constraint(m, Return8[t] == Accept8[t-8] )
end

@variable(m, Return16[1:50] >= 0 )
for t=1:16
  @constraint(m, Return16[t] == OldReturn16[t] )
end
for t=17:50
  @constraint(m, Return16[t] == Accept16[t-16] )
end

# Maximize revenue
@objective(m, Max, 7*sum{Price1[t]*Accept1[t] + 4*Price4[t]*Accept4[t] + 8*Price8[t]*Accept8[t] + 16*Price16[t]*Accept16[t], t=1:50} )

# Inventory constraints
# First period
@constraint(m, Inventory[1] == Inventory_Start + Return1[1] + Return4[1] + Return8[1] + Return16[1] )
# Other periods
for t=2:50
  @constraint(m, Inventory[t] == Inventory[t-1] - Accept1[t-1] - Accept4[t-1] - Accept8[t-1] - Accept16[t-1]
                            + Return1[t] + Return4[t] + Return8[t] + Return16[t] )
end
# Cannot accept more leases than current inventory
# We have given these constraints a name so that we can refer to them later
@constraint(m, InvConst[t=1:50], Accept1[t] + Accept4[t] + Accept8[t] + Accept16[t] <= Inventory[t] )


status = solve(m);

return status, getvalue(Accept1)[:], getvalue(Accept4)[:], getvalue(Accept8)[:], getvalue(Accept16)[:], getvalue(Inventory)[:],
      getdual(InvConst)[:], getobjectivevalue(m)
end

# Run model on real demand
# This is the optimal solution with perfect knowledge
println("Running model on real demand")
status_real, Accept1_real, Accept4_real, Accept8_real, Accept16_real, Inventory_real, ShadowPrice_real, obj_real = TNG(Demand1_real, Demand4_real, Demand8_real, Demand16_real);
println("Objective value is: ", round(obj_real,2) )
println("1-week leases accepted: ", floor(Integer, Accept1_real))
println("4-week leases accepted: ", floor(Integer, Accept4_real))
println("8-week leases accepted: ", floor(Integer, Accept8_real))
println("16-week leases accepted: ", floor(Integer, Accept16_real))
println("Beginning inventory: ", floor(Integer, Inventory_real))
println("Shadow prices of inventory: ", round(ShadowPrice_real,2), "\n")


# Show TNG solution
# This is what actually happened
println("TNG performance in reality:")
println("1-week leases accepted: ", Accept1_TNG )
println("4-week leases accepted: ", Accept4_TNG )
println("8-week leases accepted: ", Accept8_TNG )
println("16-week leases accepted: ", Accept16_TNG )
println("TNG achieved: 4713704.38\n")

# Show revenue improvement opportunity
RevIncrease = ((obj_real-4713704.38)/4713704.38)*100
println("Upper bound of revenue improvement: ", round(RevIncrease,2), "%")
