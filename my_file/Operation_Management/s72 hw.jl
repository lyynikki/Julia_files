
using Distributions
using DataFrames
df = readtable("/Users/lyynikki/Desktop/Course/15.s72/hw/15.s72+HW9/training.csv")

function eps_greedy(eps, revenue)
    counts = zeros(3); 
    rewards = zeros(3); 
    record_pulls = []; 
    horizon = length(revenue[1]);
    for t=1:horizon
        next_arm = (rand() <= eps ? rand(1:3) : indmax(rewards./counts) ) 
        counts[next_arm] += 1
        rewards[next_arm] += revenue[t,next_arm]
        push!(record_pulls, next_arm)
    end
    return rewards,sum(rewards),record_pulls,counts
end

function eps_decreasing(eps, revenue,drate)
    counts = zeros(3); 
    rewards = zeros(3); 
    record_pulls = []; 
    horizon = length(revenue[1])
    for t=1:horizon
        next_arm = (rand() <= eps ? rand(1:3) : indmax(rewards./counts) )
        counts[next_arm] += 1
        rewards[next_arm] += revenue[t,next_arm]
        push!(record_pulls, next_arm)
        eps *= drate
    end
    return rewards,sum(rewards),record_pulls,counts
end

function thompson(revenue) 
    counts = zeros(3);
    rewards = zeros(3);
    record_pulls = []; 
    a = ones(3);
    b = ones(3);
    nets = zeros(3);
    netf = zeros(3);
    horizon = length(revenue[1])
    for t=1:horizon
        sampled_parameters = (rand(Beta(a[1],b[1])),rand(Beta(a[2],b[2])),rand(Beta(a[3],b[3])))
        next_arm = indmax(sampled_parameters) 
        nets[next_arm] = revenue[t,next_arm]
        netf[next_arm] = 1 - nets[next_arm]
        rewards[next_arm] += revenue[t,next_arm]
        counts[next_arm] += 1
        a += nets
        b += netf
        nets = zeros(3)
        netf = zeros(3)
        push!(record_pulls, next_arm)
    end
    return rewards,sum(rewards),counts
end

for parameter1=0.02:0.02:0.4 
    score,total,record,counts = eps_greedy(parameter1,df)
    println("For parameter1=$parameter1, eps_greedy scored $score, total=$total")
end


for parameter2=0.1:0.1:1 
    for drate = 0.8:0.01:0.99
        score,total,record,counts = eps_decreasing(parameter2,df,drate)
        println("For parameter2=$parameter2, decreasing rate = $drate,eps_decreasing scored $score, total=$total")
    end
end

score, total,counts = thompson(df)
println("thompson rewards = thompson $score, total=$total")

test1 = readtable("/Users/lyynikki/Desktop/Course/15.s72/hw/15.s72+HW9/Test1.csv")
test2 = readtable("/Users/lyynikki/Desktop/Course/15.s72/hw/15.s72+HW9/Test2.csv")

parameter1=0.08 
score,total,record,counts = eps_greedy(parameter1,test1)
println("For parameter1=$parameter1, eps_greedy scored $score, total=$total")
drate = 0.92
parameter2=0.2
score,total,record,counts = eps_decreasing(parameter2,test1,drate)
println("For parameter2=$parameter2, drate = $drate, eps_decreasing scored $score, total=$total")
score, total,counts = thompson(test1)
println("thompson rewards = $score, total=$total")

parameter1=0.08 
score,total,record,counts = eps_greedy(parameter1,test2)
println("parameter1=$parameter1, eps_greedy scored $score, total=$total")
drate = 0.92
parameter2=0.2
score,total,record,counts = eps_decreasing(parameter2,test2,drate)
println("For parameter2=$parameter2, drate = $drate, eps_decreasing scored $score, total=$total")
score, total,counts = thompson(test2)
println("thompson rewards = thompson $score, total=$total")

parameter1=0.08 
drate = 0.92
parameter2=0.2
score1,total1,record1,counts1 = eps_greedy(parameter1,test1)
score2,total2,record2,counts2 = eps_decreasing(parameter2,test1,drate)
score3, total3,counts3 = thompson(test1)
thompson_best = indmax(score3 ./ counts3)
eps_greedy_best = indmax(score1 ./ counts1)
eps_decreasing_best = indmax(score2 ./ counts2)
println("For test 1 dataset, the best drug: $eps_greedy_best, $eps_decreasing_best, $thompson_best")

parameter1=0.08 
drate = 0.92
parameter2=0.2
score1,total1,record1,counts1 = eps_greedy(parameter1,test2)
score2,total2,record2,counts2 = eps_decreasing(parameter2,test2,drate)
score3, total3,counts3 = thompson(test2)
thompson_best = indmax(score3 ./ counts3)
eps_greedy_best = indmax(score1 ./ counts1)
eps_decreasing_best = indmax(score2 ./ counts2)
println("For test 2 dataset, the best drug: $eps_greedy_best, $eps_decreasing_best, $thompson_best")




