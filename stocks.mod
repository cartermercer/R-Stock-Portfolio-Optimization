reset;

param n;
param RiskLevel; # set this RiskLevel to different levels and see how expected return changes

set STOCKS; # Stock columns to input into data
set DAYS := {1..n}; # Each row of data

# returns on assets
param Returns {DAYS,STOCKS}; 

# getting mean of stock returns for each stock
param Mean {j in STOCKS} = (sum {i in DAYS} Returns[i,j]) / n; 

# This basically finds what will be used in the numerator for covariance formula for each stock
# (i.e. (x - xbar) )
param Difference {i in DAYS, j in STOCKS} = Returns[i,j] - Mean[j];

# Calculate Covariances
param Covar {i in STOCKS, j in STOCKS} = sum {k in DAYS} (Difference[k,i]*Difference[k,j] / (n-1));

# These are the weights, decision variables, that will be assigned to each stock in the portfolio
var W {STOCKS} >=0;

# This Variance variable is set here to be used for printing data later
var Variance = sum {i in STOCKS} (W[i]*(sum {j in STOCKS} Covar[i,j]*W[j]));

# Objective Function
maximize ExpReturn: sum {j in STOCKS} Mean[j] * W[j];

# Constraints
subject to TotalWeights: sum {j in STOCKS} W[j] = 1;
subject to Risk: sum {i in STOCKS} (W[i]*(sum {j in STOCKS} Covar[i,j]*W[j])) <= RiskLevel;








